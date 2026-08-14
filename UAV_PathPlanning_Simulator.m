%% MonteCarlo Simulations of 4 UAV Reactive Path Planning Models

%% Parameters

methods = {'VFH', 'FL_APF_WF_VO'};  % Options: 'VFH', 'APF', 'FL_APF_WF', 'FL_APF_WF_VO'
scenes     = {'rand'};              % Options: 'T', 'U', 'E', 'cor', 'rand'
N_trials = 2;

%% Setup

% Definitions
run('DefineScenarios.m');

% Open all models once
for m = 1:length(methods)
    run(['runner_' methods{m} '.m']);
    mdl_store.(methods{m}) = mdl;
    open_system(mdl);
end

%% Monte Carlo Loop
for s = 1:length(scenes)
    scenario = scenes{s};

    % Make Table for each method of given scene
    for m = 1:length(methods)
        resultsStore.(methods{m}) = table('Size', [N_trials 6], ...
            'VariableTypes', {'double','double','double','double','logical', 'double'}, ...
            'VariableNames', {'Trial','CompletionTime','PathLength','MinThreatDist','Success', 'CompTimePerStep'});
    end

    % Run n trials for given scene
    for n = 1:N_trials
        run('RandomizePositions.m');

        for m = 1:length(methods)
            fprintf('[%s | %s | Trial %d/%d]\n', scenes{s}, methods{m}, n, N_trials);

            % Build fresh UAV Scenario to be safe
            run('BuildScenario.m');

            % Run Simulation
            tic;
            out = sim(mdl_store.(methods{m}));
            t_total = toc;
            n_steps = length(out.tout);
            t_per_step_ms = (t_total / n_steps)*1000;
            
            % Plot - ONLY WHEN TESTING/INVESTGATING
            run("PathPlanPlot.m");

            % Store Results
            metrics = ComputeMetrics(out, ObstaclePositions, ObstaclesWidth);
            resultsStore.(methods{m}).Trial(n)          = n;
            resultsStore.(methods{m}).CompletionTime(n) = metrics.completionTime;
            resultsStore.(methods{m}).PathLength(n)     = metrics.pathLength;
            resultsStore.(methods{m}).MinThreatDist(n)  = metrics.minThreatDist;
            resultsStore.(methods{m}).Success(n)        = metrics.success;
            resultsStore.(methods{m}).CompTimePerStep(n) = t_per_step_ms;
        end
    end

    % Save Data of each Method for given Scene
    for m = 1:length(methods)
        filename = sprintf('results_%s_%s.csv', scenes{s}, methods{m});
        writetable(resultsStore.(methods{m}), filename);
        fprintf('Saved %s\n', filename);
    end
end

%% Close all models
for m = 1:length(methods)
    %close_system(mdl_store.(methods{m}), 0);
end

fprintf('Monte Carlo Complete\n');