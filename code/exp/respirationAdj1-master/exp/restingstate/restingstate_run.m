function data = restingstate_run(p_data, screenNumber, csvLoad, s)
% % Input:
% % ID                ID numel
% %
% % screenNumber      number of presentation screen
% % csvLoad           Csv file uploading for the condition of mouth or nose
% %
% % Author:           Lioba Enk
% % Last update:      14 July, 2022
% 
% % Modified by Busra Cilburunoglu
% % Last update: 07 Oct, 2025

try
    %%Parameters
    restingstate.fix_t = 360;  % 6 minute
    restingstate.break_t = 120; % 2 minute
    restingstate.window_color = [200 200 200];
    restingstate.text_color = [40 40 40];
    restingstate.text_font = 'Arial';
    restingstate.text_size = 105;
    restingstate.fix_size = 125;
    restingstate.fix_symbol = '+';

    % Restingstate
    restingstate.instr_dir = '/instr_restingstate/';
    restingstate.instr_subdir_wildcard = 'condition_*';
    restingstate.instr_subdir_nose_wildcard = 'nose';
    restingstate.instr_subdir_mouth_wildcard = 'mouth';
    restingstate.instr_img_wildcard = 'instr_rs*.png';
    % Paralel port 
    restingstate.ioObj = io64;
    restingstate.address = hex2dec('D010');

    %% Block order
    order_str = char(csvLoad.block_types);  % 'NM' or'MN'
    block_order = regexp(order_str, '.', 'match');  % {'N','M'} 
    data.block_order = block_order;

    %% Screen
    window = Screen('OpenWindow', screenNumber, restingstate.window_color);
    HideCursor;
    Screen('TextFont', window, restingstate.text_font);
    Screen('TextSize', window, restingstate.fix_size);
    flip_t = Screen('GetFlipInterval', window);
    data.flip_t = flip_t;

    %% Data save all
    n_blocks = length(block_order);
    data.onset_fix = cell(n_blocks, 1);
    data.offset_fix = zeros(n_blocks, 1);
    data.t_fix = zeros(n_blocks, 1);
    
    data.fix_t = restingstate.fix_t;
    % break save
    data.break_start = zeros(n_blocks, 1);
    data.break_end = zeros(n_blocks, 1);
    data.break_start(1) = NaN;
    data.break_end(1) = NaN;
    
    data.break_t = restingstate.break_t;
    %% Start intro 
        instr_dir = [fileparts(mfilename('fullpath')) restingstate.instr_dir];
        start_image =  load_images(instr_dir,  'instr_rs.01.png');
        [data.instr1_btn, data.instr1_screen_onset] = show_instr_img(start_image, window, s);
    %% Block run
    for i = 1:n_blocks
        block_type = block_order{i};  % 'N'or'M'

        %% Instructions
        instr_dir = [fileparts(mfilename('fullpath')) restingstate.instr_dir];
 
        if strcmp(block_type, 'N')
            instr_images_nose = load_images([instr_dir 'condition_14\' restingstate.instr_subdir_nose_wildcard '\'], restingstate.instr_img_wildcard);
        elseif strcmp(block_type, 'M')
            instr_images_mouth = load_images([instr_dir 'condition_23\' restingstate.instr_subdir_mouth_wildcard '\'], restingstate.instr_img_wildcard);
        else
            fprintf('Instruction images error')
        end

     if strcmp(block_type,'N')
            [data.instr1_btn, data.instr1_screen_onset] = show_instr_img(instr_images_nose, window, s);
            clear instr_images_nose img_texture
     elseif strcmp(block_type,'M')
            [data.instr1_btn, data.instr1_screen_onset] = show_instr_img(instr_images_mouth, window, s);
            clear instr_images_mouth img_texture
     end
     
        % Fixation
        DrawFormattedText(window, restingstate.fix_symbol, 'center', 'center', restingstate.text_color);
        [data.onset_fix{i}] = Screen('Flip', window);
        send_pportTrigger(restingstate.ioObj, restingstate.address, 150);
        
        data.offset_fix(i) = WaitSecs('UntilTime', data.onset_fix{i} + restingstate.fix_t);
        send_pportTrigger(restingstate.ioObj, restingstate.address, 150);

        % Break
        if i < n_blocks
            
            data.break_start(i+1) = data.offset_fix(i);  % previous block fnish
            data.break_end(i+1) = data.break_start(i+1) + restingstate.break_t;  % break finish
            
            
            break_img = imread(fullfile(instr_dir, 'instr_rs.break.png'));
            Screen('PutImage', window, break_img);
            Screen('Flip', window);
            
            send_pportTrigger(restingstate.ioObj, restingstate.address, 180); % break start

            WaitSecs(restingstate.break_t);
            
            send_pportTrigger(restingstate.ioObj, restingstate.address, 180); % break end
        end
    end

    %%Time
    for i = 1:n_blocks
        data.t_fix(i) = (data.offset_fix(i) - data.onset_fix{i}); 
       
    end
   
    %% Clear
    WaitSecs(0.5);
    Screen('Close', window);
    ShowCursor;
    sca;

catch err
    Screen('CloseAll');
    ShowCursor;
    sca;
    rethrow(err);
end
end


 
