class EPI_Section_Loadout_Slot extends EPI_VerticalLayout_Item;

var SlotData Slot;

/* TODO: Change how slot name is retrived:
	1) Custom-defined dictionary
	2) CHItemSlot::GetDisplayName (with custom casing logic) - skip if highlander isn't present
	3) class'UIArmory_loadout'.default.m_strInventoryLabels[Slot.SlotType] (with custom casing logic)
 */
simulated protected function DoDisplay () 
{
	local string strSlotType;
	local EPI_SubHeader SlotHeader;
	local XComGameState_Item Item;

	local EPI_VerticalLayout_Container ItemsContainer;
	local EPI_Section_Loadout_Item ItemElement;

	// Leave only the first letter Capital-case, lowercase the rest
	strSlotType = class'UIArmory_loadout'.default.m_strInventoryLabels[Slot.SlotType];
	strSlotType = Left(strSlotType, 1) $ Locs(Right(strSlotType, Len(strSlotType) - 1));

	SlotHeader = Spawn(class'EPI_SubHeader', self);
	SlotHeader.InitSubHeader(strSlotType, Width);
	SlotHeader.SetPosition(0, CurrentYOffset);

	IncreaseYOffset(25);

	ItemsContainer = Spawn(class'EPI_VerticalLayout_Container', self);
	ItemsContainer.InitContainer(Width);
	ItemsContainer.SetPosition(0, CurrentYOffset);

	foreach Slot.Items(Item) {
		ItemElement = Spawn(class'EPI_Section_Loadout_Item', ItemsContainer);
		ItemElement.InitLayoutItem();
		ItemElement.Item = Item;

		ItemsContainer.AddLayoutItem(ItemElement);
	}

	ItemsContainer.Display();
	IncreaseYOffset(ItemsContainer.CurrentYOffset);

	IncreaseYOffset(10);
}