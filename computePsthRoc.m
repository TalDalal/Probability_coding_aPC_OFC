function aucPerBin = computePsthRoc(A, bins, numberOfBackBins)
% A is the psth structure
% bins - is the array of bins from which we compute auc values
% first two bins are background values
if nargin < 3
    numberOfBackBins = 2;
end

aucPerBin=[];
[~, ~ , rocStruct] = binSpikeStruct(A, bins);   

bg = rocStruct(:,1:numberOfBackBins);  % first numberOfBackBins bins are background
bg=bg(:);
for col = numberOfBackBins+1:size(rocStruct,2);
    hits=[]; fp=[];c=0; auc=0;
    for cr = 0:max(rocStruct(:))
        c=c+1;
        hits(end+1) = length(find(rocStruct(:,col) >= cr))/size(rocStruct,1);
        fp(end+1) = length(find(bg >= cr))/length(bg) ;   

        %tr = trapz( fp(end), hits(end))
        if c>1
            auc = auc + -(fp(end)- fp(end-1))*(hits(end)+hits(end-1))/2;
        end
    end
    %auc = auc + -(fp(2)- fp(1))*(hits(2)+hits(1))/2;
%         if responseType == 2
%             auc = 1-auc;
%         end
    aucPerBin(end+1) = auc;

end
