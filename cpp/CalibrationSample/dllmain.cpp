#include <SDKDDKVer.h>
#define WIN32_WINNT _WIN32_WINNT_WIN2K
#define WIN32_LEAN_AND_MEAN             
#include <windows.h>
#include <map>
#include <vector>

#include "CalibrationSample.h"

//---------------------------------------------------------------------------
//	класс устройства для калибровки											|
//---------------------------------------------------------------------------
class CalibrationDevice
{
	private:
		CRITICAL_SECTION objCS;			//	критическая секция для работы в многопоточном окружении

		enum CalibStates
		{
			CALIB_NOCALIB	= 0,		//	неоткалиброванное состояние
			CALIB_PENDING	= 1,		//	в процессе калибровки
			CALIB_CALIB		= 2			//	откалиброванное состояние
		} 
		_enumState;						//	текущее состояние устройства

		wchar_t _pName[256];
		std::map<int, double> _calibratedValues;			// массив откалиброванных значений
		std::vector< std::pair<double, double> > vecCoefs;	// массив коэффициентов

		typedef std::map<int, double>::const_iterator CD_ITER;

		// проверяет значение val на вхождение в интервал между min и max
		static bool IsInRange(double min, double max, double val)
		{
			if (min <= max)
				return ((val >= min) && (val <= max));
			else
				return IsInRange(max, min, val);
		}

	public:
		DeviceFun m_DeviceFun;		//	функция устройства

		CalibrationDevice(const wchar_t * pName) : _enumState(CALIB_NOCALIB), m_DeviceFun(NULL)
		{
			InitializeCriticalSection(&objCS);
			wcscpy_s(_pName, pName);
		}

		~CalibrationDevice()
		{
			DeleteCriticalSection(&objCS);
		}

		// очистка калиброванных значений
		void Clear()
		{
			EnterCriticalSection(&objCS);
			_enumState = CALIB_NOCALIB;
			_calibratedValues.clear();
			vecCoefs.clear();
			LeaveCriticalSection(&objCS);
		}

		// калибровка устройства
		int Calibrate()
		{
			if(_enumState == CALIB_NOCALIB)
				return CALIBSAMPLE_ERRSTATE;	// устройство еще не готово к калибровке
			else
			{
				EnterCriticalSection(&objCS);
				vecCoefs.clear();
				// вычисляем линейные коэффициенты на отрезках
				double vmin, vmax, rmin, rmax;
				CD_ITER iter1 = _calibratedValues.begin();
				CD_ITER iter2 = iter1;
				std::pair<double, double> pairVal;
				++iter2;
				while (iter2 != _calibratedValues.end())
				{
					if (iter1->second < iter2->second)
					{
						vmin = iter1->second;
						vmax = iter2->second;
						rmin = iter1->first;
						rmax = iter2->first;
					}
					else
					{
						vmax = iter1->second;
						vmin = iter2->second;
						rmax = iter1->first;
						rmin = iter2->first;
					}
					pairVal.first = (rmax - rmin) / (vmax - vmin);
					pairVal.second = rmin - pairVal.first*vmin;
					vecCoefs.push_back(pairVal);
					iter1 = iter2;
					++iter2;
				}
				_enumState = CALIB_CALIB;
				LeaveCriticalSection(&objCS);
				return CALIBSAMPLE_NOERROR;
			}
		}

		// добавление калиброванного значения в устройство
		void AddCalibrationData(int r, double v)
		{
			EnterCriticalSection(&objCS);
			_calibratedValues[r] = v;
			if((_enumState == CALIB_NOCALIB) && (_calibratedValues.size() > 1))
				_enumState = CALIB_PENDING;
			LeaveCriticalSection(&objCS);
		}

		// устанавливает откалиброванное значение
		int SetDeviceValue(double v)
		{
			if(_enumState == CALIB_CALIB)
			{
				// проверяем, входит ли значение в диапазон допустимых значений
				if(IsInRange(_calibratedValues.begin()->second, _calibratedValues.rbegin()->second, v))
					return CALIBSAMPLE_ERRDATA;

				//	находим интервал, в котором находится v
				CD_ITER iter1 = _calibratedValues.begin();
				CD_ITER iter2 = iter1;
				std::vector<std::pair<double, double> >::const_iterator iterC = vecCoefs.begin();
				++iter2;
				while (iter2 != _calibratedValues.end())
				{
					if (IsInRange(iter1->second, iter2->second, v))
						break;
					++iter1;
					++iter2;
					++iterC;
				}
				//	если значения на разных сопротивлениях совпадают, то выбираем первое сопротивление (можно выбрать любое)
				//	иначе вычисляем r, как линейную функцию от v
				double r = (iter1->second == iter2->second ? iter1->first : iterC->first*v + iterC->second);
				return (m_DeviceFun == NULL ? CALIBSAMPLE_ERRINIT : m_DeviceFun((int)r));
			}
			else
				return CALIBSAMPLE_ERRSTATE;	// устройство еще не откалибровано
		}

		// устанавливает неоткалиброванное значение
		int SetResistorValue(int r)
		{
			return (m_DeviceFun == NULL ? CALIBSAMPLE_ERRINIT : m_DeviceFun(r));
		}
};

