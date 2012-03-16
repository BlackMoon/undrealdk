class Kamaz_Checker_AutodromBorder extends Actor;

var private MaterialInstanceConstant matInst;
var StaticMeshComponent BorderMesh;

simulated function PostBeginPlay()
{	
	super.PostBeginPlay();

	matInst = new class'MaterialInstanceConstant';
	matInst.SetParent(BorderMesh.GetMaterial(0));		
	BorderMesh.SetMaterial(0, matInst);
}

function setColor(LinearColor clr)
{
	matInst.SetVectorParameterValue('Color', clr);
}

DefaultProperties
{	
	Begin Object Class=StaticMeshComponent Name=MyStaticMeshComponent
	    StaticMesh=StaticMesh'Tools_1.Meshes.Plane_yellow'
		bUsePrecomputedShadows = true
	End Object

	Components.Add(MyStaticMeshComponent);
	BorderMesh = MyStaticMeshComponent;
}
