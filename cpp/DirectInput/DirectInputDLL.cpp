// DirectInputDLL.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "DirectInput.h"

LPDIRECTINPUT8 pDI;				// указатель на интерфейс DirectInput
LPDIRECTINPUTDEVICE8 pDevice;		// указатель на интерфейс устройства
bool gInitComplete;
CRITICAL_SECTION	cs		= {0};

// Структура для передачи в коллбек
::DIJOYSTATE2 gJoyState;

// Хендл главного окна
HWND gHWND;



BOOL CALLBACK    EnumObjectsCallback( const DIDEVICEOBJECTINSTANCE* pdidoi, VOID* pContext )
{
	HWND hDlg = ( HWND )pContext;

    // For axes that are returned, set the DIPROP_RANGE property for the
    // enumerated axis in order to scale min/max values.
    if( pdidoi->dwType & DIDFT_AXIS )
    {
        DIPROPRANGE diprg;
        diprg.diph.dwSize = sizeof( DIPROPRANGE );
        diprg.diph.dwHeaderSize = sizeof( DIPROPHEADER );
        diprg.diph.dwHow = DIPH_BYID;
        diprg.diph.dwObj = pdidoi->dwType; // Specify the enumerated axis
        diprg.lMin = -1000;
        diprg.lMax = +1000;

        // Set the range for the axis
        if( FAILED( pDevice->SetProperty( DIPROP_RANGE, &diprg.diph ) ) )
            return DIENUM_STOP;
    }

	return DIENUM_CONTINUE;
}

BOOL CALLBACK EnumJoysticksCallback( const DIDEVICEINSTANCE* pdidInstance,
                                     VOID* pContext )
{
    DI_ENUM_CONTEXT* pEnumContext = ( DI_ENUM_CONTEXT* )pContext;
    HRESULT hr;

    //if( g_bFilterOutXinputDevices && IsXInputDevice( &pdidInstance->guidProduct ) )
    //    return DIENUM_CONTINUE;

    // Skip anything other than the perferred joystick device as defined by the control panel.  
    // Instead you could store all the enumerated joysticks and let the user pick.
    if( pEnumContext->bPreferredJoyCfgValid &&
        !IsEqualGUID( pdidInstance->guidInstance, pEnumContext->pPreferredJoyCfg->guidInstance ) )
        return DIENUM_CONTINUE;

    // Obtain an interface to the enumerated joystick.
    hr = pDI->CreateDevice( pdidInstance->guidInstance, &pDevice, NULL );

    // If it failed, then we can't use this joystick. (Maybe the user unplugged
    // it while we were in the middle of enumerating it.)
    if( FAILED( hr ) )
        return DIENUM_CONTINUE;

    // Stop enumeration. Note: we're just taking the first joystick we get. You
    // could store all the enumerated joysticks and let the user pick.
    return DIENUM_STOP;
}

void ResetJoyState()
{
	gJoyState.lX = 65535;
	gJoyState.lRz = 65535;
	gJoyState.rglSlider[0] = 65535;
	gJoyState.lY = 65535;
}

void FreeResources()
{
	if( pDevice )
		pDevice->Unacquire();

	// Release any DirectInput objects.
	SAFE_RELEASE( pDevice );
	SAFE_RELEASE( pDI );
}



