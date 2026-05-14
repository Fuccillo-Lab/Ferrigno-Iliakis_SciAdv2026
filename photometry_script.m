
%photometry_folder = "C:\Users\sarfe\Box\grp-psom-fuccillo-lab\Treadmill\Bonsai_Stuff\Photometry";
%behavior_folder = "C:\Users\sarfe\Desktop\Data_Analysis\Nov2024_Analysis\Analyzed";
%behavior_folder = "C:\Users\sarfe\Desktop\Data_Analysis\Jan2025_Analysis";

%photometry_folder = "C:\Users\sarfe\Desktop\Data_Analysis\Nov2024_Analysis\Photometry";
%photometry_folder = "C:\Users\sarfe\Desktop\Data_Analysis\Jan2025_Analysis\Photometry";
photometry_folder = "C:\Users\sarfe\Box\Documents\Go_NoGo\March2025\Fig3_Fig4_Photometry\All_Photometry";

% Open the data
filepath = convertStringsToChars(photometry_folder);
cd(filepath);
files = dir('Photometry*.csv');

% Set minimum file size in bytes to only look at full sessions
    minSize = 1e7; 

    % Filter files larger than minSize
    largeFiles = files([files.bytes] > minSize);

clear('num_files');

    if exist('photometryStruct')
        num_files(1, 1) = size(photometryStruct, 2);
    else
        num_files(1, 1) = 0;
    end

num_files(1, 2) = size(largeFiles, 1);
h = waitbar(0,'Analysis in progress...');

clear('file_start_time');

