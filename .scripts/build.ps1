Param(
    [string] $srcDirectory, # the path that contains your mod's .XCOM_sln
    [string] $sdkPath, # the path to your SDK installation ending in "XCOM 2 War of the Chosen SDK"
    [string] $gamePath, # the path to your XCOM 2 installation ending in "XCOM2-WaroftheChosen"
    [string] $dependencyPath, # the path to your mods that this mod depends on, in this case LWOTC and CHL"
    [string] $config # build configuration
)

$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
$common = Join-Path -Path $ScriptDirectory "X2ModBuildCommon\build_common.ps1"
Write-Host "Sourcing $common"
. ($common)

$builder = [BuildProject]::new("ExtendedPersonnelInfo", $srcDirectory, $sdkPath, $gamePath)

# Adding LWOTC dependencies
$builder.IncludeSrc("$dependencyPath\X2WOTCCommunityHighlander(LWOTC)\X2WOTCCommunityHighlander\Src")
$builder.IncludeSrc("$dependencyPath\SquadBasedRoster\SquadBasedRoster\Src")
#$builder.IncludeSrc("$dependencyPath\LongWarOfTheChosen\Src")

switch ($config)
{
    "debug" {
        $builder.EnableDebug()
    }
    "default" {
        # Nothing special
    }
    "" { ThrowFailure "Missing build configuration" }
    default { ThrowFailure "Unknown build configuration $config" }
}

$builder.InvokeBuild()