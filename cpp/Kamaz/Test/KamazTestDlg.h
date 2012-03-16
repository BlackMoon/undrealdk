
// KamazTestDlg.h : header file
//

#pragma once
#include "afxcmn.h"


// CKamazTestDlg dialog
class CKamazTestDlg : public CDialogEx
{
// Construction
public:
	CKamazTestDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_KAMAZTEST_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	int first;
	int second;
	int third;
	int fourth;
	CSliderCtrl arrow_1;
	CSliderCtrl arrow_2;
	CSliderCtrl arrow_3;
	CSliderCtrl arrow_4;
	CSliderCtrl arrow_5;
	CSliderCtrl arrow_6;
	CSliderCtrl arrow_7;
	BOOL bit1_2;
	BOOL bit1_3;
	BOOL bit2_0;
	BOOL bit2_1;
	BOOL bit2_2;
	BOOL bit2_3;
	BOOL bit2_4;
	BOOL bit2_5;
	BOOL bit2_6;
	BOOL bit2_7;
	BOOL first2_1;
	BOOL first2_2;
	BOOL first2_3;
	BOOL second1_1;
	BOOL second1_2;
	BOOL second1_3;
	BOOL second1_4;
	BOOL second1_5;
	BOOL second1_6;
	BOOL second1_7;
	BOOL second1_8;
	BOOL second2_1;
	BOOL second2_2;
	BOOL second2_3;
	BOOL second2_4;
	BOOL second2_5;
	BOOL second3_3;
	BOOL second3_4;
	BOOL second3_5;
	BOOL second3_6;
	BOOL second3_7;
	BOOL second4_4;
	BOOL second4_5;
	BOOL second4_6;
	BOOL second4_7;
	BOOL second4_8;
	afx_msg void OnBnClickedCheck67();
	afx_msg void OnBnClickedCheck68();
	afx_msg void OnBnClickedCheck73();
	afx_msg void OnBnClickedCheck74();
	afx_msg void OnBnClickedCheck75();
	afx_msg void OnBnClickedCheck76();
	afx_msg void OnBnClickedCheck77();
	afx_msg void OnBnClickedCheck78();
	afx_msg void OnBnClickedCheck79();
	afx_msg void OnBnClickedCheck80();
	BOOL bit3_4;
	BOOL bit3_5;
	BOOL bit3_6;
	BOOL bit3_7;
	afx_msg void OnBnClickedCheck85();
	afx_msg void OnBnClickedCheck86();
	afx_msg void OnBnClickedCheck87();
	afx_msg void OnBnClickedCheck88();
	int ed_1;
	int ed_2;
	int ed_3;
	int ed_4;
	int ed_5;
	int ed_6;
	int ed_7;
};
