// This is a base class for a pane that is shown on side of UIPersonnel
class EPI_SidePane extends UIPanel;

// These are set inside
var UIBladeBG BG;
var UIPanel InfoContainer;

// Config. Note that variables like "Width" are prepended with "Target" to prevent name conflicts with UIPanel::Width and such
var float TargetWidth;
var float TargetHeight;

simulated function InitSidePane (float TargetX, float TargetY, optional name InitName)
{
	InitPanel(InitName);
	SetPosition(TargetX, TargetY);

	BG = Spawn(class'UIBladeBG', self);
	BG.bAnimateOnInit = false;
	BG.InitPanel('BG');
	BG.SetPosition(0, 0);
	BG.SetSize(TargetWidth, TargetHeight);
	BG.SetAlpha(80);
}

simulated function DisplayFor (XComGameState_Unit Unit)
{
	local bool ShouldShow;

	ShouldShow = Unit != none && !Unit.IsScientist() && !Unit.IsEngineer();

	// We remove the rendered info as either (a) don't need need it or (b) we are going to recreate it
	if (InfoContainer != none) {
		InfoContainer.Remove();
		InfoContainer = none;
	}

	if (!ShouldShow) {
		BG.Hide();
		return;
	}

	BG.Show();
	InfoContainer = Spawn(class'UIPanel', self);
	InfoContainer.bAnimateOnInit = false;
	InfoContainer.InitPanel();

	CreateContentFor(Unit);
}

simulated function CreateContentFor (XComGameState_Unit Unit)
{
	// Should be overriden by child classes
}

defaultproperties
{
	TargetWidth = 300;
	TargetHeight = 870; // Keep in sync with class'EPI_Utilities'.const.PersonnelHeight - 10

	bAnimateOnInit = false;
}