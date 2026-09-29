%% Combine per-scene/per-method Monte Carlo CSVs into one table + summary
% Reads results_figures/results_<scene>_<method>.csv
% Writes results_figures/results_all.csv      (every trial, with Scene/Method columns)
%        results_figures/results_summary.csv  (one row per Scene x Method)

outputFolder = 'results';
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