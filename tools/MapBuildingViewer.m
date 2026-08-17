%% Map Building Viewer Tool
%{

To be used when editing "DefineScenarios.m".

Instructions
1. Run core/DefineScenarios.m to load necessary variables to workspace
2. Set parameters in MapBuildingViewer.m
3. Run MapBuildingViewer.m to visualize

%}

%% Parameters
scenario = 'cor';   % Options: 'T', 'U', 'E', 'cor', 'rand'

%% Set Map

startRand = [S.(scenario).start_centre(1) + (rand()-0.5)*S.(scenario).start_spread(1), ...
                   S.(scenario).start_centre(2) + (rand()-0.5)*S.(scenario).start_spread(2), ...
                   S.(scenario).start_centre(3)];

goalRand       = [S.(scenario).goal_centre(1)  + (rand()-0.5)*S.(scenario).goal_spread(1), ...
                   S.(scenario).goal_centre(2)  + (rand()-0.5)*S.(scenario).goal_spread(2), ...
                   S.(scenario).goal_centre(3)];

InitialPosition     = startRand;
Waypoints           = goalRand;

ObstaclePositions  = S.(scenario).obstacles;

disp("Set Map");

%% Create UAV Scenario 
% 100hz, ENU coordinate system. East = X, North = Y, Up = Z
MyScenario = uavScenario("UpdateRate", 100, "ReferenceLocation", [0 0 0]);
disp("Created UAV Scenario");

%% Initiate UAV ownship

MyOwnship = uavPlatform("UAV", MyScenario,...   
                      "ReferenceFrame", "ENU",...
                      "InitialPosition", InitialPosition,...
                      "InitialOrientation", InitialOrientation);
updateMesh(MyOwnship,"quadrotor",{1.5},[0 0 1],eul2tform([0 0 pi]));

disp("Initated Ownship");

%% Initiate Lidar 

% Define Lidar system parameters
MaxRange = 7;
Horizontal_Res = 5;                 % Horizontal Resolution
Vertical_Res = 3;                   % Vertical Resolution
Horizontal_Limits = [-180 180];     % Horizontal FOV (deg)
Vertical_Limits = [-15 15];         % Vertical FOV (deg)     

% Load Lidar Parameters into Lidar Model
MyLidar = uavLidarPointCloudGenerator("UpdateRate",10, ...  % (Hz)
                                         "MaxRange",MaxRange, ...     % (m)
                                         "RangeAccuracy",3, ...
                                         "AzimuthResolution", Horizontal_Res, ...    % Horizontal Resolution
                                         "ElevationResolution",Vertical_Res, ...     % Vertical Resolution
                                         "AzimuthLimits",Horizontal_Limits, ...      % Horizontal FOV (deg)
                                         "ElevationLimits",Vertical_Limits, ...      % Vertical FOV (deg)                                 
                                         "HasOrganizedOutput",true);

% Create a Lidar Sensor and Mount to ownship
MySensor = uavSensor("Lidar",MyOwnship,MyLidar, ...
          "MountingLocation",[0 0 -0.4], ... 
          "MountingAngles",[0 0 0]);

disp("Created Lidar")

%% Build Map

% Waypoints
waypoints_colours = [1 0 0];
for i = 1:size(Waypoints,1)
    addMesh(MyScenario,"cylinder",{[Waypoints(i,1) Waypoints(i,2) 0.5] [(Waypoints(i, 3)-3.5) (Waypoints(i, 3)-3.4)]},waypoints_colours);
end

% Obstacles
obs_colours = [0.6 0.6 0.6];    % Gray
ObstacleHeight = 12;            % Height of the obstacles
ObstaclesWidth = 3;             % Width of the obstacles


% Randomize obstacles for rand scenario
if strcmp(scenario, 'rand')
    for i = 1:10
        S.rand.obstacles(i,:) = [S.rand.obs_centre(1) + (rand()-0.5)*S.rand.obs_spread(1), ...
                                  S.rand.obs_centre(2) + (rand()-0.5)*S.rand.obs_spread(2)];
    end
    ObstaclePositions = S.rand.obstacles;
end


for i = 1:size(ObstaclePositions,1)
    addMesh(MyScenario,"polygon", ...
        {[ObstaclePositions(i,1)-ObstaclesWidth/2 ObstaclePositions(i,2)-ObstaclesWidth/2; ...
        ObstaclePositions(i,1)+ObstaclesWidth/2 ObstaclePositions(i,2)-ObstaclesWidth/2; ...
        ObstaclePositions(i,1)+ObstaclesWidth/2 ObstaclePositions(i,2)+ObstaclesWidth/2; ...
        ObstaclePositions(i,1)-ObstaclesWidth/2 ObstaclePositions(i,2)+ObstaclesWidth/2], ...
        [0 ObstacleHeight]}, obs_colours);
end

disp("Built Map")

%% Viewer Plotting

show3D(MyScenario);
hold on;

% Start box
sc = S.(scenario).start_centre;
ss = S.(scenario).start_spread;
plot3([sc(1)-ss(1)/2, sc(1)+ss(1)/2, sc(1)+ss(1)/2, sc(1)-ss(1)/2, sc(1)-ss(1)/2], ...
      [sc(2)-ss(2)/2, sc(2)-ss(2)/2, sc(2)+ss(2)/2, sc(2)+ss(2)/2, sc(2)-ss(2)/2], ...
      repmat(sc(3),1,5), 'g--', 'LineWidth', 1.5);

% Goal box
gc = S.(scenario).goal_centre;
gs = S.(scenario).goal_spread;
plot3([gc(1)-gs(1)/2, gc(1)+gs(1)/2, gc(1)+gs(1)/2, gc(1)-gs(1)/2, gc(1)-gs(1)/2], ...
      [gc(2)-gs(2)/2, gc(2)-gs(2)/2, gc(2)+gs(2)/2, gc(2)+gs(2)/2, gc(2)-gs(2)/2], ...
      repmat(gc(3),1,5), 'r--', 'LineWidth', 1.5);

% Obstacle box (rand scenario only)
if strcmp(scenario, 'rand')
    oc = S.rand.obs_centre;
    os = S.rand.obs_spread;
    plot3([oc(1)-os(1)/2, oc(1)+os(1)/2, oc(1)+os(1)/2, oc(1)-os(1)/2, oc(1)-os(1)/2], ...
          [oc(2)-os(2)/2, oc(2)-os(2)/2, oc(2)+os(2)/2, oc(2)+os(2)/2, oc(2)-os(2)/2], ...
          repmat(sc(3),1,5), 'b--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
end

% Suppress all existing plot objects from legend
set(get(gca, 'Children'), 'HandleVisibility', 'off');

% Legend
plot3(nan, nan, nan, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Random Start Region');
plot3(nan, nan, nan, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Random Goal Region');
plot3(nan, nan, nan, 'b--', 'LineWidth', 1.5, 'DisplayName', 'Random Obstacle Region');
patch(nan, nan, [0.6 0.6 0.6], 'DisplayName', 'Obstacles');
legend('show', 'Location', 'best');

return;