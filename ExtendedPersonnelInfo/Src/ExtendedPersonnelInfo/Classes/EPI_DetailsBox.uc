class EPI_DetailsBox extends UIPanel;

// These are set outside
var UIPersonnel Personnel;

// These are set inside
var UIBGBox BGBox;
var UIPanel InfoContainer;
var XComGameState_Unit CurrentUnit;

// Config
var float TargetWidth;

delegate PreviousOnSetSelectedIndex(UIList ContainerList, int ItemIndex);

simulated function InitDetailsBox () 
{
	local float PersonnelX;
	local float PersonnelY;

	PersonnelX = 480;
	PersonnelY = 90;

	InitPanel(name("EPI_DetailsBox"));
	SetPosition(PersonnelX - TargetWidth - 10, PersonnelY);

	BGBox = Spawn(class'UIBGBox', self);
	BGBox.bAnimateOnInit = false;
	BGBox.InitBG(name("BG"), 0, 0, TargetWidth, 880, eUIState_Normal);

	PreviousOnSetSelectedIndex = Personnel.m_kList.OnSetSelectedIndex;
	Personnel.m_kList.OnSetSelectedIndex = OnListSetSelectedIndex;

	UpdateCurrentUnit(Personnel.m_kList.SelectedIndex);
	UpdateDisplay();
}

simulated function OnListSetSelectedIndex(UIList ContainerList, int ItemIndex) 
{
	UpdateCurrentUnit(ItemIndex);
	UpdateDisplay();

	PreviousOnSetSelectedIndex(ContainerList, ItemIndex);
}

simulated function UpdateCurrentUnit (int Index)
{
	local UIPersonnel_ListItem ListItem;

	ListItem = UIPersonnel_ListItem(Personnel.m_kList.GetItem(Index));

	if (ListItem == none) {
		CurrentUnit = none;
		return;
	}

	CurrentUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ListItem.UnitRef.ObjectID));
}

// Shows data based on CurrentUnit
simulated function UpdateDisplay()
{
	local float YOffset;

	// We remove the rendered info as either (a) don't need need it or (b) we are going to recreate it
	if (InfoContainer != none) {
		InfoContainer.Remove();
		InfoContainer = none;
	}

	if (CurrentUnit == none) {
		BGBox.Hide();
		return;
	}

	YOffset = 0;
	BGBox.Show();
	InfoContainer = Spawn(class'UIPanel', self);
	InfoContainer.bAnimateOnInit = false;
	InfoContainer.InitPanel();

	/*UnitNameText = Spawn(class'UIText', InfoContainer);
	UnitNameText.bAnimateOnInit = false;
	UnitNameText.InitText(name("UnitNameText"), CurrentUnit.GetName(eNameType_First) @ CurrentUnit.GetName(eNameType_Last));*/

	DoHeadshot(YOffset);
	DoBonds(YOffset);


	// TODO
}

