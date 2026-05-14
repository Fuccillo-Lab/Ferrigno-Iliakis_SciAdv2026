function [output] = musc_analysis_funct(filename, num, phase, day, date, cutoff_setting); %filename is the "c:\path", '9-7-21' and 'number'
% Performance analysis for go no-go task April 2024

% Start up

    % Open and read .txt file 
        fileID = fopen(filename);
        out = textscan(fileID, '%f %f %f %f %f', 'Delimiter', ',');
        file_struct = 5; % if changing number of commas in file, change this number too!

        opto_sesh = false;


     try
        out = cell2mat(out);
        data = out; 

     catch
        PhaseError = [strcat('OPENING ERROR! Check:', {' '}, num, {' '}, 'on', {' '}, phase, {' '}, day)];
        disp(PhaseError)
     end

        nan_error = find(isnan(out(:, file_struct)) == 1);
        time_error = find(out(:, 1) > 4294967295);
        friggen_errors = [nan_error; time_error];
        friggen_errors = sort(friggen_errors);
        


%friggen_errors = double.empty;

        if ~isempty(friggen_errors) % Fix errors in file   

                wait_start = data(:, 2) == 8;
                wait_start_index = find(wait_start == 1);
                wait_start_index = setdiff(wait_start_index, friggen_errors); %fix for if the error puts an 8 in the event column

            for i = 1:(size(friggen_errors, 1))

                friggen_errors_stops{i, 1} = find(wait_start_index < friggen_errors(i, 1));
                friggen_errors_fix(i, 1) = wait_start_index(friggen_errors_stops{i, 1}(end, 1), 1);
                
                    if friggen_errors_stops{i, 1}(end, 1) < length(wait_start_index)
                        friggen_errors_fix(i, 2) = wait_start_index(friggen_errors_stops{i, 1}(end, 1) + 1, 1); 
                    else
                        friggen_errors_fix(i, 2) = length(data);
                    end
                                            
            end
 
                friggen_errors_fix_unique(:, 1) = unique(friggen_errors_fix(:, 1));
                friggen_errors_fix_unique(:, 2) = unique(friggen_errors_fix(:, 2));
                
      
            for i = 1:(size(friggen_errors_fix_unique, 1))

                data = [data(1:(friggen_errors_fix_unique(i, 1) - 1), :); data(friggen_errors_fix_unique(i, 2):end, :)];
                %data(friggen_errors_fix(i, 1), 4) = 99;
                friggen_errors_fix_unique(i, 3) = (friggen_errors_fix_unique(i, 2) - friggen_errors_fix_unique(i, 1));

                if i < size(friggen_errors_fix_unique, 1)
                    friggen_errors_fix_unique(i + 1, 1) = (friggen_errors_fix_unique(i + 1, 1) - sum(friggen_errors_fix_unique(:, 3)));
                    friggen_errors_fix_unique(i + 1, 2) = (friggen_errors_fix_unique(i + 1, 2) - sum(friggen_errors_fix_unique(:, 3)));
                end
           
            end  
            
            clear wait_start wait_start_index;

        end

    pre_output.animalID = num;
    output.animalID = num;    
%         if ismember(pre_output.animalID, DMS)
%            pre_output.circuit = 'DMS';
%         else
%            pre_output.circuit = 'DLS';
%         end


    pre_output.phase = str2num(phase); 
    pre_output.phase_check = max(out(1, end - 1), out(1, end));
    pre_output.day = day;
    pre_output.date = date;

    output.phase = str2num(phase); 
    output.phase_check = max(out(1, end - 1), out(1, end));
    output.photometry = out(1, 3);
    output.day = day;
    output.date = date;

    %pre_output.number_errors = size(friggen_errors, 1);
    if exist('friggen_errors_fix_unique')
        pre_output.number_error_trials_removed = size(friggen_errors_fix_unique, 1);
    else
        pre_output.number_error_trials_removed = 0;
    end
    
            if ~(floor(pre_output.phase_check) == floor(pre_output.phase))
        
                PhaseError = [strcat('Incorrect Phase!!! Check:', {' '}, num, {' '}, 'on', {' '}, date)];
                disp(PhaseError)
        
            end
    
        data = [data(2:end, :)];
    
      % Fix time-related issues in file

        % Adjust the time stamps to avoid issues if the Arduino timer resets during a session

            times23 = diff( data(:, 1) ); % calculates the time difference between each timestamp
            times24 = vertcat(0, times23);  %adds a zero to the top of the list to make the vector even with original vector size
            restarttime = (times24 < 0); %scans time differences to see if there are any negative values
            restarttime2 = restarttime .* data(:, 1); %multiplies all of the original timestamps by the logic vector
            restarttime5 = (times24 < 0) == 0; %inverse of logic vector
            restarttime6 = (restarttime5 .* times24); 
            restarttime7 = restarttime6 + restarttime2;
            restarttime8 = restarttime7 / 1000000;
            sumtimess = cumsum(restarttime8);
            timessssss = sumtimess * 1000000; %time is in seconds

            data(:, 1) = timessssss;

            if timessssss(end) > 1800000000
                half_hour = find(timessssss > 1800000000);
                half_hour_timestamp = timessssss(half_hour(1, 1));
            else
                half_hour = NaN;
                half_hour_timestamp = timessssss(end);
            end

%         % Cut off data at 1 hour
% 
%             if timessssss(end) > 3600000000
%                 timessssss(timessssss > 3600000000) = NaN;
%                 new_times = rmmissing(timessssss);
%                 shorten = length(new_times);   
%                 data = data(1 : shorten, :);
%                 dur = 60;
%             else
                new_times = timessssss;
                dur = new_times(end) / 60000000;            
%             end

        % Cut off data at 40 minutes

%             if timessssss(end) > 2400000000
%                 timessssss(timessssss > 2400000000) = NaN;
%                 new_times = rmmissing(timessssss);
%                 shorten = length(new_times);   
%                 data = data(1 : shorten, :);
%                 dur = 40;
%             else
%                 new_times = timessssss;
%                 dur = new_times(end) / 60000000;            
%             end
            
%                 new_times = timessssss;
%                 dur = new_times(end) / 60000000;  
    
                output.session_duration = dur;  


wait_start = data(:, 2) == 8;
wait_start_index = find(wait_start == 1);

