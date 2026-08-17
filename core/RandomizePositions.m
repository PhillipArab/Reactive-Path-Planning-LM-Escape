%% RandomizePositions.m

InitialPosition = [S.(scenario).start_centre(1) + (rand()-0.5)*S.(scenario).start_spread(1), ...
                   S.(scenario).start_centre(2) + (rand()-0.5)*S.(scenario).start_spread(2), ...
                   S.(scenario).start_centre(3)];

Waypoints       = [S.(scenario).goal_centre(1)  + (rand()-0.5)*S.(scenario).goal_spread(1), ...
                   S.(scenario).goal_centre(2)  + (rand()-0.5)*S.(scenario).goal_spread(2), ...
                   S.(scenario).goal_centre(3)];

ObstaclePositions = S.(scenario).obstacles;

% Randomize obstacles for rand scenario
if strcmp(scenario, 'rand')
    for i = 1:5
        S.rand.obstacles(i,:) = [S.rand.obs_centre(1) + (rand()-0.5)*S.rand.obs_spread(1), ...
                                  S.rand.obs_centre(2) + (rand()-0.5)*S.rand.obs_spread(2)];
    end
    ObstaclePositions = S.rand.obstacles;
end



%disp("Randomized Positions");