function [seq,s] = seq(s, csvLoad, p_data)

% [seq,nt] = seq(s) returns a sequence matrix (seq) that is shuffled 
% per block as well as the random number generator state that was set.
%
%   seq: block x stimulus type x stimulus step x stimulus delay
%
% The number of stimulus delays is equal the number of trials per block,
% defined as sum(nt.stim_types_num) and lineraly spaced between the minimum
% and maximim of the defined stimulus delay interval (s.stim_delay).
%
% Relevant settings in nt_setup (doc setup):
%   s.rng_state
%   s.blocks
%   s.stim_types
%   s.stim_types_num
%   s.stim_steps
%   s.stim_delay
%   s.fix_t
%
% Author:           Martin Grund
% Last update:      December 18, 2018

% Modified by Busra Cilburunoglu and Lioba Enk
% Last update: Oct,10, 2025
%%

% Set random number generator state
s.rng_state = set_rng_state(s);

s.blocks = sum([s.RhyF.num_blocks, s.RhyS.num_blocks, s.RanS.num_blocks]);

seq = [];
              
    
seq_type_tmp = [];
seq_step_tmp = [];

    %% Trial array
for i=1:s.blocks

    blockList(i) = csvLoad.block_pos(i);  
    cond = s.(blockList(i)); 
    
    % Start and Main trial Numbers
    totalTrials = sum(cond.start_trials_stim_types_num) + sum(cond.stim_types_num);
    startTrialNum(i) = sum(cond.start_trials_stim_types_num); 
    trialNum(i) = sum(cond.stim_types_num); 
    
    
    trialNum(i) = cond.trials_per_block;
    itiNum(i, :) = cond.fix_t;
    StimNum(i, :) = cond.stim_types_num;
    NumBlock(i) = cond.num_blocks;

    % Pre-Trial Condition Sequence Settings
    startTrialNum(i) = cond.start_trials_per_block;
    startStimNum(i,:)  = cond.start_trials_stim_types_num;
    startFixT   = cond.start_trials_fix_t;
    
    % BlockList names

    if strcmp(blockList{1,i},'RhyF')
        blockListNum(i) = 1;
    elseif strcmp(blockList{1,i},'RhyS')
        blockListNum(i) = 2;
    elseif strcmp(blockList{1,i},'RanS')
        blockListNum(i) = 3;
     end

    % Reset of stim type every block
    seq_type_tmp = []; 
    
    %  Start trial Loop stimulus types
   for j = 1:numel(s.stim_types)
        seq_type_tmp = [seq_type_tmp; ones(cond.start_trials_stim_types_num(j),1)*s.stim_types(j)];
   end
   
    % Main trial Loop stimulus types
   for j = 1:numel(s.stim_types)
        seq_type_tmp = [seq_type_tmp; ones(cond.stim_types_num(j),1)*s.stim_types(j)];
   end

     % Shuffle stimulus types
    start_indices = 1:sum(cond.start_trials_stim_types_num);
    main_indices = (start_indices(end)+1) : totalTrials;
    
    % Shuffle stimulus types in main and start trials
    seq_ind = [Shuffle(start_indices) Shuffle(main_indices)];
    
    % Shuffle stimlus delays (rounded on ms)
    seq_stim_delay = Shuffle(round_dec(linspace(s.stim_delay(1), s.stim_delay(2), totalTrials),4))';

    % Shuffle fix_t (rounded on ms)
    seq_fix_t_start = repelem(startFixT, startTrialNum(i))';
    seq_fix_t_main = Shuffle(round_dec(linspace(cond.fix_t(1), cond.fix_t(2), trialNum(i)),4))';
    seq_fix_t = [seq_fix_t_start; seq_fix_t_main];


    % Blok code
    trialArray = [repelem(blockListNum(i), startTrialNum(i))' ; repelem(blockListNum(i), trialNum(i))'];

    % Sequence matrix: block_index - type - stim_delay - fix_t - block_code
    seq = [seq; i*ones(totalTrials,1) seq_type_tmp(seq_ind) seq_stim_delay seq_fix_t trialArray];
end
