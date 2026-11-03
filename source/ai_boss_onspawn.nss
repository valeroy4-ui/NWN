#include "crift_inc"
void main()
{
    ExecuteScript("crf_base_boss", OBJECT_SELF);
    // The original may already have rolled a mutation; never stack it.
    CRF_Enhance(OBJECT_SELF);
}
