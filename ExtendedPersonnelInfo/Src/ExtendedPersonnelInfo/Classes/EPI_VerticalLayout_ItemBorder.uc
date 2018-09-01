class EPI_VerticalLayout_ItemBorder extends EPI_VerticalLayout_ItemPadding;

delegate ConfigureBGBox(UIBGBox BGBox);

simulated function protected DoDisplay()
{
	local UIBGBox BGBox;

	Super.DoDisplay();

	BGBox = Spawn(class'UIBGBox', self);
	BGBox.bAnimateOnInit = false;
	BGBox.InitBG('BG', 0, 0, Width, CurrentYOffset);
	BGBox.SetBGColor("gray");

	ConfigureBGBox(BGBox);
}