#include <WinSDKVer.h>
#define _WIN32_WINNT _WIN32_WINNT_WIN2K
#include <SDKDDKVer.h>
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <process.h>
#include <stdio.h>
#include "DPAsync.h"

//-----------------------------------------------------------------------------------------------------------
//	���������																								|
//-----------------------------------------------------------------------------------------------------------
const DWORD dwSleepTime			= 50;			//	�����, �� ������� ������� ��� �������� ����� �������� � �����
const DWORD dwTimeoutTime		= 2000;			//	����� ��� ��������, ������� ����� ��� ��������� ������ �������� ������
const size_t szValueQueueSize	= 8;			//	������ ������ ������� ������

//-----------------------------------------------------------------------------------------------------------
//	������� ����������																						|
//-----------------------------------------------------------------------------------------------------------
CRITICAL_SECTION	objCriticalSection		= {0};		// ����������� ������ ������� � ������
bool				bThreadWorking			= false;	//	���� ����, ��� ������� ����� ������ ������� � �����
uintptr_t			hWorkingThread			= NULL;		//	handle �������� ������
char				pCharDbg[1024];

//-----------------------------------------------------------------------------------------------------------
//	���� � �������, ������� �������������� ���������� ����� ����� ����������� � ����� �����������			|
//-----------------------------------------------------------------------------------------------------------
DP_Exchange arrValues[szValueQueueSize];		//	����������� ������ ��������� �������
size_t szLastPackageIdx, szPrevPackageIdx;		//	������ ���������� ������ � ������� �������

//-----------------------------------------------------------------------------------------------------------
//	������� ������ ������� ����� ����� ����������� � ����� �����������, ������� ����� ��������� ��� DLL		|
//-----------------------------------------------------------------------------------------------------------
bool UpdateAll()
{
	szPrevPackageIdx = szLastPackageIdx;
	szLastPackageIdx = (szLastPackageIdx + 1) % szValueQueueSize;
	arrValues[szLastPackageIdx] = arrValues[szPrevPackageIdx];
	sprintf_s(pCharDbg, "Time == %d, Roll == %d, Pitch == %d\n", arrValues[szPrevPackageIdx].iTime, arrValues[szPrevPackageIdx].iRoll, arrValues[szPrevPackageIdx].iPitch);
	OutputDebugStringA(pCharDbg);
	return true;
}

//-----------------------------------------------------------------------------------------------------------
//	��������������� ��������� �������																		|
//-----------------------------------------------------------------------------------------------------------
void _cdecl ThreadFunction(void * p = NULL)
{
	bool res;
	while (bThreadWorking)
	{
		EnterCriticalSection(&objCriticalSection);
		res = UpdateAll();
		LeaveCriticalSection(&objCriticalSection);
		if (!res)
			break;
		Sleep(dwSleepTime);
	}
	_endthread();
}

//-----------------------------------------------------------------------------------------------------------
//	����� ������������� ��� ������������� ����� ���������� (�������� ������ � ������)						|
//-----------------------------------------------------------------------------------------------------------
bool Initialization()
{
	SecureZeroMemory(arrValues, sizeof(DP_Exchange)*szValueQueueSize);
	//..
	return true;
}

//-----------------------------------------------------------------------------------------------------------
//	����� ������������� ��� ����������� ����� ���������� (�������� ������ � ������)							|
//-----------------------------------------------------------------------------------------------------------
bool Finalization()
{
	//..
	return true;
}

//-----------------------------------------------------------------------------------------------------------
// ��������� ��������������																					|
//-----------------------------------------------------------------------------------------------------------

extern "C"
{
	//	��������� �������� ����������� ������ ��� ������ � ��� ������ (����� ����� ���������� �� ������ ����������)
	DPASYNC_A692645E_API void PushCurrentPack(DP_Exchange * p)
	{
		EnterCriticalSection(&objCriticalSection);
		arrValues[szLastPackageIdx] = *p;
		LeaveCriticalSection(&objCriticalSection);
	}

	// ��������� ������ �� ������� �������, ������� ��� �������� iHistoryDepth ����-������� �����
	// (� ������� �������� ���� ���������� ������, � ��� ������ �� ������������� ��� ��������� �� �����)
	// iHistoryDepth ����� ��������� �������� �� 0 �� (szValueQueueSize - 1)
	// ��� ������� ����� ����� ���������� ����� �����������
	DPASYNC_A692645E_API DP_Exchange* GetHistoryPack(int iHistoryDepth)
	{
		int iIdx = szValueQueueSize - iHistoryDepth;
		if (iIdx < 0)
			return NULL;
		else
		{
			iIdx = (iIdx + szLastPackageIdx) % szValueQueueSize;
			return (arrValues + iIdx);
		}
	}
}
//-----------------------------------------------------------------------------------------------------------
//	����� �����																								|
//-----------------------------------------------------------------------------------------------------------
BOOL APIENTRY DllMain(HMODULE, DWORD ul_reason_for_call, LPVOID)
{
	switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH: 
			Initialization();
			InitializeCriticalSection(&objCriticalSection);
			bThreadWorking = true;
			hWorkingThread = _beginthread(ThreadFunction, 0, NULL);
			break;
		case DLL_PROCESS_DETACH:
			bThreadWorking = false;
			WaitForSingleObject((HANDLE)hWorkingThread, dwTimeoutTime);
			DeleteCriticalSection(&objCriticalSection);
			Finalization();
			break;
	}
	return TRUE;
}
