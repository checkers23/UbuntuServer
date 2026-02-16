# 📁 Ejemplos de Configuración - LAB07

Esta carpeta contiene archivos de configuración de ejemplo listos para usar en tu dominio LAB07.

## 📋 Archivos Disponibles

### 🔧 `smb.conf`
**Configuración de Samba para el Controlador de Dominio**

- **Ubicación en el servidor:** `/etc/samba/smb.conf`
- **Qué hace:** Define el dominio, DNS, y recursos compartidos
- **Cómo usar:**
  ```bash
  # Ver tu configuración actual
  cat /etc/samba/smb.conf
  
  # Copiar este ejemplo (CUIDADO: respalda primero)
  sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
  sudo cp examples/smb.conf /etc/samba/smb.conf
  
  # Verificar sintaxis
  testparm
  
  # Aplicar cambios
  sudo systemctl reload samba-ad-dc
  ```

### 🌐 `netplan-config.yaml`
**Configuración de red para el servidor**

- **Ubicación en el servidor:** `/etc/netplan/50-cloud-init.yaml`
- **Qué hace:** Configura las interfaces de red (interna y externa)
- **⚠️ IMPORTANTE:** Cambia `enp0s3` y `enp0s8` por tus interfaces reales
- **Cómo usar:**
  ```bash
  # Ver tus interfaces actuales
  ip a
  
  # Editar el archivo
  sudo nano /etc/netplan/50-cloud-init.yaml
  
  # Aplicar configuración
  sudo netplan apply
  
  # Verificar
  ip a
  ip route
  ```

### 💻 `mapdrives.bat`
**Script de Windows para mapear unidades automáticamente**

- **Ubicación en el servidor:** `/var/lib/samba/sysvol/lab07.lan/scripts/mapdrives.bat`
- **Qué hace:** Mapea automáticamente Z:, H:, y F: al iniciar sesión
- **Cómo usar:**
  ```bash
  # Copiar al servidor
  sudo cp examples/mapdrives.bat /var/lib/samba/sysvol/lab07.lan/scripts/
  
  # Dar permisos
  sudo chmod 755 /var/lib/samba/sysvol/lab07.lan/scripts/mapdrives.bat
  
  # Asignar a un usuario
  sudo ldbmodify -H /var/lib/samba/private/sam.ldb <<EOF
  dn: CN=Alice Wonderland,CN=Users,DC=lab07,DC=lan
  changetype: modify
  replace: scriptPath
  scriptPath: mapdrives.bat
  EOF
  
  # Verificar
  sudo samba-tool user show alice | grep scriptPath
  ```

## 🎨 ¿Por qué se ven "bonitos" en GitHub?

Estos archivos usan **syntax highlighting** automático de GitHub:

- `.conf` → Resaltado de configuración
- `.yaml` → Resaltado de YAML
- `.bat` → Resaltado de scripts Windows

Además tienen:
- 📦 Comentarios extensos explicando cada sección
- 🎯 Separadores visuales con líneas
- ✅ Ejemplos de uso incluidos
- ⚠️ Advertencias importantes destacadas
- 📊 Tablas de referencia en comentarios

## 📖 Cómo Adaptar los Archivos

### Si tus IPs son diferentes:

1. **Abre el archivo en un editor**
2. **Busca y reemplaza:**
   - `192.168.100.1` → Tu IP interna del DC
   - `172.30.20.54` → Tu IP externa del DC
   - `lab07.lan` → Tu dominio (si es diferente)
   - `LAB07` → Tu NetBIOS (si es diferente)

### Si tus interfaces son diferentes:

En `netplan-config.yaml`:
- Ejecuta `ip a` para ver tus interfaces
- Reemplaza `enp0s3` y `enp0s8` con tus nombres reales

## ✅ Checklist Antes de Usar

- [ ] He respaldado mi configuración actual
- [ ] He adaptado las IPs a mi red
- [ ] He cambiado los nombres de interfaz
- [ ] He verificado la sintaxis con `testparm` (para smb.conf)
- [ ] He probado en un entorno de prueba primero

## 🆘 Si Algo Sale Mal

### Para Samba:
```bash
# Restaurar backup
sudo cp /etc/samba/smb.conf.backup /etc/samba/smb.conf
sudo systemctl restart samba-ad-dc
```

### Para Netplan:
```bash
# Restaurar configuración anterior
sudo nano /etc/netplan/50-cloud-init.yaml
sudo netplan apply
```

## 📚 Más Información

- Ver documentación completa: [DOCUMENTACION_COMPLETA.md](../docs/DOCUMENTACION_COMPLETA.md)
- Comandos útiles: [REFERENCIA_RAPIDA.md](../docs/REFERENCIA_RAPIDA.md)
- Solución de problemas: [SOLUCION_PROBLEMAS.md](../docs/SOLUCION_PROBLEMAS.md)

---

**💡 Consejo:** Estos archivos son ejemplos educativos. Entiende qué hace cada línea antes de aplicarlos en producción.
