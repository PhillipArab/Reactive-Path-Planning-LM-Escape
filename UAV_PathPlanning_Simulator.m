%% MonteCarlo Simulations of 6 UAV Reactive Path Planning Models

%% Main Parameters

% Methods: 'VFH', 'APF', 'RB_APF_WF', 'RB_APF_WF_VO', 'FL_APF_WF', 'FL_APF_WF_VO'
methods = {'RB_APF_WF', 'RB_APF_WF_VO', 'VFH'}; 

% Scenes Options: 'T', 'U', 'E', 'cor', 'rand'
scenes = {'E', 'U'}; 

% Seed of first trial (trial n uses seed = seed_start + n - 1)
seed_start = 2;

% Number of trials. Total simulations = [1-6 methods]*[1-5 scenes]*[N_trials]
N_trials = 3;

%% Other Parameters [CAREFUL before changing]

% Stop time per map (s) - same for all methods
stopTimes = struct('T', 60, 'U', 60, 'E', 150, 'cor', 120, 'rand', 120);

plotEverySim = false;   % Reccommended = False, unless testing with small N_trials
closeModels  = false;    % Reccommended = True, unless running repeated experiments

%% Setup

% File Paths
addpath('core');
addpath('models');
addpath('FIS');
addpath('tools');

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
            'VariableNames', {'Seed','CompletionTime','PathLength','MinThreatDist','Success', 'CompTimePerStep'});
    end

    % Run n trials for given scene
    for n = 1:N_trials
        
        % Seeding
        seed = seed_start + n - 1;
        rng(seed);

        run('RandomizePositions.m');

        for m = 1:length(methods)
            fprintf('[%s | %s | Trial %d/%d | Seed %d]\n', scenes{s}, methods{m}, n, N_trials, seed);

            % Build fresh UAV Scenario to be safe
            run('BuildScenario.m');

            % Run Simulation
            tic;
            out = sim(mdl_store.(methods{m}), 'StopTime', num2str(stopTimes.(scenario)));
            t_total = toc;
            n_steps = length(out.tout);
            t_per_step_ms = (t_total / n_steps)*1000;
            
            % Plot Simulation Result
            if (plotEverySim)
                run("PathPlanPlot.m");
            end
                      

            % Store Results
            metrics = ComputeMetrics(out, ObstaclePositions, ObstaclesWidth);
            resultsStore.(methods{m}).Seed(n)          = seed;
            resultsStore.(methods{m}).CompletionTime(n) = metrics.completionTime;
            resultsStore.(methods{m}).PathLength(n)     = metrics.pathLength;
            resultsStore.(methods{m}).MinThreatDist(n)  = metrics.minThreatDist;
            resultsStore.(methods{m}).Success(n)        = metrics.success;
            resultsStore.(methods{m}).CompTimePerStep(n) = t_per_step_ms;
        end
    end

    % Save Data of each Method for given Scene
    outputFolder = 'results';
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    for m = 1:length(methods)
        filename = sprintf('seed_%03d-%03d_%s_%s.csv', seed_start, seed_start + N_trials - 1, scenes{s}, methods{m});
        writetable(resultsStore.(methods{m}), fullfile(outputFolder, filename));
        fprintf('Saved %s\n', filename);
    end
end

run("CombineResults.m");

%% Close all models
if(closeModels)
    for m = 1:length(methods)
        close_system(mdl_store.(methods{m}), 0);
    end
end

fprintf('Monte Carlo Complete\n');