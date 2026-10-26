function [] = plotLiveSignal(params, wantedChannels, trialToView,videoFileName)

close all;
channelsData = params.allChnls(wantedChannels,:);
Fs = params.sampleRate;
t = 0:1/Fs:length(channelsData)/Fs - 1/Fs;


beginningFactor = -4*Fs;
endFactor = 2*Fs;
firstTimePoint = [params.targetOdor(1,trialToView(1))+beginningFactor params.targetOdor(1,trialToView(2))+endFactor]./Fs;
% viewRange = [firstTimePoint-1  firstTimePoint + 50];

disp(['Trials type: ' num2str(params.trialsIndex(trialToView(1):trialToView(2)))])
disp(['Lick indicator type: ' num2str(params.lickIndicator(trialToView(1):trialToView(2)))])




%Cut the signal according to the ROI
roiInds = find(t >= firstTimePoint(1) & t < firstTimePoint(end));
tPlot = t(roiInds);
y=channelsData(:,roiInds);

%Play the video
% implay(videoFileName)

pause(5)
figure(1)
hold all
% X and Y axis view
Dx=3000;y1=-3;y2=5;
%Interval of speed
speedInterval = 10;
%Plot
plot(tPlot,y);
axis off
% legend('Lick', 'Odor')
for n=1:speedInterval:length(roiInds)
    axis([tPlot(n) tPlot(n+Dx) y1 y2]);drawnow
end
