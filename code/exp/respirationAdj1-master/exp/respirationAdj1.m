%% RespirationAdj1
%  Forced-choice experiment with near-threshold somatosensory stimulation
%  - yes/no decision
%  - confidence about yes/no
% 
% Original author:  Martin Grund
% Last update:      December 18, 2018

% 10 block experiment
% Performing resting state block before the experimental block

% Modified by Busra Cilburunoglu and Lioba Enk
% Last update: 07 May 2026 (LE)

%%If matlab is closed DUE TO ERROR first this part make run 1 2 3 then
%%upload the preväous data seq-thr1f-resting-data1 lets say, then in
%%workplace change the data name as exp_data1, put 1 I meant!!!!!!!!!!!!
 
%% PREPARE 1
clc; clear; close all;
%% [SKIP IF RE-RUN] Initialize experiment 2
cd('E:\USER\Lioba\respirationAdj1-master\respirationAdj1-master\exp'); %change this folder path later

addpath(genpath([pwd, '/assets']))
addpath(genpath([pwd, '/thr1F']))

addpath('E:\USER\Lioba\respirationAdj1-master\respirationAdj1-master\exp\restingstate');
addpath('E:\USER\Lioba\respirationAdj1-master\respirationAdj1-master\exp\assets\func');
addpath('E:\USER\Lioba\respirationAdj1-master\respirationAdj1-master\exp');

%io64 path
send_pportTrigger(io64, hex2dec('D010'), 255);

% Experiment directory, threshold assessment directory, number of analog 
% output channels, analog input channels, samples per second
[p_data,aio_s,trig_s,ao] = exp_init_NI_new('respirationAdj1','thr1F',2,100000);

%% Re-run experiment

% (0) Got to working directory
%
%     cd('G:/ds5_control/');
%
% (1) Load sequence data "respirationAdj1_settings_seq.mat" [exp_seq; p_data; s;]
%
% (2) Load last threshold assessment data, e.g. "thr1F_01_data_02_01.mat" [p_data; thr1F; thr1F_data;]
%
% (3) Rename "thr1F_data" to last successful threshold assessment:
%
%     thr1F_data1 = thr1F_data; clear thr1F_data; % If 1st block failed
%     thr1F_data2 = thr1F_data; clear thr1F_data; % If 2nd block failed
%     thr1F_data3 = thr1F_data; clear thr1F_data; % If 3rd block failed
%     thr1F_data4 = thr1F_data; clear thr1F_data; % If 4th block failed
%
% (4) Load last block data, e.g. "respirationAdj1_01_data_02.mat" [exp_data; p_data; s;]
%
% (5) Rename 'exp_data' to the loaded block:
%
%     exp_data1 = exp_data; clear exp_data;
%     exp_data2 = exp_data; clear exp_data;
%     exp_data3 = exp_data; clear exp_data;
%     exp_data4 = exp_data; clear exp_data;
%
% (6) Initialize experiment
%
%     cd('G:/ds5_control/');
%
%     [aio_s,ao,ai] = exp_re_init_NI('respirationAdj1','thr1F',p_data,2,2,100000);
%
% (7) Run "Test DAQ card" section (Strg + Enter)
%
% (8) Run "Test parallel port" section
%
% (9) Run block or threshold assessment you want to re-run

%% Upload CSV file 3

% csvFile = 'respirationAdj1_blockorder.csv';

 % (LE, 17 Apr 2026): Contains IDs 01-50 (as in previous document), 
 % but 4 more IDs (that need to be excluded) & 6 more new IDs !  
 % --> necessarily go until (including) ID54 !
 % --> possibly go until (including) ID62 !
 % (LE, 07 May 2026): New document contains all IDs (up to the end of the
 % Stopping rule, that is N=75; pre-registered)
csvFile = 'respirationAdj1_blockorder_v3.csv';                     

csvLoad = UploadCSV(csvFile, p_data);


%% EXPERIMENT
%% [SKIP IF RE-RUN] Settings for experiment

%cd('E:\USER\Lioba\respirationAdj1-master\respirationAdj1-master\exp');

KbName('UnifyKeyNames'); %enables unified mode of keynames for operating systems
%setup script
s = setup;
% Since parallel port addresses change (check in device manager)
s.lpt_adr1 = hex2dec('D010'); 
%s.lpt_adr2 = hex2dec('0378'); 


%% [SKIP IF RE-RUN] Create sequence and save settings
[exp_seq,s] = seq(s, csvLoad, p_data);

%% 
save([p_data.dir s.file_prefix 'settings_seq.mat'],'p_data','exp_seq','s');
 
%% Resting state (first start the experiment with this, 6 minutes resting time in each condition m-n while looking at the cross symbol on the screen)
% Screen number write
 screenNumber = 0;
 respirationstate.address = s.lpt_adr1;

 restingstate_data = restingstate_loop(p_data, s.screenNumber,1, csvLoad, s);
 
 %% 2. [SKIP IF RE-RUN] Test stimulus ELECTRICAL
electric_test_stimuli(3, 5, aio_s,trig_s);
   
% Stops if intensity input is empty

% clear thr1F_test

%% ThA 1
block = 1;

