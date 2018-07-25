// Base class for all sections
class EPI_Section extends UIPanel;

// These are set outside
var EPI_SidePane OwningPane;

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{
	// Should be overriden by base classes
}

defaultproperties
{
	bAnimateOnInit = false;
}