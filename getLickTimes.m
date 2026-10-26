function [lickTime, lickRes] = getLickTimes(lickRes, lickTh)
% find lick times
if nargin < 2
    lickTh = 0;
end

indx1 = find(lickRes > lickTh);
indx2 = find(lickRes <= lickTh);

lickRes(indx1) = 1;
lickRes(indx2) = 0;

lickStartEndTimes = diff(lickRes);
lickOn = find(lickStartEndTimes > 0);
lickOff = find(lickStartEndTimes < 0);


% correct a situation you start recoding after the experient started and
% you lost the first event
% if abs(length(lickOn) - length(lickOff)) > 1
%     error('probnlem with extracting odor on set times. number of ons != number of Off')
% end
% Correct start ith no end
if length(lickOn) > length(lickOff)
    lickOn(length(lickOff)+1:end) = [];
elseif length(lickOn) < length(lickOff)
    lickOff(length(lickOn)+1:end) = [];
end

if length(lickOn) - length(lickOff) == -1
    disp('correcting missing first start time of odor')
    if lickOn(1) > lickOff(1) & lickOn(1) < lickOff(2)
        d = mean(lickOff(2:end)-lickOn(1:end));
        x =  lickOff(1) - d;
        lickOn = [x lickOn];
    end
end


lickTime = [lickOn; lickOff];

