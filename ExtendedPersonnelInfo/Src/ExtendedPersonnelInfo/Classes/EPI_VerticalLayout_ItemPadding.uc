class EPI_VerticalLayout_ItemPadding extends EPI_VerticalLayout_Item;

var float PaddingTop;
var float PaddingRight;
var float PaddingBottom;
var float PaddingLeft;

var EPI_VerticalLayout_Item Content;

simulated function InitLayoutItem()
{
	Super.InitLayoutItem();

	if (Content == none) {
		`REDSCREEN("Error:" @ default.Class @ "has no content set");
	} else if (Content.ParentPanel != self) {
		`REDSCREEN(Content.class @ "should be child of padding container it's inside of");
	}
}

simulated function protected DoDisplay() {
	Content.ConfigureVerticalLayoutItem(PaddingLeft, PaddingTop, Width - (PaddingLeft + PaddingRight));
	Content.Display();

	IncreaseYOffset(Content.CurrentYOffset);
	IncreaseYOffset(PaddingBottom);
}

simulated function SetVerticalPaddings(float NewValue)
{
	PaddingRight = NewValue;
	PaddingLeft = NewValue;
}