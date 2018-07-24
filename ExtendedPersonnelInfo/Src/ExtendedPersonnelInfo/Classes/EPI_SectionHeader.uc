class EPI_SectionHeader extends UIText;

simulated function InitSectionHeader(string Content, float ContainerWidth, optional name InitName)
{
	local string ContentMutated;

	InitPanel(InitName);
	SetWidth(ContainerWidth);

	ContentMutated = class'UIUtilities_Text'.static.AddFontInfo(Content, Screen.bIsIn3D, true);
	ContentMutated = class'UIUtilities_Text'.static.AlignCenter(ContentMutated);

	SetHtmlText(ContentMutated);
}

defaultproperties
{
	bAnimateOnInit = false;
}