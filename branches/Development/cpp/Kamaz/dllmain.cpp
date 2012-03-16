#include <SDKDDKVer.h>

#define WIN32_LEAN_AND_MEAN             
#include <windows.h>
#include "KamazSignal.h"
#include <process.h>
#include "Calibration.h"

bool bThreadWorking = false;		//	флаг того, что запущен поток
bool bThreadEnded = false;			//	флаг того, что работа потока дошла до конца

// Регистрация стрелочных приборов
void RegisterDevices()
{
	RegisterDeviceFunction(0, L"Speedometr", Speedometr);
	RegisterDeviceFunction(1, L"Tachometer", Tachometer);
	RegisterDeviceFunction(2, L"OilPressure", OilPressure);
	RegisterDeviceFunction(3, L"EngineTemperature", EngineTemperature);
	RegisterDeviceFunction(4, L"AccumulatorCharge", AccumulatorCharge);
	RegisterDeviceFunction(5, L"Fuel", Fuel);
	RegisterDeviceFunction(6, L"PneumaticsPressure", PneumaticsPressure);
}

void _cdecl ThreadFunction(void * p = NULL)
{
	while (bThreadWorking)
	{
		EnterCriticalSection(&objCriticalSection);
		UpdateAll();
		LeaveCriticalSection(&objCriticalSection);
		Sleep(20);
	}
	bThreadEnded = true;
	_endthread();
}

BOOL APIENTRY DllMain( HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved )
{
	DWORD dwMscs;
	switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH: 
			RegisterDevices();
			COMPortOpen();
			InitializeCriticalSection(&objCriticalSection);
			bThreadWorking = true;
			_beginthread(ThreadFunction, 0, NULL);
			break;
		case DLL_PROCESS_DETACH:
			bThreadWorking = false;
			dwMscs = 0;
			while (!bThreadEnded && (dwMscs < 2000))
			{
				dwMscs += 20;
				Sleep(20);
			}
			DeleteCriticalSection(&objCriticalSection);
			COMPortClose();

			// очистка Calibration
			ClearRegistrations();
			break;
	}
	return TRUE;
}