% Obtain trial by trial data
t = 1;

    for b = 1:(length (wait_start_index) - 1) 
        
        trial_cell{b, :} = data(wait_start_index(b, 1): wait_start_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by 8 event to 8 event) in each cell
        
            % Fix to make sure two trials don't get combined if WN doesnt print
                trial_start_index{b, :} = find(trial_cell{b, 1}(:, 2) == 9);

                    if (size(trial_start_index{b, 1}, 1) > 1) == 1

                        fix_wait_duration = (trial_cell{b, 1}(trial_start_index{b, 1}(2, 1), 8) - 499985); % calculates when to print the wait duration
                        fix_wait_timestamp = (trial_cell{b, 1}(trial_start_index{b, 1}(2, 1), 1) - fix_wait_duration);
                        fix_row_post_index = find(trial_cell{b, 1}(:, 1) > fix_wait_timestamp);
                        fix_row_insert = fix_row_post_index(1, 1) - 1;
                        fix_new_row = zeros(1,size(data,2));
                        fix_new_row(1, 1) = fix_wait_timestamp;
                        fix_new_row(1, 2) = 8;
                        data_new = [data(1: (wait_start_index(b, 1) + fix_row_insert), :); fix_new_row; data((wait_start_index(b, 1) + fix_row_insert + 1) : end, :)];
                        data = data_new;
                        clear trial_cell;
                        clear trial_start_index;

                        wait_start = data(:, 2) == 8;
                        wait_start_index = find(wait_start == 1);

                        %b = 1;
                        rerun = 1;
                    
                    end
                    
            trial_cell{b, :} = data(wait_start_index(b, 1): wait_start_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by 8 event to 8 event) in each cell
            trial_start_index{b, :} = find(trial_cell{b, 1}(:, 2) == 9);

            if ~isempty(trial_start_index{b, :})
                trial_start_timestamp(b, :) = trial_cell{b, 1}(trial_start_index{b, :}, 1);
            else
                trial_start_timestamp(b, :) = NaN;
            end

            trials_started(b, :) = sum((trial_cell{b,:}(:,2)) == 9); %returns logical values for whether the trial contained a go tone
   
            trials_reward(b, :) = sum((trial_cell{b,:}(:,2)) == 2); %returns logical values for whether the trial contained a reward

            if trials_reward(b, :) > 0
                reward_index(b, 1) = find(trial_cell{b,:}(:,2) == 2);
            else
                reward_index(b, 1) = NaN;
            end

            trials_restart(b, :) = sum((trial_cell{b,:}(:,2)) == 10);
            
            if trials_restart(b, :)
                index_restart(b, :) = find((trial_cell{b,:}(:,2)) == 10); %indexes the line of each incomplete within each trial
                restart_timestamps(b, 1) = trial_cell{b, :}(index_restart(b, :), 1);
            else
                index_restart(b, :) = NaN;
                restart_timestamps(b, 1) = NaN;
            end

            trials_miss(b, :) = sum((trial_cell{b,:}(:,2)) == 11);

            if trials_miss(b, :) == 1
                miss_index_trial(b, 1) = find((trial_cell{b,:}(:,2)) == 11);
                miss_timestamp(b, 1) = trial_cell{b, 1}(miss_index_trial(b, 1), 1);
            else
                miss_index_trial(b, 1) = NaN;
                miss_timestamp(b, 1) = NaN;
            end

            trials_correct_rejection(b, :) = sum((trial_cell{b,:}(:,2)) == 12);
            trials_false_alarm(b, :) = sum((trial_cell{b,:}(:,2)) == 13);

                if floor(output.phase_check) == 3 | floor(output.phase_check) == 13

                    if b < (length (wait_start_index) - 1)
                        if (trials_miss(b, :) == 1 | trials_false_alarm(b, :) == 1)
                            next_trial_is_repeat(b, 1) = 1; 
                        else
                            next_trial_is_repeat(b, 1) = 0; 
                        end
                    end

                else
                    next_trial_is_repeat(b, 1) = 0;
                end

               if trials_correct_rejection(b, :) == 1
                 CR_index_trial(b, 1) = find((trial_cell{b,:}(:,2)) == 12);
                 CR_timestamp(b, 1) = trial_cell{b, 1}(CR_index_trial(b, 1), 1);
               else
                 CR_index_trial(b, 1) = NaN;
                 CR_timestamp(b, 1) = NaN;                   
               end

               if trials_false_alarm(b, :) == 1
                 FA_index_trial(b, 1) = find((trial_cell{b,:}(:,2)) == 13);
                 FA_timestamp(b, 1) = trial_cell{b, 1}(FA_index_trial(b, 1), 1);
               else
                 FA_index_trial(b, 1) = NaN;
                 FA_timestamp(b, 1) = NaN;                   
               end

                if trials_miss(b, :) > 0 & trials_restart(b, :) > 0 % a fix for a lost trial
                    trials_miss(b, :) = 0;
                    current_bug_2(b, :) = 1;
                else
                    current_bug_2(b, :) = 0;
                end

    
                   try
                   go_cue_index(b, 1) = find(trial_cell{b, :}(:, 2) == 20);          
                   catch
                   go_cue_index(b, 1) = NaN;
                   end
 
                   if ~isnan(go_cue_index(b, 1))

                        try
                            go_cue_end_index(b, 1) = find(trial_cell{b, :}(:, 2) == 21);
                            go_cue_timestamps(b, 2) = trial_cell{b,:}(go_cue_end_index(b, 1), 1);  
                            go_off_not_printed(b, 1) = 0;
                        catch
                            go_cue_end_index(b, 1) = NaN;
                            go_cue_timestamps(b, 2) = NaN;
                            go_off_not_printed(b, 1) = 1;
                        end

                       go_cue_start_index(b, 1) = find(trial_cell{b, :}(:, 2) == 20);
                       go_cue_timestamps(b, 1) = trial_cell{b,:}(go_cue_start_index(b, 1), 1);
                   else
                       go_cue_start_index(b, 1) = NaN;
                       go_cue_end_index(b, 1) = NaN;
                       go_cue_timestamps(b, 1) = NaN;
                       go_cue_timestamps(b, 2) = NaN;  
                       go_off_not_printed(b, 1) = NaN;
                   end

                   try
                   nogo_cue_index(b, 1) = find(trial_cell{b, :}(:, 2) == 22);          
                   catch
                   nogo_cue_index(b, 1) = NaN;
                   end
 
                   if ~isnan(nogo_cue_index(b, 1))
                       nogo_cue_start_index(b, 1) = find(trial_cell{b, :}(:, 2) == 22);
                        try
                            nogo_cue_end_index(b, 1) = find(trial_cell{b, :}(:, 2) == 23);
                            nogo_cue_timestamps(b, 2) = trial_cell{b,:}(nogo_cue_end_index(b, 1), 1);  
                            nogo_off_not_printed(b, 1) = 0;
                        catch
                            nogo_cue_end_index(b, 1) = NaN;
                            nogo_cue_timestamps(b, 2) = NaN;
                            nogo_off_not_printed(b, 1) = 1;
                        end
                  
                       nogo_cue_timestamps(b, 1) = trial_cell{b,:}(nogo_cue_start_index(b, 1), 1);
                         
                   else
                       nogo_cue_start_index(b, 1) = NaN;
                       nogo_cue_end_index(b, 1) = NaN;
                       nogo_cue_timestamps(b, 1) = NaN;
                       nogo_cue_timestamps(b, 2) = NaN;   
                       nogo_off_not_printed(b, 1) = NaN;
                   end

            licking_index{b, 1} = find(trial_cell{b,:}(:, 4) == 1);
            licking_timestamps{b, 1} = trial_cell{b,:}(licking_index{b, 1}(:, :), 1);

            half_hour_trial(b, 1) = sum(trial_cell{b, 1}(1, 1) < half_hour_timestamp);


            if ~isnan(reward_index(b, 1))

                % Post RW licking
                reward_timestamp(b, 1) = trial_cell{b, 1}(reward_index(b, 1), 1);
                licks_postRW{b, 1} = find(licking_timestamps{b, 1} >= reward_timestamp(b, 1));

                try
                licks_postRW_timeframe(b, 1) = (trial_cell{b, 1}(end, 1) - reward_timestamp(b, 1)) / 1000000; % in seconds
                licks_per_sec_postRW(b, 1) = size(licks_postRW{b, 1}, 1) / licks_postRW_timeframe(b, 1);
                catch
                licks_per_sec_postRW(b, 1) = 0;
                end

                % Pre RW licking
                    licks_during_cue{b, 1} = find(licking_timestamps{b, 1} >= go_cue_timestamps(b, 1) & licking_timestamps{b, 1} < go_cue_timestamps(b, 2));
                    licks_during_cue_timeframe_micro(b, 1) = (go_cue_timestamps(b, 2) - go_cue_timestamps(b, 1)); 
                    licks_during_cue_timeframe_sec(b, 1) = (go_cue_timestamps(b, 2) - go_cue_timestamps(b, 1)) / 1000000; 

                    licks_pre_cue{b, 1} = find(licking_timestamps{b, 1} < go_cue_timestamps(b, 1) & licking_timestamps{b, 1} >= (go_cue_timestamps(b, 1) - licks_during_cue_timeframe_micro(b, 1)));

                    licks_per_sec_during_cue(b, 1) = size(licks_during_cue{b, 1}, 1) / licks_during_cue_timeframe_sec(b, 1);
                    licks_per_sec_pre_cue(b, 1) = size(licks_pre_cue{b, 1}, 1) / licks_during_cue_timeframe_sec(b, 1);
                                        


            else
                reward_timestamp(b, 1) = NaN;
                licks_per_sec_postRW(b, 1) = NaN;

                licks_per_sec_during_cue(b, 1) = NaN;
                licks_per_sec_pre_cue(b, 1) = NaN;                
                
            end

           RW_latencies(b, 1) =  (reward_timestamp(b, 1) - go_cue_timestamps(b, 1)) / 1000; % in miliseconds
           FA_latencies(b, 1) =  (FA_timestamp(b, 1) - nogo_cue_timestamps(b, 1)) / 1000; % in miliseconds           
           restart_latencies(b, 1) = (restart_timestamps(b, 1) - trial_start_timestamp(b, 1)) / 1000; % in miliseconds

    end

   if exist('rerun') %reruns the trial_cell loop if one of the trials did not print a stop event
                            clear trial_cell;
                        clear trial_start_index;
