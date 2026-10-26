function [expParam] = event_Extract(expParam)

% read the events from the nlyx events file
% return the start and end time of the experiment and all event times

Filename='Events.nev';
FieldSelection=[1 1 1 1 1];
ExtractHeader=1;
ExtractMode=1; 
ModeArray=1;  

[Timestamps, ~, ~, ~, ~, ~] =Nlx2MatEV( [expParam.dirPath '\' Filename], FieldSelection, ExtractHeader,ExtractMode,ModeArray);

expParam.expStartTime = Timestamps(1)/expParam.TetrodeTimeFactor;
expParam.expEndTime = Timestamps(end)/expParam.TetrodeTimeFactor;

%removing the start&stop events
Timestamps=Timestamps-Timestamps(1);
Timestamps(1)=[];
Timestamps(end)=[];

 % convert times to seconds relative to recording time
    
 if rem(length(Timestamps),2)~=0
    Timestamps(1)=[];
 end
 
 expParam.nlxOdorEventsTime = reshape(Timestamps/expParam.TetrodeTimeFactor,2,[]); 



