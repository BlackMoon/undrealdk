#include <WinSDKVer.h>
#define _WIN32_WINNT _WIN32_WINNT_WIN2K
#include <SDKDDKVer.h>
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <process.h>
#include <map>
#include <string>
#include <vector>
#include <fstream>

std::map<std::wstring, std::vector<std::pair<int, int> >* > mapFileData;	//	������������ ������ ��� �������� �������
std::vector<uintptr_t> vecWritingThreads;								//	������ ��� ������ � �����
std::map<std::wstring, std::wofstream*> mapFileStreams;					//	�������� ������
CRITICAL_SECTION objWritingCS = {0};									//	����������� ������ ��� ������ � ����
std::wstring strThreadFileName;

//	��������� ��������� ������
std::wofstream* get_ofstream_for_filename(const wchar_t * pchFileName)
{
	std::wofstream* pOfs = NULL;
	std::map<std::wstring, std::wofstream*>::const_iterator iterOfs = mapFileStreams.find(pchFileName);
	if (iterOfs == mapFileStreams.end())
	{
		pOfs = new std::wofstream(pchFileName);
		mapFileStreams[pchFileName] = pOfs;
	}
	else
		pOfs = iterOfs->second;
	return pOfs;
}

//	��������� ������� ������
std::vector<std::pair<int, int> >* get_vector_for_filename(const wchar_t * pchFileName)
{
	std::vector<std::pair<int, int> > * pData = NULL;
	std::map<std::wstring, std::vector<std::pair<int, int> >* >::const_iterator iterDataMap = mapFileData.find(pchFileName);
	if (iterDataMap == mapFileData.end())
	{
		pData = new std::vector<std::pair<int, int> >;
		mapFileData[pchFileName] = pData;
	}
	else
		pData = iterDataMap->second;
	return pData;
}

//	��������� ������� ��� ������ � ����
void _cdecl ThreadFunction(void * p = NULL)
{
	EnterCriticalSection(&objWritingCS);
	std::wstring strFileName(strThreadFileName);
	std::wofstream * pOfs = get_ofstream_for_filename(strFileName.c_str());
	if (pOfs != NULL)
	{
		std::vector<std::pair<int, int> >* pData = get_vector_for_filename(strFileName.c_str());
		if (pData != NULL)
		{
			for (std::vector<std::pair<int, int> >::const_iterator iterData = pData->begin(); iterData != pData->end(); ++iterData)
				*pOfs << iterData->first << ' ' << iterData->second << '\n';
		}
	}
	LeaveCriticalSection(&objWritingCS);
	_endthread();
}

//	������� ���������� ���������� ��� ������, ��� �����, �������� ������ �� ������ ������ ��� ���������� ������
extern "C" __declspec(dllexport) void FlushData(wchar_t * pchFileName)
{
	EnterCriticalSection(&objWritingCS);
	strThreadFileName = pchFileName;
	uintptr_t hThread = _beginthread(ThreadFunction, 0, NULL);
	vecWritingThreads.push_back(hThread);
	LeaveCriticalSection(&objWritingCS);
}

//	���������� ������ ��� ����������� ������ � ����
extern "C" __declspec(dllexport) void WriteData(wchar_t * pchFileName, int iRoll, int iPitch)
{
	EnterCriticalSection(&objWritingCS);
	std::vector<std::pair<int, int> > * pData = get_vector_for_filename(pchFileName);
	if (pData != NULL)
		pData->push_back(std::make_pair(iRoll, iPitch));
	LeaveCriticalSection(&objWritingCS);
}

BOOL APIENTRY DllMain(HMODULE, DWORD ul_reason_for_call, LPVOID)
{
	switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
			InitializeCriticalSection(&objWritingCS);
			break;
		case DLL_PROCESS_DETACH:
			//	��������� ������� �� ������ � �����, �������, ��������, ��� �� ���������
			for (std::vector<uintptr_t>::const_iterator iterT = vecWritingThreads.begin(); iterT != vecWritingThreads.end(); ++iterT)
				WaitForSingleObject((HANDLE)(*iterT), 2000);
			//	--
			DeleteCriticalSection(&objWritingCS);
			//	�����������, ������� ������
			for (std::map<std::wstring, std::wofstream*>::const_iterator iterOfs = mapFileStreams.begin(); iterOfs != mapFileStreams.end(); ++iterOfs)
			{
				if (iterOfs->second != NULL)
					delete iterOfs->second;
			}
			for (std::map<std::wstring, std::vector<std::pair<int, int> >* >::const_iterator iterData = mapFileData.begin(); iterData != mapFileData.end(); ++iterData)
			{
				if (iterData->second != NULL)
					delete iterData->second;
			}
			break;
	}

	return TRUE;
}