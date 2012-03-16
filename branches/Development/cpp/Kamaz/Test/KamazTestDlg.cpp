
// KamazTestDlg.cpp : implementation file
//

#include "stdafx.h"
#include "KamazTest.h"
#include "KamazTestDlg.h"
#include "afxdialogex.h"
#include "KamazSignal.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAboutDlg dialog used for App About

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()


// CKamazTestDlg dialog




CKamazTestDlg::CKamazTestDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CKamazTestDlg::IDD, pParent)
	, first(0)
	, fourth(0)
	, bit1_2(FALSE)
	, bit1_3(FALSE)
	, bit2_0(FALSE)
	, bit2_1(FALSE)
	, bit2_2(FALSE)
	, bit2_3(FALSE)
	, bit2_4(FALSE)
	, bit2_5(FALSE)
	, bit2_6(FALSE)
	, bit2_7(FALSE)
	, first2_1(FALSE)
	, first2_2(FALSE)
	, first2_3(FALSE)
	, second1_1(FALSE)
	, second1_2(FALSE)
	, second1_3(FALSE)
	, second1_4(FALSE)
	, second1_5(FALSE)
	, second1_6(FALSE)
	, second1_7(FALSE)
	, second1_8(FALSE)
	, second2_1(FALSE)
	, second2_2(FALSE)
	, second2_3(FALSE)
	, second2_4(FALSE)
	, second2_5(FALSE)
	, second3_3(FALSE)
	, second3_4(FALSE)
	, second3_5(FALSE)
	, second3_6(FALSE)
	, second3_7(FALSE)
	, second4_4(FALSE)
	, second4_5(FALSE)
	, second4_6(FALSE)
	, second4_7(FALSE)
	, second4_8(FALSE)
	, bit3_4(FALSE)
	, bit3_5(FALSE)
	, bit3_6(FALSE)
	, bit3_7(FALSE)
	, ed_1(0)
	, ed_2(0)
	, ed_3(0)
	, ed_4(0)
	, ed_5(0)
	, ed_6(0)
	, ed_7(0)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	second = 0;
	third = 0;
}

void CKamazTestDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Text(pDX, IDC_EDIT1, first);
	DDX_Text(pDX, IDC_EDIT2, second);
	DDX_Text(pDX, IDC_EDIT3, third);
	DDX_Text(pDX, IDC_EDIT4, fourth);
	DDX_Control(pDX, IDC_SLIDER1, arrow_1);
	DDX_Control(pDX, IDC_SLIDER3, arrow_2);
	DDX_Control(pDX, IDC_SLIDER2, arrow_3);
	DDX_Control(pDX, IDC_SLIDER4, arrow_4);
	DDX_Control(pDX, IDC_SLIDER5, arrow_5);
	DDX_Control(pDX, IDC_SLIDER6, arrow_6);
	DDX_Control(pDX, IDC_SLIDER7, arrow_7);
	DDX_Check(pDX, IDC_CHECK67, bit1_2);
	DDX_Check(pDX, IDC_CHECK68, bit1_3);
	DDX_Check(pDX, IDC_CHECK73, bit2_0);
	DDX_Check(pDX, IDC_CHECK74, bit2_1);
	DDX_Check(pDX, IDC_CHECK75, bit2_2);
	DDX_Check(pDX, IDC_CHECK76, bit2_3);
	DDX_Check(pDX, IDC_CHECK77, bit2_4);
	DDX_Check(pDX, IDC_CHECK78, bit2_5);
	DDX_Check(pDX, IDC_CHECK79, bit2_6);
	DDX_Check(pDX, IDC_CHECK80, bit2_7);
	DDX_Check(pDX, IDC_CHECK9, first2_1);
	DDX_Check(pDX, IDC_CHECK10, first2_2);
	DDX_Check(pDX, IDC_CHECK11, first2_3);
	DDX_Check(pDX, IDC_CHECK33, second1_1);
	DDX_Check(pDX, IDC_CHECK34, second1_2);
	DDX_Check(pDX, IDC_CHECK35, second1_3);
	DDX_Check(pDX, IDC_CHECK36, second1_4);
	DDX_Check(pDX, IDC_CHECK37, second1_5);
	DDX_Check(pDX, IDC_CHECK38, second1_6);
	DDX_Check(pDX, IDC_CHECK39, second1_7);
	DDX_Check(pDX, IDC_CHECK40, second1_8);
	DDX_Check(pDX, IDC_CHECK41, second2_1);
	DDX_Check(pDX, IDC_CHECK42, second2_2);
	DDX_Check(pDX, IDC_CHECK43, second2_3);
	DDX_Check(pDX, IDC_CHECK44, second2_4);
	DDX_Check(pDX, IDC_CHECK45, second2_5);
	DDX_Check(pDX, IDC_CHECK51, second3_3);
	DDX_Check(pDX, IDC_CHECK52, second3_4);
	DDX_Check(pDX, IDC_CHECK53, second3_5);
	DDX_Check(pDX, IDC_CHECK54, second3_6);
	DDX_Check(pDX, IDC_CHECK55, second3_7);
	DDX_Check(pDX, IDC_CHECK60, second4_4);
	DDX_Check(pDX, IDC_CHECK61, second4_5);
	DDX_Check(pDX, IDC_CHECK62, second4_6);
	DDX_Check(pDX, IDC_CHECK63, second4_7);
	DDX_Check(pDX, IDC_CHECK64, second4_8);
	DDX_Check(pDX, IDC_CHECK85, bit3_4);
	DDX_Check(pDX, IDC_CHECK86, bit3_5);
	DDX_Check(pDX, IDC_CHECK87, bit3_6);
	DDX_Check(pDX, IDC_CHECK88, bit3_7);
	DDX_Text(pDX, IDC_EDIT5, ed_1);
	DDX_Text(pDX, IDC_EDIT6, ed_2);
	DDX_Text(pDX, IDC_EDIT7, ed_3);
	DDX_Text(pDX, IDC_EDIT8, ed_4);
	DDX_Text(pDX, IDC_EDIT9, ed_5);
	DDX_Text(pDX, IDC_EDIT10, ed_6);
	DDX_Text(pDX, IDC_EDIT11, ed_7);
}

