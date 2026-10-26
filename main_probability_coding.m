%% ---------------------- General functions ---------------------

%--- READ THE DATA FROM THE XLS (CHEETAH) INTO A MAT FILE FOR A GIVEN MOUSE-------------------------------------------------------------------
%To generate the mat files in each directory of recrdings for a given mouse
generateMatFilesForAllRecordings('M1_PC_tetrodes', 'unitsDescription_final_M1_H_M_L', 1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% To analyze a single run: behavior + spiking activity + sniff
%you should be in the cheetah directory of this requested date of recording
[params] = analyzeSingleRun(labViewTxtName, TT7_SS_XX, lickTH, reAnalyzeCheetahData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read behavioral data only (no spiking activity). For sessions without
%recordings
[params] = READ_PROB_EXP('M24_probability_sess2_030225131348', 'head-fixed', 3.2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Concate data from different mice.
[allMiceData] = concateMiceData([2 3 5 7 12 13 17 18 20]);% the number marks the mouse number

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Refractory period analysis across all neurons. requires the allMiceData
%struct
allNeuronsRPV

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% quantification of task modulated neurons (8 conditions)
[taskModulationMat] = taskModulatedNeurons(allMiceData, 0.01, [-2 -1; -.33 0 ; 0 1], [-4 -3]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot the running signal together with a video, example from m4, 16.4
% pretraining
[params] = READ_PROB_EXP('M12_prob_reversal_sess3_070324142054', 'head-fixed', 3.45);
plotLiveSignal(params,[2 3], [14 15], '16042023.avi')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot a requisted CSC with its respiration signal.
exampleCSCwithRespiration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Plot the average PSTH of all neurons that were recorded in this sesssion,
%together with the licks
plotAverageNeuralTracesForSession(mouseData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate binary representation of a session. This enables to concate all
%sessions from a given mouse to plot the smoothed success rate graph across
%all sessions.
[dataMatrix] = createBinaryVectorsFromSessionsData(params);
[output] = createBinaryVectorsFromAllSessions(allMiceData(9).allRecs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is for backup. It runs over requested directories from one
% disk and copy it to another. It skips the CSC files, and therefore making
% a compact version of the data (about 1/6 of the total size).
copyTXTfiles

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Count in how many sessions odor A (2-hept)  or C (ethyl acetate) served as
%the high CS+ probability odor. requires the allMiceData struct
compute_H_L_neurons_counterbalancing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Computes the average number of trials across all mice and sessions. requires the allMiceData struct
averageNumberOfTrialsPerSession



%---old\non useful functions--------
save_JPG_all_neurons(allMiceData,'PC', 'F:\Experiments\2022\Behavior_Probability\head_fixed\Figures\allNeurons')
%Plot all examples of all units from a given mouse. The code save JPGs of
%the PSTHS, rasterplot and behavior
plotAllNeuronsFigures
refractoryPeriodViolationAnalysis

%% -------------- Figure 1 - behavioral analyses -----------------

%This are the 9 mice we ran for behavior.
[allMiceData] = concateMiceData([2 3 5 7 12 13 17 18 20]);% the number marks the mouse number

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Build a learning curve for a given mouse.
getLearningCurveForMouse(allMiceData(5))

%For all mice superimposed
successRateCriterion = .7;
superImposedLearnignCurvesAllMice(allMiceData, successRateCriterion)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot an example of lick raster plots and PSTH dividied by context, and for CS+ and CS-
mouseData = allMiceData(5).allRecs;
plotLickRasterExample(mouseData, 6)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Plot the average lick PSTH acrtoss all sessions
successRateCriterion = .7;
allSessionsLickPSTH(allMiceData, successRateCriterion, 0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function plots the mean RT for the two contexts as a function of
% performance. It can also plot for the M condition in supp figure 9.
successRateCriterion = .7;
RT_diff_by_success_rates_bins(allMiceData, 3, successRateCriterion, 0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%compare RT for naive and expert separatly, for both contexts
analyzeRTforNaiveExpert(allMiceData)

%%%---- Old \non useful functions
RTclassificationAcrossSessions(allMiceData(4), 100, [-2 2])
%Analyze RTs as a function of sessions after reversal
reversal_rt_by_session(allMiceData)
% RL models with RTs
RL_with_RTs_model
mouse_odor_rl

%% -------------- Supp Figure 1 - behavioral analyses -----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Example session lick raster for CS+\-
mouseData = allMiceData(5).allRecs;
plotLickRasterExample(mouseData, 6)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot performance curves for all mice, divided by context
successRateCriterion = .7;
superImposedLearnignCurvesAllMice(allMiceData, successRateCriterion)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Use this function to comapre Hit and FA rates across naive and expert
%sessions, for both conetxts
successRateCriterion = .7;
comapreFAandHitRatesForNaiveAndExpert(allMiceData, successRateCriterion)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use this to plot the average lick PSTH in novice state
successRateCriterion = .7;
superImposedLearnignCurvesAllMice(allMiceData, successRateCriterion)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% correlation between RT and performance
correlation_RT_Performance(allMiceData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Analyze RT for sessions when odor A or odor C were the H odor
RT_A_or_C_odors_as_H(allMiceData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The average sniff rate across mice and sessions.
computeAverageSniffRate(allMiceData, [-3 3])
meanSniffRateInTrialParts

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Analysis of two sessions from mice 17 and 20 with air closed
control_air_closed_analysis

%% -------------- Figure 2 - delay activity - ramping and population -----------------
%These are the four mice we recorded from.
%Use this structure when analyzing spiking activity in aPC with no OFC
%manipulation
[allMiceData] = concateMiceData([2 3 13 17]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Neurons matrix (z-scored)
z_scored_neurons_matrix(allMiceData, [-4 -3], 'allTrials', 'PC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The distance of PCA trajectories relative to baseline in the state space.
% Shown for novice and expert
successRateCriterion = .7;
trajectoryPCA(allMiceData, successRateCriterion, [-4:.1:.1], [-4 -3], 1, 'PC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SVM decoder for context during ramping activity(late delay period)
decode_probability_from_ramping_neurons(rampingNeurons, [-4 -3], [-.33 0], 100);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is the main function of ramping neurons analysis.
%This function computes the mean firing rates and PSTH of all ramping neurons, the Venn
%diagram of ramping selectivity, ramping neurons rate. and ramp to sniff
%correlation
[rampingNeurons] = central_function_ramping_neurons(allMiceData, [-4 -3], [-.33 0], 'PC');


%-old\non useful functions
%---- Find ramping neurons using a threshold
% [pooledPSTHstructEXC] = plotPSTHduringCSodor(allMiceData, [-2 -1.5], [-.5 0], 0.05, 'allTrials', 'individualResponse');
% decodeProbability_during_ramping_from_PSTHs(pooledPSTHstructEXC)
% %Plots all examples
% plotRamp_PE_examples
% % Z-scored matrix of ramping
% plotPSTHmatrixOfRampingNeurons
% % Generate PSTH and a struct of identified ramping neurons
% [outputStruct] = binaryResponseInRequestedWindow([-2 -1], [-.4 0], 0.05, 'high', .5, 'allTrials');
% %Plot the cdf of the ramping neurons along the learning
% plotCDF_rampingNeurons(outputStruct)
% rampingPercentageForNaiveExpert
% decodeTrialOutcomeBasedOnRampingActivity
% divideRampingActivityForCorrectAndErrorTrials

%% -------------- Supp Figure 2 - passive stimulation -----------------

% This function reads the data from all passive stimulation recordings from
% different animals
readXLSPassiveOdors('unitsDescription_passiveOdorExposure');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

concatePassiveOdorExperiemnts

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function plots the example of 23 simultaneously recorded neurons
examplePassiveOdors

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function load the ('allPassiveOdorData.mat') struct and computes the
% response rate for each odor, plots the averge PSTHs, quantify response rate
amplitudesAndResponseRate_passiveOdors


%---Old
% computeResponseRatePassiveOdors

%% -------------- Supp Figure 3 - more analyses of ramping activity -----------------

%This function clusters all the z-scored psths, plots the means in asubplots
%and plots the sorted neurons matrix
hierarchical_clustering_PSTHS(allMiceData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function plots the PCA trajectories
successRateCriterion = .7;
trajectoryPCA(allMiceData, successRateCriterion, [-4:.1:.1], [-4 -3], 1, 'PC');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The rest of analyses are here 
[rampingNeurons] = central_function_ramping_neurons(allMiceData, [-4 -3], [-.33 0], 'PC');

%% -------------- Supp Figure 4 - responses to context odors -----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find response rates to the context odors in novice and expert
predicting_odors_response_stats

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% violin plots of the activity in novice and expert
[activityMatrix, highRasters, lowRasters] = computeH_L_odorsActivity(allMiceData, [-4 -3], [-2 -1], .7, 'PC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot the average PSTHs divided to naive and expert
[pooledPSTHstructEXC, pooledPSTHstructInh] = plotPSTHduringCSodor(allMiceData, [-4 -3], [-2 -1], 0.01, 'allTrials', 'individualResponse');


%%%%--- Old/non-useful -----------
% Run a decoder using the data from the upper function 
decode_probability_from_H_L_neurons(highRasters, lowRasters, [-4 -3], [-2 -1], 100, activityMatrix(:,3), activityMatrix(:,4));

%%%%%%%%%%%%%%%%%%%%%%%%%% Odor Detection Decoder %%%%%%%%%%%%%%%%%%%%%%%%%%
expertRespondingIndsHigh = [pooledPSTHstructEXC(2).High_responding_exc_inds ; pooledPSTHstructInh(2).High_responding_inh_inds];
expertRespondingIndsLow = [pooledPSTHstructEXC(2).Low_responding_exc_inds ; pooledPSTHstructInh(2).Low_responding_inh_inds];

activeNeurons = union(expertRespondingIndsHigh, expertRespondingIndsLow);

%Odor detection using moving time windows (-2:.2:-1)
detectorTimeBins = -2:.1:-1;detectorWinSize = 0.2;
[allSRs_High, allSRs_Low, all_SE_High, all_SE_Low, neuronsUsedVector] ...
    = odorDetectionAcrossTimeBins(allMiceData, [], detectorTimeBins, detectorWinSize);

%%%%%%%%%%%%%%%%%%%%%%%%%% Identity across time decoder %%%%%%%%%%%%%%%%%%%%%%%%%%
%Decode the probability across time
[allMiceData] = concateMiceData([2 3]);
decodeProbabilityAcrossTime(allMiceData, [-4 -3], [-3 3], 'allTrials', 'Probability', [])

odorDiscriminationAsAfunctionOfNeuronsUsed(allMiceData, [-4 -3], [-2 -1], 'allTrials', []);


%% -------------- Figure 3 - CS+\- prediction errors -----------------

%This function is the main for context-modulated neurons
%It computes the venn diagram in supp 5 of CS+ and CS- responding neurons
%and thier overlap, the different rate of cm neurons for different error
%magnitudes in supp 5, pie charts of cm neurons for CS+ CS- and both in
%supp 5, the distribution of cm neurons found in novice and expert
central_function_context_modulated(allMiceData, [0 1], [-4 -3], 'PC')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

central_function_PE_neurons(allMiceData, [-4 -3], [0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Compute the overlap etween ramping and CM neurons
PE_ramping_overlap


%---------old\non useful functions----------------------
plot_trajectories_CS_odors(allMiceData, .7, [0:.1:3], [-4 -3], 'PC')

% This function quantifies the % modulated units for CS+ and-, divided by
% H>L
modulatedCSplus_minus_response_H_vs_L(allMiceData, 'no', [0 1])
% Compute H vs M and L vs M PE
[M_L] = modulatedCSplus_minus_response_H_vs_L_vs_M(allMiceData, [0 1], .7, 'M_vs_L')
[M_H] = modulatedCSplus_minus_response_H_vs_L_vs_M(allMiceData, [0 1], .7, 'M_vs_H')
pool_H_M_L_data_Modulated_Neurons

%%%%%%%%%%%%%%%%%%%% Decoder across time %%%%%%%%%%%%%%%%%%
% Prepare the data for the decoder
naiveRespindingInsHigh = pooledPSTHstructEXC_PE(1).High_responding_exc_inds;
expertRespondingIndsHigh = pooledPSTHstructEXC_PE(2).High_responding_exc_inds;

naiveRespindingInsLow = pooledPSTHstructEXC_PE(1).Low_responding_exc_inds;
expertRespondingIndsLow = pooledPSTHstructEXC_PE(2).Low_responding_exc_inds;
activeNeurons = union(expertRespondingIndsHigh, expertRespondingIndsLow);
% Decode
odorDetectionDecoderAcrossTime(allMiceData, [-4 -3], [-3 4], 'CS+', 'Probability', activeNeurons);



%% -------------- Supp Figure 5 - CS+\- prediction errors -----------------

%%%%%%%%%%%%%%%%%%%%%%% PSTHs for CS+ and CS- pooled (no separation for probability %%%%%%%%%%%%%%%%%%%%%%%%%
plotPSTHofCSplusAndMinus(allMiceData, [-4 -3], [0 1], 0.01, .7, 'PC')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[activityMatrix] = computeCSodorsActivity(allMiceData, [-4 -3], [0 1], .7 ,'PC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


control_PE_analysis_passive_odors

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

divideCSplusPSTHs_byRespondingNeurons



%% -------------- Figure 4 - OFC activity + OFC silencing -----------------
%Concate data
[allMiceData_OFC_recs] = concateMiceData([1 2 20]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSTH matrices
z_scored_neurons_matrix(allMiceData_OFC_recs, [-4 -3], 'allTrials', 'OFC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ramping analysis in OFC
[rampingNeurons] = central_function_ramping_neurons(allMiceData_OFC_recs, [-4 -3], [-.33 0], 'OFC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CM neurons in OFC - some analyses apper in supp figure 6
central_function_PE_neurons

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% State space distance analysis
trajectoryPCA(allMiceData_OFC_recs, .7, [-4:.1:.1], [-4 -3], 0);

%% ------------- Data for behavior during OFC silencing -----------
[allMiceData_OFC_SILENCING] = concateMiceData([4 9 10 11 14]);% the number marks the mouse number

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----- Task learning ----
% Plot the learning curve - all Mice
superImposedLearnignCurvesAllMice(allMiceData_OFC_SILENCING)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot RT against sessions
RT_diff_by_success_rates_bins(allMiceData_OFC_SILENCING, 3, .7)


%% ------------- Data for behavior during OFC silencing after learning -----------
% These are the mice to work with
[allMiceDataOFCsilenceAfterLearning] = concateMiceData([15 16 23 24]);% the number marks the mouse number


% Super impose the average learning curves- mark in orange the sessions with suppression
superImposedLearnignCurvesAllMice_OFC_silencing_after_learning(allMiceDataOFCsilenceAfterLearning)

%Plot the average lick PSTH acrtoss all sessions
allSessionsLickPSTH_OFCsilencingAfterLearning(allMiceDataOFCsilenceAfterLearning, 0.7)

% Compute the RT per session after injection
compute_RTs_per_session_after_JH60(allMiceDataOFCsilenceAfterLearning, .7)





%-----Old \ nonuseful functions -----
% Compare the # trials required for criterion
compareTrialsToCriterions_WT_vs_OFC_silencing(allMiceData, allMiceData_OFC_SILENCING, 20)


%%%%%%%%%%%%%% Data from projection specific experiments OFC->aPC silencing
%%%%%%%%%%%%%% 

[allMiceData] = concateMiceData([26]);


%% -------------- Supp Figure 6 - OFC activity + OFC silencing -----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[activityMatrix, highRasters, lowRasters] = computeH_L_odorsActivity(allMiceData_OFC_recs, [-4 -3], [0 1], .7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[activityMatrix] = computeCSodorsActivity(allMiceData_OFC_recs, [-4 -3], [0 1], .7, 'OFC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Example of a silencing of a neuron following JHU injection.
plotOFC_silencing_example_M4;
JH_validation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Analzye RT for naive and expert separatly
analyzeRTforNaiveExpert(allMiceData_OFC_SILENCING)



%% -------------- Figure 5 - aPC recordings during OFC silencing -----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------ These are the three mice we recorded from --------
[allMiceData_OFC_SILENCING] = concateMiceData([9 10 14]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
z_scored_neurons_matrix(allMiceData_OFC_SILENCING, [-4 -3], 'allTrials', 'PC');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quantify how many neurons responded to each odor by Exc and Inh
percent_task_related_activity_modulation(allMiceData_OFC_SILENCING, 0.01, [-4 -3; -2 -1; 0 1]);
% Quantify % task-modulated neurons 
[taskModulationMat] = taskModulatedNeurons(allMiceData_OFC_SILENCING, 0.01, [-2 -1; -.33 0 ; 0 1], [-4 -3]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trajectoryPCA(allMiceData_OFC_SILENCING, .7, [-4:.1:.1], [-4 -3], 0, 'PC');


% Plot the average PSTH for the cue odor under OFC silencing (we use the
% joint response flag).
[pooledPSTHstructEXC_OFC,pooledPSTHstructInh_OFC] =  plotPSTHduringCSodor(allMiceData_OFC_SILENCING, [-4 -3], [-2 -1], 0.01, 'allTrials','jointResponse');

% Compute the moving percent of units that were modulated by probability
[modulatedResponse_CSplus, modulatedResponse_CSminus] = csPlus_modulatedResponse(allMiceData_OFC_SILENCING, 'no');

% Compare the Z-scored activity between CS+\- with and without OFC
% suppression
compare_Z_CS_activity_with_without_OFC_suppression(allMiceData, allMiceData_OFC_SILENCING, [-4 -3], [0 1]);

% This is the main function of ramping neurons analysis
[rampingNeurons] = central_function_ramping_neurons(allMiceData_OFC_SILENCING, [-4 -3], [-.33 0], 'PC');

decode_probability_from_ramping_neurons(rampingNeurons, [-4 -3], [-.33 0], 10);


% This is the main function of PE neurons analysis
central_function_PE_neurons

% CS data
plotPSTHofCSplusAndMinus(allMiceData_OFC_SILENCING, [-4 -3], [0 1], 0.01, .7)
% firing rate using violin plots naive vs expert and inh vs exc
[activityMatrix] = computeCSodorsActivity(allMiceData_OFC_SILENCING, [-4 -3], [0 1]);
[activityMatrix] = computeH_L_odorsActivity(allMiceData_OFC_SILENCING, [-4 -3], [0 1], .7);



%% -------------- Supp Figure 7 - aPC recordings during OFC silencing -----------------



%%%%%%%%%%%%%%%%%%%%%%%%%% PSTH for CS+ odor - OFC silencing %%%%%%%%%%%%%%%%%%%%%%%%%%
plotPSTHduringCSodor(allMiceData_OFC_SILENCING, [-4 -2], [0 1], 0.05, 'CS+', 'individualResponse');

%%%%%%%%%%%%%%%%%%%%%%%%%% PSTH for CS- odor - OFC silencing %%%%%%%%%%%%%%%%%%%%%%%%%%
plotPSTHduringCSodor(allMiceData_OFC_SILENCING, [-4 -2], [0 1], 0.05, 'CS-', 'individualResponse');


%%%%%%%%%%%%%%%%%%%%%%%%%% PSTH for ramping - OFC silencing %%%%%%%%%%%%%%%%%%%%%%%%%%
%---- Find ramping neurons under OFC silencing
 plotPSTHduringCSodor(allMiceData_OFC_SILENCING, [-2 -1.5], [-.5 0], 0.05, 'allTrials', 'individualResponse')

 %%%%%%%%%%%%%%%%%%%%%%%%%% Decoder across time %%%%%%%%%%%%%%%%%%%%%%%%%%
% Decode the probability of the cue odor across time
[allMiceData_OFC_SILENCING] = concateMiceData([9 10 14]);
decodeProbabilityAcrossTime(allMiceData, [-4 -2], [-3 0], 'allTrials', 'Probability', 'active')

compareProbabilityVSidentityDECODING


% AuROC matrix
[fullDataStruct] = convertdifferentMiceDataIntoSingleStruct(allMiceData_OFC_SILENCING, 'PC');% unifies the structures
[outputStructCueOdor] = plotNeuronMatricesForHighAndLowConditions(fullDataStruct, [-2 -1], [-2 -1], 300);













