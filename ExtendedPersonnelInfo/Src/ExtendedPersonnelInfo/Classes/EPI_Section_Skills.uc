class EPI_Section_Skills extends EPI_Section;

// Adapted from robojumper_UISquadSelect_SkillsPanel
struct AbilityData
{
	var X2AbilityTemplate Template;
	var name AbilityName;
	var string icoColor;
};

// Config
var float PerkLineHeight;

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{
	local array<AbilityData> Abilities;
	local AbilityData Ability;
	local EPI_SectionHeader Header;
	local UIIcon PerkIcon;
	local UIText PerkText;

	InitPanel(name("Skills"));
	SetPosition(0, 0); // We use YOffset directly

	GetAbilities(Unit, Abilities);

	Header = Spawn(class'EPI_SectionHeader', self);
	Header.InitSectionHeader("Skills", OwningPane.TargetWidth, name("SkillsHeader"));
	Header.SetPosition(0, YOffset);

	YOffset += 40;

	foreach Abilities(Ability) {
		PerkIcon = Spawn(class'UIIcon', self);
		PerkIcon.bAnimateOnInit = false;
		PerkIcon.bIsNavigable = false;
		PerkIcon.InitIcon(, Ability.Template.IconImage, false);
		PerkIcon.SetBGColor(Ability.icoColor);
		PerkIcon.SetSize(PerkLineHeight, PerkLineHeight);
		PerkIcon.SetPosition(10, YOffset);

		PerkText = Spawn(class'UIText', self);
		PerkText.bAnimateOnInit = false;
		PerkText.InitText(, Ability.Template.LocFriendlyName);
		PerkText.SetPosition(PerkIcon.X + PerkIcon.Width + 5, YOffset);

		YOffset += PerkLineHeight + 10;
	}
}

// Adapted from robojumper_UISquadSelect_SkillsPanel
simulated function GetAbilities(XComGameState_Unit Unit, out array<AbilityData> Data)
{
	local array<SoldierClassAbilityType> AbilityTree;
	local X2AbilityTemplateManager AbMgr;
	local X2AbilityTemplate AbTempl;
	local AbilityData EmptyData, BuildData;
	local int i;
	
	AbMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTree = Unit.GetEarnedSoldierAbilities();

	for (i = 0; i < AbilityTree.Length; i++)
	{
		AbTempl = AbMgr.FindAbilityTemplate(AbilityTree[i].AbilityName);

		BuildData = EmptyData;
		BuildData.Template = AbTempl;
		BuildData.AbilityName = AbTempl.DataName;
		BuildData.icoColor = GetIconColor(AbTempl, Unit);
	
		Data.AddItem(BuildData);
	}
}

// Adapted from robojumper_UISquadSelect_SkillsPanel
simulated function string GetIconColor(X2AbilityTemplate Template, XComGameState_Unit Unit)
{
	local string icoColor;

	icoColor = class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR;

	if (Template.AbilitySourceName == 'eAbilitySource_Psionic')
		icoColor = class'UIUtilities_Colors'.const.PSIONIC_HTML_COLOR;
	else if (IsAnAWCPerk(Template, Unit))
		icoColor = class'UIUtilities_Colors'.const.WARNING_HTML_COLOR;

	return icoColor;
}

// Adapted from robojumper_UISquadSelect_SkillsPanel
simulated function bool IsAnAWCPerk(X2AbilityTemplate Ability, XComGameState_Unit Unit) {

	local X2SoldierClassTemplate ClassTemplate;
	local array<SoldierClassAbilityType> SoldierRank;
	local int i;

	ClassTemplate = Unit.GetSoldierClassTemplate();
	SoldierRank = ClassTemplate.GetAllPossibleAbilities();

	for (i = 0; i < SoldierRank.Length; i++)
	{
		if (SoldierRank[i].AbilityName == Ability.DataName)
		{
			return false;
		}
	}

	// The perk was nowhere to be found, so it's from awc.
	return true;
}

defaultproperties
{
	PerkLineHeight = 25;
}