BEGIN_MESSAGE_MAP(CKamazTestDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_TIMER()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_CHECK67, &CKamazTestDlg::OnBnClickedCheck67)
	ON_BN_CLICKED(IDC_CHECK68, &CKamazTestDlg::OnBnClickedCheck68)
	ON_BN_CLICKED(IDC_CHECK73, &CKamazTestDlg::OnBnClickedCheck73)
	ON_BN_CLICKED(IDC_CHECK74, &CKamazTestDlg::OnBnClickedCheck74)
	ON_BN_CLICKED(IDC_CHECK75, &CKamazTestDlg::OnBnClickedCheck75)
	ON_BN_CLICKED(IDC_CHECK76, &CKamazTestDlg::OnBnClickedCheck76)
	ON_BN_CLICKED(IDC_CHECK77, &CKamazTestDlg::OnBnClickedCheck77)
	ON_BN_CLICKED(IDC_CHECK78, &CKamazTestDlg::OnBnClickedCheck78)
	ON_BN_CLICKED(IDC_CHECK79, &CKamazTestDlg::OnBnClickedCheck79)
	ON_BN_CLICKED(IDC_CHECK80, &CKamazTestDlg::OnBnClickedCheck80)
	ON_BN_CLICKED(IDC_CHECK85, &CKamazTestDlg::OnBnClickedCheck85)
	ON_BN_CLICKED(IDC_CHECK86, &CKamazTestDlg::OnBnClickedCheck86)
	ON_BN_CLICKED(IDC_CHECK87, &CKamazTestDlg::OnBnClickedCheck87)
	ON_BN_CLICKED(IDC_CHECK88, &CKamazTestDlg::OnBnClickedCheck88)
END_MESSAGE_MAP()


// CKamazTestDlg message handlers

BOOL CKamazTestDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// TODO: Add extra initialization here

	SetTimer(1, 50, NULL);

	arrow_1.SetRange(0, 255, FALSE);
	arrow_2.SetRange(0, 255, FALSE);
	arrow_3.SetRange(0, 255, FALSE);
	arrow_4.SetRange(0, 255, FALSE);
	arrow_5.SetRange(0, 255, FALSE);
	arrow_6.SetRange(0, 255, FALSE);
	arrow_7.SetRange(0, 255, FALSE);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CKamazTestDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialogEx::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CKamazTestDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CKamazTestDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

