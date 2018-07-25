class EPI_Section_Bonds extends EPI_Section;

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{
	local StateObjectReference BondmateRef;
	local SoldierBond BondData;

	InitPanel(name("Bonds"));
	SetPosition(0, YOffset);

	if (Unit.HasSoldierBond(BondmateRef, BondData)) {
		YOffset += DoBondmate(BondmateRef, BondData);
	}
}

simulated function float DoBondmate(StateObjectReference BondmateRef, SoldierBond BondData)
{
	local XComGameState_Unit Bondmate;
	local UIPanel DetailsUnderHeader;
	local float PaneWidth, DetailsWidth;
	local EPI_SectionHeader Header;
	local UIBondIcon BondIcon;
	local UIText BondLevelText, BondmateNameText, CompatibilityText;
	local UIImage BondmateClassIcon;
	local UIProgressBar CohesionProgress;

	PaneWidth = OwningPane.TargetWidth;
	Bondmate = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(BondmateRef.ObjectID));

	Header = Spawn(class'EPI_SectionHeader', self);
	Header.InitSectionHeader("Bonded", PaneWidth, name("HasBondmateHeader"));

	BondIcon = Spawn(class'UIBondIcon', self);
	BondIcon.bAnimateOnInit = false;
	BondIcon.bIsNavigable = false;
	BondIcon.InitBondIcon(name("BondIcon"), BondData.BondLevel, , BondmateRef);
	BondIcon.SetPosition(5, 5); // A bit of space between icon and border

	BondLevelText = Spawn(class'UIText', self);
	BondLevelText.bAnimateOnInit = false;
	BondLevelText.InitText(name("BondLevelText"), string(BondData.BondLevel), true);
	BondLevelText.SetPosition(BondData.BondLevel == 1 ? 55 : 45, 70); // "1" is displayed as "I" and is barely visible on top of icon so we move it a bit to the right

	DetailsUnderHeader = Spawn(class'UIPanel', self);
	DetailsUnderHeader.bAnimateOnInit = false;
	DetailsUnderHeader.InitPanel(name("BondDetails"));
	DetailsUnderHeader.SetPosition(BondIcon.X + BondIcon.Width + 5, 34);
	DetailsWidth = PaneWidth - DetailsUnderHeader.X - 5 /* Small margin on the right */;

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