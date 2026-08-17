# UAV Reactive Path Planning with Fuzzy Logic Supervision

A hybrid reactive path planning architecture for small quadrotor UAVs, combining Artificial Potential Fields (APF), Wall Following (WF), and Virtual Obstacle (VO) placement, arbitrated by a Fuzzy Logic (FL) supervisory layer. Developed as part of a MASc thesis at Concordia University.

## Overview

Reactive local planners like APF and VFH are fast and lightweight but prone to getting stuck in local minima near concave obstacles. This project addresses that limitation with a supervisory Fuzzy Logic layer that monitors planner behavior in real time and arbitrates between escape mechanisms (APF, WF, VO). Furthermore it challenges the models on a variety of Local-Minima-rich maps, without any global map knowledge.

Two Mamdani FIS systems drive the switching logic:
- **FIS_LM** (Local Minima Likeliness) — estimates the likelihood the UAV is trapped in a local minimum
- **FIS_CP** (Critical Point Likeliness) — estimates the likelihood the UAV is in a critical switch back point

A novel geometric indicator, *θ_APF-WF*, supports the switching decision alongside the FIS outputs.

The architecture is evaluated via Monte Carlo simulation across five benchmark maps (T, U, E, Corridor, Random) against a progressive ablation baseline (VFH → APF → FL-APF+WF → FL-APF+WF+VO), achieving an overall >90% success rate.

## Repository Structure

```
Reactive-Path-Planning-LM-Escape/
├── UAV_PathPlanning_Simulator.m   # Main script — entry point
├── core/                          # Simulation pipeline (scripts + functions)
│   ├── DefineScenarios.m
│   ├── BuildScenario.m
│   ├── RandomizePositions.m
│   ├── ComputeMetrics.m
│   └── runner_*.m                 # One runner per planning method
├── models/                        # Simulink models
│   ├── APFmodel.slx
│   └── FLmodel.slx
├── fis/                           # Fuzzy Inference System definitions
│   ├── FIS_LM.fis
│   └── FIS_CP.fis
├── tools/                         # Standalone utilities (not used by main pipeline)
│   ├── MapViewer.m                # Requires DefineScenarios.m to be run first
│   └── FIS_plots.m
└── results_figures/                # Auto-created on first run; not tracked in git
```

## Requirements

- MATLAB (developed/tested on R2024b)
- Aerospace Toolbox
- Automated Driving Toolbox
- Fuzzy Logic Toolbox
- Lidar Toolbox
- Navigation Toolbox
- ROS Toolbox
- Robotics System Toolbox
- Simulink
- Simulink Real-Time
- Stateflow
- UAV Toolbox

## Usage

1. Clone the repository.
2. Open `UAV_PathPlanning_Simulator.m` in MATLAB.
3. Adjust the parameters block at the top of the script:

```matlab
%% Parameters
% Methods Options: 'VFH', 'APF', 'FL_APF_WF', 'FL_APF_WF_VO'
methods = {'VFH', 'APF', 'FL_APF_WF', 'FL_APF_WF_VO'}; 

% Scenes Options: 'T', 'U', 'E', 'cor', 'rand'
scenes = {'T', 'U', 'E', 'cor', 'rand'}; 

% Number of trials. Total simulations = [1-4 methods]*[1-5 scenes]*[N_trials]
N_trials = 3;

plotEverySim = false;   % Reccommended = False, unless testing with small N_trials
closeModels  = true;    % Reccommended = True, unless running repeated experiments
```

4. Run the script. Results are saved as `.csv` files to `results_figures/`, created automatically on first run.

Bonus 1: To manually edit a scenario map, edit and run `DefineScenarios.m` first, then use `tools/MapViewer.m` to visualize it.

Bonus 2: To view FL input/output Membership Functions, run `FIS_Plots.m`