//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "MainForm.h"
#include "CarX.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "NxInspector"
#pragma link "NxScrollControl"
#pragma link "NxPropertyItemClasses"
#pragma link "NxPropertyItems"
#pragma link "Chart"
#pragma link "TeEngine"
#pragma link "TeeProcs"
#pragma link "Series"
#pragma link "TeEngine"



#pragma resource "*.dfm"

TfrmMain *frmMain;
//---------------------------------------------------------------------------
__fastcall TfrmMain::TfrmMain(TComponent* Owner)
	: TForm(Owner)
{
}
//---------------------------------------------------------------------------
void TfrmMain::Main() {
	do {
		//car->rpm = txtRpm->Value.ToDouble();
		car->setU(VectorX);
		car->setThrottle (trbThrottle->Position/100.0f);
		car->setClutch (trbClutch->Position/100.0f);
		if (cbxStarter->AsBoolean)
			car->toRun();
		else
			car->toStop();

		car->setGear (spnGear->AsInteger);

		car->progress();

		txtRpm->Value 		= FormatFloat("0.00", car->getRPM());
		txtWheelRpm->Value 	= FormatFloat("0.00", car->wheels.rpm());

		txtFtraction->Value = FormatFloat("0.00", car->Ftraction().length());
		txtFlong->Value 	= FormatFloat("0.00", car->Flong().length());
		txtSpeed->Value 	= FormatFloat("0.00", car->getSpeed().length());

		NxProgressItem1->Position = car->getRPM()/100;
		trbThrottle->Position = 100 * car->getThrottle();

		txtBaseTorque->Value		 = FormatFloat("0.00", car->baseTorque());
		txtEngineTorque->Value		 = FormatFloat("0.00", car->engine.engineOutputTorque());
		txtEngineClutchTorque->Value = FormatFloat("0.00", car->engine.getClutchTorque());
		txtWhellsTorque->Value 		 = FormatFloat("0.00", car->wheels.getTorque());
		txtWheelsClutchTorque->Value = FormatFloat("0.00", car->wheels.getClutchTorque());
		//txtFwheels.Value 			 = FormatFloat("0.00", car->wheels.getClutchTorque()/car->wheels.R);
		txtA->Value = FormatFloat("0.00", car->Flong().length() / car->mass);

		cbxStarter->AsBoolean = car->engine.isRun;
		Sleep(10);
		Application->ProcessMessages();
	} while (_lookup);

}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::FormCreate(TObject *Sender)
{
	car =  new TCar();
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::FormClose(TObject *Sender, TCloseAction &Action)
{
	_lookup = false;
	free(car);
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::btnStartClick(TObject *Sender)
{
	_lookup = true;

	Main();
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::btnStropClick(TObject *Sender)
{
	_lookup = false;
}
//---------------------------------------------------------------------------
void __fastcall TfrmMain::BitBtn1Click(TObject *Sender)
{
//	TEngine *engine = new TEngine ();
	car->engine.isRun = true; // заводим движок
	car->engine.clutch = 0.0f;
	car->engine.throttle = 0.3f;
	car->gearbox.setGear(GEAR_NEUTRAL);

	String label;
	int rpm;
	float whellRpm;


	for (rpm = 0; rpm < 7000; rpm+=100) {
		label = IfThen(rpm%1000 == 0, IntToStr(rpm), "");


		car->engine.setRpm (rpm);
		car->wheels.wheels[0].rpm = (car->gearbox.transRpm() != 0) ? rpm / car->gearbox.transRpm() : 0;
		car->wheels.wheels[1].rpm = (car->gearbox.transRpm() != 0) ? rpm / car->gearbox.transRpm() : 0;
		car->engine.throttle = 1.0f;

		Torque->Add(car->engine.curve_torque(), label);
		brakingTorque->Add(car->engine.braking_torque(), label);

		car->engine.throttle = 0.3f;
		Torque03->Add(car->engine.curve_torque()*car->engine.throttle, label);

		car->engine.throttle = 0.5f;
		Torque05->Add(car->engine.curve_torque()*car->engine.throttle, label);

		car->engine.throttle = 0.7f;

		Torque07->Add(car->engine.curve_torque()*car->engine.throttle, label);
	}

//	torque->RefreshSeries();
//	free (engine);
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::btnDraw2Click(TObject *Sender)
{
	String label;

	int rpm;
	int whellRpm;
	const int maxRpm = 7000;

	car->gearbox.setGear(GEAR_FIRST);
	car->engine.clutch = 1.0f;
	car->engine.throttle = 1.0f;
	car->engine.isRun = true;

	for (rpm = 0; rpm < 7000; rpm+=100) {
		label = IfThen(rpm%1000 == 0, IntToStr(maxRpm-2*rpm), "");

		car->engine.setRpm (rpm);
		car->wheels.wheels[0].rpm = (maxRpm-rpm) / car->gearbox.transRpm();
		car->wheels.wheels[1].rpm = (maxRpm-rpm) / car->gearbox.transRpm();

		float baseTorque = car->baseTorque();
		float Motor = car->toMotorTorque(baseTorque);
		float Wheels = car->toWheelsTorque(baseTorque);

		//Motor = Motor > 0 ? pow (Motor, 2) : - pow(Motor, 2);
		//Wheels = Wheels > 0 ? pow(Wheels, 2) : pow(Wheels, 2);

		Torque->Add(car->engine.curve_torque(), label);
		toMotor->Add(Motor, label);
		toWheels->Add(Wheels, label);
	}
}
//---------------------------------------------------------------------------

void __fastcall TfrmMain::NextInspector1Change(TObject *Sender, TNxPropertyItem *Item,
          WideString Value)
{
	if (NxProgressItem1->Position < 15) {
		NxProgressItem1->ProgressColor = clYellow;
	}
	else if (NxProgressItem1->Position > 50) {
		NxProgressItem1->ProgressColor = clRed;
	}
	else
		NxProgressItem1->ProgressColor = clGreen;


	if (fabs(txtEngineTorque->AsFloat) < fabs(txtEngineClutchTorque->AsFloat))
		txtEngineTorque->Color = clRed;
	else
		txtEngineTorque->Color = clWindow;
}
//---------------------------------------------------------------------------


