class EPI_VerticalLayout_Container extends EPI_VerticalLayout_Item;

var private array<EPI_VerticalLayout_Item> arrContents;

var float SpacingBetweenItems;

// Shortcut in case the container isn't wrapped into anything else
simulated function InitContainer(float InitWidth) {
	InitLayoutItem();
	ConfigureVerticalLayoutItem(0, 0, InitWidth);
}

simulated function AddLayoutItem (EPI_VerticalLayout_Item Item) {
	if (Item.bIsDisplayed) {
		`REDSCREEN(Item.name @ "is already displayed - cannot be added to container");
		return;
	}

	if (Item.ParentPanel != self) {
		`REDSCREEN(Item.name @ "should be child of container it's attached to");
		return;
	}

	arrContents.AddItem(Item);
}

simulated function Display() {
	local EPI_VerticalLayout_Item Item;
	local bool HadPrevious;

	foreach arrContents(Item) {
		if (Item.bIsDisplayed) {
			HadPrevious = true;
			continue;
		}

		if (HadPrevious) {
			IncreaseYOffset(SpacingBetweenItems);
		}

		Item.ConfigureVerticalLayoutItem(0, CurrentYOffset, Width);
		Item.Display();

		IncreaseYOffset(Item.CurrentYOffset);
		HadPrevious = true;
	}

	MarkDisplayed();
}

defaultproperties
{
	SpacingBetweenItems = 0;
}