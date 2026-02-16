# 📝 Guía de Archivos CSV de Ejemplo

Esta carpeta contiene archivos CSV listos para usar con el script `crear-usuarios.sh`.

## 📂 Archivos Disponibles

| Archivo | Usuarios | Descripción | Uso |
|---------|----------|-------------|-----|
| **usuarios-ejemplo.csv** | 8 | Usuarios básicos del proyecto LAB07 | Ejemplo general |
| **estudiantes.csv** | 10 | Estudiantes numerados | Nueva clase |
| **departamento-it.csv** | 6 | Personal del departamento IT | Equipo técnico |
| **departamento-rrhh.csv** | 4 | Personal de Recursos Humanos | Equipo RRHH |

## 🚀 Cómo Usar

### Opción 1: Usar directamente (sin modificar)

```bash
# Crear los 8 usuarios de ejemplo
sudo bash scripts/crear-usuarios.sh examples/usuarios-ejemplo.csv

# Crear 10 estudiantes
sudo bash scripts/crear-usuarios.sh examples/estudiantes.csv

# Crear equipo IT
sudo bash scripts/crear-usuarios.sh examples/departamento-it.csv

# Crear equipo RRHH
sudo bash scripts/crear-usuarios.sh examples/departamento-rrhh.csv
```

### Opción 2: Copiar y modificar

```bash
# Copiar un ejemplo
cp examples/estudiantes.csv mi_clase.csv

# Editar con tu editor favorito
nano mi_clase.csv

# Cambiar nombres, contraseñas, etc.
# Guardar y ejecutar
sudo bash scripts/crear-usuarios.sh mi_clase.csv
```

### Opción 3: Crear desde cero

```bash
# Crear nuevo archivo
nano nuevos_usuarios.csv

# Copiar este formato:
# usuario,contraseña,nombre,apellido,grupo
```

## 📋 Formato del CSV

### Estructura

```
usuario,contraseña,nombre,apellido,grupo
```

### Ejemplo

```csv
maria,Pass2026!,Maria,Garcia,Students
```

### Significado de cada campo

| Campo | Descripción | Ejemplo | ¿Obligatorio? |
|-------|-------------|---------|---------------|
| **usuario** | Nombre de login (sin espacios) | `maria` o `m.garcia` | ✅ SÍ |
| **contraseña** | Contraseña del usuario | `Pass2026!` | ⚠️ Opcional* |
| **nombre** | Primer nombre | `Maria` | ✅ SÍ |
| **apellido** | Apellido | `Garcia` | ✅ SÍ |
| **grupo** | Grupo de seguridad | `Students` | ⚠️ Opcional** |

\* Si se deja vacío, usa `admin_21` por defecto  
\*\* Si se deja vacío, no se asigna a ningún grupo (solo Domain Users)

## 📖 Detalle de Cada Archivo

### 1️⃣ usuarios-ejemplo.csv

**Contenido:**
```csv
alice,admin_21,Alice,Wonderland,Students
bob,admin_21,Bob,Marley,Students
charlie,admin_21,Charlie,Sheen,Students
iosif,admin_21,Stalin,Thegreat,IT_Admins
karl,admin_21,Karl,Marx,IT_Admins
lenin,admin_21,Vladimir,Lenin,IT_Admins
vladimir,admin_21,Vladimir,Malakovsky,HR_Staff
techsupport,admin_21,Tech,Support,Tech_Support
```

**Crea:**
- 3 usuarios en grupo Students
- 3 usuarios en grupo IT_Admins
- 1 usuario en grupo HR_Staff
- 1 usuario en grupo Tech_Support

**Uso:**
```bash
sudo bash scripts/crear-usuarios.sh examples/usuarios-ejemplo.csv
```

**Verificar:**
```bash
sudo samba-tool group listmembers Students
sudo samba-tool group listmembers IT_Admins
sudo samba-tool group listmembers HR_Staff
```

---

### 2️⃣ estudiantes.csv

**Contenido:**
```csv
estudiante01,Estud1@2026,Juan,Perez,Students
estudiante02,Estud2@2026,Maria,Garcia,Students
...
estudiante10,Estud10@2026,Carmen,Flores,Students
```

**Crea:**
- 10 estudiantes numerados (01-10)
- Todos en grupo Students
- Contraseñas únicas para cada uno

**Uso:**
```bash
sudo bash scripts/crear-usuarios.sh examples/estudiantes.csv
```

**Probar login:**
```bash
kinit estudiante01@LAB07.LAN
# Password: Estud1@2026
klist
kdestroy
```

---

