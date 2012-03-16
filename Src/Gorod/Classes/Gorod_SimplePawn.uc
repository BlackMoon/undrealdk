/** Спавнится по-умолчанию для игрока. Добавлена проверка на сущствование контроллера */
class Gorod_SimplePawn extends SimplePawn;

event TickSpecial( float DeltaTime )
{
	// NOTE: The following was pulled from UT's head bobbing features

	local bool bAllowBob;
	local float smooth, Speed2D;
	local vector X, Y, Z;

	// Set ground speed
	GroundSpeed = CastlePawnSpeed;
	AccelRate = CastlePawnAccel;

	bAllowBob = true;
	if ( abs(Location.Z - OldZ) > 15 )
	{
		// if position difference too great, don't do head bob
		bAllowBob = false;
		BobTime = 0;
		WalkBob = Vect(0,0,0);
	}

	if ( bAllowBob )
	{
		// normal walking around
		// smooth eye position changes while going up/down stairs
		smooth = FMin(0.9, 10.0 * DeltaTime/CustomTimeDilation);

		// проверка
		if(Controller!=none)
		{
			if( Physics == PHYS_Walking || Controller.IsInState('PlayerClickToMove') )
			{
				EyeHeight = FMax((EyeHeight - Location.Z + OldZ) * (1 - smooth) + BaseEyeHeight * smooth,
									-0.5 * CylinderComponent.CollisionHeight);
			}
			else
			{
				EyeHeight = EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth;
			}
		}

		// Add walk bob to movement
		Bob = FClamp(Bob, -0.15, 0.15);

		if (Physics == PHYS_Walking )
		{
			GetAxes(Rotation,X,Y,Z);
			Speed2D = VSize(Velocity);
			if ( Speed2D < 10 )
			{
			  BobTime += 0.2 * DeltaTime;
			}
			else
			{
				BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
			}
			WalkBob = Y * Bob * Speed2D * sin(8 * BobTime);
			AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
			WalkBob.Z = AppliedBob;
			if ( Speed2D > 10 )
			{
				WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * sin(16 * BobTime);
			}
		}
		else if ( Physics == PHYS_Swimming )
		{
			GetAxes(Rotation,X,Y,Z);
			BobTime += DeltaTime;
			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * BobTime);
			WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * BobTime);
		}
		else
		{
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		WalkBob *= 0.1;
	}

	OldZ = Location.Z;
}

simulated function FellOutOfWorld(class<DamageType> dmgType)
{
}

DefaultProperties
{
	    Begin Object class=SkeletalMeshComponent Name=PawnSkeletalMesh
 	SkeletalMesh=SkeletalMesh'Gorod_HumanBot.SkeletalMesh.Person_Firefighter'
			scale=1.27
			AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
	AnimSets(0)=AnimSet'Gorod_HumanBot.AnimSet.HumanBot_AnimSet'
	PhysicsAsset = PhysicsAsset'Gorod_HumanBot.SkeletalMesh.Person_guy_Physics'
	bHasPhysicsAssetInstance=false
	bEnableFullAnimWeightBodies=true
	AnimTreeTemplate=AnimTree'Gorod_HumanBot.AnimTree.HumanBotAnimTree'
	CollideActors = true
	BlockActors = true
	HiddenGame=FALSE 
	HiddenEditor=FALSE
	bUseCompartment=true 
	TickGroup=TG_PreAsyncWork
    End Object
	
    Mesh=PawnSkeletalMesh
	Components.Add(PawnSkeletalMesh)

}
