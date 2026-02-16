# ⚡ Referencia Rápida - LAB07

Comandos más usados para gestión diaria del dominio lab07.lan

## 🎯 Información Básica

| Parámetro | Valor |
|-----------|-------|
| **Dominio** | lab07.lan |
| **Realm** | LAB07.LAN |
| **DC** | ls07.lab07.lan |
| **IP DC** | 192.168.100.1 |
| **Admin Password** | Admin_21 |
| **User Password** | admin_21 |

## 🔧 Gestión del Dominio

```bash
# Ver información del dominio
sudo samba-tool domain info 127.0.0.1

# Ver nivel funcional del dominio
sudo samba-tool domain level show

# Ver política de contraseñas
sudo samba-tool domain passwordsettings show

# Cambiar longitud mínima de contraseña
sudo samba-tool domain passwordsettings set --min-pwd-length=12

# Habilitar complejidad de contraseñas
sudo samba-tool domain passwordsettings set --complexity=on
```

## 👤 Gestión de Usuarios

```bash
# LISTAR usuarios
sudo samba-tool user list

# CREAR usuario
sudo samba-tool user create USUARIO PASSWORD \
  --given-name="Nombre" --surname="Apellido"

# ELIMINAR usuario
sudo samba-tool user delete USUARIO

# RESETEAR contraseña
sudo samba-tool user setpassword USUARIO --newpassword='NuevaPass123!'

# Deshabilitar expiración de contraseña
sudo samba-tool user setexpiry USUARIO --noexpiry

# MOSTRAR detalles del usuario
sudo samba-tool user show USUARIO

# HABILITAR usuario
sudo samba-tool user enable USUARIO

# DESHABILITAR usuario
sudo samba-tool user disable USUARIO
```

## 👥 Gestión de Grupos

```bash
# LISTAR grupos
sudo samba-tool group list

# CREAR grupo
sudo samba-tool group add NOMBREGRUPO

# ELIMINAR grupo
sudo samba-tool group delete NOMBREGRUPO

# AÑADIR miembros (separados por comas, SIN espacios)
sudo samba-tool group addmembers GRUPO user1,user2,user3

# QUITAR miembros
sudo samba-tool group removemembers GRUPO usuario

# LISTAR miembros del grupo
sudo samba-tool group listmembers NOMBREGRUPO

# MOSTRAR detalles del grupo
sudo samba-tool group show NOMBREGRUPO
```

## 🏢 Gestión de OUs

```bash
# LISTAR OUs
sudo samba-tool ou list

# CREAR OU
sudo samba-tool ou create "OU=NombreOU,DC=lab07,DC=lan"

# ELIMINAR OU (debe estar vacía)
sudo samba-tool ou delete "OU=NombreOU,DC=lab07,DC=lan"

# Crear usuario en una OU específica
sudo samba-tool user create usuario password \
  --userou="OU=IT_Department,DC=lab07,DC=lan"
```

## 💻 Gestión de Computadoras

```bash
# LISTAR computadoras
sudo samba-tool computer list

# ELIMINAR computadora
sudo samba-tool computer delete NOMBREPC

# MOSTRAR detalles de computadora
sudo samba-tool computer show NOMBREPC
```

## 🌐 Verificación DNS

```bash
# Registro A del DC
host -t A ls07.lab07.lan
# Esperado: ls07.lab07.lan has address 192.168.100.1

# Registros SRV de LDAP
host -t SRV _ldap._tcp.lab07.lan
# Esperado: _ldap._tcp.lab07.lan has SRV record 0 100 389 ls07.lab07.lan.

# Registros SRV de Kerberos
host -t SRV _kerberos._tcp.lab07.lan
# Esperado: _kerberos._tcp.lab07.lan has SRV record 0 100 88 ls07.lab07.lan.

# Resolución inversa
host 192.168.100.1
# Esperado: 1.100.168.192.in-addr.arpa domain name pointer ls07.lab07.lan.

# Usando nslookup
nslookup ls07.lab07.lan
nslookup lab07.lan
```

