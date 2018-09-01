class EPI_Section_Loadout_Upgrade extends EPI_VerticalLayout_Item;

var X2WeaponUpgradeTemplate UpgradeTemplate;

simulated function protected DoDisplay()
{
	local UIScrollingText UpgradeText;

	UpgradeText = Spawn(class'UIScrollingText', self);
	UpgradeText.bAnimateOnInit = false;
	UpgradeText.InitScrollingText(, " - " $ UpgradeTemplate.GetItemFriendlyName());
	UpgradeText.SetPosition(0, 0);
	UpgradeText.SetWidth(Width);

	IncreaseYOffset(25);
}