void CKamazTestDlg::OnTimer(UINT_PTR nIDEvent)
{
	UpdateData(TRUE);

	in_signals* is = InSignals();

	Speedometr(arrow_1.GetPos());
	OilPressure(arrow_2.GetPos());
	Fuel(arrow_3.GetPos());
	EngineTemperature(arrow_4.GetPos());
	AccumulatorCharge(arrow_5.GetPos());
	PneumaticsPressure(arrow_6.GetPos());
	Tachometer(arrow_7.GetPos());

	ElectrotorchDeviceLamp(bit1_2);
	TurnLamp(bit1_3);

	Circuit_1(bit2_0);
	Circuit_2(bit2_1);
	Circuit_3(bit2_2);
	Circuit_4(bit2_3);
	StopBrakeLamp(bit2_4);
	InteraxleDifferential(bit2_5);
	InterwheelDifferential_1(bit2_6);
	InterwheelDifferential_2(bit2_7);

	AccumulatorLamp(bit3_4);
	OilPressureLamp(bit3_5);
	WaterTempLamp(bit3_6);
	FuelLamp(bit3_7);


	first = is->wheel;
	second = is->gas_pedal;
	third = is->coupling_pedal;
	fourth = is->brake_pedal;

	first2_1 = is->ignition;
	first2_2 = is->brake;
	first2_3 = is->fifth_step;

	second1_1 = is->headlight;
	second1_2 = is->change_camera;
	second1_3 = is->screen_wiper;
	second1_4 = is->right_turn;
	second1_5 = is->left_turn;
	second1_6 = is->weight_switching_off;
	second1_7 = is->alarm_signal;
	second1_8 = is->dimensional_fires;

	second2_1 = is->first_step;
	second2_2 = is->back_step;
	second2_3 = is->second_step;
	second2_4 = is->third_step;
	second2_5 = is->fourth_step;

	second3_3 = is->passing_light;
	second3_4 = is->interwheel_differential_2;
	second3_5 = is->interwheel_differential_1;
	second3_6 = is->interaxle_differential;
	second3_7 = is->transfers_divider;

	second4_4 = is->electrotorch_device;
	second4_5 = is->look_at_left;
	second4_6 = is->look_at_right;
	second4_7 = is->belt_on;
	second4_8 = is->starter;
	
	ed_1 = arrow_1.GetPos();
	ed_2 = arrow_2.GetPos();
	ed_3 = arrow_3.GetPos();
	ed_4 = arrow_4.GetPos();
	ed_5 = arrow_5.GetPos();
	ed_6 = arrow_6.GetPos();
	ed_7 = arrow_7.GetPos();

	UpdateData(FALSE);
}

void CKamazTestDlg::OnBnClickedCheck67()
{
	// TODO: Add your control notification handler code here
	bit1_2 = !bit1_2;
}


void CKamazTestDlg::OnBnClickedCheck68()
{
	// TODO: Add your control notification handler code here
	bit1_3 = !bit1_3;
}


void CKamazTestDlg::OnBnClickedCheck73()
{
	// TODO: Add your control notification handler code here
	bit2_0 = !bit2_0;
}


void CKamazTestDlg::OnBnClickedCheck74()
{
	// TODO: Add your control notification handler code here
	bit2_1 = !bit2_1;
}


void CKamazTestDlg::OnBnClickedCheck75()
{
	// TODO: Add your control notification handler code here
	bit2_2 = !bit2_2;
}


void CKamazTestDlg::OnBnClickedCheck76()
{
	// TODO: Add your control notification handler code here
	bit2_3 = !bit2_3;
}


void CKamazTestDlg::OnBnClickedCheck77()
{
	// TODO: Add your control notification handler code here
	bit2_4 = !bit2_4;
}


void CKamazTestDlg::OnBnClickedCheck78()
{
	// TODO: Add your control notification handler code here
	bit2_5 = !bit2_5;
}


void CKamazTestDlg::OnBnClickedCheck79()
{
	// TODO: Add your control notification handler code here
	bit2_6 = !bit2_6;
}


void CKamazTestDlg::OnBnClickedCheck80()
{
	// TODO: Add your control notification handler code here
	bit2_7 = !bit2_7;
}


void CKamazTestDlg::OnBnClickedCheck85()
{
	// TODO: Add your control notification handler code here
	bit3_4 = !bit3_4;
}


void CKamazTestDlg::OnBnClickedCheck86()
{
	// TODO: Add your control notification handler code here
	bit3_5 = !bit3_5;
}


void CKamazTestDlg::OnBnClickedCheck87()
{
	// TODO: Add your control notification handler code here
	bit3_6 = !bit3_6;
}


void CKamazTestDlg::OnBnClickedCheck88()
{
	// TODO: Add your control notification handler code here
	bit3_7 = !bit3_7;
}
