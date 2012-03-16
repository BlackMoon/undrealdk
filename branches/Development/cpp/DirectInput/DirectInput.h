
//#include <windows.h>
#include <dinput.h>
#include <dinputd.h>

extern CRITICAL_SECTION cs;

#define SAFE_DELETE(p)  { if(p) { delete (p);     (p)=NULL; } }
#define SAFE_RELEASE(p) { if(p) { (p)->Release(); (p)=NULL; } }


BOOL CALLBACK    EnumObjectsCallback( const DIDEVICEOBJECTINSTANCE* pdidoi, VOID* pContext );
BOOL CALLBACK    EnumJoysticksCallback( const DIDEVICEINSTANCE* pdidInstance, VOID* pContext );

// ��������� ��� �������� � �������
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

	// ����
	__declspec(dllexport) int GetSteering();

	// ������ ����
	__declspec(dllexport) int GetThrottle();

	// ������ ���������
	__declspec(dllexport) int GetClutch();

	// ������ �������
	__declspec(dllexport) int GetBrake();

	// ���������� ������ ��������� ������
	__declspec(dllexport) void GetButtonsArray(int *i);

	// ���������� ��������� ������������
	__declspec(dllexport) int GetPOV();
}