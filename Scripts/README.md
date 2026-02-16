# 🚀 Scripts de Automatización - LAB07

Scripts útiles para automatizar tareas comunes en tu dominio Active Directory.

## 📜 Scripts Disponibles

### `crear-usuarios.sh`
**Creación masiva de usuarios desde un archivo CSV**

#### ¿Qué hace?
- Crea múltiples usuarios del dominio de una sola vez
- Asigna automáticamente a grupos
- Muestra progreso y errores en colores

#### Cómo usar:

1. **Crear archivo CSV de usuarios:**
   ```bash
   nano usuarios.csv
   ```
   
   Formato (con encabezado en primera línea):
   ```csv
   usuario,contraseña,nombre,apellido,grupo
   alice,admin_21,Alice,Wonderland,Students
   bob,admin_21,Bob,Marley,Students
   charlie,admin_21,Charlie,Sheen,Students
   maria,SecureP@ss123,Maria,Garcia,HR_Staff
   jose,SecureP@ss456,Jose,Lopez,IT_Admins
   ```
   
   **Nota:** La primera línea (encabezado) se ignora automáticamente.

2. **Ejecutar el script:**
   ```bash
   sudo bash crear-usuarios.sh usuarios.csv
   ```
   
   O simplemente:
   ```bash
   sudo bash crear-usuarios.sh
   # Buscará usuarios.csv por defecto
   ```

3. **Ver el resultado:**
   ```bash
   # Listar todos los usuarios creados
   sudo samba-tool user list
   
   # Ver miembros de un grupo
   sudo samba-tool group listmembers Students
   ```

#### Formato del CSV

| Campo | Descripción | Ejemplo | Requerido |
|-------|-------------|---------|-----------|
| usuario | Nombre de usuario (login) | `alice` | ✅ Sí |
| contraseña | Contraseña (o vacío para usar default) | `admin_21` | ⚠️ Opcional |
| nombre | Primer nombre | `Alice` | ✅ Sí |
| apellido | Apellido | `Wonderland` | ✅ Sí |
| grupo | Grupo de seguridad | `Students` | ⚠️ Opcional |

**Nota:** Si dejas la contraseña vacía, usará `admin_21` por defecto.

#### Ejemplos de CSV

**Ejemplo 1: Estudiantes**
```csv
student1,Pass2026!,John,Doe,Students
student2,Pass2026!,Jane,Smith,Students
student3,Pass2026!,Mike,Johnson,Students
```

**Ejemplo 2: Personal IT**
```csv
admin1,SecureP@ss1,Carlos,Rodriguez,IT_Admins
admin2,SecureP@ss2,Ana,Martinez,IT_Admins
support1,SecureP@ss3,Luis,Gonzalez,Tech_Support
```

**Ejemplo 3: Departamento RRHH**
```csv
hr1,HRpass2026!,Laura,Fernandez,HR_Staff
hr2,HRpass2026!,Pedro,Sanchez,HR_Staff
```

**Ejemplo 4: Sin grupo (se asigna después manualmente)**
```csv
temp1,TempPass123,Temporal,Usuario,
temp2,TempPass456,Otro,Temporal,
```

#### Características del Script

✅ **Validaciones:**
- Verifica que eres root/sudo
- Comprueba que el archivo CSV existe
- Valida conexión con el dominio

✅ **Feedback visual:**
- Colores para éxito (verde) y error (rojo)
- Contador de progreso
- Resumen al final

✅ **Manejo de errores:**
- Detecta usuarios duplicados
- Avisa si el grupo no existe
- Muestra qué usuarios fallaron

#### Salida de Ejemplo

```bash
$ sudo bash crear-usuarios.sh usuarios.csv

========================================
  Creación Masiva de Usuarios Samba AD
  Dominio: lab07.lan
========================================

Leyendo usuarios desde: usuarios.csv
Total de usuarios a procesar: 5

[1/5] Procesando: alice...
[✓] Usuario creado: alice
[✓]   └─ Añadido al grupo: Students

[2/5] Procesando: bob...
[✓] Usuario creado: bob
[✓]   └─ Añadido al grupo: Students

...

========================================
  Resumen
========================================
[✓] Usuarios creados exitosamente: 5

Para verificar usuarios creados:
  sudo samba-tool user list

Para verificar miembros de un grupo:
  sudo samba-tool group listmembers NOMBREGRUPO
```

## 🛠️ Personalización

### Cambiar la contraseña por defecto

Edita la línea 15 del script:
```bash
DEFAULT_PASSWORD="tu_password_aqui"
```

