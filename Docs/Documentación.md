# 📖 LAB07 — Implementación de Active Directory con Samba 4

**Versión:** 2.0 | **Última actualización:** Febrero 2026  
**Entorno:** Ubuntu Server 24.04 LTS + Samba 4.19.5  
**Laboratorio:** LAB07

---

## 📋 Índice

1. [Descripción del proyecto](#1-descripción-del-proyecto)
2. [Infraestructura y arquitectura de red](#2-infraestructura-y-arquitectura-de-red)
3. [Sprint 1 — Configuración del controlador de dominio](#3-sprint-1--configuración-del-controlador-de-dominio)
4. [Sprint 2 — Usuarios, grupos y unidades organizativas](#4-sprint-2--usuarios-grupos-y-unidades-organizativas)
5. [Sprint 3 — Recursos compartidos y control de acceso](#5-sprint-3--recursos-compartidos-y-control-de-acceso)
6. [Sprint 4 — Trust entre dominios LAB07 ↔ LAB08](#6-sprint-4--trust-entre-dominios-lab07--lab08)
7. [Apéndice A — Integración del cliente Ubuntu Desktop](#7-apéndice-a--integración-del-cliente-ubuntu-desktop)
8. [Apéndice B — Integración del cliente Windows 11](#8-apéndice-b--integración-del-cliente-windows-11)
9. [Referencia de comandos](#9-referencia-de-comandos)
10. [Resolución de incidencias comunes](#10-resolución-de-incidencias-comunes)

---

## 1. Descripción del proyecto

### 1.1 ¿Qué implementa este laboratorio?

Este proyecto despliega un **controlador de dominio Active Directory** completo usando Samba 4 sobre Ubuntu Server 24.04. El objetivo es reproducir en un entorno de laboratorio la funcionalidad esencial que ofrece Windows Server AD DS, pero sobre una pila de software 100% libre.

### 1.2 Qué incluye la implementación

| Servicio | Estado |
|---|---|
| Controlador de dominio (lab07.lan) | ✅ Operativo |
| DNS interno con zonas directa e inversa | ✅ Operativo |
| Servidor Kerberos (KDC) | ✅ Operativo |
| Directorio LDAP | ✅ Operativo |
| Recursos compartidos SMB/CIFS | ✅ Operativo |
| Catálogo Global | ✅ Operativo |
| Cliente Ubuntu unido al dominio | ✅ Operativo |
| Cliente Windows unido al dominio | ⏳ Pendiente |
| Trust bidireccional con LAB08 | ⏳ Opcional |

### 1.3 Requisitos mínimos

| Recurso | Mínimo | Recomendado |
|---|---|---|
| CPU | 1 core | 2 cores |
| RAM | 1 GB | 4 GB |
| Disco | 20 GB | 40 GB |
| Red | 1 interfaz | 2 interfaces |

**Software necesario:** Ubuntu Server 24.04 LTS ISO, VirtualBox o VMware.

---

## 2. Infraestructura y arquitectura de red

### 2.1 Diagrama de red

```
                   Internet / Red Externa
                             │
                     Gateway: 172.30.20.1
                             │
               ┌─────────────┴─────────────┐
               │     Red puente (bridge)    │
               │      172.30.20.0/25        │
               └──────┬──────────┬──────────┘
                      │          │
                .54   │          │   .53
               ┌──────┴────┐ ┌───┴──────────┐
               │   ls07    │ │     lc07      │
               │  DC-LAB07 │ │ Cliente Ubuntu│
               └──────┬────┘ └───┬──────────┘
                      │          │
                  .1  │          │  .2
               ┌──────┴──────────┴──────────┐
               │       Red interna           │
               │      192.168.100.0/25       │
               └────────────────────────────┘
```

### 2.2 Tabla de equipos

| Equipo | Rol | IP Interna | IP Externa | SO |
|---|---|---|---|---|
| **ls07** | Controlador de Dominio | 192.168.100.1/25 | 172.30.20.54/25 | Ubuntu Server 24.04 |
| **lc07** | Cliente Linux | 192.168.100.2/25 | 172.30.20.53/25 | Ubuntu Desktop 24.04 |
| **wc-07** | Cliente Windows | Por asignar | — | Windows 11 Pro |

### 2.3 Parámetros del dominio

| Parámetro | Valor |
|---|---|
| **Nombre del dominio** | lab07.lan |
| **Realm Kerberos** | LAB07.LAN |
| **Nombre NetBIOS** | LAB07 |
| **FQDN del DC** | ls07.lab07.lan |
| **IP del DC (interna)** | 192.168.100.1 |
| **Reenviador DNS** | 10.239.3.7 |
| **Versión de Samba** | 4.19.5 |

### 2.4 Credenciales del laboratorio

```
Administrador del dominio:
  Usuario   → Administrator
  Contraseña → Admin_21
  UPN        → administrator@LAB07.LAN
  SAM        → LAB07\Administrator

Usuario local del sistema:
  Usuario   → administrador
  Contraseña → admin_21

Usuarios del dominio (contraseña común de laboratorio):
  alice, bob, charlie     → grupo Students
  iosif, karl, lenin      → grupo IT_Admins
  vladimir                → grupo HR_Staff
  techsupport             → grupo Tech_Support
  Contraseña de todos    → admin_21
```

> ⚠️ Las contraseñas del laboratorio no cumplen la política de seguridad real. En producción deben usarse contraseñas fuertes.

---

## 3. Sprint 1 — Configuración del controlador de dominio

**Duración estimada:** 6 horas  
**Objetivo:** Instalar Ubuntu Server 24.04, configurar la red y provisionar el dominio lab07.lan con Samba 4.

---

### 3.1 Preparación del sistema operativo

#### Paso 1 — Configurar el hostname

El nombre completo (FQDN) del servidor debe quedar fijado antes de instalar Samba:

```bash
sudo hostnamectl set-hostname ls07.lab07.lan
```

Comprobar que es correcto:

```bash
hostname        # → ls07
hostname -f     # → ls07.lab07.lan
```

#### Paso 2 — Actualizar el sistema

```bash
sudo apt update && sudo apt upgrade -y
```

Reiniciar si se actualizó el kernel:

```bash
sudo reboot
```

#### Paso 3 — Editar /etc/hosts

```bash
sudo nano /etc/hosts
```

El archivo debe contener:

```
127.0.0.1       localhost
192.168.100.1   ls07.lab07.lan ls07

# IPv6
::1             ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
```

Verificar resolución local:

```bash
ping -c 2 ls07.lab07.lan
```

---

### 3.2 Configuración de red con Netplan

#### Paso 1 — Identificar las interfaces

```bash
ip a
# Normalmente: enp0s3 = externa, enp0s8 = interna
```

#### Paso 2 — Editar la configuración Netplan

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

```yaml
network:
  version: 2
  ethernets:

    enp0s3:        # Interfaz EXTERNA (bridge hacia internet)
      dhcp4: no
      addresses:
        - 172.30.20.54/25
      routes:
        - to: default
          via: 172.30.20.1
      nameservers:
        addresses: [127.0.0.1, 10.239.3.7]
        search: [lab07.lan]

    enp0s8:        # Interfaz INTERNA (red del laboratorio)
      dhcp4: no
      addresses:
        - 192.168.100.1/25
      nameservers:
        addresses: [127.0.0.1]
        search: [lab07.lan]
```

> ⚠️ Reemplaza `enp0s3` / `enp0s8` por los nombres reales que muestre `ip a` en tu máquina.

#### Paso 3 — Aplicar y verificar

```bash
sudo netplan apply

# Comprobar IPs asignadas
ip a | grep inet

# Comprobar rutas
ip route

# Probar gateway
ping -c 2 172.30.20.1
```

---

### 3.3 Liberar el puerto 53 para Samba

Samba actúa como servidor DNS propio y necesita el puerto 53 libre. El servicio `systemd-resolved` lo ocupa por defecto.

```bash
# Detener y deshabilitar el servicio
sudo systemctl disable --now systemd-resolved

# Comprobar que está parado
sudo systemctl status systemd-resolved
# → debe mostrar: inactive (dead)

# Verificar que el puerto 53 está libre
sudo ss -tulnp | grep :53
# → debe estar vacío
```

#### Crear /etc/resolv.conf de forma manual

```bash
# Eliminar el enlace simbólico gestionado por systemd
sudo unlink /etc/resolv.conf

# Crear el archivo estático
sudo nano /etc/resolv.conf
```

```
nameserver 127.0.0.1
nameserver 10.239.3.7
nameserver 10.239.3.8
search lab07.lan
```

---

### 3.4 Instalación de Samba y dependencias

```bash
sudo apt install -y \
  acl attr samba samba-dsdb-modules samba-vfs-modules \
  winbind libpam-winbind libnss-winbind libpam-krb5 \
  krb5-config krb5-user dnsutils ldap-utils
```

Cuando el instalador pregunte por Kerberos, responder:

```
Realm por defecto:        LAB07.LAN
Servidores Kerberos:      ls07.lab07.lan
Servidor administrativo:  ls07.lab07.lan
```

#### Desactivar los servicios que no se usan en modo DC

```bash
sudo systemctl disable --now smbd nmbd winbind

# Verificar que están parados
sudo systemctl status smbd nmbd winbind
# → todos deben mostrar: inactive (dead)
```

---

### 3.5 Aprovisionamiento del dominio

#### Paso 1 — Eliminar la configuración por defecto de Samba

```bash
sudo rm -f /etc/samba/smb.conf
```

#### Paso 2 — Lanzar el aprovisionamiento interactivo

```bash
sudo samba-tool domain provision --use-rfc2307 --interactive
```

Respuestas al asistente:

| Pregunta | Respuesta |
|---|---|
| Realm | `LAB07.LAN` |
| Domain | `LAB07` |
| Server Role | `dc` |
| DNS backend | `SAMBA_INTERNAL` |
| DNS forwarder IP | `10.239.3.7` |
| Administrator password | `Admin_21` |
| Retype password | `Admin_21` |

Salida esperada al finalizar:

```
Server Role:           active directory domain controller
Hostname:              ls07
NetBIOS Domain:        LAB07
DNS Domain:            lab07.lan
DOMAIN SID:            S-1-5-21-XXXXXXXXXX
```

#### Paso 3 — Revisar el smb.conf generado

```bash
cat /etc/samba/smb.conf
```

Debe contener algo similar a:

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

---

### 3.6 Configurar Kerberos

El aprovisionamiento genera automáticamente el archivo de configuración de Kerberos. Solo hay que colocarlo en la ruta correcta:

```bash
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

cat /etc/krb5.conf
```

El contenido relevante debe ser:

```ini
[libdefaults]
    default_realm = LAB07.LAN
    dns_lookup_realm = false
    dns_lookup_kdc = true
```

---

### 3.7 Iniciar el servicio Samba AD DC

```bash
sudo systemctl unmask samba-ad-dc
sudo systemctl enable samba-ad-dc
sudo systemctl start samba-ad-dc

# Verificar estado
sudo systemctl status samba-ad-dc
```

Salida esperada:

```
● samba-ad-dc.service - Samba AD Daemon
     Active: active (running)
```

---

### 3.8 Verificación completa del Sprint 1

#### Nivel funcional del dominio

```bash
sudo samba-tool domain level show
```

```
Forest function level: (Windows) 2008 R2
Domain function level: (Windows) 2008 R2
```

#### Información del dominio

```bash
sudo samba-tool domain info 127.0.0.1
```

```
Forest           : lab07.lan
Domain           : lab07.lan
Netbios domain   : LAB07
DC name          : ls07.lab07.lan
DC netbios name  : LS07
Server site      : Default-First-Site-Name
```

#### Verificación de DNS

```bash
# Registro A del DC
host -t A ls07.lab07.lan
# → ls07.lab07.lan has address 192.168.100.1

# Registros SRV de LDAP
host -t SRV _ldap._tcp.lab07.lan
# → _ldap._tcp.lab07.lan has SRV record 0 100 389 ls07.lab07.lan.

# Registros SRV de Kerberos
host -t SRV _kerberos._tcp.lab07.lan
# → _kerberos._tcp.lab07.lan has SRV record 0 100 88 ls07.lab07.lan.

# Resolución inversa
host 192.168.100.1
# → 1.100.168.192.in-addr.arpa domain name pointer ls07.lab07.lan.
```

#### Verificación de Kerberos

```bash
kinit administrator@LAB07.LAN
# Contraseña: Admin_21

klist
# → Default principal: administrator@LAB07.LAN

kdestroy
```

#### Verificación de LDAP

```bash
kinit administrator@LAB07.LAN

ldapsearch -Y GSSAPI -H ldap://ls07.lab07.lan \
  -b "DC=lab07,DC=lan" "(objectClass=user)" cn sAMAccountName

kdestroy
```

#### Puertos en escucha

```bash
sudo ss -tulnp | grep -E ':(53|88|389|445|636|3268)'
```

Deben aparecer: 53, 88, 389, 445, 636 y 3268.

#### Usuarios iniciales del dominio

```bash
sudo samba-tool user list
# → Administrator, Guest, krbtgt
```

### ✅ Sprint 1 completado

---

## 4. Sprint 2 — Usuarios, grupos y unidades organizativas

**Duración estimada:** 6 horas  
**Objetivo:** Construir la estructura organizativa del dominio: OUs, grupos de seguridad, usuarios y política de contraseñas.

---

### 4.1 Conceptos previos

#### OUs vs Grupos — diferencias clave

| Aspecto | Unidad Organizativa (OU) | Grupo de Seguridad |
|---|---|---|
| Función principal | Organizar objetos, aplicar GPOs | Asignar permisos a recursos |
| Puede contener | Usuarios, grupos, equipos, otras OUs | Solo miembros (usuarios y grupos) |
| Asignable a recursos | ❌ No | ✅ Sí |
| Aplicar directivas | ✅ Sí | ❌ No |

#### Ámbitos de grupo

- **Global:** Miembros del mismo dominio. Opción recomendada en la mayoría de casos.
- **Domain Local:** Para asignar permisos dentro del dominio local.
- **Universal:** Para entornos con múltiples dominios o bosques.

---

### 4.2 Crear las unidades organizativas

```bash
sudo samba-tool ou create "OU=IT_Department,DC=lab07,DC=lan"
sudo samba-tool ou create "OU=HR_Department,DC=lab07,DC=lan"
sudo samba-tool ou create "OU=Students,DC=lab07,DC=lan"
```

Verificar:

```bash
sudo samba-tool ou list
```

```
OU=IT_Department,DC=lab07,DC=lan
OU=HR_Department,DC=lab07,DC=lan
OU=Students,DC=lab07,DC=lan
OU=Domain Controllers,DC=lab07,DC=lan
```

---

### 4.3 Crear los grupos de seguridad

```bash
sudo samba-tool group add IT_Admins
sudo samba-tool group add HR_Staff
sudo samba-tool group add Students
sudo samba-tool group add Finance
sudo samba-tool group add Tech_Support
```

Verificar:

```bash
sudo samba-tool group list | grep -E "(IT_Admins|HR_Staff|Students|Finance|Tech_Support)"
```

---

### 4.4 Crear los usuarios del dominio

#### Grupo Students

```bash
sudo samba-tool user create alice admin_21 \
  --given-name=Alice --surname=Wonderland

sudo samba-tool user create bob admin_21 \
  --given-name=Bob --surname=Marley

sudo samba-tool user create charlie admin_21 \
  --given-name=Charlie --surname=Sheen
```

#### Grupo IT_Admins

```bash
sudo samba-tool user create iosif admin_21 \
  --given-name=Stalin --surname=Thegreat

sudo samba-tool user create karl admin_21 \
  --given-name=Karl --surname=Marx

sudo samba-tool user create lenin admin_21 \
  --given-name=Vladimir --surname=Lenin
```

#### Grupo HR_Staff

```bash
sudo samba-tool user create vladimir admin_21 \
  --given-name=Vladimir --surname=Malakovsky
```

#### Soporte técnico

```bash
sudo samba-tool user create techsupport admin_21 \
  --given-name=Tech --surname=Support
```

Verificar todos los usuarios:

```bash
sudo samba-tool user list
```

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

---

### 4.5 Asignar usuarios a sus grupos

```bash
sudo samba-tool group addmembers Students alice,bob,charlie
sudo samba-tool group addmembers IT_Admins iosif,karl,lenin
sudo samba-tool group addmembers HR_Staff vladimir
sudo samba-tool group addmembers Tech_Support techsupport
```

> ⚠️ Los nombres de usuario deben separarse con coma sin espacios.

Verificar membresías:

```bash
sudo samba-tool group listmembers Students
# → alice, bob, charlie

sudo samba-tool group listmembers IT_Admins
# → iosif, karl, lenin

sudo samba-tool group listmembers HR_Staff
# → vladimir
```

Comprobar los grupos de un usuario concreto:

```bash
sudo samba-tool user show alice | grep memberOf
```

---

### 4.6 Diagrama de la estructura resultante

```
lab07.lan
│
├── Domain Controllers (OU)
│   └── LS07$
│
├── IT_Department (OU)
├── HR_Department (OU)
├── Students (OU)
│
└── Users (contenedor por defecto)
    ├── — Usuarios —
    │   ├── alice       → Students
    │   ├── bob         → Students
    │   ├── charlie     → Students
    │   ├── iosif       → IT_Admins
    │   ├── karl        → IT_Admins
    │   ├── lenin       → IT_Admins
    │   ├── vladimir    → HR_Staff
    │   └── techsupport → Tech_Support
    │
    └── — Grupos —
        ├── IT_Admins    (iosif, karl, lenin)
        ├── HR_Staff     (vladimir)
        ├── Students     (alice, bob, charlie)
        ├── Finance      (vacío)
        └── Tech_Support (techsupport)
```

---

### 4.7 Política de contraseñas del dominio

#### Ver la política actual

```bash
sudo samba-tool domain passwordsettings show
```

#### Aplicar los parámetros de seguridad

```bash
sudo samba-tool domain passwordsettings set --min-pwd-length=12
sudo samba-tool domain passwordsettings set --complexity=on
sudo samba-tool domain passwordsettings set --history-length=24
sudo samba-tool domain passwordsettings set --min-pwd-age=1
sudo samba-tool domain passwordsettings set --max-pwd-age=42
sudo samba-tool domain passwordsettings set --account-lockout-duration=30
sudo samba-tool domain passwordsettings set --account-lockout-threshold=0
sudo samba-tool domain passwordsettings set --reset-account-lockout-after=30
```

Verificar la configuración aplicada:

```bash
sudo samba-tool domain passwordsettings show
```

```
Password complexity: on
Password history length: 24
Minimum password length: 12
Minimum password age (days): 1
Maximum password age (days): 42
Account lockout duration (mins): 30
Account lockout threshold (attempts): 0
Reset account lockout after (mins): 30
```

#### Probar la política

```bash
# Contraseña débil → debe fallar
sudo samba-tool user create testgpo weak123
# ERROR: the password is too short...

# Contraseña robusta → debe funcionar
sudo samba-tool user create testgpo 'SecureP@ss2026!'

# Eliminar usuario de prueba
sudo samba-tool user delete testgpo
```

#### Evitar expiración del administrador

```bash
sudo samba-tool user setexpiry Administrator --noexpiry
```

---

### 4.8 GPOs predeterminadas del dominio

Samba crea automáticamente dos GPOs al provisionar el dominio:

```bash
# Ver todas las GPOs
sudo samba-tool gpo listall

# Ver el directorio SYSVOL donde se almacenan
sudo ls -la /var/lib/samba/sysvol/lab07.lan/Policies/

# Consultar a qué contenedor está vinculada cada GPO
sudo samba-tool gpo listcontainers "{31B2F340-016D-11D2-945F-00C04FB984F9}"
sudo samba-tool gpo listcontainers "{6AC1786C-016F-11D2-945F-00C04FB984F9}"
```

Las dos GPOs por defecto son:

- **Default Domain Policy** `{31B2F340...}` → vinculada al dominio completo. Controla la política de contraseñas.
- **Default Domain Controllers Policy** `{6AC1786C...}` → vinculada a la OU Domain Controllers.

> El orden de aplicación de GPOs sigue el modelo **LSDOU**: Local → Sitio → Dominio → OU. La que se aplica en último lugar tiene prioridad sobre las anteriores.

#### Probar autenticación de usuario

```bash
kinit alice@LAB07.LAN
# Contraseña: admin_21

klist
# → Default principal: alice@LAB07.LAN

kdestroy
```

### ✅ Sprint 2 completado

---

## 5. Sprint 3 — Recursos compartidos y control de acceso

**Duración estimada:** 6 horas  
**Objetivo:** Crear carpetas compartidas en red con permisos granulares mediante ACLs POSIX y backup automatizado con cron.

---

### 5.1 Dos capas de permisos en Samba

Samba aplica dos niveles de permisos simultáneamente. El más restrictivo de los dos es siempre el que prevalece:

1. **Permisos del recurso compartido** — se configuran en `smb.conf` (quién puede conectarse al share)
2. **Permisos del sistema de archivos** — POSIX + ACLs extendidas (qué puede hacer una vez dentro)

#### POSIX clásico vs ACLs extendidas

El modelo POSIX básico solo contempla tres actores (propietario, grupo, otros). Las ACLs permiten definir permisos para múltiples usuarios y grupos individualmente, incluyendo herencia automática para archivos nuevos.

---

### 5.2 Planificación de recursos compartidos

```
/srv/samba/
├── finance/   → R/W para grupo Finance (con sticky bit)
├── hr/        → R/W para grupo HR_Staff
└── public/    → Solo lectura para todos los usuarios del dominio
```

**Matriz de acceso:**

| Recurso | Finance | HR_Staff | Students | Domain Admins |
|---|---|---|---|---|
| **FinanceDocs** | R/W sin borrar ajeno | ❌ | ❌ | Control total |
| **HRDocs** | ❌ | R/W | ❌ | Control total |
| **Public** | Solo lectura | Solo lectura | Solo lectura | Control total |

---

### 5.3 Crear los directorios

```bash
sudo mkdir -p /srv/samba/{finance,hr,public}

# Propietario y grupo base
sudo chown -R root:"Domain Users" /srv/samba
sudo chmod -R 770 /srv/samba

# Verificar
ls -la /srv/samba/
```

Resultado esperado:

```
drwxrwx--- 2 root Domain Users ... finance
drwxrwx--- 2 root Domain Users ... hr
drwxrwx--- 2 root Domain Users ... public
```

---

### 5.4 Declarar los recursos en smb.conf

```bash
sudo nano /etc/samba/smb.conf
```

Añadir al final del archivo:

```ini
# ───────────────── Recursos compartidos ─────────────────

[FinanceDocs]
    comment = Documentos del departamento de Finanzas
    path = /srv/samba/finance
    valid users = @Finance, @"Domain Admins"
    read only = no
    browseable = yes
    create mask = 0660
    directory mask = 0770

[HRDocs]
    comment = Documentos de Recursos Humanos
    path = /srv/samba/hr
    valid users = @HR_Staff, @"Domain Admins"
    read only = no
    browseable = yes
    create mask = 0660
    directory mask = 0770

[Public]
    comment = Carpeta pública de solo lectura
    path = /srv/samba/public
    valid users = @"Domain Users"
    read only = yes
    browseable = yes
    write list = @"Domain Admins"
```

Verificar la sintaxis y recargar:

```bash
testparm
sudo systemctl reload samba-ad-dc
```

Listar los recursos desde el servidor para confirmar:

```bash
smbclient -L localhost -U administrator
# Contraseña: Admin_21
```

Salida esperada:

```
Sharename       Type      Comment
---------       ----      -------
FinanceDocs     Disk      Documentos del departamento de Finanzas
HRDocs          Disk      Documentos de Recursos Humanos
Public          Disk      Carpeta pública de solo lectura
sysvol          Disk
netlogon        Disk
```

---

### 5.5 Instalar y configurar ACLs extendidas

```bash
sudo apt install -y acl
```

#### FinanceDocs — R/W con sticky bit

El sticky bit impide que un usuario borre archivos que no le pertenecen, aunque tenga permisos de escritura en la carpeta.

```bash
sudo setfacl -m g:Finance:rwx /srv/samba/finance
sudo setfacl -d -m g:Finance:rwx /srv/samba/finance    # herencia para archivos nuevos
sudo chmod +t /srv/samba/finance                        # sticky bit

# Verificar (la T mayúscula indica sticky bit activo)
getfacl /srv/samba/finance
ls -la /srv/samba/
# drwxrwx--T ... finance
```

#### HRDocs — R/W estándar

```bash
sudo setfacl -m g:HR_Staff:rwx /srv/samba/hr
sudo setfacl -d -m g:HR_Staff:rwx /srv/samba/hr

getfacl /srv/samba/hr
```

#### Public — Solo lectura

```bash
sudo setfacl -m g:"Domain Users":rx /srv/samba/public
sudo setfacl -d -m g:"Domain Users":rx /srv/samba/public

getfacl /srv/samba/public
```

#### Revisar las tres ACLs de un vistazo

```bash
for dir in finance hr public; do
    echo "━━━ /srv/samba/$dir ━━━"
    getfacl /srv/samba/$dir
    echo
done
```

---

### 5.6 Probar el acceso desde el servidor

```bash
kinit administrator@LAB07.LAN

# Crear archivos de prueba en cada recurso
sudo -u administrator touch /srv/samba/finance/prueba_finance.txt
sudo -u administrator touch /srv/samba/hr/prueba_hr.txt
sudo -u administrator touch /srv/samba/public/prueba_public.txt

# Comprobar
ls -la /srv/samba/finance/
ls -la /srv/samba/hr/
ls -la /srv/samba/public/

# Conectar vía SMB
smbclient //ls07.lab07.lan/FinanceDocs -U administrator
# smb: \> ls
# smb: \> exit

kdestroy
```

---

### 5.7 Rutas UNC para los clientes

Los clientes accederán a los recursos con estas rutas:

```
\\ls07.lab07.lan\FinanceDocs
\\ls07.lab07.lan\HRDocs
\\ls07.lab07.lan\Public
```

---

### 5.8 Script de inicio de sesión para clientes Windows

#### Crear el script de mapeo de unidades

```bash
sudo mkdir -p /var/lib/samba/sysvol/lab07.lan/scripts
sudo nano /var/lib/samba/sysvol/lab07.lan/scripts/mapdrives.bat
```

```batch
@echo off
REM Mapeo automático de unidades de red — LAB07
net use Z: \\ls07.lab07.lan\Public     /persistent:yes >nul 2>&1
net use H: \\ls07.lab07.lan\HRDocs    /persistent:yes >nul 2>&1
net use F: \\ls07.lab07.lan\FinanceDocs /persistent:yes >nul 2>&1
exit
```

```bash
sudo chmod 755 /var/lib/samba/sysvol/lab07.lan/scripts/mapdrives.bat
```

#### Asignar el script a un usuario

```bash
sudo ldbmodify -H /var/lib/samba/private/sam.ldb <<EOF
dn: CN=Alice Wonderland,CN=Users,DC=lab07,DC=lan
changetype: modify
replace: scriptPath
scriptPath: mapdrives.bat
EOF
```

Verificar:

```bash
sudo samba-tool user show alice | grep scriptPath
# → scriptPath: mapdrives.bat
```

#### Asignar el script a todos los usuarios del dominio

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

---

### 5.9 Script de montaje automático para clientes Linux

```bash
sudo mkdir -p /var/lib/samba/netlogon/linux
sudo nano /var/lib/samba/netlogon/linux/mount-shares.sh
```

```bash
#!/bin/bash
# ─────────────────────────────────────────────────────────
# Montaje automático de recursos compartidos — LAB07
# Se invoca mediante PAM al iniciar sesión en el dominio
# ─────────────────────────────────────────────────────────

USER=$PAM_USER
DOMAIN="LAB07"

mkdir -p ~/Shared/{Public,HRDocs,FinanceDocs} 2>/dev/null

# Public — accesible para todos
if ! mountpoint -q ~/Shared/Public; then
    mount -t cifs //ls07.lab07.lan/Public ~/Shared/Public \
      -o username=$USER,domain=$DOMAIN,uid=$(id -u),gid=$(id -g),_netdev 2>/dev/null
fi

# HRDocs — solo para miembros de HR_Staff
if groups | grep -q "HR_Staff"; then
    if ! mountpoint -q ~/Shared/HRDocs; then
        mount -t cifs //ls07.lab07.lan/HRDocs ~/Shared/HRDocs \
          -o username=$USER,domain=$DOMAIN,uid=$(id -u),gid=$(id -g),_netdev 2>/dev/null
    fi
fi

# FinanceDocs — solo para miembros de Finance
if groups | grep -q "Finance"; then
    if ! mountpoint -q ~/Shared/FinanceDocs; then
        mount -t cifs //ls07.lab07.lan/FinanceDocs ~/Shared/FinanceDocs \
          -o username=$USER,domain=$DOMAIN,uid=$(id -u),gid=$(id -g),_netdev 2>/dev/null
    fi
fi

exit 0
```

```bash
sudo chmod 755 /var/lib/samba/netlogon/linux/mount-shares.sh
```

Para activarlo en los clientes Linux, ver el Apéndice A.

---

### 5.10 Backup automático con cron

#### Crear el script de backup

```bash
sudo nano /usr/local/bin/backup-lab07.sh
```

```bash
#!/bin/bash
# ─────────────────────────────────────────────────────────
# Backup automático del dominio Samba — LAB07
# Ejecutado por cron cada noche a las 02:00
# ─────────────────────────────────────────────────────────

FECHA=$(date +%Y%m%d_%H%M%S)
DESTINO="/var/backups/samba-lab07"
LOG="$DESTINO/backup.log"

mkdir -p "$DESTINO"
echo "[$FECHA] Iniciando backup del dominio LAB07..." >> "$LOG"

# 1. Backup de la base de datos AD
samba-tool domain backup online \
  --targetdir="$DESTINO" \
  --server=ls07.lab07.lan \
  -U administrator%Admin_21 >> "$LOG" 2>&1

# 2. Backup del SYSVOL (GPOs y scripts de logon)
tar -czf "$DESTINO/sysvol_$FECHA.tar.gz" \
  /var/lib/samba/sysvol/ >> "$LOG" 2>&1

# 3. Rotación: conservar solo los últimos 7 días
find "$DESTINO" -name "*.tar.gz"  -mtime +7 -delete
find "$DESTINO" -name "*.tar.bz2" -mtime +7 -delete

echo "[$FECHA] Backup finalizado." >> "$LOG"
```

```bash
sudo chmod +x /usr/local/bin/backup-lab07.sh
```

#### Programar la ejecución con cron

```bash
sudo crontab -e
```

Añadir la línea:

```
0 2 * * * /usr/local/bin/backup-lab07.sh
```

Ejecutar manualmente para verificar que funciona:

```bash
sudo /usr/local/bin/backup-lab07.sh
ls -lh /var/backups/samba-lab07/
cat /var/backups/samba-lab07/backup.log
```

### ✅ Sprint 3 completado

---

## 6. Sprint 4 — Trust entre dominios LAB07 ↔ LAB08

**Duración estimada:** 6 horas  
**Objetivo:** Crear un segundo controlador de dominio y establecer una relación de confianza bidireccional de bosque.

> ⚠️ Este sprint es **opcional** y requiere un segundo servidor físico o virtual.

---

### 6.1 Qué es un forest trust y para qué sirve

Un trust de bosque permite que los usuarios de un dominio accedan a recursos del otro dominio sin necesidad de tener cuentas duplicadas. Con trust bidireccional, la confianza funciona en ambos sentidos.

| Tipo | Ámbito | Dirección | Uso típico |
|---|---|---|---|
| **Forest Trust** | Bosques completos | Bidireccional | Integración entre organizaciones |
| **External Trust** | Dominio a dominio | Uni o bidireccional | Acceso puntual y limitado |

---

### 6.2 Parámetros del segundo dominio (LAB08)

| Parámetro | Valor |
|---|---|
| Hostname | ls08.lab08.lan |
| Dominio | lab08.lan |
| Realm | LAB08.LAN |
| NetBIOS | LAB08 |
| IP interna | 192.168.100.3/25 |
| DNS secundario | 192.168.100.1 (apunta a LAB07) |

---

### 6.3 Resumen del proceso

> Sigue los pasos del Sprint 1 en el segundo servidor, sustituyendo los valores de LAB07 por los de LAB08. Después:

**En LAB07 (ls07) — configurar reenvío DNS hacia LAB08:**

```bash
sudo samba-tool dns zonecreate ls07.lab07.lan lab08.lan \
  -U administrator%Admin_21

sudo samba-tool dns add ls07.lab07.lan lab08.lan \
  @ NS ls08.lab08.lan -U administrator%Admin_21

sudo samba-tool dns add ls07.lab07.lan lab08.lan \
  ls08 A 192.168.100.3 -U administrator%Admin_21
```

**En LAB08 (ls08) — configurar reenvío DNS hacia LAB07:**

```bash
sudo samba-tool dns zonecreate ls08.lab08.lan lab07.lan \
  -U administrator%Admin_21

sudo samba-tool dns add ls08.lab08.lan lab07.lan \
  @ NS ls07.lab07.lan -U administrator%Admin_21

sudo samba-tool dns add ls08.lab08.lan lab07.lan \
  ls07 A 192.168.100.1 -U administrator%Admin_21
```

**Crear el trust bidireccional desde LAB07:**

```bash
sudo samba-tool domain trust create lab08.lan \
  --type=forest \
  --direction=both \
  -U "LAB07\administrator"%"Admin_21" \
  --remote-dc=ls08.lab08.lan
```

**Validar el trust desde ambos lados:**

```bash
# Desde LAB07
sudo samba-tool domain trust validate lab08.lan \
  -U "LAB07\administrator"%"Admin_21"

# Desde LAB08
sudo samba-tool domain trust validate lab07.lan \
  -U "LAB08\administrator"%"Admin_21"
```

**Probar autenticación cruzada:**

```bash
# Desde LAB07, obtener ticket de usuario de LAB08
kinit usuario@LAB08.LAN
klist
```

---

## 7. Apéndice A — Integración del cliente Ubuntu Desktop

**Máquina:** lc07 | Ubuntu Desktop 24.04 | IP: 192.168.100.2/25

---

### A.1 Configurar la red del cliente

El cliente debe resolver `lab07.lan` a través del DC. Sin DNS correcto, la unión al dominio no es posible.

**Opción A — Interfaz gráfica (Ubuntu Desktop):**

1. Abrir **Configuración → Red**
2. Editar la conexión activa → pestaña **IPv4**
3. Modo: **Manual**
4. Dirección: `192.168.100.2`, Máscara: `255.255.255.128`
5. DNS: `192.168.100.1`
6. Dominios de búsqueda: `lab07.lan`
7. Aplicar y reconectar

**Opción B — Netplan (terminal):**

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.100.2/25
      nameservers:
        addresses: [192.168.100.1]
        search: [lab07.lan]
```

```bash
sudo netplan apply
```

Verificar la conectividad:

```bash
nslookup lab07.lan
nslookup ls07.lab07.lan
host -t SRV _ldap._tcp.lab07.lan
ping -c 4 192.168.100.1
```

---

### A.2 Establecer el hostname del cliente

```bash
sudo hostnamectl set-hostname lc07
hostname      # → lc07
hostname -f   # → lc07
```

---

### A.3 Sincronizar el reloj con el DC

Kerberos exige que la diferencia horaria entre cliente y servidor sea inferior a 5 minutos.

```bash
sudo apt install -y chrony
sudo nano /etc/chrony/chrony.conf
```

Añadir o sustituir la línea del servidor NTP:

```
server 192.168.100.1 iburst prefer
```

```bash
sudo systemctl restart chrony
chronyc tracking
```

---

### A.4 Instalar los paquetes necesarios

```bash
sudo apt update
sudo apt install -y realmd sssd sssd-tools libnss-sss libpam-sss \
  adcli samba-common-bin packagekit krb5-user
```

Al preguntar por Kerberos:

```
Realm:                 LAB07.LAN
Kerberos servers:      ls07.lab07.lan
Administrative server: ls07.lab07.lan
```

---

### A.5 Descubrir y unirse al dominio

```bash
# Descubrir el dominio (debe detectar active-directory)
sudo realm discover lab07.lan
```

```
lab07.lan
  type: kerberos
  realm-name: LAB07.LAN
  domain-name: lab07.lan
  configured: no
  server-software: active-directory
  client-software: sssd
```

Unirse:

```bash
sudo realm join --verbose --user=administrator lab07.lan
# Contraseña: Admin_21
```

Salida esperada al finalizar:

```
* Successfully enrolled machine in realm
```

---

### A.6 Verificar la unión

```bash
sudo realm list
```

```
lab07.lan
  type: kerberos
  realm-name: LAB07.LAN
  domain-name: lab07.lan
  configured: kerberos-member
  login-formats: %U@lab07.lan
  login-policy: allow-realm-logins
```

Comprobar que el equipo aparece en el directorio activo (desde el servidor):

```bash
sudo samba-tool computer list
# → LC07$
```

---

### A.7 Ajustar la configuración de SSSD

```bash
sudo nano /etc/sssd/sssd.conf
```

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

Para permitir iniciar sesión con nombre corto (`alice` en lugar de `alice@lab07.lan`):

```ini
use_fully_qualified_names = False
fallback_homedir = /home/%u
```

```bash
sudo systemctl restart sssd
sudo systemctl enable sssd
```

---

### A.8 Creación automática del directorio home

```bash
sudo nano /etc/pam.d/common-session
```

Añadir al final:

```
session required pam_mkhomedir.so skel=/etc/skel/ umask=0077
```

---

### A.9 Probar el inicio de sesión

```bash
# Verificar que el usuario es visible
id alice@lab07.lan
getent passwd alice@lab07.lan

# Cambiar a usuario de dominio
su - alice@lab07.lan

# Inicio de sesión gráfico: introducir alice@lab07.lan en la pantalla de login
```

---

### A.10 Montar recursos compartidos desde el cliente

#### Instalación de utilidades CIFS

```bash
sudo apt install -y cifs-utils
```

#### Montaje manual puntual

```bash
sudo mkdir -p /mnt/public
sudo mount -t cifs //192.168.100.1/Public /mnt/public \
  -o username=alice,domain=LAB07
ls -la /mnt/public/
sudo umount /mnt/public
```

#### Montaje permanente en /etc/fstab

Crear archivo de credenciales:

```bash
nano ~/.smbcredentials
```

```
username=alice
password=admin_21
domain=LAB07
```

```bash
chmod 600 ~/.smbcredentials
```

Añadir en `/etc/fstab`:

```
//192.168.100.1/Public  /mnt/public  cifs  credentials=/home/alice/.smbcredentials,_netdev  0  0
```

```bash
sudo mount -a
```

#### Activar el script de montaje PAM (del Sprint 3)

Copiar el script desde el servidor y configurar PAM:

```bash
sudo scp administrador@ls07.lab07.lan:/var/lib/samba/netlogon/linux/mount-shares.sh \
  /usr/local/bin/
sudo chmod 755 /usr/local/bin/mount-shares.sh

sudo nano /etc/pam.d/common-session
# Añadir al final:
# session optional pam_exec.so /usr/local/bin/mount-shares.sh
```

### ✅ Apéndice A completado

---

## 8. Apéndice B — Integración del cliente Windows 11

> ⚠️ Windows 11 **Home** no permite unirse a dominios. Es obligatorio usar la edición **Pro** o **Enterprise**.

---

### B.1 Configurar la red en Windows

**Panel de control → Centro de redes → Cambiar configuración del adaptador:**

1. Clic derecho en el adaptador → **Propiedades**
2. Seleccionar **Protocolo de Internet versión 4 (TCP/IPv4)** → **Propiedades**
3. Configurar:
   - IP: `192.168.100.X` (X = número libre en la subred /25)
   - Máscara: `255.255.255.128`
   - Puerta de enlace: `172.30.20.1`
   - **DNS preferido: `192.168.100.1`** ← fundamental que apunte al DC

Verificar desde PowerShell:

```powershell
nslookup lab07.lan
nslookup ls07.lab07.lan
nslookup _ldap._tcp.lab07.lan
```

Los tres deben resolver correctamente antes de continuar.

---

### B.2 Sincronizar la hora con el DC

```powershell
w32tm /config /manualpeerlist:192.168.100.1 /syncfromflags:manual /reliable:YES /update
net stop w32tm && net start w32tm
w32tm /resync
```

---

### B.3 Unirse al dominio

**Método 1 — Configuración (Windows 11):**

1. **Configuración → Sistema → Acerca de**
2. **Dominio o grupo de trabajo** → clic en **Dominio**
3. Introducir: `lab07.lan`
4. Credenciales: `Administrator` / `Admin_21`
5. Mensaje de bienvenida → **Aceptar** → **Reiniciar**

**Método 2 — Propiedades del sistema (clásico):**

1. **Win + Pause** → **Cambiar configuración**
2. **Cambiar...** → seleccionar **Dominio** → escribir `lab07.lan`
3. Credenciales: `Administrator` / `Admin_21`
4. Reiniciar cuando se indique

**Método 3 — PowerShell (como Administrador):**

```powershell
Add-Computer -DomainName "lab07.lan" `
  -Credential (Get-Credential "LAB07\administrator") `
  -Restart -Force
```

---

### B.4 Verificar la unión desde el servidor

```bash
sudo samba-tool computer list
# → el nombre del equipo Windows debe aparecer en la lista
```

Desde el propio Windows (tras reiniciar):

```powershell
(Get-WmiObject Win32_ComputerSystem).Domain
# → lab07.lan

nltest /dclist:lab07.lan
# → ls07.lab07.lan
```

---

### B.5 Iniciar sesión con cuenta de dominio

En la pantalla de inicio de sesión, seleccionar **Otro usuario** e introducir:

- `LAB07\alice` — o —
- `alice@lab07.lan`
- Contraseña: `admin_21`

---

### B.6 Acceder a los recursos compartidos

**Desde el Explorador de archivos:**

1. En la barra de direcciones escribir: `\\ls07.lab07.lan`
2. Se mostrarán los recursos disponibles según el grupo del usuario

**Mapear unidad de red:**

1. Clic derecho en **Este equipo → Conectar a unidad de red**
2. Letra: `Z:`
3. Carpeta: `\\ls07.lab07.lan\Public`
4. Activar **"Conectar al iniciar sesión"**

Si se configuró el script `mapdrives.bat` en el Sprint 3, las unidades se mapean automáticamente al iniciar sesión.

---

### B.7 Instalar RSAT para administración remota

Las herramientas de Administración Remota del Servidor permiten gestionar el AD desde Windows con interfaz gráfica.

```powershell
# Herramientas de Directorio Activo
Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online

# Usuarios y equipos de AD (consola MMC clásica)
Add-WindowsCapability -Name Rsat.ActiveDirectory.DomainServices.Tools~~~~0.0.1.0 -Online
```

---

### B.8 Resolución de problemas frecuentes en Windows

#### "El dominio especificado no existe o no se puede contactar"

```cmd
ipconfig /flushdns
nslookup lab07.lan
ping ls07.lab07.lan
```

Verificar que el DNS apunta a `192.168.100.1`.

#### "La contraseña de red no es correcta"

- Confirmar que la contraseña es `Admin_21` (A mayúscula, guion bajo)
- Probar con `administrator@lab07.lan` como usuario
- Comprobar que Bloq Mayús está desactivado

#### "La contraseña ha expirado"

Desde el servidor, restablecer la contraseña y desactivar expiración:

```bash
sudo samba-tool user setpassword Administrator --newpassword='Admin_21'
sudo samba-tool user setexpiry Administrator --noexpiry
```

### ✅ Apéndice B completado

---

## 9. Referencia de comandos

### Dominio

```bash
sudo samba-tool domain info 127.0.0.1          # Estado del dominio
sudo samba-tool domain level show              # Nivel funcional
sudo samba-tool domain passwordsettings show   # Política de contraseñas
```

### Usuarios

```bash
sudo samba-tool user list                      # Listar todos los usuarios
sudo samba-tool user create USUARIO PASS       # Crear usuario
sudo samba-tool user delete USUARIO            # Eliminar usuario
sudo samba-tool user setpassword USUARIO --newpassword='NUEVA'  # Resetear contraseña
sudo samba-tool user show USUARIO              # Ver detalles del usuario
sudo samba-tool user setexpiry USUARIO --noexpiry               # Sin expiración
```

### Grupos

```bash
sudo samba-tool group list                     # Listar grupos
sudo samba-tool group add GRUPO                # Crear grupo
sudo samba-tool group addmembers GRUPO u1,u2   # Añadir miembros
sudo samba-tool group listmembers GRUPO        # Ver miembros
sudo samba-tool group removemembers GRUPO u1   # Eliminar miembro
```

### DNS y Kerberos

```bash
host -t A ls07.lab07.lan                       # Resolución de nombre
host -t SRV _ldap._tcp.lab07.lan               # Registro SRV de LDAP
host -t SRV _kerberos._tcp.lab07.lan           # Registro SRV de Kerberos
kinit usuario@LAB07.LAN                        # Obtener ticket
klist                                          # Ver tickets activos
kdestroy                                       # Destruir tickets
```

### Servicio Samba

```bash
sudo systemctl status samba-ad-dc              # Estado del servicio
sudo systemctl restart samba-ad-dc             # Reiniciar
sudo systemctl reload samba-ad-dc              # Recargar smb.conf sin cortar conexiones
sudo journalctl -u samba-ad-dc -f              # Seguir los logs en tiempo real
testparm                                       # Validar sintaxis de smb.conf
```

### ACLs y permisos

```bash
getfacl /ruta/al/directorio                    # Ver ACLs
setfacl -m g:GRUPO:rwx /ruta                   # Añadir ACL
setfacl -d -m g:GRUPO:rwx /ruta               # ACL por defecto (herencia)
setfacl -x g:GRUPO /ruta                       # Eliminar ACL
chmod +t /ruta                                 # Activar sticky bit
```

### SMB

```bash
smbclient -L localhost -U administrator        # Listar recursos
smbclient //ls07.lab07.lan/RECURSO -U usuario  # Conectar a un recurso
```

---

## 10. Resolución de incidencias comunes

### DNS no resuelve

**Síntomas:** `host ls07.lab07.lan` falla; los clientes no pueden unirse al dominio.

```bash
sudo systemctl status samba-ad-dc
sudo ss -tulnp | grep :53        # ¿Samba escucha en el 53?
cat /etc/resolv.conf             # Primera línea: nameserver 127.0.0.1
sudo systemctl restart samba-ad-dc
```

### Puerto 53 ocupado

**Síntomas:** Samba no arranca; mensaje "puerto 53 ya en uso".

```bash
sudo ss -tulnp | grep :53
sudo systemctl disable --now systemd-resolved
sudo unlink /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
sudo systemctl restart samba-ad-dc
```

### Kerberos falla al autenticar

**Síntomas:** `kinit` devuelve "Cannot find KDC".

```bash
cat /etc/krb5.conf
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
kinit administrator@LAB07.LAN
```

### El cliente no puede unirse al dominio

**Desde el cliente:**

```bash
nslookup lab07.lan               # ¿Resuelve a 192.168.100.1?
host -t SRV _ldap._tcp.lab07.lan # ¿Hay registros SRV?
ping ls07.lab07.lan              # ¿Hay conectividad?
```

Si hay desfase horario, sincronizar con chrony antes de reintentar.

### SSSD no autentifica a usuarios del dominio

```bash
sudo systemctl status sssd
sudo journalctl -u sssd -f

# Forzar la actualización de la caché
sudo sss_cache -E
sudo systemctl restart sssd
```

---

## 📊 Estado del proyecto

| Componente | Estado |
|---|---|
| Controlador de dominio ls07 | ✅ Operativo |
| DNS (zonas directa e inversa) | ✅ Operativo |
| Kerberos (KDC) | ✅ Operativo |
| Directorio LDAP | ✅ Operativo |
| 8 usuarios del dominio | ✅ Configurado |
| 5 grupos de seguridad | ✅ Configurado |
| 3 unidades organizativas | ✅ Configurado |
| Política de contraseñas | ✅ Configurado |
| 3 recursos compartidos + ACLs | ✅ Configurado |
| Backup automático con cron | ✅ Configurado |
| Cliente Ubuntu lc07 | ✅ Unido al dominio |
| Cliente Windows wc-07 | ⏳ Pendiente |
| Trust LAB07 ↔ LAB08 | ⏳ Opcional |

---

## 📚 Referencias

- [Samba Wiki — AD DC HOWTO](https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller)
- [Ubuntu Server Guide — Samba](https://ubuntu.com/server/docs/samba-active-directory)
- [SSSD Documentation](https://sssd.io/)
- [Realmd](https://www.freedesktop.org/software/realmd/)
- [Active Directory Overview — Microsoft](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)

---

**Proyecto:** LAB07 — Samba 4 Active Directory  
**Entorno:** Laboratorio académico  
**Tiempo total estimado:** ~24 horas (3 sprints + apéndices)  
**Nivel:** Intermedio
