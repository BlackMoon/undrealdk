/**Область стоп линии для знака**/
class Gorod_Znak_2_5_ControlEnd extends Gorod_Znak_Speed placeable;


function Activate(vector HitLocation, vector HitNormal)
{
	super.Activate(HitLocation, HitNormal);
	/** Проверим направление въезда в знак, если верно вызовем событие*/
	if(CheckDirection(HitLocation,HitNormal))
	{
		SendZnakEvent(self,2009);
	}
}



function bool CheckDirection(vector HitLocation, vector HitNormal)
{
	local Rotator rotRes;

		/**подъехали с лицевов стороны знака?*/
	rotRes= Rotator(HitNormal)-Rotation;
	`log(rotRes.Yaw*UnrRotToDeg); 
	if (rotRes.Yaw*UnrRotToDeg>0 || rotRes.Yaw*UnrRotToDeg<-180 )
	{
		`log(rotRes.Yaw*UnrRotToDeg @ ">0 ||" @ rotRes.Yaw*UnrRotToDeg @ " <-180"); 
		return false;
	}
	return true;
}

DefaultProperties
{
	Begin Object Name=MeshCompSignBox 
		StaticMesh = StaticMesh'Tools_1.Meshes.Mesh_Plane150x1x150_Blue' //коллизия, положение коллизии ???
	End Object
	speed_limit=0;
}