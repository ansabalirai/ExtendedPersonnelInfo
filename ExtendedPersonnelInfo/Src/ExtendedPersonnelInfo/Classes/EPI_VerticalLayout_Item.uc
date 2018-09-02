class EPI_VerticalLayout_Item extends UIPanel abstract;

var privatewrite float CurrentYOffset;
var privatewrite bool bIsDisplayed;

var name InitName;

simulated function InitLayoutItem()
{
	InitPanel(InitName);
}

simulated function ConfigureVerticalLayoutItem(float InitX, float InitY, float InitWidth)
{
	if (bIsDisplayed) {
		`REDSCREEN("Error:" @ GetFuncName() @ "called after Diplay()");
		return;
	}

	SetPosition(InitX, InitY);
	SetWidth(InitWidth);
}

simulated function Display() 
{
	if (bIsDisplayed) {
		`REDSCREEN("Error:" @ default.Class @ "is already displayed");
		return;
	}

	DoDisplay();
	MarkDisplayed();
}

simulated protected function MarkDisplayed ()
{
	bIsDisplayed = true;
}

simulated protected function DoDisplay()
{
    `REDSCREEN("Error:" @ default.Class @ "needs to override" @ GetFuncName());
}

simulated protected function IncreaseYOffset(float Delta)
{
	if (Delta < 0) {
		`REDSCREEN("Error:" @ GetFuncName() @ "called with negative argument");
		return;
	}

	CurrentYOffset += Delta;
}

// Custom size operations

simulated function SetWidth(float NewWidth)
{
	if(Width != NewWidth)
	{
		Width = NewWidth;
	}
}

simulated function SetHeight(float NewHeight)
{
	`RedScreen("NOT SUPPORTED");
}

simulated function UIPanel SetSize(float NewWidth, float NewHeight)
{
	`RedScreen("NOT SUPPORTED");
	return self;
}

defaultproperties
{
	CurrentYOffset = 0;
	bAnimateOnInit = false;
}