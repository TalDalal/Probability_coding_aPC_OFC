function [] = plotFArateAcrossMice(miceData)
% Plot the learning curve per mouse
probExpCounter = 0;pretrainCounter = 0;sessionNumPretrain = [];

CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
for miceInd = 1:size(miceData,2)
    for recInd = 1:size(miceData(miceInd).allRecs,2)
        
        if miceData(miceInd).allRecs(recInd).sessionNum > 0
            probExpCounter = probExpCounter + 1;
            %--------A success rate
            A_SR(probExpCounter) = miceData(miceInd).allRecs(recInd).data.successRate.A;
            
            %HITs and FA
            A_HIT_FA(:,probExpCounter) = [miceData(miceInd).allRecs(recInd).data.hitRate.A;miceData(miceInd).allRecs(recInd).data.FA.A];
            
            %-------C success rate
            C_SR(probExpCounter) = miceData(miceInd).allRecs(recInd).data.successRate.C;
            %HIT anf FA
            C_HIT_FA(:,probExpCounter) = [miceData(miceInd).allRecs(recInd).data.hitRate.C;miceData(miceInd).allRecs(recInd).data.FA.C];
            
        end
    end
end


%% Plot


figure;
scatter(C_HIT_FA(2,:), A_HIT_FA(2,:),80, A_SR, 'filled')
hold all;
FAlim = [-.1 .8];
plot(FAlim, FAlim, 'k--')
xlim(FAlim)
ylim(FAlim)
xlabel('Low (P = 0.25)');
ylabel('High (P = 0.75)');
title('FA analysis')
set(gca, 'FontSize', 14');box off;
colormap pink
hcb = colorbar;
hcb.Title.String = "Success rate";
caxis([0.6 1])
[~,pFA] = ttest(A_HIT_FA(2,:),C_HIT_FA(2,:));
title(['FA, P = ' num2str(pFA)])

figure;
scatter(A_SR(1,:), C_SR(1,:))
hold all;
FAlim = [-.1 1.1];
plot(FAlim, FAlim, 'k--')
xlim(FAlim)
ylim(FAlim)
xlabel('Low (P = 0.25) hit ');
ylabel('High (P = 0.75) hit ');
title('FA analysis')
set(gca, 'FontSize', 14');box off;
hcb = colorbar;
hcb.Title.String = "Success rate";
caxis([0.4 1])
[~,pHit] = ttest(A_SR,C_SR);
title(['FA, P = ' num2str(pHit)])



