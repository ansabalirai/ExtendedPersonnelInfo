class EPI_Section_Bonds extends EPI_Section;

// Config
var int CandidatesToShow;
var float CandidateMargin;

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{
	local StateObjectReference BondmateRef;
	local SoldierBond BondData;

	InitPanel(name("Bonds"));
	SetPosition(0, YOffset);

	if (Unit.HasSoldierBond(BondmateRef, BondData)) {
		YOffset += DoBondmate(BondmateRef, BondData);
	} else {
		YOffset += DoNotBonded(Unit);
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
	BondmateClassIcon.InitImage(name("BondmateClassIcon"), Bondmate.GetSoldierClassIcon()); // Dependency on highlander
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

simulated function float DoNotBonded(XComGameState_Unit Unit)
{
	local array<XComGameState_Unit> BondCandidates;
	local EPI_Utilities_BondCadidateSorting Sorting;
	local float YOffset;
	local EPI_SectionHeader Header;
	local EPI_SubHeader BestCompatibilityHeader, BestCohesionHeader;
	local UIText NoBondCadidatesText;

	BondCandidates = GetBondingCandidatesFor(Unit);

	Header = Spawn(class'EPI_SectionHeader', self);
	Header.InitSectionHeader("Not bonded", OwningPane.TargetWidth, name("NotBondedHeader"));

	if (BondCandidates.Length == 0) {
		NoBondCadidatesText = Spawn(class'UIText', self);
		NoBondCadidatesText.bAnimateOnInit = false;
		NoBondCadidatesText.InitText(name("NoBondCadidatesText"), "No candidates for bonding");
		NoBondCadidatesText.SetPosition(5, 34);

		return 55;
	}

	Sorting = new class'EPI_Utilities_BondCadidateSorting';
	Sorting.CurrentUnit = Unit;

	BestCompatibilityHeader = Spawn(class'EPI_SubHeader', self);
	BestCompatibilityHeader.InitSubHeader("Highest compatibility", OwningPane.TargetWidth, name("BestCompatibilityHeader"));
	BestCompatibilityHeader.SetPosition(5, 34);

	YOffset = 65;

	Sorting.SortByCompatibility(BondCandidates);
	ShowTopCandidates_Horizontal(Unit, BondCandidates, YOffset);

	YOffset += 10;

	BestCohesionHeader = Spawn(class'EPI_SubHeader', self);
	BestCohesionHeader.InitSubHeader("Highest cohesion", OwningPane.TargetWidth, name("BestCohesionHeader"));
	BestCohesionHeader.SetPosition(5, YOffset);

	YOffset += 30;

	Sorting.SortByCohesion(BondCandidates);
	ShowTopCandidates_Horizontal(Unit, BondCandidates, YOffset);

	return YOffset + 5;
}

simulated function array<XComGameState_Unit> GetBondingCandidatesFor(XComGameState_Unit Unit)
{
	local array<XComGameState_Unit> Results;
	local StateObjectReference CandidateRef;
	local XComGameState_Unit Candidate;

	// For checking is already bonding
	local StateObjectReference BondmateRef;
	local SoldierBond BondData;

	foreach class'UIUtilities_Strategy'.static.GetXComHQ().Crew(CandidateRef) {
		Candidate = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(CandidateRef.ObjectID));

		if (CandidateRef.ObjectID == Unit.GetReference().ObjectID) continue; // Cannot bond with self
		if (Candidate.IsDead()) continue; // Cannot bond with dead units
		if (!Candidate.IsSoldier()) continue; // Only soldiers can bond
		if (Candidate.HasSoldierBond(BondmateRef, BondData)) continue; // Already bonded

		// Compability != 0
		Unit.GetBondData(CandidateRef, BondData);
		if (BondData.Compatibility == 0) continue;

		Results.AddItem(Candidate);
	}

	return Results;
}

simulated function ShowTopCandidates(XComGameState_Unit CurrentUnit, array<XComGameState_Unit> Candidates, out float YOffset)
{
	local int i;
	local int MaxEntries;
	local SoldierBond BondData;
	local float BGWidth, ContentWidth, ContentMargin;
	local UIPanel CandidatePanel;
	local UIBGBox BGBox;
	local UIText CandidateNameText, CompatibilityText;
	local UIImage CandidateClassIcon;
	local UIProgressBar CohesionProgress;

	ContentMargin = 5;
	BGWidth = OwningPane.TargetWidth - (CandidateMargin * 2);
	ContentWidth = BGWidth - (ContentMargin * 2);
	MaxEntries = Candidates.Length < CandidatesToShow ? Candidates.Length : CandidatesToShow;

	for (i = 0; i < MaxEntries; i++) {
		CurrentUnit.GetBondData(Candidates[i].GetReference(), BondData);

		CandidatePanel = Spawn(class'UIPanel', self);
		CandidatePanel.bAnimateOnInit = false;
		CandidatePanel.InitPanel(); // No name so a unique one is generated
		CandidatePanel.SetPosition(CandidateMargin, YOffset);

		BGBox = Spawn(class'UIBGBox', CandidatePanel);
		BGBox.bAnimateOnInit = false;
		BGBox.InitBG(name("BG"));
		BGBox.SetSize(BGWidth, 65);
		BGBox.SetBGColor("gray");

		CandidateNameText = Spawn(class'UIText', CandidatePanel);
		CandidateNameText.bAnimateOnInit = false;
		CandidateNameText.InitText(name("CandidateNameText"), Candidates[i].GetName(eNameType_RankFull));
		CandidateNameText.SetPosition(ContentMargin, ContentMargin);
		CandidateNameText.SetWidth(ContentWidth);

		// We want compatibility and class icon to cover the progressbar in case something goes wrong, not the other way around
		CohesionProgress = Spawn(class'UIProgressBar', CandidatePanel);
		CohesionProgress.bAnimateOnInit = false;
		CohesionProgress.InitProgressBar(
			name("CohesionProgress"),
			140, // X
			35,  // Y
			80,  // Width
			20,   // Height
			GetCohesionPercent(BondData) // Progress
		);

		CompatibilityText = Spawn(class'UIText', CandidatePanel);
		CompatibilityText.bAnimateOnInit = false;
		CompatibilityText.InitText(name("CompatibilityText"), class'X2StrategyGameRulesetDataStructures'.static.GetSoldierCompatibilityLabel(BondData.Compatibility));
		CompatibilityText.SetPosition(ContentMargin, 30);
		CompatibilityText.SetWidth(ContentWidth);

		CandidateClassIcon = Spawn(class'UIImage', CandidatePanel);
		CandidateClassIcon.bAnimateOnInit = false;
		CandidateClassIcon.InitImage(name("CandidateClassIcon"), Candidates[i].GetSoldierClassIcon()); // Dependency on highlander
		CandidateClassIcon.SetPosition(ContentWidth - 55, 0);

		YOffset += 70;
	}
}

simulated function ShowTopCandidates_Horizontal(XComGameState_Unit CurrentUnit, array<XComGameState_Unit> Candidates, out float YOffset)
{
	// Scalars
	local int i;
	local int NumEntries;
	local float RowMargin, RowWidth; // Row is the wrapper around the boxes that are arranged horizontally
	local float EntrySpacing; // The gap between items/boxes
	local float BGWidth; // The width of each BG box
	local float ContentMargin, ContentWidth; // The margin inside the BGBox and the width of content
	local float XOffset;
	
	// Objects and other complex types
	local SoldierBond BondData;
	local UIPanel CandidatePanel;
	local UIBGBox BGBox;
	local UIScrollingText FirstNameText, LastNameText, CompatibilityText, ClassText;
	local UIProgressBar CohesionProgress;
	
	// The number of items to show
	NumEntries = Candidates.Length < CandidatesToShow ? Candidates.Length : CandidatesToShow;
	
	// Margins
	RowMargin = 5;
	EntrySpacing = 5;
	ContentMargin = 5;
	
	// Calculate widths
	RowWidth = OwningPane.TargetWidth - (RowMargin * 2);
	BGWidth = (RowWidth - ((NumEntries - 1) * EntrySpacing)) / NumEntries;
	ContentWidth = BGWidth - (ContentMargin * 2);
	
	// Spawn individual entries
	for (i = 0; i < NumEntries; i++) {
		// Get bond info
		CurrentUnit.GetBondData(Candidates[i].GetReference(), BondData);

		// Calculate the X offset for this candidate
		XOffset = RowMargin;
		XOffset += BGWidth * i;
		XOffset += EntrySpacing * i;
		
		// The parent panel for all things for this candidate
		CandidatePanel = Spawn(class'UIPanel', self);
		CandidatePanel.bAnimateOnInit = false;
		CandidatePanel.InitPanel(); // No name so a unique one is generated
		CandidatePanel.SetPosition(XOffset, YOffset);
		
		BGBox = Spawn(class'UIBGBox', CandidatePanel);
		BGBox.bAnimateOnInit = false;
		BGBox.InitBG(name("BG"));
		BGBox.SetSize(BGWidth, 130);
		BGBox.SetBGColor("gray");
		
		ClassText = Spawn(class'UIScrollingText', CandidatePanel);
		ClassText.bAnimateOnInit = false;
		ClassText.InitScrollingText('ClassText', GetRankWithClass(Candidates[i]));
		ClassText.SetPosition(ContentMargin, 0);
		ClassText.SetWidth(ContentWidth);
		
		FirstNameText = Spawn(class'UIScrollingText', CandidatePanel);
		FirstNameText.bAnimateOnInit = false;
		FirstNameText.InitScrollingText('FirstNameText', Candidates[i].GetFirstName());
		FirstNameText.SetPosition(ContentMargin, 25);
		FirstNameText.SetWidth(ContentWidth);
		
		LastNameText = Spawn(class'UIScrollingText', CandidatePanel);
		LastNameText.bAnimateOnInit = false;
		LastNameText.InitScrollingText('LastNameText', Candidates[i].GetLastName());
		LastNameText.SetPosition(ContentMargin, 50);
		LastNameText.SetWidth(ContentWidth);
		
		CompatibilityText = Spawn(class'UIScrollingText', CandidatePanel);
		CompatibilityText.bAnimateOnInit = false;
		CompatibilityText.InitScrollingText('CompatibilityText', GetCustomCompatibilityLabel(BondData.Compatibility));
		CompatibilityText.SetPosition(ContentMargin, 75);
		CompatibilityText.SetWidth(ContentWidth);
		
		CohesionProgress = Spawn(class'UIProgressBar', CandidatePanel);
		CohesionProgress.bAnimateOnInit = false;
		CohesionProgress.InitProgressBar(
			name("CohesionProgress"),
			ContentMargin, // X
			105,           // Y
			ContentWidth,  // Width
			20,            // Height
			GetCohesionPercent(BondData) // Progress
		);
	}
	
	YOffset += 130;
}

simulated function string GetClass(XComGameState_Unit Unit) {
	return Unit.GetSoldierClassDisplayName(); // TODO: Do not depend on highlander
}

simulated function string GetRankWithClass(XComGameState_Unit Unit) {
	local int iRank;
	local string Result;

	iRank = Unit.GetRank();
	Result = "";
	
	// If not rookie then add rank
	if (iRank != 0) {
		Result $= `GET_RANK_ABBRV(iRank, Unit.GetSoldierClassTemplateName()) $ " ";
	}
	
	Result $= GetClass(Unit);
	
	return Result;
}

// Reworked version of class'X2StrategyGameRulesetDataStructures'.static.GetSoldierCompatibilityLabel
simulated function string GetCustomCompatibilityLabel(float Compatibility) {
	local int NumStrLength;
	local float CompatNumber;
	local string CompatLabel; 

	CompatNumber = float(Round(Compatibility * 50.0f)) / 10.0f;
	NumStrLength = 3;
	
	if(CompatNumber >= 10.0f)
	{
		NumStrLength = 4;
	}
	
	// First the number goes with space and dash after it
	CompatLabel = Left(string(CompatNumber), NumStrLength) $ " - ";
	
	// Languages use SI-French style fractional delimiter (comma instead of dot).
	switch (GetLanguage())
	{
	case "DEU":
	case "FRA":
	case "RUS":
	case "ITA":
	case "POL":
		CompatLabel = Repl(CompatLabel, ".", ","); 
		break;
	}
	
	// Add the text
	if(IsFloatWithinMinMax(Compatibility, class'X2StrategyGameRulesetDataStructures'.default.VeryLowCompatRange))
	{
		CompatLabel $= Locs(class'X2StrategyGameRulesetDataStructures'.default.VeryLowCompatLabel);
	}
	else if(IsFloatWithinMinMax(Compatibility, class'X2StrategyGameRulesetDataStructures'.default.LowCompatRange))
	{
		CompatLabel $= Locs(class'X2StrategyGameRulesetDataStructures'.default.LowCompatLabel);
	}
	else if(IsFloatWithinMinMax(Compatibility, class'X2StrategyGameRulesetDataStructures'.default.HighCompatRange))
	{
		CompatLabel $= Locs(class'X2StrategyGameRulesetDataStructures'.default.HighCompatLabel);
	}
	else if(IsFloatWithinMinMax(Compatibility, class'X2StrategyGameRulesetDataStructures'.default.VeryHighCompatRange))
	{
		CompatLabel $= Locs(class'X2StrategyGameRulesetDataStructures'.default.VeryHighCompatLabel);
	}
	
	return CompatLabel;
}

static function bool IsFloatWithinMinMax(float Value, X2StrategyGameRulesetDataStructures.MinMaxFloat FloatStruct)
{
	return class'X2StrategyGameRulesetDataStructures'.static.IsFloatWithinMinMax(Value, FloatStruct);
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
	CandidatesToShow = 3;
	CandidateMargin = 5;
}