thr1F = thr1F_setup_respirationAdj1(0:.02:5,csvLoad);
thr1F.lpt_adr1 = s.lpt_adr1;
thr1F.s_port=s.s_port;

% Initial ThA with more trials and coarser steps
thr1F.UD_startValue = 2.5;
thr1F.UD_stopRule = 40;   % 05.02.2026 - LIOBA NEW
thr1F.UD_meanNumber = 20;
thr1F.trials_psi = 50;   % 05.02.2026 - LIOBA NEW

thr1F_data1 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data1.near;
% thr1F_data1 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 


%% BLOCK 1
block = 1;

exp_data1 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data1.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data1 = intervals(s,exp_data1);

save_exp(p_data,exp_data1,s,['0' num2str(block)]);

log_detection(thr1F_data1,exp_data1);

%%
%% ThA 2
block = 2;

thr1F = thr1F_setup_respirationAdj1(0:.02:5,csvLoad);
thr1F.lpt_adr1 = s.lpt_adr1;
thr1F.s_port=s.s_port;

thr1F.UD_startValue = exp_data1.near(end,1);

thr1F_data2 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data2.near;
% thr1F_data2 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 


%% BLOCK 2
block = 2;

exp_data2 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data2.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data2 = intervals(s,exp_data2);

save_exp(p_data,exp_data2,s,['0' num2str(block)]);

log_detection(thr1F_data2,exp_data2);

%%
%% ThA 3
block = 3;

thr1F.UD_startValue = exp_data2.near(end,1);

thr1F_data3 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data3.near;
% thr1F_data3 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 


%% BLOCK 3
block = 3;

exp_data3 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data3.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data3 = intervals(s,exp_data3);

save_exp(p_data,exp_data3,s,['0' num2str(block)]);

log_detection(thr1F_data3,exp_data3);


%%
%% ThA 4
block = 4;

thr1F.UD_startValue = exp_data3.near(end,1);

thr1F_data4 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data4.near;
% thr1F_data4 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 


%% BLOCK 4
block = 4;

exp_data4 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data4.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data4 = intervals(s,exp_data4);

save_exp(p_data,exp_data4,s,['0' num2str(block)]);

log_detection(thr1F_data4,exp_data4);

%%
%% ThA 5
block = 5;

thr1F.UD_startValue = exp_data4.near(end,1);

thr1F_data5 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data5.near;
% thr1F_data5 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 


%% BLOCK 5
block = 5;

exp_data5 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data5.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data5 = intervals(s,exp_data5);

save_exp(p_data,exp_data5,s,['0' num2str(block)]);

log_detection(thr1F_data5,exp_data5);


%%
%% ThA 6
block = 6;

thr1F.UD_startValue = exp_data5.near(end,1);

thr1F_data6 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data6.near;
% thr1F_data6 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 


%% BLOCK 6
block = 6;

exp_data6 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data6.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data6 = intervals(s,exp_data6);

save_exp(p_data,exp_data6,s,['0' num2str(block)]);

log_detection(thr1F_data6,exp_data6);


%%
%% ThA 7
block = 7;

thr1F.UD_startValue = exp_data6.near(end,1);

thr1F_data7 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data7.near;
% thr1F_data7 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 


%% BLOCK 7
block = 7;

exp_data7 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data7.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data7 = intervals(s,exp_data7);

save_exp(p_data,exp_data7,s,['0' num2str(block)]);

log_detection(thr1F_data7,exp_data7);


%%
%% ThA 8
block = 8;

thr1F.UD_startValue = exp_data7.near(end,1);

thr1F_data8 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data8.near;
% thr1F_data8 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 


%% BLOCK 8
block = 8;

exp_data8 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data8.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data8 = intervals(s,exp_data8);

save_exp(p_data,exp_data8,s,['0' num2str(block)]);

log_detection(thr1F_data8,exp_data8);


%%
%% ThA 9
block = 9;

thr1F.UD_startValue = exp_data8.near(end,1);

thr1F_data9 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data9.near;
% thr1F_data9 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad); 


%% BLOCK 9
block = 9;

exp_data9 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data9.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data9 = intervals(s,exp_data9);

save_exp(p_data,exp_data9,s,['0' num2str(block)]);

log_detection(thr1F_data9,exp_data9);


%%
%% ThA 10
block = 10;

thr1F.UD_startValue = exp_data9.near(end,1);

thr1F_data10 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);

% If repetition necessary:
% (1) Use last threshold estimate as start value and (2) re-run:
% thr1F.UD_startValue = thr1F_data10.near;
% thr1F_data10 = thr1F_loop(thr1F,p_data,aio_s,trig_s, block,1,csvLoad);


%% BLOCK 10
block = 10;

exp_data10 = run_exp(s,aio_s,trig_s, p_data.ID,thr1F_data10.PF_params_PM,exp_seq(exp_seq(:,1)==block,:),csvLoad,block);

exp_data10 = intervals(s,exp_data10);

save_exp(p_data,exp_data10,s,[num2str(block)]);    % 05.02.2026 - LIOBA NEW

log_detection(thr1F_data10,exp_data10);

%% CLOSE

diary off
clear 