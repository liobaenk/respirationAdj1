function csvLoad = UploadCSV(csvFile, p_data)
% Information about the csv file, which contains pariticpant id, block
% positions, repsonse buttons for thr1F and main exp., resting state order
% as well.

% Authors: Busra Cilburunoglu and Lioba Enk
% Last update: Oct,10, 2025

    % CSV file find
    if nargin < 1 || isempty(csvFile)
        csvFile = dir(fullfile(pwd, '*.csv'));
        csvFile = fullfile(pwd, csvFile(1).name);
    end
    
    % Find matching id in table
    T = readtable(csvFile);

    % Find participant row
    row = T(T.ID == str2double(p_data.ID), :);
    if isempty(row)
        error('Participant ID %d not found in CSV!', str2double(p_data.ID));
    end

    % Data structure
    csvLoad.ID = row.ID;

    % Block position as array
    csvLoad.block_pos = string(table2array(row(:, startsWith(T.Properties.VariableNames, 'block_pos_'))));

    % Button response order
    csvLoad.button_response_order = row.button_response_order{1};

    % Restingstate order
    csvLoad.block_types = row.block_types{1};

    % thr1F button order
    csvLoad.thr1F_button = row.thr1F_response_button{1};
end