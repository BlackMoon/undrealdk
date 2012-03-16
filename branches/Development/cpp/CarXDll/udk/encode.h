#ifndef ENCODE
#define ENCODE

/** ��������������� ������ � UTF8*/
char * unicode_to_1251(const wchar_t *unicode_string);

/* ��������������� UTF8 � ������ */
wchar_t * utf8_to_unicode(const char *utf8_string);

/** ��������������� ������ Win1251 � Unicode */
wchar_t * a1251_to_unicode(const char *string);

/** ��������������� ������ utf8 � Win1251 */
char* utf8_to_1251(const char *utf8_string);

/** ��������������� ������ ������ � utf8 */
char * unicode_to_utf8(const wchar_t *unicode_string);

#endif /* ENCODE */