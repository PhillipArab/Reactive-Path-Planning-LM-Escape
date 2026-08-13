%% DefineScenarios.m

%% Sim Parameters
UAVSampleTime       = 0.001;
Plot_decimation_1s  = 1/UAVSampleTime;
Gravity             = 9.8;
DroneMass           = 0.1;
TopSpeed            = 1;

% Position Loop Gains
kP_pos = 5;
kI_pos = 0;
kD_pos = 1;

% Velocity Loop Gains
kP_vel = 15;
kI_vel = 0;
kD_vel = 3;

% Filter
N_filter = 75;

%% Scenario Definitions

InitialOrientation = eul2quat([0 0 0]);  % All scenarios

% T Shape
S.T.start_centre = [11 5 7];
S.T.start_spread = [14 4];
S.T.goal_centre  = [11 22 7];
S.T.goal_spread  = [8 5];
S.T.obstacles    = [5 16; 8 16; 11 16; 11 13; 11 10; 14 16; 17 16];

% U Shape
S.U.start_centre = [14.5 4 7];
S.U.start_spread = [8 5];
S.U.goal_centre  = [14.5 26 7];
S.U.goal_spread  = [8 5];
S.U.obstacles    = [10 10; 10 13; 10 16; 13 19; 16 19; 19 13; 19 16; 19 10];

% E Shape
S.E.start_centre = [11 0 7];
S.E.start_spread = [14 5];
S.E.goal_centre  = [11 22 7];
S.E.goal_spread  = [5 5];
S.E.obstacles    = [2 10; 2 13; 2 16; ...
                    5 16; 8 16; 11 16; ...
                    11 13; 14 16; 17 16; 20 16; ...
                    20 13; 20 10; ...
                    2 7; 11 10; 20 7]; % deep E line

% Corridors
gapsize1 = 3;
gapsize2 = 1;
S.cor.start_centre = [14.5 3 7];
S.cor.start_spread = [6 2];
S.cor.goal_centre  = [14.5 35 7];
S.cor.goal_spread  = [3 3];
S.cor.obstacles = [
    5.5 -1;  8.5 -1;  11.5 -1;  14.5 -1;  17.5 -1;  20.5 -1;  23.5 -1; ...
    5.5  2;  5.5  5; ...
    23.5  2;  23.5  5; ...
    5.5  8;  23.5  8; ...
    (10-gapsize1/2) 8;  (13-gapsize1/2) 8;  (16+gapsize1/2) 8;  (19+gapsize1/2) 8; ...
    (10-gapsize1/2) 11; (13-gapsize1/2) 11; (16+gapsize1/2) 11; (19+gapsize1/2) 11; ...
    (10-gapsize1/2) 14; (13-gapsize1/2) 14; (16+gapsize1/2) 14; (19+gapsize1/2) 14; ...
    (10-gapsize2/2) 24; (13-gapsize2/2) 24; (16+gapsize2/2) 24; (19+gapsize2/2) 24; ...
    (10-gapsize2/2) 27; (13-gapsize2/2) 27; (16+gapsize2/2) 27; (19+gapsize2/2) 27; ...
    (10-gapsize2/2) 30; (13-gapsize2/2) 30; (16+gapsize2/2) 30; (19+gapsize2/2) 30; ...
    ];

% Random
S.rand.start_centre = [10 5 7];
S.rand.start_spread = [5 5];
S.rand.goal_centre  = [10 35 7];
S.rand.goal_spread  = [5 5];
S.rand.obs_centre   = [10 20];
S.rand.obs_spread   = [20 20];
S.rand.obstacles    = zeros(10, 2);


%% ........... Map Building Viewer. Disable for real runs.......................

% Set Scenario and Map

scenario = 'cor';

startRand = [S.(scenario).start_centre(1) + (rand()-0.5)*S.(scenario).start_spread(1), ...
                   S.(scenario).start_centre(2) + (rand()-0.5)*S.(scenario).start_spread(2), ...
                   S.(scenario).start_centre(3)];

goalRand       = [S.(scenario).goal_centre(1)  + (rand()-0.5)*S.(scenario).goal_spread(1), ...
                   S.(scenario).goal_centre(2)  + (rand()-0.5)*S.(scenario).goal_spread(2), ...
                   S.(scenario).goal_centre(3)];

InitialPosition     = startRand;
Waypoints           = goalRand;

