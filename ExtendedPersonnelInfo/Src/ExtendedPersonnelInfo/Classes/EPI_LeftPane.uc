class EPI_LeftPane extends EPI_SidePane;

simulated function InitLeftPane()
{
	local float PersonnelX;
	local float PersonnelY;

	PersonnelX = 480;
	PersonnelY = 90;

	InitSidePane(PersonnelX - TargetWidth - 10, PersonnelY, name("LeftPane"));
}

simulated function CreateContentFor (XComGameState_Unit Unit)
{
	local float YOffset;
	local EPI_Section Headshot, Bonds;

	YOffset = 0;

	Headshot = Spawn(class'EPI_Section_Headshot', InfoContainer);
	Headshot.OwningPane = self;
	Headshot.InitAndDisplay(Unit, YOffset);

	Bonds = Spawn(class'EPI_Section_Bonds', InfoContainer);
	Bonds.OwningPane = self;
	Bonds.InitAndDisplay(Unit, YOffset);
}