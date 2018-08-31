// Base class for all sections
class EPI_Section extends UIPanel abstract;

// These are set outside
var EPI_SidePane OwningPane;

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{
    `REDSCREEN("Error:" @ default.Class @ "needs to override" @ GetFuncName());
}

defaultproperties
{
	bAnimateOnInit = false;
}