### 3️⃣ departamento-it.csv

**Contenido:**
```csv
admin.sistemas,AdminIT@2026!,Administrador,Sistemas,IT_Admins
admin.redes,AdminIT@2026!,Administrador,Redes,IT_Admins
soporte1,SoporteIT@26,Soporte,Tecnico1,Tech_Support
soporte2,SoporteIT@26,Soporte,Tecnico2,Tech_Support
desarrollador1,DevPass@2026,Desarrollador,Frontend,IT_Admins
desarrollador2,DevPass@2026,Desarrollador,Backend,IT_Admins
```

**Crea:**
- 4 usuarios en IT_Admins
- 2 usuarios en Tech_Support
- Usuarios con nombres descriptivos (admin.sistemas, soporte1, etc.)

**Uso:**
```bash
sudo bash scripts/crear-usuarios.sh examples/departamento-it.csv
```

**Verificar:**
```bash
sudo samba-tool group listmembers IT_Admins
sudo samba-tool group listmembers Tech_Support
```

---

### 4️⃣ departamento-rrhh.csv

**Contenido:**
```csv
rrhh.director,RRHH_Dir@26!,Director,RecursosHumanos,HR_Staff
rrhh.asistente,RRHH_Asi@26!,Asistente,RecursosHumanos,HR_Staff
rrhh.nominas,RRHH_Nom@26!,Gestor,Nominas,HR_Staff
rrhh.seleccion,RRHH_Sel@26!,Seleccion,Personal,HR_Staff
```

**Crea:**
- 4 usuarios en HR_Staff
- Estructura jerárquica (director, asistente, gestor)
- Usuarios con prefijo rrhh.

**Uso:**
```bash
sudo bash scripts/crear-usuarios.sh examples/departamento-rrhh.csv
```

**Verificar:**
```bash
sudo samba-tool group listmembers HR_Staff
```

## ✏️ Cómo Personalizar

### Cambiar nombres de usuario

**Antes:**
```csv
alice,admin_21,Alice,Wonderland,Students
```

**Después (tu nombre):**
```csv
juan.perez,admin_21,Juan,Perez,Students
```

### Cambiar contraseñas

**Antes:**
```csv
estudiante01,Estud1@2026,Juan,Perez,Students
```

**Después (contraseña más segura):**
```csv
estudiante01,MiP@ssw0rd2026!,Juan,Perez,Students
```

### Cambiar grupo

**Antes:**
```csv
maria,Pass2026!,Maria,Garcia,Students
```

**Después (asignar a IT_Admins):**
```csv
maria,Pass2026!,Maria,Garcia,IT_Admins
```

### Añadir más usuarios

Solo añade nuevas líneas al final:

```csv
estudiante01,Estud1@2026,Juan,Perez,Students
estudiante02,Estud2@2026,Maria,Garcia,Students
estudiante11,Estud11@2026,Nuevo,Usuario,Students
estudiante12,Estud12@2026,Otro,Usuario,Students
```

## 🔐 Requisitos de Contraseñas

Recuerda que las contraseñas deben cumplir la política del dominio LAB07:

