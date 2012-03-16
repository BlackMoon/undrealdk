/** Триггер с коллизией бокса */

class Gorod_Trigger extends Actor placeable;

var(BoxCollision) StaticMeshComponent MeshBox;
var MaterialInstanceConstant MatInst;

var	const color	WhiteColor, GreenColor, RedColor;

/**
 * SetColor - устанавливаем цвет триггера */
function SetColor(Color newColor)
{
	local LinearColor CurrentCol;
	
	CurrentCol = ColorToLinearColor(newColor);
	MatInst.SetVectorParameterValue('Color', CurrentCol);
}

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	/* устанавливаем цвет триггера */
	SetColor(GreenColor);
}


event UnTouch( Actor Other )
{
	/* устанавливаем цвет триггера */
	SetColor(RedColor);
}


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	MatInst = new class'MaterialInstanceConstant';
	MatInst.SetParent(MeshBox.GetMaterial(0));
	MeshBox.SetMaterial(0, MatInst);

	SetCollisionType(COLLIDE_TouchAll);
}

defaultproperties
{

	WhiteColor=(R=255,G=255,B=255,A=255)
	GreenColor=(R=0,G=255,B=0,A=255)
	RedColor=(R=255,G=0,B=0,A=255)

	Begin Object Class=StaticMeshComponent Name=MBox 
		StaticMesh = StaticMesh'Tools_1.Meshes.Mesh_Plane150x1x150'
		CollideActors = true
		BlockActors = false
		BlockRigidBody=false
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		bUsePrecomputedShadows = true
		HiddenGame = true
	End Object
	Components.Add(MBox);
	MeshBox = MBox
	CollisionComponent = MBox
}
