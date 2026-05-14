% Makes initial photometry figure for photometry session data
% figures are zscored, traces layered and heatmaps are added

for i = 1:size(photometryStruct, 2)

% Get behavioral data metrics
photo_behavioral(i) = photometry_go_nogo_analysis_funct(photometryStruct(i).behavioral_data_animal1_photoclock, photometryStruct(i).behavioral_data_animal2_photoclock);

end

        % Convert structures to tables
        table1 = struct2table(photometryStruct, 'AsArray', true);
        table2 = struct2table(photo_behavioral, 'AsArray', true);
        
        % Merge tables
        mergedTable = [table1, table2];
        
        % Convert back to structure
        photometryStruct = table2struct(mergedTable);
        photometryStruct = photometryStruct';
        
        clear photo_behavioral


h = waitbar(0,'Figure making in progress...');

for i = 1:size(photometryStruct, 2)

% Animal 1 Figure

if ~isempty(photometryStruct(i).animalID_1) &  photometryStruct(i).animalID_1 ~= "n/a"

   
    f = figure

        subplot(3, 3, 1);
        axis off;  % turn off axes
        text(0.1, ((1/7)*6), photometryStruct(i).animalID_1, 'FontSize', 10);
        text(0.1, ((1/7)*5), strcat(photometryStruct(i).session_date, 'T',  photometryStruct(i).session_time), 'FontSize', 10, 'Interpreter', 'none');
        text(0.1, ((1/7)*4), strcat('Phase:', mat2str(photometryStruct(i).phase_animal1, 2)), 'FontSize', 10);        
        text(0.1, ((1/7)*3), strcat('RW/min:', mat2str(photometryStruct(i).RW_Per_Min_animal1, 2)), 'FontSize', 10);
        text(0.1, ((1/7)*2), strcat('dprime light:', mat2str(photometryStruct(i).D_Prime_Light_animal1, 3)), 'FontSize', 10);
        text(0.1, ((1/7)*1), strcat('dprime:', mat2str(photometryStruct(i).D_Prime_animal1, 3)), 'FontSize', 10);
        text(0.6, ((1/7)*2), strcat('Max TTL Diff (ms):', mat2str((photometryStruct(i).max_fitted_ttl_difference_box1 * 1000), 3)), 'FontSize', 10);
        text(0.6, ((1/7)*1), strcat('Mean TTL Diff (ms):', mat2str((photometryStruct(i).mean_fitted_ttl_difference_box1 * 1000), 3)), 'FontSize', 10);        
        title('Session Info');

        subplot(6, 3, 2);
        plot(photometryStruct(i).deltafoverf_unfiltered(1:100:end, 3));
        ylabel('\DeltaF/F');
        title(strcat(photometryStruct(i).Fiber1_ID, ' unfiltered'), 'Interpreter', 'none');
        
        subplot(6, 3, 5);
        plot(photometryStruct(i).deltafoverf_debleached(1:100:end, 3));
        ylabel('\DeltaF/F');
        title(strcat(photometryStruct(i).Fiber1_ID, ' debleached'), 'Interpreter', 'none');

        subplot(6, 3, 3);
        plot(photometryStruct(i).deltafoverf_unfiltered(1:100:end, 4));
        ylabel('\DeltaF/F');
        title(strcat(photometryStruct(i).Fiber2_ID, ' unfiltered'), 'Interpreter', 'none');
        
        subplot(6, 3, 6);
        plot(photometryStruct(i).deltafoverf_debleached(1:100:end, 4));
        ylabel('\DeltaF/F');
        title(strcat(photometryStruct(i).Fiber2_ID, ' debleached'), 'Interpreter', 'none');

        % Obtain start of trial traces

            photosignal_trial_start_fiber1 = [];
            photosignal_trial_start_fiber2 = [];
            % photosignal_trial_start_fiber3 = [];
            % photosignal_trial_start_fiber4 = [];

            for q = 1:size(photometryStruct(i).trial_start_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_trial_start_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).trial_start_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).trial_start_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_trial_start_index, 1) > 80
                        photosignal_trial_start_index = photosignal_trial_start_index(1:80, 1);
                    elseif size(photosignal_trial_start_index, 1) < 80
                        photosignal_trial_start_fiber1(q, :) = NaN(1, 80);
                        photosignal_trial_start_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_trial_start_fiber1(q, :) = photometryStruct(i).deltafoverf_debleached(photosignal_trial_start_index, 3); 
                photosignal_trial_start_fiber2(q, :) = photometryStruct(i).deltafoverf_debleached(photosignal_trial_start_index, 4);

            end
                fiber1_baseline_means = mean(photosignal_trial_start_fiber1(:, 1:40), 2);
                fiber1_baseline_stds = std(photosignal_trial_start_fiber1(:, 1:40), 0, 2);
                fiber2_baseline_means = mean(photosignal_trial_start_fiber2(:, 1:40), 2);
                fiber2_baseline_stds = std(photosignal_trial_start_fiber2(:, 1:40), 0, 2);

                photosignal_trial_start_fiber1 = (photosignal_trial_start_fiber1 - fiber1_baseline_means) ./ fiber1_baseline_stds;
                photosignal_trial_start_fiber2 = (photosignal_trial_start_fiber2 - fiber2_baseline_means) ./ fiber2_baseline_stds;


            % for q = 1:size(photometryStruct(i).trial_start_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            %     photosignal_trial_start_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).trial_start_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).trial_start_timestamps_animal2(q, 1) + 1));
            %         if size(photosignal_trial_start_index, 1) > 80
            %             photosignal_trial_start_index = photosignal_trial_start_index(1:80, 1);
            %         elseif size(photosignal_trial_start_index, 1) < 80
            %             photosignal_trial_start_fiber3(q, :) = NaN(1, 80);
            %             photosignal_trial_start_fiber4(q, :) = NaN(1, 80);
            %             continue
            %         end
            %     photosignal_trial_start_fiber3(q, :) = photometryStruct(i).deltafoverf_debleached(photosignal_trial_start_index, 5);
            %     photosignal_trial_start_fiber4(q, :) = photometryStruct(i).deltafoverf_debleached(photosignal_trial_start_index, 6);
            % 
            % end
            % 
            %     try
            %     fiber3_baseline_means = mean(photosignal_trial_start_fiber3(:, 1:40), 2);
            %     fiber3_baseline_stds = std(photosignal_trial_start_fiber3(:, 1:40), 0, 2);
            %     fiber4_baseline_means = mean(photosignal_trial_start_fiber4(:, 1:40), 2);
            %     fiber4_baseline_stds = std(photosignal_trial_start_fiber4(:, 1:40), 0, 2);
            % 
            %     photosignal_trial_start_fiber3 = (photosignal_trial_start_fiber3 - fiber3_baseline_means) ./ fiber3_baseline_stds;
            %     photosignal_trial_start_fiber4 = (photosignal_trial_start_fiber4 - fiber4_baseline_means) ./ fiber4_baseline_stds;
            %     end

        % Obtain Hit traces

            photosignal_hit_go_sound_fiber1 = [];
            photosignal_hit_go_sound_fiber2 = [];
            % photosignal_hit_go_sound_fiber3 = [];
            % photosignal_hit_go_sound_fiber4 = [];
            trial_start_index_hit_go_sound_animal1 = knnsearch(photometryStruct(i).trial_start_timestamps_animal1, photometryStruct(i).hit_go_sound_timestamps_animal1);
            % trial_start_index_hit_go_sound_animal2 = knnsearch(photometryStruct(i).trial_start_timestamps_animal2, photometryStruct(i).hit_go_sound_timestamps_animal2);

            for q = 1:size(photometryStruct(i).hit_go_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session

                photosignal_hit_go_sound_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).hit_go_sound_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).hit_go_sound_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_hit_go_sound_index, 1) > 80
                        photosignal_hit_go_sound_index = photosignal_hit_go_sound_index(1:80, 1);
                    elseif size(photosignal_hit_go_sound_index, 1) < 80
                        photosignal_hit_go_sound_fiber1(q, :) = NaN(1, 80);
                        photosignal_hit_go_sound_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_hit_go_sound_fiber1(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_hit_go_sound_index, 3) - fiber1_baseline_means(trial_start_index_hit_go_sound_animal1(q, 1), 1)) / fiber1_baseline_stds(trial_start_index_hit_go_sound_animal1(q, 1), 1);
                photosignal_hit_go_sound_fiber2(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_hit_go_sound_index, 4) - fiber2_baseline_means(trial_start_index_hit_go_sound_animal1(q, 1), 1)) / fiber2_baseline_stds(trial_start_index_hit_go_sound_animal1(q, 1), 1);

            end


            % for q = 1:size(photometryStruct(i).hit_go_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            % 
            %     photosignal_hit_go_sound_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).hit_go_sound_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).hit_go_sound_timestamps_animal2(q, 1) + 1));
            %         if size(photosignal_hit_go_sound_index, 1) > 80
            %             photosignal_hit_go_sound_index = photosignal_hit_go_sound_index(1:80, 1);
            %         elseif size(photosignal_hit_go_sound_index, 1) < 80
            %             photosignal_hit_go_sound_fiber3(q, :) = NaN(1, 80);
            %             photosignal_hit_go_sound_fiber4(q, :) = NaN(1, 80);
            %             continue
            %         end
            %     photosignal_hit_go_sound_fiber3(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_hit_go_sound_index, 5) - fiber3_baseline_means(trial_start_index_hit_go_sound_animal2(q, 1), 1)) / fiber3_baseline_stds(trial_start_index_hit_go_sound_animal2(q, 1), 1);
            %     photosignal_hit_go_sound_fiber4(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_hit_go_sound_index, 6) - fiber4_baseline_means(trial_start_index_hit_go_sound_animal2(q, 1), 1)) / fiber4_baseline_stds(trial_start_index_hit_go_sound_animal2(q, 1), 1);
            % 
            % end

        % Obtain CR traces

            photosignal_cr_nogo_sound_fiber1 = [];
            photosignal_cr_nogo_sound_fiber2 = [];
            % photosignal_cr_nogo_sound_fiber3 = [];
            % photosignal_cr_nogo_sound_fiber4 = [];

            try
            trial_start_index_cr_nogo_sound_animal1 = knnsearch(photometryStruct(i).trial_start_timestamps_animal1, photometryStruct(i).cr_nogo_sound_timestamps_animal1);
            catch
                trial_start_index_cr_nogo_sound_animal1 = [];
            end
            
            % try
            % trial_start_index_cr_nogo_sound_animal2 = knnsearch(photometryStruct(i).trial_start_timestamps_animal2, photometryStruct(i).cr_nogo_sound_timestamps_animal2);
            % catch
            %     trial_start_index_cr_nogo_sound_animal2 = [];
            % end            

            for q = 1:size(photometryStruct(i).cr_nogo_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session

                photosignal_cr_nogo_sound_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).cr_nogo_sound_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).cr_nogo_sound_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_cr_nogo_sound_index, 1) > 80
                        photosignal_cr_nogo_sound_index = photosignal_cr_nogo_sound_index(1:80, 1);
                    elseif size(photosignal_cr_nogo_sound_index, 1) < 80
                        photosignal_cr_nogo_sound_fiber1(q, :) = NaN(1, 80);
                        photosignal_cr_nogo_sound_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_cr_nogo_sound_fiber1(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_cr_nogo_sound_index, 3) - fiber1_baseline_means(trial_start_index_cr_nogo_sound_animal1(q, 1), 1)) / fiber1_baseline_stds(trial_start_index_cr_nogo_sound_animal1(q, 1), 1);
                photosignal_cr_nogo_sound_fiber2(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_cr_nogo_sound_index, 4) - fiber2_baseline_means(trial_start_index_cr_nogo_sound_animal1(q, 1), 1)) / fiber2_baseline_stds(trial_start_index_cr_nogo_sound_animal1(q, 1), 1);

            end


            % for q = 1:size(photometryStruct(i).cr_nogo_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            % 
            %     photosignal_cr_nogo_sound_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).cr_nogo_sound_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).cr_nogo_sound_timestamps_animal2(q, 1) + 1));
            %         if size(photosignal_cr_nogo_sound_index, 1) > 80
            %             photosignal_cr_nogo_sound_index = photosignal_cr_nogo_sound_index(1:80, 1);
            %         elseif size(photosignal_cr_nogo_sound_index, 1) < 80
            %             photosignal_cr_nogo_sound_fiber3(q, :) = NaN(1, 80);
            %             photosignal_cr_nogo_sound_fiber4(q, :) = NaN(1, 80);
            %             continue
            %         end
            %     photosignal_cr_nogo_sound_fiber3(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_cr_nogo_sound_index, 5) - fiber3_baseline_means(trial_start_index_cr_nogo_sound_animal2(q, 1), 1)) / fiber3_baseline_stds(trial_start_index_cr_nogo_sound_animal2(q, 1), 1);
            %     photosignal_cr_nogo_sound_fiber4(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_cr_nogo_sound_index, 6) - fiber4_baseline_means(trial_start_index_cr_nogo_sound_animal2(q, 1), 1)) / fiber4_baseline_stds(trial_start_index_cr_nogo_sound_animal2(q, 1), 1);
            % 
            % end

        % Obtain premature traces

            photosignal_restart_fiber1 = [];
            photosignal_restart_fiber2 = [];
            % photosignal_restart_fiber3 = [];
            % photosignal_restart_fiber4 = [];

            try
            trial_start_index_restart_animal1 = knnsearch(photometryStruct(i).trial_start_timestamps_animal1, photometryStruct(i).restart_timestamps_animal1);
            catch
                trial_start_index_restart_animal1 = [];
            end
          
            % try
            % trial_start_index_restart_animal2 = knnsearch(photometryStruct(i).trial_start_timestamps_animal2, photometryStruct(i).restart_timestamps_animal2);
            % catch
            % trial_start_index_restart_animal2 = [];
            % end

            for q = 1:size(photometryStruct(i).restart_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session

                photosignal_restart_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).restart_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).restart_timestamps_animal1(q, 1) + 1));
                    if size(photosignal_restart_index, 1) > 80
                        photosignal_restart_index = photosignal_restart_index(1:80, 1);
                    elseif size(photosignal_restart_index, 1) < 80
                        photosignal_restart_fiber1(q, :) = NaN(1, 80);
                        photosignal_restart_fiber2(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_restart_fiber1(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_restart_index, 3) - fiber1_baseline_means(trial_start_index_restart_animal1(q, 1), 1)) / fiber1_baseline_stds(trial_start_index_restart_animal1(q, 1), 1);
                photosignal_restart_fiber2(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_restart_index, 4) - fiber2_baseline_means(trial_start_index_restart_animal1(q, 1), 1)) / fiber2_baseline_stds(trial_start_index_restart_animal1(q, 1), 1);

            end

            % 
            % for q = 1:size(photometryStruct(i).restart_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            % 
            %     photosignal_restart_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).restart_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).restart_timestamps_animal2(q, 1) + 1));
            %         if size(photosignal_restart_index, 1) > 80
            %             photosignal_restart_index = photosignal_restart_index(1:80, 1);
            %         elseif size(photosignal_restart_index, 1) < 80
            %             photosignal_restart_fiber3(q, :) = NaN(1, 80);
            %             photosignal_restart_fiber4(q, :) = NaN(1, 80);
            %             continue
            %         end
            %     photosignal_restart_fiber3(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_restart_index, 5) - fiber3_baseline_means(trial_start_index_restart_animal2(q, 1), 1)) / fiber3_baseline_stds(trial_start_index_restart_animal2(q, 1), 1);
            %     photosignal_restart_fiber4(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_restart_index, 6) - fiber4_baseline_means(trial_start_index_restart_animal2(q, 1), 1)) / fiber4_baseline_stds(trial_start_index_restart_animal2(q, 1), 1);
            % 
            % end


        % Plot Hits/CRs Fiber 1

            if size(photosignal_hit_go_sound_fiber1, 1) > 0
                subplot(6, 4, 13)
                yr = mean(photosignal_hit_go_sound_fiber1, 1, 'omitnan');
                    if size(photosignal_hit_go_sound_fiber1, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_hit_go_sound_fiber1, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_hit_go_sound_fiber1(:, 1))));
                    end
                x = [1:size(photosignal_hit_go_sound_fiber1, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 

                if size(photosignal_cr_nogo_sound_fiber1, 1) > 0
                    hold on
                    y = mean(photosignal_cr_nogo_sound_fiber1, 1, 'omitnan');
                        if size(photosignal_cr_nogo_sound_fiber1, 1) == 1
                            err = zeros(1, 80);
                        else
                             err = std(photosignal_cr_nogo_sound_fiber1, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_cr_nogo_sound_fiber1(:, 1))));
                        end
                    x = [1:size(photosignal_cr_nogo_sound_fiber1, 2)];
                    shadedErrorBar(x, y, err,'lineProps','r') 
                else
                    y = 0;
                end

                title(photometryStruct(i).Fiber1_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_hit_go_sound_fiber1, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_hit_go_sound_fiber1, 1) > 0
                subplot(6, 4, 17)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_hit_go_sound_fiber1;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Sound Start (s)";
                h.YLabel = 'Hit Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

            if size(photosignal_cr_nogo_sound_fiber1, 1) > 0
                subplot(6, 4, 21)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_cr_nogo_sound_fiber1;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Sound Start (s)";
                h.YLabel = 'CR Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end


        % Plot Restarts Fiber 1

            if size(photosignal_restart_fiber1, 1) > 0
                subplot(6, 4, 11)
                yr = mean(photosignal_restart_fiber1, 1, 'omitnan');
                    if size(photosignal_restart_fiber1, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_restart_fiber1, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_restart_fiber1(:, 1))));
                    end
                x = [1:size(photosignal_restart_fiber1, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 


                title(photometryStruct(i).Fiber1_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_restart_fiber1, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_restart_fiber1, 1) > 0
                subplot(6, 4, 15)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_restart_fiber1;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Premature Lick (s)";
                h.YLabel = 'Premature Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

        % Plot Trial Start Fiber 1

            if size(photosignal_trial_start_fiber1, 1) > 0
                subplot(6, 4, 19)
                yr = mean(photosignal_trial_start_fiber1, 1, 'omitnan');
                    if size(photosignal_trial_start_fiber1, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_trial_start_fiber1, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_trial_start_fiber1(:, 1))));
                    end
                x = [1:size(photosignal_trial_start_fiber1, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 


                %title(photometryStruct(i).Fiber1_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_trial_start_fiber1, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_trial_start_fiber1, 1) > 0
                subplot(6, 4, 23)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_trial_start_fiber1;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Light On (s)";
                h.YLabel = 'All Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

        % Plot Hits/CRs Fiber 2

            if size(photosignal_hit_go_sound_fiber2, 1) > 0
                subplot(6, 4, 14)
                yr = mean(photosignal_hit_go_sound_fiber2, 1, 'omitnan');
                    if size(photosignal_hit_go_sound_fiber2, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_hit_go_sound_fiber2, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_hit_go_sound_fiber2(:, 1))));
                    end
                x = [1:size(photosignal_hit_go_sound_fiber2, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 

                if size(photosignal_cr_nogo_sound_fiber2, 1) > 0
                    hold on
                    y = mean(photosignal_cr_nogo_sound_fiber2, 1, 'omitnan');
                        if size(photosignal_cr_nogo_sound_fiber2, 1) == 1
                            err = zeros(1, 80);
                        else
                             err = std(photosignal_cr_nogo_sound_fiber2, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_cr_nogo_sound_fiber2(:, 1))));
                        end
                    x = [1:size(photosignal_cr_nogo_sound_fiber2, 2)];
                    shadedErrorBar(x, y, err,'lineProps','r') 
                else
                    y = 0;
                end

                title(photometryStruct(i).Fiber2_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_hit_go_sound_fiber2, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_hit_go_sound_fiber2, 1) > 0
                subplot(6, 4, 18)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_hit_go_sound_fiber2;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Sound Start (s)";
                h.YLabel = 'Hit Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

            if size(photosignal_cr_nogo_sound_fiber2, 1) > 0
                subplot(6, 4, 22)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_cr_nogo_sound_fiber2;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Sound Start (s)";
                h.YLabel = 'CR Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end


        % Plot Restarts Fiber 2

            if size(photosignal_restart_fiber2, 1) > 0
                subplot(6, 4, 12)
                yr = mean(photosignal_restart_fiber2, 1, 'omitnan');
                    if size(photosignal_restart_fiber2, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_restart_fiber2, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_restart_fiber2(:, 1))));
                    end
                x = [1:size(photosignal_restart_fiber2, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 


                title(photometryStruct(i).Fiber2_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_restart_fiber2, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_restart_fiber2, 1) > 0
                subplot(6, 4, 16)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_restart_fiber2;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Premature Lick (s)";
                h.YLabel = 'Premature Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

        % Plot Trial Start Fiber 2

            if size(photosignal_trial_start_fiber2, 1) > 0
                subplot(6, 4, 20)
                yr = mean(photosignal_trial_start_fiber2, 1, 'omitnan');
                    if size(photosignal_trial_start_fiber2, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_trial_start_fiber2, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_trial_start_fiber2(:, 1))));
                    end
                x = [1:size(photosignal_trial_start_fiber2, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 


                %title(photometryStruct(i).Fiber2_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_trial_start_fiber2, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_trial_start_fiber2, 1) > 0
                subplot(6, 4, 24)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_trial_start_fiber2;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Light On (s)";
                h.YLabel = 'All Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

set(f, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

figname = strcat('InitialFig_blnorm_', photometryStruct(i).session_date, '_', photometryStruct(i).session_time, '_', photometryStruct(i).animalID_1, '.png');
saveas(gcf, fullfile(filepath, figname));
close all

end

if ~isempty(photometryStruct(i).animalID_2) & photometryStruct(i).animalID_2 ~= "n/a"

    f = figure

        subplot(3, 3, 1);
        axis off;  % turn off axes
        text(0.1, ((1/7)*6), photometryStruct(i).animalID_2, 'FontSize', 10);
        text(0.1, ((1/7)*5), strcat(photometryStruct(i).session_date, 'T',  photometryStruct(i).session_time), 'FontSize', 10, 'Interpreter', 'none');
        text(0.1, ((1/7)*4), strcat('Phase:', mat2str(photometryStruct(i).phase_animal2, 2)), 'FontSize', 10);        
        text(0.1, ((1/7)*3), strcat('RW/min:', mat2str(photometryStruct(i).RW_Per_Min_animal2, 2)), 'FontSize', 10);
        text(0.1, ((1/7)*2), strcat('dprime light:', mat2str(photometryStruct(i).D_Prime_Light_animal2, 3)), 'FontSize', 10);
        text(0.1, ((1/7)*1), strcat('dprime:', mat2str(photometryStruct(i).D_Prime_animal2, 3)), 'FontSize', 10);
        text(0.6, ((1/7)*2), strcat('Max TTL Diff (ms):', mat2str((photometryStruct(i).max_fitted_ttl_difference_box4 * 1000), 3)), 'FontSize', 10);
        text(0.6, ((1/7)*1), strcat('Mean TTL Diff (ms):', mat2str((photometryStruct(i).mean_fitted_ttl_difference_box4 * 1000), 3)), 'FontSize', 10);        
        title('Session Info');

        subplot(6, 3, 2);
        plot(photometryStruct(i).deltafoverf_unfiltered(1:100:end, 5));
        ylabel('\DeltaF/F');
        title(strcat(photometryStruct(i).Fiber3_ID, ' unfiltered'), 'Interpreter', 'none');
        
        subplot(6, 3, 5);
        plot(photometryStruct(i).deltafoverf_debleached(1:100:end, 5));
        ylabel('\DeltaF/F');
        title(strcat(photometryStruct(i).Fiber3_ID, ' debleached'), 'Interpreter', 'none');

        subplot(6, 3, 3);
        plot(photometryStruct(i).deltafoverf_unfiltered(1:100:end, 6));
        ylabel('\DeltaF/F');
        title(strcat(photometryStruct(i).Fiber4_ID, ' unfiltered'), 'Interpreter', 'none');
        
        subplot(6, 3, 6);
        plot(photometryStruct(i).deltafoverf_debleached(1:100:end, 6));
        ylabel('\DeltaF/F');
        title(strcat(photometryStruct(i).Fiber4_ID, ' debleached'), 'Interpreter', 'none');

        % Obtain start of trial traces

            % photosignal_trial_start_fiber1 = [];
            % photosignal_trial_start_fiber2 = [];
            photosignal_trial_start_fiber3 = [];
            photosignal_trial_start_fiber4 = [];

            % for q = 1:size(photometryStruct(i).trial_start_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            %     photosignal_trial_start_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).trial_start_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).trial_start_timestamps_animal1(q, 1) + 1));
            %         if size(photosignal_trial_start_index, 1) > 80
            %             photosignal_trial_start_index = photosignal_trial_start_index(1:80, 1);
            %         elseif size(photosignal_trial_start_index, 1) < 80
            %             photosignal_trial_start_fiber1(q, :) = NaN(1, 80);
            %             photosignal_trial_start_fiber2(q, :) = NaN(1, 80);
            %             continue
            %         end
            %     photosignal_trial_start_fiber1(q, :) = photometryStruct(i).deltafoverf_debleached(photosignal_trial_start_index, 3); 
            %     photosignal_trial_start_fiber2(q, :) = photometryStruct(i).deltafoverf_debleached(photosignal_trial_start_index, 4);
            % 
            % end
            %     fiber1_baseline_means = mean(photosignal_trial_start_fiber1(:, 1:40), 2);
            %     fiber1_baseline_stds = std(photosignal_trial_start_fiber1(:, 1:40), 0, 2);
            %     fiber2_baseline_means = mean(photosignal_trial_start_fiber2(:, 1:40), 2);
            %     fiber2_baseline_stds = std(photosignal_trial_start_fiber2(:, 1:40), 0, 2);
            % 
            %     photosignal_trial_start_fiber1 = (photosignal_trial_start_fiber1 - fiber1_baseline_means) ./ fiber1_baseline_stds;
            %     photosignal_trial_start_fiber2 = (photosignal_trial_start_fiber2 - fiber2_baseline_means) ./ fiber2_baseline_stds;


            for q = 1:size(photometryStruct(i).trial_start_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                photosignal_trial_start_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).trial_start_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).trial_start_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_trial_start_index, 1) > 80
                        photosignal_trial_start_index = photosignal_trial_start_index(1:80, 1);
                    elseif size(photosignal_trial_start_index, 1) < 80
                        photosignal_trial_start_fiber3(q, :) = NaN(1, 80);
                        photosignal_trial_start_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_trial_start_fiber3(q, :) = photometryStruct(i).deltafoverf_debleached(photosignal_trial_start_index, 5);
                photosignal_trial_start_fiber4(q, :) = photometryStruct(i).deltafoverf_debleached(photosignal_trial_start_index, 6);

            end

                fiber3_baseline_means = mean(photosignal_trial_start_fiber3(:, 1:40), 2);
                fiber3_baseline_stds = std(photosignal_trial_start_fiber3(:, 1:40), 0, 2);
                fiber4_baseline_means = mean(photosignal_trial_start_fiber4(:, 1:40), 2);
                fiber4_baseline_stds = std(photosignal_trial_start_fiber4(:, 1:40), 0, 2);

                photosignal_trial_start_fiber3 = (photosignal_trial_start_fiber3 - fiber3_baseline_means) ./ fiber3_baseline_stds;
                photosignal_trial_start_fiber4 = (photosignal_trial_start_fiber4 - fiber4_baseline_means) ./ fiber4_baseline_stds;

        % Obtain Hit traces

            % photosignal_hit_go_sound_fiber1 = [];
            % photosignal_hit_go_sound_fiber2 = [];
            photosignal_hit_go_sound_fiber3 = [];
            photosignal_hit_go_sound_fiber4 = [];
            trial_start_index_hit_go_sound_animal1 = knnsearch(photometryStruct(i).trial_start_timestamps_animal1, photometryStruct(i).hit_go_sound_timestamps_animal1);
            trial_start_index_hit_go_sound_animal2 = knnsearch(photometryStruct(i).trial_start_timestamps_animal2, photometryStruct(i).hit_go_sound_timestamps_animal2);

            % for q = 1:size(photometryStruct(i).hit_go_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            % 
            %     photosignal_hit_go_sound_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).hit_go_sound_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).hit_go_sound_timestamps_animal1(q, 1) + 1));
            %         if size(photosignal_hit_go_sound_index, 1) > 80
            %             photosignal_hit_go_sound_index = photosignal_hit_go_sound_index(1:80, 1);
            %         elseif size(photosignal_hit_go_sound_index, 1) < 80
            %             photosignal_hit_go_sound_fiber1(q, :) = NaN(1, 80);
            %             photosignal_hit_go_sound_fiber2(q, :) = NaN(1, 80);
            %             continue
            %         end
            %     photosignal_hit_go_sound_fiber1(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_hit_go_sound_index, 3) - fiber1_baseline_means(trial_start_index_hit_go_sound_animal1(q, 1), 1)) / fiber1_baseline_stds(trial_start_index_hit_go_sound_animal1(q, 1), 1);
            %     photosignal_hit_go_sound_fiber2(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_hit_go_sound_index, 4) - fiber2_baseline_means(trial_start_index_hit_go_sound_animal1(q, 1), 1)) / fiber2_baseline_stds(trial_start_index_hit_go_sound_animal1(q, 1), 1);
            % 
            % end


            for q = 1:size(photometryStruct(i).hit_go_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                
                photosignal_hit_go_sound_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).hit_go_sound_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).hit_go_sound_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_hit_go_sound_index, 1) > 80
                        photosignal_hit_go_sound_index = photosignal_hit_go_sound_index(1:80, 1);
                    elseif size(photosignal_hit_go_sound_index, 1) < 80
                        photosignal_hit_go_sound_fiber3(q, :) = NaN(1, 80);
                        photosignal_hit_go_sound_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_hit_go_sound_fiber3(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_hit_go_sound_index, 5) - fiber3_baseline_means(trial_start_index_hit_go_sound_animal2(q, 1), 1)) / fiber3_baseline_stds(trial_start_index_hit_go_sound_animal2(q, 1), 1);
                photosignal_hit_go_sound_fiber4(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_hit_go_sound_index, 6) - fiber4_baseline_means(trial_start_index_hit_go_sound_animal2(q, 1), 1)) / fiber4_baseline_stds(trial_start_index_hit_go_sound_animal2(q, 1), 1);

            end

        % Obtain CR traces

            % photosignal_cr_nogo_sound_fiber1 = [];
            % photosignal_cr_nogo_sound_fiber2 = [];
            photosignal_cr_nogo_sound_fiber3 = [];
            photosignal_cr_nogo_sound_fiber4 = [];

            % try
            % trial_start_index_cr_nogo_sound_animal1 = knnsearch(photometryStruct(i).trial_start_timestamps_animal1, photometryStruct(i).cr_nogo_sound_timestamps_animal1);
            % catch
            %     trial_start_index_cr_nogo_sound_animal1 = [];
            % end
            
            try
            trial_start_index_cr_nogo_sound_animal2 = knnsearch(photometryStruct(i).trial_start_timestamps_animal2, photometryStruct(i).cr_nogo_sound_timestamps_animal2);
            catch
                trial_start_index_cr_nogo_sound_animal2 = [];
            end   

            % for q = 1:size(photometryStruct(i).cr_nogo_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            % 
            %     photosignal_cr_nogo_sound_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).cr_nogo_sound_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).cr_nogo_sound_timestamps_animal1(q, 1) + 1));
            %         if size(photosignal_cr_nogo_sound_index, 1) > 80
            %             photosignal_cr_nogo_sound_index = photosignal_cr_nogo_sound_index(1:80, 1);
            %         elseif size(photosignal_cr_nogo_sound_index, 1) < 80
            %             photosignal_cr_nogo_sound_fiber1(q, :) = NaN(1, 80);
            %             photosignal_cr_nogo_sound_fiber2(q, :) = NaN(1, 80);
            %             continue
            %         end
            %     photosignal_cr_nogo_sound_fiber1(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_cr_nogo_sound_index, 3) - fiber1_baseline_means(trial_start_index_cr_nogo_sound_animal1(q, 1), 1)) / fiber1_baseline_stds(trial_start_index_cr_nogo_sound_animal1(q, 1), 1);
            %     photosignal_cr_nogo_sound_fiber2(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_cr_nogo_sound_index, 4) - fiber2_baseline_means(trial_start_index_cr_nogo_sound_animal1(q, 1), 1)) / fiber2_baseline_stds(trial_start_index_cr_nogo_sound_animal1(q, 1), 1);
            % 
            % end


            for q = 1:size(photometryStruct(i).cr_nogo_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                
                photosignal_cr_nogo_sound_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).cr_nogo_sound_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).cr_nogo_sound_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_cr_nogo_sound_index, 1) > 80
                        photosignal_cr_nogo_sound_index = photosignal_cr_nogo_sound_index(1:80, 1);
                    elseif size(photosignal_cr_nogo_sound_index, 1) < 80
                        photosignal_cr_nogo_sound_fiber3(q, :) = NaN(1, 80);
                        photosignal_cr_nogo_sound_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_cr_nogo_sound_fiber3(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_cr_nogo_sound_index, 5) - fiber3_baseline_means(trial_start_index_cr_nogo_sound_animal2(q, 1), 1)) / fiber3_baseline_stds(trial_start_index_cr_nogo_sound_animal2(q, 1), 1);
                photosignal_cr_nogo_sound_fiber4(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_cr_nogo_sound_index, 6) - fiber4_baseline_means(trial_start_index_cr_nogo_sound_animal2(q, 1), 1)) / fiber4_baseline_stds(trial_start_index_cr_nogo_sound_animal2(q, 1), 1);

            end

        % Obtain premature traces

            % photosignal_restart_fiber1 = [];
            % photosignal_restart_fiber2 = [];
            photosignal_restart_fiber3 = [];
            photosignal_restart_fiber4 = [];

            % try
            % trial_start_index_restart_animal1 = knnsearch(photometryStruct(i).trial_start_timestamps_animal1, photometryStruct(i).restart_timestamps_animal1);
            % catch
            %     trial_start_index_restart_animal1 = [];
            % end
          
            try
            trial_start_index_restart_animal2 = knnsearch(photometryStruct(i).trial_start_timestamps_animal2, photometryStruct(i).restart_timestamps_animal2);
            catch
            trial_start_index_restart_animal2 = [];
            end

            % for q = 1:size(photometryStruct(i).restart_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            % 
            %     photosignal_restart_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).restart_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).restart_timestamps_animal1(q, 1) + 1));
            %         if size(photosignal_restart_index, 1) > 80
            %             photosignal_restart_index = photosignal_restart_index(1:80, 1);
            %         elseif size(photosignal_restart_index, 1) < 80
            %             photosignal_restart_fiber1(q, :) = NaN(1, 80);
            %             photosignal_restart_fiber2(q, :) = NaN(1, 80);
            %             continue
            %         end
            %     photosignal_restart_fiber1(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_restart_index, 3) - fiber1_baseline_means(trial_start_index_restart_animal1(q, 1), 1)) / fiber1_baseline_stds(trial_start_index_restart_animal1(q, 1), 1);
            %     photosignal_restart_fiber2(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_restart_index, 4) - fiber2_baseline_means(trial_start_index_restart_animal1(q, 1), 1)) / fiber2_baseline_stds(trial_start_index_restart_animal1(q, 1), 1);
            % 
            % end


            for q = 1:size(photometryStruct(i).restart_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
                
                photosignal_restart_index = find(photometryStruct(i).deltafoverf_debleached(:, 2) >= (photometryStruct(i).restart_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_debleached(:, 2) < (photometryStruct(i).restart_timestamps_animal2(q, 1) + 1));
                    if size(photosignal_restart_index, 1) > 80
                        photosignal_restart_index = photosignal_restart_index(1:80, 1);
                    elseif size(photosignal_restart_index, 1) < 80
                        photosignal_restart_fiber3(q, :) = NaN(1, 80);
                        photosignal_restart_fiber4(q, :) = NaN(1, 80);
                        continue
                    end
                photosignal_restart_fiber3(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_restart_index, 5) - fiber3_baseline_means(trial_start_index_restart_animal2(q, 1), 1)) / fiber3_baseline_stds(trial_start_index_restart_animal2(q, 1), 1);
                photosignal_restart_fiber4(q, :) = (photometryStruct(i).deltafoverf_debleached(photosignal_restart_index, 6) - fiber4_baseline_means(trial_start_index_restart_animal2(q, 1), 1)) / fiber4_baseline_stds(trial_start_index_restart_animal2(q, 1), 1);

            end

        % Plot Hits/CRs Fiber 3

            if size(photosignal_hit_go_sound_fiber3, 1) > 0
                subplot(6, 4, 13)
                yr = mean(photosignal_hit_go_sound_fiber3, 1, 'omitnan');
                    if size(photosignal_hit_go_sound_fiber3, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_hit_go_sound_fiber3, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_hit_go_sound_fiber3(:, 1))));
                    end
                x = [1:size(photosignal_hit_go_sound_fiber3, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 

                if size(photosignal_cr_nogo_sound_fiber3, 1) > 0
                    hold on
                    y = mean(photosignal_cr_nogo_sound_fiber3, 1, 'omitnan');
                        if size(photosignal_cr_nogo_sound_fiber3, 1) == 1
                            err = zeros(1, 80);
                        else
                             err = std(photosignal_cr_nogo_sound_fiber3, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_cr_nogo_sound_fiber3(:, 1))));
                        end
                    x = [1:size(photosignal_cr_nogo_sound_fiber3, 2)];
                    shadedErrorBar(x, y, err,'lineProps','r') 
                else
                    y = 0;
                end

                title(photometryStruct(i).Fiber3_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_hit_go_sound_fiber3, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_hit_go_sound_fiber3, 1) > 0
                subplot(6, 4, 17)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_hit_go_sound_fiber3;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Sound Start (s)";
                h.YLabel = 'Hit Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

            if size(photosignal_cr_nogo_sound_fiber3, 1) > 0
                subplot(6, 4, 21)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_cr_nogo_sound_fiber3;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Sound Start (s)";
                h.YLabel = 'CR Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

        % Plot Restarts Fiber 3

            if size(photosignal_restart_fiber3, 1) > 0
                subplot(6, 4, 11)
                yr = mean(photosignal_restart_fiber3, 1, 'omitnan');
                    if size(photosignal_restart_fiber3, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_restart_fiber3, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_restart_fiber3(:, 1))));
                    end
                x = [1:size(photosignal_restart_fiber3, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 


                title(photometryStruct(i).Fiber3_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_restart_fiber3, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_restart_fiber3, 1) > 0
                subplot(6, 4, 15)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_restart_fiber3;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Premature Lick (s)";
                h.YLabel = 'Premature Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

        % Plot Trial Start Fiber 3

            if size(photosignal_trial_start_fiber3, 1) > 0
                subplot(6, 4, 19)
                yr = mean(photosignal_trial_start_fiber3, 1, 'omitnan');
                    if size(photosignal_trial_start_fiber3, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_trial_start_fiber3, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_trial_start_fiber3(:, 1))));
                    end
                x = [1:size(photosignal_trial_start_fiber3, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 


                %title(photometryStruct(i).Fiber3_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_trial_start_fiber3, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_trial_start_fiber3, 1) > 0
                subplot(6, 4, 23)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_trial_start_fiber3;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Light On (s)";
                h.YLabel = 'All Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

        % Plot Hits/CRs Fiber 4

            if size(photosignal_hit_go_sound_fiber4, 1) > 0
                subplot(6, 4, 14)
                yr = mean(photosignal_hit_go_sound_fiber4, 1, 'omitnan');
                    if size(photosignal_hit_go_sound_fiber4, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_hit_go_sound_fiber4, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_hit_go_sound_fiber4(:, 1))));
                    end
                x = [1:size(photosignal_hit_go_sound_fiber4, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 

                if size(photosignal_cr_nogo_sound_fiber4, 1) > 0
                    hold on
                    y = mean(photosignal_cr_nogo_sound_fiber4, 1, 'omitnan');
                        if size(photosignal_cr_nogo_sound_fiber4, 1) == 1
                            err = zeros(1, 80);
                        else
                             err = std(photosignal_cr_nogo_sound_fiber4, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_cr_nogo_sound_fiber4(:, 1))));
                        end
                    x = [1:size(photosignal_cr_nogo_sound_fiber4, 2)];
                    shadedErrorBar(x, y, err,'lineProps','r') 
                else
                    y = 0;
                end

                title(photometryStruct(i).Fiber4_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_hit_go_sound_fiber4, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_hit_go_sound_fiber4, 1) > 0
                subplot(6, 4, 18)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_hit_go_sound_fiber4;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Sound Start (s)";
                h.YLabel = 'Hit Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels

            end

            if size(photosignal_cr_nogo_sound_fiber4, 1) > 0
                subplot(6, 4, 22)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_cr_nogo_sound_fiber4;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Sound Start (s)";
                h.YLabel = 'CR Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                    % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels

            end


        % Plot Restarts Fiber 4

            if size(photosignal_restart_fiber4, 1) > 0
                subplot(6, 4, 12)
                yr = mean(photosignal_restart_fiber4, 1, 'omitnan');
                    if size(photosignal_restart_fiber4, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_restart_fiber4, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_restart_fiber4(:, 1))));
                    end
                x = [1:size(photosignal_restart_fiber4, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 


                title(photometryStruct(i).Fiber4_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_restart_fiber4, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-5 5])
                elseif (max(yr) < max(y))
                    ylim([-5 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-5 max(yr)])
                end

            end

            if size(photosignal_restart_fiber4, 1) > 0
                subplot(6, 4, 16)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_restart_fiber4;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Premature Lick (s)";
                h.YLabel = 'Premature Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

        % Plot Trial Start Fiber 4

            if size(photosignal_trial_start_fiber4, 1) > 0
                subplot(6, 4, 20)
                yr = mean(photosignal_trial_start_fiber4, 1, 'omitnan');
                    if size(photosignal_trial_start_fiber4, 1) == 1
                        err = zeros(1, 80);
                    else
                         err = std(photosignal_trial_start_fiber4, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_trial_start_fiber4(:, 1))));
                    end
                x = [1:size(photosignal_trial_start_fiber4, 2)];
                shadedErrorBar(x, yr, err,'lineProps','b') 


                %title(photometryStruct(i).Fiber4_ID, 'Interpreter', 'none');
                xticks([0:20:80])
                xticklabels([-1 -0.5 0 0.5 1])
                %xlabel("Time from Sound Start (s)")
                % ylabel(strcat('n =', ' ', string(size(photosignal_trial_start_fiber4, 1))))
                if (max(y) < 5) & (max(yr) < 5)
                    ylim([-2 5])
                elseif (max(yr) < max(y))
                    ylim([-2 max(y)])
                elseif (max(yr) > max(y))
                    ylim([-2 max(yr)])
                end

            end

            if size(photosignal_trial_start_fiber4, 1) > 0
                subplot(6, 4, 24)
                % Assuming photosignal_reward_fiber3 is your data matrix
                data = photosignal_trial_start_fiber4;

                % Create the heatmap
                h = heatmap(data);

                % Customize the heatmap appearance
                h.Colormap = jet;   % Apply blue-to-red color scale
                h.GridVisible = 'off';      % Disable gridlines
                %h.ColorLimits = [min(data(:)), max(data(:))]; % Adjust color scale to data range
                h.ColorLimits = [-5, 5];

                % Optional: Add axis labels and title
                h.XLabel = "Time from Light On (s)";
                h.YLabel = 'All Trials';
                %h.Title = 'Photosignal Heatmap (Fiber 1)';
                % Define the x-axis labels
                    x_tick_labels = {'-1', '-0.5', '0', '0.5', '1'};  
                    x_tick_positions = round(linspace(1, size(data, 2), length(x_tick_labels))); 

                    % Define y-axis labels as character vectors inside a cell array
                    y_tick_labels = cellstr(string(0:20:size(data, 1))); 
                    y_tick_positions = round(linspace(1, size(data, 1), numel(y_tick_labels))); 

                    % Apply labels to heatmap
                    h.XDisplayLabels = repmat("", 1, size(data, 2)); % Hide all labels by default
                    h.XDisplayLabels(x_tick_positions) = x_tick_labels; % Set desired x labels

                    h.YDisplayLabels = repmat({''}, size(data, 1), 1); % Hide all labels by default
                    h.YDisplayLabels(y_tick_positions) = y_tick_labels; % Set desired y labels
            end

set(f, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

figname = strcat('InitialFig_blnorm_', photometryStruct(i).session_date, '_', photometryStruct(i).session_time, '_', photometryStruct(i).animalID_2, '.png');
saveas(gcf, fullfile(filepath, figname));
close all

end

 waitbar(i / size(photometryStruct, 2))

end

close(h);