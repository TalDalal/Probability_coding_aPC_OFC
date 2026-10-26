function [params] = computeEvokeResponsePassiveOdors(params, bgTimeWin, fgTimeWin)
%% Trial indices
params.TplusTrials = find(params.trialsIndex==4);
params.TminusTrials = find(params.trialsIndex==5);
params.Atrials = find(params.trialsIndex==6);
params.Btrials = find(params.trialsIndex==7);
params.Ctrials = find(params.trialsIndex==8);
%% Firing rate during odor
% bgTimeWin = [-2 0];fgTimeWin = [0 1];
[evokedA, p_A] = frWithinTimeFrame(params, bgTimeWin, fgTimeWin, params.Atrials);
[evokedB, p_B] = frWithinTimeFrame(params, bgTimeWin, fgTimeWin, params.Btrials);
[evokedC, p_C] = frWithinTimeFrame(params, bgTimeWin, fgTimeWin, params.Ctrials);
[evokedT_plus, p_T_plus] = frWithinTimeFrame(params, bgTimeWin, fgTimeWin, params.TplusTrials);
[evokedT_minus, p_T_minus] = frWithinTimeFrame(params, bgTimeWin, fgTimeWin, params.TminusTrials);

params.odorsTuningCurve = [evokedA evokedB evokedC evokedT_plus evokedT_minus];
params.pArray = [p_A p_B p_C p_T_plus p_T_minus];
params.odorsOrder = {'A', 'B', 'C', 'T+', 'T-'};