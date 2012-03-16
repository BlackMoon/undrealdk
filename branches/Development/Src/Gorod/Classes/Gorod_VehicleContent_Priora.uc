class Gorod_VehicleContent_Priora extends Gorod_VehicleContent;

DefaultProperties
{
	VEHICLE_LENGTH = 300;

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'Cars.Skel_Meshes.Lada_Priora'
		PhysicsAsset=PhysicsAsset'Cars.Skel_Meshes.Lada_Priora_Physics'
		AnimTreeTemplate(0)=AnimTree'Cars.Skel_Meshes.Lada_Priora_AnimTree'
    end object
	DrawScale = 1.27;


	SMesh = SVehicleMesh;
	

	Begin Object Name=RRWheel
		BoneName="B_R_Tire"
		SkelControlName="B_R_Tire"
		WheelRadius=17.2
		SuspensionTravel=0.1
    End Object

    Begin Object Name=LRWheel
		BoneName="B_L_Tire"
		SkelControlName="B_L_Tire"
		WheelRadius=17.2
		SuspensionTravel=0.1
    End Object

    Begin Object Name=RFWheel
		BoneName="F_R_Tire"
		SkelControlName="F_R_Tire"
		WheelRadius=17.2
    End Object

    Begin Object Name=LFWheel
		BoneName="F_L_Tire"
		SkelControlName="F_L_Tire"
		WheelRadius=17.2
	End Object
}
