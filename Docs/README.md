# 📚 Documentación - LAB07

Esta carpeta contiene toda la documentación detallada del proyecto LAB07 Samba Active Directory.

## 📖 Archivos Disponibles

### 📘 DOCUMENTACION_COMPLETA.md
**La guía maestra del proyecto**

- **Qué contiene:**
  - Todos los Sprints paso a paso (1, 2, 3 y 4)
  - Configuración completa del servidor
  - Usuarios, grupos y OUs
  - Carpetas compartidas y permisos
  - Configuración de clientes (Ubuntu y Windows)
  - Todos los comandos detallados

- **Cuándo usarla:**
  - ✅ Cuando configures el servidor por primera vez
  - ✅ Cuando necesites entender TODO el proyecto
  - ✅ Como guía de estudio completa
  - ✅ Para replicar el proyecto desde cero

- **Tiempo de lectura:** ~2-3 horas
- **Nivel:** Principiante a intermedio

---

### ⚡ REFERENCIA_RAPIDA.md
**Comandos del día a día**

- **Qué contiene:**
  - Comandos más usados organizados por categoría
  - Ejemplos prácticos
  - Parámetros comunes
  - Atajos útiles

- **Cuándo usarla:**
  - ✅ Para consultas rápidas
  - ✅ Cuando no recuerdas un comando específico
  - ✅ Como cheat sheet imprimible
  - ✅ Para el trabajo diario

- **Tiempo de consulta:** 30 segundos - 5 minutos
- **Nivel:** Todos

---

### 🔧 SOLUCION_PROBLEMAS.md
**Guía de troubleshooting**

- **Qué contiene:**
  - 10 problemas más comunes
  - Diagnóstico paso a paso
  - Soluciones probadas
  - Comandos de verificación

- **Cuándo usarla:**
  - ✅ Cuando algo no funciona
  - ✅ Para diagnosticar errores
  - ✅ Antes de pedir ayuda (primero intenta aquí)
  - ✅ Para prevenir problemas conocidos

- **Tiempo de consulta:** 5-15 minutos
- **Nivel:** Intermedio

---

### 🐙 CONFIGURAR_GITHUB.md
**Guía para subir el proyecto a GitHub**

- **Qué contiene:**
  - Pasos para crear repositorio
  - Comandos Git necesarios
  - Configuración de tokens
  - Buenas prácticas

- **Cuándo usarla:**
  - ✅ Cuando quieras compartir tu proyecto
  - ✅ Para hacer backup en la nube
  - ✅ Para trabajar en equipo
  - ✅ Para tu portfolio

- **Tiempo:** 15-30 minutos
- **Nivel:** Principiante

---

## 🎯 Flujo de Trabajo Recomendado

### Para Implementar el Proyecto:

```
1. Lee → DOCUMENTACION_COMPLETA.md (Sprint 1)
2. Implementa el Sprint 1
3. Verifica con comandos de REFERENCIA_RAPIDA.md
4. Si hay problemas → SOLUCION_PROBLEMAS.md
5. Repite para Sprints 2, 3 y 4
```

### Para Mantenimiento Diario:

```
1. Consulta → REFERENCIA_RAPIDA.md
2. Si hay dudas → DOCUMENTACION_COMPLETA.md
3. Si hay errores → SOLUCION_PROBLEMAS.md
```

### Para Compartir:

```
1. Sigue → CONFIGURAR_GITHUB.md
2. Verifica que todo esté en DOCUMENTACION_COMPLETA.md
```

---

## 📊 Comparación Rápida

| Documento | Cuándo usar | Extensión | Nivel |
|-----------|-------------|-----------|-------|
| **DOCUMENTACION_COMPLETA** | Implementación inicial | ~1000 líneas | Principiante |
| **REFERENCIA_RAPIDA** | Consultas diarias | ~300 líneas | Todos |
| **SOLUCION_PROBLEMAS** | Cuando hay problemas | ~400 líneas | Intermedio |
| **CONFIGURAR_GITHUB** | Subir a GitHub | ~200 líneas | Principiante |

