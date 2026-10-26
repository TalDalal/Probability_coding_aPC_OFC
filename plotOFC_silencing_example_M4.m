clear;clc
load('F:\Experiments\2022\Behavior_Probability\head_fixed\data\M4_h4dmGi_OFC\JHU_Validation\JHU_Validation\allSessions.mat')
data(1).times=allSessions{1}.expParams{1}.neuronSpikeTime{1}.t;
[R,t] = mypsth(data,5, 'n');
t = t./60;


figure;
plot(t, R, 'k')
set(gca, 'FontSize', 14');box off;
xlabel('Time from injection (min)');ylabel('Firing rate (Hz)');