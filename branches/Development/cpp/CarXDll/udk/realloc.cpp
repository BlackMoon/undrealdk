#pragma hdrstop

#include "realloc.h"
#include "encode.h"
#include <string>
#include <assert.h>

ReallocFunctionPtrType ReallocFunctionPtr = NULL;

extern "C" __declspec(dllexport) void DLLBindInit (FDLLBindInitData* InitData) 
{
	ReallocFunctionPtr = InitData->ReallocFunctionPtr;
}

void* ReallocFunction(void* Original, DWORD Count, DWORD Alignment) 
{
	return (*ReallocFunctionPtr)(Original, Count, Alignment);
}


template<typename DataType> int TUdkArray<typename DataType>::Num() 
{
	return ArrayNum;
}

template<typename DataType> void TUdkArray<typename DataType>::Reallocate(int NewNum, bool bCompact) 
{
	if (!Data)
		Data = NULL;
	ArrayNum = NewNum;
	if (ArrayNum > ArrayMax || bCompact) 
	{
		ArrayMax = ArrayNum;
		Data = (DataType*)(*ReallocFunctionPtr)(Data, ArrayMax*sizeof(DataType), 8);
	}
}

template<typename DataType> TUdkArray<typename DataType>::TUdkArray() 
{
	ArrayNum = 0;
	ArrayNum = 0;
	Data = NULL;
}

void FString::UpdateArrayNum() 
{
	ArrayNum = wcslen(Data) + 1;
	assert(ArrayNum <= ArrayMax);
}

/* FString& FString::operator = (TIXML_STRING tixmlString) {
if (tixmlString.length() > 0)
{
Data = NULL;
wchar_t* wBuff = utf8_to_unicode (tixmlString.c_str());
Reallocate(wcslen(wBuff), true);
wcscpy (Data, wBuff);
UpdateArrayNum();
}
else
{
Data = NULL;
ArrayMax = 0;
ArrayNum = 0;
}
return *this;
} */

/// <summary>
/// ������� �������� ������ � ������� utf8, ������������ ��� ������ � ���� xml
/// </summary>
/// <returns>������ char* � ������� utf8</returns>
const char* FString::toUtf8(void) 
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
void FString::Reallocate(int NewNum, bool bCompact) 
{
	ArrayNum = NewNum;
	if (ArrayNum > ArrayMax || bCompact) 
	{
		ArrayMax = ArrayNum + 8;
		Data = (wchar_t*)(*ReallocFunctionPtr)(Data, ArrayMax*sizeof(wchar_t), 8);
	}
}
