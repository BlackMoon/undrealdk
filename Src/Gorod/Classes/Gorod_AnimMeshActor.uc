/** Класс анимационного-человека. Он не сбивается. Проект "Город" */

class Gorod_AnimMeshActor extends Pawn
	placeable;

var float AnimationType;


/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
	if (Role == Role_Authority)
		ChangeSkeletalMesh();
}

simulated state Idle
{
}

/** Назначает боту случайный SkeletalMesh */
simulated function ChangeSkeletalMesh()
{
	local int SkeletalMeshI;
	SkeletalMeshI = rand(3);
	switch (SkeletalMeshI)
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
	
}

simulated state Dead
{
MPStart:
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+41.000000
		CollisionRadius=+18.000000
    End object


    Begin Object class=SkeletalMeshComponent Name=PawnSkeletalMesh
 	SkeletalMesh=SkeletalMesh'Gorod_HumanBot.SkeletalMesh.Person_guy'
			scale=1.27
			AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
	AnimSets(0)=AnimSet'Gorod_HumanBot.AnimSet.HumanBot_AnimSet'
	AnimTreeTemplate=AnimTree'Gorod_HumanBot.AnimTree.HumanBotAnimTree'
	CollideActors = true
	BlockActors = true
	HiddenGame=FALSE 
	HiddenEditor=FALSE
    End Object

    Mesh=PawnSkeletalMesh
	Components.Add(PawnSkeletalMesh)
	//это прописано в базовом классе

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=true
		bUseBooleanEnvironmentShadowing=FALSE
	End Object
	AnimationType = 0.0;

	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)
}
