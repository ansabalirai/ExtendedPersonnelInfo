class EPI_SubHeader extends UIText;

simulated function InitSubHeader(string Content, float ContainerWidth, optional name InitName)
{
	InitPanel(InitName);
	SetWidth(ContainerWidth);

	SetHtmlText(class'UIUtilities_Text'.static.AddFontInfo(Content, Screen.bIsIn3D, true, true));
}

defaultproperties
{
	bAnimateOnInit = false;
}