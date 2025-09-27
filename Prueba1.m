% =========================================================================
% EXPERIMENTOS CON CRAZYFLIE 2.1
% -------------------------------------------------------------------------
% Experimento 2 modificado: Despegue, avance recto y aterrizaje
% =========================================================================

%% Parte 1: Carpeta con herramientas de software para interacción con Crazyflie
addpath('crazyflie');

%% Parte 2: Secuencia del experimento
altura_de_despegue = 0.30; % altura de vuelo (m)
tiempo_de_despegue = 0.75; % tiempo de despegue (s)
distancia_x = 0.3;        % avance recto en X (m)
velocidad_vuelo = 0.1;    % velocidad lenta para estabilidad
tiempo_estable = 3;        % tiempo de espera en el aire antes de avanzar

% Conexión con Crazyflie
dron_id = 8; 
cf = crazyflie_connect(dron_id);

%% Despegue
disp('Despegando...');
crazyflie_takeoff(cf, altura_de_despegue, tiempo_de_despegue); 
pause(tiempo_de_despegue + tiempo_estable); % esperar estabilización

%% Avance recto en X
disp('Avanzando en línea recta...');
crazyflie_move_to_position(cf, distancia_x, 0, altura_de_despegue, velocidad_vuelo);
pause(distancia_x/velocidad_vuelo + 1); % esperar a completar el movimiento

%% Aterrizaje
disp('Aterrizando...');
crazyflie_land(cf); 
pause(altura_de_despegue/velocidad_vuelo + 1); % esperar a aterrizar completamente

%% Desconexión
crazyflie_disconnect(cf); 
disp('Vuelo terminado.');