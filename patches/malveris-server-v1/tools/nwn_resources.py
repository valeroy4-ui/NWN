"""Strict, dependency-free readers for NWN ERF/MOD and typed GFF V3.2 resources."""
import struct

def _erf_selected(read_at,size,wanted):
    """Inspect only dependencies being verified; never resolve conflicting variants.

    Unrelated duplicate keys in a third-party HAK do not make a Daily dependency
    ambiguous. Equal copies are equivalent; different relevant copies fail closed.
    """
    header=read_at(0,160)
    if len(header)<160 or header[:8] not in (b'MOD V1.0',b'HAK V1.0',b'ERF V1.0'):
        raise ValueError('Expected an ERF/MOD/HAK V1.0 archive')
    count=struct.unpack_from('<I',header,16)[0];keys,rows=struct.unpack_from('<II',header,24)
    if (count and min(keys,rows)<160) or keys+24*count>size or rows+8*count>size:
        raise ValueError('Archive directory outside file')
    directory=read_at(keys,24*count)
    if len(directory)!=24*count:raise ValueError('Truncated archive key directory')
    requested={(name.lower().encode('ascii'),typ) for name,typ in wanted};result={}
    for i in range(count):
        name,rid,typ=struct.unpack_from('<16sIH',directory,24*i);raw=name.split(b'\0',1)[0].lower()
        if (raw,typ) not in requested:continue
        key=(raw.decode('ascii'),typ);label=key[0]+' (type '+str(typ)+')'
        if rid>=count:raise ValueError('Invalid resource ID '+str(rid)+'/'+str(count)+' for '+label)
        row=read_at(rows+8*rid,8)
        if len(row)!=8:raise ValueError('Truncated resource row for '+label)
        start,length=struct.unpack('<II',row)
        if start+length>size:raise ValueError('Resource outside file: '+label)
        blob=read_at(start,length)
        if len(blob)!=length:raise ValueError('Truncated resource: '+label)
        if key in result and result[key]!=blob:
            raise ValueError('Conflicting copies of required resource: '+label)
        result[key]=blob
    return result

def erf_selected(data,wanted):
    return _erf_selected(lambda offset,length:data[offset:offset+length],len(data),wanted)

def erf_selected_file(path,wanted):
    """Read a HAK directory and selected payloads without loading a large HAK."""
    with path.open('rb') as stream:
        stream.seek(0,2);size=stream.tell()
        def read_at(offset,length):
            stream.seek(offset);return stream.read(length)
        return _erf_selected(read_at,size,wanted)

def erf_index(data):
    if len(data)<160 or data[:8] not in (b'MOD V1.0',b'HAK V1.0',b'ERF V1.0'):
        raise ValueError('Expected an ERF/MOD V1.0 archive')
    count=struct.unpack_from('<I',data,16)[0];keys,rows=struct.unpack_from('<II',data,24)
    if keys+24*count>len(data) or rows+8*count>len(data):raise ValueError('Archive directory outside file')
    result={}
    for i in range(count):
        name,rid,kind=struct.unpack_from('<16sIH',data,keys+24*i);key=(name.split(b'\0',1)[0].decode('ascii').lower(),kind)
        if rid>=count or key in result:raise ValueError('Ambiguous archive resource directory')
        start,size=struct.unpack_from('<II',data,rows+8*rid)
        if start+size>len(data):raise ValueError('Archive resource outside file')
        result[key]=data[start:start+size]
    return result

def gff_read(data):
    if len(data)<56 or data[4:8]!=b'V3.2':raise ValueError('Expected GFF V3.2')
    so,sn,fo,fn,lo,ln,do,dn,io,inn,lso,lsn=struct.unpack_from('<12I',data,8)
    for start,size in ((so,sn*12),(fo,fn*12),(lo,ln*16),(do,dn),(io,inn),(lso,lsn)):
        if start+size>len(data):raise ValueError('GFF section outside file')
    labels=[data[lo+i*16:lo+(i+1)*16].split(b'\0',1)[0].decode('ascii') for i in range(ln)]
    active=set()
    def node(index):
        if not 0<=index<sn or index in active:raise ValueError('Invalid or cyclic GFF struct')
        active.add(index);sid,start,count=struct.unpack_from('<III',data,so+index*12);fields={}
        if count>fn:raise ValueError('Invalid GFF field count')
        indices=([start] if count==1 else struct.unpack_from('<'+'I'*count,data,io+start)) if count else []
        for i in indices:
            if i>=fn:raise ValueError('Invalid GFF field index')
            typ,label,value=struct.unpack_from('<III',data,fo+i*12)
            if label>=ln or labels[label] in fields:raise ValueError('Invalid or duplicate GFF label')
            if typ in (0,1,2,3,4,5,8):v=value
            elif typ in (6,7,9):v=data[do+value:do+value+8]
            elif typ in (10,12,13):
                size=struct.unpack_from('<I',data,do+value)[0];v=data[do+value:do+value+4+size]
            elif typ==11:v=data[do+value:do+value+1+data[do+value]]
            elif typ==14:v=node(value)
            elif typ==15:
                size=struct.unpack_from('<I',data,lso+value)[0]
                if size>sn:raise ValueError('Invalid GFF list count')
                v=[node(struct.unpack_from('<I',data,lso+value+4+j*4)[0]) for j in range(size)]
            elif typ in (16,17):v=data[do+value:do+value+(16 if typ==16 else 12)]
            else:raise ValueError('Unsupported GFF field type')
            fields[labels[label]]=[typ,v]
        active.remove(index);return [sid,fields]
    return data[:4],node(0)

