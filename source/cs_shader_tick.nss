#include "_inc_telegraph"
void main()
{
    object pc=GetFirstPC(); int counter=GetMicrosecondCounter();
    while(GetIsObjectValid(pc)) { SetShaderUniformInt(pc,SHADER_UNIFORM_16,counter); pc=GetNextPC(); }
    DelayCommand(1.0 / TARGET_FPS,ExecuteScript("cs_shader_tick",GetModule()));
}
