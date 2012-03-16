class Kamaz_PostProcessDeformationController extends Actor 
	config(ScreenDeformation);

/** Инствнс материала деформации */ 
var MaterialInstanceConstant matInst;

/** Параметры деформации, хранящиеся в конфигурационном файле */
var private config float BottomHeight;
var private config bool DeformEnabled;
var private config float TopDispToUp;
var private config float BottomSidesHeightDisp;
var private config float BottomHeaderHeightDisp;
var private config float BottomSidesFlatness;
var private config float Xdisp;
var private config float Ydisp;
var private config float TopHeight;
var private config float BottomOuterSidesHeightDisp;

/** Переменные для временного хранения параметров деформации */
var private float BottomHeightTemp;
var private bool DeformEnabledTemp;
var private float TopDispToUpTemp;
var private float BottomSidesHeightDispTemp;
var private float BottomHeaderHeightDispTemp;
var private float BottomSidesFlatnessTemp;
var private float XdispTemp;
var private float YdispTemp;
var private float TopHeightTemp;
var private float BottomOuterSidesHeightDispTemp;

/** Устанавливает высоту смещения снизу */
simulated function SetBottomHeight(float val, optional bool offDeform)
{
	if(matInst != none  &&  !offDeform)
	{
		BottomHeightTemp = val;
		matInst.SetScalarParameterValue('BottomHeight', val);
	}
}

/** Устанавливает высоту смещения сверху */
simulated function SetTopHeight(float val, optional bool offDeform)
{
	if(matInst != none  &&  !offDeform)
	{
		TopHeightTemp = val;
		matInst.SetScalarParameterValue('TopHeight', val);
	}
}

/** Устанавливает смещение верхней шапки*/
simulated function SetTopDispToUp(float val, optional bool offDeform)
{
	if(matInst != none  &&  !offDeform)
	{
		TopDispToUpTemp = val;
		matInst.SetScalarParameterValue('TopDisplacementToUp', val);
	}
}

/** Устанавливает высоту смещения боковых сторон нижней части */
simulated function SetBottomSidesHeightDisp(float val, optional bool offDeform)
{
	if(matInst != none  &&  !offDeform)
	{
		BottomSidesHeightDispTemp = val;
		matInst.SetScalarParameterValue('BottomSidesHeightDisp', val);
	}
}

/** Устанавливает степень смещения нижней "шапки" */
simulated function SetBottomHeaderHeightDisp(float val, optional bool offDeform)
{
	if(matInst != none  &&  !offDeform)
	{
		BottomHeaderHeightDispTemp = val;
		matInst.SetScalarParameterValue('BottomHeaderHeightDisp', val);
	}
}

/** Устанавливает степень выпрямления боковых сторон нижней части */
simulated function SetBottomSidesFlatness(float val, optional bool offDeform)
{
	if(matInst != none  &&  !offDeform)
	{
		BottomSidesFlatnessTemp = val;
		matInst.SetScalarParameterValue('BottomSidesFlatness', val);
	}
}

/** Устанавливает степень смещения по горизонтали */
simulated function SetXdisp(float val, optional bool offDeform)
{
	if(matInst != none  &&  !offDeform)
	{
		XdispTemp = val;
		matInst.SetScalarParameterValue('Xdisp', val);
	}
}

/** Устанавливает степень смещения по вертикали */
simulated function SetYdisp(float val, optional bool offDeform)
{
	if(matInst != none  &&  !offDeform)
	{
		YdispTemp = val;
		matInst.SetScalarParameterValue('Ydisp', val);
	}
}

/** Устанавливает степень смещения по краям нижней части */
simulated function SetBottomOuterSidesHeightDisp(float val, optional bool offDeform)
{
	if(matInst != none  &&  !offDeform)
	{
		BottomOuterSidesHeightDispTemp = val;
		matInst.SetScalarParameterValue('BottomOuterSidesHeightDisp', val);
	}
}

/** Возвращает true, если деформация включена */
function bool IsDeformEnabled()
{
	return DeformEnabledTemp;
}

//-------------------------------------------------------------------------------
/** Отключения деформации */
simulated function OffDeformation()
{
	SetBottomHeight(0, false);
	SetTopDispToUp(0, false);
	SetBottomSidesHeightDisp(0, false);
	SetBottomHeaderHeightDisp(0, false);
	SetBottomSidesFlatness(0, false);
	SetXdisp(0, false);
	SetYdisp(0, false);
	SetTopHeight(0, false);
	SetBottomOuterSidesHeightDisp(0, false);
}

/** Настройка деформации из параметров в конфигурационном файле */
simulated function SetupDeformation()
{
	SetBottomHeight(BottomHeight);
	SetTopDispToUp(TopDispToUp);
	SetBottomSidesHeightDisp(BottomSidesHeightDisp);
	SetBottomHeaderHeightDisp(BottomHeaderHeightDisp);
	SetBottomSidesFlatness(BottomSidesFlatness);
	SetXdisp(Xdisp);
	SetYdisp(Ydisp);
	SetTopHeight(TopHeight);
	SetBottomOuterSidesHeightDisp(BottomOuterSidesHeightDisp);
}

/** Включение\выключение деформации */
simulated function EnableDeformation(bool enable)
{
	DeformEnabledTemp = enable;

	if((matInst == none) && (WorldInfo.WorldPostProcessChain != none))
		matInst = MaterialInstanceConstant(MaterialEffect(WorldInfo.WorldPostProcessChain.FindPostProcessEffect('MatDeform')).Material);

	if(enable)
		SetupDeformation();
	else
		OffDeformation();
}

/** Сохранение параметров деформации из временных переменных в конф. файл */
simulated function SaveDeformations()
{
	DeformEnabled = DeformEnabledTemp;

	if(DeformEnabledTemp)
	{
		BottomHeight = BottomHeightTemp;
		TopDispToUp = TopDispToUpTemp;
		BottomSidesHeightDisp = BottomSidesHeightDispTemp;
		BottomHeaderHeightDisp = BottomHeaderHeightDispTemp;
		BottomSidesFlatness = BottomSidesFlatnessTemp;
		Xdisp = XdispTemp;
		Ydisp = YdispTemp;
		TopHeight = TopHeightTemp;
		BottomOuterSidesHeightDisp = BottomOuterSidesHeightDispTemp;
	}

	SaveConfig();
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	BottomHeightTemp = BottomHeight;
	DeformEnabledTemp = DeformEnabled;
	TopDispToUpTemp = TopDispToUpTemp;
	BottomSidesHeightDispTemp = BottomSidesHeightDisp;
	BottomHeaderHeightDispTemp = BottomHeaderHeightDisp;
	BottomSidesFlatnessTemp = BottomSidesFlatness;
	XdispTemp = Xdisp;
	YdispTemp = Ydisp;
	TopHeightTemp = TopHeight;
	BottomOuterSidesHeightDispTemp = BottomOuterSidesHeightDisp;

	if(matInst == none)
		matInst = MaterialInstanceConstant(MaterialEffect(WorldInfo.WorldPostProcessChain.FindPostProcessEffect('MatDeform')).Material);

	if(DeformEnabled)
		SetupDeformation();
	else
		OffDeformation();
}

DefaultProperties
{
	//ppchain = PostProcessChain'Gorod_Effects.PostProcess.PostProcessChain_Deformation'
}
