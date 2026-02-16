# 🐙 Cómo Subir el Proyecto a GitHub

Guía paso a paso para publicar tu proyecto LAB07 en GitHub.

## 📋 Antes de Empezar

Necesitas:
- [ ] Cuenta de GitHub ([crear aquí](https://github.com/signup))
- [ ] Git instalado en tu sistema
- [ ] Acceso a los archivos del proyecto

## 🚀 Pasos para Subir a GitHub

### 1. Crear Repositorio en GitHub

1. Ve a [GitHub](https://github.com) e inicia sesión
2. Haz clic en el botón **"New"** o **"+"** → **"New repository"**
3. Configuración del repositorio:
   - **Repository name:** `lab07-samba-ad` (o el nombre que prefieras)
   - **Description:** `Implementación completa de Active Directory con Samba 4 - LAB07`
   - **Visibilidad:** Elige **Public** o **Private**
   - **NO marques:** "Initialize this repository with a README"
   - **NO añadas:** .gitignore ni license (ya los tenemos)
4. Haz clic en **"Create repository"**

### 2. Preparar tu Proyecto Localmente

```bash
# Navegar al directorio del proyecto
cd /ruta/a/lab07-samba-ad

# Verificar que tienes todos los archivos
ls -la

# Deberías ver:
# README.md
# LICENSE
# .gitignore
# docs/
# scripts/
# examples/
```

### 3. Inicializar Git y Subir

```bash
# Inicializar repositorio Git
git init

# Añadir todos los archivos
git add .

# Verificar qué se va a subir
git status

# Crear el commit inicial
git commit -m "Documentación inicial del proyecto LAB07"

# Añadir el repositorio remoto (reemplaza TU_USUARIO y NOMBRE_REPO)
git remote add origin https://github.com/TU_USUARIO/lab07-samba-ad.git

# Crear rama principal
git branch -M main

# Subir a GitHub
git push -u origin main
```

**Nota:** GitHub te pedirá tus credenciales. Si tienes 2FA activado, necesitarás un [Personal Access Token](https://github.com/settings/tokens).

### 4. Verificar en GitHub

1. Actualiza la página de tu repositorio en GitHub
2. Deberías ver todos tus archivos
3. El README.md se mostrará automáticamente en la página principal

## ⚙️ Configuración Adicional del Repositorio

### Añadir Topics/Tags

Los topics ayudan a que otros encuentren tu proyecto:

1. En tu repositorio, haz clic en el ícono de engranaje junto a **"About"**
2. Añade estos topics:
   - `samba`
   - `active-directory`
   - `ubuntu`
   - `domain-controller`
   - `ldap`
   - `kerberos`
   - `lab`
   - `documentacion`
   - `español`

### Habilitar Issues

1. Ve a **Settings** → **Features**
2. Marca la casilla **"Issues"**
3. Esto permite que otros reporten problemas o hagan preguntas

### Habilitar Discussions (Opcional)

1. Ve a **Settings** → **Features**
2. Marca la casilla **"Discussions"**
3. Útil para preguntas y discusiones de la comunidad

### Añadir Descripción y Website

1. Haz clic en el ícono de engranaje junto a **"About"**
2. Añade:
   - **Description:** Breve descripción del proyecto
   - **Website:** Si tienes un sitio web o documentación online
   - **Topics:** (como se mencionó arriba)

## 📝 Crear tu Primera Release

Las releases son versiones etiquetadas de tu proyecto:

### Desde la Línea de Comandos

```bash
# Crear y subir un tag
git tag -a v1.0.0 -m "Versión 1.0.0 - Documentación inicial completa"
git push origin v1.0.0
```

### Desde GitHub

1. Ve a tu repositorio
2. Haz clic en **"Releases"** → **"Create a new release"**
3. Configuración:
   - **Tag:** `v1.0.0`
   - **Release title:** `v1.0.0 - Documentación Inicial`
   - **Description:**
     ```markdown
     ## 🎉 Primera Versión

     Documentación completa del proyecto LAB07 que incluye:

     ### ✅ Completado
     - Servidor de dominio LAB07 configurado
     - 8 usuarios y 5 grupos de seguridad
     - 3 unidades organizativas (OUs)
     - 3 carpetas compartidas con ACLs
     - Cliente Ubuntu unido al dominio
     - Documentación completa en español
     - Scripts de automatización
     - Ejemplos de configuración

     ### 📚 Documentación
     - [Documentación Completa](docs/DOCUMENTACION_COMPLETA.md)
     - [Referencia Rápida](docs/REFERENCIA_RAPIDA.md)
     - [Solución de Problemas](docs/SOLUCION_PROBLEMAS.md)

     ### ⏳ Pendiente
     - Cliente Windows
     - Segundo controlador de dominio (LAB08)
     ```
4. Haz clic en **"Publish release"**

## 🔄 Actualizar el Repositorio

Cuando hagas cambios:

```bash
# Ver cambios
git status

# Añadir archivos modificados
git add .

# O añadir archivos específicos
git add docs/DOCUMENTACION_COMPLETA.md

# Crear commit con mensaje descriptivo
git commit -m "Añadida sección de troubleshooting"

# Subir cambios
git push origin main
```

## 🌟 Buenas Prácticas

### Mensajes de Commit Claros

Usa mensajes descriptivos:

```bash
# ✅ Bueno
git commit -m "Añadida guía de unión de cliente Windows"
git commit -m "Corregido error en script de creación de usuarios"
git commit -m "Actualizada configuración de red para LAB07"

# ❌ Malo
git commit -m "cambios"
git commit -m "fix"
git commit -m "update"
```

### Estructura de Mensajes de Commit

Formato recomendado:

```
tipo: descripción breve

Descripción más detallada (opcional)
```

Tipos comunes:
- `feat:` Nueva característica
- `fix:` Corrección de error
- `docs:` Cambios en documentación
- `style:` Formato, sin cambios de código
- `refactor:` Refactorización de código
- `test:` Añadir o modificar tests
- `chore:` Tareas de mantenimiento

Ejemplos:
```bash
git commit -m "docs: añadida sección de troubleshooting DNS"
git commit -m "feat: script de backup automático"
git commit -m "fix: corregida ruta en netplan-config.yaml"
```

## 🔐 Proteger Información Sensible

**⚠️ IMPORTANTE:** Nunca subas información sensible:

### Antes de Subir, Verificar

```bash
# Buscar posibles contraseñas en archivos
grep -r "admin_21" .
grep -r "Admin_21" .
grep -r "password" . --include="*.sh" --include="*.bat"

# Si encuentras información sensible:
# 1. Añádela al .gitignore
# 2. Elimínala de los archivos
# 3. Usa variables de entorno o archivos de configuración separados
```

### Si Accidentalmente Subiste Información Sensible

```bash
# Eliminar archivo del historial
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch ruta/archivo_sensible" \
  --prune-empty --tag-name-filter cat -- --all

# Forzar push (¡cuidado!)
git push origin --force --all
```

## 📊 Añadir Badges al README

Los badges hacen tu README más profesional:

```markdown
[![Samba Version](https://img.shields.io/badge/Samba-4.19.5-blue.svg)](https://www.samba.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20LTS-orange.svg)](https://ubuntu.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
```

Más badges en: [shields.io](https://shields.io/)

## 🤝 Colaboración

### Si Trabajas en Equipo

1. **Añadir colaboradores:**
   - Settings → Collaborators → Add people

2. **Usar branches:**
   ```bash
   # Crear nueva rama para una característica
   git checkout -b feature/nueva-caracteristica

   # Trabajar en la rama
   git add .
   git commit -m "feat: nueva característica"

   # Subir rama
   git push origin feature/nueva-caracteristica

   # En GitHub, crear Pull Request para revisar cambios
   ```

3. **Proteger la rama main:**
   - Settings → Branches → Add rule
   - Require pull request reviews before merging

## 📱 GitHub Pages (Opcional)

Crear un sitio web con tu documentación:

1. Ve a **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: **main** → Carpeta: `/docs`
4. Save

Tu documentación estará en:
`https://TU_USUARIO.github.io/lab07-samba-ad/`

## ✅ Checklist Final

Antes de hacer público tu repositorio:

- [ ] README.md está completo y claro
- [ ] LICENSE está presente
- [ ] .gitignore excluye archivos sensibles
- [ ] No hay contraseñas en el código
- [ ] Todos los enlaces funcionan
- [ ] Los ejemplos están probados
- [ ] La documentación está actualizada
- [ ] Los scripts tienen permisos correctos
- [ ] Hay una descripción del repositorio
- [ ] Los topics están añadidos

## 🎯 Próximos Pasos

Después de subir:

1. **Compartir el proyecto:**
   - LinkedIn
   - Twitter
   - Reddit (r/selfhosted, r/sysadmin)

2. **Mantener actualizado:**
   - Responder a issues
   - Aceptar pull requests
   - Actualizar documentación

3. **Añadir mejoras:**
   - GitHub Actions para CI/CD
   - Wiki para documentación adicional
   - Proyectos para tracking de tareas

## 📞 Ayuda

Si tienes problemas:

- [Documentación de GitHub](https://docs.github.com/)
- [Guía de Git](https://git-scm.com/book/es/v2)
- [GitHub Community](https://github.community/)

---

**¡Listo!** Tu proyecto LAB07 ahora está en GitHub. 🎉
