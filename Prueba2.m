% =========================================================================
% CRAZYFLIE 2.1 + FLOW DECK + ROBOTAT
% -------------------------------------------------------------------------
% Vuelo: Despegue, vuelo recto lento y aterrizaje
% Monitoreo en consola: datos del marker 27 desde Robotat
% =========================================================================

addpath('crazyflie');
addpath('robotat');   % carpeta con las funciones de Robotat

%% Parámetros de vuelo
altura_de_despegue = 0.30; % altura de vuelo (m)
tiempo_de_despegue = 1.5;  % más lento para estabilidad (s)
distancia_x = 0.3;         % avance recto en X (m)
velocidad_vuelo = 0.05;    % más lento para mayor control (m/s)
tiempo_estable = 2;        % esperar en el aire antes de moverse (s)

% Parámetros de Robotat
marker_id = 27;  % ID del marker en el dron
robotat = robotat_connect();

%% Conexión con Crazyflie
dron_id = 8;
cf = crazyflie_connect(dron_id);

%% Despegue
disp('Despegando...');
crazyflie_takeoff(cf, altura_de_despegue, tiempo_de_despegue); 
pause(tiempo_de_despegue); 

% ---- Monitoreo Robotat durante hover ----
disp('Monitoreando Robotat...');
t_hover = tic;
while toc(t_hover) < tiempo_estable
    pose = robotat_get_pose(robotat, marker_id); % [x y z qw qx qy qz]
    if ~isempty(pose)
        fprintf('[Hover] x=%.3f, y=%.3f, z=%.3f\n', pose(1), pose(2), pose(3));
    else
        fprintf('[Hover] Sin datos Robotat\n');
    end
    pause(0.1); % muestreo ~10 Hz
end

%% Avance recto en X con monitoreo
disp('Avanzando en línea recta...');
crazyflie_move_to_position(cf, distancia_x, 0, altura_de_despegue, velocidad_vuelo);

tiempo_mov = distancia_x/velocidad_vuelo + 1; % tiempo estimado de movimiento
t_move = tic;
while toc(t_move) < tiempo_mov
    pose = robotat_get_pose(robotat, marker_id);
    if ~isempty(pose)
        fprintf('[Vuelo] x=%.3f, y=%.3f, z=%.3f\n', pose(1), pose(2), pose(3));
    else
        fprintf('[Vuelo] Sin datos Robotat\n');
    end
    pause(0.1);
end

%% Aterrizaje con monitoreo
disp('Aterrizando...');
crazyflie_land(cf);
tiempo_land = altura_de_despegue/velocidad_vuelo + 1;
t_land = tic;
while toc(t_land) < tiempo_land
    pose = robotat_get_pose(robotat, marker_id);
    if ~isempty(pose)
        fprintf('[Aterrizaje] x=%.3f, y=%.3f, z=%.3f\n', pose(1), pose(2), pose(3));
    else
        fprintf('[Aterrizaje] Sin datos Robotat\n');
    end
    pause(0.1);
end

%% Desconexión
crazyflie_disconnect(cf);
robotat_disconnect(robotat);
disp('Vuelo terminado.');
