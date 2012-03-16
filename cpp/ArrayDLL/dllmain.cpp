#include <assert.h>
#include <malloc.h>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
	return TRUE;
}

char * unicode_to_utf8(const wchar_t *unicode_string)
{
	int err;
	char * res;
	int res_len = WideCharToMultiByte(CP_UTF8, 0, unicode_string, -1, NULL, 0, NULL, NULL);
	if (res_len == 0) 
		return NULL;
	res = (char*)calloc(sizeof(char), res_len);
	if (res == NULL) 
		return NULL;
	err = WideCharToMultiByte(CP_UTF8, 0, unicode_string, -1, res, res_len, NULL, NULL);
	if (err == 0)
	{
		free(res);
		return NULL;
	}
	return res;
}

extern "C"
{
	typedef void* (*ReallocFunctionPtrType)(void* Original, DWORD Count, DWORD Alignment);
	ReallocFunctionPtrType ReallocFunctionPtr = NULL;

	struct FDLLBindInitData 
	{
		INT Version;
		ReallocFunctionPtrType ReallocFunctionPtr;
	};

	__declspec(dllexport) void DLLBindInit (FDLLBindInitData* InitData) 
	{
		ReallocFunctionPtr = InitData->ReallocFunctionPtr;
	}

	/**
	 * ��������� ��� ������ �� �������� �� UDK
	 */
	struct FString 
	{
		wchar_t* Data;
		// ��������� �� ������, ����������� �++ ��� ������������� ����� ��������� �� ������
		int ArrayNum;
		// ����� ������ � Data, ����������� ������ � UpdateArrayNum*/
		int ArrayMax;
		/* ����������������� � UDK, ������� ������ ��������� �� ����� */

		/** ������� ��� ���� ����� �������� �������� ArrayNum - ������ ����� ������ � Data, ����� ��� ��������� ������ ������������� ����� UDK */
		void UpdateArrayNum()
		{
			ArrayNum = wcslen(Data) + 1;
			assert(ArrayNum <= ArrayMax);
		}

		/// <summary>
		/// ������� �������� ������ � ������� utf8, ������������ ��� ������ � ���� xml
		/// </summary>
		/// <returns>������ char* � ������� utf8</returns>
		const char* toUtf8()
		{
			if (wcslen(Data))
				return unicode_to_utf8(Data);
			else
				return "";
		}
		/// <summary>
		/// ��������� ������ ��� ��������� ������ �� UDK.
		/// </summary>
		/// <param name="NewNum">����� ������ ������, ������� ���������� ������</param>
		/// <param name="bCompact">���������� �����. �� ��������� FALSE. ��� ����� �� DLL ����� TRUE, ����� �������� ������������� ������.</param>
		void Reallocate(int NewNum, bool bCompact = false)
		{
			ArrayNum = NewNum;
			if ((ArrayNum > ArrayMax) || bCompact) 
			{
				ArrayMax = ArrayNum + 8;
				Data = (wchar_t*)(*ReallocFunctionPtr)(Data, ArrayMax*sizeof(wchar_t), 8);
			}
		}
	};

	struct UserDefProfile
	{
		FString Name;
		FString Path;
	};

	__declspec(dllexport) void GetProfileName(UserDefProfile* profile)
	{
		int nCountChar;
		wchar_t Username[256];

		nCountChar = GetEnvironmentVariable(L"USERNAME", Username, 256); 
		profile->Name.Reallocate(nCountChar+1);
		wcscpy_s(profile->Name.Data, nCountChar + 1, Username);
	}	
}
