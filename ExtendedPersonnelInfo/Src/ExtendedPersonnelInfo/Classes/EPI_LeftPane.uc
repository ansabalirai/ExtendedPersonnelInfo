class EPI_LeftPane extends EPI_SidePane;

simulated function InitLeftPane()
{
	InitSidePane(
		class'EPI_Utilities'.const.PersonnelX - TargetWidth,
		class'EPI_Utilities'.const.PersonnelY + 10,
		name("LeftPane")
	);
}

simulated function CreateContentFor (XComGameState_Unit Unit)
{
	local float YOffset;
	local EPI_Section Headshot, Stats, Bonds, Traits;

	YOffset = 0;

	Headshot = Spawn(class'EPI_Section_Headshot', InfoContainer);
	Headshot.OwningPane = self;
	Headshot.InitAndDisplay(Unit, YOffset);

	Stats = Spawn(class'EPI_Section_Stats', InfoContainer);
	Stats.OwningPane = self;
	Stats.InitAndDisplay(Unit, YOffset);

	Bonds = Spawn(class'EPI_Section_Bonds', InfoContainer);
	Bonds.OwningPane = self;
	Bonds.InitAndDisplay(Unit, YOffset);

	Traits = Spawn(class'EPI_Section_Traits', InfoContainer);
	Traits.OwningPane = self;
	Traits.InitAndDisplay(Unit, YOffset);
}