#include "_inc_death"

const int DIALOG_GRAVESTONE_ACTION_PRAY     = 1;
const int DIALOG_GRAVESTONE_ACTION_CRASH    = 2;

void main()
{
    object oGraveStone = OBJECT_SELF;
    object oPC = GetPCSpeaker();

    int iDialogGraveStoneActionType = StringToInt(GetScriptParam("DIALOG_GRAVESTONE_ACTION_TYPE"));

    switch (iDialogGraveStoneActionType)
    {
        case DIALOG_GRAVESTONE_ACTION_PRAY:
            OnPrayAtGraveStone(oGraveStone, oPC);
        break;
        case DIALOG_GRAVESTONE_ACTION_CRASH:
            OnCrashGraveStone(oGraveStone, oPC);
        break;
    }
}