t = 1;

    for b = 1:(length (wait_start_index) - 1) 
         
        trial_cell{b, :} = data(wait_start_index(b, 1): wait_start_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by 8 event to 8 event) in each cell
               
            % Fix to make sure two trials don't get combined if WN doesnt print
                trial_start_index{b, :} = find(trial_cell{b, 1}(:, 2) == 9);

                    if (size(trial_start_index{b, 1}, 1) > 1) == 1

                        fix_wait_duration = (trial_cell{b, 1}(trial_start_index{b, 1}(2, 1), 8) - 499985); % calculates when to print the wait duration
                        fix_wait_timestamp = (trial_cell{b, 1}(trial_start_index{b, 1}(2, 1), 1) - fix_wait_duration);
                        fix_row_post_index = find(trial_cell{b, 1}(:, 1) > fix_wait_timestamp);
                        fix_row_insert = fix_row_post_index(1, 1) - 1;
                        fix_new_row = zeros(1,size(data,2));
                        fix_new_row(1, 1) = fix_wait_timestamp;
                        fix_new_row(1, 2) = 8;
                        data_new = [data(1: (wait_start_index(b, 1) + fix_row_insert), :); fix_new_row; data((wait_start_index(b, 1) + fix_row_insert + 1) : end, :)];
                        data = data_new;
                        clear trial_cell;
                        clear trial_start_index;

                        wait_start = data(:, 2) == 8;
                        wait_start_index = find(wait_start == 1);

                        %b = 1;
                        rerun = 1;
                    
                    end
                    
            trial_cell{b, :} = data(wait_start_index(b, 1): wait_start_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by 8 event to 8 event) in each cell
            trial_start_index{b, :} = find(trial_cell{b, 1}(:, 2) == 9);

            if ~isempty(trial_start_index{b, :})
                trial_start_timestamp(b, :) = trial_cell{b, 1}(trial_start_index{b, :}, 1);
            else
                trial_start_timestamp(b, :) = NaN;
            end

            trials_started(b, :) = sum((trial_cell{b,:}(:,2)) == 9); %returns logical values for whether the trial contained a go tone
   
            trials_reward(b, :) = sum((trial_cell{b,:}(:,2)) == 2); %returns logical values for whether the trial contained a reward

            if trials_reward(b, :) > 0
                reward_index(b, 1) = find(trial_cell{b,:}(:,2) == 2);
            else
                reward_index(b, 1) = NaN;
            end

            trials_restart(b, :) = sum((trial_cell{b,:}(:,2)) == 10);

            if trials_restart(b, :)
                index_restart(b, :) = find((trial_cell{b,:}(:,2)) == 10); %indexes the line of each incomplete within each trial
                restart_timestamps(b, 1) = trial_cell{b, :}(index_restart(b, :), 1);
            else
                index_restart(b, :) = NaN;
                restart_timestamps(b, 1) = NaN;
            end

            trials_miss(b, :) = sum((trial_cell{b,:}(:,2)) == 11);

            if trials_miss(b, :) == 1
                miss_index_trial(b, 1) = find((trial_cell{b,:}(:,2)) == 11);
                miss_timestamp(b, 1) = trial_cell{b, 1}(miss_index_trial(b, 1), 1);
            else
                miss_index_trial(b, 1) = NaN;
                miss_timestamp(b, 1) = NaN;
            end

            trials_correct_rejection(b, :) = sum((trial_cell{b,:}(:,2)) == 12);
            trials_false_alarm(b, :) = sum((trial_cell{b,:}(:,2)) == 13);

                if floor(output.phase_check) == 3 | floor(output.phase_check) == 13

                    if b < (length (wait_start_index) - 1)
                        if (trials_miss(b, :) == 1 | trials_false_alarm(b, :) == 1)
                            next_trial_is_repeat(b, 1) = 1; 
                        else
                            next_trial_is_repeat(b, 1) = 0; 
                        end
                    end

                else
                    next_trial_is_repeat(b, 1) = 0;
                end

               if trials_correct_rejection(b, :) == 1
                 CR_index_trial(b, 1) = find((trial_cell{b,:}(:,2)) == 12);
                 CR_timestamp(b, 1) = trial_cell{b, 1}(CR_index_trial(b, 1), 1);
               else
                 CR_index_trial(b, 1) = NaN;
                 CR_timestamp(b, 1) = NaN;                   
               end

               if trials_false_alarm(b, :) == 1
                 FA_index_trial(b, 1) = find((trial_cell{b,:}(:,2)) == 13);
                 FA_timestamp(b, 1) = trial_cell{b, 1}(FA_index_trial(b, 1), 1);
               else
                 FA_index_trial(b, 1) = NaN;
                 FA_timestamp(b, 1) = NaN;                   
               end

                if trials_miss(b, :) > 0 & trials_restart(b, :) > 0 % a fix for a lost trial
                    trials_miss(b, :) = 0;
                    current_bug_2(b, :) = 1;
                else
                    current_bug_2(b, :) = 0;
                end

    
                   try
                   go_cue_index(b, 1) = find(trial_cell{b, :}(:, 2) == 20);          
                   catch
                   go_cue_index(b, 1) = NaN;
                   end
 
                   if ~isnan(go_cue_index(b, 1))

                        try
                            go_cue_end_index(b, 1) = find(trial_cell{b, :}(:, 2) == 21);
                            go_cue_timestamps(b, 2) = trial_cell{b,:}(go_cue_end_index(b, 1), 1);  
                            go_off_not_printed(b, 1) = 0;
                        catch
                            go_cue_end_index(b, 1) = NaN;
                            go_cue_timestamps(b, 2) = NaN;
                            go_off_not_printed(b, 1) = 1;
                        end

                       go_cue_start_index(b, 1) = find(trial_cell{b, :}(:, 2) == 20);
                       go_cue_timestamps(b, 1) = trial_cell{b,:}(go_cue_start_index(b, 1), 1);
                   else
                       go_cue_start_index(b, 1) = NaN;
                       go_cue_end_index(b, 1) = NaN;
                       go_cue_timestamps(b, 1) = NaN;
                       go_cue_timestamps(b, 2) = NaN;  
                       go_off_not_printed(b, 1) = NaN;
                   end

                   try
                   nogo_cue_index(b, 1) = find(trial_cell{b, :}(:, 2) == 22);          
                   catch
                   nogo_cue_index(b, 1) = NaN;
                   end
 
                   if ~isnan(nogo_cue_index(b, 1))
                       nogo_cue_start_index(b, 1) = find(trial_cell{b, :}(:, 2) == 22);
                        try
                            nogo_cue_end_index(b, 1) = find(trial_cell{b, :}(:, 2) == 23);
                            nogo_cue_timestamps(b, 2) = trial_cell{b,:}(nogo_cue_end_index(b, 1), 1);  
                            nogo_off_not_printed(b, 1) = 0;
                        catch
                            nogo_cue_end_index(b, 1) = NaN;
                            nogo_cue_timestamps(b, 2) = NaN;
                            nogo_off_not_printed(b, 1) = 1;
                        end
                  
                       nogo_cue_timestamps(b, 1) = trial_cell{b,:}(nogo_cue_start_index(b, 1), 1);
                         
                   else
                       nogo_cue_start_index(b, 1) = NaN;
                       nogo_cue_end_index(b, 1) = NaN;
                       nogo_cue_timestamps(b, 1) = NaN;
                       nogo_cue_timestamps(b, 2) = NaN;   
                       nogo_off_not_printed(b, 1) = NaN;
                   end

            licking_index{b, 1} = find(trial_cell{b,:}(:, 4) == 1);
            licking_timestamps{b, 1} = trial_cell{b,:}(licking_index{b, 1}(:, :), 1);

            half_hour_trial(b, 1) = sum(trial_cell{b, 1}(1, 1) < half_hour_timestamp);

            if ~isnan(reward_index(b, 1))

                % Post RW licking
                reward_timestamp(b, 1) = trial_cell{b, 1}(reward_index(b, 1), 1);
                licks_postRW{b, 1} = find(licking_timestamps{b, 1} >= reward_timestamp(b, 1));

                try
                licks_postRW_timeframe(b, 1) = (trial_cell{b, 1}(end, 1) - reward_timestamp(b, 1)) / 1000000; % in seconds
                licks_per_sec_postRW(b, 1) = size(licks_postRW{b, 1}, 1) / licks_postRW_timeframe(b, 1);
                catch
                licks_per_sec_postRW(b, 1) = 0;
                end

                % Pre RW licking
                    licks_during_cue{b, 1} = find(licking_timestamps{b, 1} >= go_cue_timestamps(b, 1) & licking_timestamps{b, 1} < go_cue_timestamps(b, 2));
                    licks_during_cue_timeframe_micro(b, 1) = (go_cue_timestamps(b, 2) - go_cue_timestamps(b, 1)); 
                    licks_during_cue_timeframe_sec(b, 1) = (go_cue_timestamps(b, 2) - go_cue_timestamps(b, 1)) / 1000000; 

                    licks_pre_cue{b, 1} = find(licking_timestamps{b, 1} < go_cue_timestamps(b, 1) & licking_timestamps{b, 1} >= (go_cue_timestamps(b, 1) - licks_during_cue_timeframe_micro(b, 1)));

                    licks_per_sec_during_cue(b, 1) = size(licks_during_cue{b, 1}, 1) / licks_during_cue_timeframe_sec(b, 1);
                    licks_per_sec_pre_cue(b, 1) = size(licks_pre_cue{b, 1}, 1) / licks_during_cue_timeframe_sec(b, 1);
                                        


            else
                reward_timestamp(b, 1) = NaN;
                licks_per_sec_postRW(b, 1) = NaN;

                licks_per_sec_during_cue(b, 1) = NaN;
                licks_per_sec_pre_cue(b, 1) = NaN;                
                
            end


           RW_latencies(b, 1) =  (reward_timestamp(b, 1) - go_cue_timestamps(b, 1)) / 1000; % in miliseconds
           FA_latencies(b, 1) =  (FA_timestamp(b, 1) - nogo_cue_timestamps(b, 1)) / 1000; % in miliseconds           
           restart_latencies(b, 1) = (restart_timestamps(b, 1) - trial_start_timestamp(b, 1)) / 1000; % in miliseconds

    end

   end % end of rerun statement

   % Data cutoff for loss of engagement at end of session 
            
            trials_analyzed = trials_started;
            trials_analyzed_index = find(trials_analyzed == 1);

        % Loss of engagement via misses
            local_nonresponse_rate = movmean(trials_miss(trials_analyzed_index, 1), sum(trials_started)*0.05, 'omitnan');
            local_nonresponse_rate_cutoff = 0.5;
            local_nonresponse_rate_flag = find(local_nonresponse_rate > local_nonresponse_rate_cutoff);

            local_nonresponse_rate_early_flagind = find(local_nonresponse_rate_flag < size(trials_analyzed_index, 1)*0.1);
            local_nonresponse_rate_late_flagind = find(local_nonresponse_rate_flag > size(trials_analyzed_index, 1)*0.5);

            local_nonresponse_rate_early = local_nonresponse_rate_flag(local_nonresponse_rate_early_flagind, 1);
            local_nonresponse_rate_late = local_nonresponse_rate_flag(local_nonresponse_rate_late_flagind, 1);
            
        % Loss of engagement via not consuming RW
            local_nonresponse_rate_licks_postRW = movmean(licks_per_sec_postRW(trials_analyzed_index, 1), sum(trials_started)*0.05, 'omitnan');
            local_nonresponse_rate_licks_postRW_cutoff = 2;
            local_nonresponse_rate_licks_postRW_flag = find(local_nonresponse_rate_licks_postRW < local_nonresponse_rate_licks_postRW_cutoff);

            local_nonresponse_rate_licks_postRW_early_flagind = find(local_nonresponse_rate_licks_postRW_flag < size(trials_analyzed_index, 1)*0.1);
            local_nonresponse_rate_licks_postRW_late_flagind = find(local_nonresponse_rate_licks_postRW_flag > size(trials_analyzed_index, 1)*0.5);
            
            local_nonresponse_rate_licks_postRW_early = local_nonresponse_rate_licks_postRW_flag(local_nonresponse_rate_licks_postRW_early_flagind, 1);
            local_nonresponse_rate_licks_postRW_late = local_nonresponse_rate_licks_postRW_flag(local_nonresponse_rate_licks_postRW_late_flagind, 1);
           


    if cutoff_setting == "true";
                if ~isempty(local_nonresponse_rate_early)
                    data_cutoff_early = trials_analyzed_index(local_nonresponse_rate_early(end, 1)) + 1;
                    data_cutoff_early_shortened = local_nonresponse_rate_early(end, 1) + 1;
                else
                    data_cutoff_early = 1;
                    data_cutoff_early_shortened = 1;
                end

                if ~isempty(local_nonresponse_rate_late) | ~isempty(local_nonresponse_rate_licks_postRW_late)
                    if ~isempty(local_nonresponse_rate_late)
                        miss_cutoff_late = trials_analyzed_index(local_nonresponse_rate_late(1, 1)) - 1;
                        miss_cutoff_late_shortened = local_nonresponse_rate_late(1, 1) - 1;
                    else
                        miss_cutoff_late = NaN;
                        miss_cutoff_late_shortened = NaN;
                    end

                    if  ~isempty(local_nonresponse_rate_licks_postRW_late)
                        ingest_cutoff_late = trials_analyzed_index(local_nonresponse_rate_licks_postRW_late(1, 1)) - 1;
                        ingest_cutoff_late_shortened = local_nonresponse_rate_licks_postRW_late(1, 1) - 1;
                    else
                        ingest_cutoff_late = NaN;
                        ingest_cutoff_late_shortened = NaN;
                    end

                    data_cutoff_late = min([miss_cutoff_late ingest_cutoff_late]);
                    data_cutoff_late_shortened = min([miss_cutoff_late_shortened ingest_cutoff_late_shortened]);
                else
                    data_cutoff_late = size(trial_cell, 1);
                    data_cutoff_late_shortened = size(trials_analyzed_index, 1);
                end  

                output.session_engagement_prop = (data_cutoff_late - data_cutoff_early) / size(trial_cell, 1);
    else
        data_cutoff_early = 1;
        data_cutoff_early_shortened = 1;

        data_cutoff_late = size(trial_cell, 1);
        data_cutoff_late_shortened = size(trials_analyzed_index, 1);
        
        output.session_engagement_prop = NaN;
    end

    % Obtain Performance Data (with engagement cutoff)

        Restart_Number = sum(trials_restart(data_cutoff_early:data_cutoff_late, 1));

        Hit_Number = sum(trials_reward(data_cutoff_early:data_cutoff_late, 1));
        Miss_Number = sum(trials_miss(data_cutoff_early:data_cutoff_late, 1));

        False_Alarm_Number = sum(trials_false_alarm(data_cutoff_early:data_cutoff_late, 1));
        Correct_Rejection_Number = sum(trials_correct_rejection(data_cutoff_early:data_cutoff_late, 1));
        
        Total_Trials = length(trial_cell(data_cutoff_early:data_cutoff_late, 1));
        Total_Trials_Go_Sound = Hit_Number + Miss_Number;
        Total_Trials_Nogo_Sound = False_Alarm_Number + Correct_Rejection_Number;

        Total_Trials_Plus_Restarts = Total_Trials_Go_Sound + Total_Trials_Nogo_Sound + Restart_Number;

        Hit_Rate = Hit_Number / Total_Trials_Go_Sound;
        FA_Rate = False_Alarm_Number / Total_Trials_Nogo_Sound;

        Session_Duration = (trial_cell{data_cutoff_late, 1}(1,1) - trial_cell{data_cutoff_early, 1}(1,1)) / 60000000;  % session duration in minutes

