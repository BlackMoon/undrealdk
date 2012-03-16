class Forsage_ScreenCalibration extends Actor
	config(ForsageScreenDeform);//Object;

var config float p1_x;
var config float p1_y;
var config float p2_x;
var config float p2_y;
var config float p3_x;
var config float p3_y;
var config float p4_x;
var config float p4_y;
var config float p5_x;
var config float p5_y;
var config float p6_x;
var config float p6_y;
var config float p7_x;
var config float p7_y;
var config float p8_x;
var config float p8_y;

var float tp1_x;
var float tp1_y;
var float tp2_x;
var float tp2_y;
var float tp3_x;
var float tp3_y;
var float tp4_x;
var float tp4_y;
var float tp5_x;
var float tp5_y;
var float tp6_x;
var float tp6_y;
var float tp7_x;
var float tp7_y;
var float tp8_x;
var float tp8_y;


var MaterialInstanceConstant matInst;

function InitDeform()
{
	if(WorldInfo.WorldPostProcessChain == none)
		return;

	matInst = MaterialInstanceConstant(MaterialEffect(WorldInfo.WorldPostProcessChain.FindPostProcessEffect('MatDeform')).Material);

	if(matInst != none)
	{
		SetupDeform(false);
	}
}


function SetupDeform(bool reset)
{
	if(reset)
	{
		Set_P1_X(0);
		Set_P1_Y(0);
		Set_P2_X(0);
		Set_P2_Y(0);
		Set_P3_X(0);
		Set_P3_Y(0);
		Set_P4_X(0);
		Set_P4_Y(0);
		Set_P5_X(0);
		Set_P5_Y(0);
		Set_P6_X(0);
		Set_P6_Y(0);
		Set_P7_X(0);
		Set_P7_Y(0);
		Set_P8_X(0);
		Set_P8_Y(0);
	}
	else
	{
		Set_P1_X(p1_x);
		Set_P1_Y(p1_y);
		Set_P2_X(p2_x);
		Set_P2_Y(p2_y);
		Set_P3_X(p3_x);
		Set_P3_Y(p3_y);
		Set_P4_X(p4_x);
		Set_P4_Y(p4_y);
		Set_P5_X(p5_x);
		Set_P5_Y(p5_y);
		Set_P6_X(p6_x);
		Set_P6_Y(p6_y);
		Set_P7_X(p7_x);
		Set_P7_Y(p7_y);
		Set_P8_X(p8_x);
		Set_P8_Y(p8_y);
	}
}

function SaveCalibration()
{
	p1_x = tp1_x;
	p1_y = tp1_y;
	p2_x = tp2_x;
	p2_y = tp2_y;
	p3_x = tp3_x;
	p3_y = tp3_y;
	p4_x = tp4_x;
	p4_y = tp4_y;
	p5_x = tp5_x;
	p5_y = tp5_y;
	p6_x = tp6_x;
	p6_y = tp6_y;
	p7_x = tp7_x;
	p7_y = tp7_y;
	p8_x = tp8_x;
	p8_y = tp8_y;

	SaveConfig();
}

/** @fixme */
function Reset()
{
	Set_P1_X(p1_x);
}

function Set_P1_X(float val) {
	tp1_x = val;
	matInst.SetScalarParameterValue('p1_x', val);
}
function Set_P1_Y(float val) {
	tp1_y = val;
	matInst.SetScalarParameterValue('p1_y', val);
}

function Set_P2_X(float val) {
	tp2_x = val;
	matInst.SetScalarParameterValue('p2_x', val);
}

function Set_P2_Y(float val) {
	tp2_y = val;
	matInst.SetScalarParameterValue('p2_y', val);
}

function Set_P3_X(float val) {
	tp3_x = val;
	matInst.SetScalarParameterValue('p3_x', val);
}

function Set_P3_Y(float val) {
	tp3_y = val;
	matInst.SetScalarParameterValue('p3_y', val);
}

function Set_P4_X(float val) {
	tp4_x = val;
	matInst.SetScalarParameterValue('p4_x', val);
}

function Set_P4_Y(float val) {
	tp4_y = val;
	matInst.SetScalarParameterValue('p4_y', val);
}

function Set_P5_X(float val) {
	tp5_x = val;
	matInst.SetScalarParameterValue('p5_x', val);
}

function Set_P5_Y(float val) {
	tp5_y = val;
	matInst.SetScalarParameterValue('p5_y', val);
}

function Set_P6_X(float val) {
	tp6_x = val;
	matInst.SetScalarParameterValue('p6_x', val);
}

function Set_P6_Y(float val) {
	tp6_y = val;
	matInst.SetScalarParameterValue('p6_y', val);
}

function Set_P7_X(float val) {
	tp7_x = val;
	matInst.SetScalarParameterValue('p7_x', val);
}

function Set_P7_Y(float val) {
	tp7_y = val;
	matInst.SetScalarParameterValue('p7_y', val);
}

function Set_P8_X(float val) {
	tp8_x = val;
	matInst.SetScalarParameterValue('p8_x', val);
}

function Set_P8_Y(float val) {
	tp8_y = val;
	matInst.SetScalarParameterValue('p8_y', val);
}

DefaultProperties
{
}