ObstaclePositions  = S.(scenario).obstacles;
%InitialOrientation = eul2quat([0 0 0]);
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

%% Build Map - ONLY FOR MAP TESTING, NOT REAL SIM

% % Waypoints
% waypoints_colours = [1 0 0];
% for i = 1:size(Waypoints,1)
%     addMesh(MyScenario,"cylinder",{[Waypoints(i,1) Waypoints(i,2) 0.5] [(Waypoints(i, 3)-3.5) (Waypoints(i, 3)-3.4)]},waypoints_colours);
% end
% 
% % Obstacles
% obs_colours = [0.6 0.6 0.6];    % Gray
% ObstacleHeight = 12;            % Height of the obstacles
% ObstaclesWidth = 3;             % Width of the obstacles
% 
% 
% % Randomize obstacles for rand scenario
% if strcmp(scenario, 'rand')
%     for i = 1:10
%         S.rand.obstacles(i,:) = [S.rand.obs_centre(1) + (rand()-0.5)*S.rand.obs_spread(1), ...
%                                   S.rand.obs_centre(2) + (rand()-0.5)*S.rand.obs_spread(2)];
%     end
%     ObstaclePositions = S.rand.obstacles;
% end
% 
% 
% for i = 1:size(ObstaclePositions,1)
%     addMesh(MyScenario,"polygon", ...
%         {[ObstaclePositions(i,1)-ObstaclesWidth/2 ObstaclePositions(i,2)-ObstaclesWidth/2; ...
%         ObstaclePositions(i,1)+ObstaclesWidth/2 ObstaclePositions(i,2)-ObstaclesWidth/2; ...
%         ObstaclePositions(i,1)+ObstaclesWidth/2 ObstaclePositions(i,2)+ObstaclesWidth/2; ...
%         ObstaclePositions(i,1)-ObstaclesWidth/2 ObstaclePositions(i,2)+ObstaclesWidth/2], ...
%         [0 ObstacleHeight]}, obs_colours);
% end
% 
% disp("Built Map")
% 
% %% Viewer Plotting
% 
% show3D(MyScenario);
% hold on;
% 
% % Start box
% sc = S.(scenario).start_centre;
% ss = S.(scenario).start_spread;
% plot3([sc(1)-ss(1)/2, sc(1)+ss(1)/2, sc(1)+ss(1)/2, sc(1)-ss(1)/2, sc(1)-ss(1)/2], ...
%       [sc(2)-ss(2)/2, sc(2)-ss(2)/2, sc(2)+ss(2)/2, sc(2)+ss(2)/2, sc(2)-ss(2)/2], ...
%       repmat(sc(3),1,5), 'g--', 'LineWidth', 1.5);
% 
% % Goal box
% gc = S.(scenario).goal_centre;
% gs = S.(scenario).goal_spread;
% plot3([gc(1)-gs(1)/2, gc(1)+gs(1)/2, gc(1)+gs(1)/2, gc(1)-gs(1)/2, gc(1)-gs(1)/2], ...
%       [gc(2)-gs(2)/2, gc(2)-gs(2)/2, gc(2)+gs(2)/2, gc(2)+gs(2)/2, gc(2)-gs(2)/2], ...
%       repmat(gc(3),1,5), 'r--', 'LineWidth', 1.5);
% 
% % Obstacle box (rand scenario only)
% if strcmp(scenario, 'rand')
%     oc = S.rand.obs_centre;
%     os = S.rand.obs_spread;
%     plot3([oc(1)-os(1)/2, oc(1)+os(1)/2, oc(1)+os(1)/2, oc(1)-os(1)/2, oc(1)-os(1)/2], ...
%           [oc(2)-os(2)/2, oc(2)-os(2)/2, oc(2)+os(2)/2, oc(2)+os(2)/2, oc(2)-os(2)/2], ...
%           repmat(sc(3),1,5), 'b--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
% end
% 
% % Suppress all existing plot objects from legend
% set(get(gca, 'Children'), 'HandleVisibility', 'off');
% 
% % Legend
% plot3(nan, nan, nan, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Random Start Region');
% plot3(nan, nan, nan, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Random Goal Region');
% plot3(nan, nan, nan, 'b--', 'LineWidth', 1.5, 'DisplayName', 'Random Obstacle Region');
% patch(nan, nan, [0.6 0.6 0.6], 'DisplayName', 'Obstacles');
% legend('show', 'Location', 'best');
% 
% return;