extern "C"
{
	__declspec(dllexport) bool InitializeDirectInput()
	{
		gInitComplete = false;
		pDI = NULL;
		pDevice = NULL;
		gHWND = ::GetForegroundWindow();
		if(gHWND == NULL)
		{
			//MessageBox(NULL, L"Failed to get window handle", NULL, NULL);
			return false;
		}

		HRESULT hr;
		// инициализация интерфейса
		if(FAILED(hr = DirectInput8Create(GetModuleHandle(NULL),  DIRECTINPUT_VERSION , IID_IDirectInput8, (void **)&pDI, NULL)))
		{
			//std::cout << "Failed to init DirectInput interface\n";
			return false;
		}


		/// JOYSTICK ========================================================
		// Получение настроек
		::IDirectInputJoyConfig8 *pJoyConfig = NULL;
		if(FAILED(hr = pDI->QueryInterface(IID_IDirectInputJoyConfig8, (void **) &pJoyConfig)))
		{
			//std::cout << "Failed to queryInterface \n";
			return false;
		}

		::DIJOYCONFIG JoyCfg = {0};
		::DI_ENUM_CONTEXT enumContext;
		enumContext.pPreferredJoyCfg = &JoyCfg;
		enumContext.bPreferredJoyCfgValid = false;

		if(SUCCEEDED( pJoyConfig->GetConfig( 0, &JoyCfg, DIJC_GUIDINSTANCE)))
		{
			enumContext.bPreferredJoyCfgValid = true;
		}
		else
		{
			//std::cout << "Preferred Joy Config not founded";
		}
		pJoyConfig->Release();

		// поиск простого джойстика
		if(FAILED(hr = pDI->EnumDevices( DI8DEVCLASS_GAMECTRL, ::EnumJoysticksCallback, &enumContext, DIEDFL_ATTACHEDONLY)))
		{
			//std::cout << "Failed enumDevices";
			return false;
		}

		//  Проверяем джойстик
		if(pDevice == NULL)
		{
			//std::cout << "JoyStick not found";
			//MessageBox(NULL, L"Joystick not found", NULL, NULL);
			return false;
		}

		//
		if(FAILED( hr = pDevice->SetDataFormat(&c_dfDIJoystick2)))
		{
			//std::cout << "Failed to set data format";
			return false;
		}

		if(FAILED( hr = pDevice->SetCooperativeLevel(gHWND, DISCL_EXCLUSIVE | DISCL_FOREGROUND)))
		{
			//std::cout << "Failed to set cooperative level";
			return false;
		}

		if(FAILED( hr = pDevice->EnumObjects(::EnumObjectsCallback, /*NULL*/(VOID*)gHWND, DIDFT_ALL)))
		{
			//MessageBox(0,L"failed to enumerate",0,0);
			return false;
		}

		//============
		if(FAILED(hr = pDevice->Acquire()))
		{
			//MessageBox(0,L"failed to accuire",0,0);
			return false;
		}

		//===========
		//MessageBox(0,L"init complete!!!!!!!!!!",0,0);
		gInitComplete = true;
		ResetJoyState();

		return true;
	}

	__declspec(dllexport) bool UpdateJoyState()
	{
		

		if(!gInitComplete)
		{
			//MessageBox(0,L"init incomplete",0,0);
			return false;
		}

		HRESULT hr;

		if(pDevice == NULL)
			return true;/** true ? */

		// Опрашиваем устройство
		hr = pDevice->Poll();
		if(FAILED(hr))
		{
			// Устройство потеряно, пробуем его захватить
			hr = pDevice->Acquire();

			while(hr == DIERR_INPUTLOST)
			{
				hr = pDevice->Acquire();
			}

			return true;
		}

		// Получаем состояние устройства
		if( FAILED(hr = pDevice->GetDeviceState(sizeof(DIJOYSTATE2), &gJoyState) ))
		{
			//MessageBox(0,L"failed to get sost",0,0);
			return false;
		}
		else
		{
			/*if(first)
			{
				first = false;
				ResetJoyState();
				//pDevice->
				return true;
			}*/
		}

		return true;
	}

	// Руль
	__declspec(dllexport) int GetSteer()
	{
		//if(gInitComplete)
			return (int)::gJoyState.lX;

		//return 65535;
	}

	// педаль газа
	__declspec(dllexport) int GetThrottle()
	{
		//MessageBox(0,L"GetThrottle",0,0);
		//if(gInitComplete)
			return (int)::gJoyState.lRz;
		//return 65535;
	}

	// педаль сцепления
	__declspec(dllexport) int GetClutch()
	{
		//if(gInitComplete)
			return (int)::gJoyState.rglSlider[0];
		//else
		//	return 65535;
	}

	// педаль тормоза
	__declspec(dllexport) int GetBrake()
	{
		//if(gInitComplete)
			return (int)::gJoyState.lY;
		//return 65535;
	}

	
	// Возвращает массив состояний кнопок
	__declspec(dllexport) void GetButtonsArray(int *i)
	{
		//js.rgbButtons[i] & 0x80 = нажата
		for(int c=0; c<128; c++)
		{
			if(gJoyState.rgbButtons[c] & 0x80)
				i[c] = 1;
			else
				i[c] = 0;
		}
		//memset(i, 1, 128);
		//i[0] = 1;
		//::memcpy((void*)i, gJoyState.rgbButtons, 128);
	}

	// Джойстик
	__declspec(dllexport) int GetPOV()	
	{
		return (int)::gJoyState.rgdwPOV[0];
	}
}