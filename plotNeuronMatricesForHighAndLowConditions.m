function [outputStructCueOdor] = plotNeuronMatricesForHighAndLowConditions(allRecsStruct, periodToSort, timeWinToCluster, auROCWinSize, trialOutcome)

if nargin < 5
    trialOutcome = [];
end

CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
patchColor = [190, 190, 190]./255;


%% A
[allAuROCtracesA, ROCvalsPeriodToSort, timeBins, originalPSTH] = createAuROCMatrix(allRecsStruct,auROCWinSize, 'Atrials', periodToSort, trialOutcome);
%Sort the auROC responses
[~,locs] = sort(ROCvalsPeriodToSort, 'descend');

%% C
[allAuROCtracesC, ~,~,~] = createAuROCMatrix(allRecsStruct,auROCWinSize, 'Ctrials', periodToSort, trialOutcome);

%% plot the matrices sorted by the firing rate in the 'periodToSort' window.

params = allRecsStruct(1).data;

fig = figure;
subplot(1,2,1)
sortedAllAuROCtracesA = allAuROCtracesA(locs,:);
imagesc(timeBins,1:length(allAuROCtracesA), sortedAllAuROCtracesA)
caxis([0.2 1])
hold all
%first odor
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')

%second odor 
plot(zeros(1,2), [size(allAuROCtracesA,1)  1], 'k--')
plot((params.odor_duration.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
set(gca, 'FontSize', 15);box off;
% xlabel('Time relative to CS (sec)');ylabel('Neurons')
% title('H - auROC')
xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])
crameri oslo
% colorbar

subplot(1,2,2)
sortedAllAuROCtracesC = allAuROCtracesC(locs,:);
imagesc(timeBins,1:length(allAuROCtracesC), sortedAllAuROCtracesC)
caxis([0.2 1])
hold all
%first odor
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')

%second odor
plot(zeros(1,2), [size(allAuROCtracesC,1)  1], 'k--')
plot((params.odor_duration.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')
set(gca, 'FontSize', 15);box off;
% xlabel('Time from CS (S)');ylabel('Neurons')
% title('L - auROC')
xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])
crameri oslo
ylabel('')
set(gca, 'YTickLabel', '')

han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
set(gca, 'FontSize', 14);
han.YLabel.Visible='on';
ylabel(han,'Neurons');
xlabel(han,'Time from CS (S)');

firstLastPSTHvalue = [timeWinToCluster(1)-1 timeWinToCluster(2) + 1];
allPSTHs_A_Inh = [];allPSTHs_A_Exc = [];
allPSTHs_C_Inh = [];allPSTHs_C_Exc = [];
responseDirection_C = [];responseDirection_A = [];
allPSTHs_A = [];allPSTHs_C = [];
for psthInd = 1:size(originalPSTH,2)
    %Current PSTH and time vector
    currPSTH_A = originalPSTH(psthInd).A(2,:);
    currTime_A = originalPSTH(psthInd).A(1,:);
    %Compute the bins of the time vector
    currTimeBin = median(diff(currTime_A));
    %Find the first index 
    if currTime_A(1) < firstLastPSTHvalue(1)
        firstInd = find(currTime_A >= firstLastPSTHvalue(1),1);
        
        cutPSTH_A = currPSTH_A(firstInd: firstInd+floor(diff(firstLastPSTHvalue)/currTimeBin));
        cutCurrTime_A = currTime_A(firstInd: firstInd+floor(diff(firstLastPSTHvalue)/currTimeBin));
        
        % normalize
        Z_cutPSTH_A = (cutPSTH_A - mean(cutPSTH_A(1:firstInd)));

        allPSTHs_A(end+1,:) = Z_cutPSTH_A;
        % check if this was an inhibitory or excitstory response
        if mean(Z_cutPSTH_A(find(cutCurrTime_A >= timeWinToCluster(1) & cutCurrTime_A < timeWinToCluster(2)))) < 0
            allPSTHs_A_Inh(end+1,:) = Z_cutPSTH_A;
            responseDirection_A(end+1) = -1;
        else
            allPSTHs_A_Exc(end+1,:) = Z_cutPSTH_A;
            responseDirection_A(end+1) = 1;
        end
    else
        allPSTHs_A(end+1,:) = nan(1,size(allPSTHs_A,2));
        responseDirection_A(end+1) = nan;
    end
    
     %Current PSTH and time vector
    currPSTH_C = originalPSTH(psthInd).C(2,:);
    currTime_C = originalPSTH(psthInd).C(1,:);
    %Compute the bins of the time vector
    currTimeBin = median(diff(currTime_C));
    %Find the first index 
    if currTime_C(1) < firstLastPSTHvalue(1)
        
        firstInd = find(currTime_C >= firstLastPSTHvalue(1),1);
        
        cutPSTH_C = currPSTH_C(firstInd: firstInd+floor(diff(firstLastPSTHvalue)/currTimeBin));
        cutCurrTime_C = currTime_C(firstInd: firstInd+floor(diff(firstLastPSTHvalue)/currTimeBin));
        
        %Normalize
        Z_cutPSTH_C = (cutPSTH_C - mean(cutPSTH_C(1:firstInd)));
        
        allPSTHs_C(end+1,:) = Z_cutPSTH_C;

        % check if this was an inhibitory or excitstory response
        if mean(Z_cutPSTH_C(find(cutCurrTime_C >= timeWinToCluster(1) & cutCurrTime_C < timeWinToCluster(2)))) < 0
            allPSTHs_C_Inh(end+1,:) = Z_cutPSTH_C;
            responseDirection_C(end+1) = -1;
        else
            allPSTHs_C_Exc(end+1,:) = Z_cutPSTH_C;
            responseDirection_C(end+1) = 1;
        end
    else
        allPSTHs_C(end+1,:) = nan(1,size(allPSTHs_C,2));
        responseDirection_C(end+1) = nan;
    end

