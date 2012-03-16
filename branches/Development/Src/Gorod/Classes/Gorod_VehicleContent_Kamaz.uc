class Gorod_VehicleContent_Kamaz extends Gorod_VehicleContent;

DefaultProperties
{
	VEHICLE_LENGTH = 450;

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'Kamaz.SkelMeshes.Kamaz_skel'
		PhysicsAsset=PhysicsAsset'Kamaz.SkelMeshes.PA_Kamaz_skel'
		AnimTreeTemplate(0)=AnimTree'Kamaz.AnimSets.AT_Kamaz_skel'
    end object

	SMesh = SVehicleMesh;

	Begin Object Name=RRWheel
		BoneName="B_R_Tire"
		SkelControlName="B_R_Tire_Cont"
		WheelRadius=32
    End Object

    Begin Object Name=LRWheel
		BoneName="B_L_Tire"
		SkelControlName="B_L_Tire_Cont"
		WheelRadius=32
    End Object

    Begin Object Name=RFWheel
		BoneName="F_R_Tire"
		SkelControlName="F_R_Tire_Cont"
		WheelRadius=32
    End Object

    Begin Object Name=LFWheel
		BoneName="F_L_Tire"
		SkelControlName="F_L_Tire_Cont"
		WheelRadius=32
    End Object
}