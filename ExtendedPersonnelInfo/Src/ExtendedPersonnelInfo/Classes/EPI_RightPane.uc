class EPI_RightPane extends EPI_SidePane;

simulated function InitRightPane()
{
	InitSidePane(
		class'EPI_Utilities'.const.PersonnelX + class'EPI_Utilities'.const.PersonnelWidth + 10,
		class'EPI_Utilities'.const.PersonnelY,
		name("RightPane")
	);
}

simulated function CreateContentFor (XComGameState_Unit Unit)
{
	local float YOffset;
	local EPI_Section Skills;

	YOffset = 0;

	Skills = Spawn(class'EPI_Section_Skills', InfoContainer);
	Skills.OwningPane = self;
	Skills.InitAndDisplay(Unit, YOffset);
}