## 🔐 Autenticación Kerberos

```bash
# OBTENER ticket de autenticación
kinit USUARIO@LAB07.LAN
# Ejemplo: kinit administrator@LAB07.LAN

# LISTAR tickets activos
klist

# DESTRUIR tickets
kdestroy

# Probar autenticación de usuario específico
kinit alice@LAB07.LAN
# Password: admin_21
```

## 📂 Consultas LDAP

```bash
# Autenticar primero con Kerberos
kinit administrator@LAB07.LAN

# Buscar USUARIOS
ldapsearch -Y GSSAPI -H ldap://ls07.lab07.lan \
  -b "DC=lab07,DC=lan" "(objectClass=user)" cn sAMAccountName

# Buscar GRUPOS
ldapsearch -Y GSSAPI -H ldap://ls07.lab07.lan \
  -b "DC=lab07,DC=lan" "(objectClass=group)" cn

# Buscar OUs
ldapsearch -Y GSSAPI -H ldap://ls07.lab07.lan \
  -b "DC=lab07,DC=lan" "(objectClass=organizationalUnit)" dn

# Limpiar tickets
kdestroy
```

## 📁 Acceso a Recursos Compartidos

```bash
# LISTAR recursos compartidos en servidor
smbclient -L SERVIDOR -U USUARIO
# Ejemplo: smbclient -L ls07.lab07.lan -U administrator

# CONECTAR a recurso compartido
smbclient //SERVIDOR/COMPARTIDO -U USUARIO
# Ejemplo: smbclient //ls07.lab07.lan/Public -U alice

# MONTAR recurso compartido (Linux)
sudo mount -t cifs //SERVIDOR/COMPARTIDO /ruta/montaje \
  -o username=USUARIO,domain=LAB07

# Ejemplo:
sudo mount -t cifs //192.168.100.1/Public /mnt/public \
  -o username=alice,domain=LAB07

# DESMONTAR
sudo umount /ruta/montaje
```

## 🔒 Gestión de ACLs

```bash
# VER ACLs de archivo/directorio
getfacl /ruta/al/archivo

# ESTABLECER ACL para usuario
setfacl -m u:USUARIO:rwx /ruta/al/archivo

# ESTABLECER ACL para grupo
setfacl -m g:GRUPO:rwx /ruta/al/directorio

# Establecer ACL por DEFECTO (para nuevos archivos)
setfacl -d -m g:GRUPO:rwx /ruta/al/directorio

# QUITAR ACL
setfacl -x u:USUARIO /ruta/al/archivo

# QUITAR todas las ACLs
setfacl -b /ruta/al/archivo

# COPIAR ACLs de un archivo a otro
getfacl archivo_origen | setfacl --set-file=- archivo_destino
```

## 🔧 Gestión del Servicio Samba

```bash
# VER estado del servicio
sudo systemctl status samba-ad-dc

# INICIAR servicio
sudo systemctl start samba-ad-dc

# DETENER servicio
sudo systemctl stop samba-ad-dc

# REINICIAR servicio
sudo systemctl restart samba-ad-dc

# RECARGAR configuración (sin interrumpir servicio)
sudo systemctl reload samba-ad-dc

# HABILITAR inicio automático
sudo systemctl enable samba-ad-dc

# VER logs en tiempo real
sudo journalctl -u samba-ad-dc -f

# Ver logs recientes
sudo journalctl -u samba-ad-dc -n 100
```

## 🌐 Diagnóstico de Red

```bash
# Ver PUERTOS en escucha
sudo ss -tulnp | grep -E ':(53|88|389|445|636|3268)'

# Ver puertos específicos de Samba
sudo ss -tulnp | grep samba

# PROBAR conectividad
ping -c 4 HOSTNAME

# RASTREAR ruta
traceroute HOSTNAME

# Ver CONFIGURACIÓN de red
ip a                    # Direcciones IP
ip route                # Rutas
cat /etc/resolv.conf    # Configuración DNS
```

