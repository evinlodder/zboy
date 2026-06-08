#ifndef CONSOLE_H
#define CONSOLE_H

typedef char *(*VersionFunc)(void);

typedef struct __ConsoleApi {
  VersionFunc get_version;
} ConsoleApi;

#endif // CONSOLE_H
