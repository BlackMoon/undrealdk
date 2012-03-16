#ifndef reallocH
#define reallocH

// ---------------------------------------------------------------------------
#include <windows.h>
// =============================================================================
	extern "C" {
		typedef void* (*ReallocFunctionPtrType)(void* Original, DWORD Count,
			DWORD Alignment);

		struct FDLLBindInitData {
			INT Version;
			ReallocFunctionPtrType ReallocFunctionPtr;
		};
	}

	void* ReallocFunction(void* Original, DWORD Count, DWORD Alignment);
	// =============================================================================

	template<typename DataType>
	struct TUdkArray {
		DataType* Data;

		int Num();
		TUdkArray();
		void Reallocate(int NewNum, bool bCompact = false);

		int ArrayNum;
		int ArrayMax;
	};

	/**
	 * ��������� ��� ������ �� �������� �� UDK
	 */
	struct FString {
		wchar_t* Data;
		// ��������� �� ������, ����������� �++ ��� ������������� ����� ��������� �� ������
		int ArrayNum;
		// ����� ������ � Data, ����������� ������ � UpdateArrayNum*/
		int ArrayMax;
		/* ����������������� � UDK, ������� ������ ��������� �� ����� */

		/** ������� ��� ���� ����� �������� �������� ArrayNum - ������ ����� ������ � Data, ����� ��� ��������� ������ ������������� ����� UDK */
		void UpdateArrayNum();
		//FString();

		/// <summary>
		/// ������� �������� ������ � ������� utf8, ������������ ��� ������ � ���� xml
		/// </summary>
		/// <returns>������ char* � ������� utf8</returns>
		const char* toUtf8(void);
		/// <summary>
		/// ��������� ������ ��� ��������� ������ �� UDK.
		/// </summary>
		/// <param name="NewNum">����� ������ ������, ������� ���������� ������</param>
		/// <param name="bCompact">���������� �����. �� ��������� FALSE. ��� ����� �� DLL ����� TRUE, ����� �������� ������������� ������.</param>
		void Reallocate(int NewNum, bool bCompact = false);
	};
// ---------------------------------------------------------------------------
#endif
