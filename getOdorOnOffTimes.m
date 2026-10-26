function [odorOn odorOff] = getOdorOnOffTimes(odorRes, odorTh, numOfTrials)
% find odor on/off times
if nargin < 2
    odorTh = 0;
end

indx1 = find(odorRes > odorTh);
indx2 = find(odorRes <= odorTh);

odorRes(indx1) = 1;
odorRes(indx2) = 0;

odorStartEndTimes = diff(odorRes);
odorOn = find(odorStartEndTimes > 0, numOfTrials);
odorOff = find(odorStartEndTimes < 0, numOfTrials);


% correct a situation you start recoding after the experient started and
% you lost the first event
if abs(length(odorOn) - length(odorOff)) > 1
    error('probnlem with extracting odor on set times. number of ons != number of Off')
end

if length(odorOn) - length(odorOff) == -1
    disp('correcting missing first start time of odor')
    if odorOn(1) > odorOff(1) & odorOn(1) < odorOff(2)
        d = mean(odorOff(2:end)-odorOn(1:end));
        x =  odorOff(1) - d;
        x = max(x,1); % negative values are not allowed
        odorOn = [x odorOn];
    end
end


