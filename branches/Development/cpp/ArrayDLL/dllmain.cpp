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
	 * Структура для работы со строками из UDK
	 */
	struct FString 
	{
		wchar_t* Data;
		// Указатель на строки, особенность С++ при инициализации может оказаться не пустой
		int ArrayNum;
		// Длина строки в Data, оновляеться размер в UpdateArrayNum*/
		int ArrayMax;
		/* Иницаилизируеться в UDK, трогать внутри программы не стоит */

		/** Функция для того чтобы обновить значение ArrayNum - размер длины строки в Data, нужно для коректной работы возвращаеммых строк UDK */
		void UpdateArrayNum()
		{
			ArrayNum = wcslen(Data) + 1;
			assert(ArrayNum <= ArrayMax);
		}

		/// <summary>
		/// Вернуть значение строки в формате utf8, применяеться для записи в файл xml
		/// </summary>
		/// <returns>строка char* в формате utf8</returns>
		const char* toUtf8()
		{
			if (wcslen(Data))
				return unicode_to_utf8(Data);
			else
				return "";
		}
		/// <summary>
		/// Выделение памяти для указателя строки из UDK.
		/// </summary>
		/// <param name="NewNum">Новый размер строки, который необходимо задать</param>
		/// <param name="bCompact">Компактный режим. По умолчанию FALSE. Для строк из DLL лучше TRUE, чтобы вызывать перевыделение памяти.</param>
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