for i = 1:num_files(1, 2)
    file_start_time{i, 1} = extractAfter(largeFiles(i).name, "Photometry");
    file_start_time{i, 1} = extractAfter(file_start_time{i, 1}, "_");
    file_start_time{i, 1} = extractBefore(file_start_time{i, 1}, ".csv");
    file_start_time{i, 2} = extractBefore(file_start_time{i, 1}, "T");
    file_start_time{i, 3} = extractAfter(file_start_time{i, 1}, "T");
   
    TTL_file = dir(strcat('TTL*',file_start_time{i, 2},"T",file_start_time{i, 3}(1:end-1), '*'));
    
    if isempty(TTL_file)
    TTL_file = dir(strcat('TTL*',file_start_time{i, 2},"T",file_start_time{i, 3}(1:end-2), '*'));
    end

    if isempty(TTL_file)
        original_time = file_start_time{i, 3}(1:end-3);  % '14_07'
        split_str = split(original_time, '_');          % {'14'; '07'}
        
        % Convert the second part to a number, add 1, and format it back to string
        new_minute = sprintf('%02d', str2double(split_str{2}) + 1);  % '08'
        
        % Concatenate back
        new_time = [split_str{1} '_' new_minute];  % '14_08'

        TTL_file = dir(strcat('TTL*',file_start_time{i, 2},"T",new_time, '*'));
    end

    % Prep photometry data
    try
     photometryStruct_photodata= photometry_data_prep(largeFiles(i).name, file_start_time{i, 2}, file_start_time{i, 3});
    catch e
        skipping{i, 1} = largeFiles(i).name;
        skipping{i, 2} = 1;
        skipping{i, 3} = e.message;
     end
   
        % Load Photometry_Info.xlsx
        infoTable = readtable('C:\Users\sarfe\Box\Documents\Go_NoGo\March2025\Fig3_Fig4_Photometry\All_Photometry\Photometry_Info.xlsx', ...
                              'Sheet', 'Photometry Log', 'VariableNamesRange', 'A1');
        
        % Convert time from Excel's fractional day format to hh_mm_ss
        infoTable.Time = datetime(infoTable.Time, 'ConvertFrom', 'excel', 'Format', 'HH_mm_ss');
        
        % Convert session date and time correctly
        sessionDate = file_start_time{i, 2}; % Extract date
        sessionTime = datetime(file_start_time{i, 3}, 'InputFormat', 'HH_mm_ss'); % Convert to datetime
        
        % Remove the date part from both times
        matchingTimes = timeofday(infoTable.Time); % Extract only the time component
        sessionTime = timeofday(sessionTime); % Extract only the time component
        
        % Find rows that match the session date
        matchingDatesIdx = find(infoTable.Date == sessionDate);
        
        if isempty(matchingDatesIdx)
            warning("No matching session date found in Photometry_Info.xlsx. Skipping session.");
            continue;
        end
        
        % Extract corresponding times (already in datetime format)
        matchingTimes = matchingTimes(matchingDatesIdx); % Keep only times that match the session date
        
        % Compute absolute time differences (now correctly comparing only times)
        timeDiffs = abs(matchingTimes - sessionTime); 
        
        % Find the index of the smallest time difference within a 2-minute threshold
        [smallestDiff, bestMatchIdx] = min(timeDiffs);
        
        if seconds(smallestDiff) > 120  % Set threshold of ±2 minutes (120 sec)
            warning("No matching session time found within 2 minutes. Skipping session.");
            continue;
        end
        
        % Get the final matching row index
        rowIdx = matchingDatesIdx(bestMatchIdx);
        
        
        % Define a function to standardize mouse IDs correctly
        formatMouseID = @(mouseID) lower(replace(replace(replace(replace(mouseID, "Cre", "c"), " Cre", "c"), " ", ""), ".", ""));
        
        % Extract and format Mouse ID for Box 1
        mouse1 = string(infoTable.Mouse{rowIdx}); % Convert to string to avoid cell issues
        
        if ismissing(mouse1) || strcmpi(mouse1, 'N/A') % Check for missing or 'N/A'
            photometryStruct_photodata.animalID_1 = 'n/a'; % Keep as 'n/a' if missing
        else
            photometryStruct_photodata.animalID_1 = formatMouseID(mouse1);
        end
        
        % Extract and format Mouse ID for Box 4
        mouse2 = string(infoTable.Mouse{rowIdx + 1}); % Convert to string
        
        if ismissing(mouse2) || strcmpi(mouse2, 'N/A') % Check for missing or 'N/A'
            photometryStruct_photodata.animalID_2 = 'n/a';
        else
            photometryStruct_photodata.animalID_2 = formatMouseID(mouse2);
        end
        
        
        if infoTable.LeftSide(rowIdx) >= 1
            if infoTable.LeftSide(rowIdx) == 1
                photometryStruct_photodata.Fiber1_ID = strcat(photometryStruct_photodata.animalID_1, '_left');
            elseif infoTable.LeftSide(rowIdx) == 2
                photometryStruct_photodata.Fiber2_ID = strcat(photometryStruct_photodata.animalID_1, '_left');
            elseif infoTable.LeftSide(rowIdx) == 3
                photometryStruct_photodata.Fiber3_ID = strcat(photometryStruct_photodata.animalID_2, '_left');
            elseif infoTable.LeftSide(rowIdx) == 4
                photometryStruct_photodata.Fiber4_ID = strcat(photometryStruct_photodata.animalID_2, '_left');
            end         
        end
        
        if infoTable.RightSide(rowIdx) >= 1
            if infoTable.RightSide(rowIdx) == 1
                photometryStruct_photodata.Fiber1_ID = strcat(photometryStruct_photodata.animalID_1, '_right');
            elseif infoTable.RightSide(rowIdx) == 2
                photometryStruct_photodata.Fiber2_ID = strcat(photometryStruct_photodata.animalID_1, '_right');
            elseif infoTable.RightSide(rowIdx) == 3
                photometryStruct_photodata.Fiber3_ID = strcat(photometryStruct_photodata.animalID_2, '_right');
            elseif infoTable.RightSide(rowIdx) == 4
                photometryStruct_photodata.Fiber4_ID = strcat(photometryStruct_photodata.animalID_2, '_right');
            end   
        end
        
        if infoTable.LeftSide(rowIdx + 1) >= 1
            if infoTable.LeftSide(rowIdx + 1) == 1
                photometryStruct_photodata.Fiber1_ID = strcat(photometryStruct_photodata.animalID_1, '_left');
            elseif infoTable.LeftSide(rowIdx + 1) == 2
                photometryStruct_photodata.Fiber2_ID = strcat(photometryStruct_photodata.animalID_1, '_left');
            elseif infoTable.LeftSide(rowIdx + 1) == 3
                photometryStruct_photodata.Fiber3_ID = strcat(photometryStruct_photodata.animalID_2, '_left');
            elseif infoTable.LeftSide(rowIdx + 1) == 4
                photometryStruct_photodata.Fiber4_ID = strcat(photometryStruct_photodata.animalID_2, '_left');
            end   
        end
        
        if infoTable.RightSide(rowIdx + 1) >= 1
            if infoTable.RightSide(rowIdx + 1) == 1
                photometryStruct_photodata.Fiber1_ID = strcat(photometryStruct_photodata.animalID_1, '_right');
            elseif infoTable.RightSide(rowIdx + 1) == 2
                photometryStruct_photodata.Fiber2_ID = strcat(photometryStruct_photodata.animalID_1, '_right');
            elseif infoTable.RightSide(rowIdx + 1) == 3
                photometryStruct_photodata.Fiber3_ID = strcat(photometryStruct_photodata.animalID_2, '_right');
            elseif infoTable.RightSide(rowIdx + 1) == 4
                photometryStruct_photodata.Fiber4_ID = strcat(photometryStruct_photodata.animalID_2, '_right');
            end   
        end

    % Import behavior data and get TTLs
        
        behavior_file_name = dir(strcat('CoolTerm*',file_start_time{i, 2}, '*',photometryStruct_photodata.animalID_1, '*'));
        
        if ~isempty(behavior_file_name)

            try
            behavior_fileID = fopen(behavior_file_name.name);
            behavior_data = textscan(behavior_fileID, '%f %f %f %f %f', 'Delimiter', ',');
            behavior_data = cell2mat(behavior_data);
            
                if behavior_data(1, 3) ~= 0 % if a non-photometry behavioral file is detected abort analysis
                    photometryStruct_photodata.behavior_data_animal1 = behavior_data;
                    photometryStruct_photodata.phase_animal1 = behavior_data(1, end);
                    photometryStruct_photodata.box1_behavior_ttls = photometryStruct_photodata.behavior_data_animal1(find(photometryStruct_photodata.behavior_data_animal1(:, 2) == 9), 1);
                else
                    photometryStruct_photodata.animalID_1 = [];
                    photometryStruct_photodata.Fiber1_ID = [];
                    photometryStruct_photodata.Fiber2_ID = [];
                end

                clear behavior_data behavior_fileID behavior_file_name
            catch e
                skipping{i, 1} = largeFiles(i).name;
                skipping{i, 2} = 2;
                skipping{i, 3} = e.message;
            end
        end

        if ~isempty(photometryStruct_photodata.animalID_1) & photometryStruct_photodata.animalID_1 ~= "n/a"
            % Add photometry TTLs (box 1)
            try
             photometryStruct_TTLs_box1 = fix_photometry_TTLs(photometryStruct_photodata.box1_behavior_ttls, TTL_file.name, 1);
            catch e
                skipping{i, 1} = largeFiles(i).name;
                skipping{i, 2} = 4;
                skipping{i, 3} = e.message;
            end

            % Update behavior clock to match photometry clock
            try
            box1_clock_sync_metrics = photometry_clock_sync(photometryStruct_photodata.box1_behavior_ttls, photometryStruct_TTLs_box1.final_photoTTLs_box1, photometryStruct_photodata.behavior_data_animal1, 1, photometryStruct_TTLs_box1.pervasive_photoTTL_errors_box1, photometryStruct_TTLs_box1.short_TTLs_box1);       
            end
        end
        
        
        
        behavior_file_name = dir(strcat('CoolTerm*',file_start_time{i, 2}, '*',photometryStruct_photodata.animalID_2, '*'));
        if ~isempty(behavior_file_name)
            try
            behavior_fileID = fopen(behavior_file_name.name);
            behavior_data = textscan(behavior_fileID, '%f %f %f %f %f', 'Delimiter', ',');
            behavior_data = cell2mat(behavior_data);

                if behavior_data(1, 3) ~= 0
                    photometryStruct_photodata.behavior_data_animal2 = behavior_data;
                    photometryStruct_photodata.phase_animal2 = behavior_data(1, end);
                    photometryStruct_photodata.box4_behavior_ttls = photometryStruct_photodata.behavior_data_animal2(find(photometryStruct_photodata.behavior_data_animal2(:, 2) == 9), 1);
                else
                    photometryStruct_photodata.animalID_2 = [];
                    photometryStruct_photodata.Fiber3_ID = [];
                    photometryStruct_photodata.Fiber4_ID = [];
                end

            catch e
                skipping{i, 1} = largeFiles(i).name;
                skipping{i, 2} = 3;
                skipping{i, 3} = e.message;
            end
        end

        if ~isempty(photometryStruct_photodata.animalID_2) & photometryStruct_photodata.animalID_2 ~= "n/a"
            % Add photometry TTLs (box 4)
            try
             photometryStruct_TTLs_box4 = fix_photometry_TTLs(photometryStruct_photodata.box4_behavior_ttls, TTL_file.name, 4);
            catch e
                skipping{i, 1} = largeFiles(i).name;
                skipping{i, 2} = 5;
                skipping{i, 3} = e.message;
            end

            try
            box4_clock_sync_metrics = photometry_clock_sync(photometryStruct_photodata.box4_behavior_ttls, photometryStruct_TTLs_box4.final_photoTTLs_box4, photometryStruct_photodata.behavior_data_animal2, 4, photometryStruct_TTLs_box4.pervasive_photoTTL_errors_box4, photometryStruct_TTLs_box4.short_TTLs_box4);     
            end

        end

