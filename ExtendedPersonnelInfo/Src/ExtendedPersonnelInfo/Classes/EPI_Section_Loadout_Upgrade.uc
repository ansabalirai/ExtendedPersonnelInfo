class EPI_Section_Loadout_Upgrade extends EPI_VerticalLayout_Item;

var X2WeaponUpgradeTemplate UpgradeTemplate;

simulated function protected DoDisplay()
{
	// We split the bullet point and the text so that the bullet point doesn't scroll
	local UIScrollingText UpgradeText;
	local UIText BulletPoint;

	BulletPoint = Spawn(class'UIText', self);
	BulletPoint.bAnimateOnInit = false;
	BulletPoint.InitText('BulletPoint', " - ");

	UpgradeText = Spawn(class'UIScrollingText', self);
	UpgradeText.bAnimateOnInit = false;
	UpgradeText.InitScrollingText('UpgradeText', UpgradeTemplate.GetItemFriendlyName());
	UpgradeText.SetPosition(25, 0);
	UpgradeText.SetWidth(Width - UpgradeText.X);

	IncreaseYOffset(20);
}