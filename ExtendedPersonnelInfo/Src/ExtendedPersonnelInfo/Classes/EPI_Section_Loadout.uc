class EPI_Section_Loadout extends EPI_Section config(ExtendedPersonnelInfo);

var config array<EInventorySlot> FullWidthSlots;

struct SlotData {
	var EInventorySlot SlotType;
	var array<XComGameState_Item> Items;
};

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{
	// Data
	local array<SlotData> Slots, FullRowSlots, SmallSlots;
	local SlotData Slot;

	// Calculations
	local float SectionPadding, SectionUsableWidth;
	local float SpacingBetweenContainers, ContainersWidth;
	local bool IsRight;

	// UI
	local EPI_VerticalLayout_Container FullWidthContainer, LeftContainer, RightContainer, CurrentContainer;
	local EPI_SectionHeader Header;

	SectionPadding = 5;
	SpacingBetweenContainers = 5;

	SectionUsableWidth = OwningPane.TargetWidth - (SectionPadding * 2);
	ContainersWidth = (SectionUsableWidth - SpacingBetweenContainers) / 2;

	GatherData(Unit, Slots);
	SplitSlots(Slots, FullRowSlots, SmallSlots);

	InitPanel(name("Loadout"));
	SetPosition(0, 0); // We use YOffset directly

	Header = Spawn(class'EPI_SectionHeader', self);
	Header.InitSectionHeader("Loadout", SectionUsableWidth, name("LoadoutHeader"));
	Header.SetPosition(SectionPadding, YOffset);

	YOffset += 40;

	// Full width slots
	FullWidthContainer = Spawn(class'EPI_VerticalLayout_Container', self);
	FullWidthContainer.InitContainer(SectionUsableWidth);
	FullWidthContainer.SetPosition(SectionPadding, YOffset);
	FullWidthContainer.SpacingBetweenItems = 5;

	foreach FullRowSlots(Slot) {
		DisplaySlot(Slot, FullWidthContainer);
	}

	YOffset += FullWidthContainer.CurrentYOffset + 5;

	// Half-column slots
	LeftContainer = Spawn(class'EPI_VerticalLayout_Container', self);
	LeftContainer.InitContainer(ContainersWidth);
	LeftContainer.SetPosition(SectionPadding, YOffset);
	LeftContainer.SpacingBetweenItems = 5;

	RightContainer = Spawn(class'EPI_VerticalLayout_Container', self);
	RightContainer.InitContainer(ContainersWidth);
	RightContainer.SetPosition(SectionPadding + ContainersWidth + SpacingBetweenContainers, YOffset);
	RightContainer.SpacingBetweenItems = 5;

	foreach SmallSlots(Slot) {
		// Decide which side
		IsRight = RightContainer.CurrentYOffset < LeftContainer.CurrentYOffset;
		CurrentContainer = IsRight ? RightContainer : LeftContainer;

		DisplaySlot(Slot, CurrentContainer);
	}

	YOffset += FMax(RightContainer.CurrentYOffset, LeftContainer.CurrentYOffset);
}

simulated protected function DisplaySlot (SlotData Slot, EPI_VerticalLayout_Container Container)
{
	local EPI_VerticalLayout_ItemBorder Border;
	local EPI_Section_Loadout_Slot SlotElement;

	// Create border for slot
	Border = Spawn(class'EPI_VerticalLayout_ItemBorder', Container);
	Border.InitLayoutItem();
	Border.SetVerticalPaddings(5);

	// Create slot itself
	SlotElement = Spawn(class'EPI_Section_Loadout_Slot', Border);
	SlotElement.InitLayoutItem();
	SlotElement.Slot = Slot;

	// Wrap slot into border
	Border.Content = SlotElement;

	// Add everything to the container and force display so it calculates the height
	Container.AddLayoutItem(Border);
	Container.Display();
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

simulated function SplitSlots (array<SlotData> AllSlots, out array<SlotData> FullRowSlots, out array<SlotData> SmallSlots)
{
	local SlotData Slot;

	foreach AllSlots(Slot) {
		if (default.FullWidthSlots.Find(Slot.SlotType) > -1) {
			FullRowSlots.AddItem(Slot);
		} else {
			SmallSlots.AddItem(Slot);
		}
	}

	// If there is only one small slot then make it full width as otherwise we will just have empty space in right column
	if (SmallSlots.Length == 1) {
		FullRowSlots.AddItem(SmallSlots[0]);
		SmallSlots.Length = 0;
	}
}