// Sorting functions copied/adapted from UISoldierBondScreen
class EPI_Utilities_BondCadidateSorting extends Object;

var XComGameState_Unit CurrentUnit;

simulated function SortByCompatibility (out array<XComGameState_Unit> BondCandidates)
{
	BondCandidates.Sort(CompareByCompatibility);
}

simulated function SortByCohesion (out array<XComGameState_Unit> BondCandidates)
{
	BondCandidates.Sort(CompareByCohesion);
}

simulated function int CompareByCompatibility(XComGameState_Unit A, XComGameState_Unit B)
{
	local SoldierBond BondDataA, BondDataB;

	CurrentUnit.GetBondData(A.GetReference(), BondDataA);
	CurrentUnit.GetBondData(B.GetReference(), BondDataB);
	
	if (BondDataA.Compatibility < BondDataB.Compatibility)
	{
		return -1;
	}
	else if (BondDataA.Compatibility > BondDataB.Compatibility)
	{
		return 1;
	}
	else if (BondDataA.Cohesion != BondDataB.Cohesion)  // Compatibility match, so sort by Cohesion if possible
	{
		return CompareByCohesion(A, B);
	}
	else
	{
		return CompareByName(A, B);
	}
}

simulated function int CompareByCohesion(XComGameState_Unit A, XComGameState_Unit B)
{
	local SoldierBond BondDataA, BondDataB;

	CurrentUnit.GetBondData(A.GetReference(), BondDataA);
	CurrentUnit.GetBondData(B.GetReference(), BondDataB);

	if (BondDataA.Cohesion < BondDataB.Cohesion)
	{
		return -1;
	}
	else if (BondDataA.Cohesion > BondDataB.Cohesion)
	{
		return 1;
	}
	else if (BondDataA.Compatibility != BondDataB.Compatibility)  // Cohesion match, so sort by compatibility if possible
	{
		return CompareByCompatibility(A, B);
	}
	else
	{
		return CompareByName(A, B);
	}
}

simulated function int CompareByName(XComGameState_Unit A, XComGameState_Unit B)
{
	local string NameA, NameB, FullA, FullB;

	NameA = A.GetName(eNameType_Last);
	NameB = B.GetName(eNameType_Last);

	if (NameA < NameB)
	{
		return -1;
	}
	else if (NameA > NameB)
	{
		return 1;
	}
	else // Last names match, so sort by full name.
	{
		FullA = A.GetName(eNameType_Full);
		FullB = B.GetName(eNameType_Full);
		
		if (FullA < FullB)
		{
			return -1;
		}
		else if (FullA > FullB)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
}