## 🛠️ Sistema

```bash
# Ver HOSTNAME
hostname
hostname -f

# ESTABLECER hostname
sudo hostnamectl set-hostname NOMBRE.lab07.lan

# Ver INFORMACIÓN del sistema
hostnamectl
uname -a

# VERIFICAR configuración de Samba
testparm

# Verificar sintaxis de configuración
testparm -s

# Ver sección específica de smb.conf
testparm -s --section-name=SECCION
```

## 📊 Verificación Rápida del Sistema

```bash
# Script completo de verificación
echo "=== Verificación LAB07 ==="
echo
echo "1. Servicio Samba:"
sudo systemctl status samba-ad-dc --no-pager | grep Active
echo
echo "2. DNS:"
host -t A ls07.lab07.lan
echo
echo "3. Usuarios:"
sudo samba-tool user list | wc -l
echo "usuarios en el dominio"
echo
echo "4. Grupos:"
sudo samba-tool group list | wc -l
echo "grupos en el dominio"
echo
echo "5. Computadoras:"
sudo samba-tool computer list
echo
echo "6. Puertos en escucha:"
sudo ss -tulnp | grep -E ':(53|88|389|445)' | awk '{print $5}' | sort -u
```

## 🚑 Solución Rápida de Problemas

```bash
# DNS no resuelve
sudo systemctl restart samba-ad-dc
sudo ss -tulnp | grep :53    # Verificar puerto 53

# Verificar resolv.conf
cat /etc/resolv.conf | grep nameserver
# Primera línea debe ser: nameserver 127.0.0.1

# Kerberos falla
kinit administrator@LAB07.LAN
klist

# Si falla, copiar config de Samba:
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# Puerto 53 ocupado
sudo ss -tulnp | grep :53
sudo systemctl disable --now systemd-resolved

# Cliente no puede unirse
# Desde el cliente:
nslookup lab07.lan
ping ls07.lab07.lan
host -t SRV _ldap._tcp.lab07.lan
```

## 📝 Ejemplos de Uso Común

### Crear nuevo usuario y añadirlo a un grupo

```bash
# Crear usuario
sudo samba-tool user create maria admin_21 \
  --given-name=Maria --surname=Garcia

# Añadir a grupo
sudo samba-tool group addmembers HR_Staff maria

# Verificar
sudo samba-tool group listmembers HR_Staff
```

### Resetear contraseña de usuario

```bash
sudo samba-tool user setpassword maria --newpassword='NuevaPass2026!'
```

### Ver todos los miembros de todos los grupos

```bash
for grupo in $(sudo samba-tool group list); do
  echo "=== $grupo ==="
  sudo samba-tool group listmembers $grupo
  echo
done
```

### Verificar pertenencia de un usuario a grupos

```bash
sudo samba-tool user show alice | grep memberOf
```

## 🎯 Valores por Defecto LAB07

```
Dominio:              lab07.lan
Realm:                LAB07.LAN
NetBIOS:              LAB07
DC Hostname:          ls07.lab07.lan
IP Interna DC:        192.168.100.1
IP Externa DC:        172.30.20.54
DNS Primario:         127.0.0.1
DNS Forwarder:        10.239.3.7
Admin Password:       Admin_21
User Password:        admin_21
Min Password Length:  12
Password Complexity:  On
```

## 🔌 Puertos Comunes

| Puerto | Servicio | Protocolo |
|--------|----------|-----------|
| 53 | DNS | TCP/UDP |
| 88 | Kerberos | TCP/UDP |
| 389 | LDAP | TCP |
| 445 | SMB | TCP |
| 636 | LDAPS | TCP |
| 3268 | Global Catalog | TCP |

---

**Para más detalles:** Ver [DOCUMENTACION_COMPLETA.md](DOCUMENTACION_COMPLETA.md)
