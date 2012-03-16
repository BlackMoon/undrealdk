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
	 * Структура для работы со строками из UDK
	 */
	struct FString {
		wchar_t* Data;
		// Указатель на строки, особенность С++ при инициализации может оказаться не пустой
		int ArrayNum;
		// Длина строки в Data, оновляеться размер в UpdateArrayNum*/
		int ArrayMax;
		/* Иницаилизируеться в UDK, трогать внутри программы не стоит */

		/** Функция для того чтобы обновить значение ArrayNum - размер длины строки в Data, нужно для коректной работы возвращаеммых строк UDK */
		void UpdateArrayNum();
		//FString();

		/// <summary>
		/// Вернуть значение строки в формате utf8, применяеться для записи в файл xml
		/// </summary>
		/// <returns>строка char* в формате utf8</returns>
		const char* toUtf8(void);
		/// <summary>
		/// Выделение памяти для указателя строки из UDK.
		/// </summary>
		/// <param name="NewNum">Новый размер строки, который необходимо задать</param>
		/// <param name="bCompact">Компактный режим. По умолчанию FALSE. Для строк из DLL лучше TRUE, чтобы вызывать перевыделение памяти.</param>
		void Reallocate(int NewNum, bool bCompact = false);
	};
// ---------------------------------------------------------------------------
#endif
