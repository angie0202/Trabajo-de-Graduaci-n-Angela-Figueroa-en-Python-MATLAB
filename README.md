**Título del proyecto**
Desarrollo de infraestructura experimental para el dron CrazyFlie 2.1 en Ecosistema Robotat.

**Descripción general**
- Este proyecto desarrolla una infraestructura experimental para mejorar la eficiencia y seguridad del dron CrazyFlie 2.1 en el ecosistema Robotat.
- Incluye herramientas en Python/MATLAB para control autónomo y transmisión de datos mediante MQTT.
  
**Características principales**

- Control del dron CrazyFlie 2.1 desde Python.
- Comunicación mediante protocolo MQTT con Robotat.
- Integración con MATLAB para visualización y análisis de datos.
- Scripts de vuelo estable con y sin el uso del Flow Deck.

**Requisitos**

- Python 3.8 o superior
- Librerías: paho-mqtt, matplotlib, cflib, numpy, threading, json
- MATLAB (para visualización y procesamiento de datos)
- Crazyradio PA (para comunicación con el dron)
- Ecosistema Robotat activo con marker asignado

**Instrucciones de instalación**

- Clona este repositorio o descarga los archivos.
- Instala las dependencias con:

          *pip install -r requirements.txt*

- Conecta el CrazyFlie 2.1 y verifica que esté encendido.
- Configura el broker MQTT según la IP del Robotat.
- Ejecuta el script principal con:

          *python main_robotat.py*
**Uso**

- Ejecuta el script principal para iniciar la conexión con el dron.
- Verifica en consola los datos de posición y batería.
- Puedes modificar la posición objetivo (marker90) dentro del código para realizar vuelos personalizados.

**Resultados o demostración**

- El dron logra vuelos estables sin Flow Deck, utilizando únicamente retroalimentación de posición desde Robotat.
- Se validó la comunicación en tiempo real y la carga automática mediante el sistema Qi.
- Se incluyeron capturas de pruebas exitosas en la carpeta /results.

**Autores**

Angela Figueroa
Universidad del Valle de Guatemala
Proyecto de graduación — Ingeniería Mecatrónica


