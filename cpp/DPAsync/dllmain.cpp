#include <WinSDKVer.h>
#define _WIN32_WINNT _WIN32_WINNT_WIN2K
#include <SDKDDKVer.h>
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <process.h>
#include <stdio.h>
#include "DPAsync.h"

//-----------------------------------------------------------------------------------------------------------
//	константы																								|
//-----------------------------------------------------------------------------------------------------------
const DWORD dwSleepTime			= 50;			//	время, на которое рабочий или основной поток засыпает в цикле
const DWORD dwTimeoutTime		= 2000;			//	время для таймаута, который нужен для окончания работы рабочего потока
const size_t szValueQueueSize	= 8;			//	размер списка пакетов данных

//-----------------------------------------------------------------------------------------------------------
//	рабочие переменные																						|
//-----------------------------------------------------------------------------------------------------------
CRITICAL_SECTION	objCriticalSection		= {0};		// критическая секция доступа к данным
bool				bThreadWorking			= false;	//	флаг того, что запущен поток обмена данными в цикле
uintptr_t			hWorkingThread			= NULL;		//	handle рабочего потока
char				pCharDbg[1024];

//-----------------------------------------------------------------------------------------------------------
//	поля с данными, которые предполагается передавать между вашей библиотекой и нашим приложением			|
//-----------------------------------------------------------------------------------------------------------
DP_Exchange arrValues[szValueQueueSize];		//	зацикленный список последних пакетов
size_t szLastPackageIdx, szPrevPackageIdx;		//	индекс последнего пакета в очереди пакетов

//-----------------------------------------------------------------------------------------------------------
//	функция обмена данными между вашей библиотекой и нашим приложением, которое будет загружать эту DLL		|
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
//	вспомагательная потоковая функция																		|
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
//	здесь располагается код инициализации вашей библиотеки (открытие портов и прочее)						|
//-----------------------------------------------------------------------------------------------------------
bool Initialization()
{
	SecureZeroMemory(arrValues, sizeof(DP_Exchange)*szValueQueueSize);
	//..
	return true;
}

//-----------------------------------------------------------------------------------------------------------
//	здесь располагается код финализации вашей библиотеки (закрытие портов и прочее)							|
//-----------------------------------------------------------------------------------------------------------
bool Finalization()
{
	//..
	return true;
}

//-----------------------------------------------------------------------------------------------------------
// интерфейс взаимодействия																					|
//-----------------------------------------------------------------------------------------------------------

extern "C"
{
	//	получение текущего актуального пакета для работы с его полями (часто будет вызываться из нашего приложения)
	DPASYNC_A692645E_API void PushCurrentPack(DP_Exchange * p)
	{
		EnterCriticalSection(&objCriticalSection);
		arrValues[szLastPackageIdx] = *p;
		LeaveCriticalSection(&objCriticalSection);
	}

	// получение пакета из истории пакетов, который был актуален iHistoryDepth тайм-фреймов назад
	// (в истории хранятся лишь актуальные пакеты, и эти пакеты не предназначены для изменения их полей)
	// iHistoryDepth может принимать значения от 0 до (szValueQueueSize - 1)
	// эта фукнция будет часто вызываться вашей библиотекой
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
//	точка входа																								|
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
