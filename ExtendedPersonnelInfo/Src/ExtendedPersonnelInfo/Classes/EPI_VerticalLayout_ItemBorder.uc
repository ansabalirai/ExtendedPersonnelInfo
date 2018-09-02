class EPI_VerticalLayout_ItemBorder extends EPI_VerticalLayout_ItemPadding;

var UIBGBox BGBox;

// This can be used to modify the border after all built-in configuration is finished
delegate ConfigureBGBox(UIBGBox BG);

simulated function InitLayoutItem()
{
	Super.InitLayoutItem();

	// We init the bg before everything else so that it goes under
	BGBox = Spawn(class'UIBGBox', self);
	BGBox.bAnimateOnInit = false;
	BGBox.InitBG('BG', 0, 0);
	BGBox.SetBGColor("gray");
}

simulated function protected DoDisplay()
{
	Super.DoDisplay();

	BGBox.SetHeight(CurrentYOffset);
	BGBox.SetWidth(Width);

	ConfigureBGBox(BGBox);
}