output.RW_Per_Min = Hit_Number / Session_Duration;

output.Hit_Rate = Hit_Rate;
output.FA_Rate = FA_Rate;

if Hit_Rate == 1
    dprime_hr = 1-1/(2*Total_Trials_Go_Sound);
elseif Hit_Rate == 0
    dprime_hr = 0 + 1/(2*Total_Trials_Go_Sound);
else
    dprime_hr = Hit_Rate;
end

if FA_Rate == 0
    dprime_fa = 0 + 1/(2*Total_Trials_Nogo_Sound);
elseif FA_Rate == 1
    dprime_fa = 1-1/(2*Total_Trials_Nogo_Sound);
else
    dprime_fa = FA_Rate;
end

[d, c] = dprime_simple(dprime_hr, dprime_fa);

output.D_Prime = d;
output.Response_Bias = c;

output.Restart_Rate = Restart_Number / Total_Trials_Plus_Restarts;

if output.Restart_Rate == 0
    dprime_fa = 0 + 1/(2*Total_Trials_Plus_Restarts);
elseif output.Restart_Rate == 1
    dprime_fa = 1-1/(2*Total_Trials_Plus_Restarts);
else
    dprime_fa = output.Restart_Rate;
end

[d, c] = dprime_simple(dprime_hr, dprime_fa);

