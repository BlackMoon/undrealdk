#ifndef ENCODE
#define ENCODE

/** Конвертирование Юникод в UTF8*/
char * unicode_to_1251(const wchar_t *unicode_string);

/* Конвертирование UTF8 в Юникод */
wchar_t * utf8_to_unicode(const char *utf8_string);

/** Конвертирование строки Win1251 в Unicode */
wchar_t * a1251_to_unicode(const char *string);

/** Конвертирование строки utf8 в Win1251 */
char* utf8_to_1251(const char *utf8_string);

/** Конвертирование строки Юникод в utf8 */
char * unicode_to_utf8(const wchar_t *unicode_string);

#endif /* ENCODE */