end

cutTimeBins = firstLastPSTHvalue(1):currTimeBin:firstLastPSTHvalue(2);
ZminMaxPlot = [-2 4];
figure;
hold all;
% plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, ZminMaxPlot, 'k-', 'LineWidth', .5)
% plot((-params.ISIbetweenOdors.*ones(1,2))./1000, ZminMaxPlot, 'k-', 'LineWidth', .5)
cueOdorsTimeWin = [-2 -1];minMaxPlot = [-3 4];
patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPlot(1) minMaxPlot(1) minMaxPlot(2) minMaxPlot(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

%second odor
% plot(zeros(1,2), ZminMaxPlot, 'k-', 'LineWidth', .5)
% plot((params.odor_duration.*ones(1,2))./1000, ZminMaxPlot, 'k-', 'LineWidth', .5)

errorbar_patch(cutTimeBins, mean(allPSTHs_A_Exc),std(allPSTHs_A_Exc)./sqrt(size(allPSTHs_A_Exc,1)), AColor);
errorbar_patch(cutTimeBins, mean(allPSTHs_A_Inh),std(allPSTHs_A_Inh)./sqrt(size(allPSTHs_A_Inh,1)), AColor, '--');

errorbar_patch(cutTimeBins, mean(allPSTHs_C_Exc),std(allPSTHs_C_Exc)./sqrt(size(allPSTHs_C_Exc,1)), CColor);
errorbar_patch(cutTimeBins, mean(allPSTHs_C_Inh),std(allPSTHs_C_Inh)./sqrt(size(allPSTHs_C_Inh,1)), CColor, '--');
set(gcf, 'Renderer', 'painters');
set(gca, 'FontSize', 15);box off;
xlabel('Time from CS (sec)');ylabel('Z-score')
xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])

%OUTPUT
outputStructCueOdor.sortedAllAuROCtracesA = sortedAllAuROCtracesA;
outputStructCueOdor.sortedAllAuROCtracesC = sortedAllAuROCtracesC;
outputStructCueOdor.timeBins = timeBins;


outputStructCueOdor.cutTimeBins = cutTimeBins;
outputStructCueOdor.allPSTHs_A_Exc = allPSTHs_A_Exc;
outputStructCueOdor.allPSTHs_A_Inh = allPSTHs_A_Inh;
outputStructCueOdor.allPSTHs_C_Exc = allPSTHs_C_Exc;
outputStructCueOdor.allPSTHs_C_Inh = allPSTHs_C_Inh;

outputStructCueOdor.allPSTHs_A = allPSTHs_A;
outputStructCueOdor.allPSTHs_C = allPSTHs_C;
outputStructCueOdor.responseDirection_C = responseDirection_C;
outputStructCueOdor.responseDirection_A = responseDirection_A;





