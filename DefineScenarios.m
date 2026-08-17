%% DefineScenarios.m

% When editing, use tools/MapViewer.m for visualization

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


