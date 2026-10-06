# Guía interactiva de metodologías de desarrollo de software

## Datos académicos

| Campo | Detalle |
|---|---|
| **Universidad** | Universidad Autónoma de Chihuahua |
| **Facultad** | Facultad de Ingeniería |
| **Carrera** | Ingeniería en Computación |
| **Materia** | Desarrollo Basado en Plataformas |
| **Docente** | Mtro. Luis Antonio Ramírez Martínez |
| **Actividad** | Proyecto del Primer Parcial. Guía interactiva de metodologías de desarrollo de software |
| **Grupo** | 6CC2 |
| **Fecha de entrega** | 08/10/2026 |

### Integrantes del equipo

| Nombre completo | Matrícula |
|---|---|
| Daniel Emiliano Jimenez Frade | 376976 |
| Juan David Rocha Montelongo | 367910 |
| carlos ubaldo dominguez valles | 367633 |

## Descripción

Aplicación de terminal escrita en Bash que permite consultar y administrar información sobre metodologías de desarrollo de software, tanto ágiles (Scrum, XP, Kanban y Crystal) como tradicionales (Cascada, Espiral y Modelo V).

La aplicación se maneja mediante menús interactivos. Para cada metodología se dispone de una base de información propia (archivo `.inf`) en la que se pueden agregar, buscar, eliminar y leer conceptos con sus definiciones.

## Objetivo

Integrar los conocimientos adquiridos durante el primer parcial: Bash scripting, manejo de archivos, expresiones regulares, control de versiones con Git de forma colaborativa y empaquetado con Docker, mediante el desarrollo de una aplicación interactiva publicada como imagen en Docker Hub.

## Tecnologías utilizadas

- Bash (script principal `app.sh`)
- `grep` y `sed` (búsqueda y manejo de expresiones regulares)
- Git y GitHub (control de versiones y trabajo colaborativo)
- Docker y Docker Hub (empaquetado y publicación de la imagen)

## Requisitos previos

- Bash 4 o superior (Linux, macOS, WSL o Git Bash en Windows)
- Git
- Docker (solo para ejecutar la aplicación en contenedor)
- Cuenta de Docker Hub (solo si se desea publicar una imagen propia)

## Instalación

### Opción 1: desde el repositorio

```bash
git clone https://github.com/DanielEmilianoJF/Proyecto-Parcial-1-DBP.git
cd Proyecto-Parcial-1-DBP
chmod +x app.sh
```

### Opción 2: construir la imagen localmente

```bash
git clone https://github.com/DanielEmilianoJF/Proyecto-Parcial-1-DBP.git
cd Proyecto-Parcial-1-DBP
docker build -t a367633-ctrl/guia-metodologias:1.0 .
```

### Opción 3: descargar la imagen publicada en Docker Hub

No requiere clonar el repositorio:

```bash
docker pull a367633-ctrl/guia-metodologias:1.0
```

Imagen en Docker Hub: [https://hub.docker.com/r/a367633-ctrl/guia-metodologias](https://hub.docker.com/r/a367633-ctrl/guia-metodologias)

## Ejecución

La aplicación **requiere un parámetro obligatorio** que indica el tipo de metodología.

### Con Bash

```bash
./app.sh -a    # Metodologías ágiles
./app.sh -t    # Metodologías tradicionales
```

### Con Docker

La aplicación es interactiva, por lo que el contenedor debe iniciarse con `-it`:

```bash
docker run -it a367633-ctrl/guia-metodologias:1.0        # ágiles (-a, valor por defecto)
docker run -it a367633-ctrl/guia-metodologias:1.0 -t     # tradicionales
```

Los cambios hechos a los archivos `.inf` dentro del contenedor se pierden al eliminarlo. Para conservarlos, se puede montar la carpeta `datos/` del repositorio clonado:

```bash
docker run -it -v "$(pwd)/datos:/app/datos" a367633-ctrl/guia-metodologias:1.0 -a
```

## Scripts / comandos disponibles

| Comando | Descripción |
|---|---|
| `./app.sh -a` | Inicia la guía de metodologías ágiles (Scrum, XP, Kanban, Crystal). |
| `./app.sh -t` | Inicia la guía de metodologías tradicionales (Cascada, Espiral, Modelo V). |
| `docker build -t <imagen> .` | Construye la imagen Docker de la aplicación. |
| `docker run -it <imagen> [-a \| -t]` | Ejecuta la aplicación dentro de un contenedor. |

Si no se indica parámetro, o se indica uno no reconocido, la aplicación muestra un mensaje de uso y termina con código de error.

## Funcionalidades / uso

1. **Menú principal:** según el parámetro (`-a` o `-t`) se muestra la lista de metodologías disponibles.
2. **Submenú por metodología:** al elegir un tema se muestra la sección en la que se encuentra el usuario y las siguientes opciones:
   - **Agregar información:** solicita un concepto y su definición y los agrega al archivo `.inf` correspondiente sin borrar los registros existentes.
   - **Buscar información:** localiza un concepto mediante expresiones regulares e indica claramente si no existe.
   - **Eliminar información:** comprueba que el concepto exista y elimina únicamente ese registro.
   - **Leer base de información:** muestra todo el contenido del archivo `.inf`.
3. **Continuidad de ejecución:** después de cada operación el usuario puede ejecutar otra operación en la misma metodología, volver al menú anterior o salir. La aplicación solo termina cuando el usuario lo decide.

### Formato de los archivos `.inf`

Cada registro ocupa una sola línea con el formato:

```text
[concepto] .- Definición.
```

Cada metodología utiliza su propio archivo: `scrum.inf`, `xp.inf`, `kanban.inf`, `crystal.inf`, `cascada.inf`, `espiral.inf` y `modelo-v.inf`.

## Estructura general del proyecto

```text
Proyecto-Parcial-1-DBP/
|-- app.sh              # Script principal (parámetros, menús y operaciones)
|-- Dockerfile          # Definición de la imagen Docker
|-- datos/
|   |-- scrum.inf
|   |-- xp.inf
|   |-- kanban.inf
|   |-- crystal.inf
|   |-- cascada.inf
|   |-- espiral.inf
|   `-- modelo-v.inf
`-- README.md
```

## Autores

- Daniel Emiliano Jimenez Frade — 376976
- Juan David Rocha Montelongo — 367910
- carlos ubaldo dominguez valles — 367633
