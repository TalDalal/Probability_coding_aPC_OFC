clear;clc
%Find the ramping neurons: PSTH, firing rate and binary mat
bgWin = [-2 -1];
fgWin = [-.4 0];
pValTH = .05;
minimalEvokeRate = .5;
[responseMat, FGmat, PSTHstruct, outcomeRasterStruct] = binaryResponseInRequestedWindow(bgWin,fgWin , pValTH, 'high', minimalEvokeRate);
%% ----A
[hitA_FR] = computeEvokedFRfromRaster(outcomeRasterStruct.hit.A, bgWin, fgWin);
[missA_FR] = computeEvokedFRfromRaster(outcomeRasterStruct.miss.A, bgWin, fgWin);

data = [hitA_FR missA_FR]';
labels = [ones(1,length(hitA_FR)) zeros(1,length(missA_FR))]';

accuracyA =SVM_binaryDecoding(data, labels, 0);
data = [];labels = [];

%% ----C
[hitC_FR] = computeEvokedFRfromRaster(outcomeRasterStruct.hit.C, bgWin, fgWin);
[missC_FR] = computeEvokedFRfromRaster(outcomeRasterStruct.miss.C, bgWin, fgWin);

data = [hitC_FR missC_FR]';
labels = [ones(1,length(hitC_FR)) zeros(1,length(missC_FR))]';
% labels = labels(randsample(length(labels),length(labels)));

% leave_one_out_decoder_chatGPT(data, labels)
[accuracyC, percentVec] =SVM_binaryDecoding(data, labels, 0);
%% Plot
figure;
plot(percentVec, accuracyA, 'r-s');
hold all;
plot(percentVec, accuracyC, 'm-s');
plot([0 100], [.5 .5], 'k--');
ylim([0 1]);set(gca, 'FontSize', 14');box off;
xlabel('% of trials used');ylabel('Accuracy');
