#include <Windows.h>
#include <stdio.h>

#include "encode.h"

wchar_t * a1251_to_unicode(const char *string){
	int err;
	wchar_t * res;
	int res_len = MultiByteToWideChar(
		1251,			// Code page
		0,					// No flags
		string,		// Multibyte characters string
		-1,					// The string is NULL terminated
		NULL,				// No buffer yet, allocate it later
		0					// No buffer
		);
	if (res_len == 0) 
	{
		printf("Failed to obtain utf8 string length\n");
		return NULL;
	}
	res = (wchar_t*)calloc(sizeof(wchar_t), res_len);
	if (res == NULL) 
	{
		printf("Failed to allocate unicode string\n");
		return NULL;
	}
	err = MultiByteToWideChar(
		1251,			// Code page
		0,					// No flags
		string,		// Multibyte characters string
		-1,					// The string is NULL terminated
		res,				// Output buffer
		res_len				// buffer size
		);
	if (err == 0)
	{
		printf("Failed to convert to unicode\n");
		free(res);
		return NULL;
	}
	return res;
}

char* utf8_to_1251(const char *utf8_string)
{
	return unicode_to_1251 (utf8_to_unicode (utf8_string));
}

wchar_t * utf8_to_unicode(const char *utf8_string)
{
	int err;
	wchar_t * res;
	int res_len = MultiByteToWideChar(
		CP_UTF8,			// Code page
		0,					// No flags
		utf8_string,		// Multibyte characters string
		-1,					// The string is NULL terminated
		NULL,				// No buffer yet, allocate it later
		0					// No buffer
		);
	if (res_len == 0) 
	{
		printf("Failed to obtain utf8 string length\n");
		return NULL;
	}
	res = (wchar_t*)calloc(sizeof(wchar_t), res_len);
	if (res == NULL) 
	{
		printf("Failed to allocate unicode string\n");
		return NULL;
	}
	err = MultiByteToWideChar(
		CP_UTF8,			// Code page
		0,					// No flags
		utf8_string,		// Multibyte characters string
		-1,					// The string is NULL terminated
		res,				// Output buffer
		res_len				// buffer size
		);
	if (err == 0)
	{
		printf("Failed to convert to unicode\n");
		free(res);
		return NULL;
	}
	return res;
}

char * unicode_to_1251(const wchar_t *unicode_string)
{
	int err;
	char * res;
	int res_len = WideCharToMultiByte(
		1251,				// Code page
		0,					// Default replacement of illegal chars
		unicode_string,		// Multibyte characters string
		-1,					// Number of unicode chars is not known
		NULL,				// No buffer yet, allocate it later
		0,					// No buffer
		NULL,				// Use system default
		NULL				// We are not interested whether the default char was used
		);
	if (res_len == 0) 
	{
		printf("Failed to obtain required cp1251 string length\n");
		return NULL;
	}
	res = (char*)calloc(sizeof(char), res_len);
	if (res == NULL) 
	{
		printf("Failed to allocate cp1251 string\n");
		return NULL;
	}
	err = WideCharToMultiByte(
		1251,				// Code page
		0,					// Default replacement of illegal chars
		unicode_string,		// Multibyte characters string
		-1,					// Number of unicode chars is not known
		res,				// Output buffer
		res_len,			// buffer size
		NULL,				// Use system default
		NULL				// We are not interested whether the default char was used
		);
	if (err == 0)
	{
		printf("Failed to convert from unicode\n");
		free(res);
		return NULL;
	}
	return res;
}

char * unicode_to_utf8(const wchar_t *unicode_string)
{
	int err;
	char * res;
	int res_len = WideCharToMultiByte(
		CP_UTF8,				// Code page
		0,					// Default replacement of illegal chars
		unicode_string,		// Multibyte characters string
		-1,					// Number of unicode chars is not known
		NULL,				// No buffer yet, allocate it later
		0,					// No buffer
		NULL,				// Use system default
		NULL				// We are not interested whether the default char was used
		);
	if (res_len == 0) 
	{
		printf("Failed to obtain required UTF8 string length\n");
		return NULL;
	}
	res = (char*)calloc(sizeof(char), res_len);
	if (res == NULL) 
	{
		printf("Failed to allocate UTF8 string\n");
		return NULL;
	}
	err = WideCharToMultiByte(
		CP_UTF8,				// Code page
		0,					// Default replacement of illegal chars
		unicode_string,		// Multibyte characters string
		-1,					// Number of unicode chars is not known
		res,				// Output buffer
		res_len,			// buffer size
		NULL,				// Use system default
		NULL				// We are not interested whether the default char was used
		);
	if (err == 0)
	{
		printf("Failed to convert from unicode\n");
		free(res);
		return NULL;
	}
	return res;
}