// dllmain.cpp : Defines the entry point for the DLL application.
//#include "stdafx.h"
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include "DirectInput.h"




BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	DWORD dwMscs;

	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		break;

	case DLL_THREAD_ATTACH:
		break;
	case DLL_THREAD_DETACH:
		break;
	case DLL_PROCESS_DETACH:
		FreeResources();
		break;
	}
	return TRUE;
}