class EPI_VerticalLayout_Container extends EPI_VerticalLayout_Item;

var private array<EPI_VerticalLayout_Item> arrContents;

// Shortcut in case the container isn't wrapped into anything else
simulated function InitContainer(float InitWidth) {
	InitLayoutItem();
	ConfigureVerticalLayoutItem(0, 0, InitWidth);
}

simulated function AddLayoutItem (EPI_VerticalLayout_Item Item) {
	if (Item.ParentPanel != self) {
		`REDSCREEN(Item.class @ "should be child of container it's attached to");
	}

	arrContents.AddItem(Item);
}

simulated function protected DoDisplay() {
	local EPI_VerticalLayout_Item Item;

	foreach arrContents(Item) {
		Item.ConfigureVerticalLayoutItem(0, CurrentYOffset, Width);
		Item.Display();

		IncreaseYOffset(Item.CurrentYOffset);
	}
}