✅ **Requisitos:**
- Mínimo 12 caracteres
- Al menos 1 mayúscula
- Al menos 1 minúscula
- Al menos 1 número
- Al menos 1 símbolo (@, !, #, etc.)

✅ **Contraseñas válidas:**
```
SecureP@ss2026!
Admin_21
MyP@ssw0rd123
Estud1@2026
```

❌ **Contraseñas NO válidas:**
```
password          (muy corta, sin complejidad)
12345678          (sin letras)
Password          (sin números/símbolos)
Pass123           (muy corta)
```

## 🛠️ Antes de Ejecutar

### 1. Verificar que los grupos existen

```bash
# Ver grupos disponibles
sudo samba-tool group list

# Si falta algún grupo, créalo
sudo samba-tool group add Students
sudo samba-tool group add IT_Admins
sudo samba-tool group add HR_Staff
sudo samba-tool group add Tech_Support
sudo samba-tool group add Finance
```

### 2. Hacer una prueba pequeña

```bash
# Crear archivo de prueba con 2 usuarios
cat > test.csv << EOF
test1,TestP@ss2026!,Test,Usuario1,Students
test2,TestP@ss2026!,Test,Usuario2,Students
EOF

# Ejecutar
sudo bash scripts/crear-usuarios.sh test.csv

# Verificar
sudo samba-tool user list | grep test

# Si funciona, eliminar usuarios de prueba
sudo samba-tool user delete test1
sudo samba-tool user delete test2
```

### 3. Hacer backup

```bash
# Exportar usuarios actuales
sudo samba-tool user list > usuarios_antes_$(date +%Y%m%d).txt
```

## 📊 Ejemplos de Uso Real

### Escenario 1: Nueva clase de 25 estudiantes

```bash
# 1. Copiar plantilla
cp examples/estudiantes.csv clase2026.csv

# 2. Editar y añadir hasta estudiante25
nano clase2026.csv

# 3. Ejecutar
sudo bash scripts/crear-usuarios.sh clase2026.csv

# 4. Verificar
sudo samba-tool group listmembers Students | wc -l
# Debe mostrar: 25
```

### Escenario 2: Nuevo departamento de Ventas

```bash
# 1. Crear grupo primero
sudo samba-tool group add Ventas

# 2. Crear CSV
cat > ventas.csv << EOF
ventas.director,VentasDir@26!,Director,Ventas,Ventas
ventas.jefe,VentasJefe@26,Jefe,Equipo,Ventas
vendedor1,Vend1@2026,Vendedor,Uno,Ventas
vendedor2,Vend2@2026,Vendedor,Dos,Ventas
vendedor3,Vend3@2026,Vendedor,Tres,Ventas
EOF

# 3. Ejecutar
sudo bash scripts/crear-usuarios.sh ventas.csv

# 4. Verificar
sudo samba-tool group listmembers Ventas
```

### Escenario 3: Usuarios temporales sin grupo

```bash
# Crear CSV sin especificar grupo
cat > temporales.csv << EOF
temp1,TempP@ss1,Temporal,Uno,
temp2,TempP@ss2,Temporal,Dos,
temp3,TempP@ss3,Temporal,Tres,
EOF

# Ejecutar
sudo bash scripts/crear-usuarios.sh temporales.csv

# Los usuarios se crean pero solo están en "Domain Users"
# Puedes asignarlos a un grupo después
sudo samba-tool group addmembers Invitados temp1,temp2,temp3
```

## 🔍 Verificación Post-Creación

Después de crear usuarios, verifica:

```bash
# 1. Contar usuarios totales
sudo samba-tool user list | wc -l

# 2. Ver usuarios de un grupo específico
sudo samba-tool group listmembers Students

# 3. Probar login de un usuario
kinit estudiante01@LAB07.LAN
# Password: Estud1@2026
klist
kdestroy

# 4. Ver detalles de un usuario
sudo samba-tool user show estudiante01
```

## ⚠️ Errores Comunes y Soluciones

### Error: "Usuario ya existe"
```bash
# Ver si existe
sudo samba-tool user list | grep nombre_usuario

# Si quieres recrearlo, elimínalo primero
sudo samba-tool user delete nombre_usuario
```

### Error: "Grupo no existe"
```bash
# Crear el grupo
sudo samba-tool group add NombreGrupo

# Verificar
sudo samba-tool group list | grep NombreGrupo
```

### Error: "Contraseña muy débil"
```bash
# Editar el CSV y cambiar contraseñas
# Usar: mayúsculas + minúsculas + números + símbolos + 12+ caracteres
```

## 💡 Consejos Profesionales

1. **Usa convenciones de nombres:**
   - Estudiantes: `estudiante01`, `estudiante02`
   - IT: `admin.sistemas`, `soporte1`
   - RRHH: `rrhh.director`, `rrhh.nominas`

2. **Contraseñas iniciales iguales:**
   - Primera vez: todos `admin_21` o `Inicial@2026`
   - Forzar cambio en primer login

3. **Documenta las contraseñas:**
   ```bash
   # Crear archivo de contraseñas (¡SEGURO!)
   echo "usuarios-ejemplo.csv - Password: admin_21" > contraseñas.txt
   chmod 600 contraseñas.txt  # Solo tú puedes leerlo
   ```

4. **Backups antes de cambios masivos:**
   ```bash
   sudo samba-tool user list > backup_usuarios_$(date +%Y%m%d).txt
   ```

## 📚 Recursos Adicionales

- Script principal: [scripts/crear-usuarios.sh](../scripts/crear-usuarios.sh)
- Guía del script: [scripts/README.md](../scripts/README.md)
- Documentación completa: [docs/DOCUMENTACION_COMPLETA.md](../docs/DOCUMENTACION_COMPLETA.md)
- Comandos útiles: [docs/REFERENCIA_RAPIDA.md](../docs/REFERENCIA_RAPIDA.md)

---

**🎯 Recuerda:** Estos son archivos de EJEMPLO. Personalízalos según tus necesidades antes de usarlos en producción.
