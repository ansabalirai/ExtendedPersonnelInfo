class EPI_PersonnelListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIPersonnel Personnel;
	local EPI_Main Main;

	Personnel = UIPersonnel(Screen);
	if (Personnel == none) return;

	Main = Personnel.Spawn(class'EPI_Main', Personnel);
	Main.Personnel = Personnel;
	Main.InitEPIMain();
}

defaultproperties
{
	// We don't use ScreenClass as it doesn't account for inheritance
	ScreenClass = none;
}