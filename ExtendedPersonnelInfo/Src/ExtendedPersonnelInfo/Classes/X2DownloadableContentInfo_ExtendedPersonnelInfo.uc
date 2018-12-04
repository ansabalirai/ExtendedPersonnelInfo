class X2DownloadableContentInfo_ExtendedPersonnelInfo extends X2DownloadableContentInfo;

exec function ToggleEPILoadoutDebug()
{
	local EPI_Section_Loadout LoadoutSection;

	LoadoutSection = EPI_Section_Loadout(class'XComEngine'.static.GetClassDefaultObject(class'EPI_Section_Loadout'));

	if (LoadoutSection == none)
	{
		`log("Failed to fetch CDO for EPI_Section_Loadout",, 'EPI');
		return;
	}

	LoadoutSection.EnableDataDebug = !LoadoutSection.EnableDataDebug;
	`log((LoadoutSection.EnableDataDebug ? "Enabled" : "Disabled") @ "loadout data debug",, 'EPI');
}