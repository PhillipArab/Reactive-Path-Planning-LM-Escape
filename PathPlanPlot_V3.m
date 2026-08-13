%% Path Planning Points Plot V3
%{
Notes:
-removed VO - too hard to see 
-changed CP to green (consistent with draw.io diagrams)

%}

%% Default counts to 0 if variables don't exist (APF-only / VFH configs)
if ~exist('finalMinimaCount','var'), finalMinimaCount = 0; end
if ~exist('finalMinimaList', 'var'), finalMinimaList  = []; end
if ~exist('finalCPCount',    'var'), finalCPCount     = 0; end
if ~exist('finalCPList',     'var'), finalCPList      = []; end
if ~exist('finalVOCount',    'var'), finalVOCount     = 0; end
if ~exist('finalVOList',     'var'), finalVOList      = []; end

%% Add meshes

% Colours
LM_colour = [1 0 1]; % Magenta
CP_colour = [0 1 0]; % Green

% Waypoint draw for pictures
waypoints_colours = [1 0 0];
for i = 1:size(Waypoints, 1)
    addMesh(MyScenario, "cylinder", ...
        {[Waypoints(i,1) Waypoints(i,2) 0.5] [(Waypoints(i,3)-0.1) (Waypoints(i,3))]}, ...
        waypoints_colours);
end

% Local Minima (magenta) - cylinder
for i = 1:finalMinimaCount
    addMesh(MyScenario,"cylinder",{[finalMinimaList(i,1) ...
        finalMinimaList(i,2) 0.5] [(finalMinimaList(i,3)-0.15) ...
        (finalMinimaList(i,3)+0.15)]}, LM_colour);
end

% Critical Points (green) - cylinder
for i = 1:finalCPCount
    addMesh(MyScenario,"cylinder",{[finalCPList(i,1) ...
        finalCPList(i,2) 0.5] [(finalCPList(i,3)-0.15) ...
        (finalCPList(i,3)+0.15)]}, CP_colour);
end

%% Initialize Figure
figure;
show3D(MyScenario);
hold on;
title("Path Planning Points View");

%% Add overlay plots

% Trajectory
UAV_traj = squeeze(out.trajectoryPoints)';
h_traj = plot3(UAV_traj(:,1),UAV_traj(:,2),UAV_traj(:,3),"-b");


% % Start/Goal/Obstacle boxes (no legend entry)
% sc = S.(scenario).start_centre;
% ss = S.(scenario).start_spread;
% plot3([sc(1)-ss(1)/2, sc(1)+ss(1)/2, sc(1)+ss(1)/2, sc(1)-ss(1)/2, sc(1)-ss(1)/2], ...
%       [sc(2)-ss(2)/2, sc(2)-ss(2)/2, sc(2)+ss(2)/2, sc(2)+ss(2)/2, sc(2)-ss(2)/2], ...
%       repmat(sc(3),1,5), 'b--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
% 
% gc = S.(scenario).goal_centre;
% gs = S.(scenario).goal_spread;
% plot3([gc(1)-gs(1)/2, gc(1)+gs(1)/2, gc(1)+gs(1)/2, gc(1)-gs(1)/2, gc(1)-gs(1)/2], ...
%       [gc(2)-gs(2)/2, gc(2)-gs(2)/2, gc(2)+gs(2)/2, gc(2)+gs(2)/2, gc(2)-gs(2)/2], ...
%       repmat(gc(3),1,5), 'r--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
% 
% % Obstacle box (rand scenario only)
% if strcmp(scenario, 'rand')
%     oc = S.rand.obs_centre;
%     os = S.rand.obs_spread;
%     plot3([oc(1)-os(1)/2, oc(1)+os(1)/2, oc(1)+os(1)/2, oc(1)-os(1)/2, oc(1)-os(1)/2], ...
%           [oc(2)-os(2)/2, oc(2)-os(2)/2, oc(2)+os(2)/2, oc(2)+os(2)/2, oc(2)-os(2)/2], ...
%           repmat(sc(3),1,5), 'b--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
% end


%% Legend 

% Suppress all scene objects from legend
set(findobj(gca,'Type','Patch','-or','Type','Surface','-or','Type','hgtransform'), 'HandleVisibility','off');

% Explicit dummy handles for legend
h_way  = patch(nan,nan,nan, 'FaceColor',waypoints_colours, 'EdgeColor','none');
h_obs  = patch(nan,nan,nan, 'FaceColor',obs_colours, 'EdgeColor','none');
h_lm   = patch(nan,nan,nan, 'FaceColor',LM_colour, 'EdgeColor','none');
h_cp   = patch(nan,nan,nan, 'FaceColor',CP_colour, 'EdgeColor','none');
h_start = plot3(nan,nan,nan, 'b--', 'LineWidth', 1.5);
h_goal  = plot3(nan,nan,nan, 'r--', 'LineWidth', 1.5);
h_uav = plot3(nan, nan, nan, 'bx', 'MarkerSize', 14, 'LineWidth', 1);

% Legend
legend([h_obs, h_way, h_uav, h_traj, h_lm, h_cp], ...
       ["Obstacles","Goal","UAV Start", ...
        "Trajectory","Local Minima","Critical Points"]);


disp("Plotting Complete");
