#!/bin/bash
# =====================================================================
# Guía interactiva de metodologías de desarrollo de software
#
# Uso:
#   ./app.sh -a   Metodologías ágiles (Scrum, XP, Kanban, Crystal)
#   ./app.sh -t   Metodologías tradicionales (Cascada, Espiral, Modelo V)
# =====================================================================

DIR_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_DATOS="$DIR_BASE/datos"

# ---------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------

uso() {
    echo "Uso: ./app.sh {-a | -t}"
    echo "  -a   Guía rápida de metodologías ágiles"
    echo "  -t   Guía rápida de metodologías tradicionales"
}

# leer "mensaje" variable
# Lee una línea del usuario. Si se cierra la entrada (Ctrl+D), termina.
leer() {
    local mensaje="$1" nombre_var="$2" valor
    printf '%s' "$mensaje"
    if ! read -r valor; then
        echo
        echo "Entrada finalizada. ¡Hasta luego!"
        exit 0
    fi
    printf -v "$nombre_var" '%s' "$valor"
}

# Elimina espacios al inicio y al final de una cadena
recortar() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# Escapa los caracteres especiales de expresiones regulares (BRE)
escapar_regex() {
    printf '%s' "$1" | sed 's/[][\.*^$]/\\&/g'
}

# ---------------------------------------------------------------------
# Operaciones sobre el archivo .inf
# Formato de cada registro (una sola línea):  [concepto] .- Definición.
# ---------------------------------------------------------------------

agregar_info() {
    local archivo="$1" concepto definicion esc
    leer "Concepto: " concepto
    concepto="$(recortar "$concepto")"
    leer "Definición: " definicion
    definicion="$(recortar "$definicion")"

    if [ -z "$concepto" ] || [ -z "$definicion" ]; then
        echo "El concepto y la definición no pueden estar vacíos."
        return
    fi
    case "$concepto" in
        *\[*|*\]*) echo "El concepto no puede contener corchetes."; return ;;
    esac

    esc="$(escapar_regex "$concepto")"
    if grep -qi "^\[$esc\]" "$archivo"; then
        echo "El concepto '$concepto' ya existe. Elimínelo primero si desea reemplazarlo."
        return
    fi

    [[ "$definicion" == *. ]] || definicion="$definicion."

    # Si el archivo no termina en salto de línea, se agrega uno
    if [ -s "$archivo" ] && [ -n "$(tail -c1 "$archivo")" ]; then
        echo >> "$archivo"
    fi

    # >> agrega al final sin borrar los registros existentes
    echo "[$concepto] .- $definicion" >> "$archivo"
    echo "Registro agregado correctamente."
}

buscar_info() {
    local archivo="$1" concepto esc resultado
    leer "Concepto a buscar: " concepto
    concepto="$(recortar "$concepto")"
    if [ -z "$concepto" ]; then
        echo "Debe escribir un concepto."
        return
    fi

    esc="$(escapar_regex "$concepto")"
    # ^ = inicio de línea, \[ \] = corchetes literales, -i = sin distinguir mayúsculas
    resultado="$(grep -i "^\[$esc\]" "$archivo")"

    if [ -n "$resultado" ]; then
        echo
        echo "$resultado"
    else
        echo "El concepto '$concepto' no existe en esta sección."
    fi
}

eliminar_info() {
    local archivo="$1" concepto esc tmp
    leer "Concepto a eliminar: " concepto
    concepto="$(recortar "$concepto")"
    if [ -z "$concepto" ]; then
        echo "Debe escribir un concepto."
        return
    fi

    esc="$(escapar_regex "$concepto")"
    if ! grep -qi "^\[$esc\]" "$archivo"; then
        echo "El concepto '$concepto' no existe en esta sección."
        return
    fi

    # grep -v deja pasar todas las líneas EXCEPTO la del concepto
    tmp="$(mktemp)"
    grep -vi "^\[$esc\]" "$archivo" > "$tmp"
    cat "$tmp" > "$archivo"
    rm -f "$tmp"
    echo "Registro '$concepto' eliminado correctamente."
}

