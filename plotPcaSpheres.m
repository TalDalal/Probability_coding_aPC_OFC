function [] = plotPcaSpheres(trialsByNeuronsMat, numOfOdors, clrMat)
%% params

trialNum = size(trialsByNeuronsMat,1)/numOfOdors;

% color matrix
% clrMat = [0.2984    0.9308    0.7855; ...
%     0.3330    0.1549    0.7031; ...
%     0.7311    0.7012    0.2633; ...
%     0.0999    0.8605    0.0948; ...
%     0.2058    0.8897    0.9785; ...
%     0.7094    0.2452    0.7921];

%% PCA
% figure;
[pc,sc,g]=pca(trialsByNeuronsMat);

hold all;
for jj=1:numOfOdors% Run over all odors
    
    % Find the PC values of all current trials
    currValues = [sc((jj-1)*trialNum+1:(jj)*trialNum,1), ...
        sc((jj-1)*trialNum+1:(jj)*trialNum,2),sc((jj-1)*trialNum+1:(jj)*trialNum,3)];
    
    %MEAN+S.E.M
    meanCurrValues = mean(currValues);%In X Y and Z axes.
    seCurrValues = std(currValues)./sqrt(size(currValues,1));%In X Y and Z axes.
    
    
    %Compute the 3d dimensions of the sphere using the SE.
    [X,Y,Z] = sphere;
    X = X*seCurrValues(1);
    Y = Y*seCurrValues(2);
    Z = Z*seCurrValues(3);
    
    %Plot the sphere
    surf(X+meanCurrValues(1),Y+meanCurrValues(2),Z+meanCurrValues(3),  'FaceColor', 'none', 'EdgeColor', clrMat(jj,:))
    zlim([-20 25])
    
    %Scatter all PCA values
%     scatter3(currValues(:,1),currValues(:,2), currValues(:,3), 30, clrMat(jj,:), 'fill')
    
    %Clear
    currValues = [];meanCurrValues = [];seCurrValues = [];
    X = []; Y = [];Z = [];
    
end

%Plotting parameters
xlabel('PC1','fontSize',14); ylabel('PC2','fontSize',14); zlabel('PC3','fontSize',14)
set(gca,'fontSize',14)
box off;
set(gca,'tickdir','out','ticklength',get(gca,'ticklength')*2);
set(gca,'linewidth',.25)
xlim([-25 40]);ylim([-15 30])

set(gcf, 'Renderer','painters' )