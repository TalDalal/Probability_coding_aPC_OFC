function [odorTimes] = odorTimeStamps(params)

odorSignal = params.allChnls(params.odorsChnl,:);
odorTh = params.odorTh;

% find odor on/off times

indx1 = find(odorSignal > odorTh);
indx2 = find(odorSignal <= odorTh);

odorSignal(indx1) = 1;
odorSignal(indx2) = 0;

odorStartEndTimes = diff(odorSignal);
odorOn = find(odorStartEndTimes > 0);
odorOff = find(odorStartEndTimes < 0);

% We expect to N*2 in trials with two odors (<4) and N trials of single
% odor (4+5)
expectedNumTrials = length(find(params.trialsIndex<4))*2 + length(find(params.trialsIndex>=4));
if length(odorOn) < expectedNumTrials & length(odorOff) < expectedNumTrials
    % In previous runs of the labview script we missed the first event so we
    % complete it here
    odorOn = [0 odorOn];
    odorOff = [0 odorOff];
end
odorTimes = [odorOn ; odorOff];



