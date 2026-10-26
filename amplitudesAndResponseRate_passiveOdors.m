clear;
if ismac
    cd('/Volumes/My Passport/Tal/Experiments/2022/Behavior_Probability/head_fixed/data/passive_odor_stimulation');
else
    cd('F:\Experiments\2022\Behavior_Probability\head_fixed\data\passive_odor_stimulation');
end
load('allPassiveOdorData.mat')
%%
odorIdentities{1} = '2-heptanone(cue)';%'A'
odorIdentities{2} = 'ethyl-acetate(cue)';%'C'
odorIdentities{3} = 'ethyl-butyrate(CS+)';%'T+'
odorIdentities{4} = 'penthyl-acetate(CS-)';%'T-'

clrArray = [155,41,72 ; 255,114,81 ; 85,51,17 ; 153,102,51]./255;
%%
bgDuration = [-4 -2];
fgDuration = [0 1];
pAlpha = 0.01;
c = 0;
psthKernel = 0.07;
%%

responseRateMat = nan(100,size(odorIdentities,2));
evokedResponse = nan(100,size(odorIdentities,2));

neuronsPerMouse = [];
odorPSTHmatrix = [];
%%
for mouseInd = 1:size(allPassiveOdorData,2)
    %Current mouse
    currMouse = allPassiveOdorData(mouseInd).data;
    
    neuronsPerMouse(mouseInd) = size(currMouse.firingRates,2);
    
    trialsArray{1} = currMouse.Atrials;
    trialsArray{2} = currMouse.Ctrials;
    trialsArray{3} = currMouse.TplusTrials;
    trialsArray{4} = currMouse.TminusTrials;
    
    for neuronInd = 1:size(currMouse.firingRates,2)
        
        
        c = c + 1;
        
        %Curr fr matrix
        currFR = currMouse.firingRates(neuronInd).firingRateByBIn;
        currT = currMouse.firingRateAnalysisBins;
        
        for odorInd = 1:size(trialsArray,2)
            
            %----- Response rate----
            [respFlag, evResponse] = bgFg_passiveOdors(bgDuration, fgDuration, currFR, currT, trialsArray{odorInd}, pAlpha);
            
            responseRateMat(c,odorInd) = respFlag;
            evokedResponse(c,odorInd) =  evResponse;
            
            %----- PSTH ------
            if respFlag
                currOdorRaster = currMouse.allRasterPlots(neuronInd).data(trialsArray{odorInd});
                %PSTH
                [R,t] = mypsth(currOdorRaster, psthKernel, 'n');
                %Norm
                psthBG = mean(R(find(t < 0)));
                R = R - psthBG;
                %Clip
                firstValuePSTH = find(t >= -1,1);
                R = R(firstValuePSTH:firstValuePSTH+250);
                tShort = t(firstValuePSTH:firstValuePSTH+250);
                
                if mean(R(find(tShort >= fgDuration(1) & tShort < fgDuration(2)))) > 0
                    respSign = 1;
                else
                    respSign = -1;
                end
                
                %Add the odor index and response sign at the end
                odorPSTHmatrix(end+1,:) = [R odorInd respSign];
            end
                
                
                
        end
    end
end
%% Response rate to each odor
responseRateMat = responseRateMat(1:c,:);
evokedResponse = evokedResponse(1:c,:);

neuronsPerMouseSum = [0 cumsum(neuronsPerMouse)];
for neuronsInd = 1:length(neuronsPerMouseSum)-1
    ratePerMouse(neuronsInd,:) = mean(responseRateMat(neuronsPerMouseSum(neuronsInd)+1:neuronsPerMouseSum(neuronsInd+1),:));
end


[~,loc] = sort(mean(responseRateMat), 'descend');
sortedMeanRate = mean(responseRateMat(:,loc));
seRate = binoDistSE(sortedMeanRate, repmat(c, 1,4));


