class EPI_Section_Stats extends EPI_Section;

const FONT_SIZE = 18;

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{
	InitPanel();
	SetPosition(0, YOffset);

	ShowPsi(Unit);
	ShowXP(Unit);
	ShowAP(Unit);
	ShowCombatInt(Unit);

	YOffset += 25;
}

simulated protected function ShowPsi (XComGameState_Unit Unit)
{
	local UIImage Icon;
	local UIText Text;

	Icon = Spawn(class'UIImage', self);
	Icon.bAnimateOnInit = false;
	Icon.InitImage('PSI_Icon', "gfxXComIcons.promote_psi");
	Icon.SetPosition(5, 2.5);
	Icon.SetSize(20, 20);

	Text = Spawn(class'UIText', self);
	Text.bAnimateOnInit = false;
	Text.InitText('PSI_Text');
	Text.SetHtmlText(GetHtmlText(string(int(Unit.GetCurrentStat(eStat_PsiOffense))))); // The parentheses though
	Text.SetX(25);
}

simulated protected function ShowXP (XComGameState_Unit Unit)
{
	local UIImage Icon;
	local UIText Text;
	local string xpText;

	xpText = string(Unit.GetTotalNumKills());
	if (ShouldShowRequiredXp(Unit)) {
		xpText $= "/" $ class'X2ExperienceConfig'.static.GetRequiredKills(Unit.GetSoldierRank() + 1);
	}

	Icon = Spawn(class'UIImage', self);
	Icon.bAnimateOnInit = false;
	Icon.InitImage('XP_Icon', "gfxAlerts.promote_icon");
	Icon.SetPosition(50, 2.5);
	Icon.SetSize(20, 20);

	Text = Spawn(class'UIText', self);
	Text.bAnimateOnInit = false;
	Text.InitText('XP_Text');
	Text.SetHtmlText(GetHtmlText(xpText));
	Text.SetX(68);
}

simulated protected function bool ShouldShowRequiredXp (XComGameState_Unit Unit)
{
	local X2SoldierClassTemplate Template;
	Template = Unit.GetSoldierClassTemplate();

	if (Template.bBlockRankingUp) return false;

	return Template.DataName == 'Rookie' || Unit.GetSoldierRank() < Template.GetMaxConfiguredRank();
}

simulated protected function ShowAP (XComGameState_Unit Unit)
{
	local UIImage Icon;
	local UIText Text;

	Icon = Spawn(class'UIImage', self);
	Icon.bAnimateOnInit = false;
	Icon.InitImage('AP_Icon', "EPI_UILibrary.AP_Icon");
	Icon.SetPosition(140, 2.5);
	Icon.SetSize(20, 20);

	Text = Spawn(class'UIText', self);
	Text.bAnimateOnInit = false;
	Text.InitText('AP_Text');
	Text.SetHtmlText(GetHtmlText(string(Unit.AbilityPoints)));
	Text.SetX(160);
}

simulated protected function ShowCombatInt (XComGameState_Unit Unit)
{
	local UIImage Icon;
	local UIScrollingText Text;

	Icon = Spawn(class'UIImage', self);
	Icon.bAnimateOnInit = false;
	Icon.InitImage('CombatInt_Icon', "EPI_UILibrary.CombatInt_Icon");
	Icon.SetPosition(185, 2.5);
	Icon.SetSize(20, 20);

	Text = Spawn(class'UIScrollingText', self);
	Text.bAnimateOnInit = false;
	Text.InitScrollingText('CombatInt_Text');
	Text.SetHtmlText(GetHtmlText(Unit.GetCombatIntelligenceLabel()));
	Text.SetX(210);
	Text.SetWidth(OwningPane.TargetWidth - Text.X - 5 /* A bit of padding */);
}

simulated protected function string GetHtmlText(string Text)
{
	return class'UIUtilities_Text'.static.AddFontInfo(Text, Screen.bIsIn3D, false, false, FONT_SIZE);
}