class EPI_Section_Headshot extends EPI_Section;

// Config
var float Margin;

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{
	local XComGameState_CampaignSettings SettingsState;
	local StateObjectReference UnitRef;
	local Texture2D StaffPicture;
	local float SectionHeight, HeadshotSideLength;
	local UIImage Image;

	InitPanel(name("Headshot"));
	SetPosition(0, YOffset);

	SectionHeight = OwningPane.TargetWidth;
	HeadshotSideLength = SectionHeight - (Margin * 2);

	UnitRef = Unit.GetReference();
	SettingsState = XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	StaffPicture = `XENGINE.m_kPhotoManager.GetHeadshotTexture(SettingsState.GameIndex, UnitRef.ObjectID, HeadshotSideLength, HeadshotSideLength);

	if (StaffPicture != none) {
		Image = Spawn(class'UIImage', self);
		Image.bAnimateOnInit = false;
		Image.InitImage(name("Image"), class'UIUtilities_Image'.static.ValidateImagePath(PathName(StaffPicture)));
		Image.SetPosition(Margin, Margin);
		Image.SetSize(HeadshotSideLength, HeadshotSideLength);
	}

	YOffset += SectionHeight;
}

defaultproperties
{
	Margin = 5;
}