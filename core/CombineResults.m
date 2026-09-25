%% Combine per-scene/per-method Monte Carlo CSVs into one table + summary
% Reads results_figures/results_<scene>_<method>.csv
% Writes results_figures/results_all.csv      (every trial, with Scene/Method columns)
%        results_figures/results_summary.csv  (one row per Scene x Method)

outputFolder = 'results_figures';
files = dir(fullfile(outputFolder, 'results_*.csv'));
files = files(~ismember({files.name}, {'results_all.csv', 'results_summary.csv'}));

allResults = table();
for k = 1:numel(files)
    % Scene names have no underscores; method names do -> split at first underscore
    tok = regexp(files(k).name, '^results_([^_]+)_(.+)\.csv$', 'tokens', 'once');
    if isempty(tok), continue; end

    T = readtable(fullfile(files(k).folder, files(k).name));
    T.Scene  = repmat(string(tok{1}), height(T), 1);
    T.Method = repmat(string(tok{2}), height(T), 1);
    allResults = [allResults; T]; %#ok<AGROW>
end

allResults = movevars(allResults, {'Scene', 'Method'}, 'Before', 1);
allResults = sortrows(allResults, {'Scene', 'Method', 'Trial'});
writetable(allResults, fullfile(outputFolder, 'results_all.csv'));

%% Summary per Scene x Method
% Success rate over all trials
S = groupsummary(allResults, {'Scene', 'Method'}, 'mean', 'Success');
S.Properties.VariableNames{'mean_Success'} = 'SuccessRate';

% Time/path/clearance stats over successful trials only
% (failed trials would skew these with timeout values)
succ = allResults(allResults.Success == 1, :);
M = groupsummary(succ, {'Scene', 'Method'}, {'mean', 'std'}, ...
    {'CompletionTime', 'PathLength', 'MinThreatDist'});
M.Properties.VariableNames{'GroupCount'} = 'N_success';

% std of a single value is reported as 0 by MATLAB - make it NaN instead
stdCols = startsWith(M.Properties.VariableNames, 'std_');
M{M.N_success < 2, stdCols} = NaN;

% Compute time per step over all trials
C = groupsummary(allResults, {'Scene', 'Method'}, 'mean', 'CompTimePerStep');
C = removevars(C, 'GroupCount');

summary = outerjoin(S, M, 'Keys', {'Scene', 'Method'}, 'MergeKeys', true);
summary = outerjoin(summary, C, 'Keys', {'Scene', 'Method'}, 'MergeKeys', true);
summary.Properties.VariableNames{'GroupCount'} = 'N_trials';
summary.N_success(isnan(summary.N_success)) = 0;   % groups with no successes
summary = movevars(summary, 'N_success', 'After', 'N_trials');

writetable(summary, fullfile(outputFolder, 'results_summary.csv'));
fprintf('Combined %d files -> results_all.csv, results_summary.csv\n', numel(files));
