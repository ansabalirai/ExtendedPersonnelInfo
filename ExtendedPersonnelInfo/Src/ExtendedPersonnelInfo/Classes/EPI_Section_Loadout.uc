class EPI_Section_Loadout extends EPI_Section;

struct SlotData {
	var EInventorySlot SlotType;
	var array<XComGameState_Item> Items;
};

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{	
	local array<SlotData> Slots;
	local SlotData Slot;
	local XComGameState_Item Item;
	local float ContainerMargin, ContainerWidth, ContentMargin, ContentWidth;
	local EPI_SectionHeader Header;
	local UIBGBox SlotBG;
	local EPI_SubHeader SlotHeader;
	local UIText ItemText;

	ContainerMargin = 5;
	ContainerWidth = OwningPane.TargetWidth - (ContainerMargin * 2);
	ContentMargin = 5;
	ContentWidth = ContainerWidth - (ContentMargin * 2);

	GatherData(Unit, Slots);
	InitPanel(name("Loadout"));
	SetPosition(0, 0); // We use YOffset directly

	Header = Spawn(class'EPI_SectionHeader', self);
	Header.InitSectionHeader("Loadout", ContainerWidth, name("LoadoutHeader"));
	Header.SetPosition(ContainerMargin, YOffset);

	YOffset += 40;

	foreach Slots(Slot) {
		SlotBG = Spawn(class'UIBGBox', self);
		SlotBG.bAnimateOnInit = false;
		SlotBG.InitBG(, ContainerMargin, YOffset, ContainerWidth, 35 + (Slot.Items.Length * 25));
		SlotBG.SetBGColor("gray");

		SlotHeader = Spawn(class'EPI_SubHeader', self);
		SlotHeader.InitSubHeader(class'UIArmory_loadout'.default.m_strInventoryLabels[Slot.SlotType], ContentWidth);
		SlotHeader.SetPosition(ContainerMargin + ContentMargin, YOffset);

		YOffset += 30;

		foreach Slot.Items(Item) {
			ItemText = Spawn(class'UIText', self);
			ItemText.bAnimateOnInit = false;
			ItemText.InitText(, Item.GetMyTemplate().GetItemFriendlyName(Item.GetReference().ObjectID));
			ItemText.SetPosition(ContainerMargin + ContentMargin, YOffset);

			YOffset += 25;
		}

		YOffset += 10;
	}
}

simulated function GatherData(XComGameState_Unit Unit, out array<SlotData> Slots)
{
	local CHUIItemSlotEnumerator En;
	local EInventorySlot PrevSlotType;
	local SlotData CurrentSlotData, EmptySlotData;

	En = class'CHUIItemSlotEnumerator'.static.CreateEnumerator(Unit);
	PrevSlotType = -1; // Enums start at 0 so this is guranteed not to match with anything

	while (En.HasNext())
	{
		En.Next();

		if (PrevSlotType != En.Slot) { // Changed slot type, refresh CurrentSlotData
			if (CurrentSlotData.Items.Length > 0) { // We have some items in this slot
				Slots.AddItem(CurrentSlotData);
			}

			CurrentSlotData = EmptySlotData;
			CurrentSlotData.SlotType = En.Slot;
		} 

		if (En.ItemState != none) {
			CurrentSlotData.Items.AddItem(En.ItemState);
		}

		PrevSlotType = En.Slot;
	}

	// Add the last slot
	if (CurrentSlotData.Items.Length > 0) {
		Slots.AddItem(CurrentSlotData);
	}
}