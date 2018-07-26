// This class deals with spawing side panes and listening to changes on the personnel screen
class EPI_Main extends UIPanel;

// These are set outside
var UIPersonnel Personnel;

// These are set inside
var EPI_LeftPane LeftPane;
var EPI_RightPane RightPane;
var XComGameState_Unit CurrentUnit;

delegate PreviousOnSetSelectedIndex(UIList ContainerList, int ItemIndex);

simulated function InitEPIMain () 
{
	InitPanel(name("EPI"));

	LeftPane = Spawn(class'EPI_LeftPane', self);
	LeftPane.InitLeftPane();

	RightPane = Spawn(class'EPI_RightPane', self);
	RightPane.InitRightPane();

	PreviousOnSetSelectedIndex = Personnel.m_kList.OnSetSelectedIndex;
	Personnel.m_kList.OnSetSelectedIndex = OnListSetSelectedIndex;

	UpdateCurrentUnit(Personnel.m_kList.SelectedIndex);
	UpdateDisplay();
}

simulated function UpdateDisplay ()
{
	LeftPane.DisplayFor(CurrentUnit);
	RightPane.DisplayFor(CurrentUnit);
}

simulated function OnListSetSelectedIndex(UIList ContainerList, int ItemIndex) 
{
	UpdateCurrentUnit(ItemIndex);
	UpdateDisplay();

	PreviousOnSetSelectedIndex(ContainerList, ItemIndex);
}

simulated function UpdateCurrentUnit (int Index)
{
	local UIPersonnel_ListItem ListItem;

	ListItem = UIPersonnel_ListItem(Personnel.m_kList.GetItem(Index));

	if (ListItem == none) {
		CurrentUnit = none;
		return;
	}

	CurrentUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ListItem.UnitRef.ObjectID));
}

defaultproperties 
{
	bAnimateOnInit = false;
}