ratePerMouse = ratePerMouse(:,loc).*100;
ratePerMouse_Array{1} = ratePerMouse(:,1);
ratePerMouse_Array{2} = ratePerMouse(:,2);
ratePerMouse_Array{3} = ratePerMouse(:,3);
ratePerMouse_Array{4} = ratePerMouse(:,4);
%% % effective odors
[numEffectiveOdors,~] = hist(sum(responseRateMat,2)',size(responseRateMat,2)+1);
numEffectiveOdors = numEffectiveOdors./size(responseRateMat,1);
effectiveOdorsSE = binoDistSE(numEffectiveOdors, repmat(size(responseRateMat,1), 1,length(numEffectiveOdors)));
effectiveOdorsVec = 0:size(responseRateMat,2);

%% plot
figure;
errorbar(sortedMeanRate.*100, seRate.*100)
set(gca, 'FontSize', 18, 'XTickLabel', {odorIdentities{loc(1)}, odorIdentities{loc(2)}, odorIdentities{loc(3)}, odorIdentities{loc(4)}});box off;
xtickangle(45);ylabel('Active neurons (%)');
title(['N = ' num2str(size(responseRateMat,1)) ' neurons'])
hold all
plotSpread(ratePerMouse_Array, 'distributionMarkers', {'o', 'o','o', 'o'})


figure;
errorbar(effectiveOdorsVec, numEffectiveOdors.*100, effectiveOdorsSE.*100)
set(gca, 'FontSize', 18);
ylabel('Active neurons (%)');xlabel('# effective odors')
title(['Passive - N = ' num2str(size(responseRateMat,1)) ' neurons'])


%% plot mean PSTH
figure;
for odorInd = 1:size(trialsArray,2)
    subplot(1,4,odorInd)
    currPSTH_exc = odorPSTHmatrix(find(odorPSTHmatrix(:,end-1)==odorInd & odorPSTHmatrix(:,end)>0),1:end-2);
    currPSTH_inh = odorPSTHmatrix(find(odorPSTHmatrix(:,end-1)==odorInd & odorPSTHmatrix(:,end)<0),1:end-2);
    
    errorbar_patch(tShort, mean(currPSTH_exc), std(currPSTH_exc)./size(currPSTH_exc,1), clrArray(odorInd,:))
    hold on;
    errorbar_patch(tShort, mean(currPSTH_inh), std(currPSTH_inh)./size(currPSTH_inh,1), clrArray(odorInd,:))
    
    title(odorIdentities{odorInd});set(gca, 'FontSize', 18);box off;
    ylim([-8 8]);xlim([-1 2]);patch([fgDuration(1) fgDuration(2) fgDuration(2) fgDuration(1)], [-8 -8 8 8], [.5 .5 .5],'EdgeColor','none','FaceAlpha',0.1)
end

    
 %% plot CS+\- super imposed
 figure;
for odorInd = 3:4
    currPSTH_exc = odorPSTHmatrix(find(odorPSTHmatrix(:,end-1)==odorInd & odorPSTHmatrix(:,end)>0),1:end-2);
    currPSTH_inh = odorPSTHmatrix(find(odorPSTHmatrix(:,end-1)==odorInd & odorPSTHmatrix(:,end)<0),1:end-2);
    
    errorbar_patch(tShort, mean(currPSTH_exc), std(currPSTH_exc)./size(currPSTH_exc,1), clrArray(odorInd,:))
    hold on;
    errorbar_patch(tShort, mean(currPSTH_inh), std(currPSTH_inh)./size(currPSTH_inh,1), clrArray(odorInd,:), '--')
    
    title(odorIdentities{odorInd});set(gca, 'FontSize', 18);box off;
    ylim([-8 8]);xlim([-1 2]);patch([fgDuration(1) fgDuration(2) fgDuration(2) fgDuration(1)], [-8 -8 8 8], [.5 .5 .5],'EdgeColor','none','FaceAlpha',0.1)
end


%% Plot venn diagram of CS+\- responding neurons
NumCSplusResponding = sum(responseRateMat(:,3));
NumCSminusResponding = sum(responseRateMat(:,4));
NumBothResponding = sum(responseRateMat(:,4).*responseRateMat(:,3));
figure;
plot_venn_diagram(NumCSplusResponding, NumCSminusResponding, NumBothResponding)
clc
disp(['CS+\- venn: %CS+ = ' num2str(NumCSplusResponding./size(responseRateMat,1)) '; %CS- = ' num2str(NumCSminusResponding./size(responseRateMat,1)) ...
    '%_both = ' num2str(NumBothResponding./size(responseRateMat,1))])

%%
function [respFlag, evokedResponse] = bgFg_passiveOdors(bgDuration, fgDuration, FR, t, trials, pAlpha)
        bgFR = mean(FR(trials, find(t >= bgDuration(1) & t < bgDuration(2))),2);
        fgFR = mean(FR(trials, find(t >= fgDuration(1) & t < fgDuration(2))),2);
        
        evokedResponse = mean(fgFR - bgFR);
        [respFlag,~] = ttest(fgFR, bgFR, 'Alpha', pAlpha);
end

function plot_venn_diagram(A_only, B_only, AB_overlap)
% Define RGB colors for circles (normalized between 0 and 1)
color_A = [0, 169, 137] / 255;
color_B = [171, 62, 143] / 255;

% Total count for calculating percentages
total = A_only + B_only - AB_overlap ;

% Calculate percentages for each section
percent_A_only = ((A_only-AB_overlap )/ total).*100;
percent_B_only = ((B_only-AB_overlap) / total).*100;
percent_AB_overlap = (AB_overlap / total).*100;

% Create the Venn diagram
    figure;
venn([A_only, B_only], AB_overlap);

% Customize colors
h = findobj(gca, 'Type', 'patch');
set(h(1), 'FaceColor', color_B, 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Set color for B
set(h(2), 'FaceColor', color_A, 'EdgeColor', 'none', 'FaceAlpha', 0.5); % Set color for A

% Add percentage labels to each section
% Adjust the positions to avoid overlap
text(-3, 0.2, sprintf('A only: %.1f%%', percent_A_only), 'HorizontalAlignment', 'center');
text(3, 0.2, sprintf('B only: %.1f%%', percent_B_only), 'HorizontalAlignment', 'center');
text(0, .2, sprintf('A & B: %.1f%%', percent_AB_overlap), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

% Title and turn off axis for better visualization
title('Venn Diagram');
axis off;
end
    

        