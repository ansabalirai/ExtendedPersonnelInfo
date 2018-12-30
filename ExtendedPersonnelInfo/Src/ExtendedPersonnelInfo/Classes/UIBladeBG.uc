class UIBladeBG extends UIPanel;

simulated function SetLeftMode()
{
	GoToFrame(1);
}

simulated function SetRightMode()
{
	GoToFrame(7);
}

simulated protected function GoToFrame(int Frame)
{
	MC.FunctionNum("gotoAndPlay", Frame);
}

defaultproperties
{
	LibID = "X2BladeBG"
}