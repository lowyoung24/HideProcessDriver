#include "minifs.h"

DRIVER_INITIALIZE DriverEntry;
DRIVER_UNLOAD DriverUnload;

PDEVICE_OBJECT g_DeviceObject = NULL;
UNICODE_STRING DriverName, SymbolName;

int ActiveProcessLinks_off = 0;

#pragma alloc_text(INIT, DriverEntry)

#define DEVICE_NAME L"\\Device\\HideProcessCheat"
#define SYMBOLIC_LINK_NAME L"\\DosDevices\\HideProcessCheatSL"

BOOLEAN GetOffset(IN PEPROCESS Process)
{
    BOOLEAN success = FALSE;
    HANDLE PID = PsGetCurrentProcessId();
    PLIST_ENTRY ListEntry = { 0, };
    PLIST_ENTRY NextEntry = { 0, };

    for (int i = 0x00; i < PAGE_SIZE; i += 8)
    {
        if (*(PHANDLE)((PCHAR)Process + i) == PID)
        {
            ListEntry = (PVOID*)((PCHAR)Process + i + 0x8);
            if (MmIsAddressValid(ListEntry) && MmIsAddressValid(ListEntry->Flink))
            {
                NextEntry = ListEntry->Flink;
                if (ListEntry == NextEntry->Blink)
                {
                    ActiveProcessLinks_off = i + 8;
                    success = TRUE;
                    break;
                }
            }
        }
    }
    return success;
}

VOID DriverUnload(_In_ PDRIVER_OBJECT DriverObject) {
    UNICODE_STRING symLinkName;
    RtlInitUnicodeString(&symLinkName, SYMBOLIC_LINK_NAME);

    IoDeleteSymbolicLink(&symLinkName);
    IoDeleteDevice(DriverObject->DeviceObject);
}

NTSTATUS DriverEntry(IN PDRIVER_OBJECT pDriver, IN PUNICODE_STRING pRegPath) {
    NTSTATUS status;
    UNREFERENCED_PARAMETER(pRegPath);

    DbgPrint("DriverEntry called\n");

    RtlInitUnicodeString(&DriverName, DEVICE_NAME);
    RtlInitUnicodeString(&SymbolName, SYMBOLIC_LINK_NAME);

    status = IoCreateDevice(pDriver, 0, &DriverName, FILE_DEVICE_UNKNOWN, 0, FALSE, &g_DeviceObject);
    if (!NT_SUCCESS(status)) {
        DbgPrint("IoCreateDevice failed: 0x%x\n", status);
        return status;
    }

    status = IoCreateSymbolicLink(&SymbolName, &DriverName);
    if (!NT_SUCCESS(status)) {
        DbgPrint("IoCreateSymbolicLink failed: 0x%x\n", status);
        IoDeleteDevice(g_DeviceObject);
        return status;
    }

    pDriver->DriverUnload = DriverUnload;

    DbgPrint("Driver loaded successfully\n");
    return STATUS_SUCCESS;
}