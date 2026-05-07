function restingstate_data = restingstate_loop(p_data,screenNumber,run, csvLoad, s)
% restingstate_loop(p_data,block_types,screenNumber,run)
% runs resting state presentation script and saves data
%
% p_data        personal data (ID)
% block_types   indicates order of nasal (N) vs. mouth (M)
% screenNumber  number of presentation screen (set in respirationNO.m
% run           number of runs of resting state measure
%
% Author: Lioba Enk
% Modified by   Busra Cilburunoglu
% Last update:  07 Oct, 2025

% %     ListenChar(-1);  
% 
    % Run experiment
    restingstate_data = restingstate_run(p_data, screenNumber,csvLoad, s);

    % Save data
    restingstate_save(restingstate_data, p_data, ['0' num2str(run)]);

    ListenChar(0);  
%     
end