% Combine Structures
try   
    if exist("photometryStruct_TTLs_box1") & exist("photometryStruct_TTLs_box4")
    table1 = struct2table(photometryStruct_photodata, 'AsArray', true); % Convert struct1 to a table
    table2 = struct2table(photometryStruct_TTLs_box1, 'AsArray', true); % Convert struct2 to a table
    table3 = struct2table(photometryStruct_TTLs_box4, 'AsArray', true); % Convert struct2 to a table
    table4 = struct2table(box1_clock_sync_metrics, 'AsArray', true); % Convert struct2 to a table
    table5 = struct2table(box4_clock_sync_metrics, 'AsArray', true); % Convert struct2 to a table
    mergedTable = [table1, table2, table3, table4, table5];
    
    elseif exist("photometryStruct_TTLs_box1") & ~exist("photometryStruct_TTLs_box4")
        photometryStruct_TTLs_box4.original_TTLs_box4 = [];
        photometryStruct_TTLs_box4.final_photoTTLs_box4 = [];
        photometryStruct_TTLs_box4.pervasive_photoTTL_errors_box4 = [];
        photometryStruct_TTLs_box4.initial_photoTTL_errors_box4 = [];
        photometryStruct_TTLs_box4.short_TTLs_box4 = [];
    
        box4_clock_sync_metrics.behavioral_data_animal2_photoclock = [];
        box4_clock_sync_metrics.behavioral_ttls_animal2_photoclock = [];
        box4_clock_sync_metrics.fit_coefficents_box4 = [];
        box4_clock_sync_metrics.mean_fitted_ttl_difference_box4 = [];
        box4_clock_sync_metrics.std_fitted_ttl_difference_box4 = [];
        box4_clock_sync_metrics.max_fitted_ttl_difference_box4 = [];
    
        box4_clock_sync_metrics.behavior_data_animal2 = [];
        box4_clock_sync_metrics.box4_behavior_ttls = [];
    
    table1 = struct2table(photometryStruct_photodata, 'AsArray', true); % Convert struct1 to a table
    table2 = struct2table(photometryStruct_TTLs_box1, 'AsArray', true); % Convert struct2 to a table
    table3 = struct2table(photometryStruct_TTLs_box4, 'AsArray', true); % Convert struct2 to a table
    table4 = struct2table(box1_clock_sync_metrics, 'AsArray', true); % Convert struct2 to a table
    table5 = struct2table(box4_clock_sync_metrics, 'AsArray', true); % Convert struct2 to a table
    mergedTable = [table1, table2, table3, table4, table5];
    
    elseif exist("photometryStruct_TTLs_box4") & ~exist("photometryStruct_TTLs_box1")
        photometryStruct_TTLs_box1.original_TTLs_box1 = [];
        photometryStruct_TTLs_box1.final_photoTTLs_box1 = [];
        photometryStruct_TTLs_box1.pervasive_photoTTL_errors_box1 = [];
        photometryStruct_TTLs_box1.initial_photoTTL_errors_box1 = [];
        photometryStruct_TTLs_box1.short_TTLs_box1 = [];
    
        box1_clock_sync_metrics.behavioral_data_animal1_photoclock = [];
        box1_clock_sync_metrics.behavioral_ttls_animal1_photoclock = [];
        box1_clock_sync_metrics.fit_coefficents_box1 = [];
        box1_clock_sync_metrics.mean_fitted_ttl_difference_box1 = [];
        box1_clock_sync_metrics.std_fitted_ttl_difference_box1 = [];
        box1_clock_sync_metrics.max_fitted_ttl_difference_box1 = [];
    
        box1_clock_sync_metrics.behavior_data_animal1 = [];
        box1_clock_sync_metrics.box1_behavior_ttls = [];
    
    table1 = struct2table(photometryStruct_photodata, 'AsArray', true); % Convert struct1 to a table
    table2 = struct2table(photometryStruct_TTLs_box1, 'AsArray', true); % Convert struct2 to a table
    table3 = struct2table(photometryStruct_TTLs_box4, 'AsArray', true); % Convert struct2 to a table
    table4 = struct2table(box1_clock_sync_metrics, 'AsArray', true); % Convert struct2 to a table
    table5 = struct2table(box4_clock_sync_metrics, 'AsArray', true); % Convert struct2 to a table
    mergedTable = [table1, table2, table3, table4, table5];
    end
catch e
    skipping{i, 1} = largeFiles(i).name;
    skipping{i, 2} = 6;
    skipping{i, 3} = e.message;
end

if exist("mergedTable")
photometryStruct(i + num_files(1, 1)) = table2struct(mergedTable); % Convert back to struct
end



clear table1 table2 table3 table4 table5 mergedTable photometryStruct_photodata photometryStruct_TTLs_box1 photometryStruct_TTLs_box4 box1_clock_sync_metrics box4_clock_sync_metrics

    waitbar(i / num_files(1, 2))
end
close(h);

% Save workspace
    save_name = inputdlg("What should the workspace be saved as?");
    save(convertCharsToStrings(save_name));