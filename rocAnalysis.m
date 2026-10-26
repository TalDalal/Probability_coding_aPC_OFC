%% roc analysis


    

aucAll=[];
%
winsize=mean(diff(bins));
aucAll=[];
for i=1:size(allNeurons,2)
    %[resMat1, zeroIndx, rocStruct] = plotAllConnNeruons(allNeurons, contraEx, timeRange, bins, normalizeFlag);

    A = getPsthContraIps(allNeurons, i, responseType, timeRange, suffel);

    aucAll(end+1,:) = computePsthRoc(A, bins);  % first two bins are used to evalute bg 
    
end

%
zeroIndx = find(bins > 0);
zeroIndx = zeroIndx(1)-1;

xrange = bins(6:end);


x=sum(aucAll(:,zeroIndx:zeroIndx+0.2/winsize),2);
[a,b]=sort(x,'descend');
imagesc(xrange, [], aucAll(b,4:end),[0 1])

% keep the AUC value in allNeuons
for i=1:size(allNeurons,2)
    allNeurons(i).auc = aucAll(i,zeroIndx+2:end);
end