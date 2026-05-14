function [matchingSessions, mean_go_traces, mean_nogo_traces, mean_hit_traces, mean_cr_traces, mean_miss_traces, mean_fa_traces, animal_performance] = select_photo_data(sessions_list_path, photometryStruct)
% Function to select photometry data from photometryStruct for plotting

% Load Sessions List
sessions_of_interest = readtable(sessions_list_path);

% Prealocate fields to photometryStruct

    for i = 1:size(photometryStruct, 2)
        photometryStruct(i).local_nogo_performance_log_animal1 = [];
        photometryStruct(i).moving_nogo_performance_animal1 = [];
        photometryStruct(i).local_nogo_performance_log_animal2 = [];
        photometryStruct(i).moving_nogo_performance_animal2 = [];
    end

% Initialize struct with all fields
matchingSessions = photometryStruct([]);  % empty struct with same fields

for i = 1:height(sessions_of_interest)
    target_ID = string(sessions_of_interest.Animal(i));
    target_date = sessions_of_interest.Date(i);   % likely datetime
    target_time = sessions_of_interest.Time(i);   % likely string or char

    isMatch = arrayfun(@(s) ...
        ( (isfield(s, 'animalID_1') && strcmp(s.animalID_1, target_ID)) || ...
          (isfield(s, 'animalID_2') && strcmp(s.animalID_2, target_ID)) ) && ...
        isfield(s, 'session_date') && ...
        isfield(s, 'session_time') && ...
        isequal(datetime(s.session_date, 'InputFormat', 'yyyy-MM-dd'), target_date) && ...
        strcmp(s.session_time, target_time), ...
        photometryStruct);

    matchingSessions = [matchingSessions; photometryStruct(isMatch)];

        % Obtain Go traces (regardless of trial type)

            photosignal_go_sound_start_fiber1 = [];
            photosignal_go_sound_start_fiber2 = [];
            photosignal_go_sound_start_fiber3 = [];
            photosignal_go_sound_start_fiber4 = [];

            for q = 1:size(matchingSessions(i).go_sound_start_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_go_sound_start_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).go_sound_start_timestamps_animal1(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).go_sound_start_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_go_sound_start_index, 1) > 80
                        photosignal_go_sound_start_index = photosignal_go_sound_start_index(1:80, 1);
                    elseif size(photosignal_go_sound_start_index, 1) < 80
                        photosignal_go_sound_start_fiber1(q, :) = NaN(1, 80);
                        photosignal_go_sound_start_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_go_sound_start_fiber1(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_go_sound_start_index, 3);
                photosignal_go_sound_start_fiber2(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_go_sound_start_index, 4);

            end

            for q = 1:size(matchingSessions(i).go_sound_start_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_go_sound_start_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).go_sound_start_timestamps_animal2(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).go_sound_start_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_go_sound_start_index, 1) > 80
                        photosignal_go_sound_start_index = photosignal_go_sound_start_index(1:80, 1);
                    elseif size(photosignal_go_sound_start_index, 1) < 80
                        photosignal_go_sound_start_fiber3(q, :) = NaN(1, 80);
                        photosignal_go_sound_start_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_go_sound_start_fiber3(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_go_sound_start_index, 5);
                photosignal_go_sound_start_fiber4(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_go_sound_start_index, 6);

            end

        % Obtain NoGo traces (regardless of trial type)

            photosignal_nogo_sound_start_fiber1 = [];
            photosignal_nogo_sound_start_fiber2 = [];
            photosignal_nogo_sound_start_fiber3 = [];
            photosignal_nogo_sound_start_fiber4 = [];

            for q = 1:size(matchingSessions(i).nogo_sound_start_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_nogo_sound_start_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).nogo_sound_start_timestamps_animal1(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).nogo_sound_start_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_nogo_sound_start_index, 1) > 80
                        photosignal_nogo_sound_start_index = photosignal_nogo_sound_start_index(1:80, 1);
                    elseif size(photosignal_nogo_sound_start_index, 1) < 80
                        photosignal_nogo_sound_start_fiber1(q, :) = NaN(1, 80);
                        photosignal_nogo_sound_start_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_nogo_sound_start_fiber1(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_nogo_sound_start_index, 3);
                photosignal_nogo_sound_start_fiber2(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_nogo_sound_start_index, 4);

            end

            for q = 1:size(matchingSessions(i).nogo_sound_start_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_nogo_sound_start_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).nogo_sound_start_timestamps_animal2(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).nogo_sound_start_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_nogo_sound_start_index, 1) > 80
                        photosignal_nogo_sound_start_index = photosignal_nogo_sound_start_index(1:80, 1);
                    elseif size(photosignal_nogo_sound_start_index, 1) < 80
                        photosignal_nogo_sound_start_fiber3(q, :) = NaN(1, 80);
                        photosignal_nogo_sound_start_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_nogo_sound_start_fiber3(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_nogo_sound_start_index, 5);
                photosignal_nogo_sound_start_fiber4(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_nogo_sound_start_index, 6);

            end

        % Obtain Hit traces

            photosignal_hit_go_sound_fiber1 = [];
            photosignal_hit_go_sound_fiber2 = [];
            photosignal_hit_go_sound_fiber3 = [];
            photosignal_hit_go_sound_fiber4 = [];

            for q = 1:size(matchingSessions(i).hit_go_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_hit_go_sound_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).hit_go_sound_timestamps_animal1(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).hit_go_sound_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_hit_go_sound_index, 1) > 80
                        photosignal_hit_go_sound_index = photosignal_hit_go_sound_index(1:80, 1);
                    elseif size(photosignal_hit_go_sound_index, 1) < 80
                        photosignal_hit_go_sound_fiber1(q, :) = NaN(1, 80);
                        photosignal_hit_go_sound_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_hit_go_sound_fiber1(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_hit_go_sound_index, 3);
                photosignal_hit_go_sound_fiber2(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_hit_go_sound_index, 4);

            end

            for q = 1:size(matchingSessions(i).hit_go_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_hit_go_sound_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).hit_go_sound_timestamps_animal2(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).hit_go_sound_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_hit_go_sound_index, 1) > 80
                        photosignal_hit_go_sound_index = photosignal_hit_go_sound_index(1:80, 1);
                    elseif size(photosignal_hit_go_sound_index, 1) < 80
                        photosignal_hit_go_sound_fiber3(q, :) = NaN(1, 80);
                        photosignal_hit_go_sound_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_hit_go_sound_fiber3(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_hit_go_sound_index, 5);
                photosignal_hit_go_sound_fiber4(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_hit_go_sound_index, 6);

            end

        % Obtain Miss traces

            photosignal_miss_go_sound_fiber1 = [];
            photosignal_miss_go_sound_fiber2 = [];
            photosignal_miss_go_sound_fiber3 = [];
            photosignal_miss_go_sound_fiber4 = [];

            for q = 1:size(matchingSessions(i).miss_go_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_miss_go_sound_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).miss_go_sound_timestamps_animal1(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).miss_go_sound_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_miss_go_sound_index, 1) > 80
                        photosignal_miss_go_sound_index = photosignal_miss_go_sound_index(1:80, 1);
                    elseif size(photosignal_miss_go_sound_index, 1) < 80
                        photosignal_miss_go_sound_fiber1(q, :) = NaN(1, 80);
                        photosignal_miss_go_sound_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_miss_go_sound_fiber1(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_miss_go_sound_index, 3);
                photosignal_miss_go_sound_fiber2(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_miss_go_sound_index, 4);

            end

            for q = 1:size(matchingSessions(i).miss_go_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_miss_go_sound_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).miss_go_sound_timestamps_animal2(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).miss_go_sound_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_miss_go_sound_index, 1) > 80
                        photosignal_miss_go_sound_index = photosignal_miss_go_sound_index(1:80, 1);
                    elseif size(photosignal_miss_go_sound_index, 1) < 80
                        photosignal_miss_go_sound_fiber3(q, :) = NaN(1, 80);
                        photosignal_miss_go_sound_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_miss_go_sound_fiber3(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_miss_go_sound_index, 5);
                photosignal_miss_go_sound_fiber4(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_miss_go_sound_index, 6);

            end

        % Obtain CR traces

            photosignal_cr_nogo_sound_fiber1 = [];
            photosignal_cr_nogo_sound_fiber2 = [];
            photosignal_cr_nogo_sound_fiber3 = [];
            photosignal_cr_nogo_sound_fiber4 = [];

            for q = 1:size(matchingSessions(i).cr_nogo_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_cr_nogo_sound_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).cr_nogo_sound_timestamps_animal1(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).cr_nogo_sound_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_cr_nogo_sound_index, 1) > 80
                        photosignal_cr_nogo_sound_index = photosignal_cr_nogo_sound_index(1:80, 1);
                    elseif size(photosignal_cr_nogo_sound_index, 1) < 80
                        photosignal_cr_nogo_sound_fiber1(q, :) = NaN(1, 80);
                        photosignal_cr_nogo_sound_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_cr_nogo_sound_fiber1(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_cr_nogo_sound_index, 3);
                photosignal_cr_nogo_sound_fiber2(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_cr_nogo_sound_index, 4);

            end

            for q = 1:size(matchingSessions(i).cr_nogo_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_cr_nogo_sound_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).cr_nogo_sound_timestamps_animal2(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).cr_nogo_sound_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_cr_nogo_sound_index, 1) > 80
                        photosignal_cr_nogo_sound_index = photosignal_cr_nogo_sound_index(1:80, 1);
                    elseif size(photosignal_cr_nogo_sound_index, 1) < 80
                        photosignal_cr_nogo_sound_fiber3(q, :) = NaN(1, 80);
                        photosignal_cr_nogo_sound_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_cr_nogo_sound_fiber3(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_cr_nogo_sound_index, 5);
                photosignal_cr_nogo_sound_fiber4(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_cr_nogo_sound_index, 6);

            end

        % Obtain FA traces

            photosignal_fa_nogo_sound_fiber1 = [];
            photosignal_fa_nogo_sound_fiber2 = [];
            photosignal_fa_nogo_sound_fiber3 = [];
            photosignal_fa_nogo_sound_fiber4 = [];

            for q = 1:size(matchingSessions(i).fa_nogo_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_fa_nogo_sound_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).fa_nogo_sound_timestamps_animal1(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).fa_nogo_sound_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_fa_nogo_sound_index, 1) > 80
                        photosignal_fa_nogo_sound_index = photosignal_fa_nogo_sound_index(1:80, 1);
                    elseif size(photosignal_fa_nogo_sound_index, 1) < 80
                        photosignal_fa_nogo_sound_fiber1(q, :) = NaN(1, 80);
                        photosignal_fa_nogo_sound_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_fa_nogo_sound_fiber1(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_fa_nogo_sound_index, 3);
                photosignal_fa_nogo_sound_fiber2(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_fa_nogo_sound_index, 4);

            end

            for q = 1:size(matchingSessions(i).fa_nogo_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_fa_nogo_sound_index = find(matchingSessions(i).deltafoverf_normalized(:, 2) >= (matchingSessions(i).fa_nogo_sound_timestamps_animal2(q, 1) - 1) & matchingSessions(i).deltafoverf_normalized(:, 2) < (matchingSessions(i).fa_nogo_sound_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_fa_nogo_sound_index, 1) > 80
                        photosignal_fa_nogo_sound_index = photosignal_fa_nogo_sound_index(1:80, 1);
                    elseif size(photosignal_fa_nogo_sound_index, 1) < 80
                        photosignal_fa_nogo_sound_fiber3(q, :) = NaN(1, 80);
                        photosignal_fa_nogo_sound_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_fa_nogo_sound_fiber3(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_fa_nogo_sound_index, 5);
                photosignal_fa_nogo_sound_fiber4(q, :) = matchingSessions(i).deltafoverf_normalized(photosignal_fa_nogo_sound_index, 6);

            end

        % Calculate local FA Rates

            % Preallocate
            local_nogo_performance_log = NaN(length(matchingSessions(i).nogo_sound_start_timestamps_animal1), 1);

            for a = 1:length(local_nogo_performance_log)
                ts = matchingSessions(i).nogo_sound_start_timestamps_animal1(a, 1);
                
                if ismember(ts, matchingSessions(i).cr_nogo_sound_timestamps_animal1)
                    local_nogo_performance_log(a, 1) = 0;
                elseif ismember(ts, matchingSessions(i).fa_nogo_sound_timestamps_animal1)
                    local_nogo_performance_log(a, 1) = 1;
                end
            end

            matchingSessions(i).local_nogo_performance_log_animal1 = local_nogo_performance_log;
            
            moving_nogo_performance = [];
            for a = 1:floor(length(local_nogo_performance_log) / 10)
                if a == 1
                    moving_nogo_performance(a, 1) = sum(local_nogo_performance_log(a:(a+9), 1)) / 10;
                else
                    moving_nogo_performance(a, 1) = sum(local_nogo_performance_log(((a*10)-9):(a*10), 1)) / 10;
                end
            end

            matchingSessions(i).moving_nogo_performance_animal1 = moving_nogo_performance;
            %matchingSessions(i).moving_nogo_performance_animal1 = movsum(local_nogo_performance_log, [4 0]) ./ 5; % Creates a moving sum of the previous 4 trials + current one to determine moving FA window
            clear local_nogo_performance_log moving_nogo_performance a 

            % Preallocate
            local_nogo_performance_log = NaN(length(matchingSessions(i).nogo_sound_start_timestamps_animal2), 1);

            for a = 1:length(local_nogo_performance_log)
                ts = matchingSessions(i).nogo_sound_start_timestamps_animal2(a, 1);
                
                if ismember(ts, matchingSessions(i).cr_nogo_sound_timestamps_animal2)
                    local_nogo_performance_log(a, 1) = 0;
                elseif ismember(ts, matchingSessions(i).fa_nogo_sound_timestamps_animal2)
                    local_nogo_performance_log(a, 1) = 1;
                end
            end

            matchingSessions(i).local_nogo_performance_log_animal2 = local_nogo_performance_log;

            moving_nogo_performance = [];
            for a = 1:floor(length(local_nogo_performance_log) / 10)
                if a == 1
                    moving_nogo_performance(a, 1) = sum(local_nogo_performance_log(a:(a+9), 1)) / 10;
                else
                    moving_nogo_performance(a, 1) = sum(local_nogo_performance_log(((a*10)-9):(a*10), 1)) / 10;
                end
            end

            matchingSessions(i).moving_nogo_performance_animal2 = moving_nogo_performance;
            %matchingSessions(i).moving_nogo_performance_animal2 = movsum(local_nogo_performance_log, [4 0]) ./ 5; % Creates a moving sum of the previous 4 trials + current one to determine moving FA window
            clear local_nogo_performance_log moving_nogo_performance a

        mean_go_traces{i, 1} = target_ID;
        mean_go_traces{i, 2} = matchingSessions(i).session_date;
        mean_go_traces{i, 3} = matchingSessions(i).session_time;        

        mean_nogo_traces{i, 1} = target_ID;
        mean_nogo_traces{i, 2} = matchingSessions(i).session_date;
        mean_nogo_traces{i, 3} = matchingSessions(i).session_time;        

        mean_hit_traces{i, 1} = target_ID;
        mean_hit_traces{i, 2} = matchingSessions(i).session_date;
        mean_hit_traces{i, 3} = matchingSessions(i).session_time;

        mean_miss_traces{i, 1} = target_ID;
        mean_miss_traces{i, 2} = matchingSessions(i).session_date;
        mean_miss_traces{i, 3} = matchingSessions(i).session_time;

        mean_cr_traces{i, 1} = target_ID;
        mean_cr_traces{i, 2} = matchingSessions(i).session_date;
        mean_cr_traces{i, 3} = matchingSessions(i).session_time;

        mean_fa_traces{i, 1} = target_ID;
        mean_fa_traces{i, 2} = matchingSessions(i).session_date;
        mean_fa_traces{i, 3} = matchingSessions(i).session_time;

        animal_performance{i, 1} = target_ID;
        animal_performance{i, 2} = matchingSessions(i).session_date;
        animal_performance{i, 3} = matchingSessions(i).session_time;        

        if matchingSessions(i).animalID_1 == target_ID
            mean_go_traces{i, 4} = matchingSessions(i).Fiber1_ID;                
            mean_go_traces{i, 5} = mean(photosignal_go_sound_start_fiber1, 1, 'omitnan');
            mean_go_traces{i, 6} = photosignal_go_sound_start_fiber1;
            mean_go_traces{i, 7} = matchingSessions(i).Fiber2_ID;            
            mean_go_traces{i, 8} = mean(photosignal_go_sound_start_fiber2, 1, 'omitnan');
            mean_go_traces{i, 9} = photosignal_go_sound_start_fiber2;

            mean_nogo_traces{i, 4} = matchingSessions(i).Fiber1_ID;                
            mean_nogo_traces{i, 5} = mean(photosignal_nogo_sound_start_fiber1, 1, 'omitnan');
            mean_nogo_traces{i, 6} = photosignal_nogo_sound_start_fiber1;
            mean_nogo_traces{i, 7} = matchingSessions(i).Fiber2_ID;            
            mean_nogo_traces{i, 8} = mean(photosignal_nogo_sound_start_fiber2, 1, 'omitnan');
            mean_nogo_traces{i, 9} = photosignal_nogo_sound_start_fiber2;

            mean_hit_traces{i, 4} = matchingSessions(i).Fiber1_ID;                
            mean_hit_traces{i, 5} = mean(photosignal_hit_go_sound_fiber1, 1, 'omitnan');
            mean_hit_traces{i, 6} = photosignal_hit_go_sound_fiber1;
            mean_hit_traces{i, 7} = matchingSessions(i).Fiber2_ID;            
            mean_hit_traces{i, 8} = mean(photosignal_hit_go_sound_fiber2, 1, 'omitnan');
            mean_hit_traces{i, 9} = photosignal_hit_go_sound_fiber2;

            mean_miss_traces{i, 4} = matchingSessions(i).Fiber1_ID;                
            mean_miss_traces{i, 5} = mean(photosignal_miss_go_sound_fiber1, 1, 'omitnan');
            mean_miss_traces{i, 6} = photosignal_miss_go_sound_fiber1;
            mean_miss_traces{i, 7} = matchingSessions(i).Fiber2_ID;            
            mean_miss_traces{i, 8} = mean(photosignal_miss_go_sound_fiber2, 1, 'omitnan');
            mean_miss_traces{i, 9} = photosignal_miss_go_sound_fiber2;

            mean_cr_traces{i, 4} = matchingSessions(i).Fiber1_ID;                
            mean_cr_traces{i, 5} = mean(photosignal_cr_nogo_sound_fiber1, 1, 'omitnan');
            mean_cr_traces{i, 6} = photosignal_cr_nogo_sound_fiber1;
            mean_cr_traces{i, 7} = matchingSessions(i).Fiber2_ID;            
            mean_cr_traces{i, 8} = mean(photosignal_cr_nogo_sound_fiber2, 1, 'omitnan');
            mean_cr_traces{i, 9} = photosignal_cr_nogo_sound_fiber2;

            mean_fa_traces{i, 4} = matchingSessions(i).Fiber1_ID;                
            mean_fa_traces{i, 5} = mean(photosignal_fa_nogo_sound_fiber1, 1, 'omitnan');
            mean_fa_traces{i, 6} = photosignal_fa_nogo_sound_fiber1;
            mean_fa_traces{i, 7} = matchingSessions(i).Fiber2_ID;            
            mean_fa_traces{i, 8} = mean(photosignal_fa_nogo_sound_fiber2, 1, 'omitnan');
            mean_fa_traces{i, 9} = photosignal_fa_nogo_sound_fiber2;

            animal_performance{i, 4} = matchingSessions(i).Hit_Rate_animal1;
            animal_performance{i, 5} = matchingSessions(i).FA_Rate_animal1;
            animal_performance{i, 6} = matchingSessions(i).D_Prime_animal1;

            animal_performance{i, 7} = matchingSessions(i).hit_go_sound_timestamps_animal1 - matchingSessions(i).trial_start_timestamps_animal1(1:size(matchingSessions(i).hit_go_sound_timestamps_animal1, 1), :); % Sound delay for association phase
            animal_performance{i, 8} = matchingSessions(i).moving_nogo_performance_animal1;
            animal_performance{i, 9} = matchingSessions(i).Response_Bias_animal1;

        elseif matchingSessions(i).animalID_2 == target_ID
            mean_go_traces{i, 4} = matchingSessions(i).Fiber3_ID;                
            mean_go_traces{i, 5} = mean(photosignal_go_sound_start_fiber3, 1, 'omitnan');
            mean_go_traces{i, 6} = photosignal_go_sound_start_fiber3;
            mean_go_traces{i, 7} = matchingSessions(i).Fiber4_ID;            
            mean_go_traces{i, 8} = mean(photosignal_go_sound_start_fiber4, 1, 'omitnan');
            mean_go_traces{i, 9} = photosignal_go_sound_start_fiber4;

            mean_nogo_traces{i, 4} = matchingSessions(i).Fiber3_ID;                
            mean_nogo_traces{i, 5} = mean(photosignal_nogo_sound_start_fiber3, 1, 'omitnan');
            mean_nogo_traces{i, 6} = photosignal_nogo_sound_start_fiber3;
            mean_nogo_traces{i, 7} = matchingSessions(i).Fiber4_ID;            
            mean_nogo_traces{i, 8} = mean(photosignal_nogo_sound_start_fiber4, 1, 'omitnan');
            mean_nogo_traces{i, 9} = photosignal_nogo_sound_start_fiber4;

            mean_hit_traces{i, 4} = matchingSessions(i).Fiber3_ID;            
            mean_hit_traces{i, 5} = mean(photosignal_hit_go_sound_fiber3, 1, 'omitnan');
            mean_hit_traces{i, 6} = photosignal_hit_go_sound_fiber3;
            mean_hit_traces{i, 7} = matchingSessions(i).Fiber4_ID;            
            mean_hit_traces{i, 8} = mean(photosignal_hit_go_sound_fiber4, 1, 'omitnan');
            mean_hit_traces{i, 9} = photosignal_hit_go_sound_fiber4;

            mean_miss_traces{i, 4} = matchingSessions(i).Fiber3_ID;            
            mean_miss_traces{i, 5} = mean(photosignal_miss_go_sound_fiber3, 1, 'omitnan');
            mean_miss_traces{i, 6} = photosignal_miss_go_sound_fiber3;
            mean_miss_traces{i, 7} = matchingSessions(i).Fiber4_ID;            
            mean_miss_traces{i, 8} = mean(photosignal_miss_go_sound_fiber4, 1, 'omitnan');
            mean_miss_traces{i, 9} = photosignal_miss_go_sound_fiber4;

            mean_cr_traces{i, 4} = matchingSessions(i).Fiber3_ID;            
            mean_cr_traces{i, 5} = mean(photosignal_cr_nogo_sound_fiber3, 1, 'omitnan');
            mean_cr_traces{i, 6} = photosignal_cr_nogo_sound_fiber3;
            mean_cr_traces{i, 7} = matchingSessions(i).Fiber4_ID;            
            mean_cr_traces{i, 8} = mean(photosignal_cr_nogo_sound_fiber4, 1, 'omitnan');
            mean_cr_traces{i, 9} = photosignal_cr_nogo_sound_fiber4;

            mean_fa_traces{i, 4} = matchingSessions(i).Fiber3_ID;            
            mean_fa_traces{i, 5} = mean(photosignal_fa_nogo_sound_fiber3, 1, 'omitnan');
            mean_fa_traces{i, 6} = photosignal_fa_nogo_sound_fiber3;
            mean_fa_traces{i, 7} = matchingSessions(i).Fiber4_ID;            
            mean_fa_traces{i, 8} = mean(photosignal_fa_nogo_sound_fiber4, 1, 'omitnan');
            mean_fa_traces{i, 9} = photosignal_fa_nogo_sound_fiber4;

            animal_performance{i, 4} = matchingSessions(i).Hit_Rate_animal2;
            animal_performance{i, 5} = matchingSessions(i).FA_Rate_animal2;
            animal_performance{i, 6} = matchingSessions(i).D_Prime_animal2;

            animal_performance{i, 7} = matchingSessions(i).hit_go_sound_timestamps_animal2 - matchingSessions(i).trial_start_timestamps_animal2(1:size(matchingSessions(i).hit_go_sound_timestamps_animal2, 1), :);
            animal_performance{i, 8} = matchingSessions(i).moving_nogo_performance_animal2;
            animal_performance{i, 9} = matchingSessions(i).Response_Bias_animal2;
            
        end

        clear photosignal_hit_go_sound_fiber1 photosignal_hit_go_sound_fiber2 photosignal_cr_nogo_sound_fiber1 ...
        photosignal_cr_nogo_sound_fiber2 photosignal_hit_go_sound_fiber3 photosignal_hit_go_sound_fiber4 photosignal_cr_nogo_sound_fiber3 photosignal_cr_nogo_sound_fiber4 ...
        photosignal_miss_go_sound_fiber1 photosignal_miss_go_sound_fiber2 photosignal_fa_nogo_sound_fiber1 ...
        photosignal_fa_nogo_sound_fiber2 photosignal_miss_go_sound_fiber3 photosignal_miss_go_sound_fiber4 photosignal_fa_nogo_sound_fiber3 photosignal_fa_nogo_sound_fiber4 ...
        target_ID target_date target_time isMatch

end

end