function [phase, R,t,tAll,Rall] = plotSniffPhaseRaw(sniffTimes, t, SNIFF_JUMP, figureFlag)
% use sniff times and spike times to plot the sniff phases
% we use every SNIFF_JUMPth sniff
if nargin < 4
    figureFlag = 1;
end

inhaleColor = [200 200 240]./255;
exhaleColor = [200 200 200]./255;

%%
data=[];exhaleLen=[];inhaleLen=[];sniffRadSpikes = [];

if figureFlag
    figure; 
end
hold all
cc=0; sniffDurAll=[];maxSniffDur = 2;
for i = 1:SNIFF_JUMP:size(sniffTimes,2)-1
    cc=cc+1;
    tIndx = find(t >= sniffTimes(1,i)-1 & t < sniffTimes(1,i+1) +1);
    data(cc).times = t(tIndx) - sniffTimes(1,i);
    
    sniffDur  = sniffTimes(1,i+1) - sniffTimes(1,i);
    
    sniffDurSpikes = t(find(t >= sniffTimes(1,i) & t < sniffTimes(1,i+1)))-sniffTimes(1,i);
    if ~isempty(sniffDurSpikes)
       sniffRadSpikes = [sniffRadSpikes ;(sniffDurSpikes./sniffDur)*2*pi];
    end

    sniffDurAll = [sniffDurAll  sniffDur];

    xdata1 = [0 sniffDur sniffDur  0];
    ydata1 = [cc cc cc+1 cc+1];
    patch(xdata1,ydata1, inhaleColor, 'EdgeColor','none');


    scatter(data(cc).times, cc*ones(1,length(data(cc).times)),'.k')
end
% 
[R,t]=mypsth(data);
tAll = t;Rall = R;
index = find(t > 0 & t < 1);
tAll = t(index);Rall = R(index);
ind = find(t > 0);
t=t(ind:end);
R=R(ind:end);
meanSnifDur = mean(sniffDurAll );
ind = find(t > meanSnifDur);
t=t(1:ind+1);
R=R(1:ind+1);
hold off;
lp.rayleihPhase_Pval = circ_rtest(sniffRadSpikes);
lp.rayleihPhase = circ_mean(sniffRadSpikes);

title(['phase = ' num2str(lp.rayleihPhase) ' p = ' num2str(lp.rayleihPhase_Pval)])
xlim([-maxSniffDur+1 maxSniffDur])


