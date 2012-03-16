class Gorod_VehicleContent_Audi extends Gorod_VehicleContent;

DefaultProperties
{
	VEHICLE_LENGTH = 300;

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'Cars.Skel_Meshes.Audi_Skel'
		PhysicsAsset=PhysicsAsset'Cars.Skel_Meshes.Audi_Skel_Physics'
		AnimTreeTemplate(0)=AnimTree'Cars.Skel_Meshes.Audi_Skel_AnimTree'
    end object

	SMesh = SVehicleMesh;

	Begin Object Name=RRWheel
		BoneName="B_R_Tire"
		SkelControlName="B_R_Tire"
		WheelRadius=18.7
    End Object

    Begin Object Name=LRWheel
		BoneName="B_L_Tire"
		SkelControlName="B_L_Tire"
		WheelRadius=18.7
    End Object

    Begin Object Name=RFWheel
		BoneName="F_R_Tire"
		SkelControlName="F_R_Tire"
		WheelRadius=18.7
    End Object

    Begin Object Name=LFWheel
		BoneName="F_L_Tire"
		SkelControlName="F_L_Tire"
		WheelRadius=18.7
    End Object
}
