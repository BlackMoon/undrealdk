
/**  ласс бота-человека. ѕроект "√ород" */
class Gorod_HumanBot extends Pawn
	placeable;

/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

/** ѕерва€ точка, к которой пойдет бот */
var () Gorod_HumanBotPathNode FirstPoint;

var NavigationPoint MyNextNavigationPoint;

/** ссылка на контролеер бота */
var  Gorod_HumanBotAiController botAiCont;

//пока не работаем с репликацией
var RepNotify bool bIsDied;
//var bool bIsDied;

//пока не работаем с репликацией
var SkeletalMesh ReplicatedMesh;
//пока не работаем с репликацией
var RepNotify Vector HitLoc;

/** –азмещение сбившей машины*/
//var Vector HitLoc;

 //пока не работаем с репликацией


var RepNotify int SkeletalMeshI;

replication
{
	if(bNetDirty)
		bIsDied, SkeletalMeshI,HitLoc;

}

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
	if(Physics!=PHYS_Walking)
	{
		SetPhysics(PHYS_Walking);
	}
	if (Role == Role_Authority)
	{
		GenSkeletalMesh();

		//спауним наш контроллер
		if(botAiCont==none)
		{
			bIsDied = false;
			botAiCont = Spawn(class'Gorod_HumanBotAiController');
			botAiCont.SetPawn(self);
			//танцы с бубном
			//bWantsToCrouch = true;
			//CylinderComponent.SetActorCollision(false,false);
			
		}
	}
	setTimer(0.01,true,'GorodFellOutOfWorld');
}
simulated state Idle
{

}

//пока не работаем с репликацией