//	список всех устройств соответственно их идентификаторам
std::map<int, CalibrationDevice*> mapDevices;

//---------------------------------------------------------------------------
//	точка входа в библиотеку												|
//---------------------------------------------------------------------------
BOOL APIENTRY DllMain(HMODULE, DWORD ul_reason_for_call, LPVOID)
{
	if (ul_reason_for_call == DLL_PROCESS_DETACH)
		ClearRegistrations();
	return TRUE;
}

//---------------------------------------------------------------------------
//	регистрация идентификатора устройства и фукнции устройства для отправки	|
//	значения резистора на устройство										|
//..........................................................................|
//	id		:	идентификатор устройства									|
//	pFun	:	указатель на функцию										|
//---------------------------------------------------------------------------
extern "C" int CALIBRATIONSAMPLE_API RegisterDeviceFunction(int id, const wchar_t * name, DeviceFun pFun)
{
	if (pFun == NULL)
		return CALIBSAMPLE_ERRDATA;
	else
	{
		std::map<int, CalibrationDevice*>::iterator iterDev = mapDevices.find(id);
		if (iterDev != mapDevices.end())	//	уже регистрировали такое устройство
			return CALIBSAMPLE_WRONGDEVICE;
		else
		{
			//	создаем и регистрируем устройство
			CalibrationDevice * pDev = new CalibrationDevice(name);	
			pDev->m_DeviceFun = pFun;
			mapDevices[id] = pDev;	
			return CALIBSAMPLE_NOERROR;
		}
	}
}

//---------------------------------------------------------------------------
//	очистка всех регистрационных данных	об устройствах						|
//---------------------------------------------------------------------------
extern "C" void CALIBRATIONSAMPLE_API ClearRegistrations()
{
	std::map<int, CalibrationDevice*>::const_iterator iter_end = mapDevices.end();
	for (std::map<int, CalibrationDevice*>::const_iterator iter = mapDevices.begin(); iter != iter_end; ++iter)
		delete iter->second;
	mapDevices.clear();
}

//---------------------------------------------------------------------------
//	функция для очистки калибровочных данных устройства						|
//..........................................................................|
//	id	:	идентификатор устройства										|
//---------------------------------------------------------------------------
extern "C" int CALIBRATIONSAMPLE_API ClearCalibrationData(int id)
{
	std::map<int, CalibrationDevice*>::iterator iterDev = mapDevices.find(id);
	if (iterDev == mapDevices.end())
		return CALIBSAMPLE_WRONGDEVICE;
	else
	{
		iterDev->second->Clear();
		return CALIBSAMPLE_NOERROR;
	}
}

//---------------------------------------------------------------------------
//	функция для добавки калибровочных данных								|
//..........................................................................|
//	id	:	идентификатор устройства										|
//	r	:	значение резистора												|
//	v	:	значение на устройстве											|
//---------------------------------------------------------------------------
extern "C" int CALIBRATIONSAMPLE_API AddCalibrationData(int id, int r, double v)
{
	std::map<int, CalibrationDevice*>::iterator iterDev = mapDevices.find(id);
	if (iterDev == mapDevices.end())
		return CALIBSAMPLE_WRONGDEVICE;
	else
	{
		iterDev->second->AddCalibrationData(r, v);
		return CALIBSAMPLE_NOERROR;
	}
}

//---------------------------------------------------------------------------
//	команда на калибровку устройства										|
//..........................................................................|
//	id			:	идентификатор устройства								|
//	[retval]	:	возвращается номер ошибки								|
//---------------------------------------------------------------------------
extern "C" int CALIBRATIONSAMPLE_API CalibrateDevice(int id)
{
	std::map<int, CalibrationDevice*>::iterator iterDev = mapDevices.find(id);
	return (iterDev == mapDevices.end() ? CALIBSAMPLE_WRONGDEVICE : iterDev->second->Calibrate());
}

//---------------------------------------------------------------------------
//	функция для задания значения на панели прибора в откалиброванном состоянии
//---------------------------------------------------------------------------
//	id			:	идентификатор устройства								|
//  v			:	требуемое значение										|
//	[retval]	:	возвращается номер ошибки								|
//---------------------------------------------------------------------------
extern "C" int CALIBRATIONSAMPLE_API ShowDeviceValue(int id, double v)
{
	std::map<int, CalibrationDevice*>::iterator iterDev = mapDevices.find(id);
	return (iterDev == mapDevices.end() ? CALIBSAMPLE_WRONGDEVICE : iterDev->second->SetDeviceValue(v));
}

//---------------------------------------------------------------------------
//	функция для задания значения резистора в неоткалиброванном устройстве	|
//---------------------------------------------------------------------------
//	id			:	идентификатор устройства								|
//  r			:	требуемое значение										|
//	[retval]	:	возвращается номер ошибки								|
//---------------------------------------------------------------------------
extern "C" int CALIBRATIONSAMPLE_API ShowDeviceResistor(int id, int r)
{
	std::map<int, CalibrationDevice*>::iterator iterDev = mapDevices.find(id);
	return (iterDev == mapDevices.end() ? CALIBSAMPLE_WRONGDEVICE : iterDev->second->SetResistorValue(r));
}
