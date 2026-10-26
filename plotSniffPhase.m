function [lp, t, R, meanSnifDur] = plotSniffPhase(lp, figureFlag, morphFlag,SNIFF_JUMP)
% use sniff times and spike times to plot the sniff phases
% we use every SNIFF_JUMPth sniff
if nargin < 2
    figureFlag = 0;
end
if nargin < 3
    morphFlag = 0;
end
sniffTimes = lp.inhaleTimes;
if nargin < 4
    SNIFF_JUMP = round(size(sniffTimes,2)/100);
end

% if median(diff(sniffTimes(1,:))) > median(diff(sniffTimes))
%     disp('switch inhlation with exalation')
%     x = sniffTimes(2,1:end-1);
%     x(2,:) = sniffTimes(1,2:end);
%     sniffTimes = x;
% end
     
    
inhaleColor = [200 200 240]./255;
exhaleColor = [200 200 200]./255;

%%
data=[];exhaleLen=[];inhaleLen=[];

if figureFlag
    figure; 
end
cc=0; sniffDurAll=[];


    
t=lp.t;
if morphFlag
    [sniffTimes, t, ~] = morphSniffSpikes(sniffTimes, t, []);
end
meanSnifDur = mean(diff(sniffTimes(1,:)));

% plot the raster plot (-1 to +1 sec before inhalation
oneSniffSpikesTime=[];
for i = 1:SNIFF_JUMP:size(sniffTimes,2)-1
    cc=cc+1;
    % collect all spikes 1 sec before inhlation and 1 sec after inhalation
    tIndx = find(t >= sniffTimes(1,i)-1 & t < sniffTimes(1,i+1) +1);
    data(cc).times = t(tIndx) - sniffTimes(1,i);


    

    hold on;

    sniffDur  = sniffTimes(1,i+1)-sniffTimes(1,i);
    
    tIndx = find(t >= sniffTimes(1,i) & t < sniffTimes(1,i+1));   % one snif spikes
    oneSniffSpikesTime = [oneSniffSpikesTime  (t(tIndx) - sniffTimes(1,i))/sniffDur];  %spikes time relative to sniff
    
    
    xdata1 = [0 sniffDur sniffDur  0];
    ydata1 = [cc cc cc+1 cc+1];
    patch(xdata1,ydata1, inhaleColor, 'EdgeColor','none');

%     xdata2 = [sniffDur lp.sniffTimes(2,sniffIndx(i+1)) - sniffStartEndTimes(1) lp.sniffTimes(2,sniffIndx(i+1)) - sniffStartEndTimes(1)  diff(sniffStartEndTimes) ];
%     ydata2 = [i i i+1 i+1];
%     patch(xdata2,ydata2, exhaleColor, 'EdgeColor','none');

%     inhaleLen = [inhaleLen diff(sniffStartEndTimes)];
%     exhaleLen = [exhaleLen  lp.sniffTimes(2,sniffIndx(i+1)) - sniffStartEndTimes(2) ];

    scatter(data(cc).times, cc*ones(1,length(data(cc).times)),'.k')
end
% 
oneSniffSpikesTime = oneSniffSpikesTime*2*pi;  % convert to radians

lp.phase2 = circ_mean(oneSniffSpikesTime')/(2*pi)*360;  %in angles
if lp.phase2 < 0
    lp.phase2 = lp.phase2 +360;
end

lp.pPhase = circ_rtest(oneSniffSpikesTime');

    
[R,t]=mypsth(data);
ind1 = find(t > 0,1);
ind2 = find(t > meanSnifDur,1);
t=t(ind1:ind2);
R=R(ind1:ind2);

[a,b]=max(R);
lp.R=R;
max(R) - min(R)
lp.phase = t(b)/meanSnifDur*360;
if lp.phase > 360
    disp('warninig this neuron phase might be wrong')
    lp.phase = 360;
    i
end

title([num2str(lp.fileIndx) '_' num2str(lp.mClusterIndx) ' phase = ' num2str([lp.phase lp.phase2]) ' p = ' num2str(lp.pPhase) ])

%% baseline FR
frbg=[];
for i=1:size(data,2)
    frbg(end+1) =  length(find(data(i).times > 0  & data(i).times < meanSnifDur));
end

lp.frbg = mean(frbg)/meanSnifDur;