### Usar otro archivo por defecto

Edita la línea 16:
```bash
CSV_FILE="${1:-mi_archivo.csv}"
```

## ⚠️ Requisitos

- Ejecutar como root o con sudo
- Samba AD DC debe estar corriendo
- Los grupos deben existir previamente

### Crear grupos antes de ejecutar:

```bash
sudo samba-tool group add Students
sudo samba-tool group add IT_Admins
sudo samba-tool group add HR_Staff
sudo samba-tool group add Finance
sudo samba-tool group add Tech_Support
```

## 🔒 Políticas de Contraseñas

Recuerda que las contraseñas deben cumplir con la política del dominio:

```bash
# Ver política actual
sudo samba-tool domain passwordsettings show

# Para LAB07 (por defecto):
# - Mínimo 12 caracteres
# - Complejidad: ON (mayúsculas, minúsculas, números, símbolos)
```

Contraseñas válidas:
- ✅ `SecureP@ss2026!`
- ✅ `Admin_21`
- ✅ `MyP@ssw0rd123`

Contraseñas inválidas:
- ❌ `password` (muy corta, sin complejidad)
- ❌ `12345678` (sin letras)
- ❌ `Password` (sin números/símbolos)

## 📊 Casos de Uso

### Caso 1: Nueva clase de estudiantes
```bash
# Crear CSV con 30 estudiantes
# usuarios.csv:
# est01,Pass2026!,Estudiante,Uno,Students
# est02,Pass2026!,Estudiante,Dos,Students
# ...

sudo bash crear-usuarios.sh usuarios.csv
```

### Caso 2: Nuevo departamento
```bash
# Crear grupo primero
sudo samba-tool group add Ventas

# Crear CSV
# ventas.csv:
# vendedor1,VentasP@ss1,Juan,Perez,Ventas
# vendedor2,VentasP@ss2,Maria,Lopez,Ventas

sudo bash crear-usuarios.sh ventas.csv
```

### Caso 3: Usuarios temporales
```bash
# temp.csv (sin grupo, se asigna manualmente después)
# temp1,TempP@ss1,Temp,Uno,
# temp2,TempP@ss2,Temp,Dos,

sudo bash crear-usuarios.sh temp.csv

# Asignar a grupo después
sudo samba-tool group addmembers Invitados temp1,temp2
```

## 🔍 Verificación

Después de crear usuarios:

```bash
# Contar usuarios totales
sudo samba-tool user list | wc -l

# Ver usuarios de un grupo específico
sudo samba-tool group listmembers Students

# Probar login de un usuario
kinit alice@LAB07.LAN
klist
kdestroy
```

## 🆘 Solución de Problemas

### Error: "This script must be run as root"
```bash
# Usar sudo
sudo bash crear-usuarios.sh usuarios.csv
```

### Error: "CSV file not found"
```bash
# Verificar que el archivo existe
ls -la usuarios.csv

# O especificar ruta completa
sudo bash crear-usuarios.sh /ruta/completa/usuarios.csv
```

### Error: "Could not add to group"
```bash
# Crear el grupo primero
sudo samba-tool group add NombreGrupo

# Verificar que existe
sudo samba-tool group list | grep NombreGrupo
```

### Error: "Password is too short"
```bash
# Ver política de contraseñas
sudo samba-tool domain passwordsettings show

# Usar contraseñas más largas y complejas
# Mínimo 12 caracteres con mayúsculas, minúsculas, números y símbolos
```

## 🚀 Futuros Scripts

Próximos scripts planeados:
- [ ] `eliminar-usuarios.sh` - Eliminar usuarios masivamente
- [ ] `backup-ad.sh` - Backup automático del AD
- [ ] `reporte-usuarios.sh` - Generar reportes de usuarios
- [ ] `reset-passwords.sh` - Resetear contraseñas masivamente
- [ ] `exportar-usuarios.sh` - Exportar usuarios a CSV

## 📚 Más Información

- Documentación completa: [DOCUMENTACION_COMPLETA.md](../docs/DOCUMENTACION_COMPLETA.md)
- Comandos de gestión: [REFERENCIA_RAPIDA.md](../docs/REFERENCIA_RAPIDA.md)
- Solución de problemas: [SOLUCION_PROBLEMAS.md](../docs/SOLUCION_PROBLEMAS.md)

---

**💡 Consejo:** Prueba primero con un CSV pequeño (2-3 usuarios) para verificar que todo funciona correctamente.
