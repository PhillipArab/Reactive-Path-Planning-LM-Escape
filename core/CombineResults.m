%% Combine per-batch Monte Carlo CSVs into one table
% Reads  results/seed_<start>-<end>_<scene>_<method>.csv
% Writes results/results_all.csv (every trial, with Scene/Method columns)
% If a Scene/Method/Seed appears in multiple files, the newest file's row is kept.

outputFolder = 'results';
files = dir(fullfile(outputFolder, 'seed_*.csv'));
[~, idx] = sort([files.datenum]);  files = files(idx);   % oldest first

allResults = table();
for k = 1:numel(files)
    % Scene names have no underscores; method names do -> scene is first token after seed range
    tok = regexp(files(k).name, '^seed_\d+-\d+_([^_]+)_(.+)\.csv$', 'tokens', 'once');
    if isempty(tok), continue; end

    T = readtable(fullfile(files(k).folder, files(k).name));
    T.Scene  = repmat(string(tok{1}), height(T), 1);
    T.Method = repmat(string(tok{2}), height(T), 1);
    allResults = [allResults; T]; %#ok<AGROW>
end

if isempty(allResults)
    warning('No seed_*.csv files found in %s', outputFolder);
    return;
end

% Remove duplicates: keep the newest run of each Scene/Method/Seed
[~, keep] = unique(allResults(:, {'Scene','Method','Seed'}), 'last');
allResults = allResults(keep, :);

allResults = movevars(allResults, {'Scene', 'Method'}, 'Before', 1);
allResults = sortrows(allResults, {'Scene', 'Method', 'Seed'});
writetable(allResults, fullfile(outputFolder, 'results_all.csv'));
fprintf('Combined %d files -> results_all.csv (%d rows)\n', numel(files), height(allResults));