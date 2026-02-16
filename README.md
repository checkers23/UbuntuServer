# 🏢 LAB07 - Samba 4 Active Directory

[![Samba Version](https://img.shields.io/badge/Samba-4.19.5-blue.svg)](https://www.samba.org/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04%20LTS-orange.svg)](https://ubuntu.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> Implementación completa de Active Directory con Samba 4 en Ubuntu Server 24.04

## 📋 ¿Qué es este proyecto?

Este es un proyecto de laboratorio que implementa un **controlador de dominio Active Directory** completo usando Samba 4 en Ubuntu Server. Incluye:

- ✅ Controlador de dominio funcional (lab07.lan)
- ✅ Usuarios y grupos de seguridad organizados
- ✅ Carpetas compartidas con permisos
- ✅ Cliente Ubuntu Desktop unido al dominio
- ✅ Autenticación centralizada
- ✅ DNS y Kerberos configurados

## 🖥️ Infraestructura

### Servidor (ls07)
- **Dominio:** lab07.lan
- **Hostname:** ls07.lab07.lan
- **IP Interna:** 192.168.100.1/25
- **IP Externa:** 172.30.20.54/25
- **OS:** Ubuntu Server 24.04 LTS

### Cliente Ubuntu (lc07)
- **Hostname:** lc07
- **IP Interna:** 192.168.100.2/25
- **IP Externa:** 172.30.20.53/25
- **OS:** Ubuntu Desktop 24.04
- **Estado:** ✅ Unido al dominio

### Cliente Windows
- **Estado:** ⏳ Pendiente de unir al dominio
- **IP:** Por asignar

## 🔑 Credenciales

**Administrador del Dominio:**
- Usuario: `Administrator` o `administrator@LAB07.LAN`
- Contraseña: `Admin_21`
- Dominio: `LAB07\Administrator`

**Usuario del Sistema Linux:**
- Usuario: `administrador`
- Contraseña: `admin_21`

## 🚀 Inicio Rápido

### Ver toda la documentación
La documentación completa con todos los pasos, comandos y configuraciones está en:

📖 **[DOCUMENTACION_COMPLETA.md](docs/DOCUMENTACION_COMPLETA.md)**

### Comandos más usados

```bash
# Ver información del dominio
sudo samba-tool domain info 127.0.0.1

# Listar usuarios
sudo samba-tool user list

# Crear un usuario
sudo samba-tool user create nombre password

# Listar grupos
sudo samba-tool group list

# Verificar estado del servicio
sudo systemctl status samba-ad-dc
```

Para más comandos, consulta: [REFERENCIA_RAPIDA.md](docs/REFERENCIA_RAPIDA.md)

## 📚 Documentación

| Documento | Descripción |
|-----------|-------------|
| **[DOCUMENTACION_COMPLETA.md](docs/DOCUMENTACION_COMPLETA.md)** | 📖 Documentación completa del proyecto con todos los sprints |
| **[REFERENCIA_RAPIDA.md](docs/REFERENCIA_RAPIDA.md)** | ⚡ Comandos más usados y referencia rápida |
| **[SOLUCION_PROBLEMAS.md](docs/SOLUCION_PROBLEMAS.md)** | 🔧 Guía para resolver problemas comunes |
| **[CONFIGURAR_GITHUB.md](docs/CONFIGURAR_GITHUB.md)** | 🐙 Cómo subir este proyecto a GitHub |

## 📁 Estructura del Proyecto

```
lab07-samba-ad/
│
├── README.md                          # ← Estás aquí (entrada básica)
├── LICENSE                            # Licencia del proyecto
│
├── docs/                              # Documentación completa
│   ├── DOCUMENTACION_COMPLETA.md      # Todos los sprints y detalles
│   ├── REFERENCIA_RAPIDA.md           # Comandos rápidos
│   ├── SOLUCION_PROBLEMAS.md          # Troubleshooting
│   └── CONFIGURAR_GITHUB.md           # Setup de GitHub
│
├── scripts/                           # Scripts de automatización
│   └── crear-usuarios.sh              # Crear usuarios masivamente
│
└── examples/                          # Ejemplos de configuración
    ├── smb.conf                       # Configuración Samba
    ├── netplan-config.yaml            # Configuración de red
    └── mapdrives.bat                  # Script Windows
```

## 🎯 ¿Por dónde empezar?

1. **Si ya tienes todo montado:** 
   - Usa [REFERENCIA_RAPIDA.md](docs/REFERENCIA_RAPIDA.md) para comandos del día a día

2. **Si quieres entender todo el proyecto:**
   - Lee [DOCUMENTACION_COMPLETA.md](docs/DOCUMENTACION_COMPLETA.md) de principio a fin

3. **Si tienes un problema:**
   - Consulta [SOLUCION_PROBLEMAS.md](docs/SOLUCION_PROBLEMAS.md)

4. **Si quieres subirlo a GitHub:**
   - Sigue [CONFIGURAR_GITHUB.md](docs/CONFIGURAR_GITHUB.md)

## 📊 Estado del Proyecto

### Completado ✅
- [x] Servidor de dominio LAB07 configurado
- [x] DNS y Kerberos funcionando
- [x] Usuarios y grupos creados
- [x] Carpetas compartidas configuradas
- [x] Cliente Ubuntu unido al dominio
- [x] Documentación completa

### Pendiente ⏳
- [ ] Unir cliente Windows al dominio
- [ ] Segundo controlador de dominio (LAB08 - opcional)
- [ ] Trust entre dominios (LAB07 ↔ LAB08)

## 🌐 Red y Arquitectura

```
Internet
   │
Gateway: 172.30.20.1
   │
   ├─── 172.30.20.54/25 (ls07 - externa)
   ├─── 172.30.20.53/25 (lc07 - externa)
   │
Red Interna: 192.168.100.0/25
   │
   ├─── 192.168.100.1/25 (ls07 - DC)
   └─── 192.168.100.2/25 (lc07 - cliente)
```

## 🔧 Verificación Rápida

```bash
# ¿Está funcionando el servicio?
sudo systemctl status samba-ad-dc

# ¿Resuelve DNS?
host -t A ls07.lab07.lan

# ¿Funciona Kerberos?
kinit administrator@LAB07.LAN

# ¿Qué usuarios hay?
sudo samba-tool user list
```

## 📞 Soporte

- **Documentación completa:** [docs/DOCUMENTACION_COMPLETA.md](docs/DOCUMENTACION_COMPLETA.md)
- **Comandos rápidos:** [docs/REFERENCIA_RAPIDA.md](docs/REFERENCIA_RAPIDA.md)
- **Problemas comunes:** [docs/SOLUCION_PROBLEMAS.md](docs/SOLUCION_PROBLEMAS.md)

## 📝 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

**💡 Consejo:** Si es tu primera vez con este proyecto, empieza por la [DOCUMENTACION_COMPLETA.md](docs/DOCUMENTACION_COMPLETA.md) para entender todo paso a paso.