output.D_Prime_Light = d;
output.Response_Bias_Light = c;

output.Hit_Number = Hit_Number;
output.Miss_Number = Miss_Number;
output.Correct_Rejection_Number = Correct_Rejection_Number;
output.False_Alarm_Number = False_Alarm_Number;

output.Restart_Number = Restart_Number;

output.Total_Trials_Go_Sound = Total_Trials_Go_Sound;
output.Total_Trials_Nogo_Sound = Total_Trials_Nogo_Sound;

output.Total_Trials_Plus_Restarts = Total_Trials_Plus_Restarts;


% Cue associations
    
    lps_difference_cue = licks_per_sec_during_cue - licks_per_sec_pre_cue;

    output.mean_lps_difference_after_cue_start = mean(lps_difference_cue(data_cutoff_early:data_cutoff_late, 1), 'omitnan');
    output.mean_lps_during_cue = mean(licks_per_sec_during_cue(data_cutoff_early:data_cutoff_late, 1), 'omitnan');
    output.mean_lps_pre_cue =  mean(licks_per_sec_pre_cue(data_cutoff_early:data_cutoff_late, 1), 'omitnan');

   [h, p] = ttest(licks_per_sec_during_cue(data_cutoff_early:data_cutoff_late, 1), licks_per_sec_pre_cue(data_cutoff_early:data_cutoff_late, 1));

   output.ttest_pval_lps_pericue = p;
    

    % Obtain Performance Data (without engagement cutoff)

        Restart_Number_uncut = sum(trials_restart);

        Hit_Number_uncut = sum(trials_reward);
        Miss_Number_uncut = sum(trials_miss);

        False_Alarm_Number_uncut = sum(trials_false_alarm);
        Correct_Rejection_Number_uncut = sum(trials_correct_rejection);
        
        Total_Trials_uncut = length(trial_cell);
        Total_Trials_Go_Sound_uncut = Hit_Number_uncut + Miss_Number_uncut;
        Total_Trials_Nogo_Sound_uncut = False_Alarm_Number_uncut + Correct_Rejection_Number_uncut;

        Total_Trials_Plus_Restarts_uncut = Total_Trials_Go_Sound_uncut + Total_Trials_Nogo_Sound_uncut + Restart_Number_uncut;

        Hit_Rate_uncut = Hit_Number_uncut / Total_Trials_Go_Sound_uncut;
        FA_Rate_uncut = False_Alarm_Number_uncut / Total_Trials_Nogo_Sound_uncut;

        Session_Duration_uncut = (trial_cell{data_cutoff_late, 1}(1,1) - trial_cell{data_cutoff_early, 1}(1,1)) / 60000000;  % session duration in minutes

