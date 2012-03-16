
//#include <windows.h>
#include <dinput.h>
#include <dinputd.h>

extern CRITICAL_SECTION cs;

#define SAFE_DELETE(p)  { if(p) { delete (p);     (p)=NULL; } }
#define SAFE_RELEASE(p) { if(p) { (p)->Release(); (p)=NULL; } }


BOOL CALLBACK    EnumObjectsCallback( const DIDEVICEOBJECTINSTANCE* pdidoi, VOID* pContext );
BOOL CALLBACK    EnumJoysticksCallback( const DIDEVICEINSTANCE* pdidInstance, VOID* pContext );

// Структура для передачи в коллбек
struct DI_ENUM_CONTEXT
{
	DIJOYCONFIG* pPreferredJoyCfg;
	bool bPreferredJoyCfgValid;
};


BOOL CALLBACK    EnumObjectsCallback( const DIDEVICEOBJECTINSTANCE* pdidoi, VOID* pContext );
BOOL CALLBACK EnumJoysticksCallback( const DIDEVICEINSTANCE* pdidInstance, VOID* pContext );
void ResetJoyState();
void FreeResources();


extern "C"
{
	__declspec(dllexport) bool InitializeDirectInput();
	__declspec(dllexport) bool UpdateJoyState();

	// Руль
	__declspec(dllexport) int GetSteering();

	// педаль газа
	__declspec(dllexport) int GetThrottle();

	// педаль сцепления
	__declspec(dllexport) int GetClutch();

	// педаль тормоза
	__declspec(dllexport) int GetBrake();

	// Возвращает массив состояний кнопок
	__declspec(dllexport) void GetButtonsArray(int *i);

	// Возвращает положение миниджойтика
	__declspec(dllexport) int GetPOV();
}