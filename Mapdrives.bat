@echo off
REM ============================================================================
REM Windows Logon Script for LAB07 Domain
REM File: mapdrives.bat
REM Location: /var/lib/samba/sysvol/lab07.lan/scripts/mapdrives.bat
REM ============================================================================
REM
REM Purpose: Automatically map network drives for domain users
REM Domain: lab07.lan
REM DC: ls07.lab07.lan (192.168.100.1)
REM Last Modified: Febrero 2026
REM
REM Usage: Assigned to users via Active Directory (scriptPath attribute)
REM ============================================================================

echo Mapeando unidades de red para LAB07...

REM Map Public share (all domain users)
net use Z: \\ls07.lab07.lan\Public /persistent:yes >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Unidad publica mapeada en Z:
) else (
    echo [AVISO] No se pudo mapear la unidad publica
)

REM Map HR Documents (HR_Staff group only)
net use H: \\ls07.lab07.lan\HRDocs /persistent:yes >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Documentos RRHH mapeados en H:
)

REM Map Finance Documents (Finance group only)
net use F: \\ls07.lab07.lan\FinanceDocs /persistent:yes >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Documentos Finanzas mapeados en F:
)

echo.
echo Unidades de red mapeadas correctamente.
timeout /t 3 >nul

exit

REM ============================================================================
REM DRIVE LETTER ASSIGNMENTS:
REM ============================================================================
REM   Z: = Public (all domain users - read-only)
REM   H: = HRDocs (HR_Staff group members - read/write)
REM   F: = FinanceDocs (Finance group members - read/write, no delete)
REM
REM ============================================================================
REM HOW TO ASSIGN THIS SCRIPT TO USERS:
REM ============================================================================
REM
REM Method 1: Single user
REM   sudo ldbmodify -H /var/lib/samba/private/sam.ldb <<EOF
REM   dn: CN=Username,CN=Users,DC=lab07,DC=lan
REM   changetype: modify
REM   replace: scriptPath
REM   scriptPath: mapdrives.bat
REM   EOF
REM
REM Method 2: Multiple users (bash script)
REM   for user in alice bob charlie; do
REM     CN_NAME=$(sudo samba-tool user show $user | grep "^dn:" | cut -d',' -f1 | cut -d'=' -f2)
REM     sudo ldbmodify -H /var/lib/samba/private/sam.ldb <<EOF
REM   dn: CN=$CN_NAME,CN=Users,DC=lab07,DC=lan
REM   changetype: modify
REM   replace: scriptPath
REM   scriptPath: mapdrives.bat
REM   EOF
REM   done
REM
REM Verify assignment:
REM   sudo samba-tool user show USERNAME | grep scriptPath
REM
REM Expected output:
REM   scriptPath: mapdrives.bat
REM
REM ============================================================================
REM TROUBLESHOOTING:
REM ============================================================================
REM
REM Script doesn't run:
REM   1. Verify script exists on server:
REM      ls -la /var/lib/samba/sysvol/lab07.lan/scripts/
REM   2. Check user has scriptPath attribute:
REM      sudo samba-tool user show alice | grep scriptPath
REM   3. Verify file permissions (should be 755):
REM      ls -la /var/lib/samba/sysvol/lab07.lan/scripts/mapdrives.bat
REM
REM Drives don't map:
REM   1. Test UNC path manually from Windows:
REM      \\ls07.lab07.lan\Public
REM   2. Verify DNS resolution:
REM      nslookup ls07.lab07.lan
REM   3. Check user group membership:
REM      sudo samba-tool user show alice | grep memberOf
REM   4. Verify share permissions:
REM      testparm -s --section-name=Public
REM
REM ============================================================================
