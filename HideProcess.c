#include <windows.h>
#include <winternl.h>
#include <stdio.h>
#include <stdlib.h>

#pragma comment(lib, "ntdll.lib")

EXTERN_C NTSTATUS NtSystemDebugControl(
    ULONG Command,
    PVOID InputBuffer,
    ULONG InputBufferLength,
    PVOID OutputBuffer,
    ULONG OutputBufferLength,
    PULONG ReturnLength
);

#define DEBUG_HIDE_SYSTEM_PROCESS 0x19

typedef struct _DEBUG_OBJECT_SECURITY_INFORMATION {
    ULONG Flags;
} DEBUG_OBJECT_SECURITY_INFORMATION;

int main(int argc, char* argv[])
{
    if (argc != 2)
    {
        printf("[+] HideProcess - User Mode Process Hiding Tool\n");
        printf("[+] Usage: HideProcess.exe <PID>\n");
        printf("[+] Example: HideProcess.exe 1234\n");
        return 1;
    }

    ULONG targetPid = atoi(argv[1]);
    if (targetPid == 0)
    {
        printf("[-] Invalid PID: %s\n", argv[1]);
        return 1;
    }

    printf("[+] Attempting to hide process with PID: %lu\n", targetPid);

    NTSTATUS status = NtSystemDebugControl(
        DEBUG_HIDE_SYSTEM_PROCESS,
        &targetPid,
        sizeof(ULONG),
        NULL,
        0,
        NULL
    );

    if (NT_SUCCESS(status))
    {
        printf("[+] Process %lu hidden successfully!\n", targetPid);
        return 0;
    }
    else
    {
        printf("[-] Failed to hide process. Status: 0x%08X\n", status);
        printf("[-] Note: This method may not work on all Windows versions\n");
        return 1;
    }
}