output.RW_Per_Min_uncut = Hit_Number_uncut / Session_Duration_uncut;

output.Hit_Rate_uncut = Hit_Rate_uncut;
output.FA_Rate_uncut = FA_Rate_uncut;

    if Hit_Rate_uncut == 1
        dprime_hr_uncut = 1-1/(2*Total_Trials_Go_Sound_uncut);
    elseif Hit_Rate_uncut == 0
        dprime_hr_uncut = 0 + 1/(2*Total_Trials_Go_Sound_uncut);
    else
        dprime_hr_uncut = Hit_Rate_uncut;
    end

    if FA_Rate_uncut == 0
        dprime_fa_uncut = 0 + 1/(2*Total_Trials_Nogo_Sound_uncut);
    elseif FA_Rate_uncut == 1
        dprime_fa_uncut = 1-1/(2*Total_Trials_Nogo_Sound_uncut);
    else
        dprime_fa_uncut = FA_Rate_uncut;
    end

[d, c] = dprime_simple(dprime_hr_uncut, dprime_fa_uncut);

output.D_Prime_uncut = d;
output.Response_Bias_uncut = c;

output.Restart_Rate_uncut = Restart_Number_uncut / Total_Trials_Plus_Restarts_uncut;

    if output.Restart_Rate_uncut == 0
        dprime_fa_uncut = 0 + 1/(2*Total_Trials_Plus_Restarts_uncut);
    elseif output.Restart_Rate_uncut == 1
        dprime_fa_uncut = 1-1/(2*Total_Trials_Plus_Restarts_uncut);
    else
        dprime_fa_uncut = output.Restart_Rate_uncut;
    end

