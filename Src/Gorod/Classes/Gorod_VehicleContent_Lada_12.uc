class Gorod_VehicleContent_Lada_12 extends Gorod_VehicleContent;

DefaultProperties
{
	VEHICLE_LENGTH = 300;

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'Cars.Skel_Meshes.LADA_skel'
		PhysicsAsset=PhysicsAsset'Cars.Skel_Meshes.LADA_skel_Physics'
		AnimTreeTemplate(0)=AnimTree'Cars.Skel_Meshes.LADA_skel_AnimTree'
    end object

	SMesh = SVehicleMesh;

	CollisionType = COLLIDE_BlockAll

	Begin Object Name=RRWheel
		BoneName="B_R_Tire"
		SkelControlName="B_R_Tire_Cont"
		WheelRadius=17
    End Object

    Begin Object Name=LRWheel
		BoneName="B_L_Tire"
		SkelControlName="B_L_Tire_Cont"
		WheelRadius=17
    End Object

    Begin Object Name=RFWheel
		BoneName="F_R_Tire"
		SkelControlName="F_R_Tire_Cont"
		WheelRadius=17
    End Object

    Begin Object Name=LFWheel
		BoneName="F_L_Tire"
		SkelControlName="F_L_Tire_Cont"
		WheelRadius=17
    End Object
}