clear;
if ismac
    cd('/Volumes/My Passport/Tal/Experiments/2022/Behavior_Probability/head_fixed/data/passive_odor_stimulation');
else
    cd('F:\Experiments\2022\Behavior_Probability\head_fixed\data\passive_odor_stimulation');
end
load('allPassiveOdorData.mat')
%%
odorIdentities{1} = 'ethyl-butyrate(CS+)';%'T+'
odorIdentities{2} = 'penthyl-acetate(CS-)';%'T-'

clrArray = [155,41,72 ; 255,114,81 ; 85,51,17 ; 153,102,51]./255;
%%
bgDuration = [-4 -2];
fgDuration = [0 1];
pAlpha = 0.01;
c = 0;
nBoot = 100;
%%

% responseRateMat = nan(100,size(odorIdentities,2));
% evokedResponse = nan(100,size(odorIdentities,2));

neuronsPerMouse = [];
odorPSTHmatrix = [];
allCSplus_simulated_modulated_neurons = [];allCSminus_simulated_modulated_neurons = [];
%%
for mouseInd = 1:size(allPassiveOdorData,2)
    %Current mouse
    currMouse = allPassiveOdorData(mouseInd).data;
    
    neuronsPerMouse(mouseInd) = size(currMouse.firingRates,2);
    
    trialsArray{1} = currMouse.TplusTrials;
    trialsArray{2} = currMouse.TminusTrials;
    
    for neuronInd = 1:size(currMouse.firingRates,2)
        
        
        c = c + 1;
        
        %Curr fr matrix
        currFR = currMouse.firingRates(neuronInd).firingRateByBIn;
        currT = currMouse.firingRateAnalysisBins;
        
        for odorInd = 1:size(trialsArray,2)
            
            %----- Response rate----
            [respFlag, evResponse] = bgFg_passiveOdors(bgDuration, fgDuration, currFR, currT, trialsArray{odorInd}, pAlpha);
            
            
            if respFlag
                [modulatedResponse] = simulate_neurons(evResponse, nBoot);
                
                if odorInd==1
                    allCSplus_simulated_modulated_neurons = [allCSplus_simulated_modulated_neurons modulatedResponse];
                else
                   allCSminus_simulated_modulated_neurons = [allCSminus_simulated_modulated_neurons modulatedResponse];
                end
            end
  
        end

        
        
    end
end


figure;
plot_modulated_neurons([sum(~allCSplus_simulated_modulated_neurons) sum(allCSplus_simulated_modulated_neurons)], ...
    [sum(~allCSminus_simulated_modulated_neurons) sum(allCSminus_simulated_modulated_neurons)])

function [respFlag, evokedResponse] = bgFg_passiveOdors(bgDuration, fgDuration, FR, t, trials, pAlpha)
        bgFR = mean(FR(trials, find(t >= bgDuration(1) & t < bgDuration(2))),2);
        fgFR = mean(FR(trials, find(t >= fgDuration(1) & t < fgDuration(2))),2);
        
        evokedResponse = fgFR - bgFR;
        [respFlag,~] = ttest(fgFR, bgFR, 'Alpha', pAlpha);
end

function [modulatedResponse] = simulate_neurons(evResponse, nBoot)
fr_modulation_per_neuron = [];
for bootInd = 1:nBoot
    A_context = randsample(length(evResponse), round(0.75*length(evResponse)));
    B_context = setdiff(1:length(evResponse), A_context);
    [h(bootInd),~] = ttest2(evResponse(A_context), evResponse(B_context));
    fr_modulation_per_neuron(end+1) = logical(mean(evResponse(A_context)) > mean(evResponse(B_context)));
    
    
end
modulatedResponse =  fr_modulation_per_neuron(find(h==1));
end

function plot_modulated_neurons(cs_plus, cs_minus)
    % PLOT_MODULATED_NEURONS plots percentages of neurons from two vectors
    % and connects corresponding points with lines.
    %
    % Inputs:
    %   - cs_plus: 1x2 vector with counts of neurons for CS+.
    %   - cs_minus: 1x2 vector with counts of neurons for CS-.
    %
    % The function computes percentages, plots them with SEM, and connects
    % related points with lines.
    lowProbColor = [220,107,169]./255;%purple
    highProbColor = [0,174,239]./255;%green

    % Validate inputs
    if numel(cs_plus) ~= 2 || numel(cs_minus) ~= 2
        error('Both inputs must be 1x2 vectors.');
    end

    % Compute total neurons for each input
    total_plus = sum(cs_plus);
    total_minus = sum(cs_minus);

    % Compute percentages
    pct_plus = cs_plus / total_plus * 100;
    pct_minus = cs_minus / total_minus * 100;

    % Compute SEM (binomial distribution)
    sem_plus = sqrt((pct_plus .* (100 - pct_plus)) / total_plus);
    sem_minus = sqrt((pct_minus .* (100 - pct_minus)) / total_minus);

    % Create x positions for plotting
    x_positions = [1, 2];

    % Plot data
%     figure;
    hold on;

    % Plot percentages for CS+ and CS- with SEM
    errorbar(x_positions(1), pct_plus(1), sem_plus(1), 'o', 'MarkerSize', 8, ...
        'LineWidth', 1.5, 'Color', highProbColor, 'MarkerFaceColor', highProbColor, 'MarkerEdgeColor', highProbColor);
    errorbar(x_positions(1), pct_plus(2), sem_plus(2), 'o', 'MarkerSize', 8, ...
        'LineWidth', 1.5, 'Color', lowProbColor, 'MarkerFaceColor', lowProbColor, 'MarkerEdgeColor', lowProbColor);

    errorbar(x_positions(2), pct_minus(1), sem_minus(1), 'o', 'MarkerSize', 8, ...
        'LineWidth', 1.5, 'Color', highProbColor, 'MarkerFaceColor', highProbColor, 'MarkerEdgeColor', highProbColor);
    errorbar(x_positions(2), pct_minus(2), sem_minus(2), 'o', 'MarkerSize', 8, ...
        'LineWidth', 1.5, 'Color', lowProbColor, 'MarkerFaceColor', lowProbColor, 'MarkerEdgeColor', lowProbColor);

    % Connect corresponding points with lines
    plot(x_positions, [pct_plus(1), pct_minus(1)], 'k--', 'LineWidth', 1.2);
    plot(x_positions, [pct_plus(2), pct_minus(2)], 'k--', 'LineWidth', 1.2);

    % Format plot
    xlim([0.5, 2.5]);
    ylim([0, 100]);
    xticks(x_positions);
    xticklabels({'CS+', 'CS-'});
    ylabel('% of Modulated Neurons');
%     title('Neuron Percentages for Odors CS+ and CS-');
    legend({'CS+ (First)', 'CS+ (Second)', 'CS- (First)', 'CS- (Second)'}, ...
           'Location', 'NorthEast');
    hold off;
    set(gca, 'FontSize', 18);box off;
end
