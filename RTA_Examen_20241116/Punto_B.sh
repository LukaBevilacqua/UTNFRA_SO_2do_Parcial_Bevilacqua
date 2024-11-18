#!/bin/bash

ruta_destino="/usr/local/bin/BevilacquaAltaUser-Groups.sh"

if [ "$(realpath "$0")" != "$ruta_destino" ]; then
    echo "El script no está en la ubicación correcta. Moviéndolo a $ruta_destino..."
    
    sudo cp "$0" "$ruta_destino"
    
    sudo chmod +x "$ruta_destino"
    
    echo "El script se ha movido y se ha dado permisos de ejecución."
    echo "Ejecute el script nuevamente desde $ruta_destino."
    
    exit 0
fi

if [ $# -ne 2 ]; then
    echo "Uso: $0 <usuario_existente> <ruta_Lista_Usuarios.txt>"
    exit 1
fi

usuario_existente=$1
archivo_lista=$2

if [ ! -f "$archivo_lista" ]; then
    echo "Error: El archivo $archivo_lista no existe."
    exit 1
fi

clave_encriptada=$(sudo getent shadow "$usuario_existente" | cut -d: -f2)

if [ -z "$clave_encriptada" ]; then
    echo "Error: No se pudo obtener la contraseña del usuario $usuario_existente"
    exit 1
fi

while read -r linea; do
    usuario=$(echo "$linea" | cut -d: -f1)
    grupo=$(echo "$linea" | cut -d: -f2)

    if ! getent group "$grupo" > /dev/null; then
        sudo groupadd "$grupo"
        echo "Grupo $grupo creado."
    fi

    if ! id "$usuario" > /dev/null 2>&1; then
        sudo useradd -m -g "$grupo" "$usuario"
        echo "$usuario:$clave_encriptada" | sudo chpasswd -e
        echo "Usuario $usuario creado y asignado al grupo $grupo."
    else
        echo "El usuario $usuario ya existe, omitiendo."
    fi
done < "$archivo_lista"

echo "Procesamiento completo."

