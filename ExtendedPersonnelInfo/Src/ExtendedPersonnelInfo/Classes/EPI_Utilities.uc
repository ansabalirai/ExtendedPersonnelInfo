class EPI_Utilities extends Object;

const PersonnelX = 480;
const PersonnelY = 90;

const PersonnelWidth = 1000;
const PersonnelHeight = 880;

static function LogDiamentions (string id, UIPanel Panel) 
{
	`log(id $ ": (" $ Panel.X $ ", " $ Panel.Y $ ") (" $ Panel.Width $ ", " $ Panel.Height $ ")");
}