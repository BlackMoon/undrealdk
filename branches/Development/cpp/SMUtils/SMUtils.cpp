// ForsageWnd.cpp
#include "SMUtils.h"
#include <process.h>
#include <Tlhelp32.h>

int X, Y, NX, NY;

BOOL CALLBACK HaveFoundMonitor(HMONITOR hMonitor, HDC hdcMonitor, LPRECT lprcMonitor, LPARAM dwData)
{
	(*(int*)dwData)++;
	return true;
}

BOOL CALLBACK HaveFoundWindow(HWND hwnd, LPARAM lParam)
{
	*((HWND*)lParam) = hwnd;	
	return false;
}
// поиск окна по процессу
HWND FindUDKWindow(DWORD pid)
{	
	THREADENTRY32 te = {0};
	te.dwSize = sizeof(THREADENTRY32);
	
	HANDLE hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
	if (hSnap == INVALID_HANDLE_VALUE) return 0;

	if (!Thread32First(hSnap, &te))
	{
		CloseHandle(hSnap);
		return 0;
	}
	
	do
	{
		if (te.th32OwnerProcessID == pid)
			break;		
	}
	while (Thread32Next(hSnap, &te));
	CloseHandle(hSnap);

	HWND hwnd = 0;
	EnumThreadWindows(te.th32ThreadID, HaveFoundWindow, (LPARAM)&hwnd);	
	return hwnd;
}

void ThreadWindowPos(void* pParam)
{	
	HWND hWndUDK = FindUDKWindow(GetCurrentProcessId());				
	MoveWindow(hWndUDK, X, Y, NX, NY, 1);
	_endthread();
}

extern "C" SMUTILS_API void WindowPos(int x, int y, int cx, int cy)
{		
	X = x;
	Y = y;	
	NX = cx;	
	NY = cy;

	_beginthread(ThreadWindowPos, 0, 0);
}

extern "C" SMUTILS_API int MonitorsNum()
{	
	int nMonitors = 0;
	EnumDisplayMonitors(0, 0, HaveFoundMonitor, (LPARAM)&nMonitors);	
	return nMonitors;
}
