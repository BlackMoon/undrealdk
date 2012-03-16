class Forsage_Pawn extends GamePawn dependson(Forsage_PLayerCar);

var repnotify private Forsage_PlayerCar basePawn;       
var eViewMode ViewMode;

replication
{
	if (bNetInitial && Role == Role_Authority) basePawn;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'basePawn')		
		basePawn.showVehicleMesh(ViewMode);		
	else 
		super.ReplicatedEvent(VarName);
}

simulated function bool CalcCamera(float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV)
{	
	local bool bres;	
	local MirrorSettings ms;
	bres = false;

	if (Role < Role_Authority && basePawn != none)
	{
		ms = basePawn.getMirrorSettings(ViewMode);		
		out_CamLoc = basePawn.getMirrorLocation(ViewMode);				
		out_CamRot = ms.Rotation;			
		out_FOV = ms.FOV;
		bres = true;		
	}		
	return bres;
}

function SetBasePawn(Pawn P)
{	
	basePawn = Forsage_PlayerCar(P);		
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{	
	return false;	
}

DefaultProperties
{	
	bAlwaysRelevant = true
}