def text(field):
    typ,value=field
    if typ==10:return value[4:].decode('utf-8',errors='replace')
    if typ==11:return value[1:].decode('ascii')
    if typ==12:
        count=struct.unpack_from('<I',value,8)[0];offset=12;strings=[]
        for _ in range(count):
            language,size=struct.unpack_from('<II',value,offset);offset+=8
            strings.append((language,value[offset:offset+size].decode('utf-8',errors='replace')));offset+=size
        return next((v for lang,v in strings if lang==0),strings[0][1] if strings else '')
    return ''

def value(fields,key,default=''):
    field=fields.get(key)
    return text(field) if field and field[0] in (10,11,12) else field[1] if field else default

def gff_write(kind,root):
    """Serialize the typed tree without converting integer/float bit patterns."""
    structs=[];fields=[];labels=[];data=bytearray();indices=bytearray();lists=bytearray()
    def add(node):
        index=len(structs);structs.append(None);sid,values=node;own=[]
        for label,(typ,value_) in values.items():
            if label not in labels:labels.append(label)
            if typ in (0,1,2,3,4,5,8):v=value_
            elif typ==14:v=add(value_)
            elif typ==15:
                children=[add(n) for n in value_];v=len(lists);lists.extend(struct.pack('<I',len(children)))
                for child in children:lists.extend(struct.pack('<I',child))
            else:v=len(data);data.extend(value_)
            own.append(len(fields));fields.append((typ,labels.index(label),v))
        if len(own)==1:start=own[0]
        elif own:
            start=len(indices);indices.extend(struct.pack('<'+'I'*len(own),*own))
        else:start=0
        structs[index]=(sid,start,len(own));return index
    add(root)
    ss=b''.join(struct.pack('<III',*x) for x in structs);ff=b''.join(struct.pack('<III',*x) for x in fields)
    ll=b''.join(x.encode('ascii').ljust(16,b'\0') for x in labels)
    so=56;fo=so+len(ss);lo=fo+len(ff);do=lo+len(ll);io=do+len(data);lso=io+len(indices)
    result=kind+b'V3.2'+struct.pack('<12I',so,len(structs),fo,len(fields),lo,len(labels),do,len(data),io,len(indices),lso,len(lists))+ss+ff+ll+data+indices+lists
    if gff_read(result)!=(kind,root):raise ValueError('GFF serialization verification failed')
    return result

def erf_update(original,updates):
    """Append changed data and a new directory. Every untouched payload is reused."""
    old=erf_index(original);count=struct.unpack_from('<I',original,16)[0];ko,ro=struct.unpack_from('<II',original,24)
    locations={};tails={}
    for i in range(count):
        name,rid,typ=struct.unpack_from('<16sIH',original,ko+24*i);key=(name.split(b'\0',1)[0].decode('ascii').lower(),typ)
        locations[key]=struct.unpack_from('<II',original,ro+8*rid);tails[key]=original[ko+24*i+22:ko+24*i+24]
    result=bytearray(original)
    for key,payload in updates.items():
        if len(key[0])>16 or key[0]!=key[0].lower():raise ValueError('Invalid resource name')
        locations[key]=(len(result),len(payload));result.extend(payload)
    key_start=len(result)
    for i,key in enumerate(locations):result.extend(struct.pack('<16sIH',key[0].encode('ascii'),i,key[1])+tails.get(key,b'\0\0'))
    row_start=len(result)
    for start,size in locations.values():result.extend(struct.pack('<II',start,size))
    struct.pack_into('<I',result,16,len(locations));struct.pack_into('<II',result,24,key_start,row_start)
    expected=old.copy();expected.update(updates)
    if erf_index(result)!=expected:raise ValueError('ERF update verification failed')
    return bytes(result)

def resref(s):
    raw=s.encode('ascii');return [11,bytes([len(raw)])+raw]

def locstring(s):
    raw=s.encode('utf-8');body=struct.pack('<III',0xffffffff,1,0)+struct.pack('<I',len(raw))+raw
    return [12,struct.pack('<I',len(body))+body]

def erf_rebuild(original,updates=None,remove=()):
    """Compact the current resource map, dropping removed and orphaned payloads."""
    resources=erf_index(original);resources={k:v for k,v in resources.items() if k not in set(remove)};resources.update(updates or {})
    header=bytearray(original[:160]);length=struct.unpack_from('<I',header,12)[0];offset=struct.unpack_from('<I',header,20)[0]
    if offset+length>len(original):raise ValueError('Localized archive description outside file')
    localized=original[offset:offset+length];count=len(resources);keys_start=160+len(localized);rows_start=keys_start+24*count;data_start=rows_start+8*count
    keys=bytearray();rows=bytearray();payload=bytearray()
    for i,((name,typ),blob) in enumerate(resources.items()):
        if len(name)>16:raise ValueError('Resource name too long')
        keys.extend(struct.pack('<16sIH2x',name.encode('ascii'),i,typ));rows.extend(struct.pack('<II',data_start+len(payload),len(blob)));payload.extend(blob)
    struct.pack_into('<4I',header,16,count,160,keys_start,rows_start)
    result=bytes(header+localized+keys+rows+payload)
    if erf_index(result)!=resources:raise ValueError('Compacted archive verification failed')
    return result
