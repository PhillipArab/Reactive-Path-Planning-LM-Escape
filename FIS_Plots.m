%% FIS Plots

% Tool to produce plots of FIS Input and Output Membership Functions

%% LM FIS Section
fis = readfis('FIS_LML.fis');
% Membership Functions
fig1 = figure; 
subplot(2,2,1); plotmf(fis, 'input', 3); title('$\|\vec{F}_{APF}\|$', 'Interpreter', 'latex');
subplot(2,2,2); plotmf(fis, 'input', 4); title('$d_{goal}$', 'Interpreter', 'latex');
subplot(2,2,3); plotmf(fis, 'input', 2); title('$d_{1s}$', 'Interpreter', 'latex');
subplot(2,2,4); plotmf(fis, 'input', 1); title('$d_{3s}$', 'Interpreter', 'latex');
set(findall(fig1, 'Type', 'axes'), 'FontSize', 14);
set(findall(fig1, 'Type', 'text'), 'FontSize', 16);
for ax = findall(fig1, 'Type', 'axes')'
    xlabel(ax, '');
    ylabel(ax, '');
end
exportgraphics(fig1, 'LM_FIS_MFs.pdf', 'ContentType', 'vector')
exportgraphics(fig1, 'LM_FIS_MFs.png', 'Resolution', 600)

%% CP FIS Section
fis = readfis('FIS_CPL.fis');
% Membership Functions
fig3 = figure;
subplot(2,2,1); plotmf(fis, 'input', 1); title('$\theta_{APF-WF}$', 'Interpreter', 'latex');
subplot(2,2,2); plotmf(fis, 'input', 2); title('$d_{LM,closest}$', 'Interpreter', 'latex');
subplot(2,2,3); plotmf(fis, 'input', 3); title('$C_{obs}$', 'Interpreter', 'latex');
subplot(2,2,4); plotmf(fis, 'output', 1); title('$\mu_{CP}$', 'Interpreter', 'latex');
set(findall(fig3, 'Type', 'axes'), 'FontSize', 14);
set(findall(fig3, 'Type', 'text'), 'FontSize', 16);
for ax = findall(fig3, 'Type', 'axes')'
    xlabel(ax, '');
    ylabel(ax, '');
end
exportgraphics(fig3, 'CP_FIS_MFs.pdf', 'ContentType', 'vector')
exportgraphics(fig3, 'CP_FIS_MFs.png', 'Resolution', 600)