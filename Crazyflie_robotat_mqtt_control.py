import json
import time
import threading
import paho.mqtt.client as mqtt
import matplotlib.pyplot as plt
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.crazyflie.high_level_commander import HighLevelCommander
import cflib.crtp
from datetime import datetime, timezone

# -------------------------------------------------------
# CONFIGURACIÓN
# -------------------------------------------------------
URI = "radio://0/80/2M/E7E7E7E7E9"
MQTT_TOPIC = 'mocap/drone2'
MQTT_BROKER = '192.168.50.200'
PORT = 1880

# -------------------------------------------------------
# VARIABLES GLOBALES
# -------------------------------------------------------
mocap_pose = {'x': 0.0, 'y': 0.0, 'z': 0.0}
real_trajectory = []
cf = None
last_ts = None

# Posición del marker 90 (objetivo), puede comentarlo para probarlo sin un marker como destino.
marker90 = {'x': 0.131, 'y': -1.032, 'z': 0.012}


# -------------------------------------------------------
# CALLBACK MQTT
# -------------------------------------------------------
def on_message(client, userdata, msg):
    global mocap_pose, cf, last_ts
    try:
        data = json.loads(msg.payload.decode())
        pos = data['payload']['pose']['position']
        ts_str = data.get('ts', None)

        if ts_str is not None:
            msg_time = datetime.fromisoformat(ts_str.replace('Z', '+00:00'))
            if last_ts is not None and msg_time <= last_ts:
                return
            last_ts = msg_time

        mocap_pose['x'] = float(pos['x'])
        mocap_pose['y'] = float(pos['y'])
        mocap_pose['z'] = float(pos['z'])

        # Actualizar EKF con posición del MoCap
        if cf is not None:
            cf.extpos.send_extpos(
                mocap_pose['x'], mocap_pose['y'], mocap_pose['z']
            )

        # Guardar trayectoria real
        real_trajectory.append([mocap_pose['x'], mocap_pose['y'], mocap_pose['z']])

    except Exception as e:
        print("Error en MQTT:", e)


def start_mqtt():
    client = mqtt.Client()
    client.on_message = on_message
    client.connect(MQTT_BROKER, PORT, 60)
    client.subscribe(MQTT_TOPIC)
    client.loop_forever()


## -------------------------------------------------------
# TRAJECTORIA SIMPLE (takeoff -> linear -> land)
# -------------------------------------------------------
#def fly_linear_trajectory(cf):
#    global theoretical_trajectory, mocap_pose

#    commander = HighLevelCommander(cf)

    # Esperar a tener una posición inicial válida del MoCap
#    print("Esperando posición inicial del MoCap...")
#    while mocap_pose['x'] == 0.0 and mocap_pose['y'] == 0.0 and mocap_pose['z'] == 0.0:
#        time.sleep(0.1)

    # Posición inicial (desde MoCap)
#    x0, y0, z0 = mocap_pose['x'], mocap_pose['y'], mocap_pose['z']
#    print(f"Posición inicial detectada: x={x0:.2f}, y={y0:.2f}, z={z0:.2f}")

#    # Configuración de trayectoria
#    hover_height = 0.5
#    N = 6
#    dx = 0.0  # desplazamiento total en X
#    dy = -1.0  # desplazamiento total en Y
#    dz = 0.0  # desplazamiento total en Z (mantener altura)

    # --- Generar trayectoria teórica antes del vuelo ---
#    xs = [x0 + i * dx / (N - 1) for i in range(N)]
#    ys = [y0 + i * dy / (N - 1) for i in range(N)]
#    zs = [z0 + hover_height + i * dz / (N - 1) for i in range(N)]
#    theoretical_trajectory = [[xs[i], ys[i], zs[i]] for i in range(N)]

#    # Despegue
#    print("Despegando...")
#    commander.takeoff(hover_height, 3.0)
#    time.sleep(3.5)

    # --- Ejecutar trayectoria lineal ---
#    print("Ejecutando trayectoria lineal...")
#    for i in range(N):
#        commander.go_to(xs[i], ys[i], zs[i], 0.0, 0.5, relative=False)
#        time.sleep(0.5)

#    # Hover final
#    print("Hover final...")
#    time.sleep(2.0)

#    # Aterrizaje
#    print("Aterrizando...")
#    commander.land(0.0, 3.0)
#    time.sleep(3.0)
#    commander.stop()##


# -------------------------------------------------------
# VUELO HACIA EL MARKER 90 (Puede poner cualquier trayectoria)
# -------------------------------------------------------
def fly_to_marker(cf):
    global mocap_pose, marker90
    commander = HighLevelCommander(cf)

    print("Esperando posición inicial del MoCap...")
    while mocap_pose['x'] == 0.0 and mocap_pose['y'] == 0.0 and mocap_pose['z'] == 0.0:
        time.sleep(0.1)

    x0, y0, z0 = mocap_pose['x'], mocap_pose['y'], mocap_pose['z']
    print(f"Posición inicial: x={x0:.3f}, y={y0:.3f}, z={z0:.3f}")

    hover_height = 0.5
    target_x, target_y, target_z = marker90['x'], marker90['y'], hover_height

    # Despegue
    print("Despegando...")
    commander.takeoff(hover_height, 3.0)
    time.sleep(3.5)

    # Ir al marker 90 (manteniendo altura)
    print(f"Volando hacia marker 90: ({target_x:.3f}, {target_y:.3f})")
    commander.go_to(target_x, target_y, target_z, 0.0, 0.6, relative=False)
    time.sleep(4.0)

    # Hover un momento
    print("Hover en destino...")
    time.sleep(2.0)

    # Aterrizar en la posición del marker 90
    print("Aterrizando...")
    commander.land(0.0, 2.0)
    time.sleep(3.0)
    commander.stop()


# -------------------------------------------------------
# GRAFICAR
# -------------------------------------------------------
def plot_trajectory():
    import numpy as np
    if len(real_trajectory) == 0:
        print("No se registró trayectoria real.")
        return
    real = np.array(real_trajectory)
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.plot(real[:, 0], real[:, 1], real[:, 2] - 0.024, 'b', label='Trayectoria real (MoCap)')
    ax.scatter(marker90['x'], marker90['y'], marker90['z'], c='r', s=60, label='Marker 90')
    ax.set_xlim([-2, 2])
    ax.set_ylim([-2, 2])
    ax.set_zlim([0, 1])
    ax.set_xlabel('X [m]')
    ax.set_ylabel('Y [m]')
    ax.set_zlabel('Z [m]')
    ax.legend()
    plt.title("Trayectoria del dron hacia el marker 90")
    plt.show()


# -------------------------------------------------------
# MAIN
# -------------------------------------------------------
def main():
    global cf
    cflib.crtp.init_drivers()

    mqtt_thread = threading.Thread(target=start_mqtt, daemon=True)
    mqtt_thread.start()

    print("Conectando al dron...")
    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache='./cache')) as scf:
        cf = scf.cf
        print("Conectado correctamente.")

        cf.param.set_value('stabilizer.estimator', '2')
        print("Reiniciando estimador Kalman...")
        cf.param.set_value('kalman.resetEstimation', '1')
        time.sleep(0.1)
        cf.param.set_value('kalman.resetEstimation', '0')
        print("Estimador reiniciado.")
        time.sleep(3.0)

        # Volar hacia el marker 90
        fly_to_marker(cf)

    # Graficar resultados
    plot_trajectory()


# -------------------------------------------------------
if __name__ == '__main__':
    main()
