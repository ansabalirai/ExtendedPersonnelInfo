class EPI_Section_Loadout_Item extends EPI_VerticalLayout_Item;

var XComGameState_Item Item;

simulated protected function DoDisplay () 
{
	// Data
	local array<X2WeaponUpgradeTemplate> arrUpgradeTemplates;
	local X2WeaponUpgradeTemplate UpgradeTemplate;

	// UI
	local EPI_VerticalLayout_Container UpgradesContainer;
	local EPI_Section_Loadout_Upgrade UpgradeElement;
	local UIScrollingText ItemText;

	arrUpgradeTemplates = Item.GetMyWeaponUpgradeTemplates();

	ItemText = Spawn(class'UIScrollingText', self);
	ItemText.bAnimateOnInit = false;
	ItemText.InitScrollingText(, Item.GetMyTemplate().GetItemFriendlyName(Item.GetReference().ObjectID));
	ItemText.SetPosition(0, CurrentYOffset);
	ItemText.SetWidth(Width);

	IncreaseYOffset(25);
	
	UpgradesContainer = Spawn(class'EPI_VerticalLayout_Container', self);
	UpgradesContainer.InitContainer(Width);
	UpgradesContainer.SetPosition(0, CurrentYOffset);

	foreach arrUpgradeTemplates(UpgradeTemplate) {
		UpgradeElement = Spawn(class'EPI_Section_Loadout_Upgrade', UpgradesContainer);
		UpgradeElement.InitLayoutItem();
		UpgradeElement.UpgradeTemplate = UpgradeTemplate;

		UpgradesContainer.AddLayoutItem(UpgradeElement);
	}

	UpgradesContainer.Display();
	IncreaseYOffset(UpgradesContainer.CurrentYOffset);
}