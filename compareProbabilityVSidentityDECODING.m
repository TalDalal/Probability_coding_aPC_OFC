clear;clc
[allMiceData] = concateMiceData([9]);
[probReal, probShuff] = decodeProbabilityAcrossTime(allMiceData, [-4 -2], [-4 0], 'allTrials', 'Probability', 'all');
[identReal, identShuff] = decodeProbabilityAcrossTime(allMiceData, [-4 -2], [-4 0], 'allTrials', 'Identity', 'all');

patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];csOdorsTimeWin = [0 1];
minMaxPatch = [0.3 1.05];
figure;
hold all;

patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')


errorbar_patch(probReal(1,:), probReal(2,:), probReal(3,:), 'b')
errorbar_patch(probShuff(1,:), probShuff(2,:), probShuff(3,:), 'k')

errorbar_patch(identReal(1,:), identReal(2,:), identReal(3,:), 'r')
errorbar_patch(identShuff(1,:), identShuff(2,:), identShuff(3,:), 'm')

box off;set(gca, 'FontSize', 18);
xlabel('Time (sec)');ylabel('Accuracy (%)');set(gcf, 'Renderer', 'painters');
ylim(minMaxPatch);
