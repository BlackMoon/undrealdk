class Gorod_VehicleLightsController extends Actor;

var MaterialInstanceConstant MatInst;

/**
 * ������ �� ������-����, ��������� ��������� ������� �� ���������
 */
var Gorod_AIVehicle AIVehicle;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	AIVehicle = Gorod_AIVehicle(Owner);

	if(AIVehicle == none)
	{
		`warn("[Gorod_VehicleLightsController]: owner is not a Gorod_AIVehicle!");
		return;
	}
	
	MatInst = new class'MaterialInstanceConstant';
	MatInst.SetParent(AIVehicle.SMesh.GetMaterial(0));
	AIVehicle.SMesh.SetMaterial(0, MatInst);
}

/********************************************************************/
/*          ���/���� �������� ������� (������ � ����������)         */
/********************************************************************/

/**
 * ���/���� ����� ����������
 */
simulated function SetLeftTurnSignal(bool bOn)
{
	if(bOn)
		MatInst.SetScalarParameterValue('LeftLamp_OnOff', 1);
	else
		MatInst.SetScalarParameterValue('LeftLamp_OnOff', 0);
}

/**
 *  ���/���� ������ ���������� 
 */
simulated function SetRightTurnSignal(bool bOn)
{
	if(bOn)
		MatInst.SetScalarParameterValue('RightLamp_OnOff', 1);
	else
		MatInst.SetScalarParameterValue('RightLamp_OnOff', 0);
}

/**
 *  ���/���� ���������� ����
 */
simulated function SetParkingLights(bool bOn)
{
	if(bOn)
		MatInst.SetScalarParameterValue('MarkerLights_OnOff', 1);
	else
		MatInst.SetScalarParameterValue('MarkerLights_OnOff', 0);
}

/**
 * ���/���� ����
 */
simulated function SetHeadLights(bool bOn)
{
	if(bOn)
		MatInst.SetScalarParameterValue('FrontLamps_OnOff', 1);
	else
		MatInst.SetScalarParameterValue('FrontLamps_OnOff', 0);
}

/********************************/
/*          ���� ������         */
/********************************/
simulated function SetColor(LinearColor col)
{
	MatInst.SetVectorParameterValue('Kuzov_Color', col);
}

/***********************************************************/
/*          ���������� ��������� �������� ��������         */
/***********************************************************/

simulated function UpdateSignalLights()
{
	SetLeftTurnSignal(AIVehicle.LightsInfo.bLeftSignalLightOn);
	SetRightTurnSignal(AIVehicle.LightsInfo.bRightSignalLightOn);
	SetHeadLights(AIVehicle.LightsInfo.bHeadLightsOn);
	SetParkingLights(AIVehicle.LightsInfo.bParkingLightsOn);
}

DefaultProperties
{
	RemoteRole = ROLE_SimulatedProxy;
}
