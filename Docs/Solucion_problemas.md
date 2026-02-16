# 🔧 Guía de Solución de Problemas - LAB07

Soluciones a problemas comunes en el dominio lab07.lan

## 🚨 Problemas Más Comunes

### 1. DNS No Resuelve Nombres

**Síntomas:**
- `host ls07.lab07.lan` falla
- No se pueden unir clientes al dominio
- Errores de "dominio no encontrado"

**Diagnóstico:**
```bash
# Verificar servicio Samba
sudo systemctl status samba-ad-dc

# Verificar puerto 53
sudo ss -tulnp | grep :53

# Verificar resolv.conf
cat /etc/resolv.conf
```

**Soluciones:**
```bash
# 1. Verificar que systemd-resolved está deshabilitado
sudo systemctl status systemd-resolved
# Debe mostrar: inactive (dead)

# Si está activo, deshabilitarlo:
sudo systemctl disable --now systemd-resolved
sudo unlink /etc/resolv.conf

# 2. Crear resolv.conf manual
sudo nano /etc/resolv.conf
```

Contenido:
```
nameserver 127.0.0.1
nameserver 10.239.3.7
search lab07.lan
```

```bash
# 3. Reiniciar Samba
sudo systemctl restart samba-ad-dc

# 4. Verificar DNS funciona
host -t A ls07.lab07.lan
host -t SRV _ldap._tcp.lab07.lan
```

---

### 2. Autenticación Kerberos Falla

**Síntomas:**
- `kinit` falla con error
- "Cannot find KDC for realm"
- Usuarios no pueden autenticarse

**Diagnóstico:**
```bash
# Ver configuración de Kerberos
cat /etc/krb5.conf

# Probar autenticación
kinit administrator@LAB07.LAN
```

**Soluciones:**
```bash
# 1. Copiar configuración de Samba
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# 2. Verificar contenido
cat /etc/krb5.conf | grep -A 5 "\[libdefaults\]"

# Debe contener:
# [libdefaults]
#     default_realm = LAB07.LAN
#     dns_lookup_realm = false
#     dns_lookup_kdc = true

# 3. Probar de nuevo
kinit administrator@LAB07.LAN
klist
kdestroy
```

---

### 3. Puerto 53 Ya Está en Uso

**Síntomas:**
- Samba no inicia
- Error: "Address already in use"
- Puerto 53 ocupado

**Diagnóstico:**
```bash
# Ver qué proceso usa el puerto 53
sudo ss -tulnp | grep :53
```

**Soluciones:**
```bash
# 1. Desactivar systemd-resolved
sudo systemctl disable --now systemd-resolved

# 2. Verificar que está detenido
sudo systemctl status systemd-resolved

# 3. Eliminar enlace simbólico
sudo unlink /etc/resolv.conf

# 4. Crear resolv.conf manual
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf

# 5. Verificar puerto libre
sudo ss -tulnp | grep :53
# Debe estar vacío

# 6. Iniciar Samba
sudo systemctl start samba-ad-dc
```

---

### 4. Cliente Ubuntu No Puede Unirse

**Síntomas:**
- `realm join` falla
- "Failed to join domain"
- No puede descubrir el dominio

**Desde el Cliente:**

```bash
# 1. Verificar DNS
nslookup lab07.lan
# Debe resolver a: 192.168.100.1

# 2. Verificar registros SRV
host -t SRV _ldap._tcp.lab07.lan
# Debe mostrar: _ldap._tcp.lab07.lan has SRV record...

# 3. Probar ping
ping ls07.lab07.lan
# Debe responder desde 192.168.100.1

# 4. Verificar resolv.conf
cat /etc/resolv.conf
# Primera línea debe ser: nameserver 192.168.100.1

# 5. Descubrir dominio
sudo realm discover lab07.lan

# 6. Si todo está bien, intentar unir de nuevo
sudo realm join --verbose --user=administrator lab07.lan
```

**Desde el Servidor:**

```bash
# Verificar que Samba está corriendo
sudo systemctl status samba-ad-dc

# Ver logs en tiempo real
sudo journalctl -u samba-ad-dc -f

# Verificar DNS del servidor
host -t A ls07.lab07.lan
```

---

### 5. Cliente Windows No Puede Unirse

**Síntomas:**
- "El dominio especificado no existe"
- "No se puede contactar el dominio"
- Error de contraseña

**Soluciones:**

#### A. Verificar DNS (en Windows)
```cmd
:: Desde PowerShell o CMD
nslookup lab07.lan
nslookup ls07.lab07.lan
nslookup _ldap._tcp.lab07.lan

:: Hacer ping
ping ls07.lab07.lan
ping 192.168.100.1

:: Vaciar caché DNS
ipconfig /flushdns
```

#### B. Verificar Configuración de Red
- DNS debe ser: 192.168.100.1
- Dominio de búsqueda: lab07.lan
- Puerta de enlace: 172.30.20.1 (o vacío)

#### C. Verificar Contraseña del Administrador

Desde el servidor:
```bash
# Resetear contraseña
sudo samba-tool user setpassword Administrator --newpassword='Admin_21'

# Deshabilitar expiración
sudo samba-tool user setexpiry Administrator --noexpiry

# Verificar
sudo samba-tool user show Administrator | grep -E "(Password|accountExpires)"
```

#### D. Intentar Unir con Diferentes Formatos

- `Administrator`
- `administrator@lab07.lan`
- `LAB07\administrator`

---

### 6. Recursos Compartidos No Accesibles

**Síntomas:**
- No aparecen compartidos
- "Access denied"
- Usuarios no pueden ver carpetas

**Verificaciones:**

