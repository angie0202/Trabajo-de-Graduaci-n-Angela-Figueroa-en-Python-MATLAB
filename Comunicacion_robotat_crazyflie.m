% =========================================================================
% CRAZYFLIE 2.1 + FLOW DECK + ROBOTAT
% -------------------------------------------------------------------------
% Vuelo: Despegue MUY suave, vuelo recto corto y aterrizaje despacio
% Visualización: posición (x, y, z) en tiempo real
% Marker: 27 | Dron ID: 8
% =========================================================================

addpath('crazyflie');
addpath('robotat');

%% Parámetros de vuelo
altura_de_despegue = 0.25;    % altura de vuelo (m)
tiempo_de_despegue = 4.0;     % tiempo de despegue suave (s)
distancia_x = 0.01;           % avance muy corto (m)
velocidad_vuelo = 0.03;       % vuelo lento (m/s)
tiempo_estable = 3.0;         % tiempo en hover antes de avanzar (s)
tiempo_hover_final = 2.0;     % hover antes de aterrizar (s)
tiempo_aterrizaje = 4.0;      % aterrizaje lento (s)

marker_id = 27;
robotat = robotat_connect();

%% Conexión con Crazyflie
dron_id = 8;
cf = crazyflie_connect(dron_id);

%% Inicializar gráfica
figure('Name', 'Monitoreo Crazyflie - Robotat', 'NumberTitle', 'off');
ax = axes;
grid(ax, 'on');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
xlim([-0.5 0.5]);
ylim([-0.5 0.5]);
zlim([0 0.4]);
view(45,30);
hold on;
h_marker = plot3(0,0,0,'bo','MarkerFaceColor','b');
h_traj = plot3(0,0,0,'r-','LineWidth',1.2);
title('Trayectoria en tiempo real del dron');
poses = [];

update_plot = @(pose) set(h_marker, 'XData', pose(1), 'YData', pose(2), 'ZData', pose(3));

%% ==============================================================
% ETAPA 1: Confirmar detección del marker ANTES de volar
% ==============================================================

disp('Esperando detección del marker del dron (ID 27)...');
disp('Mueve un poco el dron si no aparece en el gráfico.');
disp('Presiona ENTER cuando veas que el marker se actualiza correctamente.');

while true
    pose = robotat_get_pose(robotat, marker_id);
    if ~isempty(pose)
        poses = [poses; pose(1:3)];
        update_plot(pose);
        set(h_traj, 'XData', poses(:,1), 'YData', poses(:,2), 'ZData', poses(:,3));
        fprintf('[DETECCIÓN] x=%.3f, y=%.3f, z=%.3f\n', pose(1), pose(2), pose(3));
    else
        fprintf('[SIN DETECCIÓN]\n');
    end
    pause(0.2);

    % Si el usuario presiona ENTER, continúa al vuelo
    if get(gcf,'CurrentCharacter') == char(13)
        break;
    end
end
clc;  % limpia pantalla para iniciar vuelo

%% ==============================================================
% ETAPA 2: Despegue suave
% ==============================================================

disp('Despegando suavemente...');
crazyflie_takeoff(cf, altura_de_despegue, tiempo_de_despegue);
t_hover = tic;
while toc(t_hover) < tiempo_de_despegue
    pose = robotat_get_pose(robotat, marker_id);
    if ~isempty(pose)
        poses = [poses; pose(1:3)];
        update_plot(pose);
        set(h_traj, 'XData', poses(:,1), 'YData', poses(:,2), 'ZData', poses(:,3));
        fprintf('[Despegue] x=%.3f, y=%.3f, z=%.3f\n', pose(1), pose(2), pose(3));
    end
    pause(0.1);
end

%% Hover estable
disp('Estabilizando...');
t_hover = tic;
while toc(t_hover) < tiempo_estable
    pose = robotat_get_pose(robotat, marker_id);
    if ~isempty(pose)
        poses = [poses; pose(1:3)];
        update_plot(pose);
        set(h_traj, 'XData', poses(:,1), 'YData', poses(:,2), 'ZData', poses(:,3));
        fprintf('[Hover] x=%.3f, y=%.3f, z=%.3f\n', pose(1), pose(2), pose(3));
    end
    pause(0.1);
end

%% Avance recto muy corto
disp('Avanzando suavemente...');
crazyflie_move_to_position(cf, distancia_x, 0, altura_de_despegue, velocidad_vuelo);
t_move = tic;
while toc(t_move) < distancia_x/velocidad_vuelo + 1
    pose = robotat_get_pose(robotat, marker_id);
    if ~isempty(pose)
        poses = [poses; pose(1:3)];
        update_plot(pose);
        set(h_traj, 'XData', poses(:,1), 'YData', poses(:,2), 'ZData', poses(:,3));
        fprintf('[Vuelo] x=%.3f, y=%.3f, z=%.3f\n', pose(1), pose(2), pose(3));
    end
    pause(0.1);
end

%% Hover final antes de aterrizar
disp('Hover antes de aterrizar...');
t_hover = tic;
while toc(t_hover) < tiempo_hover_final
    pose = robotat_get_pose(robotat, marker_id);
    if ~isempty(pose)
        poses = [poses; pose(1:3)];
        update_plot(pose);
        set(h_traj, 'XData', poses(:,1), 'YData', poses(:,2), 'ZData', poses(:,3));
        fprintf('[Hover final] x=%.3f, y=%.3f, z=%.3f\n', pose(1), pose(2), pose(3));
    end
    pause(0.1);
end

%% Aterrizaje muy suave
disp('Aterrizando muy despacio...');
crazyflie_land(cf, 0.0, tiempo_aterrizaje);
t_land = tic;
while toc(t_land) < tiempo_aterrizaje
    pose = robotat_get_pose(robotat, marker_id);
    if ~isempty(pose)
        poses = [poses; pose(1:3)];
        update_plot(pose);
        set(h_traj, 'XData', poses(:,1), 'YData', poses(:,2), 'ZData', poses(:,3));
        fprintf('[Aterrizaje] x=%.3f, y=%.3f, z=%.3f\n', pose(1), pose(2), pose(3));
    end
    pause(0.1);
end

%% Desconexión
crazyflie_disconnect(cf);
robotat_disconnect(robotat);
disp('Vuelo terminado.');
