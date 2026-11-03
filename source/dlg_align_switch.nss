void main()
{
    object oPC    = GetPCSpeaker();
    int iAligment = StringToInt(GetScriptParam("ALIGNMENT_CATEGORY"));
    AdjustAlignment(oPC, iAligment, 100, 0);
}


