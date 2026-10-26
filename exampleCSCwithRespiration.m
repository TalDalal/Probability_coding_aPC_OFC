%%
expParam.dirPath = pwd;
expParam.TetrodeTimeFactor = 10^6;expParam.expStartTime = 0;

[expParam] = event_Extract(expParam);
events = expParam.nlxOdorEventsTime;
%%
CSCpath = 'F:\Experiments\2022\Behavior_Probability\head_fixed\data\M10_h4dmGi_OFC\Passive_odors\11122023\2023-12-11_13-47-20\CSC12.ncs';
respirationPath = 'F:\Experiments\2022\Behavior_Probability\head_fixed\data\M10_h4dmGi_OFC\Passive_odors\11122023\2023-12-11_13-47-20\CSC33_RESPIRATION.ncs';
[~, ~, SampleFrequencies, ~, currCSCchannel, ~] = Nlx2MatCSC(CSCpath, [1 1 1 1 1],1, 1, 0);
[~, ~, SampleFrequencies, ~, currRespchannel, ~] = Nlx2MatCSC(respirationPath, [1 1 1 1 1],1, 1, 0);
sampleRate = SampleFrequencies(1);
%%
% decimate 
decimationFactor=2;
spikes = decimate(currCSCchannel(:), decimationFactor);
resp = decimate(currRespchannel(:), decimationFactor);
resp = bandpass_signal(resp,sampleRate/decimationFactor,0.2,20);
%%
timeFrame = [0 100];
t = 0:1/(sampleRate/decimationFactor):length(spikes)./(sampleRate/decimationFactor) - 1/(sampleRate/decimationFactor);
plotLocs = find(t > timeFrame(1) & t < timeFrame(2));
figure;
plot(t(plotLocs), spikes(plotLocs))
hold all;
plot(t(plotLocs), resp(plotLocs).*2)

scatter(events(1,:),zeros(1, size(events,2)), 'k*')
scatter(events(2,:),zeros(1, size(events,2)), 'k*')
xlim([timeFrame])