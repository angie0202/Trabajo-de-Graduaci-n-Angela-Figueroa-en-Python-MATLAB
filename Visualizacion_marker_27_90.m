%% =========================================================================
% VISUALIZACIÓN EN TIEMPO REAL DE MARKERS EN ROBOTAT (versión robusta)
% -------------------------------------------------------------------------
% - Marker 27 (verde, círculo) deja trayectoria acumulada (línea azul)
% - Marker 90 (rojo, cuadrado) muestra posición actual
% - Se dibuja línea negra entre ambos markers
% - Recupera objetos si son eliminados
% =========================================================================

clear; clc; close all;

%% === CONEXIÓN CON ROBOTAT ===
robotat = robotat_connect();
if isempty(robotat)
    error(' No se pudo conectar al servidor Robotat.');
else
    disp(' Conectado correctamente al servidor Robotat.');
end

%% === DEFINICIÓN DE MARKERS ===
id_inicio = 27;
id_destino = 90;

%% === CONFIGURACIÓN DE LA FIGURA ===
fig = figure('Name', 'Visualización en tiempo real de markers Robotat');
hold on; grid on; axis equal;
xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
title('Trayectoria del Marker 27 y conexión con Marker 90');
view(45, 45);

% Crear objetos iniciales
p_inicio = plot3(nan, nan, nan, 'go', 'MarkerFaceColor', 'g', 'DisplayName', 'Marker 27');
p_destino = plot3(nan, nan, nan, 'rs', 'MarkerFaceColor', 'r', 'DisplayName', 'Marker 90');
trayectoria = plot3(nan, nan, nan, 'b-', 'LineWidth', 2, 'DisplayName', 'Ruta Marker 27');
conexion = plot3(nan, nan, nan, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Conexión 27→90');

legend('show', 'Location', 'best');

%% === VARIABLES PARA GUARDAR LA RUTA DEL MARKER 27 ===
rutaX = [];
rutaY = [];
rutaZ = [];

disp('Iniciando visualización en tiempo real... (Ctrl+C para detener)');

%% === BUCLE PRINCIPAL ===
while true
    if ~ishandle(fig)
        disp(' Figura cerrada. Terminando...');
        break;
    end

    % Obtiene las poses seguras
    pose_inicio = safe_get_pose(robotat, id_inicio);
    pose_destino = safe_get_pose(robotat, id_destino);

    % === Si ambos markers son visibles ===
    if ~isempty(pose_inicio) && ~isempty(pose_destino)
        punto_inicio = pose_inicio(1:3);
        punto_destino = pose_destino(1:3);

        % Acumula los puntos del marker 27
        rutaX(end+1) = punto_inicio(1);
        rutaY(end+1) = punto_inicio(2);
        rutaZ(end+1) = punto_inicio(3);

        % === Verifica y recrea los objetos si se eliminaron ===
        if ~ishandle(p_inicio)
            p_inicio = plot3(nan, nan, nan, 'go', 'MarkerFaceColor', 'g');
        end
        if ~ishandle(p_destino)
            p_destino = plot3(nan, nan, nan, 'rs', 'MarkerFaceColor', 'r');
        end
        if ~ishandle(trayectoria)
            trayectoria = plot3(nan, nan, nan, 'b-', 'LineWidth', 2);
        end
        if ~ishandle(conexion)
            conexion = plot3(nan, nan, nan, 'k--', 'LineWidth', 1.5);
        end

        % === Actualiza los objetos (protegido por try) ===
        try
            set(p_inicio, 'XData', punto_inicio(1), 'YData', punto_inicio(2), 'ZData', punto_inicio(3));
            set(p_destino, 'XData', punto_destino(1), 'YData', punto_destino(2), 'ZData', punto_destino(3));
            set(trayectoria, 'XData', rutaX, 'YData', rutaY, 'ZData', rutaZ);
            set(conexion, 'XData', [punto_inicio(1) punto_destino(1)], ...
                          'YData', [punto_inicio(2) punto_destino(2)], ...
                          'ZData', [punto_inicio(3) punto_destino(3)]);
        catch
            % Si falla una actualización, recrea los objetos y continúa
            disp('Error leve, recreando objetos gráficos...');
            p_inicio = plot3(punto_inicio(1), punto_inicio(2), punto_inicio(3), 'go', 'MarkerFaceColor', 'g');
            p_destino = plot3(punto_destino(1), punto_destino(2), punto_destino(3), 'rs', 'MarkerFaceColor', 'r');
            trayectoria = plot3(rutaX, rutaY, rutaZ, 'b-', 'LineWidth', 2);
            conexion = plot3([punto_inicio(1) punto_destino(1)], ...
                             [punto_inicio(2) punto_destino(2)], ...
                             [punto_inicio(3) punto_destino(3)], ...
                             'k--', 'LineWidth', 1.5);
        end
    else
        disp('Esperando markers visibles...');
    end

    drawnow limitrate nocallbacks;
    pause(0.05);
end

%% === DESCONECTAR ===
robotat_disconnect(robotat);
disp('🔌 Conexión cerrada.');

%% === FUNCIÓN LOCAL SEGURA ===
function pose = safe_get_pose(robotat, id)
    pose = [];
    try
        pose = robotat_get_pose(robotat, id);
        if isempty(pose)
            pose = [];
        end
    catch
        % Ignora errores de conexión o visibilidad
    end
end
