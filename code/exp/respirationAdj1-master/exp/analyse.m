%% Analyse
clearvars -except exp_data data; clc;

% --- 1. Data Check ---
if exist('exp_data', 'var')
    data_struct = exp_data;
elseif exist('data', 'var')
    data_struct = data;
else
    [file, path] = uigetfile('*.mat');
   
    loaded_data = load(fullfile(path, file));
    field_names = fieldnames(loaded_data);
    
    if isfield(loaded_data, 'exp_data')
        data_struct = loaded_data.exp_data; 
    else
        data_struct = loaded_data.(field_names{1});
    end
end




%2. Settings 
% 1=RhyF, 2=RhyS, 3=RanS
block_names_map = {1, 'RhyF'; 2, 'RhyS'; 3, 'RanS'}; 
block_nums = unique(data_struct.seq(:,1)); 

% ITI 
TOLERANCE_MS = 100; 
ITI_RANGES = struct();
ITI_RANGES.RhyF = [500, 1500]; 
ITI_RANGES.RhyS = [3000, 4000]; 
ITI_RANGES.RanS = [500, 6500]; 

FIXED_ITI_MS = 1000; % RanS içindeki sabit 1.0 saniye
RAN_MIN_MS = 500;    % RanS tasarlanmış minimum ITI değeri

% Graph setting
color_RhyF = [1 1 0.5]; color_RhyS = [0.5 1 0.5]; color_RanS = [0.5 1 1];
Y_LIMIT_MAX = 2.0; Y_TICK_STEP = 0.2; Y_TICKS_MANUAL = 0:Y_TICK_STEP:Y_LIMIT_MAX;
num_blocks = length(block_nums);

figure('Name', 'ITI Histogram Analysis', 'Color', 'w', 'Position', [100, 100, 1000, 1000]); 
fprintf('\n%-10s %-10s %-15s %-15s\n', 'Block', 'Type', 'Mean (ms)', 'SD (ms)');
fprintf('%s\n', repmat('-', 1, 60));

% --- 3. Analysis Loop ---
for i = 1:num_blocks
    b_num = block_nums(i);
    block_idx = data_struct.seq(:,1) == b_num;
    
    % *** 5. Sütundan Tip Kodunu Al ***
    first_trial_idx = find(block_idx, 1);
    if isempty(first_trial_idx)
         warning('Blok %d için veri bulunamadı, atlanıyor.', b_num);
         continue; 
    end
    type_code = data_struct.seq(first_trial_idx, 5); 
    
    % Block name
    map_idx = find(cell2mat(block_names_map(:,1)) == type_code, 1);
    
    if isempty(map_idx)
        b_name = sprintf('Unknown (Code %d)', type_code);
        box_color = [0.7 0.7 0.7];
    else
        b_name = block_names_map{map_idx, 2};
        
        if strcmp(b_name, 'RhyF'); box_color = color_RhyF;
        elseif strcmp(b_name, 'RhyS'); box_color = color_RhyS;
        else; box_color = color_RanS; % type_code=3 (RanS)
        end
    end
    
    if isfield(ITI_RANGES, b_name)
        current_design_range = ITI_RANGES.(b_name); 
    else
        current_design_range = [0, 10000]; 
    end
    
    % ExtrITI Durations
    if isfield(data_struct, 't_fix_cue')
        iti_values = data_struct.t_fix_cue(block_idx);
    else
        onset_cue = [data_struct.onset_cue{block_idx}];
        onset_fix = [data_struct.onset_fix{block_idx}];
        iti_values = (onset_cue - onset_fix)' * 1000;
    end
    
    %filter
    iti_min_bound = current_design_range(1) - TOLERANCE_MS;
    iti_max_bound = current_design_range(2) + TOLERANCE_MS;
    
   
    iti_values = iti_values(iti_values >= iti_min_bound & iti_values <= iti_max_bound);
    
    % RAN S 
    if strcmp(b_name, 'RanS') 
        % 2. Adım: Sabit 1000ms ITI'ları çıkar
        tolerance_fixed = 5; 
        iti_values = iti_values(abs(iti_values - FIXED_ITI_MS) > tolerance_fixed);
        % 3. Adım: Tasarlanmış Minimum (500ms) değerinin altındaki hatalı kayıtları çıkar
        iti_values = iti_values(iti_values >= RAN_MIN_MS - 5);
    end
  
    
    % Calculate Statistics and Plot 
    mean_val = mean(iti_values, 'omitnan');
    sd_val = std(iti_values, 'omitnan');
    
    fprintf('%-10d %-10s %-15s %-15s\n', b_num, b_name, num2str(mean_val, '%.4f'), num2str(sd_val, '%.4f'));
    
    % Plot Graph
    cols = 4; rows = ceil(num_blocks / cols);
    h_subplot = subplot(rows, cols, i);
    
    if strcmp(b_name, 'RhyF')
        bin_width = 50; bin_edges = current_design_range(1):bin_width:current_design_range(2); 
        xlim_range = [current_design_range(1)-100, current_design_range(2)+100];
        xticks_manual = current_design_range(1):200:current_design_range(2);
        xtick_labels_manual = arrayfun(@(x) num2str(x/1000, '%.1f'), xticks_manual, 'UniformOutput', false);
    else 
        bin_width = 100;
        if strcmp(b_name, 'RhyS') 
             xticks_manual = 3000:250:4000;
             xlim_range = [2800, 4200];
             bin_edges = current_design_range(1):bin_width:current_design_range(2);
        else % RanS ve Unknown (Geniş aralık ayarları)
             xticks_manual = 1000:1000:6000; 
             xlim_range = [0, 7000];
             min_val = floor(min(iti_values, [], 'omitnan') / bin_width) * bin_width;
             max_val = ceil(max(iti_values, [], 'omitnan') / bin_width) * bin_width;
             if isempty(min_val) || isnan(min_val); bin_edges = 'auto';
             else; bin_edges = min_val:bin_width:max_val; 
             end
        end
        xtick_labels_manual = arrayfun(@(x) num2str(x/1000), xticks_manual, 'UniformOutput', false);
    end
    
    histogram(iti_values, bin_edges, 'FaceColor', [0.30 0.50 0.85], 'EdgeColor', 'k'); 
    pbaspect([1 1 1]); xlim(xlim_range); grid on;
    
    set(gca, 'XTick', xticks_manual, 'XTickLabel', xtick_labels_manual);
    set(gca, 'Box', 'on', 'LineWidth', 1.5, 'FontName', 'Helvetica', 'FontSize', 10, 'YTick', Y_TICKS_MANUAL, 'YLim', [0, Y_LIMIT_MAX]);
    
    title(sprintf('Block %d (%s)', b_num, b_name), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('ITI (s)', 'FontSize', 10); ylabel('Frequency', 'FontSize', 10);
    
    stat_str = sprintf('Mean (SD) =\n%.3f (%.3f)', mean_val, sd_val);
    xl = xlim; text_y_pos = Y_LIMIT_MAX * 0.6; 
    text_handle = text(mean(xl), text_y_pos, stat_str, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'BackgroundColor', box_color, ... 
        'FontSize', 9, 'FontWeight', 'bold', 'Margin', 8, 'EdgeColor', 'k', 'LineWidth', 1.5);
end
sgtitle('ITI Duration Histogram Analysis (All Blocks)', 'FontSize', 16, 'FontWeight', 'bold');
fprintf('\nBlockType, mean and sd of the study\n');