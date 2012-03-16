class Gorod_Znak_2_5_ControlArea extends Gorod_Znak_Speed placeable;

var () TriggerVolume triger;

function Activate(vector HitLocation, vector HitNormal)
{
	super.Activate(HitLocation, HitNormal);
	if(CheckDirection(HitLocation,HitNormal))
	{
		SendZnakEvent(self,2007);
	}
}

function UnActivate()
{
	SendZnakEvent(self,2008);
}



function bool CheckDirection(vector HitLocation, vector HitNormal)
{
	local Rotator rotRes;

	rotRes= Rotator(HitNormal)-Rotation;
	`log(rotRes.Yaw*UnrRotToDeg);

	/**подъехали с лицевов стороны знака?*/
	if (rotRes.Yaw*UnrRotToDeg<91 &&  rotRes.Yaw*UnrRotToDeg>89)
	{
		`log(rotRes.Yaw*UnrRotToDeg @ "==90"); 
		return false;
	}
	return true;
}

DefaultProperties
{
	Begin Object Name=MeshCompSign
		Materials[0] = MaterialInstanceConstant'Znaky.Material_Instances.2_5_mINST'
	End Object
	speed_limit=0;
}
