ECHO OFF

REG add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v DisableRegistryTools /t REG_DWORD /d 0 /f
REG DELETE HKLM\System\CurrentControlSet\Control\StorageDevicePolicies /f

ECHO --------------------------------
ECHO --------------------------------
ECHO Simdi Flash Bellegi cikartip tak!
ECHO --------------------------------
ECHO --------------------------------

PAUSE
EXIT