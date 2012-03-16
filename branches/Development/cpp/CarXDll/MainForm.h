// ---------------------------------------------------------------------------

#ifndef MainFormH
#define MainFormH
// ---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "NxInspector.hpp"
#include "NxScrollControl.hpp"
#include "NxPropertyItemClasses.hpp"
#include "NxPropertyItems.hpp"
#include <Buttons.hpp>
#include <ExtCtrls.hpp>



#include "Chart.hpp"
#include "TeeProcs.hpp"
#include "Series.hpp"
#include "TeEngine.hpp"

#include "car.h"


// ---------------------------------------------------------------------------
class TfrmMain : public TForm {
__published: // IDE-managed Components

	TNextInspector *NextInspector1;
	TNxTextItem *NxTextItem1;
	TNxTextItem *txtRpm;
	TNxTextItem *NxTextItem2;
	TNxTrackBarItem *trbThrottle;
	TPanel *pnlBottom;
	TBitBtn *btnStart;
	TBitBtn *btnStrop;
	TChart *chartTorque;
	TBitBtn *BitBtn1;
	TNxProgressItem *NxProgressItem1;
	TNxTrackBarItem *trbClutch;
	TNxCheckBoxItem *cbxStarter;
	TNxSpinItem *spnGear;
	TLineSeries *Torque;
	TLineSeries *brakingTorque;
	TLineSeries *Torque03;
	TLineSeries *Torque05;
	TLineSeries *Torque07;
	TNxTextItem *NxTextItem3;
	TNxTextItem *txtFtraction;
	TNxTextItem *txtA;
	TNxTextItem *txtSpeed;
	TNxTextItem *txtFlong;
	TNxTextItem *txt;
	TNxTextItem *txtEngineClutchTorque;
	TNxTextItem *txtWheelsClutchTorque;
	TNxTextItem *txtFWheels;
	TNxTextItem *txtWheelRpm;
	TNxTextItem *txtBaseTorque;
	TButton *btnDraw2;
	TLineSeries *toMotor;
	TLineSeries *toWheels;
	TNxTextItem *txtEngineTorque;
	TNxTextItem *txtWhellsTorque;

	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
	void __fastcall btnStartClick(TObject *Sender);
	void __fastcall btnStropClick(TObject *Sender);
	void __fastcall BitBtn1Click(TObject *Sender);
	void __fastcall btnDraw2Click(TObject *Sender);
	void __fastcall NextInspector1Change(TObject *Sender, TNxPropertyItem *Item, WideString Value);



private: // User declarations

	bool _lookup;

	TCar* car;

public: // User declarations

	__fastcall TfrmMain(TComponent* Owner);

	void Main();
};

// ---------------------------------------------------------------------------
extern PACKAGE TfrmMain *frmMain;
// ---------------------------------------------------------------------------
#endif
