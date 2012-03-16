#pragma once
//#define CARX_STATIC_LIB

#ifdef CARX_STATIC_LIB
	#define CARX_API
#else
	#ifdef CARX_EXPORTS
		#define CARX_API __declspec(dllexport)
	#else
		#define CARX_API __declspec(dllimport)
	#endif
#endif


				

