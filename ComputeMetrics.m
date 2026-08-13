% Performance Metrics Function V1

function metrics = ComputeMetrics(out, ObstaclePositions, ObstaclesWidth)

% Path Length
UAV_traj = squeeze(out.trajectoryPoints)';
steps = diff(UAV_traj(:,1:3));
metrics.pathLength = sum(vecnorm(steps, 2, 2));

% Completion Time
metrics.completionTime = out.tout(end);

% Success
metrics.success = logical(out.goalsReached.Data(end));

% Minimum Threat Distance
hw = ObstaclesWidth / 2;
traj2D = UAV_traj(:, 1:2);
dx = max(abs(traj2D(:,1) - ObstaclePositions(:,1)') - hw, 0);
dy = max(abs(traj2D(:,2) - ObstaclePositions(:,2)') - hw, 0);
metrics.minThreatDist = min(sqrt(dx.^2 + dy.^2), [], 'all');

end