```bash
# 1. Verificar que los compartidos existen
smbclient -L localhost -U administrator

# 2. Verificar configuración
testparm -s --section-name=Public

# 3. Verificar permisos de filesystem
ls -la /srv/samba/

# 4. Verificar ACLs
getfacl /srv/samba/public/

# 5. Verificar grupo del usuario
sudo samba-tool user show alice | grep memberOf
```

**Soluciones:**

```bash
# Si falta configuración en smb.conf
sudo nano /etc/samba/smb.conf
# Añadir sección [Public], [HRDocs], [FinanceDocs]

# Recargar configuración
sudo systemctl reload samba-ad-dc

# Si faltan permisos
sudo chmod 770 /srv/samba/finance
sudo chown -R root:"Domain Users" /srv/samba/

# Reestablecer ACLs
sudo setfacl -m g:"Domain Users":rx /srv/samba/public/
sudo setfacl -d -m g:"Domain Users":rx /srv/samba/public/
```

---

### 7. Script de Logon No Se Ejecuta (Windows)

**Síntomas:**
- Las unidades no se mapean automáticamente
- Script no aparece al iniciar sesión

**Verificaciones en el Servidor:**

```bash
# 1. Verificar que el script existe
ls -la /var/lib/samba/sysvol/lab07.lan/scripts/

# 2. Verificar permisos
ls -la /var/lib/samba/sysvol/lab07.lan/scripts/mapdrives.bat
# Debe ser: -rwxr-xr-x (755)

# 3. Verificar atributo del usuario
sudo samba-tool user show alice | grep scriptPath
# Debe mostrar: scriptPath: mapdrives.bat
```

**Soluciones:**

```bash
# Asignar script al usuario
sudo ldbmodify -H /var/lib/samba/private/sam.ldb <<EOF
dn: CN=Alice Wonderland,CN=Users,DC=lab07,DC=lan
changetype: modify
replace: scriptPath
scriptPath: mapdrives.bat
EOF

# Verificar
sudo samba-tool user show alice | grep scriptPath
```

---

### 8. Usuario Bloqueado o Contraseña Expirada

**Síntomas:**
- "Account is disabled"
- "Password has expired"
- Usuario no puede iniciar sesión

**Soluciones:**

```bash
# Ver estado del usuario
sudo samba-tool user show USUARIO

# Habilitar usuario
sudo samba-tool user enable USUARIO

# Resetear contraseña
sudo samba-tool user setpassword USUARIO --newpassword='NuevaPass2026!'

# Deshabilitar expiración
sudo samba-tool user setexpiry USUARIO --noexpiry

# Verificar
sudo samba-tool user show USUARIO | grep -E "(userAccountControl|accountExpires)"
```

---

### 9. Servicio Samba No Inicia

**Síntomas:**
- `systemctl start samba-ad-dc` falla
- Error en logs

**Diagnóstico:**

```bash
# Ver estado detallado
sudo systemctl status samba-ad-dc

# Ver logs
sudo journalctl -u samba-ad-dc -n 50

# Verificar configuración
testparm
```

**Soluciones Comunes:**

```bash
# 1. Error de sintaxis en smb.conf
sudo testparm
# Corregir errores mostrados

# 2. Puerto ocupado
sudo ss -tulnp | grep :53
# Si aparece otro proceso, detenerlo

# 3. Permisos incorrectos
sudo chown -R root:root /var/lib/samba/
sudo chmod 755 /var/lib/samba/sysvol

# 4. Reintentar inicio
sudo systemctl restart samba-ad-dc
```

---

### 10. Problemas de Tiempo/Sincronización

**Síntomas:**
- Kerberos falla intermitentemente
- "Clock skew too great"

**Solución:**

```bash
# Verificar hora actual
timedatectl

# Verificar sincronización NTP
timedatectl show-timesync --all

# Si la hora está mal, sincronizar:
sudo timedatectl set-ntp true

# O manualmente:
sudo systemctl enable --now systemd-timesyncd

# Verificar de nuevo
timedatectl
```

---

## 🔍 Comandos de Diagnóstico Rápido

### Script de Verificación Completa

```bash
#!/bin/bash
echo "=== LAB07 Diagnóstico Rápido ==="
echo
echo "1. Servicio Samba:"
sudo systemctl status samba-ad-dc --no-pager | grep Active
echo
echo "2. Puerto 53 (debe estar libre o en uso por Samba):"
sudo ss -tulnp | grep :53
echo
echo "3. DNS Interno:"
host -t A ls07.lab07.lan
echo
echo "4. DNS Registro SRV:"
host -t SRV _ldap._tcp.lab07.lan
echo
echo "5. Kerberos (necesitas contraseña):"
kinit administrator@LAB07.LAN && klist && kdestroy
echo
echo "6. Usuarios en el dominio:"
sudo samba-tool user list | wc -l
echo
echo "7. Compartidos configurados:"
testparm -s --show-all-parameters 2>/dev/null | grep "^\[" | grep -v "global"
echo
```

---

## 📞 Dónde Buscar Más Ayuda

Si los problemas persisten:

1. **Ver logs detallados:**
   ```bash
   sudo journalctl -u samba-ad-dc -f
   ```

2. **Documentación oficial:**
   - [Samba Wiki](https://wiki.samba.org/)
   - [Ubuntu Server Guide](https://ubuntu.com/server/docs)

3. **Consultar la documentación completa:**
   - [DOCUMENTACION_COMPLETA.md](DOCUMENTACION_COMPLETA.md)
   - [REFERENCIA_RAPIDA.md](REFERENCIA_RAPIDA.md)

---

**Última actualización:** Febrero 2026
