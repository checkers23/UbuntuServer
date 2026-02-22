# 📖 Documentación Completa - LAB07 Samba AD

**Versión:** 2.0  
**Última actualización:** Febrero 2026  
**Proyecto:** Implementación de Active Directory con Samba 4  
**Laboratorio:** LAB07

---

## 📋 Tabla de Contenidos

1. [Resumen del Proyecto](#1-resumen-del-proyecto)
2. [Infraestructura](#2-infraestructura)
3. [Sprint 1: Configuración del Controlador de Dominio](#3-sprint-1-configuración-del-controlador-de-dominio)
4. [Sprint 2: Usuarios, Grupos y Unidades Organizativas](#4-sprint-2-usuarios-grupos-y-unidades-organizativas)
5. [Sprint 3: Carpetas Compartidas y Permisos](#5-sprint-3-carpetas-compartidas-y-permisos)
6. [Sprint 4: Trust entre Dominios (LAB07 ↔ LAB08)](#6-sprint-4-trust-entre-dominios)
7. [Configuración del Cliente Ubuntu](#7-configuración-del-cliente-ubuntu)
8. [Configuración del Cliente Windows](#8-configuración-del-cliente-windows)
9. [Referencia de Comandos](#9-referencia-de-comandos)
10. [Solución de Problemas](#10-solución-de-problemas)

---

## 1. Resumen del Proyecto

### 1.1 Descripción

Este proyecto implementa un **controlador de dominio Active Directory completo** usando Samba 4 en Ubuntu Server 24.04. Proporciona servicios de autenticación centralizada, gestión de usuarios y grupos, carpetas compartidas con permisos granulares, y soporte para clientes Windows y Linux.

### 1.2 Características Principales

✅ **Controlador de Dominio Funcional**
- Dominio: lab07.lan
- Realm: LAB07.LAN
- NetBIOS: LAB07

✅ **Servicios Activos**
- DNS interno con resolución de nombres
- Servidor Kerberos (KDC)
- Servidor LDAP
- SMB/CIFS para compartir archivos
- Catálogo Global

✅ **Estructura Organizativa**
- 3 Unidades Organizativas (OUs)
- 5 Grupos de Seguridad
- 8+ Usuarios del dominio
- Políticas de contraseñas (GPO)

✅ **Carpetas Compartidas**
- FinanceDocs (Grupo Finance)
- HRDocs (Grupo HR_Staff)
- Public (Todos los usuarios)

### 1.3 Requisitos

**Hardware Mínimo:**
- CPU: 2 cores
- RAM: 2GB (4GB recomendado)
- Disco: 20GB

**Software:**
- Ubuntu Server 24.04 LTS
- Samba 4.19.5
- Acceso root/sudo

---

## 2. Infraestructura

### 2.1 Arquitectura de Red

```
                    Internet / Red Externa
                              │
                    Gateway: 172.30.20.1
                              │
                  ┌───────────┴───────────┐
                  │   Red Externa         │
                  │   172.30.20.0/25      │
                  └───────┬───────┬───────┘
                          │       │
                    .54   │       │   .53
                  ┌───────┴───┐ ┌─┴───────┐
                  │   ls07    │ │   lc07  │
                  │ DC Server │ │ Cliente │
                  │172.30.20  │ │172.30.20│
                  │    .54    │ │    .53  │
                  └───────┬───┘ └─┴───────┘
                          │       │
                    .1    │       │   .2
                  ┌───────┴───────┴────────┐
                  │   Red Interna          │
                  │   192.168.100.0/25     │
                  │                        │
                  │  ls07: 192.168.100.1   │
                  │  lc07: 192.168.100.2   │
                  └────────────────────────┘
```

### 2.2 Servidor - ls07

| Parámetro | Valor |
|-----------|-------|
| **Hostname** | ls07.lab07.lan |
| **Dominio** | lab07.lan |
| **Realm** | LAB07.LAN |
| **NetBIOS** | LAB07 |
| **IP Interna** | 192.168.100.1/25 |
| **IP Externa** | 172.30.20.54/25 |
| **Gateway** | 172.30.20.1 |
| **DNS Primario** | 127.0.0.1 (sí mismo) |
| **DNS Forwarder** | 10.239.3.7 |
| **OS** | Ubuntu Server 24.04 LTS |
| **Rol** | Controlador de Dominio AD |

### 2.3 Cliente Ubuntu - lc07

| Parámetro | Valor |
|-----------|-------|
| **Hostname** | lc07 |
| **IP Interna** | 192.168.100.2/25 |
| **IP Externa** | 172.30.20.53/25 |
| **Gateway** | 172.30.20.1 |
| **DNS** | 192.168.100.1 (apunta al DC) |
| **Dominio** | lab07.lan |
| **OS** | Ubuntu Desktop 24.04 |
| **Estado** | ✅ Unido al dominio |

### 2.4 Cliente Windows

| Parámetro | Valor |
|-----------|-------|
| **Hostname** | Por definir |
| **IP** | Por asignar |
| **DNS** | 192.168.100.1 |
| **Dominio** | lab07.lan |
| **OS** | Windows 11 Pro |
| **Estado** | ⏳ Pendiente |

### 2.5 Credenciales

**Administrador del Dominio (LAB07):**
```
Usuario: Administrator
Contraseña: Admin_21
UPN: administrator@LAB07.LAN
SAM: LAB07\Administrator
```

**Usuario del Sistema Linux:**
```
Usuario: administrador
Contraseña: admin_21
```

**Usuarios del Dominio:**
```
Todos los usuarios: password = admin_21
- alice, bob, charlie (Estudiantes)
- iosif, karl, lenin (IT Admins)
- vladimir (HR Staff)
- techsupport (Soporte Técnico)
```

---

## 3. Sprint 1: Configuración del Controlador de Dominio

**Duración:** 6 horas  
**Objetivo:** Instalar y configurar Samba 4 como Controlador de Dominio

### 3.1 Configuración Inicial del Sistema

#### Paso 1: Establecer el Hostname

```bash
# Configurar hostname completo
sudo hostnamectl set-hostname ls07.lab07.lan

# Verificar
hostname
hostname -f
```

**Salida esperada:**
```
ls07
ls07.lab07.lan
```

#### Paso 2: Actualizar el Sistema

```bash
# Actualizar repositorios
sudo apt update

# Actualizar paquetes
sudo apt upgrade -y

# Reiniciar si es necesario
sudo reboot
```

#### Paso 3: Configurar /etc/hosts

```bash
sudo nano /etc/hosts
```

**Contenido:**
```
127.0.0.1 localhost
192.168.100.1 ls07.lab07.lan ls07

::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

**Verificar:**
```bash
cat /etc/hosts
ping -c 2 ls07.lab07.lan
```

### 3.2 Configuración de Red

#### Paso 1: Identificar Interfaces

```bash
# Listar interfaces de red
ip a

# Salida ejemplo:
# enp0s3: interfaz externa (172.30.20.54/25)
# enp0s8: interfaz interna (192.168.100.1/25)
```

#### Paso 2: Configurar Netplan

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

**Contenido:**
```yaml
network:
  version: 2
  ethernets:
    enp0s3:  # Interfaz EXTERNA
      dhcp4: no
      addresses:
        - 172.30.20.54/25
      routes:
        - to: default
          via: 172.30.20.1
      nameservers:
        addresses: [127.0.0.1, 10.239.3.7]
        search: [lab07.lan]
    
    enp0s8:  # Interfaz INTERNA
      dhcp4: no
      addresses:
        - 192.168.100.1/25
      nameservers:
        addresses: [127.0.0.1]
        search: [lab07.lan]
```

**⚠️ IMPORTANTE:** 
- Adapta `enp0s3` y `enp0s8` a tus nombres de interfaz
- Usa `ip a` para ver tus interfaces reales

#### Paso 3: Aplicar Configuración

```bash
# Aplicar cambios
sudo netplan apply

# Verificar IPs
ip a | grep inet

# Verificar rutas
ip route

# Probar conectividad
ping -c 2 172.30.20.1      # Gateway
ping -c 2 10.239.3.7       # DNS externo
```

**Salida esperada:**
```
inet 172.30.20.54/25 ...
inet 192.168.100.1/25 ...
default via 172.30.20.1 dev enp0s3
```

### 3.3 Deshabilitar systemd-resolved

**⚠️ CRÍTICO:** Samba necesita control total del puerto 53 (DNS).

```bash
# Detener y deshabilitar systemd-resolved
sudo systemctl disable --now systemd-resolved

# Verificar que está detenido
sudo systemctl status systemd-resolved

# Debe mostrar: "inactive (dead)"
```

#### Eliminar enlace simbólico y crear resolv.conf manual

```bash
# Eliminar el enlace simbólico
sudo unlink /etc/resolv.conf

# Crear archivo manual
sudo nano /etc/resolv.conf
```

**Contenido:**
```
nameserver 127.0.0.1
nameserver 10.239.3.7
nameserver 10.239.3.8
search lab07.lan
```

#### Verificar que el puerto 53 está libre

```bash
sudo ss -tulnp | grep :53
```

**Salida esperada:** (vacío - ningún proceso usando puerto 53)

### 3.4 Instalar Samba y Dependencias

```bash
sudo apt install -y acl attr samba samba-dsdb-modules samba-vfs-modules \
  winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user \
  dnsutils ldap-utils
```

**Durante la instalación de Kerberos, responder:**
```
Realm: LAB07.LAN
Kerberos Server: ls07.lab07.lan
Administrative Server: ls07.lab07.lan
```

#### Detener servicios por defecto

```bash
# Detener servicios que no se usan en modo DC
sudo systemctl disable --now smbd nmbd winbind

# Verificar que están detenidos
sudo systemctl status smbd
sudo systemctl status nmbd
sudo systemctl status winbind

# Todos deben mostrar: "inactive (dead)"
```

### 3.5 Provisionar el Dominio

#### Paso 1: Eliminar configuración por defecto

```bash
sudo rm -f /etc/samba/smb.conf
```

#### Paso 2: Provisionar el dominio

```bash
sudo samba-tool domain provision --use-rfc2307 --interactive
```

**Respuestas durante el provisionamiento:**

| Pregunta | Respuesta |
|----------|-----------|
| Realm | `LAB07.LAN` |
| Domain | `LAB07` |
| Server Role | `dc` (domain controller) |
| DNS backend | `SAMBA_INTERNAL` |
| DNS forwarder IP address | `10.239.3.7` |
| Administrator password | `Admin_21` |
| Retype password | `Admin_21` |

**Salida esperada:**
```
Server Role:           active directory domain controller
Hostname:              ls07
NetBIOS Domain:        LAB07
DNS Domain:            lab07.lan
DOMAIN SID:            S-1-5-21-...
```

#### Paso 3: Verificar configuración generada

```bash
cat /etc/samba/smb.conf
```

**Contenido esperado:**
```ini
[global]
    dns forwarder = 10.239.3.7
    netbios name = LS07
    realm = LAB07.LAN
    server role = active directory domain controller
    workgroup = LAB07

[sysvol]
    path = /var/lib/samba/sysvol
    read only = No

[netlogon]
    path = /var/lib/samba/sysvol/lab07.lan/scripts
    read only = No
```

### 3.6 Configurar Kerberos

```bash
# Copiar configuración de Kerberos generada por Samba
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# Verificar contenido
cat /etc/krb5.conf
```

**Debe contener:**
```ini
[libdefaults]
    default_realm = LAB07.LAN
    dns_lookup_realm = false
    dns_lookup_kdc = true
```

### 3.7 Iniciar Samba AD DC

```bash
# Desbloquear, habilitar e iniciar el servicio
sudo systemctl unmask samba-ad-dc
sudo systemctl enable samba-ad-dc
sudo systemctl start samba-ad-dc

# Verificar estado
sudo systemctl status samba-ad-dc
```

**Salida esperada:**
```
● samba-ad-dc.service - Samba AD Daemon
     Loaded: loaded
     Active: active (running)
```

### 3.8 Verificación Completa

#### Nivel del Dominio

```bash
sudo samba-tool domain level show
```

**Salida esperada:**
```
Forest function level: (Windows) 2008 R2
Domain function level: (Windows) 2008 R2
```

#### Información del Dominio

```bash
sudo samba-tool domain info 127.0.0.1
```

**Salida esperada:**
```
Forest           : lab07.lan
Domain           : lab07.lan
Netbios domain   : LAB07
DC name          : ls07.lab07.lan
DC netbios name  : LS07
Server site      : Default-First-Site-Name
Client site      : Default-First-Site-Name
```

#### Verificar DNS

```bash
# Registro A del DC
host -t A ls07.lab07.lan

# Salida esperada:
# ls07.lab07.lan has address 192.168.100.1

# Registros SRV de LDAP
host -t SRV _ldap._tcp.lab07.lan

# Salida esperada:
# _ldap._tcp.lab07.lan has SRV record 0 100 389 ls07.lab07.lan.

# Registros SRV de Kerberos
host -t SRV _kerberos._tcp.lab07.lan

# Salida esperada:
# _kerberos._tcp.lab07.lan has SRV record 0 100 88 ls07.lab07.lan.

# Resolución inversa
host 192.168.100.1

# Salida esperada:
# 1.100.168.192.in-addr.arpa domain name pointer ls07.lab07.lan.
```

#### Verificar Kerberos

```bash
# Obtener ticket
kinit administrator@LAB07.LAN
# Password: Admin_21

# Listar tickets
klist

# Salida esperada:
# Ticket cache: FILE:/tmp/krb5cc_...
# Default principal: administrator@LAB07.LAN
# Valid starting     Expires            Service principal
# ...                ...                krbtgt/LAB07.LAN@LAB07.LAN

# Destruir ticket
kdestroy
```

#### Verificar LDAP

```bash
# Autenticar con Kerberos primero
kinit administrator@LAB07.LAN

# Buscar usuarios
ldapsearch -Y GSSAPI -H ldap://ls07.lab07.lan \
  -b "DC=lab07,DC=lan" "(objectClass=user)" cn sAMAccountName

# Debe mostrar: Administrator, Guest, krbtgt

# Limpiar
kdestroy
```

#### Listar Usuarios

```bash
sudo samba-tool user list
```

**Salida esperada:**
```
Administrator
Guest
krbtgt
```

#### Verificar Puertos en Escucha

```bash
sudo ss -tulnp | grep -E ':(53|88|389|445|636|3268)'
```

**Debe mostrar Samba escuchando en:**
- Puerto 53 (DNS)
- Puerto 88 (Kerberos)
- Puerto 389 (LDAP)
- Puerto 445 (SMB)
- Puerto 636 (LDAPS)
- Puerto 3268 (Catálogo Global)

### ✅ Sprint 1 Completado

Has configurado exitosamente:
- ✅ Sistema Ubuntu configurado
- ✅ Red dual (externa e interna) operativa
- ✅ systemd-resolved deshabilitado
- ✅ Samba 4 instalado y provisionado
- ✅ Dominio lab07.lan operativo
- ✅ DNS funcionando correctamente
- ✅ Kerberos autenticando
- ✅ LDAP respondiendo
- ✅ Servicios iniciados y habilitados

**Siguiente paso:** [Sprint 2: Usuarios, Grupos y OUs](#4-sprint-2-usuarios-grupos-y-unidades-organizativas)

---

## 4. Sprint 2: Usuarios, Grupos y Unidades Organizativas

**Duración:** 6 horas  
**Objetivo:** Crear estructura organizativa con OUs, grupos de seguridad y usuarios del dominio

### 4.1 Conceptos: OUs vs Grupos

| Característica | OU (Unidad Organizativa) | Grupo de Seguridad |
|----------------|--------------------------|---------------------|
| **Propósito** | Organización y aplicación de GPOs | Asignar permisos |
| **Contiene** | Usuarios, Grupos, Computadoras, OUs | Solo miembros (usuarios) |
| **Permisos** | ❌ No se asignan a recursos | ✅ Se asignan a recursos |
| **GPOs** | ✅ Se aplican a OUs | ❌ No se aplican a grupos |

### 4.2 Tipos y Ámbitos de Grupos

**Tipos:**
- **Security Group:** Asigna permisos (el más común)
- **Distribution Group:** Solo para email

**Ámbitos:**
- **Domain Local:** Permisos en el dominio local
- **Global:** Miembros del mismo dominio (recomendado)
- **Universal:** A través de todo el bosque

### 4.3 Crear Unidades Organizativas

```bash
# OU para el departamento de IT
sudo samba-tool ou create "OU=IT_Department,DC=lab07,DC=lan"

# OU para el departamento de RRHH
sudo samba-tool ou create "OU=HR_Department,DC=lab07,DC=lan"

# OU para estudiantes
sudo samba-tool ou create "OU=Students,DC=lab07,DC=lan"
```

#### Verificar OUs creadas

```bash
sudo samba-tool ou list
```

**Salida esperada:**
```
OU=IT_Department,DC=lab07,DC=lan
OU=HR_Department,DC=lab07,DC=lan
OU=Students,DC=lab07,DC=lan
OU=Domain Controllers,DC=lab07,DC=lan
```

### 4.4 Crear Grupos de Seguridad

```bash
# Grupo de administradores de IT
sudo samba-tool group add IT_Admins

# Grupo de personal de RRHH
sudo samba-tool group add HR_Staff

# Grupo de estudiantes
sudo samba-tool group add Students

# Grupo de finanzas (inicialmente vacío)
sudo samba-tool group add Finance

# Grupo de soporte técnico
sudo samba-tool group add Tech_Support
```

#### Verificar grupos creados

```bash
sudo samba-tool group list | grep -E "(IT_Admins|HR_Staff|Students|Finance|Tech_Support)"
```

**Salida esperada:**
```
Finance
HR_Staff
IT_Admins
Students
Tech_Support
```

### 4.5 Crear Usuarios del Dominio

#### Usuarios del grupo Students

```bash
sudo samba-tool user create alice admin_21 \
  --given-name=Alice --surname=Wonderland

sudo samba-tool user create bob admin_21 \
  --given-name=Bob --surname=Marley

sudo samba-tool user create charlie admin_21 \
  --given-name=Charlie --surname=Sheen
```

#### Usuarios del grupo IT_Admins

```bash
sudo samba-tool user create iosif admin_21 \
  --given-name=Stalin --surname=Thegreat

sudo samba-tool user create karl admin_21 \
  --given-name=Karl --surname=Marx

sudo samba-tool user create lenin admin_21 \
  --given-name=Vladimir --surname=Lenin
```

#### Usuarios del grupo HR_Staff

```bash
sudo samba-tool user create vladimir admin_21 \
  --given-name=Vladimir --surname=Malakovsky
```

#### Usuario de soporte técnico

```bash
sudo samba-tool user create techsupport admin_21 \
  --given-name=Tech --surname=Support
```

#### Verificar usuarios creados

```bash
sudo samba-tool user list
```

**Salida esperada:**
```
Administrator
alice
bob
charlie
Guest
iosif
karl
krbtgt
lenin
techsupport
vladimir
```

### 4.6 Asignar Usuarios a Grupos

```bash
# Añadir estudiantes al grupo Students
sudo samba-tool group addmembers Students alice,bob,charlie

# Añadir administradores IT al grupo IT_Admins
sudo samba-tool group addmembers IT_Admins iosif,karl,lenin

# Añadir personal RRHH al grupo HR_Staff
sudo samba-tool group addmembers HR_Staff vladimir

# Añadir soporte técnico
sudo samba-tool group addmembers Tech_Support techsupport
```

**⚠️ IMPORTANTE:** Los usuarios se separan con comas SIN espacios.

#### Verificar membresías

```bash
# Ver miembros de Students
sudo samba-tool group listmembers Students

# Salida esperada:
# alice
# bob
# charlie

# Ver miembros de IT_Admins
sudo samba-tool group listmembers IT_Admins

# Salida esperada:
# iosif
# karl
# lenin

# Ver miembros de HR_Staff
sudo samba-tool group listmembers HR_Staff

# Salida esperada:
# vladimir

# Ver miembros de Finance (vacío)
sudo samba-tool group listmembers Finance

# Salida esperada: (vacío)
```

#### Verificar grupos de un usuario

```bash
sudo samba-tool user show alice | grep memberOf
```

**Salida esperada:**
```
memberOf: CN=Students,CN=Users,DC=lab07,DC=lan
memberOf: CN=Domain Users,CN=Users,DC=lab07,DC=lan
```

### 4.7 Probar Autenticación de Usuario

```bash
# Obtener ticket como alice
kinit alice@LAB07.LAN
# Password: admin_21

# Verificar ticket
klist

# Salida esperada:
# Default principal: alice@LAB07.LAN

# Limpiar
kdestroy
```

### 4.8 Estructura Organizativa Final

```
lab07.lan
│
├── Domain Controllers (OU)
│   └── LS07 (Computadora)
│
├── IT_Department (OU)
├── HR_Department (OU)  
├── Students (OU)
│
└── Users (Contenedor - por defecto)
    │
    ├── USUARIOS:
    │   ├── alice → Students
    │   ├── bob → Students
    │   ├── charlie → Students
    │   ├── iosif → IT_Admins
    │   ├── karl → IT_Admins
    │   ├── lenin → IT_Admins
    │   ├── vladimir → HR_Staff
    │   └── techsupport → Tech_Support
    │
    └── GRUPOS:
        ├── IT_Admins (iosif, karl, lenin)
        ├── HR_Staff (vladimir)
        ├── Students (alice, bob, charlie)
        ├── Finance (vacío)
        └── Tech_Support (techsupport)
```

### 4.9 Configurar Política de Contraseñas (GPO)

#### Ver política actual

```bash
sudo samba-tool domain passwordsettings show
```

#### Configurar política de seguridad

```bash
# Longitud mínima: 12 caracteres
sudo samba-tool domain passwordsettings set --min-pwd-length=12

# Habilitar complejidad (mayúsculas, minúsculas, números, símbolos)
sudo samba-tool domain passwordsettings set --complexity=on

# Historial: recordar últimas 24 contraseñas
sudo samba-tool domain passwordsettings set --history-length=24

# Edad mínima: 1 día (evita cambios inmediatos)
sudo samba-tool domain passwordsettings set --min-pwd-age=1

# Edad máxima: 42 días (forzar cambios periódicos)
sudo samba-tool domain passwordsettings set --max-pwd-age=42

# Duración de bloqueo: 30 minutos
sudo samba-tool domain passwordsettings set --account-lockout-duration=30

# Umbral de bloqueo: 0 (deshabilitado para laboratorio)
sudo samba-tool domain passwordsettings set --account-lockout-threshold=0

# Reiniciar contador de bloqueo: 30 minutos
sudo samba-tool domain passwordsettings set --reset-account-lockout-after=30
```

#### Verificar nueva política

```bash
sudo samba-tool domain passwordsettings show
```

**Salida esperada:**
```
Password complexity: on
Store plaintext passwords: off
Password history length: 24
Minimum password length: 12
Minimum password age (days): 1
Maximum password age (days): 42
Account lockout duration (mins): 30
Account lockout threshold (attempts): 0
Reset account lockout after (mins): 30
```

#### Probar política

```bash
# Intentar crear usuario con contraseña débil
sudo samba-tool user create testgpo weak123

# Debe fallar con error:
# ERROR: the password is too short. It should be equal or longer than 12 characters!

# Crear con contraseña compleja
sudo samba-tool user create testgpo 'SecureP@ss2026!'

# Debe funcionar

# Eliminar usuario de prueba
sudo samba-tool user delete testgpo
```

#### Configurar Administrator sin expiración

```bash
sudo samba-tool user setexpiry Administrator --noexpiry
```
4.10: Gestión de GPOs
Samba 4 crea automáticamente dos GPOs predeterminadas durante el aprovisionamiento del dominio.
Listar todas las GPOs e inspeccionar la estructura SYSVOL:
bash# Listar todas las GPOs del dominio
sudo samba-tool gpo listall

# Ver el directorio SYSVOL (donde se almacenan las GPOs en disco)
sudo ls -la /var/lib/samba/sysvol/lab07.lan/Policies/

# Ver a qué contenedor está vinculada cada GPO
sudo samba-tool gpo listcontainers "{31B2F340-016D-11D2-945F-00C04FB984F9}"
sudo samba-tool gpo listcontainers "{6AC1786C-016F-11D2-945F-00C04FB984F9}"
GPOs predeterminadas:

Default Domain Policy {31B2F340...} → vinculada a DC=lab07,DC=lan — controla la política de contraseñas
Default Domain Controllers Policy {6AC1786C...} → vinculada a OU=Domain Controllers

Orden de procesamiento de GPOs (LSDOU): Local → Sitio → Dominio → OU — la última aplicada tiene prioridad.

### ✅ Sprint 2 Completado

Has configurado exitosamente:
- ✅ 3 Unidades Organizativas creadas
- ✅ 5 Grupos de Seguridad creados
- ✅ 8 Usuarios del dominio creados
- ✅ Usuarios asignados a grupos apropiados
- ✅ Política de contraseñas configurada (GPO)
- ✅ Estructura verificada con samba-tool
- ✅ Autenticación Kerberos probada

**Siguiente paso:** [Sprint 3: Carpetas Compartidas y Permisos](#5-sprint-3-carpetas-compartidas-y-permisos)

---

## 5. Sprint 3: Carpetas Compartidas y Permisos

**Duración:** 6 horas  
**Objetivo:** Configurar carpetas compartidas con permisos granulares ACL

### 5.1 Entender los Niveles de Permisos

En Samba (como en Windows Server), hay **DOS niveles de permisos**:

1. **Permisos de Compartir** (configurados en smb.conf)
2. **Permisos del Sistema de Archivos** (POSIX + ACLs)

**Regla de Oro:** El permiso más restrictivo siempre gana.

### 5.2 POSIX vs ACLs

#### POSIX Básico (Limitado):
```
rwxrw-r--
│││││││││
││││││└└└─ Otros (o)
│││└└└───  Grupo (g)
└└└─────   Propietario (u)
```

#### ACLs (Granular, similar a NTFS):
- Múltiples usuarios y grupos por archivo
- Herencia de permisos
- Permisos por defecto

### 5.3 Estructura Planificada

```
/srv/samba/
├── finance/    → Grupo Finance (R/W sin borrar)
├── hr/         → Grupo HR_Staff (R/W)
└── public/     → Domain Users (Solo lectura)
```

### 5.4 Matriz de Permisos

| Compartido | Finance | HR_Staff | Students | Domain Admins |
|------------|---------|----------|----------|---------------|
| **FinanceDocs** | R/W (sin borrar) | ❌ | ❌ | Control Total |
| **HRDocs** | ❌ | R/W | ❌ | Control Total |
| **Public** | R | R | R | Control Total |

### 5.5 Crear Directorios

```bash
# Crear estructura
sudo mkdir -p /srv/samba/{finance,hr,public}

# Verificar
ls -la /srv/samba/
```

#### Establecer propietarios y permisos básicos

```bash
# Propietario: root, Grupo: Domain Users
sudo chown -R root:"Domain Users" /srv/samba

# Permisos base
sudo chmod -R 770 /srv/samba

# Verificar
ls -la /srv/samba/
```

**Salida esperada:**
```
drwxrwx--- 5 root Domain Users 4096 ... .
drwxrwx--- 2 root Domain Users 4096 ... finance
drwxrwx--- 2 root Domain Users 4096 ... hr
drwxrwx--- 2 root Domain Users 4096 ... public
```

### 5.6 Configurar Compartidos en Samba

```bash
sudo nano /etc/samba/smb.conf
```

**Añadir al final del archivo:**

```ini
#===================== Share Definitions =====================

[FinanceDocs]
    comment = Documentos del Departamento de Finanzas
    path = /srv/samba/finance
    valid users = @Finance, @"Domain Admins"
    read only = no
    browseable = yes
    create mask = 0660
    directory mask = 0770

[HRDocs]
    comment = Documentos del Departamento de RRHH
    path = /srv/samba/hr
    valid users = @HR_Staff, @"Domain Admins"
    read only = no
    browseable = yes
    create mask = 0660
    directory mask = 0770

[Public]
    comment = Documentos Públicos Compartidos (Solo Lectura)
    path = /srv/samba/public
    valid users = @"Domain Users"
    read only = yes
    browseable = yes
    write list = @"Domain Admins"
```

#### Verificar sintaxis

```bash
testparm
```

**Salida esperada:**
```
Load smb config files from /etc/samba/smb.conf
Loaded services file OK.
```

#### Recargar Samba

```bash
sudo systemctl reload samba-ad-dc
```

#### Listar compartidos

```bash
smbclient -L localhost -U administrator
# Password: Admin_21
```

**Salida esperada:**
```
Sharename       Type      Comment
---------       ----      -------
FinanceDocs     Disk      Documentos del Departamento de Finanzas
HRDocs          Disk      Documentos del Departamento de RRHH
Public          Disk      Documentos Públicos Compartidos
sysvol          Disk
netlogon        Disk
```

### 5.7 Instalar Herramientas ACL

```bash
sudo apt install -y acl
```

### 5.8 Configurar ACLs

#### FinanceDocs (R/W sin borrar - sticky bit)

```bash
# Establecer ACL para grupo Finance
sudo setfacl -m g:Finance:rwx /srv/samba/finance

# ACL por defecto (para nuevos archivos)
sudo setfacl -d -m g:Finance:rwx /srv/samba/finance

# Aplicar sticky bit (evita borrar archivos de otros)
sudo chmod +t /srv/samba/finance

# Verificar
getfacl /srv/samba/finance
ls -la /srv/samba/
```

**Salida esperada con sticky bit:**
```
drwxrwx--T 2 root Domain Users ... finance
         ^-- T = sticky bit activo
```

**¿Qué hace el sticky bit?**
- ✅ Los usuarios pueden crear archivos
- ✅ Los usuarios solo pueden borrar sus propios archivos
- ❌ Los usuarios NO pueden borrar archivos de otros

#### HRDocs (R/W normal)

```bash
# Establecer ACL para grupo HR_Staff
sudo setfacl -m g:HR_Staff:rwx /srv/samba/hr

# ACL por defecto
sudo setfacl -d -m g:HR_Staff:rwx /srv/samba/hr

# Verificar
getfacl /srv/samba/hr
```

#### Public (Solo lectura)

```bash
# Permisos de solo lectura para Domain Users
sudo setfacl -m g:"Domain Users":rx /srv/samba/public

# ACL por defecto
sudo setfacl -d -m g:"Domain Users":rx /srv/samba/public

# Verificar
getfacl /srv/samba/public
```

### 5.9 Ver Todas las ACLs

```bash
for dir in finance hr public; do
    echo "=== /srv/samba/$dir ==="
    getfacl /srv/samba/$dir
    echo
done
```

### 5.10 Probar desde el Servidor

#### Crear archivos de prueba

```bash
# Autenticar como administrator
kinit administrator@LAB07.LAN

# Crear archivos de prueba
sudo -u administrator touch /srv/samba/finance/test_finance.txt
sudo -u administrator touch /srv/samba/hr/test_hr.txt
sudo -u administrator touch /srv/samba/public/test_public.txt

# Verificar
ls -la /srv/samba/finance/
ls -la /srv/samba/hr/
ls -la /srv/samba/public/

# Limpiar
kdestroy
```

#### Probar con smbclient

```bash
# Conectar a FinanceDocs como administrator
smbclient //ls07.lab07.lan/FinanceDocs -U administrator
# Password: Admin_21

# Dentro de la sesión SMB:
smb: \> ls
smb: \> exit
```

### 5.11 Rutas UNC para Acceso

Los clientes accederán a las comparticiones usando:

```
\\ls07.lab07.lan\FinanceDocs
\\ls07.lab07.lan\HRDocs
\\ls07.lab07.lan\Public
```

### 5.12 Mapeo Automático de Carpetas

#### Para Clientes Windows - Scripts de Logon

##### Crear script de logon

```bash
sudo mkdir -p /var/lib/samba/sysvol/lab07.lan/scripts
sudo nano /var/lib/samba/sysvol/lab07.lan/scripts/mapdrives.bat
```

**Contenido:**
```batch
@echo off
REM Mapeo automático de unidades de red
net use Z: \\ls07.lab07.lan\Public /persistent:yes >nul 2>&1
net use H: \\ls07.lab07.lan\HRDocs /persistent:yes >nul 2>&1
net use F: \\ls07.lab07.lan\FinanceDocs /persistent:yes >nul 2>&1
exit
```

##### Establecer permisos

```bash
sudo chmod 755 /var/lib/samba/sysvol/lab07.lan/scripts/mapdrives.bat
```

##### Asignar script a usuario

```bash
# Para alice
sudo ldbmodify -H /var/lib/samba/private/sam.ldb <<EOF
dn: CN=Alice Wonderland,CN=Users,DC=lab07,DC=lan
changetype: modify
replace: scriptPath
scriptPath: mapdrives.bat
EOF
```

##### Verificar asignación

```bash
sudo samba-tool user show alice | grep scriptPath
```

**Salida esperada:**
```
scriptPath: mapdrives.bat
```

##### Asignar a todos los usuarios (script masivo)

```bash
for user in alice bob charlie iosif karl lenin vladimir; do
  CN_NAME=$(sudo samba-tool user show $user | grep "^dn:" | cut -d',' -f1 | cut -d'=' -f2)
  sudo ldbmodify -H /var/lib/samba/private/sam.ldb <<EOF
dn: CN=$CN_NAME,CN=Users,DC=lab07,DC=lan
changetype: modify
replace: scriptPath
scriptPath: mapdrives.bat
EOF
done
```

#### Para Clientes Linux - Script PAM

##### Crear script de montaje

```bash
sudo mkdir -p /var/lib/samba/netlogon/linux
sudo nano /var/lib/samba/netlogon/linux/mount-shares.sh
```

**Contenido:**
```bash
#!/bin/bash
# Montaje automático de recursos compartidos para usuarios del dominio

USER=$PAM_USER
DOMAIN="LAB07"

# Crear puntos de montaje
mkdir -p ~/Shared/{Public,HRDocs,FinanceDocs} 2>/dev/null

# Montar Public (todos los usuarios)
if ! mountpoint -q ~/Shared/Public; then
    mount -t cifs //ls07.lab07.lan/Public ~/Shared/Public \
      -o username=$USER,domain=$DOMAIN,uid=$(id -u),gid=$(id -g),_netdev 2>/dev/null
fi

# Montar HRDocs (solo grupo HR_Staff)
if groups | grep -q "HR_Staff"; then
    if ! mountpoint -q ~/Shared/HRDocs; then
        mount -t cifs //ls07.lab07.lan/HRDocs ~/Shared/HRDocs \
          -o username=$USER,domain=$DOMAIN,uid=$(id -u),gid=$(id -g),_netdev 2>/dev/null
    fi
fi

# Montar FinanceDocs (solo grupo Finance)
if groups | grep -q "Finance"; then
    if ! mountpoint -q ~/Shared/FinanceDocs; then
        mount -t cifs //ls07.lab07.lan/FinanceDocs ~/Shared/FinanceDocs \
          -o username=$USER,domain=$DOMAIN,uid=$(id -u),gid=$(id -g),_netdev 2>/dev/null
    fi
fi

exit 0
```

##### Establecer permisos

```bash
sudo chmod 755 /var/lib/samba/netlogon/linux/mount-shares.sh
```

##### Configurar en los clientes Linux

Los clientes Linux deberán:

1. Copiar el script:
```bash
sudo scp administrador@ls07.lab07.lan:/var/lib/samba/netlogon/linux/mount-shares.sh \
  /usr/local/bin/
sudo chmod 755 /usr/local/bin/mount-shares.sh
```

2. Configurar PAM:
```bash
sudo nano /etc/pam.d/common-session
```

Añadir al final:
```
session optional pam_exec.so /usr/local/bin/mount-shares.sh
```

### ✅ Sprint 3 Completado

Has configurado exitosamente:
- ✅ 3 carpetas compartidas creadas
- ✅ Compartidos configurados en smb.conf
- ✅ ACLs granulares establecidas
- ✅ Sticky bit aplicado a Finance (evita borrados)
- ✅ Permisos verificados
- ✅ Acceso desde servidor probado
- ✅ Mapeo automático configurado (Windows & Linux)
- ✅ Scripts de logon probados y funcionando

**Siguiente paso:** [Sprint 4: Trust entre Dominios](#6-sprint-4-trust-entre-dominios) (Opcional)

---

## 6. Sprint 4: Trust entre Dominios (LAB07 ↔ LAB08)

**Duración:** 6 horas  
**Objetivo:** Crear segundo dominio y establecer trust bidireccional de bosque

**⚠️ NOTA:** Este sprint es OPCIONAL y requiere un segundo servidor.

### 6.1 Arquitectura con Dos Dominios

```
Bosque 1: lab07.lan               Bosque 2: lab08.lan
├── DC: ls07.lab07.lan            ├── DC: ls08.lab08.lan
├── IP: 192.168.100.1             ├── IP: 192.168.100.2
└── Usuarios: 8                   └── Usuarios: 2
            │
            │ ◄──── Forest Trust (Bidireccional) ────►
            │
```

### 6.2 Tipos de Trust

| Tipo | Ámbito | Dirección | Uso |
|------|--------|-----------|-----|
| **Forest Trust** | Bosques completos | Bidireccional | Integración completa entre organizaciones |
| **External Trust** | Dominios específicos | Uni/Bidireccional | Acceso limitado entre dominios |

### 6.3 Información del Segundo Dominio (LAB08)

Si decides implementar un segundo dominio, estos serían los parámetros:

| Parámetro | Valor |
|-----------|-------|
| **Hostname** | ls08.lab08.lan |
| **Dominio** | lab08.lan |
| **Realm** | LAB08.LAN |
| **NetBIOS** | LAB08 |
| **IP Interna** | 192.168.100.3/25 |
| **IP Externa** | 172.30.20.XX/25 |
| **DNS Primario** | 127.0.0.1 |
| **DNS Secundario** | 192.168.100.1 (LAB07) |

### 6.4 Pasos para Crear el Trust (Resumen)

**IMPORTANTE:** Solo realiza estos pasos si tienes un segundo servidor.

1. Instalar segundo DC siguiendo Sprint 1 con los valores de LAB08
2. Configurar reenvío DNS mutuo
3. Crear trust bidireccional
4. Validar trust
5. Probar autenticación cruzada

Para instrucciones detalladas, consulta la documentación original del proyecto LAB05.

---

## 7. Configuración del Cliente Ubuntu

**Objetivo:** Unir cliente Ubuntu Desktop al dominio lab07.lan

### 7.1 Información del Cliente

| Parámetro | Valor |
|-----------|-------|
| **Hostname** | lc07 |
| **IP Interna** | 192.168.100.2/25 |
| **IP Externa** | 172.30.20.53/25 |
| **DNS** | 192.168.100.1 (DC) |
| **Gateway** | 172.30.20.1 |
| **Dominio** | lab07.lan |
| **Estado** | ✅ Unido |

### 7.2 Configurar Red

#### Para Ubuntu Desktop (GUI):

1. Abrir **Configuración** → **Red**
2. Clic en el ícono de engranaje de la conexión
3. Ir a la pestaña **IPv4**
4. Seleccionar **Manual**
5. Configurar:
   - **Dirección:** 192.168.100.2
   - **Máscara:** 255.255.255.128
   - **Puerta de enlace:** 172.30.20.1 (o dejar vacío)
   - **DNS:** 192.168.100.1
   - **Dominios de búsqueda:** lab07.lan
6. Clic en **Aplicar**

#### Para Ubuntu Server (CLI):

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

**Configuración:**
```yaml
network:
  version: 2
  ethernets:
    enp0s3:  # Tu interfaz - verifica con: ip a
      dhcp4: no
      addresses:
        - 192.168.100.2/25
      nameservers:
        addresses: [192.168.100.1]
        search: [lab07.lan]
```

**Aplicar:**
```bash
sudo netplan apply
```

### 7.3 Verificar Conectividad

```bash
# Probar resolución DNS
nslookup lab07.lan
nslookup ls07.lab07.lan

# Probar ping
ping -c 4 192.168.100.1
ping -c 4 ls07.lab07.lan

# Probar registros SRV (crítico para unión al dominio)
host -t SRV _ldap._tcp.lab07.lan
```

**Salida esperada:**
```
lab07.lan has address 192.168.100.1
ls07.lab07.lan has address 192.168.100.1
_ldap._tcp.lab07.lan has SRV record 0 100 389 ls07.lab07.lan.
```

### 7.4 Establecer Hostname

```bash
# Configurar hostname
sudo hostnamectl set-hostname lc07

# Verificar
hostname
hostname -f
```

### 7.5 Instalar Paquetes Necesarios

```bash
sudo apt update
sudo apt install -y realmd sssd sssd-tools libnss-sss libpam-sss \
  adcli samba-common-bin packagekit krb5-user
```

**Durante la instalación de Kerberos:**
- **Realm por defecto:** LAB07.LAN
- **Servidores Kerberos:** ls07.lab07.lan
- **Servidor administrativo:** ls07.lab07.lan

### 7.6 Descubrir el Dominio

```bash
sudo realm discover lab07.lan
```

**Salida esperada:**
```
lab07.lan
  type: kerberos
  realm-name: LAB07.LAN
  domain-name: lab07.lan
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  required-package: sssd
  required-package: libnss-sss
  required-package: libpam-sss
  required-package: adcli
  required-package: samba-common-bin
```

✅ **Indicador clave:** `type: kerberos` y `server-software: active-directory`

### 7.7 Unir al Dominio

```bash
sudo realm join --verbose --user=administrator lab07.lan
```

**Introduce la contraseña:** `Admin_21`

**Salida esperada:**
```
 * Resolving: _ldap._tcp.lab07.lan
 * Performing LDAP DSE lookup on: 192.168.100.1
 * Successfully discovered: lab07.lan
 * Enrolling machine in realm
 * Calculated computer account name: LC07
 * Using domain name: lab07.lan
 * Joining machine to realm
 * Successfully enrolled machine in realm
```

### 7.8 Verificar Unión al Dominio

```bash
sudo realm list
```

**Salida esperada:**
```
lab07.lan
  type: kerberos
  realm-name: LAB07.LAN
  domain-name: lab07.lan
  configured: kerberos-member
  server-software: active-directory
  client-software: sssd
  login-formats: %U@lab07.lan
  login-policy: allow-realm-logins
```

✅ **Indicador clave:** `configured: kerberos-member`

#### Verificar cuenta de computadora en el DC

```bash
# Desde el servidor (ls07)
sudo samba-tool computer list
```

**Debe mostrar:**
```
LC07$
```

### 7.9 Configurar SSSD

```bash
sudo nano /etc/sssd/sssd.conf
```

**Contenido:**
```ini
[sssd]
domains = lab07.lan
config_file_version = 2
services = nss, pam

[domain/lab07.lan]
default_shell = /bin/bash
krb5_store_password_if_offline = True
cache_credentials = True
krb5_realm = LAB07.LAN
realmd_tags = manages-system joined-with-adcli
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = lab07.lan
use_fully_qualified_names = True
ldap_id_mapping = True
access_provider = ad
```

**Para usar nombres cortos (opcional):**

Cambiar estas líneas:
```ini
use_fully_qualified_names = False
fallback_homedir = /home/%u
```

#### Reiniciar SSSD

```bash
sudo systemctl restart sssd
sudo systemctl enable sssd
```

### 7.10 Configurar Creación Automática de Directorios Home

```bash
sudo nano /etc/pam.d/common-session
```

**Añadir al final:**
```
session required pam_mkhomedir.so skel=/etc/skel/ umask=0077
```

Esto crea directorios home automáticamente en el primer inicio de sesión.

### 7.11 Probar Inicio de Sesión

#### Método 1: SSH (si está habilitado)

```bash
ssh alice@lab07.lan@localhost
# o si usas nombres cortos:
ssh alice@localhost
```

#### Método 2: GUI Login

1. Cerrar sesión actual
2. En la pantalla de login, clic en **"¿No está en la lista?"**
3. Introducir: `alice@lab07.lan`
4. Contraseña: `admin_21`
5. Debe iniciar sesión correctamente

#### Método 3: Switch user

```bash
su - alice@lab07.lan
```

### 7.12 Montar Carpetas Compartidas

#### Instalar utilidades CIFS

```bash
sudo apt install -y cifs-utils
```

#### Montaje manual

```bash
# Crear punto de montaje
sudo mkdir -p /mnt/public

# Montar recurso compartido
sudo mount -t cifs //192.168.100.1/Public /mnt/public \
  -o username=alice,domain=LAB07

# Listar contenido
ls -la /mnt/public/

# Desmontar
sudo umount /mnt/public
```

#### Montaje permanente con credenciales

1. **Crear archivo de credenciales:**
```bash
nano ~/.smbcredentials
```

**Contenido:**
```
username=alice
password=admin_21
domain=LAB07
```

2. **Proteger archivo:**
```bash
chmod 600 ~/.smbcredentials
```

3. **Añadir a /etc/fstab:**
```bash
sudo nano /etc/fstab
```

**Añadir línea:**
```
//192.168.100.1/Public  /mnt/public  cifs  credentials=/home/alice/.smbcredentials,_netdev  0  0
```

4. **Montar:**
```bash
sudo mount -a
```

### ✅ Cliente Ubuntu Completado

Has configurado exitosamente:
- ✅ Red configurada correctamente
- ✅ DNS apuntando al DC
- ✅ Paquetes instalados
- ✅ Cliente unido al dominio lab07.lan
- ✅ SSSD configurado
- ✅ Directorios home creados automáticamente
- ✅ Inicio de sesión funcionando
- ✅ Recursos compartidos accesibles

---

## 8. Configuración del Cliente Windows

**Estado:** ⏳ Pendiente de configuración

### 8.1 Requisitos Previos

- **OS:** Windows 11 Pro o Enterprise (Home NO puede unirse a dominios)
- **Red:** Conectividad con el DC
- **DNS:** Configurado para apuntar a 192.168.100.1

### 8.2 Configurar Red

#### Opción A: IP Estática (Recomendado)

1. Abrir **Configuración** → **Red e Internet** → **Ethernet/Wi-Fi**
2. Clic en **Editar** junto a Asignación de IP
3. Seleccionar **Manual**
4. Configurar:
   - **Dirección IP:** 192.168.100.X/25 (ejemplo: .10)
   - **Máscara de subred:** 255.255.255.128
   - **Puerta de enlace:** 172.30.20.1 (opcional)
   - **DNS preferido:** 192.168.100.1
   - **DNS alternativo:** (dejar vacío o 10.239.3.7)

#### Opción B: DHCP

Asegúrate de que el servidor DHCP proporcione:
- IP en el rango 192.168.100.0/25
- Servidor DNS: 192.168.100.1

### 8.3 Verificar Conectividad

Abrir **PowerShell** o **Símbolo del sistema**:

```cmd
:: Probar conectividad al DC
ping 192.168.100.1

:: Verificar resolución DNS
nslookup lab07.lan
nslookup ls07.lab07.lan
nslookup _ldap._tcp.lab07.lan
```

**Resultados esperados:**
- lab07.lan → 192.168.100.1
- ls07.lab07.lan → 192.168.100.1
- _ldap._tcp.lab07.lan → Registro SRV encontrado

### 8.4 Unir al Dominio

#### Método 1: Configuración (Windows 11)

1. Abrir **Configuración** → **Sistema** → **Acerca de**
2. Clic en **Dominio o grupo de trabajo**
3. En "Dominio o grupo de trabajo", clic en **Dominio**
4. Introducir nombre del dominio: `lab07.lan`
5. Clic en **Aceptar**
6. Introducir credenciales:
   - **Usuario:** Administrator o administrator@lab07.lan
   - **Contraseña:** Admin_21
7. Clic en **Aceptar**
8. Mensaje de bienvenida: "Bienvenido al dominio lab07.lan"
9. Clic en **Aceptar** y **Reiniciar**

#### Método 2: Propiedades del Sistema (Clásico)

1. Presionar **Win + Pause** o buscar "Propiedades del sistema"
2. Clic en **Cambiar configuración** junto al nombre del equipo
3. Clic en **Cambiar...**
4. Seleccionar botón **Dominio**
5. Introducir: `lab07.lan`
6. Clic en **Aceptar**
7. Introducir credenciales:
   - **Usuario:** Administrator
   - **Contraseña:** Admin_21
8. Mensaje de bienvenida aparece
9. Clic en **Aceptar** y reiniciar

### 8.5 Verificar Unión al Dominio

Después del reinicio:

1. **En la pantalla de login**, clic en **Otro usuario**
2. Introducir credenciales de dominio:
   - **Usuario:** alice o alice@lab07.lan o LAB07\alice
   - **Contraseña:** admin_21
3. Debe iniciar sesión correctamente

#### Verificar desde PowerShell

```powershell
# Comprobar dominio del equipo
(Get-WmiObject Win32_ComputerSystem).Domain

# Debe mostrar: lab07.lan

# Ver controlador de dominio
nltest /dclist:lab07.lan

# Debe mostrar: ls07.lab07.lan
```

### 8.6 Acceder a Carpetas Compartidas

#### Desde el Explorador de Archivos

1. Presionar **Win + E**
2. En la barra de direcciones, escribir: `\\ls07.lab07.lan`
3. Presionar **Enter**
4. Debe mostrar:
   - FinanceDocs (si el usuario está en Finance)
   - HRDocs (si el usuario está en HR_Staff)
   - Public (todos los usuarios del dominio)

#### Mapear unidad de red

1. Clic derecho en **Este equipo** → **Conectar a unidad de red**
2. Elegir letra de unidad (por ejemplo, Z:)
3. Introducir ruta: `\\ls07.lab07.lan\Public`
4. Marcar **"Conectar al iniciar sesión"**
5. Clic en **Finalizar**

### 8.7 Script de Logon Automático

Si has configurado el script de logon en el Sprint 3, las unidades se mapearán automáticamente:

- **Z:** → Public
- **H:** → HRDocs (si en grupo HR_Staff)
- **F:** → FinanceDocs (si en grupo Finance)

### 8.8 Solución de Problemas Windows

#### Error: "El dominio especificado no existe o no se puede contactar"

**Soluciones:**
- Verificar DNS está configurado a 192.168.100.1
- Probar: `nslookup lab07.lan`
- Hacer ping: `ping ls07.lab07.lan`
- Vaciar caché DNS: `ipconfig /flushdns`

#### Error: "La contraseña de red especificada no es correcta"

**Soluciones:**
- Verificar contraseña es `Admin_21` (A mayúscula)
- Probar usuario: `administrator@lab07.lan`
- Verificar Bloq Mayús está desactivado

#### Error: "La contraseña ha expirado"

**Solución:** En el DC, resetear contraseña:
```bash
sudo samba-tool user setpassword Administrator --newpassword='Admin_21'
sudo samba-tool user setexpiry Administrator --noexpiry
```

### ✅ Cliente Windows Completado

Una vez configurado:
- ✅ Windows Pro/Enterprise unido a lab07.lan
- ✅ Usuarios del dominio pueden iniciar sesión
- ✅ Recursos compartidos accesibles
- ✅ Resolución DNS funcionando
- ✅ Autenticación correcta

---

## 9. Referencia de Comandos

Ver el archivo completo: [REFERENCIA_RAPIDA.md](REFERENCIA_RAPIDA.md)

### 9.1 Comandos Más Usados

#### Gestión de Dominio

```bash
# Información del dominio
sudo samba-tool domain info 127.0.0.1

# Nivel del dominio
sudo samba-tool domain level show

# Política de contraseñas
sudo samba-tool domain passwordsettings show
```

#### Gestión de Usuarios

```bash
# Listar usuarios
sudo samba-tool user list

# Crear usuario
sudo samba-tool user create USUARIO PASSWORD

# Eliminar usuario
sudo samba-tool user delete USUARIO

# Resetear contraseña
sudo samba-tool user setpassword USUARIO --newpassword='NuevaPass123!'

# Mostrar detalles
sudo samba-tool user show USUARIO
```

#### Gestión de Grupos

```bash
# Listar grupos
sudo samba-tool group list

# Crear grupo
sudo samba-tool group add GRUPO

# Añadir miembros (separados por comas, sin espacios)
sudo samba-tool group addmembers GRUPO user1,user2,user3

# Listar miembros
sudo samba-tool group listmembers GRUPO
```

#### DNS y Kerberos

```bash
# Probar DNS
host -t A ls07.lab07.lan
host -t SRV _ldap._tcp.lab07.lan

# Obtener ticket Kerberos
kinit usuario@LAB07.LAN

# Listar tickets
klist

# Destruir tickets
kdestroy
```

#### Servicio Samba

```bash
# Estado
sudo systemctl status samba-ad-dc

# Reiniciar
sudo systemctl restart samba-ad-dc

# Recargar configuración
sudo systemctl reload samba-ad-dc

# Ver logs
sudo journalctl -u samba-ad-dc -f
```

---

## 10. Solución de Problemas

Ver el archivo completo: [SOLUCION_PROBLEMAS.md](SOLUCION_PROBLEMAS.md)

### 10.1 Problemas Comunes

#### DNS no resuelve

**Síntomas:**
- `host ls07.lab07.lan` falla
- No se puede unir clientes al dominio

**Soluciones:**
```bash
# Verificar servicio
sudo systemctl status samba-ad-dc

# Verificar puerto 53 está libre
sudo ss -tulnp | grep :53

# Verificar resolv.conf
cat /etc/resolv.conf
# Primera línea debe ser: nameserver 127.0.0.1

# Reiniciar Samba
sudo systemctl restart samba-ad-dc
```

#### Autenticación Kerberos falla

**Síntomas:**
- `kinit` falla
- Error "Cannot find KDC"

**Soluciones:**
```bash
# Verificar krb5.conf
cat /etc/krb5.conf

# Copiar configuración de Samba
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# Probar autenticación
kinit administrator@LAB07.LAN
```

#### Puerto 53 en uso

**Síntomas:**
- Samba no inicia
- Error: puerto 53 ya en uso

**Soluciones:**
```bash
# Ver qué usa el puerto
sudo ss -tulnp | grep :53

# Deshabilitar systemd-resolved
sudo systemctl disable --now systemd-resolved
sudo unlink /etc/resolv.conf

# Crear resolv.conf manual
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
```

#### Cliente no puede unirse

**Desde el cliente:**
```bash
# Verificar DNS
nslookup lab07.lan
# Debe resolver a 192.168.100.1

# Verificar SRV records
host -t SRV _ldap._tcp.lab07.lan

# Probar conectividad
ping ls07.lab07.lan
```

---

## 📊 Resumen del Proyecto

### Estado de Completado

| Componente | Estado | Notas |
|------------|--------|-------|
| **Servidor DC** | ✅ Completo | ls07.lab07.lan operativo |
| **DNS** | ✅ Completo | Resolviendo correctamente |
| **Kerberos** | ✅ Completo | Autenticación funcionando |
| **LDAP** | ✅ Completo | Directorio activo |
| **Usuarios** | ✅ Completo | 8 usuarios creados |
| **Grupos** | ✅ Completo | 5 grupos de seguridad |
| **OUs** | ✅ Completo | 3 unidades organizativas |
| **Compartidos** | ✅ Completo | 3 carpetas configuradas |
| **Cliente Ubuntu** | ✅ Completo | lc07 unido al dominio |
| **Cliente Windows** | ⏳ Pendiente | Por configurar |
| **Segundo DC** | ⏳ Opcional | LAB08 (si se requiere) |
| **Forest Trust** | ⏳ Opcional | LAB07 ↔ LAB08 |

### Puertos Activos

| Puerto | Servicio | Estado |
|--------|----------|--------|
| 53 | DNS | ✅ Activo |
| 88 | Kerberos | ✅ Activo |
| 389 | LDAP | ✅ Activo |
| 445 | SMB | ✅ Activo |
| 636 | LDAPS | ✅ Activo |
| 3268 | Global Catalog | ✅ Activo |

### Estructura del Dominio

```
LAB07.LAN
│
├── Servidor: ls07.lab07.lan (192.168.100.1)
│   ├── DNS: ✅ Operativo
│   ├── Kerberos: ✅ Operativo
│   ├── LDAP: ✅ Operativo
│   └── SMB: ✅ Operativo
│
├── Usuarios: 8
│   ├── alice, bob, charlie (Students)
│   ├── iosif, karl, lenin (IT_Admins)
│   ├── vladimir (HR_Staff)
│   └── techsupport (Tech_Support)
│
├── Grupos: 5
│   ├── IT_Admins
│   ├── HR_Staff
│   ├── Students
│   ├── Finance
│   └── Tech_Support
│
├── Compartidos: 3
│   ├── FinanceDocs (Finance)
│   ├── HRDocs (HR_Staff)
│   └── Public (Domain Users)
│
└── Clientes:
    ├── lc07 (Ubuntu Desktop) - ✅ Unido
    └── Windows Client - ⏳ Pendiente
```

---

## 📚 Referencias Adicionales

### Documentación Oficial
- [Samba Wiki - Active Directory](https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller)
- [Ubuntu Server Guide - Samba](https://ubuntu.com/server/docs/samba-active-directory)

### Herramientas
- **samba-tool:** Herramienta principal de gestión AD
- **testparm:** Validador de configuración de Samba
- **smbclient:** Cliente SMB/CIFS para pruebas
- **ldapsearch:** Herramienta de consultas LDAP
- **kinit/klist:** Herramientas de autenticación Kerberos
- **realm:** Utilidad de unión a dominios para Linux
- **sssd:** Daemon de servicios de seguridad del sistema

---

## 📝 Notas Finales

### Información del Proyecto
- **Nombre:** LAB07 - Samba 4 Active Directory
- **Versión:** 2.0
- **Fecha:** Febrero 2026
- **Autor:** Proyecto de laboratorio
- **Entorno:** Laboratorio/Pruebas
- **Tiempo Total:** ~24 horas (4 sprints)
- **Nivel:** Intermedio a Avanzado

### Lecciones Aprendidas

1. **DNS es crítico** - Sin DNS correcto, nada funciona
2. **systemd-resolved debe deshabilitarse** - Conflicto de puerto 53
3. **Permisos de dos capas** - Share + filesystem (el más restrictivo gana)
4. **Kerberos requiere tiempo sincronizado** - Diferencia < 5 minutos
5. **Las políticas de contraseña aplican a nivel de dominio** - No se pueden sobrescribir por usuario

### Próximos Pasos Recomendados

- [ ] Unir cliente Windows al dominio
- [ ] Configurar segundo DC (LAB08) - opcional
- [ ] Implementar GPOs avanzadas via RSAT
- [ ] Configurar backup automático
- [ ] Añadir monitoreo y alertas
- [ ] Implementar alta disponibilidad
- [ ] Integrar con servicios de email

---

**Fin de la Documentación Completa**

Para más información consulta:
- [Referencia Rápida](REFERENCIA_RAPIDA.md)
- [Solución de Problemas](SOLUCION_PROBLEMAS.md)
- [Configurar GitHub](CONFIGURAR_GITHUB.md)
