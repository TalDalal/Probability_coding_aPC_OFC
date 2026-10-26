filenames = {'21.4_2_1.mat'};
fileNums=1:(length(filenames))

size_window=5;
sampleRate=1000;

figure;
LegendsStrings = cell(numel(filenames),1);
%clr={[1 0 0];[1 0 1];[0 1 1];[0 1 0];[0 0 1];[0 0 0];[0.49  0.18 0.56];[0.2 0.5 0.68]};
successrate_all=[];
lick_resp=[];
for kk = 1:numel(filenames)
    load(filenames{kk});

 subplot(2,2,1)
 clr='rbkgm';
 subplot(2,2,1)
 for i=size(exp.allchannels,1):-1:1
     plot((1:size(exp.allchannels,2))./sampleRate, exp.allchannels(i,:) , clr(i));  % light signals
     hold on;
 end

 subplot(2,2,3)
 %%%%%%%%%%%% Moving Average time difference for each 10 trials
 [mov_avg_time_diff_10trials]=motivation_on10trials(exp,params,size_window);
 plot(1:length(mov_avg_time_diff_10trials),mov_avg_time_diff_10trials,'color',clrs(kk),'linestyle','-','marker','.')
 %LegendsStrings{kk} = ['od concentration = ',num2str(params.odor_concentration)];
  ylabel(' average time diff for trials(s)')
  xlabel('#trials')
  hold on
 %%%%%%%%%%%%%%% successrate over 10 trials
 figure
 subplot(1,3,1)
 [successrate_per10trial, successrate_uptolasttrial,SuccessHits,Falseallarm]=successrate_ontrials(exp,params,size_window);
 plot(1:length(successrate_per10trial),successrate_per10trial,'*-')
 LegendsStrings{kk} = ['od concentration = ',num2str(params.odor_concentration)];
 LegendsStrings{kk} = ['OC = ',num2str(params.odor_concentration)];
 LegendsStrings{kk}=['run number',num2str(fileNums)];

 hold on
 plot(1:length(successrate_uptolasttrial),successrate_uptolasttrial,'color',clrs(kk),'linestyle','-','marker','none')
  hold on
 ylabel(' successrate')
 xlabel(' #trials')
 successrate_all=[successrate_all;params.odor_concentration,successrate_uptolasttrial(end) ];
 subplot(1,3,2)
 plot(1:length(SuccessHits),SuccessHits,'color',clrs(kk),'linestyle','-','marker','none')
 hold on
   ylabel(' HITS')
 xlabel(' #trials')
 subplot(1,3,3)
 plot(1:length(Falseallarm),Falseallarm,'color',clrs(kk),'linestyle','--','marker','x','markersize',4) 
 hold on
  
  ylabel(' False Alarms')
 xlabel(' #trials')
 %%%%%%%%%%%%%%%lick response time
 
 [odoron,lickon]=lickresponse(exp,params);
 lick_responsetime=nonzeros(lickon-odoron);
 avg_lick_resp=mean(lick_responsetime);
 lick_resp=[lick_resp;params.mice_no params.odor_duration mean(lick_responsetime) std(lick_responsetime)];
  subplot(2,2,4)
  plot(1:length(lick_responsetime),lick_responsetime,'color',clrs(kk),'linestyle','-','marker','.')
  ylabel(' lick response time (ms)')
  xlabel(' lick count')
  hold on
end
subplot(1,3,1)
legend(LegendsStrings, 'Interpreter', 'none')
%suptitle(['odor duration=', num2str(params.odor_duration),'ms',',', 'odor concentration=',num2str(params.odor_concentration),'%',',','Mice id=',num2str(params.mice_no) ])
%hold on
suptitle([ 'odor concentration=',num2str(params.odor_concentration),',','Mice id=',num2str(params.mice_no) ])