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
	local float CurrentYOffset, LeftYOffset, RightYOffset, RightXOffset;
	local float ContainerMargin, ContainerWidth, ContentMargin, ContentWidth;
	local bool IsRight;
	local EPI_SectionHeader Header;
	local UIBGBox SlotBG;
	local string strSlotType;
	local EPI_SubHeader SlotHeader;
	local UIScrollingText ItemText;

	ContainerMargin = 5;
	RightXOffset = OwningPane.TargetWidth / 2;
	ContainerWidth = RightXOffset - (ContainerMargin * 2);
	ContentMargin = 5;
	ContentWidth = ContainerWidth - (ContentMargin * 2);

	GatherData(Unit, Slots);
	InitPanel(name("Loadout"));
	SetPosition(0, 0); // We use YOffset directly

	Header = Spawn(class'EPI_SectionHeader', self);
	Header.InitSectionHeader("Loadout", OwningPane.TargetWidth - (ContainerMargin * 2), name("LoadoutHeader"));
	Header.SetPosition(ContainerMargin, YOffset);

	YOffset += 40;
	LeftYOffset = YOffset;
	RightYOffset = YOffset;
	
	foreach Slots(Slot) {
		// Decide which column this slots goes, but give priority to left one
		IsRight = RightYOffset < LeftYOffset;
		CurrentYOffset = IsRight ? RightYOffset : LeftYOffset;

		SlotBG = Spawn(class'UIBGBox', self);
		SlotBG.bAnimateOnInit = false;
		SlotBG.InitBG(, ContainerMargin, CurrentYOffset, ContainerWidth, 35 + (Slot.Items.Length * 25));
		SlotBG.SetBGColor("gray");
		if (IsRight) SlotBG.SetX(SlotBG.X + RightXOffset);

		// Leave only the first letter Capital-case, lowercase the rest
		strSlotType = class'UIArmory_loadout'.default.m_strInventoryLabels[Slot.SlotType];
		strSlotType = Left(strSlotType, 1) $ Locs(Right(strSlotType, Len(strSlotType) - 1));

		SlotHeader = Spawn(class'EPI_SubHeader', self);
		SlotHeader.InitSubHeader(strSlotType, ContentWidth);
		SlotHeader.SetPosition(ContainerMargin + ContentMargin, CurrentYOffset);
		if (IsRight) SlotHeader.SetX(SlotHeader.X + RightXOffset);

		CurrentYOffset += 30;

		foreach Slot.Items(Item) {
			ItemText = Spawn(class'UIScrollingText', self);
			ItemText.bAnimateOnInit = false;
			ItemText.InitScrollingText(, Item.GetMyTemplate().GetItemFriendlyName(Item.GetReference().ObjectID));
			ItemText.SetPosition(ContainerMargin + ContentMargin, CurrentYOffset);
			ItemText.SetWidth(ContentWidth);
			if (IsRight) ItemText.SetX(ItemText.X + RightXOffset);

			CurrentYOffset += 25;
		}

		CurrentYOffset += 10;

		// "Submit" the Y offset changes
		if (IsRight) RightYOffset = CurrentYOffset;
		else LeftYOffset = CurrentYOffset;
	}

	// We use the bigger Y offset as the overall offset of whole section
	YOffset = LeftYOffset > RightYOffset ? LeftYOffset : RightYOffset;
}

simulated function GatherData(XComGameState_Unit Unit, out array<SlotData> Slots)
{
	local array<EInventorySlot> SlotsToShow;
	local CHUIItemSlotEnumerator En;
	local EInventorySlot PrevSlotType;
	local SlotData CurrentSlotData, EmptySlotData;

	GetSlotsToShow(Unit, SlotsToShow);

	En = class'CHUIItemSlotEnumerator'.static.CreateEnumerator(Unit,,,, SlotsToShow);
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

simulated function GetSlotsToShow (XComGameState_Unit Unit, out array<EInventorySlot> SlotsToShow) 
{
	local array<CHItemSlot> ModSlots;
	local CHItemSlot SlotTemplate;

	SlotsToShow = class'CHItemSlot'.static.GetDefaultDisplayedSlots(Unit);
	ModSlots = class'CHItemSlot'.static.GetAllSlotTemplates();

	foreach ModSlots(SlotTemplate) {
		if (SlotTemplate.UnitShowSlot(Unit)) {
			SlotsToShow.Add(SlotTemplate.InvSlot);
		}
	}
}