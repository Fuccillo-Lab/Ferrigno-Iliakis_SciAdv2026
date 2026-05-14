function [training_output] = treadmill_training_funct(filename, num, phase, day, date); %filename is the "c:\path", '9-7-21' and 'number'
% Perfromance analysis for all the training phases for Jan 2023

% Start up

    %addpath("C:\Users\sarfe\MATLAB");

    % Open and read .txt file 
        fileID = fopen(filename);

    if floor(str2num(phase)) == 13 | floor(str2num(phase)) == 777 % phase 13 corresponds to the 2022 ascending tones cohort
        out = textscan(fileID, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
        file_struct = 14; % if changing number of commas in file, change this number too!  
    
    elseif floor(str2num(phase)) == 00 % phase 00 corresponds to the Dec 2021 ascending tones cohort
        out = textscan(fileID, '%f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
        file_struct = 9; % if changing number of commas in file, change this number too!  
   
    else % 2023 data
        out = textscan(fileID, '%f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
        file_struct = 13; % if changing number of commas in file, change this number too!

        DMS = {'01', '05', '06', '07', '08', '13', '16'};

    end

    if floor(str2num(phase)) ~= 00
        short = 250; %length of short trials in mm
        medium = 500;
        long = 750;
        cutoff = 200;
        %rescale_vector = [0:10:(long + cutoff)]';
        resc_vect = [0:10:(long + cutoff)]';
    else
        short = 250; %length of short trials in mm
        medium = 750;
        long = 1250;
        cutoff = 200; % not actually true for 2021, will impact the validity of the velocity traces
        %rescale_vector = [0:10:(long + cutoff)]';
        resc_vect = [0:10:(long + cutoff)]';
    end

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

                tone_stop = data(:, 2) == 8;
                tone_stop_index = find(tone_stop == 1);
                tone_stop_index = setdiff(tone_stop_index, friggen_errors); %fix for if the error puts an 8 in the event column


            for i = 1:(size(friggen_errors, 1))

                friggen_errors_stops{i, 1} = find(tone_stop_index < friggen_errors(i, 1));
                friggen_errors_fix(i, 1) = tone_stop_index(friggen_errors_stops{i, 1}(end, 1), 1);
                
                    if friggen_errors_stops{i, 1}(end, 1) < length(tone_stop_index)
                        friggen_errors_fix(i, 2) = tone_stop_index(friggen_errors_stops{i, 1}(end, 1) + 1, 1); 
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
            
            clear tone_stop tone_stop_index;

        end

    output.animalID = num;
    training_output.animalID = num;
        
%         if ismember(output.animalID, DMS)
%            output.circuit = 'DMS';
%         else
%            output.circuit = 'DLS';
%         end


    output.phase = str2num(phase); 
    output.phase_check = max(out(1, end - 1), out(1, end));

    training_output.phase_check = max(out(1, end - 1), out(1, end));
    training_output.phase = str2num(phase); 


    output.day = day;
    output.date = date;

    training_output.day = day;
    training_output.date = date;

    %output.number_errors = size(friggen_errors, 1);
    if exist('friggen_errors_fix_unique')
        output.number_error_trials_removed = size(friggen_errors_fix_unique, 1);
    else
        output.number_error_trials_removed = 0;
    end
    
            if ~(floor(output.phase_check) == floor(output.phase))
                output.phase_check = output.phase;
        
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

                training_output.session_duration = dur;  

% 
%                 if output.phase == 00
%                    output.Complete_Cued = data(end, end);
% 
%                    return
%                 end
                
    % Add movement stamps signifying no movment

    %     moves = data(:, 2) == 0 | 8 | 10;
    %     moves_index = find(moves == 1);

    %     %data_control = data;
    %     %moves_index_control = moves_index;

    %     for i = 1:(size(moves_index, 1) - 1)

    %         time_diffs(i, 1) = data(moves_index((i + 1), 1), 1) - data(moves_index(i, 1), 1);
    %         time_diffs(i, 2) = data(moves_index(i, 1), 1);
    %         time_diffs(i, 3) = moves_index(i, 1);
    %         time_diffs(i, 4) = time_diffs(i, 1) / 300000;

    %         if time_diffs(i, 4) >= 1

    %             t = floor(time_diffs(i, 4));

    %                 for q = 1:(t)
                                
    %                     stop_new_timestamp = time_diffs(i, 2) + (300000 * q);

    %                     stop_new_row = zeros(1,size(data,2));
    %                     stop_new_row(1, 1) = stop_new_timestamp;
    %                     data = [data(1: (time_diffs(i, 3) + (q - 1)), :); stop_new_row; data( (time_diffs(i, 3) + q) : end, :)];
                                   
    %                 end

    %             moves_index((i + 1): end, 1) = moves_index((i + 1): end, 1) + q;

    %         end

    %     end

    % new_times = data(:, 1);
             
    % Separate behavioral events from data file

        licks = data(:, 2) == 1;
        lick_index = find(licks == 1);

        solenoid = data(:, 2) == 2 | data(:, 2) == 12;
        solenoid_index = find(solenoid == 1);

        tone_go = data(:, 2) == 9;
        tone_go_index = find(tone_go == 1);

        tone_stop = data(:, 2) == 8;
        tone_stop_index = find(tone_stop == 1);
                
        percent20 = data(:, 2) == 3;
        percent20_index = find(percent20 == 1);
                
        percent40 = data(:, 2) == 4;
        percent40_index = find(percent40 == 1);
        
        percent60 = data(:, 2) == 5;
        percent60_index = find(percent60 == 1);
                
        percent80 = data(:, 2) == 6;
        percent80_index = find(percent80 == 1);
                
        percent100 = data(:, 2) == 7;
        percent100_index = find(percent100 == 1);

        slow_down = data(:, 2) == 77;
        slow_down_index = find(slow_down == 1);

        restart = data(:, 2) == 10;
        restart_index = find(restart == 1);

        slow_fail = data(:, 2) == 11;
        slow_fail_index = find(slow_fail == 1);

        premature_slow = data(:, 2) == 13;
        premature_slow_index = find(premature_slow == 1);

    % Obtain physical data from behavioral file

    if floor(str2num(phase)) ~= 13 & floor(str2num(phase)) ~= 777 & floor(str2num(phase)) ~= 00

        % Separate physical metrics from the behavioral file
            distance_cum = data(:, 3); %cumulative distance (cm) run through session
            distance_trial = data(:, 6); %elapsed distance within trial
            velocity = data(:, 5);

            velocity1 = data(:, 8);
            velocity2 = data(:, 10);
            velocity3 = data(:, 11);
            velocity4 = data(:, 12);
            velocity5 = data(:, 13);

        % Remove outliers from velocity data 
            velocity(velocity > 700) = 0;
            data(:, 5) = velocity;
            
            new_timess = new_times ./ 60000000;

    end
            
%Create Figure 1

%    figure(1)
%        hold on
%        plot(new_timess, velocity, 'b');
%          plot(new_timess, velocity1, 'm');
% %           plot(new_times, velocity2, 'g');
% %          plot(new_times, velocity3, 'c');
% %              plot(new_times, velocity4, 'k');
% %            plot(new_times, velocity5, 'r');    
% % 
% %        plot(new_times, licks * 300, 'r*');
%        plot(new_timess, solenoid * 250, 'r.');
% %        plot(new_times, tone_go * 50, 'k+');
% %        plot(new_times, tone_stop * 20, 'k*');
% %        plot(new_times, percent20 * 120, 'c+');
% %        plot(new_times, percent40 * 140, 'c+');
% %        plot(new_times, percent60 * 160, 'c+');
% %        plot(new_times, percent80 * 130, 'c+');
% %        plot(new_times, percent100 * 190, 'c+');
% %        plot(new_times, slow_down * 200, 'c+');
% %        plot(new_times, slow_fail, 'r');
% %        plot(new_times, premature_slow * 300, 'k+');
%        axis ([-inf inf 0 600]);

%    hold off
   

%    % Save Fig 1 file to computer 
   
%     [Where] = Where_file(filename);
%     SaveName = [strcat(Where, 'SessionPlot_v3_', date, '_', num, '_', phase)];
%     savefig(SaveName);

%     close all


% Obtain trial by trial data
t = 1;

    for b = 1:(length (tone_stop_index) - 1) 
                
        stop_cue{b, :} = data(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by 8 event to 8 event) in each cell
               
            % Fix to make sure two trials don't get combined if WN doesnt print
                go_tone_index{b, :} = find(stop_cue{b, 1}(:, 2) == 9);

                    if (size(go_tone_index{b, 1}, 1) > 1) == 1

                        fix_wait_duration = (stop_cue{b, 1}(go_tone_index{b, 1}(2, 1), 8) - 499985); % calculates when to print the wait duration
                        fix_wait_timestamp = (stop_cue{b, 1}(go_tone_index{b, 1}(2, 1), 1) - fix_wait_duration);
                        fix_row_post_index = find(stop_cue{b, 1}(:, 1) > fix_wait_timestamp);
                        fix_row_insert = fix_row_post_index(1, 1) - 1;
                        fix_new_row = zeros(1,size(data,2));
                        fix_new_row(1, 1) = fix_wait_timestamp;
                        fix_new_row(1, 2) = 8;
                        data_new = [data(1: (tone_stop_index(b, 1) + fix_row_insert), :); fix_new_row; data((tone_stop_index(b, 1) + fix_row_insert + 1) : end, :)];
                        data = data_new;
                        clear stop_cue;
                        clear go_tone_index;

                        tone_stop = data(:, 2) == 8;
                        tone_stop_index = find(tone_stop == 1);

                        %b = 1;
                        rerun = 1;
                    
                    end
                    
            stop_cue{b, :} = data(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by 8 event to 8 event) in each cell
            go_tone_index{b, :} = find(stop_cue{b, 1}(:, 2) == 9);
            
            trials_distractor_catch(b, :) = sum(stop_cue{b,:}(go_tone_index{b, 1}, 4) == 10);
            %stop_cue_times{b, :} = new_times(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :); % makes a cell array containing the timestamps for every trial (defined by 8 event to 8 event) in each cell

            trials_go(b, :) = sum((stop_cue{b,:}(:,2)) == 9); %returns logical values for whether the trial contained a go tone

            
            %trials_distance_mode(b, :) = mode(stop_cue{b, :}(:, 7));
                      
            trials_reward(b, :) = sum((stop_cue{b,:}(:,2)) == 2 | (stop_cue{b,:}(:,2)) == 12); %returns logical values for whether the trial contained a reward

            if trials_reward(b, :) > 0
                reward_index(b, 1) = find(stop_cue{b,:}(:,2) == 2 | (stop_cue{b,:}(:,2)) == 12);
            else
                reward_index(b, 1) = NaN;
            end
            
            trials_reward_slow(b, :) = sum((stop_cue{b,:}(:,2)) == 2);
            trials_reward_stop(b, :) = sum((stop_cue{b,:}(:,2)) == 12);
            
            trials_incomplete(b, :) = sum((stop_cue{b,:}(:,2)) == 10);
            index_incomplete{b,:} = find((stop_cue{b,:}(:,2)) == 10); %indexes the line of each incomplete within each trial

            trials_slowfail(b, :) = sum((stop_cue{b,:}(:,2)) == 11); 
            trials_overrun(b, :) = sum((stop_cue{b,:}(:,2)) == 11); 

            trials_slowdown(b, :) = sum(stop_cue{b,:}(:,2) == 77);

                trials_distractor_control(b, :) = sum(stop_cue{b,:}(go_tone_index{b, 1}, 4) == 20);
                trials_distractor_target(b, :) = sum(stop_cue{b,:}(go_tone_index{b, 1}, 4) == 22);
            trials_distractor_played(b, 1) = sum(stop_cue{b,:}(:,2) == 222);


                if trials_slowfail(b, :) > 0 & trials_incomplete(b, :) > 0 % a fix for a lost trial
                    trials_slowfail(b, :) = 0;
                    current_bug_2(b, :) = 1;
                else
                    current_bug_2(b, :) = 0;
                end

            trials_premature_slow(b, :) = sum((stop_cue{b,:}(:,2)) == 13);
                
                if trials_premature_slow(b, :) > 0 & trials_slowfail(b, :) > 0 % a fix for a lost trial
                    trials_slowfail(b, :) = 0;
                    current_bug(b, :) = 1;
                else
                    current_bug(b, :) = 0;
                end

           trials_cued(b, 1) = sum(stop_cue{b, :}(:, 4) == 20);
                if trials_cued(b, 1) == 0
                    trials_cued(b, 1) = sum(stop_cue{b, :}(:, 2) == 20);
                end

           trials_uncued(b, 1) = sum(stop_cue{b, :}(:, 4) == 22);


                   try
                   cue_index(b, 1) = find(stop_cue{b, :}(:, 2) == 20);
                   catch
                   cue_index(b, 1) = NaN;
                   end

             if floor(output.phase_check) == 77 | floor(output.phase_check) == 5 % decoy/distractor cue task

                   try
                   decoy_cue_index(b, 1) = find(stop_cue{b, :}(:, 2) == 222);
                   catch
                   decoy_cue_index(b, 1) = NaN;
                   end

            end

                movement_index{b, :} = find(stop_cue{b, 1}(:, 2) == 0); 


        if trials_reward(b, :) + trials_incomplete(b, :) + trials_slowfail(b, :) + trials_premature_slow(b, :) > 0
            trial_end_index(b, 1) = find(stop_cue{b,:}(:,2) == 2 | (stop_cue{b,:}(:,2)) == 12 | (stop_cue{b,:}(:,2)) == 11 | (stop_cue{b,:}(:,2)) == 10 | (stop_cue{b,:}(:,2)) == 13);
        else
            trial_end_index(b, 1) = NaN;
        end
       
      if floor(str2num(phase)) ~= 00 
          if trials_go(b, 1) == 1
           trials_block_number(b, 1) = stop_cue{b, :}(go_tone_index{b, :}(1, 1), 12);
           trials_block_number_cue(b, 1) = stop_cue{b, :}(go_tone_index{b, :}(1, 1), 4);
          else
           trials_block_number(b, 1) = NaN;
           trials_block_number_cue(b, 1) = NaN;
          end
      else
           trials_block_number(b, 1) = NaN;
           trials_block_number_cue(b, 1) = NaN;        
      end

%             if trials_reward(b, :) + trials_incomplete(b, :) + trials_slowfail(b, :) + trials_premature_slow(b, :) == 0 % fix for RW not printed
%                 pre_reward_num = stop_cue{b, 1}(1, 14);
%                 post_reward_num = stop_cue{b, 1}(end, 14);
%                 if post_reward_num - pre_reward_num == 1
%                     trials_reward(b, :) = 1;
%                     current_bug_3(b, :) = 1;
%                 else
%                     mystery_bug(b, :) = 1;
%                 end
%             else
%                 current_bug_3(b, :) = 0;
%                 mystery_bug(b, :) = 0;
%             end


            index_premature_slow{b,:} = find(stop_cue{b,:}(:,2) == 13); %indexes the line of each pre slow within each trial

            trials_short(b, :) = sum(stop_cue{b, :}(2, 7) == short);
            trials_medium(b, :) = sum(stop_cue{b, :}(2, 7) == medium);
            trials_long(b, :) = sum(stop_cue{b, :}(2, 7) == long);

            if ~isnan(trial_end_index(b, 1))
                maximum_distance_reached(b, 1) = max(stop_cue{b, :}(2:trial_end_index(b, 1), 6)); % in mm
                maximum_distance_reached(b, 2) = max(stop_cue{b, :}(2:trial_end_index(b, 1), 6)) / 10; % in cm
                maximum_distance_reached(b, 3) = find(stop_cue{b, :}(2:trial_end_index(b, 1), 6) == max(stop_cue{b, :}(2:trial_end_index(b, 1), 6)), 1);

            end

            if ~isempty(go_tone_index{b, 1}) & ~isnan(trial_end_index(b, 1))

                % clear resc_vect
                % resc_vect = [0:10:floor(maximum_distance_reached(b, 1))]';
                for t = 1:(size(resc_vect, 1) - 1)
                    rescaling_index{b, 1}{t, :} = find(stop_cue{b, :}(2:maximum_distance_reached(b, 3), 6) > resc_vect(t, 1) & stop_cue{b, :}(2:maximum_distance_reached(b, 3), 6) < resc_vect(t + 1, 1));
                    
                    if ~isempty(rescaling_index{b, 1}{t, :})
                        rescaled_velocities_smooth{b, 1}(t, 1) = mean(stop_cue{b, :}(rescaling_index{b, 1}{t, :}(1, 1):rescaling_index{b, 1}{t, :}(end, 1), 8)) / 10; % in cm/s
                        rescaled_velocities_raw{b, 1}(t, 1) = mean(stop_cue{b, :}(rescaling_index{b, 1}{t, :}(1, 1):rescaling_index{b, 1}{t, :}(end, 1), 5)) / 10; % in cm/s
                    
                    else
                        rescaled_velocities_smooth{b, 1}(t, 1) = 0;
                        rescaled_velocities_raw{b, 1}(t, 1) = 0;
                    end

                end

                if trials_short(b, :) == 1 & size(rescaled_velocities_smooth{b, 1}, 1) > ((short + cutoff) / 10)
                    rescaled_velocities_smooth{b, 1} =  rescaled_velocities_smooth{b, 1}(1:((short + cutoff) / 10), 1);
                    rescaled_velocities_raw{b, 1} =  rescaled_velocities_raw{b, 1}(1:((short + cutoff) / 10), 1);

                elseif trials_medium(b, :) == 1 & size(rescaled_velocities_smooth{b, 1}, 1) > ((medium + cutoff) / 10)
                    rescaled_velocities_smooth{b, 1} =  rescaled_velocities_smooth{b, 1}(1:((medium + cutoff) / 10), 1);
                    rescaled_velocities_raw{b, 1} =  rescaled_velocities_raw{b, 1}(1:((medium + cutoff) / 10), 1);

                elseif trials_long(b, :) == 1 & size(rescaled_velocities_smooth{b, 1}, 1) > ((long + cutoff) / 10)
                    rescaled_velocities_smooth{b, 1} =  rescaled_velocities_smooth{b, 1}(1:((long + cutoff) / 10), 1);
                    rescaled_velocities_raw{b, 1} =  rescaled_velocities_raw{b, 1}(1:((long + cutoff) / 10), 1);

                end  

            else
                   rescaled_velocities_smooth{b, 1} = [];
                   rescaled_velocities_raw{b, 1} = [];
            end   

            time_reset{b, :} = (stop_cue{b, 1}(:,1) - stop_cue{b, 1}(1,1) ) / 1000000; %resets the timestamps for each trial and converts it from msecs to secs
                
            %distancetrial{i,:}=(stop_cue{i, 1}(:,3)-stop_cue{i, 1}(1,3)); %returns distance elapsed during each event in a trial
            distancetrial{b,:} = (stop_cue{b, 1}(:, 6));

            %velocitytrial{i,:}=distancetrial{i,:}./time_reset{i,:}; %returns the velocity of each event in a trial
            velocitytrial{b,:} = (stop_cue{b, 1}(:, 5));

            %acelerationtrial{i, :} = diff(velocitytrial{i,:});
            accelerationtrial{b, :} = (diff(velocitytrial{b,:})) ./ (diff(time_reset{b,:})); %returns acceleration of each event

            %velocitythreshold{i,:} = find(velocitytrial{i,:} >= 3);
            %timearresend(i,:)=time_reset{i, 1}(end,1);

            index_reward{b,:} = find(stop_cue{b,:}(:,2) == 2 | stop_cue{b,:}(:,2) == 12); %indexes the line of each reward within each trial
            index_reward_slow{b,:} = find(stop_cue{b,:}(:,2) == 2); %indexes the line of each reward within each trial
            index_reward_stop{b,:} = find(stop_cue{b,:}(:,2) == 12); %indexes the line of each reward within each trial
            
            index_restart{b,:} = find(stop_cue{b,:}(:,2) == 10); %indexes the line of each reward within each trial
                if ~isempty(index_restart{b, :})
                    restart_distances(b, :) = stop_cue{b, :}(index_restart{b, :}(1,1), 6);
                    restart_times(b, :) = (stop_cue{b, :}(index_restart{b, :}(1,1), 1) - stop_cue{b, :}((index_restart{b, :}(1,1) - 1), 1));
                else
                    restart_distances(b, :) = NaN;
                    restart_times(b, :) = NaN;
                end
                
            %feddbackindex{i,:}=find(stop_cue{i,:}(:,2)>6);

            %timenev{b, :} = stop_cue_times{b, :}; %copies stop_cue_times cell array into a new cell array for some reason?
            
            target_distances(b, :) = stop_cue{b, 1}(2, 7);
%             
%             distance20_1{b,:} = find(stop_cue{b,:}(:,2) == 3 & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.2)); %indexes events within corresponding distance percentage (<20%)
%             distance40_1{b,:} = find(stop_cue{b,:}(:,2) == 4 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.2) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.4)); %indexes events within corresponding distance percentage (<40%)
%             distance60_1{b,:} = find(stop_cue{b,:}(:,2) == 5 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.4) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.6)); %indexes events within corresponding distance percentage (<60%)
%             distance80_1{b,:} = find(stop_cue{b,:}(:,2) == 6 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.6) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.8)); %indexes events within corresponding distance percentage (<80%)
%             distance100_1{b,:} = find(stop_cue{b,:}(:,2) == 7 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.8) & stop_cue{b,:}(:,6) < (target_distances(b, :)*1)); %indexes events within corresponding distance percentage (<100%)
%             distanceslow_1{b,:} = find(stop_cue{b,:}(:,2) == 77 & stop_cue{b,:}(:,6) > (target_distances(b, :)*1)); %indexes events within corresponding distance percentage (>100%)
%             
            distance20_1{b,:} = find(stop_cue{b,:}(:,2) == 3); %indexes events within corresponding distance percentage (<20%)
            distance40_1{b,:} = find(stop_cue{b,:}(:,2) == 4); %indexes events within corresponding distance percentage (<40%)

            distance60_1{b,:} = find(stop_cue{b,:}(:,2) == 5); %indexes events within corresponding distance percentage (<60%)
                if size(distance60_1{b,:}, 1) > 2
                    trials_T3(b, 1) = 1;
                else
                    trials_T3(b, 1) = 0;
                end            
            distance80_1{b,:} = find(stop_cue{b,:}(:,2) == 6); %indexes events within corresponding distance percentage (<80%)
            distance100_1{b,:} = find(stop_cue{b,:}(:,2) == 7); %indexes events within corresponding distance percentage (<100%)
                if size(distance100_1{b,:}, 1) > 2
                    trials_T5(b, 1) = 1;
                else
                    trials_T5(b, 1) = 0;
                end  
            distanceslow_1{b,:} = find(stop_cue{b,:}(:,2) == 77); %indexes events within corresponding distance percentage (>100%)
        


        if trials_go(b, :) > 0
            distance20{b,:} = find(stop_cue{b,:}(:,6) <= (target_distances(b, :)*0.2) & stop_cue{b,:}(:,6) ~= 0 & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<20%)
            distance40{b,:} = find(stop_cue{b,:}(:,6) > (target_distances(b, :)*0.2) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.4) & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<40%)
            distance60{b,:} = find(stop_cue{b,:}(:,6) > (target_distances(b, :)*0.4) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.6) & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<60%)
            distance80{b,:} = find(stop_cue{b,:}(:,6) > (target_distances(b, :)*0.6) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.8) & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<80%)
            distance100{b,:} = find(stop_cue{b,:}(:,6) > (target_distances(b, :)*0.8) & stop_cue{b,:}(:,6) < (target_distances(b, :)*1) & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<100%)
            distanceslow{b,:} = find(stop_cue{b,:}(:,6) > target_distances(b, :)); %indexes events within corresponding distance percentage (>100%)
        end   

         if floor(output.phase_check) == 4 | floor(output.phase_check) == 44 | floor(output.phase_check) == 7 | floor(output.phase_check) == 13 | floor(str2num(phase)) == 00  | floor(str2num(phase)) == 1  | floor(str2num(phase)) == 2  | floor(str2num(phase)) == 3 % if it isnt an opto session
                opto_sesh = false;

                trials_opto_control(b, :) = 1;
                trials_opto_target_1(b, :) = 0;

                index_opto_onoff_ctl{b,1} = NaN;
                index_opto_onoff_ctl{b,2} = NaN;
                opto_duration_ctl(b, :) = NaN;

                index_opto_onoff_1{b,1} = NaN;
                index_opto_onoff_1{b,2} = NaN;
                opto_duration_1(b, :) = NaN;

            end

            if floor(output.phase_check) == 77 | floor(output.phase_check) == 5 % decoy/distractor cue tasks
                opto_sesh = false;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 20);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 22);

                index_opto_onoff_ctl{b,1} = NaN;
                index_opto_onoff_ctl{b,2} = NaN;
                opto_duration_ctl(b, :) = NaN;

                index_opto_onoff_1{b,1} = NaN;
                index_opto_onoff_1{b,2} = NaN;
                opto_duration_1(b, :) = NaN;


                
            end




            if floor(output.phase_check) == 11
                opto_sesh = true;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 10);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 11);

                if (trials_opto_control(b, :) == 1) 
                    index_opto_onoff_ctl{b,1} = find(stop_cue{b,:}(:,2) == 100); 
                    index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 101);
                    if ~isempty(index_opto_onoff_ctl{b,2} & index_opto_onoff_ctl{b,1})
                    opto_duration_ctl(b, :) = (stop_cue{b,:}(index_opto_onoff_ctl{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1)) / 1000000; % opto duration in seconds           
                        
                        % if opto_duration_ctl(b, :) > 0.9899 & opto_duration_ctl(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_ctl(b, :) = NaN;
                        %      trials_opto_control_ctl(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_ctl(b, :) = NaN;
                    end
                else
                    index_opto_onoff_ctl{b,1} = NaN;
                    index_opto_onoff_ctl{b,2} = NaN;
                    opto_duration_ctl(b, :) = NaN;
                end

                
                if (trials_opto_target_1(b, :) == 1) 
                    index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 110); 
                    index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 111);
                    if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
                    opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds           
                        
                        % if opto_duration_1(b, :) > 0.9899 & opto_duration_1(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_1(b, :) = NaN;
                        %      trials_opto_target_1(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_1(b, :) = NaN;
                    end
                else
                    index_opto_onoff_1{b,1} = NaN;
                    index_opto_onoff_1{b,2} = NaN;
                    opto_duration_1(b, :) = NaN;
                end
                
            end

             if floor(output.phase_check) == 22 | floor(output.phase_check) == 88
                opto_sesh = true;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 10);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 22);

                if (trials_opto_control(b, :) == 1) 
                    index_opto_onoff_ctl{b,1} = find(stop_cue{b,:}(:,2) == 100); 
                    index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 101);
                    if ~isempty(index_opto_onoff_ctl{b,2} & index_opto_onoff_ctl{b,1})
                    opto_duration_ctl(b, :) = (stop_cue{b,:}(index_opto_onoff_ctl{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1)) / 1000000; % opto duration in seconds           
                    opto_time_on_ctl(b, 1) = stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1);
                    opto_time_on_ctl(b, 2) = opto_time_on_ctl(b, 1) + 1000000;
                    speed_ind_ctl{b, 1} = find(stop_cue{b,:}(:, 1) > opto_time_on_ctl(b, 2));
                    speed_ind_ctl{b, 2} = stop_cue{b,:}(index_opto_onoff_ctl{b,1}:speed_ind_ctl{b, 1}(1, 1), 5); % raw velocities
                    speed_ind_ctl{b, 3} = stop_cue{b,:}(index_opto_onoff_ctl{b,1}:speed_ind_ctl{b, 1}(1, 1), 8); % smoothed velocities

                    speed_comp_raw_ctl(b, 1) = speed_ind_ctl{b, 2}(1, 1) / 10; % in cm/s
                    speed_comp_raw_ctl(b, 2) = mean(speed_ind_ctl{b, 2}) / 10; % raw mean speed in cm/s
                    speed_comp_raw_ctl(b, 3) = (speed_comp_raw_ctl(b, 1) - speed_comp_raw_ctl(b, 2)) / speed_comp_raw_ctl(b, 1); 

                    speed_comp_smooth_ctl(b, 1) = speed_ind_ctl{b, 3}(1, 1) / 10; % in cm/s
                    speed_comp_smooth_ctl(b, 2) = mean(speed_ind_ctl{b, 3}) / 10; % raw mean speed in cm/s
                    speed_comp_smooth_ctl(b, 3) = (speed_comp_smooth_ctl(b, 1) - speed_comp_smooth_ctl(b, 2)) / speed_comp_smooth_ctl(b, 1); 
                 

                        % if opto_duration_ctl(b, :) > 0.9899 & opto_duration_ctl(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_ctl(b, :) = NaN;
                        %      trials_opto_control_ctl(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_ctl(b, :) = NaN;
                    end
                else
                    index_opto_onoff_ctl{b,1} = NaN;
                    index_opto_onoff_ctl{b,2} = NaN;
                    opto_duration_ctl(b, :) = NaN;

                    speed_comp_raw_ctl(b, 1) = NaN; 
                    speed_comp_raw_ctl(b, 2) = NaN; 
                    speed_comp_raw_ctl(b, 3) = NaN; 
                    speed_comp_smooth_ctl(b, 1) = NaN; 
                    speed_comp_smooth_ctl(b, 2) = NaN; 
                    speed_comp_smooth_ctl(b, 3) = NaN;
                  
                end

                
                if (trials_opto_target_1(b, :) == 1) 
                    index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 220); 
                    index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 221);
                    if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
                    opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds           
                    opto_time_on_1(b, 1) = stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1);
                    opto_time_on_1(b, 2) = opto_time_on_1(b, 1) + 1000000;
                    speed_ind_1{b, 1} = find(stop_cue{b,:}(:, 1) > opto_time_on_1(b, 2));
                    speed_ind_1{b, 2} = stop_cue{b,:}(index_opto_onoff_1{b,1}:speed_ind_1{b, 1}(1, 1), 5); % raw velocities
                    speed_ind_1{b, 3} = stop_cue{b,:}(index_opto_onoff_1{b,1}:speed_ind_1{b, 1}(1, 1), 8); % smoothed velocities

                    speed_comp_raw_1(b, 1) = speed_ind_1{b, 2}(1, 1) / 10; % in cm/s
                    speed_comp_raw_1(b, 2) = mean(speed_ind_1{b, 2}) / 10; % raw mean speed in cm/s
                    speed_comp_raw_1(b, 3) = (speed_comp_raw_1(b, 1) - speed_comp_raw_1(b, 2)) / speed_comp_raw_1(b, 1); 

                    speed_comp_smooth_1(b, 1) = speed_ind_1{b, 3}(1, 1) / 10; % in cm/s
                    speed_comp_smooth_1(b, 2) = mean(speed_ind_1{b, 3}) / 10; % raw mean speed in cm/s
                    speed_comp_smooth_1(b, 3) = (speed_comp_smooth_1(b, 1) - speed_comp_smooth_1(b, 2)) / speed_comp_smooth_1(b, 1); 

                        % if opto_duration_1(b, :) > 0.9899 & opto_duration_1(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_1(b, :) = NaN;
                        %      trials_opto_target_1(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_1(b, :) = NaN;
                    end
                else
                    index_opto_onoff_1{b,1} = NaN;
                    index_opto_onoff_1{b,2} = NaN;
                    opto_duration_1(b, :) = NaN;

                    speed_comp_raw_1(b, 1) = NaN; 
                    speed_comp_raw_1(b, 2) = NaN; 
                    speed_comp_raw_1(b, 3) = NaN; 
                    speed_comp_smooth_1(b, 1) = NaN; 
                    speed_comp_smooth_1(b, 2) = NaN; 
                    speed_comp_smooth_1(b, 3) = NaN; 

                end
                
            end



             if floor(output.phase_check) == 777 % 2022 opto session data
                opto_sesh = true;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 66);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 777);

                if (trials_opto_control(b, :) == 1) 
                        
                    index_opto_onoff_ctl{b,1} = find(stop_cue{b,:}(:,6) > (target_distances(b, :) * 0.4), 1); 

                    if ~isempty(index_opto_onoff_ctl{b,1})

                        if trials_incomplete(b, 1) == 1
                            index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 10);
                        elseif trials_premature_slow(b, 1) == 1
                             index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 13);  
                        else
                            index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,6) > target_distances(b, :), 1);
                        end
                    
                    end

                    if ~isempty(index_opto_onoff_ctl{b,2} & index_opto_onoff_ctl{b,1})
                    opto_duration_ctl(b, :) = (stop_cue{b,:}(index_opto_onoff_ctl{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1)) / 1000000; % opto duration in seconds           
                    opto_time_on_ctl(b, 1) = stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1);
                    opto_time_on_ctl(b, 2) = opto_time_on_ctl(b, 1) + 1000000;
                    speed_ind_ctl{b, 1} = find(stop_cue{b,:}(:, 1) > opto_time_on_ctl(b, 2));
                    speed_ind_ctl{b, 2} = stop_cue{b,:}(index_opto_onoff_ctl{b,1}:speed_ind_ctl{b, 1}(1, 1), 5); % raw velocities
                    speed_ind_ctl{b, 3} = stop_cue{b,:}(index_opto_onoff_ctl{b,1}:speed_ind_ctl{b, 1}(1, 1), 8); % smoothed velocities

                    speed_comp_raw_ctl(b, 1) = speed_ind_ctl{b, 2}(1, 1) / 10; % in cm/s
                    speed_comp_raw_ctl(b, 2) = mean(speed_ind_ctl{b, 2}) / 10; % raw mean speed in cm/s
                    speed_comp_raw_ctl(b, 3) = (speed_comp_raw_ctl(b, 1) - speed_comp_raw_ctl(b, 2)) / speed_comp_raw_ctl(b, 1); 

                    speed_comp_smooth_ctl(b, 1) = speed_ind_ctl{b, 3}(1, 1) / 10; % in cm/s
                    speed_comp_smooth_ctl(b, 2) = mean(speed_ind_ctl{b, 3}) / 10; % raw mean speed in cm/s
                    speed_comp_smooth_ctl(b, 3) = (speed_comp_smooth_ctl(b, 1) - speed_comp_smooth_ctl(b, 2)) / speed_comp_smooth_ctl(b, 1); 
                 

                        if opto_duration_ctl(b, :) < 0.001 %fix for when there is an immediate early slow and immediate restart
                             opto_duration_ctl(b, :) = NaN;
                             trials_opto_control(b, :) = 0;
                        end                    
                    
                    else
                    opto_duration_ctl(b, :) = NaN;
                    end
                else
                    index_opto_onoff_ctl{b,1} = NaN;
                    index_opto_onoff_ctl{b,2} = NaN;
                    opto_duration_ctl(b, :) = NaN;

                    speed_comp_raw_ctl(b, 1) = NaN; 
                    speed_comp_raw_ctl(b, 2) = NaN; 
                    speed_comp_raw_ctl(b, 3) = NaN; 
                    speed_comp_smooth_ctl(b, 1) = NaN; 
                    speed_comp_smooth_ctl(b, 2) = NaN; 
                    speed_comp_smooth_ctl(b, 3) = NaN;
                  
                end

                
                if (trials_opto_target_1(b, :) == 1) 
                    index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 777); 
                    index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 778);
                    if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
                    opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds           
                    opto_time_on_1(b, 1) = stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1);
                    opto_time_on_1(b, 2) = opto_time_on_1(b, 1) + 1000000;
                    speed_ind_1{b, 1} = find(stop_cue{b,:}(:, 1) > opto_time_on_1(b, 2));
                    speed_ind_1{b, 2} = stop_cue{b,:}(index_opto_onoff_1{b,1}:speed_ind_1{b, 1}(1, 1), 5); % raw velocities
                    speed_ind_1{b, 3} = stop_cue{b,:}(index_opto_onoff_1{b,1}:speed_ind_1{b, 1}(1, 1), 8); % smoothed velocities

                    speed_comp_raw_1(b, 1) = speed_ind_1{b, 2}(1, 1) / 10; % in cm/s
                    speed_comp_raw_1(b, 2) = mean(speed_ind_1{b, 2}) / 10; % raw mean speed in cm/s
                    speed_comp_raw_1(b, 3) = (speed_comp_raw_1(b, 1) - speed_comp_raw_1(b, 2)) / speed_comp_raw_1(b, 1); 

                    speed_comp_smooth_1(b, 1) = speed_ind_1{b, 3}(1, 1) / 10; % in cm/s
                    speed_comp_smooth_1(b, 2) = mean(speed_ind_1{b, 3}) / 10; % raw mean speed in cm/s
                    speed_comp_smooth_1(b, 3) = (speed_comp_smooth_1(b, 1) - speed_comp_smooth_1(b, 2)) / speed_comp_smooth_1(b, 1); 

                        % if opto_duration_1(b, :) > 0.9899 & opto_duration_1(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_1(b, :) = NaN;
                        %      trials_opto_target_1(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_1(b, :) = NaN;
                    end
                else
                    index_opto_onoff_1{b,1} = NaN;
                    index_opto_onoff_1{b,2} = NaN;
                    opto_duration_1(b, :) = NaN;

                    speed_comp_raw_1(b, 1) = NaN; 
                    speed_comp_raw_1(b, 2) = NaN; 
                    speed_comp_raw_1(b, 3) = NaN; 
                    speed_comp_smooth_1(b, 1) = NaN; 
                    speed_comp_smooth_1(b, 2) = NaN; 
                    speed_comp_smooth_1(b, 3) = NaN; 

                end
                
            end







             if floor(output.phase_check) == 33
                opto_sesh = true;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 10);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 33);

                if (trials_opto_control(b, :) == 1) 
                    index_opto_onoff_ctl{b,1} = find(stop_cue{b,:}(:,2) == 100); 
                    index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 101);
                    if ~isempty(index_opto_onoff_ctl{b,2} & index_opto_onoff_ctl{b,1})
                    opto_duration_ctl(b, :) = (stop_cue{b,:}(index_opto_onoff_ctl{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1)) / 1000000; % opto duration in seconds           
                        
                        if opto_duration_ctl(b, :) > 4.99 & opto_duration_ctl(b, :) < 5 % opto stim timed out before run started
                             opto_duration_ctl(b, :) = NaN;
                             trials_opto_control_ctl(b, :) = 0;
                             trials_opto_control_slow_start(b, :) = 1;
                        else
                             trials_opto_control_slow_start(b, :) = 0;                            
                        end                    
                    
                    else
                    opto_duration_ctl(b, :) = NaN;
                    end
                else
                    index_opto_onoff_ctl{b,1} = NaN;
                    index_opto_onoff_ctl{b,2} = NaN;
                    opto_duration_ctl(b, :) = NaN;
                    trials_opto_control_slow_start(b, :) = NaN;   

                end

                
                if (trials_opto_target_1(b, :) == 1) 
                    index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 330); 
                    index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 331);
                    if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
                    opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds           

                        if opto_duration_1(b, :) > 4.99 & opto_duration_1(b, :) < 5 % opto stim timed out before run started
                             opto_duration_1(b, :) = NaN;
                             trials_opto_target_1(b, :) = 0;
                             trials_opto_target_1_slow_start(b, :) = 1;
                        else
                             trials_opto_target_1_slow_start(b, :) = 0;                            
                        end  
                                            
                    else
                    opto_duration_1(b, :) = NaN;
                    end
                else
                    index_opto_onoff_1{b,1} = NaN;
                    index_opto_onoff_1{b,2} = NaN;
                    opto_duration_1(b, :) = NaN;
                    trials_opto_target_1_slow_start(b, :) = NaN;  

                end
                
            end 

%             if phase == '888'
%                 trials_opto_control(b, :) = sum(stop_cue{b,:}(1, 4) == 66);
%                 trials_opto_target_1(b, :) = sum(stop_cue{b,:}(1, 4) == 777);
%                 trials_opto_target_2(b, :) = sum(stop_cue{b,:}(1, 4) == 888);
%                 
%                 if (trials_opto_target_1(b, :) == 1) 
%                     index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 777); 
%                     index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 778);
%                     if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
%                     opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds
% 
%                     else
%                     opto_duration_1(b, :) = NaN;
%                     end
%                 else
%                     index_opto_onoff_1{b,1} = NaN;
%                     index_opto_onoff_1{b,2} = NaN;
%                     opto_duration_1(b, :) = NaN;
%                 end
% 
%                 if (trials_opto_target_2(b, :) == 1) 
%                     index_opto_onoff_2{b,1} = find(stop_cue{b,:}(:,2) == 888); 
%                     index_opto_onoff_2{b,2} = find(stop_cue{b,:}(:,2) == 889);
%                     if ~isempty(index_opto_onoff_2{b,2})
%                     opto_duration_2(b, :) = (stop_cue{b,:}(index_opto_onoff_2{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_2{b, 1}, 1)) / 1000000; % opto duration in seconds
%                     else
%                     opto_duration_2(b, :) = NaN;
%                     end
%                 else
%                     index_opto_onoff_2{b,1} = NaN;
%                     index_opto_onoff_2{b,2} = NaN;
%                     opto_duration_2(b, :) = NaN;
%                 end
%             end
% 
%             trials_mat_12_para_120(b, :) = sum(stop_cue{b,:}(:, 4) == 120);
%             trials_mat_12_para_150(b, :) = sum(stop_cue{b,:}(:, 4) == 150);
%             trials_mat_12_para_130(b, :) = sum(stop_cue{b,:}(:, 4) == 130);

            % trials_mat_13_para_25(b, :) = sum(stop_cue{b,:}(:, 4) == 0.25);
            % trials_mat_13_para_30(b, :) = sum(stop_cue{b,:}(:, 4) == 0.3);
            % trials_mat_13_para_35(b, :) = sum(stop_cue{b,:}(:, 4) == 0.35);
            
            licking_index{b, 1} = find(stop_cue{b,:}(:, 4) == 1);
            licking_timestamps{b, 1} = stop_cue{b,:}(licking_index{b, 1}(:, :), 1);

            low_vel_dist{b, 1} = find(stop_cue{b,:}(:, 5) > 145 & stop_cue{b,:}(:, 5) < 155);
                if ~isempty(index_reward{b, 1})
                    low_vel_dist{b, 4} = find(low_vel_dist{b, 1}(:, 1) < index_reward{b, 1});
                    low_vel_dist{b, 1} = low_vel_dist{b, 1}(low_vel_dist{b, 4} ,1);
                end
            low_vel_dist{b, 2} = stop_cue{b,:}(low_vel_dist{b, 1}(:, 1), 1);
            low_vel_dist{b, 3} = stop_cue{b,:}(low_vel_dist{b, 1}(:, 1), 6);
            low_vel_dist_sizes(b, 1) = size(low_vel_dist{b, 3}, 1);
            

            half_hour_trial(b, 1) = sum(stop_cue{b, 1}(1, 1) < half_hour_timestamp);

%             if size(distance100_1{b,:}, 1) > 20
%                 ind_1 = distance60_1{b, :}(1, 1);
%                 ind_2 = distance100_1{b, :}(end, 1);        
%                 mean_binned_velocity(b, :) = mean(stop_cue{b, 1}(ind_1:ind_2, 9)); %averages movement and "tone" stamps so error values of this set might be off
%             else
%                 mean_binned_velocity(b,:) = NaN;
%             end
        
%          if floor(output.phase) == 8
%            trials_cued(b, 1) = sum(stop_cue{b, :}(:, 4) == 20);
%            trials_uncued(b, 1) = sum(stop_cue{b, :}(:, 4) == 22);
%          elseif floor(output.phase) == 0
%            trials_cued(b, 1) = sum(stop_cue{b, :}(:, 2) == 20);
%                    if trials_cued(b, 1) > 0
%                    cue_index(b, 1) = find(stop_cue{b, :}(:, 2) == 20);
%                    else
%                    cue_index(b, 1) = 0;
%                    end
%           try
%            reward_index(b, :) = find(stop_cue{b,:}(:,2) == 2);
%           catch
%               reward_index(b, :) = NaN;
%           end
%            trials_uncued(b, 1) = sum(stop_cue{b, :}(:, 2) == 22);
%          if output.day == 03
%            timestamps_cueassc(b, 1) = stop_cue{b, :}(cue_index(b, 1), 1);
%            timestamps_cueassc(b, 2) = stop_cue{b, :}(reward_index(b, :), 1);
%            lickfreq_cueassc(b, 1) = sum(licking_timestamps{b, 1}(:,:) >= (timestamps_cueassc(b, 1) - 1200900) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 1)); %1200900 is the time b/w cue and rw
%            lickfreq_cueassc(b, 2) = sum(licking_timestamps{b, 1}(:,:) >= timestamps_cueassc(b, 1) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 2)); 
%          else
%             lickfreq_cueassc(b, 1) = sum(licking_index{b, 1}(:, 1) < reward_index(b, :));
%             lickfreq_cueassc(b, 2) = sum(licking_index{b, 1}(:, 1) > reward_index(b, :));
%             
%          end
%          else
%             trials_cued(b, 1) = trials_go(b, 1);
%             trials_uncued(b, 1) = 0;
%          end

         % licking calculation
%             pre_rw_licks(b, 1) = sum(licking_index{b, 1}(:, 1) < reward_index(b, :));
%             post_rw_licks(b, 1) = sum(licking_index{b, 1}(:, 1) > reward_index(b, :));

  
    if floor(output.phase_check) == 13

        if reward_index(b, :) > 0
           
           timestamps_cueassc(b, 1) = stop_cue{b, :}(distanceslow{b, 1}(1, 1), 1); % different from code below
           timestamps_cueassc(b, 2) = stop_cue{b, :}(reward_index(b, :), 1);

           pericue_index{b, 1} = find(stop_cue{b, :}(:, 1) >= (timestamps_cueassc(b, 1) - 1200900) & stop_cue{b, :}(:, 1) < timestamps_cueassc(b, 1)); % index precue lines
           pericue_index{b, 1} = intersect(pericue_index{b, 1}, movement_index{b, 1});
           pericue_index{b, 2} = find(stop_cue{b, :}(:, 1) >= timestamps_cueassc(b, 1) & stop_cue{b, :}(:, 1) < timestamps_cueassc(b, 2)); % index postcue lines   
           pericue_index{b, 2} = intersect(pericue_index{b, 2}, movement_index{b, 1});

           lickfreq_cueassc(b, 1) = sum(licking_timestamps{b, 1}(:,:) >= (timestamps_cueassc(b, 1) - 1200900) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 1)); %1200900 is the time b/w cue and rw
           lickfreq_cueassc(b, 2) = sum(licking_timestamps{b, 1}(:,:) >= timestamps_cueassc(b, 1) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 2)); 

           vel2_cueassc(b, 1) = mean(stop_cue{b, :}(pericue_index{b, 1}, 9)) / 10; % different from code below
           vel2_cueassc(b, 2) = mean(stop_cue{b, :}(pericue_index{b, 2}, 9)) / 10; % different from code below

           rawVel_cueassc(b, 1) = mean(stop_cue{b, :}(pericue_index{b, 1}, 5)) / 10;
           rawVel_cueassc(b, 2) = mean(stop_cue{b, :}(pericue_index{b, 2}, 5)) / 10;
         
         %   rawVel_cueassc(b, 1) = ((stop_cue{b, :}(pericue_index{b, 1}(end, 1), 5) - stop_cue{b, :}(pericue_index{b, 1}(1, 1), 5)) / 10) / ((stop_cue{b, :}(pericue_index{b, 1}(end, 1), 1) - stop_cue{b, :}(pericue_index{b, 1}(1, 1), 1)) / 1000000); % calculating vel
         %         if isnan(rawVel_cueassc(b, 1))
         %             rawVel_cueassc(b, 1) = 0;
         %         end
         % try  
         %   rawVel_cueassc(b, 2) = ((stop_cue{b, :}(pericue_index{b, 2}(end, 1), 5) - stop_cue{b, :}(pericue_index{b, 2}(1, 1), 5)) /10) / ((stop_cue{b, :}(pericue_index{b, 2}(end, 1), 1) - stop_cue{b, :}(pericue_index{b, 2}(1, 1), 1)) / 1000000);
         % catch
         %   rawVel_cueassc(b, 2) = 0;
         % end

        end

    else
        if reward_index(b, :) > 0 & cue_index(b, 1) > 0
           
           timestamps_cueassc(b, 1) = stop_cue{b, :}(cue_index(b, 1), 1);
           timestamps_cueassc(b, 2) = stop_cue{b, :}(reward_index(b, :), 1);

           pericue_index{b, 1} = find(stop_cue{b, :}(:, 1) >= (timestamps_cueassc(b, 1) - 1200900) & stop_cue{b, :}(:, 1) < timestamps_cueassc(b, 1)); % index precue lines
           pericue_index{b, 1} = intersect(pericue_index{b, 1}, movement_index{b, 1});
           pericue_index{b, 2} = find(stop_cue{b, :}(:, 1) >= timestamps_cueassc(b, 1) & stop_cue{b, :}(:, 1) < timestamps_cueassc(b, 2)); % index postcue lines   
           pericue_index{b, 2} = intersect(pericue_index{b, 2}, movement_index{b, 1});

           lickfreq_cueassc(b, 1) = sum(licking_timestamps{b, 1}(:,:) >= (timestamps_cueassc(b, 1) - 1200900) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 1)); %1200900 is the time b/w cue and rw
           lickfreq_cueassc(b, 2) = sum(licking_timestamps{b, 1}(:,:) >= timestamps_cueassc(b, 1) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 2)); 

           vel2_cueassc(b, 1) = mean(stop_cue{b, :}(pericue_index{b, 1}, 8)) / 10;
           vel2_cueassc(b, 2) = mean(stop_cue{b, :}(pericue_index{b, 2}, 8)) / 10;

           rawVel_cueassc(b, 1) = mean(stop_cue{b, :}(pericue_index{b, 1}, 5)) / 10;
           rawVel_cueassc(b, 2) = mean(stop_cue{b, :}(pericue_index{b, 2}, 5)) / 10;
         
         %   rawVel_cueassc(b, 1) = ((stop_cue{b, :}(pericue_index{b, 1}(end, 1), 5) - stop_cue{b, :}(pericue_index{b, 1}(1, 1), 5)) / 10) / ((stop_cue{b, :}(pericue_index{b, 1}(end, 1), 1) - stop_cue{b, :}(pericue_index{b, 1}(1, 1), 1)) / 1000000); % calculating vel
         %         if isnan(rawVel_cueassc(b, 1))
         %             rawVel_cueassc(b, 1) = 0;
         %         end
         % try  
         %   rawVel_cueassc(b, 2) = ((stop_cue{b, :}(pericue_index{b, 2}(end, 1), 5) - stop_cue{b, :}(pericue_index{b, 2}(1, 1), 5)) /10) / ((stop_cue{b, :}(pericue_index{b, 2}(end, 1), 1) - stop_cue{b, :}(pericue_index{b, 2}(1, 1), 1)) / 1000000);
         % catch
         %   rawVel_cueassc(b, 2) = 0;
         % end

        end
    end
      
%                 if trials_go(b, :) == 1
%                     raw_trials{t, :} = data(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :);
%                     t = t + 1;
%                 end
        

    end

   if exist('rerun') %reruns the stop_cue loop if one of the trials did not print a stop event
                            clear stop_cue;
                        clear go_tone_index;
t = 1;

    for b = 1:(length (tone_stop_index) - 1) 
                
        stop_cue{b, :} = data(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by 8 event to 8 event) in each cell
               
            % Fix to make sure two trials don't get combined if WN doesnt print
                go_tone_index{b, :} = find(stop_cue{b, 1}(:, 2) == 9);

                    if (size(go_tone_index{b, 1}, 1) > 1) == 1

                        fix_wait_duration = (stop_cue{b, 1}(go_tone_index{b, 1}(2, 1), 8) - 499985); % calculates when to print the wait duration
                        fix_wait_timestamp = (stop_cue{b, 1}(go_tone_index{b, 1}(2, 1), 1) - fix_wait_duration);
                        fix_row_post_index = find(stop_cue{b, 1}(:, 1) > fix_wait_timestamp);
                        fix_row_insert = fix_row_post_index(1, 1) - 1;
                        fix_new_row = zeros(1,size(data,2));
                        fix_new_row(1, 1) = fix_wait_timestamp;
                        fix_new_row(1, 2) = 8;
                        data_new = [data(1: (tone_stop_index(b, 1) + fix_row_insert), :); fix_new_row; data((tone_stop_index(b, 1) + fix_row_insert + 1) : end, :)];
                        data = data_new;
                        clear stop_cue;
                        clear go_tone_index;

                        tone_stop = data(:, 2) == 8;
                        tone_stop_index = find(tone_stop == 1);

                        %b = 1;
                        rerun = 1;
                    
                    end
                    
            stop_cue{b, :} = data(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by 8 event to 8 event) in each cell
            go_tone_index{b, :} = find(stop_cue{b, 1}(:, 2) == 9);
                        
            %stop_cue_times{b, :} = new_times(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :); % makes a cell array containing the timestamps for every trial (defined by 8 event to 8 event) in each cell

            trials_go(b, :) = sum((stop_cue{b,:}(:,2)) == 9); %returns logical values for whether the trial contained a go tone

             trials_distractor_catch(b, :) = sum(stop_cue{b,:}(go_tone_index{b, 1}, 4) == 10);

            %trials_distance_mode(b, :) = mode(stop_cue{b, :}(:, 7));
                      
            trials_reward(b, :) = sum((stop_cue{b,:}(:,2)) == 2 | (stop_cue{b,:}(:,2)) == 12); %returns logical values for whether the trial contained a reward

            if trials_reward(b, :) > 0
                reward_index(b, 1) = find(stop_cue{b,:}(:,2) == 2 | (stop_cue{b,:}(:,2)) == 12);
            else
                reward_index(b, 1) = NaN;
            end
            
            trials_reward_slow(b, :) = sum((stop_cue{b,:}(:,2)) == 2);
            trials_reward_stop(b, :) = sum((stop_cue{b,:}(:,2)) == 12);
            
            trials_incomplete(b, :) = sum((stop_cue{b,:}(:,2)) == 10);
            index_incomplete{b,:} = find((stop_cue{b,:}(:,2)) == 10); %indexes the line of each incomplete within each trial

            trials_slowfail(b, :) = sum((stop_cue{b,:}(:,2)) == 11); 
            trials_overrun(b, :) = sum((stop_cue{b,:}(:,2)) == 11); 

            trials_slowdown(b, :) = sum(stop_cue{b,:}(:,2) == 77);

                trials_distractor_control(b, :) = sum(stop_cue{b,:}(go_tone_index{b, 1}, 4) == 20);
                trials_distractor_target(b, :) = sum(stop_cue{b,:}(go_tone_index{b, 1}, 4) == 22);
            trials_distractor_played(b, 1) = sum(stop_cue{b,:}(:,2) == 222);

                if trials_slowfail(b, :) > 0 & trials_incomplete(b, :) > 0 % a fix for a lost trial
                    trials_slowfail(b, :) = 0;
                    current_bug_2(b, :) = 1;
                else
                    current_bug_2(b, :) = 0;
                end

            trials_premature_slow(b, :) = sum((stop_cue{b,:}(:,2)) == 13);
                
                if trials_premature_slow(b, :) > 0 & trials_slowfail(b, :) > 0 % a fix for a lost trial
                    trials_slowfail(b, :) = 0;
                    current_bug(b, :) = 1;
                else
                    current_bug(b, :) = 0;
                end

           trials_cued(b, 1) = sum(stop_cue{b, :}(:, 4) == 20);
                if trials_cued(b, 1) == 0
                    trials_cued(b, 1) = sum(stop_cue{b, :}(:, 2) == 20);
                end

           trials_uncued(b, 1) = sum(stop_cue{b, :}(:, 4) == 22);


                   try
                   cue_index(b, 1) = find(stop_cue{b, :}(:, 2) == 20);
                   catch
                   cue_index(b, 1) = NaN;
                   end

             if floor(output.phase_check) == 77 | floor(output.phase_check) == 5 % decoy/distractor cue task

                   try
                   decoy_cue_index(b, 1) = find(stop_cue{b, :}(:, 2) == 222);
                   catch
                   decoy_cue_index(b, 1) = NaN;
                   end

            end

                movement_index{b, :} = find(stop_cue{b, 1}(:, 2) == 0); 


        if trials_reward(b, :) + trials_incomplete(b, :) + trials_slowfail(b, :) + trials_premature_slow(b, :) > 0
            trial_end_index(b, 1) = find(stop_cue{b,:}(:,2) == 2 | (stop_cue{b,:}(:,2)) == 12 | (stop_cue{b,:}(:,2)) == 11 | (stop_cue{b,:}(:,2)) == 10 | (stop_cue{b,:}(:,2)) == 13);
        else
            trial_end_index(b, 1) = NaN;
        end
       
      if floor(str2num(phase)) ~= 00 
          if trials_go(b, 1) == 1
           trials_block_number(b, 1) = stop_cue{b, :}(go_tone_index{b, :}(1, 1), 12);
           trials_block_number_cue(b, 1) = stop_cue{b, :}(go_tone_index{b, :}(1, 1), 4);
          else
           trials_block_number(b, 1) = NaN;
           trials_block_number_cue(b, 1) = NaN;
          end
      else
           trials_block_number(b, 1) = NaN;
           trials_block_number_cue(b, 1) = NaN;        
      end

%             if trials_reward(b, :) + trials_incomplete(b, :) + trials_slowfail(b, :) + trials_premature_slow(b, :) == 0 % fix for RW not printed
%                 pre_reward_num = stop_cue{b, 1}(1, 14);
%                 post_reward_num = stop_cue{b, 1}(end, 14);
%                 if post_reward_num - pre_reward_num == 1
%                     trials_reward(b, :) = 1;
%                     current_bug_3(b, :) = 1;
%                 else
%                     mystery_bug(b, :) = 1;
%                 end
%             else
%                 current_bug_3(b, :) = 0;
%                 mystery_bug(b, :) = 0;
%             end


            index_premature_slow{b,:} = find(stop_cue{b,:}(:,2) == 13); %indexes the line of each pre slow within each trial

            trials_short(b, :) = sum(stop_cue{b, :}(2, 7) == short);
            trials_medium(b, :) = sum(stop_cue{b, :}(2, 7) == medium);
            trials_long(b, :) = sum(stop_cue{b, :}(2, 7) == long);

            if ~isnan(trial_end_index(b, 1))
                maximum_distance_reached(b, 1) = max(stop_cue{b, :}(2:trial_end_index(b, 1), 6)); % in mm
                maximum_distance_reached(b, 2) = max(stop_cue{b, :}(2:trial_end_index(b, 1), 6)) / 10; % in cm
                maximum_distance_reached(b, 3) = find(stop_cue{b, :}(2:trial_end_index(b, 1), 6) == max(stop_cue{b, :}(2:trial_end_index(b, 1), 6)), 1);
                
            end

            if ~isempty(go_tone_index{b, 1}) & ~isnan(trial_end_index(b, 1))

                % clear resc_vect
                % resc_vect = [0:10:floor(maximum_distance_reached(b, 1))]';
                for t = 1:(size(resc_vect, 1) - 1)
                    rescaling_index{b, 1}{t, :} = find(stop_cue{b, :}(2:maximum_distance_reached(b, 3), 6) > resc_vect(t, 1) & stop_cue{b, :}(2:maximum_distance_reached(b, 3), 6) < resc_vect(t + 1, 1));
                    
                    if ~isempty(rescaling_index{b, 1}{t, :})
                        rescaled_velocities_smooth{b, 1}(t, 1) = mean(stop_cue{b, :}(rescaling_index{b, 1}{t, :}(1, 1):rescaling_index{b, 1}{t, :}(end, 1), 8)) / 10; % in cm/s
                        rescaled_velocities_raw{b, 1}(t, 1) = mean(stop_cue{b, :}(rescaling_index{b, 1}{t, :}(1, 1):rescaling_index{b, 1}{t, :}(end, 1), 5)) / 10; % in cm/s
                    
                    else
                        rescaled_velocities_smooth{b, 1}(t, 1) = 0;
                        rescaled_velocities_raw{b, 1}(t, 1) = 0;
                    end

                end

                if trials_short(b, :) == 1 & size(rescaled_velocities_smooth{b, 1}, 1) > ((short + cutoff) / 10)
                    rescaled_velocities_smooth{b, 1} =  rescaled_velocities_smooth{b, 1}(1:((short + cutoff) / 10), 1);
                    rescaled_velocities_raw{b, 1} =  rescaled_velocities_raw{b, 1}(1:((short + cutoff) / 10), 1);

                elseif trials_medium(b, :) == 1 & size(rescaled_velocities_smooth{b, 1}, 1) > ((medium + cutoff) / 10)
                    rescaled_velocities_smooth{b, 1} =  rescaled_velocities_smooth{b, 1}(1:((medium + cutoff) / 10), 1);
                    rescaled_velocities_raw{b, 1} =  rescaled_velocities_raw{b, 1}(1:((medium + cutoff) / 10), 1);

                elseif trials_long(b, :) == 1 & size(rescaled_velocities_smooth{b, 1}, 1) > ((long + cutoff) / 10)
                    rescaled_velocities_smooth{b, 1} =  rescaled_velocities_smooth{b, 1}(1:((long + cutoff) / 10), 1);
                    rescaled_velocities_raw{b, 1} =  rescaled_velocities_raw{b, 1}(1:((long + cutoff) / 10), 1);

                end  

            else
                   rescaled_velocities_smooth{b, 1} = [];
                   rescaled_velocities_raw{b, 1} = [];
            end   

            time_reset{b, :} = (stop_cue{b, 1}(:,1) - stop_cue{b, 1}(1,1) ) / 1000000; %resets the timestamps for each trial and converts it from msecs to secs
                
            %distancetrial{i,:}=(stop_cue{i, 1}(:,3)-stop_cue{i, 1}(1,3)); %returns distance elapsed during each event in a trial
            distancetrial{b,:} = (stop_cue{b, 1}(:, 6));

            %velocitytrial{i,:}=distancetrial{i,:}./time_reset{i,:}; %returns the velocity of each event in a trial
            velocitytrial{b,:} = (stop_cue{b, 1}(:, 5));

            %acelerationtrial{i, :} = diff(velocitytrial{i,:});
            accelerationtrial{b, :} = (diff(velocitytrial{b,:})) ./ (diff(time_reset{b,:})); %returns acceleration of each event

            %velocitythreshold{i,:} = find(velocitytrial{i,:} >= 3);
            %timearresend(i,:)=time_reset{i, 1}(end,1);

            index_reward{b,:} = find(stop_cue{b,:}(:,2) == 2 | stop_cue{b,:}(:,2) == 12); %indexes the line of each reward within each trial
            index_reward_slow{b,:} = find(stop_cue{b,:}(:,2) == 2); %indexes the line of each reward within each trial
            index_reward_stop{b,:} = find(stop_cue{b,:}(:,2) == 12); %indexes the line of each reward within each trial
            
            index_restart{b,:} = find(stop_cue{b,:}(:,2) == 10); %indexes the line of each reward within each trial
                if ~isempty(index_restart{b, :})
                    restart_distances(b, :) = stop_cue{b, :}(index_restart{b, :}(1,1), 6);
                    restart_times(b, :) = (stop_cue{b, :}(index_restart{b, :}(1,1), 1) - stop_cue{b, :}((index_restart{b, :}(1,1) - 1), 1));
                else
                    restart_distances(b, :) = NaN;
                    restart_times(b, :) = NaN;
                end
                
            %feddbackindex{i,:}=find(stop_cue{i,:}(:,2)>6);

            %timenev{b, :} = stop_cue_times{b, :}; %copies stop_cue_times cell array into a new cell array for some reason?
            
            target_distances(b, :) = stop_cue{b, 1}(2, 7);
%             
%             distance20_1{b,:} = find(stop_cue{b,:}(:,2) == 3 & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.2)); %indexes events within corresponding distance percentage (<20%)
%             distance40_1{b,:} = find(stop_cue{b,:}(:,2) == 4 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.2) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.4)); %indexes events within corresponding distance percentage (<40%)
%             distance60_1{b,:} = find(stop_cue{b,:}(:,2) == 5 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.4) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.6)); %indexes events within corresponding distance percentage (<60%)
%             distance80_1{b,:} = find(stop_cue{b,:}(:,2) == 6 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.6) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.8)); %indexes events within corresponding distance percentage (<80%)
%             distance100_1{b,:} = find(stop_cue{b,:}(:,2) == 7 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.8) & stop_cue{b,:}(:,6) < (target_distances(b, :)*1)); %indexes events within corresponding distance percentage (<100%)
%             distanceslow_1{b,:} = find(stop_cue{b,:}(:,2) == 77 & stop_cue{b,:}(:,6) > (target_distances(b, :)*1)); %indexes events within corresponding distance percentage (>100%)
%             
            distance20_1{b,:} = find(stop_cue{b,:}(:,2) == 3); %indexes events within corresponding distance percentage (<20%)
            distance40_1{b,:} = find(stop_cue{b,:}(:,2) == 4); %indexes events within corresponding distance percentage (<40%)

            distance60_1{b,:} = find(stop_cue{b,:}(:,2) == 5); %indexes events within corresponding distance percentage (<60%)
                if size(distance60_1{b,:}, 1) > 2
                    trials_T3(b, 1) = 1;
                else
                    trials_T3(b, 1) = 0;
                end            
            distance80_1{b,:} = find(stop_cue{b,:}(:,2) == 6); %indexes events within corresponding distance percentage (<80%)
            distance100_1{b,:} = find(stop_cue{b,:}(:,2) == 7); %indexes events within corresponding distance percentage (<100%)
                if size(distance100_1{b,:}, 1) > 2
                    trials_T5(b, 1) = 1;
                else
                    trials_T5(b, 1) = 0;
                end  
            distanceslow_1{b,:} = find(stop_cue{b,:}(:,2) == 77); %indexes events within corresponding distance percentage (>100%)
        


        if trials_go(b, :) > 0
            distance20{b,:} = find(stop_cue{b,:}(:,6) <= (target_distances(b, :)*0.2) & stop_cue{b,:}(:,6) ~= 0 & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<20%)
            distance40{b,:} = find(stop_cue{b,:}(:,6) > (target_distances(b, :)*0.2) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.4) & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<40%)
            distance60{b,:} = find(stop_cue{b,:}(:,6) > (target_distances(b, :)*0.4) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.6) & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<60%)
            distance80{b,:} = find(stop_cue{b,:}(:,6) > (target_distances(b, :)*0.6) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.8) & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<80%)
            distance100{b,:} = find(stop_cue{b,:}(:,6) > (target_distances(b, :)*0.8) & stop_cue{b,:}(:,6) < (target_distances(b, :)*1) & stop_cue{b, :}(:, 2) == 0); %indexes events within corresponding distance percentage (<100%)
            distanceslow{b,:} = find(stop_cue{b,:}(:,6) > target_distances(b, :)); %indexes events within corresponding distance percentage (>100%)
        end   

         if floor(output.phase_check) == 4 | floor(output.phase_check) == 44 | floor(output.phase_check) == 7 | floor(output.phase_check) == 13 | floor(str2num(phase)) == 00  | floor(str2num(phase)) == 1  | floor(str2num(phase)) == 2  | floor(str2num(phase)) == 3 % if it isnt an opto session
                opto_sesh = false;

                trials_opto_control(b, :) = 1;
                trials_opto_target_1(b, :) = 0;

                index_opto_onoff_ctl{b,1} = NaN;
                index_opto_onoff_ctl{b,2} = NaN;
                opto_duration_ctl(b, :) = NaN;

                index_opto_onoff_1{b,1} = NaN;
                index_opto_onoff_1{b,2} = NaN;
                opto_duration_1(b, :) = NaN;

         end
  

           if floor(output.phase_check) == 77 | floor(output.phase_check) == 5 % not opto session but still with two trial types
                opto_sesh = false;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 20);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 22);

                index_opto_onoff_ctl{b,1} = NaN;
                index_opto_onoff_ctl{b,2} = NaN;
                opto_duration_ctl(b, :) = NaN;

                index_opto_onoff_1{b,1} = NaN;
                index_opto_onoff_1{b,2} = NaN;
                opto_duration_1(b, :) = NaN;


                
            end




            if floor(output.phase_check) == 11
                opto_sesh = true;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 10);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 11);

                if (trials_opto_control(b, :) == 1) 
                    index_opto_onoff_ctl{b,1} = find(stop_cue{b,:}(:,2) == 100); 
                    index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 101);
                    if ~isempty(index_opto_onoff_ctl{b,2} & index_opto_onoff_ctl{b,1})
                    opto_duration_ctl(b, :) = (stop_cue{b,:}(index_opto_onoff_ctl{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1)) / 1000000; % opto duration in seconds           
                        
                        % if opto_duration_ctl(b, :) > 0.9899 & opto_duration_ctl(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_ctl(b, :) = NaN;
                        %      trials_opto_control_ctl(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_ctl(b, :) = NaN;
                    end
                else
                    index_opto_onoff_ctl{b,1} = NaN;
                    index_opto_onoff_ctl{b,2} = NaN;
                    opto_duration_ctl(b, :) = NaN;
                end

                
                if (trials_opto_target_1(b, :) == 1) 
                    index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 110); 
                    index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 111);
                    if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
                    opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds           
                        
                        % if opto_duration_1(b, :) > 0.9899 & opto_duration_1(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_1(b, :) = NaN;
                        %      trials_opto_target_1(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_1(b, :) = NaN;
                    end
                else
                    index_opto_onoff_1{b,1} = NaN;
                    index_opto_onoff_1{b,2} = NaN;
                    opto_duration_1(b, :) = NaN;
                end
                
            end

             if floor(output.phase_check) == 22 | floor(output.phase_check) == 88
                opto_sesh = true;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 10);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 22);

                if (trials_opto_control(b, :) == 1) 
                    index_opto_onoff_ctl{b,1} = find(stop_cue{b,:}(:,2) == 100); 
                    index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 101);
                    if ~isempty(index_opto_onoff_ctl{b,2} & index_opto_onoff_ctl{b,1})
                    opto_duration_ctl(b, :) = (stop_cue{b,:}(index_opto_onoff_ctl{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1)) / 1000000; % opto duration in seconds           
                    opto_time_on_ctl(b, 1) = stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1);
                    opto_time_on_ctl(b, 2) = opto_time_on_ctl(b, 1) + 1000000;
                    speed_ind_ctl{b, 1} = find(stop_cue{b,:}(:, 1) > opto_time_on_ctl(b, 2));
                    speed_ind_ctl{b, 2} = stop_cue{b,:}(index_opto_onoff_ctl{b,1}:speed_ind_ctl{b, 1}(1, 1), 5); % raw velocities
                    speed_ind_ctl{b, 3} = stop_cue{b,:}(index_opto_onoff_ctl{b,1}:speed_ind_ctl{b, 1}(1, 1), 8); % smoothed velocities

                    speed_comp_raw_ctl(b, 1) = speed_ind_ctl{b, 2}(1, 1) / 10; % in cm/s
                    speed_comp_raw_ctl(b, 2) = mean(speed_ind_ctl{b, 2}) / 10; % raw mean speed in cm/s
                    speed_comp_raw_ctl(b, 3) = (speed_comp_raw_ctl(b, 1) - speed_comp_raw_ctl(b, 2)) / speed_comp_raw_ctl(b, 1); 

                    speed_comp_smooth_ctl(b, 1) = speed_ind_ctl{b, 3}(1, 1) / 10; % in cm/s
                    speed_comp_smooth_ctl(b, 2) = mean(speed_ind_ctl{b, 3}) / 10; % raw mean speed in cm/s
                    speed_comp_smooth_ctl(b, 3) = (speed_comp_smooth_ctl(b, 1) - speed_comp_smooth_ctl(b, 2)) / speed_comp_smooth_ctl(b, 1); 
                 

                        % if opto_duration_ctl(b, :) > 0.9899 & opto_duration_ctl(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_ctl(b, :) = NaN;
                        %      trials_opto_control_ctl(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_ctl(b, :) = NaN;
                    end
                else
                    index_opto_onoff_ctl{b,1} = NaN;
                    index_opto_onoff_ctl{b,2} = NaN;
                    opto_duration_ctl(b, :) = NaN;

                    speed_comp_raw_ctl(b, 1) = NaN; 
                    speed_comp_raw_ctl(b, 2) = NaN; 
                    speed_comp_raw_ctl(b, 3) = NaN; 
                    speed_comp_smooth_ctl(b, 1) = NaN; 
                    speed_comp_smooth_ctl(b, 2) = NaN; 
                    speed_comp_smooth_ctl(b, 3) = NaN;
                  
                end

                
                if (trials_opto_target_1(b, :) == 1) 
                    index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 220); 
                    index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 221);
                    if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
                    opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds           
                    opto_time_on_1(b, 1) = stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1);
                    opto_time_on_1(b, 2) = opto_time_on_1(b, 1) + 1000000;
                    speed_ind_1{b, 1} = find(stop_cue{b,:}(:, 1) > opto_time_on_1(b, 2));
                    speed_ind_1{b, 2} = stop_cue{b,:}(index_opto_onoff_1{b,1}:speed_ind_1{b, 1}(1, 1), 5); % raw velocities
                    speed_ind_1{b, 3} = stop_cue{b,:}(index_opto_onoff_1{b,1}:speed_ind_1{b, 1}(1, 1), 8); % smoothed velocities

                    speed_comp_raw_1(b, 1) = speed_ind_1{b, 2}(1, 1) / 10; % in cm/s
                    speed_comp_raw_1(b, 2) = mean(speed_ind_1{b, 2}) / 10; % raw mean speed in cm/s
                    speed_comp_raw_1(b, 3) = (speed_comp_raw_1(b, 1) - speed_comp_raw_1(b, 2)) / speed_comp_raw_1(b, 1); 

                    speed_comp_smooth_1(b, 1) = speed_ind_1{b, 3}(1, 1) / 10; % in cm/s
                    speed_comp_smooth_1(b, 2) = mean(speed_ind_1{b, 3}) / 10; % raw mean speed in cm/s
                    speed_comp_smooth_1(b, 3) = (speed_comp_smooth_1(b, 1) - speed_comp_smooth_1(b, 2)) / speed_comp_smooth_1(b, 1); 

                        % if opto_duration_1(b, :) > 0.9899 & opto_duration_1(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_1(b, :) = NaN;
                        %      trials_opto_target_1(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_1(b, :) = NaN;
                    end
                else
                    index_opto_onoff_1{b,1} = NaN;
                    index_opto_onoff_1{b,2} = NaN;
                    opto_duration_1(b, :) = NaN;

                    speed_comp_raw_1(b, 1) = NaN; 
                    speed_comp_raw_1(b, 2) = NaN; 
                    speed_comp_raw_1(b, 3) = NaN; 
                    speed_comp_smooth_1(b, 1) = NaN; 
                    speed_comp_smooth_1(b, 2) = NaN; 
                    speed_comp_smooth_1(b, 3) = NaN; 

                end
                
            end



             if floor(output.phase_check) == 777 % 2022 opto session data
                opto_sesh = true;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 66);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 777);

                if (trials_opto_control(b, :) == 1) 
                        
                    index_opto_onoff_ctl{b,1} = find(stop_cue{b,:}(:,6) > (target_distances(b, :) * 0.4), 1); 

                    if ~isempty(index_opto_onoff_ctl{b,1})

                        if trials_incomplete(b, 1) == 1
                            index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 10);
                        elseif trials_premature_slow(b, 1) == 1
                             index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 13);  
                        else
                            index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,6) > target_distances(b, :), 1);
                        end
                    
                    end

                    if ~isempty(index_opto_onoff_ctl{b,2} & index_opto_onoff_ctl{b,1})
                    opto_duration_ctl(b, :) = (stop_cue{b,:}(index_opto_onoff_ctl{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1)) / 1000000; % opto duration in seconds           
                    opto_time_on_ctl(b, 1) = stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1);
                    opto_time_on_ctl(b, 2) = opto_time_on_ctl(b, 1) + 1000000;
                    speed_ind_ctl{b, 1} = find(stop_cue{b,:}(:, 1) > opto_time_on_ctl(b, 2));
                    speed_ind_ctl{b, 2} = stop_cue{b,:}(index_opto_onoff_ctl{b,1}:speed_ind_ctl{b, 1}(1, 1), 5); % raw velocities
                    speed_ind_ctl{b, 3} = stop_cue{b,:}(index_opto_onoff_ctl{b,1}:speed_ind_ctl{b, 1}(1, 1), 8); % smoothed velocities

                    speed_comp_raw_ctl(b, 1) = speed_ind_ctl{b, 2}(1, 1) / 10; % in cm/s
                    speed_comp_raw_ctl(b, 2) = mean(speed_ind_ctl{b, 2}) / 10; % raw mean speed in cm/s
                    speed_comp_raw_ctl(b, 3) = (speed_comp_raw_ctl(b, 1) - speed_comp_raw_ctl(b, 2)) / speed_comp_raw_ctl(b, 1); 

                    speed_comp_smooth_ctl(b, 1) = speed_ind_ctl{b, 3}(1, 1) / 10; % in cm/s
                    speed_comp_smooth_ctl(b, 2) = mean(speed_ind_ctl{b, 3}) / 10; % raw mean speed in cm/s
                    speed_comp_smooth_ctl(b, 3) = (speed_comp_smooth_ctl(b, 1) - speed_comp_smooth_ctl(b, 2)) / speed_comp_smooth_ctl(b, 1); 
                 

                        if opto_duration_ctl(b, :) < 0.001 %fix for when there is an immediate early slow and immediate restart
                             opto_duration_ctl(b, :) = NaN;
                             trials_opto_control(b, :) = 0;
                        end                    
                    
                    else
                    opto_duration_ctl(b, :) = NaN;
                    end
                else
                    index_opto_onoff_ctl{b,1} = NaN;
                    index_opto_onoff_ctl{b,2} = NaN;
                    opto_duration_ctl(b, :) = NaN;

                    speed_comp_raw_ctl(b, 1) = NaN; 
                    speed_comp_raw_ctl(b, 2) = NaN; 
                    speed_comp_raw_ctl(b, 3) = NaN; 
                    speed_comp_smooth_ctl(b, 1) = NaN; 
                    speed_comp_smooth_ctl(b, 2) = NaN; 
                    speed_comp_smooth_ctl(b, 3) = NaN;
                  
                end

                
                if (trials_opto_target_1(b, :) == 1) 
                    index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 777); 
                    index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 778);
                    if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
                    opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds           
                    opto_time_on_1(b, 1) = stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1);
                    opto_time_on_1(b, 2) = opto_time_on_1(b, 1) + 1000000;
                    speed_ind_1{b, 1} = find(stop_cue{b,:}(:, 1) > opto_time_on_1(b, 2));
                    speed_ind_1{b, 2} = stop_cue{b,:}(index_opto_onoff_1{b,1}:speed_ind_1{b, 1}(1, 1), 5); % raw velocities
                    speed_ind_1{b, 3} = stop_cue{b,:}(index_opto_onoff_1{b,1}:speed_ind_1{b, 1}(1, 1), 8); % smoothed velocities

                    speed_comp_raw_1(b, 1) = speed_ind_1{b, 2}(1, 1) / 10; % in cm/s
                    speed_comp_raw_1(b, 2) = mean(speed_ind_1{b, 2}) / 10; % raw mean speed in cm/s
                    speed_comp_raw_1(b, 3) = (speed_comp_raw_1(b, 1) - speed_comp_raw_1(b, 2)) / speed_comp_raw_1(b, 1); 

                    speed_comp_smooth_1(b, 1) = speed_ind_1{b, 3}(1, 1) / 10; % in cm/s
                    speed_comp_smooth_1(b, 2) = mean(speed_ind_1{b, 3}) / 10; % raw mean speed in cm/s
                    speed_comp_smooth_1(b, 3) = (speed_comp_smooth_1(b, 1) - speed_comp_smooth_1(b, 2)) / speed_comp_smooth_1(b, 1); 

                        % if opto_duration_1(b, :) > 0.9899 & opto_duration_1(b, :) < 1.0099 %fix for when there is an immediate early slow and immediate restart
                        %      opto_duration_1(b, :) = NaN;
                        %      trials_opto_target_1(b, :) = 0;
                        % end                    
                    
                    else
                    opto_duration_1(b, :) = NaN;
                    end
                else
                    index_opto_onoff_1{b,1} = NaN;
                    index_opto_onoff_1{b,2} = NaN;
                    opto_duration_1(b, :) = NaN;

                    speed_comp_raw_1(b, 1) = NaN; 
                    speed_comp_raw_1(b, 2) = NaN; 
                    speed_comp_raw_1(b, 3) = NaN; 
                    speed_comp_smooth_1(b, 1) = NaN; 
                    speed_comp_smooth_1(b, 2) = NaN; 
                    speed_comp_smooth_1(b, 3) = NaN; 

                end
                
            end







             if floor(output.phase_check) == 33
                opto_sesh = true;

                trials_opto_control(b, :) = sum(stop_cue{b,:}(:, 4) == 10);
                trials_opto_target_1(b, :) = sum(stop_cue{b,:}(:, 4) == 33);

                if (trials_opto_control(b, :) == 1) 
                    index_opto_onoff_ctl{b,1} = find(stop_cue{b,:}(:,2) == 100); 
                    index_opto_onoff_ctl{b,2} = find(stop_cue{b,:}(:,2) == 101);
                    if ~isempty(index_opto_onoff_ctl{b,2} & index_opto_onoff_ctl{b,1})
                    opto_duration_ctl(b, :) = (stop_cue{b,:}(index_opto_onoff_ctl{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_ctl{b, 1}, 1)) / 1000000; % opto duration in seconds           
                        
                        if opto_duration_ctl(b, :) > 4.99 & opto_duration_ctl(b, :) < 5 % opto stim timed out before run started
                             opto_duration_ctl(b, :) = NaN;
                             trials_opto_control_ctl(b, :) = 0;
                             trials_opto_control_slow_start(b, :) = 1;
                        else
                             trials_opto_control_slow_start(b, :) = 0;                            
                        end                    
                    
                    else
                    opto_duration_ctl(b, :) = NaN;
                    end
                else
                    index_opto_onoff_ctl{b,1} = NaN;
                    index_opto_onoff_ctl{b,2} = NaN;
                    opto_duration_ctl(b, :) = NaN;
                    trials_opto_control_slow_start(b, :) = NaN;   

                end

                
                if (trials_opto_target_1(b, :) == 1) 
                    index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 330); 
                    index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 331);
                    if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
                    opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds           

                        if opto_duration_1(b, :) > 4.99 & opto_duration_1(b, :) < 5 % opto stim timed out before run started
                             opto_duration_1(b, :) = NaN;
                             trials_opto_target_1(b, :) = 0;
                             trials_opto_target_1_slow_start(b, :) = 1;
                        else
                             trials_opto_target_1_slow_start(b, :) = 0;                            
                        end  
                                            
                    else
                    opto_duration_1(b, :) = NaN;
                    end
                else
                    index_opto_onoff_1{b,1} = NaN;
                    index_opto_onoff_1{b,2} = NaN;
                    opto_duration_1(b, :) = NaN;
                    trials_opto_target_1_slow_start(b, :) = NaN;  

                end
                
            end 

%             if phase == '888'
%                 trials_opto_control(b, :) = sum(stop_cue{b,:}(1, 4) == 66);
%                 trials_opto_target_1(b, :) = sum(stop_cue{b,:}(1, 4) == 777);
%                 trials_opto_target_2(b, :) = sum(stop_cue{b,:}(1, 4) == 888);
%                 
%                 if (trials_opto_target_1(b, :) == 1) 
%                     index_opto_onoff_1{b,1} = find(stop_cue{b,:}(:,2) == 777); 
%                     index_opto_onoff_1{b,2} = find(stop_cue{b,:}(:,2) == 778);
%                     if ~isempty(index_opto_onoff_1{b,2} & index_opto_onoff_1{b,1})
%                     opto_duration_1(b, :) = (stop_cue{b,:}(index_opto_onoff_1{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_1{b, 1}, 1)) / 1000000; % opto duration in seconds
% 
%                     else
%                     opto_duration_1(b, :) = NaN;
%                     end
%                 else
%                     index_opto_onoff_1{b,1} = NaN;
%                     index_opto_onoff_1{b,2} = NaN;
%                     opto_duration_1(b, :) = NaN;
%                 end
% 
%                 if (trials_opto_target_2(b, :) == 1) 
%                     index_opto_onoff_2{b,1} = find(stop_cue{b,:}(:,2) == 888); 
%                     index_opto_onoff_2{b,2} = find(stop_cue{b,:}(:,2) == 889);
%                     if ~isempty(index_opto_onoff_2{b,2})
%                     opto_duration_2(b, :) = (stop_cue{b,:}(index_opto_onoff_2{b,2}(1, 1), 1) - stop_cue{b,:}(index_opto_onoff_2{b, 1}, 1)) / 1000000; % opto duration in seconds
%                     else
%                     opto_duration_2(b, :) = NaN;
%                     end
%                 else
%                     index_opto_onoff_2{b,1} = NaN;
%                     index_opto_onoff_2{b,2} = NaN;
%                     opto_duration_2(b, :) = NaN;
%                 end
%             end
% 
%             trials_mat_12_para_120(b, :) = sum(stop_cue{b,:}(:, 4) == 120);
%             trials_mat_12_para_150(b, :) = sum(stop_cue{b,:}(:, 4) == 150);
%             trials_mat_12_para_130(b, :) = sum(stop_cue{b,:}(:, 4) == 130);

            % trials_mat_13_para_25(b, :) = sum(stop_cue{b,:}(:, 4) == 0.25);
            % trials_mat_13_para_30(b, :) = sum(stop_cue{b,:}(:, 4) == 0.3);
            % trials_mat_13_para_35(b, :) = sum(stop_cue{b,:}(:, 4) == 0.35);
            
            licking_index{b, 1} = find(stop_cue{b,:}(:, 4) == 1);
            licking_timestamps{b, 1} = stop_cue{b,:}(licking_index{b, 1}(:, :), 1);

            low_vel_dist{b, 1} = find(stop_cue{b,:}(:, 5) > 145 & stop_cue{b,:}(:, 5) < 155);
                if ~isempty(index_reward{b, 1})
                    low_vel_dist{b, 4} = find(low_vel_dist{b, 1}(:, 1) < index_reward{b, 1});
                    low_vel_dist{b, 1} = low_vel_dist{b, 1}(low_vel_dist{b, 4} ,1);
                end
            low_vel_dist{b, 2} = stop_cue{b,:}(low_vel_dist{b, 1}(:, 1), 1);
            low_vel_dist{b, 3} = stop_cue{b,:}(low_vel_dist{b, 1}(:, 1), 6);
            low_vel_dist_sizes(b, 1) = size(low_vel_dist{b, 3}, 1);
            

            half_hour_trial(b, 1) = sum(stop_cue{b, 1}(1, 1) < half_hour_timestamp);
% 
%             if size(distance100_1{b,:}, 1) > 20
%                 ind_1 = distance60_1{b, :}(1, 1);
%                 ind_2 = distance100_1{b, :}(end, 1);        
%                 mean_binned_velocity(b, :) = mean(stop_cue{b, 1}(ind_1:ind_2, 9)); %averages movement and "tone" stamps so error values of this set might be off
%             else
%                 mean_binned_velocity(b,:) = NaN;
%             end
        
%          if floor(output.phase) == 8
%            trials_cued(b, 1) = sum(stop_cue{b, :}(:, 4) == 20);
%            trials_uncued(b, 1) = sum(stop_cue{b, :}(:, 4) == 22);
%          elseif floor(output.phase) == 0
%            trials_cued(b, 1) = sum(stop_cue{b, :}(:, 2) == 20);
%                    if trials_cued(b, 1) > 0
%                    cue_index(b, 1) = find(stop_cue{b, :}(:, 2) == 20);
%                    else
%                    cue_index(b, 1) = 0;
%                    end
%           try
%            reward_index(b, :) = find(stop_cue{b,:}(:,2) == 2);
%           catch
%               reward_index(b, :) = NaN;
%           end
%            trials_uncued(b, 1) = sum(stop_cue{b, :}(:, 2) == 22);
%          if output.day == 03
%            timestamps_cueassc(b, 1) = stop_cue{b, :}(cue_index(b, 1), 1);
%            timestamps_cueassc(b, 2) = stop_cue{b, :}(reward_index(b, :), 1);
%            lickfreq_cueassc(b, 1) = sum(licking_timestamps{b, 1}(:,:) >= (timestamps_cueassc(b, 1) - 1200900) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 1)); %1200900 is the time b/w cue and rw
%            lickfreq_cueassc(b, 2) = sum(licking_timestamps{b, 1}(:,:) >= timestamps_cueassc(b, 1) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 2)); 
%          else
%             lickfreq_cueassc(b, 1) = sum(licking_index{b, 1}(:, 1) < reward_index(b, :));
%             lickfreq_cueassc(b, 2) = sum(licking_index{b, 1}(:, 1) > reward_index(b, :));
%             
%          end
%          else
%             trials_cued(b, 1) = trials_go(b, 1);
%             trials_uncued(b, 1) = 0;
%          end

         % licking calculation
%             pre_rw_licks(b, 1) = sum(licking_index{b, 1}(:, 1) < reward_index(b, :));
%             post_rw_licks(b, 1) = sum(licking_index{b, 1}(:, 1) > reward_index(b, :));

  
    if floor(output.phase_check) == 13

        if reward_index(b, :) > 0
           
           timestamps_cueassc(b, 1) = stop_cue{b, :}(distanceslow{b, 1}(1, 1), 1); % different from code below
           timestamps_cueassc(b, 2) = stop_cue{b, :}(reward_index(b, :), 1);

           pericue_index{b, 1} = find(stop_cue{b, :}(:, 1) >= (timestamps_cueassc(b, 1) - 1200900) & stop_cue{b, :}(:, 1) < timestamps_cueassc(b, 1)); % index precue lines
           pericue_index{b, 1} = intersect(pericue_index{b, 1}, movement_index{b, 1});
           pericue_index{b, 2} = find(stop_cue{b, :}(:, 1) >= timestamps_cueassc(b, 1) & stop_cue{b, :}(:, 1) < timestamps_cueassc(b, 2)); % index postcue lines   
           pericue_index{b, 2} = intersect(pericue_index{b, 2}, movement_index{b, 1});

           lickfreq_cueassc(b, 1) = sum(licking_timestamps{b, 1}(:,:) >= (timestamps_cueassc(b, 1) - 1200900) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 1)); %1200900 is the time b/w cue and rw
           lickfreq_cueassc(b, 2) = sum(licking_timestamps{b, 1}(:,:) >= timestamps_cueassc(b, 1) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 2)); 

           vel2_cueassc(b, 1) = mean(stop_cue{b, :}(pericue_index{b, 1}, 9)) / 10; % different from code below
           vel2_cueassc(b, 2) = mean(stop_cue{b, :}(pericue_index{b, 2}, 9)) / 10; % different from code below

           rawVel_cueassc(b, 1) = mean(stop_cue{b, :}(pericue_index{b, 1}, 5)) / 10;
           rawVel_cueassc(b, 2) = mean(stop_cue{b, :}(pericue_index{b, 2}, 5)) / 10;
         
         %   rawVel_cueassc(b, 1) = ((stop_cue{b, :}(pericue_index{b, 1}(end, 1), 5) - stop_cue{b, :}(pericue_index{b, 1}(1, 1), 5)) / 10) / ((stop_cue{b, :}(pericue_index{b, 1}(end, 1), 1) - stop_cue{b, :}(pericue_index{b, 1}(1, 1), 1)) / 1000000); % calculating vel
         %         if isnan(rawVel_cueassc(b, 1))
         %             rawVel_cueassc(b, 1) = 0;
         %         end
         % try  
         %   rawVel_cueassc(b, 2) = ((stop_cue{b, :}(pericue_index{b, 2}(end, 1), 5) - stop_cue{b, :}(pericue_index{b, 2}(1, 1), 5)) /10) / ((stop_cue{b, :}(pericue_index{b, 2}(end, 1), 1) - stop_cue{b, :}(pericue_index{b, 2}(1, 1), 1)) / 1000000);
         % catch
         %   rawVel_cueassc(b, 2) = 0;
         % end

        end

    else
        if reward_index(b, :) > 0 & trials_cued(b, 1) == 1
           
           timestamps_cueassc(b, 1) = stop_cue{b, :}(cue_index(b, 1), 1);
           timestamps_cueassc(b, 2) = stop_cue{b, :}(reward_index(b, :), 1);

           pericue_index{b, 1} = find(stop_cue{b, :}(:, 1) >= (timestamps_cueassc(b, 1) - 1200900) & stop_cue{b, :}(:, 1) < timestamps_cueassc(b, 1)); % index precue lines
           pericue_index{b, 1} = intersect(pericue_index{b, 1}, movement_index{b, 1});
           pericue_index{b, 2} = find(stop_cue{b, :}(:, 1) >= timestamps_cueassc(b, 1) & stop_cue{b, :}(:, 1) < timestamps_cueassc(b, 2)); % index postcue lines   
           pericue_index{b, 2} = intersect(pericue_index{b, 2}, movement_index{b, 1});

           lickfreq_cueassc(b, 1) = sum(licking_timestamps{b, 1}(:,:) >= (timestamps_cueassc(b, 1) - 1200900) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 1)); %1200900 is the time b/w cue and rw
           lickfreq_cueassc(b, 2) = sum(licking_timestamps{b, 1}(:,:) >= timestamps_cueassc(b, 1) & licking_timestamps{b, 1}(:,:) < timestamps_cueassc(b, 2)); 

           vel2_cueassc(b, 1) = mean(stop_cue{b, :}(pericue_index{b, 1}, 8)) / 10;
           vel2_cueassc(b, 2) = mean(stop_cue{b, :}(pericue_index{b, 2}, 8)) / 10;

           rawVel_cueassc(b, 1) = mean(stop_cue{b, :}(pericue_index{b, 1}, 5)) / 10;
           rawVel_cueassc(b, 2) = mean(stop_cue{b, :}(pericue_index{b, 2}, 5)) / 10;
         
         %   rawVel_cueassc(b, 1) = ((stop_cue{b, :}(pericue_index{b, 1}(end, 1), 5) - stop_cue{b, :}(pericue_index{b, 1}(1, 1), 5)) / 10) / ((stop_cue{b, :}(pericue_index{b, 1}(end, 1), 1) - stop_cue{b, :}(pericue_index{b, 1}(1, 1), 1)) / 1000000); % calculating vel
         %         if isnan(rawVel_cueassc(b, 1))
         %             rawVel_cueassc(b, 1) = 0;
         %         end
         % try  
         %   rawVel_cueassc(b, 2) = ((stop_cue{b, :}(pericue_index{b, 2}(end, 1), 5) - stop_cue{b, :}(pericue_index{b, 2}(1, 1), 5)) /10) / ((stop_cue{b, :}(pericue_index{b, 2}(end, 1), 1) - stop_cue{b, :}(pericue_index{b, 2}(1, 1), 1)) / 1000000);
         % catch
         %   rawVel_cueassc(b, 2) = 0;
         % end

        end
    end
      
%                 if trials_go(b, :) == 1
%                     raw_trials{t, :} = data(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :);
%                     t = t + 1;
%                 end
        
    end
   end % end of rerun statement

% output.current_bug = sum(current_bug);
% output.current_bug_2 = sum(current_bug_2);
% output.current_bug_3 = sum(current_bug_3);
% output.mystery_bug = sum(mystery_bug);

%         
%     if (size(tone_stop_index, 1) > size(trials_go, 1)) == 1 % if there are any trials missing a stop tone timestamp
%                 
%         stop_cue{b, :} = data(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :); % makes a cell array containing the data from every trial (defined by 8 event to 8 event) in each cell
%                
%             % Fix to make sure two trials don't get combined if WN doesnt print
%                 go_tone_index{b, :} = find(stop_cue{b, 1}(:, 2) == 9);
% 
% %                     if (size(go_tone_index{b, 1}, 1) > 1) == 1
% % 
% %                         fix_wait_duration = (stop_cue{b, 1}(go_tone_index{b, 1}(2, 1), 8) - 499985); % calculates when to print the wait duration
% %                         fix_wait_timestamp = (stop_cue{b, 1}(go_tone_index{b, 1}(2, 1), 1) - fix_wait_duration);
% %                         fix_row_post_index = find(stop_cue{b, 1}(:, 1) > fix_wait_timestamp);
% %                         fix_row_insert = fix_row_post_index(1, 1) - 1;
% %                         fix_new_row = zeros(1,size(data,2));
% %                         fix_new_row(1, 1) = fix_wait_timestamp;
% %                         fix_new_row(1, 2) = 8;
% %                         data_new = [data(1: (tone_stop_index(b, 1) + fix_row_insert), :); fix_new_row; data((tone_stop_index(b, 1) + fix_row_insert + 1) : end, :)];
% %                         data = data_new;
% %                         %clear stop_cue;
% % 
% %                         tone_stop = data(:, 2) == 8;
% %                         tone_stop_index = find(tone_stop == 1);
% % 
% %                         b = 1;
% % 
% %                     end
% %                     
%             stop_cue_times{b, :} = new_times(tone_stop_index(b, 1): tone_stop_index(b + 1, 1), :); % makes a cell array containing the timestamps for every trial (defined by 8 event to 8 event) in each cell
% 
%             trials_go(b, :) = sum((stop_cue{b,:}(:,2)) == 9); %returns logical values for whether the trial contained a go tone
%             
%             %trials_distance_mode(b, :) = mode(stop_cue{b, :}(:, 7));
%                       
%             trials_reward(b, :) = sum((stop_cue{b,:}(:,2)) == 2); %returns logical values for whether the trial contained a reward
%             trials_incomplete(b, :) = sum((stop_cue{b,:}(:,2)) == 10);
%             trials_slowfail(b, :) = sum((stop_cue{b,:}(:,2)) == 11); 
% 
%             trials_slowdown(b, :) = sum(stop_cue{b,:}(:,2) == 77);
%             trials_premature_slow(b, :) = sum((stop_cue{b,:}(:,2)) == 13);
% 
%             trials_short(b, :) = sum(stop_cue{b, :}(2, 7) == 250);
%             trials_medium(b, :) = sum(stop_cue{b, :}(2, 7) == 750);
%             trials_long(b, :) = sum(stop_cue{b, :}(2, 7) == 1250);
% 
%             time_reset{b, :} = (stop_cue{b, 1}(:,1) - stop_cue{b, 1}(1,1) ) / 1000000; %resets the timestamps for each trial and converts it from msecs to secs
%                 
%             %distancetrial{i,:}=(stop_cue{i, 1}(:,3)-stop_cue{i, 1}(1,3)); %returns distance elapsed during each event in a trial
%             distancetrial{b,:} = (stop_cue{b, 1}(:, 6));
% 
%             %velocitytrial{i,:}=distancetrial{i,:}./time_reset{i,:}; %returns the velocity of each event in a trial
%             velocitytrial{b,:} = (stop_cue{b, 1}(:, 5));
% 
%             %acelerationtrial{i, :} = diff(velocitytrial{i,:});
%             accelerationtrial{b, :} = (diff(velocitytrial{b,:})) ./ (diff(time_reset{b,:})); %returns acceleration of each event
% 
%             %velocitythreshold{i,:} = find(velocitytrial{i,:} >= 3);
%             %timearresend(i,:)=time_reset{i, 1}(end,1);
% 
%             index_reward{b,:} = find(stop_cue{b,:}(:,2) == 2); %indexes the line of each reward within each trial
%             index_restart{b,:} = find(stop_cue{b,:}(:,2) == 10); %indexes the line of each reward within each trial
%                 if ~isempty(index_restart{b, :})
%                     restart_distances(b, :) = stop_cue{b, :}(index_restart{b, :}, 6);
%                     restart_times(b, :) = (stop_cue{b, :}(index_restart{b, :}, 1) - stop_cue{b, :}((index_restart{b, :} - 1), 1));
%                 else
%                     restart_distances(b, :) = NaN;
%                     restart_times(b, :) = NaN;
%                 end
% 
%             %feddbackindex{i,:}=find(stop_cue{i,:}(:,2)>6);
% 
%             timenev{b, :} = stop_cue_times{b, :}; %copies stop_cue_times cell array into a new cell array for some reason?
%             
%             target_distances(b, :) = stop_cue{b, 1}(2, 7);
% %             
% %             distance20_1{b,:} = find(stop_cue{b,:}(:,2) == 3 & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.2)); %indexes events within corresponding distance percentage (<20%)
% %             distance40_1{b,:} = find(stop_cue{b,:}(:,2) == 4 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.2) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.4)); %indexes events within corresponding distance percentage (<40%)
% %             distance60_1{b,:} = find(stop_cue{b,:}(:,2) == 5 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.4) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.6)); %indexes events within corresponding distance percentage (<60%)
% %             distance80_1{b,:} = find(stop_cue{b,:}(:,2) == 6 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.6) & stop_cue{b,:}(:,6) < (target_distances(b, :)*0.8)); %indexes events within corresponding distance percentage (<80%)
% %             distance100_1{b,:} = find(stop_cue{b,:}(:,2) == 7 & stop_cue{b,:}(:,6) > (target_distances(b, :)*0.8) & stop_cue{b,:}(:,6) < (target_distances(b, :)*1)); %indexes events within corresponding distance percentage (<100%)
% %             distanceslow_1{b,:} = find(stop_cue{b,:}(:,2) == 77 & stop_cue{b,:}(:,6) > (target_distances(b, :)*1)); %indexes events within corresponding distance percentage (>100%)
% %             
%             distance20_1{b,:} = find(stop_cue{b,:}(:,2) == 3); %indexes events within corresponding distance percentage (<20%)
%             distance40_1{b,:} = find(stop_cue{b,:}(:,2) == 4); %indexes events within corresponding distance percentage (<40%)
%             distance60_1{b,:} = find(stop_cue{b,:}(:,2) == 5); %indexes events within corresponding distance percentage (<60%)
%             distance80_1{b,:} = find(stop_cue{b,:}(:,2) == 6); %indexes events within corresponding distance percentage (<80%)
%             distance100_1{b,:} = find(stop_cue{b,:}(:,2) == 7); %indexes events within corresponding distance percentage (<100%)
%             distanceslow_1{b,:} = find(stop_cue{b,:}(:,2) == 77); %indexes events within corresponding distance percentage (>100%)
%             
%     end

% Obtain overall performance metrics

    if opto_sesh == true
        trials_opto_target_1 = ~isnan(opto_duration_1); %selecting only trials where stim actually occured
        trials_opto_control = ~isnan(opto_duration_ctl); %selecting only comparable trials
    end

%         if phase == '888'
%         trials_opto_target_1 = ~isnan(opto_duration_1); %selecting only trials where stim actually occured
%         trials_opto_target_2 = ~isnan(opto_duration_2); %selecting only trials where stim actually occured
%         trials_opto_control_1 = trials_opto_control; 
%         trials_opto_control_2 = trials_opto_control .* trials_go; 
%         end        

   
        %half_hour_trial_num = sum(half_hour_trial);

        trials_premature = ~trials_go;
        trials_incomplete_slowdown = trials_incomplete .* trials_slowdown;

            for i = 1:(length (trials_incomplete_slowdown))

                if trials_incomplete_slowdown(i, 1) > 0

                    trials_incomplete_slowdown(i, 1) = 1;

                end

            end

        trials_incomplete_running = (~trials_incomplete_slowdown) .* trials_incomplete;
        incomplete_running_distances = trials_incomplete_running .* restart_distances;
        incomplete_slowdown_distances = trials_incomplete_slowdown .* restart_distances;
        incomplete_slowdown_distances_norm = incomplete_slowdown_distances ./ target_distances;
        
        




        trials_reward_short = trials_reward .* trials_short;
        trials_reward_medium = trials_reward .* trials_medium;
        trials_reward_long = trials_reward .* trials_long;

        trials_premature_short = trials_premature .* trials_short;
        trials_premature_medium = trials_premature .* trials_medium;
        trials_premature_long = trials_premature .* trials_long;

        trials_incomplete_slowdown_short = trials_incomplete_slowdown .* trials_short;
        trials_incomplete_slowdown_medium = trials_incomplete_slowdown .* trials_medium;
        trials_incomplete_slowdown_long = trials_incomplete_slowdown .* trials_long;

        trials_incomplete_running_short = trials_incomplete_running .* trials_short;
        trials_incomplete_running_medium = trials_incomplete_running .* trials_medium;
        trials_incomplete_running_long = trials_incomplete_running .* trials_long;

        trials_slowfail_short = trials_slowfail .* trials_short;
        trials_slowfail_medium = trials_slowfail .* trials_medium;
        trials_slowfail_long = trials_slowfail .* trials_long;

        trials_premature_slow_short = trials_premature_slow .* trials_short;
        trials_premature_slow_medium = trials_premature_slow .* trials_medium;
        trials_premature_slow_long = trials_premature_slow .* trials_long;

        trials_opto_control_index = find(trials_opto_control == 1);
        trials_opto_target_1_index = find(trials_opto_target_1 == 1);      

        trials_opto_control_short = trials_opto_control .* trials_short;
        trials_opto_target_1_short = trials_opto_target_1 .* trials_short;

        trials_opto_control_medium = trials_opto_control .* trials_medium;
        trials_opto_target_1_medium = trials_opto_target_1 .* trials_medium;

        trials_opto_control_long = trials_opto_control .* trials_long;
        trials_opto_target_1_long = trials_opto_target_1 .* trials_long;

        trials_opto_control_short_index = find(trials_opto_control_short == 1);
        trials_opto_target_1_short_index = find(trials_opto_target_1_short == 1);

        trials_opto_control_medium_index = find(trials_opto_control_medium == 1);
        trials_opto_target_1_medium_index = find(trials_opto_target_1_medium == 1);

        trials_opto_control_long_index = find(trials_opto_control_long == 1);
        trials_opto_target_1_long_index = find(trials_opto_target_1_long == 1);

        trials_running_index = find(trials_go == 1);  
        trials_running_index_short = trials_go .* trials_short;
        trials_running_index_medium = trials_go .* trials_medium;
        trials_running_index_long = trials_go .* trials_long;  


    % Determining the restarts that occured during the slowdown phase versus running phase

        % Obtain incomplete data

            incomplete_trials_index = find(trials_incomplete == 1);

            % If there are incomplete trials then the following code will run to determine which of them occur in slowdown phase

            if ~isempty(incomplete_trials_index)
                    
                    for i = 1:(length (incomplete_trials_index)) 

                        incomplete_data(i, :) = stop_cue(incomplete_trials_index(i, 1), 1);

                    end   

                % Select incomplete trials that occur during slowdown periods

                    for i = 1:(length (incomplete_data))

                        incomplete_slowdown_trials_log{i, :} = find(incomplete_data{i, 1}(:, 2) == 77);

                            if isempty (incomplete_slowdown_trials_log{i, :})  

                                incomplete_slowdown_trials_log{i, :} = 0;
                            else
                                                      
                                incomplete_slowdown_trials_log{i, :} = 1;

                            end
                    end

                    incomplete_slowdown_trials = cell2mat(incomplete_slowdown_trials_log);

            else

                incomplete_slowdown_trials = NaN;
                incomplete_data = NaN;

            end

        incomplete_slowdown_index = find(incomplete_slowdown_trials == 1);

    % Analysis of incomplete slowdown trials

%        if length(incomplete_slowdown_index) > 1
% 
%         % Select out data from index
%             
%             for i = 1:(length (incomplete_slowdown_index))
% 
%                 incomplete_slowdown_data(i, :) = incomplete_data(incomplete_slowdown_index(i, 1), :);
% 
%             end
% 
%         % Find the distance at which the animal stopped relative to the target distance
% 
%         % Pretty sure this code chunk is wrong!!!!
% %             for i = 1:(length (incomplete_slowdown_data))
% % 
% %                 incomplete_slowdown_distances(i, :) = (incomplete_slowdown_data{i, 1}(2, 7) / 10);               
% %                 incomplete_slowdown_distances_norm(i, :) = (incomplete_slowdown_data{i, 1}(end - 1, 6) / incomplete_slowdown_data{i, 1}(2, 7));
% % 
% %             end
% 
%             % Save outputs
% 
%     %            output{63, 1} = 'incomplete_slowdown_distances_rawdata';
%     %            output{63, 2} = incomplete_slowdown_distances;
%     %            output.mean_incomplete_slowdown_target_distances = mean(incomplete_slowdown_distances);    %
% 
%     %            output.SEM_incomplete_slowdown_target_distances = (std(incomplete_slowdown_distances)/(sqrt(length(incomplete_slowdown_distances))));%
% 
%     %            output.median_incomplete_slowdown_target_distances = median(incomplete_slowdown_distances);    %
% 
%     %            output.geomean_incomplete_slowdown_target_distances = geomean(incomplete_slowdown_distances);            %
%     %
% 
%     %            output.mean_incomplete_slowdown_distances_norm = mean(incomplete_slowdown_distances_norm);    %
% 
%     %            output.SEM_incomplete_slowdown_distances_norm = (std(incomplete_slowdown_distances_norm)/(sqrt(length(incomplete_slowdown_distances_norm))));%
% 
%     %            output.median_incomplete_slowdown_distances_norm = median(incomplete_slowdown_distances_norm);    %
% 
%     %            output.geomean_incomplete_slowdown_distances_norm = geomean(incomplete_slowdown_distances_norm);            %
% 
%     %       else%
% 
%     %            output.mean_incomplete_slowdown_target_distances = 0;    %
% 
%     %            output.SEM_incomplete_slowdown_target_distances = 0;%
% 
%     %            output.median_incomplete_slowdown_target_distances = 0;    %
% 
%     %            output.geomean_incomplete_slowdown_target_distances = 0;            %
%     %
% 
%     %            output.mean_incomplete_slowdown_distances_norm = 0;    %
% 
%     %            output.SEM_incomplete_slowdown_distances_norm = 0;%
% 
%     %            output.median_incomplete_slowdown_distances_norm = 0;    %
% 
%     %            output.geomean_incomplete_slowdown_distances_norm = 0;            
%               
%        end

    % Obtain Performance Data

        Complete_Trials = sum(trials_reward);
        Incomplete_Trials = sum(trials_incomplete);
        Incomplete_Running_Trials = sum(trials_incomplete_running);
        Incomplete_Slowdown_Trials = sum(incomplete_slowdown_trials);
        Premature_Trials = sum(trials_premature);
        Slowdown_Failures = sum(trials_slowfail);
        Premature_slowdown_trials = sum(trials_premature_slow);
        
        Total_Trials = length(stop_cue);
        Total_Running_Trials = Total_Trials - Premature_Trials;
        Total_Slowdown_Trials = Total_Running_Trials - Incomplete_Running_Trials - Premature_slowdown_trials;

        Performance_Percentage = ( Complete_Trials / Total_Trials ) * 100;
        Performance_Percentage_2 = ( Complete_Trials / Total_Running_Trials ) * 100;
        Performance_Percentage_3 = ( Complete_Trials / Total_Slowdown_Trials) * 100;

        Session_Duration = dur;  % session duration in minutes

        Total_Running_Trials = Total_Trials - Premature_Trials;
        Total_Slowdown_Trials = Total_Running_Trials - Incomplete_Running_Trials - Premature_slowdown_trials;

% Create index for short, medium, long trials
        
  trials_short_index = find(trials_short == 1);      
  trials_medium_index = find(trials_medium == 1);  
  trials_long_index = find(trials_long == 1);  
  
% Create velocity trajectory graphs for each trial type

   % Obtain running data

        smooth_value = 21; % change this to alter the bin number, final bin number will be 1 less than this value
        smooth_value_slow = 21;
        smooth_xaxis = [1:(smooth_value - 1)];
        
        window = 20; % change this to alter the smoothing value for conv function
        mask = ones(1,window) / window;
       
        size_limit = 20; %the minimum size velocity matrix to analyze

        reward_counter = 0;
        error_counter = 0;
       
    for i = 1:(length (stop_cue)) 

          if trials_reward(i, 1) > 0
              reward_counter = reward_counter + 1;
          end

            if reward_counter < 101
                motivation_index(i, 1) = i;
            end
            
%         if ismember(i, trials_short_index)
%             smooth_value = (short*0.2) + 1;
%             smooth_value_slow = (short*(cutoff / short)) + 1;
%             smooth_xaxis = [1:(smooth_value - 1)];
%             smooth_xaxis_slow = [1:(smooth_value_slow - 1)];     
%             
%         elseif ismember(i, trials_medium_index)
%             smooth_value = (medium*0.2) + 1;
%             smooth_value_slow = (medium*(cutoff / medium)) + 1;
%             smooth_xaxis = [1:(smooth_value - 1)];
%             smooth_xaxis_slow = [1:(smooth_value_slow - 1)];   
%             
%             
%         elseif ismember(i, trials_long_index)
%             smooth_value = (long*0.2) + 1;
%             smooth_value_slow = (long*(cutoff / long)) + 1;
%             smooth_xaxis = [1:(smooth_value - 1)];
%             smooth_xaxis_slow = [1:(smooth_value_slow - 1)];   
%             
%         end
            
            slowdown_period_index{i, :} = find(stop_cue{i, 1}(:, 2) == 77);                 
            T5_index{i, :} = find(stop_cue{i, 1}(:, 2) == 7);
            T3_index{i, :} = find(stop_cue{i, 1}(:, 2) == 5);


                if ~isempty(index_reward{i, :})
                    reward_distance(i, :) = (stop_cue{i, 1}(index_reward{i, :}(1,1), 6) - target_distances(i, 1)) / 10; % reward distance in centimeters

                        if reward_distance(i, :) < 1
                            reward_distance(i, :) = NaN;
                        end

                    reward_time(i, 1) = stop_cue{i, 1}(index_reward{i, :}(1,1), 1);
                    reward_velocity(i, 1) = stop_cue{i, 1}(index_reward{i, :}(1,1), 5); % raw velocity
                    reward_vel2(i, 1) = stop_cue{i, 1}(index_reward{i, :}(1,1), 8); % averaged velocity
                    
                    if ~isempty(slowdown_period_index{i, :})
                        reward_time(i, 2) = stop_cue{i, 1}(slowdown_period_index{i, :}(1,1), 1);
                        reward_time(i, 3) = (reward_time(i, 1) - reward_time(i, 2)) / 1000000;
                        reward_time(i, 4) = (reward_time(i, 1) - stop_cue{i, 1}(T5_index{i, :}(1,1), 1)) / 1000000;                                                 
                    else
                        reward_time(i, 3) = 0;
                        reward_time(i, 4) = 0;
                    end
                else
                    index_reward{i, :} = NaN;
                    reward_distance(i, :) = NaN;
                    reward_time(i, 1:3) = NaN;
                    reward_velocity(i, 1) = NaN;
                    reward_vel2(i, 1) = NaN;

                end

                if ~isnan(index_premature_slow{i, :})
                    premature_slow_distance(i, :) = (stop_cue{i, 1}(index_premature_slow{i, :}(1,1), 6)); 
                        trials_premature_slow_late(i, :) = premature_slow_distance(i, :) >= ((0.4 * target_distances(i, :)) + 10);
                        trials_premature_slow_imm(i, :) = premature_slow_distance(i, :) > (0.40 * target_distances(i, :)) & premature_slow_distance(i, :) < ((0.4 * target_distances(i, :)) + 10);
                        trials_premature_slow_early(i, :) = premature_slow_distance(i, :) <= (0.4 * target_distances(i, :));
 
                    premature_slow_time(i, 1) = stop_cue{i, 1}(index_premature_slow{i, :}(1,1), 1);
                    premature_slow_velocity(i, 1) = stop_cue{i, 1}(index_premature_slow{i, :}(1,1), 5); % raw velocity
                    premature_slow_vel2(i, 1) = stop_cue{i, 1}(index_premature_slow{i, :}(1,1), 8); % average vel         

                else
                    trials_premature_slow_late(i, :) = 0;
                    trials_premature_slow_imm(i, :) = 0;
                    trials_premature_slow_early(i, :) = 0;
                    index_premature_slow{i, :} = NaN;
                    premature_slow_distance(i, :) = NaN;
                    premature_slow_time(i, 1:3) = NaN;
                    premature_slow_velocity(i, 1) = NaN;
                    premature_slow_vel2(i, 1) = NaN;

                end

                if ~isempty(index_incomplete{i, :})
                    incomplete_distance(i, :) = (stop_cue{i, 1}(index_incomplete{i, :}(1,1), 6)) / 10; % incomplete distance in centimeters
                    incomplete_time(i, 1) = stop_cue{i, 1}(index_incomplete{i, :}(1,1), 1);
                    incomplete_velocity(i, 1) = stop_cue{i, 1}(index_incomplete{i, :}(1,1), 5); % raw vel
                    incomplete_vel2(i, 1) = stop_cue{i, 1}(index_incomplete{i, :}(1,1), 8); % average vel
                    
                else
                    index_incomplete{i, :} = NaN;
                    incomplete_distance(i, :) = NaN;
                    incomplete_time(i, 1:3) = NaN;
                    incomplete_velocity(i, 1) = NaN;
                    incomplete_vel2(i, 1) = NaN;
                    
                end

            
            wn_index{i, :} = find(stop_cue{i, 1}(:, 2) == 8);
            go_index{i, :} = find(stop_cue{i, 1}(:, 2) == 9);
                
                if (size(go_index{i, 1}, 1) > 0 && size(go_index{i, 1}, 1) < 2) == 1  %temp fix but need to figure out whats going on for 16 on 6/21/22
                    slowdown_parameter(i, :) = stop_cue{i, 1}(go_index{i, :}, file_struct);
                else
                    slowdown_parameter(i, :) = NaN;
                end

            %movement_index{i, :} = find(stop_cue{i, 1}(:, 2) == 0);
            distances{i, :} = stop_cue{i, 1}(movement_index{i, :}, 6);   
            
            if size(movement_index{i, :}, 1) > 0 
            go_latency_from_WN(i, :) = (stop_cue{i, 1}(movement_index{i, :}(1,1), 1) - stop_cue{i, 1}(wn_index{i, :}(1,1), 1)) / 1000000; % time in seconds  
            else
            go_latency_from_WN(i, :) = NaN;
            end

            if size(go_index{i, :}, 1) > 0 & size(movement_index{i, :}, 1) > 0 
                go_latency(i, :) = (stop_cue{i, 1}(movement_index{i, :}(1,1), 1) - stop_cue{i, 1}(go_index{i, :}(1,1), 1)) / 1000000;

                go_latency_from_go(i, :) = (stop_cue{i, 1}(movement_index{i, :}(1,1), 1) - stop_cue{i, 1}(go_index{i, :}, 1)) / 1000000; % time in seconds   
            else
                
                go_latency_from_go(i, :) = NaN;  
                go_latency(i, :) = NaN;
            end


            if incomplete_running_distances(i, :) > 0
                trials_incomplete_running_late(i, :) = incomplete_running_distances(i, :) >= ((0.4 * target_distances(i, :)) + 10);
                trials_incomplete_running_imm(i, :) = incomplete_running_distances(i, :) > (0.40 * target_distances(i, :)) & incomplete_running_distances(i, :) < ((0.4 * target_distances(i, :)) + 10);
                trials_incomplete_running_early(i, :) = incomplete_running_distances(i, :) <= (0.4 * target_distances(i, :));
            else
                trials_incomplete_running_late(i, :) = 0;
                trials_incomplete_running_imm(i, :) = 0;
                trials_incomplete_running_early(i, :) = 0;
            end

            if trials_incomplete_running_late(i, :) > 0 | trials_premature_slow_late(i, :) > 0 | trials_slowfail(i, :) > 0
                error_counter = error_counter + 1;
            end

            if trials_incomplete_running_late(i, :) > 0 | trials_premature_slow_late(i, :) > 0 
                trials_pretarget_error(i, :) = 1;

                if trials_incomplete_running_late(i, :) > 0
                    pretarget_error_index(i, 1) = find(stop_cue{i,:}(:,2) == 10);
                else
                    pretarget_error_index(i, 1) = find(stop_cue{i,:}(:,2) == 13);
                end
                
                pretarget_error_distance(i, 1) = stop_cue{i,:}(pretarget_error_index(i, 1), 6);
                pretarget_error_distance_percent(i, 1) = pretarget_error_distance(i, 1) / target_distances(i, 1);
                
                     if floor(output.phase_check) == 77 | floor(output.phase_check) == 5 % decoy/distractor cue task

                        if trials_opto_target_1(i, 1) == 1 & ~isnan(decoy_cue_index(i, 1))
                            decoy_cue_distance(i, 1) = (pretarget_error_distance(i, 1) - stop_cue{i,:}(decoy_cue_index(i, 1), 6)) / 10; % distance in cm
                        
                            if decoy_cue_distance(i, 1) < 1
                                decoy_cue_distance(i, 1) = NaN;
                            end

                        else
                            decoy_cue_distance(i, 1) = NaN;
                        end

                    end

            else
                trials_pretarget_error(i, :) = 0;
                pretarget_error_index(i, 1) = NaN;
                pretarget_error_distance(i, 1) = NaN;
                pretarget_error_distance_percent(i, 1) = NaN;  

                     if floor(output.phase_check) == 77 | floor(output.phase_check) == 5 % decoy/distractor cue task

                        decoy_cue_distance(i, 1) = NaN;

                    end             

            end   

            cumulative_perf(i, 1) = reward_counter / (reward_counter + error_counter); 

            tone_distances{i, :} = target_distances(i, :) * 0.2;
            max_distances{i, :} = max(distances{i, :}); 
    
            total_movement_velocities{i, :} = stop_cue{i, 1}(movement_index{i, :}, 5); % raw vel
            total_movement_vel2{i, :} = stop_cue{i, 1}(movement_index{i, :}, 8);  % average vel 
            
                % Create index for stop events

                    time_initial{i, :} = stop_cue{i, 1}(movement_index{i, :}(1:end - 1, 1), 1);
                    time_post{i, :} = stop_cue{i, 1}(movement_index{i, :}(2:end, 1), 1);
                    time_differences{i, :} = time_post{i, :} - time_initial{i, :};

                    stops_index{i, :} = find(time_differences{i, :} >= 500000);
                    stops_durations{i, :} = (time_differences{i, :}(stops_index{i, :}, 1)) / 1000000;
                    if size(stops_durations{i, :}, 1) > 0
                        mean_stops_durations(i, :) = mean(stops_durations{i, :});
                    end
                    stops_index{i, :} = movement_index{i, :}(stops_index{i, :}, 1);
                    stops_distances{i, :} = stop_cue{i, 1}(stops_index{i, :}, 6);
                    stops_frequency(i, :) = length(stops_distances{i, :});

                   

                if (size(slowdown_period_index{i, 1}, 1) > 1) == 1  
                    slowdown_period_start(i, :) = slowdown_period_index{i, :}(1,1);
                    
                    if (size(go_index{i, 1}, 1) > 0) == 1
                        running_period_distance(i, :) = (stop_cue{i, 1}(slowdown_period_start(i, :), 6) - stop_cue{i, 1}(go_index{i, :}, 6)) / 10; % in cm
                        running_period_time(i, :) = (stop_cue{i, 1}(slowdown_period_start(i, :), 1) - stop_cue{i, 1}(go_index{i, :}, 1)) / 1000000; % time in seconds
                    else
                       running_period_distance(i, :) = NaN;
                       running_period_time(i, :) = NaN;
                       
                    end
                    
                    if index_reward{i, 1} > 0
                        slowdown_distance_to_reward(i, :) = (stop_cue{i, 1}(index_reward{i, :}, 6) - stop_cue{i, 1}(slowdown_period_start(i, :), 6)) / 10; % in cm
                        slowdown_time_to_reward(i, :) = (stop_cue{i, 1}(index_reward{i, :}, 1) - stop_cue{i, 1}(slowdown_period_start(i, :), 1)) / 1000000; % time in seconds
   
                    else
                        slowdown_distance_to_reward(i, :) = NaN;
                        slowdown_time_to_reward(i, :) =  NaN;
                    end

                else
                    slowdown_period_start(i, :) = NaN;
                    slowdown_distance_to_reward(i, :) = NaN;
                    slowdown_time_to_reward(i, :) =  NaN;
                    running_period_distance(i, :) = NaN;
                    running_period_time(i, :) = NaN;

                end


%                 phs{i, 1} = stop_cue{i, 1}(movement_index{i, :}, 5);
%                 phsconv{i, 1} = conv(phs{i, 1}, mask, 'same');
%                 stop_cue{i, 1}(movement_index{i, :}, 5) = phsconv{i, 1};
        
          %  if (size(distance20_1{i, 1}, 1) > size_limit) == 1  
          try
                movement_20_index{i, :} = find(movement_index{i, :} < distance20_1{i, 1}(end - 2, 1));
                movement_20_index{i, :} = movement_index{i, :}(movement_20_index{i, :}, 1);

                % rescale data based on distance
                movement_20_velocities_lengths_dist{i, 1} = stop_cue{i, 1}(movement_20_index{i, :}(end, 1), 6); % to normalize by distance, collect final distances
                movement_20_velocities_lengths_dist{i, 2} = stop_cue{i, 1}(movement_20_index{i, :}(1, 1), 6); % to normalize by distance, collect start distances
                movement_20_velocities_smooth_dist{i, :} = linspace(movement_20_velocities_lengths_dist{i, 2}, movement_20_velocities_lengths_dist{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_20_velocities_smooth_index_dist{i, f} = find(stop_cue{i, 1}(movement_20_index{i, :}, 6) >= movement_20_velocities_smooth_dist{i, 1}(1, f) & stop_cue{i, 1}(movement_20_index{i, :}, 6) < movement_20_velocities_smooth_dist{i, 1}(1, f + 1));
                        movement_20_velocities_smooth_index_dist{i, f} = movement_20_index{i, :}(movement_20_velocities_smooth_index_dist{i, f}, 1);
                        
                        movement_20_velocities_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_20_velocities_smooth_index_dist{i, f}, 5);
                        movement_20_vel2_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_20_velocities_smooth_index_dist{i, f}, 8);                        
                        movement_20_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_20_velocities_smooth_index_dist{i, f}, 4);

                            if isempty(movement_20_velocities_smooth_predata_dist{i, f})
                                movement_20_velocities_smooth_predata_dist{i, f} = NaN;
                                movement_20_vel2_smooth_predata_dist{i, f} = NaN;
                            end

                        movement_20_velocities_smooth_mean_data_dist(i, f) = mean(movement_20_velocities_smooth_predata_dist{i, f});
                        movement_20_velocities_smooth_med_data_dist(i, f) = median(movement_20_velocities_smooth_predata_dist{i, f});
                        movement_20_velocities_smooth_sem_data_dist(i, f) = (std(movement_20_velocities_smooth_predata_dist{i, f})/(sqrt(length(movement_20_velocities_smooth_predata_dist{i, f}))));

                        movement_20_vel2_smooth_mean_data_dist(i, f) = mean(movement_20_vel2_smooth_predata_dist{i, f});
                        movement_20_vel2_smooth_med_data_dist(i, f) = median(movement_20_vel2_smooth_predata_dist{i, f});
                        movement_20_vel2_smooth_sem_data_dist(i, f) = (std(movement_20_vel2_smooth_predata_dist{i, f})/(sqrt(length(movement_20_vel2_smooth_predata_dist{i, f}))));
                        
                        movement_20_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_20_velocities_smooth_index_dist{i, f}, 4);
                        movement_20_licking_smooth_mean_data_dist(i, f) = mean(movement_20_licking_smooth_predata_dist{i, f});
                        movement_20_licking_smooth_med_data_dist(i, f) = median(movement_20_licking_smooth_predata_dist{i, f});
                        movement_20_licking_smooth_sem_data_dist(i, f) = (std(movement_20_licking_smooth_predata_dist{i, f})/(sqrt(length(movement_20_licking_smooth_predata_dist{i, f}))));
                        
                    end

                % rescale data based on time
                movement_20_velocities_lengths_time{i, 1} = stop_cue{i, 1}(movement_20_index{i, :}(end, 1), 6); % to normalize by timeance, collect final timeances
                movement_20_velocities_lengths_time{i, 2} = stop_cue{i, 1}(movement_20_index{i, :}(1, 1), 6); % to normalize by timeance, collect start timeances
                movement_20_velocities_smooth_time{i, :} = linspace(movement_20_velocities_lengths_time{i, 2}, movement_20_velocities_lengths_time{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_20_velocities_smooth_index_time{i, f} = find(stop_cue{i, 1}(movement_20_index{i, :}, 6) >= movement_20_velocities_smooth_time{i, 1}(1, f) & stop_cue{i, 1}(movement_20_index{i, :}, 6) < movement_20_velocities_smooth_time{i, 1}(1, f + 1));
                        movement_20_velocities_smooth_index_time{i, f} = movement_20_index{i, :}(movement_20_velocities_smooth_index_time{i, f}, 1);
                        
                        movement_20_velocities_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_20_velocities_smooth_index_time{i, f}, 5);
                        movement_20_vel2_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_20_velocities_smooth_index_time{i, f}, 8);                        
                        movement_20_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_20_velocities_smooth_index_time{i, f}, 4);

                            if isempty(movement_20_velocities_smooth_predata_time{i, f})
                                movement_20_velocities_smooth_predata_time{i, f} = NaN;
                                movement_20_vel2_smooth_predata_time{i, f} = NaN;
                            end

                        movement_20_velocities_smooth_mean_data_time(i, f) = mean(movement_20_velocities_smooth_predata_time{i, f});
                        movement_20_velocities_smooth_med_data_time(i, f) = median(movement_20_velocities_smooth_predata_time{i, f});
                        movement_20_velocities_smooth_sem_data_time(i, f) = (std(movement_20_velocities_smooth_predata_time{i, f})/(sqrt(length(movement_20_velocities_smooth_predata_time{i, f}))));

                        movement_20_vel2_smooth_mean_data_time(i, f) = mean(movement_20_vel2_smooth_predata_time{i, f});
                        movement_20_vel2_smooth_med_data_time(i, f) = median(movement_20_vel2_smooth_predata_time{i, f});
                        movement_20_vel2_smooth_sem_data_time(i, f) = (std(movement_20_vel2_smooth_predata_time{i, f})/(sqrt(length(movement_20_vel2_smooth_predata_time{i, f}))));
                        
                        movement_20_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_20_velocities_smooth_index_time{i, f}, 4);
                        movement_20_licking_smooth_mean_data_time(i, f) = mean(movement_20_licking_smooth_predata_time{i, f});
                        movement_20_licking_smooth_med_data_time(i, f) = median(movement_20_licking_smooth_predata_time{i, f});
                        movement_20_licking_smooth_sem_data_time(i, f) = (std(movement_20_licking_smooth_predata_time{i, f})/(sqrt(length(movement_20_licking_smooth_predata_time{i, f}))));
                        
                    end


           % else
          catch
                j = smooth_value - 1;

                movement_20_velocities_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_20_velocities_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_20_velocities_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_20_velocities_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_20_velocities_smooth_med_data_time(i, :) = NaN(1,j);
                movement_20_velocities_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_20_vel2_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_20_vel2_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_20_vel2_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_20_vel2_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_20_vel2_smooth_med_data_time(i, :) = NaN(1,j);
                movement_20_vel2_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_20_licking_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_20_licking_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_20_licking_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_20_licking_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_20_licking_smooth_med_data_time(i, :) = NaN(1,j);
                movement_20_licking_smooth_sem_data_time(i, :) = NaN(1,j);

            end


            %if (size(distance40_1{i, 1}, 1) > size_limit) == 1  
            try 
                movement_40_index{i, :} = find(movement_index{i, :} < distance40_1{i, 1}(end, 1) & movement_index{i, :} > distance20_1{i, 1}(end - 2, 1));
                movement_40_index{i, :} = movement_index{i, :}(movement_40_index{i, :}, 1);

                % rescale data based on distance
                movement_40_velocities_lengths_dist{i, 1} = stop_cue{i, 1}(movement_40_index{i, :}(end, 1), 6); % to normalize by distance, collect final distances
                movement_40_velocities_lengths_dist{i, 2} = stop_cue{i, 1}(movement_40_index{i, :}(1, 1), 6); % to normalize by distance, collect start distances
                movement_40_velocities_smooth_dist{i, :} = linspace(movement_40_velocities_lengths_dist{i, 2}, movement_40_velocities_lengths_dist{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_40_velocities_smooth_index_dist{i, f} = find(stop_cue{i, 1}(movement_40_index{i, :}, 6) >= movement_40_velocities_smooth_dist{i, 1}(1, f) & stop_cue{i, 1}(movement_40_index{i, :}, 6) < movement_40_velocities_smooth_dist{i, 1}(1, f + 1));
                        movement_40_velocities_smooth_index_dist{i, f} = movement_40_index{i, :}(movement_40_velocities_smooth_index_dist{i, f}, 1);
                        
                        movement_40_velocities_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_40_velocities_smooth_index_dist{i, f}, 5);
                        movement_40_vel2_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_40_velocities_smooth_index_dist{i, f}, 8);                        
                        movement_40_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_40_velocities_smooth_index_dist{i, f}, 4);

                            if isempty(movement_40_velocities_smooth_predata_dist{i, f})
                                movement_40_velocities_smooth_predata_dist{i, f} = NaN;
                                movement_40_vel2_smooth_predata_dist{i, f} = NaN;
                            end

                        movement_40_velocities_smooth_mean_data_dist(i, f) = mean(movement_40_velocities_smooth_predata_dist{i, f});
                        movement_40_velocities_smooth_med_data_dist(i, f) = median(movement_40_velocities_smooth_predata_dist{i, f});
                        movement_40_velocities_smooth_sem_data_dist(i, f) = (std(movement_40_velocities_smooth_predata_dist{i, f})/(sqrt(length(movement_40_velocities_smooth_predata_dist{i, f}))));

                        movement_40_vel2_smooth_mean_data_dist(i, f) = mean(movement_40_vel2_smooth_predata_dist{i, f});
                        movement_40_vel2_smooth_med_data_dist(i, f) = median(movement_40_vel2_smooth_predata_dist{i, f});
                        movement_40_vel2_smooth_sem_data_dist(i, f) = (std(movement_40_vel2_smooth_predata_dist{i, f})/(sqrt(length(movement_40_vel2_smooth_predata_dist{i, f}))));
                        
                        movement_40_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_40_velocities_smooth_index_dist{i, f}, 4);
                        movement_40_licking_smooth_mean_data_dist(i, f) = mean(movement_40_licking_smooth_predata_dist{i, f});
                        movement_40_licking_smooth_med_data_dist(i, f) = median(movement_40_licking_smooth_predata_dist{i, f});
                        movement_40_licking_smooth_sem_data_dist(i, f) = (std(movement_40_licking_smooth_predata_dist{i, f})/(sqrt(length(movement_40_licking_smooth_predata_dist{i, f}))));
                        
                    end

                % rescale data based on time
                movement_40_velocities_lengths_time{i, 1} = stop_cue{i, 1}(movement_40_index{i, :}(end, 1), 1); % to normalize by time, collect final times
                movement_40_velocities_lengths_time{i, 2} = stop_cue{i, 1}(movement_40_index{i, :}(1, 1), 1); % to normalize by time, collect start times
                movement_40_velocities_smooth_time{i, :} = linspace(movement_40_velocities_lengths_time{i, 2}, movement_40_velocities_lengths_time{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_40_velocities_smooth_index_time{i, f} = find(stop_cue{i, 1}(movement_40_index{i, :}, 6) >= movement_40_velocities_smooth_time{i, 1}(1, f) & stop_cue{i, 1}(movement_40_index{i, :}, 6) < movement_40_velocities_smooth_time{i, 1}(1, f + 1));
                        movement_40_velocities_smooth_index_time{i, f} = movement_40_index{i, :}(movement_40_velocities_smooth_index_time{i, f}, 1);
                        
                        movement_40_velocities_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_40_velocities_smooth_index_time{i, f}, 5);
                        movement_40_vel2_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_40_velocities_smooth_index_time{i, f}, 8);                        
                        movement_40_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_40_velocities_smooth_index_time{i, f}, 4);

                            if isempty(movement_40_velocities_smooth_predata_time{i, f})
                                movement_40_velocities_smooth_predata_time{i, f} = NaN;
                                movement_40_vel2_smooth_predata_time{i, f} = NaN;
                            end

                        movement_40_velocities_smooth_mean_data_time(i, f) = mean(movement_40_velocities_smooth_predata_time{i, f});
                        movement_40_velocities_smooth_med_data_time(i, f) = median(movement_40_velocities_smooth_predata_time{i, f});
                        movement_40_velocities_smooth_sem_data_time(i, f) = (std(movement_40_velocities_smooth_predata_time{i, f})/(sqrt(length(movement_40_velocities_smooth_predata_time{i, f}))));

                        movement_40_vel2_smooth_mean_data_time(i, f) = mean(movement_40_vel2_smooth_predata_time{i, f});
                        movement_40_vel2_smooth_med_data_time(i, f) = median(movement_40_vel2_smooth_predata_time{i, f});
                        movement_40_vel2_smooth_sem_data_time(i, f) = (std(movement_40_vel2_smooth_predata_time{i, f})/(sqrt(length(movement_40_vel2_smooth_predata_time{i, f}))));
                        
                        movement_40_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_40_velocities_smooth_index_time{i, f}, 4);
                        movement_40_licking_smooth_mean_data_time(i, f) = mean(movement_40_licking_smooth_predata_time{i, f});
                        movement_40_licking_smooth_med_data_time(i, f) = median(movement_40_licking_smooth_predata_time{i, f});
                        movement_40_licking_smooth_sem_data_time(i, f) = (std(movement_40_licking_smooth_predata_time{i, f})/(sqrt(length(movement_40_licking_smooth_predata_time{i, f}))));
                        
                    end

           % else
            catch
                j = smooth_value - 1;

                movement_40_velocities_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_40_velocities_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_40_velocities_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_40_velocities_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_40_velocities_smooth_med_data_time(i, :) = NaN(1,j);
                movement_40_velocities_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_40_vel2_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_40_vel2_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_40_vel2_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_40_vel2_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_40_vel2_smooth_med_data_time(i, :) = NaN(1,j);
                movement_40_vel2_smooth_sem_data_time(i, :) = NaN(1,j);
                
                movement_40_licking_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_40_licking_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_40_licking_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_40_licking_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_40_licking_smooth_med_data_time(i, :) = NaN(1,j);
                movement_40_licking_smooth_sem_data_time(i, :) = NaN(1,j);

            end

            %if (size(distance60_1{i, 1}, 1) > size_limit) == 1  
            try

                movement_60_index{i, :} = find(movement_index{i, :} < distance60_1{i, 1}(end, 1) & movement_index{i, :} > distance40_1{i, 1}(end - 2, 1));
                movement_60_index{i, :} = movement_index{i, :}(movement_60_index{i, :}, 1);

                % rescale data based on distance
                movement_60_velocities_lengths_dist{i, 1} = stop_cue{i, 1}(movement_60_index{i, :}(end, 1), 6); % to normalize by distance, collect final distances
                movement_60_velocities_lengths_dist{i, 2} = stop_cue{i, 1}(movement_60_index{i, :}(1, 1), 6); % to normalize by distance, collect start distances
                movement_60_velocities_smooth_dist{i, :} = linspace(movement_60_velocities_lengths_dist{i, 2}, movement_60_velocities_lengths_dist{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_60_velocities_smooth_index_dist{i, f} = find(stop_cue{i, 1}(movement_60_index{i, :}, 6) >= movement_60_velocities_smooth_dist{i, 1}(1, f) & stop_cue{i, 1}(movement_60_index{i, :}, 6) < movement_60_velocities_smooth_dist{i, 1}(1, f + 1));
                        movement_60_velocities_smooth_index_dist{i, f} = movement_60_index{i, :}(movement_60_velocities_smooth_index_dist{i, f}, 1);
                        
                        movement_60_velocities_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_60_velocities_smooth_index_dist{i, f}, 5);
                        movement_60_vel2_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_60_velocities_smooth_index_dist{i, f}, 8);                        
                        movement_60_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_60_velocities_smooth_index_dist{i, f}, 4);

                            if isempty(movement_60_velocities_smooth_predata_dist{i, f})
                                movement_60_velocities_smooth_predata_dist{i, f} = NaN;
                                movement_60_vel2_smooth_predata_dist{i, f} = NaN;
                            end

                        movement_60_velocities_smooth_mean_data_dist(i, f) = mean(movement_60_velocities_smooth_predata_dist{i, f});
                        movement_60_velocities_smooth_med_data_dist(i, f) = median(movement_60_velocities_smooth_predata_dist{i, f});
                        movement_60_velocities_smooth_sem_data_dist(i, f) = (std(movement_60_velocities_smooth_predata_dist{i, f})/(sqrt(length(movement_60_velocities_smooth_predata_dist{i, f}))));

                        movement_60_vel2_smooth_mean_data_dist(i, f) = mean(movement_60_vel2_smooth_predata_dist{i, f});
                        movement_60_vel2_smooth_med_data_dist(i, f) = median(movement_60_vel2_smooth_predata_dist{i, f});
                        movement_60_vel2_smooth_sem_data_dist(i, f) = (std(movement_60_vel2_smooth_predata_dist{i, f})/(sqrt(length(movement_60_vel2_smooth_predata_dist{i, f}))));
                        
                        movement_60_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_60_velocities_smooth_index_dist{i, f}, 4);
                        movement_60_licking_smooth_mean_data_dist(i, f) = mean(movement_60_licking_smooth_predata_dist{i, f});
                        movement_60_licking_smooth_med_data_dist(i, f) = median(movement_60_licking_smooth_predata_dist{i, f});
                        movement_60_licking_smooth_sem_data_dist(i, f) = (std(movement_60_licking_smooth_predata_dist{i, f})/(sqrt(length(movement_60_licking_smooth_predata_dist{i, f}))));
                        
                    end

                % rescale data based on time
                movement_60_velocities_lengths_time{i, 1} = stop_cue{i, 1}(movement_60_index{i, :}(end, 1), 1); % to normalize by time, collect final times
                movement_60_velocities_lengths_time{i, 2} = stop_cue{i, 1}(movement_60_index{i, :}(1, 1), 1); % to normalize by time, collect start times
                movement_60_velocities_smooth_time{i, :} = linspace(movement_60_velocities_lengths_time{i, 2}, movement_60_velocities_lengths_time{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_60_velocities_smooth_index_time{i, f} = find(stop_cue{i, 1}(movement_60_index{i, :}, 6) >= movement_60_velocities_smooth_time{i, 1}(1, f) & stop_cue{i, 1}(movement_60_index{i, :}, 6) < movement_60_velocities_smooth_time{i, 1}(1, f + 1));
                        movement_60_velocities_smooth_index_time{i, f} = movement_60_index{i, :}(movement_60_velocities_smooth_index_time{i, f}, 1);
                        
                        movement_60_velocities_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_60_velocities_smooth_index_time{i, f}, 5);
                        movement_60_vel2_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_60_velocities_smooth_index_time{i, f}, 8);                        
                        movement_60_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_60_velocities_smooth_index_time{i, f}, 4);

                            if isempty(movement_60_velocities_smooth_predata_time{i, f})
                                movement_60_velocities_smooth_predata_time{i, f} = NaN;
                                movement_60_vel2_smooth_predata_time{i, f} = NaN;
                            end

                        movement_60_velocities_smooth_mean_data_time(i, f) = mean(movement_60_velocities_smooth_predata_time{i, f});
                        movement_60_velocities_smooth_med_data_time(i, f) = median(movement_60_velocities_smooth_predata_time{i, f});
                        movement_60_velocities_smooth_sem_data_time(i, f) = (std(movement_60_velocities_smooth_predata_time{i, f})/(sqrt(length(movement_60_velocities_smooth_predata_time{i, f}))));

                        movement_60_vel2_smooth_mean_data_time(i, f) = mean(movement_60_vel2_smooth_predata_time{i, f});
                        movement_60_vel2_smooth_med_data_time(i, f) = median(movement_60_vel2_smooth_predata_time{i, f});
                        movement_60_vel2_smooth_sem_data_time(i, f) = (std(movement_60_vel2_smooth_predata_time{i, f})/(sqrt(length(movement_60_vel2_smooth_predata_time{i, f}))));
                        
                        movement_60_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_60_velocities_smooth_index_time{i, f}, 4);
                        movement_60_licking_smooth_mean_data_time(i, f) = mean(movement_60_licking_smooth_predata_time{i, f});
                        movement_60_licking_smooth_med_data_time(i, f) = median(movement_60_licking_smooth_predata_time{i, f});
                        movement_60_licking_smooth_sem_data_time(i, f) = (std(movement_60_licking_smooth_predata_time{i, f})/(sqrt(length(movement_60_licking_smooth_predata_time{i, f}))));
                        
                    end

           % else
            catch
                j = smooth_value - 1;

                movement_60_velocities_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_60_velocities_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_60_velocities_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_60_velocities_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_60_velocities_smooth_med_data_time(i, :) = NaN(1,j);
                movement_60_velocities_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_60_vel2_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_60_vel2_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_60_vel2_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_60_vel2_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_60_vel2_smooth_med_data_time(i, :) = NaN(1,j);
                movement_60_vel2_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_60_licking_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_60_licking_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_60_licking_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_60_licking_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_60_licking_smooth_med_data_time(i, :) = NaN(1,j);
                movement_60_licking_smooth_sem_data_time(i, :) = NaN(1,j);

            end

            %if (size(distance80_1{i, 1}, 1) > size_limit) == 1  
             try
                movement_80_index{i, :} = find(movement_index{i, :} < distance80_1{i, 1}(end, 1) & movement_index{i, :} > distance60_1{i, 1}(end - 2, 1));
                movement_80_index{i, :} = movement_index{i, :}(movement_80_index{i, :}, 1);

                % rescale data based on distance
                movement_80_velocities_lengths_dist{i, 1} = stop_cue{i, 1}(movement_80_index{i, :}(end, 1), 6); % to normalize by distance, collect final distances
                movement_80_velocities_lengths_dist{i, 2} = stop_cue{i, 1}(movement_80_index{i, :}(1, 1), 6); % to normalize by distance, collect start distances
                movement_80_velocities_smooth_dist{i, :} = linspace(movement_80_velocities_lengths_dist{i, 2}, movement_80_velocities_lengths_dist{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_80_velocities_smooth_index_dist{i, f} = find(stop_cue{i, 1}(movement_80_index{i, :}, 6) >= movement_80_velocities_smooth_dist{i, 1}(1, f) & stop_cue{i, 1}(movement_80_index{i, :}, 6) < movement_80_velocities_smooth_dist{i, 1}(1, f + 1));
                        movement_80_velocities_smooth_index_dist{i, f} = movement_80_index{i, :}(movement_80_velocities_smooth_index_dist{i, f}, 1);
                        
                        movement_80_velocities_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_80_velocities_smooth_index_dist{i, f}, 5);
                        movement_80_vel2_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_80_velocities_smooth_index_dist{i, f}, 8);                        
                        movement_80_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_80_velocities_smooth_index_dist{i, f}, 4);

                            if isempty(movement_80_velocities_smooth_predata_dist{i, f})
                                movement_80_velocities_smooth_predata_dist{i, f} = NaN;
                                movement_80_vel2_smooth_predata_dist{i, f} = NaN;
                            end

                        movement_80_velocities_smooth_mean_data_dist(i, f) = mean(movement_80_velocities_smooth_predata_dist{i, f});
                        movement_80_velocities_smooth_med_data_dist(i, f) = median(movement_80_velocities_smooth_predata_dist{i, f});
                        movement_80_velocities_smooth_sem_data_dist(i, f) = (std(movement_80_velocities_smooth_predata_dist{i, f})/(sqrt(length(movement_80_velocities_smooth_predata_dist{i, f}))));

                        movement_80_vel2_smooth_mean_data_dist(i, f) = mean(movement_80_vel2_smooth_predata_dist{i, f});
                        movement_80_vel2_smooth_med_data_dist(i, f) = median(movement_80_vel2_smooth_predata_dist{i, f});
                        movement_80_vel2_smooth_sem_data_dist(i, f) = (std(movement_80_vel2_smooth_predata_dist{i, f})/(sqrt(length(movement_80_vel2_smooth_predata_dist{i, f}))));
                        
                        movement_80_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_80_velocities_smooth_index_dist{i, f}, 4);
                        movement_80_licking_smooth_mean_data_dist(i, f) = mean(movement_80_licking_smooth_predata_dist{i, f});
                        movement_80_licking_smooth_med_data_dist(i, f) = median(movement_80_licking_smooth_predata_dist{i, f});
                        movement_80_licking_smooth_sem_data_dist(i, f) = (std(movement_80_licking_smooth_predata_dist{i, f})/(sqrt(length(movement_80_licking_smooth_predata_dist{i, f}))));
                        
                    end

                % rescale data based on time
                movement_80_velocities_lengths_time{i, 1} = stop_cue{i, 1}(movement_80_index{i, :}(end, 1), 1); % to normalize by time, collect final times
                movement_80_velocities_lengths_time{i, 2} = stop_cue{i, 1}(movement_80_index{i, :}(1, 1), 1); % to normalize by time, collect start times
                movement_80_velocities_smooth_time{i, :} = linspace(movement_80_velocities_lengths_time{i, 2}, movement_80_velocities_lengths_time{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_80_velocities_smooth_index_time{i, f} = find(stop_cue{i, 1}(movement_80_index{i, :}, 6) >= movement_80_velocities_smooth_time{i, 1}(1, f) & stop_cue{i, 1}(movement_80_index{i, :}, 6) < movement_80_velocities_smooth_time{i, 1}(1, f + 1));
                        movement_80_velocities_smooth_index_time{i, f} = movement_80_index{i, :}(movement_80_velocities_smooth_index_time{i, f}, 1);
                        
                        movement_80_velocities_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_80_velocities_smooth_index_time{i, f}, 5);
                        movement_80_vel2_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_80_velocities_smooth_index_time{i, f}, 8);                        
                        movement_80_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_80_velocities_smooth_index_time{i, f}, 4);

                            if isempty(movement_80_velocities_smooth_predata_time{i, f})
                                movement_80_velocities_smooth_predata_time{i, f} = NaN;
                                movement_80_vel2_smooth_predata_time{i, f} = NaN;
                            end

                        movement_80_velocities_smooth_mean_data_time(i, f) = mean(movement_80_velocities_smooth_predata_time{i, f});
                        movement_80_velocities_smooth_med_data_time(i, f) = median(movement_80_velocities_smooth_predata_time{i, f});
                        movement_80_velocities_smooth_sem_data_time(i, f) = (std(movement_80_velocities_smooth_predata_time{i, f})/(sqrt(length(movement_80_velocities_smooth_predata_time{i, f}))));

                        movement_80_vel2_smooth_mean_data_time(i, f) = mean(movement_80_vel2_smooth_predata_time{i, f});
                        movement_80_vel2_smooth_med_data_time(i, f) = median(movement_80_vel2_smooth_predata_time{i, f});
                        movement_80_vel2_smooth_sem_data_time(i, f) = (std(movement_80_vel2_smooth_predata_time{i, f})/(sqrt(length(movement_80_vel2_smooth_predata_time{i, f}))));
                        
                        movement_80_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_80_velocities_smooth_index_time{i, f}, 4);
                        movement_80_licking_smooth_mean_data_time(i, f) = mean(movement_80_licking_smooth_predata_time{i, f});
                        movement_80_licking_smooth_med_data_time(i, f) = median(movement_80_licking_smooth_predata_time{i, f});
                        movement_80_licking_smooth_sem_data_time(i, f) = (std(movement_80_licking_smooth_predata_time{i, f})/(sqrt(length(movement_80_licking_smooth_predata_time{i, f}))));
                        
                    end

            %else
             catch
                j = smooth_value - 1;

                movement_80_velocities_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_80_velocities_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_80_velocities_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_80_velocities_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_80_velocities_smooth_med_data_time(i, :) = NaN(1,j);
                movement_80_velocities_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_80_vel2_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_80_vel2_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_80_vel2_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_80_vel2_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_80_vel2_smooth_med_data_time(i, :) = NaN(1,j);
                movement_80_vel2_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_80_licking_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_80_licking_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_80_licking_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_80_licking_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_80_licking_smooth_med_data_time(i, :) = NaN(1,j);
                movement_80_licking_smooth_sem_data_time(i, :) = NaN(1,j);

            end

            %if (size(distance100_1{i, 1}, 1) > size_limit) == 1
            try
                movement_100_index{i, :} = find(movement_index{i, :} < distance100_1{i, 1}(end, 1) & movement_index{i, :} > distance80_1{i, 1}(end - 2, 1));
                movement_100_index{i, :} = movement_index{i, :}(movement_100_index{i, :}, 1);

                % rescale data based on distance
                movement_100_velocities_lengths_dist{i, 1} = stop_cue{i, 1}(movement_100_index{i, :}(end, 1), 6); % to normalize by distance, collect final distances
                movement_100_velocities_lengths_dist{i, 2} = stop_cue{i, 1}(movement_100_index{i, :}(1, 1), 6); % to normalize by distance, collect start distances
                movement_100_velocities_smooth_dist{i, :} = linspace(movement_100_velocities_lengths_dist{i, 2}, movement_100_velocities_lengths_dist{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_100_velocities_smooth_index_dist{i, f} = find(stop_cue{i, 1}(movement_100_index{i, :}, 6) >= movement_100_velocities_smooth_dist{i, 1}(1, f) & stop_cue{i, 1}(movement_100_index{i, :}, 6) < movement_100_velocities_smooth_dist{i, 1}(1, f + 1));
                        movement_100_velocities_smooth_index_dist{i, f} = movement_100_index{i, :}(movement_100_velocities_smooth_index_dist{i, f}, 1);
                        
                        movement_100_velocities_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_100_velocities_smooth_index_dist{i, f}, 5);
                        movement_100_vel2_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_100_velocities_smooth_index_dist{i, f}, 8);                        
                        movement_100_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_100_velocities_smooth_index_dist{i, f}, 4);

                            if isempty(movement_100_velocities_smooth_predata_dist{i, f})
                                movement_100_velocities_smooth_predata_dist{i, f} = NaN;
                                movement_100_vel2_smooth_predata_dist{i, f} = NaN;
                            end

                        movement_100_velocities_smooth_mean_data_dist(i, f) = mean(movement_100_velocities_smooth_predata_dist{i, f});
                        movement_100_velocities_smooth_med_data_dist(i, f) = median(movement_100_velocities_smooth_predata_dist{i, f});
                        movement_100_velocities_smooth_sem_data_dist(i, f) = (std(movement_100_velocities_smooth_predata_dist{i, f})/(sqrt(length(movement_100_velocities_smooth_predata_dist{i, f}))));

                        movement_100_vel2_smooth_mean_data_dist(i, f) = mean(movement_100_vel2_smooth_predata_dist{i, f});
                        movement_100_vel2_smooth_med_data_dist(i, f) = median(movement_100_vel2_smooth_predata_dist{i, f});
                        movement_100_vel2_smooth_sem_data_dist(i, f) = (std(movement_100_vel2_smooth_predata_dist{i, f})/(sqrt(length(movement_100_vel2_smooth_predata_dist{i, f}))));
                        
                        movement_100_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_100_velocities_smooth_index_dist{i, f}, 4);
                        movement_100_licking_smooth_mean_data_dist(i, f) = mean(movement_100_licking_smooth_predata_dist{i, f});
                        movement_100_licking_smooth_med_data_dist(i, f) = median(movement_100_licking_smooth_predata_dist{i, f});
                        movement_100_licking_smooth_sem_data_dist(i, f) = (std(movement_100_licking_smooth_predata_dist{i, f})/(sqrt(length(movement_100_licking_smooth_predata_dist{i, f}))));
                        
                    end

                % rescale data based on time
                movement_100_velocities_lengths_time{i, 1} = stop_cue{i, 1}(movement_100_index{i, :}(end, 1), 1); % to normalize by time, collect final times
                movement_100_velocities_lengths_time{i, 2} = stop_cue{i, 1}(movement_100_index{i, :}(1, 1), 1); % to normalize by time, collect start times
                movement_100_velocities_smooth_time{i, :} = linspace(movement_100_velocities_lengths_time{i, 2}, movement_100_velocities_lengths_time{i, 1}, smooth_value);

                    for f = 1:(smooth_value - 1)

                        movement_100_velocities_smooth_index_time{i, f} = find(stop_cue{i, 1}(movement_100_index{i, :}, 6) >= movement_100_velocities_smooth_time{i, 1}(1, f) & stop_cue{i, 1}(movement_100_index{i, :}, 6) < movement_100_velocities_smooth_time{i, 1}(1, f + 1));
                        movement_100_velocities_smooth_index_time{i, f} = movement_100_index{i, :}(movement_100_velocities_smooth_index_time{i, f}, 1);
                        
                        movement_100_velocities_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_100_velocities_smooth_index_time{i, f}, 5);
                        movement_100_vel2_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_100_velocities_smooth_index_time{i, f}, 8);                        
                        movement_100_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_100_velocities_smooth_index_time{i, f}, 4);

                            if isempty(movement_100_velocities_smooth_predata_time{i, f})
                                movement_100_velocities_smooth_predata_time{i, f} = NaN;
                                movement_100_vel2_smooth_predata_time{i, f} = NaN;
                            end

                        movement_100_velocities_smooth_mean_data_time(i, f) = mean(movement_100_velocities_smooth_predata_time{i, f});
                        movement_100_velocities_smooth_med_data_time(i, f) = median(movement_100_velocities_smooth_predata_time{i, f});
                        movement_100_velocities_smooth_sem_data_time(i, f) = (std(movement_100_velocities_smooth_predata_time{i, f})/(sqrt(length(movement_100_velocities_smooth_predata_time{i, f}))));

                        movement_100_vel2_smooth_mean_data_time(i, f) = mean(movement_100_vel2_smooth_predata_time{i, f});
                        movement_100_vel2_smooth_med_data_time(i, f) = median(movement_100_vel2_smooth_predata_time{i, f});
                        movement_100_vel2_smooth_sem_data_time(i, f) = (std(movement_100_vel2_smooth_predata_time{i, f})/(sqrt(length(movement_100_vel2_smooth_predata_time{i, f}))));
                        
                        movement_100_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_100_velocities_smooth_index_time{i, f}, 4);
                        movement_100_licking_smooth_mean_data_time(i, f) = mean(movement_100_licking_smooth_predata_time{i, f});
                        movement_100_licking_smooth_med_data_time(i, f) = median(movement_100_licking_smooth_predata_time{i, f});
                        movement_100_licking_smooth_sem_data_time(i, f) = (std(movement_100_licking_smooth_predata_time{i, f})/(sqrt(length(movement_100_licking_smooth_predata_time{i, f}))));
                        
                    end

            %else
            catch
                j = smooth_value - 1;

                movement_100_velocities_lengths_dist{i, 1} = [];

                movement_100_velocities_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_100_velocities_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_100_velocities_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_100_velocities_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_100_velocities_smooth_med_data_time(i, :) = NaN(1,j);
                movement_100_velocities_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_100_vel2_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_100_vel2_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_100_vel2_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_100_vel2_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_100_vel2_smooth_med_data_time(i, :) = NaN(1,j);
                movement_100_vel2_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_100_licking_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_100_licking_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_100_licking_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_100_licking_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_100_licking_smooth_med_data_time(i, :) = NaN(1,j);
                movement_100_licking_smooth_sem_data_time(i, :) = NaN(1,j);

            end
        
           %if (size(distanceslow_1{i, 1}, 1) > size_limit) == 1
           try
                movement_slow_index{i, :} = find(movement_index{i, :} < distanceslow_1{i, 1}(end, 1) & movement_index{i, :} > distance100_1{i, 1}(end, 1));
                movement_slow_index{i, :} = movement_index{i, :}(movement_slow_index{i, :}, 1);
                % rescale data based on distance
                movement_slow_velocities_lengths_dist{i, 1} = stop_cue{i, 1}(movement_slow_index{i, :}(end, 1), 6); % to normalize by distance, collect final distances
                movement_slow_velocities_lengths_dist{i, 2} = stop_cue{i, 1}(movement_slow_index{i, :}(1, 1), 6); % to normalize by distance, collect start distances
                movement_slow_velocities_smooth_dist{i, :} = linspace(movement_slow_velocities_lengths_dist{i, 2}, movement_slow_velocities_lengths_dist{i, 1}, smooth_value_slow);

                total_slowdown_velocities{i, 1} = stop_cue{i, 1}(movement_slow_index{i, :}, 5);
                total_slowdown_vel2{i, 1} = stop_cue{i, 1}(movement_slow_index{i, :}, 8);

                    % if  length(total_slowdown_velocities{i, 1}) > 3
                    %  ttt = [1:length(total_slowdown_velocities{i, 1})]';
                    %    p = fitlm(ttt, total_slowdown_velocities{i, 1}, 'poly1');   
                    %    total_slowdown_velocity_metrics(i, 1) = table2array(p.Coefficients(2, 1));
                    %    total_slowdown_velocity_metrics(i, 2) = table2array(p.Coefficients(2, 4));
                    % else
                    %     total_slowdown_velocity_metrics(i, 1) = NaN;
                    %     total_slowdown_velocity_metrics(i, 2) = NaN;
                    % end   
                        
                        
                    for f = 1:(smooth_value_slow - 1)

                        movement_slow_velocities_smooth_index_dist{i, f} = find(stop_cue{i, 1}(movement_slow_index{i, :}, 6) >= movement_slow_velocities_smooth_dist{i, 1}(1, f) & stop_cue{i, 1}(movement_slow_index{i, :}, 6) < movement_slow_velocities_smooth_dist{i, 1}(1, f + 1));
                        movement_slow_velocities_smooth_index_dist{i, f} = movement_slow_index{i, :}(movement_slow_velocities_smooth_index_dist{i, f}, 1);
                        
                        movement_slow_velocities_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_slow_velocities_smooth_index_dist{i, f}, 5);
                        movement_slow_vel2_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_slow_velocities_smooth_index_dist{i, f}, 8);                        
                        movement_slow_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_slow_velocities_smooth_index_dist{i, f}, 4);

                            if isempty(movement_slow_velocities_smooth_predata_dist{i, f})
                                movement_slow_velocities_smooth_predata_dist{i, f} = NaN;
                                movement_slow_vel2_smooth_predata_dist{i, f} = NaN;
                            end

                        movement_slow_velocities_smooth_mean_data_dist(i, f) = mean(movement_slow_velocities_smooth_predata_dist{i, f});
                        movement_slow_velocities_smooth_med_data_dist(i, f) = median(movement_slow_velocities_smooth_predata_dist{i, f});
                        movement_slow_velocities_smooth_sem_data_dist(i, f) = (std(movement_slow_velocities_smooth_predata_dist{i, f})/(sqrt(length(movement_slow_velocities_smooth_predata_dist{i, f}))));

                        movement_slow_vel2_smooth_mean_data_dist(i, f) = mean(movement_slow_vel2_smooth_predata_dist{i, f});
                        movement_slow_vel2_smooth_med_data_dist(i, f) = median(movement_slow_vel2_smooth_predata_dist{i, f});
                        movement_slow_vel2_smooth_sem_data_dist(i, f) = (std(movement_slow_vel2_smooth_predata_dist{i, f})/(sqrt(length(movement_slow_vel2_smooth_predata_dist{i, f}))));
                        
                        movement_slow_licking_smooth_predata_dist{i, f} = stop_cue{i, 1}(movement_slow_velocities_smooth_index_dist{i, f}, 4);
                        movement_slow_licking_smooth_mean_data_dist(i, f) = mean(movement_slow_licking_smooth_predata_dist{i, f});
                        movement_slow_licking_smooth_med_data_dist(i, f) = median(movement_slow_licking_smooth_predata_dist{i, f});
                        movement_slow_licking_smooth_sem_data_dist(i, f) = (std(movement_slow_licking_smooth_predata_dist{i, f})/(sqrt(length(movement_slow_licking_smooth_predata_dist{i, f}))));
                        
                    end

                % rescale data based on time
                movement_slow_velocities_lengths_time{i, 1} = stop_cue{i, 1}(movement_slow_index{i, :}(end, 1), 1); % to normalize by time, collect final times
                movement_slow_velocities_lengths_time{i, 2} = stop_cue{i, 1}(movement_slow_index{i, :}(1, 1), 1); % to normalize by time, collect start times
                movement_slow_velocities_smooth_time{i, :} = linspace(movement_slow_velocities_lengths_time{i, 2}, movement_slow_velocities_lengths_time{i, 1}, smooth_value_slow);

                    for f = 1:(smooth_value_slow - 1)

                        movement_slow_velocities_smooth_index_time{i, f} = find(stop_cue{i, 1}(movement_slow_index{i, :}, 6) >= movement_slow_velocities_smooth_time{i, 1}(1, f) & stop_cue{i, 1}(movement_slow_index{i, :}, 6) < movement_slow_velocities_smooth_time{i, 1}(1, f + 1));
                        movement_slow_velocities_smooth_index_time{i, f} = movement_slow_index{i, :}(movement_slow_velocities_smooth_index_time{i, f}, 1);
                        
                        movement_slow_velocities_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_slow_velocities_smooth_index_time{i, f}, 5);
                        movement_slow_vel2_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_slow_velocities_smooth_index_time{i, f}, 8);                        
                        movement_slow_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_slow_velocities_smooth_index_time{i, f}, 4);

                            if isempty(movement_slow_velocities_smooth_predata_time{i, f})
                                movement_slow_velocities_smooth_predata_time{i, f} = NaN;
                                movement_slow_vel2_smooth_predata_time{i, f} = NaN;
                            end

                        movement_slow_velocities_smooth_mean_data_time(i, f) = mean(movement_slow_velocities_smooth_predata_time{i, f});
                        movement_slow_velocities_smooth_med_data_time(i, f) = median(movement_slow_velocities_smooth_predata_time{i, f});
                        movement_slow_velocities_smooth_sem_data_time(i, f) = (std(movement_slow_velocities_smooth_predata_time{i, f})/(sqrt(length(movement_slow_velocities_smooth_predata_time{i, f}))));

                        movement_slow_vel2_smooth_mean_data_time(i, f) = mean(movement_slow_vel2_smooth_predata_time{i, f});
                        movement_slow_vel2_smooth_med_data_time(i, f) = median(movement_slow_vel2_smooth_predata_time{i, f});
                        movement_slow_vel2_smooth_sem_data_time(i, f) = (std(movement_slow_vel2_smooth_predata_time{i, f})/(sqrt(length(movement_slow_vel2_smooth_predata_time{i, f}))));
                        
                        movement_slow_licking_smooth_predata_time{i, f} = stop_cue{i, 1}(movement_slow_velocities_smooth_index_time{i, f}, 4);
                        movement_slow_licking_smooth_mean_data_time(i, f) = mean(movement_slow_licking_smooth_predata_time{i, f});
                        movement_slow_licking_smooth_med_data_time(i, f) = median(movement_slow_licking_smooth_predata_time{i, f});
                        movement_slow_licking_smooth_sem_data_time(i, f) = (std(movement_slow_licking_smooth_predata_time{i, f})/(sqrt(length(movement_slow_licking_smooth_predata_time{i, f}))));
                        
                    end
                  
%                     lick_rate_slowdown_time_total{i, 1} = movement_slow_velocities_lengths_time{i, 1} - movement_slow_velocities_lengths_time{i, 2};
%                     lick_rate_slowdown_time_total{i, 2} = movement_slow_velocities_lengths_time{i, 2} - stop_cue{i, 1}(1, 1);
%             
%                     lick_rate_slowdown_time_total{i, 1} = movement_slow_velocities_lengths_time{i, 1} - movement_slow_velocities_lengths_time{i, 2};
%                     lick_rate_slowdown_time_total{i, 2} = movement_slow_velocities_lengths_time{i, 2} - lick_rate_slowdown_time_total{i, 1};
%                     lick_rate_slowdown_time_total{i, 3} = find(stop_cue{i, 1}(:, 1) > lick_rate_slowdown_time_total{i, 2});
%                     lick_rate_slowdown_time_total{i, 4}(:, :) = find(stop_cue{i, 1}(:, 1) < movement_slow_velocities_lengths_time{i, 2});
%                     lick_rate_slowdown_time_total{i, 5}(:, :) = intersect(lick_rate_slowdown_time_total{i, 3}(:, :), lick_rate_slowdown_time_total{i, 4}(:, :) );
                  
            %else
           catch
                j = smooth_value_slow - 1;

                movement_slow_velocities_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_slow_velocities_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_slow_velocities_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_slow_velocities_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_slow_velocities_smooth_med_data_time(i, :) = NaN(1,j);
                movement_slow_velocities_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_slow_vel2_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_slow_vel2_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_slow_vel2_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_slow_vel2_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_slow_vel2_smooth_med_data_time(i, :) = NaN(1,j);
                movement_slow_vel2_smooth_sem_data_time(i, :) = NaN(1,j);

                movement_slow_licking_smooth_mean_data_dist(i, :) = NaN(1,j);
                movement_slow_licking_smooth_med_data_dist(i, :) = NaN(1,j);
                movement_slow_licking_smooth_sem_data_dist(i, :) = NaN(1,j);

                movement_slow_licking_smooth_mean_data_time(i, :) = NaN(1,j);
                movement_slow_licking_smooth_med_data_time(i, :) = NaN(1,j);
                movement_slow_licking_smooth_sem_data_time(i, :) = NaN(1,j);
                
                total_slowdown_velocities{i, 1} = NaN;
                total_slowdown_vel2{i, 1} = NaN;

                total_slowdown_velocity_metrics(i, 1) = NaN;
                total_slowdown_velocity_metrics(i, 2) = NaN;
                
                
            end

            
                if (size(slowdown_period_index{i, 1}, 1) > size_limit) == 1 & ~isempty(movement_100_velocities_lengths_dist{i, 2})   
                    
                    if (size(go_index{i, 1}, 1) > 0) == 1
                        running_period_T5_distance(i, :) = (movement_100_velocities_lengths_dist{i, 2} - stop_cue{i, 1}(go_index{i, :}, 6)) / 10; % in cm
                        running_period_T5_time(i, :) = (movement_100_velocities_lengths_time{i, 2} - stop_cue{i, 1}(go_index{i, :}, 1)) / 1000000; % time in seconds
                    else
                       running_period_T5_distance(i, :) = NaN;
                       running_period_T5_time(i, :) = NaN;
                       
                    end
                    
                    if index_reward{i, 1} > 0
                        T5_distance_to_reward(i, :) = (stop_cue{i, 1}(index_reward{i, :}, 6) - movement_100_velocities_lengths_dist{i, 2}) / 10; % in cm
                        T5_time_to_reward(i, :) = (stop_cue{i, 1}(index_reward{i, :}, 1) - movement_100_velocities_lengths_time{i, 2}) / 1000000; % time in seconds
   
                    else
                        T5_distance_to_reward(i, :) = NaN;
                        T5_time_to_reward(i, :) =  NaN;
                    end

                else
                 
                    T5_distance_to_reward(i, :) = NaN;
                    T5_time_to_reward(i, :) =  NaN;
                    running_period_T5_distance(i, :) = NaN;
                    running_period_T5_time(i, :) = NaN;

                end           
            
        movement_velocities_smooth_mean_dist(i, :) = [movement_20_velocities_smooth_mean_data_dist(i, :) movement_40_velocities_smooth_mean_data_dist(i, :) movement_60_velocities_smooth_mean_data_dist(i, :) movement_80_velocities_smooth_mean_data_dist(i, :) movement_100_velocities_smooth_mean_data_dist(i, :) movement_slow_velocities_smooth_mean_data_dist(i, :)];
        movement_velocities_smooth_med_dist(i, :) = [movement_20_velocities_smooth_med_data_dist(i, :) movement_40_velocities_smooth_med_data_dist(i, :) movement_60_velocities_smooth_med_data_dist(i, :) movement_80_velocities_smooth_med_data_dist(i, :) movement_100_velocities_smooth_med_data_dist(i, :) movement_slow_velocities_smooth_med_data_dist(i, :)];
        movement_velocities_smooth_mean_time(i, :) = [movement_20_velocities_smooth_mean_data_time(i, :) movement_40_velocities_smooth_mean_data_time(i, :) movement_60_velocities_smooth_mean_data_time(i, :) movement_80_velocities_smooth_mean_data_time(i, :) movement_100_velocities_smooth_mean_data_time(i, :) movement_slow_velocities_smooth_mean_data_time(i, :)];
        movement_velocities_smooth_med_time(i, :) = [movement_20_velocities_smooth_med_data_time(i, :) movement_40_velocities_smooth_med_data_time(i, :) movement_60_velocities_smooth_med_data_time(i, :) movement_80_velocities_smooth_med_data_time(i, :) movement_100_velocities_smooth_med_data_time(i, :) movement_slow_velocities_smooth_med_data_time(i, :)];
        slowdown_velocities_smooth_mean_time(i, :) = [movement_100_velocities_smooth_mean_data_time(i, :) movement_slow_velocities_smooth_mean_data_time(i, :)];
        slowdown_only_velocities_smooth_mean_time(i, :) = [movement_slow_velocities_smooth_mean_data_time(i, :)];    
        movement_licking_smooth_mean_dist(i, :) = [movement_20_licking_smooth_mean_data_dist(i, :) movement_40_licking_smooth_mean_data_dist(i, :) movement_60_licking_smooth_mean_data_dist(i, :) movement_80_licking_smooth_mean_data_dist(i, :) movement_100_licking_smooth_mean_data_dist(i, :) movement_slow_licking_smooth_mean_data_dist(i, :)];
        movement_licking_smooth_med_dist(i, :) = [movement_20_licking_smooth_med_data_dist(i, :) movement_40_licking_smooth_med_data_dist(i, :) movement_60_licking_smooth_med_data_dist(i, :) movement_80_licking_smooth_med_data_dist(i, :) movement_100_licking_smooth_med_data_dist(i, :) movement_slow_licking_smooth_med_data_dist(i, :)];
        movement_licking_smooth_mean_time(i, :) = [movement_20_licking_smooth_mean_data_time(i, :) movement_40_licking_smooth_mean_data_time(i, :) movement_60_licking_smooth_mean_data_time(i, :) movement_80_licking_smooth_mean_data_time(i, :) movement_100_licking_smooth_mean_data_time(i, :) movement_slow_licking_smooth_mean_data_time(i, :)];
        movement_licking_smooth_med_time(i, :) = [movement_20_licking_smooth_med_data_time(i, :) movement_40_licking_smooth_med_data_time(i, :) movement_60_licking_smooth_med_data_time(i, :) movement_80_licking_smooth_med_data_time(i, :) movement_100_licking_smooth_med_data_time(i, :) movement_slow_licking_smooth_med_data_time(i, :)];
        slowdown_licking_smooth_mean_time(i, :) = [movement_100_licking_smooth_mean_data_time(i, :) movement_slow_licking_smooth_mean_data_time(i, :)];
        slowdown_only_licking_smooth_mean_time(i, :) = [movement_slow_licking_smooth_mean_data_time(i, :)];       
        movement_velocities_maintain_dist(i, :) = [movement_40_velocities_smooth_mean_data_dist(i, :) movement_60_velocities_smooth_mean_data_dist(i, :) movement_80_velocities_smooth_mean_data_dist(i, :) movement_100_velocities_smooth_mean_data_dist(i, :)];
        movement_velocities_maintain_time(i, :) = [movement_40_velocities_smooth_mean_data_time(i, :) movement_60_velocities_smooth_mean_data_time(i, :) movement_80_velocities_smooth_mean_data_time(i, :) movement_100_velocities_smooth_mean_data_time(i, :)];

    movement_vel2_smooth_mean_dist(i, :) = [movement_20_vel2_smooth_mean_data_dist(i, :) movement_40_vel2_smooth_mean_data_dist(i, :) movement_60_vel2_smooth_mean_data_dist(i, :) movement_80_vel2_smooth_mean_data_dist(i, :) movement_100_vel2_smooth_mean_data_dist(i, :) movement_slow_vel2_smooth_mean_data_dist(i, :)];
        
%%%% NEED TO FIX THE CONVOLUTION!!!! %%%%%

%         movement_velocities_smooth_mean_dist_conv(i, :) = conv(movement_velocities_smooth_mean_dist(i, :), mask, 'same');
%         movement_velocities_smooth_med_dist(i, :) = conv(movement_velocities_smooth_med_dist(i, :), mask, 'same');
%         movement_velocities_smooth_mean_time(i, :) = conv(movement_velocities_smooth_mean_time(i, :), mask, 'same');
%         movement_velocities_smooth_med_time(i, :)  = conv(movement_velocities_smooth_med_time(i, :) , mask, 'same');
%         slowdown_velocities_smooth_mean_time(i, :) = conv(slowdown_velocities_smooth_mean_time(i, :), mask, 'same');
%         slowdown_only_velocities_smooth_mean_time(i, :) = conv(slowdown_only_velocities_smooth_mean_time(i, :)  , mask, 'same');
%         movement_licking_smooth_mean_dist(i, :)  = conv(movement_licking_smooth_mean_dist(i, :) , mask, 'same');
%         movement_licking_smooth_med_dist(i, :) = conv(movement_licking_smooth_med_dist(i, :), mask, 'same');
%         movement_licking_smooth_mean_time(i, :) = conv(movement_licking_smooth_mean_time(i, :), mask, 'same');
%         movement_licking_smooth_med_time(i, :)  = conv(movement_licking_smooth_med_time(i, :) , mask, 'same');
%         slowdown_licking_smooth_mean_time(i, :) = conv(slowdown_licking_smooth_mean_time(i, :), mask, 'same');
%         slowdown_only_licking_smooth_mean_time(i, :)  = conv(slowdown_only_licking_smooth_mean_time(i, :) , mask, 'same');  
% 
%         movement_velocities_smooth_mean_dist_diff(i, :) = diff(movement_velocities_smooth_mean_dist(i, :));  

%    % Maintainence Metrics

%         movement_velocities_maintain_dist(i, :) = movement_velocities_smooth_mean_dist(i, (smooth_value:(smooth_value - 1)*5));
%         movement_velocities_maintain_time(i, :) = movement_velocities_smooth_mean_time(i, (smooth_value:(smooth_value - 1)*5));
%           warning('off','all')  
%             if  length(movement_velocities_maintain_time(i, :)) > 3
%                ttt = [1:length(movement_velocities_maintain_time(i, :))]';
%                p = fitlm(ttt, movement_velocities_maintain_time(i, :), 'poly1');   
%                maintenance_velocity_metrics_time(i, 1) = table2array(p.Coefficients(2, 1));
%                maintenance_velocity_metrics_time(i, 2) = table2array(p.Coefficients(2, 4));
%             else
%                 maintenance_velocity_metrics_time(i, 1) = NaN;
%                 maintenance_velocity_metrics_time(i, 2) = NaN;
%             end   
        
%             if  length(movement_velocities_maintain_dist(i, :)) > 3
%                ttt = [1:length(movement_velocities_maintain_dist(i, :))]';
%                p = fitlm(ttt, movement_velocities_maintain_dist(i, :), 'poly1');   
%                maintenance_velocity_metrics_dist(i, 1) = table2array(p.Coefficients(2, 1));
%                maintenance_velocity_metrics_dist(i, 2) = table2array(p.Coefficients(2, 4));
%             else
%                 maintenance_velocity_metrics_dist(i, 1) = NaN;
%                 maintenance_velocity_metrics_dist(i, 2) = NaN;
%             end 
% warning('on','all')
%     % Slowdown ratio metric

%         velocity_reduction_ratio_time(i, 1) = movement_velocities_smooth_mean_time(i, end) / movement_velocities_smooth_mean_time(i, ((smooth_value - 1) * 5));               
%         velocity_reduction_ratio_dist(i, 1) = movement_velocities_smooth_mean_dist(i, end) / movement_velocities_smooth_mean_dist(i, ((smooth_value - 1) * 5));



%         movement_velocities_smooth_mean_disty(i, :) = conv(movement_velocities_smooth_mean_dist(i, :), mask, 'same');
%         movement_velocities_smooth_med_disty(i, :) = conv(movement_velocities_smooth_med_dist(i, :), mask, 'same');
%         movement_velocities_smooth_mean_timey(i, :) = conv(movement_velocities_smooth_mean_time(i, :), mask, 'same');
%         movement_velocities_smooth_med_timey(i, :)  = conv(movement_velocities_smooth_med_time(i, :) , mask, 'same');
%         slowdown_velocities_smooth_mean_timey(i, :) = conv(slowdown_velocities_smooth_mean_time(i, :), mask, 'same');
%         slowdown_only_velocities_smooth_mean_timey(i, :) = conv(slowdown_only_velocities_smooth_mean_time(i, :)  , mask, 'same');
%         movement_licking_smooth_mean_disty(i, :)  = conv(movement_licking_smooth_mean_dist(i, :) , mask, 'same');
%         movement_licking_smooth_med_disty(i, :) = conv(movement_licking_smooth_med_dist(i, :), mask, 'same');
%         movement_licking_smooth_mean_timey(i, :) = conv(movement_licking_smooth_mean_time(i, :), mask, 'same');
%         movement_licking_smooth_med_timey(i, :)  = conv(movement_licking_smooth_med_time(i, :) , mask, 'same');
%         slowdown_licking_smooth_mean_timey(i, :) = conv(slowdown_licking_smooth_mean_time(i, :), mask, 'same');
%         slowdown_only_licking_smooth_mean_timey(i, :)  = conv(slowdown_only_licking_smooth_mean_time(i, :) , mask, 'same');  
% 
%             movement_velocities_smooth_mean_distyy(i, :) = conv(movement_velocities_smooth_mean_dist(i, :), mask, 'valid');
%             movement_velocities_smooth_mean_distyyy(i, :) = conv(movement_velocities_smooth_mean_dist(i, :), mask, 'full');

    % Velocity maintainence parameters

        % Calculate CV of running section (20% to 100%) of complete trials
                    
            CV_velocity_maintain_dist(i, :) = std(movement_velocities_maintain_dist(i, :)) / mean(movement_velocities_maintain_dist(i, :));
            CV_velocity_maintain_time(i, :) = std(movement_velocities_maintain_time(i, :)) / mean(movement_velocities_maintain_time(i, :));
        
  %Peak velocities

              max_vel_timenorm(i, 1) = max(movement_velocities_smooth_mean_time(i, :));

            if max_vel_timenorm(i, 1) > 0
                max_vel_timenorm(i, 2) = find(movement_velocities_smooth_mean_time(i, :) == max_vel_timenorm(i, 1), 1);
                max_vel_timenorm(i, 3) = (max_vel_timenorm(i, 2) / 100) * (target_distances(i, 1) / 10);

            end

              max_vel_distnorm(i, 1) = max(movement_velocities_smooth_mean_dist(i, :));

            if max_vel_distnorm(i, 1) > 0
                max_vel_distnorm(i, 2) = find(movement_velocities_smooth_mean_dist(i, :) == max_vel_distnorm(i, 1), 1);
                max_vel_distnorm(i, 3) = (max_vel_distnorm(i, 2) / 100) * (target_distances(i, 1) / 10);

            end
            
    end

    
    
    % Index by trial type

        complete_trials_index = find(trials_reward == 1);
        complete_trials_slow_index = find(trials_reward_slow == 1);
        complete_trials_stop_index = find(trials_reward_stop == 1);
        incomplete_slowdown_trials_index = find(trials_incomplete_slowdown == 1);
        trials_incomplete_running_index = find(trials_incomplete_running == 1);
        trials_incomplete_running_late_index = find(trials_incomplete_running_late == 1);
        trials_incomplete_running_early_index = find(trials_incomplete_running_early == 1);
        trials_overrun_index = find(trials_slowfail == 1);
        trials_premature_slow_index = find(trials_premature_slow == 1);

        trials_slow_100_index = find(slowdown_parameter == 100);
        trials_slow_150_index = find(slowdown_parameter == 150);
        trials_slow_200_index = find(slowdown_parameter == 200);

       
    % Slowdown parameter performance

        trials_slow_100_log = slowdown_parameter == 100;
        trials_slow_150_log = slowdown_parameter == 150;
        trials_slow_200_log = slowdown_parameter == 200;

        trials_slow_100_complete = trials_slow_100_log .* trials_reward;
        trials_slow_100_incomplete_slowdown = trials_slow_100_log .* trials_incomplete_slowdown;
        trials_slow_100_slowfail = trials_slow_100_log .* trials_slowfail;
        
        trials_slow_150_complete = trials_slow_150_log .* trials_reward;
        trials_slow_150_incomplete_slowdown = trials_slow_150_log .* trials_incomplete_slowdown;
        trials_slow_150_slowfail = trials_slow_150_log .* trials_slowfail;
        
        trials_slow_200_complete = trials_slow_200_log .* trials_reward;
        trials_slow_200_incomplete_slowdown = trials_slow_200_log .* trials_incomplete_slowdown;
        trials_slow_200_slowfail = trials_slow_200_log .* trials_slowfail;        

        trials_slow_100_complete_index = find(trials_slow_100_complete == 1);
        trials_slow_150_complete_index = find(trials_slow_150_complete == 1);
        trials_slow_200_complete_index = find(trials_slow_200_complete == 1);


            A = mean(movement_velocities_smooth_mean_dist(complete_trials_index, :), 'omitnan')';
            B = mean(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :), 'omitnan')';
            %B = movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :);
            C = mean(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :), 'omitnan')';

            D = mean(movement_velocities_smooth_mean_time(complete_trials_index, :), 'omitnan')';
            E = mean(movement_velocities_smooth_mean_time(incomplete_slowdown_trials_index, :), 'omitnan')';
            %E = movement_velocities_smooth_mean_time(incomplete_slowdown_trials_index, :);
            F = mean(movement_velocities_smooth_mean_time(trials_incomplete_running_index, :), 'omitnan')';
            %G = nanmean(movement_velocities_smooth_mean_time(trials_premature_slow_index, :));
        
            H = mean(slowdown_velocities_smooth_mean_time(complete_trials_index, :), 'omitnan')';
            I = mean(slowdown_only_velocities_smooth_mean_time(complete_trials_index, :), 'omitnan')';
            

            J = mean(movement_velocities_smooth_mean_time(trials_slow_100_complete_index, :), 'omitnan')';
            K = mean(movement_velocities_smooth_mean_time(trials_slow_150_complete_index, :), 'omitnan')';
            L = mean(movement_velocities_smooth_mean_time(trials_slow_200_complete_index, :), 'omitnan')';

            M = mean(movement_velocities_smooth_mean_dist(trials_slow_100_complete_index, :), 'omitnan')';
            N = mean(movement_velocities_smooth_mean_dist(trials_slow_150_complete_index, :), 'omitnan')';
            O = mean(movement_velocities_smooth_mean_dist(trials_slow_200_complete_index, :), 'omitnan')';      

            Z = mean(movement_licking_smooth_mean_dist(complete_trials_index, :), 'omitnan')';

            Y = mean(movement_licking_smooth_mean_time(complete_trials_index, :), 'omitnan')';

            X = mean(slowdown_licking_smooth_mean_time(complete_trials_index, :), 'omitnan')';
            W = mean(slowdown_only_licking_smooth_mean_time(complete_trials_index, :), 'omitnan')';
            

%          figure(2)
%                hold on
%                plot(Z);
%                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
%                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
%                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
%                %legend('complete','incomplete slowdown', 'incomplete running')
%                %axis ([-inf inf 0 600]);
%                title 'Average Lick Rate Rescaled by Distance'
%                 xlabel('Normalized Percent Distance to Target') 
%                 ylabel('Lick Rate (not sure units)') 
% 
%            hold off
%      
%            % Save Fig file to computer 
% 
%             [Where] = Where_file(filename);
%             SaveName = [strcat(Where, 'LickRate_Distance_', date, '_', num)];
%             savefig(SaveName);
% 
%             close all   
% 
%          figure(3)
%                hold on
%                plot(Y);
%                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
%                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
%                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
%                %legend('complete','incomplete slowdown', 'incomplete running')
%                %axis ([-inf inf 0 600]);
%                title 'Average Lick Rate Rescaled by Time'
%                 xlabel('Normalized Percent Time to Target') 
%                 ylabel('Lick Rate (not sure units)') 
% 
%            hold off
%      
%            % Save Fig file to computer 
% 
%             [Where] = Where_file(filename);
%             SaveName = [strcat(Where, 'LickRate_Time_', date, '_', num)];
%             savefig(SaveName);
% 
%             close all   
% 
%     % Plot
% 
%          figure(2)
%                hold on
%                plot(A);
%                plot(B);
%                plot(C);
%                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
%                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
%                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
%                %legend('complete','incomplete slowdown', 'incomplete running')
%                axis ([-inf inf 0 600]);
%                title 'Average Velocity Trajectories Rescaled by Distance'
%                 xlabel('Normalized Percent Distance to Target') 
%                 ylabel('Mean Velocity (cm/s)') 
% 
%            hold off
%      
%            % Save Fig file to computer 
% 
%             [Where] = Where_file(filename);
%             SaveName = [strcat(Where, 'VelocityTrajectories_Distance_', date, '_', num)];
%             savefig(SaveName);
% 
%             close all   
% 
%          figure(3)
%                hold on
%                plot(D);
%                plot(E);
%                plot(F);
%                %plot(G);           
%                legend('complete','incomplete slowdown', 'incomplete running')
%                axis ([-inf inf 0 600]);
%                 title 'Average Velocity Trajectories Rescaled by Time'
%                 xlabel('Normalized Percent Time to Target') 
%                 ylabel('Mean Velocity (cm/s)') 
% 
%            hold off  
%      
%            % Save Fig file to computer 
% 
%             [Where] = Where_file(filename);
%             SaveName = [strcat(Where, 'VelocityTrajectories_Time_', date, '_', num)];
%             savefig(SaveName);
% 
%             close all   
% 
%          figure(4)
%                hold on
%                plot(M);
%                plot(N);
%                plot(O);
%                %plot(G);           
%                legend('100','150', '200')
%                axis ([-inf inf 0 600]);
%                 title 'Average Velocity Trajectories by Slowdown Parameter Rescaled by Time'
%                 xlabel('Normalized Percent Time to Target') 
%                 ylabel('Mean Velocity (cm/s)') 
% 
%            hold off  
%      
%            % Save Fig file to computer 
% 
%             [Where] = Where_file(filename);
%             SaveName = [strcat(Where, 'VelocityTrajectories_Time_SlowPar_', date, '_', num)];
%             savefig(SaveName);
% 
%             close all  
% 
% 
%           figure(5)
%                hold on
%                plot(M);
%                plot(N);
%                plot(O);
%                %plot(G);           
%                legend('100','150', '200')
%                axis ([-inf inf 0 600]);
%                 title 'Average Velocity Trajectories by Slowdown Parameter Rescaled by Dist'
%                 xlabel('Normalized Percent Distance to Target') 
%                 ylabel('Mean Velocity (cm/s)') 
% 
%            hold off  
%      
%            % Save Fig file to computer 
% 
%             [Where] = Where_file(filename);
%             SaveName = [strcat(Where, 'VelocityTrajectories_Dist_SlowPar_', date, '_', num)];
%             savefig(SaveName);
% 
%             close all  


% Add Performance Data to Mastersheet

%      output.Complete_Trials = Complete_Trials;
% %     output.Complete_Trials_Slow = sum(trials_reward_slow);
% %     output.Complete_Trials_Stop = sum(trials_reward_stop);
%      output.Premature_Trials = Premature_Trials;       
%     
%      output.Premature_slowdown_trials = Premature_slowdown_trials;     
% %     output.Incomplete_Running = sum(trials_incomplete_running);
%      output.Incomplete_Trials = Incomplete_Trials;
%      output.Incomplete_Running_Late = sum(trials_incomplete_running_late);
%      output.Incomplete_Running_Early = sum(trials_incomplete_running_early);
% %     output.Incomplete_Slowdown_Trials = Incomplete_Slowdown_Trials;    
%     
%     output.Slowdown_Failures = Slowdown_Failures;
%     output.Total_Trials = Total_Trials;
% 
     output.reward_rate_per_min = Complete_Trials / Session_Duration;
     
     training_output.Rewards = Complete_Trials;
     training_output.reward_rate_per_min = Complete_Trials / Session_Duration;
%     output.mean_reward_distance = nanmean(reward_distance);
%     output.median_reward_distance = nanmedian(reward_distance);
% 
% %     output.Prop_Reward_Stop = output.Complete_Trials_Stop / output.Complete_Trials;
% 
%     output.Total_Running_Trials = Total_Running_Trials;
% %     output.Total_Late_Running_Trials = Total_Running_Trials - output.Incomplete_Running_Early;
%     output.Total_Slowdown_Trials = Total_Slowdown_Trials;
%     
% 
% %     output.Performance_Percentage = Performance_Percentage;
% %     output.Performance_Percentage_2 = Performance_Percentage_2;
% %     output.Performance_Percentage_3 = Performance_Percentage_3;
% %     output.Performance_Percentage_4 = output.Complete_Trials / output.Total_Late_Running_Trials;
% 
% %     output.Late_Running_Stop_Rate = output.Incomplete_Running_Late / Total_Running_Trials;
% %     output.Running_Stop_Rate = Incomplete_Running_Trials / Total_Running_Trials;
% %     output.Slowdown_Stop_Rate = Incomplete_Slowdown_Trials / Total_Slowdown_Trials;
% 
% %     output.Premature_slowdown_rate = Premature_slowdown_trials / Total_Running_Trials;
% 
% output.Reward_Prop = Complete_Trials / Total_Running_Trials;   
% output.Overrun_Prop = Slowdown_Failures / Total_Running_Trials;
% output.PreTarget_Error_Prop = (Premature_slowdown_trials + Incomplete_Trials) / Total_Running_Trials;
% output.PreSlow_Prop = Premature_slowdown_trials / Total_Running_Trials;     
% output.Stops_Late_Prop = sum(trials_incomplete_running_late) / Total_Running_Trials;
% output.Stops_Early_Prop = sum(trials_incomplete_running_early) / Total_Running_Trials;
% 


% 
% output.Complete_Trials_halfhour = sum(trials_reward(1:half_hour_trial_num, 1));
% output.Premature_Trials_halfhour = sum(trials_premature(1:half_hour_trial_num, 1));
% output.Premature_slowdown_trials_halfhour = sum(trials_premature_slow(1:half_hour_trial_num, 1));     
% output.Incomplete_halfhour = sum(trials_incomplete(1:half_hour_trial_num, 1));
% output.Incomplete_Running_Late_halfhour = sum(trials_incomplete_running_late(1:half_hour_trial_num, 1));
% output.Incomplete_Running_Early_halfhour = sum(trials_incomplete_running_early(1:half_hour_trial_num, 1));
% output.Slowdown_Failures_halfhour = sum(trials_slowfail(1:half_hour_trial_num, 1));
% output.Total_Trials_halfhour = half_hour_trial_num;
% output.reward_rate_per_min_halfhour = output.Complete_Trials_halfhour / 30;
% output.mean_reward_distance_halfhour = nanmean(reward_distance(1:half_hour_trial_num, 1));
% output.median_reward_distance_halfhour = nanmedian(reward_distance(1:half_hour_trial_num, 1));
% output.Total_Running_Trials_halfhour = half_hour_trial_num - output.Premature_Trials_halfhour;
% 
% output.Reward_Prop_halfhour = output.Complete_Trials_halfhour / output.Total_Running_Trials_halfhour;
% output.Overrun_Prop_halfhour = output.Slowdown_Failures_halfhour / output.Total_Running_Trials_halfhour;
% output.PreTarget_Error_Prop_halfhour = (output.Premature_slowdown_trials_halfhour + output.Incomplete_halfhour) / output.Total_Running_Trials_halfhour;
% output.PreSlow_Prop_halfhour = Premature_slowdown_trials / output.Total_Running_Trials_halfhour;     
% output.Stops_Late_Prop_halfhour = output.Incomplete_Running_Late_halfhour / output.Total_Running_Trials_halfhour;
% output.Stops_Early_Prop_halfhour = output.Incomplete_Running_Early_halfhour / output.Total_Running_Trials_halfhour;

% %     output.mean_reward_slowdown_distances = nanmean(slowdown_distance_to_reward);
% %     output.mean_reward_slowdown_times = nanmean(slowdown_time_to_reward);
% %     output.med_reward_slowdown_distances = nanmedian(slowdown_distance_to_reward);
% %     output.med_reward_slowdown_times = nanmedian(slowdown_time_to_reward);
% % 
% %     output.sem_reward_slowdown_distances = (nanstd(slowdown_distance_to_reward)/(sqrt(length(slowdown_distance_to_reward))));
% %     output.sem_reward_slowdown_times = (nanstd(slowdown_time_to_reward)/(sqrt(length(slowdown_time_to_reward))));
% % 
% %     output.mean_running_period_distances = nanmean(running_period_distance);
% %     output.mean_running_period_times = nanmean(running_period_time);
% %     output.med_running_period_distances = nanmedian(running_period_distance);
% %     output.med_running_period_times = nanmedian(running_period_time);
% % 
% %     output.sem_running_period_distances = (nanstd(running_period_distance)/(sqrt(length(running_period_distance))));
% %     output.sem_running_period_times = (nanstd(running_period_time)/(sqrt(length(running_period_time))));
% % 
% %     output.mean_go_latency_from_WN = nanmean(go_latency_from_WN);
% %     output.med_go_latency_from_WN = nanmedian(go_latency_from_WN);
% %     output.sem_go_latency_from_WN = (nanstd(go_latency_from_WN)/(sqrt(length(go_latency_from_WN))));
% % 
% %     output.mean_go_latency_from_go = nanmean(go_latency_from_go);
% %     output.med_go_latency_from_go = nanmedian(go_latency_from_go);
% %     output.sem_go_latency_from_go = (nanstd(go_latency_from_go)/(sqrt(length(go_latency_from_go))));
% 
% %     output.number_slow_100_trials = length(trials_slow_100_index);
% %     output.number_slow_150_trials = length(trials_slow_150_index);
% %     output.number_slow_200_trials = length(trials_slow_200_index);
% % 
% %     output.trials_slow_100_complete = sum(trials_slow_100_complete);
% %     output.trials_slow_100_incomplete_slowdown = sum(trials_slow_100_incomplete_slowdown);
% %     output.trials_slow_100_slowfail = sum(trials_slow_100_slowfail);
% %     
% %     output.trials_slow_150_complete = sum(trials_slow_150_complete);
% %     output.trials_slow_150_incomplete_slowdown = sum(trials_slow_150_incomplete_slowdown);
% %     output.trials_slow_150_slowfail = sum(trials_slow_150_slowfail);
% %     
% %     output.trials_slow_200_complete = sum(trials_slow_200_complete);
% %     output.trials_slow_200_incomplete_slowdown = sum(trials_slow_200_incomplete_slowdown);
% %     output.trials_slow_200_slowfail = sum(trials_slow_200_slowfail);
% %     
% %     output.Performance_3_slow_100 = output.trials_slow_100_complete / (output.trials_slow_100_complete + output.trials_slow_100_incomplete_slowdown + output.trials_slow_100_slowfail);
% %     output.Performance_3_slow_150 = output.trials_slow_150_complete / (output.trials_slow_150_complete + output.trials_slow_150_incomplete_slowdown + output.trials_slow_150_slowfail);
% %     output.Performance_3_slow_200 = output.trials_slow_200_complete / (output.trials_slow_200_complete + output.trials_slow_200_incomplete_slowdown + output.trials_slow_200_slowfail);
% 
% % Outputs for stop frequency metric
% 
%     stops_frequency_complete = stops_frequency(complete_trials_index, 1);
%     stops_durations_complete = stops_durations(complete_trials_index, 1);
%     stops_distances_complete = stops_distances(complete_trials_index, 1);
%     stops_durations_complete = cell2mat(stops_durations_complete);
%     stops_distances_complete = cell2mat(stops_distances_complete);
%     stops_distances_complete = stops_distances_complete ./ 10;
% 
% %     output.stop_rate_complete = sum(stops_frequency_complete) / Complete_Trials;
% %     output.mean_stop_duration = mean(stops_durations_complete);   
% %     output.mean_stop_distance = mean(stops_distances_complete);
% %     output.median_stop_duration = median(stops_durations_complete);   
% %     output.median_stop_distance = median(stops_distances_complete);
% %     output.sem_stop_duration = (std(stops_durations_complete)/(sqrt(length(stops_durations_complete))));   
% %     output.sem_stop_distance = (std(stops_distances_complete)/(sqrt(length(stops_distances_complete))));
%        
%         xaxis_dura = [1: length(stops_durations_complete)]';
%         xaxis_dist = [1: length(stops_distances_complete)]';
% 
% %            figure(6)
% %                hold on
% %                scatter(xaxis_dist, stops_distances_complete);
% %                %plot_areaerrorbar(slowdown_velocities_smooth_mean_time(complete_trials_index, :));
% %                %plot(hhh);
% %                %plot(G);           
% %                %legend('complete','fitted curve')
% %                axis ([0 inf 0 inf]);
% %                 title 'Distance Animal Stopped at During Completed Trial'
% %                 xlabel('Stop Occurance Number') 
% %                 ylabel('Distance (cm)') 
% %               
% %            hold off    
% %     
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'StopDistances_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all   
% % 
% %            figure(7)
% %                hold on
% %                scatter(xaxis_dura, stops_durations_complete);
% %                %plot_areaerrorbar(slowdown_velocities_smooth_mean_time(complete_trials_index, :));
% %                %plot(hhh);
% %                %plot(G);           
% %                %legend('complete','fitted curve')
% %                axis ([0 inf 0 inf]);
% %                 title 'Duration Animal Stopped for During Completed Trial'
% %                 xlabel('Stop Occurance Number') 
% %                 ylabel('Duration (s)') 
% %               
% %            hold off     
% %     
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'StopDurations_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all   
% % 
% 
% % Fit slowdown to exponential decay
% %     if  length(H) > 3
% % 
% %     x = [1:length(H)]';
% %     hhh = fit(x, H, 'poly2');
% %     
% % %            figure(8)
% % %                hold on
% % %                plot(H);
% % %                %plot_areaerrorbar(slowdown_velocities_smooth_mean_time(complete_trials_index, :));
% % %                plot(hhh);
% % %                %plot(G);           
% % %                legend('complete','fitted curve')
% % %                axis ([-inf inf 0 600]);
% % %                 title 'Average Slowdown Trajectories Rescaled by Time'
% % %                 xlabel('Normalized Percent Time to Target') 
% % %                 ylabel('Mean Velocity (cm/s)') 
% % %               
% % %            hold off    
% % %     
% % %            % Save Fig file to computer 
% % % 
% % %             [Where] = Where_file(filename);
% % %             SaveName = [strcat(Where, 'SlowdownFit_', date, '_', num)];
% % %             savefig(SaveName);
% % % 
% % %             close all   
% % 
% %     % Save output
% % 
% %         output.slowdown_fit_parameters = hhh;
% %         output.slowdown_average_vel_data = H;
% % 
% %     else
% %         output.slowdown_fit_parameters = NaN;
% %         output.slowdown_average_vel_data = NaN; 
% % 
% %     end
% 
% 
        trials_running_late = trials_go .* ~trials_incomplete_running_early;

        trials_running_late_short = trials_running_late .* trials_short;
        trials_running_late_medium = trials_running_late .* trials_medium;
        trials_running_late_long = trials_running_late .* trials_long;

        trials_incomplete_running_late_short = trials_incomplete_running_late .* trials_short;
        trials_incomplete_running_late_medium = trials_incomplete_running_late .* trials_medium;
        trials_incomplete_running_late_long = trials_incomplete_running_late .* trials_long;

        trials_incomplete_running_early_short = trials_incomplete_running_early .* trials_short;
        trials_incomplete_running_early_medium = trials_incomplete_running_early .* trials_medium;
        trials_incomplete_running_early_long = trials_incomplete_running_early .* trials_long;

        trials_incomplete_running_imm_short = trials_incomplete_running_early .* trials_short;
        trials_incomplete_running_imm_medium = trials_incomplete_running_early .* trials_medium;
        trials_incomplete_running_imm_long = trials_incomplete_running_early .* trials_long;       

%     % Performance by distance
%      
%         trials_reward_short_log = find(trials_reward_short == 1);
%         trials_reward_medium_log = find(trials_reward_medium == 1);
%         trials_reward_long_log = find(trials_reward_long == 1);
%         
%         trials_incomplete_slowdown_short_log = find(trials_incomplete_slowdown_short == 1);
%         trials_incomplete_slowdown_medium_log = find(trials_incomplete_slowdown_medium == 1);
%         trials_incomplete_slowdown_long_log = find(trials_incomplete_slowdown_long == 1);
%         
%         trials_incomplete_running_short_log = find(trials_incomplete_running_short == 1);
%         trials_incomplete_running_medium_log = find(trials_incomplete_running_medium == 1);
%         trials_incomplete_running_long_log = find(trials_incomplete_running_long == 1);
%         
%         trials_slowfail_short_log = find(trials_slowfail_short == 1);
%         trials_slowfail_medium_log = find(trials_slowfail_medium == 1);
%         trials_slowfail_long_log = find(trials_slowfail_long == 1);
%     
%     
%         complete_short_trials_sum = sum(trials_reward_short);
%         incomplete_slowdown_short_trials_sum = sum(trials_incomplete_slowdown_short);
%         slowfail_short_trials_sum = sum(trials_slowfail_short);
%         total_short_slowdown_trials_sum = complete_short_trials_sum + incomplete_slowdown_short_trials_sum + slowfail_short_trials_sum;
%         
% 
%         
%         complete_medium_trials_sum = sum(trials_reward_medium);
%         incomplete_slowdown_medium_trials_sum = sum(trials_incomplete_slowdown_medium);
%         slowfail_medium_trials_sum = sum(trials_slowfail_medium);
%         total_medium_slowdown_trials_sum = complete_medium_trials_sum + incomplete_slowdown_medium_trials_sum + slowfail_medium_trials_sum;
%         
% 
%         complete_long_trials_sum = sum(trials_reward_long);
%         incomplete_slowdown_long_trials_sum = sum(trials_incomplete_slowdown_long);
%         slowfail_long_trials_sum = sum(trials_slowfail_long);
%         total_long_slowdown_trials_sum = complete_long_trials_sum + incomplete_slowdown_long_trials_sum + slowfail_long_trials_sum;
% 
% %            output.Performance_2_short = complete_short_trials_sum / sum(trials_running_index_short);
% %            output.Performance_2_medium = complete_medium_trials_sum / sum(trials_running_index_medium);     
% %            output.Performance_2_long = complete_long_trials_sum / sum(trials_running_index_long);           
%            
%            output.Performance_3_short = complete_short_trials_sum / total_short_slowdown_trials_sum;
%            output.Performance_3_medium = complete_medium_trials_sum / total_medium_slowdown_trials_sum;     
%            output.Performance_3_long = complete_long_trials_sum / total_long_slowdown_trials_sum;
% 
%            output.Performance_4_short = complete_short_trials_sum / sum(trials_running_late_short);
%            output.Performance_4_medium = complete_medium_trials_sum / sum(trials_running_late_medium);     
%            output.Performance_4_long = complete_long_trials_sum / sum(trials_running_late_long);   
% 
%            output.number_complete_short_trials = complete_short_trials_sum;
%            output.number_complete_medium_trials = complete_medium_trials_sum;
%            output.number_complete_long_trials = complete_long_trials_sum;
% 
%         output.running_late_stop_rate_short = sum(trials_incomplete_running_late_short) / sum(trials_running_late_short);
%         output.running_late_stop_rate_medium = sum(trials_incomplete_running_late_medium) / sum(trials_running_late_medium);
%         output.running_late_stop_rate_long = sum(trials_incomplete_running_late_long) / sum(trials_running_late_long);
%            
%          output.overrun_rate_short = slowfail_short_trials_sum / sum(trials_running_late_short);
%         output.overrun_rate_medium = slowfail_medium_trials_sum / sum(trials_running_late_medium);
%         output.overrun_rate_long = slowfail_long_trials_sum / sum(trials_running_late_long);
% 
%         output.premature_slow_short_rate = sum(trials_premature_slow_short) / sum(trials_running_late_short);
%    output.premature_slow_medium_rate = sum(trials_premature_slow_medium) / sum(trials_running_late_medium);
%       output.premature_slow_long_rate = sum(trials_premature_slow_long) / sum(trials_running_late_long);
% 
% %             output.CV_velocity_maintain_dist_complete(:, :) = CV_velocity_maintain_dist(complete_trials_index, :);
% %             output.CV_velocity_maintain_time_complete(:, :) = CV_velocity_maintain_time(complete_trials_index, :);
% 
%     % Figures 
%         
%             vel_smooth_short_dist_complete = nanmean(movement_velocities_smooth_mean_dist(trials_reward_short_log, :))';
%             vel_smooth_short_dist_incomplete_slowdown = nanmean(movement_velocities_smooth_mean_dist(trials_incomplete_slowdown_short_log, :))';
%             vel_smooth_short_dist_incomplete_running = nanmean(movement_velocities_smooth_mean_dist(trials_incomplete_running_short_log, :))';
%             
%             vel_smooth_short_time_complete = nanmean(movement_velocities_smooth_mean_time(trials_reward_short_log, :))';
%             vel_smooth_short_time_incomplete_slowdown = nanmean(movement_velocities_smooth_mean_time(trials_incomplete_slowdown_short_log, :))';
%             vel_smooth_short_time_incomplete_running = nanmean(movement_velocities_smooth_mean_time(trials_incomplete_running_short_log, :))';
%             
%             vel_smooth_medium_dist_complete = nanmean(movement_velocities_smooth_mean_dist(trials_reward_medium_log, :))';
%             vel_smooth_medium_dist_incomplete_slowdown = nanmean(movement_velocities_smooth_mean_dist(trials_incomplete_slowdown_medium_log, :))';
%             vel_smooth_medium_dist_incomplete_running = nanmean(movement_velocities_smooth_mean_dist(trials_incomplete_running_medium_log, :))';
%             
%             vel_smooth_medium_time_complete = nanmean(movement_velocities_smooth_mean_time(trials_reward_medium_log, :))';
%             vel_smooth_medium_time_incomplete_slowdown = nanmean(movement_velocities_smooth_mean_time(trials_incomplete_slowdown_medium_log, :))';
%             vel_smooth_medium_time_incomplete_running = nanmean(movement_velocities_smooth_mean_time(trials_incomplete_running_medium_log, :))';
%             
%             vel_smooth_long_dist_complete = nanmean(movement_velocities_smooth_mean_dist(trials_reward_long_log, :))';
%             vel_smooth_long_dist_incomplete_slowdown = nanmean(movement_velocities_smooth_mean_dist(trials_incomplete_slowdown_long_log, :))';
%             vel_smooth_long_dist_incomplete_running = nanmean(movement_velocities_smooth_mean_dist(trials_incomplete_running_long_log, :))';
%             
%             vel_smooth_long_time_complete = nanmean(movement_velocities_smooth_mean_time(trials_reward_long_log, :))';
%             vel_smooth_long_time_incomplete_slowdown = nanmean(movement_velocities_smooth_mean_time(trials_incomplete_slowdown_long_log, :))';
%             vel_smooth_long_time_incomplete_running = nanmean(movement_velocities_smooth_mean_time(trials_incomplete_running_long_log, :))';
% 
% 
% %            figure(9)
% %                hold on
% %                plot(vel_smooth_short_dist_complete);
% %                plot(vel_smooth_short_dist_incomplete_slowdown);
% %                plot(vel_smooth_short_dist_incomplete_running);
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
% %                legend('complete','incomplete slowdown', 'incomplete running')
% %                axis ([-inf inf 0 600]);
% %                title 'Average Velocity Trajectories Short Trials Rescaled by Distance'
% %                 xlabel('Normalized Percent Distance to Target') 
% %                 ylabel('Mean Velocity (cm/s)') 
% % 
% %            hold off
% %      
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'VelocityTrajectories_Distance_Short_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all   
% % 
% %              figure(10)
% %                    hold on
% %                    plot(vel_smooth_short_time_complete);
% %                    plot(vel_smooth_short_time_incomplete_slowdown);
% %                    plot(vel_smooth_short_time_incomplete_running);
% %                    %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
% %                    %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
% %                    %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
% %                    legend('complete','incomplete slowdown', 'incomplete running')
% %                    axis ([-inf inf 0 600]);
% %                    title 'Average Velocity Trajectories Short Trials Rescaled by Time'
% %                     xlabel('Normalized Percent Distance to Target') 
% %                     ylabel('Mean Velocity (cm/s)') 
% % 
% %                hold off
% %          
% %                % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityTrajectories_Time_Short_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all   
% % 
% % 
% %          figure(11)
% %                hold on
% %                plot(vel_smooth_medium_dist_complete);
% %                plot(vel_smooth_medium_dist_incomplete_slowdown);
% %                plot(vel_smooth_medium_dist_incomplete_running);
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
% %                legend('complete','incomplete slowdown', 'incomplete running')
% %                axis ([-inf inf 0 600]);
% %                title 'Average Velocity Trajectories medium Trials Rescaled by Distance'
% %                 xlabel('Normalized Percent Distance to Target') 
% %                 ylabel('Mean Velocity (cm/s)') 
% % 
% %            hold off
% %      
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'VelocityTrajectories_Distance_medium_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all   
% % 
% %              figure(12)
% %                    hold on
% %                    plot(vel_smooth_medium_time_complete);
% %                    plot(vel_smooth_medium_time_incomplete_slowdown);
% %                    plot(vel_smooth_medium_time_incomplete_running);
% %                    %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
% %                    %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
% %                    %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
% %                    legend('complete','incomplete slowdown', 'incomplete running')
% %                    axis ([-inf inf 0 600]);
% %                    title 'Average Velocity Trajectories medium Trials Rescaled by Time'
% %                     xlabel('Normalized Percent Distance to Target') 
% %                     ylabel('Mean Velocity (cm/s)') 
% % 
% %                hold off
% %          
% %                % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityTrajectories_Time_medium_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all   
% % 
% %          figure(13)
% %                hold on
% %                plot(vel_smooth_long_dist_complete);
% %                plot(vel_smooth_long_dist_incomplete_slowdown);
% %                plot(vel_smooth_long_dist_incomplete_running);
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
% %                legend('complete','incomplete slowdown', 'incomplete running')
% %                axis ([-inf inf 0 600]);
% %                title 'Average Velocity Trajectories long Trials Rescaled by Distance'
% %                 xlabel('Normalized Percent Distance to Target') 
% %                 ylabel('Mean Velocity (cm/s)') 
% % 
% %            hold off
% %      
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'VelocityTrajectories_Distance_long_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all   
% % 
% %              figure(14)
% %                    hold on
% %                    plot(vel_smooth_long_time_complete);
% %                    plot(vel_smooth_long_time_incomplete_slowdown);
% %                    plot(vel_smooth_long_time_incomplete_running);
% %                    %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
% %                    %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
% %                    %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
% %                    legend('complete','incomplete slowdown', 'incomplete running')
% %                    axis ([-inf inf 0 600]);
% %                    title 'Average Velocity Trajectories long Trials Rescaled by Time'
% %                     xlabel('Normalized Percent Distance to Target') 
% %                     ylabel('Mean Velocity (cm/s)') 
% % 
% %                hold off
% %          
% %                % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityTrajectories_Time_long_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all   
% % 
% 
% %         figure(15)
% %             hold on
% %                    % plot(vel_smooth_short_time_complete);
% %                    % plot(vel_smooth_medium_time_complete);
% %                    % plot(vel_smooth_long_time_complete);
% % 
% % 
% %             options.color_line = [236 112  22]./255;
% %             options.color_area = [243 169 114]./255;                   
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_reward_short_log, :), options);
% %             clear options
% % 
% %             options.color_line = [216 0  115]./255;
% %             options.color_area = [226 20 135]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_reward_medium_log, :), options);
% %             clear options
% % 
% %             options.color_area = [128 193 219]./255;   
% %             options.color_line = [ 52 148 186]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_reward_long_log, :), options);
% % 
% % 
% %                    legend('', 'short', '', 'medium', '', 'long')
% %                    axis ([-inf inf 0 600]);
% %                    title 'Average Velocity Trajectories Across Completed Trials Rescaled by Dist'
% %                     xlabel('Normalized Percent Distance to Target') 
% %                     ylabel('Mean Velocity (cm/s)') 
% % 
% %             hold off
% %          
% %                % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityTrajectories_Dist_SML_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all
% 
% 
% %     output.mean_vel_trace_short = vel_smooth_short_dist_complete;
% %     output.mean_vel_trace_medium = vel_smooth_medium_dist_complete;
% %     output.mean_vel_trace_long = vel_smooth_long_dist_complete;
% % 
% % 
% % % Rewarded Distances
% %     trials_reward_short_index = find(trials_reward_short == 1);
% %     trials_reward_medium_index = find(trials_reward_medium == 1);
% %     trials_reward_long_index = find(trials_reward_long == 1);
% %     
% %     reward_distance_mat = cell2mat(reward_distance);
% %     
% %     mean_reward_distance_short = mean(reward_distance_mat(trials_reward_short_index, 1));
% %     mean_reward_distance_medium = mean(reward_distance_mat(trials_reward_medium_index, 1));
% %     mean_reward_distance_long = mean(reward_distance_mat(trials_reward_long_index, 1));
% %     
% %     median_reward_distance_short = median(reward_distance_mat(trials_reward_short_index, 1));
% %     median_reward_distance_medium = median(reward_distance_mat(trials_reward_medium_index, 1));
% %     median_reward_distance_long = median(reward_distance_mat(trials_reward_long_index, 1));
% %     
% %     sem_reward_distance_short = (std(reward_distance_mat(trials_reward_short_index, 1))/(sqrt(length(reward_distance_mat(trials_reward_short_index, 1)))));
% %     sem_reward_distance_medium = (std(reward_distance_mat(trials_reward_medium_index, 1))/(sqrt(length(reward_distance_mat(trials_reward_medium_index, 1)))));
% %     sem_reward_distance_long = (std(reward_distance_mat(trials_reward_long_index, 1))/(sqrt(length(reward_distance_mat(trials_reward_long_index, 1)))));
% %     
% %     output.mean_reward_distance_short = mean_reward_distance_short;
% %     output.median_reward_distance_short = median_reward_distance_short;
% %     output.sem_reward_distance_short = sem_reward_distance_short;
% %     
% %     output.mean_reward_distance_medium = mean_reward_distance_medium;
% %     output.median_reward_distance_medium = median_reward_distance_medium;
% %     output.sem_reward_distance_medium = sem_reward_distance_medium;
% %     
% %     output.mean_reward_distance_long = mean_reward_distance_long;
% %     output.median_reward_distance_long = median_reward_distance_long;
% %     output.sem_reward_distance_long = sem_reward_distance_long;
% 
%  % Lickrate metrics
% 
% %         tone_5_complete_lickrate_time = mean(movement_100_licking_smooth_mean_data_time(complete_trials_index, :));
% %         tone_5_complete_lickrate_dist = mean(movement_100_licking_smooth_mean_data_dist(complete_trials_index, :));
% %         slowdown_complete_lickrate_time = mean(movement_slow_licking_smooth_mean_data_time(complete_trials_index, :));
% %         slowdown_complete_lickrate_dist = mean(movement_slow_licking_smooth_mean_data_dist(complete_trials_index, :));
% % 
% %         output.mean_tone5_lickrate_time = mean(tone_5_complete_lickrate_time);
% %         output.mean_tone5_lickrate_dist = mean(tone_5_complete_lickrate_dist);
% %         output.mean_slowdown_lickrate_time = mean(slowdown_complete_lickrate_time);
% %         output.mean_slowdown_lickrate_dist = mean(slowdown_complete_lickrate_dist);
% 
% %not finished
% 
% trials_reward_short_index = find(trials_reward_short == 1);
% trials_reward_medium_index = find(trials_reward_medium == 1);
% trials_reward_long_index = find(trials_reward_long == 1);
% 
% x = size(trials_reward_short_index, 1);
% y = size(trials_reward_medium_index, 1);
% z = size(trials_reward_long_index, 1);
% 
% heatmap_data_short(1:x, :) = movement_velocities_smooth_mean_dist(trials_reward_short_index, :); 
% heatmap_data_medium(1:y, :) = movement_velocities_smooth_mean_dist(trials_reward_medium_index, :); 
% heatmap_data_long(1:z, :) = movement_velocities_smooth_mean_dist(trials_reward_long_index, :); 
% 
% heatmap_data = [heatmap_data_short; heatmap_data_medium; heatmap_data_long];
% 
% %heatmap(heatmap_data, 'Colormap', jet, 'ColorLimits',[0 800])
% % figure(16)
% % heatmap(heatmap_data, 'Colormap', jet)
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Dist_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all
%                 
% heatmap_data_time_short(1:x, :) = movement_velocities_smooth_mean_time(trials_reward_short_index, :); 
% heatmap_data_time_medium(1:y, :) = movement_velocities_smooth_mean_time(trials_reward_medium_index, :); 
% heatmap_data_time_long(1:z, :) = movement_velocities_smooth_mean_time(trials_reward_long_index, :); 
% 
% heatmap_time_data = [heatmap_data_short; heatmap_data_medium; heatmap_data_long];
% 
% %heatmap(heatmap_time_data, 'Colormap', jet, 'ColorLimits',[0 800])
% % figure(17)
% % heatmap(heatmap_time_data, 'Colormap', jet)
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all
%  % Rewarded distance distribution
%  
% %     reward_distance_short(:, :) = reward_distance_mat(trials_reward_short_index, 1);
% %     reward_distance_medium(:, :) = reward_distance_mat(trials_reward_medium_index, 1);
% %     reward_distance_long(:, :) = reward_distance_mat(trials_reward_long_index, 1);
% % 
% 
% % 				subplot(1, 3, 1)
% % 				boxplot(reward_distance_short)
% % 					hold on
% % 					%legend('Cohort 1','Cohort 2')
% % 					%title('Rewarded Distances (total) for Short Trials')
% % 					xlabel('Short Trial Distribution')
% % 					ylabel('Total Distance Ran (cm)')
% % 					%xlim([0 3])
% % 					ylim([0 200])
% % 
% % 				subplot(1, 3, 2)
% % 				boxplot(reward_distance_medium)
% % 					hold on
% % 					%legend('Cohort 1','Cohort 2')
% % 					title('Rewarded Distances')
% % 					xlabel('Medium Trial Distribution')
% % 					ylabel('Total Distance Ran (cm)')
% % 					%xlim([0 3])
% % 					ylim([0 200])
% % 
% % 				subplot(1, 3, 3)
% % 				boxplot(reward_distance_long)
% % 					hold on
% % 					%legend('Cohort 1','Cohort 2')
% % 					%title('Rewarded Distances')
% % 					xlabel('Long Trial Distribution')
% % 					ylabel('Total Distance Ran (cm)')
% % 					%xlim([0 3])
% % 					ylim([0 200])
% %                     
% %   % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'Rewarded_Distances_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all  
%                 
%                 
%     ratio_T5_time = T5_time_to_reward ./ running_period_T5_time;
%     ratio_T5_distance = T5_distance_to_reward ./ running_period_T5_distance;   
% 
%     ratio_target_time = slowdown_time_to_reward ./ running_period_time;
%     ratio_target_distance = slowdown_distance_to_reward ./ running_period_distance;
% 
% 
% % output.ratio_T5_time = ratio_T5_time;
% % output.ratio_T5_distance = ratio_T5_distance;
% % output.ratio_target_time = ratio_target_time;
% % output.ratio_target_distance = ratio_target_distance;
% 
% % output.ratios_T5_time_short = ratio_T5_time(trials_reward_short_index, 1);
% % output.ratios_T5_distance_short = ratio_T5_distance(trials_reward_short_index, 1);
% % output.ratios_target_time_short = ratio_target_time(trials_reward_short_index, 1);
% % output.ratios_target_distance_short = ratio_target_distance(trials_reward_short_index, 1);
% % 
% % output.ratios_T5_time_medium = ratio_T5_time(trials_reward_medium_index, 1);
% % output.ratios_T5_distance_medium = ratio_T5_distance(trials_reward_medium_index, 1);
% % output.ratios_target_time_medium = ratio_target_time(trials_reward_medium_index, 1);
% % output.ratios_target_distance_medium = ratio_target_distance(trials_reward_medium_index, 1);
% % 
% % output.ratios_T5_time_long = ratio_T5_time(trials_reward_long_index, 1);
% % output.ratios_T5_distance_long = ratio_T5_distance(trials_reward_long_index, 1);
% % output.ratios_target_time_long = ratio_target_time(trials_reward_long_index, 1);
% % output.ratios_target_distance_long = ratio_target_distance(trials_reward_long_index, 1);
% % 
% % output.mean_ratio_T5_time_short = nanmean(ratio_T5_time(trials_reward_short_index, 1));
% % output.mean_ratio_T5_distance_short = nanmean(ratio_T5_distance(trials_reward_short_index, 1));
% % output.mean_ratio_target_time_short = nanmean(ratio_target_time(trials_reward_short_index, 1));
% % output.mean_ratio_target_distance_short = nanmean(ratio_target_distance(trials_reward_short_index, 1));
% % 
% % output.mean_ratio_T5_time_medium = nanmean(ratio_T5_time(trials_reward_medium_index, 1));
% % output.mean_ratio_T5_distance_medium = nanmean(ratio_T5_distance(trials_reward_medium_index, 1));
% % output.mean_ratio_target_time_medium = nanmean(ratio_target_time(trials_reward_medium_index, 1));
% % output.mean_ratio_target_distance_medium = nanmean(ratio_target_distance(trials_reward_medium_index, 1));
% % 
% % output.mean_ratio_T5_time_long = nanmean(ratio_T5_time(trials_reward_long_index, 1));
% % output.mean_ratio_T5_distance_long = nanmean(ratio_T5_distance(trials_reward_long_index, 1));
% % output.mean_ratio_target_time_long = nanmean(ratio_target_time(trials_reward_long_index, 1));
% % output.mean_ratio_target_distance_long = nanmean(ratio_target_distance(trials_reward_long_index, 1));
% % 
% % output.SEM_ratio_T5_time_short = nanstd(ratio_T5_time(trials_reward_short_index, 1))/ (sqrt(length(ratio_T5_time(trials_reward_short_index, 1))));
% % output.SEM_ratio_T5_distance_short = nanstd(ratio_T5_distance(trials_reward_short_index, 1))/ (sqrt(length(ratio_T5_distance(trials_reward_short_index, 1))));
% % output.SEM_ratio_target_time_short = nanstd(ratio_target_time(trials_reward_short_index, 1))/ (sqrt(length(ratio_target_time(trials_reward_short_index, 1))));
% % output.SEM_ratio_target_distance_short = nanstd(ratio_target_distance(trials_reward_short_index, 1))/ (sqrt(length(ratio_target_distance(trials_reward_short_index, 1))));
% % 
% % output.SEM_ratio_T5_time_medium = nanstd(ratio_T5_time(trials_reward_medium_index, 1))/ (sqrt(length(ratio_T5_time(trials_reward_medium_index, 1))));
% % output.SEM_ratio_T5_distance_medium = nanstd(ratio_T5_distance(trials_reward_medium_index, 1))/ (sqrt(length(ratio_T5_distance(trials_reward_medium_index, 1))));
% % output.SEM_ratio_target_time_medium = nanstd(ratio_target_time(trials_reward_medium_index, 1))/ (sqrt(length(ratio_target_time(trials_reward_medium_index, 1))));
% % output.SEM_ratio_target_distance_medium = nanstd(ratio_target_distance(trials_reward_medium_index, 1))/ (sqrt(length(ratio_target_distance(trials_reward_medium_index, 1))));
% % 
% % output.SEM_ratio_T5_time_long = nanstd(ratio_T5_time(trials_reward_long_index, 1))/ (sqrt(length(ratio_T5_time(trials_reward_long_index, 1))));
% % output.SEM_ratio_T5_distance_long = nanstd(ratio_T5_distance(trials_reward_long_index, 1))/ (sqrt(length(ratio_T5_distance(trials_reward_long_index, 1))));
% % output.SEM_ratio_target_time_long = nanstd(ratio_target_time(trials_reward_long_index, 1))/ (sqrt(length(ratio_target_time(trials_reward_long_index, 1))));
% % output.SEM_ratio_target_distance_long = nanstd(ratio_target_distance(trials_reward_long_index, 1))/ (sqrt(length(ratio_target_distance(trials_reward_long_index, 1))));
% % 
% 
% %         subplot(1, 3, 1)
% %                 boxplot(ratio_T5_time(trials_reward_short_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances (total) for Short Trials')
% %                     xlabel('Short Trials')
% %                     ylabel('Ratio of Time in T5 to Time Before T5')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 2)
% %                 boxplot(ratio_T5_time(trials_reward_medium_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     title('Ratio of Time Spent in Tone 5 to Time Running before T5')
% %                     xlabel('Medium Trials')
% %                     ylabel('Ratio of Time in T5 to Time Before T5')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 3)
% %                 boxplot(ratio_T5_time(trials_reward_long_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances')
% %                     xlabel('Long Trials')
% %                     ylabel('Ratio of Time in T5 to Time Before T5')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %   % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'T5RatioTime_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all  
% %                 
% % 
% %         subplot(1, 3, 1)
% %                 boxplot(ratio_T5_distance(trials_reward_short_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances (total) for Short Trials')
% %                     xlabel('Short Trials')
% %                     ylabel('Ratio of distance in T5 to distance Before T5')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 2)
% %                 boxplot(ratio_T5_distance(trials_reward_medium_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     title('Ratio of distance Spent in Tone 5 to distance Running before T5')
% %                     xlabel('Medium Trials')
% %                     ylabel('Ratio of distance in T5 to distance Before T5')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 3)
% %                 boxplot(ratio_T5_distance(trials_reward_long_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances')
% %                     xlabel('Long Trials')
% %                     ylabel('Ratio of distance in T5 to distance Before T5')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %   % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'T5RatioDistance_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all  
% % 
% % 
% % 
% %         subplot(1, 3, 1)
% %                 boxplot(ratio_target_time(trials_reward_short_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances (total) for Short Trials')
% %                     xlabel('Short Trials')
% %                     ylabel('Ratio of Time in Slowdown to Time in Running Period')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 2)
% %                 boxplot(ratio_target_time(trials_reward_medium_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     title('Ratio of Time in Slowdown to Time in Running Period')
% %                     xlabel('Medium Trials')
% %                     ylabel('Ratio of Time in Slowdown to Time in Running Period')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 3)
% %                 boxplot(ratio_target_time(trials_reward_long_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances')
% %                     xlabel('Long Trials')
% %                     ylabel('Ratio of Time in Slowdown to Time in Running Period')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %   % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'SlowdownRunningRatioTime_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all                  
% % 
% % 
% % 
% %         subplot(1, 3, 1)
% %                 boxplot(ratio_target_distance(trials_reward_short_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances (total) for Short Trials')
% %                     xlabel('Short Trials')
% %                     ylabel('Ratio of Distance in Slowdown to Distance in Running Period')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 2)
% %                 boxplot(ratio_target_distance(trials_reward_medium_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     title('Ratio of Distance in Slowdown to Distance in Running Period')
% %                     xlabel('Medium Trials')
% %                     ylabel('Ratio of Distance in Slowdown to Distance in Running Period')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 3)
% %                 boxplot(ratio_target_distance(trials_reward_long_index, 1))
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances')
% %                     xlabel('Long Trials')
% %                     ylabel('Ratio of Distance in Slowdown to Distance in Running Period')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %   % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'SlowdownRunningRatioDistance_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all  
%                 
% %     short_T5_dist = T5_distance_to_reward(trials_reward_short_index, 1);
% %    medium_T5_dist = T5_distance_to_reward(trials_reward_medium_index, 1);
% %    long_T5_dist = T5_distance_to_reward(trials_reward_long_index, 1);
% %                 
% % 
% % 
% %         subplot(1, 3, 1)
% %                 boxplot(short_T5_dist)
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances (total) for Short Trials')
% %                     xlabel('Short Trials')
% %                     ylabel('Distance (cm)')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 2)
% %                 boxplot(medium_T5_dist)
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     title('Distances from T5 to Reward')
% %                     xlabel('Medium Trials')
% %                     ylabel('Distance (cm)')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% % 
% %                 subplot(1, 3, 3)
% %                 boxplot(long_T5_dist)
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances')
% %                     xlabel('Long Trials')
% %                     ylabel('Distance (cm)')
% %                     %xlim([0 3])
% %                     %ylim([0 200])
% 
% 
% % Slowdown distance figure (from target)
% % 
% %     short_target_dist = slowdown_distance_to_reward(trials_reward_short_index, 1);
% %    medium_target_dist = slowdown_distance_to_reward(trials_reward_medium_index, 1);
% %    long_target_dist = slowdown_distance_to_reward(trials_reward_long_index, 1);
% %                 
% %     % outputs
% %     
% %         output.mean_short_slowdown_distance_from_target = mean(short_target_dist);
% %         output.mean_medium_slowdown_distance_from_target = mean(medium_target_dist);
% %         output.mean_long_slowdown_distance_from_target = mean(long_target_dist);
% % 
% %         output.sem_short_slowdown_distance_from_target = nanstd(short_target_dist)/ (sqrt(length(short_target_dist)));
% %         output.sem_medium_slowdown_distance_from_target = nanstd(medium_target_dist)/ (sqrt(length(medium_target_dist)));
% %         output.sem_long_slowdown_distance_from_target = nanstd(long_target_dist)/ (sqrt(length(long_target_dist)));  
% 
% %         subplot(1, 3, 1)
% %                 boxplot(short_target_dist)
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances (total) for Short Trials')
% %                     xlabel('Short Trials')
% %                     ylabel('Distance (cm)')
% %                     %xlim([0 3])
% %                     ylim([0 75])
% % 
% %                 subplot(1, 3, 2)
% %                 boxplot(medium_target_dist)
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     title('Distances from target to Reward')
% %                     xlabel('Medium Trials')
% %                     ylabel('Distance (cm)')
% %                     %xlim([0 3])
% %                     ylim([0 75])
% % 
% %                 subplot(1, 3, 3)
% %                 boxplot(long_target_dist)
% %                     hold on
% %                     %legend('Cohort 1','Cohort 2')
% %                     %title('Rewarded Distances')
% %                     xlabel('Long Trials')
% %                     ylabel('Distance (cm)')
% %                     %xlim([0 3])
% %                     ylim([0 75])                
% % 
% %   % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'SlowdownDistancesfromTargetSML_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all    
%                 
%   % Slowdown metrics (not done cause im tired and angry right now)
% 
%   stopped_trial_slowdowns_short(:, 1) = total_slowdown_velocity_metrics(trials_incomplete_slowdown_short_log(:, :), 1);
%   stopped_trial_slowdowns_short(:, 2) = total_slowdown_velocity_metrics(trials_incomplete_slowdown_short_log(:, :), 2);
%   complete_trial_slowdowns_short(:, 1) = total_slowdown_velocity_metrics(trials_reward_short_log(:, :), 1);
%   complete_trial_slowdowns_short(:, 2) = total_slowdown_velocity_metrics(trials_reward_short_log(:, :), 2);
% 
%   complete_trial_slowdowns_100(:, 1) = total_slowdown_velocity_metrics(trials_slow_100_complete_index(:, :), 1);
%   complete_trial_slowdowns_100(:, 2) = total_slowdown_velocity_metrics(trials_slow_100_complete_index(:, :), 2);
%   complete_trial_slowdowns_150(:, 1) = total_slowdown_velocity_metrics(trials_slow_150_complete_index(:, :), 1);
%   complete_trial_slowdowns_150(:, 2) = total_slowdown_velocity_metrics(trials_slow_150_complete_index(:, :), 2);
%   complete_trial_slowdowns_200(:, 1) = total_slowdown_velocity_metrics(trials_slow_200_complete_index(:, :), 1);
%   complete_trial_slowdowns_200(:, 2) = total_slowdown_velocity_metrics(trials_slow_200_complete_index(:, :), 2);
% 
% 
% sig_short = find(complete_trial_slowdowns_short(:, 2) < 0.05);
%   complete_trial_slowdowns_short_sig(:, 1) = complete_trial_slowdowns_short(sig_short(:, :), 1);
%   complete_trial_slowdowns_short_sig(:, 2) = complete_trial_slowdowns_short(sig_short(:, :), 2);
% 
% sig_stop_short = find(stopped_trial_slowdowns_short(:, 2) < 0.05);
% 
% stopped_trial_slowdowns_short_sig(:, 1) = stopped_trial_slowdowns_short(sig_stop_short(:, :), 1);
% stopped_trial_slowdowns_short_sig(:, 2) = stopped_trial_slowdowns_short(sig_stop_short(:, :), 2);
%   
% 
% sig_100 = find(complete_trial_slowdowns_100(:, 2) < 0.05);
%   complete_trial_slowdowns_100_sig(:, 1) = complete_trial_slowdowns_100(sig_100(:, :), 1);
%   complete_trial_slowdowns_100_sig(:, 2) = complete_trial_slowdowns_100(sig_100(:, :), 2);
% sig_150 = find(complete_trial_slowdowns_150(:, 2) < 0.05);
%   complete_trial_slowdowns_150_sig(:, 1) = complete_trial_slowdowns_150(sig_150(:, :), 1);
%   complete_trial_slowdowns_150_sig(:, 2) = complete_trial_slowdowns_150(sig_150(:, :), 2);
% sig_200 = find(complete_trial_slowdowns_200(:, 2) < 0.05);
%   complete_trial_slowdowns_200_sig(:, 1) = complete_trial_slowdowns_200(sig_200(:, :), 1);
%   complete_trial_slowdowns_200_sig(:, 2) = complete_trial_slowdowns_200(sig_200(:, :), 2);
% 
%   stopped_trial_slowdowns_medium(:, 1) = total_slowdown_velocity_metrics(trials_incomplete_slowdown_medium_log(:, :), 1);
%   stopped_trial_slowdowns_medium(:, 2) = total_slowdown_velocity_metrics(trials_incomplete_slowdown_medium_log(:, :), 2);
%   complete_trial_slowdowns_medium(:, 1) = total_slowdown_velocity_metrics(trials_reward_medium_log(:, :), 1);
%   complete_trial_slowdowns_medium(:, 2) = total_slowdown_velocity_metrics(trials_reward_medium_log(:, :), 2);
% 
% sig_medium = find(complete_trial_slowdowns_medium(:, 2) < 0.05);
%   complete_trial_slowdowns_medium_sig(:, 1) = complete_trial_slowdowns_medium(sig_medium(:, :), 1);
%   complete_trial_slowdowns_medium_sig(:, 2) = complete_trial_slowdowns_medium(sig_medium(:, :), 2);
% 
% sig_stop_medium = find(stopped_trial_slowdowns_medium(:, 2) < 0.05);
% 
% stopped_trial_slowdowns_medium_sig(:, 1) = stopped_trial_slowdowns_medium(sig_stop_medium(:, :), 1);
% stopped_trial_slowdowns_medium_sig(:, 2) = stopped_trial_slowdowns_medium(sig_stop_medium(:, :), 2);
% 
% 
% 
% 
% 
%   stopped_trial_slowdowns_long(:, 1) = total_slowdown_velocity_metrics(trials_incomplete_slowdown_long_log(:, :), 1);
%   stopped_trial_slowdowns_long(:, 2) = total_slowdown_velocity_metrics(trials_incomplete_slowdown_long_log(:, :), 2);
%   complete_trial_slowdowns_long(:, 1) = total_slowdown_velocity_metrics(trials_reward_long_log(:, :), 1);
%   complete_trial_slowdowns_long(:, 2) = total_slowdown_velocity_metrics(trials_reward_long_log(:, :), 2);
% 
% sig_long = find(complete_trial_slowdowns_long(:, 2) < 0.05);
%   complete_trial_slowdowns_long_sig(:, 1) = complete_trial_slowdowns_long(sig_long(:, :), 1);
%   complete_trial_slowdowns_long_sig(:, 2) = complete_trial_slowdowns_long(sig_long(:, :), 2);
% 
% sig_stop_long = find(stopped_trial_slowdowns_long(:, 2) < 0.05);
% 
% stopped_trial_slowdowns_long_sig(:, 1) = stopped_trial_slowdowns_long(sig_stop_long(:, :), 1);
% stopped_trial_slowdowns_long_sig(:, 2) = stopped_trial_slowdowns_long(sig_stop_long(:, :), 2);
% 
% % output.complete_slowdown_slopes_short = complete_trial_slowdowns_short_sig(:, 1);
% % output.incomplete_slowdown_slopes_short = stopped_trial_slowdowns_short_sig(:, 1);
% % output.mean_complete_slowdown_slopes_short = mean(complete_trial_slowdowns_short_sig(:, 1));
% % output.mean_incomplete_slowdown_slopes_short = mean(stopped_trial_slowdowns_short_sig(:, 1));
% % output.cv_complete_slowdown_slopes_short = std(complete_trial_slowdowns_short_sig(:, 1))/mean(complete_trial_slowdowns_short_sig(:, 1));
% % output.cv_incomplete_slowdown_slopes_short = std(stopped_trial_slowdowns_short_sig(:, 1))/mean(stopped_trial_slowdowns_short_sig(:, 1));
% % 
% % output.complete_slowdown_slopes_medium = complete_trial_slowdowns_medium_sig(:, 1);
% % output.incomplete_slowdown_slopes_medium = stopped_trial_slowdowns_medium_sig(:, 1);
% % output.mean_complete_slowdown_slopes_medium = mean(complete_trial_slowdowns_medium_sig(:, 1));
% % output.mean_incomplete_slowdown_slopes_medium = mean(stopped_trial_slowdowns_medium_sig(:, 1));
% % output.cv_complete_slowdown_slopes_medium = std(complete_trial_slowdowns_medium_sig(:, 1))/mean(complete_trial_slowdowns_medium_sig(:, 1));
% % output.cv_incomplete_slowdown_slopes_medium = std(stopped_trial_slowdowns_medium_sig(:, 1))/mean(stopped_trial_slowdowns_medium_sig(:, 1));
% % 
% % output.complete_slowdown_slopes_long = complete_trial_slowdowns_long_sig(:, 1);
% % output.incomplete_slowdown_slopes_long = stopped_trial_slowdowns_long_sig(:, 1);
% % output.mean_complete_slowdown_slopes_long = mean(complete_trial_slowdowns_long_sig(:, 1));
% % output.mean_incomplete_slowdown_slopes_long = mean(stopped_trial_slowdowns_long_sig(:, 1));
% % output.cv_complete_slowdown_slopes_long = std(complete_trial_slowdowns_long_sig(:, 1))/mean(complete_trial_slowdowns_long_sig(:, 1));
% % output.cv_incomplete_slowdown_slopes_long = std(stopped_trial_slowdowns_long_sig(:, 1))/mean(stopped_trial_slowdowns_long_sig(:, 1));
% % 
% % 
% % output.mean_complete_trial_slowdowns_100_sig = mean(complete_trial_slowdowns_100_sig(:, 1));
% % output.mean_complete_trial_slowdowns_150_sig = mean(complete_trial_slowdowns_150_sig(:, 1));
% % output.mean_complete_trial_slowdowns_200_sig = mean(complete_trial_slowdowns_200_sig(:, 1));
% % 
% % output.CV_complete_trial_slowdowns_100_sig = std(complete_trial_slowdowns_100_sig(:, 1))/mean(complete_trial_slowdowns_100_sig(:, 1));
% % output.CV_complete_trial_slowdowns_150_sig = std(complete_trial_slowdowns_150_sig(:, 1))/mean(complete_trial_slowdowns_150_sig(:, 1));
% % output.CV_complete_trial_slowdowns_202_sig = std(complete_trial_slowdowns_200_sig(:, 1))/mean(complete_trial_slowdowns_200_sig(:, 1));
% % 
% % output.velocity_reduction_complete_time = velocity_reduction_ratio_time(complete_trials_index, 1);
% % output.velocity_reduction_complete_short_time = velocity_reduction_ratio_time(trials_reward_short_index, 1);
% % output.velocity_reduction_complete_medium_time = velocity_reduction_ratio_time(trials_reward_medium_index, 1);
% % output.velocity_reduction_complete_long_time = velocity_reduction_ratio_time(trials_reward_long_index, 1);
% % 
% % output.velocity_reduction_overrun_time = velocity_reduction_ratio_time(trials_overrun_index, 1);
% % output.velocity_reduction_stopped_time= velocity_reduction_ratio_time(incomplete_slowdown_trials_index, 1);
% % 
% % 
% % output.velocity_reduction_complete_dist = velocity_reduction_ratio_dist(complete_trials_index, 1);
% % output.velocity_reduction_complete_short_dist = velocity_reduction_ratio_dist(trials_reward_short_index, 1);
% % output.velocity_reduction_complete_medium_dist = velocity_reduction_ratio_dist(trials_reward_medium_index, 1);
% % output.velocity_reduction_complete_long_dist = velocity_reduction_ratio_dist(trials_reward_long_index, 1);
% % 
% % output.velocity_reduction_overrun_dist = velocity_reduction_ratio_dist(trials_overrun_index, 1);
% % output.velocity_reduction_stopped_dist= velocity_reduction_ratio_dist(incomplete_slowdown_trials_index, 1);
% 
% % Maintainence Heatmaps
% 
% x = size(trials_reward_short_index, 1);
% y = size(trials_reward_medium_index, 1);
% z = size(trials_reward_long_index, 1);
% 
% 
% heatmap_data_short_vel_maint_time(1:x, :) = movement_velocities_maintain_time(trials_reward_short_index, :); 
% heatmap_data_medium_vel_maint_time(1:y, :) = movement_velocities_maintain_time(trials_reward_medium_index, :); 
% heatmap_data_long_vel_maint_time(1:z, :) = movement_velocities_maintain_time(trials_reward_long_index, :); 
% 
% % figure(16)
% % heatmap(heatmap_data_short_vel_maint_time, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_Short_time_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all
% % 
% % figure(17)
% % heatmap(heatmap_data_medium_vel_maint_time, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_medium_time_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all    
% % 
% % figure(18)
% % heatmap(heatmap_data_long_vel_maint_time, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_long_time_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all           
% 
% 
% 
% heatmap_data_short_vel_maint_dist(1:x, :) = movement_velocities_maintain_dist(trials_reward_short_index, :); 
% heatmap_data_medium_vel_maint_dist(1:y, :) = movement_velocities_maintain_dist(trials_reward_medium_index, :); 
% heatmap_data_long_vel_maint_dist(1:z, :) = movement_velocities_maintain_dist(trials_reward_long_index, :); 
% 
% % figure(16)
% % heatmap(heatmap_data_short_vel_maint_dist, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_Short_dist_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all
% % 
% % figure(17)
% % heatmap(heatmap_data_medium_vel_maint_dist, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% 
% % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_medium_dist_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all    
% % 
% % figure(18)
% % heatmap(heatmap_data_long_vel_maint_dist, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_long_dist_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all    
% 
% 
% 
% maintenance_velocity_metrics_time_sig = maintenance_velocity_metrics_time(:, 2) < 0.05;
% 
% significant_maintenance_velocity_metrics_short_complete_time = trials_reward_short .* maintenance_velocity_metrics_time_sig;
% significant_maintenance_velocity_metrics_medium_complete_time = trials_reward_medium .* maintenance_velocity_metrics_time_sig;
% significant_maintenance_velocity_metrics_long_complete_time = trials_reward_long .* maintenance_velocity_metrics_time_sig;
% 
% % output.mean_maintenance_metric_short_time = mean(maintenance_velocity_metrics_time(trials_reward_short_index, 1));
% % output.mean_maintenance_metric_medium_time = mean(maintenance_velocity_metrics_time(trials_reward_medium_index, 1));
% % output.mean_maintenance_metric_long_time = mean(maintenance_velocity_metrics_time(trials_reward_long_index, 1));
% % 
% % output.ratio_of_significant_maintenance_metric_short_time = sum(significant_maintenance_velocity_metrics_short_complete_time) / length(maintenance_velocity_metrics_time(trials_reward_short_index, 1));
% % output.ratio_of_significant_maintenance_metric_medium_time = sum(significant_maintenance_velocity_metrics_medium_complete_time) / length(maintenance_velocity_metrics_time(trials_reward_medium_index, 1));
% % output.ratio_of_significant_maintenance_metric_long_time = sum(significant_maintenance_velocity_metrics_long_complete_time) / length(maintenance_velocity_metrics_time(trials_reward_long_index, 1));
% % 
% 
% maintenance_velocity_metrics_dist_sig = maintenance_velocity_metrics_dist(:, 2) < 0.05;
% 
% significant_maintenance_velocity_metrics_short_complete_dist = trials_reward_short .* maintenance_velocity_metrics_dist_sig;
% significant_maintenance_velocity_metrics_medium_complete_dist = trials_reward_medium .* maintenance_velocity_metrics_dist_sig;
% significant_maintenance_velocity_metrics_long_complete_dist = trials_reward_long .* maintenance_velocity_metrics_dist_sig;
% 
% % output.mean_maintenance_metric_short_dist = mean(maintenance_velocity_metrics_dist(trials_reward_short_index, 1));
% % output.mean_maintenance_metric_medium_dist = mean(maintenance_velocity_metrics_dist(trials_reward_medium_index, 1));
% % output.mean_maintenance_metric_long_dist = mean(maintenance_velocity_metrics_dist(trials_reward_long_index, 1));
% % 
% % output.ratio_of_significant_maintenance_metric_short_dist = sum(significant_maintenance_velocity_metrics_short_complete_dist) / length(maintenance_velocity_metrics_dist(trials_reward_short_index, 1));
% % output.ratio_of_significant_maintenance_metric_medium_dist = sum(significant_maintenance_velocity_metrics_medium_complete_dist) / length(maintenance_velocity_metrics_dist(trials_reward_medium_index, 1));
% % output.ratio_of_significant_maintenance_metric_long_dist = sum(significant_maintenance_velocity_metrics_long_complete_dist) / length(maintenance_velocity_metrics_dist(trials_reward_long_index, 1));
% % 
% 
% % output.complete_short = complete_short_trials_sum;
% % output.complete_medium = complete_medium_trials_sum;
% % output.complete_long = complete_long_trials_sum;
% 
% % Premature slowdown trials-- maintainence analysis
% 
% trials_premature_slow_short_log = find(trials_premature_slow_short(:, 1) == 1);
% trials_premature_slow_medium_log = find(trials_premature_slow_medium(:, 1) == 1);
% trials_premature_slow_long_log = find(trials_premature_slow_long(:, 1) == 1);
% 
% x = size(trials_premature_slow_short_log, 1);
% y = size(trials_premature_slow_medium_log, 1);
% z = size(trials_premature_slow_long_log, 1);
% 
% heatmap_data_short_vel_maint_time_prematureslow(1:x, :) = movement_velocities_maintain_time(trials_premature_slow_short_log, :); 
% heatmap_data_medium_vel_maint_time_prematureslow(1:y, :) = movement_velocities_maintain_time(trials_premature_slow_medium_log, :); 
% heatmap_data_long_vel_maint_time_prematureslow(1:z, :) = movement_velocities_maintain_time(trials_premature_slow_long_log, :); 
% 
% % figure(16)
% % heatmap(heatmap_data_short_vel_maint_time_prematureslow, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_Short_time_prematureslow_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all
% % 
% % figure(17)
% % heatmap(heatmap_data_medium_vel_maint_time_prematureslow, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_medium_time_prematureslow_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all    
% % 
% % figure(18)
% % heatmap(heatmap_data_long_vel_maint_time_prematureslow, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_long_time_prematureslow_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all           
% % 
% % 
% % 
% heatmap_data_short_vel_maint_dist_prematureslow(1:x, :) = movement_velocities_maintain_dist(trials_premature_slow_short_log, :); 
% heatmap_data_medium_vel_maint_dist_prematureslow(1:y, :) = movement_velocities_maintain_dist(trials_premature_slow_medium_log, :); 
% heatmap_data_long_vel_maint_dist_prematureslow(1:z, :) = movement_velocities_maintain_dist(trials_premature_slow_long_log, :); 
% 
% % figure(16)
% % heatmap(heatmap_data_short_vel_maint_dist_prematureslow, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_Short_dist_prematureslow_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all
% % 
% % figure(17)
% % heatmap(heatmap_data_medium_vel_maint_dist_prematureslow, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_medium_dist_prematureslow_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all    
% % 
% % figure(18)
% % heatmap(heatmap_data_long_vel_maint_dist_prematureslow, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_Maint_long_dist_prematureslow_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all  
% 
% 
% sig_maint_velocity_metrics_short_premature_slow_time = trials_premature_slow_short .* maintenance_velocity_metrics_time_sig;
% sig_maint_velocity_metrics_medium_premature_slow_time = trials_premature_slow_medium .* maintenance_velocity_metrics_time_sig;
% sig_maint_velocity_metrics_long_premature_slow_time = trials_premature_slow_long .* maintenance_velocity_metrics_time_sig;
% 
% % output.mean_maintenance_metric_short_time_premature_slow = mean(maintenance_velocity_metrics_time(trials_premature_slow_short_log, 1));
% % output.mean_maintenance_metric_medium_time_premature_slow = mean(maintenance_velocity_metrics_time(trials_premature_slow_medium_log, 1));
% % output.mean_maintenance_metric_long_time_premature_slow = mean(maintenance_velocity_metrics_time(trials_premature_slow_long_log, 1));
% % 
% % output.ratio_sig_maint_metric_short_time_premature_slow = sum(sig_maint_velocity_metrics_short_premature_slow_time) / length(maintenance_velocity_metrics_time(trials_premature_slow_short_log, 1));
% % output.ratio_sig_maint_metric_medium_time_premature_slow = sum(sig_maint_velocity_metrics_medium_premature_slow_time) / length(maintenance_velocity_metrics_time(trials_premature_slow_medium_log, 1));
% % output.ratio_sig_maint_metric_long_time_premature_slow = sum(sig_maint_velocity_metrics_long_premature_slow_time) / length(maintenance_velocity_metrics_time(trials_premature_slow_long_log, 1));
% % 
% % 
% 
% 
% sig_maint_velocity_metrics_short_premature_slow_dist = trials_premature_slow_short .* maintenance_velocity_metrics_dist_sig;
% sig_maint_velocity_metrics_medium_premature_slow_dist = trials_premature_slow_medium .* maintenance_velocity_metrics_dist_sig;
% sig_maint_velocity_metrics_long_premature_slow_dist = trials_premature_slow_long .* maintenance_velocity_metrics_dist_sig;
% 
% % output.mean_maintenance_metric_short_dist_premature_slow = mean(maintenance_velocity_metrics_dist(trials_premature_slow_short_log, 1));
% % output.mean_maintenance_metric_medium_dist_premature_slow = mean(maintenance_velocity_metrics_dist(trials_premature_slow_medium_log, 1));
% % output.mean_maintenance_metric_long_dist_premature_slow = mean(maintenance_velocity_metrics_dist(trials_premature_slow_long_log, 1));
% % 
% % output.ratio_sig_maint_metric_short_dist_premature_slow = sum(sig_maint_velocity_metrics_short_premature_slow_dist) / length(maintenance_velocity_metrics_dist(trials_premature_slow_short_log, 1));
% % output.ratio_sig_maint_metric_medium_dist_premature_slow = sum(sig_maint_velocity_metrics_medium_premature_slow_dist) / length(maintenance_velocity_metrics_dist(trials_premature_slow_medium_log, 1));
% % output.ratio_sig_maint_metric_long_dist_premature_slow = sum(sig_maint_velocity_metrics_long_premature_slow_dist) / length(maintenance_velocity_metrics_dist(trials_premature_slow_long_log, 1));
% 
% 
% % % Performance for maintanence parameter tasks
% 
% %     % Create index 
% 
% %     trials_mat_12_para_120_index = find(trials_mat_12_para_120 == 1);
% %     trials_mat_12_para_150_index = find(trials_mat_12_para_150 == 1);
% %     trials_mat_12_para_130_index = find(trials_mat_12_para_130 == 1);
% 
% %     % trials_mat_13_para_25_index = find(trials_mat_13_para_25 == 1);
% %     % trials_mat_13_para_30_index = find(trials_mat_13_para_30 == 1);
% %     % trials_mat_13_para_35_index = find(trials_mat_13_para_35 == 1);    
% 
% %     % Obtain Performance Data
% 
% %     if str2num(phase) == 12
% 
% %         % mat_12_para_50 performance
% 
% %             trials_mat_12_para_120_reward = trials_mat_12_para_120 .* trials_reward;
% %             trials_mat_12_para_120_premature_slowdown = trials_mat_12_para_120 .* trials_premature_slow;
% %             trials_mat_12_para_120_premature = trials_mat_12_para_120 .* trials_premature;
% %             trials_mat_12_para_120_running_period = trials_mat_12_para_120 .* ~trials_mat_12_para_120_premature;
% 
% 
% %             Complete_Trials_mat_12_para_120 = sum(trials_mat_12_para_120_reward);
% %             Premature_slowdown_trials_mat_12_para_120 = sum(trials_mat_12_para_120_premature_slowdown);        
% %             Total_Running_Trials_mat_12_para_120 = sum(trials_mat_12_para_120_running_period);  
% 
% %             output.mat_12_para_120_reward_prop = Complete_Trials_mat_12_para_120 / Total_Running_Trials_mat_12_para_120;
% %             output.mat_12_para_120_error_prop = Premature_slowdown_trials_mat_12_para_120 / Total_Running_Trials_mat_12_para_120;
% %             output.mat_12_para_120_total_running = Total_Running_Trials_mat_12_para_120;
% %             output.mat_12_para_120_reward_total = Complete_Trials_mat_12_para_120;
% 
% %         % mat_12_para_50 figures
% 
% %         trials_mat_12_para_120_reward_index = find(trials_mat_12_para_120_reward == 1);
% %         trials_mat_12_para_120_premature_slowdown_index = find(trials_mat_12_para_120_premature_slowdown == 1);
% 
% %         x = size(trials_mat_12_para_120_reward_index, 1);
% 
% %         heatmap_data_time_mat_12_para_120_reward(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_12_para_120_reward_index, :); 
% 
% 
% % %         figure(18)
% % %         heatmap(heatmap_data_time_mat_12_para_120_reward, 'Colormap', jet, 'ColorLimits',[0 600])
% % % 
% % %                % Save Fig file to computer 
% % % 
% % %                 [Where] = Where_file(filename);
% % %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_12_para_120_reward_', date, '_', num)];
% % %                 savefig(SaveName);            
% % %                 
% % %                 close all
% 
% %         x = size(trials_mat_12_para_120_premature_slowdown_index, 1);
% 
% %         heatmap_data_time_mat_12_para_120_premature_slowdown(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_12_para_120_premature_slowdown_index, :); 
% 
% 
% % %         figure(18)
% % %         heatmap(heatmap_data_time_mat_12_para_120_premature_slowdown, 'Colormap', jet, 'ColorLimits',[0 600])
% % % 
% % %                % Save Fig file to computer 
% % % 
% % %                 [Where] = Where_file(filename);
% % %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_12_para_120_premature_slowdown_', date, '_', num)];
% % %                 savefig(SaveName);            
% % %                 
% % %                 close all
% 
% %         % mat_12_para_55 performance
% 
% %             trials_mat_12_para_150_reward = trials_mat_12_para_150 .* trials_reward;
% %             trials_mat_12_para_150_premature_slowdown = trials_mat_12_para_150 .* trials_premature_slow;
% %             trials_mat_12_para_150_premature = trials_mat_12_para_150 .* trials_premature;
% %             trials_mat_12_para_150_running_period = trials_mat_12_para_150 .* ~trials_mat_12_para_150_premature;
% 
% 
% %             Complete_Trials_mat_12_para_150 = sum(trials_mat_12_para_150_reward);
% %             Premature_slowdown_trials_mat_12_para_150 = sum(trials_mat_12_para_150_premature_slowdown);        
% %             Total_Running_Trials_mat_12_para_150 = sum(trials_mat_12_para_150_running_period);  
% 
% %             output.mat_12_para_150_reward_prop = Complete_Trials_mat_12_para_150 / Total_Running_Trials_mat_12_para_150;
% %             output.mat_12_para_150_error_prop = Premature_slowdown_trials_mat_12_para_150 / Total_Running_Trials_mat_12_para_150;
% %             output.mat_12_para_150_total_running = Total_Running_Trials_mat_12_para_150;
% %             output.mat_12_para_150_reward_total = Complete_Trials_mat_12_para_150;
% 
% %         % mat_12_para_55 figure
%         
% %         trials_mat_12_para_150_reward_index = find(trials_mat_12_para_150_reward == 1);
% %         trials_mat_12_para_150_premature_slowdown_index = find(trials_mat_12_para_150_premature_slowdown == 1);
% 
% %         x = size(trials_mat_12_para_150_reward_index, 1);
% 
% %         heatmap_data_time_mat_12_para_150_reward(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_12_para_150_reward_index, :); 
% 
% 
% % %         figure(18)
% % %         heatmap(heatmap_data_time_mat_12_para_150_reward, 'Colormap', jet, 'ColorLimits',[0 600])
% % % 
% % %                % Save Fig file to computer 
% % % 
% % %                 [Where] = Where_file(filename);
% % %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_12_para_150_reward_', date, '_', num)];
% % %                 savefig(SaveName);            
% % %                 
% % %                 close all
% 
% %         x = size(trials_mat_12_para_150_premature_slowdown_index, 1);
% 
% %         heatmap_data_time_mat_12_para_150_premature_slowdown(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_12_para_150_premature_slowdown_index, :); 
% 
% 
% % %         figure(18)
% % %         heatmap(heatmap_data_time_mat_12_para_150_premature_slowdown, 'Colormap', jet, 'ColorLimits',[0 600])
% % % 
% % %                % Save Fig file to computer 
% % % 
% % %                 [Where] = Where_file(filename);
% % %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_12_para_150_premature_slowdown_', date, '_', num)];
% % %                 savefig(SaveName);            
% % %                 
% % %                 close all
% 
% %         % mat_12_para_60 performance
% 
% %             trials_mat_12_para_130_reward = trials_mat_12_para_130 .* trials_reward;
% %             trials_mat_12_para_130_premature_slowdown = trials_mat_12_para_130 .* trials_premature_slow;
% %             trials_mat_12_para_130_premature = trials_mat_12_para_130 .* trials_premature;
% %             trials_mat_12_para_130_running_period = trials_mat_12_para_130 .* ~trials_mat_12_para_130_premature;
% 
% 
% %             Complete_Trials_mat_12_para_130 = sum(trials_mat_12_para_130_reward);
% %             Premature_slowdown_trials_mat_12_para_130 = sum(trials_mat_12_para_130_premature_slowdown);        
% %             Total_Running_Trials_mat_12_para_130 = sum(trials_mat_12_para_130_running_period);  
% 
% %             output.mat_12_para_130_reward_prop = Complete_Trials_mat_12_para_130 / Total_Running_Trials_mat_12_para_130;
% %             output.mat_12_para_130_error_prop = Premature_slowdown_trials_mat_12_para_130 / Total_Running_Trials_mat_12_para_130;
% %             output.mat_12_para_130_total_running = Total_Running_Trials_mat_12_para_130;
% %             output.mat_12_para_130_reward_total = Complete_Trials_mat_12_para_130;   
%             
% %         % mat_12_para_60 figure
%         
% %         trials_mat_12_para_130_reward_index = find(trials_mat_12_para_130_reward == 1);
% %         trials_mat_12_para_130_premature_slowdown_index = find(trials_mat_12_para_130_premature_slowdown == 1);
% 
% %         x = size(trials_mat_12_para_130_reward_index, 1);
% 
% %         heatmap_data_time_mat_12_para_130_reward(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_12_para_130_reward_index, :); 
% 
% % % 
% % %         figure(18)
% % %         heatmap(heatmap_data_time_mat_12_para_130_reward, 'Colormap', jet, 'ColorLimits',[0 600])
% % % 
% % %                % Save Fig file to computer 
% % % 
% % %                 [Where] = Where_file(filename);
% % %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_12_para_130_reward_', date, '_', num)];
% % %                 savefig(SaveName);            
% % %                 
% % %                 close all
% 
% %         x = size(trials_mat_12_para_130_premature_slowdown_index, 1);
% 
% %         heatmap_data_time_mat_12_para_130_premature_slowdown(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_12_para_130_premature_slowdown_index, :); 
% 
% 
% % %         figure(18)
% % %         heatmap(heatmap_data_time_mat_12_para_130_premature_slowdown, 'Colormap', jet, 'ColorLimits',[0 600])
% % % 
% % %                % Save Fig file to computer 
% % % 
% % %                 [Where] = Where_file(filename);
% % %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_12_para_130_premature_slowdown_', date, '_', num)];
% % %                 savefig(SaveName);            
% % %                 
% % %                 close all
% %     else
% 
% %             output.mat_12_para_120_reward_prop = NaN;
% %             output.mat_12_para_120_error_prop = NaN;
% %             output.mat_12_para_120_total_running = NaN;
% %             output.mat_12_para_120_reward_total = NaN;
% 
% %             output.mat_12_para_150_reward_prop = NaN;
% %             output.mat_12_para_150_error_prop = NaN;
% %             output.mat_12_para_150_total_running = NaN;
% %             output.mat_12_para_150_reward_total = NaN;
% 
% %             output.mat_12_para_130_reward_prop = NaN;
% %             output.mat_12_para_130_error_prop = NaN;
% %             output.mat_12_para_130_total_running = NaN;
% %             output.mat_12_para_130_reward_total = NaN; 
%             
% %     end 
% 
% %     % if phase == '13'
% 
% %     %     % mat_13_para_25 performance
% 
% %     %         trials_mat_13_para_25_reward = trials_mat_13_para_25 .* trials_reward;
% %     %         trials_mat_13_para_25_premature_slowdown = trials_mat_13_para_25 .* trials_premature_slow;
% %     %         trials_mat_13_para_25_premature = trials_mat_13_para_25 .* trials_premature;
% %     %         trials_mat_13_para_25_running_period = trials_mat_13_para_25 .* ~trials_mat_13_para_25_premature;
% 
% 
% %     %         Complete_Trials_mat_13_para_25 = sum(trials_mat_13_para_25_reward);
% %     %         Premature_slowdown_trials_mat_13_para_25 = sum(trials_mat_13_para_25_premature_slowdown);        
% %     %         Total_Running_Trials_mat_13_para_25 = sum(trials_mat_13_para_25_running_period);  
% 
% %     %         output.mat_13_para_25_reward_prop = Complete_Trials_mat_13_para_25 / Total_Running_Trials_mat_13_para_25;
% %     %         output.mat_13_para_25_error_prop = Premature_slowdown_trials_mat_13_para_25 / Total_Running_Trials_mat_13_para_25;
% %     %         output.mat_13_para_25_total_running = Total_Running_Trials_mat_13_para_25;
%        
% %     %     % mat_13_para_25 figure
%         
% %     %     trials_mat_13_para_25_reward_index = find(trials_mat_13_para_25_reward == 1);
% %     %     trials_mat_13_para_25_premature_slowdown_index = find(trials_mat_13_para_25_premature_slowdown == 1);
% 
% %     %     x = size(trials_mat_13_para_25_reward_index, 1);
% 
% %     %     heatmap_data_time_mat_13_para_25_reward(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_13_para_25_reward_index, :); 
% 
% 
% %     %     figure(18)
% %     %     heatmap(heatmap_data_time_mat_13_para_25_reward, 'Colormap', jet, 'ColorLimits',[0 600])
% 
% %     %            % Save Fig file to computer 
% 
% %     %             [Where] = Where_file(filename);
% %     %             SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_13_para_25_reward_', date, '_', num)];
% %     %             savefig(SaveName);            
%                 
% %     %             close all
% 
% %     %     x = size(trials_mat_13_para_25_premature_slowdown_index, 1);
% 
% %     %     heatmap_data_time_mat_13_para_25_premature_slowdown(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_13_para_25_premature_slowdown_index, :); 
% 
% 
% %     %     figure(18)
% %     %     heatmap(heatmap_data_time_mat_13_para_25_premature_slowdown, 'Colormap', jet, 'ColorLimits',[0 600])
% 
% %     %            % Save Fig file to computer 
% 
% %     %             [Where] = Where_file(filename);
% %     %             SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_13_para_25_premature_slowdown_', date, '_', num)];
% %     %             savefig(SaveName);            
%                 
% %     %             close all
% %     %     % mat_13_para_30 performance
% 
% %     %         trials_mat_13_para_30_reward = trials_mat_13_para_30 .* trials_reward;
% %     %         trials_mat_13_para_30_premature_slowdown = trials_mat_13_para_30 .* trials_premature_slow;
% %     %         trials_mat_13_para_30_premature = trials_mat_13_para_30 .* trials_premature;
% %     %         trials_mat_13_para_30_running_period = trials_mat_13_para_30 .* ~trials_mat_13_para_30_premature;
% 
% 
% %     %         Complete_Trials_mat_13_para_30 = sum(trials_mat_13_para_30_reward);
% %     %         Premature_slowdown_trials_mat_13_para_30 = sum(trials_mat_13_para_30_premature_slowdown);        
% %     %         Total_Running_Trials_mat_13_para_30 = sum(trials_mat_13_para_30_running_period);  
% 
% %     %         output.mat_13_para_30_reward_prop = Complete_Trials_mat_13_para_30 / Total_Running_Trials_mat_13_para_30;
% %     %         output.mat_13_para_30_error_prop = Premature_slowdown_trials_mat_13_para_30 / Total_Running_Trials_mat_13_para_30;
%        
% %     %     % mat_13_para_30 figure
%         
% %     %     trials_mat_13_para_30_reward_index = find(trials_mat_13_para_30_reward == 1);
% %     %     trials_mat_13_para_30_premature_slowdown_index = find(trials_mat_13_para_30_premature_slowdown == 1);
% %     %         output.mat_13_para_30_total_running = Total_Running_Trials_mat_13_para_30;
% 
% %     %     x = size(trials_mat_13_para_30_reward_index, 1);
% 
% %     %     heatmap_data_time_mat_13_para_30_reward(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_13_para_30_reward_index, :); 
% 
% 
% %     %     figure(18)
% %     %     heatmap(heatmap_data_time_mat_13_para_30_reward, 'Colormap', jet, 'ColorLimits',[0 600])
% 
% %     %            % Save Fig file to computer 
% 
% %     %             [Where] = Where_file(filename);
% %     %             SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_13_para_30_reward_', date, '_', num)];
% %     %             savefig(SaveName);            
%                 
% %     %             close all
% 
% %     %     x = size(trials_mat_13_para_30_premature_slowdown_index, 1);
% 
% %     %     heatmap_data_time_mat_13_para_30_premature_slowdown(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_13_para_30_premature_slowdown_index, :); 
% 
% 
% %     %     figure(18)
% %     %     heatmap(heatmap_data_time_mat_13_para_30_premature_slowdown, 'Colormap', jet, 'ColorLimits',[0 600])
% 
% %     %            % Save Fig file to computer 
% 
% %     %             [Where] = Where_file(filename);
% %     %             SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_13_para_30_premature_slowdown_', date, '_', num)];
% %     %             savefig(SaveName);            
%                 
% %     %             close all
% %     %     % mat_13_para_35 performance
% 
% %     %         trials_mat_13_para_35_reward = trials_mat_13_para_35 .* trials_reward;
% %     %         trials_mat_13_para_35_premature_slowdown = trials_mat_13_para_35 .* trials_premature_slow;
% %     %         trials_mat_13_para_35_premature = trials_mat_13_para_35 .* trials_premature;
% %     %         trials_mat_13_para_35_running_period = trials_mat_13_para_35 .*  ~trials_mat_13_para_35_premature;
% 
% 
% %     %         Complete_Trials_mat_13_para_35 = sum(trials_mat_13_para_35_reward);
% %     %         Premature_slowdown_trials_mat_13_para_35 = sum(trials_mat_13_para_35_premature_slowdown);        
% %     %         Total_Running_Trials_mat_13_para_35 = sum(trials_mat_13_para_35_running_period);  
% 
% %     %         output.mat_13_para_35_reward_prop = Complete_Trials_mat_13_para_35 / Total_Running_Trials_mat_13_para_35;
% %     %         output.mat_13_para_35_error_prop = Premature_slowdown_trials_mat_13_para_35 / Total_Running_Trials_mat_13_para_35;
% %     %            output.mat_13_para_35_total_running = Total_Running_Trials_mat_13_para_35;
%     
% %     %     % mat_13_para_35 figure
%         
% %     %     trials_mat_13_para_35_reward_index = find(trials_mat_13_para_35_reward == 1);
% %     %     trials_mat_13_para_35_premature_slowdown_index = find(trials_mat_13_para_35_premature_slowdown == 1);
% 
% %     %     x = size(trials_mat_13_para_35_reward_index, 1);
% 
% %     %     heatmap_data_time_mat_13_para_35_reward(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_13_para_35_reward_index, :); 
% 
% 
% %     %     figure(18)
% %     %     heatmap(heatmap_data_time_mat_13_para_35_reward, 'Colormap', jet, 'ColorLimits',[0 600])
% 
% %     %            % Save Fig file to computer 
% 
% %     %             [Where] = Where_file(filename);
% %     %             SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_13_para_35_reward_', date, '_', num)];
% %     %             savefig(SaveName);            
%                 
% %     %             close all
% 
% %     %     x = size(trials_mat_13_para_35_premature_slowdown_index, 1);
% 
% %     %     heatmap_data_time_mat_13_para_35_premature_slowdown(1:x, :) = movement_velocities_smooth_mean_time(trials_mat_13_para_35_premature_slowdown_index, :); 
% 
% 
% %     %     figure(18)
% %     %     heatmap(heatmap_data_time_mat_13_para_35_premature_slowdown, 'Colormap', jet, 'ColorLimits',[0 600])
% 
% %     %            % Save Fig file to computer 
% 
% %     %             [Where] = Where_file(filename);
% %     %             SaveName = [strcat(Where, 'VelocityHeatmap_time_mat_13_para_35_premature_slowdown_', date, '_', num)];
% %     %             savefig(SaveName);            
%                 
% %     %             close all
% 
% %     % end
% 
% % % Tone averages SML
% 
% %     mean_20_vel = mean(movement_20_velocities_smooth_mean_data_dist, 2);
% %     mean_40_vel = mean(movement_40_velocities_smooth_mean_data_dist, 2);
% %     mean_60_vel = mean(movement_60_velocities_smooth_mean_data_dist, 2);
% %     mean_80_vel = mean(movement_80_velocities_smooth_mean_data_dist, 2);
% %     mean_100_vel = mean(movement_100_velocities_smooth_mean_data_dist, 2);
% 
% %     tone_means = [mean_20_vel, mean_40_vel, mean_60_vel, mean_80_vel, mean_100_vel];
% 
% 
% %     tone_means_short_reward_plotdata = tone_means(trials_reward_short_index, :);
% %     tone_means_medium_reward_plotdata = tone_means(trials_reward_medium_index, :);
% %     tone_means_long_reward_plotdata = tone_means(trials_reward_long_index, :);
% 
% %     % Figure
% 
% %         % hold on
% 
% %         % options.color_line = [236 112  22]./255;
% %         % options.color_area = [243 169 114]./255;
% %         % plot_areaerrorbar(tone_means_short_reward_plotdata, options)
% 
% %         % clear options
% 
% %         % options.color_line = [216 0  115]./255;
% %         % options.color_area = [226 20 135]./255;
% %         % plot_areaerrorbar(tone_means_medium_reward_plotdata, options)
% 
% %         % clear options
% 
% %         %         options.color_area = [128 193 219]./255;   
% %         %         options.color_line = [ 52 148 186]./255;
% %         % plot_areaerrorbar(tone_means_long_reward_plotdata)
% 
% %         % legend( '', 'short', '', 'medium', '', 'long')
% %         % xticks([ 1 2 3 4 5])
% %         % ylim([0 600])
% %         % xlabel('Tone Number')
% %         % ylabel('Average Velocity (cm/s)')
% %         % title('Average Velocity by Tone for Complete Trials by Distance')
% 
% %         %                % Save Fig file to computer 
% 
% %         %                 [Where] = Where_file(filename);
% %         %                 SaveName = [strcat(Where, 'Tone_Means_SML_', date, '_', num)];
% %         %                 savefig(SaveName);            
%                         
% %         %                 close all
% 
% %     % Save means/SEMs as outputs
% 
% %         output.MeanVel_T1_rewarded_short = mean(tone_means_short_reward_plotdata(:, 1));          
% %         output.MeanVel_T2_rewarded_short = mean(tone_means_short_reward_plotdata(:, 2));         
% %         output.MeanVel_T3_rewarded_short = mean(tone_means_short_reward_plotdata(:, 3));
% %         output.MeanVel_T4_rewarded_short = mean(tone_means_short_reward_plotdata(:, 4));         
% %         output.MeanVel_T5_rewarded_short = mean(tone_means_short_reward_plotdata(:, 5));         
% 
% %         output.MeanVel_T1_rewarded_medium = mean(tone_means_medium_reward_plotdata(:, 1));          
% %         output.MeanVel_T2_rewarded_medium = mean(tone_means_medium_reward_plotdata(:, 2));         
% %         output.MeanVel_T3_rewarded_medium = mean(tone_means_medium_reward_plotdata(:, 3));
% %         output.MeanVel_T4_rewarded_medium = mean(tone_means_medium_reward_plotdata(:, 4));         
% %         output.MeanVel_T5_rewarded_medium = mean(tone_means_medium_reward_plotdata(:, 5));    
% 
% %         output.MeanVel_T1_rewarded_long = mean(tone_means_long_reward_plotdata(:, 1));          
% %         output.MeanVel_T2_rewarded_long = mean(tone_means_long_reward_plotdata(:, 2));         
% %         output.MeanVel_T3_rewarded_long = mean(tone_means_long_reward_plotdata(:, 3));
% %         output.MeanVel_T4_rewarded_long = mean(tone_means_long_reward_plotdata(:, 4));         
% %         output.MeanVel_T5_rewarded_long = mean(tone_means_long_reward_plotdata(:, 5)); 
% 
% 
% %         output.SEMVel_T1_rewarded_short = std(tone_means_short_reward_plotdata(:, 1)) / sqrt(length(tone_means_short_reward_plotdata(:, 1)));          
% %         output.SEMVel_T2_rewarded_short = std(tone_means_short_reward_plotdata(:, 2)) / sqrt(length(tone_means_short_reward_plotdata(:, 2)));         
% %         output.SEMVel_T3_rewarded_short = std(tone_means_short_reward_plotdata(:, 3)) / sqrt(length(tone_means_short_reward_plotdata(:, 3)));
% %         output.SEMVel_T4_rewarded_short = std(tone_means_short_reward_plotdata(:, 4)) / sqrt(length(tone_means_short_reward_plotdata(:, 4)));         
% %         output.SEMVel_T5_rewarded_short = std(tone_means_short_reward_plotdata(:, 5)) / sqrt(length(tone_means_short_reward_plotdata(:, 5)));         
% 
% %         output.SEMVel_T1_rewarded_medium = std(tone_means_medium_reward_plotdata(:, 1)) / sqrt(length(tone_means_medium_reward_plotdata(:, 1)));          
% %         output.SEMVel_T2_rewarded_medium = std(tone_means_medium_reward_plotdata(:, 2)) / sqrt(length(tone_means_medium_reward_plotdata(:, 2)));         
% %         output.SEMVel_T3_rewarded_medium = std(tone_means_medium_reward_plotdata(:, 3)) / sqrt(length(tone_means_medium_reward_plotdata(:, 3)));
% %         output.SEMVel_T4_rewarded_medium = std(tone_means_medium_reward_plotdata(:, 4)) / sqrt(length(tone_means_medium_reward_plotdata(:, 4)));         
% %         output.SEMVel_T5_rewarded_medium = std(tone_means_medium_reward_plotdata(:, 5)) / sqrt(length(tone_means_medium_reward_plotdata(:, 5)));         
% 
% %         output.SEMVel_T1_rewarded_long = std(tone_means_long_reward_plotdata(:, 1)) / sqrt(length(tone_means_long_reward_plotdata(:, 1)));          
% %         output.SEMVel_T2_rewarded_long = std(tone_means_long_reward_plotdata(:, 2)) / sqrt(length(tone_means_long_reward_plotdata(:, 2)));         
% %         output.SEMVel_T3_rewarded_long = std(tone_means_long_reward_plotdata(:, 3)) / sqrt(length(tone_means_long_reward_plotdata(:, 3)));
% %         output.SEMVel_T4_rewarded_long = std(tone_means_long_reward_plotdata(:, 4)) / sqrt(length(tone_means_long_reward_plotdata(:, 4)));         
% %         output.SEMVel_T5_rewarded_long = std(tone_means_long_reward_plotdata(:, 5)) / sqrt(length(tone_means_long_reward_plotdata(:, 5)));         
% 
% %  if str2num(phase) == 12
%     
% %     % Tone averages by Maitenance Parameter
% 
% %         % Short Rewarded Trials
% 
% %             trials_mat_12_para_120_reward_short = trials_mat_12_para_120 .* trials_reward_short;
% %             trials_mat_12_para_120_reward_short_index = find(trials_mat_12_para_120_reward_short == 1);
% 
% %             trials_mat_12_para_150_reward_short = trials_mat_12_para_150 .* trials_reward_short;
% %             trials_mat_12_para_150_reward_short_index = find(trials_mat_12_para_150_reward_short == 1);
% 
% %             trials_mat_12_para_130_reward_short = trials_mat_12_para_130 .* trials_reward_short;
% %             trials_mat_12_para_130_reward_short_index = find(trials_mat_12_para_130_reward_short == 1);
% 
% %             tone_means_para_120_reward_short_plotdata = tone_means(trials_mat_12_para_120_reward_short_index, :);
% %             tone_means_para_150_reward_short_plotdata = tone_means(trials_mat_12_para_150_reward_short_index, :);
% %             tone_means_para_130_reward_short_plotdata = tone_means(trials_mat_12_para_130_reward_short_index, :);
% 
% %             output.Short_rewards_120 = size(trials_mat_12_para_120_reward_short_index, 1);
% %             output.Short_rewards_150 = size(trials_mat_12_para_150_reward_short_index, 1);
% %             output.Short_rewards_130 = size(trials_mat_12_para_130_reward_short_index, 1);
% 
% 
% 
% %         % Figure
% 
% %             % hold on
% 
% %             % options.color_line = [236 112  22]./255;
% %             % options.color_area = [243 169 114]./255;
% %             % plot_areaerrorbar(tone_means_para_120_reward_short_plotdata, options)
% 
% %             % clear options
% 
% %             % options.color_line = [216 0  115]./255;
% %             % options.color_area = [226 20 135]./255;
% %             % plot_areaerrorbar(tone_means_para_130_reward_short_plotdata, options)
% 
% %             % clear options
% 
% %             % options.color_area = [128 193 219]./255;   
% %             % options.color_line = [ 52 148 186]./255;
% %             % plot_areaerrorbar(tone_means_para_150_reward_short_plotdata, options)
% 
% %             % legend( '', '120', '', '130', '', '150')
% %             % xticks([ 1 2 3 4 5])
% %             % ylim([0 600])
% %             % xlabel('Tone Number')
% %             % ylabel('Average Velocity (cm/s)')
% %             % title('Average Velocity by Tone for short Trials by Maitenance Parameter')
% 
% %             %                % Save Fig file to computer 
% 
% %             %                 [Where] = Where_file(filename);
% %             %                 SaveName = [strcat(Where, 'Tone_Means_short_matPar_', date, '_', num)];
% %             %                 savefig(SaveName);            
%                             
% %             %                 close all
% 
% %         % Save means/SEMs as outputs
% 
% %             output.MeanVel_T1_rewarded_short_120 = mean(tone_means_para_120_reward_short_plotdata(:, 1));          
% %             output.MeanVel_T2_rewarded_short_120 = mean(tone_means_para_120_reward_short_plotdata(:, 2));         
% %             output.MeanVel_T3_rewarded_short_120 = mean(tone_means_para_120_reward_short_plotdata(:, 3));
% %             output.MeanVel_T4_rewarded_short_120 = mean(tone_means_para_120_reward_short_plotdata(:, 4));         
% %             output.MeanVel_T5_rewarded_short_120 = mean(tone_means_para_120_reward_short_plotdata(:, 5));         
% 
% %             output.MeanVel_T1_rewarded_short_150 = mean(tone_means_para_150_reward_short_plotdata(:, 1));          
% %             output.MeanVel_T2_rewarded_short_150 = mean(tone_means_para_150_reward_short_plotdata(:, 2));         
% %             output.MeanVel_T3_rewarded_short_150 = mean(tone_means_para_150_reward_short_plotdata(:, 3));
% %             output.MeanVel_T4_rewarded_short_150 = mean(tone_means_para_150_reward_short_plotdata(:, 4));         
% %             output.MeanVel_T5_rewarded_short_150 = mean(tone_means_para_150_reward_short_plotdata(:, 5));    
% 
% %             output.MeanVel_T1_rewarded_short_130 = mean(tone_means_para_130_reward_short_plotdata(:, 1));          
% %             output.MeanVel_T2_rewarded_short_130 = mean(tone_means_para_130_reward_short_plotdata(:, 2));         
% %             output.MeanVel_T3_rewarded_short_130 = mean(tone_means_para_130_reward_short_plotdata(:, 3));
% %             output.MeanVel_T4_rewarded_short_130 = mean(tone_means_para_130_reward_short_plotdata(:, 4));         
% %             output.MeanVel_T5_rewarded_short_130 = mean(tone_means_para_130_reward_short_plotdata(:, 5)); 
% 
% 
% %             output.SEMVel_T1_rewarded_short_120 = std(tone_means_para_120_reward_short_plotdata(:, 1)) / sqrt(length(tone_means_para_120_reward_short_plotdata(:, 1)));          
% %             output.SEMVel_T2_rewarded_short_120 = std(tone_means_para_120_reward_short_plotdata(:, 2)) / sqrt(length(tone_means_para_120_reward_short_plotdata(:, 2)));         
% %             output.SEMVel_T3_rewarded_short_120 = std(tone_means_para_120_reward_short_plotdata(:, 3)) / sqrt(length(tone_means_para_120_reward_short_plotdata(:, 3)));
% %             output.SEMVel_T4_rewarded_short_120 = std(tone_means_para_120_reward_short_plotdata(:, 4)) / sqrt(length(tone_means_para_120_reward_short_plotdata(:, 4)));         
% %             output.SEMVel_T5_rewarded_short_120 = std(tone_means_para_120_reward_short_plotdata(:, 5)) / sqrt(length(tone_means_para_120_reward_short_plotdata(:, 5)));         
% 
% %             output.SEMVel_T1_rewarded_short_150 = std(tone_means_para_150_reward_short_plotdata(:, 1)) / sqrt(length(tone_means_para_150_reward_short_plotdata(:, 1)));          
% %             output.SEMVel_T2_rewarded_short_150 = std(tone_means_para_150_reward_short_plotdata(:, 2)) / sqrt(length(tone_means_para_150_reward_short_plotdata(:, 2)));         
% %             output.SEMVel_T3_rewarded_short_150 = std(tone_means_para_150_reward_short_plotdata(:, 3)) / sqrt(length(tone_means_para_150_reward_short_plotdata(:, 3)));
% %             output.SEMVel_T4_rewarded_short_150 = std(tone_means_para_150_reward_short_plotdata(:, 4)) / sqrt(length(tone_means_para_150_reward_short_plotdata(:, 4)));         
% %             output.SEMVel_T5_rewarded_short_150 = std(tone_means_para_150_reward_short_plotdata(:, 5)) / sqrt(length(tone_means_para_150_reward_short_plotdata(:, 5)));         
% 
% %             output.SEMVel_T1_rewarded_short_130 = std(tone_means_para_130_reward_short_plotdata(:, 1)) / sqrt(length(tone_means_para_130_reward_short_plotdata(:, 1)));          
% %             output.SEMVel_T2_rewarded_short_130 = std(tone_means_para_130_reward_short_plotdata(:, 2)) / sqrt(length(tone_means_para_130_reward_short_plotdata(:, 2)));         
% %             output.SEMVel_T3_rewarded_short_130 = std(tone_means_para_130_reward_short_plotdata(:, 3)) / sqrt(length(tone_means_para_130_reward_short_plotdata(:, 3)));
% %             output.SEMVel_T4_rewarded_short_130 = std(tone_means_para_130_reward_short_plotdata(:, 4)) / sqrt(length(tone_means_para_130_reward_short_plotdata(:, 4)));         
% %             output.SEMVel_T5_rewarded_short_130 = std(tone_means_para_130_reward_short_plotdata(:, 5)) / sqrt(length(tone_means_para_130_reward_short_plotdata(:, 5)));  
% 
% %         % Medium Rewarded Trials
% 
% %             trials_mat_12_para_120_reward_medium = trials_mat_12_para_120 .* trials_reward_medium;
% %             trials_mat_12_para_120_reward_medium_index = find(trials_mat_12_para_120_reward_medium == 1);
% 
% %             trials_mat_12_para_150_reward_medium = trials_mat_12_para_150 .* trials_reward_medium;
% %             trials_mat_12_para_150_reward_medium_index = find(trials_mat_12_para_150_reward_medium == 1);
% 
% %             trials_mat_12_para_130_reward_medium = trials_mat_12_para_130 .* trials_reward_medium;
% %             trials_mat_12_para_130_reward_medium_index = find(trials_mat_12_para_130_reward_medium == 1);
% 
% %             tone_means_para_120_reward_medium_plotdata = tone_means(trials_mat_12_para_120_reward_medium_index, :);
% %             tone_means_para_150_reward_medium_plotdata = tone_means(trials_mat_12_para_150_reward_medium_index, :);
% %             tone_means_para_130_reward_medium_plotdata = tone_means(trials_mat_12_para_130_reward_medium_index, :);
% 
% %             output.Medium_rewards_120 = size(trials_mat_12_para_120_reward_short_index, 1);
% %             output.Medium_rewards_150 = size(trials_mat_12_para_150_reward_short_index, 1);
% %             output.Medium_rewards_130 = size(trials_mat_12_para_130_reward_short_index, 1);
% 
% %         % Figure
% 
% %             % hold on
% 
% %             % options.color_line = [236 112  22]./255;
% %             % options.color_area = [243 169 114]./255;
% %             % plot_areaerrorbar(tone_means_para_120_reward_medium_plotdata, options)
% 
% %             % clear options
% 
% %             % options.color_line = [216 0  115]./255;
% %             % options.color_area = [226 20 135]./255;
% %             % plot_areaerrorbar(tone_means_para_130_reward_medium_plotdata, options)
% 
% %             % clear options
% 
% %             % options.color_area = [128 193 219]./255;   
% %             % options.color_line = [ 52 148 186]./255;
% %             % plot_areaerrorbar(tone_means_para_150_reward_medium_plotdata, options)
% 
% %             % legend( '', '120', '', '130', '', '150')
% %             % xticks([ 1 2 3 4 5])
% %             % ylim([0 600])
% %             % xlabel('Tone Number')
% %             % ylabel('Average Velocity (cm/s)')
% %             % title('Average Velocity by Tone for medium Trials by Maitenance Parameter')
% 
% %             %                % Save Fig file to computer 
% 
% %             %                 [Where] = Where_file(filename);
% %             %                 SaveName = [strcat(Where, 'Tone_Means_medium_matPar_', date, '_', num)];
% %             %                 savefig(SaveName);            
%                             
% %             %                 close all
% 
% %         % Save means/SEMs as outputs
% 
% %             output.MeanVel_T1_rewarded_medium_120 = mean(tone_means_para_120_reward_medium_plotdata(:, 1));          
% %             output.MeanVel_T2_rewarded_medium_120 = mean(tone_means_para_120_reward_medium_plotdata(:, 2));         
% %             output.MeanVel_T3_rewarded_medium_120 = mean(tone_means_para_120_reward_medium_plotdata(:, 3));
% %             output.MeanVel_T4_rewarded_medium_120 = mean(tone_means_para_120_reward_medium_plotdata(:, 4));         
% %             output.MeanVel_T5_rewarded_medium_120 = mean(tone_means_para_120_reward_medium_plotdata(:, 5));         
% 
% %             output.MeanVel_T1_rewarded_medium_150 = mean(tone_means_para_150_reward_medium_plotdata(:, 1));          
% %             output.MeanVel_T2_rewarded_medium_150 = mean(tone_means_para_150_reward_medium_plotdata(:, 2));         
% %             output.MeanVel_T3_rewarded_medium_150 = mean(tone_means_para_150_reward_medium_plotdata(:, 3));
% %             output.MeanVel_T4_rewarded_medium_150 = mean(tone_means_para_150_reward_medium_plotdata(:, 4));         
% %             output.MeanVel_T5_rewarded_medium_150 = mean(tone_means_para_150_reward_medium_plotdata(:, 5));    
% 
% %             output.MeanVel_T1_rewarded_medium_130 = mean(tone_means_para_130_reward_medium_plotdata(:, 1));          
% %             output.MeanVel_T2_rewarded_medium_130 = mean(tone_means_para_130_reward_medium_plotdata(:, 2));         
% %             output.MeanVel_T3_rewarded_medium_130 = mean(tone_means_para_130_reward_medium_plotdata(:, 3));
% %             output.MeanVel_T4_rewarded_medium_130 = mean(tone_means_para_130_reward_medium_plotdata(:, 4));         
% %             output.MeanVel_T5_rewarded_medium_130 = mean(tone_means_para_130_reward_medium_plotdata(:, 5)); 
% 
% 
% %             output.SEMVel_T1_rewarded_medium_120 = std(tone_means_para_120_reward_medium_plotdata(:, 1)) / sqrt(length(tone_means_para_120_reward_medium_plotdata(:, 1)));          
% %             output.SEMVel_T2_rewarded_medium_120 = std(tone_means_para_120_reward_medium_plotdata(:, 2)) / sqrt(length(tone_means_para_120_reward_medium_plotdata(:, 2)));         
% %             output.SEMVel_T3_rewarded_medium_120 = std(tone_means_para_120_reward_medium_plotdata(:, 3)) / sqrt(length(tone_means_para_120_reward_medium_plotdata(:, 3)));
% %             output.SEMVel_T4_rewarded_medium_120 = std(tone_means_para_120_reward_medium_plotdata(:, 4)) / sqrt(length(tone_means_para_120_reward_medium_plotdata(:, 4)));         
% %             output.SEMVel_T5_rewarded_medium_120 = std(tone_means_para_120_reward_medium_plotdata(:, 5)) / sqrt(length(tone_means_para_120_reward_medium_plotdata(:, 5)));         
% 
% %             output.SEMVel_T1_rewarded_medium_150 = std(tone_means_para_150_reward_medium_plotdata(:, 1)) / sqrt(length(tone_means_para_150_reward_medium_plotdata(:, 1)));          
% %             output.SEMVel_T2_rewarded_medium_150 = std(tone_means_para_150_reward_medium_plotdata(:, 2)) / sqrt(length(tone_means_para_150_reward_medium_plotdata(:, 2)));         
% %             output.SEMVel_T3_rewarded_medium_150 = std(tone_means_para_150_reward_medium_plotdata(:, 3)) / sqrt(length(tone_means_para_150_reward_medium_plotdata(:, 3)));
% %             output.SEMVel_T4_rewarded_medium_150 = std(tone_means_para_150_reward_medium_plotdata(:, 4)) / sqrt(length(tone_means_para_150_reward_medium_plotdata(:, 4)));         
% %             output.SEMVel_T5_rewarded_medium_150 = std(tone_means_para_150_reward_medium_plotdata(:, 5)) / sqrt(length(tone_means_para_150_reward_medium_plotdata(:, 5)));         
% 
% %             output.SEMVel_T1_rewarded_medium_130 = std(tone_means_para_130_reward_medium_plotdata(:, 1)) / sqrt(length(tone_means_para_130_reward_medium_plotdata(:, 1)));          
% %             output.SEMVel_T2_rewarded_medium_130 = std(tone_means_para_130_reward_medium_plotdata(:, 2)) / sqrt(length(tone_means_para_130_reward_medium_plotdata(:, 2)));         
% %             output.SEMVel_T3_rewarded_medium_130 = std(tone_means_para_130_reward_medium_plotdata(:, 3)) / sqrt(length(tone_means_para_130_reward_medium_plotdata(:, 3)));
% %             output.SEMVel_T4_rewarded_medium_130 = std(tone_means_para_130_reward_medium_plotdata(:, 4)) / sqrt(length(tone_means_para_130_reward_medium_plotdata(:, 4)));         
% %             output.SEMVel_T5_rewarded_medium_130 = std(tone_means_para_130_reward_medium_plotdata(:, 5)) / sqrt(length(tone_means_para_130_reward_medium_plotdata(:, 5)));         
% 
% %         % Long Rewarded Trials
% 
% %             trials_mat_12_para_120_reward_long = trials_mat_12_para_120 .* trials_reward_long;
% %             trials_mat_12_para_120_reward_long_index = find(trials_mat_12_para_120_reward_long == 1);
% 
% %             trials_mat_12_para_150_reward_long = trials_mat_12_para_150 .* trials_reward_long;
% %             trials_mat_12_para_150_reward_long_index = find(trials_mat_12_para_150_reward_long == 1);
% 
% %             trials_mat_12_para_130_reward_long = trials_mat_12_para_130 .* trials_reward_long;
% %             trials_mat_12_para_130_reward_long_index = find(trials_mat_12_para_130_reward_long == 1);
% 
% %             tone_means_para_120_reward_long_plotdata = tone_means(trials_mat_12_para_120_reward_long_index, :);
% %             tone_means_para_150_reward_long_plotdata = tone_means(trials_mat_12_para_150_reward_long_index, :);
% %             tone_means_para_130_reward_long_plotdata = tone_means(trials_mat_12_para_130_reward_long_index, :);
% 
% %             output.Long_rewards_120 = size(trials_mat_12_para_120_reward_short_index, 1);
% %             output.Long_rewards_150 = size(trials_mat_12_para_150_reward_short_index, 1);
% %             output.Long_rewards_130 = size(trials_mat_12_para_130_reward_short_index, 1);
% 
% %         % % Figure
% 
% %             % hold on
% 
% %             % options.color_line = [236 112  22]./255;
% %             % options.color_area = [243 169 114]./255;
% %             % plot_areaerrorbar(tone_means_para_120_reward_long_plotdata, options)
% 
% %             % clear options
% 
% %             % options.color_line = [216 0  115]./255;
% %             % options.color_area = [226 20 135]./255;
% %             % plot_areaerrorbar(tone_means_para_130_reward_long_plotdata, options)
% 
% %             % clear options
% 
% %             % options.color_area = [128 193 219]./255;   
% %             % options.color_line = [ 52 148 186]./255;
% %             % plot_areaerrorbar(tone_means_para_150_reward_long_plotdata, options)
% 
% %             % legend( '', '120', '', '130', '', '150')
% %             % xticks([ 1 2 3 4 5])
% %             % ylim([0 600])
% %             % xlabel('Tone Number')
% %             % ylabel('Average Velocity (cm/s)')
% %             % title('Average Velocity by Tone for Long Trials by Maitenance Parameter')
% 
% %             %                % Save Fig file to computer 
% 
% %             %                 [Where] = Where_file(filename);
% %             %                 SaveName = [strcat(Where, 'Tone_Means_long_matPar_', date, '_', num)];
% %             %                 savefig(SaveName);            
%                             
% %             %                 close all
% 
% %         % Save means/SEMs as outputs
% 
% %             output.MeanVel_T1_rewarded_long_120 = mean(tone_means_para_120_reward_long_plotdata(:, 1));          
% %             output.MeanVel_T2_rewarded_long_120 = mean(tone_means_para_120_reward_long_plotdata(:, 2));         
% %             output.MeanVel_T3_rewarded_long_120 = mean(tone_means_para_120_reward_long_plotdata(:, 3));
% %             output.MeanVel_T4_rewarded_long_120 = mean(tone_means_para_120_reward_long_plotdata(:, 4));         
% %             output.MeanVel_T5_rewarded_long_120 = mean(tone_means_para_120_reward_long_plotdata(:, 5));         
% 
% %             output.MeanVel_T1_rewarded_long_150 = mean(tone_means_para_150_reward_long_plotdata(:, 1));          
% %             output.MeanVel_T2_rewarded_long_150 = mean(tone_means_para_150_reward_long_plotdata(:, 2));         
% %             output.MeanVel_T3_rewarded_long_150 = mean(tone_means_para_150_reward_long_plotdata(:, 3));
% %             output.MeanVel_T4_rewarded_long_150 = mean(tone_means_para_150_reward_long_plotdata(:, 4));         
% %             output.MeanVel_T5_rewarded_long_150 = mean(tone_means_para_150_reward_long_plotdata(:, 5));    
% 
% %             output.MeanVel_T1_rewarded_long_130 = mean(tone_means_para_130_reward_long_plotdata(:, 1));          
% %             output.MeanVel_T2_rewarded_long_130 = mean(tone_means_para_130_reward_long_plotdata(:, 2));         
% %             output.MeanVel_T3_rewarded_long_130 = mean(tone_means_para_130_reward_long_plotdata(:, 3));
% %             output.MeanVel_T4_rewarded_long_130 = mean(tone_means_para_130_reward_long_plotdata(:, 4));         
% %             output.MeanVel_T5_rewarded_long_130 = mean(tone_means_para_130_reward_long_plotdata(:, 5)); 
% 
% 
% %             output.SEMVel_T1_rewarded_long_120 = std(tone_means_para_120_reward_long_plotdata(:, 1)) / sqrt(length(tone_means_para_120_reward_long_plotdata(:, 1)));          
% %             output.SEMVel_T2_rewarded_long_120 = std(tone_means_para_120_reward_long_plotdata(:, 2)) / sqrt(length(tone_means_para_120_reward_long_plotdata(:, 2)));         
% %             output.SEMVel_T3_rewarded_long_120 = std(tone_means_para_120_reward_long_plotdata(:, 3)) / sqrt(length(tone_means_para_120_reward_long_plotdata(:, 3)));
% %             output.SEMVel_T4_rewarded_long_120 = std(tone_means_para_120_reward_long_plotdata(:, 4)) / sqrt(length(tone_means_para_120_reward_long_plotdata(:, 4)));         
% %             output.SEMVel_T5_rewarded_long_120 = std(tone_means_para_120_reward_long_plotdata(:, 5)) / sqrt(length(tone_means_para_120_reward_long_plotdata(:, 5)));         
% 
% %             output.SEMVel_T1_rewarded_long_150 = std(tone_means_para_150_reward_long_plotdata(:, 1)) / sqrt(length(tone_means_para_150_reward_long_plotdata(:, 1)));          
% %             output.SEMVel_T2_rewarded_long_150 = std(tone_means_para_150_reward_long_plotdata(:, 2)) / sqrt(length(tone_means_para_150_reward_long_plotdata(:, 2)));         
% %             output.SEMVel_T3_rewarded_long_150 = std(tone_means_para_150_reward_long_plotdata(:, 3)) / sqrt(length(tone_means_para_150_reward_long_plotdata(:, 3)));
% %             output.SEMVel_T4_rewarded_long_150 = std(tone_means_para_150_reward_long_plotdata(:, 4)) / sqrt(length(tone_means_para_150_reward_long_plotdata(:, 4)));         
% %             output.SEMVel_T5_rewarded_long_150 = std(tone_means_para_150_reward_long_plotdata(:, 5)) / sqrt(length(tone_means_para_150_reward_long_plotdata(:, 5)));         
% 
% %             output.SEMVel_T1_rewarded_long_130 = std(tone_means_para_130_reward_long_plotdata(:, 1)) / sqrt(length(tone_means_para_130_reward_long_plotdata(:, 1)));          
% %             output.SEMVel_T2_rewarded_long_130 = std(tone_means_para_130_reward_long_plotdata(:, 2)) / sqrt(length(tone_means_para_130_reward_long_plotdata(:, 2)));         
% %             output.SEMVel_T3_rewarded_long_130 = std(tone_means_para_130_reward_long_plotdata(:, 3)) / sqrt(length(tone_means_para_130_reward_long_plotdata(:, 3)));
% %             output.SEMVel_T4_rewarded_long_130 = std(tone_means_para_130_reward_long_plotdata(:, 4)) / sqrt(length(tone_means_para_130_reward_long_plotdata(:, 4)));         
% %             output.SEMVel_T5_rewarded_long_130 = std(tone_means_para_130_reward_long_plotdata(:, 5)) / sqrt(length(tone_means_para_130_reward_long_plotdata(:, 5)));         
% 
% %     % Learning curve data
% 
% %         % Error rate across session
% 
% %             bin_size = 5;
% 
% %             number_bins = floor(length(trials_running_index) / bin_size);
% %             binning_mat(1, :) = [1:number_bins]';
% 
% 
% %             trials_120_premature_slowdown_index = find(trials_mat_12_para_120_premature_slowdown == 1);
% %             trials_150_premature_slowdown_index = find(trials_mat_12_para_150_premature_slowdown == 1);
% %             trials_130_premature_slowdown_index = find(trials_mat_12_para_130_premature_slowdown == 1);
% 
% %                 for i = 1:number_bins
% %                     binning_ind{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
% %                     binning_ind{i, 2} = trials_running_index(binning_ind{i, 1}, 1);
% %                     binning_mat(2, i) = (sum(ismember(binning_ind{i, 2}, trials_120_premature_slowdown_index)) / bin_size);
% %                     binning_mat(3, i) = (sum(ismember(binning_ind{i, 2}, trials_150_premature_slowdown_index)) / bin_size);
% %                     binning_mat(4, i) = (sum(ismember(binning_ind{i, 2}, trials_130_premature_slowdown_index)) / bin_size);
%                 
% %                 end
% 
% %             output.learning_curve_error_data = binning_mat;
% 
% %         % Error rate across session (stops)
% %             trials_mat_12_para_120_incomplete_running_late = trials_mat_12_para_120 .* trials_incomplete_running_late;
% %             trials_mat_12_para_150_incomplete_running_late = trials_mat_12_para_150 .* trials_incomplete_running_late;
% %             trials_mat_12_para_130_incomplete_running_late = trials_mat_12_para_130 .* trials_incomplete_running_late;
% 
% %             trials_short_incomplete_running_late = trials_running_index_short .* trials_incomplete_running_late;
% %             trials_medium_incomplete_running_late = trials_running_index_medium .* trials_incomplete_running_late;
% %             trials_long_incomplete_running_late = trials_running_index_long .* trials_incomplete_running_late;
% 
% %             trials_short_incomplete_running_late_index = find(trials_short_incomplete_running_late == 1);
% %             trials_medium_incomplete_running_late_index = find(trials_medium_incomplete_running_late == 1);
% %             trials_long_incomplete_running_late_index = find(trials_long_incomplete_running_late == 1);
%            
% %             trials_incomplete_running_late_index = find(trials_incomplete_running_late == 1);
% 
% %             trials_mat_12_para_120_incomplete_running_late_index = find(trials_mat_12_para_120_incomplete_running_late == 1);
% %             trials_mat_12_para_150_incomplete_running_late_index = find(trials_mat_12_para_150_incomplete_running_late == 1);
% %             trials_mat_12_para_130_incomplete_running_late_index = find(trials_mat_12_para_130_incomplete_running_late == 1);
% 
% %             binning_mat_stop(1, :) = [1:number_bins]';
% 
% %                 % for i = 1:number_bins
% %                 %     binning_ind_stop{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
% %                 %     binning_ind_stop{i, 2} = trials_running_index(binning_ind_stop{i, 1}, 1);
% %                 %     binning_mat_stop(2, i) = (sum(ismember(binning_ind_stop{i, 2}, trials_mat_12_para_120_incomplete_running_late_index)) / bin_size);
% %                 %     binning_mat_stop(3, i) = (sum(ismember(binning_ind_stop{i, 2}, trials_mat_12_para_150_incomplete_running_late_index)) / bin_size);
% %                 %     binning_mat_stop(4, i) = (sum(ismember(binning_ind_stop{i, 2}, trials_mat_12_para_130_incomplete_running_late_index)) / bin_size);
%                 
% %                 % end
% 
% %                 for i = 1:number_bins
% %                     binning_ind_stop{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
% %                     binning_ind_stop{i, 2} = trials_running_index(binning_ind_stop{i, 1}, 1);
% %                     binning_mat_stop(2, i) = (sum(ismember(binning_ind_stop{i, 2}, trials_short_incomplete_running_late_index)) / bin_size);
% %                     binning_mat_stop(3, i) = (sum(ismember(binning_ind_stop{i, 2}, trials_medium_incomplete_running_late_index)) / bin_size);
% %                     binning_mat_stop(4, i) = (sum(ismember(binning_ind_stop{i, 2}, trials_long_incomplete_running_late_index)) / bin_size);
%                 
% %                 end
% 
% %                 % for i = 1:number_bins
% %                 %     binning_ind_stop{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
% %                 %     binning_ind_stop{i, 2} = trials_running_index(binning_ind_stop{i, 1}, 1);
% %                 %     binning_mat_stop(2, i) = (sum(ismember(binning_ind_stop{i, 2}, trials_incomplete_running_late_index)) / bin_size);
% 
% %                 % end
% 
% %             output.learning_curve_error_data_late_stops = binning_mat_stop;
% 
% 
% %     else
% 
% %             output.Short_rewards_120 = NaN;
% %             output.Short_rewards_150 = NaN;
% %             output.Short_rewards_130 = NaN;
% 
% %         % Save means/SEMs as outputs
% 
% %             output.MeanVel_T1_rewarded_short_120 = NaN;          
% %             output.MeanVel_T2_rewarded_short_120 = NaN;         
% %             output.MeanVel_T3_rewarded_short_120 = NaN;
% %             output.MeanVel_T4_rewarded_short_120 = NaN;         
% %             output.MeanVel_T5_rewarded_short_120 = NaN;         
% 
% %             output.MeanVel_T1_rewarded_short_150 = NaN;          
% %             output.MeanVel_T2_rewarded_short_150 = NaN;         
% %             output.MeanVel_T3_rewarded_short_150 = NaN;
% %             output.MeanVel_T4_rewarded_short_150 = NaN;         
% %             output.MeanVel_T5_rewarded_short_150 = NaN;    
% 
% %             output.MeanVel_T1_rewarded_short_130 = NaN;          
% %             output.MeanVel_T2_rewarded_short_130 = NaN;         
% %             output.MeanVel_T3_rewarded_short_130 = NaN;
% %             output.MeanVel_T4_rewarded_short_130 = NaN;         
% %             output.MeanVel_T5_rewarded_short_130 = NaN; 
% 
% %             output.SEMVel_T1_rewarded_short_120 = NaN;          
% %             output.SEMVel_T2_rewarded_short_120 = NaN;         
% %             output.SEMVel_T3_rewarded_short_120 = NaN;
% %             output.SEMVel_T4_rewarded_short_120 = NaN;         
% %             output.SEMVel_T5_rewarded_short_120 = NaN;         
% 
% %             output.SEMVel_T1_rewarded_short_150 = NaN;          
% %             output.SEMVel_T2_rewarded_short_150 = NaN;         
% %             output.SEMVel_T3_rewarded_short_150 = NaN;
% %             output.SEMVel_T4_rewarded_short_150 = NaN;         
% %             output.SEMVel_T5_rewarded_short_150 = NaN;         
% 
% %             output.SEMVel_T1_rewarded_short_130 = NaN;          
% %             output.SEMVel_T2_rewarded_short_130 = NaN;         
% %             output.SEMVel_T3_rewarded_short_130 = NaN;
% %             output.SEMVel_T4_rewarded_short_130 = NaN;         
% %             output.SEMVel_T5_rewarded_short_130 = NaN;  
% 
% %             output.Medium_rewards_120 = NaN;
% %             output.Medium_rewards_150 = NaN;
% %             output.Medium_rewards_130 = NaN;
% 
% %         % Save means/SEMs as outputs
% 
% %             output.MeanVel_T1_rewarded_medium_120 = NaN;          
% %             output.MeanVel_T2_rewarded_medium_120 = NaN;         
% %             output.MeanVel_T3_rewarded_medium_120 = NaN;
% %             output.MeanVel_T4_rewarded_medium_120 = NaN;         
% %             output.MeanVel_T5_rewarded_medium_120 = NaN;         
% 
% %             output.MeanVel_T1_rewarded_medium_150 = NaN;          
% %             output.MeanVel_T2_rewarded_medium_150 = NaN;         
% %             output.MeanVel_T3_rewarded_medium_150 = NaN;
% %             output.MeanVel_T4_rewarded_medium_150 = NaN;         
% %             output.MeanVel_T5_rewarded_medium_150 = NaN;    
% 
% %             output.MeanVel_T1_rewarded_medium_130 = NaN;          
% %             output.MeanVel_T2_rewarded_medium_130 = NaN;         
% %             output.MeanVel_T3_rewarded_medium_130 = NaN;
% %             output.MeanVel_T4_rewarded_medium_130 = NaN;         
% %             output.MeanVel_T5_rewarded_medium_130 = NaN; 
% 
% %             output.SEMVel_T1_rewarded_medium_120 = NaN;          
% %             output.SEMVel_T2_rewarded_medium_120 = NaN;         
% %             output.SEMVel_T3_rewarded_medium_120 = NaN;
% %             output.SEMVel_T4_rewarded_medium_120 = NaN;         
% %             output.SEMVel_T5_rewarded_medium_120 = NaN;         
% 
% %             output.SEMVel_T1_rewarded_medium_150 = NaN;          
% %             output.SEMVel_T2_rewarded_medium_150 = NaN;         
% %             output.SEMVel_T3_rewarded_medium_150 = NaN;
% %             output.SEMVel_T4_rewarded_medium_150 = NaN;         
% %             output.SEMVel_T5_rewarded_medium_150 = NaN;         
% 
% %             output.SEMVel_T1_rewarded_medium_130 = NaN;          
% %             output.SEMVel_T2_rewarded_medium_130 = NaN;         
% %             output.SEMVel_T3_rewarded_medium_130 = NaN;
% %             output.SEMVel_T4_rewarded_medium_130 = NaN;         
% %             output.SEMVel_T5_rewarded_medium_130 = NaN;         
% 
% %             output.Long_rewards_120 = NaN;
% %             output.Long_rewards_150 = NaN;
% %             output.Long_rewards_130 = NaN;
% 
% %         % Save means/SEMs as outputs
% 
% %             output.MeanVel_T1_rewarded_long_120 = NaN;          
% %             output.MeanVel_T2_rewarded_long_120 = NaN;         
% %             output.MeanVel_T3_rewarded_long_120 = NaN;
% %             output.MeanVel_T4_rewarded_long_120 = NaN;         
% %             output.MeanVel_T5_rewarded_long_120 = NaN;         
% 
% %             output.MeanVel_T1_rewarded_long_150 = NaN;          
% %             output.MeanVel_T2_rewarded_long_150 = NaN;         
% %             output.MeanVel_T3_rewarded_long_150 = NaN;
% %             output.MeanVel_T4_rewarded_long_150 = NaN;         
% %             output.MeanVel_T5_rewarded_long_150 = NaN;    
% 
% %             output.MeanVel_T1_rewarded_long_130 = NaN;          
% %             output.MeanVel_T2_rewarded_long_130 = NaN;         
% %             output.MeanVel_T3_rewarded_long_130 = NaN;
% %             output.MeanVel_T4_rewarded_long_130 = NaN;         
% %             output.MeanVel_T5_rewarded_long_130 = NaN; 
% 
% %             output.SEMVel_T1_rewarded_long_120 = NaN;          
% %             output.SEMVel_T2_rewarded_long_120 = NaN;         
% %             output.SEMVel_T3_rewarded_long_120 = NaN;
% %             output.SEMVel_T4_rewarded_long_120 = NaN;         
% %             output.SEMVel_T5_rewarded_long_120 = NaN;         
% 
% %             output.SEMVel_T1_rewarded_long_150 = NaN;          
% %             output.SEMVel_T2_rewarded_long_150 = NaN;         
% %             output.SEMVel_T3_rewarded_long_150 = NaN;
% %             output.SEMVel_T4_rewarded_long_150 = NaN;         
% %             output.SEMVel_T5_rewarded_long_150 = NaN;         
% 
% %             output.SEMVel_T1_rewarded_long_130 = NaN;          
% %             output.SEMVel_T2_rewarded_long_130 = NaN;         
% %             output.SEMVel_T3_rewarded_long_130 = NaN;
% %             output.SEMVel_T4_rewarded_long_130 = NaN;         
% %             output.SEMVel_T5_rewarded_long_130 = NaN;         
% 
% %         output.learning_curve_error_data = NaN;
% %         output.learning_curve_error_data_late_stops = NaN;
%     
% %  end
%  
% %  % Peak velocities
% % output.mean_peak_vel_distance_short_distnorm = mean(max_vel_distnorm(trials_reward_short_index, 3));
% % output.mean_peak_vel_distance_medium_distnorm = mean(max_vel_distnorm(trials_reward_medium_index, 3));
% % output.mean_peak_vel_distance_long_distnorm = mean(max_vel_distnorm(trials_reward_long_index, 3));
% 
% % output.sem_peak_vel_distance_short_distnorm = std(max_vel_distnorm(trials_reward_short_index, 3)) / sqrt(length(max_vel_distnorm(trials_reward_short_index, 3)));
% % output.sem_peak_vel_distance_medium_distnorm = std(max_vel_distnorm(trials_reward_medium_index, 3)) / sqrt(length(max_vel_distnorm(trials_reward_medium_index, 3)));
% % output.sem_peak_vel_distance_long_distnorm = std(max_vel_distnorm(trials_reward_long_index, 3)) / sqrt(length(max_vel_distnorm(trials_reward_long_index, 3)));
%  
% 
% % output.mean_peak_vel_short_distnorm = mean(max_vel_distnorm(trials_reward_short_index, 1)) / 10; 
% % output.mean_peak_vel_medium_distnorm = mean(max_vel_distnorm(trials_reward_medium_index, 1))/ 10;
% % output.mean_peak_vel_long_distnorm = mean(max_vel_distnorm(trials_reward_long_index, 1)) / 10;
% 
% % output.sem_peak_vel_short_distnorm = (std(max_vel_distnorm(trials_reward_short_index, 1)) / 10) / sqrt(length(max_vel_distnorm(trials_reward_short_index, 1)));
% % output.sem_peak_vel_medium_distnorm = (std(max_vel_distnorm(trials_reward_medium_index, 1)) / 10) / sqrt(length(max_vel_distnorm(trials_reward_medium_index, 1)));
% % output.sem_peak_vel_long_distnorm = (std(max_vel_distnorm(trials_reward_long_index, 1)) / 10) / sqrt(length(max_vel_distnorm(trials_reward_long_index, 1)));
%   
% 
%  
% % % output.mean_peak_vel_distance_short_timenorm = mean(max_vel_timenorm(trials_reward_short_index, 3));
% % % output.mean_peak_vel_distance_medium_timenorm = mean(max_vel_timenorm(trials_reward_medium_index, 3));
% % % output.mean_peak_vel_distance_long_timenorm = mean(max_vel_timenorm(trials_reward_long_index, 3));
% 
% % % output.sem_peak_vel_distance_short_timenorm = std(max_vel_timenorm(trials_reward_short_index, 3)) / sqrt(length(max_vel_timenorm(trials_reward_short_index, 3)));
% % % output.sem_peak_vel_distance_medium_timenorm = std(max_vel_timenorm(trials_reward_medium_index, 3)) / sqrt(length(max_vel_timenorm(trials_reward_medium_index, 3)));
% % % output.sem_peak_vel_distance_long_timenorm = std(max_vel_timenorm(trials_reward_long_index, 3)) / sqrt(length(max_vel_timenorm(trials_reward_long_index, 3)));
%  
% 
% % % output.mean_peak_vel_short_timenorm = mean(max_vel_timenorm(trials_reward_short_index, 1)) / 10; 
% % % output.mean_peak_vel_medium_timenorm = mean(max_vel_timenorm(trials_reward_medium_index, 1))/ 10;
% % % output.mean_peak_vel_long_timenorm = mean(max_vel_timenorm(trials_reward_long_index, 1)) / 10;
% 
% % % output.sem_peak_vel_short_timenorm = (std(max_vel_timenorm(trials_reward_short_index, 1)) / 10) / sqrt(length(max_vel_timenorm(trials_reward_short_index, 1)));
% % % output.sem_peak_vel_medium_timenorm = (std(max_vel_timenorm(trials_reward_medium_index, 1)) / 10) / sqrt(length(max_vel_timenorm(trials_reward_medium_index, 1)));
% % % output.sem_peak_vel_long_timenorm = (std(max_vel_timenorm(trials_reward_long_index, 1)) / 10) / sqrt(length(max_vel_timenorm(trials_reward_long_index, 1)));
% 
% 
% % %     hold on
% % %     histogram(max_vel_distnorm(trials_reward_short_index, 3), [0:5:100], 'Normalization', 'probability')
% % %     histogram(max_vel_distnorm(trials_reward_medium_index, 3), [0:5:100], 'Normalization', 'probability')
% % %     histogram(max_vel_distnorm(trials_reward_long_index, 3), [0:5:100], 'Normalization', 'probability')
% % %     legend('short', 'medium', 'long')
% % %     xlabel('Peak Velocity Distance (cm from start)')
% % %     ylabel('Relative Probability')
% % % 
% % %        % Save Fig file to computer 
% % % 
% % %         [Where] = Where_file(filename);
% % %         SaveName = [strcat(Where, 'PeakVel_Distances_Hist_', date, '_', num)];
% % %         savefig(SaveName);            
% % %         
% % %         close all
% 
% % [BF, BC] = bimodalitycoeff(max_vel_distnorm(trials_reward_short_index, 3));
% % output.bimodalitycoeff_short = [BF, BC];
% 
% % [BF, BC] = bimodalitycoeff(max_vel_distnorm(trials_reward_medium_index, 3));
% % output.bimodalitycoeff_medium = [BF, BC];
% 
% % [BF, BC] = bimodalitycoeff(max_vel_distnorm(trials_reward_long_index, 3));
% % output.bimodalitycoeff_long = [BF, BC];
% 
% 
% 
% % if str2num(phase) == 12
% % % Full traces by mait para
% 
% %     % Short
% %         tone_means_para_120_reward_short_plotdata_full = movement_velocities_smooth_mean_dist(trials_mat_12_para_120_reward_short_index, :);
% %         tone_means_para_150_reward_short_plotdata_full = movement_velocities_smooth_mean_dist(trials_mat_12_para_150_reward_short_index, :);
% %         tone_means_para_130_reward_short_plotdata_full = movement_velocities_smooth_mean_dist(trials_mat_12_para_130_reward_short_index, :);
% 
% %             % Figure
% 
% %                 hold on
% 
% %                 options.color_line = [236 112  22]./255;
% %                 options.color_area = [243 169 114]./255;
% %                 plot_areaerrorbar(tone_means_para_120_reward_short_plotdata_full, options)
% 
% %                 clear options
% 
% %                 options.color_line = [216 0  115]./255;
% %                 options.color_area = [226 20 135]./255;
% %                 plot_areaerrorbar(tone_means_para_150_reward_short_plotdata_full, options)
% 
% %                 clear options
% 
% %                 options.color_area = [128 193 219]./255;   
% %                 options.color_line = [ 52 148 186]./255;
% %                 plot_areaerrorbar(tone_means_para_130_reward_short_plotdata_full, options)
% 
% %                 legend( '', '120', '', '130', '', '150')
% %                 %xticks([ 1 2 3 4 5])
% %                 ylim([0 600])
% %                 xlabel('Tone Number')
% %                 ylabel('Average Velocity (cm/s)')
% %                 title('Average Velocity Trace by Tone for short Trials by Maitenance Parameter')
% 
% %                                % Save Fig file to computer 
% 
% %                                 [Where] = Where_file(filename);
% %                                 SaveName = [strcat(Where, 'Tone_Means_short_matPar_fulltrace_', date, '_', num)];
% %                                 savefig(SaveName);            
%                                 
% %                                 close all
% 
% 
% %     % medium
% %         tone_means_para_120_reward_medium_plotdata_full = movement_velocities_smooth_mean_dist(trials_mat_12_para_120_reward_medium_index, :);
% %         tone_means_para_150_reward_medium_plotdata_full = movement_velocities_smooth_mean_dist(trials_mat_12_para_150_reward_medium_index, :);
% %         tone_means_para_130_reward_medium_plotdata_full = movement_velocities_smooth_mean_dist(trials_mat_12_para_130_reward_medium_index, :);
% 
% %             % Figure
% 
% %                 hold on
% 
% %                 options.color_line = [236 112  22]./255;
% %                 options.color_area = [243 169 114]./255;
% %                 plot_areaerrorbar(tone_means_para_120_reward_medium_plotdata_full, options)
% 
% %                 clear options
% 
% %                 options.color_line = [216 0  115]./255;
% %                 options.color_area = [226 20 135]./255;
% %                 plot_areaerrorbar(tone_means_para_150_reward_medium_plotdata_full, options)
% 
% %                 clear options
% 
% %                 options.color_area = [128 193 219]./255;   
% %                 options.color_line = [ 52 148 186]./255;
% %                 plot_areaerrorbar(tone_means_para_130_reward_medium_plotdata_full, options)
% 
% %                 legend( '', '120', '', '130', '', '150')
% %                 %xticks([ 1 2 3 4 5])
% %                 ylim([0 600])
% %                 xlabel('Tone Number')
% %                 ylabel('Average Velocity (cm/s)')
% %                 title('Average Velocity Trace by Tone for medium Trials by Maitenance Parameter')
% 
% %                                % Save Fig file to computer 
% 
% %                                 [Where] = Where_file(filename);
% %                                 SaveName = [strcat(Where, 'Tone_Means_medium_matPar_fulltrace_', date, '_', num)];
% %                                 savefig(SaveName);            
%                                 
% %                                 close all
% 
% 
% 
% %     % long
% %         tone_means_para_120_reward_long_plotdata_full = movement_velocities_smooth_mean_dist(trials_mat_12_para_120_reward_long_index, :);
% %         tone_means_para_150_reward_long_plotdata_full = movement_velocities_smooth_mean_dist(trials_mat_12_para_150_reward_long_index, :);
% %         tone_means_para_130_reward_long_plotdata_full = movement_velocities_smooth_mean_dist(trials_mat_12_para_130_reward_long_index, :);
% 
% %             % Figure
% 
% %                 hold on
% 
% %                 options.color_line = [236 112  22]./255;
% %                 options.color_area = [243 169 114]./255;
% %                 plot_areaerrorbar(tone_means_para_120_reward_long_plotdata_full, options)
% 
% %                 clear options
% 
% %                 options.color_line = [216 0  115]./255;
% %                 options.color_area = [226 20 135]./255;
% %                 plot_areaerrorbar(tone_means_para_150_reward_long_plotdata_full, options)
% 
% %                 clear options
% 
% %                 options.color_area = [128 193 219]./255;   
% %                 options.color_line = [ 52 148 186]./255;
% %                 plot_areaerrorbar(tone_means_para_130_reward_long_plotdata_full, options)
% 
% %                 legend( '', '120', '', '130', '', '150')
% %                 %xticks([ 1 2 3 4 5])
% %                 ylim([0 600])
% %                 xlabel('Tone Number')
% %                 ylabel('Average Velocity (cm/s)')
% %                 title('Average Velocity Trace by Tone for long Trials by Maitenance Parameter')
% 
% %                                % Save Fig file to computer 
% 
% %                                 [Where] = Where_file(filename);
% %                                 SaveName = [strcat(Where, 'Tone_Means_long_matPar_fulltrace_', date, '_', num)];
% %                                 savefig(SaveName);            
%                                 
% %                                 close all
% 
% % end
% % % Reward velocity
%         
% %   % output.mean_rw_vel_smooth_dist = mean(movement_velocities_smooth_mean_dist(complete_trials_index, end));
% %   % output.sem_rw_vel_smooth_dist = std(movement_velocities_smooth_mean_dist(complete_trials_index, end)) / sqrt(length(movement_velocities_smooth_mean_dist(complete_trials_index, end)));
% 
% %   % output.mean_rw_stop_vel_smooth_dist = mean(movement_velocities_smooth_mean_dist(complete_trials_stop_index, end));
% %   % output.sem_rw_stop_vel_smooth_dist = std(movement_velocities_smooth_mean_dist(complete_trials_stop_index, end)) / sqrt(length(movement_velocities_smooth_mean_dist(complete_trials_index, end)));
% 
% %   % output.mean_rw_slow_vel_smooth_dist = mean(movement_velocities_smooth_mean_dist(complete_trials_slow_index, end));
% %   %   output.sem_rw_slow_vel_smooth_dist = std(movement_velocities_smooth_mean_dist(complete_trials_slow_index, end)) / sqrt(length(movement_velocities_smooth_mean_dist(complete_trials_index, end)));
%            
% %   output.mean_rw_vel = mean(reward_velocity(complete_trials_index, 1));
% %   output.sem_rw_vel = std(reward_velocity(complete_trials_index, 1)) / sqrt(length(reward_velocity(complete_trials_index, 1)));
% 
% %   output.mean_rw_stop_vel = mean(reward_velocity(complete_trials_stop_index, 1));
% %   output.sem_rw_stop_vel = std(reward_velocity(complete_trials_stop_index, 1)) / sqrt(length(reward_velocity(complete_trials_stop_index, 1)));
% 
% %   output.mean_rw_slow_vel = mean(reward_velocity(complete_trials_slow_index, 1));
% %   output.sem_rw_slow_vel = std(reward_velocity(complete_trials_slow_index, 1)) / sqrt(length(reward_velocity(complete_trials_slow_index, 1)));
% 
% 
% 
  trials_reward_stop_short = trials_reward_short .* trials_reward_stop;
  trials_reward_slow_short = trials_reward_short .* trials_reward_slow;
  trials_reward_stop_short_index = find(trials_reward_stop_short == 1);
  trials_reward_slow_short_index = find(trials_reward_slow_short == 1);
% 
% %   output.mean_rw_vel_short = mean(reward_velocity(trials_reward_short_index, 1));
% %   output.sem_rw_vel_short = std(reward_velocity(trials_reward_short_index, 1)) / sqrt(length(reward_velocity(trials_reward_short_index, 1)));
% 
% %   output.mean_rw_stop_vel_short = mean(reward_velocity(trials_reward_stop_short_index, 1));
% %   output.sem_rw_stop_vel_short = std(reward_velocity(trials_reward_stop_short_index, 1)) / sqrt(length(reward_velocity(trials_reward_stop_short_index, 1)));
% 
% %   output.mean_rw_slow_vel_short = mean(reward_velocity(trials_reward_slow_short_index, 1));
% %   output.sem_rw_slow_vel_short = std(reward_velocity(trials_reward_slow_short_index, 1)) / sqrt(length(reward_velocity(trials_reward_slow_short_index, 1)));
% 
% 
  trials_reward_stop_medium = trials_reward_medium .* trials_reward_stop;
  trials_reward_slow_medium = trials_reward_medium .* trials_reward_slow;
  trials_reward_stop_medium_index = find(trials_reward_stop_medium == 1);
  trials_reward_slow_medium_index = find(trials_reward_slow_medium == 1);
% 
% %   output.mean_rw_vel_medium = mean(reward_velocity(trials_reward_medium_index, 1));
% %   output.sem_rw_vel_medium = std(reward_velocity(trials_reward_medium_index, 1)) / sqrt(length(reward_velocity(trials_reward_medium_index, 1)));
% 
% %   output.mean_rw_stop_vel_medium = mean(reward_velocity(trials_reward_stop_medium_index, 1));
% %   output.sem_rw_stop_vel_medium = std(reward_velocity(trials_reward_stop_medium_index, 1)) / sqrt(length(reward_velocity(trials_reward_stop_medium_index, 1)));
% 
% %   output.mean_rw_slow_vel_medium = mean(reward_velocity(trials_reward_slow_medium_index, 1));
% %   output.sem_rw_slow_vel_medium = std(reward_velocity(trials_reward_slow_medium_index, 1)) / sqrt(length(reward_velocity(trials_reward_slow_medium_index, 1)));
% 
% 
% 
  trials_reward_stop_long = trials_reward_long .* trials_reward_stop;
  trials_reward_slow_long = trials_reward_long .* trials_reward_slow;
  trials_reward_stop_long_index = find(trials_reward_stop_long == 1);
  trials_reward_slow_long_index = find(trials_reward_slow_long == 1);
% 
% %   output.mean_rw_vel_long = mean(reward_velocity(trials_reward_long_index, 1));
% %   output.sem_rw_vel_long = std(reward_velocity(trials_reward_long_index, 1)) / sqrt(length(reward_velocity(trials_reward_long_index, 1)));
% 
% %   output.mean_rw_stop_vel_long = mean(reward_velocity(trials_reward_stop_long_index, 1));
% %   output.sem_rw_stop_vel_long = std(reward_velocity(trials_reward_stop_long_index, 1)) / sqrt(length(reward_velocity(trials_reward_stop_long_index, 1)));
% 
% %   output.mean_rw_slow_vel_long = mean(reward_velocity(trials_reward_slow_long_index, 1));
% %   output.sem_rw_slow_vel_long = std(reward_velocity(trials_reward_slow_long_index, 1)) / sqrt(length(reward_velocity(trials_reward_slow_long_index, 1)));
% 
% % % Sub thresh analysis
% 
% %     % short
% 
% %         max_size_short = max(low_vel_dist_sizes(trials_reward_short_index, 1));
% 
% %         for i = 1:size(trials_reward_short_index, 1)
% %            low_vel_dist_sizes_short(i, :) = max_size_short - size(low_vel_dist{trials_reward_short_index(i, 1), 3}, 1); 
% %            low_vel_dist_short{i, 1} = [low_vel_dist{trials_reward_short_index(i, 1), 3};nan(low_vel_dist_sizes_short(i, :), 1)];
% 
% %         end
% 
% %         low_vel_dist_short_hist = cell2mat(low_vel_dist_short);
% 
% %         low_vel_dist_short_hist_cut_index = find(low_vel_dist_short_hist(:, 1) > (0.8*short));
% %         low_vel_dist_short_hist = low_vel_dist_short_hist(low_vel_dist_short_hist_cut_index, 1);
%         
% %         %[f,xi] = ksdensity(low_vel_dist_short_hist); 
% %          %plot(xi,f);                        
% 
% 
% %         output.low_vel_dist_short_hist = low_vel_dist_short_hist;
% 
% %         figure(1)    
% %         hold on
% %         histogram(low_vel_dist_short_hist, [(short*0.8):10:(short+cutoff)], 'Normalization', 'probability')
% %             ylabel('Relative Probability')
%         
%             
% 
% % %plot(x,ySix,'k-','LineWidth',2)
% 
% %            % Save Fig file to computer 
% 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'Threshold_crossing_hist_short_', date, '_', num)];
% %             savefig(SaveName);            
%             
% %             close all
% 
% %     % medium
% 
% %         max_size_medium = max(low_vel_dist_sizes(trials_reward_medium_index, 1));
% 
% %         for i = 1:size(trials_reward_medium_index, 1)
% %            low_vel_dist_sizes_medium(i, :) = max_size_medium - size(low_vel_dist{trials_reward_medium_index(i, 1), 3}, 1); 
% %            low_vel_dist_medium{i, 1} = [low_vel_dist{trials_reward_medium_index(i, 1), 3};nan(low_vel_dist_sizes_medium(i, :), 1)];
% 
% %         end
% 
% %         low_vel_dist_medium_hist = cell2mat(low_vel_dist_medium);
% 
% %         low_vel_dist_medium_hist_cut_index = find(low_vel_dist_medium_hist(:, 1) > (0.8*medium));
% %         low_vel_dist_medium_hist = low_vel_dist_medium_hist(low_vel_dist_medium_hist_cut_index, 1);
% %         output.low_vel_dist_medium_hist = low_vel_dist_medium_hist;
% 
% %         histogram(low_vel_dist_medium_hist, [(medium*0.8):15:(medium+cutoff)], 'Normalization', 'probability')
%             
% %            % Save Fig file to computer 
% 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'Threshold_crossing_hist_medium_', date, '_', num)];
% %             savefig(SaveName);            
%             
% %             close all
% 
% %     % long
% 
% %         max_size_long = max(low_vel_dist_sizes(trials_reward_long_index, 1));
% 
% %         for i = 1:size(trials_reward_long_index, 1)
% %            low_vel_dist_sizes_long(i, :) = max_size_long - size(low_vel_dist{trials_reward_long_index(i, 1), 3}, 1); 
% %            low_vel_dist_long{i, 1} = [low_vel_dist{trials_reward_long_index(i, 1), 3};nan(low_vel_dist_sizes_long(i, :), 1)];
% 
% %         end
% 
% %         low_vel_dist_long_hist = cell2mat(low_vel_dist_long);
% 
% %         low_vel_dist_long_hist_cut_index = find(low_vel_dist_long_hist(:, 1) > (0.8*long));
% %         low_vel_dist_long_hist = low_vel_dist_long_hist(low_vel_dist_long_hist_cut_index, 1);
% %         output.low_vel_dist_long_hist = low_vel_dist_long_hist;
% 
% %         histogram(low_vel_dist_long_hist, [(long*0.8):20:(long+cutoff)], 'Normalization', 'probability')
%             
% %            % Save Fig file to computer 
% 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'Threshold_crossing_hist_long_', date, '_', num)];
% %             savefig(SaveName);            
%             
% %             close all
% 
% Opto manipulation analysis

    % Control 1
        trials_opto_control_short = trials_opto_control .* trials_short;
        trials_opto_control_medium = trials_opto_control .* trials_medium;
        trials_opto_control_long = trials_opto_control .* trials_long;

        trials_go_opto_control = trials_opto_control .* trials_go;
        trials_go_opto_control_short = trials_go_opto_control .* trials_short;
        trials_go_opto_control_medium = trials_go_opto_control .* trials_medium;
        trials_go_opto_control_long = trials_go_opto_control .* trials_long;

        trials_opto_control_complete = trials_opto_control .* trials_reward;
        trials_opto_control_complete_slow = trials_opto_control .* trials_reward_slow;
        trials_opto_control_complete_stop = trials_opto_control .* trials_reward_stop;
        trials_opto_control_incomplete_running = trials_opto_control .* trials_incomplete_running;
        trials_opto_control_incomplete_running_late = trials_opto_control .* trials_incomplete_running_late;
        trials_opto_control_incomplete_running_early = trials_opto_control .* trials_incomplete_running_early;
        trials_opto_control_premature = trials_opto_control .* trials_premature;
        trials_opto_control_slowfail = trials_opto_control .* trials_slowfail;
        trials_opto_control_premature_slow = trials_opto_control .* trials_premature_slow;

        trials_opto_control_complete_short = trials_opto_control .* trials_reward_short;
        trials_opto_control_complete_slow_short = trials_opto_control .* trials_reward_slow_short;
        trials_opto_control_complete_stop_short = trials_opto_control .* trials_reward_stop_short;
        trials_opto_control_incomplete_running_short = trials_opto_control .* trials_incomplete_running_short;
        trials_opto_control_incomplete_running_late_short = trials_opto_control .* trials_incomplete_running_late_short;
        trials_opto_control_incomplete_running_early_short = trials_opto_control .* trials_incomplete_running_early_short;
        trials_opto_control_premature_short = trials_opto_control .* trials_premature_short;
        trials_opto_control_slowfail_short = trials_opto_control .* trials_slowfail_short;
        trials_opto_control_premature_slow_short = trials_opto_control .* trials_premature_slow_short;

        trials_opto_control_complete_medium = trials_opto_control .* trials_reward_medium;
        trials_opto_control_complete_slow_medium = trials_opto_control .* trials_reward_slow_medium;
        trials_opto_control_complete_stop_medium = trials_opto_control .* trials_reward_stop_medium;
        trials_opto_control_incomplete_running_medium = trials_opto_control .* trials_incomplete_running_medium;
        trials_opto_control_incomplete_running_late_medium = trials_opto_control .* trials_incomplete_running_late_medium;
        trials_opto_control_incomplete_running_early_medium = trials_opto_control .* trials_incomplete_running_early_medium;
        trials_opto_control_premature_medium = trials_opto_control .* trials_premature_medium;
        trials_opto_control_slowfail_medium = trials_opto_control .* trials_slowfail_medium;
        trials_opto_control_premature_slow_medium = trials_opto_control .* trials_premature_slow_medium;

        trials_opto_control_complete_long = trials_opto_control .* trials_reward_long;
        trials_opto_control_complete_slow_long = trials_opto_control .* trials_reward_slow_long;
        trials_opto_control_complete_stop_long = trials_opto_control .* trials_reward_stop_long;
        trials_opto_control_incomplete_running_long = trials_opto_control .* trials_incomplete_running_long;
        trials_opto_control_incomplete_running_late_long = trials_opto_control .* trials_incomplete_running_late_long;
        trials_opto_control_incomplete_running_early_long = trials_opto_control .* trials_incomplete_running_early_long;
        trials_opto_control_premature_long = trials_opto_control .* trials_premature_long;
        trials_opto_control_slowfail_long = trials_opto_control .* trials_slowfail_long;
        trials_opto_control_premature_slow_long = trials_opto_control .* trials_premature_slow_long;

        trials_opto_control_incomplete_running_imm = trials_opto_control .* trials_incomplete_running_imm;
        trials_opto_control_incomplete_running_imm_short = trials_opto_control .* trials_incomplete_running_imm_short;
        trials_opto_control_incomplete_running_imm_medium = trials_opto_control .* trials_incomplete_running_imm_medium;
        trials_opto_control_incomplete_running_imm_long = trials_opto_control .* trials_incomplete_running_imm_long;        

    % target_1 

        trials_opto_target_1_short = trials_opto_target_1 .* trials_short;
        trials_opto_target_1_medium = trials_opto_target_1 .* trials_medium;
        trials_opto_target_1_long = trials_opto_target_1 .* trials_long;

        trials_go_opto_target_1 = trials_opto_target_1 .* trials_go;
        trials_go_opto_target_1_short = trials_go_opto_target_1 .* trials_short;
        trials_go_opto_target_1_medium = trials_go_opto_target_1 .* trials_medium;
        trials_go_opto_target_1_long = trials_go_opto_target_1 .* trials_long;    
    
        trials_opto_target_1_complete = trials_opto_target_1 .* trials_reward;
        trials_opto_target_1_complete_slow = trials_opto_target_1 .* trials_reward_slow;
        trials_opto_target_1_complete_stop = trials_opto_target_1 .* trials_reward_stop;
        trials_opto_target_1_incomplete_running = trials_opto_target_1 .* trials_incomplete_running;
        trials_opto_target_1_incomplete_running_late = trials_opto_target_1 .* trials_incomplete_running_late;
        trials_opto_target_1_incomplete_running_early = trials_opto_target_1 .* trials_incomplete_running_early;
        trials_opto_target_1_premature = trials_opto_target_1 .* trials_premature;
        trials_opto_target_1_slowfail = trials_opto_target_1 .* trials_slowfail;
        trials_opto_target_1_premature_slow = trials_opto_target_1 .* trials_premature_slow;

        trials_opto_target_1_complete_short = trials_opto_target_1 .* trials_reward_short;
        trials_opto_target_1_complete_slow_short = trials_opto_target_1 .* trials_reward_slow_short;
        trials_opto_target_1_complete_stop_short = trials_opto_target_1 .* trials_reward_stop_short;
        trials_opto_target_1_incomplete_running_short = trials_opto_target_1 .* trials_incomplete_running_short;
        trials_opto_target_1_incomplete_running_late_short = trials_opto_target_1 .* trials_incomplete_running_late_short;
        trials_opto_target_1_incomplete_running_early_short = trials_opto_target_1 .* trials_incomplete_running_early_short;
        trials_opto_target_1_premature_short = trials_opto_target_1 .* trials_premature_short;
        trials_opto_target_1_slowfail_short = trials_opto_target_1 .* trials_slowfail_short;
        trials_opto_target_1_premature_slow_short = trials_opto_target_1 .* trials_premature_slow_short;

        trials_opto_target_1_complete_medium = trials_opto_target_1 .* trials_reward_medium;
        trials_opto_target_1_complete_slow_medium = trials_opto_target_1 .* trials_reward_slow_medium;
        trials_opto_target_1_complete_stop_medium = trials_opto_target_1 .* trials_reward_stop_medium;
        trials_opto_target_1_incomplete_running_medium = trials_opto_target_1 .* trials_incomplete_running_medium;
        trials_opto_target_1_incomplete_running_late_medium = trials_opto_target_1 .* trials_incomplete_running_late_medium;
        trials_opto_target_1_incomplete_running_early_medium = trials_opto_target_1 .* trials_incomplete_running_early_medium;
        trials_opto_target_1_premature_medium = trials_opto_target_1 .* trials_premature_medium;
        trials_opto_target_1_slowfail_medium = trials_opto_target_1 .* trials_slowfail_medium;
        trials_opto_target_1_premature_slow_medium = trials_opto_target_1 .* trials_premature_slow_medium;

        trials_opto_target_1_complete_long = trials_opto_target_1 .* trials_reward_long;
        trials_opto_target_1_complete_slow_long = trials_opto_target_1 .* trials_reward_slow_long;
        trials_opto_target_1_complete_stop_long = trials_opto_target_1 .* trials_reward_stop_long;
        trials_opto_target_1_incomplete_running_long = trials_opto_target_1 .* trials_incomplete_running_long;
        trials_opto_target_1_incomplete_running_late_long = trials_opto_target_1 .* trials_incomplete_running_late_long;
        trials_opto_target_1_incomplete_running_early_long = trials_opto_target_1 .* trials_incomplete_running_early_long;
        trials_opto_target_1_premature_long = trials_opto_target_1 .* trials_premature_long;
        trials_opto_target_1_slowfail_long = trials_opto_target_1 .* trials_slowfail_long;
        trials_opto_target_1_premature_slow_long = trials_opto_target_1 .* trials_premature_slow_long;

        trials_opto_target_1_incomplete_running_imm = trials_opto_target_1 .* trials_incomplete_running_imm;
        trials_opto_target_1_incomplete_running_imm_short = trials_opto_target_1 .* trials_incomplete_running_imm_short;
        trials_opto_target_1_incomplete_running_imm_medium = trials_opto_target_1 .* trials_incomplete_running_imm_medium;
        trials_opto_target_1_incomplete_running_imm_long = trials_opto_target_1 .* trials_incomplete_running_imm_long;

        trials_opto_control_premature_slow_imm = trials_opto_control .* trials_premature_slow_imm;
        trials_opto_target_1_premature_slow_imm = trials_opto_target_1 .* trials_premature_slow_imm;
        trials_opto_control_premature_slow_imm_short = trials_opto_control_short .* trials_premature_slow_imm;
        trials_opto_target_1_premature_slow_imm_short = trials_opto_target_1_short .* trials_premature_slow_imm;
        trials_opto_control_premature_slow_imm_medium = trials_opto_control_medium .* trials_premature_slow_imm;
        trials_opto_target_1_premature_slow_imm_medium = trials_opto_target_1_medium .* trials_premature_slow_imm;
        trials_opto_control_premature_slow_imm_long = trials_opto_control_long .* trials_premature_slow_imm;
        trials_opto_target_1_premature_slow_imm_long = trials_opto_target_1_long .* trials_premature_slow_imm;
        
        trials_opto_control_premature_slow_late = trials_opto_control .* trials_premature_slow_late;
        trials_opto_target_1_premature_slow_late = trials_opto_target_1 .* trials_premature_slow_late;
        trials_opto_control_premature_slow_late_short = trials_opto_control_short .* trials_premature_slow_late;
        trials_opto_target_1_premature_slow_late_short = trials_opto_target_1_short .* trials_premature_slow_late;
        trials_opto_control_premature_slow_late_medium = trials_opto_control_medium .* trials_premature_slow_late;
        trials_opto_target_1_premature_slow_late_medium = trials_opto_target_1_medium .* trials_premature_slow_late;
        trials_opto_control_premature_slow_late_long = trials_opto_control_long .* trials_premature_slow_late;
        trials_opto_target_1_premature_slow_late_long = trials_opto_target_1_long .* trials_premature_slow_late;


% Performance metrics

output.Complete_opto_control = sum(trials_opto_control_complete);
output.Complete_opto_target_1 = sum(trials_opto_target_1_complete);
output.Complete_short_opto_control = sum(trials_opto_control_complete_short);
output.Complete_short_opto_target_1 = sum(trials_opto_target_1_complete_short);
output.Complete_medium_opto_control = sum(trials_opto_control_complete_medium);
output.Complete_medium_opto_target_1 = sum(trials_opto_target_1_complete_medium);
output.Complete_long_opto_control = sum(trials_opto_control_complete_long);
output.Complete_long_opto_target_1 = sum(trials_opto_target_1_complete_long);

output.Incomplete_late_opto_control = sum(trials_opto_control_incomplete_running_late);
output.Incomplete_late_opto_target_1 = sum(trials_opto_target_1_incomplete_running_late);
output.Incomplete_late_short_opto_control = sum(trials_opto_control_incomplete_running_late_short);
output.Incomplete_late_short_opto_target_1 = sum(trials_opto_target_1_incomplete_running_late_short);
output.Incomplete_late_medium_opto_control = sum(trials_opto_control_incomplete_running_late_medium);
output.Incomplete_late_medium_opto_target_1 = sum(trials_opto_target_1_incomplete_running_late_medium);
output.Incomplete_late_long_opto_control = sum(trials_opto_control_incomplete_running_late_long);
output.Incomplete_late_long_opto_target_1 = sum(trials_opto_target_1_incomplete_running_late_long);

output.Incomplete_early_opto_control = sum(trials_opto_control_incomplete_running_early);
output.Incomplete_early_opto_target_1 = sum(trials_opto_target_1_incomplete_running_early);
output.Incomplete_early_short_opto_control = sum(trials_opto_control_incomplete_running_early_short);
output.Incomplete_early_short_opto_target_1 = sum(trials_opto_target_1_incomplete_running_early_short);
output.Incomplete_early_medium_opto_control = sum(trials_opto_control_incomplete_running_early_medium);
output.Incomplete_early_medium_opto_target_1 = sum(trials_opto_target_1_incomplete_running_early_medium);
output.Incomplete_early_long_opto_control = sum(trials_opto_control_incomplete_running_early_long);
output.Incomplete_early_long_opto_target_1 = sum(trials_opto_target_1_incomplete_running_early_long);

output.Incomplete_imm_opto_control = sum(trials_opto_control_incomplete_running_imm);
output.Incomplete_imm_opto_target_1 = sum(trials_opto_target_1_incomplete_running_imm);
output.Incomplete_imm_short_opto_control = sum(trials_opto_control_incomplete_running_imm_short);
output.Incomplete_imm_short_opto_target_1 = sum(trials_opto_target_1_incomplete_running_imm_short);
output.Incomplete_imm_medium_opto_control = sum(trials_opto_control_incomplete_running_imm_medium);
output.Incomplete_imm_medium_opto_target_1 = sum(trials_opto_target_1_incomplete_running_imm_medium);
output.Incomplete_imm_long_opto_control = sum(trials_opto_control_incomplete_running_imm_long);
output.Incomplete_imm_long_opto_target_1 = sum(trials_opto_target_1_incomplete_running_imm_long);

output.Premature_opto_control = sum(trials_opto_control_premature);
output.Premature_opto_target_1 = sum(trials_opto_target_1_premature);
output.Premature_short_opto_control = sum(trials_opto_control_premature_short);
output.Premature_short_opto_target_1 = sum(trials_opto_target_1_premature_short);
output.Premature_medium_opto_control = sum(trials_opto_control_premature_medium);
output.Premature_medium_opto_target_1 = sum(trials_opto_target_1_premature_medium);
output.Premature_long_opto_control = sum(trials_opto_control_premature_long);
output.Premature_long_opto_target_1 = sum(trials_opto_target_1_premature_long);

output.Premature_slowdown_opto_control = sum(trials_opto_control_premature_slow);
output.Premature_slowdown_opto_target_1 = sum(trials_opto_target_1_premature_slow);
output.Premature_slowdown_short_opto_control = sum(trials_opto_control_premature_slow_short);
output.Premature_slowdown_short_opto_target_1 = sum(trials_opto_target_1_premature_slow_short);
output.Premature_slowdown_medium_opto_control = sum(trials_opto_control_premature_slow_medium);
output.Premature_slowdown_medium_opto_target_1 = sum(trials_opto_target_1_premature_slow_medium);
output.Premature_slowdown_long_opto_control = sum(trials_opto_control_premature_slow_long);
output.Premature_slowdown_long_opto_target_1 = sum(trials_opto_target_1_premature_slow_long);

output.Premature_slowdown_imm_opto_control = sum(trials_opto_control_premature_slow_imm);
output.Premature_slowdown_imm_opto_target_1 = sum(trials_opto_target_1_premature_slow_imm);
output.Premature_slowdown_imm_short_opto_control = sum(trials_opto_control_premature_slow_imm_short);
output.Premature_slowdown_imm_short_opto_target_1 = sum(trials_opto_target_1_premature_slow_imm_short);
output.Premature_slowdown_imm_medium_opto_control = sum(trials_opto_control_premature_slow_imm_medium);
output.Premature_slowdown_imm_medium_opto_target_1 = sum(trials_opto_target_1_premature_slow_imm_medium);
output.Premature_slowdown_imm_long_opto_control = sum(trials_opto_control_premature_slow_imm_long);
output.Premature_slowdown_imm_long_opto_target_1 = sum(trials_opto_target_1_premature_slow_imm_long);

output.Premature_slowdown_late_opto_control = sum(trials_opto_control_premature_slow_late);
output.Premature_slowdown_late_opto_target_1 = sum(trials_opto_target_1_premature_slow_late);
output.Premature_slowdown_late_short_opto_control = sum(trials_opto_control_premature_slow_late_short);
output.Premature_slowdown_late_short_opto_target_1 = sum(trials_opto_target_1_premature_slow_late_short);
output.Premature_slowdown_late_medium_opto_control = sum(trials_opto_control_premature_slow_late_medium);
output.Premature_slowdown_late_medium_opto_target_1 = sum(trials_opto_target_1_premature_slow_late_medium);
output.Premature_slowdown_late_long_opto_control = sum(trials_opto_control_premature_slow_late_long);
output.Premature_slowdown_late_long_opto_target_1 = sum(trials_opto_target_1_premature_slow_late_long);

output.Overrun_opto_control = sum(trials_opto_control_slowfail);
output.Overrun_opto_target_1 = sum(trials_opto_target_1_slowfail);
output.Overrun_short_opto_control = sum(trials_opto_control_slowfail_short);
output.Overrun_short_opto_target_1 = sum(trials_opto_target_1_slowfail_short);
output.Overrun_medium_opto_control = sum(trials_opto_control_slowfail_medium);
output.Overrun_medium_opto_target_1 = sum(trials_opto_target_1_slowfail_medium);
output.Overrun_long_opto_control = sum(trials_opto_control_slowfail_long);
output.Overrun_long_opto_target_1 = sum(trials_opto_target_1_slowfail_long);

output.Total_Trials_opto_control = sum(trials_opto_control);
output.Total_Trials_short_opto_control = sum(trials_opto_control_short);
output.Total_Trials_medium_opto_control = sum(trials_opto_control_medium);
output.Total_Trials_long_opto_control = sum(trials_opto_control_long);

output.Total_Running_Trials_opto_control = sum(trials_go_opto_control);
output.Total_Running_Trials_short_opto_control = sum(trials_go_opto_control_short);
output.Total_Running_Trials_medium_opto_control = sum(trials_go_opto_control_medium);
output.Total_Running_Trials_long_opto_control = sum(trials_go_opto_control_long);

output.Total_Running_Trials_Late_opto_control = output.Total_Running_Trials_opto_control - output.Incomplete_early_opto_control - output.Premature_slowdown_imm_opto_control;
output.Total_Running_Trials_Late_short_opto_control = output.Total_Running_Trials_short_opto_control - output.Incomplete_early_short_opto_control - output.Premature_slowdown_imm_short_opto_control;
output.Total_Running_Trials_Late_medium_opto_control = output.Total_Running_Trials_medium_opto_control - output.Incomplete_early_medium_opto_control - output.Premature_slowdown_imm_medium_opto_control;
output.Total_Running_Trials_Late_long_opto_control = output.Total_Running_Trials_long_opto_control - output.Incomplete_early_long_opto_control - output.Premature_slowdown_imm_long_opto_control;

output.Total_Trials_opto_target_1 = sum(trials_opto_target_1);
output.Total_Trials_short_opto_target_1 = sum(trials_opto_target_1_short);
output.Total_Trials_medium_opto_target_1 = sum(trials_opto_target_1_medium);
output.Total_Trials_long_opto_target_1 = sum(trials_opto_target_1_long);

output.Total_Running_Trials_opto_target_1 = sum(trials_go_opto_target_1);
output.Total_Running_Trials_short_opto_target_1 = sum(trials_go_opto_target_1_short);
output.Total_Running_Trials_medium_opto_target_1 = sum(trials_go_opto_target_1_medium);
output.Total_Running_Trials_long_opto_target_1 = sum(trials_go_opto_target_1_long);

output.Total_Running_Trials_Late_opto_target_1 = output.Total_Running_Trials_opto_target_1 - output.Incomplete_early_opto_target_1 - output.Premature_slowdown_imm_opto_target_1;
output.Total_Running_Trials_Late_short_opto_target_1 = output.Total_Running_Trials_short_opto_target_1 - output.Incomplete_early_short_opto_target_1 - output.Premature_slowdown_imm_short_opto_target_1;
output.Total_Running_Trials_Late_medium_opto_target_1 = output.Total_Running_Trials_medium_opto_target_1 - output.Incomplete_early_medium_opto_target_1 - output.Premature_slowdown_imm_medium_opto_target_1;
output.Total_Running_Trials_Late_long_opto_target_1 = output.Total_Running_Trials_long_opto_target_1 - output.Incomplete_early_long_opto_target_1 - output.Premature_slowdown_imm_long_opto_target_1;

output.Reward_Prop_opto_control = output.Complete_opto_control / output.Total_Running_Trials_Late_opto_control;   
output.Reward_Prop_opto_target_1 = output.Complete_opto_target_1 / output.Total_Running_Trials_Late_opto_target_1;   
output.Reward_Prop_short_opto_control = output.Complete_short_opto_control / output.Total_Running_Trials_Late_short_opto_control; 
output.Reward_Prop_short_opto_target_1 = output.Complete_short_opto_target_1 / output.Total_Running_Trials_Late_short_opto_target_1;   
output.Reward_Prop_medium_opto_control = output.Complete_medium_opto_control / output.Total_Running_Trials_Late_medium_opto_control;   
output.Reward_Prop_medium_opto_target_1 = output.Complete_medium_opto_target_1 / output.Total_Running_Trials_Late_medium_opto_target_1;   
output.Reward_Prop_long_opto_control = output.Complete_long_opto_control / output.Total_Running_Trials_Late_long_opto_control;   
output.Reward_Prop_long_opto_target_1 = output.Complete_long_opto_target_1 / output.Total_Running_Trials_Late_long_opto_target_1;  

output.PreTarget_Error_Prop_opto_control = (output.Premature_slowdown_late_opto_control + output.Incomplete_late_opto_control) / output.Total_Running_Trials_Late_opto_control;
output.PreTarget_Error_Prop_opto_target_1 = (output.Premature_slowdown_late_opto_target_1 + output.Incomplete_late_opto_target_1) / output.Total_Running_Trials_Late_opto_target_1;
output.PreTarget_Error_Prop_short_opto_control = (output.Premature_slowdown_late_short_opto_control + output.Incomplete_late_short_opto_control) / output.Total_Running_Trials_Late_short_opto_control;
output.PreTarget_Error_Prop_short_opto_target_1 = (output.Premature_slowdown_late_short_opto_target_1 + output.Incomplete_late_short_opto_target_1) / output.Total_Running_Trials_Late_short_opto_target_1;
output.PreTarget_Error_Prop_medium_opto_control = (output.Premature_slowdown_late_medium_opto_control + output.Incomplete_late_medium_opto_control) / output.Total_Running_Trials_Late_medium_opto_control;
output.PreTarget_Error_Prop_medium_opto_target_1 = (output.Premature_slowdown_late_medium_opto_target_1 + output.Incomplete_late_medium_opto_target_1) / output.Total_Running_Trials_Late_medium_opto_target_1;
output.PreTarget_Error_Prop_long_opto_control = (output.Premature_slowdown_late_long_opto_control + output.Incomplete_late_long_opto_control) / output.Total_Running_Trials_Late_long_opto_control;
output.PreTarget_Error_Prop_long_opto_target_1 = (output.Premature_slowdown_late_long_opto_target_1 + output.Incomplete_late_long_opto_target_1) / output.Total_Running_Trials_Late_long_opto_target_1;

output.Overrun_Prop_opto_control = output.Overrun_opto_control / output.Total_Running_Trials_Late_opto_control;
output.Overrun_Prop_opto_target_1 = output.Overrun_opto_target_1 / output.Total_Running_Trials_Late_opto_target_1;
output.Overrun_Prop_short_opto_control = output.Overrun_short_opto_control / output.Total_Running_Trials_Late_short_opto_control;
output.Overrun_Prop_short_opto_target_1 = output.Overrun_short_opto_target_1 / output.Total_Running_Trials_Late_short_opto_target_1;
output.Overrun_Prop_medium_opto_control = output.Overrun_medium_opto_control / output.Total_Running_Trials_Late_medium_opto_control;
output.Overrun_Prop_medium_opto_target_1 = output.Overrun_medium_opto_target_1 / output.Total_Running_Trials_Late_medium_opto_target_1;
output.Overrun_Prop_long_opto_control = output.Overrun_long_opto_control / output.Total_Running_Trials_Late_long_opto_control;
output.Overrun_Prop_long_opto_target_1 = output.Overrun_long_opto_target_1 / output.Total_Running_Trials_Late_long_opto_target_1;




    % RW Type prop
      trials_reward_stop_opto_control = trials_reward_stop .* trials_opto_control;
      trials_reward_slow_opto_control = trials_reward_slow .* trials_opto_control;

      trials_reward_stop_short_opto_control = trials_reward_stop_short .* trials_opto_control;
      trials_reward_slow_short_opto_control = trials_reward_slow_short .* trials_opto_control;
      trials_reward_stop_medium_opto_control = trials_reward_stop_medium .* trials_opto_control;
      trials_reward_slow_medium_opto_control = trials_reward_slow_medium .* trials_opto_control;
      trials_reward_stop_long_opto_control = trials_reward_stop_long .* trials_opto_control;
      trials_reward_slow_long_opto_control = trials_reward_slow_long .* trials_opto_control;

      trials_reward_stop_opto_target_1 = trials_reward_stop .* trials_opto_target_1;
      trials_reward_slow_opto_target_1 = trials_reward_slow .* trials_opto_target_1;

      trials_reward_stop_short_opto_target_1 = trials_reward_stop_short .* trials_opto_target_1;
      trials_reward_slow_short_opto_target_1 = trials_reward_slow_short .* trials_opto_target_1;
      trials_reward_stop_medium_opto_target_1 = trials_reward_stop_medium .* trials_opto_target_1;
      trials_reward_slow_medium_opto_target_1 = trials_reward_slow_medium .* trials_opto_target_1;
      trials_reward_stop_long_opto_target_1 = trials_reward_stop_long .* trials_opto_target_1;
      trials_reward_slow_long_opto_target_1 = trials_reward_slow_long .* trials_opto_target_1;


output.Total_RW_stops_opto_control = sum(trials_reward_stop_opto_control);
output.Total_RW_stops_short_opto_control = sum(trials_reward_stop_short_opto_control);
output.Total_RW_stops_medium_opto_control = sum(trials_reward_stop_medium_opto_control);
output.Total_RW_stops_long_opto_control = sum(trials_reward_stop_long_opto_control);

output.Total_RW_stops_opto_target_1 = sum(trials_reward_stop_opto_target_1);
output.Total_RW_stops_short_opto_target_1 = sum(trials_reward_stop_short_opto_target_1);
output.Total_RW_stops_medium_opto_target_1 = sum(trials_reward_stop_medium_opto_target_1);
output.Total_RW_stops_long_opto_target_1 = sum(trials_reward_stop_long_opto_target_1);

output.Total_RW_slows_opto_control = sum(trials_reward_slow_opto_control);
output.Total_RW_slows_short_opto_control = sum(trials_reward_slow_short_opto_control);
output.Total_RW_slows_medium_opto_control = sum(trials_reward_slow_medium_opto_control);
output.Total_RW_slows_long_opto_control = sum(trials_reward_slow_long_opto_control);

output.Total_RW_slows_opto_target_1 = sum(trials_reward_slow_opto_target_1);
output.Total_RW_slows_short_opto_target_1 = sum(trials_reward_slow_short_opto_target_1);
output.Total_RW_slows_medium_opto_target_1 = sum(trials_reward_slow_medium_opto_target_1);
output.Total_RW_slows_long_opto_target_1 = sum(trials_reward_slow_long_opto_target_1);


% output.RW_Stop_Prop_control = sum(trials_reward_stop_opto_control) / output.Complete_opto_control;
% output.RW_Stop_Prop_short_control = sum(trials_reward_stop_short_opto_control) / output.Complete_short_opto_control;
% output.RW_Stop_Prop_medium_control = sum(trials_reward_stop_medium_opto_control) / output.Complete_medium_opto_control;
% output.RW_Stop_Prop_long_control = sum(trials_reward_stop_long_opto_control) / output.Complete_long_opto_control;

% output.RW_Stop_Prop_target = sum(trials_reward_stop_opto_target) / output.Complete_opto_target;
% output.RW_Stop_Prop_short_target = sum(trials_reward_stop_short_opto_target) / output.Complete_short_opto_target;
% output.RW_Stop_Prop_medium_target = sum(trials_reward_stop_medium_opto_target) / output.Complete_medium_opto_target;
% output.RW_Stop_Prop_long_target = sum(trials_reward_stop_long_opto_target) / output.Complete_long_opto_target;

% % The rest of the opto analysis


trials_opto_control_complete_index = find(trials_opto_control_complete == 1);
trials_opto_control_complete_short_index = find(trials_opto_control_complete_short == 1);
trials_opto_control_complete_medium_index = find(trials_opto_control_complete_medium == 1);
trials_opto_control_complete_long_index = find(trials_opto_control_complete_long == 1);
trials_opto_control_slowfail_index = find(trials_opto_control_slowfail == 1);

trials_opto_target_1_complete_index = find(trials_opto_target_1_complete == 1);
trials_opto_target_1_complete_short_index = find(trials_opto_target_1_complete_short == 1);
trials_opto_target_1_complete_medium_index = find(trials_opto_target_1_complete_medium == 1);
trials_opto_target_1_complete_long_index = find(trials_opto_target_1_complete_long == 1);
trials_opto_target_1_slowfail_index = find(trials_opto_target_1_slowfail == 1);

% % 
% % output.velocity_reduction_complete_time_opto_control = velocity_reduction_ratio_time(trials_opto_control_complete_index, 1);
% % output.velocity_reduction_complete_short_time_opto_control = velocity_reduction_ratio_time(trials_opto_control_complete_short_index, 1);
% % output.velocity_reduction_complete_medium_time_opto_control = velocity_reduction_ratio_time(trials_opto_control_complete_medium_index, 1);
% % output.velocity_reduction_complete_long_time_opto_control = velocity_reduction_ratio_time(trials_opto_control_complete_long_index, 1);
% % 
% % output.velocity_reduction_overrun_time_opto_control = velocity_reduction_ratio_time(trials_opto_control_slowfail_index, 1);
% % output.velocity_reduction_stopped_time_opto_control = velocity_reduction_ratio_time(trials_opto_control_incomplete_slowdown_index, 1);
% % 
% % output.velocity_reduction_complete_dist_opto_control = velocity_reduction_ratio_dist(trials_opto_control_complete_index, 1);
% % output.velocity_reduction_complete_short_dist_opto_control = velocity_reduction_ratio_dist(trials_opto_control_complete_short_index, 1);
% % output.velocity_reduction_complete_medium_dist_opto_control = velocity_reduction_ratio_dist(trials_opto_control_complete_medium_index, 1);
% % output.velocity_reduction_complete_long_dist_opto_control = velocity_reduction_ratio_dist(trials_opto_control_complete_long_index, 1);
% % 
% % output.velocity_reduction_overrun_dist_opto_control = velocity_reduction_ratio_dist(trials_opto_control_slowfail_index, 1);
% % output.velocity_reduction_stopped_dist_opto_control = velocity_reduction_ratio_dist(trials_opto_control_incomplete_slowdown_index, 1);
% % 
% % 
% % output.velocity_reduction_complete_time_opto_target = velocity_reduction_ratio_time(trials_opto_target_complete_index, 1);
% % output.velocity_reduction_complete_short_time_opto_target = velocity_reduction_ratio_time(trials_opto_target_complete_short_index, 1);
% % output.velocity_reduction_complete_medium_time_opto_target = velocity_reduction_ratio_time(trials_opto_target_complete_medium_index, 1);
% % output.velocity_reduction_complete_long_time_opto_target = velocity_reduction_ratio_time(trials_opto_target_complete_long_index, 1);
% % 
% % output.velocity_reduction_overrun_time_opto_target = velocity_reduction_ratio_time(trials_opto_target_slowfail_index, 1);
% % output.velocity_reduction_stopped_time_opto_target = velocity_reduction_ratio_time(trials_opto_target_incomplete_slowdown_index, 1);
% % 
% % output.velocity_reduction_complete_dist_opto_target = velocity_reduction_ratio_dist(trials_opto_target_complete_index, 1);
% % output.velocity_reduction_complete_short_dist_opto_target = velocity_reduction_ratio_dist(trials_opto_target_complete_short_index, 1);
% % output.velocity_reduction_complete_medium_dist_opto_target = velocity_reduction_ratio_dist(trials_opto_target_complete_medium_index, 1);
% % output.velocity_reduction_complete_long_dist_opto_target = velocity_reduction_ratio_dist(trials_opto_target_complete_long_index, 1);
% % 
% % output.velocity_reduction_overrun_dist_opto_target = velocity_reduction_ratio_dist(trials_opto_target_slowfail_index, 1);
% % output.velocity_reduction_stopped_dist_opto_target = velocity_reduction_ratio_dist(trials_opto_target_incomplete_slowdown_index, 1);
% % 
% % 
% % 
% % 
% % 
% % sig_maint_velocity_metrics_short_complete_time_optcont = trials_opto_control_complete_short .* maintenance_velocity_metrics_time_sig;
% % sig_maint_velocity_metrics_medium_complete_time_optcont = trials_opto_control_complete_medium .* maintenance_velocity_metrics_time_sig;
% % sig_maint_velocity_metrics_long_complete_time_optcont = trials_opto_control_complete_long .* maintenance_velocity_metrics_time_sig;
% % 
% % output.mean_maintenance_metric_short_time_optcont = mean(maintenance_velocity_metrics_time(trials_opto_control_complete_short_index, 1));
% % output.mean_maintenance_metric_medium_time_optcont = mean(maintenance_velocity_metrics_time(trials_opto_control_complete_medium_index, 1));
% % output.mean_maintenance_metric_long_time_optcont = mean(maintenance_velocity_metrics_time(trials_opto_control_complete_long_index, 1));
% % 
% % output.ratio_of_significant_maintenance_metric_short_time_optcont = sum(sig_maint_velocity_metrics_short_complete_time_optcont) / length(maintenance_velocity_metrics_time(trials_opto_control_complete_short_index, 1));
% % output.ratio_of_significant_maintenance_metric_medium_time_optcont = sum(sig_maint_velocity_metrics_medium_complete_time_optcont) / length(maintenance_velocity_metrics_time(trials_opto_control_complete_medium_index, 1));
% % output.ratio_of_significant_maintenance_metric_long_time_optcont = sum(sig_maint_velocity_metrics_long_complete_time_optcont) / length(maintenance_velocity_metrics_time(trials_opto_control_complete_long_index, 1));
% % 
% % 
% % sig_maint_velocity_metrics_short_complete_dist_optcont = trials_opto_control_complete_short .* maintenance_velocity_metrics_dist_sig;
% % sig_maint_velocity_metrics_medium_complete_dist_optcont = trials_opto_control_complete_medium .* maintenance_velocity_metrics_dist_sig;
% % sig_maint_velocity_metrics_long_complete_dist_optcont = trials_opto_control_complete_long .* maintenance_velocity_metrics_dist_sig;
% % 
% % output.mean_maintenance_metric_short_dist_optcont = mean(maintenance_velocity_metrics_dist(trials_opto_control_complete_short_index, 1));
% % output.mean_maintenance_metric_medium_dist_optcont = mean(maintenance_velocity_metrics_dist(trials_opto_control_complete_medium_index, 1));
% % output.mean_maintenance_metric_long_dist_optcont = mean(maintenance_velocity_metrics_dist(trials_opto_control_complete_long_index, 1));
% % 
% % output.ratio_of_significant_maintenance_metric_short_dist_optcont = sum(sig_maint_velocity_metrics_short_complete_dist_optcont) / length(maintenance_velocity_metrics_dist(trials_opto_control_complete_short_index, 1));
% % output.ratio_of_significant_maintenance_metric_medium_dist_optcont = sum(sig_maint_velocity_metrics_medium_complete_dist_optcont) / length(maintenance_velocity_metrics_dist(trials_opto_control_complete_medium_index, 1));
% % output.ratio_of_significant_maintenance_metric_long_dist_optcont = sum(sig_maint_velocity_metrics_long_complete_dist_optcont) / length(maintenance_velocity_metrics_dist(trials_opto_control_complete_long_index, 1));
% % 
% % 
% % sig_maint_velocity_metrics_short_complete_time_opttarg = trials_opto_target_complete_short .* maintenance_velocity_metrics_time_sig;
% % sig_maint_velocity_metrics_medium_complete_time_opttarg = trials_opto_target_complete_medium .* maintenance_velocity_metrics_time_sig;
% % sig_maint_velocity_metrics_long_complete_time_opttarg = trials_opto_target_complete_long .* maintenance_velocity_metrics_time_sig;
% % 
% % output.mean_maintenance_metric_short_time_opttarg = mean(maintenance_velocity_metrics_time(trials_opto_target_complete_short_index, 1));
% % output.mean_maintenance_metric_medium_time_opttarg = mean(maintenance_velocity_metrics_time(trials_opto_target_complete_medium_index, 1));
% % output.mean_maintenance_metric_long_time_opttarg = mean(maintenance_velocity_metrics_time(trials_opto_target_complete_long_index, 1));
% % 
% % output.ratio_of_significant_maintenance_metric_short_time_opttarg = sum(sig_maint_velocity_metrics_short_complete_time_opttarg) / length(maintenance_velocity_metrics_time(trials_opto_target_complete_short_index, 1));
% % output.ratio_of_significant_maintenance_metric_medium_time_opttarg = sum(sig_maint_velocity_metrics_medium_complete_time_opttarg) / length(maintenance_velocity_metrics_time(trials_opto_target_complete_medium_index, 1));
% % output.ratio_of_significant_maintenance_metric_long_time_opttarg = sum(sig_maint_velocity_metrics_long_complete_time_opttarg) / length(maintenance_velocity_metrics_time(trials_opto_target_complete_long_index, 1));
% % 
% % 
% % sig_maint_velocity_metrics_short_complete_dist_opttarg = trials_opto_target_complete_short .* maintenance_velocity_metrics_dist_sig;
% % sig_maint_velocity_metrics_medium_complete_dist_opttarg = trials_opto_target_complete_medium .* maintenance_velocity_metrics_dist_sig;
% % sig_maint_velocity_metrics_long_complete_dist_opttarg = trials_opto_target_complete_long .* maintenance_velocity_metrics_dist_sig;
% % 
% % output.mean_maintenance_metric_short_dist_opttarg = mean(maintenance_velocity_metrics_dist(trials_opto_target_complete_short_index, 1));
% % output.mean_maintenance_metric_medium_dist_opttarg = mean(maintenance_velocity_metrics_dist(trials_opto_target_complete_medium_index, 1));
% % output.mean_maintenance_metric_long_dist_opttarg = mean(maintenance_velocity_metrics_dist(trials_opto_target_complete_long_index, 1));
% % 
% % output.ratio_of_significant_maintenance_metric_short_dist_opttarg = sum(sig_maint_velocity_metrics_short_complete_dist_opttarg) / length(maintenance_velocity_metrics_dist(trials_opto_target_complete_short_index, 1));
% % output.ratio_of_significant_maintenance_metric_medium_dist_opttarg = sum(sig_maint_velocity_metrics_medium_complete_dist_opttarg) / length(maintenance_velocity_metrics_dist(trials_opto_target_complete_medium_index, 1));
% % output.ratio_of_significant_maintenance_metric_long_dist_opttarg = sum(sig_maint_velocity_metrics_long_complete_dist_opttarg) / length(maintenance_velocity_metrics_dist(trials_opto_target_complete_long_index, 1));
% %   
% % 
% % 
% % % Heatmap 
% % 
% % x = size(trials_opto_control_complete_short_index, 1);
% % y = size(trials_opto_control_complete_medium_index, 1);
% % z = size(trials_opto_control_complete_long_index, 1);
% % 
% % heatmap_data_time_short_opto_control(1:x, :) = movement_velocities_smooth_mean_time(trials_opto_control_complete_short_index, :); 
% % heatmap_data_time_medium_opto_control(1:y, :) = movement_velocities_smooth_mean_time(trials_opto_control_complete_medium_index, :); 
% % heatmap_data_time_long_opto_control(1:z, :) = movement_velocities_smooth_mean_time(trials_opto_control_complete_long_index, :); 
% % 
% % heatmap_time_data_opto_control = [heatmap_data_time_short_opto_control; heatmap_data_time_medium_opto_control; heatmap_data_time_long_opto_control];
% % 
% % figure(17)
% % heatmap(heatmap_time_data_opto_control, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_optocontrol_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all
% % 
% % x = size(trials_opto_target_complete_short_index, 1);
% % y = size(trials_opto_target_complete_medium_index, 1);
% % z = size(trials_opto_target_complete_long_index, 1);
% % 
% % heatmap_data_time_short_opto_target(1:x, :) = movement_velocities_smooth_mean_time(trials_opto_target_complete_short_index, :); 
% % heatmap_data_time_medium_opto_target(1:y, :) = movement_velocities_smooth_mean_time(trials_opto_target_complete_medium_index, :); 
% % heatmap_data_time_long_opto_target(1:z, :) = movement_velocities_smooth_mean_time(trials_opto_target_complete_long_index, :); 
% % 
% % heatmap_time_data_opto_target = [heatmap_data_time_short_opto_target; heatmap_data_time_medium_opto_target; heatmap_data_time_long_opto_target];
% % 
% % figure(18)
% % heatmap(heatmap_time_data_opto_target, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_optotarget_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all
% % 
% % 
% % % Complete Traces
% % 
% %             vel_smooth_short_dist_complete_opto_control = nanmean(movement_velocities_smooth_mean_dist(trials_opto_control_complete_index, :))';
% %             vel_smooth_short_dist_complete_opto_target = nanmean(movement_velocities_smooth_mean_dist(trials_opto_target_complete_index, :))';
% %             %vel_smooth_short_dist_incomplete_running_opto_control = nanmean(movement_velocities_smooth_mean_dist(trials_incomplete_running_short_log, :))';
% %             
% % 
% %            figure(9)
% %                hold on
% %                plot(vel_smooth_short_dist_complete_opto_control);
% %                plot(vel_smooth_short_dist_complete_opto_target);
% %                %plot(vel_smooth_short_dist_incomplete_running);
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
% %                legend('control','opto')
% %                axis ([-inf inf 0 600]);
% %                title 'Average Velocity Trajectories Complete Rescaled by Distance'
% %                 xlabel('Normalized Percent Distance to Target') 
% %                 ylabel('Mean Velocity (cm/s)') 
% % 
% %            hold off
% %      
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'VelocityTrajectories_Distance_Complete_Opto_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all   
% %             
% % % All trial Traces
% % 
% %             vel_smooth_short_dist_alltrial_opto_control = nanmean(movement_velocities_smooth_mean_dist(trials_opto_control_index, :))';
% %             vel_smooth_short_dist_alltrial_opto_target = nanmean(movement_velocities_smooth_mean_dist(trials_opto_target_index, :))';
% %             %vel_smooth_short_dist_incomplete_running_opto_control = nanmean(movement_velocities_smooth_mean_dist(trials_incomplete_running_short_log, :))';
% %             
% % 
% %             
% %             %vel_smooth_short_dist_alltrial_opto_control = (movement_velocities_smooth_mean_dist(trials_opto_control_index, :))';
% %             %vel_smooth_short_dist_alltrial_opto_target = (movement_velocities_smooth_mean_dist(trials_opto_target_index, :))';
% %     
% %            figure(11)
% %                hold on
% %                plot(vel_smooth_short_dist_alltrial_opto_control);
% %                plot(vel_smooth_short_dist_alltrial_opto_target);
% %                %plot(vel_smooth_short_dist_incomplete_running);
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(complete_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(incomplete_slowdown_trials_index, :));
% %                %plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_incomplete_running_index, :));
% %                legend('control','opto')
% %                axis ([-inf inf 0 600]);
% %                title 'Average Velocity Trajectories (All trials) Rescaled by Distance'
% %                 xlabel('Normalized Percent Distance to Target') 
% %                 ylabel('Mean Velocity (cm/s)') 
% % 
% %            hold off
% %      
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'VelocityTrajectories_Distance_All_Trials_Opto_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all  
% %       

% Rewarded Distances opto/control
    mean_reward_distance_optocont = mean(reward_distance(trials_opto_control_complete_index, 1), 'omitnan');
    median_reward_distance_optocont = median(reward_distance(trials_opto_control_complete_index, 1), 'omitnan');
    sem_reward_distance_optocont = (std(reward_distance(trials_opto_control_complete_index, 1), 'omitnan')/(sqrt(sum(~isnan(reward_distance(trials_opto_control_complete_index, 1))))));

    mean_reward_distance_short_optocont = mean(reward_distance(trials_opto_control_complete_short_index, 1), 'omitnan');
    mean_reward_distance_medium_optocont = mean(reward_distance(trials_opto_control_complete_medium_index, 1), 'omitnan');
    mean_reward_distance_long_optocont = mean(reward_distance(trials_opto_control_complete_long_index, 1), 'omitnan');
    
    median_reward_distance_short_optocont = median(reward_distance(trials_opto_control_complete_short_index, 1), 'omitnan');
    median_reward_distance_medium_optocont = median(reward_distance(trials_opto_control_complete_medium_index, 1), 'omitnan');
    median_reward_distance_long_optocont = median(reward_distance(trials_opto_control_complete_long_index, 1), 'omitnan');
    
    sem_reward_distance_short_optocont = (std(reward_distance(trials_opto_control_complete_short_index, 1), 'omitnan')/(sqrt(sum(~isnan(reward_distance(trials_opto_control_complete_short_index, 1))))));
    sem_reward_distance_medium_optocont = (std(reward_distance(trials_opto_control_complete_medium_index, 1), 'omitnan')/(sqrt(sum(~isnan(reward_distance(trials_opto_control_complete_medium_index, 1))))));
    sem_reward_distance_long_optocont = (std(reward_distance(trials_opto_control_complete_long_index, 1), 'omitnan')/(sqrt(sum(~isnan(reward_distance(trials_opto_control_complete_long_index, 1))))));

    mean_reward_distance_optotarg = mean(reward_distance(trials_opto_target_1_complete_index, 1), 'omitnan');
    median_reward_distance_optotarg = median(reward_distance(trials_opto_target_1_complete_index, 1), 'omitnan');
    sem_reward_distance_optotarg = (std(reward_distance(trials_opto_target_1_complete_index, 1), 'omitnan')/(sqrt(sum(~isnan(reward_distance(trials_opto_target_1_complete_index, 1))))));

    mean_reward_distance_short_optotarg = mean(reward_distance(trials_opto_target_1_complete_short_index, 1), 'omitnan');
    mean_reward_distance_medium_optotarg = mean(reward_distance(trials_opto_target_1_complete_medium_index, 1), 'omitnan');
    mean_reward_distance_long_optotarg = mean(reward_distance(trials_opto_target_1_complete_long_index, 1), 'omitnan');
    
    median_reward_distance_short_optotarg = median(reward_distance(trials_opto_target_1_complete_short_index, 1), 'omitnan');
    median_reward_distance_medium_optotarg = median(reward_distance(trials_opto_target_1_complete_medium_index, 1), 'omitnan');
    median_reward_distance_long_optotarg = median(reward_distance(trials_opto_target_1_complete_long_index, 1), 'omitnan');
    
    sem_reward_distance_short_optotarg = (std(reward_distance(trials_opto_target_1_complete_short_index, 1), 'omitnan')/(sqrt(sum(~isnan(reward_distance(trials_opto_target_1_complete_short_index, 1))))));
    sem_reward_distance_medium_optotarg = (std(reward_distance(trials_opto_target_1_complete_medium_index, 1), 'omitnan')/(sqrt(sum(~isnan(reward_distance(trials_opto_target_1_complete_medium_index, 1))))));
    sem_reward_distance_long_optotarg = (std(reward_distance(trials_opto_target_1_complete_long_index, 1), 'omitnan')/(sqrt(sum(~isnan(reward_distance(trials_opto_target_1_complete_long_index, 1))))));
    

    output.reward_distances_opto_control = reward_distance(trials_opto_control_complete_index, 1);
    output.reward_distances_opto_target = reward_distance(trials_opto_target_1_complete_index, 1);

    output.reward_distances_opto_control_short = reward_distance(trials_opto_control_complete_short_index, 1);
    output.reward_distances_opto_target_short = reward_distance(trials_opto_target_1_complete_short_index, 1);

    output.reward_distances_opto_control_medium = reward_distance(trials_opto_control_complete_medium_index, 1);
    output.reward_distances_opto_target_medium = reward_distance(trials_opto_target_1_complete_medium_index, 1);

    output.reward_distances_opto_control_long = reward_distance(trials_opto_control_complete_long_index, 1);
    output.reward_distances_opto_target_long = reward_distance(trials_opto_target_1_complete_long_index, 1);

    output.mean_reward_distance_optocont = mean_reward_distance_optocont;
    output.median_reward_distance_optocont = median_reward_distance_optocont;
    output.sem_reward_distance_optocont = sem_reward_distance_optocont;

    output.mean_reward_distance_optotarg = mean_reward_distance_optotarg;
    output.median_reward_distance_optotarg = median_reward_distance_optotarg;
    output.sem_reward_distance_optotarg = sem_reward_distance_optotarg;

    output.mean_reward_distance_short_optocont = mean_reward_distance_short_optocont;
    output.median_reward_distance_short_optocont = median_reward_distance_short_optocont;
    output.sem_reward_distance_short_optocont = sem_reward_distance_short_optocont;
    
    output.mean_reward_distance_medium_optocont = mean_reward_distance_medium_optocont;
    output.median_reward_distance_medium_optocont = median_reward_distance_medium_optocont;
    output.sem_reward_distance_medium_optocont = sem_reward_distance_medium_optocont;
    
    output.mean_reward_distance_long_optocont = mean_reward_distance_long_optocont;
    output.median_reward_distance_long_optocont = median_reward_distance_long_optocont;
    output.sem_reward_distance_long_optocont = sem_reward_distance_long_optocont;

    output.mean_reward_distance_short_optotarg = mean_reward_distance_short_optotarg;
    output.median_reward_distance_short_optotarg = median_reward_distance_short_optotarg;
    output.sem_reward_distance_short_optotarg = sem_reward_distance_short_optotarg;
    
    output.mean_reward_distance_medium_optotarg = mean_reward_distance_medium_optotarg;
    output.median_reward_distance_medium_optotarg = median_reward_distance_medium_optotarg;
    output.sem_reward_distance_medium_optotarg = sem_reward_distance_medium_optotarg;
    
    output.mean_reward_distance_long_optotarg = mean_reward_distance_long_optotarg;
    output.median_reward_distance_long_optotarg = median_reward_distance_long_optotarg;
    output.sem_reward_distance_long_optotarg = sem_reward_distance_long_optotarg;

% % Restart Distances opto/control

	trials_opto_control_pretarget_error = trials_opto_control .* trials_pretarget_error;
	trials_opto_target_1_pretarget_error = trials_opto_target_1 .* trials_pretarget_error;

	trials_opto_control_pretarget_error_short = trials_opto_control_short .* trials_pretarget_error;
	trials_opto_control_pretarget_error_medium = trials_opto_control_medium .* trials_pretarget_error;
	trials_opto_control_pretarget_error_long = trials_opto_control_long .* trials_pretarget_error;

	trials_opto_target_1_pretarget_error_short = trials_opto_target_1_short .* trials_pretarget_error;
	trials_opto_target_1_pretarget_error_medium = trials_opto_target_1_medium .* trials_pretarget_error;
	trials_opto_target_1_pretarget_error_long = trials_opto_target_1_long .* trials_pretarget_error;

	trials_opto_control_pretarget_error_index = find(trials_opto_control_pretarget_error == 1);
	trials_opto_target_1_pretarget_error_index = find(trials_opto_target_1_pretarget_error == 1);
	trials_opto_control_pretarget_error_short_index = find(trials_opto_control_pretarget_error_short == 1);
	trials_opto_control_pretarget_error_medium_index = find(trials_opto_control_pretarget_error_medium == 1);
	trials_opto_control_pretarget_error_long_index = find(trials_opto_control_pretarget_error_long == 1);
	trials_opto_target_1_pretarget_error_short_index = find(trials_opto_target_1_pretarget_error_short == 1);
	trials_opto_target_1_pretarget_error_medium_index = find(trials_opto_target_1_pretarget_error_medium == 1);
	trials_opto_target_1_pretarget_error_long_index = find(trials_opto_target_1_pretarget_error_long == 1);


    mean_pretarget_error_distance_optocont = mean(pretarget_error_distance_percent(trials_opto_control_pretarget_error_index, 1), 'omitnan');   
    median_pretarget_error_distance_optocont = median(pretarget_error_distance_percent(trials_opto_control_pretarget_error_index, 1), 'omitnan');
    sem_pretarget_error_distance_optocont = (std(pretarget_error_distance_percent(trials_opto_control_pretarget_error_index, 1))/(sqrt(length(pretarget_error_distance_percent(trials_opto_control_pretarget_error_index, 1)))));
    
    mean_pretarget_error_distance_optotarg = mean(pretarget_error_distance_percent(trials_opto_target_1_pretarget_error_index, 1), 'omitnan');   
    median_pretarget_error_distance_optotarg = median(pretarget_error_distance_percent(trials_opto_target_1_pretarget_error_index, 1), 'omitnan');
    sem_pretarget_error_distance_optotarg = (std(pretarget_error_distance_percent(trials_opto_target_1_pretarget_error_index, 1))/(sqrt(length(pretarget_error_distance_percent(trials_opto_target_1_pretarget_error_index, 1)))));
    
    mean_pretarget_error_short_distance_optocont = mean(pretarget_error_distance(trials_opto_control_pretarget_error_short_index, 1), 'omitnan');   
    median_pretarget_error_short_distance_optocont = median(pretarget_error_distance(trials_opto_control_pretarget_error_short_index, 1), 'omitnan');
    sem_pretarget_error_short_distance_optocont = (std(pretarget_error_distance(trials_opto_control_pretarget_error_short_index, 1))/(sqrt(length(pretarget_error_distance(trials_opto_control_pretarget_error_short_index, 1)))));
        
    mean_pretarget_error_medium_distance_optocont = mean(pretarget_error_distance(trials_opto_control_pretarget_error_medium_index, 1), 'omitnan');   
    median_pretarget_error_medium_distance_optocont = median(pretarget_error_distance(trials_opto_control_pretarget_error_medium_index, 1), 'omitnan');
    sem_pretarget_error_medium_distance_optocont = (std(pretarget_error_distance(trials_opto_control_pretarget_error_medium_index, 1))/(sqrt(length(pretarget_error_distance(trials_opto_control_pretarget_error_medium_index, 1)))));
        
    mean_pretarget_error_long_distance_optocont = mean(pretarget_error_distance(trials_opto_control_pretarget_error_long_index, 1), 'omitnan');   
    median_pretarget_error_long_distance_optocont = median(pretarget_error_distance(trials_opto_control_pretarget_error_long_index, 1), 'omitnan');
    sem_pretarget_error_long_distance_optocont = (std(pretarget_error_distance(trials_opto_control_pretarget_error_long_index, 1))/(sqrt(length(pretarget_error_distance(trials_opto_control_pretarget_error_long_index, 1)))));
        
    mean_pretarget_error_short_distance_optotarg = mean(pretarget_error_distance(trials_opto_target_1_pretarget_error_short_index, 1), 'omitnan');   
    median_pretarget_error_short_distance_optotarg = median(pretarget_error_distance(trials_opto_target_1_pretarget_error_short_index, 1), 'omitnan');
    sem_pretarget_error_short_distance_optotarg = (std(pretarget_error_distance(trials_opto_target_1_pretarget_error_short_index, 1))/(sqrt(length(pretarget_error_distance(trials_opto_target_1_pretarget_error_short_index, 1)))));
        
    mean_pretarget_error_medium_distance_optotarg = mean(pretarget_error_distance(trials_opto_target_1_pretarget_error_medium_index, 1), 'omitnan');   
    median_pretarget_error_medium_distance_optotarg = median(pretarget_error_distance(trials_opto_target_1_pretarget_error_medium_index, 1), 'omitnan');
    sem_pretarget_error_medium_distance_optotarg = (std(pretarget_error_distance(trials_opto_target_1_pretarget_error_medium_index, 1))/(sqrt(length(pretarget_error_distance(trials_opto_target_1_pretarget_error_medium_index, 1)))));
        
    mean_pretarget_error_long_distance_optotarg = mean(pretarget_error_distance(trials_opto_target_1_pretarget_error_long_index, 1), 'omitnan');   
    median_pretarget_error_long_distance_optotarg = median(pretarget_error_distance(trials_opto_target_1_pretarget_error_long_index, 1), 'omitnan');
    sem_pretarget_error_long_distance_optotarg = (std(pretarget_error_distance(trials_opto_target_1_pretarget_error_long_index, 1))/(sqrt(length(pretarget_error_distance(trials_opto_target_1_pretarget_error_long_index, 1)))));
          


    
	output.pretarget_error_distance_optocont = pretarget_error_distance_percent(trials_opto_control_pretarget_error_index, 1);
	output.pretarget_error_distance_optotarg = pretarget_error_distance_percent(trials_opto_target_1_pretarget_error_index, 1);
	output.pretarget_error_short_distance_optocont = pretarget_error_distance(trials_opto_control_pretarget_error_short_index, 1);
	output.pretarget_error_medium_distance_optocont = pretarget_error_distance(trials_opto_control_pretarget_error_medium_index, 1);
	output.pretarget_error_long_distance_optocont = pretarget_error_distance(trials_opto_control_pretarget_error_long_index, 1);
	output.pretarget_error_short_distance_optotarg = pretarget_error_distance(trials_opto_target_1_pretarget_error_short_index, 1);
	output.pretarget_error_medium_distance_optotarg = pretarget_error_distance(trials_opto_target_1_pretarget_error_medium_index, 1);
	output.pretarget_error_long_distance_optotarg = pretarget_error_distance(trials_opto_target_1_pretarget_error_long_index, 1);

	output.mean_pretarget_error_distance_optocont = mean_pretarget_error_distance_optocont;
	output.median_pretarget_error_distance_optocont = median_pretarget_error_distance_optocont;
	output.sem_pretarget_error_distance_optocont = sem_pretarget_error_distance_optocont;

	output.mean_pretarget_error_distance_optotarg = mean_pretarget_error_distance_optotarg;
	output.median_pretarget_error_distance_optotarg = median_pretarget_error_distance_optotarg;
	output.sem_pretarget_error_distance_optotarg = sem_pretarget_error_distance_optotarg;

	output.mean_pretarget_error_short_distance_optocont = mean_pretarget_error_short_distance_optocont;
	output.median_pretarget_error_short_distance_optocont = median_pretarget_error_short_distance_optocont;
	output.sem_pretarget_error_short_distance_optocont = sem_pretarget_error_short_distance_optocont;
	output.mean_pretarget_error_short_distance_optotarg = mean_pretarget_error_short_distance_optotarg;
	output.median_pretarget_error_short_distance_optotarg = median_pretarget_error_short_distance_optotarg;
	output.sem_pretarget_error_short_distance_optotarg = sem_pretarget_error_short_distance_optotarg;

	output.mean_pretarget_error_medium_distance_optocont = mean_pretarget_error_medium_distance_optocont;
	output.median_pretarget_error_medium_distance_optocont = median_pretarget_error_medium_distance_optocont;
	output.sem_pretarget_error_medium_distance_optocont = sem_pretarget_error_medium_distance_optocont;
	output.mean_pretarget_error_medium_distance_optotarg = mean_pretarget_error_medium_distance_optotarg;
	output.median_pretarget_error_medium_distance_optotarg = median_pretarget_error_medium_distance_optotarg;
	output.sem_pretarget_error_medium_distance_optotarg = sem_pretarget_error_medium_distance_optotarg;

	output.mean_pretarget_error_long_distance_optocont = mean_pretarget_error_long_distance_optocont;
	output.median_pretarget_error_long_distance_optocont = median_pretarget_error_long_distance_optocont;
	output.sem_pretarget_error_long_distance_optocont = sem_pretarget_error_long_distance_optocont;
	output.mean_pretarget_error_long_distance_optotarg = mean_pretarget_error_long_distance_optotarg;
	output.median_pretarget_error_long_distance_optotarg = median_pretarget_error_long_distance_optotarg;
	output.sem_pretarget_error_long_distance_optotarg = sem_pretarget_error_long_distance_optotarg;



% %     
% %  % Fit slowdown to exponential decay opto/control (might need to make sure
% %  % this is actually a helpful analysis)
% %    
% %     optocont_slow = nanmean(slowdown_only_velocities_smooth_mean_time(trials_opto_control_index, :))';
% %     optotarg_slow = nanmean(slowdown_only_velocities_smooth_mean_time(trials_opto_target_index, :))';
% %  
% % 
% %     if  length(optocont_slow) > 3
% % 
% %     xxx = [1:length(optocont_slow)]';
% %     optocont_slow_fit = fit(xxx, optocont_slow, 'poly2');
% %     
% %            figure(8)
% %                hold on
% %                plot(optocont_slow);
% % 
% %                plot(optocont_slow_fit);
% %                %plot(G);           
% %                legend('all control trials','fitted curve')
% %                axis ([-inf inf 0 600]);
% %                 title 'Average Slowdown Trajectories Opto Control Rescaled by Time'
% %                 xlabel('Normalized Percent Time to Target') 
% %                 ylabel('Mean Velocity (cm/s)') 
% %               
% %            hold off    
% %     
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'SlowdownFit_optocont_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all   
% % 
% %     % Save output
% % 
% %         output.slowdown_fit_parameters_optocont = optocont_slow_fit;
% %         output.slowdown_average_vel_data_optocont = optocont_slow;
% % 
% %     else
% %         output.slowdown_fit_parameters_optocont = NaN;
% %         output.slowdown_average_vel_data_optocont = NaN; 
% % 
% %     end        
% % 
% % 
% %     if  length(optotarg_slow) > 3
% % 
% %     yyy = [1:length(optotarg_slow)]';
% %     optotarg_slow_fit = fit(yyy, optotarg_slow, 'poly2');
% %     
% %            figure(8)
% %                hold on
% %                plot(optotarg_slow);
% % 
% %                plot(optotarg_slow_fit);
% %                %plot(G);           
% %                legend('all opto trials','fitted curve')
% %                axis ([-inf inf 0 600]);
% %                 title 'Average Slowdown Trajectories Light On Trials Rescaled by Time'
% %                 xlabel('Normalized Percent Time to Target') 
% %                 ylabel('Mean Velocity (cm/s)') 
% %               
% %            hold off    
% %     
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'SlowdownFit_optotarg_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all   
% % 
% %     % Save output
% % 
% %         output.slowdown_fit_parameters_optotarg = optotarg_slow_fit;
% %         output.slowdown_average_vel_data_optotarg = optotarg_slow;
% % 
% %     else
% %         output.slowdown_fit_parameters_optotarg = NaN;
% %         output.slowdown_average_vel_data_optotarg = NaN; 
% % 
% %     end  
% %     
% % % Opto duration data
% %     opto_over_1_sec = opto_duration >= 1;
% %     opto_under_1_sec = opto_duration < 1;
% % 
% %     opto_over_1_sec_index = find(opto_duration >= 1);
% %     opto_under_1_sec_index = find(opto_duration < 1);
% %     
% %    figure(20)
% %    hold on
% %    histogram(opto_duration)
% %    
% %            % Save Fig file to computer 
% % 
% %             [Where] = Where_file(filename);
% %             SaveName = [strcat(Where, 'Opto_duration_histogram_', date, '_', num)];
% %             savefig(SaveName);
% % 
% %             close all   
% %             
% %  output.mean_opto_duration = nanmean(opto_duration);
% %  output.short_opto_proportion = size(opto_under_1_sec_index, 1) / (size(opto_under_1_sec_index, 1) + size(opto_over_1_sec_index, 1));
% % 
% % trials_opto_target_complete_1sec = opto_over_1_sec .* trials_opto_target_complete;
% % trials_opto_target_premature_1sec = opto_over_1_sec .* trials_opto_target_premature;
% % trials_opto_target_incomplete_slowdown_1sec = opto_over_1_sec .* trials_opto_target_incomplete_slowdown;
% % trials_opto_target_incomplete_running_1sec = opto_over_1_sec .* trials_opto_target_incomplete_running;
% % trials_opto_target_slowfail_1sec = opto_over_1_sec .* trials_opto_target_slowfail;
% % trials_opto_target_premature_slow_1sec = opto_over_1_sec .* trials_opto_target_premature_slow;
% % trials_opto_target_complete_short_1sec = opto_over_1_sec .* trials_opto_target_complete_short;
% % trials_opto_target_premature_short_1sec = opto_over_1_sec .* trials_opto_target_premature_short;
% % trials_opto_target_incomplete_slowdown_short_1sec = opto_over_1_sec .* trials_opto_target_incomplete_slowdown_short;
% % trials_opto_target_incomplete_running_short_1sec = opto_over_1_sec .* trials_opto_target_incomplete_running_short;
% % trials_opto_target_slowfail_short_1sec = opto_over_1_sec .* trials_opto_target_slowfail_short;
% % trials_opto_target_premature_slow_short_1sec = opto_over_1_sec .* trials_opto_target_premature_slow_short;
% % trials_opto_target_complete_medium_1sec = opto_over_1_sec .* trials_opto_target_complete_medium;
% % trials_opto_target_premature_medium_1sec = opto_over_1_sec .* trials_opto_target_premature_medium;
% % trials_opto_target_incomplete_slowdown_medium_1sec = opto_over_1_sec .* trials_opto_target_incomplete_slowdown_medium;
% % trials_opto_target_incomplete_running_medium_1sec = opto_over_1_sec .* trials_opto_target_incomplete_running_medium;
% % trials_opto_target_slowfail_medium_1sec = opto_over_1_sec .* trials_opto_target_slowfail_medium;
% % trials_opto_target_premature_slow_medium_1sec = opto_over_1_sec .* trials_opto_target_premature_slow_medium;
% % trials_opto_target_complete_long_1sec = opto_over_1_sec .* trials_opto_target_complete_long;
% % trials_opto_target_premature_long_1sec = opto_over_1_sec .* trials_opto_target_premature_long;
% % trials_opto_target_incomplete_slowdown_long_1sec = opto_over_1_sec .* trials_opto_target_incomplete_slowdown_long;
% % trials_opto_target_incomplete_running_long_1sec = opto_over_1_sec .* trials_opto_target_incomplete_running_long;
% % trials_opto_target_slowfail_long_1sec = opto_over_1_sec .* trials_opto_target_slowfail_long;
% % trials_opto_target_premature_slow_long_1sec = opto_over_1_sec .* trials_opto_target_premature_slow_long;
% % 
% % % Performance metrics for opto inhibiitons longer than one second
% %  
% % output.complete_opto_target_1sec = sum(trials_opto_target_complete_1sec);
% % output.premature_opto_target_1sec = sum(trials_opto_target_premature_1sec);
% % output.incomplete_slowdown_opto_target_1sec = sum(trials_opto_target_incomplete_slowdown_1sec);
% % output.incomplete_running_opto_target_1sec = sum(trials_opto_target_incomplete_running_1sec);
% % output.overrun_opto_target_1sec = sum(trials_opto_target_slowfail_1sec);
% % output.premature_slowdown_opto_target_1sec = sum(trials_opto_target_premature_slow_1sec);
% % output.total_opto_target_1sec = size(opto_over_1_sec_index, 1);
% % output.Performance_Percentage_opto_target_1sec = output.complete_opto_target_1sec / output.total_opto_target_1sec;
% % output.Performance_Percentage_2_opto_target_1sec = output.complete_opto_target_1sec / (output.total_opto_target_1sec - output.premature_opto_target_1sec);
% % output.Performance_Percentage_3_opto_target_1sec = output.complete_opto_target_1sec / (output.total_opto_target_1sec - output.premature_opto_target_1sec - output.incomplete_running_opto_target_1sec - output.premature_slowdown_opto_target_1sec);
% % 
% % % trials_opto_target_complete_index_1sec = find(trials_opto_target_complete_1sec == 1);
% % % trials_opto_target_complete_short_index_1sec = find(trials_opto_target_complete_short_1sec == 1);
% % % trials_opto_target_complete_medium_index_1sec = find(trials_opto_target_complete_medium_1sec == 1);
% % % trials_opto_target_complete_long_index_1sec = find(trials_opto_target_complete_long_1sec == 1);
% % 
% % % trials_opto_target_slowfail_index_1sec = find(trials_opto_target_slowfail_1sec == 1);
% % % trials_opto_target_incomplete_slowdown_index_1sec = find(trials_opto_target_incomplete_slowdown_1sec == 1);
% % 
% % 
% % trials_opto_target_complete_short_index_1sec = find(trials_opto_target_complete_short_1sec == 1);
% % trials_opto_target_complete_medium_index_1sec = find(trials_opto_target_complete_medium_1sec == 1);
% % trials_opto_target_complete_long_index_1sec = find(trials_opto_target_complete_long_1sec == 1);
% % 
% % trials_opto_target_incomplete_slowdown_short_index_1sec = find(trials_opto_target_incomplete_slowdown_short_1sec == 1);
% % trials_opto_target_incomplete_slowdown_medium_index_1sec = find(trials_opto_target_incomplete_slowdown_medium_1sec == 1);
% % trials_opto_target_incomplete_slowdown_long_index_1sec = find(trials_opto_target_incomplete_slowdown_long_1sec == 1);
% % 
% % trials_opto_target_incomplete_slowdown_index_1sec = find(trials_opto_target_incomplete_slowdown_1sec == 1);
% % 
% % % Rewarded Distances >1sec opto
% % 
% %     mean_reward_distance_short_optotarg_1sec = mean(reward_distance_mat(trials_opto_target_complete_short_index_1sec, 1));
% %     mean_reward_distance_medium_optotarg_1sec = mean(reward_distance_mat(trials_opto_target_complete_medium_index_1sec, 1));
% %     mean_reward_distance_long_optotarg_1sec = mean(reward_distance_mat(trials_opto_target_complete_long_index_1sec, 1));
% %     
% %     median_reward_distance_short_optotarg_1sec = median(reward_distance_mat(trials_opto_target_complete_short_index_1sec, 1));
% %     median_reward_distance_medium_optotarg_1sec = median(reward_distance_mat(trials_opto_target_complete_medium_index_1sec, 1));
% %     median_reward_distance_long_optotarg_1sec = median(reward_distance_mat(trials_opto_target_complete_long_index_1sec, 1));
% %     
% %     sem_reward_distance_short_optotarg_1sec = (std(reward_distance_mat(trials_opto_target_complete_short_index_1sec, 1))/(sqrt(length(reward_distance_mat(trials_opto_target_complete_short_index_1sec, 1)))));
% %     sem_reward_distance_medium_optotarg_1sec = (std(reward_distance_mat(trials_opto_target_complete_medium_index_1sec, 1))/(sqrt(length(reward_distance_mat(trials_opto_target_complete_medium_index_1sec, 1)))));
% %     sem_reward_distance_long_optotarg_1sec = (std(reward_distance_mat(trials_opto_target_complete_long_index_1sec, 1))/(sqrt(length(reward_distance_mat(trials_opto_target_complete_long_index_1sec, 1)))));
% %     
% %     output.mean_reward_distance_short_optotarg_1sec = mean_reward_distance_short_optotarg_1sec;
% %     output.median_reward_distance_short_optotarg_1sec = median_reward_distance_short_optotarg_1sec;
% %     output.sem_reward_distance_short_optotarg_1sec = sem_reward_distance_short_optotarg_1sec;
% %     
% %     output.mean_reward_distance_medium_optotarg_1sec = mean_reward_distance_medium_optotarg_1sec;
% %     output.median_reward_distance_medium_optotarg_1sec = median_reward_distance_medium_optotarg_1sec;
% %     output.sem_reward_distance_medium_optotarg_1sec = sem_reward_distance_medium_optotarg_1sec;
% %     
% %     output.mean_reward_distance_long_optotarg_1sec = mean_reward_distance_long_optotarg_1sec;
% %     output.median_reward_distance_long_optotarg_1sec = median_reward_distance_long_optotarg_1sec;
% %     output.sem_reward_distance_long_optotarg_1sec = sem_reward_distance_long_optotarg_1sec;
% % 
% % % Restart Distances >1sec opto
% % 
% %     mean_incomplete_slowdown_distance_optotarg_1sec = mean(incomplete_slowdown_distances_norm(trials_opto_target_incomplete_slowdown_index_1sec, 1));   
% %     median_incomplete_slowdown_distance_optotarg_1sec = median(incomplete_slowdown_distances_norm(trials_opto_target_incomplete_slowdown_index_1sec, 1));
% %     sem_incomplete_slowdown_distance_optotarg_1sec = (std(incomplete_slowdown_distances_norm(trials_opto_target_incomplete_slowdown_index_1sec, 1))/(sqrt(length(incomplete_slowdown_distances_norm(trials_opto_target_incomplete_slowdown_index_1sec, 1)))));
% %     
% %     output.mean_incomplete_slowdown_distance_optotarg_1sec = mean_incomplete_slowdown_distance_optotarg_1sec;
% %     output.median_incomplete_slowdown_distance_optotarg_1sec = median_incomplete_slowdown_distance_optotarg_1sec;
% %     output.sem_incomplete_slowdown_distance_optotarg_1sec = sem_incomplete_slowdown_distance_optotarg_1sec;
% %     
% % % Heatmap
% % 
% % x = size(trials_opto_target_complete_short_index_1sec, 1);
% % y = size(trials_opto_target_complete_medium_index_1sec, 1);
% % z = size(trials_opto_target_complete_long_index_1sec, 1);
% % 
% % heatmap_data_time_short_opto_target_1sec(1:x, :) = movement_velocities_smooth_mean_time(trials_opto_target_complete_short_index_1sec, :); 
% % heatmap_data_time_medium_opto_target_1sec(1:y, :) = movement_velocities_smooth_mean_time(trials_opto_target_complete_medium_index_1sec, :); 
% % heatmap_data_time_long_opto_target_1sec(1:z, :) = movement_velocities_smooth_mean_time(trials_opto_target_complete_long_index_1sec, :); 
% % 
% % heatmap_time_data_opto_target_1sec = [heatmap_data_time_short_opto_target_1sec; heatmap_data_time_medium_opto_target_1sec; heatmap_data_time_long_opto_target_1sec];
% % 
% % figure(22)
% % heatmap(heatmap_time_data_opto_target_1sec, 'Colormap', jet, 'ColorLimits',[0 800])
% % 
% % % Save Fig file to computer 
% % 
% %                 [Where] = Where_file(filename);
% %                 SaveName = [strcat(Where, 'VelocityHeatmap_time_optotarget_1sec_', date, '_', num)];
% %                 savefig(SaveName);
% % 
% %                 close all    
% % 
% % % Rewarded times opto/control
% % 
% %     % All trials
% % 
% %     mean_reward_time_optocont = mean(reward_time(trials_opto_control_complete_index, 3));
% %     median_reward_time_optocont = median(reward_time(trials_opto_control_complete_index, 3));
% %     sem_reward_time_optocont = (std(reward_time(trials_opto_control_complete_index, 3))/(sqrt(length(reward_time(trials_opto_control_complete_index, 3)))));
% %        
% %     mean_reward_time_optotarg = mean(reward_time(trials_opto_target_complete_index, 3));
% %     median_reward_time_optotarg = median(reward_time(trials_opto_target_complete_index, 3));
% %     sem_reward_time_optotarg = (std(reward_time(trials_opto_target_complete_index, 3))/(sqrt(length(reward_time(trials_opto_target_complete_index, 3)))));
% % 
% %     output.mean_reward_time_optocont = mean_reward_time_optocont;
% %     output.mean_reward_time_optotarg = mean_reward_time_optotarg;
% %     
% %     output.median_reward_time_optocont = median_reward_time_optocont;
% %     output.median_reward_time_optotarg = median_reward_time_optotarg;
% %     
% %     output.sem_reward_time_optocont = sem_reward_time_optocont;
% %     output.sem_reward_time_optotarg = sem_reward_time_optotarg;    
% % 
% %     % By Trial Distance
% % 
% %     mean_reward_time_short_optocont = mean(reward_time(trials_opto_control_complete_short_index, 3));
% %     mean_reward_time_medium_optocont = mean(reward_time(trials_opto_control_complete_medium_index, 3));
% %     mean_reward_time_long_optocont = mean(reward_time(trials_opto_control_complete_long_index, 3));
% %     
% %     median_reward_time_short_optocont = median(reward_time(trials_opto_control_complete_short_index, 3));
% %     median_reward_time_medium_optocont = median(reward_time(trials_opto_control_complete_medium_index, 3));
% %     median_reward_time_long_optocont = median(reward_time(trials_opto_control_complete_long_index, 3));
% %     
% %     sem_reward_time_short_optocont = (std(reward_time(trials_opto_control_complete_short_index, 3))/(sqrt(length(reward_time(trials_opto_control_complete_short_index, 3)))));
% %     sem_reward_time_medium_optocont = (std(reward_time(trials_opto_control_complete_medium_index, 3))/(sqrt(length(reward_time(trials_opto_control_complete_medium_index, 3)))));
% %     sem_reward_time_long_optocont = (std(reward_time(trials_opto_control_complete_long_index, 3))/(sqrt(length(reward_time(trials_opto_control_complete_long_index, 3)))));
% %     
% %     output.mean_reward_time_short_optocont = mean_reward_time_short_optocont;
% %     output.median_reward_time_short_optocont = median_reward_time_short_optocont;
% %     output.sem_reward_time_short_optocont = sem_reward_time_short_optocont;
% %     
% %     output.mean_reward_time_medium_optocont = mean_reward_time_medium_optocont;
% %     output.median_reward_time_medium_optocont = median_reward_time_medium_optocont;
% %     output.sem_reward_time_medium_optocont = sem_reward_time_medium_optocont;
% %     
% %     output.mean_reward_time_long_optocont = mean_reward_time_long_optocont;
% %     output.median_reward_time_long_optocont = median_reward_time_long_optocont;
% %     output.sem_reward_time_long_optocont = sem_reward_time_long_optocont;
% % 
% % 
% % 
% %     mean_reward_time_short_optotarg = mean(reward_time(trials_opto_target_complete_short_index, 3));
% %     mean_reward_time_medium_optotarg = mean(reward_time(trials_opto_target_complete_medium_index, 3));
% %     mean_reward_time_long_optotarg = mean(reward_time(trials_opto_target_complete_long_index, 3));
% %     
% %     median_reward_time_short_optotarg = median(reward_time(trials_opto_target_complete_short_index, 3));
% %     median_reward_time_medium_optotarg = median(reward_time(trials_opto_target_complete_medium_index, 3));
% %     median_reward_time_long_optotarg = median(reward_time(trials_opto_target_complete_long_index, 3));
% %     
% %     sem_reward_time_short_optotarg = (std(reward_time(trials_opto_target_complete_short_index, 3))/(sqrt(length(reward_time(trials_opto_target_complete_short_index, 3)))));
% %     sem_reward_time_medium_optotarg = (std(reward_time(trials_opto_target_complete_medium_index, 3))/(sqrt(length(reward_time(trials_opto_target_complete_medium_index, 3)))));
% %     sem_reward_time_long_optotarg = (std(reward_time(trials_opto_target_complete_long_index, 3))/(sqrt(length(reward_time(trials_opto_target_complete_long_index, 3)))));
% %     
% %     output.mean_reward_time_short_optotarg = mean_reward_time_short_optotarg;
% %     output.median_reward_time_short_optotarg = median_reward_time_short_optotarg;
% %     output.sem_reward_time_short_optotarg = sem_reward_time_short_optotarg;
% %     
% %     output.mean_reward_time_medium_optotarg = mean_reward_time_medium_optotarg;
% %     output.median_reward_time_medium_optotarg = median_reward_time_medium_optotarg;
% %     output.sem_reward_time_medium_optotarg = sem_reward_time_medium_optotarg;
% %     
% %     output.mean_reward_time_long_optotarg = mean_reward_time_long_optotarg;
% %     output.median_reward_time_long_optotarg = median_reward_time_long_optotarg;
% %     output.sem_reward_time_long_optotarg = sem_reward_time_long_optotarg;
% %  
% %  % Performance medium and long combined
% %     output.complete_medlong_opto_control = output.complete_medium_opto_control + output.complete_long_opto_control;
% %     output.total_medlong_opto_control = output.total_medium_opto_control + output.total_long_opto_control;
% %     output.premature_medlong_opto_control = output.premature_medium_opto_control + output.premature_long_opto_control;
% %     output.incomplete_running_opto_control_medlong = output.incomplete_running_opto_control_medium + output.incomplete_running_opto_control_long;
% %     output.premature_slowdown_opto_control_medlong = output.premature_slowdown_opto_control_medium + output.premature_slowdown_opto_control_long;
% %     output.overrun_opto_control_medlong = output.overrun_opto_control_medium + output.overrun_opto_control_long;
% %     output.incomplete_slowdown_opto_control_medlong = output.incomplete_slowdown_opto_control_medium + output.incomplete_slowdown_opto_control_long;
% % 
% %     output.complete_medlong_opto_target = output.complete_medium_opto_target + output.complete_long_opto_target;
% %     output.total_medlong_opto_target = output.total_medium_opto_target + output.total_long_opto_target;
% %     output.premature_medlong_opto_target = output.premature_medium_opto_target + output.premature_long_opto_target;
% %     output.incomplete_running_opto_target_medlong = output.incomplete_running_opto_target_medium + output.incomplete_running_opto_target_long;
% %     output.premature_slowdown_opto_target_medlong = output.premature_slowdown_opto_target_medium + output.premature_slowdown_opto_target_long;
% %     output.overrun_opto_target_medlong = output.overrun_opto_target_medium + output.overrun_opto_target_long;
% %     output.incomplete_slowdown_opto_target_medlong = output.incomplete_slowdown_opto_target_medium + output.incomplete_slowdown_opto_target_long;
% % 
% %     output.Performance_Percentage_3_medlong_opto_control = output.complete_medlong_opto_control / (output.total_medlong_opto_control - output.premature_medlong_opto_control - output.incomplete_running_opto_control_medlong - output.premature_slowdown_opto_control_medlong);
% %     output.Performance_Percentage_3_medlong_opto_target = output.complete_medlong_opto_target / (output.total_medlong_opto_target - output.premature_medlong_opto_target - output.incomplete_running_opto_target_medlong - output.premature_slowdown_opto_target_medlong);
% % 
% %     output.total_opto_slowdown_control_short = output.total_short_opto_control - (output.incomplete_running_opto_control_short + output.premature_slowdown_opto_control_short); 
% % output.total_opto_slowdown_target_short = output.total_short_opto_target - (output.incomplete_running_opto_target_short + output.premature_slowdown_opto_target_short); 
% % output.total_opto_slowdown_control_medlong = output.total_medlong_opto_control - (output.incomplete_running_opto_control_medlong + output.premature_slowdown_opto_control_medlong); 
% % output.total_opto_slowdown_target_medlong = output.total_medlong_opto_target - (output.incomplete_running_opto_target_medlong + output.premature_slowdown_opto_target_medlong); 
% % 
% % output.overrun_rate_opto_control_short = output.overrun_opto_control_short ./ output.total_opto_slowdown_control_short;
% % output.overrun_rate_opto_target_short = output.overrun_opto_target_short ./ output.total_opto_slowdown_target_short;
% % 
% % output.overrun_rate_opto_control_medlong = output.overrun_opto_control_medlong ./ output.total_opto_slowdown_control_medlong;
% % output.overrun_rate_opto_target_medlong = output.overrun_opto_target_medlong ./ output.total_opto_slowdown_target_medlong;
% % 
% % output.incomplete_slowdown_rate_opto_control_short = output.incomplete_slowdown_opto_control_short ./ output.total_opto_slowdown_control_short;
% % output.incomplete_slowdown_rate_opto_target_short = output.incomplete_slowdown_opto_target_short ./ output.total_opto_slowdown_target_short;
% % 
% % output.incomplete_slowdown_rate_opto_control_medlong = output.incomplete_slowdown_opto_control_medlong ./ output.total_opto_slowdown_control_medlong;
% % output.incomplete_slowdown_rate_opto_target_medlong = output.incomplete_slowdown_opto_target_medlong ./ output.total_opto_slowdown_target_medlong;
% 
% % output.reward_rate = output.Complete_Trials / output.session_duration;
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% % Analysis to control for premature slowdown effect
% 
%     trials_opto_target_1_premature_slow_index = find(trials_opto_target_1_premature_slow == 1);
%     
%     output.mean_opto_target_1_duration_pre_slow = nanmean(opto_duration_1(trials_opto_target_1_premature_slow_index, 1));
%     
%     output.mean_opto_target_1_duration = nanmean(opto_duration_1(:, 1));
%     output.mean_opto_target_2_duration = nanmean(opto_duration_2(:, 1));
%     
%     mean_vel_opto_control_1 = nanmean(movement_velocities_smooth_mean_dist(trials_opto_control_1_index, :));
%     output.mean_vel_opto_control_1_slow = mean(mean_vel_opto_control_1(1, 40:100));
%      
%     mean_vel_opto_target_1 = nanmean(movement_velocities_smooth_mean_dist(trials_opto_target_1_index, :));
%     output.mean_vel_opto_target_1_slow = mean(mean_vel_opto_target_1(1, 40:100));
%     
%     mean_vel_opto_control_2 = nanmean(movement_velocities_smooth_mean_dist(trials_opto_control_2_index, :));
%     output.mean_vel_opto_control_2_slow = mean(mean_vel_opto_control_2(1, 80:120));
%      
%     mean_vel_opto_target_2 = nanmean(movement_velocities_smooth_mean_dist(trials_opto_target_2_index, :));
%     output.mean_vel_opto_target_2_slow = mean(mean_vel_opto_target_2(1, 80:120));
% 
% % Distance to RW for each trial type
% 
%     % All distances
% 
%         trials_opto_control_1_complete_index = find(trials_opto_control_1_complete == 1);
%         trials_opto_target_1_complete_index = find(trials_opto_target_1_complete == 1);
%         trials_opto_control_2_complete_index = find(trials_opto_control_2_complete == 1);
%         trials_opto_target_2_complete_index = find(trials_opto_target_2_complete == 1);
% 
%         output.RW_distances_opto_control_1 = reward_distance(trials_opto_control_1_complete_index, 1);
%         output.RW_distances_opto_target_1 = reward_distance(trials_opto_target_1_complete_index, 1);
%         output.RW_distances_opto_control_2 = reward_distance(trials_opto_control_2_complete_index, 1);
%         output.RW_distances_opto_target_2 = reward_distance(trials_opto_target_2_complete_index, 1);
% 
%         trials_opto_control_1_complete_slow_index = find(trials_opto_control_1_complete_slow == 1);
%         trials_opto_target_1_complete_slow_index = find(trials_opto_target_1_complete_slow == 1);
%         trials_opto_control_2_complete_slow_index = find(trials_opto_control_2_complete_slow == 1);
%         trials_opto_target_2_complete_slow_index = find(trials_opto_target_2_complete_slow == 1);
% 
%         output.RW_distances_slow_opto_control_1 = reward_distance(trials_opto_control_1_complete_slow_index, 1);
%         output.RW_distances_slow_opto_target_1 = reward_distance(trials_opto_target_1_complete_slow_index, 1);
%         output.RW_distances_slow_opto_control_2 = reward_distance(trials_opto_control_2_complete_slow_index, 1);
%         output.RW_distances_slow_opto_target_2 = reward_distance(trials_opto_target_2_complete_slow_index, 1);
% 
%         trials_opto_control_1_complete_stop_index = find(trials_opto_control_1_complete_stop == 1);
%         trials_opto_target_1_complete_stop_index = find(trials_opto_target_1_complete_stop == 1);
%         trials_opto_control_2_complete_stop_index = find(trials_opto_control_2_complete_stop == 1);
%         trials_opto_target_2_complete_stop_index = find(trials_opto_target_2_complete_stop == 1);
% 
%         output.RW_distances_stop_opto_control_1 = reward_distance(trials_opto_control_1_complete_stop_index, 1);
%         output.RW_distances_stop_opto_target_1 = reward_distance(trials_opto_target_1_complete_stop_index, 1);
%         output.RW_distances_stop_opto_control_2 = reward_distance(trials_opto_control_2_complete_stop_index, 1);
%         output.RW_distances_stop_opto_target_2 = reward_distance(trials_opto_target_2_complete_stop_index, 1);
% 
%     % By trial distance
% 
%         trials_opto_control_1_complete_short_index = find(trials_opto_control_1_complete_short == 1);
%         trials_opto_target_1_complete_short_index = find(trials_opto_target_1_complete_short == 1);
%         trials_opto_control_2_complete_short_index = find(trials_opto_control_2_complete_short == 1);
%         trials_opto_target_2_complete_short_index = find(trials_opto_target_2_complete_short == 1);
% 
%         trials_opto_control_1_complete_medium_index = find(trials_opto_control_1_complete_medium == 1);
%         trials_opto_target_1_complete_medium_index = find(trials_opto_target_1_complete_medium == 1);
%         trials_opto_control_2_complete_medium_index = find(trials_opto_control_2_complete_medium == 1);
%         trials_opto_target_2_complete_medium_index = find(trials_opto_target_2_complete_medium == 1);
% 
%         trials_opto_control_1_complete_long_index = find(trials_opto_control_1_complete_long == 1);
%         trials_opto_target_1_complete_long_index = find(trials_opto_target_1_complete_long == 1);
%         trials_opto_control_2_complete_long_index = find(trials_opto_control_2_complete_long == 1);
%         trials_opto_target_2_complete_long_index = find(trials_opto_target_2_complete_long == 1);
% 
%         output.RW_distances_opto_control_1_short = reward_distance(trials_opto_control_1_complete_short_index, 1);
%         output.RW_distances_opto_target_1_short = reward_distance(trials_opto_target_1_complete_short_index, 1);
%         output.RW_distances_opto_control_1_medium = reward_distance(trials_opto_control_1_complete_medium_index, 1);
%         output.RW_distances_opto_target_1_medium = reward_distance(trials_opto_target_1_complete_medium_index, 1);
%         output.RW_distances_opto_control_1_long = reward_distance(trials_opto_control_1_complete_long_index, 1);
%         output.RW_distances_opto_target_1_long = reward_distance(trials_opto_target_1_complete_long_index, 1);
% 
%         output.RW_distances_opto_control_2_short = reward_distance(trials_opto_control_2_complete_short_index, 1);
%         output.RW_distances_opto_target_2_short = reward_distance(trials_opto_target_2_complete_short_index, 1);
%         output.RW_distances_opto_control_2_medium = reward_distance(trials_opto_control_2_complete_medium_index, 1);
%         output.RW_distances_opto_target_2_medium = reward_distance(trials_opto_target_2_complete_medium_index, 1);
%         output.RW_distances_opto_control_2_long = reward_distance(trials_opto_control_2_complete_long_index, 1);
%         output.RW_distances_opto_target_2_long = reward_distance(trials_opto_target_2_complete_long_index, 1);
% 
% 
%         output.Mean_RW_distances_opto_control_1_short = mean(output.RW_distances_opto_control_1_short);
%         output.Mean_RW_distances_opto_target_1_short = mean(output.RW_distances_opto_target_1_short);
%         output.Mean_RW_distances_opto_control_1_medium = mean(output.RW_distances_opto_control_1_medium);
%         output.Mean_RW_distances_opto_target_1_medium = mean(output.RW_distances_opto_target_1_medium);
%         output.Mean_RW_distances_opto_control_1_long = mean(output.RW_distances_opto_control_1_long);
%         output.Mean_RW_distances_opto_target_1_long = mean(output.RW_distances_opto_target_1_long);
%         output.Mean_RW_distances_opto_control_2_short = mean(output.RW_distances_opto_control_2_short);
%         output.Mean_RW_distances_opto_target_2_short = mean(output.RW_distances_opto_target_2_short);
%         output.Mean_RW_distances_opto_control_2_medium = mean(output.RW_distances_opto_control_2_medium);
%         output.Mean_RW_distances_opto_target_2_medium = mean(output.RW_distances_opto_target_2_medium);
%         output.Mean_RW_distances_opto_control_2_long = mean(output.RW_distances_opto_control_2_long);
%         output.Mean_RW_distances_opto_target_2_long = mean(output.RW_distances_opto_target_2_long);
% 
% %         RW_distances_opto_control_1_short_clean_index = find(output.RW_distances_opto_control_1_short > 1);
% %         RW_distances_opto_target_1_short_clean_index = find(output.RW_distances_opto_target_1_short > 1);
% %         RW_distances_opto_control_1_medium_clean_index = find(output.RW_distances_opto_control_1_medium > 1);
% %         RW_distances_opto_target_1_medium_clean_index = find(output.RW_distances_opto_target_1_medium > 1);
% %         RW_distances_opto_control_1_long_clean_index = find(output.RW_distances_opto_control_1_long > 1);
% %         RW_distances_opto_target_1_long_clean_index = find(output.RW_distances_opto_target_1_long > 1);
% %         RW_distances_opto_control_2_short_clean_index = find(output.RW_distances_opto_control_2_short > 1);
% %         RW_distances_opto_target_2_short_clean_index = find(output.RW_distances_opto_target_2_short > 1);
% %         RW_distances_opto_control_2_medium_clean_index = find(output.RW_distances_opto_control_2_medium > 1);
% %         RW_distances_opto_target_2_medium_clean_index = find(output.RW_distances_opto_target_2_medium > 1);
% %         RW_distances_opto_control_2_long_clean_index = find(output.RW_distances_opto_control_2_long > 1);
% %         RW_distances_opto_target_2_long_clean_index = find(output.RW_distances_opto_target_2_long > 1);
% % 
% % 
% % 
% % output.RW_distances_opto_control_1_short_clean = output.RW_distances_opto_control_1_short(RW_distances_opto_control_1_short_clean_index, 1);
% % output.RW_distances_opto_target_1_short_clean = output.RW_distances_opto_target_1_short(RW_distances_opto_target_1_short_clean_index, 1);
% % output.RW_distances_opto_control_1_medium_clean = output.RW_distances_opto_control_1_medium(RW_distances_opto_control_1_medium_clean_index, 1);
% % output.RW_distances_opto_target_1_medium_clean = output.RW_distances_opto_target_1_medium(RW_distances_opto_target_1_medium_clean_index, 1);
% % output.RW_distances_opto_control_1_long_clean = output.RW_distances_opto_control_1_long(RW_distances_opto_control_1_long_clean_index, 1);
% % output.RW_distances_opto_target_1_long_clean = output.RW_distances_opto_target_1_long(RW_distances_opto_target_1_long_clean_index, 1);
% % output.RW_distances_opto_control_2_short_clean = output.RW_distances_opto_control_2_short(RW_distances_opto_control_2_short_clean_index, 1);
% % output.RW_distances_opto_target_2_short_clean = output.RW_distances_opto_target_2_short(RW_distances_opto_target_2_short_clean_index, 1);
% % output.RW_distances_opto_control_2_medium_clean = output.RW_distances_opto_control_2_medium(RW_distances_opto_control_2_medium_clean_index, 1);
% % output.RW_distances_opto_target_2_medium_clean = output.RW_distances_opto_target_2_medium(RW_distances_opto_target_2_medium_clean_index, 1);
% % output.RW_distances_opto_control_2_long_clean = output.RW_distances_opto_control_2_long(RW_distances_opto_control_2_long_clean_index, 1);
% % output.RW_distances_opto_target_2_long_clean = output.RW_distances_opto_target_2_long(RW_distances_opto_target_2_long_clean_index, 1);
% % 
% % 
% % output.Mean_RW_distances_opto_control_1_short_clean = mean(output.RW_distances_opto_control_1_short_clean);
% % output.Mean_RW_distances_opto_target_1_short_clean = mean(output.RW_distances_opto_target_1_short_clean);
% % output.Mean_RW_distances_opto_control_1_medium_clean = mean(output.RW_distances_opto_control_1_medium_clean);
% % output.Mean_RW_distances_opto_target_1_medium_clean = mean(output.RW_distances_opto_target_1_medium_clean);
% % output.Mean_RW_distances_opto_control_1_long_clean = mean(output.RW_distances_opto_control_1_long_clean);
% % output.Mean_RW_distances_opto_target_1_long_clean = mean(output.RW_distances_opto_target_1_long_clean);
% % output.Mean_RW_distances_opto_control_2_short_clean = mean(output.RW_distances_opto_control_2_short_clean);
% % output.Mean_RW_distances_opto_target_2_short_clean = mean(output.RW_distances_opto_target_2_short_clean);
% % output.Mean_RW_distances_opto_control_2_medium_clean = mean(output.RW_distances_opto_control_2_medium_clean);
% % output.Mean_RW_distances_opto_target_2_medium_clean = mean(output.RW_distances_opto_target_2_medium_clean);
% % output.Mean_RW_distances_opto_control_2_long_clean = mean(output.RW_distances_opto_control_2_long_clean);
% % output.Mean_RW_distances_opto_target_2_long_clean = mean(output.RW_distances_opto_target_2_long_clean);
% 
% %         trials_opto_control_1_complete_slow_short_index = find(trials_opto_control_1_complete_slow_short == 1);
% %         trials_opto_target_1_complete_slow_short_index = find(trials_opto_target_1_complete_slow_short == 1);
% %         trials_opto_control_2_complete_slow_short_index = find(trials_opto_control_2_complete_slow_short == 1);
% %         trials_opto_target_2_complete_slow_short_index = find(trials_opto_target_2_complete_slow_short == 1);
% % 
% %         trials_opto_control_1_complete_slow_medium_index = find(trials_opto_control_1_complete_slow_medium == 1);
% %         trials_opto_target_1_complete_slow_medium_index = find(trials_opto_target_1_complete_slow_medium == 1);
% %         trials_opto_control_2_complete_slow_medium_index = find(trials_opto_control_2_complete_slow_medium == 1);
% %         trials_opto_target_2_complete_slow_medium_index = find(trials_opto_target_2_complete_slow_medium == 1);
% % 
% %         trials_opto_control_1_complete_slow_long_index = find(trials_opto_control_1_complete_slow_long == 1);
% %         trials_opto_target_1_complete_slow_long_index = find(trials_opto_target_1_complete_slow_long == 1);
% %         trials_opto_control_2_complete_slow_long_index = find(trials_opto_control_2_complete_slow_long == 1);
% %         trials_opto_target_2_complete_slow_long_index = find(trials_opto_target_2_complete_slow_long == 1);
% % 
% %         output.RW_distances_opto_control_1_slow_short = reward_distance(trials_opto_control_1_complete_slow_short_index, 1);
% %         output.RW_distances_opto_target_1_slow_short = reward_distance(trials_opto_target_1_complete_slow_short_index, 1);
% %         output.RW_distances_opto_control_1_slow_medium = reward_distance(trials_opto_control_1_complete_slow_medium_index, 1);
% %         output.RW_distances_opto_target_1_slow_medium = reward_distance(trials_opto_target_1_complete_slow_medium_index, 1);
% %         output.RW_distances_opto_control_1_slow_long = reward_distance(trials_opto_control_1_complete_slow_long_index, 1);
% %         output.RW_distances_opto_target_1_slow_long = reward_distance(trials_opto_target_1_complete_slow_long_index, 1);
% % 
% %         output.RW_distances_opto_control_2_slow_short = reward_distance(trials_opto_control_2_complete_slow_short_index, 1);
% %         output.RW_distances_opto_target_2_slow_short = reward_distance(trials_opto_target_2_complete_slow_short_index, 1);
% %         output.RW_distances_opto_control_2_slow_medium = reward_distance(trials_opto_control_2_complete_slow_medium_index, 1);
% %         output.RW_distances_opto_target_2_slow_medium = reward_distance(trials_opto_target_2_complete_slow_medium_index, 1);
% %         output.RW_distances_opto_control_2_slow_long = reward_distance(trials_opto_control_2_complete_slow_long_index, 1);
% %         output.RW_distances_opto_target_2_slow_long = reward_distance(trials_opto_target_2_complete_slow_long_index, 1);
% % 
% %         trials_opto_control_1_complete_stop_short_index = find(trials_opto_control_1_complete_stop_short == 1);
% %         trials_opto_target_1_complete_stop_short_index = find(trials_opto_target_1_complete_stop_short == 1);
% %         trials_opto_control_2_complete_stop_short_index = find(trials_opto_control_2_complete_stop_short == 1);
% %         trials_opto_target_2_complete_stop_short_index = find(trials_opto_target_2_complete_stop_short == 1);
% % 
% %         trials_opto_control_1_complete_stop_medium_index = find(trials_opto_control_1_complete_stop_medium == 1);
% %         trials_opto_target_1_complete_stop_medium_index = find(trials_opto_target_1_complete_stop_medium == 1);
% %         trials_opto_control_2_complete_stop_medium_index = find(trials_opto_control_2_complete_stop_medium == 1);
% %         trials_opto_target_2_complete_stop_medium_index = find(trials_opto_target_2_complete_stop_medium == 1);
% % 
% %         trials_opto_control_1_complete_stop_long_index = find(trials_opto_control_1_complete_stop_long == 1);
% %         trials_opto_target_1_complete_stop_long_index = find(trials_opto_target_1_complete_stop_long == 1);
% %         trials_opto_control_2_complete_stop_long_index = find(trials_opto_control_2_complete_stop_long == 1);
% %         trials_opto_target_2_complete_stop_long_index = find(trials_opto_target_2_complete_stop_long == 1);
% % 
% %         output.RW_distances_opto_control_1_stop_short = reward_distance(trials_opto_control_1_complete_stop_short_index, 1);
% %         output.RW_distances_opto_target_1_stop_short = reward_distance(trials_opto_target_1_complete_stop_short_index, 1);
% %         output.RW_distances_opto_control_1_stop_medium = reward_distance(trials_opto_control_1_complete_stop_medium_index, 1);
% %         output.RW_distances_opto_target_1_stop_medium = reward_distance(trials_opto_target_1_complete_stop_medium_index, 1);
% %         output.RW_distances_opto_control_1_stop_long = reward_distance(trials_opto_control_1_complete_stop_long_index, 1);
% %         output.RW_distances_opto_target_1_stop_long = reward_distance(trials_opto_target_1_complete_stop_long_index, 1);
% % 
% %         output.RW_distances_opto_control_2_stop_short = reward_distance(trials_opto_control_2_complete_stop_short_index, 1);
% %         output.RW_distances_opto_target_2_stop_short = reward_distance(trials_opto_target_2_complete_stop_short_index, 1);
% %         output.RW_distances_opto_control_2_stop_medium = reward_distance(trials_opto_control_2_complete_stop_medium_index, 1);
% %         output.RW_distances_opto_target_2_stop_medium = reward_distance(trials_opto_target_2_complete_stop_medium_index, 1);
% %         output.RW_distances_opto_control_2_stop_long = reward_distance(trials_opto_control_2_complete_stop_long_index, 1);
% %         output.RW_distances_opto_target_2_stop_long = reward_distance(trials_opto_target_2_complete_stop_long_index, 1);
% 
% 
% % Distance to mait fail for each trial type
% 
%     % All distances
% 
%         trials_opto_control_1_premature_slow_index = find(trials_opto_control_1_premature_slow == 1);
%         trials_opto_target_1_premature_slow_index = find(trials_opto_target_1_premature_slow == 1);
%         trials_opto_control_2_premature_slow_index = find(trials_opto_control_2_premature_slow == 1);
%         trials_opto_target_2_premature_slow_index = find(trials_opto_target_2_premature_slow == 1);
% 
%         output.preslow_distances_opto_control_1 = premature_slow_distance(trials_opto_control_1_premature_slow_index, 1);
%         output.preslow_distances_opto_target_1 = premature_slow_distance(trials_opto_target_1_premature_slow_index, 1);
%         output.preslow_distances_opto_control_2 = premature_slow_distance(trials_opto_control_2_premature_slow_index, 1);
%         output.preslow_distances_opto_target_2 = premature_slow_distance(trials_opto_target_2_premature_slow_index, 1);
% 
%     % By trial distance
% 
%         trials_opto_control_1_premature_slow_short_index = find(trials_opto_control_1_premature_slow_short == 1);
%         trials_opto_target_1_premature_slow_short_index = find(trials_opto_target_1_premature_slow_short == 1);
%         trials_opto_control_2_premature_slow_short_index = find(trials_opto_control_2_premature_slow_short == 1);
%         trials_opto_target_2_premature_slow_short_index = find(trials_opto_target_2_premature_slow_short == 1);
% 
%         trials_opto_control_1_premature_slow_medium_index = find(trials_opto_control_1_premature_slow_medium == 1);
%         trials_opto_target_1_premature_slow_medium_index = find(trials_opto_target_1_premature_slow_medium == 1);
%         trials_opto_control_2_premature_slow_medium_index = find(trials_opto_control_2_premature_slow_medium == 1);
%         trials_opto_target_2_premature_slow_medium_index = find(trials_opto_target_2_premature_slow_medium == 1);
% 
%         trials_opto_control_1_premature_slow_long_index = find(trials_opto_control_1_premature_slow_long == 1);
%         trials_opto_target_1_premature_slow_long_index = find(trials_opto_target_1_premature_slow_long == 1);
%         trials_opto_control_2_premature_slow_long_index = find(trials_opto_control_2_premature_slow_long == 1);
%         trials_opto_target_2_premature_slow_long_index = find(trials_opto_target_2_premature_slow_long == 1);
% 
%         output.preslow_distances_opto_control_1_short = premature_slow_distance(trials_opto_control_1_premature_slow_short_index, 1);
%         output.preslow_distances_opto_target_1_short = premature_slow_distance(trials_opto_target_1_premature_slow_short_index, 1);
%         output.preslow_distances_opto_control_1_medium = premature_slow_distance(trials_opto_control_1_premature_slow_medium_index, 1);
%         output.preslow_distances_opto_target_1_medium = premature_slow_distance(trials_opto_target_1_premature_slow_medium_index, 1);
%         output.preslow_distances_opto_control_1_long = premature_slow_distance(trials_opto_control_1_premature_slow_long_index, 1);
%         output.preslow_distances_opto_target_1_long = premature_slow_distance(trials_opto_target_1_premature_slow_long_index, 1);
% 
%         output.preslow_distances_opto_control_2_short = premature_slow_distance(trials_opto_control_2_premature_slow_short_index, 1);
%         output.preslow_distances_opto_target_2_short = premature_slow_distance(trials_opto_target_2_premature_slow_short_index, 1);
%         output.preslow_distances_opto_control_2_medium = premature_slow_distance(trials_opto_control_2_premature_slow_medium_index, 1);
%         output.preslow_distances_opto_target_2_medium = premature_slow_distance(trials_opto_target_2_premature_slow_medium_index, 1);
%         output.preslow_distances_opto_control_2_long = premature_slow_distance(trials_opto_control_2_premature_slow_long_index, 1);
%         output.preslow_distances_opto_target_2_long = premature_slow_distance(trials_opto_target_2_premature_slow_long_index, 1);
% 
% output.Mean_preslow_distances_opto_control_1_short = mean(output.preslow_distances_opto_control_1_short);
% output.Mean_preslow_distances_opto_target_1_short = mean(output.preslow_distances_opto_target_1_short);
% output.Mean_preslow_distances_opto_control_1_medium = mean(output.preslow_distances_opto_control_1_medium);
% output.Mean_preslow_distances_opto_target_1_medium = mean(output.preslow_distances_opto_target_1_medium);
% output.Mean_preslow_distances_opto_control_1_long = mean(output.preslow_distances_opto_control_1_long);
% output.Mean_preslow_distances_opto_target_1_long = mean(output.preslow_distances_opto_target_1_long);
% output.Mean_preslow_distances_opto_control_2_short = mean(output.preslow_distances_opto_control_2_short);
% output.Mean_preslow_distances_opto_target_2_short = mean(output.preslow_distances_opto_target_2_short);
% output.Mean_preslow_distances_opto_control_2_medium = mean(output.preslow_distances_opto_control_2_medium);
% output.Mean_preslow_distances_opto_target_2_medium = mean(output.preslow_distances_opto_target_2_medium);
% output.Mean_preslow_distances_opto_control_2_long = mean(output.preslow_distances_opto_control_2_long);
% output.Mean_preslow_distances_opto_target_2_long = mean(output.preslow_distances_opto_target_2_long);
% 
% % Distance to running period stop for each trial type
% 
%     % All distances
% 
%         trials_opto_control_1_incomplete_running_index = find(trials_opto_control_1_incomplete_running == 1);
%         trials_opto_target_1_incomplete_running_index = find(trials_opto_target_1_incomplete_running == 1);
%         trials_opto_control_2_incomplete_running_index = find(trials_opto_control_2_incomplete_running == 1);
%         trials_opto_target_2_incomplete_running_index = find(trials_opto_target_2_incomplete_running == 1);
% 
%         output.incomplete_running_distances_opto_control_1 = incomplete_distance(trials_opto_control_1_incomplete_running_index, 1);
%         output.incomplete_running_distances_opto_target_1 = incomplete_distance(trials_opto_target_1_incomplete_running_index, 1);
%         output.incomplete_running_distances_opto_control_2 = incomplete_distance(trials_opto_control_2_incomplete_running_index, 1);
%         output.incomplete_running_distances_opto_target_2 = incomplete_distance(trials_opto_target_2_incomplete_running_index, 1);
% 
%     % By trial distance
% 
%         trials_opto_control_1_incomplete_running_short_index = find(trials_opto_control_1_incomplete_running_short == 1);
%         trials_opto_target_1_incomplete_running_short_index = find(trials_opto_target_1_incomplete_running_short == 1);
%         trials_opto_control_2_incomplete_running_short_index = find(trials_opto_control_2_incomplete_running_short == 1);
%         trials_opto_target_2_incomplete_running_short_index = find(trials_opto_target_2_incomplete_running_short == 1);
% 
%         trials_opto_control_1_incomplete_running_medium_index = find(trials_opto_control_1_incomplete_running_medium == 1);
%         trials_opto_target_1_incomplete_running_medium_index = find(trials_opto_target_1_incomplete_running_medium == 1);
%         trials_opto_control_2_incomplete_running_medium_index = find(trials_opto_control_2_incomplete_running_medium == 1);
%         trials_opto_target_2_incomplete_running_medium_index = find(trials_opto_target_2_incomplete_running_medium == 1);
% 
%         trials_opto_control_1_incomplete_running_long_index = find(trials_opto_control_1_incomplete_running_long == 1);
%         trials_opto_target_1_incomplete_running_long_index = find(trials_opto_target_1_incomplete_running_long == 1);
%         trials_opto_control_2_incomplete_running_long_index = find(trials_opto_control_2_incomplete_running_long == 1);
%         trials_opto_target_2_incomplete_running_long_index = find(trials_opto_target_2_incomplete_running_long == 1);
% 
%         output.incomplete_running_distances_opto_control_1_short = incomplete_distance(trials_opto_control_1_incomplete_running_short_index, 1);
%         output.incomplete_running_distances_opto_target_1_short = incomplete_distance(trials_opto_target_1_incomplete_running_short_index, 1);
%         output.incomplete_running_distances_opto_control_1_medium = incomplete_distance(trials_opto_control_1_incomplete_running_medium_index, 1);
%         output.incomplete_running_distances_opto_target_1_medium = incomplete_distance(trials_opto_target_1_incomplete_running_medium_index, 1);
%         output.incomplete_running_distances_opto_control_1_long = incomplete_distance(trials_opto_control_1_incomplete_running_long_index, 1);
%         output.incomplete_running_distances_opto_target_1_long = incomplete_distance(trials_opto_target_1_incomplete_running_long_index, 1);
% 
%         output.incomplete_running_distances_opto_control_2_short = incomplete_distance(trials_opto_control_2_incomplete_running_short_index, 1);
%         output.incomplete_running_distances_opto_target_2_short = incomplete_distance(trials_opto_target_2_incomplete_running_short_index, 1);
%         output.incomplete_running_distances_opto_control_2_medium = incomplete_distance(trials_opto_control_2_incomplete_running_medium_index, 1);
%         output.incomplete_running_distances_opto_target_2_medium = incomplete_distance(trials_opto_target_2_incomplete_running_medium_index, 1);
%         output.incomplete_running_distances_opto_control_2_long = incomplete_distance(trials_opto_control_2_incomplete_running_long_index, 1);
%         output.incomplete_running_distances_opto_target_2_long = incomplete_distance(trials_opto_target_2_incomplete_running_long_index, 1);
% 
% output.Mean_incomplete_running_distances_opto_control_1_short = mean(output.incomplete_running_distances_opto_control_1_short);
% output.Mean_incomplete_running_distances_opto_target_1_short = mean(output.incomplete_running_distances_opto_target_1_short);
% output.Mean_incomplete_running_distances_opto_control_1_medium = mean(output.incomplete_running_distances_opto_control_1_medium);
% output.Mean_incomplete_running_distances_opto_target_1_medium = mean(output.incomplete_running_distances_opto_target_1_medium);
% output.Mean_incomplete_running_distances_opto_control_1_long = mean(output.incomplete_running_distances_opto_control_1_long);
% output.Mean_incomplete_running_distances_opto_target_1_long = mean(output.incomplete_running_distances_opto_target_1_long);
% output.Mean_incomplete_running_distances_opto_control_2_short = mean(output.incomplete_running_distances_opto_control_2_short);
% output.Mean_incomplete_running_distances_opto_target_2_short = mean(output.incomplete_running_distances_opto_target_2_short);
% output.Mean_incomplete_running_distances_opto_control_2_medium = mean(output.incomplete_running_distances_opto_control_2_medium);
% output.Mean_incomplete_running_distances_opto_target_2_medium = mean(output.incomplete_running_distances_opto_target_2_medium);
% output.Mean_incomplete_running_distances_opto_control_2_long = mean(output.incomplete_running_distances_opto_control_2_long);
% output.Mean_incomplete_running_distances_opto_target_2_long = mean(output.incomplete_running_distances_opto_target_2_long);
% 
% % Time to RW for each trial type
% 
%     % All times
% 
%         output.RW_times_opto_control_1 = reward_time(trials_opto_control_1_complete_index, 4);
%         output.RW_times_opto_target_1 = reward_time(trials_opto_target_1_complete_index, 4);
%         output.RW_times_opto_control_2 = reward_time(trials_opto_control_2_complete_index, 4);
%         output.RW_times_opto_target_2 = reward_time(trials_opto_target_2_complete_index, 4);
% 
%         output.RW_times_slow_opto_control_1 = reward_time(trials_opto_control_1_complete_slow_index, 4);
%         output.RW_times_slow_opto_target_1 = reward_time(trials_opto_target_1_complete_slow_index, 4);
%         output.RW_times_slow_opto_control_2 = reward_time(trials_opto_control_2_complete_slow_index, 4);
%         output.RW_times_slow_opto_target_2 = reward_time(trials_opto_target_2_complete_slow_index, 4);
% 
%         output.RW_times_stop_opto_control_1 = reward_time(trials_opto_control_1_complete_stop_index, 4);
%         output.RW_times_stop_opto_target_1 = reward_time(trials_opto_target_1_complete_stop_index, 4);
%         output.RW_times_stop_opto_control_2 = reward_time(trials_opto_control_2_complete_stop_index, 4);
%         output.RW_times_stop_opto_target_2 = reward_time(trials_opto_target_2_complete_stop_index, 4);
% 
%     % By trial time
% 
%         output.RW_times_opto_control_1_short = reward_time(trials_opto_control_1_complete_short_index, 4);
%         output.RW_times_opto_target_1_short = reward_time(trials_opto_target_1_complete_short_index, 4);
%         output.RW_times_opto_control_1_medium = reward_time(trials_opto_control_1_complete_medium_index, 4);
%         output.RW_times_opto_target_1_medium = reward_time(trials_opto_target_1_complete_medium_index, 4);
%         output.RW_times_opto_control_1_long = reward_time(trials_opto_control_1_complete_long_index, 4);
%         output.RW_times_opto_target_1_long = reward_time(trials_opto_target_1_complete_long_index, 4);
% 
%         output.RW_times_opto_control_2_short = reward_time(trials_opto_control_2_complete_short_index, 4);
%         output.RW_times_opto_target_2_short = reward_time(trials_opto_target_2_complete_short_index, 4);
%         output.RW_times_opto_control_2_medium = reward_time(trials_opto_control_2_complete_medium_index, 4);
%         output.RW_times_opto_target_2_medium = reward_time(trials_opto_target_2_complete_medium_index, 4);
%         output.RW_times_opto_control_2_long = reward_time(trials_opto_control_2_complete_long_index, 4);
%         output.RW_times_opto_target_2_long = reward_time(trials_opto_target_2_complete_long_index, 4);
% 
%         output.Mean_RW_times_opto_control_1_short = mean(output.RW_times_opto_control_1_short);
%         output.Mean_RW_times_opto_target_1_short = mean(output.RW_times_opto_target_1_short);
%         output.Mean_RW_times_opto_control_1_medium = mean(output.RW_times_opto_control_1_medium);
%         output.Mean_RW_times_opto_target_1_medium = mean(output.RW_times_opto_target_1_medium);
%         output.Mean_RW_times_opto_control_1_long = mean(output.RW_times_opto_control_1_long);
%         output.Mean_RW_times_opto_target_1_long = mean(output.RW_times_opto_target_1_long);
%         output.Mean_RW_times_opto_control_2_short = mean(output.RW_times_opto_control_2_short);
%         output.Mean_RW_times_opto_target_2_short = mean(output.RW_times_opto_target_2_short);
%         output.Mean_RW_times_opto_control_2_medium = mean(output.RW_times_opto_control_2_medium);
%         output.Mean_RW_times_opto_target_2_medium = mean(output.RW_times_opto_target_2_medium);
%         output.Mean_RW_times_opto_control_2_long = mean(output.RW_times_opto_control_2_long);
%         output.Mean_RW_times_opto_target_2_long = mean(output.RW_times_opto_target_2_long);
% 
% %         output.RW_times_opto_control_1_slow_short = reward_time(trials_opto_control_1_complete_slow_short_index, 4);
% %         output.RW_times_opto_target_1_slow_short = reward_time(trials_opto_target_1_complete_slow_short_index, 4);
% %         output.RW_times_opto_control_1_slow_medium = reward_time(trials_opto_control_1_complete_slow_medium_index, 4);
% %         output.RW_times_opto_target_1_slow_medium = reward_time(trials_opto_target_1_complete_slow_medium_index, 4);
% %         output.RW_times_opto_control_1_slow_long = reward_time(trials_opto_control_1_complete_slow_long_index, 4);
% %         output.RW_times_opto_target_1_slow_long = reward_time(trials_opto_target_1_complete_slow_long_index, 4);
% % 
% %         output.RW_times_opto_control_2_slow_short = reward_time(trials_opto_control_2_complete_slow_short_index, 4);
% %         output.RW_times_opto_target_2_slow_short = reward_time(trials_opto_target_2_complete_slow_short_index, 4);
% %         output.RW_times_opto_control_2_slow_medium = reward_time(trials_opto_control_2_complete_slow_medium_index, 4);
% %         output.RW_times_opto_target_2_slow_medium = reward_time(trials_opto_target_2_complete_slow_medium_index, 4);
% %         output.RW_times_opto_control_2_slow_long = reward_time(trials_opto_control_2_complete_slow_long_index, 4);
% %         output.RW_times_opto_target_2_slow_long = reward_time(trials_opto_target_2_complete_slow_long_index, 4);
% % 
% %         output.RW_times_opto_control_1_stop_short = reward_time(trials_opto_control_1_complete_stop_short_index, 4);
% %         output.RW_times_opto_target_1_stop_short = reward_time(trials_opto_target_1_complete_stop_short_index, 4);
% %         output.RW_times_opto_control_1_stop_medium = reward_time(trials_opto_control_1_complete_stop_medium_index, 4);
% %         output.RW_times_opto_target_1_stop_medium = reward_time(trials_opto_target_1_complete_stop_medium_index, 4);
% %         output.RW_times_opto_control_1_stop_long = reward_time(trials_opto_control_1_complete_stop_long_index, 4);
% %         output.RW_times_opto_target_1_stop_long = reward_time(trials_opto_target_1_complete_stop_long_index, 4);
% % 
% %         output.RW_times_opto_control_2_stop_short = reward_time(trials_opto_control_2_complete_stop_short_index, 4);
% %         output.RW_times_opto_target_2_stop_short = reward_time(trials_opto_target_2_complete_stop_short_index, 4);
% %         output.RW_times_opto_control_2_stop_medium = reward_time(trials_opto_control_2_complete_stop_medium_index, 4);
% %         output.RW_times_opto_target_2_stop_medium = reward_time(trials_opto_target_2_complete_stop_medium_index, 4);
% %         output.RW_times_opto_control_2_stop_long = reward_time(trials_opto_control_2_complete_stop_long_index, 4);
% %         output.RW_times_opto_target_2_stop_long = reward_time(trials_opto_target_2_complete_stop_long_index, 4);
% 
% 
% % Trajectories
% 
%     % Rewarded traces
% 
%         % Ctl versus opto 1
% 
%         figure(15)
%             hold on
% 
%             options.color_line = [236 112  22]./255; 
%             options.color_area = [243 169 114]./255;                   
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, :), options);
%             clear options
% 
% %             options.color_line = [216 0  115]./255;
% %             options.color_area = [226 20 135]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, :), options);
% %             clear options
% 
% %             options.color_area = [128 193 219]./255;   
% %             options.color_line = [ 52 148 186]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, :), options);
% 
% 
%             %%%%%%
% 
% 
%             options.color_line = [255 0 0]./255; % red
%             options.color_area = [255 153 204]./255; % pink                 
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, :), options);
%             clear options
% 
% %             options.color_line = [0 0 255]./255; % blue
% %             options.color_area = [0 204 255]./255;  % light blue          
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, :), options);
% %             clear options
% % 
% %             options.color_area = [0 51 0]./255;  % green
% %             options.color_line = [51 153 102]./255;   %light green         
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, :), options);
% % 
% 
%                    legend('', 'short CTL', '', 'short opto')
%                    axis ([-inf inf 0 600]);
%                    title 'Average Velocity Trajectories Opto 1'
%                     xlabel('Normalized Percent Distance to Target') 
%                     ylabel('Mean Velocity (cm/s)') 
% 
%             hold off
%          
%                % Save Fig file to computer 
% 
%                 [Where] = Where_file(filename);
%                 SaveName = [strcat(Where, 'VelocityTrajectories_Dist_short_opto_1_', date, '_', num)];
%                 savefig(SaveName);
% 
%                 close all
% 
% 
% 
% 
% 
%         figure(16)
%             hold on
% 
% %             options.color_line = [236 112  22]./255; 
% %             options.color_area = [243 169 114]./255;                   
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, :), options);
% %             clear options
% 
%             options.color_line = [216 0  115]./255;
%             options.color_area = [226 20 135]./255;            
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, :), options);
%             clear options
% 
% %             options.color_area = [128 193 219]./255;   
% %             options.color_line = [ 52 148 186]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, :), options);
% 
% 
%             %%%%%%
% 
% 
% %             options.color_line = [255 0 0]./255; % red
% %             options.color_area = [255 153 204]./255; % pink                 
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, :), options);
% %             clear options
% 
%             options.color_line = [0 0 255]./255; % blue
%             options.color_area = [0 204 255]./255;  % light blue          
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, :), options);
%             clear options
% % 
% %             options.color_area = [0 51 0]./255;  % green
% %             options.color_line = [51 153 102]./255;   %light green         
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, :), options);
% % 
% 
%                    legend('', 'medium CTL', '', 'medium opto')
%                    axis ([-inf inf 0 600]);
%                    title 'Average Velocity Trajectories Opto 1'
%                     xlabel('Normalized Percent Distance to Target') 
%                     ylabel('Mean Velocity (cm/s)') 
% 
%             hold off
%          
%                % Save Fig file to computer 
% 
%                 [Where] = Where_file(filename);
%                 SaveName = [strcat(Where, 'VelocityTrajectories_Dist_medium_opto_1_', date, '_', num)];
%                 savefig(SaveName);
% 
%                 close all                
% 
% 
% 
% 
%         figure(18)
%             hold on
% 
% %             options.color_line = [236 112  22]./255; 
% %             options.color_area = [243 169 114]./255;                   
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, :), options);
% %             clear options
% 
% %             options.color_line = [216 0  115]./255;
% %             options.color_area = [226 20 135]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, :), options);
% %             clear options
% 
%             options.color_area = [128 193 219]./255;   
%             options.color_line = [ 52 148 186]./255;            
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, :), options);
%               clear options
% 
%             %%%%%%
% 
% 
% %             options.color_line = [255 0 0]./255; % red
% %             options.color_area = [255 153 204]./255; % pink                 
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, :), options);
% %             clear options
% 
% %             options.color_line = [0 0 255]./255; % blue
% %             options.color_area = [0 204 255]./255;  % light blue          
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, :), options);
% %             clear options
% % 
%             options.color_area = [0 51 0]./255;  % green
%             options.color_line = [51 153 102]./255;   %light green         
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, :), options);
% 
% 
%                    legend('', 'long CTL', '', 'long opto')
%                    axis ([-inf inf 0 600]);
%                    title 'Average Velocity Trajectories Opto 1'
%                     xlabel('Normalized Percent Distance to Target') 
%                     ylabel('Mean Velocity (cm/s)') 
% 
%             hold off
%          
%                % Save Fig file to computer 
% 
%                 [Where] = Where_file(filename);
%                 SaveName = [strcat(Where, 'VelocityTrajectories_Dist_long_opto_1_', date, '_', num)];
%                 savefig(SaveName);
% 
%                 close all  
% 
% 
%         % Ctl versus opto 2
% 
%         figure(15)
%             hold on
% 
%             options.color_line = [236 112  22]./255; 
%             options.color_area = [243 169 114]./255;                   
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_2_short_index, :), options);
%             clear options
% 
% %             options.color_line = [216 0  115]./255;
% %             options.color_area = [226 20 135]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_2_medium_index, :), options);
% %             clear options
% 
% %             options.color_area = [128 193 219]./255;   
% %             options.color_line = [ 52 148 186]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_2_long_index, :), options);
% 
% 
%             %%%%%%
% 
% 
%             options.color_line = [255 0 0]./255; % red
%             options.color_area = [255 153 204]./255; % pink                 
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_2_short_index, :), options);
%             clear options
% 
% %             options.color_line = [0 0 255]./255; % blue
% %             options.color_area = [0 204 255]./255;  % light blue          
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_2_medium_index, :), options);
% %             clear options
% % 
% %             options.color_area = [0 51 0]./255;  % green
% %             options.color_line = [51 153 102]./255;   %light green         
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_2_long_index, :), options);
% % 
% 
%                    legend('', 'short CTL', '', 'short opto')
%                    axis ([-inf inf 0 600]);
%                    title 'Average Velocity Trajectories Opto 2'
%                     xlabel('Normalized Percent Distance to Target') 
%                     ylabel('Mean Velocity (cm/s)') 
% 
%             hold off
%          
%                % Save Fig file to computer 
% 
%                 [Where] = Where_file(filename);
%                 SaveName = [strcat(Where, 'VelocityTrajectories_Dist_short_opto_2_', date, '_', num)];
%                 savefig(SaveName);
% 
%                 close all
% 
% 
% 
% 
% 
%         figure(16)
%             hold on
% 
% %             options.color_line = [236 112  22]./255; 
% %             options.color_area = [243 169 114]./255;                   
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_2_short_index, :), options);
% %             clear options
% 
%             options.color_line = [216 0  115]./255;
%             options.color_area = [226 20 135]./255;            
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_2_medium_index, :), options);
%             clear options
% 
% %             options.color_area = [128 193 219]./255;   
% %             options.color_line = [ 52 148 186]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_2_long_index, :), options);
% 
% 
%             %%%%%%
% 
% 
% %             options.color_line = [255 0 0]./255; % red
% %             options.color_area = [255 153 204]./255; % pink                 
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_2_short_index, :), options);
% %             clear options
% 
%             options.color_line = [0 0 255]./255; % blue
%             options.color_area = [0 204 255]./255;  % light blue          
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_2_medium_index, :), options);
%             clear options
% % 
% %             options.color_area = [0 51 0]./255;  % green
% %             options.color_line = [51 153 102]./255;   %light green         
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_2_long_index, :), options);
% % 
% 
%                    legend('', 'medium CTL', '', 'medium opto')
%                    axis ([-inf inf 0 600]);
%                    title 'Average Velocity Trajectories Opto 2'
%                     xlabel('Normalized Percent Distance to Target') 
%                     ylabel('Mean Velocity (cm/s)') 
% 
%             hold off
%          
%                % Save Fig file to computer 
% 
%                 [Where] = Where_file(filename);
%                 SaveName = [strcat(Where, 'VelocityTrajectories_Dist_medium_opto_2_', date, '_', num)];
%                 savefig(SaveName);
% 
%                 close all                
% 
% 
% 
% 
%         figure(18)
%             hold on
% 
% %             options.color_line = [236 112  22]./255; 
% %             options.color_area = [243 169 114]./255;                   
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_2_short_index, :), options);
% %             clear options
% 
% %             options.color_line = [216 0  115]./255;
% %             options.color_area = [226 20 135]./255;            
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_2_medium_index, :), options);
% %             clear options
% 
%             options.color_area = [128 193 219]./255;   
%             options.color_line = [ 52 148 186]./255;            
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_control_2_long_index, :), options);
%               clear options
% 
%             %%%%%%
% 
% 
% %             options.color_line = [255 0 0]./255; % red
% %             options.color_area = [255 153 204]./255; % pink                 
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_2_short_index, :), options);
% %             clear options
% 
% %             options.color_line = [0 0 255]./255; % blue
% %             options.color_area = [0 204 255]./255;  % light blue          
% %             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_2_medium_index, :), options);
% %             clear options
% % 
%             options.color_area = [0 51 0]./255;  % green
%             options.color_line = [51 153 102]./255;   %light green         
%             plot_areaerrorbar(movement_velocities_smooth_mean_dist(trials_opto_target_2_long_index, :), options);
% 
% 
%                    legend('', 'long CTL', '', 'long opto')
%                    axis ([-inf inf 0 600]);
%                    title 'Average Velocity Trajectories Opto 2'
%                     xlabel('Normalized Percent Distance to Target') 
%                     ylabel('Mean Velocity (cm/s)') 
% 
%             hold off
%          
%                % Save Fig file to computer 
% 
%                 [Where] = Where_file(filename);
%                 SaveName = [strcat(Where, 'VelocityTrajectories_Dist_long_opto_2_', date, '_', num)];
%                 savefig(SaveName);
% 
%                 close all  
% 
% 
% 
% % Go latency
% 
%         trials_opto_control_1_t3 = trials_opto_control_1 .* trials_T3;
%         trials_opto_target_1_t3 = trials_opto_target_1 .* trials_T3;
%         trials_opto_control_2_t3 = trials_opto_control_2 .* trials_T3;
%         trials_opto_target_2_t3 = trials_opto_target_2 .* trials_T3;
%         trials_opto_control_1_short_t3 = trials_opto_control_1_short .* trials_T3;
%         trials_opto_target_1_short_t3 = trials_opto_target_1_short .* trials_T3;
%         trials_opto_control_1_medium_t3 = trials_opto_control_1_medium .* trials_T3;
%         trials_opto_target_1_medium_t3 = trials_opto_target_1_medium .* trials_T3;
%         trials_opto_control_1_long_t3 = trials_opto_control_1_long .* trials_T3;
%         trials_opto_target_1_long_t3 = trials_opto_target_1_long .* trials_T3;
%         trials_opto_control_2_short_t3 = trials_opto_control_2_short .* trials_T3;
%         trials_opto_target_2_short_t3 = trials_opto_target_2_short .* trials_T3;
%         trials_opto_control_2_medium_t3 = trials_opto_control_2_medium .* trials_T3;
%         trials_opto_target_2_medium_t3 = trials_opto_target_2_medium .* trials_T3;
%         trials_opto_control_2_long_t3 = trials_opto_control_2_long .* trials_T3;
%         trials_opto_target_2_long_t3 = trials_opto_target_2_long .* trials_T3;
% 
%         trials_opto_control_1_t3_index = find(trials_opto_control_1_t3 == 1);
%         trials_opto_target_1_t3_index = find(trials_opto_target_1_t3 == 1);
%         trials_opto_control_2_t3_index = find(trials_opto_control_2_t3 == 1);
%         trials_opto_target_2_t3_index = find(trials_opto_target_2_t3 == 1);
% 
%         trials_opto_control_1_short_t3_index = find(trials_opto_control_1_short_t3 == 1);
%         trials_opto_target_1_short_t3_index = find(trials_opto_target_1_short_t3 == 1);
%         trials_opto_control_1_medium_t3_index = find(trials_opto_control_1_medium_t3 == 1);
%         trials_opto_target_1_medium_t3_index = find(trials_opto_target_1_medium_t3 == 1);
%         trials_opto_control_1_long_t3_index = find(trials_opto_control_1_long_t3 == 1);
%         trials_opto_target_1_long_t3_index = find(trials_opto_target_1_long_t3 == 1);
%         
%         trials_opto_control_2_short_t3_index = find(trials_opto_control_2_short_t3 == 1);
%         trials_opto_target_2_short_t3_index = find(trials_opto_target_2_short_t3 == 1);
%         trials_opto_control_2_medium_t3_index = find(trials_opto_control_2_medium_t3 == 1);
%         trials_opto_target_2_medium_t3_index = find(trials_opto_target_2_medium_t3 == 1);
%         trials_opto_control_2_long_t3_index = find(trials_opto_control_2_long_t3 == 1);
%         trials_opto_target_2_long_t3_index = find(trials_opto_target_2_long_t3 == 1);
% 
%     % All distances
% 
%         output.overall_go_latency_opto_control_1 = go_latency(trials_opto_control_1_t3_index, 1);
%         output.overall_go_latency_opto_target_1 = go_latency(trials_opto_target_1_t3_index, 1);
%         output.overall_go_latency_opto_control_2 = go_latency(trials_opto_control_2_t3_index, 1);
%         output.overall_go_latency_opto_target_2 = go_latency(trials_opto_target_2_t3_index, 1);
% 
%     % By trial distance
% 
%         output.short_go_latency_opto_control_1 = go_latency(trials_opto_control_1_short_t3_index, 1);
%         output.short_go_latency_opto_target_1 = go_latency(trials_opto_target_1_short_t3_index, 1);
%         output.medium_go_latency_opto_control_1 = go_latency(trials_opto_control_1_medium_t3_index, 1);
%         output.medium_go_latency_opto_target_1 = go_latency(trials_opto_target_1_medium_t3_index, 1);
%         output.long_go_latency_opto_control_1 = go_latency(trials_opto_control_1_long_t3_index, 1);
%         output.long_go_latency_opto_target_1 = go_latency(trials_opto_target_1_long_t3_index, 1);
% 
%         output.short_go_latency_opto_control_2 = go_latency(trials_opto_control_2_short_t3_index, 1);
%         output.short_go_latency_opto_target_2 = go_latency(trials_opto_target_2_short_t3_index, 1);
%         output.medium_go_latency_opto_control_2 = go_latency(trials_opto_control_2_medium_t3_index, 1);
%         output.medium_go_latency_opto_target_2 = go_latency(trials_opto_target_2_medium_t3_index, 1);
%         output.long_go_latency_opto_control_2 = go_latency(trials_opto_control_2_long_t3_index, 1);
%         output.long_go_latency_opto_target_2 = go_latency(trials_opto_target_2_long_t3_index, 1);    
% 
%         output.Mean_short_go_latency_opto_control_1 = mean(output.short_go_latency_opto_control_1);
%         output.Mean_short_go_latency_opto_target_1 = mean(output.short_go_latency_opto_target_1);
%         output.Mean_medium_go_latency_opto_control_1 = mean(output.medium_go_latency_opto_control_1);
%         output.Mean_medium_go_latency_opto_target_1 = mean(output.medium_go_latency_opto_target_1);
%         output.Mean_long_go_latency_opto_control_1 = mean(output.long_go_latency_opto_control_1);
%         output.Mean_long_go_latency_opto_target_1 = mean(output.long_go_latency_opto_target_1);
%         output.Mean_short_go_latency_opto_control_2 = mean(output.short_go_latency_opto_control_2);
%         output.Mean_short_go_latency_opto_target_2 = mean(output.short_go_latency_opto_target_2);
%         output.Mean_medium_go_latency_opto_control_2 = mean(output.medium_go_latency_opto_control_2);
%         output.Mean_medium_go_latency_opto_target_2 = mean(output.medium_go_latency_opto_target_2);
%         output.Mean_long_go_latency_opto_control_2 = mean(output.long_go_latency_opto_control_2);
%         output.Mean_long_go_latency_opto_target_2 = mean(output.long_go_latency_opto_target_2);  
% 
% % Sub thresh analysis for opto
% 
%     if phase == '777'
% 
%         % Opto 1
% 
%             % short
% 
%                 max_size_short_control_1 = max(low_vel_dist_sizes(trials_opto_control_1_short_index, 1));
% 
%                 for i = 1:size(trials_opto_control_1_short_index, 1)
%                    low_vel_dist_sizes_short_control_1(i, :) = max_size_short_control_1 - size(low_vel_dist{trials_opto_control_1_short_index(i, 1), 3}, 1); 
%                    low_vel_dist_short_control_1{i, 1} = [low_vel_dist{trials_opto_control_1_short_index(i, 1), 3};nan(low_vel_dist_sizes_short_control_1(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_short_hist_control_1 = cell2mat(low_vel_dist_short_control_1);
% 
%                 low_vel_dist_short_hist_cut_index_control_1 = find(low_vel_dist_short_hist_control_1(:, 1) > (0.4*short) & low_vel_dist_short_hist_control_1(:, 1) < (short+cutoff));
%                 low_vel_dist_short_hist_control_1 = low_vel_dist_short_hist_control_1(low_vel_dist_short_hist_cut_index_control_1, 1);
%                 
%                              
% 
%                 max_size_short_target_1 = max(low_vel_dist_sizes(trials_opto_target_1_short_index, 1));
% 
%                 for i = 1:size(trials_opto_target_1_short_index, 1)
%                    low_vel_dist_sizes_short_target_1(i, :) = max_size_short_target_1 - size(low_vel_dist{trials_opto_target_1_short_index(i, 1), 3}, 1); 
%                    low_vel_dist_short_target_1{i, 1} = [low_vel_dist{trials_opto_target_1_short_index(i, 1), 3};nan(low_vel_dist_sizes_short_target_1(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_short_hist_target_1 = cell2mat(low_vel_dist_short_target_1);
% 
%                 low_vel_dist_short_hist_cut_index_target_1 = find(low_vel_dist_short_hist_target_1(:, 1) > (0.4*short) & low_vel_dist_short_hist_target_1(:, 1) < (short+cutoff));
%                 low_vel_dist_short_hist_target_1 = low_vel_dist_short_hist_target_1(low_vel_dist_short_hist_cut_index_target_1, 1);
%                 
%                 % [f_c1_short, xi_c1_short] = ksdensity(low_vel_dist_short_hist_target_1);
% 
%                 % [f_t1_short, xi_t1_short] = ksdensity(low_vel_dist_short_hist_control_1); 
% 
% 
%                 % plot(xi_c1_short, f_c1_short);   
%                 % plot(xi_t1_short, f_t1_short);  
% 
% 
%                 output.low_vel_dist_short_hist_control_1 = low_vel_dist_short_hist_control_1;
%                 output.low_vel_dist_short_hist_target_1 = low_vel_dist_short_hist_target_1;
% 
%                 % figure(1)    
%                 % hold on
%                 % histogram(low_vel_dist_short_hist_control_1, [(short*0.4):10:(short+cutoff)], 'Normalization', 'probability')
%                 % histogram(low_vel_dist_short_hist_target_1, [(short*0.4):10:(short+cutoff)], 'Normalization', 'probability')
%                 % ylabel('Relative Probability')
%   
%                figure(2)    
%                 hold on
%                 histfit(low_vel_dist_short_hist_control_1, 25, 'kernel')
%                 histfit(low_vel_dist_short_hist_target_1, 25, 'kernel')
%                 xlim([(short*0.4) (short+cutoff)])
% 
%                 output.low_vel_dist_short_hist_control_1_parameters = fitdist(low_vel_dist_short_hist_control_1, 'Kernel');
%                 output.low_vel_dist_short_hist_target_1_parameters = fitdist(low_vel_dist_short_hist_target_1, 'Kernel');
% 
%         %plot(x,ySix,'k-','LineWidth',2)
% 
%                    % Save Fig file to computer 
% 
%                     [Where] = Where_file(filename);
%                     SaveName = [strcat(Where, 'Threshold_crossing_hist_short_opto_1_', date, '_', num)];
%                     savefig(SaveName);            
%                     
%                     close all
% 
%             % medium
% 
%                 max_size_medium_control_1 = max(low_vel_dist_sizes(trials_opto_control_1_medium_index, 1));
% 
%                 for i = 1:size(trials_opto_control_1_medium_index, 1)
%                    low_vel_dist_sizes_medium_control_1(i, :) = max_size_medium_control_1 - size(low_vel_dist{trials_opto_control_1_medium_index(i, 1), 3}, 1); 
%                    low_vel_dist_medium_control_1{i, 1} = [low_vel_dist{trials_opto_control_1_medium_index(i, 1), 3};nan(low_vel_dist_sizes_medium_control_1(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_medium_hist_control_1 = cell2mat(low_vel_dist_medium_control_1);
% 
%                 low_vel_dist_medium_hist_cut_index_control_1 = find(low_vel_dist_medium_hist_control_1(:, 1) > (0.4*medium) & low_vel_dist_medium_hist_control_1(:, 1) < (medium+cutoff));
%                 low_vel_dist_medium_hist_control_1 = low_vel_dist_medium_hist_control_1(low_vel_dist_medium_hist_cut_index_control_1, 1);
%                 
%                              
% 
%                 max_size_medium_target_1 = max(low_vel_dist_sizes(trials_opto_target_1_medium_index, 1));
% 
%                 for i = 1:size(trials_opto_target_1_medium_index, 1)
%                    low_vel_dist_sizes_medium_target_1(i, :) = max_size_medium_target_1 - size(low_vel_dist{trials_opto_target_1_medium_index(i, 1), 3}, 1); 
%                    low_vel_dist_medium_target_1{i, 1} = [low_vel_dist{trials_opto_target_1_medium_index(i, 1), 3};nan(low_vel_dist_sizes_medium_target_1(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_medium_hist_target_1 = cell2mat(low_vel_dist_medium_target_1);
% 
%                 low_vel_dist_medium_hist_cut_index_target_1 = find(low_vel_dist_medium_hist_target_1(:, 1) > (0.4*medium) & low_vel_dist_medium_hist_target_1(:, 1) < (medium+cutoff));
%                 low_vel_dist_medium_hist_target_1 = low_vel_dist_medium_hist_target_1(low_vel_dist_medium_hist_cut_index_target_1, 1);
%                 
%                 % [f_c1_medium, xi_c1_medium] = ksdensity(low_vel_dist_medium_hist_target_1);
% 
%                 % [f_t1_medium, xi_t1_medium] = ksdensity(low_vel_dist_medium_hist_control_1); 
% 
% 
%                 % plot(xi_c1_medium, f_c1_medium);   
%                 % plot(xi_t1_medium, f_t1_medium);  
% 
% 
%                 output.low_vel_dist_medium_hist_control_1 = low_vel_dist_medium_hist_control_1;
%                 output.low_vel_dist_medium_hist_target_1 = low_vel_dist_medium_hist_target_1;
% 
%                 % figure(1)    
%                 % hold on
%                 % histogram(low_vel_dist_medium_hist_control_1, [(medium*0.4):10:(medium+cutoff)], 'Normalization', 'probability')
%                 % histogram(low_vel_dist_medium_hist_target_1, [(medium*0.4):10:(medium+cutoff)], 'Normalization', 'probability')
%                 % ylabel('Relative Probability')
%   
%                figure(2)    
%                 hold on
%                 histfit(low_vel_dist_medium_hist_control_1, 25, 'kernel')
%                 histfit(low_vel_dist_medium_hist_target_1, 25, 'kernel')
%                 xlim([(medium*0.4) (medium+cutoff)])
% 
%                 output.low_vel_dist_medium_hist_control_1_parameters = fitdist(low_vel_dist_medium_hist_control_1, 'Kernel');
%                 output.low_vel_dist_medium_hist_target_1_parameters = fitdist(low_vel_dist_medium_hist_target_1, 'Kernel');
% 
%         %plot(x,ySix,'k-','LineWidth',2)
% 
%                    % Save Fig file to computer 
% 
%                     [Where] = Where_file(filename);
%                     SaveName = [strcat(Where, 'Threshold_crossing_hist_medium_opto_1_', date, '_', num)];
%                     savefig(SaveName);            
%                     
%                     close all
% 
%              % long
% 
%                 max_size_long_control_1 = max(low_vel_dist_sizes(trials_opto_control_1_long_index, 1));
% 
%                 for i = 1:size(trials_opto_control_1_long_index, 1)
%                    low_vel_dist_sizes_long_control_1(i, :) = max_size_long_control_1 - size(low_vel_dist{trials_opto_control_1_long_index(i, 1), 3}, 1); 
%                    low_vel_dist_long_control_1{i, 1} = [low_vel_dist{trials_opto_control_1_long_index(i, 1), 3};nan(low_vel_dist_sizes_long_control_1(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_long_hist_control_1 = cell2mat(low_vel_dist_long_control_1);
% 
%                 low_vel_dist_long_hist_cut_index_control_1 = find(low_vel_dist_long_hist_control_1(:, 1) > (0.4*long) & low_vel_dist_long_hist_control_1(:, 1) < (long+cutoff));
%                 low_vel_dist_long_hist_control_1 = low_vel_dist_long_hist_control_1(low_vel_dist_long_hist_cut_index_control_1, 1);
%                 
%                              
% 
%                 max_size_long_target_1 = max(low_vel_dist_sizes(trials_opto_target_1_long_index, 1));
% 
%                 for i = 1:size(trials_opto_target_1_long_index, 1)
%                    low_vel_dist_sizes_long_target_1(i, :) = max_size_long_target_1 - size(low_vel_dist{trials_opto_target_1_long_index(i, 1), 3}, 1); 
%                    low_vel_dist_long_target_1{i, 1} = [low_vel_dist{trials_opto_target_1_long_index(i, 1), 3};nan(low_vel_dist_sizes_long_target_1(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_long_hist_target_1 = cell2mat(low_vel_dist_long_target_1);
% 
%                 low_vel_dist_long_hist_cut_index_target_1 = find(low_vel_dist_long_hist_target_1(:, 1) > (0.4*long) & low_vel_dist_long_hist_target_1(:, 1) < (long+cutoff));
%                 low_vel_dist_long_hist_target_1 = low_vel_dist_long_hist_target_1(low_vel_dist_long_hist_cut_index_target_1, 1);
%                 
%                 % [f_c1_long, xi_c1_long] = ksdensity(low_vel_dist_long_hist_target_1);
% 
%                 % [f_t1_long, xi_t1_long] = ksdensity(low_vel_dist_long_hist_control_1); 
% 
% 
%                 % plot(xi_c1_long, f_c1_long);   
%                 % plot(xi_t1_long, f_t1_long);  
% 
% 
%                 output.low_vel_dist_long_hist_control_1 = low_vel_dist_long_hist_control_1;
%                 output.low_vel_dist_long_hist_target_1 = low_vel_dist_long_hist_target_1;
% 
%                 % figure(1)    
%                 % hold on
%                 % histogram(low_vel_dist_long_hist_control_1, [(long*0.4):10:(long+cutoff)], 'Normalization', 'probability')
%                 % histogram(low_vel_dist_long_hist_target_1, [(long*0.4):10:(long+cutoff)], 'Normalization', 'probability')
%                 % ylabel('Relative Probability')
%   
%                figure(2)    
%                 hold on
%                 histfit(low_vel_dist_long_hist_control_1, 25, 'kernel')
%                 histfit(low_vel_dist_long_hist_target_1, 25, 'kernel')
%                 xlim([(long*0.4) (long+cutoff)])
% 
%                 output.low_vel_dist_long_hist_control_1_parameters = fitdist(low_vel_dist_long_hist_control_1, 'Kernel');
%                 output.low_vel_dist_long_hist_target_1_parameters = fitdist(low_vel_dist_long_hist_target_1, 'Kernel');
% 
%         %plot(x,ySix,'k-','LineWidth',2)
% 
%                    % Save Fig file to computer 
% 
%                     [Where] = Where_file(filename);
%                     SaveName = [strcat(Where, 'Threshold_crossing_hist_long_opto_1_', date, '_', num)];
%                     savefig(SaveName);            
%                     
%                     close all
% 
%         % Opto 2
% 
%             % short
% 
%                 max_size_short_control_2 = max(low_vel_dist_sizes(trials_opto_control_2_short_index, 1));
% 
%                 for i = 1:size(trials_opto_control_2_short_index, 1)
%                    low_vel_dist_sizes_short_control_2(i, :) = max_size_short_control_2 - size(low_vel_dist{trials_opto_control_2_short_index(i, 1), 3}, 1); 
%                    low_vel_dist_short_control_2{i, 1} = [low_vel_dist{trials_opto_control_2_short_index(i, 1), 3};nan(low_vel_dist_sizes_short_control_2(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_short_hist_control_2 = cell2mat(low_vel_dist_short_control_2);
% 
%                 low_vel_dist_short_hist_cut_index_control_2 = find(low_vel_dist_short_hist_control_2(:, 1) > (0.8*short) & low_vel_dist_short_hist_control_2(:, 1) < (short+cutoff));
%                 low_vel_dist_short_hist_control_2 = low_vel_dist_short_hist_control_2(low_vel_dist_short_hist_cut_index_control_2, 1);
%                 
%                              
% 
%                 max_size_short_target_2 = max(low_vel_dist_sizes(trials_opto_target_2_short_index, 1));
% 
%                 for i = 1:size(trials_opto_target_2_short_index, 1)
%                    low_vel_dist_sizes_short_target_2(i, :) = max_size_short_target_2 - size(low_vel_dist{trials_opto_target_2_short_index(i, 1), 3}, 1); 
%                    low_vel_dist_short_target_2{i, 1} = [low_vel_dist{trials_opto_target_2_short_index(i, 1), 3};nan(low_vel_dist_sizes_short_target_2(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_short_hist_target_2 = cell2mat(low_vel_dist_short_target_2);
% 
%                 low_vel_dist_short_hist_cut_index_target_2 = find(low_vel_dist_short_hist_target_2(:, 1) > (0.8*short) & low_vel_dist_short_hist_target_2(:, 1) < (short+cutoff));
%                 low_vel_dist_short_hist_target_2 = low_vel_dist_short_hist_target_2(low_vel_dist_short_hist_cut_index_target_2, 1);
%                 
%                 % [f_c1_short, xi_c1_short] = ksdensity(low_vel_dist_short_hist_target_2);
% 
%                 % [f_t1_short, xi_t1_short] = ksdensity(low_vel_dist_short_hist_control_2); 
% 
% 
%                 % plot(xi_c1_short, f_c1_short);   
%                 % plot(xi_t1_short, f_t1_short);  
% 
% 
%                 output.low_vel_dist_short_hist_control_2 = low_vel_dist_short_hist_control_2;
%                 output.low_vel_dist_short_hist_target_2 = low_vel_dist_short_hist_target_2;
% 
%                 % figure(1)    
%                 % hold on
%                 % histogram(low_vel_dist_short_hist_control_2, [(short*0.8):10:(short+cutoff)], 'Normalization', 'probability')
%                 % histogram(low_vel_dist_short_hist_target_2, [(short*0.8):10:(short+cutoff)], 'Normalization', 'probability')
%                 % ylabel('Relative Probability')
% 
%                figure(2)    
%                 hold on
%                 histfit(low_vel_dist_short_hist_control_2, 25, 'kernel')
%                 histfit(low_vel_dist_short_hist_target_2, 25, 'kernel')
%                 xlim([(short*0.8) (short+cutoff)])
% 
%                 output.low_vel_dist_long_hist_control_2_parameters = fitdist(low_vel_dist_short_hist_control_2, 'Kernel');
%                 output.low_vel_dist_long_hist_target_2_parameters = fitdist(low_vel_dist_short_hist_target_2, 'Kernel');                            
% 
%         %plot(x,ySix,'k-','LineWidth',2)
% 
%                    % Save Fig file to computer 
% 
%                     [Where] = Where_file(filename);
%                     SaveName = [strcat(Where, 'Threshold_crossing_hist_short_opto_2_', date, '_', num)];
%                     savefig(SaveName);            
%                     
%                     close all
% 
%             % medium
% 
%                 max_size_medium_control_2 = max(low_vel_dist_sizes(trials_opto_control_2_medium_index, 1));
% 
%                 for i = 1:size(trials_opto_control_2_medium_index, 1)
%                    low_vel_dist_sizes_medium_control_2(i, :) = max_size_medium_control_2 - size(low_vel_dist{trials_opto_control_2_medium_index(i, 1), 3}, 1); 
%                    low_vel_dist_medium_control_2{i, 1} = [low_vel_dist{trials_opto_control_2_medium_index(i, 1), 3};nan(low_vel_dist_sizes_medium_control_2(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_medium_hist_control_2 = cell2mat(low_vel_dist_medium_control_2);
% 
%                 low_vel_dist_medium_hist_cut_index_control_2 = find(low_vel_dist_medium_hist_control_2(:, 1) > (0.8*medium) & low_vel_dist_medium_hist_control_2(:, 1) < (medium+cutoff));
%                 low_vel_dist_medium_hist_control_2 = low_vel_dist_medium_hist_control_2(low_vel_dist_medium_hist_cut_index_control_2, 1);
%                 
%                              
% 
%                 max_size_medium_target_2 = max(low_vel_dist_sizes(trials_opto_target_2_medium_index, 1));
% 
%                 for i = 1:size(trials_opto_target_2_medium_index, 1)
%                    low_vel_dist_sizes_medium_target_2(i, :) = max_size_medium_target_2 - size(low_vel_dist{trials_opto_target_2_medium_index(i, 1), 3}, 1); 
%                    low_vel_dist_medium_target_2{i, 1} = [low_vel_dist{trials_opto_target_2_medium_index(i, 1), 3};nan(low_vel_dist_sizes_medium_target_2(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_medium_hist_target_2 = cell2mat(low_vel_dist_medium_target_2);
% 
%                 low_vel_dist_medium_hist_cut_index_target_2 = find(low_vel_dist_medium_hist_target_2(:, 1) > (0.8*medium) & low_vel_dist_medium_hist_target_2(:, 1) < (medium+cutoff));
%                 low_vel_dist_medium_hist_target_2 = low_vel_dist_medium_hist_target_2(low_vel_dist_medium_hist_cut_index_target_2, 1);
%                 
%                 % [f_c1_medium, xi_c1_medium] = ksdensity(low_vel_dist_medium_hist_target_2);
% 
%                 % [f_t1_medium, xi_t1_medium] = ksdensity(low_vel_dist_medium_hist_control_2); 
% 
% 
%                 % plot(xi_c1_medium, f_c1_medium);   
%                 % plot(xi_t1_medium, f_t1_medium);  
% 
% 
%                 output.low_vel_dist_medium_hist_control_2 = low_vel_dist_medium_hist_control_2;
%                 output.low_vel_dist_medium_hist_target_2 = low_vel_dist_medium_hist_target_2;
% 
%                 % figure(1)    
%                 % hold on
%                 % histogram(low_vel_dist_medium_hist_control_2, [(medium*0.8):10:(medium+cutoff)], 'Normalization', 'probability')
%                 % histogram(low_vel_dist_medium_hist_target_2, [(medium*0.8):10:(medium+cutoff)], 'Normalization', 'probability')
%                 % ylabel('Relative Probability')
% 
%                figure(2)    
%                 hold on
%                 histfit(low_vel_dist_medium_hist_control_2, 25, 'kernel')
%                 histfit(low_vel_dist_medium_hist_target_2, 25, 'kernel')
%                 xlim([(medium*0.8) (medium+cutoff)])
% 
%                 output.low_vel_dist_long_hist_control_2_parameters = fitdist(low_vel_dist_medium_hist_control_2, 'Kernel');
%                 output.low_vel_dist_long_hist_target_2_parameters = fitdist(low_vel_dist_medium_hist_target_2, 'Kernel');                            
% 
%         %plot(x,ySix,'k-','LineWidth',2)
% 
%                    % Save Fig file to computer 
% 
%                     [Where] = Where_file(filename);
%                     SaveName = [strcat(Where, 'Threshold_crossing_hist_medium_opto_2_', date, '_', num)];
%                     savefig(SaveName);            
%                     
%                     close all
% 
%             % long
% 
%                 max_size_long_control_2 = max(low_vel_dist_sizes(trials_opto_control_2_long_index, 1));
% 
%                 for i = 1:size(trials_opto_control_2_long_index, 1)
%                    low_vel_dist_sizes_long_control_2(i, :) = max_size_long_control_2 - size(low_vel_dist{trials_opto_control_2_long_index(i, 1), 3}, 1); 
%                    low_vel_dist_long_control_2{i, 1} = [low_vel_dist{trials_opto_control_2_long_index(i, 1), 3};nan(low_vel_dist_sizes_long_control_2(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_long_hist_control_2 = cell2mat(low_vel_dist_long_control_2);
% 
%                 low_vel_dist_long_hist_cut_index_control_2 = find(low_vel_dist_long_hist_control_2(:, 1) > (0.8*long) & low_vel_dist_long_hist_control_2(:, 1) < (long+cutoff));
%                 low_vel_dist_long_hist_control_2 = low_vel_dist_long_hist_control_2(low_vel_dist_long_hist_cut_index_control_2, 1);
%                 
%                              
% 
%                 max_size_long_target_2 = max(low_vel_dist_sizes(trials_opto_target_2_long_index, 1));
% 
%                 for i = 1:size(trials_opto_target_2_long_index, 1)
%                    low_vel_dist_sizes_long_target_2(i, :) = max_size_long_target_2 - size(low_vel_dist{trials_opto_target_2_long_index(i, 1), 3}, 1); 
%                    low_vel_dist_long_target_2{i, 1} = [low_vel_dist{trials_opto_target_2_long_index(i, 1), 3};nan(low_vel_dist_sizes_long_target_2(i, :), 1)];
% 
%                 end
% 
%                 low_vel_dist_long_hist_target_2 = cell2mat(low_vel_dist_long_target_2);
% 
%                 low_vel_dist_long_hist_cut_index_target_2 = find(low_vel_dist_long_hist_target_2(:, 1) > (0.8*long) & low_vel_dist_long_hist_target_2(:, 1) < (long+cutoff));
%                 low_vel_dist_long_hist_target_2 = low_vel_dist_long_hist_target_2(low_vel_dist_long_hist_cut_index_target_2, 1);
%                 
%                 % [f_c1_long, xi_c1_long] = ksdensity(low_vel_dist_long_hist_target_2);
% 
%                 % [f_t1_long, xi_t1_long] = ksdensity(low_vel_dist_long_hist_control_2); 
% 
% 
%                 % plot(xi_c1_long, f_c1_long);   
%                 % plot(xi_t1_long, f_t1_long);  
% 
% 
%                 output.low_vel_dist_long_hist_control_2 = low_vel_dist_long_hist_control_2;
%                 output.low_vel_dist_long_hist_target_2 = low_vel_dist_long_hist_target_2;
% 
%                 % figure(1)    
%                 % hold on
%                 % histogram(low_vel_dist_long_hist_control_2, [(long*0.8):10:(long+cutoff)], 'Normalization', 'probability')
%                 % histogram(low_vel_dist_long_hist_target_2, [(long*0.8):10:(long+cutoff)], 'Normalization', 'probability')
%                 % ylabel('Relative Probability')
% 
%                figure(2)    
%                 hold on
%                 histfit(low_vel_dist_long_hist_control_2, 25, 'kernel')
%                 histfit(low_vel_dist_long_hist_target_2, 25, 'kernel')
%                 xlim([(long*0.8) (long+cutoff)])
% 
%                 output.low_vel_dist_long_hist_control_2_parameters = fitdist(low_vel_dist_long_hist_control_2, 'Kernel');
%                 output.low_vel_dist_long_hist_target_2_parameters = fitdist(low_vel_dist_long_hist_target_2, 'Kernel');                            
% 
%         %plot(x,ySix,'k-','LineWidth',2)
% 
%                    % Save Fig file to computer 
% 
%                     [Where] = Where_file(filename);
%                     SaveName = [strcat(Where, 'Threshold_crossing_hist_long_opto_2_', date, '_', num)];
%                     savefig(SaveName);            
%                     
%                     close all
% 
%     % 
% 
%         output.low_vel_dist_short_hist_control_1_mean = mean(low_vel_dist_short_hist_control_1, "omitnan");
%         output.low_vel_dist_short_hist_target_1_mean = mean(low_vel_dist_short_hist_target_1, "omitnan");
% 
%         output.low_vel_dist_medium_hist_control_1_mean = mean(low_vel_dist_medium_hist_control_1, "omitnan");
%         output.low_vel_dist_medium_hist_target_1_mean = mean(low_vel_dist_medium_hist_target_1, "omitnan");
% 
%         output.low_vel_dist_long_hist_control_1_mean = mean(low_vel_dist_long_hist_control_1, "omitnan");
%         output.low_vel_dist_long_hist_target_1_mean = mean(low_vel_dist_long_hist_target_1, "omitnan");
% 
%         output.low_vel_dist_short_hist_control_2_mean = mean(low_vel_dist_short_hist_control_2, "omitnan");
%         output.low_vel_dist_short_hist_target_2_mean = mean(low_vel_dist_short_hist_target_2, "omitnan");
% 
%         output.low_vel_dist_medium_hist_control_2_mean = mean(low_vel_dist_medium_hist_control_2, "omitnan");
%         output.low_vel_dist_medium_hist_target_2_mean = mean(low_vel_dist_medium_hist_target_2, "omitnan");
% 
%         output.low_vel_dist_long_hist_control_2_mean = mean(low_vel_dist_long_hist_control_2, "omitnan");
%         output.low_vel_dist_long_hist_target_2_mean = mean(low_vel_dist_long_hist_target_2, "omitnan"); 
% 
%         output.low_vel_dist_short_hist_control_1_median = median(low_vel_dist_short_hist_control_1, "omitnan");
%         output.low_vel_dist_short_hist_target_1_median = median(low_vel_dist_short_hist_target_1, "omitnan");
% 
%         output.low_vel_dist_medium_hist_control_1_median = median(low_vel_dist_medium_hist_control_1, "omitnan");
%         output.low_vel_dist_medium_hist_target_1_median = median(low_vel_dist_medium_hist_target_1, "omitnan");
% 
%         output.low_vel_dist_long_hist_control_1_median = median(low_vel_dist_long_hist_control_1, "omitnan");
%         output.low_vel_dist_long_hist_target_1_median = median(low_vel_dist_long_hist_target_1, "omitnan");
% 
%         output.low_vel_dist_short_hist_control_2_median = median(low_vel_dist_short_hist_control_2, "omitnan");
%         output.low_vel_dist_short_hist_target_2_median = median(low_vel_dist_short_hist_target_2, "omitnan");
% 
%         output.low_vel_dist_medium_hist_control_2_median = median(low_vel_dist_medium_hist_control_2, "omitnan");
%         output.low_vel_dist_medium_hist_target_2_median = median(low_vel_dist_medium_hist_target_2, "omitnan"); 
% 
%         output.low_vel_dist_long_hist_control_2_median = median(low_vel_dist_long_hist_control_2, "omitnan");
%         output.low_vel_dist_long_hist_target_2_median = median(low_vel_dist_long_hist_target_2, "omitnan"); 
% 
% % Velocity averages
% 
% output.mean_vel_dist_40_opto_control_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, 40:49), 2);
% output.mean_vel_dist_40_opto_target_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, 40:49), 2);
% output.mean_vel_dist_50_opto_control_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, 50:59), 2);
% output.mean_vel_dist_50_opto_target_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, 50:59), 2);
% output.mean_vel_dist_60_opto_control_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, 60:69), 2);
% output.mean_vel_dist_60_opto_target_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, 60:69), 2);
% output.mean_vel_dist_70_opto_control_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, 70:79), 2);
% output.mean_vel_dist_70_opto_target_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, 70:79), 2);
% output.mean_vel_dist_80_opto_control_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, 80:89), 2);
% output.mean_vel_dist_80_opto_target_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, 80:89), 2);
% output.mean_vel_dist_90_opto_control_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, 90:99), 2);
% output.mean_vel_dist_90_opto_target_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, 90:99), 2);
% output.mean_vel_dist_100_opto_control_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, 100:109), 2);
% output.mean_vel_dist_100_opto_target_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, 100:109), 2);
% output.mean_vel_dist_110_opto_control_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_short_index, 110:120), 2);
% output.mean_vel_dist_110_opto_target_1_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_short_index, 110:120), 2);
% 
% output.mean_vel_dist_40_opto_control_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, 40:49), 2);
% output.mean_vel_dist_40_opto_target_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, 40:49), 2);
% output.mean_vel_dist_50_opto_control_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, 50:59), 2);
% output.mean_vel_dist_50_opto_target_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, 50:59), 2);
% output.mean_vel_dist_60_opto_control_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, 60:69), 2);
% output.mean_vel_dist_60_opto_target_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, 60:69), 2);
% output.mean_vel_dist_70_opto_control_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, 70:79), 2);
% output.mean_vel_dist_70_opto_target_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, 70:79), 2);
% output.mean_vel_dist_80_opto_control_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, 80:89), 2);
% output.mean_vel_dist_80_opto_target_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, 80:89), 2);
% output.mean_vel_dist_90_opto_control_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, 90:99), 2);
% output.mean_vel_dist_90_opto_target_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, 90:99), 2);
% output.mean_vel_dist_100_opto_control_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, 100:109), 2);
% output.mean_vel_dist_100_opto_target_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, 100:109), 2);
% output.mean_vel_dist_110_opto_control_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_medium_index, 110:120), 2);
% output.mean_vel_dist_110_opto_target_1_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_medium_index, 110:120), 2);
% 
% output.mean_vel_dist_40_opto_control_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, 40:49), 2);
% output.mean_vel_dist_40_opto_target_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, 40:49), 2);
% output.mean_vel_dist_50_opto_control_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, 50:59), 2);
% output.mean_vel_dist_50_opto_target_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, 50:59), 2);
% output.mean_vel_dist_60_opto_control_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, 60:69), 2);
% output.mean_vel_dist_60_opto_target_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, 60:69), 2);
% output.mean_vel_dist_70_opto_control_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, 70:79), 2);
% output.mean_vel_dist_70_opto_target_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, 70:79), 2);
% output.mean_vel_dist_80_opto_control_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, 80:89), 2);
% output.mean_vel_dist_80_opto_target_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, 80:89), 2);
% output.mean_vel_dist_90_opto_control_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, 90:99), 2);
% output.mean_vel_dist_90_opto_target_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, 90:99), 2);
% output.mean_vel_dist_100_opto_control_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, 100:109), 2);
% output.mean_vel_dist_100_opto_target_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, 100:109), 2);
% output.mean_vel_dist_110_opto_control_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_1_long_index, 110:120), 2);
% output.mean_vel_dist_110_opto_target_1_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_1_long_index, 110:120), 2);
% 
% 
% output.mean_vel_mean_40_opto_control_1_short = mean(output.mean_vel_dist_40_opto_control_1_short, "omitnan");
% output.mean_vel_sem_40_opto_control_1_short = std(output.mean_vel_dist_40_opto_control_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_40_opto_control_1_short))));
% output.mean_vel_n_40_opto_control_1_short = sum(~isnan(output.mean_vel_dist_40_opto_control_1_short));
% 
% output.mean_vel_mean_40_opto_target_1_short = mean(output.mean_vel_dist_40_opto_target_1_short, "omitnan");
% output.mean_vel_sem_40_opto_target_1_short = std(output.mean_vel_dist_40_opto_target_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_40_opto_target_1_short))));
% output.mean_vel_n_40_opto_target_1_short = sum(~isnan(output.mean_vel_dist_40_opto_target_1_short));
% 
% output.mean_vel_mean_50_opto_control_1_short = mean(output.mean_vel_dist_50_opto_control_1_short, "omitnan");
% output.mean_vel_sem_50_opto_control_1_short = std(output.mean_vel_dist_50_opto_control_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_50_opto_control_1_short))));
% output.mean_vel_n_50_opto_control_1_short = sum(~isnan(output.mean_vel_dist_50_opto_control_1_short));
% 
% output.mean_vel_mean_50_opto_target_1_short = mean(output.mean_vel_dist_50_opto_target_1_short, "omitnan");
% output.mean_vel_sem_50_opto_target_1_short = std(output.mean_vel_dist_50_opto_target_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_50_opto_target_1_short))));
% output.mean_vel_n_50_opto_target_1_short = sum(~isnan(output.mean_vel_dist_50_opto_target_1_short));
% 
% output.mean_vel_mean_60_opto_control_1_short = mean(output.mean_vel_dist_60_opto_control_1_short, "omitnan");
% output.mean_vel_sem_60_opto_control_1_short = std(output.mean_vel_dist_60_opto_control_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_60_opto_control_1_short))));
% output.mean_vel_n_60_opto_control_1_short = sum(~isnan(output.mean_vel_dist_60_opto_control_1_short));
% 
% output.mean_vel_mean_60_opto_target_1_short = mean(output.mean_vel_dist_60_opto_target_1_short, "omitnan");
% output.mean_vel_sem_60_opto_target_1_short = std(output.mean_vel_dist_60_opto_target_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_60_opto_target_1_short))));
% output.mean_vel_n_60_opto_target_1_short = sum(~isnan(output.mean_vel_dist_60_opto_target_1_short));
% 
% output.mean_vel_mean_70_opto_control_1_short = mean(output.mean_vel_dist_70_opto_control_1_short, "omitnan");
% output.mean_vel_sem_70_opto_control_1_short = std(output.mean_vel_dist_70_opto_control_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_70_opto_control_1_short))));
% output.mean_vel_n_70_opto_control_1_short = sum(~isnan(output.mean_vel_dist_70_opto_control_1_short));
% 
% output.mean_vel_mean_70_opto_target_1_short = mean(output.mean_vel_dist_70_opto_target_1_short, "omitnan");
% output.mean_vel_sem_70_opto_target_1_short = std(output.mean_vel_dist_70_opto_target_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_70_opto_target_1_short))));
% output.mean_vel_n_70_opto_target_1_short = sum(~isnan(output.mean_vel_dist_70_opto_target_1_short));
% 
% output.mean_vel_mean_80_opto_control_1_short = mean(output.mean_vel_dist_80_opto_control_1_short, "omitnan");
% output.mean_vel_sem_80_opto_control_1_short = std(output.mean_vel_dist_80_opto_control_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_control_1_short))));
% output.mean_vel_n_80_opto_control_1_short = sum(~isnan(output.mean_vel_dist_80_opto_control_1_short));
% 
% output.mean_vel_mean_80_opto_target_1_short = mean(output.mean_vel_dist_80_opto_target_1_short, "omitnan");
% output.mean_vel_sem_80_opto_target_1_short = std(output.mean_vel_dist_80_opto_target_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_target_1_short))));
% output.mean_vel_n_80_opto_target_1_short = sum(~isnan(output.mean_vel_dist_80_opto_target_1_short));
% 
% output.mean_vel_mean_90_opto_control_1_short = mean(output.mean_vel_dist_90_opto_control_1_short, "omitnan");
% output.mean_vel_sem_90_opto_control_1_short = std(output.mean_vel_dist_90_opto_control_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_control_1_short))));
% output.mean_vel_n_90_opto_control_1_short = sum(~isnan(output.mean_vel_dist_90_opto_control_1_short));
% 
% output.mean_vel_mean_90_opto_target_1_short = mean(output.mean_vel_dist_90_opto_target_1_short, "omitnan");
% output.mean_vel_sem_90_opto_target_1_short = std(output.mean_vel_dist_90_opto_target_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_target_1_short))));
% output.mean_vel_n_90_opto_target_1_short = sum(~isnan(output.mean_vel_dist_90_opto_target_1_short));
% 
% output.mean_vel_mean_100_opto_control_1_short = mean(output.mean_vel_dist_100_opto_control_1_short, "omitnan");
% output.mean_vel_sem_100_opto_control_1_short = std(output.mean_vel_dist_100_opto_control_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_control_1_short))));
% output.mean_vel_n_100_opto_control_1_short = sum(~isnan(output.mean_vel_dist_100_opto_control_1_short));
% 
% output.mean_vel_mean_100_opto_target_1_short = mean(output.mean_vel_dist_100_opto_target_1_short, "omitnan");
% output.mean_vel_sem_100_opto_target_1_short = std(output.mean_vel_dist_100_opto_target_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_target_1_short))));
% output.mean_vel_n_100_opto_target_1_short = sum(~isnan(output.mean_vel_dist_100_opto_target_1_short));
% 
% output.mean_vel_mean_110_opto_control_1_short = mean(output.mean_vel_dist_110_opto_control_1_short, "omitnan");
% output.mean_vel_sem_110_opto_control_1_short = std(output.mean_vel_dist_110_opto_control_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_control_1_short))));
% output.mean_vel_n_110_opto_control_1_short = sum(~isnan(output.mean_vel_dist_110_opto_control_1_short));
% 
% output.mean_vel_mean_110_opto_target_1_short = mean(output.mean_vel_dist_110_opto_target_1_short, "omitnan");
% output.mean_vel_sem_110_opto_target_1_short = std(output.mean_vel_dist_110_opto_target_1_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_target_1_short))));
% output.mean_vel_n_110_opto_target_1_short = sum(~isnan(output.mean_vel_dist_110_opto_target_1_short));
% 
% 
% % Medium
% 
% output.mean_vel_mean_40_opto_control_1_medium = mean(output.mean_vel_dist_40_opto_control_1_medium, "omitnan");
% output.mean_vel_sem_40_opto_control_1_medium = std(output.mean_vel_dist_40_opto_control_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_40_opto_control_1_medium))));
% output.mean_vel_n_40_opto_control_1_medium = sum(~isnan(output.mean_vel_dist_40_opto_control_1_medium));
% 
% output.mean_vel_mean_40_opto_target_1_medium = mean(output.mean_vel_dist_40_opto_target_1_medium, "omitnan");
% output.mean_vel_sem_40_opto_target_1_medium = std(output.mean_vel_dist_40_opto_target_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_40_opto_target_1_medium))));
% output.mean_vel_n_40_opto_target_1_medium = sum(~isnan(output.mean_vel_dist_40_opto_target_1_medium));
% 
% output.mean_vel_mean_50_opto_control_1_medium = mean(output.mean_vel_dist_50_opto_control_1_medium, "omitnan");
% output.mean_vel_sem_50_opto_control_1_medium = std(output.mean_vel_dist_50_opto_control_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_50_opto_control_1_medium))));
% output.mean_vel_n_50_opto_control_1_medium = sum(~isnan(output.mean_vel_dist_50_opto_control_1_medium));
% 
% output.mean_vel_mean_50_opto_target_1_medium = mean(output.mean_vel_dist_50_opto_target_1_medium, "omitnan");
% output.mean_vel_sem_50_opto_target_1_medium = std(output.mean_vel_dist_50_opto_target_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_50_opto_target_1_medium))));
% output.mean_vel_n_50_opto_target_1_medium = sum(~isnan(output.mean_vel_dist_50_opto_target_1_medium));
% 
% output.mean_vel_mean_60_opto_control_1_medium = mean(output.mean_vel_dist_60_opto_control_1_medium, "omitnan");
% output.mean_vel_sem_60_opto_control_1_medium = std(output.mean_vel_dist_60_opto_control_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_60_opto_control_1_medium))));
% output.mean_vel_n_60_opto_control_1_medium = sum(~isnan(output.mean_vel_dist_60_opto_control_1_medium));
% 
% output.mean_vel_mean_60_opto_target_1_medium = mean(output.mean_vel_dist_60_opto_target_1_medium, "omitnan");
% output.mean_vel_sem_60_opto_target_1_medium = std(output.mean_vel_dist_60_opto_target_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_60_opto_target_1_medium))));
% output.mean_vel_n_60_opto_target_1_medium = sum(~isnan(output.mean_vel_dist_60_opto_target_1_medium));
% 
% output.mean_vel_mean_70_opto_control_1_medium = mean(output.mean_vel_dist_70_opto_control_1_medium, "omitnan");
% output.mean_vel_sem_70_opto_control_1_medium = std(output.mean_vel_dist_70_opto_control_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_70_opto_control_1_medium))));
% output.mean_vel_n_70_opto_control_1_medium = sum(~isnan(output.mean_vel_dist_70_opto_control_1_medium));
% 
% output.mean_vel_mean_70_opto_target_1_medium = mean(output.mean_vel_dist_70_opto_target_1_medium, "omitnan");
% output.mean_vel_sem_70_opto_target_1_medium = std(output.mean_vel_dist_70_opto_target_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_70_opto_target_1_medium))));
% output.mean_vel_n_70_opto_target_1_medium = sum(~isnan(output.mean_vel_dist_70_opto_target_1_medium));
% 
% output.mean_vel_mean_80_opto_control_1_medium = mean(output.mean_vel_dist_80_opto_control_1_medium, "omitnan");
% output.mean_vel_sem_80_opto_control_1_medium = std(output.mean_vel_dist_80_opto_control_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_control_1_medium))));
% output.mean_vel_n_80_opto_control_1_medium = sum(~isnan(output.mean_vel_dist_80_opto_control_1_medium));
% 
% output.mean_vel_mean_80_opto_target_1_medium = mean(output.mean_vel_dist_80_opto_target_1_medium, "omitnan");
% output.mean_vel_sem_80_opto_target_1_medium = std(output.mean_vel_dist_80_opto_target_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_target_1_medium))));
% output.mean_vel_n_80_opto_target_1_medium = sum(~isnan(output.mean_vel_dist_80_opto_target_1_medium));
% 
% output.mean_vel_mean_90_opto_control_1_medium = mean(output.mean_vel_dist_90_opto_control_1_medium, "omitnan");
% output.mean_vel_sem_90_opto_control_1_medium = std(output.mean_vel_dist_90_opto_control_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_control_1_medium))));
% output.mean_vel_n_90_opto_control_1_medium = sum(~isnan(output.mean_vel_dist_90_opto_control_1_medium));
% 
% output.mean_vel_mean_90_opto_target_1_medium = mean(output.mean_vel_dist_90_opto_target_1_medium, "omitnan");
% output.mean_vel_sem_90_opto_target_1_medium = std(output.mean_vel_dist_90_opto_target_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_target_1_medium))));
% output.mean_vel_n_90_opto_target_1_medium = sum(~isnan(output.mean_vel_dist_90_opto_target_1_medium));
% 
% output.mean_vel_mean_100_opto_control_1_medium = mean(output.mean_vel_dist_100_opto_control_1_medium, "omitnan");
% output.mean_vel_sem_100_opto_control_1_medium = std(output.mean_vel_dist_100_opto_control_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_control_1_medium))));
% output.mean_vel_n_100_opto_control_1_medium = sum(~isnan(output.mean_vel_dist_100_opto_control_1_medium));
% 
% output.mean_vel_mean_100_opto_target_1_medium = mean(output.mean_vel_dist_100_opto_target_1_medium, "omitnan");
% output.mean_vel_sem_100_opto_target_1_medium = std(output.mean_vel_dist_100_opto_target_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_target_1_medium))));
% output.mean_vel_n_100_opto_target_1_medium = sum(~isnan(output.mean_vel_dist_100_opto_target_1_medium));
% 
% output.mean_vel_mean_110_opto_control_1_medium = mean(output.mean_vel_dist_110_opto_control_1_medium, "omitnan");
% output.mean_vel_sem_110_opto_control_1_medium = std(output.mean_vel_dist_110_opto_control_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_control_1_medium))));
% output.mean_vel_n_110_opto_control_1_medium = sum(~isnan(output.mean_vel_dist_110_opto_control_1_medium));
% 
% output.mean_vel_mean_110_opto_target_1_medium = mean(output.mean_vel_dist_110_opto_target_1_medium, "omitnan");
% output.mean_vel_sem_110_opto_target_1_medium = std(output.mean_vel_dist_110_opto_target_1_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_target_1_medium))));
% output.mean_vel_n_110_opto_target_1_medium = sum(~isnan(output.mean_vel_dist_110_opto_target_1_medium));
% 
% 
% 
% % long
% 
% output.mean_vel_mean_40_opto_control_1_long = mean(output.mean_vel_dist_40_opto_control_1_long, "omitnan");
% output.mean_vel_sem_40_opto_control_1_long = std(output.mean_vel_dist_40_opto_control_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_40_opto_control_1_long))));
% output.mean_vel_n_40_opto_control_1_long = sum(~isnan(output.mean_vel_dist_40_opto_control_1_long));
% 
% output.mean_vel_mean_40_opto_target_1_long = mean(output.mean_vel_dist_40_opto_target_1_long, "omitnan");
% output.mean_vel_sem_40_opto_target_1_long = std(output.mean_vel_dist_40_opto_target_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_40_opto_target_1_long))));
% output.mean_vel_n_40_opto_target_1_long = sum(~isnan(output.mean_vel_dist_40_opto_target_1_long));
% 
% output.mean_vel_mean_50_opto_control_1_long = mean(output.mean_vel_dist_50_opto_control_1_long, "omitnan");
% output.mean_vel_sem_50_opto_control_1_long = std(output.mean_vel_dist_50_opto_control_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_50_opto_control_1_long))));
% output.mean_vel_n_50_opto_control_1_long = sum(~isnan(output.mean_vel_dist_50_opto_control_1_long));
% 
% output.mean_vel_mean_50_opto_target_1_long = mean(output.mean_vel_dist_50_opto_target_1_long, "omitnan");
% output.mean_vel_sem_50_opto_target_1_long = std(output.mean_vel_dist_50_opto_target_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_50_opto_target_1_long))));
% output.mean_vel_n_50_opto_target_1_long = sum(~isnan(output.mean_vel_dist_50_opto_target_1_long));
% 
% output.mean_vel_mean_60_opto_control_1_long = mean(output.mean_vel_dist_60_opto_control_1_long, "omitnan");
% output.mean_vel_sem_60_opto_control_1_long = std(output.mean_vel_dist_60_opto_control_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_60_opto_control_1_long))));
% output.mean_vel_n_60_opto_control_1_long = sum(~isnan(output.mean_vel_dist_60_opto_control_1_long));
% 
% output.mean_vel_mean_60_opto_target_1_long = mean(output.mean_vel_dist_60_opto_target_1_long, "omitnan");
% output.mean_vel_sem_60_opto_target_1_long = std(output.mean_vel_dist_60_opto_target_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_60_opto_target_1_long))));
% output.mean_vel_n_60_opto_target_1_long = sum(~isnan(output.mean_vel_dist_60_opto_target_1_long));
% 
% output.mean_vel_mean_70_opto_control_1_long = mean(output.mean_vel_dist_70_opto_control_1_long, "omitnan");
% output.mean_vel_sem_70_opto_control_1_long = std(output.mean_vel_dist_70_opto_control_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_70_opto_control_1_long))));
% output.mean_vel_n_70_opto_control_1_long = sum(~isnan(output.mean_vel_dist_70_opto_control_1_long));
% 
% output.mean_vel_mean_70_opto_target_1_long = mean(output.mean_vel_dist_70_opto_target_1_long, "omitnan");
% output.mean_vel_sem_70_opto_target_1_long = std(output.mean_vel_dist_70_opto_target_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_70_opto_target_1_long))));
% output.mean_vel_n_70_opto_target_1_long = sum(~isnan(output.mean_vel_dist_70_opto_target_1_long));
% 
% output.mean_vel_mean_80_opto_control_1_long = mean(output.mean_vel_dist_80_opto_control_1_long, "omitnan");
% output.mean_vel_sem_80_opto_control_1_long = std(output.mean_vel_dist_80_opto_control_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_control_1_long))));
% output.mean_vel_n_80_opto_control_1_long = sum(~isnan(output.mean_vel_dist_80_opto_control_1_long));
% 
% output.mean_vel_mean_80_opto_target_1_long = mean(output.mean_vel_dist_80_opto_target_1_long, "omitnan");
% output.mean_vel_sem_80_opto_target_1_long = std(output.mean_vel_dist_80_opto_target_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_target_1_long))));
% output.mean_vel_n_80_opto_target_1_long = sum(~isnan(output.mean_vel_dist_80_opto_target_1_long));
% 
% output.mean_vel_mean_90_opto_control_1_long = mean(output.mean_vel_dist_90_opto_control_1_long, "omitnan");
% output.mean_vel_sem_90_opto_control_1_long = std(output.mean_vel_dist_90_opto_control_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_control_1_long))));
% output.mean_vel_n_90_opto_control_1_long = sum(~isnan(output.mean_vel_dist_90_opto_control_1_long));
% 
% output.mean_vel_mean_90_opto_target_1_long = mean(output.mean_vel_dist_90_opto_target_1_long, "omitnan");
% output.mean_vel_sem_90_opto_target_1_long = std(output.mean_vel_dist_90_opto_target_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_target_1_long))));
% output.mean_vel_n_90_opto_target_1_long = sum(~isnan(output.mean_vel_dist_90_opto_target_1_long));
% 
% output.mean_vel_mean_100_opto_control_1_long = mean(output.mean_vel_dist_100_opto_control_1_long, "omitnan");
% output.mean_vel_sem_100_opto_control_1_long = std(output.mean_vel_dist_100_opto_control_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_control_1_long))));
% output.mean_vel_n_100_opto_control_1_long = sum(~isnan(output.mean_vel_dist_100_opto_control_1_long));
% 
% output.mean_vel_mean_100_opto_target_1_long = mean(output.mean_vel_dist_100_opto_target_1_long, "omitnan");
% output.mean_vel_sem_100_opto_target_1_long = std(output.mean_vel_dist_100_opto_target_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_target_1_long))));
% output.mean_vel_n_100_opto_target_1_long = sum(~isnan(output.mean_vel_dist_100_opto_target_1_long));
% 
% output.mean_vel_mean_110_opto_control_1_long = mean(output.mean_vel_dist_110_opto_control_1_long, "omitnan");
% output.mean_vel_sem_110_opto_control_1_long = std(output.mean_vel_dist_110_opto_control_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_control_1_long))));
% output.mean_vel_n_110_opto_control_1_long = sum(~isnan(output.mean_vel_dist_110_opto_control_1_long));
% 
% output.mean_vel_mean_110_opto_target_1_long = mean(output.mean_vel_dist_110_opto_target_1_long, "omitnan");
% output.mean_vel_sem_110_opto_target_1_long = std(output.mean_vel_dist_110_opto_target_1_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_target_1_long))));
% output.mean_vel_n_110_opto_target_1_long = sum(~isnan(output.mean_vel_dist_110_opto_target_1_long));
% 
% 
% 
% 
% 
% 
% output.mean_vel_dist_80_opto_control_2_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_short_index, 80:89), 2);
% output.mean_vel_dist_80_opto_target_2_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_short_index, 80:89), 2);
% output.mean_vel_dist_90_opto_control_2_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_short_index, 90:99), 2);
% output.mean_vel_dist_90_opto_target_2_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_short_index, 90:99), 2);
% output.mean_vel_dist_100_opto_control_2_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_short_index, 100:109), 2);
% output.mean_vel_dist_100_opto_target_2_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_short_index, 100:109), 2);
% output.mean_vel_dist_110_opto_control_2_short = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_short_index, 110:120), 2);
% output.mean_vel_dist_110_opto_target_2_short = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_short_index, 110:120), 2);
% 
% output.mean_vel_dist_80_opto_control_2_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_medium_index, 80:89), 2);
% output.mean_vel_dist_80_opto_target_2_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_medium_index, 80:89), 2);
% output.mean_vel_dist_90_opto_control_2_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_medium_index, 90:99), 2);
% output.mean_vel_dist_90_opto_target_2_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_medium_index, 90:99), 2);
% output.mean_vel_dist_100_opto_control_2_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_medium_index, 100:109), 2);
% output.mean_vel_dist_100_opto_target_2_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_medium_index, 100:109), 2);
% output.mean_vel_dist_110_opto_control_2_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_medium_index, 110:120), 2);
% output.mean_vel_dist_110_opto_target_2_medium = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_medium_index, 110:120), 2);
% 
% output.mean_vel_dist_80_opto_control_2_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_long_index, 80:89), 2);
% output.mean_vel_dist_80_opto_target_2_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_long_index, 80:89), 2);
% output.mean_vel_dist_90_opto_control_2_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_long_index, 90:99), 2);
% output.mean_vel_dist_90_opto_target_2_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_long_index, 90:99), 2);
% output.mean_vel_dist_100_opto_control_2_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_long_index, 100:109), 2);
% output.mean_vel_dist_100_opto_target_2_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_long_index, 100:109), 2);
% output.mean_vel_dist_110_opto_control_2_long = mean(movement_velocities_smooth_mean_dist(trials_opto_control_2_long_index, 110:120), 2);
% output.mean_vel_dist_110_opto_target_2_long = mean(movement_velocities_smooth_mean_dist(trials_opto_target_2_long_index, 110:120), 2);
% 
% 
% 
% output.mean_vel_mean_80_opto_control_2_short = mean(output.mean_vel_dist_80_opto_control_2_short, "omitnan");
% output.mean_vel_sem_80_opto_control_2_short = std(output.mean_vel_dist_80_opto_control_2_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_control_2_short))));
% output.mean_vel_n_80_opto_control_2_short = sum(~isnan(output.mean_vel_dist_80_opto_control_2_short));
% 
% output.mean_vel_mean_80_opto_target_2_short = mean(output.mean_vel_dist_80_opto_target_2_short, "omitnan");
% output.mean_vel_sem_80_opto_target_2_short = std(output.mean_vel_dist_80_opto_target_2_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_target_2_short))));
% output.mean_vel_n_80_opto_target_2_short = sum(~isnan(output.mean_vel_dist_80_opto_target_2_short));
% 
% output.mean_vel_mean_90_opto_control_2_short = mean(output.mean_vel_dist_90_opto_control_2_short, "omitnan");
% output.mean_vel_sem_90_opto_control_2_short = std(output.mean_vel_dist_90_opto_control_2_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_control_2_short))));
% output.mean_vel_n_90_opto_control_2_short = sum(~isnan(output.mean_vel_dist_90_opto_control_2_short));
% 
% output.mean_vel_mean_90_opto_target_2_short = mean(output.mean_vel_dist_90_opto_target_2_short, "omitnan");
% output.mean_vel_sem_90_opto_target_2_short = std(output.mean_vel_dist_90_opto_target_2_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_target_2_short))));
% output.mean_vel_n_90_opto_target_2_short = sum(~isnan(output.mean_vel_dist_90_opto_target_2_short));
% 
% output.mean_vel_mean_100_opto_control_2_short = mean(output.mean_vel_dist_100_opto_control_2_short, "omitnan");
% output.mean_vel_sem_100_opto_control_2_short = std(output.mean_vel_dist_100_opto_control_2_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_control_2_short))));
% output.mean_vel_n_100_opto_control_2_short = sum(~isnan(output.mean_vel_dist_100_opto_control_2_short));
% 
% output.mean_vel_mean_100_opto_target_2_short = mean(output.mean_vel_dist_100_opto_target_2_short, "omitnan");
% output.mean_vel_sem_100_opto_target_2_short = std(output.mean_vel_dist_100_opto_target_2_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_target_2_short))));
% output.mean_vel_n_100_opto_target_2_short = sum(~isnan(output.mean_vel_dist_100_opto_target_2_short));
% 
% output.mean_vel_mean_110_opto_control_2_short = mean(output.mean_vel_dist_110_opto_control_2_short, "omitnan");
% output.mean_vel_sem_110_opto_control_2_short = std(output.mean_vel_dist_110_opto_control_2_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_control_2_short))));
% output.mean_vel_n_110_opto_control_2_short = sum(~isnan(output.mean_vel_dist_110_opto_control_2_short));
% 
% output.mean_vel_mean_110_opto_target_2_short = mean(output.mean_vel_dist_110_opto_target_2_short, "omitnan");
% output.mean_vel_sem_110_opto_target_2_short = std(output.mean_vel_dist_110_opto_target_2_short, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_target_2_short))));
% output.mean_vel_n_110_opto_target_2_short = sum(~isnan(output.mean_vel_dist_110_opto_target_2_short));
% 
% 
% 
% % Medium
% 
% output.mean_vel_mean_80_opto_control_2_medium = mean(output.mean_vel_dist_80_opto_control_2_medium, "omitnan");
% output.mean_vel_sem_80_opto_control_2_medium = std(output.mean_vel_dist_80_opto_control_2_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_control_2_medium))));
% output.mean_vel_n_80_opto_control_2_medium = sum(~isnan(output.mean_vel_dist_80_opto_control_2_medium));
% 
% output.mean_vel_mean_80_opto_target_2_medium = mean(output.mean_vel_dist_80_opto_target_2_medium, "omitnan");
% output.mean_vel_sem_80_opto_target_2_medium = std(output.mean_vel_dist_80_opto_target_2_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_target_2_medium))));
% output.mean_vel_n_80_opto_target_2_medium = sum(~isnan(output.mean_vel_dist_80_opto_target_2_medium));
% 
% output.mean_vel_mean_90_opto_control_2_medium = mean(output.mean_vel_dist_90_opto_control_2_medium, "omitnan");
% output.mean_vel_sem_90_opto_control_2_medium = std(output.mean_vel_dist_90_opto_control_2_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_control_2_medium))));
% output.mean_vel_n_90_opto_control_2_medium = sum(~isnan(output.mean_vel_dist_90_opto_control_2_medium));
% 
% output.mean_vel_mean_90_opto_target_2_medium = mean(output.mean_vel_dist_90_opto_target_2_medium, "omitnan");
% output.mean_vel_sem_90_opto_target_2_medium = std(output.mean_vel_dist_90_opto_target_2_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_target_2_medium))));
% output.mean_vel_n_90_opto_target_2_medium = sum(~isnan(output.mean_vel_dist_90_opto_target_2_medium));
% 
% output.mean_vel_mean_100_opto_control_2_medium = mean(output.mean_vel_dist_100_opto_control_2_medium, "omitnan");
% output.mean_vel_sem_100_opto_control_2_medium = std(output.mean_vel_dist_100_opto_control_2_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_control_2_medium))));
% output.mean_vel_n_100_opto_control_2_medium = sum(~isnan(output.mean_vel_dist_100_opto_control_2_medium));
% 
% output.mean_vel_mean_100_opto_target_2_medium = mean(output.mean_vel_dist_100_opto_target_2_medium, "omitnan");
% output.mean_vel_sem_100_opto_target_2_medium = std(output.mean_vel_dist_100_opto_target_2_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_target_2_medium))));
% output.mean_vel_n_100_opto_target_2_medium = sum(~isnan(output.mean_vel_dist_100_opto_target_2_medium));
% 
% output.mean_vel_mean_110_opto_control_2_medium = mean(output.mean_vel_dist_110_opto_control_2_medium, "omitnan");
% output.mean_vel_sem_110_opto_control_2_medium = std(output.mean_vel_dist_110_opto_control_2_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_control_2_medium))));
% output.mean_vel_n_110_opto_control_2_medium = sum(~isnan(output.mean_vel_dist_110_opto_control_2_medium));
% 
% output.mean_vel_mean_110_opto_target_2_medium = mean(output.mean_vel_dist_110_opto_target_2_medium, "omitnan");
% output.mean_vel_sem_110_opto_target_2_medium = std(output.mean_vel_dist_110_opto_target_2_medium, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_target_2_medium))));
% output.mean_vel_n_110_opto_target_2_medium = sum(~isnan(output.mean_vel_dist_110_opto_target_2_medium));
% 
% 
% 
% % long
% 
% output.mean_vel_mean_80_opto_control_2_long = mean(output.mean_vel_dist_80_opto_control_2_long, "omitnan");
% output.mean_vel_sem_80_opto_control_2_long = std(output.mean_vel_dist_80_opto_control_2_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_control_2_long))));
% output.mean_vel_n_80_opto_control_2_long = sum(~isnan(output.mean_vel_dist_80_opto_control_2_long));
% 
% output.mean_vel_mean_80_opto_target_2_long = mean(output.mean_vel_dist_80_opto_target_2_long, "omitnan");
% output.mean_vel_sem_80_opto_target_2_long = std(output.mean_vel_dist_80_opto_target_2_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_80_opto_target_2_long))));
% output.mean_vel_n_80_opto_target_2_long = sum(~isnan(output.mean_vel_dist_80_opto_target_2_long));
% 
% output.mean_vel_mean_90_opto_control_2_long = mean(output.mean_vel_dist_90_opto_control_2_long, "omitnan");
% output.mean_vel_sem_90_opto_control_2_long = std(output.mean_vel_dist_90_opto_control_2_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_control_2_long))));
% output.mean_vel_n_90_opto_control_2_long = sum(~isnan(output.mean_vel_dist_90_opto_control_2_long));
% 
% output.mean_vel_mean_90_opto_target_2_long = mean(output.mean_vel_dist_90_opto_target_2_long, "omitnan");
% output.mean_vel_sem_90_opto_target_2_long = std(output.mean_vel_dist_90_opto_target_2_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_90_opto_target_2_long))));
% output.mean_vel_n_90_opto_target_2_long = sum(~isnan(output.mean_vel_dist_90_opto_target_2_long));
% 
% output.mean_vel_mean_100_opto_control_2_long = mean(output.mean_vel_dist_100_opto_control_2_long, "omitnan");
% output.mean_vel_sem_100_opto_control_2_long = std(output.mean_vel_dist_100_opto_control_2_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_control_2_long))));
% output.mean_vel_n_100_opto_control_2_long = sum(~isnan(output.mean_vel_dist_100_opto_control_2_long));
% 
% output.mean_vel_mean_100_opto_target_2_long = mean(output.mean_vel_dist_100_opto_target_2_long, "omitnan");
% output.mean_vel_sem_100_opto_target_2_long = std(output.mean_vel_dist_100_opto_target_2_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_100_opto_target_2_long))));
% output.mean_vel_n_100_opto_target_2_long = sum(~isnan(output.mean_vel_dist_100_opto_target_2_long));
% 
% output.mean_vel_mean_110_opto_control_2_long = mean(output.mean_vel_dist_110_opto_control_2_long, "omitnan");
% output.mean_vel_sem_110_opto_control_2_long = std(output.mean_vel_dist_110_opto_control_2_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_control_2_long))));
% output.mean_vel_n_110_opto_control_2_long = sum(~isnan(output.mean_vel_dist_110_opto_control_2_long));
% 
% output.mean_vel_mean_110_opto_target_2_long = mean(output.mean_vel_dist_110_opto_target_2_long, "omitnan");
% output.mean_vel_sem_110_opto_target_2_long = std(output.mean_vel_dist_110_opto_target_2_long, "omitnan") / (sqrt(sum(~isnan(output.mean_vel_dist_110_opto_target_2_long))));
% output.mean_vel_n_110_opto_target_2_long = sum(~isnan(output.mean_vel_dist_110_opto_target_2_long));
% 
% 
%     else
% 
%         output.low_vel_dist_short_hist_control_1_mean = NaN;
%         output.low_vel_dist_short_hist_target_1_mean = NaN;
%         output.low_vel_dist_medium_hist_control_1_mean = NaN;
%         output.low_vel_dist_medium_hist_target_1_mean = NaN;
%         output.low_vel_dist_long_hist_control_1_mean = NaN;
%         output.low_vel_dist_long_hist_target_1_mean = NaN;
%         output.low_vel_dist_long_hist_control_2_mean = NaN;
%         output.low_vel_dist_long_hist_target_2_mean = NaN;
%         output.low_vel_dist_long_hist_control_2_mean = NaN;
%         output.low_vel_dist_long_hist_target_2_mean = NaN; 
%         output.low_vel_dist_long_hist_control_2_mean = NaN;
%         output.low_vel_dist_long_hist_target_2_mean = NaN; 
% 
%         output.low_vel_dist_short_hist_control_1_median = NaN;
%         output.low_vel_dist_short_hist_target_1_median = NaN;
%         output.low_vel_dist_medium_hist_control_1_median = NaN;
%         output.low_vel_dist_medium_hist_target_1_median = NaN;
%         output.low_vel_dist_long_hist_control_1_median = NaN;
%         output.low_vel_dist_long_hist_target_1_median = NaN;
%         output.low_vel_dist_long_hist_control_2_median = NaN;
%         output.low_vel_dist_long_hist_target_2_median = NaN;
%         output.low_vel_dist_long_hist_control_2_median = NaN;
%         output.low_vel_dist_long_hist_target_2_median = NaN; 
%         output.low_vel_dist_long_hist_control_2_median = NaN;
%         output.low_vel_dist_long_hist_target_2_median = NaN; 
% 
%         output.low_vel_dist_short_hist_control_1_parameters = NaN;
%         output.low_vel_dist_short_hist_target_1_parameters = NaN;
%         output.low_vel_dist_medium_hist_control_1_parameters = NaN;
%         output.low_vel_dist_medium_hist_target_1_parameters = NaN;
%         output.low_vel_dist_long_hist_control_1_parameters = NaN;
%         output.low_vel_dist_long_hist_target_1_parameters = NaN;
%         output.low_vel_dist_long_hist_control_2_parameters = NaN;
%         output.low_vel_dist_long_hist_target_2_parameters = NaN;  
%         output.low_vel_dist_long_hist_control_2_parameters = NaN;
%         output.low_vel_dist_long_hist_target_2_parameters = NaN; 
%         output.low_vel_dist_long_hist_control_2_parameters = NaN;
%         output.low_vel_dist_long_hist_target_2_parameters = NaN;  
% 
%         output.low_vel_dist_short_hist_control_1 = NaN;
%         output.low_vel_dist_short_hist_target_1 = NaN;                              
%         output.low_vel_dist_medium_hist_control_1 = NaN;
%         output.low_vel_dist_medium_hist_target_1 = NaN;          
%         output.low_vel_dist_long_hist_control_1 = NaN;
%         output.low_vel_dist_long_hist_target_1 = NaN;      
% 
%         output.low_vel_dist_short_hist_control_2 = NaN;
%         output.low_vel_dist_short_hist_target_2 = NaN;                              
%         output.low_vel_dist_medium_hist_control_2 = NaN;
%         output.low_vel_dist_medium_hist_target_2 = NaN;          
%         output.low_vel_dist_long_hist_control_2 = NaN;
%         output.low_vel_dist_long_hist_target_2 = NaN;    
% 
%         output.mean_vel_dist_40_opto_control_1_short = NaN;
%         output.mean_vel_dist_40_opto_target_1_short = NaN;
%         output.mean_vel_dist_50_opto_control_1_short = NaN;
%         output.mean_vel_dist_50_opto_target_1_short = NaN;
%         output.mean_vel_dist_60_opto_control_1_short = NaN;
%         output.mean_vel_dist_60_opto_target_1_short = NaN;
%         output.mean_vel_dist_70_opto_control_1_short = NaN;
%         output.mean_vel_dist_70_opto_target_1_short = NaN;
%         output.mean_vel_dist_80_opto_control_1_short = NaN;
%         output.mean_vel_dist_80_opto_target_1_short = NaN;
%         output.mean_vel_dist_90_opto_control_1_short = NaN;
%         output.mean_vel_dist_90_opto_target_1_short = NaN;
%         output.mean_vel_dist_100_opto_control_1_short = NaN;
%         output.mean_vel_dist_100_opto_target_1_short = NaN;
%         output.mean_vel_dist_110_opto_control_1_short = NaN;
%         output.mean_vel_dist_110_opto_target_1_short = NaN;
%         output.mean_vel_dist_40_opto_control_1_medium = NaN;
%         output.mean_vel_dist_40_opto_target_1_medium = NaN;
%         output.mean_vel_dist_50_opto_control_1_medium = NaN;
%         output.mean_vel_dist_50_opto_target_1_medium = NaN;
%         output.mean_vel_dist_60_opto_control_1_medium = NaN;
%         output.mean_vel_dist_60_opto_target_1_medium = NaN;
%         output.mean_vel_dist_70_opto_control_1_medium = NaN;
%         output.mean_vel_dist_70_opto_target_1_medium = NaN;
%         output.mean_vel_dist_80_opto_control_1_medium = NaN;
%         output.mean_vel_dist_80_opto_target_1_medium = NaN;
%         output.mean_vel_dist_90_opto_control_1_medium = NaN;
%         output.mean_vel_dist_90_opto_target_1_medium = NaN;
%         output.mean_vel_dist_100_opto_control_1_medium = NaN;
%         output.mean_vel_dist_100_opto_target_1_medium = NaN;
%         output.mean_vel_dist_110_opto_control_1_medium = NaN;
%         output.mean_vel_dist_110_opto_target_1_medium = NaN;
%         output.mean_vel_dist_40_opto_control_1_long = NaN;
%         output.mean_vel_dist_40_opto_target_1_long = NaN;
%         output.mean_vel_dist_50_opto_control_1_long = NaN;
%         output.mean_vel_dist_50_opto_target_1_long = NaN;
%         output.mean_vel_dist_60_opto_control_1_long = NaN;
%         output.mean_vel_dist_60_opto_target_1_long = NaN;
%         output.mean_vel_dist_70_opto_control_1_long = NaN;
%         output.mean_vel_dist_70_opto_target_1_long = NaN;
%         output.mean_vel_dist_80_opto_control_1_long = NaN;
%         output.mean_vel_dist_80_opto_target_1_long = NaN;
%         output.mean_vel_dist_90_opto_control_1_long = NaN;
%         output.mean_vel_dist_90_opto_target_1_long = NaN;
%         output.mean_vel_dist_100_opto_control_1_long = NaN;
%         output.mean_vel_dist_100_opto_target_1_long = NaN;
%         output.mean_vel_dist_110_opto_control_1_long = NaN;
%         output.mean_vel_dist_110_opto_target_1_long = NaN;
% 
%         output.mean_vel_mean_40_opto_control_1_short = NaN;
%         output.mean_vel_sem_40_opto_control_1_short = NaN;
%         output.mean_vel_n_40_opto_control_1_short = NaN;
%         output.mean_vel_mean_40_opto_target_1_short = NaN;
%         output.mean_vel_sem_40_opto_target_1_short = NaN;
%         output.mean_vel_n_40_opto_target_1_short = NaN;
%         output.mean_vel_mean_50_opto_control_1_short = NaN;
%         output.mean_vel_sem_50_opto_control_1_short = NaN;
%         output.mean_vel_n_50_opto_control_1_short = NaN;
%         output.mean_vel_mean_50_opto_target_1_short = NaN;
%         output.mean_vel_sem_50_opto_target_1_short = NaN;
%         output.mean_vel_n_50_opto_target_1_short = NaN;
%         output.mean_vel_mean_60_opto_control_1_short = NaN;
%         output.mean_vel_sem_60_opto_control_1_short = NaN;
%         output.mean_vel_n_60_opto_control_1_short = NaN;
%         output.mean_vel_mean_60_opto_target_1_short = NaN;
%         output.mean_vel_sem_60_opto_target_1_short = NaN;
%         output.mean_vel_n_60_opto_target_1_short = NaN;
%         output.mean_vel_mean_70_opto_control_1_short = NaN;
%         output.mean_vel_sem_70_opto_control_1_short = NaN;
%         output.mean_vel_n_70_opto_control_1_short = NaN;
%         output.mean_vel_mean_70_opto_target_1_short = NaN;
%         output.mean_vel_sem_70_opto_target_1_short = NaN;
%         output.mean_vel_n_70_opto_target_1_short = NaN;
%         output.mean_vel_mean_80_opto_control_1_short = NaN;
%         output.mean_vel_sem_80_opto_control_1_short = NaN;
%         output.mean_vel_n_80_opto_control_1_short = NaN;
%         output.mean_vel_mean_80_opto_target_1_short = NaN;
%         output.mean_vel_sem_80_opto_target_1_short = NaN;
%         output.mean_vel_n_80_opto_target_1_short = NaN;
%         output.mean_vel_mean_90_opto_control_1_short = NaN;
%         output.mean_vel_sem_90_opto_control_1_short = NaN;
%         output.mean_vel_n_90_opto_control_1_short = NaN;
%         output.mean_vel_mean_90_opto_target_1_short = NaN;
%         output.mean_vel_sem_90_opto_target_1_short = NaN;
%         output.mean_vel_n_90_opto_target_1_short = NaN;
%         output.mean_vel_mean_100_opto_control_1_short = NaN;
%         output.mean_vel_sem_100_opto_control_1_short = NaN;
%         output.mean_vel_n_100_opto_control_1_short = NaN;
%         output.mean_vel_mean_100_opto_target_1_short = NaN;
%         output.mean_vel_sem_100_opto_target_1_short = NaN;
%         output.mean_vel_n_100_opto_target_1_short = NaN;
%         output.mean_vel_mean_110_opto_control_1_short = NaN;
%         output.mean_vel_sem_110_opto_control_1_short = NaN;
%         output.mean_vel_n_110_opto_control_1_short = NaN;
%         output.mean_vel_mean_110_opto_target_1_short = NaN;
%         output.mean_vel_sem_110_opto_target_1_short = NaN;
%         output.mean_vel_n_110_opto_target_1_short = NaN;
%         output.mean_vel_mean_40_opto_control_1_medium = NaN;
%         output.mean_vel_sem_40_opto_control_1_medium = NaN;
%         output.mean_vel_n_40_opto_control_1_medium = NaN;
%         output.mean_vel_mean_40_opto_target_1_medium = NaN;
%         output.mean_vel_sem_40_opto_target_1_medium = NaN;
%         output.mean_vel_n_40_opto_target_1_medium = NaN;
%         output.mean_vel_mean_50_opto_control_1_medium = NaN;
%         output.mean_vel_sem_50_opto_control_1_medium = NaN;
%         output.mean_vel_n_50_opto_control_1_medium = NaN;
%         output.mean_vel_mean_50_opto_target_1_medium = NaN;
%         output.mean_vel_sem_50_opto_target_1_medium = NaN;
%         output.mean_vel_n_50_opto_target_1_medium = NaN;
%         output.mean_vel_mean_60_opto_control_1_medium = NaN;
%         output.mean_vel_sem_60_opto_control_1_medium = NaN;
%         output.mean_vel_n_60_opto_control_1_medium = NaN;
%         output.mean_vel_mean_60_opto_target_1_medium = NaN;
%         output.mean_vel_sem_60_opto_target_1_medium = NaN;
%         output.mean_vel_n_60_opto_target_1_medium = NaN;
%         output.mean_vel_mean_70_opto_control_1_medium = NaN;
%         output.mean_vel_sem_70_opto_control_1_medium = NaN;
%         output.mean_vel_n_70_opto_control_1_medium = NaN;
%         output.mean_vel_mean_70_opto_target_1_medium = NaN;
%         output.mean_vel_sem_70_opto_target_1_medium = NaN;
%         output.mean_vel_n_70_opto_target_1_medium = NaN;
%         output.mean_vel_mean_80_opto_control_1_medium = NaN;
%         output.mean_vel_sem_80_opto_control_1_medium = NaN;
%         output.mean_vel_n_80_opto_control_1_medium = NaN;
%         output.mean_vel_mean_80_opto_target_1_medium = NaN;
%         output.mean_vel_sem_80_opto_target_1_medium = NaN;
%         output.mean_vel_n_80_opto_target_1_medium = NaN;
%         output.mean_vel_mean_90_opto_control_1_medium = NaN;
%         output.mean_vel_sem_90_opto_control_1_medium = NaN;
%         output.mean_vel_n_90_opto_control_1_medium = NaN;
%         output.mean_vel_mean_90_opto_target_1_medium = NaN;
%         output.mean_vel_sem_90_opto_target_1_medium = NaN;
%         output.mean_vel_n_90_opto_target_1_medium = NaN;
%         output.mean_vel_mean_100_opto_control_1_medium = NaN;
%         output.mean_vel_sem_100_opto_control_1_medium = NaN;
%         output.mean_vel_n_100_opto_control_1_medium = NaN;
%         output.mean_vel_mean_100_opto_target_1_medium = NaN;
%         output.mean_vel_sem_100_opto_target_1_medium = NaN;
%         output.mean_vel_n_100_opto_target_1_medium = NaN;
%         output.mean_vel_mean_110_opto_control_1_medium = NaN;
%         output.mean_vel_sem_110_opto_control_1_medium = NaN;
%         output.mean_vel_n_110_opto_control_1_medium = NaN;
%         output.mean_vel_mean_110_opto_target_1_medium = NaN;
%         output.mean_vel_sem_110_opto_target_1_medium = NaN;
%         output.mean_vel_n_110_opto_target_1_medium = NaN;
%         output.mean_vel_mean_40_opto_control_1_long = NaN;
%         output.mean_vel_sem_40_opto_control_1_long = NaN;
%         output.mean_vel_n_40_opto_control_1_long = NaN;
%         output.mean_vel_mean_40_opto_target_1_long = NaN;
%         output.mean_vel_sem_40_opto_target_1_long = NaN;
%         output.mean_vel_n_40_opto_target_1_long = NaN;
%         output.mean_vel_mean_50_opto_control_1_long = NaN;
%         output.mean_vel_sem_50_opto_control_1_long = NaN;
%         output.mean_vel_n_50_opto_control_1_long = NaN;
%         output.mean_vel_mean_50_opto_target_1_long = NaN;
%         output.mean_vel_sem_50_opto_target_1_long = NaN;
%         output.mean_vel_n_50_opto_target_1_long = NaN;
%         output.mean_vel_mean_60_opto_control_1_long = NaN;
%         output.mean_vel_sem_60_opto_control_1_long = NaN;
%         output.mean_vel_n_60_opto_control_1_long = NaN;
%         output.mean_vel_mean_60_opto_target_1_long = NaN;
%         output.mean_vel_sem_60_opto_target_1_long = NaN;
%         output.mean_vel_n_60_opto_target_1_long = NaN;
%         output.mean_vel_mean_70_opto_control_1_long = NaN;
%         output.mean_vel_sem_70_opto_control_1_long = NaN;
%         output.mean_vel_n_70_opto_control_1_long = NaN;
%         output.mean_vel_mean_70_opto_target_1_long = NaN;
%         output.mean_vel_sem_70_opto_target_1_long = NaN;
%         output.mean_vel_n_70_opto_target_1_long = NaN;
%         output.mean_vel_mean_80_opto_control_1_long = NaN;
%         output.mean_vel_sem_80_opto_control_1_long = NaN;
%         output.mean_vel_n_80_opto_control_1_long = NaN;
%         output.mean_vel_mean_80_opto_target_1_long = NaN;
%         output.mean_vel_sem_80_opto_target_1_long = NaN;
%         output.mean_vel_n_80_opto_target_1_long = NaN;
%         output.mean_vel_mean_90_opto_control_1_long = NaN;
%         output.mean_vel_sem_90_opto_control_1_long = NaN;
%         output.mean_vel_n_90_opto_control_1_long = NaN;
%         output.mean_vel_mean_90_opto_target_1_long = NaN;
%         output.mean_vel_sem_90_opto_target_1_long = NaN;
%         output.mean_vel_n_90_opto_target_1_long = NaN;
%         output.mean_vel_mean_100_opto_control_1_long = NaN; 
%         output.mean_vel_sem_100_opto_control_1_long = NaN;
%         output.mean_vel_n_100_opto_control_1_long = NaN;
%         output.mean_vel_mean_100_opto_target_1_long = NaN;
%         output.mean_vel_sem_100_opto_target_1_long = NaN;
%         output.mean_vel_n_100_opto_target_1_long = NaN;
%         output.mean_vel_mean_110_opto_control_1_long = NaN;
%         output.mean_vel_sem_110_opto_control_1_long = NaN;
%         output.mean_vel_n_110_opto_control_1_long = NaN;
%         output.mean_vel_mean_110_opto_target_1_long =NaN;
%         output.mean_vel_sem_110_opto_target_1_long = NaN;
%         output.mean_vel_n_110_opto_target_1_long = NaN;
% 
%         output.mean_vel_dist_40_opto_control_1_short = NaN;
%         output.mean_vel_dist_40_opto_target_1_short = NaN;
%         output.mean_vel_dist_50_opto_control_1_short = NaN;
%         output.mean_vel_dist_50_opto_target_1_short = NaN;
%         output.mean_vel_dist_60_opto_control_1_short = NaN;
%         output.mean_vel_dist_60_opto_target_1_short = NaN;
%         output.mean_vel_dist_70_opto_control_1_short = NaN;
%         output.mean_vel_dist_70_opto_target_1_short = NaN;
%         output.mean_vel_dist_80_opto_control_1_short = NaN;
%         output.mean_vel_dist_80_opto_target_1_short = NaN;
%         output.mean_vel_dist_90_opto_control_1_short = NaN;
%         output.mean_vel_dist_90_opto_target_1_short = NaN;
%         output.mean_vel_dist_100_opto_control_1_short = NaN;
%         output.mean_vel_dist_100_opto_target_1_short = NaN;
%         output.mean_vel_dist_110_opto_control_1_short = NaN;
%         output.mean_vel_dist_110_opto_target_1_short = NaN;
%         output.mean_vel_dist_40_opto_control_1_medium = NaN;
%         output.mean_vel_dist_40_opto_target_1_medium = NaN;
%         output.mean_vel_dist_50_opto_control_1_medium = NaN;
%         output.mean_vel_dist_50_opto_target_1_medium = NaN;
%         output.mean_vel_dist_60_opto_control_1_medium = NaN;
%         output.mean_vel_dist_60_opto_target_1_medium = NaN;
%         output.mean_vel_dist_70_opto_control_1_medium = NaN;
%         output.mean_vel_dist_70_opto_target_1_medium = NaN;
%         output.mean_vel_dist_80_opto_control_1_medium = NaN;
%         output.mean_vel_dist_80_opto_target_1_medium = NaN;
%         output.mean_vel_dist_90_opto_control_1_medium = NaN;
%         output.mean_vel_dist_90_opto_target_1_medium = NaN;
%         output.mean_vel_dist_100_opto_control_1_medium = NaN;
%         output.mean_vel_dist_100_opto_target_1_medium = NaN;
%         output.mean_vel_dist_110_opto_control_1_medium = NaN;
%         output.mean_vel_dist_110_opto_target_1_medium = NaN;
%         output.mean_vel_dist_40_opto_control_1_long = NaN;
%         output.mean_vel_dist_40_opto_target_1_long = NaN;
%         output.mean_vel_dist_50_opto_control_1_long = NaN;
%         output.mean_vel_dist_50_opto_target_1_long = NaN;
%         output.mean_vel_dist_60_opto_control_1_long = NaN;
%         output.mean_vel_dist_60_opto_target_1_long = NaN;
%         output.mean_vel_dist_70_opto_control_1_long = NaN;
%         output.mean_vel_dist_70_opto_target_1_long = NaN;
%         output.mean_vel_dist_80_opto_control_1_long = NaN;
%         output.mean_vel_dist_80_opto_target_1_long = NaN;
%         output.mean_vel_dist_90_opto_control_1_long = NaN;
%         output.mean_vel_dist_90_opto_target_1_long = NaN;
%         output.mean_vel_dist_100_opto_control_1_long = NaN;
%         output.mean_vel_dist_100_opto_target_1_long = NaN;
%         output.mean_vel_dist_110_opto_control_1_long = NaN;
%         output.mean_vel_dist_110_opto_target_1_long = NaN;
% 
%         output.mean_vel_mean_80_opto_control_1_short = NaN;
%         output.mean_vel_sem_80_opto_control_1_short = NaN;
%         output.mean_vel_n_80_opto_control_1_short = NaN;
%         output.mean_vel_mean_80_opto_target_1_short = NaN;
%         output.mean_vel_sem_80_opto_target_1_short = NaN;
%         output.mean_vel_n_80_opto_target_1_short = NaN;
%         output.mean_vel_mean_90_opto_control_1_short = NaN;
%         output.mean_vel_sem_90_opto_control_1_short = NaN;
%         output.mean_vel_n_90_opto_control_1_short = NaN;
%         output.mean_vel_mean_90_opto_target_1_short = NaN;
%         output.mean_vel_sem_90_opto_target_1_short = NaN;
%         output.mean_vel_n_90_opto_target_1_short = NaN;
%         output.mean_vel_mean_100_opto_control_1_short = NaN;
%         output.mean_vel_sem_100_opto_control_1_short = NaN;
%         output.mean_vel_n_100_opto_control_1_short = NaN;
%         output.mean_vel_mean_100_opto_target_1_short = NaN;
%         output.mean_vel_sem_100_opto_target_1_short = NaN;
%         output.mean_vel_n_100_opto_target_1_short = NaN;
%         output.mean_vel_mean_110_opto_control_1_short = NaN;
%         output.mean_vel_sem_110_opto_control_1_short = NaN;
%         output.mean_vel_n_110_opto_control_1_short = NaN;
%         output.mean_vel_mean_110_opto_target_1_short = NaN;
%         output.mean_vel_sem_110_opto_target_1_short = NaN;
%         output.mean_vel_n_110_opto_target_1_short = NaN;
% 
%         output.mean_vel_mean_80_opto_control_1_medium = NaN;
%         output.mean_vel_sem_80_opto_control_1_medium = NaN;
%         output.mean_vel_n_80_opto_control_1_medium = NaN;
%         output.mean_vel_mean_80_opto_target_1_medium = NaN;
%         output.mean_vel_sem_80_opto_target_1_medium = NaN;
%         output.mean_vel_n_80_opto_target_1_medium = NaN;
%         output.mean_vel_mean_90_opto_control_1_medium = NaN;
%         output.mean_vel_sem_90_opto_control_1_medium = NaN;
%         output.mean_vel_n_90_opto_control_1_medium = NaN;
%         output.mean_vel_mean_90_opto_target_1_medium = NaN;
%         output.mean_vel_sem_90_opto_target_1_medium = NaN;
%         output.mean_vel_n_90_opto_target_1_medium = NaN;
%         output.mean_vel_mean_100_opto_control_1_medium = NaN;
%         output.mean_vel_sem_100_opto_control_1_medium = NaN;
%         output.mean_vel_n_100_opto_control_1_medium = NaN;
%         output.mean_vel_mean_100_opto_target_1_medium = NaN;
%         output.mean_vel_sem_100_opto_target_1_medium = NaN;
%         output.mean_vel_n_100_opto_target_1_medium = NaN;
%         output.mean_vel_mean_110_opto_control_1_medium = NaN;
%         output.mean_vel_sem_110_opto_control_1_medium = NaN;
%         output.mean_vel_n_110_opto_control_1_medium = NaN;
%         output.mean_vel_mean_110_opto_target_1_medium = NaN;
%         output.mean_vel_sem_110_opto_target_1_medium = NaN;
%         output.mean_vel_n_110_opto_target_1_medium = NaN;
% 
%         output.mean_vel_mean_80_opto_control_1_long = NaN;
%         output.mean_vel_sem_80_opto_control_1_long = NaN;
%         output.mean_vel_n_80_opto_control_1_long = NaN;
%         output.mean_vel_mean_80_opto_target_1_long = NaN;
%         output.mean_vel_sem_80_opto_target_1_long = NaN;
%         output.mean_vel_n_80_opto_target_1_long = NaN;
%         output.mean_vel_mean_90_opto_control_1_long = NaN;
%         output.mean_vel_sem_90_opto_control_1_long = NaN;
%         output.mean_vel_n_90_opto_control_1_long = NaN;
%         output.mean_vel_mean_90_opto_target_1_long = NaN;
%         output.mean_vel_sem_90_opto_target_1_long = NaN;
%         output.mean_vel_n_90_opto_target_1_long = NaN;
%         output.mean_vel_mean_100_opto_control_1_long = NaN; 
%         output.mean_vel_sem_100_opto_control_1_long = NaN;
%         output.mean_vel_n_100_opto_control_1_long = NaN;
%         output.mean_vel_mean_100_opto_target_1_long = NaN;
%         output.mean_vel_sem_100_opto_target_1_long = NaN;
%         output.mean_vel_n_100_opto_target_1_long = NaN;
%         output.mean_vel_mean_110_opto_control_1_long = NaN;
%         output.mean_vel_sem_110_opto_control_1_long = NaN;
%         output.mean_vel_n_110_opto_control_1_long = NaN;
%         output.mean_vel_mean_110_opto_target_1_long =NaN;
%         output.mean_vel_sem_110_opto_target_1_long = NaN;
%         output.mean_vel_n_110_opto_target_1_long = NaN;
% 
% output.mean_vel_dist_100_opto_control_2_long = NaN;
% output.mean_vel_dist_100_opto_control_2_medium = NaN;
% output.mean_vel_dist_100_opto_control_2_short = NaN;
% output.mean_vel_dist_100_opto_target_2_long = NaN;
% output.mean_vel_dist_100_opto_target_2_medium = NaN;
% output.mean_vel_dist_100_opto_target_2_short = NaN;
% output.mean_vel_dist_110_opto_control_2_long = NaN;
% output.mean_vel_dist_110_opto_control_2_medium = NaN;
% output.mean_vel_dist_110_opto_control_2_short = NaN;
% output.mean_vel_dist_110_opto_target_2_long = NaN;
% output.mean_vel_dist_110_opto_target_2_medium = NaN;
% output.mean_vel_dist_110_opto_target_2_short = NaN;
% output.mean_vel_dist_80_opto_control_2_long = NaN;
% output.mean_vel_dist_80_opto_control_2_medium = NaN;
% output.mean_vel_dist_80_opto_control_2_short = NaN;
% output.mean_vel_dist_80_opto_target_2_long = NaN;
% output.mean_vel_dist_80_opto_target_2_medium = NaN;
% output.mean_vel_dist_80_opto_target_2_short = NaN;
% output.mean_vel_dist_90_opto_control_2_long = NaN;
% output.mean_vel_dist_90_opto_control_2_medium = NaN;
% output.mean_vel_dist_90_opto_control_2_short = NaN;
% output.mean_vel_dist_90_opto_target_2_long = NaN;
% output.mean_vel_dist_90_opto_target_2_medium = NaN;
% output.mean_vel_dist_90_opto_target_2_short = NaN;
% output.mean_vel_mean_100_opto_control_2_long = NaN;
% output.mean_vel_mean_100_opto_control_2_medium = NaN;
% output.mean_vel_mean_100_opto_control_2_short = NaN;
% output.mean_vel_mean_100_opto_target_2_long = NaN;
% output.mean_vel_mean_100_opto_target_2_medium = NaN;
% output.mean_vel_mean_100_opto_target_2_short = NaN;
% output.mean_vel_mean_110_opto_control_2_long = NaN;
% output.mean_vel_mean_110_opto_control_2_medium = NaN;
% output.mean_vel_mean_110_opto_control_2_short = NaN;
% output.mean_vel_mean_110_opto_target_2_long = NaN;
% output.mean_vel_mean_110_opto_target_2_medium = NaN;
% output.mean_vel_mean_110_opto_target_2_short = NaN;
% output.mean_vel_mean_80_opto_control_2_long = NaN;
% output.mean_vel_mean_80_opto_control_2_medium = NaN;
% output.mean_vel_mean_80_opto_control_2_short = NaN;
% output.mean_vel_mean_80_opto_target_2_long = NaN;
% output.mean_vel_mean_80_opto_target_2_medium = NaN;
% output.mean_vel_mean_80_opto_target_2_short = NaN;
% output.mean_vel_mean_90_opto_control_2_long = NaN;
% output.mean_vel_mean_90_opto_control_2_medium = NaN;
% output.mean_vel_mean_90_opto_control_2_short = NaN;
% output.mean_vel_mean_90_opto_target_2_long = NaN;
% output.mean_vel_mean_90_opto_target_2_medium = NaN;
% output.mean_vel_mean_90_opto_target_2_short = NaN;
% output.mean_vel_n_100_opto_control_2_long = NaN;
% output.mean_vel_n_100_opto_control_2_medium = NaN;
% output.mean_vel_n_100_opto_control_2_short = NaN;
% output.mean_vel_n_100_opto_target_2_long = NaN;
% output.mean_vel_n_100_opto_target_2_medium = NaN;
% output.mean_vel_n_100_opto_target_2_short = NaN;
% output.mean_vel_n_110_opto_control_2_long = NaN;
% output.mean_vel_n_110_opto_control_2_medium = NaN;
% output.mean_vel_n_110_opto_control_2_short = NaN;
% output.mean_vel_n_110_opto_target_2_long = NaN;
% output.mean_vel_n_110_opto_target_2_medium = NaN;
% output.mean_vel_n_110_opto_target_2_short = NaN;
% output.mean_vel_n_80_opto_control_2_long = NaN;
% output.mean_vel_n_80_opto_control_2_medium = NaN;
% output.mean_vel_n_80_opto_control_2_short = NaN;
% output.mean_vel_n_80_opto_target_2_long = NaN;
% output.mean_vel_n_80_opto_target_2_medium = NaN;
% output.mean_vel_n_80_opto_target_2_short = NaN;
% output.mean_vel_n_90_opto_control_2_long = NaN;
% output.mean_vel_n_90_opto_control_2_medium = NaN;
% output.mean_vel_n_90_opto_control_2_short = NaN;
% output.mean_vel_n_90_opto_target_2_long = NaN;
% output.mean_vel_n_90_opto_target_2_medium = NaN;
% output.mean_vel_n_90_opto_target_2_short = NaN;
% output.mean_vel_sem_100_opto_control_2_long = NaN;
% output.mean_vel_sem_100_opto_control_2_medium = NaN;
% output.mean_vel_sem_100_opto_control_2_short = NaN;
% output.mean_vel_sem_100_opto_target_2_long = NaN;
% output.mean_vel_sem_100_opto_target_2_medium = NaN;
% output.mean_vel_sem_100_opto_target_2_short = NaN;
% output.mean_vel_sem_110_opto_control_2_long = NaN;
% output.mean_vel_sem_110_opto_control_2_medium = NaN;
% output.mean_vel_sem_110_opto_control_2_short = NaN;
% output.mean_vel_sem_110_opto_target_2_long = NaN;
% output.mean_vel_sem_110_opto_target_2_medium = NaN;
% output.mean_vel_sem_110_opto_target_2_short = NaN;
% output.mean_vel_sem_80_opto_control_2_long = NaN;
% output.mean_vel_sem_80_opto_control_2_medium = NaN;
% output.mean_vel_sem_80_opto_control_2_short = NaN;
% output.mean_vel_sem_80_opto_target_2_long = NaN;
% output.mean_vel_sem_80_opto_target_2_medium = NaN;
% output.mean_vel_sem_80_opto_target_2_short = NaN;
% output.mean_vel_sem_90_opto_control_2_long = NaN;
% output.mean_vel_sem_90_opto_control_2_medium = NaN;
% output.mean_vel_sem_90_opto_control_2_short = NaN;
% output.mean_vel_sem_90_opto_target_2_long = NaN;
% output.mean_vel_sem_90_opto_target_2_medium = NaN;
% output.mean_vel_sem_90_opto_target_2_short = NaN;
% 
%     end
% 
% 
% 
%     if phase == '888'
% 
%     % All distances
% 
%         output.overall_go_latency_from_WN_opto_control_1 = go_latency_from_WN(trials_opto_control_1_index, 1);
%         output.overall_go_latency_from_WN_opto_target_1 = go_latency_from_WN(trials_opto_target_1_index, 1);
% 
% 
%         output.mean_overall_go_latency_from_WN_opto_control_1 = nanmean(output.overall_go_latency_from_WN_opto_control_1 );
%         output.mean_overall_go_latency_from_WN_opto_target_1 = nanmean(output.overall_go_latency_from_WN_opto_target_1);
% 
% 
%     % By trial type
% 
%         trials_opto_control_1_premature_index = find(trials_opto_control_1_premature == 1);
%         trials_opto_target_1_premature_index = find(trials_opto_target_1_premature == 1);
% 
%         trials_opto_control_1_goodwait = trials_opto_control_1 .* trials_go;
%         trials_opto_target_1_goodwait = trials_opto_target_1 .* trials_go;
%         trials_opto_control_1_goodwait_index = find(trials_opto_control_1_goodwait == 1);
%         trials_opto_target_1_goodwait_index = find(trials_opto_target_1_goodwait == 1);
% 
%         output.goodwait_go_latency_opto_control_1 = go_latency_from_WN(trials_opto_control_1_goodwait_index, 1);
%         output.goodwait_go_latency_opto_target_1 = go_latency_from_WN(trials_opto_target_1_goodwait_index, 1);
%         output.premature_go_latency_opto_control_1 = go_latency_from_WN(trials_opto_control_1_premature_index, 1);
%         output.premature_go_latency_opto_target_1 = go_latency_from_WN(trials_opto_target_1_premature_index, 1);
% 
%         output.mean_goodwait_go_latency_opto_control_1 = nanmean(output.goodwait_go_latency_opto_control_1);
%         output.mean_goodwait_go_latency_opto_target_1 = nanmean(output.goodwait_go_latency_opto_target_1);
%         output.mean_premature_go_latency_opto_control_1 = nanmean(output.premature_go_latency_opto_control_1);
%         output.mean_premature_go_latency_opto_target_1 = nanmean(output.premature_go_latency_opto_target_1);
%  
% % Acceleration averages
% 
% output.mean_acc_dist_10_opto_control_2_short_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_short_t3_index, 1:09), 2);
% output.mean_acc_dist_10_opto_target_2_short_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_short_t3_index, 1:09), 2);
% output.mean_acc_dist_20_opto_control_2_short_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_short_t3_index, 10:19), 2);
% output.mean_acc_dist_20_opto_target_2_short_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_short_t3_index, 10:19), 2);
% output.mean_acc_dist_30_opto_control_2_short_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_short_t3_index, 20:29), 2);
% output.mean_acc_dist_30_opto_target_2_short_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_short_t3_index, 20:29), 2);
% output.mean_acc_dist_40_opto_control_2_short_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_short_t3_index, 30:40), 2);
% output.mean_acc_dist_40_opto_target_2_short_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_short_t3_index, 30:40), 2);
% 
% output.mean_acc_dist_10_opto_control_2_medium_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_medium_t3_index, 1:09), 2);
% output.mean_acc_dist_10_opto_target_2_medium_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_medium_t3_index, 1:09), 2);
% output.mean_acc_dist_20_opto_control_2_medium_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_medium_t3_index, 10:19), 2);
% output.mean_acc_dist_20_opto_target_2_medium_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_medium_t3_index, 10:19), 2);
% output.mean_acc_dist_30_opto_control_2_medium_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_medium_t3_index, 20:29), 2);
% output.mean_acc_dist_30_opto_target_2_medium_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_medium_t3_index, 20:29), 2);
% output.mean_acc_dist_40_opto_control_2_medium_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_medium_t3_index, 30:40), 2);
% output.mean_acc_dist_40_opto_target_2_medium_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_medium_t3_index, 30:40), 2);
% 
% output.mean_acc_dist_10_opto_control_2_long_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_long_t3_index, 1:09), 2);
% output.mean_acc_dist_10_opto_target_2_long_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_long_t3_index, 1:09), 2);
% output.mean_acc_dist_20_opto_control_2_long_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_long_t3_index, 10:19), 2);
% output.mean_acc_dist_20_opto_target_2_long_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_long_t3_index, 10:19), 2);
% output.mean_acc_dist_30_opto_control_2_long_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_long_t3_index, 20:29), 2);
% output.mean_acc_dist_30_opto_target_2_long_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_long_t3_index, 20:29), 2);
% output.mean_acc_dist_40_opto_control_2_long_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_control_2_long_t3_index, 30:40), 2);
% output.mean_acc_dist_40_opto_target_2_long_m = mean(movement_velocities_smooth_mean_dist_diff(trials_opto_target_2_long_t3_index, 30:40), 2);
% 
% else
%  
% 
% 
% output.overall_go_latency_from_WN_opto_control_1 = NaN;
% output.overall_go_latency_from_WN_opto_target_1 = NaN;
% output.goodwait_go_latency_opto_control_1 = NaN;
% output.goodwait_go_latency_opto_target_1 = NaN;
% output.premature_go_latency_opto_control_1 = NaN;
% output.premature_go_latency_opto_target_1 = NaN;   
% 
% output.mean_acc_dist_10_opto_control_2_short_m = NaN;
% output.mean_acc_dist_10_opto_target_2_short_m = NaN;
% output.mean_acc_dist_20_opto_control_2_short_m = NaN;
% output.mean_acc_dist_20_opto_target_2_short_m = NaN;
% output.mean_acc_dist_30_opto_control_2_short_m = NaN;
% output.mean_acc_dist_30_opto_target_2_short_m = NaN;
% output.mean_acc_dist_40_opto_control_2_short_m = NaN;
% output.mean_acc_dist_40_opto_target_2_short_m = NaN;
% output.mean_acc_dist_10_opto_control_2_medium_m = NaN;
% output.mean_acc_dist_10_opto_target_2_medium_m = NaN;
% output.mean_acc_dist_20_opto_control_2_medium_m = NaN;
% output.mean_acc_dist_20_opto_target_2_medium_m = NaN;
% output.mean_acc_dist_30_opto_control_2_medium_m = NaN;
% output.mean_acc_dist_30_opto_target_2_medium_m = NaN;
% output.mean_acc_dist_40_opto_control_2_medium_m = NaN;
% output.mean_acc_dist_40_opto_target_2_medium_m = NaN;
% output.mean_acc_dist_10_opto_control_2_long_m = NaN;
% output.mean_acc_dist_10_opto_target_2_long_m = NaN;
% output.mean_acc_dist_20_opto_control_2_long_m = NaN;
% output.mean_acc_dist_20_opto_target_2_long_m = NaN;
% output.mean_acc_dist_30_opto_control_2_long_m = NaN;
% output.mean_acc_dist_30_opto_target_2_long_m = NaN;
% output.mean_acc_dist_40_opto_control_2_long_m = NaN;
% output.mean_acc_dist_40_opto_target_2_long_m = NaN;
% 
% 
% 
% 
%     end

% output.mean_stops_per_trial = sum(stops_frequency) / Total_Running_Trials;
% 
% mean_stop_duration = mean_stops_durations;
% mean_stop_duration = mean_stop_duration(find(mean_stop_duration > 0), 1);
% 
% output.mean_stop_duration = mean(mean_stop_duration);
% 
% output.mean_running_vel = nanmean(mean_binned_velocity);
% 
% 
% 
% 
% output.mean_stops_per_trial_halfhour = sum(stops_frequency(1:half_hour_trial_num, 1)) / Total_Running_Trials;
% 
% mean_stop_duration_halfhour = mean_stops_durations(1:half_hour_trial_num, 1);
% mean_stop_duration_halfhour = mean_stop_duration_halfhour(find(mean_stop_duration_halfhour > 0), 1);
% 
% output.mean_stop_duration_halfhour = mean(mean_stop_duration_halfhour);
% 
% output.mean_running_vel_halfhour = nanmean(mean_binned_velocity(1:half_hour_trial_num, 1));


% % Cued/Uncued Performance Data
% 
% trials_reward_cued = trials_reward .* trials_cued;
% trials_reward_cued_index = find(trials_reward_cued == 1);
% trials_premature_cued = trials_premature .* trials_cued;
% trials_premature_slow_cued = trials_premature_slow .* trials_cued;
% trials_incomplete_slow_cued = trials_incomplete .* trials_cued;
% trials_incomplete_running_late_cued = trials_incomplete_running_late .* trials_cued;
% trials_incomplete_running_early_cued = trials_incomplete_running_early .* trials_cued;
% trials_slowfail_cued = trials_slowfail .* trials_cued;
% trials_go_cued = trials_go .* trials_cued;
% 
% trials_reward_cued_short = trials_reward_cued .* trials_short;
% trials_premature_cued_short = trials_premature_cued .* trials_short;
% trials_premature_slow_cued_short = trials_premature_slow_cued .* trials_short;
% trials_incomplete_slow_cued_short = trials_incomplete_slow_cued .* trials_short;
% trials_incomplete_running_late_cued_short = trials_incomplete_running_late_cued .* trials_short;
% trials_incomplete_running_early_cued_short = trials_incomplete_running_early_cued .* trials_short;
% trials_slowfail_cued_short = trials_slowfail_cued .* trials_short;
% trials_go_cued_short = trials_go_cued .* trials_short;
% 
% trials_reward_cued_medium = trials_reward_cued .* trials_medium;
% trials_premature_cued_medium = trials_premature_cued .* trials_medium;
% trials_premature_slow_cued_medium = trials_premature_slow_cued .* trials_medium;
% trials_incomplete_slow_cued_medium = trials_incomplete_slow_cued .* trials_medium;
% trials_incomplete_running_late_cued_medium = trials_incomplete_running_late_cued .* trials_medium;
% trials_incomplete_running_early_cued_medium = trials_incomplete_running_early_cued .* trials_medium;
% trials_slowfail_cued_medium = trials_slowfail_cued .* trials_medium;
% trials_go_cued_medium = trials_go_cued .* trials_medium;
% 
% trials_reward_cued_long = trials_reward_cued .* trials_long;
% trials_premature_cued_long = trials_premature_cued .* trials_long;
% trials_premature_slow_cued_long = trials_premature_slow_cued .* trials_long;
% trials_incomplete_slow_cued_long = trials_incomplete_slow_cued .* trials_long;
% trials_incomplete_running_late_cued_long = trials_incomplete_running_late_cued .* trials_long;
% trials_incomplete_running_early_cued_long = trials_incomplete_running_early_cued .* trials_long;
% trials_slowfail_cued_long = trials_slowfail_cued .* trials_long;
% trials_go_cued_long = trials_go_cued .* trials_long;
% 
% trials_cued_short = trials_cued .* trials_short;
% trials_cued_medium = trials_cued .* trials_medium;
% trials_cued_long = trials_cued .* trials_long;
% 
% 
% % uncued
% trials_reward_uncued = trials_reward .* trials_uncued;
% trials_reward_uncued_index = find(trials_reward_uncued == 1);
% trials_premature_uncued = trials_premature .* trials_uncued;
% trials_premature_slow_uncued = trials_premature_slow .* trials_uncued;
% trials_incomplete_slow_uncued = trials_incomplete .* trials_uncued;
% trials_incomplete_running_late_uncued = trials_incomplete_running_late .* trials_uncued;
% trials_incomplete_running_early_uncued = trials_incomplete_running_early .* trials_uncued;
% trials_slowfail_uncued = trials_slowfail .* trials_uncued;
% trials_go_uncued = trials_go .* trials_uncued;
% 
% trials_reward_uncued_short = trials_reward_uncued .* trials_short;
% trials_premature_uncued_short = trials_premature_uncued .* trials_short;
% trials_premature_slow_uncued_short = trials_premature_slow_uncued .* trials_short;
% trials_incomplete_slow_uncued_short = trials_incomplete_slow_uncued .* trials_short;
% trials_incomplete_running_late_uncued_short = trials_incomplete_running_late_uncued .* trials_short;
% trials_incomplete_running_early_uncued_short = trials_incomplete_running_early_uncued .* trials_short;
% trials_slowfail_uncued_short = trials_slowfail_uncued .* trials_short;
% trials_go_uncued_short = trials_go_uncued .* trials_short;
% 
% trials_reward_uncued_medium = trials_reward_uncued .* trials_medium;
% trials_premature_uncued_medium = trials_premature_uncued .* trials_medium;
% trials_premature_slow_uncued_medium = trials_premature_slow_uncued .* trials_medium;
% trials_incomplete_slow_uncued_medium = trials_incomplete_slow_uncued .* trials_medium;
% trials_incomplete_running_late_uncued_medium = trials_incomplete_running_late_uncued .* trials_medium;
% trials_incomplete_running_early_uncued_medium = trials_incomplete_running_early_uncued .* trials_medium;
% trials_slowfail_uncued_medium = trials_slowfail_uncued .* trials_medium;
% trials_go_uncued_medium = trials_go_uncued .* trials_medium;
% 
% trials_reward_uncued_long = trials_reward_uncued .* trials_long;
% trials_premature_uncued_long = trials_premature_uncued .* trials_long;
% trials_premature_slow_uncued_long = trials_premature_slow_uncued .* trials_long;
% trials_incomplete_slow_uncued_long = trials_incomplete_slow_uncued .* trials_long;
% trials_incomplete_running_late_uncued_long = trials_incomplete_running_late_uncued .* trials_long;
% trials_incomplete_running_early_uncued_long = trials_incomplete_running_early_uncued .* trials_long;
% trials_slowfail_uncued_long = trials_slowfail_uncued .* trials_long;
% trials_go_uncued_long = trials_go_uncued .* trials_long;
% 
% trials_uncued_short = trials_uncued .* trials_short;
% trials_uncued_medium = trials_uncued .* trials_medium;
% trials_uncued_long = trials_uncued .* trials_long;
% 
% % outputs 
% output.Complete_Cued = sum(trials_reward_cued);
% output.Complete_Cued_short = sum(trials_reward_cued_short);
% output.Complete_Cued_medium = sum(trials_reward_cued_medium);
% output.Complete_Cued_long = sum(trials_reward_cued_long);
% 
% output.Complete_uncued = sum(trials_reward_uncued);
% output.Complete_uncued_short = sum(trials_reward_uncued_short);
% output.Complete_uncued_medium = sum(trials_reward_uncued_medium);
% output.Complete_uncued_long = sum(trials_reward_uncued_long);
% 
% output.Incomplete_cued = sum(trials_incomplete_slow_cued);
% output.Incomplete_cued_short = sum(trials_incomplete_slow_cued_short);
% output.Incomplete_cued_medium = sum(trials_incomplete_slow_cued_medium);
% output.Incomplete_cued_long = sum(trials_incomplete_slow_cued_long);
% 
% output.Incomplete_uncued = sum(trials_incomplete_slow_uncued);
% output.Incomplete_uncued_short = sum(trials_incomplete_slow_uncued_short);
% output.Incomplete_uncued_medium = sum(trials_incomplete_slow_uncued_medium);
% output.Incomplete_uncued_long = sum(trials_incomplete_slow_uncued_long);
% 
% output.Incomplete_late_cued = sum(trials_incomplete_running_late_cued);
% output.Incomplete_late_cued_short = sum(trials_incomplete_running_late_cued_short);
% output.Incomplete_late_cued_medium = sum(trials_incomplete_running_late_cued_medium);
% output.Incomplete_late_cued_long = sum(trials_incomplete_running_late_cued_long);
% 
% output.Incomplete_late_uncued = sum(trials_incomplete_running_late_uncued);
% output.Incomplete_late_uncued_short = sum(trials_incomplete_running_late_uncued_short);
% output.Incomplete_late_uncued_medium = sum(trials_incomplete_running_late_uncued_medium);
% output.Incomplete_late_uncued_long = sum(trials_incomplete_running_late_uncued_long);
% 
% output.Incomeplete_early_cued = sum(trials_incomplete_running_early_cued);
% output.Incomeplete_early_cued_short = sum(trials_incomplete_running_early_cued_short);
% output.Incomeplete_early_cued_medium = sum(trials_incomplete_running_early_cued_medium);
% output.Incomeplete_early_cued_long = sum(trials_incomplete_running_early_cued_long);
% 
% output.Incomeplete_early_uncued = sum(trials_incomplete_running_early_uncued);
% output.Incomeplete_early_uncued_short = sum(trials_incomplete_running_early_uncued_short);
% output.Incomeplete_early_uncued_medium = sum(trials_incomplete_running_early_uncued_medium);
% output.Incomeplete_early_uncued_long = sum(trials_incomplete_running_early_uncued_long);
% 
% output.Premature_Cued = sum(trials_premature_cued);
% output.Premature_Cued_short = sum(trials_premature_cued_short);
% output.Premature_Cued_medium = sum(trials_premature_cued_medium);
% output.Premature_Cued_long = sum(trials_premature_cued_long);
% 
% output.Premature_uncued = sum(trials_premature_uncued);
% output.Premature_uncued_short = sum(trials_premature_uncued_short);
% output.Premature_uncued_medium = sum(trials_premature_uncued_medium);
% output.Premature_uncued_long = sum(trials_premature_uncued_long);
% 
% output.Premature_slowdown_cued = sum(trials_premature_slow_cued);
% output.Premature_slowdown_cued_short = sum(trials_premature_slow_cued_short);
% output.Premature_slowdown_cued_medium = sum(trials_premature_slow_cued_medium);
% output.Premature_slowdown_cued_long = sum(trials_premature_slow_cued_long);
% 
% output.Premature_slowdown_uncued = sum(trials_premature_slow_uncued);
% output.Premature_slowdown_uncued_short = sum(trials_premature_slow_uncued_short);
% output.Premature_slowdown_uncued_medium = sum(trials_premature_slow_uncued_medium);
% output.Premature_slowdown_uncued_long = sum(trials_premature_slow_uncued_long);
% 
% output.Overrun_cued = sum(trials_slowfail_cued);
% output.Overrun_cued_short = sum(trials_slowfail_cued_short);
% output.Overrun_cued_medium = sum(trials_slowfail_cued_medium);
% output.Overrun_cued_long = sum(trials_slowfail_cued_long);
% 
% output.Overrun_uncued = sum(trials_slowfail_uncued);
% output.Overrun_uncued_short = sum(trials_slowfail_uncued_short);
% output.Overrun_uncued_medium = sum(trials_slowfail_uncued_medium);
% output.Overrun_uncued_long = sum(trials_slowfail_uncued_long);
% 
% output.Total_Trials_Cued = sum(trials_cued);
% output.Total_Trials_Cued_short = sum(trials_cued_short);
% output.Total_Trials_Cued_medium = sum(trials_cued_medium);
% output.Total_Trials_Cued_long = sum(trials_cued_long);
% 
% output.Total_Running_Trials_Cued = sum(trials_go_cued);
% output.Total_Running_Trials_Cued_short = sum(trials_go_cued_short);
% output.Total_Running_Trials_Cued_medium = sum(trials_go_cued_medium);
% output.Total_Running_Trials_Cued_long = sum(trials_go_cued_long);
% 
% output.Total_Running_Trials_Late_Cued = output.Total_Running_Trials_Cued - output.Incomeplete_early_cued;
% output.Total_Running_Trials_Late_Cued_short = output.Total_Running_Trials_Cued_short - output.Incomeplete_early_cued_short;
% output.Total_Running_Trials_Late_Cued_medium = output.Total_Running_Trials_Cued_medium - output.Incomeplete_early_cued_medium;
% output.Total_Running_Trials_Late_Cued_long = output.Total_Running_Trials_Cued_long - output.Incomeplete_early_cued_long;
% 
% output.Total_Trials_uncued = sum(trials_uncued);
% output.Total_Trials_uncued_short = sum(trials_uncued_short);
% output.Total_Trials_uncued_medium = sum(trials_uncued_medium);
% output.Total_Trials_uncued_long = sum(trials_uncued_long);
% 
% output.Total_Running_Trials_uncued = sum(trials_go_uncued);
% output.Total_Running_Trials_uncued_short = sum(trials_go_uncued_short);
% output.Total_Running_Trials_uncued_medium = sum(trials_go_uncued_medium);
% output.Total_Running_Trials_uncued_long = sum(trials_go_uncued_long);
% 
% output.Total_Running_Trials_Late_uncued = output.Total_Running_Trials_uncued - output.Incomeplete_early_uncued;
% output.Total_Running_Trials_Late_uncued_short = output.Total_Running_Trials_uncued_short - output.Incomeplete_early_uncued_short;
% output.Total_Running_Trials_Late_uncued_medium = output.Total_Running_Trials_uncued_medium - output.Incomeplete_early_uncued_medium;
% output.Total_Running_Trials_Late_uncued_long = output.Total_Running_Trials_uncued_long - output.Incomeplete_early_uncued_long;
% 
% output.Reward_Prop_Cued = output.Complete_Cued / output.Total_Running_Trials_Late_Cued;   
% output.Reward_Prop_Cued_short = output.Complete_Cued_short / output.Total_Running_Trials_Late_Cued_short;   
% output.Reward_Prop_Cued_medium = output.Complete_Cued_medium / output.Total_Running_Trials_Late_Cued_medium;   
% output.Reward_Prop_Cued_long = output.Complete_Cued_long / output.Total_Running_Trials_Late_Cued_long;   
% 
% output.Reward_Prop_uncued = output.Complete_uncued / output.Total_Running_Trials_Late_uncued;   
% output.Reward_Prop_uncued_short = output.Complete_uncued_short / output.Total_Running_Trials_Late_uncued_short;   
% output.Reward_Prop_uncued_medium = output.Complete_uncued_medium / output.Total_Running_Trials_Late_uncued_medium;   
% output.Reward_Prop_uncued_long = output.Complete_uncued_long / output.Total_Running_Trials_Late_uncued_long; 
% 
% output.PreTarget_Error_Prop_cued = (output.Premature_slowdown_cued + output.Incomplete_late_cued) / output.Total_Running_Trials_Late_Cued;
% output.PreTarget_Error_Prop_cued_short = (output.Premature_slowdown_cued_short + output.Incomplete_late_cued_short) / output.Total_Running_Trials_Late_Cued_short;
% output.PreTarget_Error_Prop_cued_medium = (output.Premature_slowdown_cued_medium + output.Incomplete_late_cued_medium) / output.Total_Running_Trials_Late_Cued_medium;
% output.PreTarget_Error_Prop_cued_long = (output.Premature_slowdown_cued_long + output.Incomplete_late_cued_long) / output.Total_Running_Trials_Late_Cued_long;
% 
% output.PreTarget_Error_Prop_uncued = (output.Premature_slowdown_uncued + output.Incomplete_late_uncued) / output.Total_Running_Trials_Late_uncued;
% output.PreTarget_Error_Prop_uncued_short = (output.Premature_slowdown_uncued_short + output.Incomplete_late_uncued_short) / output.Total_Running_Trials_Late_uncued_short;
% output.PreTarget_Error_Prop_uncued_medium = (output.Premature_slowdown_uncued_medium + output.Incomplete_late_uncued_medium) / output.Total_Running_Trials_Late_uncued_medium;
% output.PreTarget_Error_Prop_uncued_long = (output.Premature_slowdown_uncued_long + output.Incomplete_late_uncued_long) / output.Total_Running_Trials_Late_uncued_long;
% 
% output.Overrun_Prop_cued = output.Overrun_cued / output.Total_Running_Trials_Late_Cued;
% output.Overrun_Prop_cued_short = output.Overrun_cued_short / output.Total_Running_Trials_Late_Cued_short;
% output.Overrun_Prop_cued_medium = output.Overrun_cued_medium / output.Total_Running_Trials_Late_Cued_medium;
% output.Overrun_Prop_cued_long = output.Overrun_cued_long / output.Total_Running_Trials_Late_Cued_long;
% 
% output.Overrun_Prop_uncued = output.Overrun_uncued / output.Total_Running_Trials_Late_uncued;
% output.Overrun_Prop_uncued_short = output.Overrun_uncued_short / output.Total_Running_Trials_Late_uncued_short;
% output.Overrun_Prop_uncued_medium = output.Overrun_uncued_medium / output.Total_Running_Trials_Late_uncued_medium;
% output.Overrun_Prop_uncued_long = output.Overrun_uncued_long / output.Total_Running_Trials_Late_uncued_long;
% 
% 
% % % Cue association learning curve data
%     %trials_cue_index = find(trials_cue == 1);
% 
%         bin_size = 1;
% 
%     % Licking
%    
% %  if output.phase == 00   
% %     if  output.day == 03
%         cue_lick_ratio = lickfreq_cueassc(:, 2) ./ lickfreq_cueassc(:, 1); % postcue (but pre rw) licks over precue licks
% %     else
% %         cue_lick_ratio = lickfreq_cueassc(:, 1) ./ lickfreq_cueassc(:, 2); % prerw licks over postrw licks
% %     end
% 
%         number_bins_cued = floor(length(trials_reward_cued_index) / bin_size);
%         binning_mat_licking_cued(1, :) = [1:number_bins_cued]';
% 
%             for i = 1:number_bins_cued
%                 binning_ind_licking_cued{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_licking_cued{i, 2} = trials_reward_cued_index(binning_ind_licking_cued{i, 1}, 1);
%                 binning_mat_licking_cued(2, i) = mean(cue_lick_ratio(binning_ind_licking_cued{i, 2}, 1));
%                 % binning_mat(3, i) = (sum(ismember(binning_ind{i, 2}, trials_150_premature_slowdown_index)) / bin_size);
%                 % binning_mat(4, i) = (sum(ismember(binning_ind{i, 2}, trials_130_premature_slowdown_index)) / bin_size);
%             
%             end
% 
%         output.learning_curve_cue_association = binning_mat_licking_cued;
%         output.mean_cue_association_lick_ratio = mean(cue_lick_ratio(trials_reward_cued_index, 1));
%         output.med_cue_association_lick_ratio = median(cue_lick_ratio(trials_reward_cued_index, 1));
% 
%         %output.learning_curve_linear_fit = fitlm([1:number_bins_cued], binning_mat_licking_cued(2, :));
% %  else
% %         output.learning_curve_cue_association = NaN;
% %         output.learning_curve_linear_fit = NaN;     
% %  end
% 
% % Raw Vel
%     bin_size = 1;
%         cue_rawVel_ratio = rawVel_cueassc(:, 2) ./ rawVel_cueassc(:, 1); % postcue (but pre rw) rawVels over precue rawVels
%         nan_del_rawVel_ratio = isnan(cue_rawVel_ratio);
%         nan_del_rawVel_ratio_index = find(nan_del_rawVel_ratio == 1);  
%         cue_rawVel_ratio(nan_del_rawVel_ratio_index, 1) = 1;
%         
%         number_bins_cued = floor(length(trials_opto_control_complete_index) / bin_size);
%         binning_mat_rawVel_cued(1, :) = [1:number_bins_cued]';
% 
%             for i = 1:number_bins_cued
%                 binning_ind_rawVel_cued{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_rawVel_cued{i, 2} = trials_opto_control_complete_index(binning_ind_rawVel_cued{i, 1}, 1);
%                 binning_mat_rawVel_cued(2, i) = mean(cue_rawVel_ratio(binning_ind_rawVel_cued{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_cue_association_rawVel = binning_mat_rawVel_cued;
%         output.learning_curve_cue_association_rawVel_unbinned = cue_rawVel_ratio(trials_opto_control_complete_index, 1);      
% 
%         output.mean_cue_association_rawVel_ratio = mean(cue_rawVel_ratio(trials_opto_control_complete_index, 1));
%         output.med_cue_association_rawVel_ratio = median(cue_rawVel_ratio(trials_opto_control_complete_index, 1));
% 
%         output.mean_precue_rawVel = mean(rawVel_cueassc(trials_opto_control_complete_index, 1));
%         output.median_precue_rawVel = median(rawVel_cueassc(trials_opto_control_complete_index, 1));

%     % Short
%         trials_reward_cued_short_index = find(trials_reward_cued_short == 1);
%         
%         number_bins_cued_short = floor(length(trials_reward_cued_short_index) / bin_size);
%         binning_mat_rawVel_cued_short(1, :) = [1:number_bins_cued_short]';
% 
%             for i = 1:number_bins_cued_short
%                 binning_ind_rawVel_cued_short{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_rawVel_cued_short{i, 2} = trials_reward_cued_short_index(binning_ind_rawVel_cued_short{i, 1}, 1);
%                 binning_mat_rawVel_cued_short(2, i) = mean(cue_rawVel_ratio(binning_ind_rawVel_cued_short{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_cue_association_rawVel_short = binning_mat_rawVel_cued_short;
%         output.learning_curve_cue_association_rawVel_unbinned_short = cue_rawVel_ratio(trials_reward_cued_short_index, 1);      
% 
%         output.mean_cue_association_rawVel_ratio_short = mean(cue_rawVel_ratio(trials_reward_cued_short_index, 1));
%         output.med_cue_association_rawVel_ratio_short = median(cue_rawVel_ratio(trials_reward_cued_short_index, 1));
% 
%         output.mean_precue_rawVel_short = mean(rawVel_cueassc(trials_reward_cued_short_index, 1));
%         output.median_precue_rawVel_short = median(rawVel_cueassc(trials_reward_cued_short_index, 1));
% 
%     % medium
%         trials_reward_cued_medium_index = find(trials_reward_cued_medium == 1);
%         
%         number_bins_cued_medium = floor(length(trials_reward_cued_medium_index) / bin_size);
%         binning_mat_rawVel_cued_medium(1, :) = [1:number_bins_cued_medium]';
% 
%             for i = 1:number_bins_cued_medium
%                 binning_ind_rawVel_cued_medium{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_rawVel_cued_medium{i, 2} = trials_reward_cued_medium_index(binning_ind_rawVel_cued_medium{i, 1}, 1);
%                 binning_mat_rawVel_cued_medium(2, i) = mean(cue_rawVel_ratio(binning_ind_rawVel_cued_medium{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_cue_association_rawVel_medium = binning_mat_rawVel_cued_medium;
%         output.learning_curve_cue_association_rawVel_unbinned_medium = cue_rawVel_ratio(trials_reward_cued_medium_index, 1);      
% 
%         output.mean_cue_association_rawVel_ratio_medium = mean(cue_rawVel_ratio(trials_reward_cued_medium_index, 1));
%         output.med_cue_association_rawVel_ratio_medium = median(cue_rawVel_ratio(trials_reward_cued_medium_index, 1));
% 
%         output.mean_precue_rawVel_medium = mean(rawVel_cueassc(trials_reward_cued_medium_index, 1));
%         output.median_precue_rawVel_medium = median(rawVel_cueassc(trials_reward_cued_medium_index, 1));
% 
%     % long
%         trials_reward_cued_long_index = find(trials_reward_cued_long == 1);
%         
%         number_bins_cued_long = floor(length(trials_reward_cued_long_index) / bin_size);
%         binning_mat_rawVel_cued_long(1, :) = [1:number_bins_cued_long]';
% 
%             for i = 1:number_bins_cued_long
%                 binning_ind_rawVel_cued_long{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_rawVel_cued_long{i, 2} = trials_reward_cued_long_index(binning_ind_rawVel_cued_long{i, 1}, 1);
%                 binning_mat_rawVel_cued_long(2, i) = mean(cue_rawVel_ratio(binning_ind_rawVel_cued_long{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_cue_association_rawVel_long = binning_mat_rawVel_cued_long;
%         output.learning_curve_cue_association_rawVel_unbinned_long = cue_rawVel_ratio(trials_reward_cued_long_index, 1);      
% 
%         output.mean_cue_association_rawVel_ratio_long = mean(cue_rawVel_ratio(trials_reward_cued_long_index, 1));
%         output.med_cue_association_rawVel_ratio_long = median(cue_rawVel_ratio(trials_reward_cued_long_index, 1));
% 
%         output.mean_precue_rawVel_long = mean(rawVel_cueassc(trials_reward_cued_long_index, 1));
%         output.median_precue_rawVel_long = median(rawVel_cueassc(trials_reward_cued_long_index, 1));
% 
% 
% Velocity 2
%     bin_size = 1;
%         cue_vel2_ratio = vel2_cueassc(:, 2) ./ vel2_cueassc(:, 1); % postcue (but pre rw) vel2s over precue vel2s
% 
%         number_bins_cued = floor(length(trials_opto_control_complete_index) / bin_size);
%         binning_mat_vel2_cued(1, :) = [1:number_bins_cued]';
% 
%             for i = 1:number_bins_cued
%                 binning_ind_vel2_cued{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_vel2_cued{i, 2} = trials_opto_control_complete_index(binning_ind_vel2_cued{i, 1}, 1);
%                 binning_mat_vel2_cued(2, i) = mean(cue_vel2_ratio(binning_ind_vel2_cued{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_cue_association_vel2 = binning_mat_vel2_cued;
%         output.mean_cue_association_vel2_ratio = mean(cue_vel2_ratio(trials_opto_control_complete_index, 1));
%         output.med_cue_association_vel2_ratio = median(cue_vel2_ratio(trials_opto_control_complete_index, 1));
% 
%         output.mean_precue_vel2 = mean(vel2_cueassc(trials_opto_control_complete_index, 1));
%         output.median_precue_vel2 = median(vel2_cueassc(trials_opto_control_complete_index, 1));

% % Reward Distance
%     bin_size = 1;
% % Cued
%         number_bins_cued = floor(length(trials_reward_cued_index) / bin_size);
%         binning_mat_RWdist_cued(1, :) = [1:number_bins_cued]';
% 
%             for i = 1:number_bins_cued
%                 binning_ind_RWdist_cued{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_RWdist_cued{i, 2} = trials_reward_cued_index(binning_ind_RWdist_cued{i, 1}, 1);
%                 binning_mat_RWdist_cued(2, i) = mean(reward_distance(binning_ind_RWdist_cued{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_RWdist_cued = binning_mat_RWdist_cued;
%         output.mean_slowdown_distance_cued = mean(reward_distance(trials_reward_cued_index, 1));
%         output.med_slowdown_distance_cued = median(reward_distance(trials_reward_cued_index, 1));
% 
% 
% 	% Short
%         number_bins_cued_short = floor(length(trials_reward_cued_short_index) / bin_size);
%         binning_mat_RWdist_cued_short(1, :) = [1:number_bins_cued_short]';
% 
%             for i = 1:number_bins_cued_short
%                 binning_ind_RWdist_cued_short{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_RWdist_cued_short{i, 2} = trials_reward_cued_short_index(binning_ind_RWdist_cued_short{i, 1}, 1);
%                 binning_mat_RWdist_cued_short(2, i) = mean(reward_distance(binning_ind_RWdist_cued_short{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_RWdist_short_cued = binning_mat_RWdist_cued_short;
%         output.mean_slowdown_distance_short_cued = mean(reward_distance(trials_reward_cued_short_index, 1));
%         output.med_slowdown_distance_short_cued = median(reward_distance(trials_reward_cued_short_index, 1));
% 
% 	% medium
%         number_bins_cued_medium = floor(length(trials_reward_cued_medium_index) / bin_size);
%         binning_mat_RWdist_cued_medium(1, :) = [1:number_bins_cued_medium]';
% 
%             for i = 1:number_bins_cued_medium
%                 binning_ind_RWdist_cued_medium{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_RWdist_cued_medium{i, 2} = trials_reward_cued_medium_index(binning_ind_RWdist_cued_medium{i, 1}, 1);
%                 binning_mat_RWdist_cued_medium(2, i) = mean(reward_distance(binning_ind_RWdist_cued_medium{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_RWdist_medium_cued = binning_mat_RWdist_cued_medium;
%         output.mean_slowdown_distance_medium_cued = mean(reward_distance(trials_reward_cued_medium_index, 1));
%         output.med_slowdown_distance_medium_cued = median(reward_distance(trials_reward_cued_medium_index, 1));
% 
% 	% long
%         number_bins_cued_long = floor(length(trials_reward_cued_long_index) / bin_size);
%         binning_mat_RWdist_cued_long(1, :) = [1:number_bins_cued_long]';
% 
%             for i = 1:number_bins_cued_long
%                 binning_ind_RWdist_cued_long{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_RWdist_cued_long{i, 2} = trials_reward_cued_long_index(binning_ind_RWdist_cued_long{i, 1}, 1);
%                 binning_mat_RWdist_cued_long(2, i) = mean(reward_distance(binning_ind_RWdist_cued_long{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_RWdist_long_cued = binning_mat_RWdist_cued_long;
%         output.mean_slowdown_distance_long_cued = mean(reward_distance(trials_reward_cued_long_index, 1));
%         output.med_slowdown_distance_long_cued = median(reward_distance(trials_reward_cued_long_index, 1));
% 
% % uncued
%         trials_reward_uncued_short_index = find(trials_reward_uncued_short == 1);
%         trials_reward_uncued_medium_index = find(trials_reward_uncued_medium == 1);
%         trials_reward_uncued_long_index = find(trials_reward_uncued_long == 1);
% 
%         number_bins_uncued = floor(length(trials_reward_uncued_index) / bin_size);
%         binning_mat_RWdist_uncued(1, :) = [1:number_bins_uncued]';
% 
%             for i = 1:number_bins_uncued
%                 binning_ind_RWdist_uncued{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_RWdist_uncued{i, 2} = trials_reward_uncued_index(binning_ind_RWdist_uncued{i, 1}, 1);
%                 binning_mat_RWdist_uncued(2, i) = mean(reward_distance(binning_ind_RWdist_uncued{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_RWdist_uncued = binning_mat_RWdist_uncued;
%         output.mean_slowdown_distance_uncued = mean(reward_distance(trials_reward_uncued_index, 1));
%         output.med_slowdown_distance_uncued = median(reward_distance(trials_reward_uncued_index, 1));
% 
% 
% 	% Short
%         number_bins_uncued_short = floor(length(trials_reward_uncued_short_index) / bin_size);
%         binning_mat_RWdist_uncued_short(1, :) = [1:number_bins_uncued_short]';
% 
%             for i = 1:number_bins_uncued_short
%                 binning_ind_RWdist_uncued_short{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_RWdist_uncued_short{i, 2} = trials_reward_uncued_short_index(binning_ind_RWdist_uncued_short{i, 1}, 1);
%                 binning_mat_RWdist_uncued_short(2, i) = mean(reward_distance(binning_ind_RWdist_uncued_short{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_RWdist_short_uncued = binning_mat_RWdist_uncued_short;
%         output.mean_slowdown_distance_short_uncued = mean(reward_distance(trials_reward_uncued_short_index, 1));
%         output.med_slowdown_distance_short_uncued = median(reward_distance(trials_reward_uncued_short_index, 1));
% 
% 	% medium
%         number_bins_uncued_medium = floor(length(trials_reward_uncued_medium_index) / bin_size);
%         binning_mat_RWdist_uncued_medium(1, :) = [1:number_bins_uncued_medium]';
% 
%             for i = 1:number_bins_uncued_medium
%                 binning_ind_RWdist_uncued_medium{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_RWdist_uncued_medium{i, 2} = trials_reward_uncued_medium_index(binning_ind_RWdist_uncued_medium{i, 1}, 1);
%                 binning_mat_RWdist_uncued_medium(2, i) = mean(reward_distance(binning_ind_RWdist_uncued_medium{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_RWdist_medium_uncued = binning_mat_RWdist_uncued_medium;
%         output.mean_slowdown_distance_medium_uncued = mean(reward_distance(trials_reward_uncued_medium_index, 1));
%         output.med_slowdown_distance_medium_uncued = median(reward_distance(trials_reward_uncued_medium_index, 1));
% 
% 	% long
%         number_bins_uncued_long = floor(length(trials_reward_uncued_long_index) / bin_size);
%         binning_mat_RWdist_uncued_long(1, :) = [1:number_bins_uncued_long]';
% 
%             for i = 1:number_bins_uncued_long
%                 binning_ind_RWdist_uncued_long{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_RWdist_uncued_long{i, 2} = trials_reward_uncued_long_index(binning_ind_RWdist_uncued_long{i, 1}, 1);
%                 binning_mat_RWdist_uncued_long(2, i) = mean(reward_distance(binning_ind_RWdist_uncued_long{i, 2}, 1));
% 
%             end
% 
%         output.learning_curve_RWdist_long_uncued = binning_mat_RWdist_uncued_long;
%         output.mean_slowdown_distance_long_uncued = mean(reward_distance(trials_reward_uncued_long_index, 1));
%         output.med_slowdown_distance_long_uncued = median(reward_distance(trials_reward_uncued_long_index, 1));
% 
% % Learning curve data
% 
%     trials_cued_index = find(trials_cued == 1);
%     trials_uncued_index = find(trials_uncued == 1);
% 
%         bin_size = 5;
% 
%     % Error rate across session (cued-- not counting early running period error)
%         errors_cued = trials_incomplete_running_late_cued + trials_premature_slow_cued + trials_slowfail_cued;
%         errors_cued_index = find(errors_cued == 1);
% 
%         number_bins_cued = floor(length(trials_cued_index) / bin_size);
%         binning_mat_cued(1, :) = [1:number_bins_cued]';
% 
%             for i = 1:number_bins_cued
%                 binning_ind_cued{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_cued{i, 2} = trials_cued_index(binning_ind_cued{i, 1}, 1);
%                 binning_mat_cued(2, i) = (sum(ismember(binning_ind_cued{i, 2}, errors_cued_index)) / bin_size);
%                 % binning_mat(3, i) = (sum(ismember(binning_ind{i, 2}, trials_150_premature_slowdown_index)) / bin_size);
%                 % binning_mat(4, i) = (sum(ismember(binning_ind{i, 2}, trials_130_premature_slowdown_index)) / bin_size);
%             
%             end
% 
%         output.learning_curve_error_data_cued = binning_mat_cued;
% 
% 
%     % Error rate across session (uncued-- not counting early running period error)
%         errors_uncued = trials_incomplete_running_late_uncued + trials_premature_slow_uncued + trials_slowfail_uncued;
%         errors_uncued_index = find(errors_uncued == 1);
% 
%         number_bins_uncued = floor(length(trials_uncued_index) / bin_size);
%         binning_mat_uncued(1, :) = [1:number_bins_uncued]';
% 
%             for i = 1:number_bins_uncued
%                 binning_ind_uncued{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
%                 binning_ind_uncued{i, 2} = trials_uncued_index(binning_ind_uncued{i, 1}, 1);
%                 binning_mat_uncued(2, i) = (sum(ismember(binning_ind_uncued{i, 2}, errors_uncued_index)) / bin_size);
%                 % binning_mat(3, i) = (sum(ismember(binning_ind{i, 2}, trials_150_premature_slowdown_index)) / bin_size);
%                 % binning_mat(4, i) = (sum(ismember(binning_ind{i, 2}, trials_130_premature_slowdown_index)) / bin_size);
%             
%             end
% 
%         output.learning_curve_error_data_uncued = binning_mat_uncued;
% 
% 
% 
% output.mean_reward_distance_cued = nanmean(reward_distance(trials_reward_cued_index, 1));
% output.median_reward_distance_cued = nanmedian(reward_distance(trials_reward_cued_index, 1));
% 
% output.mean_reward_distance_cued_short = nanmean(reward_distance(trials_reward_cued_short_index, 1));
% output.median_reward_distance_cued_short = nanmedian(reward_distance(trials_reward_cued_short_index, 1));
% 
% output.mean_reward_distance_cued_medium = nanmean(reward_distance(trials_reward_cued_medium_index, 1));
% output.median_reward_distance_cued_medium = nanmedian(reward_distance(trials_reward_cued_medium_index, 1));
% 
% output.mean_reward_distance_cued_long = nanmean(reward_distance(trials_reward_cued_long_index, 1));
% output.median_reward_distance_cued_long = nanmedian(reward_distance(trials_reward_cued_long_index, 1));
% 
% output.go_latency_from_go = go_latency_from_go;
% output.mean_go_latency_from_go = nanmean(go_latency_from_go);
% output.median_go_latency_from_go = nanmedian(go_latency_from_go);
% 
% % Block transition analysis
% try
% block_index_mat = find(~isnan(trials_block_number));
% 
% for i = 1:size(block_index_mat, 1)
%     block_index_mat(i, 2) = trials_block_number_cue(block_index_mat(i, 1), 1);
% 
%     if i > 1
%         block_switch(i, 1) = block_index_mat(i, 2) ~= block_index_mat(i - 1, 2);
%     else
%         block_switch(i, 1) = 0;
%     end
% 
% end
% 
% block_switch_index = find(block_switch == 1);
% 
% trials_pretarget = trials_premature_slow + trials_incomplete_running_late;
% trials_pretarget_index = find(trials_pretarget == 1);
% trials_reward_index = find(trials_reward == 1);
% 
% for i = 1:size(block_switch_index, 1) % uses the block switch to determine which trials belong in each block-- ommits last block
% 
%    if i == 1
%       block_index{i, 1} = block_index_mat(1:(block_switch_index(i, 1) - 1), 1); 
%       block_index{i, 2} = block_index_mat((block_switch_index(i, 1) - 1), 2); 
%       blocks_cued_index(i, 1) = block_index{i, 2} == 20;
%    else 
%       block_index{i, 1} = block_index_mat((block_switch_index(i - 1, 1)):(block_switch_index(i, 1) - 1), 1); 
%       block_index{i, 2} = block_index_mat((block_switch_index(i, 1) - 1), 2); 
%       blocks_cued_index(i, 1) = block_index{i, 2} == 20;
%    end
% 
%    blocks_rewarded{i, 1} = intersect(block_index{i, 1}, trials_reward_index);
%    blocks_overrun{i, 1} = intersect(block_index{i, 1}, trials_overrun_index);
%    blocks_pretarget{i, 1} = intersect(block_index{i, 1}, trials_pretarget_index);
% 
%    block_lengths(i, 1) = size(block_index{i, 1}, 1);
% 
%    block_proportions(i, 1) = size(blocks_rewarded{i, 1}, 1); % rewards
%    block_proportions(i, 2) = size(blocks_overrun{i, 1}, 1); % overruns
%    block_proportions(i, 3) = size(blocks_pretarget{i, 1}, 1); % pretarget
%    block_proportions(i, 4) = sum(block_proportions(i, 1:3));
% 
%    block_performance(i, 1) = block_proportions(i, 1) / block_proportions(i, 4);
%    block_performance(i, 2) = block_proportions(i, 2) / block_proportions(i, 4); 
%    block_performance(i, 3) = block_proportions(i, 3) / block_proportions(i, 4);   
%    
% end
% 
% blocks_cued_indexx = find(blocks_cued_index == 1);
% blocks_uncued_indexx = find(blocks_cued_index == 0);
% 
% output.block_info = block_proportions;
% 
% output.cued_block_perf_reward = block_performance(blocks_cued_indexx,  1);
% output.uncued_block_perf_reward = block_performance(blocks_uncued_indexx,  1);
% 
% output.cued_block_perf_overrun = block_performance(blocks_cued_indexx,  2);
% output.uncued_block_perf_overrun = block_performance(blocks_uncued_indexx,  2);
% 
% output.cued_block_perf_pretarget = block_performance(blocks_cued_indexx,  3);
% output.uncued_block_perf_pretarget = block_performance(blocks_uncued_indexx,  3);
% 
% catch
% 
% output.block_info = [];
% 
% output.cued_block_perf_reward = [];
% output.uncued_block_perf_reward = [];
% 
% output.cued_block_perf_overrun = [];
% output.uncued_block_perf_overrun = [];
% 
% output.cued_block_perf_pretarget = [];
% output.uncued_block_perf_pretarget = [];
% 
% end
% 
% output.cumulative_performance = cumulative_perf;
% output.max_cumulative_performance = max(cumulative_perf);
% output.mean_cumulative_performance = mean(cumulative_perf, "omitnan");
% output.median_cumulative_performance = median(cumulative_perf, "omitnan");
% output.mode_cumulative_performance = mode(cumulative_perf);
% 
% 
% % Only select trials with sufficient motivation
% 
%     motivation_trial_max = motivation_index(end, 1);
% 
%     trials_reward_mot = trials_reward(1:motivation_trial_max, 1);
%     trials_incomplete_running_late_mot = trials_incomplete_running_late(1:motivation_trial_max, 1);
%     trials_incomplete_running_early_mot = trials_incomplete_running_early(1:motivation_trial_max, 1);
%     trials_premature_mot = trials_premature(1:motivation_trial_max, 1);
%     trials_premature_slow_mot = trials_premature_slow(1:motivation_trial_max, 1);
%     trials_slowfail_mot = trials_slowfail(1:motivation_trial_max, 1);
%     trials_cued_mot = trials_cued(1:motivation_trial_max, 1);
%     trials_uncued_mot = trials_uncued(1:motivation_trial_max, 1);
%     trials_go_mot = trials_go(1:motivation_trial_max, 1);
%     trials_short_mot = trials_short(1:motivation_trial_max, 1);
%     trials_medium_mot = trials_medium(1:motivation_trial_max, 1);    
%     trials_long_mot = trials_long(1:motivation_trial_max, 1);
% 
%     trials_cued_mot_short = trials_cued_mot .* trials_short_mot;
%     trials_cued_mot_medium = trials_cued_mot .* trials_medium_mot;
%     trials_cued_mot_long = trials_cued_mot .* trials_long_mot;
%     trials_go_cued_mot = trials_go_mot .* trials_cued_mot;
%     trials_go_cued_mot_short = trials_go_mot .* trials_cued_mot_short;
%     trials_go_cued_mot_medium = trials_go_mot .* trials_cued_mot_medium;
%     trials_go_cued_mot_long = trials_go_mot .* trials_cued_mot_long;
% 
%     trials_uncued_mot_short = trials_uncued_mot .* trials_short_mot;
%     trials_uncued_mot_medium = trials_uncued_mot .* trials_medium_mot;
%     trials_uncued_mot_long = trials_uncued_mot .* trials_long_mot;
%     trials_go_uncued_mot = trials_go_mot .* trials_uncued_mot;
%     trials_go_uncued_mot_short = trials_go_mot .* trials_uncued_mot_short;
%     trials_go_uncued_mot_medium = trials_go_mot .* trials_uncued_mot_medium;
%     trials_go_uncued_mot_long = trials_go_mot .* trials_uncued_mot_long;
% 
%     trials_reward_mot_cued = trials_reward_mot .* trials_cued_mot;
%     trials_incomplete_running_late_mot_cued = trials_incomplete_running_late_mot .* trials_cued_mot;
%     trials_incomplete_running_early_mot_cued = trials_incomplete_running_early_mot .* trials_cued_mot;
%     trials_premature_mot_cued = trials_premature_mot .* trials_cued_mot;
%     trials_premature_slow_mot_cued = trials_premature_slow_mot .* trials_cued_mot;
%     trials_slowfail_mot_cued = trials_slowfail_mot .* trials_cued_mot;
%     trials_go_mot_cued = trials_go_mot .* trials_cued_mot; 
% 
%     trials_reward_mot_cued_short = trials_reward_mot_cued .* trials_short_mot;
%     trials_incomplete_running_late_mot_cued_short = trials_incomplete_running_late_mot_cued .* trials_short_mot;
%     trials_incomplete_running_early_mot_cued_short = trials_incomplete_running_early_mot_cued .* trials_short_mot;
%     trials_premature_mot_cued_short = trials_premature_mot_cued .* trials_short_mot;
%     trials_premature_slow_mot_cued_short = trials_premature_slow_mot_cued .* trials_short_mot;
%     trials_slowfail_mot_cued_short = trials_slowfail_mot_cued .* trials_short_mot;
%     trials_go_mot_cued_short = trials_go_mot_cued .* trials_short_mot; 
% 
%     trials_reward_mot_cued_medium = trials_reward_mot_cued .* trials_medium_mot;
%     trials_incomplete_running_late_mot_cued_medium = trials_incomplete_running_late_mot_cued .* trials_medium_mot;
%     trials_incomplete_running_early_mot_cued_medium = trials_incomplete_running_early_mot_cued .* trials_medium_mot;
%     trials_premature_mot_cued_medium = trials_premature_mot_cued .* trials_medium_mot;
%     trials_premature_slow_mot_cued_medium = trials_premature_slow_mot_cued .* trials_medium_mot;
%     trials_slowfail_mot_cued_medium = trials_slowfail_mot_cued .* trials_medium_mot;
%     trials_go_mot_cued_medium = trials_go_mot_cued .* trials_medium_mot; 
% 
%     trials_reward_mot_cued_long = trials_reward_mot_cued .* trials_long_mot;
%     trials_incomplete_running_late_mot_cued_long = trials_incomplete_running_late_mot_cued .* trials_long_mot;
%     trials_incomplete_running_early_mot_cued_long = trials_incomplete_running_early_mot_cued .* trials_long_mot;
%     trials_premature_mot_cued_long = trials_premature_mot_cued .* trials_long_mot;
%     trials_premature_slow_mot_cued_long = trials_premature_slow_mot_cued .* trials_long_mot;
%     trials_slowfail_mot_cued_long = trials_slowfail_mot_cued .* trials_long_mot;
%     trials_go_mot_cued_long = trials_go_mot_cued .* trials_long_mot; 
% 
%     trials_reward_mot_uncued = trials_reward_mot .* trials_uncued_mot;
%     trials_incomplete_running_late_mot_uncued = trials_incomplete_running_late_mot .* trials_uncued_mot;
%     trials_incomplete_running_early_mot_uncued = trials_incomplete_running_early_mot .* trials_uncued_mot;
%     trials_premature_mot_uncued = trials_premature_mot .* trials_uncued_mot;
%     trials_premature_slow_mot_uncued = trials_premature_slow_mot .* trials_uncued_mot;
%     trials_slowfail_mot_uncued = trials_slowfail_mot .* trials_uncued_mot;
%     trials_go_mot_uncued = trials_go_mot .* trials_uncued_mot; 
% 
%     trials_reward_mot_uncued_short = trials_reward_mot_uncued .* trials_short_mot;
%     trials_incomplete_running_late_mot_uncued_short = trials_incomplete_running_late_mot_uncued .* trials_short_mot;
%     trials_incomplete_running_early_mot_uncued_short = trials_incomplete_running_early_mot_uncued .* trials_short_mot;
%     trials_premature_mot_uncued_short = trials_premature_mot_uncued .* trials_short_mot;
%     trials_premature_slow_mot_uncued_short = trials_premature_slow_mot_uncued .* trials_short_mot;
%     trials_slowfail_mot_uncued_short = trials_slowfail_mot_uncued .* trials_short_mot;
%     trials_go_mot_uncued_short = trials_go_mot_uncued .* trials_short_mot; 
% 
%     trials_reward_mot_uncued_medium = trials_reward_mot_uncued .* trials_medium_mot;
%     trials_incomplete_running_late_mot_uncued_medium = trials_incomplete_running_late_mot_uncued .* trials_medium_mot;
%     trials_incomplete_running_early_mot_uncued_medium = trials_incomplete_running_early_mot_uncued .* trials_medium_mot;
%     trials_premature_mot_uncued_medium = trials_premature_mot_uncued .* trials_medium_mot;
%     trials_premature_slow_mot_uncued_medium = trials_premature_slow_mot_uncued .* trials_medium_mot;
%     trials_slowfail_mot_uncued_medium = trials_slowfail_mot_uncued .* trials_medium_mot;
%     trials_go_mot_uncued_medium = trials_go_mot_uncued .* trials_medium_mot; 
% 
%     trials_reward_mot_uncued_long = trials_reward_mot_uncued .* trials_long_mot;
%     trials_incomplete_running_late_mot_uncued_long = trials_incomplete_running_late_mot_uncued .* trials_long_mot;
%     trials_incomplete_running_early_mot_uncued_long = trials_incomplete_running_early_mot_uncued .* trials_long_mot;
%     trials_premature_mot_uncued_long = trials_premature_mot_uncued .* trials_long_mot;
%     trials_premature_slow_mot_uncued_long = trials_premature_slow_mot_uncued .* trials_long_mot;
%     trials_slowfail_mot_uncued_long = trials_slowfail_mot_uncued .* trials_long_mot;
%     trials_go_mot_uncued_long = trials_go_mot_uncued .* trials_long_mot; 
% 
% 
% 
% output.Complete_Cued_mot = sum(trials_reward_mot_cued);
% output.Complete_Cued_short_mot = sum(trials_reward_mot_cued_short);
% output.Complete_Cued_medium_mot = sum(trials_reward_mot_cued_medium);
% output.Complete_Cued_long_mot = sum(trials_reward_mot_cued_long);
% 
% output.Complete_uncued_mot = sum(trials_reward_mot_uncued);
% output.Complete_uncued_short_mot = sum(trials_reward_mot_uncued_short);
% output.Complete_uncued_medium_mot = sum(trials_reward_mot_uncued_medium);
% output.Complete_uncued_long_mot = sum(trials_reward_mot_uncued_long);
% 
% output.Incomplete_late_cued_mot = sum(trials_incomplete_running_late_mot_cued);
% output.Incomplete_late_cued_short_mot = sum(trials_incomplete_running_late_mot_cued_short);
% output.Incomplete_late_cued_medium_mot = sum(trials_incomplete_running_late_mot_cued_medium);
% output.Incomplete_late_cued_long_mot = sum(trials_incomplete_running_late_mot_cued_long);
% 
% output.Incomplete_late_uncued_mot = sum(trials_incomplete_running_late_mot_uncued);
% output.Incomplete_late_uncued_short_mot = sum(trials_incomplete_running_late_mot_uncued_short);
% output.Incomplete_late_uncued_medium_mot = sum(trials_incomplete_running_late_mot_uncued_medium);
% output.Incomplete_late_uncued_long_mot = sum(trials_incomplete_running_late_mot_uncued_long);
% 
% output.Incomeplete_early_cued_mot = sum(trials_incomplete_running_early_mot_cued);
% output.Incomeplete_early_cued_short_mot = sum(trials_incomplete_running_early_mot_cued_short);
% output.Incomeplete_early_cued_medium_mot = sum(trials_incomplete_running_early_mot_cued_medium);
% output.Incomeplete_early_cued_long_mot = sum(trials_incomplete_running_early_mot_cued_long);
% 
% output.Incomeplete_early_uncued_mot = sum(trials_incomplete_running_early_mot_uncued);
% output.Incomeplete_early_uncued_short_mot = sum(trials_incomplete_running_early_mot_uncued_short);
% output.Incomeplete_early_uncued_medium_mot = sum(trials_incomplete_running_early_mot_uncued_medium);
% output.Incomeplete_early_uncued_long_mot = sum(trials_incomplete_running_early_mot_uncued_long);
% 
% output.Premature_Cued_mot = sum(trials_premature_mot_cued);
% output.Premature_Cued_short_mot = sum(trials_premature_mot_cued_short);
% output.Premature_Cued_medium_mot = sum(trials_premature_mot_cued_medium);
% output.Premature_Cued_long_mot = sum(trials_premature_mot_cued_long);
% 
% output.Premature_uncued_mot = sum(trials_premature_mot_uncued);
% output.Premature_uncued_short_mot = sum(trials_premature_mot_uncued_short);
% output.Premature_uncued_medium_mot = sum(trials_premature_mot_uncued_medium);
% output.Premature_uncued_long_mot = sum(trials_premature_mot_uncued_long);
% 
% output.Premature_slowdown_cued_mot = sum(trials_premature_slow_mot_cued);
% output.Premature_slowdown_cued_short_mot = sum(trials_premature_slow_mot_cued_short);
% output.Premature_slowdown_cued_medium_mot = sum(trials_premature_slow_mot_cued_medium);
% output.Premature_slowdown_cued_long_mot = sum(trials_premature_slow_mot_cued_long);
% 
% output.Premature_slowdown_uncued_mot = sum(trials_premature_slow_mot_uncued);
% output.Premature_slowdown_uncued_short_mot = sum(trials_premature_slow_mot_uncued_short);
% output.Premature_slowdown_uncued_medium_mot = sum(trials_premature_slow_mot_uncued_medium);
% output.Premature_slowdown_uncued_long_mot = sum(trials_premature_slow_mot_uncued_long);
% 
% output.Overrun_cued_mot = sum(trials_slowfail_mot_cued);
% output.Overrun_cued_short_mot = sum(trials_slowfail_mot_cued_short);
% output.Overrun_cued_medium_mot = sum(trials_slowfail_mot_cued_medium);
% output.Overrun_cued_long_mot = sum(trials_slowfail_mot_cued_long);
% 
% output.Overrun_uncued_mot = sum(trials_slowfail_mot_uncued);
% output.Overrun_uncued_short_mot = sum(trials_slowfail_mot_uncued_short);
% output.Overrun_uncued_medium_mot = sum(trials_slowfail_mot_uncued_medium);
% output.Overrun_uncued_long_mot = sum(trials_slowfail_mot_uncued_long);
% 
% output.Total_Trials_Cued_mot = sum(trials_cued_mot);
% output.Total_Trials_Cued_short_mot = sum(trials_cued_mot_short);
% output.Total_Trials_Cued_medium_mot = sum(trials_cued_mot_medium);
% output.Total_Trials_Cued_long_mot = sum(trials_cued_mot_long);
% 
% output.Total_Running_Trials_Cued_mot = sum(trials_go_cued_mot);
% output.Total_Running_Trials_Cued_short_mot = sum(trials_go_cued_mot_short);
% output.Total_Running_Trials_Cued_medium_mot = sum(trials_go_cued_mot_medium);
% output.Total_Running_Trials_Cued_long_mot = sum(trials_go_cued_mot_long);
% 
% output.Total_Running_Trials_Late_Cued_mot = output.Total_Running_Trials_Cued_mot - output.Incomeplete_early_cued_mot;
% output.Total_Running_Trials_Late_Cued_short_mot = output.Total_Running_Trials_Cued_short_mot - output.Incomeplete_early_cued_short_mot;
% output.Total_Running_Trials_Late_Cued_medium_mot = output.Total_Running_Trials_Cued_medium_mot - output.Incomeplete_early_cued_medium_mot;
% output.Total_Running_Trials_Late_Cued_long_mot = output.Total_Running_Trials_Cued_long_mot - output.Incomeplete_early_cued_long_mot;
% 
% output.Total_Trials_uncued_mot = sum(trials_uncued_mot);
% output.Total_Trials_uncued_short_mot = sum(trials_uncued_mot_short);
% output.Total_Trials_uncued_medium_mot = sum(trials_uncued_mot_medium);
% output.Total_Trials_uncued_long_mot = sum(trials_uncued_mot_long);
% 
% output.Total_Running_Trials_uncued_mot = sum(trials_go_uncued_mot);
% output.Total_Running_Trials_uncued_short_mot = sum(trials_go_uncued_mot_short);
% output.Total_Running_Trials_uncued_medium_mot = sum(trials_go_uncued_mot_medium);
% output.Total_Running_Trials_uncued_long_mot = sum(trials_go_uncued_mot_long);
% 
% output.Total_Running_Trials_Late_uncued_mot = output.Total_Running_Trials_uncued_mot - output.Incomeplete_early_uncued_mot;
% output.Total_Running_Trials_Late_uncued_short_mot = output.Total_Running_Trials_uncued_short_mot - output.Incomeplete_early_uncued_short_mot;
% output.Total_Running_Trials_Late_uncued_medium_mot = output.Total_Running_Trials_uncued_medium_mot - output.Incomeplete_early_uncued_medium_mot;
% output.Total_Running_Trials_Late_uncued_long_mot = output.Total_Running_Trials_uncued_long_mot - output.Incomeplete_early_uncued_long_mot;
% 
% output.Reward_Prop_Cued_mot = output.Complete_Cued_mot / output.Total_Running_Trials_Late_Cued_mot;   
% output.Reward_Prop_Cued_short_mot = output.Complete_Cued_short_mot / output.Total_Running_Trials_Late_Cued_short_mot;   
% output.Reward_Prop_Cued_medium_mot = output.Complete_Cued_medium_mot / output.Total_Running_Trials_Late_Cued_medium_mot;   
% output.Reward_Prop_Cued_long_mot = output.Complete_Cued_long_mot / output.Total_Running_Trials_Late_Cued_long_mot;   
% 
% output.Reward_Prop_uncued_mot = output.Complete_uncued_mot / output.Total_Running_Trials_Late_uncued_mot;   
% output.Reward_Prop_uncued_short_mot = output.Complete_uncued_short_mot / output.Total_Running_Trials_Late_uncued_short_mot;   
% output.Reward_Prop_uncued_medium_mot = output.Complete_uncued_medium_mot / output.Total_Running_Trials_Late_uncued_medium_mot;   
% output.Reward_Prop_uncued_long_mot = output.Complete_uncued_long_mot / output.Total_Running_Trials_Late_uncued_long_mot; 
% 
% output.PreTarget_Error_Prop_cued_mot = (output.Premature_slowdown_cued_mot + output.Incomplete_late_cued_mot) / output.Total_Running_Trials_Late_Cued_mot;
% output.PreTarget_Error_Prop_cued_short_mot = (output.Premature_slowdown_cued_short_mot + output.Incomplete_late_cued_short_mot) / output.Total_Running_Trials_Late_Cued_short_mot;
% output.PreTarget_Error_Prop_cued_medium_mot = (output.Premature_slowdown_cued_medium_mot + output.Incomplete_late_cued_medium_mot) / output.Total_Running_Trials_Late_Cued_medium_mot;
% output.PreTarget_Error_Prop_cued_long_mot = (output.Premature_slowdown_cued_long_mot + output.Incomplete_late_cued_long_mot) / output.Total_Running_Trials_Late_Cued_long_mot;
% 
% output.PreTarget_Error_Prop_uncued_mot = (output.Premature_slowdown_uncued_mot + output.Incomplete_late_uncued_mot) / output.Total_Running_Trials_Late_uncued_mot;
% output.PreTarget_Error_Prop_uncued_short_mot = (output.Premature_slowdown_uncued_short_mot + output.Incomplete_late_uncued_short_mot) / output.Total_Running_Trials_Late_uncued_short_mot;
% output.PreTarget_Error_Prop_uncued_medium_mot = (output.Premature_slowdown_uncued_medium_mot + output.Incomplete_late_uncued_medium_mot) / output.Total_Running_Trials_Late_uncued_medium_mot;
% output.PreTarget_Error_Prop_uncued_long_mot = (output.Premature_slowdown_uncued_long_mot + output.Incomplete_late_uncued_long_mot) / output.Total_Running_Trials_Late_uncued_long_mot;
% 
% output.Overrun_Prop_cued_mot = output.Overrun_cued_mot / output.Total_Running_Trials_Late_Cued_mot;
% output.Overrun_Prop_cued_short_mot = output.Overrun_cued_short_mot / output.Total_Running_Trials_Late_Cued_short_mot;
% output.Overrun_Prop_cued_medium_mot = output.Overrun_cued_medium_mot / output.Total_Running_Trials_Late_Cued_medium_mot;
% output.Overrun_Prop_cued_long_mot = output.Overrun_cued_long_mot / output.Total_Running_Trials_Late_Cued_long_mot;
% 
% output.Overrun_Prop_uncued_mot = output.Overrun_uncued_mot / output.Total_Running_Trials_Late_uncued_mot;
% output.Overrun_Prop_uncued_short_mot = output.Overrun_uncued_short_mot / output.Total_Running_Trials_Late_uncued_short_mot;
% output.Overrun_Prop_uncued_medium_mot = output.Overrun_uncued_medium_mot / output.Total_Running_Trials_Late_uncued_medium_mot;
% output.Overrun_Prop_uncued_long_mot = output.Overrun_uncued_long_mot / output.Total_Running_Trials_Late_uncued_long_mot;
% 
% % Motivated Reward Distances
% 
%     trials_reward_mot_cued_index = find(trials_reward_mot_cued == 1);
%     trials_reward_mot_uncued_index = find(trials_reward_mot_uncued == 1);
% 
%     trials_reward_mot_cued_short_index = find(trials_reward_mot_cued_short == 1);
%     trials_reward_mot_cued_medium_index = find(trials_reward_mot_cued_medium == 1);
%     trials_reward_mot_cued_long_index = find(trials_reward_mot_cued_long == 1);
% 
%     trials_reward_mot_uncued_short_index = find(trials_reward_mot_uncued_short == 1);
%     trials_reward_mot_uncued_medium_index = find(trials_reward_mot_uncued_medium == 1);
%     trials_reward_mot_uncued_long_index = find(trials_reward_mot_uncued_long == 1);
% 
%     output.mean_reward_distance_cued_mot = nanmean(reward_distance(trials_reward_mot_cued_index, 1));
%     output.median_reward_distance_cued_mot = nanmedian(reward_distance(trials_reward_mot_cued_index, 1));
%     output.sem_reward_distance_cued_mot = sem(reward_distance(trials_reward_mot_cued_index, 1), 1);
% 
%     output.mean_reward_distance_uncued_mot = nanmean(reward_distance(trials_reward_mot_uncued_index, 1));
%     output.median_reward_distance_uncued_mot = nanmedian(reward_distance(trials_reward_mot_uncued_index, 1));
%     output.sem_reward_distance_uncued_mot = sem(reward_distance(trials_reward_mot_uncued_index, 1), 1);
% 
%     output.mean_reward_distance_cued_mot_short = nanmean(reward_distance(trials_reward_mot_cued_short_index, 1));
%     output.median_reward_distance_cued_mot_short = nanmedian(reward_distance(trials_reward_mot_cued_short_index, 1));
%     output.sem_reward_distance_cued_mot_short = sem(reward_distance(trials_reward_mot_cued_short_index, 1), 1);
% 
%     output.mean_reward_distance_uncued_mot_short = nanmean(reward_distance(trials_reward_mot_uncued_short_index, 1));
%     output.median_reward_distance_uncued_mot_short = nanmedian(reward_distance(trials_reward_mot_uncued_short_index, 1));
%     output.sem_reward_distance_uncued_mot_short = sem(reward_distance(trials_reward_mot_uncued_short_index, 1), 1);
% 
%     output.mean_reward_distance_cued_mot_medium = nanmean(reward_distance(trials_reward_mot_cued_medium_index, 1));
%     output.median_reward_distance_cued_mot_medium = nanmedian(reward_distance(trials_reward_mot_cued_medium_index, 1));
%     output.sem_reward_distance_cued_mot_medium = sem(reward_distance(trials_reward_mot_cued_medium_index, 1), 1);
% 
%     output.mean_reward_distance_uncued_mot_medium = nanmean(reward_distance(trials_reward_mot_uncued_medium_index, 1));
%     output.median_reward_distance_uncued_mot_medium = nanmedian(reward_distance(trials_reward_mot_uncued_medium_index, 1));
%     output.sem_reward_distance_uncued_mot_medium = sem(reward_distance(trials_reward_mot_uncued_medium_index, 1), 1);
% 
%     output.mean_reward_distance_cued_mot_long = nanmean(reward_distance(trials_reward_mot_cued_long_index, 1));
%     output.median_reward_distance_cued_mot_long = nanmedian(reward_distance(trials_reward_mot_cued_long_index, 1));
%     output.sem_reward_distance_cued_mot_long = sem(reward_distance(trials_reward_mot_cued_long_index, 1), 1);
% 
%     output.mean_reward_distance_uncued_mot_long = nanmean(reward_distance(trials_reward_mot_uncued_long_index, 1));
%     output.median_reward_distance_uncued_mot_long = nanmedian(reward_distance(trials_reward_mot_uncued_long_index, 1));
%     output.sem_reward_distance_uncued_mot_long = sem(reward_distance(trials_reward_mot_uncued_long_index, 1), 1);
% 
% % Motivated PreTarget Distances
% 
%     % Cued
%         trials_premature_slow_mot_cued_index_short = find(trials_premature_slow_mot_cued_short == 1);
%         trials_incomplete_running_late_mot_cued_index_short = find(trials_incomplete_running_late_mot_cued_short == 1);
%         
%         trials_premature_slow_mot_cued_index_medium = find(trials_premature_slow_mot_cued_medium == 1);
%         trials_incomplete_running_late_mot_cued_index_medium = find(trials_incomplete_running_late_mot_cued_medium == 1);
%         
%         trials_premature_slow_mot_cued_index_long = find(trials_premature_slow_mot_cued_long == 1);
%         trials_incomplete_running_late_mot_cued_index_long = find(trials_incomplete_running_late_mot_cued_long == 1);
% 
%         preslow_distances_cued_short = premature_slow_distance(trials_premature_slow_mot_cued_index_short, 1);
%         preslow_distances_cued_medium = premature_slow_distance(trials_premature_slow_mot_cued_index_medium, 1);
%         preslow_distances_cued_long = premature_slow_distance(trials_premature_slow_mot_cued_index_long, 1);
% 
%         incomplete_distances_cued_short = incomplete_distance(trials_incomplete_running_late_mot_cued_index_short, 1);
%         incomplete_distances_cued_medium = incomplete_distance(trials_incomplete_running_late_mot_cued_index_medium, 1);
%         incomplete_distances_cued_long = incomplete_distance(trials_incomplete_running_late_mot_cued_index_long, 1);
% 
%         pretarget_distances_mot_cued_short = [preslow_distances_cued_short; incomplete_distances_cued_short;];
%         pretarget_distances_mot_cued_medium = [preslow_distances_cued_medium; incomplete_distances_cued_medium;];
%         pretarget_distances_mot_cued_long = [preslow_distances_cued_long; incomplete_distances_cued_long;];
% 
%         pretarget_distances_mot_cued_short_percent = pretarget_distances_mot_cued_short ./ (short / 10);
%         pretarget_distances_mot_cued_medium_percent = pretarget_distances_mot_cued_medium ./ (medium / 10);     
%         pretarget_distances_mot_cued_long_percent = pretarget_distances_mot_cued_long ./ (long / 10);
% 
%         pretarget_distances_percentage_cued = [pretarget_distances_mot_cued_short_percent; pretarget_distances_mot_cued_medium_percent; pretarget_distances_mot_cued_long_percent;];
% 
%     % Uncued
%         trials_premature_slow_mot_uncued_index_short = find(trials_premature_slow_mot_uncued_short == 1);
%         trials_incomplete_running_late_mot_uncued_index_short = find(trials_incomplete_running_late_mot_uncued_short == 1);
%         
%         trials_premature_slow_mot_uncued_index_medium = find(trials_premature_slow_mot_uncued_medium == 1);
%         trials_incomplete_running_late_mot_uncued_index_medium = find(trials_incomplete_running_late_mot_uncued_medium == 1);
%         
%         trials_premature_slow_mot_uncued_index_long = find(trials_premature_slow_mot_uncued_long == 1);
%         trials_incomplete_running_late_mot_uncued_index_long = find(trials_incomplete_running_late_mot_uncued_long == 1);
% 
%         preslow_distances_uncued_short = premature_slow_distance(trials_premature_slow_mot_uncued_index_short, 1);
%         preslow_distances_uncued_medium = premature_slow_distance(trials_premature_slow_mot_uncued_index_medium, 1);
%         preslow_distances_uncued_long = premature_slow_distance(trials_premature_slow_mot_uncued_index_long, 1);
% 
%         incomplete_distances_uncued_short = incomplete_distance(trials_incomplete_running_late_mot_uncued_index_short, 1);
%         incomplete_distances_uncued_medium = incomplete_distance(trials_incomplete_running_late_mot_uncued_index_medium, 1);
%         incomplete_distances_uncued_long = incomplete_distance(trials_incomplete_running_late_mot_uncued_index_long, 1);
% 
%         pretarget_distances_mot_uncued_short = [preslow_distances_uncued_short; incomplete_distances_uncued_short;];
%         pretarget_distances_mot_uncued_medium = [preslow_distances_uncued_medium; incomplete_distances_uncued_medium;];
%         pretarget_distances_mot_uncued_long = [preslow_distances_uncued_long; incomplete_distances_uncued_long;];
% 
%         pretarget_distances_mot_uncued_short_percent = pretarget_distances_mot_uncued_short ./ (short / 10);
%         pretarget_distances_mot_uncued_medium_percent = pretarget_distances_mot_uncued_medium ./ (medium / 10);     
%         pretarget_distances_mot_uncued_long_percent = pretarget_distances_mot_uncued_long ./ (long / 10);
% 
%         pretarget_distances_percentage_uncued = [pretarget_distances_mot_uncued_short_percent; pretarget_distances_mot_uncued_medium_percent; pretarget_distances_mot_uncued_long_percent;];
% 
%     % Outputs
% 
%         output.pretarget_dist_short_mot_cued = pretarget_distances_mot_cued_short;
%         output.pretarget_dist_medium_mot_cued = pretarget_distances_mot_cued_medium;   
%         output.pretarget_dist_long_mot_cued = pretarget_distances_mot_cued_long;
%         output.pretarget_distances_percentage_cued = pretarget_distances_percentage_cued;
% 
%         output.pretarget_dist_short_mot_uncued = pretarget_distances_mot_uncued_short;
%         output.pretarget_dist_medium_mot_uncued = pretarget_distances_mot_uncued_medium;   
%         output.pretarget_dist_long_mot_uncued = pretarget_distances_mot_uncued_long;
%         output.pretarget_distances_percentage_uncued = pretarget_distances_percentage_uncued;
% 
% 
%         output.mean_pretarget_dist_short_mot_cued = mean(pretarget_distances_mot_cued_short);
%         output.median_pretarget_dist_short_mot_cued = median(pretarget_distances_mot_cued_short);
%         output.sem_pretarget_dist_short_mot_cued = sem(pretarget_distances_mot_cued_short, 1);
% 
%         output.mean_pretarget_dist_short_mot_uncued = mean(pretarget_distances_mot_uncued_short);
%         output.median_pretarget_dist_short_mot_uncued = median(pretarget_distances_mot_uncued_short);
%         output.sem_pretarget_dist_short_mot_uncued = sem(pretarget_distances_mot_uncued_short, 1);
% 
%         output.mean_pretarget_dist_medium_mot_cued = mean(pretarget_distances_mot_cued_medium);
%         output.median_pretarget_dist_medium_mot_cued = median(pretarget_distances_mot_cued_medium);
%         output.sem_pretarget_dist_medium_mot_cued = sem(pretarget_distances_mot_cued_medium, 1);
% 
%         output.mean_pretarget_dist_medium_mot_uncued = mean(pretarget_distances_mot_uncued_medium);
%         output.median_pretarget_dist_medium_mot_uncued = median(pretarget_distances_mot_uncued_medium);
%         output.sem_pretarget_dist_medium_mot_uncued = sem(pretarget_distances_mot_uncued_medium, 1);
% 
%         output.mean_pretarget_dist_long_mot_cued = mean(pretarget_distances_mot_cued_long);
%         output.median_pretarget_dist_long_mot_cued = median(pretarget_distances_mot_cued_long);
%         output.sem_pretarget_dist_long_mot_cued = sem(pretarget_distances_mot_cued_long, 1);
% 
%         output.mean_pretarget_dist_long_mot_uncued = mean(pretarget_distances_mot_uncued_long);
%         output.median_pretarget_dist_long_mot_uncued = median(pretarget_distances_mot_uncued_long);
%         output.sem_pretarget_dist_long_mot_uncued = sem(pretarget_distances_mot_uncued_long, 1);
% 
%         output.mean_pretarget_distances_percentage_cued = mean(pretarget_distances_percentage_cued);
%         output.median_pretarget_distances_percentage_cued = median(pretarget_distances_percentage_cued);
%         output.sem_pretarget_distances_percentage_cued = sem(pretarget_distances_percentage_cued, 1);
% 
%         output.mean_pretarget_distances_percentage_uncued = mean(pretarget_distances_percentage_uncued);
%         output.median_pretarget_distances_percentage_uncued = median(pretarget_distances_percentage_uncued);
%         output.sem_pretarget_distances_percentage_uncued = sem(pretarget_distances_percentage_uncued, 1);
% 
%  % Save info for Trial Types
%     trials_go_index = find(trials_go == 1);
% 
% 		output.trials_reward_newind = trials_reward(trials_go_index, 1);
% 		output.trials_premature_slow_newind = trials_premature_slow(trials_go_index, 1);
% 		output.trials_incomplete_early_newind = trials_incomplete_running_early(trials_go_index, 1);
% 		output.trials_incomplete_late_newind = trials_incomplete_running_late(trials_go_index, 1);
% 		output.trials_pretarget_newind = trials_pretarget(trials_go_index, 1);
% 		output.trials_overrun_newind = trials_slowfail(trials_go_index, 1);
% 		output.trials_cued_newind = trials_cued(trials_go_index, 1);
% 		output.trials_short_newind = trials_short(trials_go_index, 1);
% 		output.trials_medium_newind = trials_medium(trials_go_index, 1);
% 		output.trials_long_newind = trials_long(trials_go_index, 1);
% 		output.reward_distance_newind = reward_distance(trials_go_index, 1);
% 		output.premature_slow_distance_newind = premature_slow_distance(trials_go_index, 1);
% 		output.incomplete_distance_newind = incomplete_distance(trials_go_index, 1);		
% 		output.go_latency_newind = go_latency(trials_go_index, 1);
% 
% %  % Duration info
% % output.total_rewarded_durations_short = total_rewarded_duration_short;
% % output.total_rewarded_durations_medium = total_rewarded_duration_medium;
% % output.total_rewarded_durations_long = total_rewarded_duration_long;
% % 
% % output.running_durations_short = running_duration_short;
% % output.running_durations_medium = running_duration_medium;
% % output.running_durations_long = running_duration_long;
% % 
% % output.slowdown_durations_short = slowdown_duration_short;
% % output.slowdown_durations_medium = slowdown_duration_medium;
% % output.slowdown_durations_long = slowdown_duration_long;
% % 
% % output.median_running_duration_short = median(running_duration_short, 'omitnan');
% % output.median_slowdown_duration_short = median(slowdown_duration_short, 'omitnan');
% % 
% % output.median_running_duration_medium = median(running_duration_medium , 'omitnan');
% % output.median_slowdown_duration_medium = median(slowdown_duration_medium , 'omitnan');
% % 
% % output.median_running_duration_long = median(running_duration_long , 'omitnan');
% % output.median_slowdown_duration_long = median(slowdown_duration_long , 'omitnan');

% Go Latencies

    % All distances

        output.overall_go_latency_opto_control_1 = go_latency(trials_opto_control_index, 1);
        output.overall_go_latency_opto_target_1 = go_latency(trials_opto_target_1_index, 1);

    % By trial distance

        output.short_go_latency_opto_control_1 = go_latency(trials_opto_control_short_index, 1);
        output.short_go_latency_opto_target_1 = go_latency(trials_opto_target_1_short_index, 1);
        output.medium_go_latency_opto_control_1 = go_latency(trials_opto_control_medium_index, 1);
        output.medium_go_latency_opto_target_1 = go_latency(trials_opto_target_1_medium_index, 1);
        output.long_go_latency_opto_control_1 = go_latency(trials_opto_control_long_index, 1);
        output.long_go_latency_opto_target_1 = go_latency(trials_opto_target_1_long_index, 1);  

        output.Mean_go_latency_opto_control_1 = mean(output.overall_go_latency_opto_control_1);
        output.Mean_go_latency_opto_target_1 = mean(output.overall_go_latency_opto_target_1);

        output.Mean_short_go_latency_opto_control_1 = mean(output.short_go_latency_opto_control_1);
        output.Mean_short_go_latency_opto_target_1 = mean(output.short_go_latency_opto_target_1);
        output.Mean_medium_go_latency_opto_control_1 = mean(output.medium_go_latency_opto_control_1);
        output.Mean_medium_go_latency_opto_target_1 = mean(output.medium_go_latency_opto_target_1);
        output.Mean_long_go_latency_opto_control_1 = mean(output.long_go_latency_opto_control_1);
        output.Mean_long_go_latency_opto_target_1 = mean(output.long_go_latency_opto_target_1);

        output.median_go_latency_opto_control_1 = median(output.overall_go_latency_opto_control_1);
        output.median_go_latency_opto_target_1 = median(output.overall_go_latency_opto_target_1);

        output.median_short_go_latency_opto_control_1 = median(output.short_go_latency_opto_control_1);
        output.median_short_go_latency_opto_target_1 = median(output.short_go_latency_opto_target_1);
        output.median_medium_go_latency_opto_control_1 = median(output.medium_go_latency_opto_control_1);
        output.median_medium_go_latency_opto_target_1 = median(output.medium_go_latency_opto_target_1);
        output.median_long_go_latency_opto_control_1 = median(output.long_go_latency_opto_control_1);
        output.median_long_go_latency_opto_target_1 = median(output.long_go_latency_opto_target_1);        
 
% Early Restart Distances

   	% Indexes etc
   		early_restart_distances_percent = restart_distances ./ target_distances;

		trials_opto_control_incomplete_running_early_index = find(trials_opto_control_incomplete_running_early == 1);
		trials_opto_control_incomplete_running_early_short_index = find(trials_opto_control_incomplete_running_early_short == 1);
		trials_opto_control_incomplete_running_early_medium_index = find(trials_opto_control_incomplete_running_early_medium == 1);
		trials_opto_control_incomplete_running_early_long_index = find(trials_opto_control_incomplete_running_early_long == 1);

		trials_opto_target_1_incomplete_running_early_index = find(trials_opto_target_1_incomplete_running_early == 1);
		trials_opto_target_1_incomplete_running_early_short_index = find(trials_opto_target_1_incomplete_running_early_short == 1);
		trials_opto_target_1_incomplete_running_early_medium_index = find(trials_opto_target_1_incomplete_running_early_medium == 1);
		trials_opto_target_1_incomplete_running_early_long_index = find(trials_opto_target_1_incomplete_running_early_long == 1);

    % All distances

        output.overall_early_restart_distances_opto_control_1 = restart_distances(trials_opto_control_incomplete_running_early_index, 1) / 10; % in cm 
        output.overall_early_restart_distances_opto_target_1 = restart_distances(trials_opto_target_1_incomplete_running_early_index, 1) / 10; % in cm

        output.overall_early_restart_distances_percent_opto_control_1 = early_restart_distances_percent(trials_opto_control_incomplete_running_early_index, 1);
        output.overall_early_restart_distances_percent_opto_target_1 = early_restart_distances_percent(trials_opto_target_1_incomplete_running_early_index, 1);

    % By trial distance

        output.short_early_restart_distances_opto_control_1 = restart_distances(trials_opto_control_incomplete_running_early_short_index, 1) / 10;
        output.short_early_restart_distances_opto_target_1 = restart_distances(trials_opto_target_1_incomplete_running_early_short_index, 1) / 10;

        output.medium_early_restart_distances_opto_control_1 = restart_distances(trials_opto_control_incomplete_running_early_medium_index, 1) / 10;
        output.medium_early_restart_distances_opto_target_1 = restart_distances(trials_opto_target_1_incomplete_running_early_medium_index, 1) / 10;

        output.long_early_restart_distances_opto_control_1 = restart_distances(trials_opto_control_incomplete_running_early_long_index, 1) / 10;
        output.long_early_restart_distances_opto_target_1 = restart_distances(trials_opto_target_1_incomplete_running_early_long_index, 1) / 10;  

        output.Mean_early_restart_distances_opto_control_1 = mean(output.overall_early_restart_distances_opto_control_1);
        output.Mean_early_restart_distances_opto_target_1 = mean(output.overall_early_restart_distances_opto_target_1);

        output.Mean_short_early_restart_distances_opto_control_1 = mean(output.short_early_restart_distances_opto_control_1);
        output.Mean_short_early_restart_distances_opto_target_1 = mean(output.short_early_restart_distances_opto_target_1);
        output.Mean_medium_early_restart_distances_opto_control_1 = mean(output.medium_early_restart_distances_opto_control_1);
        output.Mean_medium_early_restart_distances_opto_target_1 = mean(output.medium_early_restart_distances_opto_target_1);
        output.Mean_long_early_restart_distances_opto_control_1 = mean(output.long_early_restart_distances_opto_control_1);
        output.Mean_long_early_restart_distances_opto_target_1 = mean(output.long_early_restart_distances_opto_target_1);

        output.median_early_restart_distances_opto_control_1 = median(output.overall_early_restart_distances_opto_control_1);
        output.median_early_restart_distances_opto_target_1 = median(output.overall_early_restart_distances_opto_target_1);

        output.median_short_early_restart_distances_opto_control_1 = median(output.short_early_restart_distances_opto_control_1);
        output.median_short_early_restart_distances_opto_target_1 = median(output.short_early_restart_distances_opto_target_1);
        output.median_medium_early_restart_distances_opto_control_1 = median(output.medium_early_restart_distances_opto_control_1);
        output.median_medium_early_restart_distances_opto_target_1 = median(output.medium_early_restart_distances_opto_target_1);
        output.median_long_early_restart_distances_opto_control_1 = median(output.long_early_restart_distances_opto_control_1);
        output.median_long_early_restart_distances_opto_target_1 = median(output.long_early_restart_distances_opto_target_1);   

% Trial Repeats analysis
    
    trial_repeats = [trials_reward target_distances trials_opto_target_1];
    
    trial_repeats = trial_repeats .* ~trials_premature;
    
    premature_remov_index = find(trial_repeats(:, 2) ~= 0);
    trial_repeats = trial_repeats(premature_remov_index, :);
    
    
    
		    b = 0;
		    c = 0;
		    d = 0;
		    for i = 1:size(trial_repeats, 1)
			    c = c + 1; % counter for block size
    
			    if trial_repeats(i, 3) == 1
				    d = d + 1; % opto trial counter
    
			    end
    
			    if trial_repeats(i, 1) == 1
				    b = b + 1; % block number counter
				    repeat_blocks(b, 1) = c; % block size
				    repeat_blocks(b, 2) = d; % number of inhibitions
				    repeat_blocks(b, 3) = trial_repeats(i, 2); % target distance			
    
				    c = 0;
				    d = 0;
			    end
    
		    end
    
		    b = 0;
		    bb = 0;
		    bbb = 0;
		    c = 0;
		    cc = 0;
		    ccc = 0;
		    d = 0;
		    dd = 0;
		    ddd = 0;
		    for i = 1:size(repeat_blocks, 1)
			    if repeat_blocks(i, 3) == short
				    b = b + 1;
				    short_repeat_blocks(b, :) = repeat_blocks(i, :);
    
				    if short_repeat_blocks(b, 2) == 0
					    bb = bb + 1;
					    optocont_short_repeat_blocks(bb, :) = short_repeat_blocks(b, :);
				    else
					    bbb = bbb + 1;
					    optotarg_short_repeat_blocks(bbb, :) = short_repeat_blocks(b, :);					
				    end
    
			    end
    
			    if repeat_blocks(i, 3) == medium
				    c = c + 1;
				    medium_repeat_blocks(c, :) = repeat_blocks(i, :);
    
				    if medium_repeat_blocks(c, 2) == 0
					    cc = cc + 1;
					    optocont_medium_repeat_blocks(cc, :) = medium_repeat_blocks(c, :);
				    else
					    ccc = ccc + 1;
					    optotarg_medium_repeat_blocks(ccc, :) = medium_repeat_blocks(c, :);					
				    end
			    end
    
			    if repeat_blocks(i, 3) == long
				    d = d + 1;
				    long_repeat_blocks(d, :) = repeat_blocks(i, :);
    
				    if long_repeat_blocks(d, 2) == 0
					    dd = dd + 1;
					    optocont_long_repeat_blocks(dd, :) = long_repeat_blocks(d, :);
				    else
					    ddd = ddd + 1;
					    optotarg_long_repeat_blocks(ddd, :) = long_repeat_blocks(d, :);					
				    end
			    end			
		    end			


                if ~exist('short_repeat_blocks')
	                short_repeat_blocks = NaN;
                end
                
                if ~exist('medium_repeat_blocks')
	                medium_repeat_blocks = NaN;
                end
                
                if ~exist('long_repeat_blocks')
	                long_repeat_blocks = NaN;
                end
                
                if ~exist('optocont_short_repeat_blocks')
	                optocont_short_repeat_blocks = NaN;
                end
                
                if ~exist('optotarg_short_repeat_blocks')
	                optotarg_short_repeat_blocks = NaN;
                end
                
                if ~exist('optocont_medium_repeat_blocks')
	                optocont_medium_repeat_blocks = NaN;
                end
                
                if ~exist('optotarg_medium_repeat_blocks')
	                optotarg_medium_repeat_blocks = NaN;
                end
                
                if ~exist('optocont_long_repeat_blocks')
	                optocont_long_repeat_blocks = NaN;
                end
                
                if ~exist('optotarg_long_repeat_blocks')
	                optotarg_long_repeat_blocks = NaN;
                end

	output.mean_short_repeat_blocks = mean(short_repeat_blocks(:, 1));
	output.mean_medium_repeat_blocks = mean(medium_repeat_blocks(:, 1));
	output.mean_long_repeat_blocks = mean(long_repeat_blocks(:, 1));

	output.median_short_repeat_blocks = median(short_repeat_blocks(:, 1));
	output.median_medium_repeat_blocks = median(medium_repeat_blocks(:, 1));
	output.median_long_repeat_blocks = median(long_repeat_blocks(:, 1));

	output.optocont_short_repeat_blocks = optocont_short_repeat_blocks;
	output.optocont_medium_repeat_blocks = optocont_medium_repeat_blocks;
	output.optocont_long_repeat_blocks = optocont_long_repeat_blocks;
	output.optotarg_short_repeat_blocks = optotarg_short_repeat_blocks;
	output.optotarg_medium_repeat_blocks = optotarg_medium_repeat_blocks;
	output.optotarg_long_repeat_blocks = optotarg_long_repeat_blocks;

	output.mean_short_opto_control_repeat = mean(optocont_short_repeat_blocks(:, 1));
	output.mean_short_opto_target_repeat = mean(optotarg_short_repeat_blocks(:, 1));
	output.mean_medium_opto_control_repeat = mean(optocont_medium_repeat_blocks(:, 1));
	output.mean_medium_opto_target_repeat = mean(optotarg_medium_repeat_blocks(:, 1));
	output.mean_long_opto_control_repeat = mean(optocont_long_repeat_blocks(:, 1));
	output.mean_long_opto_target_repeat = mean(optotarg_long_repeat_blocks(:, 1));

	output.median_short_opto_control_repeat = median(optocont_short_repeat_blocks(:, 1));
	output.median_short_opto_target_repeat = median(optotarg_short_repeat_blocks(:, 1));
	output.median_medium_opto_control_repeat = median(optocont_medium_repeat_blocks(:, 1));
	output.median_medium_opto_target_repeat = median(optotarg_medium_repeat_blocks(:, 1));
	output.median_long_opto_control_repeat = median(optocont_long_repeat_blocks(:, 1));
	output.median_long_opto_target_repeat = median(optotarg_long_repeat_blocks(:, 1));


% Opto durations
    output.stim_duration_control = opto_duration_ctl;
    output.stim_duration_target = opto_duration_1;   

% Velocity snapshots around cue 

%     output.precue_data_rawvel_opto_control = rawVel_cueassc(trials_opto_control_complete_index, 1);
%     output.precue_data_vel2_opto_control = vel2_cueassc(trials_opto_control_complete_index, 1);
% 
%     output.postcue_data_rawvel_opto_control = rawVel_cueassc(trials_opto_control_complete_index, 2);
%     output.postcue_data_vel2_opto_control = vel2_cueassc(trials_opto_control_complete_index, 2);
%    
%     output.precue_data_rawvel_short_opto_control = rawVel_cueassc(trials_opto_control_complete_short_index, 1);
%     output.precue_data_vel2_short_opto_control = vel2_cueassc(trials_opto_control_complete_short_index, 1);
% 
%     output.postcue_data_rawvel_short_opto_control = rawVel_cueassc(trials_opto_control_complete_short_index, 2);
%     output.postcue_data_vel2_short_opto_control = vel2_cueassc(trials_opto_control_complete_short_index, 2);
% 
%     output.precue_data_rawvel_medium_opto_control = rawVel_cueassc(trials_opto_control_complete_medium_index, 1);
%     output.precue_data_vel2_medium_opto_control = vel2_cueassc(trials_opto_control_complete_medium_index, 1);
% 
%     output.postcue_data_rawvel_medium_opto_control = rawVel_cueassc(trials_opto_control_complete_medium_index, 2);
%     output.postcue_data_vel2_medium_opto_control = vel2_cueassc(trials_opto_control_complete_medium_index, 2);
% 
%     output.precue_data_rawvel_long_opto_control = rawVel_cueassc(trials_opto_control_complete_long_index, 1);
%     output.precue_data_vel2_long_opto_control = vel2_cueassc(trials_opto_control_complete_long_index, 1);
% 
%     output.postcue_data_rawvel_long_opto_control = rawVel_cueassc(trials_opto_control_complete_long_index, 2);
%     output.postcue_data_vel2_long_opto_control = vel2_cueassc(trials_opto_control_complete_long_index, 2);
% 
% 
%     output.precue_data_rawvel_opto_target_1 = rawVel_cueassc(trials_opto_target_1_complete_index, 1);
%     output.precue_data_vel2_opto_target_1 = vel2_cueassc(trials_opto_target_1_complete_index, 1);
% 
%     output.postcue_data_rawvel_opto_target_1 = rawVel_cueassc(trials_opto_target_1_complete_index, 2);
%     output.postcue_data_vel2_opto_target_1 = vel2_cueassc(trials_opto_target_1_complete_index, 2);
%    
%     output.precue_data_rawvel_short_opto_target_1 = rawVel_cueassc(trials_opto_target_1_complete_short_index, 1);
%     output.precue_data_vel2_short_opto_target_1 = vel2_cueassc(trials_opto_target_1_complete_short_index, 1);
% 
%     output.postcue_data_rawvel_short_opto_target_1 = rawVel_cueassc(trials_opto_target_1_complete_short_index, 2);
%     output.postcue_data_vel2_short_opto_target_1 = vel2_cueassc(trials_opto_target_1_complete_short_index, 2);
% 
%     output.precue_data_rawvel_medium_opto_target_1 = rawVel_cueassc(trials_opto_target_1_complete_medium_index, 1);
%     output.precue_data_vel2_medium_opto_target_1 = vel2_cueassc(trials_opto_target_1_complete_medium_index, 1);
% 
%     output.postcue_data_rawvel_medium_opto_target_1 = rawVel_cueassc(trials_opto_target_1_complete_medium_index, 2);
%     output.postcue_data_vel2_medium_opto_target_1 = vel2_cueassc(trials_opto_target_1_complete_medium_index, 2);
% 
%     output.precue_data_rawvel_long_opto_target_1 = rawVel_cueassc(trials_opto_target_1_complete_long_index, 1);
%     output.precue_data_vel2_long_opto_target_1 = vel2_cueassc(trials_opto_target_1_complete_long_index, 1);
% 
%     output.postcue_data_rawvel_long_opto_target_1 = rawVel_cueassc(trials_opto_target_1_complete_long_index, 2);
%     output.postcue_data_vel2_long_opto_target_1 = vel2_cueassc(trials_opto_target_1_complete_long_index, 2);


% Velocity Comparison Opto

    relavant_opto_control_trials = trials_opto_control_complete + trials_opto_control_pretarget_error + trials_opto_control_slowfail;
    relavant_opto_target_1_trials = trials_opto_target_1_complete + trials_opto_target_1_pretarget_error + trials_opto_target_1_slowfail;


    relavant_opto_control_trials_short = relavant_opto_control_trials .* trials_opto_control_short;
    relavant_opto_control_trials_medium = relavant_opto_control_trials .* trials_opto_control_medium;
    relavant_opto_control_trials_long = relavant_opto_control_trials .* trials_opto_control_long;

    relavant_opto_target_1_trials_short = relavant_opto_target_1_trials .* trials_opto_target_1_short;
    relavant_opto_target_1_trials_medium = relavant_opto_target_1_trials .* trials_opto_target_1_medium;
    relavant_opto_target_1_trials_long = relavant_opto_target_1_trials .* trials_opto_target_1_long;


    relavant_opto_control_trials_index = find(relavant_opto_control_trials == 1);
    relavant_opto_target_1_trials_index = find(relavant_opto_target_1_trials == 1);
    relavant_opto_control_trials_short_index = find(relavant_opto_control_trials_short == 1);
    relavant_opto_control_trials_medium_index = find(relavant_opto_control_trials_medium == 1);
    relavant_opto_control_trials_long_index = find(relavant_opto_control_trials_long == 1);
    relavant_opto_target_1_trials_short_index = find(relavant_opto_target_1_trials_short == 1);
    relavant_opto_target_1_trials_medium_index = find(relavant_opto_target_1_trials_medium == 1);
    relavant_opto_target_1_trials_long_index = find(relavant_opto_target_1_trials_long == 1);


    % output.speed_comp_raw_ctl_all = speed_comp_raw_ctl(relavant_opto_control_trials_index, :);
    % output.speed_comp_raw_ctl_short = speed_comp_raw_ctl(relavant_opto_control_trials_short_index, :);
    % output.speed_comp_raw_ctl_medium = speed_comp_raw_ctl(relavant_opto_control_trials_medium_index, :);
    % output.speed_comp_raw_ctl_long = speed_comp_raw_ctl(relavant_opto_control_trials_long_index, :);

    % output.speed_comp_raw_tar_all = speed_comp_raw_1(relavant_opto_target_1_trials_index, :);
    % output.speed_comp_raw_tar_short = speed_comp_raw_1(relavant_opto_target_1_trials_short_index, :);
    % output.speed_comp_raw_tar_medium = speed_comp_raw_1(relavant_opto_target_1_trials_medium_index, :);
    % output.speed_comp_raw_tar_long = speed_comp_raw_1(relavant_opto_target_1_trials_long_index, :);

%     output.speed_comp_smooth_ctl_all = speed_comp_smooth_ctl(relavant_opto_control_trials_index, :);
%     output.speed_comp_smooth_ctl_short = speed_comp_smooth_ctl(relavant_opto_control_trials_short_index, :);
%     output.speed_comp_smooth_ctl_medium = speed_comp_smooth_ctl(relavant_opto_control_trials_medium_index, :);
%     output.speed_comp_smooth_ctl_long = speed_comp_smooth_ctl(relavant_opto_control_trials_long_index, :);
% 
%     output.speed_comp_smooth_tar_all = speed_comp_smooth_1(relavant_opto_target_1_trials_index, :);
%     output.speed_comp_smooth_tar_short = speed_comp_smooth_1(relavant_opto_target_1_trials_short_index, :);
%     output.speed_comp_smooth_tar_medium = speed_comp_smooth_1(relavant_opto_target_1_trials_medium_index, :);
%     output.speed_comp_smooth_tar_long = speed_comp_smooth_1(relavant_opto_target_1_trials_long_index, :);
% 
% 
%     output.speed_comp_smooth_ctl_all_pretarget = speed_comp_smooth_ctl(trials_opto_control_pretarget_error_index, :);
%     output.speed_comp_smooth_ctl_short_pretarget = speed_comp_smooth_ctl(trials_opto_control_pretarget_error_short_index, :);
%     output.speed_comp_smooth_ctl_medium_pretarget = speed_comp_smooth_ctl(trials_opto_control_pretarget_error_medium_index, :);
%     output.speed_comp_smooth_ctl_long_pretarget = speed_comp_smooth_ctl(trials_opto_control_pretarget_error_long_index, :);
% 
%     output.speed_comp_smooth_tar_all_pretarget = speed_comp_smooth_1(trials_opto_target_1_pretarget_error_index, :);
%     output.speed_comp_smooth_tar_short_pretarget = speed_comp_smooth_1(trials_opto_target_1_pretarget_error_short_index, :);
%     output.speed_comp_smooth_tar_medium_pretarget = speed_comp_smooth_1(trials_opto_target_1_pretarget_error_medium_index, :);
%     output.speed_comp_smooth_tar_long_pretarget = speed_comp_smooth_1(trials_opto_target_1_pretarget_error_long_index, :);


% Velocity trace data

    trials_opto_control_slowfail_short_index = find(trials_opto_control_slowfail_short == 1);
    trials_opto_control_slowfail_medium_index = find(trials_opto_control_slowfail_medium == 1);
    trials_opto_control_slowfail_long_index = find(trials_opto_control_slowfail_long == 1);
    trials_opto_target_1_slowfail_short_index = find(trials_opto_target_1_slowfail_short == 1);
    trials_opto_target_1_slowfail_medium_index = find(trials_opto_target_1_slowfail_medium == 1);
    trials_opto_target_1_slowfail_long_index = find(trials_opto_target_1_slowfail_long == 1);


    output.smooth_vel_trace_all_short_opto_control = cell2mat(rescaled_velocities_smooth(relavant_opto_control_trials_short_index, :)')';
    output.smooth_vel_trace_all_short_opto_target_1 = cell2mat(rescaled_velocities_smooth(relavant_opto_target_1_trials_short_index, :)')';
    output.smooth_vel_trace_all_medium_opto_control = cell2mat(rescaled_velocities_smooth(relavant_opto_control_trials_medium_index, :)')';
    output.smooth_vel_trace_all_medium_opto_target_1 = cell2mat(rescaled_velocities_smooth(relavant_opto_target_1_trials_medium_index, :)')';
    output.smooth_vel_trace_all_long_opto_control = cell2mat(rescaled_velocities_smooth(relavant_opto_control_trials_long_index, :)')';
    output.smooth_vel_trace_all_long_opto_target_1 = cell2mat(rescaled_velocities_smooth(relavant_opto_target_1_trials_long_index, :)')';

    output.smooth_vel_trace_RW_short_opto_control = cell2mat(rescaled_velocities_smooth(trials_opto_control_complete_short_index, :)')';
    output.smooth_vel_trace_RW_short_opto_target_1 = cell2mat(rescaled_velocities_smooth(trials_opto_target_1_complete_short_index, :)')';
    output.smooth_vel_trace_RW_medium_opto_control = cell2mat(rescaled_velocities_smooth(trials_opto_control_complete_medium_index, :)')';
    output.smooth_vel_trace_RW_medium_opto_target_1 = cell2mat(rescaled_velocities_smooth(trials_opto_target_1_complete_medium_index, :)')';
    output.smooth_vel_trace_RW_long_opto_control = cell2mat(rescaled_velocities_smooth(trials_opto_control_complete_long_index, :)')';
    output.smooth_vel_trace_RW_long_opto_target_1 = cell2mat(rescaled_velocities_smooth(trials_opto_target_1_complete_long_index, :)')';

    output.smooth_vel_trace_PT_short_opto_control = cell2mat(rescaled_velocities_smooth(trials_opto_control_pretarget_error_short_index, :)')';
    output.smooth_vel_trace_PT_short_opto_target_1 = cell2mat(rescaled_velocities_smooth(trials_opto_target_1_pretarget_error_short_index, :)')';
    output.smooth_vel_trace_PT_medium_opto_control = cell2mat(rescaled_velocities_smooth(trials_opto_control_pretarget_error_medium_index, :)')';
    output.smooth_vel_trace_PT_medium_opto_target_1 = cell2mat(rescaled_velocities_smooth(trials_opto_target_1_pretarget_error_medium_index, :)')';
    output.smooth_vel_trace_PT_long_opto_control = cell2mat(rescaled_velocities_smooth(trials_opto_control_pretarget_error_long_index, :)')';
    output.smooth_vel_trace_PT_long_opto_target_1 = cell2mat(rescaled_velocities_smooth(trials_opto_target_1_pretarget_error_long_index, :)')';
    
    output.smooth_vel_trace_OR_short_opto_control = cell2mat(rescaled_velocities_smooth(trials_opto_control_slowfail_short_index, :)')';
    output.smooth_vel_trace_OR_short_opto_target_1 = cell2mat(rescaled_velocities_smooth(trials_opto_target_1_slowfail_short_index, :)')';
    output.smooth_vel_trace_OR_medium_opto_control = cell2mat(rescaled_velocities_smooth(trials_opto_control_slowfail_medium_index, :)')';
    output.smooth_vel_trace_OR_medium_opto_target_1 = cell2mat(rescaled_velocities_smooth(trials_opto_target_1_slowfail_medium_index, :)')';
    output.smooth_vel_trace_OR_long_opto_control = cell2mat(rescaled_velocities_smooth(trials_opto_control_slowfail_long_index, :)')';
    output.smooth_vel_trace_OR_long_opto_target_1 = cell2mat(rescaled_velocities_smooth(trials_opto_target_1_slowfail_long_index, :)')';
    
    output.raw_vel_trace_all_short_opto_control = cell2mat(rescaled_velocities_raw(relavant_opto_control_trials_short_index, :)')';
    output.raw_vel_trace_all_short_opto_target_1 = cell2mat(rescaled_velocities_raw(relavant_opto_target_1_trials_short_index, :)')';
    output.raw_vel_trace_all_medium_opto_control = cell2mat(rescaled_velocities_raw(relavant_opto_control_trials_medium_index, :)')';
    output.raw_vel_trace_all_medium_opto_target_1 = cell2mat(rescaled_velocities_raw(relavant_opto_target_1_trials_medium_index, :)')';
    output.raw_vel_trace_all_long_opto_control = cell2mat(rescaled_velocities_raw(relavant_opto_control_trials_long_index, :)')';
    output.raw_vel_trace_all_long_opto_target_1 = cell2mat(rescaled_velocities_raw(relavant_opto_target_1_trials_long_index, :)')';

    output.raw_vel_trace_RW_short_opto_control = cell2mat(rescaled_velocities_raw(trials_opto_control_complete_short_index, :)')';
    output.raw_vel_trace_RW_short_opto_target_1 = cell2mat(rescaled_velocities_raw(trials_opto_target_1_complete_short_index, :)')';
    output.raw_vel_trace_RW_medium_opto_control = cell2mat(rescaled_velocities_raw(trials_opto_control_complete_medium_index, :)')';
    output.raw_vel_trace_RW_medium_opto_target_1 = cell2mat(rescaled_velocities_raw(trials_opto_target_1_complete_medium_index, :)')';
    output.raw_vel_trace_RW_long_opto_control = cell2mat(rescaled_velocities_raw(trials_opto_control_complete_long_index, :)')';
    output.raw_vel_trace_RW_long_opto_target_1 = cell2mat(rescaled_velocities_raw(trials_opto_target_1_complete_long_index, :)')';

    output.raw_vel_trace_PT_short_opto_control = cell2mat(rescaled_velocities_raw(trials_opto_control_pretarget_error_short_index, :)')';
    output.raw_vel_trace_PT_short_opto_target_1 = cell2mat(rescaled_velocities_raw(trials_opto_target_1_pretarget_error_short_index, :)')';
    output.raw_vel_trace_PT_medium_opto_control = cell2mat(rescaled_velocities_raw(trials_opto_control_pretarget_error_medium_index, :)')';
    output.raw_vel_trace_PT_medium_opto_target_1 = cell2mat(rescaled_velocities_raw(trials_opto_target_1_pretarget_error_medium_index, :)')';
    output.raw_vel_trace_PT_long_opto_control = cell2mat(rescaled_velocities_raw(trials_opto_control_pretarget_error_long_index, :)')';
    output.raw_vel_trace_PT_long_opto_target_1 = cell2mat(rescaled_velocities_raw(trials_opto_target_1_pretarget_error_long_index, :)')';
    
    output.raw_vel_trace_OR_short_opto_control = cell2mat(rescaled_velocities_raw(trials_opto_control_slowfail_short_index, :)')';
    output.raw_vel_trace_OR_short_opto_target_1 = cell2mat(rescaled_velocities_raw(trials_opto_target_1_slowfail_short_index, :)')';
    output.raw_vel_trace_OR_medium_opto_control = cell2mat(rescaled_velocities_raw(trials_opto_control_slowfail_medium_index, :)')';
    output.raw_vel_trace_OR_medium_opto_target_1 = cell2mat(rescaled_velocities_raw(trials_opto_target_1_slowfail_medium_index, :)')';
    output.raw_vel_trace_OR_long_opto_control = cell2mat(rescaled_velocities_raw(trials_opto_control_slowfail_long_index, :)')';
    output.raw_vel_trace_OR_long_opto_target_1 = cell2mat(rescaled_velocities_raw(trials_opto_target_1_slowfail_long_index, :)')';

% Trial History info

trials_opto_assignment = trials_opto_control + (trials_opto_target_1 .* 2);
trials_distance_assignment = trials_short + (trials_medium .* 2) + (trials_long .* 3);
trials_outcome_assignment = trials_reward + (trials_pretarget_error .* 2) + (trials_slowfail .* 3);

for i = 1:size(stop_cue, 1)

	if trials_reward(i, 1) == 1

		if trials_short(i, 1) == 1

			if trials_opto_control(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 1;

			elseif trials_opto_target_1(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 2;

			end

		elseif trials_medium(i, 1) == 1

			if trials_opto_control(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 3;

			elseif trials_opto_target_1(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 4;
				
			end

		elseif trials_long(i, 1) == 1

			if trials_opto_control(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 5;

			elseif trials_opto_target_1(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 6;

			end

		end
			
	elseif trials_pretarget_error(i, 1) == 1


		if trials_short(i, 1) == 1

			if trials_opto_control(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 7;

			elseif trials_opto_target_1(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 8;

			end

		elseif trials_medium(i, 1) == 1

			if trials_opto_control(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 9;

			elseif trials_opto_target_1(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 10;

			end

		elseif trials_long(i, 1) == 1

			if trials_opto_control(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 11;

			elseif trials_opto_target_1(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 12;

			end

		end

	elseif trials_slowfail(i, 1) == 1

		if trials_short(i, 1) == 1

			if trials_opto_control(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 13;

			elseif trials_opto_target_1(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 14;

			end

		elseif trials_medium(i, 1) == 1

			if trials_opto_control(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 15;

			elseif trials_opto_target_1(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 16;

			end

		elseif trials_long(i, 1) == 1

			if trials_opto_control(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 17;

			elseif trials_opto_target_1(i, 1) == 1

				trial_comp(i, 2) = trials_opto_assignment(i, 1);
				trial_comp(i, 3) = trials_distance_assignment(i, 1);
				trial_comp(i, 4) = trials_outcome_assignment(i, 1);
				trial_comp(i, 1) = 18;

			end

		end

	else
		
		trial_comp(i, 2) = trials_opto_assignment(i, 1);
		trial_comp(i, 3) = trials_distance_assignment(i, 1);
		trial_comp(i, 4) = trials_outcome_assignment(i, 1);
		trial_comp(i, 1) = 0;

	end

end


remove_trials = find(trial_comp(:, 1) ~= 0);
trial_comp_clean = trial_comp(remove_trials, :);

output.Trial_by_Trial_Data = trial_comp_clean;



% Distractor Analysis

	% Catch Trials

		trials_distractor_catch_optocont = trials_distractor_catch .* trials_opto_control;
		trials_distractor_catch_optotarg = trials_distractor_catch .* trials_opto_target_1;

		trials_distractor_catch_overrun = trials_distractor_catch_optocont .* trials_overrun;
		trials_distractor_catch_reward = trials_distractor_catch_optocont .* trials_reward;
		trials_distractor_catch_pretarget = trials_distractor_catch_optocont .* trials_pretarget_error;

		trials_distractor_catch_index = find(trials_distractor_catch_optocont == 1);
		trials_distractor_catch_reward_index = find(trials_distractor_catch_reward == 1);
		trials_distractor_catch_overrun_index = find(trials_distractor_catch_overrun == 1);
		trials_distractor_catch_pretarget_index = find(trials_distractor_catch_pretarget == 1);

		output.trials_distractor_catch_reward_index = trials_distractor_catch_reward_index;
		output.trials_distractor_catch_overrun_index = trials_distractor_catch_overrun_index;
		output.trials_distractor_catch_pretarget_index = trials_distractor_catch_pretarget_index;

		trials_bad_catch = cat(1, trials_distractor_catch_reward_index, trials_distractor_catch_pretarget_index);
		trials_bad_catch_index = ismember(trials_distractor_catch_index, trials_bad_catch);
		trials_bad_catch_ind = find(trials_bad_catch_index == 1);

		% if size(trials_bad_catch_ind, 1) == 1 & trials_bad_catch_ind == 1
		%    clear trials_bad_catch_ind
		%    trials_bad_catch_ind = [];
		% 
		% end
		%     
		%     if ~isempty(trials_bad_catch_ind)
		%         if trials_bad_catch_ind(1, 1) > 1
		%             data_cut_off = trials_distractor_catch_index((trials_bad_catch_ind(1, 1) - 1), 1);
		%             output.prop_of_data_kept = data_cut_off / size(trials_distractor_catch, 1);
		%         else
		%             data_cut_off = trials_distractor_catch_index(trials_bad_catch_ind(1, 1), 1);
		%             output.prop_of_data_kept = data_cut_off / size(trials_distractor_catch, 1);
		%         end
		% 
		%     else
		%         data_cut_off = size(trials_distractor_catch, 1);
		%         output.prop_of_data_kept = data_cut_off / size(trials_distractor_catch, 1);
		%     end

		           data_cut_off = size(trials_distractor_catch, 1);
		        output.prop_of_data_kept = data_cut_off / size(trials_distractor_catch, 1);


trials_reward_distcont = trials_reward .* trials_distractor_control;
trials_reward_disttarg = trials_reward .* trials_distractor_target;

trials_distractor_control_pretarget = trials_distractor_control .* trials_pretarget_error;
trials_distractor_target_pretarget_eh = trials_distractor_target .* trials_pretarget_error; % doesnt verify whether WN was played

trials_distractor_target_pretarget_postWN = trials_distractor_target_pretarget_eh .* trials_distractor_played;
trials_distractor_target_pretarget_preWN = trials_distractor_target_pretarget_eh - trials_distractor_target_pretarget_postWN;


trials_overrun_distcont = trials_overrun .* trials_distractor_control;
trials_overrun_disttarg = trials_overrun .* trials_distractor_target;

trials_hit = trials_reward_distcont + trials_reward_disttarg;
trials_false_alarm = trials_distractor_played .* trials_pretarget_error;
trials_spontaneous = trials_distractor_control_pretarget + trials_distractor_target_pretarget_preWN + trials_distractor_catch_reward + trials_distractor_catch_pretarget;
trials_miss = trials_overrun_distcont + trials_overrun_disttarg;
trials_catch_correct = trials_distractor_catch_overrun;


training_output.trials_hit = sum(trials_hit);
training_output.trials_false_alarm = sum(trials_false_alarm);
training_output.trials_spontaneous = sum(trials_spontaneous);
training_output.trials_miss = sum(trials_miss);
training_output.trials_catch_correct = sum(trials_catch_correct);

training_output.total_trials_new = sum(trials_hit) + sum(trials_false_alarm) + sum(trials_spontaneous) + sum(trials_miss) + sum(trials_catch_correct);
training_output.total_distractors_played = sum(trials_distractor_played);
training_output.total_catch_trials = size(trials_distractor_catch_index, 1);

training_output.Hit_Rate = training_output.trials_hit / (training_output.trials_hit + training_output.trials_miss); % Hit Rate = Number of Correctly Identified Targets / Total Number of Target Stimuli Presented
training_output.False_Alarm_Rate = training_output.trials_false_alarm / training_output.total_distractors_played; % False Alarm Rate = Number of Incorrect Responses to Non-Targets / Total Number of Non-Target Stimuli Presented

training_output.Miss_Rate = training_output.trials_miss / (training_output.trials_hit + training_output.trials_miss);

training_output.Catch_Withholding_Rate = training_output.trials_catch_correct / training_output.total_catch_trials;

training_output.Spontaneous_Responding_Rate = training_output.trials_spontaneous / training_output.total_trials_new;

[d, c] = dprime_simple(training_output.Hit_Rate, training_output.False_Alarm_Rate);

training_output.D_Prime = d;
training_output.Response_Bias = c;


% Raw Vel
    bin_size = 1;
        cue_rawVel_ratio = rawVel_cueassc(:, 2) ./ rawVel_cueassc(:, 1); % postcue (but pre rw) rawVels over precue rawVels
        nan_del_rawVel_ratio = isnan(cue_rawVel_ratio);
        nan_del_rawVel_ratio_index = find(nan_del_rawVel_ratio == 1);  
        cue_rawVel_ratio(nan_del_rawVel_ratio_index, 1) = 1;
        
        number_bins_cued = floor(length(trials_opto_control_complete_index) / bin_size);
        binning_mat_rawVel_cued(1, :) = [1:number_bins_cued]';

            for i = 1:number_bins_cued
                binning_ind_rawVel_cued{i, 1} = [((i-1)*bin_size + 1):i*bin_size];
                binning_ind_rawVel_cued{i, 2} = trials_opto_control_complete_index(binning_ind_rawVel_cued{i, 1}, 1);
                binning_mat_rawVel_cued(2, i) = mean(cue_rawVel_ratio(binning_ind_rawVel_cued{i, 2}, 1));

            end

        output.learning_curve_cue_association_rawVel = binning_mat_rawVel_cued;
        output.learning_curve_cue_association_rawVel_unbinned = cue_rawVel_ratio(trials_opto_control_complete_index, 1);      

        output.mean_cue_association_rawVel_ratio = mean(cue_rawVel_ratio(trials_opto_control_complete_index, 1));
        output.med_cue_association_rawVel_ratio = median(cue_rawVel_ratio(trials_opto_control_complete_index, 1));

        output.mean_precue_rawVel = mean(rawVel_cueassc(trials_opto_control_complete_index, 1));
        output.median_precue_rawVel = median(rawVel_cueassc(trials_opto_control_complete_index, 1));



training_output.Reward_Prop = output.Complete_opto_control / output.Total_Running_Trials_Late_opto_control;  
training_output.PreTarget_Error_Prop = (output.Premature_slowdown_late_opto_control + output.Incomplete_late_opto_control) / output.Total_Running_Trials_Late_opto_control;
training_output.Overrun_Prop = output.Overrun_opto_control / output.Total_Running_Trials_Late_opto_control;

training_output.Reward_Prop_distractor = output.Complete_opto_target_1 / output.Total_Running_Trials_Late_opto_target_1;   
training_output.PreTarget_Error_Prop_distractor = (output.Premature_slowdown_late_opto_target_1 + output.Incomplete_late_opto_target_1) / output.Total_Running_Trials_Late_opto_target_1;
training_output.Overrun_Prop_distractor = output.Overrun_opto_target_1 / output.Total_Running_Trials_Late_opto_target_1;

training_output.mean_precue_vel = mean(rawVel_cueassc(trials_opto_control_complete_index, 1));
training_output.mean_delta_vel_ratio = mean(cue_rawVel_ratio(trials_opto_control_complete_index, 1));

training_output.median_reward_distance = output.median_reward_distance_optocont;


training_output.Reward_Prop_control_short = output.Complete_short_opto_control / output.Total_Running_Trials_Late_short_opto_control; 
training_output.Reward_Prop_distractor_short = output.Complete_short_opto_target_1 / output.Total_Running_Trials_Late_short_opto_target_1; 

training_output.PreTarget_Error_Prop_control_short = (output.Premature_slowdown_late_short_opto_control + output.Incomplete_late_short_opto_control) / output.Total_Running_Trials_Late_short_opto_control;
training_output.PreTarget_Error_Prop_distractor_short = (output.Premature_slowdown_late_short_opto_target_1 + output.Incomplete_late_short_opto_target_1) / output.Total_Running_Trials_Late_short_opto_target_1;

training_output.Overrun_Prop_control_short = output.Overrun_short_opto_control / output.Total_Running_Trials_Late_short_opto_control;
training_output.Overrun_Prop_distractor_short = output.Overrun_short_opto_target_1 / output.Total_Running_Trials_Late_short_opto_target_1;

training_output.Reward_Prop_control_medium = output.Complete_medium_opto_control / output.Total_Running_Trials_Late_medium_opto_control; 
training_output.Reward_Prop_distractor_medium = output.Complete_medium_opto_target_1 / output.Total_Running_Trials_Late_medium_opto_target_1; 

training_output.PreTarget_Error_Prop_control_medium = (output.Premature_slowdown_late_medium_opto_control + output.Incomplete_late_medium_opto_control) / output.Total_Running_Trials_Late_medium_opto_control;
training_output.PreTarget_Error_Prop_distractor_medium = (output.Premature_slowdown_late_medium_opto_target_1 + output.Incomplete_late_medium_opto_target_1) / output.Total_Running_Trials_Late_medium_opto_target_1;

training_output.Overrun_Prop_control_medium = output.Overrun_medium_opto_control / output.Total_Running_Trials_Late_medium_opto_control;
training_output.Overrun_Prop_distractor_medium = output.Overrun_medium_opto_target_1 / output.Total_Running_Trials_Late_medium_opto_target_1;

training_output.Reward_Prop_control_long = output.Complete_long_opto_control / output.Total_Running_Trials_Late_long_opto_control; 
training_output.Reward_Prop_distractor_long = output.Complete_long_opto_target_1 / output.Total_Running_Trials_Late_long_opto_target_1; 

training_output.PreTarget_Error_Prop_control_long = (output.Premature_slowdown_late_long_opto_control + output.Incomplete_late_long_opto_control) / output.Total_Running_Trials_Late_long_opto_control;
training_output.PreTarget_Error_Prop_distractor_long = (output.Premature_slowdown_late_long_opto_target_1 + output.Incomplete_late_long_opto_target_1) / output.Total_Running_Trials_Late_long_opto_target_1;

training_output.Overrun_Prop_control_long = output.Overrun_long_opto_control / output.Total_Running_Trials_Late_long_opto_control;
training_output.Overrun_Prop_distractor_long = output.Overrun_long_opto_target_1 / output.Total_Running_Trials_Late_long_opto_target_1;


training_output.Preslow_late_prop = output.Premature_slowdown_late_opto_control / output.Total_Running_Trials_opto_control;
training_output.Preslow_imm_prop = output.Premature_slowdown_imm_opto_control / output.Total_Running_Trials_opto_control;

training_output.Prestop_late_prop = output.Incomplete_late_opto_control / output.Total_Running_Trials_opto_control;
training_output.Prestop_early_prop = output.Incomplete_early_opto_control / output.Total_Running_Trials_opto_control;
training_output.Prestop_imm_prop = output.Incomplete_imm_opto_control / output.Total_Running_Trials_opto_control;




% Decoy distances

     if floor(output.phase_check) == 77 | floor(output.phase_check) == 5 % decoy/distractor cue task

        mean_decoy_cue_distance = mean(decoy_cue_distance, 'omitnan');
        median_decoy_cue_distance = median(decoy_cue_distance, 'omitnan');
        sem_decoy_cue_distance = (std(decoy_cue_distance, 'omitnan')/(sqrt(sum(~isnan(decoy_cue_distance)))));

        mean_decoy_cue_distance_short = mean(decoy_cue_distance(trials_opto_target_1_short_index, 1), 'omitnan');
        mean_decoy_cue_distance_medium = mean(decoy_cue_distance(trials_opto_target_1_medium_index, 1), 'omitnan');
        mean_decoy_cue_distance_long = mean(decoy_cue_distance(trials_opto_target_1_long_index, 1), 'omitnan');
        
        median_decoy_cue_distance_short = median(decoy_cue_distance(trials_opto_target_1_short_index, 1), 'omitnan');
        median_decoy_cue_distance_medium = median(decoy_cue_distance(trials_opto_target_1_medium_index, 1), 'omitnan');
        median_decoy_cue_distance_long = median(decoy_cue_distance(trials_opto_target_1_long_index, 1), 'omitnan');
        
        sem_decoy_cue_distance_short = (std(decoy_cue_distance(trials_opto_target_1_short_index, 1), 'omitnan')/(sqrt(sum(~isnan(decoy_cue_distance(trials_opto_target_1_short_index, 1))))));
        sem_decoy_cue_distance_medium = (std(decoy_cue_distance(trials_opto_target_1_medium_index, 1), 'omitnan')/(sqrt(sum(~isnan(decoy_cue_distance(trials_opto_target_1_medium_index, 1))))));
        sem_decoy_cue_distance_long = (std(decoy_cue_distance(trials_opto_target_1_long_index, 1), 'omitnan')/(sqrt(sum(~isnan(decoy_cue_distance(trials_opto_target_1_long_index, 1))))));
        

        output.decoy_cue_distances = decoy_cue_distance;

        output.decoy_cue_distances_short = decoy_cue_distance(trials_opto_target_1_short_index, 1);

        output.decoy_cue_distances_medium = decoy_cue_distance(trials_opto_target_1_medium_index, 1);

        output.decoy_cue_distances_long = decoy_cue_distance(trials_opto_target_1_long_index, 1);

        output.mean_decoy_cue_distance = mean_decoy_cue_distance;
        output.median_decoy_cue_distance = median_decoy_cue_distance;
        output.sem_decoy_cue_distance = sem_decoy_cue_distance;

        output.mean_decoy_cue_distance_short = mean_decoy_cue_distance_short;
        output.median_decoy_cue_distance_short = median_decoy_cue_distance_short;
        output.sem_decoy_cue_distance_short = sem_decoy_cue_distance_short;
        
        output.mean_decoy_cue_distance_medium = mean_decoy_cue_distance_medium;
        output.median_decoy_cue_distance_medium = median_decoy_cue_distance_medium;
        output.sem_decoy_cue_distance_medium = sem_decoy_cue_distance_medium;
        
        output.mean_decoy_cue_distance_long = mean_decoy_cue_distance_long;
        output.median_decoy_cue_distance_long = median_decoy_cue_distance_long;
        output.sem_decoy_cue_distance_long = sem_decoy_cue_distance_long;

        training_output.decoy_cue_distances = decoy_cue_distance;

        training_output.decoy_cue_distances_short = decoy_cue_distance(trials_opto_target_1_short_index, 1);

        training_output.decoy_cue_distances_medium = decoy_cue_distance(trials_opto_target_1_medium_index, 1);

        training_output.decoy_cue_distances_long = decoy_cue_distance(trials_opto_target_1_long_index, 1);

        training_output.mean_decoy_cue_distance = mean_decoy_cue_distance;
        training_output.median_decoy_cue_distance = median_decoy_cue_distance;
        training_output.sem_decoy_cue_distance = sem_decoy_cue_distance;

        training_output.mean_decoy_cue_distance_short = mean_decoy_cue_distance_short;
        training_output.median_decoy_cue_distance_short = median_decoy_cue_distance_short;
        training_output.sem_decoy_cue_distance_short = sem_decoy_cue_distance_short;
        
        training_output.mean_decoy_cue_distance_medium = mean_decoy_cue_distance_medium;
        training_output.median_decoy_cue_distance_medium = median_decoy_cue_distance_medium;
        training_output.sem_decoy_cue_distance_medium = sem_decoy_cue_distance_medium;
        
        training_output.mean_decoy_cue_distance_long = mean_decoy_cue_distance_long;
        training_output.median_decoy_cue_distance_long = median_decoy_cue_distance_long;
        training_output.sem_decoy_cue_distance_long = sem_decoy_cue_distance_long;


    else

        output.decoy_cue_distances = NaN;

        output.decoy_cue_distances_short = NaN;

        output.decoy_cue_distances_medium = NaN;

        output.decoy_cue_distances_long = NaN;

        output.mean_decoy_cue_distance = NaN;
        output.median_decoy_cue_distance = NaN;
        output.sem_decoy_cue_distance = NaN;

        output.mean_decoy_cue_distance_short = NaN;
        output.median_decoy_cue_distance_short = NaN;
        output.sem_decoy_cue_distance_short = NaN;
        
        output.mean_decoy_cue_distance_medium = NaN;
        output.median_decoy_cue_distance_medium = NaN;
        output.sem_decoy_cue_distance_medium = NaN;
        
        output.mean_decoy_cue_distance_long = NaN;
        output.median_decoy_cue_distance_long = NaN;
        output.sem_decoy_cue_distance_long = NaN;

        training_output.decoy_cue_distances = NaN;

        training_output.decoy_cue_distances_short = NaN;

        training_output.decoy_cue_distances_medium = NaN;

        training_output.decoy_cue_distances_long = NaN;

        training_output.mean_decoy_cue_distance = NaN;
        training_output.median_decoy_cue_distance = NaN;
        training_output.sem_decoy_cue_distance = NaN;

        training_output.mean_decoy_cue_distance_short = NaN;
        training_output.median_decoy_cue_distance_short = NaN;
        training_output.sem_decoy_cue_distance_short = NaN;
        
        training_output.mean_decoy_cue_distance_medium = NaN;
        training_output.median_decoy_cue_distance_medium = NaN;
        training_output.sem_decoy_cue_distance_medium = NaN;
        
        training_output.mean_decoy_cue_distance_long = NaN;
        training_output.median_decoy_cue_distance_long = NaN;
        training_output.sem_decoy_cue_distance_long = NaN;

     end

   if floor(output.phase_check) > 3
		[d, c] = dprime_simple(training_output.Reward_Prop, training_output.PreTarget_Error_Prop);

		training_output.dprime_distcont = d;
		training_output.criterion_distcont = c;	
		clear d c

		[d, c] = dprime_simple(training_output.Reward_Prop_distractor, training_output.PreTarget_Error_Prop_distractor);
		
		training_output.dprime_disttarg = d;
		training_output.criterion_disttarg = c;	
   else
		training_output.dprime_distcont = NaN;
		training_output.criterion_distcont = NaN;	
		training_output.dprime_disttarg = NaN;
		training_output.criterion_disttarg = NaN;	
   end

    training_output.reward_distances_opto_control = reward_distance(trials_opto_control_complete_index, 1);
    training_output.reward_distances_opto_target = reward_distance(trials_opto_target_1_complete_index, 1);

    training_output.reward_distances_opto_control_short = reward_distance(trials_opto_control_complete_short_index, 1);
    training_output.reward_distances_opto_target_short = reward_distance(trials_opto_target_1_complete_short_index, 1);

    training_output.reward_distances_opto_control_medium = reward_distance(trials_opto_control_complete_medium_index, 1);
    training_output.reward_distances_opto_target_medium = reward_distance(trials_opto_target_1_complete_medium_index, 1);

    training_output.reward_distances_opto_control_long = reward_distance(trials_opto_control_complete_long_index, 1);
    training_output.reward_distances_opto_target_long = reward_distance(trials_opto_target_1_complete_long_index, 1);





   end