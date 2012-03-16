// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the SMUTILS_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// SMUTILS_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#include <windows.h>

#ifdef SMUTILS_EXPORTS
#define SMUTILS_API __declspec(dllexport)
#else
#define SMUTILS_API __declspec(dllimport)
#endif

extern "C" SMUTILS_API int MonitorsNum();
extern "C" SMUTILS_API void WindowPos(int x, int y, int cx, int cy);