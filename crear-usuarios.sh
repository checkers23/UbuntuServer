#!/bin/bash
################################################################################
# Bulk User Creation Script for Samba AD - LAB07
# File: crear-usuarios.sh
# Purpose: Create multiple domain users from a CSV file
# Domain: lab07.lan
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="lab07.lan"
DEFAULT_PASSWORD="admin_21"
CSV_FILE="${1:-usuarios.csv}"

################################################################################
# Functions
################################################################################

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Creación Masiva de Usuarios Samba AD${NC}"
    echo -e "${BLUE}  Dominio: $DOMAIN${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script debe ejecutarse como root (usa sudo)"
        exit 1
    fi
}

check_csv() {
    if [[ ! -f "$CSV_FILE" ]]; then
        print_error "Archivo CSV no encontrado: $CSV_FILE"
        echo
        echo "Uso: $0 [archivo_csv]"
        echo
        echo "Formato del CSV (sin encabezados):"
        echo "usuario,contraseña,nombre,apellido,grupo"
        echo
        echo "Ejemplo:"
        echo "alice,Pass123!,Alice,Wonderland,Students"
        echo "bob,Pass456!,Bob,Marley,Students"
        echo "iosif,Pass789!,Stalin,Thegreat,IT_Admins"
        exit 1
    fi
}

check_domain() {
    if ! samba-tool domain info 127.0.0.1 &>/dev/null; then
        print_error "No se puede conectar al dominio. ¿Está Samba corriendo?"
        print_info "Verifica con: sudo systemctl status samba-ad-dc"
        exit 1
    fi
}

create_user() {
    local username=$1
    local password=$2
    local firstname=$3
    local lastname=$4
    local group=$5

    # Use default password if not specified
    [[ -z "$password" ]] && password="$DEFAULT_PASSWORD"

    # Create user
    if samba-tool user create "$username" "$password" \
        --given-name="$firstname" \
        --surname="$lastname" &>/dev/null; then
        print_success "Usuario creado: $username"
        
        # Add to group if specified
        if [[ -n "$group" ]]; then
            if samba-tool group addmembers "$group" "$username" &>/dev/null; then
                print_success "  └─ Añadido al grupo: $group"
            else
                print_warning "  └─ No se pudo añadir al grupo: $group (el grupo puede no existir)"
                print_info "     Crear grupo primero: sudo samba-tool group add $group"
            fi
        fi
    else
        print_error "Error al crear usuario: $username (puede que ya exista)"
    fi
}

################################################################################
# Main Script
################################################################################

print_header
check_root
check_csv
check_domain

print_info "Leyendo usuarios desde: $CSV_FILE"
echo

# Count lines
total_lines=$(wc -l < "$CSV_FILE")
print_info "Total de usuarios a procesar: $total_lines"
echo

# Read CSV and create users
line_num=0
success_count=0
error_count=0

while IFS=',' read -r username password firstname lastname group; do
    line_num=$((line_num + 1))
    
    # Skip empty lines
    [[ -z "$username" ]] && continue
    
    # Trim whitespace
    username=$(echo "$username" | xargs)
    password=$(echo "$password" | xargs)
    firstname=$(echo "$firstname" | xargs)
    lastname=$(echo "$lastname" | xargs)
    group=$(echo "$group" | xargs)
    
    echo "[$line_num/$total_lines] Procesando: $username..."
    
    if create_user "$username" "$password" "$firstname" "$lastname" "$group"; then
        success_count=$((success_count + 1))
    else
        error_count=$((error_count + 1))
    fi
    
    echo
done < "$CSV_FILE"

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Resumen${NC}"
echo -e "${BLUE}========================================${NC}"
print_success "Usuarios creados exitosamente: $success_count"
if [[ $error_count -gt 0 ]]; then
    print_warning "Usuarios con errores: $error_count"
fi
echo

print_info "Para verificar usuarios creados:"
echo "  sudo samba-tool user list"
echo
print_info "Para verificar miembros de un grupo:"
echo "  sudo samba-tool group listmembers NOMBREGRUPO"
echo

################################################################################
# Example CSV File (usuarios.csv)
################################################################################
# alice,admin_21,Alice,Wonderland,Students
# bob,admin_21,Bob,Marley,Students
# charlie,admin_21,Charlie,Sheen,Students
# iosif,admin_21,Stalin,Thegreat,IT_Admins
# karl,admin_21,Karl,Marx,IT_Admins
# lenin,admin_21,Vladimir,Lenin,IT_Admins
# vladimir,admin_21,Vladimir,Malakovsky,HR_Staff
# techsupport,admin_21,Tech,Support,Tech_Support
################################################################################

################################################################################
# Advanced Usage Examples
################################################################################
#
# 1. Create CSV from scratch:
#    cat > usuarios.csv <<EOF
#    alice,admin_21,Alice,Wonderland,Students
#    bob,admin_21,Bob,Marley,Students
#    EOF
#
# 2. Generate random passwords:
#    for i in {1..10}; do
#        user="user$i"
#        pass=$(openssl rand -base64 12)
#        echo "$user,$pass,User,$i,Students"
#    done > usuarios.csv
#
# 3. Import from existing file with different format:
#    awk -F';' '{print $1","$2","$3","$4","$5}' old_format.csv > usuarios.csv
#
################################################################################