leer_base() {
    local archivo="$1"
    echo
    if [ -s "$archivo" ]; then
        cat "$archivo"
    else
        echo "La base de información está vacía."
    fi
}

# ---------------------------------------------------------------------
# Navegación
# ---------------------------------------------------------------------

# Devuelve 0 si el usuario quiere permanecer, 1 si quiere volver. Salir termina el programa.
preguntar_continuidad() {
    local resp
    while true; do
        echo
        echo "¿Qué desea hacer ahora?"
        echo "1. Ejecutar otra operación (permanecer en esta metodología)"
        echo "2. Volver al menú anterior"
        echo "3. Salir"
        leer "Opción: " resp
        case "$resp" in
            1) return 0 ;;
            2) return 1 ;;
            3) echo "¡Hasta luego!"; exit 0 ;;
            *) echo "Opción no válida." ;;
        esac
    done
}

# submenu "Nombre de la sección" archivo.inf
submenu() {
    local nombre="$1" archivo="$DIR_DATOS/$2" opcion
    mkdir -p "$DIR_DATOS"
    [ -f "$archivo" ] || touch "$archivo"

    while true; do
        echo
        echo "Usted está en la sección $nombre,"
        echo "seleccione la opción que desea utilizar."
        echo "1. Agregar información"
        echo "2. Buscar información"
        echo "3. Eliminar información"
        echo "4. Leer base de información"
        leer "Opción: " opcion

        case "$opcion" in
            1) agregar_info "$archivo" ;;
            2) buscar_info "$archivo" ;;
            3) eliminar_info "$archivo" ;;
            4) leer_base "$archivo" ;;
            *) echo "Opción no válida."; continue ;;
        esac

        preguntar_continuidad || return 0
    done
}

# menu_temas "Línea de bienvenida," "Nombre 1" archivo1.inf "Nombre 2" archivo2.inf ...
menu_temas() {
    local bienvenida="$1"; shift
    local -a nombres=() archivos=()
    local i opcion

    while [ $# -gt 0 ]; do
        nombres+=("$1")
        archivos+=("$2")
        shift 2
    done

    while true; do
        echo
        echo "$bienvenida"
        echo "para continuar seleccione un tema:"
        for i in "${!nombres[@]}"; do
            echo "$((i + 1)). ${nombres[$i]}"
        done
        echo "0. Salir"
        leer "Opción: " opcion

        if [ "$opcion" = "0" ]; then
            echo "¡Hasta luego!"
            exit 0
        elif [[ "$opcion" =~ ^[0-9]+$ ]] && [ "$opcion" -ge 1 ] && [ "$opcion" -le "${#nombres[@]}" ]; then
            submenu "${nombres[$((opcion - 1))]}" "${archivos[$((opcion - 1))]}"
        else
            echo "Opción no válida."
        fi
    done
}

menu_agil() {
    menu_temas "Bienvenido a la guía rápida de Agile," \
        "SCRUM" "scrum.inf" \
        "XP (Programación Extrema)" "xp.inf" \
        "Kanban" "kanban.inf" \
        "Crystal" "crystal.inf"
}

menu_tradicional() {
    menu_temas "Bienvenido a la guía rápida de metodologías tradicionales," \
        "Cascada" "cascada.inf" \
        "Espiral" "espiral.inf" \
        "Modelo V" "modelo-v.inf"
}

# ---------------------------------------------------------------------
# Programa principal: validación de parámetros
# ---------------------------------------------------------------------

if [ $# -eq 0 ]; then
    echo "Error: debe indicar un parámetro."
    uso
    exit 1
elif [ $# -gt 1 ]; then
    echo "Error: solo se permite un parámetro."
    uso
    exit 1
fi

case "$1" in
    -a) menu_agil ;;
    -t) menu_tradicional ;;
    *)
        echo "Error: parámetro no reconocido '$1'."
        uso
        exit 1
        ;;
esac
