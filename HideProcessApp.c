#include <windows.h>
#include <stdio.h>
#include <stdlib.h>

#define IOCTL_HIDE_PROCESS CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define SYMBOLIC_LINK_NAME "\\\\.\\HideProcessCheatSL"

void PrintUsage(const char* exeName)
{
    printf("[+] HideProcess - Kernel Driver Process Hiding Tool\n");
    printf("[+] Usage: %s <PID>\n", exeName);
    printf("[+] Example: %s 1234\n", exeName);
    printf("\n[!] Requires the driver (HideProcess.sys) to be installed and running.\n");
    printf("[!] To install driver, run as Administrator:\n");
    printf("    sc create HideProcess type= kernel binPath= C:\\Windows\\System32\\drivers\\HideProcess.sys\n");
    printf("    sc start HideProcess\n");
}

BOOL InstallDriver()
{
    SC_HANDLE schSCManager = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);
    if (schSCManager == NULL)
    {
        printf("[-] Failed to open Service Control Manager. Error: %lu\n", GetLastError());
        return FALSE;
    }

    char sysPath[MAX_PATH];
    GetSystemDirectoryA(sysPath, MAX_PATH);
    strcat_s(sysPath, MAX_PATH, "\\drivers\\HideProcess.sys");

    SC_HANDLE schService = CreateServiceA(
        schSCManager,
        "HideProcess",
        "HideProcess",
        SERVICE_ALL_ACCESS,
        SERVICE_KERNEL_DRIVER,
        SERVICE_DEMAND_START,
        SERVICE_ERROR_NORMAL,
        sysPath,
        NULL, NULL, NULL, NULL, NULL
    );

    if (schService == NULL)
    {
        DWORD err = GetLastError();
        if (err == ERROR_SERVICE_EXISTS)
        {
            printf("[i] Driver service already exists.\n");
        }
        else
        {
            printf("[-] Failed to create service. Error: %lu\n", err);
            CloseServiceHandle(schSCManager);
            return FALSE;
        }
    }
    else
    {
        CloseServiceHandle(schService);
        printf("[+] Driver service created successfully.\n");
    }

    schService = OpenServiceA(schSCManager, "HideProcess", SERVICE_ALL_ACCESS);
    if (schService == NULL)
    {
        printf("[-] Failed to open service. Error: %lu\n", GetLastError());
        CloseServiceHandle(schSCManager);
        return FALSE;
    }

    if (!StartService(schService, 0, NULL))
    {
        DWORD err = GetLastError();
        if (err == ERROR_SERVICE_ALREADY_RUNNING)
        {
            printf("[i] Driver is already running.\n");
        }
        else
        {
            printf("[-] Failed to start driver. Error: %lu\n", err);
            CloseServiceHandle(schService);
            CloseServiceHandle(schSCManager);
            return FALSE;
        }
    }
    else
    {
        printf("[+] Driver started successfully.\n");
    }

    CloseServiceHandle(schService);
    CloseServiceHandle(schSCManager);
    return TRUE;
}

BOOL HideProcessByPid(ULONG targetPid)
{
    HANDLE hDevice = CreateFileA(
        SYMBOLIC_LINK_NAME,
        GENERIC_READ | GENERIC_WRITE,
        FILE_SHARE_READ | FILE_SHARE_WRITE,
        NULL,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL,
        NULL
    );

    if (hDevice == INVALID_HANDLE_VALUE)
    {
        printf("[-] Failed to open device. Error: %lu\n", GetLastError());
        printf("[-] Make sure the driver is installed and running.\n");
        return FALSE;
    }

    ULONG bytesReturned = 0;
    BOOL success = DeviceIoControl(
        hDevice,
        IOCTL_HIDE_PROCESS,
        &targetPid,
        sizeof(ULONG),
        NULL,
        0,
        &bytesReturned,
        NULL
    );

    if (success)
    {
        printf("[+] Process %lu hidden successfully!\n", targetPid);
    }
    else
    {
        printf("[-] Failed to hide process. Error: %lu\n", GetLastError());
    }

    CloseHandle(hDevice);
    return success;
}

int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        PrintUsage(argv[0]);
        return 1;
    }

    if (strcmp(argv[1], "-install") == 0)
    {
        printf("[+] Installing driver...\n");
        return InstallDriver() ? 0 : 1;
    }

    if (strcmp(argv[1], "-uninstall") == 0)
    {
        printf("[+] Uninstalling driver...\n");
        SC_HANDLE schSCManager = OpenSCManager(NULL, NULL, SC_MANAGER_ALL_ACCESS);
        if (schSCManager == NULL)
        {
            printf("[-] Failed to open SCM. Error: %lu\n", GetLastError());
            return 1;
        }

        SC_HANDLE schService = OpenServiceA(schSCManager, "HideProcess", SERVICE_ALL_ACCESS);
        if (schService == NULL)
        {
            printf("[-] Failed to open service. Error: %lu\n", GetLastError());
            CloseServiceHandle(schSCManager);
            return 1;
        }

        SERVICE_STATUS status;
        ControlService(schService, SERVICE_CONTROL_STOP, &status);

        if (!DeleteService(schService))
        {
            printf("[-] Failed to delete service. Error: %lu\n", GetLastError());
            CloseServiceHandle(schService);
            CloseServiceHandle(schSCManager);
            return 1;
        }

        printf("[+] Driver uninstalled successfully.\n");
        CloseServiceHandle(schService);
        CloseServiceHandle(schSCManager);
        return 0;
    }

    ULONG targetPid = atoi(argv[1]);
    if (targetPid == 0)
    {
        printf("[-] Invalid PID: %s\n", argv[1]);
        PrintUsage(argv[0]);
        return 1;
    }

    printf("[+] Target PID: %lu\n", targetPid);
    printf("[+] Opening driver device...\n");

    if (!HideProcessByPid(targetPid))
    {
        printf("\n[i] Attempting to auto-install driver...\n");
        if (InstallDriver())
        {
            printf("\n[i] Retrying to hide process...\n");
            HideProcessByPid(targetPid);
        }
    }

    return 0;
}