simulated function DoHeadshot (out float YOffset)
{
	local XComGameState_CampaignSettings SettingsState;
	local StateObjectReference UnitRef;
	local Texture2D StaffPicture;
	local float Margin, HeadshotSideLength;
	local UIImage Image;

	Margin = 5;
	HeadshotSideLength = TargetWidth - (Margin * 2);

	SettingsState = XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings'));
	UnitRef = CurrentUnit.GetReference();
	StaffPicture = `XENGINE.m_kPhotoManager.GetHeadshotTexture(SettingsState.GameIndex, UnitRef.ObjectID, HeadshotSideLength, HeadshotSideLength);

	if (StaffPicture != none) {
		Image = Spawn(class'UIImage', InfoContainer);
		Image.bAnimateOnInit = false;
		Image.InitImage(name("Headshot"), class'UIUtilities_Image'.static.ValidateImagePath(PathName(StaffPicture)));
		Image.SetPosition(Margin, YOffset + Margin);
		Image.SetSize(HeadshotSideLength, HeadshotSideLength);
	}

	YOffset += HeadshotSideLength + (Margin * 2);
}

simulated function DoBonds (out float YOffset)
{
	local StateObjectReference BondmateRef;
	local SoldierBond BondData;
	local UIPanel BondsPanel;

	BondsPanel = Spawn(class'UIPanel', InfoContainer);
	BondsPanel.bAnimateOnInit = false;
	BondsPanel.InitPanel(name("Bonds"));
	BondsPanel.SetPosition(0, YOffset);

	if (CurrentUnit.HasSoldierBond(BondmateRef, BondData)) {
		YOffset += DoBondmate(BondsPanel, BondmateRef, BondData);
	}
}

simulated function float DoBondmate(UIPanel Container, StateObjectReference BondmateRef, SoldierBond BondData)
{
	local XComGameState_Unit Bondmate;
	local UIPanel DetailsUnderHeader;
	local float DetailsWidth;
	local EPI_SectionHeader Header;
	local UIBondIcon BondIcon;
	local UIText BondLevelText, BondmateNameText, CompatibilityText;
	local UIImage BondmateClassIcon;
	local UIProgressBar CohesionProgress;

	Bondmate = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(BondmateRef.ObjectID));

	Header = Spawn(class'EPI_SectionHeader', Container);
	Header.InitSectionHeader("Bonded", TargetWidth, name("HasBondmateHeader"));

	BondIcon = Spawn(class'UIBondIcon', Container);
	BondIcon.bAnimateOnInit = false;
	BondIcon.bIsNavigable = false;
	BondIcon.InitBondIcon(name("BondIcon"), BondData.BondLevel, , BondmateRef);
	BondIcon.SetPosition(5, 5); // A bit of space between icon and border

	BondLevelText = Spawn(class'UIText', Container);
	BondLevelText.bAnimateOnInit = false;
	BondLevelText.InitText(name("BondLevelText"), string(BondData.BondLevel), true);
	BondLevelText.SetPosition(BondData.BondLevel == 1 ? 55 : 45, 70); // "1" is displayed as "I" and is barely visible on top of icon so we move it a bit to the right

	DetailsUnderHeader = Spawn(class'UIPanel', Container);
	DetailsUnderHeader.bAnimateOnInit = false;
	DetailsUnderHeader.InitPanel(name("BondDetails"));
	DetailsUnderHeader.SetPosition(BondIcon.X + BondIcon.Width + 5, 34);
	DetailsWidth = TargetWidth - DetailsUnderHeader.X - 5 /* Small margin on the right */;

	BondmateNameText = Spawn(class'UIText', DetailsUnderHeader);
	BondmateNameText.bAnimateOnInit = false;
	BondmateNameText.InitText(name("BondmateNameText"), Bondmate.GetName(eNameType_RankFull));
	BondmateNameText.SetPosition(0, 0);
	BondmateNameText.SetWidth(DetailsWidth);

	CompatibilityText = Spawn(class'UIText', DetailsUnderHeader);
	CompatibilityText.bAnimateOnInit = false;
	CompatibilityText.InitText(name("CompatibilityText"), class'X2StrategyGameRulesetDataStructures'.static.GetSoldierCompatibilityLabel(BondData.Compatibility));
	CompatibilityText.SetPosition(0, 24);
	CompatibilityText.SetWidth(DetailsWidth);

	BondmateClassIcon = Spawn(class'UIImage', DetailsUnderHeader);
	BondmateClassIcon.bAnimateOnInit = false;
	BondmateClassIcon.InitImage(name("BondmateClassIcon"), Bondmate.GetSoldierClassIcon());
	BondmateClassIcon.SetPosition(DetailsWidth - 60, -12);

	CohesionProgress = Spawn(class'UIProgressBar', DetailsUnderHeader);
	CohesionProgress.bAnimateOnInit = false;
	CohesionProgress.InitProgressBar(
		name("CohesionProgress"),
		0,                           // X
		50,                          // Y
		DetailsWidth,                // Width
		20,                          // Height
		GetCohesionPercent(BondData) // Progress
	);

	// How high this section is plus a bit of margin
	return BondIcon.Height + 10;
}

// Copied from UISoldierBondScreen::RefreshHeader
simulated function float GetCohesionPercent(SoldierBond BondData)
{
	local array<int> CohesionThresholds;
	local float CohesionMax;
	
	CohesionThresholds = class'X2StrategyGameRulesetDataStructures'.default.CohesionThresholds;
	CohesionMax = float(CohesionThresholds[Clamp(BondData.BondLevel + 1, 0, CohesionThresholds.Length - 1)]);

	return float(BondData.Cohesion) / CohesionMax;
}

defaultproperties 
{
	bAnimateOnInit = false;
	TargetWidth = 300;
}