---

## 🗂️ Contenido de DOCUMENTACION_COMPLETA.md

### Sprint 1: Configuración del DC (6 horas)
- Configuración inicial del sistema
- Red dual (interna/externa)
- Instalación de Samba
- Provisión del dominio
- Verificación completa

### Sprint 2: Usuarios y Grupos (6 horas)
- Creación de OUs
- Creación de grupos de seguridad
- Creación de usuarios
- Asignación de membresías
- Política de contraseñas (GPO)

### Sprint 3: Carpetas Compartidas (6 horas)
- Estructura de carpetas
- Configuración de recursos compartidos
- Permisos ACL granulares
- Mapeo automático (Windows/Linux)

### Sprint 4: Forest Trust (6 horas) - Opcional
- Segundo controlador de dominio
- Configuración de trust bidireccional
- Autenticación cruzada

### Configuración de Clientes
- Ubuntu Desktop (lc07)
- Windows 11 (pendiente)

---

## 💡 Consejos de Uso

### Para Estudiantes:
1. **Lee DOCUMENTACION_COMPLETA** de principio a fin primero
2. **Implementa cada Sprint** antes de pasar al siguiente
3. **Guarda REFERENCIA_RAPIDA** como favorito

### Para Profesionales:
1. **Escanea DOCUMENTACION_COMPLETA** para entender la arquitectura
2. **Usa REFERENCIA_RAPIDA** para comandos específicos
3. **Consulta SOLUCION_PROBLEMAS** solo cuando sea necesario

### Para Profesores:
1. **DOCUMENTACION_COMPLETA** como material de clase
2. **REFERENCIA_RAPIDA** como material de apoyo
3. **Asigna los Sprints** como prácticas progresivas

---

## 🔍 Búsqueda Rápida

¿Necesitas algo específico?

| Busco... | Documento | Sección |
|----------|-----------|---------|
| Configurar DNS | DOCUMENTACION_COMPLETA | Sprint 1, Paso 3.3 |
| Crear usuario | REFERENCIA_RAPIDA | Gestión de Usuarios |
| Error DNS | SOLUCION_PROBLEMAS | Problema #1 |
| Subir a GitHub | CONFIGURAR_GITHUB | Todo el documento |
| Ver política de contraseñas | REFERENCIA_RAPIDA | Gestión del Dominio |
| Cliente no se une | SOLUCION_PROBLEMAS | Problema #4 |
| Crear grupos | DOCUMENTACION_COMPLETA | Sprint 2, Paso 4.4 |
| Configurar ACLs | DOCUMENTACION_COMPLETA | Sprint 3, Paso 5.8 |

---

## 📥 Descargar Documentación

Todos estos archivos están en formato Markdown (.md) y se pueden:
- ✅ Ver directamente en GitHub
- ✅ Descargar individualmente
- ✅ Convertir a PDF con herramientas online
- ✅ Editar con cualquier editor de texto

---

## 🆘 ¿Necesitas Ayuda?

1. **Primero:** Busca en SOLUCION_PROBLEMAS.md
2. **Segundo:** Revisa la sección correspondiente en DOCUMENTACION_COMPLETA.md
3. **Tercero:** Verifica comandos en REFERENCIA_RAPIDA.md
4. **Último:** Abre un issue en GitHub o pregunta a la comunidad

---

## 📝 Contribuir a la Documentación

Si encuentras errores o mejoras:
1. Abre un issue describiendo el problema
2. O haz un pull request con la corrección
3. Toda ayuda es bienvenida

---

**🎓 Nota:** Esta documentación está diseñada para ser **progresiva**. Si eres nuevo, empieza por DOCUMENTACION_COMPLETA.md y sigue el orden de los Sprints.