[d, c] = dprime_simple(dprime_hr_uncut, dprime_fa_uncut);

output.D_Prime_Light_uncut = d;
output.Response_Bias_Light_uncut = c;

output.Hit_Number_uncut = Hit_Number_uncut;
output.Miss_Number_uncut = Miss_Number_uncut;
output.Correct_Rejection_Number_uncut = Correct_Rejection_Number_uncut;
output.False_Alarm_Number_uncut = False_Alarm_Number_uncut;

output.Restart_Number_uncut = Restart_Number_uncut;

output.Total_Trials_Go_Sound_uncut = Total_Trials_Go_Sound_uncut;
output.Total_Trials_Nogo_Sound_uncut = Total_Trials_Nogo_Sound_uncut;

output.Total_Trials_Plus_Restarts_uncut = Total_Trials_Plus_Restarts_uncut;




% Testing
output.local_nonresponse_rate = local_nonresponse_rate;
output.median_lps_postRW = median(licks_per_sec_postRW, 'omitnan');
output.lps_raw = licks_per_sec_postRW;

if output.median_lps_postRW < 3
    output.potential_lickometer_issue = "potential issue";
else
    output.potential_lickometer_issue = "ok";
end
 
% Cue associations
    
    output.mean_lps_difference_after_cue_start_uncut = mean(lps_difference_cue, 'omitnan');
    output.mean_lps_during_cue_uncut = mean(licks_per_sec_during_cue, 'omitnan');
    output.mean_lps_pre_cue_uncut =  mean(licks_per_sec_pre_cue, 'omitnan');

   [h, p] = ttest(licks_per_sec_during_cue(:, 1), licks_per_sec_pre_cue(:, 1));

   output.ttest_pval_lps_pericue_uncut = p;
   





   % Premature licking latencies

       % output.premature_lick_latencies = (restart_timestamps - trial_start_timestamp) ./ 1000000; %in seconds
       % output.premature_sound_lick_latencies = (restart_timestamps(trials_lick_during_cue_uncut, 1) - go_cue_timestamps(trials_lick_during_cue_uncut, 1)) ./ 1000000;
       % 
       % output.median_premature_lick_latencies = median(output.premature_lick_latencies, 'omitnan'); %in seconds
       % output.median_premature_sound_lick_latencies = median(output.premature_sound_lick_latencies, 'omitnan');
       % 
       % 
       % output.median_premature_lick_latencies_uncut = median((restart_timestamps - trial_start_timestamp) ./ 1000000, 'omitnan'); %in seconds
       % output.median_premature_sound_lick_latencies_uncut = median((restart_timestamps(trials_lick_during_cue_uncut, 1) - go_cue_timestamps(trials_lick_during_cue_uncut, 1)) ./ 1000000, 'omitnan');
       % 

output.go_off_not_printed = sum(go_off_not_printed, 'omitnan');
output.nogo_off_not_printed = sum(nogo_off_not_printed, 'omitnan');


% nogo_off_not_printed_when = find(nogo_off_not_printed == 1);
% 
% if ~isempty(nogo_off_not_printed_when)
% output.approx_when_sc_stopped_nogo = trial_cell{nogo_off_not_printed_when(end, 1), 1}(1, 1) / 60000000;
% else
% output.approx_when_sc_stopped_nogo = NaN;
% end


% go_off_not_printed_when = find(go_off_not_printed == 1);
% 
% if ~isempty(go_off_not_printed_when)
% output.approx_when_sc_stopped_go = trial_cell{go_off_not_printed_when, 1}(1, 1) / 60000000;
% else
% output.approx_when_sc_stopped_go = NaN;
% end


% go_cue_duration = go_cue_timestamps(:, 2) - go_cue_timestamps(:, 1);
% go_cue_duration_nonans = go_cue_duration(~isnan(go_cue_duration), 1);
% 
% output.go_cue_durations = go_cue_duration_nonans;


% Trial by Trial Data
    trial_log_uncut = (trials_reward(trials_analyzed_index, 1) .* 5) + (trials_miss(trials_analyzed_index, 1) .* 4) + (trials_correct_rejection(trials_analyzed_index, 1) .* 3) + (trials_false_alarm(trials_analyzed_index, 1) .* 2) + (trials_restart(trials_analyzed_index, 1) .* 1);
    % 5 is hit, 4 is miss, 3 is CR, 2 is FA, 1 is restart
    
    trial_log_cut = trial_log_uncut(data_cutoff_early_shortened:data_cutoff_late_shortened);

output.trial_log = trial_log_cut;
output.trial_log_uncut = trial_log_uncut;


output.mean_RW_latency = mean(RW_latencies(data_cutoff_early:data_cutoff_late, 1), "omitnan");
output.mean_FA_latency = mean(FA_latencies(data_cutoff_early:data_cutoff_late, 1), "omitnan");
output.mean_restart_latency = mean(restart_latencies(data_cutoff_early:data_cutoff_late, 1), "omitnan");

output.median_RW_latency = median(RW_latencies(data_cutoff_early:data_cutoff_late, 1), "omitnan");
output.median_FA_latency = median(FA_latencies(data_cutoff_early:data_cutoff_late, 1), "omitnan");
output.median_restart_latency = median(restart_latencies(data_cutoff_early:data_cutoff_late, 1), "omitnan");

output.std_RW_latency = std(RW_latencies(data_cutoff_early:data_cutoff_late, 1), "omitnan");
output.std_FA_latency = std(FA_latencies(data_cutoff_early:data_cutoff_late, 1), "omitnan");
output.std_restart_latency = std(restart_latencies(data_cutoff_early:data_cutoff_late, 1), "omitnan");



output.mean_RW_latency_uncut = mean(RW_latencies, "omitnan");
output.mean_FA_latency_uncut = mean(FA_latencies, "omitnan");
output.mean_restart_latency_uncut = mean(restart_latencies, "omitnan");

output.median_RW_latency_uncut = median(RW_latencies, "omitnan");
output.median_FA_latency_uncut = median(FA_latencies, "omitnan");
output.median_restart_latency_uncut = median(restart_latencies, "omitnan");

