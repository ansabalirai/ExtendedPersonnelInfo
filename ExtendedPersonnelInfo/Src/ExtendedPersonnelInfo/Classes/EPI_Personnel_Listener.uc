class EPI_Personnel_Listener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIPersonnel Personnel;
	local EPI_DetailsBox DetailsBox;

	Personnel = UIPersonnel(Screen);
	if (Personnel == none) return;

	DetailsBox = Personnel.Spawn(class'EPI_DetailsBox', Personnel);
	
	DetailsBox.Personnel = Personnel;
	DetailsBox.InitDetailsBox();
}

defaultproperties
{
	// We don't use ScreenClass as it doesn't account for inheritance
	ScreenClass = none;
}