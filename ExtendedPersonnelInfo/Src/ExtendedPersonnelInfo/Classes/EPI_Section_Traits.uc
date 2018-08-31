class EPI_Section_Traits extends EPI_Section;

// Config
var float TraitLineHeight;

simulated function InitAndDisplay(XComGameState_Unit Unit, out float YOffset)
{
	// Data
	local X2EventListenerTemplateManager EventTemplateManager;
	local X2TraitTemplate TraitTemplate;
	local name TraitName;

	// UI
	local EPI_SectionHeader Header;
	local UIIcon TraitIcon;
	local UIText TraitText;

	// Setup self
	InitPanel(name("Traits"));
	SetPosition(0, 0); // We use YOffset directly

	// Do not show anything if there are no traits
	if (Unit.AcquiredTraits.Length == 0) {
		return;
	}

	// Setup header
	Header = Spawn(class'EPI_SectionHeader', self);
	Header.InitSectionHeader("Traits", OwningPane.TargetWidth, name("TraitsHeader"));
	Header.SetPosition(0, YOffset);

	YOffset += 40;

	// Create traits
	EventTemplateManager = class'X2EventListenerTemplateManager'.static.GetEventListenerTemplateManager();
	foreach Unit.AcquiredTraits(TraitName)
	{
		TraitTemplate = X2TraitTemplate(EventTemplateManager.FindEventListenerTemplate(TraitName));
		if(TraitTemplate != none)
		{
			TraitIcon = Spawn(class'UIIcon', self);
			TraitIcon.bAnimateOnInit = false;
			TraitIcon.bIsNavigable = false;
			TraitIcon.InitIcon(, TraitTemplate.IconImage, false);
			TraitIcon.SetBGColor(TraitTemplate.bPositiveTrait ? class'UIUtilities_Colors'.const.GOOD_HTML_COLOR : class'UIUtilities_Colors'.const.BAD_HTML_COLOR);
			TraitIcon.SetSize(TraitLineHeight, TraitLineHeight);
			TraitIcon.SetPosition(10, YOffset);

			TraitText = Spawn(class'UIText', self);
			TraitText.bAnimateOnInit = false;
			TraitText.InitText(, TraitTemplate.TraitFriendlyName);
			TraitText.SetPosition(TraitIcon.X + TraitIcon.Width + 5, YOffset);

			YOffset += TraitLineHeight + 10;
		}
	}
}

defaultproperties
{
	TraitLineHeight = 25;
}