output.std_RW_latency_uncut = std(RW_latencies, "omitnan");
output.std_FA_latency_uncut = std(FA_latencies, "omitnan");
output.std_restart_latency_uncut = std(restart_latencies, "omitnan");


% Extra analysis of ingestive licking

sound_start = data(:, 2) == 20;
sound_start_index = find(sound_start == 1);

for b = 1:(length (sound_start_index) - 1) 
post_sound_trial_cell{b, :} = data(sound_start_index(b, 1): sound_start_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by sound start to next sound start) in each cell

            trials_reward_post_sound_analysis(b, :) = sum((post_sound_trial_cell{b,:}(:,2)) == 2); %returns logical values for whether the trial contained a reward

            if trials_reward_post_sound_analysis(b, :) > 0
                reward_index_post_sound_analysis(b, 1) = find(post_sound_trial_cell{b,:}(:,2) == 2);
            else
                reward_index_post_sound_analysis(b, 1) = NaN;
            end
            
            % trial_start_index_post_sound_analysis(b, 1) = find(post_sound_trial_cell{b, :}(:, 2) == 9);
            % trial_start_timestamps_post_sound_analysis(b, 1) = post_sound_trial_cell{b,:}(trial_start_index_post_sound_analysis(b, 1), 1);
            
            go_cue_end_index_post_sound_analysis(b, 1) = find(post_sound_trial_cell{b, :}(:, 2) == 21);

            go_cue_timestamps_post_sound_analysis(b, 1) = post_sound_trial_cell{b,:}(1, 1);
            go_cue_timestamps_post_sound_analysis(b, 2) = post_sound_trial_cell{b,:}(go_cue_end_index_post_sound_analysis(b, 1), 1);

            licking_index_post_sound_analysis{b, 1} = find(post_sound_trial_cell{b,:}(:, 4) == 1);
            licking_timestamps_post_sound_analysis{b, 1} = post_sound_trial_cell{b,:}(licking_index_post_sound_analysis{b, 1}(:, :), 1);

            if ~isnan(reward_index_post_sound_analysis(b, 1))

                % Post RW licking
                reward_timestamp_post_sound_analysis(b, 1) = post_sound_trial_cell{b, 1}(reward_index_post_sound_analysis(b, 1), 1);
                licks_postRW_post_sound_analysis{b, 1} = find(licking_timestamps_post_sound_analysis{b, 1} >= reward_timestamp_post_sound_analysis(b, 1));
                

                try
                licks_postRW_latency_post_sound_analysis(b, 1) = (licking_timestamps_post_sound_analysis{b, 1}(licks_postRW_post_sound_analysis{b, 1}(2,1), 1) - reward_timestamp_post_sound_analysis(b, 1)) / 1000000; % in seconds, second lick to avoid counting RW dispensing as a lick
                licks_postRW_timeframe_post_sound_analysis(b, 1) = (post_sound_trial_cell{b, 1}(end, 1) - reward_timestamp_post_sound_analysis(b, 1)) / 1000000; % in seconds
                licks_per_sec_postRW_post_sound_analysis(b, 1) = size(licks_postRW_post_sound_analysis{b, 1}, 1) / licks_postRW_timeframe_post_sound_analysis(b, 1);
                catch
                licks_per_sec_postRW_post_sound_analysis(b, 1) = 0;
                licks_postRW_latency_post_sound_analysis(b, 1) = NaN;
                end

                % Pre RW licking
                    licks_during_cue_post_sound_analysis{b, 1} = find(licking_timestamps_post_sound_analysis{b, 1} >= go_cue_timestamps_post_sound_analysis(b, 1) & licking_timestamps_post_sound_analysis{b, 1} < go_cue_timestamps_post_sound_analysis(b, 2));
                    licks_during_cue_timeframe_micro_post_sound_analysis(b, 1) = (go_cue_timestamps_post_sound_analysis(b, 2) - go_cue_timestamps_post_sound_analysis(b, 1)); 
                    licks_during_cue_timeframe_sec_post_sound_analysis(b, 1) = (go_cue_timestamps_post_sound_analysis(b, 2) - go_cue_timestamps_post_sound_analysis(b, 1)) / 1000000; 

                    licks_pre_cue_post_sound_analysis{b, 1} = find(licking_timestamps_post_sound_analysis{b, 1} < go_cue_timestamps_post_sound_analysis(b, 1) & licking_timestamps_post_sound_analysis{b, 1} >= (go_cue_timestamps_post_sound_analysis(b, 1) - licks_during_cue_timeframe_micro_post_sound_analysis(b, 1)));

                    licks_per_sec_during_cue_post_sound_analysis(b, 1) = size(licks_during_cue_post_sound_analysis{b, 1}, 1) / licks_during_cue_timeframe_sec_post_sound_analysis(b, 1);
                    licks_per_sec_pre_cue_post_sound_analysis(b, 1) = size(licks_pre_cue_post_sound_analysis{b, 1}, 1) / licks_during_cue_timeframe_sec_post_sound_analysis(b, 1);
                                        


            else
                reward_timestamp_post_sound_analysis(b, 1) = NaN;
                licks_per_sec_postRW_post_sound_analysis(b, 1) = NaN;
                licks_postRW_latency_post_sound_analysis(b, 1) = NaN;

                licks_per_sec_during_cue_post_sound_analysis(b, 1) = NaN;
                licks_per_sec_pre_cue_post_sound_analysis(b, 1) = NaN;                
                
            end

end
            

            output.licks_per_sec_during_cue_post_sound_analysis = licks_per_sec_during_cue_post_sound_analysis;
            output.licks_per_sec_postRW_post_sound_analysis = licks_per_sec_postRW_post_sound_analysis;
            output.lick_latency_postRW_post_sound_analysis = licks_postRW_latency_post_sound_analysis; 

            output.mean_licks_per_sec_during_cue_post_sound_analysis = mean(licks_per_sec_during_cue_post_sound_analysis, 'omitnan');
            output.mean_licks_per_sec_postRW_post_sound_analysis = mean(licks_per_sec_postRW_post_sound_analysis, 'omitnan');

            output.mean_lick_latency_postRW_post_sound_analysis = mean(licks_postRW_latency_post_sound_analysis, 'omitnan'); 




end