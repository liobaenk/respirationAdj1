function restingstate_save(restingstate, p_data,file_name_end)
% respirationstate_save(p_data,respirationstate_data,file_name_end) saves data of resting state
% measure (nasal/oral) of online blood pressure, pulse ox etc. (respirationstate_data)
% under file_name (p_data) + file_name_end
%
% Output: txt + matlab file
%
% Author:           Lioba Enk
% Last update:      13 July, 2022

% Modified by Busra Cilburunoglu
% Last update: 07 Oct, 2025

% Setup data logging
file_name = ['restingstate_' p_data.ID];

% Create participant data directory
if ~exist(p_data.dir,'dir')
    mkdir('.',p_data.dir);
end

% Save Matlab variables
mat_file_tmp = [p_data.dir file_name '_data_' file_name_end '.mat'];

if exist(mat_file_tmp, 'file')
    disp('MAT-file of experiment exists. Generated random file name to prevent overwritting.')
    save([p_data.dir file_name '_data_' file_name_end '_' num2str(round(sum(100*clock))) '.mat'],'p_data','restingstate');
else
    save([p_data.dir file_name '_data_' file_name_end '.mat'],'p_data','restingstate');
end


%% Save trial data

% Make thr1F_data easily accessbile
d = restingstate;

% Get current date
date_str = datestr(now,'yyyy/mm/dd');

% Open file
data_file = fopen([p_data.dir file_name '_data_' file_name_end '.txt'],'a');

% Write header
%fprintf(data_file,'ID\tage\tgender\tcapsize\tsurveyid\tdate\tcondition\tsetting_fix_t\tt_onset_fix\tt_offset_fix\tt_fix\n');
fprintf(data_file,'ID\tage\tgender\tcapsize\tsurveyid\tdate\tcondition\tsetting_fix_t\tt_onset_fix\tt_offset_fix\tt_fix\tbreak_start\tbreak_end\tbreak_duration\n');

for i = 1:length(d.block_order)
   % fprintf(data_file,'%s\t%s\t%s\t%s\t%s\t%.0f\t%.6f\t%.4f\t%.4f\n', ...
      %  p_data.ID, p_data.age, p_data.gender,  p_data.capsize, p_data.surveyid, date_str, char(d.block_order(i)), d.t_fix(i), d.onset_fix{i,1}, d.offset_fix(i,1), d.t_fix(i,1));
      fprintf(data_file,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.0f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.0f\n', ...
   p_data.ID,p_data.age_years,p_data.gender_fmd,p_data.capsize_cm, p_data.surveyid_soscisurvey, date_str, char(d.block_order(i)), d.fix_t, d.onset_fix{i}, d.offset_fix(i), d.t_fix(i),  d.break_start(i), d.break_end(i), d.break_t);

end
%%%%%%       '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.0f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.0f\n'
%%%%%%       bu yenisi 
%%%%%%       bu eski %s\t%s\t%s\t%s\t%s\t%s\t%s\t%.0f\t%.4f\t%.4f\t%.4f\n',

fclose(data_file);