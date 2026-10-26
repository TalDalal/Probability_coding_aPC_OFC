%simulate data
% nNeurons = 70;
% 
% [neural_activity, context, mapping] = simulate_neural_data(nNeurons);

[rampingNeurons] = psth_delay_modulated_neurons(allMiceData, [-.33 0], [-4 -3], [-2 0], 'allTrials', 2, 'PC');
rampingSessionsInds = find(rampingNeurons(1).allDelayActiveNeurons > 0);
close;

high_ramp_raster = rampingNeurons(1).high_rasters(rampingSessionsInds);
low_ramp_raster = rampingNeurons(1).low_rasters(rampingSessionsInds);
context_A_identity = rampingNeurons(1).high_Low_Flag(rampingSessionsInds);


neural_activity = [];context = [];mapping = [];
for ind = 1:size(high_ramp_raster,2)
    currHigh = high_ramp_raster{ind};
    currLow = low_ramp_raster{ind};

    FR_high = compute_firing_rate(currHigh, [-.5 0]);
    FR_low = compute_firing_rate(currLow, [-.5 0]);

    neural_activity{ind,1} = [FR_high FR_low]';
    context{ind,1} = [ones(1, length(FR_high)) zeros(1, length(FR_low))]';

    if strcmpi(context_A_identity{ind}, 'A')
        mapping(ind,1) = 1;
    else
        mapping(ind,1) = -1;
    end
end

results = glm_context_per_neuron(neural_activity, context);
beta_context = results.beta_context;

[h,p] = ttest2(beta_context(mapping==1), beta_context(mapping==-1))

%%%---- plot
group_results = test_probability_vs_identity(beta_context, mapping);

disp(group_results.gamma)
disp(group_results.pval)

figure
hold on

histogram(beta_context(mapping==1), 'FaceColor','r')
histogram(beta_context(mapping==-1), 'FaceColor','b')

legend('A = high prob','A = low prob')
xlabel('Context beta')
ylabel('Count')
title('Sign flip = probability coding')


figure

mean1 = mean(beta_context(mapping==1));
mean2 = mean(beta_context(mapping==-1));

bar([mean1 mean2])
set(gca,'XTickLabel',{'A=high prob','A=low prob'})
ylabel('Context beta')
title('Population effect')


%--------- Functions-------

function FR = compute_firing_rate(data, window)

% data   : struct array, data(i).times = spike times for trial i (in sec)
% window : [t_start t_end] in seconds
%
% output:
% FR     : 1 x nTrials vector of firing rates (Hz)

nTrials = length(data);
FR = zeros(1, nTrials);

t_start = window(1);
t_end   = window(2);
win_length = t_end - t_start;

for i = 1:nTrials
    
    spike_times = data(i).times;
    
    % count spikes within window
    nSpikes = sum(spike_times >= t_start & spike_times < t_end);
    
    % convert to firing rate (Hz)
    FR(i) = nSpikes / win_length;
    
end

end






function group_results = test_probability_vs_identity(beta_context, mapping)

% mapping: +1 or -1 per neuron

tbl = table(beta_context(:), mapping(:), ...
    'VariableNames', {'Beta','Mapping'});

mdl = fitglm(tbl, 'Beta ~ Mapping');

group_results.gamma = mdl.Coefficients.Estimate;
group_results.pval  = mdl.Coefficients.pValue;

end


function results = glm_context_per_neuron(neural_activity, context)

nNeurons = length(neural_activity);

beta = zeros(nNeurons,1);

for n = 1:nNeurons
    
    y = neural_activity{n};
    ctx = context{n}; % 0=B, 1=A
    
    tbl = table(y, ctx, 'VariableNames', {'Activity','Context'});
    
    mdl = fitglm(tbl, 'Activity ~ Context');
    
    beta(n) = mdl.Coefficients.Estimate(2);
    
end

results.beta_context = beta;

end

function [neural_activity, context, mapping] = simulate_neural_data(nNeurons)

neural_activity = cell(nNeurons,1);
context         = cell(nNeurons,1);
mapping         = zeros(nNeurons,1);

for n = 1:nNeurons
    
    % random number of trials
    nTrials = randi([80 150]);
    
    % random interleaved contexts (0=B, 1=A)
    ctx = rand(nTrials,1) > 0.5;
    
    % assign mapping: +1 = A is high prob, -1 = A is low prob
    if rand > 0.5
        map = +1;
    else
        map = -1;
    end
    
    mapping(n) = map;
    
    % assign probability per trial
    prob = zeros(nTrials,1);
    
    if map == +1
        % A=0.75, B=0.25
        prob(ctx==1) = 0.75;
        prob(ctx==0) = 0.25;
    else
        % A=0.25, B=0.75
        prob(ctx==1) = 0.25;
        prob(ctx==0) = 0.75;
    end
    
    % define "odor identity" (just A vs B here)
    odor = ctx; % (this is the confounded variable)
    
    % weights (you can play with these)
    w_prob  = 1;     % TRUE signal (probability coding)
    w_odor  = 2;   % weaker identity coding
    noiseSD = 1.0;
    
    % generate activity
    activity = w_prob * prob + w_odor * odor + noiseSD * randn(nTrials,1);
    
    neural_activity{n} = activity;
    context{n} = ctx;
    
end

end