simulated event ReplicatedEvent(Name VarName)
{
	if(VarName  == 'SkeletalMeshI' && Role != ROLE_Authority)
	{
		ChangeSkeletalMesh(SkeletalMeshI);
	}
	if(VarName == 'HitLoc' /*&& Role != ROLE_Authority*/)
	{
		`log("_______________>>client HitLoc = "$hitLoc);
		bPlayedDeath = true;
		BotSetDyingPhisics(HitLoc);
	}
	if(VarName == 'bIsDied')
	{
		if(bIsDied == false)
		{
			RecoverFromRagdoll();
			botAiCont.GoToState('Teleportating');
			GotoState('Idle');
		}
	}
	super.ReplicatedEvent(VarName);
}

server reliable function  GenSkeletalMesh()
{
	SkeletalMeshI = rand(3);
	ChangeSkeletalMesh(SkeletalMeshI);
}
/** Ќазначает боту случайный SkeletalMesh */
simulated function ChangeSkeletalMesh(int SkeletalMeshIndex)
{
	switch (SkeletalMeshIndex)
	{
	case 0:
		Mesh.SetSkeletalMesh(SkeletalMesh'Gorod_HumanBot.SkeletalMesh.Person_guyBag');
		break;
	case 1:
		Mesh.SetSkeletalMesh(SkeletalMesh'Gorod_HumanBot.SkeletalMesh.Person_Woman');
		break;
	case 2:
		Mesh.SetSkeletalMesh(SkeletalMesh'Gorod_HumanBot.SkeletalMesh.Person_guy');
		break;
	default:
		Mesh.SetSkeletalMesh(SkeletalMesh'Gorod_HumanBot.SkeletalMesh.Person_guy');
		break;
	}

	//пока не работаем с репликацией

	ReplicatedMesh = Mesh.SkeletalMesh;

}

function CrushedBy(Pawn OtherPawn)
{
}
simulated function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	if(DamageType!=class'KillZDamageType')
	{
		Mesh.MinDistFactorForKinematicUpdate = 0.f;
		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default, true);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn, false);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, true);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, false);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, true);
		Mesh.ForceSkelUpdate();
		Mesh.SetTickGroup(TG_PostAsyncWork);
		CollisionComponent = Mesh;
		Mesh.SetHasPhysicsAssetInstance(true);
		CylinderComponent.SetActorCollision(false, false);
		Mesh.SetActorCollision(true, false);
		Mesh.SetTraceBlocking(true, true);
		SetPhysics(PHYS_RigidBody);
		Mesh.PhysicsWeight = 1.0;

		if (Mesh.bNotUpdatingKinematicDueToDistance)
		{
			Mesh.UpdateRBBonesFromSpaceBases(true, true);
		}

		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
		Mesh.bUpdateKinematicBonesFromAnimation = false;
		Mesh.SetRBLinearVelocity(Velocity, false);
		Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
		Mesh.SetNotifyRigidBodyCollision(true);
		Mesh.WakeRigidBody();

		bIsDied = true;
		return true;
	}
	else
	{
		botAiCont.GoToState('Teleportating');
		return true;
	}
}
/** ‘ункци€ задани€ боту физассета и включени€ RigidBody*/
simulated function BotSetDyingPhisics(optional Vector Loc )
{
	Mesh.SetBlockRigidBody(true);
	if(!IsZero(Loc))
		Died(self.Controller, class'DmgType_Crushed', Loc);
	else
		Died(self.Controller, class'DmgType_Crushed', Location);
}

/** ¬озвращаемс€ из рагдола */
simulated function RecoverFromRagdoll()
{
	//перестаем обновл€ть физические кости, чтобы соотвествовать анимации
	Mesh.bUpdateKinematicBonesFromAnimation = false;
	CylinderComponent.SetActorCollision(true, false);
	CollisionComponent = CylinderComponent;
	Mesh.SetHasPhysicsAssetInstance( false);
	Mesh.PutRigidBodyToSleep();
	SetPhysics(EPhysics.PHYS_Walking);
	CylinderComponent.WakeRigidBody();

}
simulated State Dying
{
ignores Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, FellOutOfWorld;

	simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon) {}
	simulated function PlayNextAnimation() {}
	singular event BaseChange() {}
	simulated event Landed(vector HitNormal, Actor FloorActor) {}

	function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation);

	simulated singular event OutsideWorldBounds()
	{
		RecoverFromRagdoll();
		botAiCont.GoToState('Teleportating');
		GotoState('Idle');
		bIsDied = false;
	}
	simulated function RecoverTimer()
	{
			RecoverFromRagdoll();

			if(Role!=ROLE_Authority)
				self.SetHidden(true);
			else
				botAiCont.GoToState('Teleportating');
			GotoState('Idle');
			bIsDied = false;
	}

	simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
	}

	simulated event BeginState(Name PreviousStateName)
	{
		SetTimer(5.0,false,'RecoverTimer');
		SetDyingPhysics();
	}
Begin:
}

// дл€ отладки, пожалуйста, не удал€й мен€!
//simulated function DrawHUD(HUD H)
//{
//	local Vector X, Y, Z, WorldLoc, ScreenLoc;
//	local Kamaz_HUD gHud;
	
//	super.DrawHUD(H);
//	gHud = Kamaz_HUD(H);
//	if( gHud !=none)
//	{
//		// –исуем подсказку дл€ бота дл€ отладки
//		GetAxes(Rotation, X, Y, Z);
//		WorldLoc =  Location;
//		ScreenLoc = H.Canvas.Project(WorldLoc);
    	
//		if(ScreenLoc.X >= 0 &&	ScreenLoc.X < H.Canvas.ClipX && ScreenLoc.Y >= 0 && ScreenLoc.Y < H.Canvas.ClipY)
//		{
//			H.Canvas.DrawColor = MakeColor(255,255,255,255);
//			H.Canvas.SetPos(ScreenLoc.X, ScreenLoc.Y);
//			H.Canvas.DrawText("[" @self.Name @"] z = "@self.Location.Z @ " ");
//		}
//	}
//}

function GorodFellOutOfWorld()
{

	local Vector v;
	v.X=0;
	v.Y=0;
	v.Z=0;

	if(self.Location.Z<=0)
	{
		self.SetPhysics(EPhysics.PHYS_None);

		self.SetLocation(v);
		RecoverFromRagdoll();
		ClearTimer('GorodFellOutOfWorld');
		botAiCont.GoToState('Teleportating');
		GotoState('Idle');
		bIsDied = false;
	}
}

//simulated singular event OutsideWorldBounds()
//{
//	`log("OutsideWorldBounds "@self);
//	RecoverFromRagdoll();
//	botAiCont.GoToState('Teleportating');
//	GotoState('Idle');
//	bIsDied = false;

//}
//simulated event FellOutOfWorld(class<DamageType> dmgType)
//{
//	`log("FellOutOfWorld "@self);
//	RecoverFromRagdoll();
//	botAiCont.GoToState('Teleportating');
//	GotoState('Idle');
//	bIsDied = false;

//}


simulated state Dead
{
MPStart:
}
function ChangeTarget(Gorod_HumanBotPathNode HumanTarget, optional Vector botLocation, optional Rotator botRotation)
{
	botAiCont.LastTarget = HumanTarget;
	botAiCont.PrevTarget = HumanTarget;
	botAiCont.Target = HumanTarget;
	botAiCont.SetLocation(botLocation);
	botAiCont.SetRotation(botRotation);
	botAiCont.GotoState('FollowPath');
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+41.000000
		CollisionRadius=+18.000000
    End object



    Begin Object class=SkeletalMeshComponent Name=PawnSkeletalMesh
 	SkeletalMesh=SkeletalMesh'Gorod_HumanBot.SkeletalMesh.Person_guyBag'
			scale=1.27 *1.27
			AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
	AnimSets(0)=AnimSet'Gorod_HumanBot.AnimSet.HumanBot_AnimSet'
	PhysicsAsset = PhysicsAsset'Gorod_HumanBot.SkeletalMesh.Person_guy_Physics'
	bHasPhysicsAssetInstance=false
	bEnableFullAnimWeightBodies=false
	AnimTreeTemplate=AnimTree'Gorod_HumanBot.AnimTree.HumanBotAnimTree'
	CollideActors = true
	BlockActors = true
	HiddenGame=FALSE 
	HiddenEditor=FALSE
	bUseCompartment=true 
	TickGroup=TG_PreAsyncWork
	bUpdateSkelWhenNotRendered = false
	bIgnoreControllersWhenNotRendered = true
	bEnableLineCheckWithBounds = false
    End Object

    Mesh=PawnSkeletalMesh
	Components.Add(PawnSkeletalMesh)
    GroundSpeed=50.0 //Making the bot slower than the player
	MaxStepHeight=35.0 // default is 35.0
	MaxJumpHeight=41.5

	bCanCrouch=true
	bCanClimbLadders=True

	CrouchHeight=+41.6
	CrouchRadius=+17.0

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bUseBooleanEnvironmentShadowing=FALSE
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)
	/** смотри KActor */
	bSimGravityDisabled = true;

	bPhysRigidBodyOutOfWorldCheck = false;
	bIsDied = false;
}
