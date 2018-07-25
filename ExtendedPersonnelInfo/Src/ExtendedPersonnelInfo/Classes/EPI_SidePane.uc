// This is a base class for a pane that is shown on side of UIPersonnel
class EPI_SidePane extends UIPanel;

// These are set inside
var UIBGBox BGBox;
var UIPanel InfoContainer;

// Config. Note that variables like "Width" are prepended with "Target" to prevent name conflicts with UIPanel::Width and such
var float TargetWidth;
var float TargetHeight;

simulated function InitSidePane (float TargetX, float TargetY, optional name InitName)
{
	InitPanel(InitName);
	SetPosition(TargetX, TargetY);

	BGBox = Spawn(class'UIBGBox', self);
	BGBox.bAnimateOnInit = false;
	BGBox.InitBG(name("BG"), 0, 0, TargetWidth, TargetHeight, eUIState_Normal);
}

simulated function DisplayFor (XComGameState_Unit Unit)
{
	// We remove the rendered info as either (a) don't need need it or (b) we are going to recreate it
	if (InfoContainer != none) {
		InfoContainer.Remove();
		InfoContainer = none;
	}

	if (Unit == none) {
		BGBox.Hide();
		return;
	}

	BGBox.Show();
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
	TargetHeight = 880;

	bAnimateOnInit = false;
}