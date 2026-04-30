#pragma once

#ifndef __NTIFS_H
#define __NTIFS_H

#include <ntdef.h>

typedef unsigned long ULONG;
typedef unsigned short USHORT;
typedef unsigned char UCHAR;
typedef long NTSTATUS;
typedef void *PVOID;
typedef PVOID *PPVOID;
typedef ULONG *PULONG;
typedef USHORT *PUSHORT;
typedef UCHAR *PUCHAR;
typedef void (*PDRIVER_INITIALIZE)(PVOID, PVOID);
typedef void (*PDRIVER_UNLOAD)(PVOID);
typedef PVOID PDEVICE_OBJECT;
typedef PVOID PEPROCESS;
typedef PVOID PHANDLE;

typedef struct _LIST_ENTRY {
    struct _LIST_ENTRY *Flink;
    struct _LIST_ENTRY *Blink;
} LIST_ENTRY, *PLIST_ENTRY;

typedef struct _UNICODE_STRING {
    USHORT Length;
    USHORT MaximumLength;
    PWSTR Buffer;
} UNICODE_STRING, *PUNICODE_STRING;

typedef const UNICODE_STRING* PCUNICODE_STRING;

#define RtlInitUnicodeString(DestinationString, SourceString) { \
    (DestinationString)->Length = (USHORT)(wcslen(SourceString) * sizeof(WCHAR)); \
    (DestinationString)->MaximumLength = (DestinationString)->Length + sizeof(UNICODE_NULL); \
    (DestinationString)->Buffer = (PWSTR)(SourceString); \
}

#define RTL_CONSTANT_UNICODE_STRING(_str, _buffer, _maxLen) \
    { sizeof(_maxLen) - sizeof(WCHAR), sizeof(_maxLen), _buffer }

#define IOCTL_HIDE_PROCESS CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define PAGE_SIZE 4096

EXTERN_C NTKERNELAPI BOOLEAN MmIsAddressValid(PVOID VirtualAddress);
EXTERN_C NTKERNELAPI PVOID PsGetCurrentProcess(VOID);
EXTERN_C NTKERNELAPI HANDLE PsGetCurrentProcessId(VOID);
EXTERN_C NTKERNELAPI NTSTATUS PsLookupProcessByProcessId(HANDLE ProcessId, PEPROCESS *Process);

#define FILE_DEVICE_UNKNOWN 0x00000022
#define METHOD_BUFFERED 0
#define FILE_ANY_ACCESS 0
#define CTL_CODE(DeviceType, Function, Method, Access) ( \
    ((DeviceType) << 16) | ((Access) << 14) | ((Function) << 2) | (Method) \
)

typedef enum _DEVICE_TYPE {
    FILE_DEVICE_UNKNOWN_TYPE = 0x00000022
} DEVICE_TYPE;

#define FILE_DEVICE_SECURE_OPEN 0x00000080

EXTERN_C NTKERNELAPI NTSTATUS IoCreateDevice(
    PVOID DriverObject,
    ULONG DeviceExtensionSize,
    PUNICODE_STRING DeviceName,
    DEVICE_TYPE DeviceType,
    ULONG DeviceCharacteristics,
    BOOLEAN Exclusive,
    PDEVICE_OBJECT *DeviceObject
);

EXTERN_C NTKERNELAPI NTSTATUS IoCreateSymbolicLink(
    PUNICODE_STRING SymbolicLinkName,
    PUNICODE_STRING DeviceName
);

EXTERN_C NTKERNELAPI VOID IoDeleteDevice(PDEVICE_OBJECT DeviceObject);

EXTERN_C NTKERNELAPI NTSTATUS IoDeleteSymbolicLink(PUNICODE_STRING SymbolicLinkName);

#define STATUS_SUCCESS 0
#define STATUS_INSUFFICIENT_RESOURCES ((NTSTATUS)0xC000009AL)
#define STATUS_OBJECT_NAME_EXISTS ((NTSTATUS)0xC0000035L)

#define UNREFERENCED_PARAMETER(P) (void)(P)

#endif