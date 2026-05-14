function output = combine_days(output)
% Takes output structure with multiple days of opto data and combines the
% multi-session data for each animal

    [~,index] = sortrows({output.date}.'); output = output(index); clear index
    [~,index] = sortrows({output.animalID}.'); output = output(index); clear index   

	data = struct2table(output);
	%data = sortrows(data,'phase','ascend');

	anID = findgroups(data.animalID);
    phaseg = findgroups(data.phase);
	%phaseday = findgroups(data.phase, data.day);

n_groups_ID = max(anID);
n_groups_ID_list = [1:n_groups_ID];

	for i = 1:(n_groups_ID)

		anID_{i, 1} = find(anID == n_groups_ID_list(1, i));
		anID_leg(i, 1) = data.animalID(anID_{i, 1}(1,1), 1);

    end

    	% For outputs that can just be easily added together across days

			for i = 1:size(anID_, 1)

						output_combined(i).animalID = output(anID_{i, 1}(1, 1)).animalID;

							output_combined(i).Hits_Light_Off = sum([output(anID_{i, 1}).Hits_Light_Off]);
							output_combined(i).Misses_Light_Off = sum([output(anID_{i, 1}).Misses_Light_Off]);
							output_combined(i).CRs_Light_Off = sum([output(anID_{i, 1}).CRs_Light_Off]);
							output_combined(i).FAs_Light_Off = sum([output(anID_{i, 1}).FAs_Light_Off]);
							output_combined(i).Total_Go_Sound_Light_Off = sum([output(anID_{i, 1}).Total_Go_Sound_Light_Off]);
							output_combined(i).Total_NoGo_Sound_Light_Off = sum([output(anID_{i, 1}).Total_NoGo_Sound_Light_Off]);
							output_combined(i).Hits_Light_On = sum([output(anID_{i, 1}).Hits_Light_On]);
							output_combined(i).Misses_Light_On = sum([output(anID_{i, 1}).Misses_Light_On]);
							output_combined(i).CRs_Light_On = sum([output(anID_{i, 1}).CRs_Light_On]);
							output_combined(i).FAs_Light_On = sum([output(anID_{i, 1}).FAs_Light_On]);
							output_combined(i).Total_Go_Sound_Light_On = sum([output(anID_{i, 1}).Total_Go_Sound_Light_On]);
							output_combined(i).Total_NoGo_Sound_Light_On = sum([output(anID_{i, 1}).Total_NoGo_Sound_Light_On]);
			
            
		            % Combine arrays
            
			            for p = 1:size(anID_{i, :}, 1)
            
				            if size(data.lps_raw{anID_{i, :}(p, 1), :}, 1) > 0
					            lps_raw{i, p} = data.lps_raw{anID_{i, :}(p, 1), :};
					            lps_raw_sizes(i, p) = size(data.lps_raw{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
				            else
					            lps_raw{i, p} = [];
					            lps_raw_sizes(i, p) = NaN;
				            end
            
				            if size(data.RW_latencies_light_off{anID_{i, :}(p, 1), :}, 1) > 0
					            RW_latencies_light_off{i, p} = data.RW_latencies_light_off{anID_{i, :}(p, 1), :};
					            RW_latencies_light_off_sizes(i, p) = size(data.RW_latencies_light_off{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
				            else
					            RW_latencies_light_off{i, p} = [];
					            RW_latencies_light_off_sizes(i, p) = NaN;
				            end		
            
				            if size(data.RW_latencies_light_on{anID_{i, :}(p, 1), :}, 1) > 0
					            RW_latencies_light_on{i, p} = data.RW_latencies_light_on{anID_{i, :}(p, 1), :};
					            RW_latencies_light_on_sizes(i, p) = size(data.RW_latencies_light_on{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
				            else
					            RW_latencies_light_on{i, p} = [];
					            RW_latencies_light_on_sizes(i, p) = NaN;
				            end		
            
            
				            if size(data.FA_latencies_light_off{anID_{i, :}(p, 1), :}, 1) > 0
					            FA_latencies_light_off{i, p} = data.FA_latencies_light_off{anID_{i, :}(p, 1), :};
					            FA_latencies_light_off_sizes(i, p) = size(data.FA_latencies_light_off{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
				            else
					            FA_latencies_light_off{i, p} = [];
					            FA_latencies_light_off_sizes(i, p) = NaN;
				            end		
            
				            if size(data.FA_latencies_light_on{anID_{i, :}(p, 1), :}, 1) > 0
					            FA_latencies_light_on{i, p} = data.FA_latencies_light_on{anID_{i, :}(p, 1), :};
					            FA_latencies_light_on_sizes(i, p) = size(data.FA_latencies_light_on{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
				            else
					            FA_latencies_light_on{i, p} = [];
					            FA_latencies_light_on_sizes(i, p) = NaN;
				            end		
            
                        end
            
            end


 			last_col_lps_raw = (size(lps_raw, 2) + 1);
 			last_col_RW_latencies_light_off = (size(RW_latencies_light_off, 2) + 1);
 			last_col_RW_latencies_light_on = (size(RW_latencies_light_on, 2) + 1);
 			last_col_FA_latencies_light_off = (size(FA_latencies_light_off, 2) + 1);
 			last_col_FA_latencies_light_on = (size(FA_latencies_light_on, 2) + 1);



for i = 1:size(anID_, 1)

    for j = 1:(last_col_lps_raw - 1)
        if j == 1
			lps_raw{i, last_col_lps_raw} = [];
    		lps_raw{i, last_col_lps_raw} = [lps_raw{i, last_col_lps_raw}; lps_raw{i, j};];
        else
			lps_raw{i, last_col_lps_raw} = [lps_raw{i, last_col_lps_raw}; lps_raw{i, j};];
        end

	data_sizes_lps_raw(i, 1) = size(lps_raw{i, last_col_lps_raw}, 1);

    end

    for j = 1:(last_col_RW_latencies_light_off - 1)
        if j == 1
			RW_latencies_light_off{i, last_col_RW_latencies_light_off} = [];
    		RW_latencies_light_off{i, last_col_RW_latencies_light_off} = [RW_latencies_light_off{i, last_col_RW_latencies_light_off}; RW_latencies_light_off{i, j};];
        else
			RW_latencies_light_off{i, last_col_RW_latencies_light_off} = [RW_latencies_light_off{i, last_col_RW_latencies_light_off}; RW_latencies_light_off{i, j};];
        end

	data_sizes_RW_latencies_light_off(i, 1) = size(RW_latencies_light_off{i, last_col_RW_latencies_light_off}, 1);

    end

    for j = 1:(last_col_RW_latencies_light_on - 1)
        if j == 1
			RW_latencies_light_on{i, last_col_RW_latencies_light_on} = [];
    		RW_latencies_light_on{i, last_col_RW_latencies_light_on} = [RW_latencies_light_on{i, last_col_RW_latencies_light_on}; RW_latencies_light_on{i, j};];
        else
			RW_latencies_light_on{i, last_col_RW_latencies_light_on} = [RW_latencies_light_on{i, last_col_RW_latencies_light_on}; RW_latencies_light_on{i, j};];
        end

	data_sizes_RW_latencies_light_on(i, 1) = size(RW_latencies_light_on{i, last_col_RW_latencies_light_on}, 1);

    end


    for j = 1:(last_col_FA_latencies_light_off - 1)
        if j == 1
			FA_latencies_light_off{i, last_col_FA_latencies_light_off} = [];
    		FA_latencies_light_off{i, last_col_FA_latencies_light_off} = [FA_latencies_light_off{i, last_col_FA_latencies_light_off}; FA_latencies_light_off{i, j};];
        else
			FA_latencies_light_off{i, last_col_FA_latencies_light_off} = [FA_latencies_light_off{i, last_col_FA_latencies_light_off}; FA_latencies_light_off{i, j};];
        end

	data_sizes_FA_latencies_light_off(i, 1) = size(FA_latencies_light_off{i, last_col_FA_latencies_light_off}, 1);

    end

    for j = 1:(last_col_FA_latencies_light_on - 1)
        if j == 1
			FA_latencies_light_on{i, last_col_FA_latencies_light_on} = [];
    		FA_latencies_light_on{i, last_col_FA_latencies_light_on} = [FA_latencies_light_on{i, last_col_FA_latencies_light_on}; FA_latencies_light_on{i, j};];
        else
			FA_latencies_light_on{i, last_col_FA_latencies_light_on} = [FA_latencies_light_on{i, last_col_FA_latencies_light_on}; FA_latencies_light_on{i, j};];
        end

	data_sizes_FA_latencies_light_on(i, 1) = size(FA_latencies_light_on{i, last_col_FA_latencies_light_on}, 1);

    end

output_combined(i).lps_raw = lps_raw{i, last_col_lps_raw}(:, :);
output_combined(i).RW_latencies_light_off = RW_latencies_light_off{i, last_col_RW_latencies_light_off}(:, :);
output_combined(i).RW_latencies_light_on = RW_latencies_light_on{i, last_col_RW_latencies_light_on}(:, :);
output_combined(i).FA_latencies_light_off = FA_latencies_light_off{i, last_col_FA_latencies_light_off}(:, :);
output_combined(i).FA_latencies_light_on = FA_latencies_light_on{i, last_col_FA_latencies_light_on}(:, :);

end






% 			% Combining entire arrays full of trial by trial data across days

% 				for p = 1:size(anID_{i, :}, 1)

% 					if size(data.pretarget_error_distance_optocont{anID_{i, :}(p, 1), :}, 1) > 0
% 						pretarget_error_dist_optocont{i, p} = data.pretarget_error_distance_optocont{anID_{i, :}(p, 1), :};
% 						pretarget_error_dist_optocont_sizes(i, p) = size(data.pretarget_error_distance_optocont{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pretarget_error_dist_optocont{i, p} = [];
% 						pretarget_error_dist_optocont_sizes(i, p) = NaN;
% 					end

% 					if size(data.pretarget_error_distance_optotarg{anID_{i, :}(p, 1), :}, 1) > 0
% 						pretarget_error_dist_optotarg{i, p} = data.pretarget_error_distance_optotarg{anID_{i, :}(p, 1), :};
% 						pretarget_error_dist_optotarg_sizes(i, p) = size(data.pretarget_error_distance_optotarg{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pretarget_error_dist_optotarg{i, p} = [];
% 						pretarget_error_dist_optotarg_sizes(i, p) = NaN;
% 					end		

% 					if size(data.pretarget_error_short_distance_optocont{anID_{i, :}(p, 1), :}, 1) > 0
% 						pretarget_error_short_dist_optocont{i, p} = data.pretarget_error_short_distance_optocont{anID_{i, :}(p, 1), :};
% 						pretarget_error_short_dist_optocont_sizes(i, p) = size(data.pretarget_error_short_distance_optocont{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pretarget_error_short_dist_optocont{i, p} = [];
% 						pretarget_error_short_dist_optocont_sizes(i, p) = NaN;
% 					end

% 					if size(data.pretarget_error_short_distance_optotarg{anID_{i, :}(p, 1), :}, 1) > 0
% 						pretarget_error_short_dist_optotarg{i, p} = data.pretarget_error_short_distance_optotarg{anID_{i, :}(p, 1), :};
% 						pretarget_error_short_dist_optotarg_sizes(i, p) = size(data.pretarget_error_short_distance_optotarg{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pretarget_error_short_dist_optotarg{i, p} = [];
% 						pretarget_error_short_dist_optotarg_sizes(i, p) = NaN;
% 					end		

% 					if size(data.pretarget_error_medium_distance_optocont{anID_{i, :}(p, 1), :}, 1) > 0
% 						pretarget_error_medium_dist_optocont{i, p} = data.pretarget_error_medium_distance_optocont{anID_{i, :}(p, 1), :};
% 						pretarget_error_medium_dist_optocont_sizes(i, p) = size(data.pretarget_error_medium_distance_optocont{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pretarget_error_medium_dist_optocont{i, p} = [];
% 						pretarget_error_medium_dist_optocont_sizes(i, p) = NaN;
% 					end

% 					if size(data.pretarget_error_medium_distance_optotarg{anID_{i, :}(p, 1), :}, 1) > 0
% 						pretarget_error_medium_dist_optotarg{i, p} = data.pretarget_error_medium_distance_optotarg{anID_{i, :}(p, 1), :};
% 						pretarget_error_medium_dist_optotarg_sizes(i, p) = size(data.pretarget_error_medium_distance_optotarg{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pretarget_error_medium_dist_optotarg{i, p} = [];
% 						pretarget_error_medium_dist_optotarg_sizes(i, p) = NaN;
% 					end	

% 					if size(data.pretarget_error_long_distance_optocont{anID_{i, :}(p, 1), :}, 1) > 0
% 						pretarget_error_long_dist_optocont{i, p} = data.pretarget_error_long_distance_optocont{anID_{i, :}(p, 1), :};
% 						pretarget_error_long_dist_optocont_sizes(i, p) = size(data.pretarget_error_long_distance_optocont{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pretarget_error_long_dist_optocont{i, p} = [];
% 						pretarget_error_long_dist_optocont_sizes(i, p) = NaN;
% 					end

% 					if size(data.pretarget_error_long_distance_optotarg{anID_{i, :}(p, 1), :}, 1) > 0
% 						pretarget_error_long_dist_optotarg{i, p} = data.pretarget_error_long_distance_optotarg{anID_{i, :}(p, 1), :};
% 						pretarget_error_long_dist_optotarg_sizes(i, p) = size(data.pretarget_error_long_distance_optotarg{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pretarget_error_long_dist_optotarg{i, p} = [];
% 						pretarget_error_long_dist_optotarg_sizes(i, p) = NaN;
% 					end	




% 					if size(data.reward_distances_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						reward_distances_opto_control{i, p} = data.reward_distances_opto_control{anID_{i, :}(p, 1), :};
% 						reward_distances_opto_control_sizes(i, p) = size(data.reward_distances_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						reward_distances_opto_control{i, p} = [];
% 						reward_distances_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.reward_distances_opto_target{anID_{i, :}(p, 1), :}, 1) > 0
% 						reward_distances_opto_target{i, p} = data.reward_distances_opto_target{anID_{i, :}(p, 1), :};
% 						reward_distances_opto_target_sizes(i, p) = size(data.reward_distances_opto_target{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						reward_distances_opto_target{i, p} = [];
% 						reward_distances_opto_target_sizes(i, p) = NaN;
% 					end

% 					if size(data.reward_distances_opto_control_short{anID_{i, :}(p, 1), :}, 1) > 0
% 						reward_distances_opto_control_short{i, p} = data.reward_distances_opto_control_short{anID_{i, :}(p, 1), :};
% 						reward_distances_opto_control_short_sizes(i, p) = size(data.reward_distances_opto_control_short{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						reward_distances_opto_control_short{i, p} = [];
% 						reward_distances_opto_control_short_sizes(i, p) = NaN;
% 					end

% 					if size(data.reward_distances_opto_target_short{anID_{i, :}(p, 1), :}, 1) > 0
% 						reward_distances_opto_target_short{i, p} = data.reward_distances_opto_target_short{anID_{i, :}(p, 1), :};
% 						reward_distances_opto_target_short_sizes(i, p) = size(data.reward_distances_opto_target_short{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						reward_distances_opto_target_short{i, p} = [];
% 						reward_distances_opto_target_short_sizes(i, p) = NaN;
% 					end

% 					if size(data.reward_distances_opto_control_medium{anID_{i, :}(p, 1), :}, 1) > 0
% 						reward_distances_opto_control_medium{i, p} = data.reward_distances_opto_control_medium{anID_{i, :}(p, 1), :};
% 						reward_distances_opto_control_medium_sizes(i, p) = size(data.reward_distances_opto_control_medium{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						reward_distances_opto_control_medium{i, p} = [];
% 						reward_distances_opto_control_medium_sizes(i, p) = NaN;
% 					end

% 					if size(data.reward_distances_opto_target_medium{anID_{i, :}(p, 1), :}, 1) > 0
% 						reward_distances_opto_target_medium{i, p} = data.reward_distances_opto_target_medium{anID_{i, :}(p, 1), :};
% 						reward_distances_opto_target_medium_sizes(i, p) = size(data.reward_distances_opto_target_medium{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						reward_distances_opto_target_medium{i, p} = [];
% 						reward_distances_opto_target_medium_sizes(i, p) = NaN;
% 					end

% 					if size(data.reward_distances_opto_control_long{anID_{i, :}(p, 1), :}, 1) > 0
% 						reward_distances_opto_control_long{i, p} = data.reward_distances_opto_control_long{anID_{i, :}(p, 1), :};
% 						reward_distances_opto_control_long_sizes(i, p) = size(data.reward_distances_opto_control_long{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						reward_distances_opto_control_long{i, p} = [];
% 						reward_distances_opto_control_long_sizes(i, p) = NaN;
% 					end	

% 					if size(data.reward_distances_opto_target_long{anID_{i, :}(p, 1), :}, 1) > 0
% 						reward_distances_opto_target_long{i, p} = data.reward_distances_opto_target_long{anID_{i, :}(p, 1), :};
% 						reward_distances_opto_target_long_sizes(i, p) = size(data.reward_distances_opto_target_long{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						reward_distances_opto_target_long{i, p} = [];
% 						reward_distances_opto_target_long_sizes(i, p) = NaN;
% 					end					





% 					if size(data.overall_go_latency_opto_control_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						overall_go_latency_opto_control_1{i, p} = data.overall_go_latency_opto_control_1{anID_{i, :}(p, 1), :};
% 						overall_go_latency_opto_control_1_sizes(i, p) = size(data.overall_go_latency_opto_control_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						overall_go_latency_opto_control_1{i, p} = [];
% 						overall_go_latency_opto_control_1_sizes(i, p) = NaN;
% 					end	

% 					if size(data.overall_go_latency_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						overall_go_latency_opto_target_1{i, p} = data.overall_go_latency_opto_target_1{anID_{i, :}(p, 1), :};
% 						overall_go_latency_opto_target_1_sizes(i, p) = size(data.overall_go_latency_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						overall_go_latency_opto_target_1{i, p} = [];
% 						overall_go_latency_opto_target_1_sizes(i, p) = NaN;
% 					end	

% 					if size(data.short_go_latency_opto_control_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						short_go_latency_opto_control_1{i, p} = data.short_go_latency_opto_control_1{anID_{i, :}(p, 1), :};
% 						short_go_latency_opto_control_1_sizes(i, p) = size(data.short_go_latency_opto_control_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						short_go_latency_opto_control_1{i, p} = [];
% 						short_go_latency_opto_control_1_sizes(i, p) = NaN;
% 					end	

% 					if size(data.short_go_latency_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						short_go_latency_opto_target_1{i, p} = data.short_go_latency_opto_target_1{anID_{i, :}(p, 1), :};
% 						short_go_latency_opto_target_1_sizes(i, p) = size(data.short_go_latency_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						short_go_latency_opto_target_1{i, p} = [];
% 						short_go_latency_opto_target_1_sizes(i, p) = NaN;
% 					end	


% 					if size(data.medium_go_latency_opto_control_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						medium_go_latency_opto_control_1{i, p} = data.medium_go_latency_opto_control_1{anID_{i, :}(p, 1), :};
% 						medium_go_latency_opto_control_1_sizes(i, p) = size(data.medium_go_latency_opto_control_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						medium_go_latency_opto_control_1{i, p} = [];
% 						medium_go_latency_opto_control_1_sizes(i, p) = NaN;
% 					end	

% 					if size(data.medium_go_latency_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						medium_go_latency_opto_target_1{i, p} = data.medium_go_latency_opto_target_1{anID_{i, :}(p, 1), :};
% 						medium_go_latency_opto_target_1_sizes(i, p) = size(data.medium_go_latency_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						medium_go_latency_opto_target_1{i, p} = [];
% 						medium_go_latency_opto_target_1_sizes(i, p) = NaN;
% 					end	


% 					if size(data.long_go_latency_opto_control_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						long_go_latency_opto_control_1{i, p} = data.long_go_latency_opto_control_1{anID_{i, :}(p, 1), :};
% 						long_go_latency_opto_control_1_sizes(i, p) = size(data.long_go_latency_opto_control_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						long_go_latency_opto_control_1{i, p} = [];
% 						long_go_latency_opto_control_1_sizes(i, p) = NaN;
% 					end	

% 					if size(data.long_go_latency_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						long_go_latency_opto_target_1{i, p} = data.long_go_latency_opto_target_1{anID_{i, :}(p, 1), :};
% 						long_go_latency_opto_target_1_sizes(i, p) = size(data.long_go_latency_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						long_go_latency_opto_target_1{i, p} = [];
% 						long_go_latency_opto_target_1_sizes(i, p) = NaN;
% 					end	



% 					if size(data.overall_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						overall_early_restart_distances_opto_control_1{i, p} = data.overall_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :};
% 						overall_early_restart_distances_opto_control_1_sizes(i, p) = size(data.overall_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						overall_early_restart_distances_opto_control_1{i, p} = [];
% 						overall_early_restart_distances_opto_control_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.overall_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						overall_early_restart_distances_opto_target_1{i, p} = data.overall_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :};
% 						overall_early_restart_distances_opto_target_1_sizes(i, p) = size(data.overall_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						overall_early_restart_distances_opto_target_1{i, p} = [];
% 						overall_early_restart_distances_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.short_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						short_early_restart_distances_opto_control_1{i, p} = data.short_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :};
% 						short_early_restart_distances_opto_control_1_sizes(i, p) = size(data.short_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						short_early_restart_distances_opto_control_1{i, p} = [];
% 						short_early_restart_distances_opto_control_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.short_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						short_early_restart_distances_opto_target_1{i, p} = data.short_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :};
% 						short_early_restart_distances_opto_target_1_sizes(i, p) = size(data.short_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						short_early_restart_distances_opto_target_1{i, p} = [];
% 						short_early_restart_distances_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.medium_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						medium_early_restart_distances_opto_control_1{i, p} = data.medium_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :};
% 						medium_early_restart_distances_opto_control_1_sizes(i, p) = size(data.medium_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						medium_early_restart_distances_opto_control_1{i, p} = [];
% 						medium_early_restart_distances_opto_control_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.medium_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						medium_early_restart_distances_opto_target_1{i, p} = data.medium_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :};
% 						medium_early_restart_distances_opto_target_1_sizes(i, p) = size(data.medium_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						medium_early_restart_distances_opto_target_1{i, p} = [];
% 						medium_early_restart_distances_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.long_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						long_early_restart_distances_opto_control_1{i, p} = data.long_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :};
% 						long_early_restart_distances_opto_control_1_sizes(i, p) = size(data.long_early_restart_distances_opto_control_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						long_early_restart_distances_opto_control_1{i, p} = [];
% 						long_early_restart_distances_opto_control_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.long_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						long_early_restart_distances_opto_target_1{i, p} = data.long_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :};
% 						long_early_restart_distances_opto_target_1_sizes(i, p) = size(data.long_early_restart_distances_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						long_early_restart_distances_opto_target_1{i, p} = [];
% 						long_early_restart_distances_opto_target_1_sizes(i, p) = NaN;
% 					end







% 					if size(data.optocont_short_repeat_blocks{anID_{i, :}(p, 1), :}, 1) > 0
% 						optocont_short_repeat_blocks{i, p} = data.optocont_short_repeat_blocks{anID_{i, :}(p, 1), :};
% 						optocont_short_repeat_blocks_sizes(i, p) = size(data.optocont_short_repeat_blocks{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						optocont_short_repeat_blocks{i, p} = [];
% 						optocont_short_repeat_blocks_sizes(i, p) = NaN;
% 					end

% 					if size(data.optotarg_short_repeat_blocks{anID_{i, :}(p, 1), :}, 1) > 0
% 						optotarg_short_repeat_blocks{i, p} = data.optotarg_short_repeat_blocks{anID_{i, :}(p, 1), :};
% 						optotarg_short_repeat_blocks_sizes(i, p) = size(data.optotarg_short_repeat_blocks{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						optotarg_short_repeat_blocks{i, p} = [];
% 						optotarg_short_repeat_blocks_sizes(i, p) = NaN;
% 					end

% 					if size(data.optocont_medium_repeat_blocks{anID_{i, :}(p, 1), :}, 1) > 0
% 						optocont_medium_repeat_blocks{i, p} = data.optocont_medium_repeat_blocks{anID_{i, :}(p, 1), :};
% 						optocont_medium_repeat_blocks_sizes(i, p) = size(data.optocont_medium_repeat_blocks{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						optocont_medium_repeat_blocks{i, p} = [];
% 						optocont_medium_repeat_blocks_sizes(i, p) = NaN;
% 					end

% 					if size(data.optotarg_medium_repeat_blocks{anID_{i, :}(p, 1), :}, 1) > 0
% 						optotarg_medium_repeat_blocks{i, p} = data.optotarg_medium_repeat_blocks{anID_{i, :}(p, 1), :};
% 						optotarg_medium_repeat_blocks_sizes(i, p) = size(data.optotarg_medium_repeat_blocks{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						optotarg_medium_repeat_blocks{i, p} = [];
% 						optotarg_medium_repeat_blocks_sizes(i, p) = NaN;
% 					end

% 					if size(data.optocont_long_repeat_blocks{anID_{i, :}(p, 1), :}, 1) > 0
% 						optocont_long_repeat_blocks{i, p} = data.optocont_long_repeat_blocks{anID_{i, :}(p, 1), :};
% 						optocont_long_repeat_blocks_sizes(i, p) = size(data.optocont_long_repeat_blocks{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						optocont_long_repeat_blocks{i, p} = [];
% 						optocont_long_repeat_blocks_sizes(i, p) = NaN;
% 					end

% 					if size(data.optotarg_long_repeat_blocks{anID_{i, :}(p, 1), :}, 1) > 0
% 						optotarg_long_repeat_blocks{i, p} = data.optotarg_long_repeat_blocks{anID_{i, :}(p, 1), :};
% 						optotarg_long_repeat_blocks_sizes(i, p) = size(data.optotarg_long_repeat_blocks{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						optotarg_long_repeat_blocks{i, p} = [];
% 						optotarg_long_repeat_blocks_sizes(i, p) = NaN;
% 					end


% 					% if size(data.precue_data_rawvel_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 					% 	precue_data_rawvel_opto_control{i, p} = data.precue_data_rawvel_opto_control{anID_{i, :}(p, 1), :};
% 					% 	precue_data_rawvel_opto_control_sizes(i, p) = size(data.precue_data_rawvel_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					% else
% 					% 	precue_data_rawvel_opto_control{i, p} = [];
% 					% 	precue_data_rawvel_opto_control_sizes(i, p) = NaN;
% 					% end

% 					% if size(data.precue_data_rawvel_short_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 					% 	precue_data_rawvel_short_opto_control{i, p} = data.precue_data_rawvel_short_opto_control{anID_{i, :}(p, 1), :};
% 					% 	precue_data_rawvel_short_opto_control_sizes(i, p) = size(data.precue_data_rawvel_short_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					% else
% 					% 	precue_data_rawvel_short_opto_control{i, p} = [];
% 					% 	precue_data_rawvel_short_opto_control_sizes(i, p) = NaN;
% 					% end

% 					% if size(data.precue_data_rawvel_medium_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 					% 	precue_data_rawvel_medium_opto_control{i, p} = data.precue_data_rawvel_medium_opto_control{anID_{i, :}(p, 1), :};
% 					% 	precue_data_rawvel_medium_opto_control_sizes(i, p) = size(data.precue_data_rawvel_medium_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					% else
% 					% 	precue_data_rawvel_medium_opto_control{i, p} = [];
% 					% 	precue_data_rawvel_medium_opto_control_sizes(i, p) = NaN;
% 					% end

% 					% if size(data.precue_data_rawvel_long_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 					% 	precue_data_rawvel_long_opto_control{i, p} = data.precue_data_rawvel_long_opto_control{anID_{i, :}(p, 1), :};
% 					% 	precue_data_rawvel_long_opto_control_sizes(i, p) = size(data.precue_data_rawvel_long_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					% else
% 					% 	precue_data_rawvel_long_opto_control{i, p} = [];
% 					% 	precue_data_rawvel_long_opto_control_sizes(i, p) = NaN;
% 					% end



% 					% if size(data.precue_data_rawvel_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 					% 	precue_data_rawvel_opto_target_1{i, p} = data.precue_data_rawvel_opto_target_1{anID_{i, :}(p, 1), :};
% 					% 	precue_data_rawvel_opto_target_1_sizes(i, p) = size(data.precue_data_rawvel_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					% else
% 					% 	precue_data_rawvel_opto_target_1{i, p} = [];
% 					% 	precue_data_rawvel_opto_target_1_sizes(i, p) = NaN;
% 					% end

% 					% if size(data.precue_data_rawvel_short_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 					% 	precue_data_rawvel_short_opto_target_1{i, p} = data.precue_data_rawvel_short_opto_target_1{anID_{i, :}(p, 1), :};
% 					% 	precue_data_rawvel_short_opto_target_1_sizes(i, p) = size(data.precue_data_rawvel_short_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					% else
% 					% 	precue_data_rawvel_short_opto_target_1{i, p} = [];
% 					% 	precue_data_rawvel_short_opto_target_1_sizes(i, p) = NaN;
% 					% end

% 					% if size(data.precue_data_rawvel_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 					% 	precue_data_rawvel_medium_opto_target_1{i, p} = data.precue_data_rawvel_medium_opto_target_1{anID_{i, :}(p, 1), :};
% 					% 	precue_data_rawvel_medium_opto_target_1_sizes(i, p) = size(data.precue_data_rawvel_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					% else
% 					% 	precue_data_rawvel_medium_opto_target_1{i, p} = [];
% 					% 	precue_data_rawvel_medium_opto_target_1_sizes(i, p) = NaN;
% 					% end

% 					% if size(data.precue_data_rawvel_long_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 					% 	precue_data_rawvel_long_opto_target_1{i, p} = data.precue_data_rawvel_long_opto_target_1{anID_{i, :}(p, 1), :};
% 					% 	precue_data_rawvel_long_opto_target_1_sizes(i, p) = size(data.precue_data_rawvel_long_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					% else
% 					% 	precue_data_rawvel_long_opto_target_1{i, p} = [];
% 					% 	precue_data_rawvel_long_opto_target_1_sizes(i, p) = NaN;
% 					% end






% 					if size(data.raw_vel_trace_all_short_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_all_short_opto_control{i, p} = data.raw_vel_trace_all_short_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_all_short_opto_control_sizes(i, p) = size(data.raw_vel_trace_all_short_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_all_short_opto_control{i, p} = [];
% 						raw_vel_trace_all_short_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_all_short_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_all_short_opto_target_1{i, p} = data.raw_vel_trace_all_short_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_all_short_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_all_short_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_all_short_opto_target_1{i, p} = [];
% 						raw_vel_trace_all_short_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_all_medium_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_all_medium_opto_control{i, p} = data.raw_vel_trace_all_medium_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_all_medium_opto_control_sizes(i, p) = size(data.raw_vel_trace_all_medium_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_all_medium_opto_control{i, p} = [];
% 						raw_vel_trace_all_medium_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_all_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_all_medium_opto_target_1{i, p} = data.raw_vel_trace_all_medium_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_all_medium_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_all_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_all_medium_opto_target_1{i, p} = [];
% 						raw_vel_trace_all_medium_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_all_long_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_all_long_opto_control{i, p} = data.raw_vel_trace_all_long_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_all_long_opto_control_sizes(i, p) = size(data.raw_vel_trace_all_long_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_all_long_opto_control{i, p} = [];
% 						raw_vel_trace_all_long_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_all_long_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_all_long_opto_target_1{i, p} = data.raw_vel_trace_all_long_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_all_long_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_all_long_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_all_long_opto_target_1{i, p} = [];
% 						raw_vel_trace_all_long_opto_target_1_sizes(i, p) = NaN;
% 					end



% 					if size(data.smooth_vel_trace_all_short_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_all_short_opto_control{i, p} = data.smooth_vel_trace_all_short_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_all_short_opto_control_sizes(i, p) = size(data.smooth_vel_trace_all_short_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_all_short_opto_control{i, p} = [];
% 						smooth_vel_trace_all_short_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_all_short_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_all_short_opto_target_1{i, p} = data.smooth_vel_trace_all_short_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_all_short_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_all_short_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_all_short_opto_target_1{i, p} = [];
% 						smooth_vel_trace_all_short_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_all_medium_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_all_medium_opto_control{i, p} = data.smooth_vel_trace_all_medium_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_all_medium_opto_control_sizes(i, p) = size(data.smooth_vel_trace_all_medium_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_all_medium_opto_control{i, p} = [];
% 						smooth_vel_trace_all_medium_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_all_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_all_medium_opto_target_1{i, p} = data.smooth_vel_trace_all_medium_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_all_medium_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_all_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_all_medium_opto_target_1{i, p} = [];
% 						smooth_vel_trace_all_medium_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_all_long_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_all_long_opto_control{i, p} = data.smooth_vel_trace_all_long_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_all_long_opto_control_sizes(i, p) = size(data.smooth_vel_trace_all_long_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_all_long_opto_control{i, p} = [];
% 						smooth_vel_trace_all_long_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_all_long_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_all_long_opto_target_1{i, p} = data.smooth_vel_trace_all_long_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_all_long_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_all_long_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_all_long_opto_target_1{i, p} = [];
% 						smooth_vel_trace_all_long_opto_target_1_sizes(i, p) = NaN;
% 					end









% 					if size(data.raw_vel_trace_RW_short_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_RW_short_opto_control{i, p} = data.raw_vel_trace_RW_short_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_RW_short_opto_control_sizes(i, p) = size(data.raw_vel_trace_RW_short_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_RW_short_opto_control{i, p} = [];
% 						raw_vel_trace_RW_short_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_RW_short_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_RW_short_opto_target_1{i, p} = data.raw_vel_trace_RW_short_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_RW_short_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_RW_short_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_RW_short_opto_target_1{i, p} = [];
% 						raw_vel_trace_RW_short_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_RW_medium_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_RW_medium_opto_control{i, p} = data.raw_vel_trace_RW_medium_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_RW_medium_opto_control_sizes(i, p) = size(data.raw_vel_trace_RW_medium_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_RW_medium_opto_control{i, p} = [];
% 						raw_vel_trace_RW_medium_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_RW_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_RW_medium_opto_target_1{i, p} = data.raw_vel_trace_RW_medium_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_RW_medium_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_RW_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_RW_medium_opto_target_1{i, p} = [];
% 						raw_vel_trace_RW_medium_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_RW_long_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_RW_long_opto_control{i, p} = data.raw_vel_trace_RW_long_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_RW_long_opto_control_sizes(i, p) = size(data.raw_vel_trace_RW_long_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_RW_long_opto_control{i, p} = [];
% 						raw_vel_trace_RW_long_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_RW_long_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_RW_long_opto_target_1{i, p} = data.raw_vel_trace_RW_long_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_RW_long_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_RW_long_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_RW_long_opto_target_1{i, p} = [];
% 						raw_vel_trace_RW_long_opto_target_1_sizes(i, p) = NaN;
% 					end



% 					if size(data.smooth_vel_trace_RW_short_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_RW_short_opto_control{i, p} = data.smooth_vel_trace_RW_short_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_RW_short_opto_control_sizes(i, p) = size(data.smooth_vel_trace_RW_short_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_RW_short_opto_control{i, p} = [];
% 						smooth_vel_trace_RW_short_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_RW_short_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_RW_short_opto_target_1{i, p} = data.smooth_vel_trace_RW_short_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_RW_short_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_RW_short_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_RW_short_opto_target_1{i, p} = [];
% 						smooth_vel_trace_RW_short_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_RW_medium_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_RW_medium_opto_control{i, p} = data.smooth_vel_trace_RW_medium_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_RW_medium_opto_control_sizes(i, p) = size(data.smooth_vel_trace_RW_medium_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_RW_medium_opto_control{i, p} = [];
% 						smooth_vel_trace_RW_medium_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_RW_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_RW_medium_opto_target_1{i, p} = data.smooth_vel_trace_RW_medium_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_RW_medium_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_RW_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_RW_medium_opto_target_1{i, p} = [];
% 						smooth_vel_trace_RW_medium_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_RW_long_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_RW_long_opto_control{i, p} = data.smooth_vel_trace_RW_long_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_RW_long_opto_control_sizes(i, p) = size(data.smooth_vel_trace_RW_long_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_RW_long_opto_control{i, p} = [];
% 						smooth_vel_trace_RW_long_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_RW_long_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_RW_long_opto_target_1{i, p} = data.smooth_vel_trace_RW_long_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_RW_long_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_RW_long_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_RW_long_opto_target_1{i, p} = [];
% 						smooth_vel_trace_RW_long_opto_target_1_sizes(i, p) = NaN;
% 					end








% 					if size(data.raw_vel_trace_PT_short_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_PT_short_opto_control{i, p} = data.raw_vel_trace_PT_short_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_PT_short_opto_control_sizes(i, p) = size(data.raw_vel_trace_PT_short_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_PT_short_opto_control{i, p} = [];
% 						raw_vel_trace_PT_short_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_PT_short_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_PT_short_opto_target_1{i, p} = data.raw_vel_trace_PT_short_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_PT_short_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_PT_short_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_PT_short_opto_target_1{i, p} = [];
% 						raw_vel_trace_PT_short_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_PT_medium_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_PT_medium_opto_control{i, p} = data.raw_vel_trace_PT_medium_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_PT_medium_opto_control_sizes(i, p) = size(data.raw_vel_trace_PT_medium_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_PT_medium_opto_control{i, p} = [];
% 						raw_vel_trace_PT_medium_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_PT_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_PT_medium_opto_target_1{i, p} = data.raw_vel_trace_PT_medium_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_PT_medium_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_PT_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_PT_medium_opto_target_1{i, p} = [];
% 						raw_vel_trace_PT_medium_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_PT_long_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_PT_long_opto_control{i, p} = data.raw_vel_trace_PT_long_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_PT_long_opto_control_sizes(i, p) = size(data.raw_vel_trace_PT_long_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_PT_long_opto_control{i, p} = [];
% 						raw_vel_trace_PT_long_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_PT_long_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_PT_long_opto_target_1{i, p} = data.raw_vel_trace_PT_long_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_PT_long_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_PT_long_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_PT_long_opto_target_1{i, p} = [];
% 						raw_vel_trace_PT_long_opto_target_1_sizes(i, p) = NaN;
% 					end



% 					if size(data.smooth_vel_trace_PT_short_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_PT_short_opto_control{i, p} = data.smooth_vel_trace_PT_short_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_PT_short_opto_control_sizes(i, p) = size(data.smooth_vel_trace_PT_short_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_PT_short_opto_control{i, p} = [];
% 						smooth_vel_trace_PT_short_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_PT_short_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_PT_short_opto_target_1{i, p} = data.smooth_vel_trace_PT_short_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_PT_short_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_PT_short_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_PT_short_opto_target_1{i, p} = [];
% 						smooth_vel_trace_PT_short_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_PT_medium_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_PT_medium_opto_control{i, p} = data.smooth_vel_trace_PT_medium_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_PT_medium_opto_control_sizes(i, p) = size(data.smooth_vel_trace_PT_medium_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_PT_medium_opto_control{i, p} = [];
% 						smooth_vel_trace_PT_medium_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_PT_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_PT_medium_opto_target_1{i, p} = data.smooth_vel_trace_PT_medium_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_PT_medium_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_PT_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_PT_medium_opto_target_1{i, p} = [];
% 						smooth_vel_trace_PT_medium_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_PT_long_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_PT_long_opto_control{i, p} = data.smooth_vel_trace_PT_long_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_PT_long_opto_control_sizes(i, p) = size(data.smooth_vel_trace_PT_long_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_PT_long_opto_control{i, p} = [];
% 						smooth_vel_trace_PT_long_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_PT_long_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_PT_long_opto_target_1{i, p} = data.smooth_vel_trace_PT_long_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_PT_long_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_PT_long_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_PT_long_opto_target_1{i, p} = [];
% 						smooth_vel_trace_PT_long_opto_target_1_sizes(i, p) = NaN;
% 					end



% 					if size(data.raw_vel_trace_OR_short_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_OR_short_opto_control{i, p} = data.raw_vel_trace_OR_short_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_OR_short_opto_control_sizes(i, p) = size(data.raw_vel_trace_OR_short_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_OR_short_opto_control{i, p} = [];
% 						raw_vel_trace_OR_short_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_OR_short_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_OR_short_opto_target_1{i, p} = data.raw_vel_trace_OR_short_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_OR_short_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_OR_short_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_OR_short_opto_target_1{i, p} = [];
% 						raw_vel_trace_OR_short_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_OR_medium_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_OR_medium_opto_control{i, p} = data.raw_vel_trace_OR_medium_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_OR_medium_opto_control_sizes(i, p) = size(data.raw_vel_trace_OR_medium_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_OR_medium_opto_control{i, p} = [];
% 						raw_vel_trace_OR_medium_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_OR_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_OR_medium_opto_target_1{i, p} = data.raw_vel_trace_OR_medium_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_OR_medium_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_OR_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_OR_medium_opto_target_1{i, p} = [];
% 						raw_vel_trace_OR_medium_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_OR_long_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_OR_long_opto_control{i, p} = data.raw_vel_trace_OR_long_opto_control{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_OR_long_opto_control_sizes(i, p) = size(data.raw_vel_trace_OR_long_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_OR_long_opto_control{i, p} = [];
% 						raw_vel_trace_OR_long_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.raw_vel_trace_OR_long_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						raw_vel_trace_OR_long_opto_target_1{i, p} = data.raw_vel_trace_OR_long_opto_target_1{anID_{i, :}(p, 1), :};
% 						raw_vel_trace_OR_long_opto_target_1_sizes(i, p) = size(data.raw_vel_trace_OR_long_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						raw_vel_trace_OR_long_opto_target_1{i, p} = [];
% 						raw_vel_trace_OR_long_opto_target_1_sizes(i, p) = NaN;
% 					end



% 					if size(data.smooth_vel_trace_OR_short_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_OR_short_opto_control{i, p} = data.smooth_vel_trace_OR_short_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_OR_short_opto_control_sizes(i, p) = size(data.smooth_vel_trace_OR_short_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_OR_short_opto_control{i, p} = [];
% 						smooth_vel_trace_OR_short_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_OR_short_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_OR_short_opto_target_1{i, p} = data.smooth_vel_trace_OR_short_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_OR_short_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_OR_short_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_OR_short_opto_target_1{i, p} = [];
% 						smooth_vel_trace_OR_short_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_OR_medium_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_OR_medium_opto_control{i, p} = data.smooth_vel_trace_OR_medium_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_OR_medium_opto_control_sizes(i, p) = size(data.smooth_vel_trace_OR_medium_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_OR_medium_opto_control{i, p} = [];
% 						smooth_vel_trace_OR_medium_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_OR_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_OR_medium_opto_target_1{i, p} = data.smooth_vel_trace_OR_medium_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_OR_medium_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_OR_medium_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_OR_medium_opto_target_1{i, p} = [];
% 						smooth_vel_trace_OR_medium_opto_target_1_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_OR_long_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_OR_long_opto_control{i, p} = data.smooth_vel_trace_OR_long_opto_control{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_OR_long_opto_control_sizes(i, p) = size(data.smooth_vel_trace_OR_long_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_OR_long_opto_control{i, p} = [];
% 						smooth_vel_trace_OR_long_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.smooth_vel_trace_OR_long_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						smooth_vel_trace_OR_long_opto_target_1{i, p} = data.smooth_vel_trace_OR_long_opto_target_1{anID_{i, :}(p, 1), :};
% 						smooth_vel_trace_OR_long_opto_target_1_sizes(i, p) = size(data.smooth_vel_trace_OR_long_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						smooth_vel_trace_OR_long_opto_target_1{i, p} = [];
% 						smooth_vel_trace_OR_long_opto_target_1_sizes(i, p) = NaN;
% 					end



% 					if size(data.pre_rw_lick_rates_opto_control{anID_{i, :}(p, 1), :}, 1) > 0
% 						pre_rw_lick_rates_opto_control{i, p} = data.pre_rw_lick_rates_opto_control{anID_{i, :}(p, 1), :};
% 						pre_rw_lick_rates_opto_control_sizes(i, p) = size(data.pre_rw_lick_rates_opto_control{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pre_rw_lick_rates_opto_control{i, p} = [];
% 						pre_rw_lick_rates_opto_control_sizes(i, p) = NaN;
% 					end

% 					if size(data.pre_rw_lick_rates_opto_target_1{anID_{i, :}(p, 1), :}, 1) > 0
% 						pre_rw_lick_rates_opto_target_1{i, p} = data.pre_rw_lick_rates_opto_target_1{anID_{i, :}(p, 1), :};
% 						pre_rw_lick_rates_opto_target_1_sizes(i, p) = size(data.pre_rw_lick_rates_opto_target_1{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
% 					else
% 						pre_rw_lick_rates_opto_target_1{i, p} = [];
% 						pre_rw_lick_rates_opto_target_1_sizes(i, p) = NaN;
% 					end



%                 end

% 			end

% 			last_col_pretarget_error_dist_optocont = (size(pretarget_error_dist_optocont, 2) + 1);
% 			last_col_pretarget_error_dist_optotarg = (size(pretarget_error_dist_optotarg, 2) + 1);

% 			last_col_pretarget_error_short_dist_optocont = (size(pretarget_error_short_dist_optocont, 2) + 1);
% 			last_col_pretarget_error_short_dist_optotarg = (size(pretarget_error_short_dist_optotarg, 2) + 1);

% 			last_col_pretarget_error_medium_dist_optocont = (size(pretarget_error_medium_dist_optocont, 2) + 1);
% 			last_col_pretarget_error_medium_dist_optotarg = (size(pretarget_error_medium_dist_optotarg, 2) + 1);

% 			last_col_pretarget_error_long_dist_optocont = (size(pretarget_error_long_dist_optocont, 2) + 1);
% 			last_col_pretarget_error_long_dist_optotarg = (size(pretarget_error_long_dist_optotarg, 2) + 1);



% 			last_col_reward_distances_opto_control = (size(reward_distances_opto_control, 2) + 1);
% 			last_col_reward_distances_opto_control_short = (size(reward_distances_opto_control_short, 2) + 1);
% 			last_col_reward_distances_opto_control_medium = (size(reward_distances_opto_control_medium, 2) + 1);
% 			last_col_reward_distances_opto_control_long = (size(reward_distances_opto_control_long, 2) + 1);

% 			last_col_reward_distances_opto_target = (size(reward_distances_opto_target, 2) + 1);
% 			last_col_reward_distances_opto_target_short = (size(reward_distances_opto_target_short, 2) + 1);
% 			last_col_reward_distances_opto_target_medium = (size(reward_distances_opto_target_medium, 2) + 1);
% 			last_col_reward_distances_opto_target_long = (size(reward_distances_opto_target_long, 2) + 1);



% 			last_col_overall_go_latency_opto_control_1 = (size(overall_go_latency_opto_control_1, 2) + 1);
% 			last_col_overall_go_latency_opto_target_1 = (size(overall_go_latency_opto_target_1, 2) + 1);

% 			last_col_short_go_latency_opto_control_1 = (size(short_go_latency_opto_control_1, 2) + 1);
% 			last_col_short_go_latency_opto_target_1 = (size(short_go_latency_opto_target_1, 2) + 1);

% 			last_col_medium_go_latency_opto_control_1 = (size(medium_go_latency_opto_control_1, 2) + 1);
% 			last_col_medium_go_latency_opto_target_1 = (size(medium_go_latency_opto_target_1, 2) + 1);

% 			last_col_long_go_latency_opto_control_1 = (size(long_go_latency_opto_control_1, 2) + 1);
% 			last_col_long_go_latency_opto_target_1 = (size(long_go_latency_opto_target_1, 2) + 1);



% 			last_col_overall_early_restart_distances_opto_control_1 = (size(overall_early_restart_distances_opto_control_1, 2) + 1);
% 			last_col_overall_early_restart_distances_opto_target_1 = (size(overall_early_restart_distances_opto_target_1, 2) + 1);

% 			last_col_short_early_restart_distances_opto_control_1 = (size(short_early_restart_distances_opto_control_1, 2) + 1);
% 			last_col_short_early_restart_distances_opto_target_1 = (size(short_early_restart_distances_opto_target_1, 2) + 1);

% 			last_col_medium_early_restart_distances_opto_control_1 = (size(medium_early_restart_distances_opto_control_1, 2) + 1);
% 			last_col_medium_early_restart_distances_opto_target_1 = (size(medium_early_restart_distances_opto_target_1, 2) + 1);

% 			last_col_long_early_restart_distances_opto_control_1 = (size(long_early_restart_distances_opto_control_1, 2) + 1);
% 			last_col_long_early_restart_distances_opto_target_1 = (size(long_early_restart_distances_opto_target_1, 2) + 1);



% 			last_col_optocont_short_repeat_blocks = (size(optocont_short_repeat_blocks, 2) + 1);
% 			last_col_optotarg_short_repeat_blocks = (size(optotarg_short_repeat_blocks, 2) + 1);

% 			last_col_optocont_medium_repeat_blocks = (size(optocont_medium_repeat_blocks, 2) + 1);
% 			last_col_optotarg_medium_repeat_blocks = (size(optotarg_medium_repeat_blocks, 2) + 1);

% 			last_col_optocont_long_repeat_blocks = (size(optocont_long_repeat_blocks, 2) + 1);
% 			last_col_optotarg_long_repeat_blocks = (size(optotarg_long_repeat_blocks, 2) + 1);




% 			% last_col_precue_data_rawvel_opto_control = (size(precue_data_rawvel_opto_control, 2) + 1);
% 			% last_col_precue_data_rawvel_short_opto_control = (size(precue_data_rawvel_short_opto_control, 2) + 1);
% 			% last_col_precue_data_rawvel_medium_opto_control = (size(precue_data_rawvel_medium_opto_control, 2) + 1);
% 			% last_col_precue_data_rawvel_long_opto_control = (size(precue_data_rawvel_long_opto_control, 2) + 1);


% 			% last_col_precue_data_rawvel_opto_target_1 = (size(precue_data_rawvel_opto_target_1, 2) + 1);
% 			% last_col_precue_data_rawvel_short_opto_target_1 = (size(precue_data_rawvel_short_opto_target_1, 2) + 1);
% 			% last_col_precue_data_rawvel_medium_opto_target_1 = (size(precue_data_rawvel_medium_opto_target_1, 2) + 1);
% 			% last_col_precue_data_rawvel_long_opto_target_1 = (size(precue_data_rawvel_long_opto_target_1, 2) + 1);



% 			last_col_raw_vel_trace_all_short_opto_control = (size(raw_vel_trace_all_short_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_all_short_opto_target_1 = (size(raw_vel_trace_all_short_opto_target_1, 2) + 1);
% 			last_col_raw_vel_trace_all_medium_opto_control = (size(raw_vel_trace_all_medium_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_all_medium_opto_target_1 = (size(raw_vel_trace_all_medium_opto_target_1, 2) + 1);
% 			last_col_raw_vel_trace_all_long_opto_control = (size(raw_vel_trace_all_long_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_all_long_opto_target_1 = (size(raw_vel_trace_all_long_opto_target_1, 2) + 1);

% 			last_col_smooth_vel_trace_all_short_opto_control = (size(smooth_vel_trace_all_short_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_all_short_opto_target_1 = (size(smooth_vel_trace_all_short_opto_target_1, 2) + 1);
% 			last_col_smooth_vel_trace_all_medium_opto_control = (size(smooth_vel_trace_all_medium_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_all_medium_opto_target_1 = (size(smooth_vel_trace_all_medium_opto_target_1, 2) + 1);
% 			last_col_smooth_vel_trace_all_long_opto_control = (size(smooth_vel_trace_all_long_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_all_long_opto_target_1 = (size(smooth_vel_trace_all_long_opto_target_1, 2) + 1);


% 			last_col_raw_vel_trace_PT_short_opto_control = (size(raw_vel_trace_PT_short_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_PT_short_opto_target_1 = (size(raw_vel_trace_PT_short_opto_target_1, 2) + 1);
% 			last_col_raw_vel_trace_PT_medium_opto_control = (size(raw_vel_trace_PT_medium_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_PT_medium_opto_target_1 = (size(raw_vel_trace_PT_medium_opto_target_1, 2) + 1);
% 			last_col_raw_vel_trace_PT_long_opto_control = (size(raw_vel_trace_PT_long_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_PT_long_opto_target_1 = (size(raw_vel_trace_PT_long_opto_target_1, 2) + 1);

% 			last_col_smooth_vel_trace_PT_short_opto_control = (size(smooth_vel_trace_PT_short_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_PT_short_opto_target_1 = (size(smooth_vel_trace_PT_short_opto_target_1, 2) + 1);
% 			last_col_smooth_vel_trace_PT_medium_opto_control = (size(smooth_vel_trace_PT_medium_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_PT_medium_opto_target_1 = (size(smooth_vel_trace_PT_medium_opto_target_1, 2) + 1);
% 			last_col_smooth_vel_trace_PT_long_opto_control = (size(smooth_vel_trace_PT_long_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_PT_long_opto_target_1 = (size(smooth_vel_trace_PT_long_opto_target_1, 2) + 1);


% 			last_col_raw_vel_trace_RW_short_opto_control = (size(raw_vel_trace_RW_short_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_RW_short_opto_target_1 = (size(raw_vel_trace_RW_short_opto_target_1, 2) + 1);
% 			last_col_raw_vel_trace_RW_medium_opto_control = (size(raw_vel_trace_RW_medium_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_RW_medium_opto_target_1 = (size(raw_vel_trace_RW_medium_opto_target_1, 2) + 1);
% 			last_col_raw_vel_trace_RW_long_opto_control = (size(raw_vel_trace_RW_long_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_RW_long_opto_target_1 = (size(raw_vel_trace_RW_long_opto_target_1, 2) + 1);

% 			last_col_smooth_vel_trace_RW_short_opto_control = (size(smooth_vel_trace_RW_short_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_RW_short_opto_target_1 = (size(smooth_vel_trace_RW_short_opto_target_1, 2) + 1);
% 			last_col_smooth_vel_trace_RW_medium_opto_control = (size(smooth_vel_trace_RW_medium_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_RW_medium_opto_target_1 = (size(smooth_vel_trace_RW_medium_opto_target_1, 2) + 1);
% 			last_col_smooth_vel_trace_RW_long_opto_control = (size(smooth_vel_trace_RW_long_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_RW_long_opto_target_1 = (size(smooth_vel_trace_RW_long_opto_target_1, 2) + 1);

% 			last_col_raw_vel_trace_OR_short_opto_control = (size(raw_vel_trace_OR_short_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_OR_short_opto_target_1 = (size(raw_vel_trace_OR_short_opto_target_1, 2) + 1);
% 			last_col_raw_vel_trace_OR_medium_opto_control = (size(raw_vel_trace_OR_medium_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_OR_medium_opto_target_1 = (size(raw_vel_trace_OR_medium_opto_target_1, 2) + 1);
% 			last_col_raw_vel_trace_OR_long_opto_control = (size(raw_vel_trace_OR_long_opto_control, 2) + 1);
% 			last_col_raw_vel_trace_OR_long_opto_target_1 = (size(raw_vel_trace_OR_long_opto_target_1, 2) + 1);

% 			last_col_smooth_vel_trace_OR_short_opto_control = (size(smooth_vel_trace_OR_short_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_OR_short_opto_target_1 = (size(smooth_vel_trace_OR_short_opto_target_1, 2) + 1);
% 			last_col_smooth_vel_trace_OR_medium_opto_control = (size(smooth_vel_trace_OR_medium_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_OR_medium_opto_target_1 = (size(smooth_vel_trace_OR_medium_opto_target_1, 2) + 1);
% 			last_col_smooth_vel_trace_OR_long_opto_control = (size(smooth_vel_trace_OR_long_opto_control, 2) + 1);
% 			last_col_smooth_vel_trace_OR_long_opto_target_1 = (size(smooth_vel_trace_OR_long_opto_target_1, 2) + 1);


% 			last_col_pre_rw_lick_rates_opto_control = (size(pre_rw_lick_rates_opto_control, 2) + 1);
% 			last_col_pre_rw_lick_rates_opto_target_1 = (size(pre_rw_lick_rates_opto_target_1, 2) + 1);

% 	        for i = 1:size(anID_, 1)
%                 for j = 1:(last_col_pretarget_error_dist_optocont - 1)
%                     if j == 1
% 						pretarget_error_dist_optocont{i, last_col_pretarget_error_dist_optocont} = [];
%                 		pretarget_error_dist_optocont{i, last_col_pretarget_error_dist_optocont} = [pretarget_error_dist_optocont{i, last_col_pretarget_error_dist_optocont}; pretarget_error_dist_optocont{i, j};];
%                     else
% 						pretarget_error_dist_optocont{i, last_col_pretarget_error_dist_optocont} = [pretarget_error_dist_optocont{i, last_col_pretarget_error_dist_optocont}; pretarget_error_dist_optocont{i, j};];
%                     end

% 				data_sizes_pretarget_error_dist_optocont(i, 1) = size(pretarget_error_dist_optocont{i, last_col_pretarget_error_dist_optocont}, 1);

%                 end

%                 for j = 1:(last_col_pretarget_error_dist_optotarg - 1)
%                     if j == 1
% 						pretarget_error_dist_optotarg{i, last_col_pretarget_error_dist_optotarg} = [];
%                 		pretarget_error_dist_optotarg{i, last_col_pretarget_error_dist_optotarg} = [pretarget_error_dist_optotarg{i, last_col_pretarget_error_dist_optotarg}; pretarget_error_dist_optotarg{i, j};];
%                     else
% 						pretarget_error_dist_optotarg{i, last_col_pretarget_error_dist_optotarg} = [pretarget_error_dist_optotarg{i, last_col_pretarget_error_dist_optotarg}; pretarget_error_dist_optotarg{i, j};];
%                     end

% 				data_sizes_pretarget_error_dist_optotarg(i, 1) = size(pretarget_error_dist_optotarg{i, last_col_pretarget_error_dist_optotarg}, 1);

%                 end

%                 for j = 1:(last_col_pretarget_error_short_dist_optocont - 1)
%                     if j == 1
% 						pretarget_error_short_dist_optocont{i, last_col_pretarget_error_short_dist_optocont} = [];
%                 		pretarget_error_short_dist_optocont{i, last_col_pretarget_error_short_dist_optocont} = [pretarget_error_short_dist_optocont{i, last_col_pretarget_error_short_dist_optocont}; pretarget_error_short_dist_optocont{i, j};];
%                     else
% 						pretarget_error_short_dist_optocont{i, last_col_pretarget_error_short_dist_optocont} = [pretarget_error_short_dist_optocont{i, last_col_pretarget_error_short_dist_optocont}; pretarget_error_short_dist_optocont{i, j};];
%                     end

% 				data_sizes_pretarget_error_short_dist_optocont(i, 1) = size(pretarget_error_short_dist_optocont{i, last_col_pretarget_error_short_dist_optocont}, 1);

%                 end

%                 for j = 1:(last_col_pretarget_error_short_dist_optotarg - 1)
%                     if j == 1
% 						pretarget_error_short_dist_optotarg{i, last_col_pretarget_error_short_dist_optotarg} = [];
%                 		pretarget_error_short_dist_optotarg{i, last_col_pretarget_error_short_dist_optotarg} = [pretarget_error_short_dist_optotarg{i, last_col_pretarget_error_short_dist_optotarg}; pretarget_error_short_dist_optotarg{i, j};];
%                     else
% 						pretarget_error_short_dist_optotarg{i, last_col_pretarget_error_short_dist_optotarg} = [pretarget_error_short_dist_optotarg{i, last_col_pretarget_error_short_dist_optotarg}; pretarget_error_short_dist_optotarg{i, j};];
%                     end

% 				data_sizes_pretarget_error_short_dist_optotarg(i, 1) = size(pretarget_error_short_dist_optotarg{i, last_col_pretarget_error_short_dist_optotarg}, 1);

%                 end

%                 for j = 1:(last_col_pretarget_error_medium_dist_optocont - 1)
%                     if j == 1
% 						pretarget_error_medium_dist_optocont{i, last_col_pretarget_error_medium_dist_optocont} = [];
%                 		pretarget_error_medium_dist_optocont{i, last_col_pretarget_error_medium_dist_optocont} = [pretarget_error_medium_dist_optocont{i, last_col_pretarget_error_medium_dist_optocont}; pretarget_error_medium_dist_optocont{i, j};];
%                     else
% 						pretarget_error_medium_dist_optocont{i, last_col_pretarget_error_medium_dist_optocont} = [pretarget_error_medium_dist_optocont{i, last_col_pretarget_error_medium_dist_optocont}; pretarget_error_medium_dist_optocont{i, j};];
%                     end

% 				data_sizes_pretarget_error_medium_dist_optocont(i, 1) = size(pretarget_error_medium_dist_optocont{i, last_col_pretarget_error_medium_dist_optocont}, 1);

%                 end

%                 for j = 1:(last_col_pretarget_error_medium_dist_optotarg - 1)
%                     if j == 1
% 						pretarget_error_medium_dist_optotarg{i, last_col_pretarget_error_medium_dist_optotarg} = [];
%                 		pretarget_error_medium_dist_optotarg{i, last_col_pretarget_error_medium_dist_optotarg} = [pretarget_error_medium_dist_optotarg{i, last_col_pretarget_error_medium_dist_optotarg}; pretarget_error_medium_dist_optotarg{i, j};];
%                     else
% 						pretarget_error_medium_dist_optotarg{i, last_col_pretarget_error_medium_dist_optotarg} = [pretarget_error_medium_dist_optotarg{i, last_col_pretarget_error_medium_dist_optotarg}; pretarget_error_medium_dist_optotarg{i, j};];
%                     end

% 				data_sizes_pretarget_error_medium_dist_optotarg(i, 1) = size(pretarget_error_medium_dist_optotarg{i, last_col_pretarget_error_medium_dist_optotarg}, 1);

%                 end 

%                 for j = 1:(last_col_pretarget_error_long_dist_optocont - 1)
%                     if j == 1
% 						pretarget_error_long_dist_optocont{i, last_col_pretarget_error_long_dist_optocont} = [];
%                 		pretarget_error_long_dist_optocont{i, last_col_pretarget_error_long_dist_optocont} = [pretarget_error_long_dist_optocont{i, last_col_pretarget_error_long_dist_optocont}; pretarget_error_long_dist_optocont{i, j};];
%                     else
% 						pretarget_error_long_dist_optocont{i, last_col_pretarget_error_long_dist_optocont} = [pretarget_error_long_dist_optocont{i, last_col_pretarget_error_long_dist_optocont}; pretarget_error_long_dist_optocont{i, j};];
%                     end

% 				data_sizes_pretarget_error_long_dist_optocont(i, 1) = size(pretarget_error_long_dist_optocont{i, last_col_pretarget_error_long_dist_optocont}, 1);

%                 end

%                 for j = 1:(last_col_pretarget_error_long_dist_optotarg - 1)
%                     if j == 1
% 						pretarget_error_long_dist_optotarg{i, last_col_pretarget_error_long_dist_optotarg} = [];
%                 		pretarget_error_long_dist_optotarg{i, last_col_pretarget_error_long_dist_optotarg} = [pretarget_error_long_dist_optotarg{i, last_col_pretarget_error_long_dist_optotarg}; pretarget_error_long_dist_optotarg{i, j};];
%                     else
% 						pretarget_error_long_dist_optotarg{i, last_col_pretarget_error_long_dist_optotarg} = [pretarget_error_long_dist_optotarg{i, last_col_pretarget_error_long_dist_optotarg}; pretarget_error_long_dist_optotarg{i, j};];
%                     end

% 				data_sizes_pretarget_error_long_dist_optotarg(i, 1) = size(pretarget_error_long_dist_optotarg{i, last_col_pretarget_error_long_dist_optotarg}, 1);

%                 end  





%                 for j = 1:(last_col_reward_distances_opto_control - 1)
%                     if j == 1
% 						reward_distances_opto_control{i, last_col_reward_distances_opto_control} = [];
%                 		reward_distances_opto_control{i, last_col_reward_distances_opto_control} = [reward_distances_opto_control{i, last_col_reward_distances_opto_control}; reward_distances_opto_control{i, j};];
%                     else
% 						reward_distances_opto_control{i, last_col_reward_distances_opto_control} = [reward_distances_opto_control{i, last_col_reward_distances_opto_control}; reward_distances_opto_control{i, j};];
%                     end

% 				data_sizes_reward_distances_opto_control(i, 1) = size(reward_distances_opto_control{i, last_col_reward_distances_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_reward_distances_opto_control_short - 1)
%                     if j == 1
% 						reward_distances_opto_control_short{i, last_col_reward_distances_opto_control_short} = [];
%                 		reward_distances_opto_control_short{i, last_col_reward_distances_opto_control_short} = [reward_distances_opto_control_short{i, last_col_reward_distances_opto_control_short}; reward_distances_opto_control_short{i, j};];
%                     else
% 						reward_distances_opto_control_short{i, last_col_reward_distances_opto_control_short} = [reward_distances_opto_control_short{i, last_col_reward_distances_opto_control_short}; reward_distances_opto_control_short{i, j};];
%                     end

% 				data_sizes_reward_distances_opto_control_short(i, 1) = size(reward_distances_opto_control_short{i, last_col_reward_distances_opto_control_short}, 1);

%                 end

%                 for j = 1:(last_col_reward_distances_opto_control_medium - 1)
%                     if j == 1
% 						reward_distances_opto_control_medium{i, last_col_reward_distances_opto_control_medium} = [];
%                 		reward_distances_opto_control_medium{i, last_col_reward_distances_opto_control_medium} = [reward_distances_opto_control_medium{i, last_col_reward_distances_opto_control_medium}; reward_distances_opto_control_medium{i, j};];
%                     else
% 						reward_distances_opto_control_medium{i, last_col_reward_distances_opto_control_medium} = [reward_distances_opto_control_medium{i, last_col_reward_distances_opto_control_medium}; reward_distances_opto_control_medium{i, j};];
%                     end

% 				data_sizes_reward_distances_opto_control_medium(i, 1) = size(reward_distances_opto_control_medium{i, last_col_reward_distances_opto_control_medium}, 1);

%                 end

%                 for j = 1:(last_col_reward_distances_opto_control_long - 1)
%                     if j == 1
% 						reward_distances_opto_control_long{i, last_col_reward_distances_opto_control_long} = [];
%                 		reward_distances_opto_control_long{i, last_col_reward_distances_opto_control_long} = [reward_distances_opto_control_long{i, last_col_reward_distances_opto_control_long}; reward_distances_opto_control_long{i, j};];
%                     else
% 						reward_distances_opto_control_long{i, last_col_reward_distances_opto_control_long} = [reward_distances_opto_control_long{i, last_col_reward_distances_opto_control_long}; reward_distances_opto_control_long{i, j};];
%                     end

% 				data_sizes_reward_distances_opto_control_long(i, 1) = size(reward_distances_opto_control_long{i, last_col_reward_distances_opto_control_long}, 1);

%                 end

%                 for j = 1:(last_col_reward_distances_opto_target - 1)
%                     if j == 1
% 						reward_distances_opto_target{i, last_col_reward_distances_opto_target} = [];
%                 		reward_distances_opto_target{i, last_col_reward_distances_opto_target} = [reward_distances_opto_target{i, last_col_reward_distances_opto_target}; reward_distances_opto_target{i, j};];
%                     else
% 						reward_distances_opto_target{i, last_col_reward_distances_opto_target} = [reward_distances_opto_target{i, last_col_reward_distances_opto_target}; reward_distances_opto_target{i, j};];
%                     end

% 				data_sizes_reward_distances_opto_target(i, 1) = size(reward_distances_opto_target{i, last_col_reward_distances_opto_target}, 1);

%                 end

%                 for j = 1:(last_col_reward_distances_opto_target_short - 1)
%                     if j == 1
% 						reward_distances_opto_target_short{i, last_col_reward_distances_opto_target_short} = [];
%                 		reward_distances_opto_target_short{i, last_col_reward_distances_opto_target_short} = [reward_distances_opto_target_short{i, last_col_reward_distances_opto_target_short}; reward_distances_opto_target_short{i, j};];
%                     else
% 						reward_distances_opto_target_short{i, last_col_reward_distances_opto_target_short} = [reward_distances_opto_target_short{i, last_col_reward_distances_opto_target_short}; reward_distances_opto_target_short{i, j};];
%                     end

% 				data_sizes_reward_distances_opto_target_short(i, 1) = size(reward_distances_opto_target_short{i, last_col_reward_distances_opto_target_short}, 1);

%                 end

%                 for j = 1:(last_col_reward_distances_opto_target_medium - 1)
%                     if j == 1
% 						reward_distances_opto_target_medium{i, last_col_reward_distances_opto_target_medium} = [];
%                 		reward_distances_opto_target_medium{i, last_col_reward_distances_opto_target_medium} = [reward_distances_opto_target_medium{i, last_col_reward_distances_opto_target_medium}; reward_distances_opto_target_medium{i, j};];
%                     else
% 						reward_distances_opto_target_medium{i, last_col_reward_distances_opto_target_medium} = [reward_distances_opto_target_medium{i, last_col_reward_distances_opto_target_medium}; reward_distances_opto_target_medium{i, j};];
%                     end

% 				data_sizes_reward_distances_opto_target_medium(i, 1) = size(reward_distances_opto_target_medium{i, last_col_reward_distances_opto_target_medium}, 1);

%                 end

%                 for j = 1:(last_col_reward_distances_opto_target_long - 1)
%                     if j == 1
% 						reward_distances_opto_target_long{i, last_col_reward_distances_opto_target_long} = [];
%                 		reward_distances_opto_target_long{i, last_col_reward_distances_opto_target_long} = [reward_distances_opto_target_long{i, last_col_reward_distances_opto_target_long}; reward_distances_opto_target_long{i, j};];
%                     else
% 						reward_distances_opto_target_long{i, last_col_reward_distances_opto_target_long} = [reward_distances_opto_target_long{i, last_col_reward_distances_opto_target_long}; reward_distances_opto_target_long{i, j};];
%                     end

% 				data_sizes_reward_distances_opto_target_long(i, 1) = size(reward_distances_opto_target_long{i, last_col_reward_distances_opto_target_long}, 1);

%                 end




%                 for j = 1:(last_col_overall_go_latency_opto_control_1 - 1)
%                     if j == 1
% 						overall_go_latency_opto_control_1{i, last_col_overall_go_latency_opto_control_1} = [];
%                 		overall_go_latency_opto_control_1{i, last_col_overall_go_latency_opto_control_1} = [overall_go_latency_opto_control_1{i, last_col_overall_go_latency_opto_control_1}; overall_go_latency_opto_control_1{i, j};];
%                     else
% 						overall_go_latency_opto_control_1{i, last_col_overall_go_latency_opto_control_1} = [overall_go_latency_opto_control_1{i, last_col_overall_go_latency_opto_control_1}; overall_go_latency_opto_control_1{i, j};];
%                     end

% 				data_sizes_overall_go_latency_opto_control_1(i, 1) = size(overall_go_latency_opto_control_1{i, last_col_overall_go_latency_opto_control_1}, 1);

%                 end

%                 for j = 1:(last_col_overall_go_latency_opto_target_1 - 1)
%                     if j == 1
% 						overall_go_latency_opto_target_1{i, last_col_overall_go_latency_opto_target_1} = [];
%                 		overall_go_latency_opto_target_1{i, last_col_overall_go_latency_opto_target_1} = [overall_go_latency_opto_target_1{i, last_col_overall_go_latency_opto_target_1}; overall_go_latency_opto_target_1{i, j};];
%                     else
% 						overall_go_latency_opto_target_1{i, last_col_overall_go_latency_opto_target_1} = [overall_go_latency_opto_target_1{i, last_col_overall_go_latency_opto_target_1}; overall_go_latency_opto_target_1{i, j};];
%                     end

% 				data_sizes_overall_go_latency_opto_target_1(i, 1) = size(overall_go_latency_opto_target_1{i, last_col_overall_go_latency_opto_target_1}, 1);

%                 end


%                 for j = 1:(last_col_short_go_latency_opto_control_1 - 1)
%                     if j == 1
% 						short_go_latency_opto_control_1{i, last_col_short_go_latency_opto_control_1} = [];
%                 		short_go_latency_opto_control_1{i, last_col_short_go_latency_opto_control_1} = [short_go_latency_opto_control_1{i, last_col_short_go_latency_opto_control_1}; short_go_latency_opto_control_1{i, j};];
%                     else
% 						short_go_latency_opto_control_1{i, last_col_short_go_latency_opto_control_1} = [short_go_latency_opto_control_1{i, last_col_short_go_latency_opto_control_1}; short_go_latency_opto_control_1{i, j};];
%                     end

% 				data_sizes_short_go_latency_opto_control_1(i, 1) = size(short_go_latency_opto_control_1{i, last_col_short_go_latency_opto_control_1}, 1);

%                 end

%                 for j = 1:(last_col_short_go_latency_opto_target_1 - 1)
%                     if j == 1
% 						short_go_latency_opto_target_1{i, last_col_short_go_latency_opto_target_1} = [];
%                 		short_go_latency_opto_target_1{i, last_col_short_go_latency_opto_target_1} = [short_go_latency_opto_target_1{i, last_col_short_go_latency_opto_target_1}; short_go_latency_opto_target_1{i, j};];
%                     else
% 						short_go_latency_opto_target_1{i, last_col_short_go_latency_opto_target_1} = [short_go_latency_opto_target_1{i, last_col_short_go_latency_opto_target_1}; short_go_latency_opto_target_1{i, j};];
%                     end

% 				data_sizes_short_go_latency_opto_target_1(i, 1) = size(short_go_latency_opto_target_1{i, last_col_short_go_latency_opto_target_1}, 1);

%                 end



%                 for j = 1:(last_col_medium_go_latency_opto_control_1 - 1)
%                     if j == 1
% 						medium_go_latency_opto_control_1{i, last_col_medium_go_latency_opto_control_1} = [];
%                 		medium_go_latency_opto_control_1{i, last_col_medium_go_latency_opto_control_1} = [medium_go_latency_opto_control_1{i, last_col_medium_go_latency_opto_control_1}; medium_go_latency_opto_control_1{i, j};];
%                     else
% 						medium_go_latency_opto_control_1{i, last_col_medium_go_latency_opto_control_1} = [medium_go_latency_opto_control_1{i, last_col_medium_go_latency_opto_control_1}; medium_go_latency_opto_control_1{i, j};];
%                     end

% 				data_sizes_medium_go_latency_opto_control_1(i, 1) = size(medium_go_latency_opto_control_1{i, last_col_medium_go_latency_opto_control_1}, 1);

%                 end

%                 for j = 1:(last_col_medium_go_latency_opto_target_1 - 1)
%                     if j == 1
% 						medium_go_latency_opto_target_1{i, last_col_medium_go_latency_opto_target_1} = [];
%                 		medium_go_latency_opto_target_1{i, last_col_medium_go_latency_opto_target_1} = [medium_go_latency_opto_target_1{i, last_col_medium_go_latency_opto_target_1}; medium_go_latency_opto_target_1{i, j};];
%                     else
% 						medium_go_latency_opto_target_1{i, last_col_medium_go_latency_opto_target_1} = [medium_go_latency_opto_target_1{i, last_col_medium_go_latency_opto_target_1}; medium_go_latency_opto_target_1{i, j};];
%                     end

% 				data_sizes_medium_go_latency_opto_target_1(i, 1) = size(medium_go_latency_opto_target_1{i, last_col_medium_go_latency_opto_target_1}, 1);

%                 end                
    


%                 for j = 1:(last_col_long_go_latency_opto_control_1 - 1)
%                     if j == 1
% 						long_go_latency_opto_control_1{i, last_col_long_go_latency_opto_control_1} = [];
%                 		long_go_latency_opto_control_1{i, last_col_long_go_latency_opto_control_1} = [long_go_latency_opto_control_1{i, last_col_long_go_latency_opto_control_1}; long_go_latency_opto_control_1{i, j};];
%                     else
% 						long_go_latency_opto_control_1{i, last_col_long_go_latency_opto_control_1} = [long_go_latency_opto_control_1{i, last_col_long_go_latency_opto_control_1}; long_go_latency_opto_control_1{i, j};];
%                     end

% 				data_sizes_long_go_latency_opto_control_1(i, 1) = size(long_go_latency_opto_control_1{i, last_col_long_go_latency_opto_control_1}, 1);

%                 end

%                 for j = 1:(last_col_long_go_latency_opto_target_1 - 1)
%                     if j == 1
% 						long_go_latency_opto_target_1{i, last_col_long_go_latency_opto_target_1} = [];
%                 		long_go_latency_opto_target_1{i, last_col_long_go_latency_opto_target_1} = [long_go_latency_opto_target_1{i, last_col_long_go_latency_opto_target_1}; long_go_latency_opto_target_1{i, j};];
%                     else
% 						long_go_latency_opto_target_1{i, last_col_long_go_latency_opto_target_1} = [long_go_latency_opto_target_1{i, last_col_long_go_latency_opto_target_1}; long_go_latency_opto_target_1{i, j};];
%                     end

% 				data_sizes_long_go_latency_opto_target_1(i, 1) = size(long_go_latency_opto_target_1{i, last_col_long_go_latency_opto_target_1}, 1);

%                 end







%                 for j = 1:(last_col_overall_early_restart_distances_opto_control_1 - 1)
%                     if j == 1
% 						overall_early_restart_distances_opto_control_1{i, last_col_overall_early_restart_distances_opto_control_1} = [];
%                 		overall_early_restart_distances_opto_control_1{i, last_col_overall_early_restart_distances_opto_control_1} = [overall_early_restart_distances_opto_control_1{i, last_col_overall_early_restart_distances_opto_control_1}; overall_early_restart_distances_opto_control_1{i, j};];
%                     else
% 						overall_early_restart_distances_opto_control_1{i, last_col_overall_early_restart_distances_opto_control_1} = [overall_early_restart_distances_opto_control_1{i, last_col_overall_early_restart_distances_opto_control_1}; overall_early_restart_distances_opto_control_1{i, j};];
%                     end

% 				data_sizes_overall_early_restart_distances_opto_control_1(i, 1) = size(overall_early_restart_distances_opto_control_1{i, last_col_overall_early_restart_distances_opto_control_1}, 1);

%                 end

%                 for j = 1:(last_col_overall_early_restart_distances_opto_target_1 - 1)
%                     if j == 1
% 						overall_early_restart_distances_opto_target_1{i, last_col_overall_early_restart_distances_opto_target_1} = [];
%                 		overall_early_restart_distances_opto_target_1{i, last_col_overall_early_restart_distances_opto_target_1} = [overall_early_restart_distances_opto_target_1{i, last_col_overall_early_restart_distances_opto_target_1}; overall_early_restart_distances_opto_target_1{i, j};];
%                     else
% 						overall_early_restart_distances_opto_target_1{i, last_col_overall_early_restart_distances_opto_target_1} = [overall_early_restart_distances_opto_target_1{i, last_col_overall_early_restart_distances_opto_target_1}; overall_early_restart_distances_opto_target_1{i, j};];
%                     end

% 				data_sizes_overall_early_restart_distances_opto_target_1(i, 1) = size(overall_early_restart_distances_opto_target_1{i, last_col_overall_early_restart_distances_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_short_early_restart_distances_opto_control_1 - 1)
%                     if j == 1
% 						short_early_restart_distances_opto_control_1{i, last_col_short_early_restart_distances_opto_control_1} = [];
%                 		short_early_restart_distances_opto_control_1{i, last_col_short_early_restart_distances_opto_control_1} = [short_early_restart_distances_opto_control_1{i, last_col_short_early_restart_distances_opto_control_1}; short_early_restart_distances_opto_control_1{i, j};];
%                     else
% 						short_early_restart_distances_opto_control_1{i, last_col_short_early_restart_distances_opto_control_1} = [short_early_restart_distances_opto_control_1{i, last_col_short_early_restart_distances_opto_control_1}; short_early_restart_distances_opto_control_1{i, j};];
%                     end

% 				data_sizes_short_early_restart_distances_opto_control_1(i, 1) = size(short_early_restart_distances_opto_control_1{i, last_col_short_early_restart_distances_opto_control_1}, 1);

%                 end

%                 for j = 1:(last_col_short_early_restart_distances_opto_target_1 - 1)
%                     if j == 1
% 						short_early_restart_distances_opto_target_1{i, last_col_short_early_restart_distances_opto_target_1} = [];
%                 		short_early_restart_distances_opto_target_1{i, last_col_short_early_restart_distances_opto_target_1} = [short_early_restart_distances_opto_target_1{i, last_col_short_early_restart_distances_opto_target_1}; short_early_restart_distances_opto_target_1{i, j};];
%                     else
% 						short_early_restart_distances_opto_target_1{i, last_col_short_early_restart_distances_opto_target_1} = [short_early_restart_distances_opto_target_1{i, last_col_short_early_restart_distances_opto_target_1}; short_early_restart_distances_opto_target_1{i, j};];
%                     end

% 				data_sizes_short_early_restart_distances_opto_target_1(i, 1) = size(short_early_restart_distances_opto_target_1{i, last_col_short_early_restart_distances_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_medium_early_restart_distances_opto_control_1 - 1)
%                     if j == 1
% 						medium_early_restart_distances_opto_control_1{i, last_col_medium_early_restart_distances_opto_control_1} = [];
%                 		medium_early_restart_distances_opto_control_1{i, last_col_medium_early_restart_distances_opto_control_1} = [medium_early_restart_distances_opto_control_1{i, last_col_medium_early_restart_distances_opto_control_1}; medium_early_restart_distances_opto_control_1{i, j};];
%                     else
% 						medium_early_restart_distances_opto_control_1{i, last_col_medium_early_restart_distances_opto_control_1} = [medium_early_restart_distances_opto_control_1{i, last_col_medium_early_restart_distances_opto_control_1}; medium_early_restart_distances_opto_control_1{i, j};];
%                     end

% 				data_sizes_medium_early_restart_distances_opto_control_1(i, 1) = size(medium_early_restart_distances_opto_control_1{i, last_col_medium_early_restart_distances_opto_control_1}, 1);

%                 end

%                 for j = 1:(last_col_medium_early_restart_distances_opto_target_1 - 1)
%                     if j == 1
% 						medium_early_restart_distances_opto_target_1{i, last_col_medium_early_restart_distances_opto_target_1} = [];
%                 		medium_early_restart_distances_opto_target_1{i, last_col_medium_early_restart_distances_opto_target_1} = [medium_early_restart_distances_opto_target_1{i, last_col_medium_early_restart_distances_opto_target_1}; medium_early_restart_distances_opto_target_1{i, j};];
%                     else
% 						medium_early_restart_distances_opto_target_1{i, last_col_medium_early_restart_distances_opto_target_1} = [medium_early_restart_distances_opto_target_1{i, last_col_medium_early_restart_distances_opto_target_1}; medium_early_restart_distances_opto_target_1{i, j};];
%                     end

% 				data_sizes_medium_early_restart_distances_opto_target_1(i, 1) = size(medium_early_restart_distances_opto_target_1{i, last_col_medium_early_restart_distances_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_long_early_restart_distances_opto_control_1 - 1)
%                     if j == 1
% 						long_early_restart_distances_opto_control_1{i, last_col_long_early_restart_distances_opto_control_1} = [];
%                 		long_early_restart_distances_opto_control_1{i, last_col_long_early_restart_distances_opto_control_1} = [long_early_restart_distances_opto_control_1{i, last_col_long_early_restart_distances_opto_control_1}; long_early_restart_distances_opto_control_1{i, j};];
%                     else
% 						long_early_restart_distances_opto_control_1{i, last_col_long_early_restart_distances_opto_control_1} = [long_early_restart_distances_opto_control_1{i, last_col_long_early_restart_distances_opto_control_1}; long_early_restart_distances_opto_control_1{i, j};];
%                     end

% 				data_sizes_long_early_restart_distances_opto_control_1(i, 1) = size(long_early_restart_distances_opto_control_1{i, last_col_long_early_restart_distances_opto_control_1}, 1);

%                 end

%                 for j = 1:(last_col_long_early_restart_distances_opto_target_1 - 1)
%                     if j == 1
% 						long_early_restart_distances_opto_target_1{i, last_col_long_early_restart_distances_opto_target_1} = [];
%                 		long_early_restart_distances_opto_target_1{i, last_col_long_early_restart_distances_opto_target_1} = [long_early_restart_distances_opto_target_1{i, last_col_long_early_restart_distances_opto_target_1}; long_early_restart_distances_opto_target_1{i, j};];
%                     else
% 						long_early_restart_distances_opto_target_1{i, last_col_long_early_restart_distances_opto_target_1} = [long_early_restart_distances_opto_target_1{i, last_col_long_early_restart_distances_opto_target_1}; long_early_restart_distances_opto_target_1{i, j};];
%                     end

% 				data_sizes_long_early_restart_distances_opto_target_1(i, 1) = size(long_early_restart_distances_opto_target_1{i, last_col_long_early_restart_distances_opto_target_1}, 1);

%                 end








% % 
% %                 for j = 1:(last_col_optocont_short_repeat_blocks - 1)
% %                     if j == 1
% % 						optocont_short_repeat_blocks{i, last_col_optocont_short_repeat_blocks} = [];
% %                 		optocont_short_repeat_blocks{i, last_col_optocont_short_repeat_blocks} = [optocont_short_repeat_blocks{i, last_col_optocont_short_repeat_blocks}; optocont_short_repeat_blocks{i, j};];
% %                     else
% % 						optocont_short_repeat_blocks{i, last_col_optocont_short_repeat_blocks} = [optocont_short_repeat_blocks{i, last_col_optocont_short_repeat_blocks}; optocont_short_repeat_blocks{i, j};];
% %                     end
% % 
% % 				data_sizes_optocont_short_repeat_blocks(i, 1) = size(optocont_short_repeat_blocks{i, last_col_optocont_short_repeat_blocks}, 1);
% % 
% %                 end
% % 
% %                 for j = 1:(last_col_optotarg_short_repeat_blocks - 1)
% %                     if j == 1
% % 						optotarg_short_repeat_blocks{i, last_col_optotarg_short_repeat_blocks} = [];
% %                 		optotarg_short_repeat_blocks{i, last_col_optotarg_short_repeat_blocks} = [optotarg_short_repeat_blocks{i, last_col_optotarg_short_repeat_blocks}; optotarg_short_repeat_blocks{i, j};];
% %                     else
% % 						optotarg_short_repeat_blocks{i, last_col_optotarg_short_repeat_blocks} = [optotarg_short_repeat_blocks{i, last_col_optotarg_short_repeat_blocks}; optotarg_short_repeat_blocks{i, j};];
% %                     end
% % 
% % 				data_sizes_optotarg_short_repeat_blocks(i, 1) = size(optotarg_short_repeat_blocks{i, last_col_optotarg_short_repeat_blocks}, 1);
% % 
% %                 end
% % 
% %                 for j = 1:(last_col_optocont_medium_repeat_blocks - 1)
% %                     if j == 1
% % 						optocont_medium_repeat_blocks{i, last_col_optocont_medium_repeat_blocks} = [];
% %                 		optocont_medium_repeat_blocks{i, last_col_optocont_medium_repeat_blocks} = [optocont_medium_repeat_blocks{i, last_col_optocont_medium_repeat_blocks}; optocont_medium_repeat_blocks{i, j};];
% %                     else
% % 						optocont_medium_repeat_blocks{i, last_col_optocont_medium_repeat_blocks} = [optocont_medium_repeat_blocks{i, last_col_optocont_medium_repeat_blocks}; optocont_medium_repeat_blocks{i, j};];
% %                     end
% % 
% % 				data_sizes_optocont_medium_repeat_blocks(i, 1) = size(optocont_medium_repeat_blocks{i, last_col_optocont_medium_repeat_blocks}, 1);
% % 
% %                 end
% % 
% %                 for j = 1:(last_col_optotarg_medium_repeat_blocks - 1)
% %                     if j == 1
% % 						optotarg_medium_repeat_blocks{i, last_col_optotarg_medium_repeat_blocks} = [];
% %                 		optotarg_medium_repeat_blocks{i, last_col_optotarg_medium_repeat_blocks} = [optotarg_medium_repeat_blocks{i, last_col_optotarg_medium_repeat_blocks}; optotarg_medium_repeat_blocks{i, j};];
% %                     else
% % 						optotarg_medium_repeat_blocks{i, last_col_optotarg_medium_repeat_blocks} = [optotarg_medium_repeat_blocks{i, last_col_optotarg_medium_repeat_blocks}; optotarg_medium_repeat_blocks{i, j};];
% %                     end
% % 
% % 				data_sizes_optotarg_medium_repeat_blocks(i, 1) = size(optotarg_medium_repeat_blocks{i, last_col_optotarg_medium_repeat_blocks}, 1);
% % 
% %                 end
% % 
% %                 for j = 1:(last_col_optocont_long_repeat_blocks - 1)
% %                     if j == 1
% % 						optocont_long_repeat_blocks{i, last_col_optocont_long_repeat_blocks} = [];
% %                 		optocont_long_repeat_blocks{i, last_col_optocont_long_repeat_blocks} = [optocont_long_repeat_blocks{i, last_col_optocont_long_repeat_blocks}; optocont_long_repeat_blocks{i, j};];
% %                     else
% % 						optocont_long_repeat_blocks{i, last_col_optocont_long_repeat_blocks} = [optocont_long_repeat_blocks{i, last_col_optocont_long_repeat_blocks}; optocont_long_repeat_blocks{i, j};];
% %                     end
% % 
% % 				data_sizes_optocont_long_repeat_blocks(i, 1) = size(optocont_long_repeat_blocks{i, last_col_optocont_long_repeat_blocks}, 1);
% % 
% %                 end
% % 
% %                 for j = 1:(last_col_optotarg_long_repeat_blocks - 1)
% %                     if j == 1
% % 						optotarg_long_repeat_blocks{i, last_col_optotarg_long_repeat_blocks} = [];
% %                 		optotarg_long_repeat_blocks{i, last_col_optotarg_long_repeat_blocks} = [optotarg_long_repeat_blocks{i, last_col_optotarg_long_repeat_blocks}; optotarg_long_repeat_blocks{i, j};];
% %                     else
% % 						optotarg_long_repeat_blocks{i, last_col_optotarg_long_repeat_blocks} = [optotarg_long_repeat_blocks{i, last_col_optotarg_long_repeat_blocks}; optotarg_long_repeat_blocks{i, j};];
% %                     end
% % 
% % 				data_sizes_optotarg_long_repeat_blocks(i, 1) = size(optotarg_long_repeat_blocks{i, last_col_optotarg_long_repeat_blocks}, 1);
% % 
% %                 end


%                 % for j = 1:(last_col_precue_data_rawvel_opto_control - 1)
%                 %     if j == 1
% 				% 		precue_data_rawvel_opto_control{i, last_col_precue_data_rawvel_opto_control} = [];
%                 % 		precue_data_rawvel_opto_control{i, last_col_precue_data_rawvel_opto_control} = [precue_data_rawvel_opto_control{i, last_col_precue_data_rawvel_opto_control}; precue_data_rawvel_opto_control{i, j};];
%                 %     else
% 				% 		precue_data_rawvel_opto_control{i, last_col_precue_data_rawvel_opto_control} = [precue_data_rawvel_opto_control{i, last_col_precue_data_rawvel_opto_control}; precue_data_rawvel_opto_control{i, j};];
%                 %     end

% 				% data_sizes_precue_data_rawvel_opto_control(i, 1) = size(precue_data_rawvel_opto_control{i, last_col_precue_data_rawvel_opto_control}, 1);

%                 % end

%                 % for j = 1:(last_col_precue_data_rawvel_short_opto_control - 1)
%                 %     if j == 1
% 				% 		precue_data_rawvel_short_opto_control{i, last_col_precue_data_rawvel_short_opto_control} = [];
%                 % 		precue_data_rawvel_short_opto_control{i, last_col_precue_data_rawvel_short_opto_control} = [precue_data_rawvel_short_opto_control{i, last_col_precue_data_rawvel_short_opto_control}; precue_data_rawvel_short_opto_control{i, j};];
%                 %     else
% 				% 		precue_data_rawvel_short_opto_control{i, last_col_precue_data_rawvel_short_opto_control} = [precue_data_rawvel_short_opto_control{i, last_col_precue_data_rawvel_short_opto_control}; precue_data_rawvel_short_opto_control{i, j};];
%                 %     end

% 				% data_sizes_precue_data_rawvel_short_opto_control(i, 1) = size(precue_data_rawvel_short_opto_control{i, last_col_precue_data_rawvel_short_opto_control}, 1);

%                 % end


%                 % for j = 1:(last_col_precue_data_rawvel_medium_opto_control - 1)
%                 %     if j == 1
% 				% 		precue_data_rawvel_medium_opto_control{i, last_col_precue_data_rawvel_medium_opto_control} = [];
%                 % 		precue_data_rawvel_medium_opto_control{i, last_col_precue_data_rawvel_medium_opto_control} = [precue_data_rawvel_medium_opto_control{i, last_col_precue_data_rawvel_medium_opto_control}; precue_data_rawvel_medium_opto_control{i, j};];
%                 %     else
% 				% 		precue_data_rawvel_medium_opto_control{i, last_col_precue_data_rawvel_medium_opto_control} = [precue_data_rawvel_medium_opto_control{i, last_col_precue_data_rawvel_medium_opto_control}; precue_data_rawvel_medium_opto_control{i, j};];
%                 %     end

% 				% data_sizes_precue_data_rawvel_medium_opto_control(i, 1) = size(precue_data_rawvel_medium_opto_control{i, last_col_precue_data_rawvel_medium_opto_control}, 1);

%                 % end



%                 % for j = 1:(last_col_precue_data_rawvel_long_opto_control - 1)
%                 %     if j == 1
% 				% 		precue_data_rawvel_long_opto_control{i, last_col_precue_data_rawvel_long_opto_control} = [];
%                 % 		precue_data_rawvel_long_opto_control{i, last_col_precue_data_rawvel_long_opto_control} = [precue_data_rawvel_long_opto_control{i, last_col_precue_data_rawvel_long_opto_control}; precue_data_rawvel_long_opto_control{i, j};];
%                 %     else
% 				% 		precue_data_rawvel_long_opto_control{i, last_col_precue_data_rawvel_long_opto_control} = [precue_data_rawvel_long_opto_control{i, last_col_precue_data_rawvel_long_opto_control}; precue_data_rawvel_long_opto_control{i, j};];
%                 %     end

% 				% data_sizes_precue_data_rawvel_long_opto_control(i, 1) = size(precue_data_rawvel_long_opto_control{i, last_col_precue_data_rawvel_long_opto_control}, 1);

%                 % end



%                 % for j = 1:(last_col_precue_data_rawvel_opto_target_1 - 1)
%                 %     if j == 1
% 				% 		precue_data_rawvel_opto_target_1{i, last_col_precue_data_rawvel_opto_target_1} = [];
%                 % 		precue_data_rawvel_opto_target_1{i, last_col_precue_data_rawvel_opto_target_1} = [precue_data_rawvel_opto_target_1{i, last_col_precue_data_rawvel_opto_target_1}; precue_data_rawvel_opto_target_1{i, j};];
%                 %     else
% 				% 		precue_data_rawvel_opto_target_1{i, last_col_precue_data_rawvel_opto_target_1} = [precue_data_rawvel_opto_target_1{i, last_col_precue_data_rawvel_opto_target_1}; precue_data_rawvel_opto_target_1{i, j};];
%                 %     end

% 				% data_sizes_precue_data_rawvel_opto_target_1(i, 1) = size(precue_data_rawvel_opto_target_1{i, last_col_precue_data_rawvel_opto_target_1}, 1);

%                 % end

%                 % for j = 1:(last_col_precue_data_rawvel_short_opto_target_1 - 1)
%                 %     if j == 1
% 				% 		precue_data_rawvel_short_opto_target_1{i, last_col_precue_data_rawvel_short_opto_target_1} = [];
%                 % 		precue_data_rawvel_short_opto_target_1{i, last_col_precue_data_rawvel_short_opto_target_1} = [precue_data_rawvel_short_opto_target_1{i, last_col_precue_data_rawvel_short_opto_target_1}; precue_data_rawvel_short_opto_target_1{i, j};];
%                 %     else
% 				% 		precue_data_rawvel_short_opto_target_1{i, last_col_precue_data_rawvel_short_opto_target_1} = [precue_data_rawvel_short_opto_target_1{i, last_col_precue_data_rawvel_short_opto_target_1}; precue_data_rawvel_short_opto_target_1{i, j};];
%                 %     end

% 				% data_sizes_precue_data_rawvel_short_opto_target_1(i, 1) = size(precue_data_rawvel_short_opto_target_1{i, last_col_precue_data_rawvel_short_opto_target_1}, 1);

%                 % end


%                 % for j = 1:(last_col_precue_data_rawvel_medium_opto_target_1 - 1)
%                 %     if j == 1
% 				% 		precue_data_rawvel_medium_opto_target_1{i, last_col_precue_data_rawvel_medium_opto_target_1} = [];
%                 % 		precue_data_rawvel_medium_opto_target_1{i, last_col_precue_data_rawvel_medium_opto_target_1} = [precue_data_rawvel_medium_opto_target_1{i, last_col_precue_data_rawvel_medium_opto_target_1}; precue_data_rawvel_medium_opto_target_1{i, j};];
%                 %     else
% 				% 		precue_data_rawvel_medium_opto_target_1{i, last_col_precue_data_rawvel_medium_opto_target_1} = [precue_data_rawvel_medium_opto_target_1{i, last_col_precue_data_rawvel_medium_opto_target_1}; precue_data_rawvel_medium_opto_target_1{i, j};];
%                 %     end

% 				% data_sizes_precue_data_rawvel_medium_opto_target_1(i, 1) = size(precue_data_rawvel_medium_opto_target_1{i, last_col_precue_data_rawvel_medium_opto_target_1}, 1);

%                 % end



%                 % for j = 1:(last_col_precue_data_rawvel_long_opto_target_1 - 1)
%                 %     if j == 1
% 				% 		precue_data_rawvel_long_opto_target_1{i, last_col_precue_data_rawvel_long_opto_target_1} = [];
%                 % 		precue_data_rawvel_long_opto_target_1{i, last_col_precue_data_rawvel_long_opto_target_1} = [precue_data_rawvel_long_opto_target_1{i, last_col_precue_data_rawvel_long_opto_target_1}; precue_data_rawvel_long_opto_target_1{i, j};];
%                 %     else
% 				% 		precue_data_rawvel_long_opto_target_1{i, last_col_precue_data_rawvel_long_opto_target_1} = [precue_data_rawvel_long_opto_target_1{i, last_col_precue_data_rawvel_long_opto_target_1}; precue_data_rawvel_long_opto_target_1{i, j};];
%                 %     end

% 				% data_sizes_precue_data_rawvel_long_opto_target_1(i, 1) = size(precue_data_rawvel_long_opto_target_1{i, last_col_precue_data_rawvel_long_opto_target_1}, 1);

%                 % end









%                 for j = 1:(last_col_raw_vel_trace_all_short_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_all_short_opto_control{i, last_col_raw_vel_trace_all_short_opto_control} = [];
%                 		raw_vel_trace_all_short_opto_control{i, last_col_raw_vel_trace_all_short_opto_control} = [raw_vel_trace_all_short_opto_control{i, last_col_raw_vel_trace_all_short_opto_control}; raw_vel_trace_all_short_opto_control{i, j};];
%                     else
% 						raw_vel_trace_all_short_opto_control{i, last_col_raw_vel_trace_all_short_opto_control} = [raw_vel_trace_all_short_opto_control{i, last_col_raw_vel_trace_all_short_opto_control}; raw_vel_trace_all_short_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_all_short_opto_control(i, 1) = size(raw_vel_trace_all_short_opto_control{i, last_col_raw_vel_trace_all_short_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_all_short_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_all_short_opto_target_1{i, last_col_raw_vel_trace_all_short_opto_target_1} = [];
%                 		raw_vel_trace_all_short_opto_target_1{i, last_col_raw_vel_trace_all_short_opto_target_1} = [raw_vel_trace_all_short_opto_target_1{i, last_col_raw_vel_trace_all_short_opto_target_1}; raw_vel_trace_all_short_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_all_short_opto_target_1{i, last_col_raw_vel_trace_all_short_opto_target_1} = [raw_vel_trace_all_short_opto_target_1{i, last_col_raw_vel_trace_all_short_opto_target_1}; raw_vel_trace_all_short_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_all_short_opto_target_1(i, 1) = size(raw_vel_trace_all_short_opto_target_1{i, last_col_raw_vel_trace_all_short_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_all_medium_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_all_medium_opto_control{i, last_col_raw_vel_trace_all_medium_opto_control} = [];
%                 		raw_vel_trace_all_medium_opto_control{i, last_col_raw_vel_trace_all_medium_opto_control} = [raw_vel_trace_all_medium_opto_control{i, last_col_raw_vel_trace_all_medium_opto_control}; raw_vel_trace_all_medium_opto_control{i, j};];
%                     else
% 						raw_vel_trace_all_medium_opto_control{i, last_col_raw_vel_trace_all_medium_opto_control} = [raw_vel_trace_all_medium_opto_control{i, last_col_raw_vel_trace_all_medium_opto_control}; raw_vel_trace_all_medium_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_all_medium_opto_control(i, 1) = size(raw_vel_trace_all_medium_opto_control{i, last_col_raw_vel_trace_all_medium_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_all_medium_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_all_medium_opto_target_1{i, last_col_raw_vel_trace_all_medium_opto_target_1} = [];
%                 		raw_vel_trace_all_medium_opto_target_1{i, last_col_raw_vel_trace_all_medium_opto_target_1} = [raw_vel_trace_all_medium_opto_target_1{i, last_col_raw_vel_trace_all_medium_opto_target_1}; raw_vel_trace_all_medium_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_all_medium_opto_target_1{i, last_col_raw_vel_trace_all_medium_opto_target_1} = [raw_vel_trace_all_medium_opto_target_1{i, last_col_raw_vel_trace_all_medium_opto_target_1}; raw_vel_trace_all_medium_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_all_medium_opto_target_1(i, 1) = size(raw_vel_trace_all_medium_opto_target_1{i, last_col_raw_vel_trace_all_medium_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_all_long_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_all_long_opto_control{i, last_col_raw_vel_trace_all_long_opto_control} = [];
%                 		raw_vel_trace_all_long_opto_control{i, last_col_raw_vel_trace_all_long_opto_control} = [raw_vel_trace_all_long_opto_control{i, last_col_raw_vel_trace_all_long_opto_control}; raw_vel_trace_all_long_opto_control{i, j};];
%                     else
% 						raw_vel_trace_all_long_opto_control{i, last_col_raw_vel_trace_all_long_opto_control} = [raw_vel_trace_all_long_opto_control{i, last_col_raw_vel_trace_all_long_opto_control}; raw_vel_trace_all_long_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_all_long_opto_control(i, 1) = size(raw_vel_trace_all_long_opto_control{i, last_col_raw_vel_trace_all_long_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_all_long_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_all_long_opto_target_1{i, last_col_raw_vel_trace_all_long_opto_target_1} = [];
%                 		raw_vel_trace_all_long_opto_target_1{i, last_col_raw_vel_trace_all_long_opto_target_1} = [raw_vel_trace_all_long_opto_target_1{i, last_col_raw_vel_trace_all_long_opto_target_1}; raw_vel_trace_all_long_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_all_long_opto_target_1{i, last_col_raw_vel_trace_all_long_opto_target_1} = [raw_vel_trace_all_long_opto_target_1{i, last_col_raw_vel_trace_all_long_opto_target_1}; raw_vel_trace_all_long_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_all_long_opto_target_1(i, 1) = size(raw_vel_trace_all_long_opto_target_1{i, last_col_raw_vel_trace_all_long_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_all_short_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_all_short_opto_control{i, last_col_smooth_vel_trace_all_short_opto_control} = [];
%                 		smooth_vel_trace_all_short_opto_control{i, last_col_smooth_vel_trace_all_short_opto_control} = [smooth_vel_trace_all_short_opto_control{i, last_col_smooth_vel_trace_all_short_opto_control}; smooth_vel_trace_all_short_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_all_short_opto_control{i, last_col_smooth_vel_trace_all_short_opto_control} = [smooth_vel_trace_all_short_opto_control{i, last_col_smooth_vel_trace_all_short_opto_control}; smooth_vel_trace_all_short_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_all_short_opto_control(i, 1) = size(smooth_vel_trace_all_short_opto_control{i, last_col_smooth_vel_trace_all_short_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_all_short_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_all_short_opto_target_1{i, last_col_smooth_vel_trace_all_short_opto_target_1} = [];
%                 		smooth_vel_trace_all_short_opto_target_1{i, last_col_smooth_vel_trace_all_short_opto_target_1} = [smooth_vel_trace_all_short_opto_target_1{i, last_col_smooth_vel_trace_all_short_opto_target_1}; smooth_vel_trace_all_short_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_all_short_opto_target_1{i, last_col_smooth_vel_trace_all_short_opto_target_1} = [smooth_vel_trace_all_short_opto_target_1{i, last_col_smooth_vel_trace_all_short_opto_target_1}; smooth_vel_trace_all_short_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_all_short_opto_target_1(i, 1) = size(smooth_vel_trace_all_short_opto_target_1{i, last_col_smooth_vel_trace_all_short_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_all_medium_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_all_medium_opto_control{i, last_col_smooth_vel_trace_all_medium_opto_control} = [];
%                 		smooth_vel_trace_all_medium_opto_control{i, last_col_smooth_vel_trace_all_medium_opto_control} = [smooth_vel_trace_all_medium_opto_control{i, last_col_smooth_vel_trace_all_medium_opto_control}; smooth_vel_trace_all_medium_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_all_medium_opto_control{i, last_col_smooth_vel_trace_all_medium_opto_control} = [smooth_vel_trace_all_medium_opto_control{i, last_col_smooth_vel_trace_all_medium_opto_control}; smooth_vel_trace_all_medium_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_all_medium_opto_control(i, 1) = size(smooth_vel_trace_all_medium_opto_control{i, last_col_smooth_vel_trace_all_medium_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_all_medium_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_all_medium_opto_target_1{i, last_col_smooth_vel_trace_all_medium_opto_target_1} = [];
%                 		smooth_vel_trace_all_medium_opto_target_1{i, last_col_smooth_vel_trace_all_medium_opto_target_1} = [smooth_vel_trace_all_medium_opto_target_1{i, last_col_smooth_vel_trace_all_medium_opto_target_1}; smooth_vel_trace_all_medium_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_all_medium_opto_target_1{i, last_col_smooth_vel_trace_all_medium_opto_target_1} = [smooth_vel_trace_all_medium_opto_target_1{i, last_col_smooth_vel_trace_all_medium_opto_target_1}; smooth_vel_trace_all_medium_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_all_medium_opto_target_1(i, 1) = size(smooth_vel_trace_all_medium_opto_target_1{i, last_col_smooth_vel_trace_all_medium_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_all_long_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_all_long_opto_control{i, last_col_smooth_vel_trace_all_long_opto_control} = [];
%                 		smooth_vel_trace_all_long_opto_control{i, last_col_smooth_vel_trace_all_long_opto_control} = [smooth_vel_trace_all_long_opto_control{i, last_col_smooth_vel_trace_all_long_opto_control}; smooth_vel_trace_all_long_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_all_long_opto_control{i, last_col_smooth_vel_trace_all_long_opto_control} = [smooth_vel_trace_all_long_opto_control{i, last_col_smooth_vel_trace_all_long_opto_control}; smooth_vel_trace_all_long_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_all_long_opto_control(i, 1) = size(smooth_vel_trace_all_long_opto_control{i, last_col_smooth_vel_trace_all_long_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_all_long_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_all_long_opto_target_1{i, last_col_smooth_vel_trace_all_long_opto_target_1} = [];
%                 		smooth_vel_trace_all_long_opto_target_1{i, last_col_smooth_vel_trace_all_long_opto_target_1} = [smooth_vel_trace_all_long_opto_target_1{i, last_col_smooth_vel_trace_all_long_opto_target_1}; smooth_vel_trace_all_long_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_all_long_opto_target_1{i, last_col_smooth_vel_trace_all_long_opto_target_1} = [smooth_vel_trace_all_long_opto_target_1{i, last_col_smooth_vel_trace_all_long_opto_target_1}; smooth_vel_trace_all_long_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_all_long_opto_target_1(i, 1) = size(smooth_vel_trace_all_long_opto_target_1{i, last_col_smooth_vel_trace_all_long_opto_target_1}, 1);

%                 end










%                 for j = 1:(last_col_raw_vel_trace_RW_short_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_RW_short_opto_control{i, last_col_raw_vel_trace_RW_short_opto_control} = [];
%                 		raw_vel_trace_RW_short_opto_control{i, last_col_raw_vel_trace_RW_short_opto_control} = [raw_vel_trace_RW_short_opto_control{i, last_col_raw_vel_trace_RW_short_opto_control}; raw_vel_trace_RW_short_opto_control{i, j};];
%                     else
% 						raw_vel_trace_RW_short_opto_control{i, last_col_raw_vel_trace_RW_short_opto_control} = [raw_vel_trace_RW_short_opto_control{i, last_col_raw_vel_trace_RW_short_opto_control}; raw_vel_trace_RW_short_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_RW_short_opto_control(i, 1) = size(raw_vel_trace_RW_short_opto_control{i, last_col_raw_vel_trace_RW_short_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_RW_short_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_RW_short_opto_target_1{i, last_col_raw_vel_trace_RW_short_opto_target_1} = [];
%                 		raw_vel_trace_RW_short_opto_target_1{i, last_col_raw_vel_trace_RW_short_opto_target_1} = [raw_vel_trace_RW_short_opto_target_1{i, last_col_raw_vel_trace_RW_short_opto_target_1}; raw_vel_trace_RW_short_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_RW_short_opto_target_1{i, last_col_raw_vel_trace_RW_short_opto_target_1} = [raw_vel_trace_RW_short_opto_target_1{i, last_col_raw_vel_trace_RW_short_opto_target_1}; raw_vel_trace_RW_short_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_RW_short_opto_target_1(i, 1) = size(raw_vel_trace_RW_short_opto_target_1{i, last_col_raw_vel_trace_RW_short_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_RW_medium_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_RW_medium_opto_control{i, last_col_raw_vel_trace_RW_medium_opto_control} = [];
%                 		raw_vel_trace_RW_medium_opto_control{i, last_col_raw_vel_trace_RW_medium_opto_control} = [raw_vel_trace_RW_medium_opto_control{i, last_col_raw_vel_trace_RW_medium_opto_control}; raw_vel_trace_RW_medium_opto_control{i, j};];
%                     else
% 						raw_vel_trace_RW_medium_opto_control{i, last_col_raw_vel_trace_RW_medium_opto_control} = [raw_vel_trace_RW_medium_opto_control{i, last_col_raw_vel_trace_RW_medium_opto_control}; raw_vel_trace_RW_medium_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_RW_medium_opto_control(i, 1) = size(raw_vel_trace_RW_medium_opto_control{i, last_col_raw_vel_trace_RW_medium_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_RW_medium_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_RW_medium_opto_target_1{i, last_col_raw_vel_trace_RW_medium_opto_target_1} = [];
%                 		raw_vel_trace_RW_medium_opto_target_1{i, last_col_raw_vel_trace_RW_medium_opto_target_1} = [raw_vel_trace_RW_medium_opto_target_1{i, last_col_raw_vel_trace_RW_medium_opto_target_1}; raw_vel_trace_RW_medium_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_RW_medium_opto_target_1{i, last_col_raw_vel_trace_RW_medium_opto_target_1} = [raw_vel_trace_RW_medium_opto_target_1{i, last_col_raw_vel_trace_RW_medium_opto_target_1}; raw_vel_trace_RW_medium_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_RW_medium_opto_target_1(i, 1) = size(raw_vel_trace_RW_medium_opto_target_1{i, last_col_raw_vel_trace_RW_medium_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_RW_long_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_RW_long_opto_control{i, last_col_raw_vel_trace_RW_long_opto_control} = [];
%                 		raw_vel_trace_RW_long_opto_control{i, last_col_raw_vel_trace_RW_long_opto_control} = [raw_vel_trace_RW_long_opto_control{i, last_col_raw_vel_trace_RW_long_opto_control}; raw_vel_trace_RW_long_opto_control{i, j};];
%                     else
% 						raw_vel_trace_RW_long_opto_control{i, last_col_raw_vel_trace_RW_long_opto_control} = [raw_vel_trace_RW_long_opto_control{i, last_col_raw_vel_trace_RW_long_opto_control}; raw_vel_trace_RW_long_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_RW_long_opto_control(i, 1) = size(raw_vel_trace_RW_long_opto_control{i, last_col_raw_vel_trace_RW_long_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_RW_long_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_RW_long_opto_target_1{i, last_col_raw_vel_trace_RW_long_opto_target_1} = [];
%                 		raw_vel_trace_RW_long_opto_target_1{i, last_col_raw_vel_trace_RW_long_opto_target_1} = [raw_vel_trace_RW_long_opto_target_1{i, last_col_raw_vel_trace_RW_long_opto_target_1}; raw_vel_trace_RW_long_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_RW_long_opto_target_1{i, last_col_raw_vel_trace_RW_long_opto_target_1} = [raw_vel_trace_RW_long_opto_target_1{i, last_col_raw_vel_trace_RW_long_opto_target_1}; raw_vel_trace_RW_long_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_RW_long_opto_target_1(i, 1) = size(raw_vel_trace_RW_long_opto_target_1{i, last_col_raw_vel_trace_RW_long_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_RW_short_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_RW_short_opto_control{i, last_col_smooth_vel_trace_RW_short_opto_control} = [];
%                 		smooth_vel_trace_RW_short_opto_control{i, last_col_smooth_vel_trace_RW_short_opto_control} = [smooth_vel_trace_RW_short_opto_control{i, last_col_smooth_vel_trace_RW_short_opto_control}; smooth_vel_trace_RW_short_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_RW_short_opto_control{i, last_col_smooth_vel_trace_RW_short_opto_control} = [smooth_vel_trace_RW_short_opto_control{i, last_col_smooth_vel_trace_RW_short_opto_control}; smooth_vel_trace_RW_short_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_RW_short_opto_control(i, 1) = size(smooth_vel_trace_RW_short_opto_control{i, last_col_smooth_vel_trace_RW_short_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_RW_short_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_RW_short_opto_target_1{i, last_col_smooth_vel_trace_RW_short_opto_target_1} = [];
%                 		smooth_vel_trace_RW_short_opto_target_1{i, last_col_smooth_vel_trace_RW_short_opto_target_1} = [smooth_vel_trace_RW_short_opto_target_1{i, last_col_smooth_vel_trace_RW_short_opto_target_1}; smooth_vel_trace_RW_short_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_RW_short_opto_target_1{i, last_col_smooth_vel_trace_RW_short_opto_target_1} = [smooth_vel_trace_RW_short_opto_target_1{i, last_col_smooth_vel_trace_RW_short_opto_target_1}; smooth_vel_trace_RW_short_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_RW_short_opto_target_1(i, 1) = size(smooth_vel_trace_RW_short_opto_target_1{i, last_col_smooth_vel_trace_RW_short_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_RW_medium_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_RW_medium_opto_control{i, last_col_smooth_vel_trace_RW_medium_opto_control} = [];
%                 		smooth_vel_trace_RW_medium_opto_control{i, last_col_smooth_vel_trace_RW_medium_opto_control} = [smooth_vel_trace_RW_medium_opto_control{i, last_col_smooth_vel_trace_RW_medium_opto_control}; smooth_vel_trace_RW_medium_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_RW_medium_opto_control{i, last_col_smooth_vel_trace_RW_medium_opto_control} = [smooth_vel_trace_RW_medium_opto_control{i, last_col_smooth_vel_trace_RW_medium_opto_control}; smooth_vel_trace_RW_medium_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_RW_medium_opto_control(i, 1) = size(smooth_vel_trace_RW_medium_opto_control{i, last_col_smooth_vel_trace_RW_medium_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_RW_medium_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_RW_medium_opto_target_1{i, last_col_smooth_vel_trace_RW_medium_opto_target_1} = [];
%                 		smooth_vel_trace_RW_medium_opto_target_1{i, last_col_smooth_vel_trace_RW_medium_opto_target_1} = [smooth_vel_trace_RW_medium_opto_target_1{i, last_col_smooth_vel_trace_RW_medium_opto_target_1}; smooth_vel_trace_RW_medium_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_RW_medium_opto_target_1{i, last_col_smooth_vel_trace_RW_medium_opto_target_1} = [smooth_vel_trace_RW_medium_opto_target_1{i, last_col_smooth_vel_trace_RW_medium_opto_target_1}; smooth_vel_trace_RW_medium_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_RW_medium_opto_target_1(i, 1) = size(smooth_vel_trace_RW_medium_opto_target_1{i, last_col_smooth_vel_trace_RW_medium_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_RW_long_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_RW_long_opto_control{i, last_col_smooth_vel_trace_RW_long_opto_control} = [];
%                 		smooth_vel_trace_RW_long_opto_control{i, last_col_smooth_vel_trace_RW_long_opto_control} = [smooth_vel_trace_RW_long_opto_control{i, last_col_smooth_vel_trace_RW_long_opto_control}; smooth_vel_trace_RW_long_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_RW_long_opto_control{i, last_col_smooth_vel_trace_RW_long_opto_control} = [smooth_vel_trace_RW_long_opto_control{i, last_col_smooth_vel_trace_RW_long_opto_control}; smooth_vel_trace_RW_long_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_RW_long_opto_control(i, 1) = size(smooth_vel_trace_RW_long_opto_control{i, last_col_smooth_vel_trace_RW_long_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_RW_long_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_RW_long_opto_target_1{i, last_col_smooth_vel_trace_RW_long_opto_target_1} = [];
%                 		smooth_vel_trace_RW_long_opto_target_1{i, last_col_smooth_vel_trace_RW_long_opto_target_1} = [smooth_vel_trace_RW_long_opto_target_1{i, last_col_smooth_vel_trace_RW_long_opto_target_1}; smooth_vel_trace_RW_long_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_RW_long_opto_target_1{i, last_col_smooth_vel_trace_RW_long_opto_target_1} = [smooth_vel_trace_RW_long_opto_target_1{i, last_col_smooth_vel_trace_RW_long_opto_target_1}; smooth_vel_trace_RW_long_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_RW_long_opto_target_1(i, 1) = size(smooth_vel_trace_RW_long_opto_target_1{i, last_col_smooth_vel_trace_RW_long_opto_target_1}, 1);

%                 end





%                 for j = 1:(last_col_raw_vel_trace_PT_short_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_PT_short_opto_control{i, last_col_raw_vel_trace_PT_short_opto_control} = [];
%                 		raw_vel_trace_PT_short_opto_control{i, last_col_raw_vel_trace_PT_short_opto_control} = [raw_vel_trace_PT_short_opto_control{i, last_col_raw_vel_trace_PT_short_opto_control}; raw_vel_trace_PT_short_opto_control{i, j};];
%                     else
% 						raw_vel_trace_PT_short_opto_control{i, last_col_raw_vel_trace_PT_short_opto_control} = [raw_vel_trace_PT_short_opto_control{i, last_col_raw_vel_trace_PT_short_opto_control}; raw_vel_trace_PT_short_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_PT_short_opto_control(i, 1) = size(raw_vel_trace_PT_short_opto_control{i, last_col_raw_vel_trace_PT_short_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_PT_short_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_PT_short_opto_target_1{i, last_col_raw_vel_trace_PT_short_opto_target_1} = [];
%                 		raw_vel_trace_PT_short_opto_target_1{i, last_col_raw_vel_trace_PT_short_opto_target_1} = [raw_vel_trace_PT_short_opto_target_1{i, last_col_raw_vel_trace_PT_short_opto_target_1}; raw_vel_trace_PT_short_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_PT_short_opto_target_1{i, last_col_raw_vel_trace_PT_short_opto_target_1} = [raw_vel_trace_PT_short_opto_target_1{i, last_col_raw_vel_trace_PT_short_opto_target_1}; raw_vel_trace_PT_short_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_PT_short_opto_target_1(i, 1) = size(raw_vel_trace_PT_short_opto_target_1{i, last_col_raw_vel_trace_PT_short_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_PT_medium_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_PT_medium_opto_control{i, last_col_raw_vel_trace_PT_medium_opto_control} = [];
%                 		raw_vel_trace_PT_medium_opto_control{i, last_col_raw_vel_trace_PT_medium_opto_control} = [raw_vel_trace_PT_medium_opto_control{i, last_col_raw_vel_trace_PT_medium_opto_control}; raw_vel_trace_PT_medium_opto_control{i, j};];
%                     else
% 						raw_vel_trace_PT_medium_opto_control{i, last_col_raw_vel_trace_PT_medium_opto_control} = [raw_vel_trace_PT_medium_opto_control{i, last_col_raw_vel_trace_PT_medium_opto_control}; raw_vel_trace_PT_medium_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_PT_medium_opto_control(i, 1) = size(raw_vel_trace_PT_medium_opto_control{i, last_col_raw_vel_trace_PT_medium_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_PT_medium_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_PT_medium_opto_target_1{i, last_col_raw_vel_trace_PT_medium_opto_target_1} = [];
%                 		raw_vel_trace_PT_medium_opto_target_1{i, last_col_raw_vel_trace_PT_medium_opto_target_1} = [raw_vel_trace_PT_medium_opto_target_1{i, last_col_raw_vel_trace_PT_medium_opto_target_1}; raw_vel_trace_PT_medium_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_PT_medium_opto_target_1{i, last_col_raw_vel_trace_PT_medium_opto_target_1} = [raw_vel_trace_PT_medium_opto_target_1{i, last_col_raw_vel_trace_PT_medium_opto_target_1}; raw_vel_trace_PT_medium_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_PT_medium_opto_target_1(i, 1) = size(raw_vel_trace_PT_medium_opto_target_1{i, last_col_raw_vel_trace_PT_medium_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_PT_long_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_PT_long_opto_control{i, last_col_raw_vel_trace_PT_long_opto_control} = [];
%                 		raw_vel_trace_PT_long_opto_control{i, last_col_raw_vel_trace_PT_long_opto_control} = [raw_vel_trace_PT_long_opto_control{i, last_col_raw_vel_trace_PT_long_opto_control}; raw_vel_trace_PT_long_opto_control{i, j};];
%                     else
% 						raw_vel_trace_PT_long_opto_control{i, last_col_raw_vel_trace_PT_long_opto_control} = [raw_vel_trace_PT_long_opto_control{i, last_col_raw_vel_trace_PT_long_opto_control}; raw_vel_trace_PT_long_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_PT_long_opto_control(i, 1) = size(raw_vel_trace_PT_long_opto_control{i, last_col_raw_vel_trace_PT_long_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_PT_long_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_PT_long_opto_target_1{i, last_col_raw_vel_trace_PT_long_opto_target_1} = [];
%                 		raw_vel_trace_PT_long_opto_target_1{i, last_col_raw_vel_trace_PT_long_opto_target_1} = [raw_vel_trace_PT_long_opto_target_1{i, last_col_raw_vel_trace_PT_long_opto_target_1}; raw_vel_trace_PT_long_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_PT_long_opto_target_1{i, last_col_raw_vel_trace_PT_long_opto_target_1} = [raw_vel_trace_PT_long_opto_target_1{i, last_col_raw_vel_trace_PT_long_opto_target_1}; raw_vel_trace_PT_long_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_PT_long_opto_target_1(i, 1) = size(raw_vel_trace_PT_long_opto_target_1{i, last_col_raw_vel_trace_PT_long_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_PT_short_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_PT_short_opto_control{i, last_col_smooth_vel_trace_PT_short_opto_control} = [];
%                 		smooth_vel_trace_PT_short_opto_control{i, last_col_smooth_vel_trace_PT_short_opto_control} = [smooth_vel_trace_PT_short_opto_control{i, last_col_smooth_vel_trace_PT_short_opto_control}; smooth_vel_trace_PT_short_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_PT_short_opto_control{i, last_col_smooth_vel_trace_PT_short_opto_control} = [smooth_vel_trace_PT_short_opto_control{i, last_col_smooth_vel_trace_PT_short_opto_control}; smooth_vel_trace_PT_short_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_PT_short_opto_control(i, 1) = size(smooth_vel_trace_PT_short_opto_control{i, last_col_smooth_vel_trace_PT_short_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_PT_short_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_PT_short_opto_target_1{i, last_col_smooth_vel_trace_PT_short_opto_target_1} = [];
%                 		smooth_vel_trace_PT_short_opto_target_1{i, last_col_smooth_vel_trace_PT_short_opto_target_1} = [smooth_vel_trace_PT_short_opto_target_1{i, last_col_smooth_vel_trace_PT_short_opto_target_1}; smooth_vel_trace_PT_short_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_PT_short_opto_target_1{i, last_col_smooth_vel_trace_PT_short_opto_target_1} = [smooth_vel_trace_PT_short_opto_target_1{i, last_col_smooth_vel_trace_PT_short_opto_target_1}; smooth_vel_trace_PT_short_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_PT_short_opto_target_1(i, 1) = size(smooth_vel_trace_PT_short_opto_target_1{i, last_col_smooth_vel_trace_PT_short_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_PT_medium_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_PT_medium_opto_control{i, last_col_smooth_vel_trace_PT_medium_opto_control} = [];
%                 		smooth_vel_trace_PT_medium_opto_control{i, last_col_smooth_vel_trace_PT_medium_opto_control} = [smooth_vel_trace_PT_medium_opto_control{i, last_col_smooth_vel_trace_PT_medium_opto_control}; smooth_vel_trace_PT_medium_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_PT_medium_opto_control{i, last_col_smooth_vel_trace_PT_medium_opto_control} = [smooth_vel_trace_PT_medium_opto_control{i, last_col_smooth_vel_trace_PT_medium_opto_control}; smooth_vel_trace_PT_medium_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_PT_medium_opto_control(i, 1) = size(smooth_vel_trace_PT_medium_opto_control{i, last_col_smooth_vel_trace_PT_medium_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_PT_medium_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_PT_medium_opto_target_1{i, last_col_smooth_vel_trace_PT_medium_opto_target_1} = [];
%                 		smooth_vel_trace_PT_medium_opto_target_1{i, last_col_smooth_vel_trace_PT_medium_opto_target_1} = [smooth_vel_trace_PT_medium_opto_target_1{i, last_col_smooth_vel_trace_PT_medium_opto_target_1}; smooth_vel_trace_PT_medium_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_PT_medium_opto_target_1{i, last_col_smooth_vel_trace_PT_medium_opto_target_1} = [smooth_vel_trace_PT_medium_opto_target_1{i, last_col_smooth_vel_trace_PT_medium_opto_target_1}; smooth_vel_trace_PT_medium_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_PT_medium_opto_target_1(i, 1) = size(smooth_vel_trace_PT_medium_opto_target_1{i, last_col_smooth_vel_trace_PT_medium_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_PT_long_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_PT_long_opto_control{i, last_col_smooth_vel_trace_PT_long_opto_control} = [];
%                 		smooth_vel_trace_PT_long_opto_control{i, last_col_smooth_vel_trace_PT_long_opto_control} = [smooth_vel_trace_PT_long_opto_control{i, last_col_smooth_vel_trace_PT_long_opto_control}; smooth_vel_trace_PT_long_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_PT_long_opto_control{i, last_col_smooth_vel_trace_PT_long_opto_control} = [smooth_vel_trace_PT_long_opto_control{i, last_col_smooth_vel_trace_PT_long_opto_control}; smooth_vel_trace_PT_long_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_PT_long_opto_control(i, 1) = size(smooth_vel_trace_PT_long_opto_control{i, last_col_smooth_vel_trace_PT_long_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_PT_long_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_PT_long_opto_target_1{i, last_col_smooth_vel_trace_PT_long_opto_target_1} = [];
%                 		smooth_vel_trace_PT_long_opto_target_1{i, last_col_smooth_vel_trace_PT_long_opto_target_1} = [smooth_vel_trace_PT_long_opto_target_1{i, last_col_smooth_vel_trace_PT_long_opto_target_1}; smooth_vel_trace_PT_long_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_PT_long_opto_target_1{i, last_col_smooth_vel_trace_PT_long_opto_target_1} = [smooth_vel_trace_PT_long_opto_target_1{i, last_col_smooth_vel_trace_PT_long_opto_target_1}; smooth_vel_trace_PT_long_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_PT_long_opto_target_1(i, 1) = size(smooth_vel_trace_PT_long_opto_target_1{i, last_col_smooth_vel_trace_PT_long_opto_target_1}, 1);

%                 end







%                 for j = 1:(last_col_raw_vel_trace_OR_short_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_OR_short_opto_control{i, last_col_raw_vel_trace_OR_short_opto_control} = [];
%                 		raw_vel_trace_OR_short_opto_control{i, last_col_raw_vel_trace_OR_short_opto_control} = [raw_vel_trace_OR_short_opto_control{i, last_col_raw_vel_trace_OR_short_opto_control}; raw_vel_trace_OR_short_opto_control{i, j};];
%                     else
% 						raw_vel_trace_OR_short_opto_control{i, last_col_raw_vel_trace_OR_short_opto_control} = [raw_vel_trace_OR_short_opto_control{i, last_col_raw_vel_trace_OR_short_opto_control}; raw_vel_trace_OR_short_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_OR_short_opto_control(i, 1) = size(raw_vel_trace_OR_short_opto_control{i, last_col_raw_vel_trace_OR_short_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_OR_short_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_OR_short_opto_target_1{i, last_col_raw_vel_trace_OR_short_opto_target_1} = [];
%                 		raw_vel_trace_OR_short_opto_target_1{i, last_col_raw_vel_trace_OR_short_opto_target_1} = [raw_vel_trace_OR_short_opto_target_1{i, last_col_raw_vel_trace_OR_short_opto_target_1}; raw_vel_trace_OR_short_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_OR_short_opto_target_1{i, last_col_raw_vel_trace_OR_short_opto_target_1} = [raw_vel_trace_OR_short_opto_target_1{i, last_col_raw_vel_trace_OR_short_opto_target_1}; raw_vel_trace_OR_short_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_OR_short_opto_target_1(i, 1) = size(raw_vel_trace_OR_short_opto_target_1{i, last_col_raw_vel_trace_OR_short_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_OR_medium_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_OR_medium_opto_control{i, last_col_raw_vel_trace_OR_medium_opto_control} = [];
%                 		raw_vel_trace_OR_medium_opto_control{i, last_col_raw_vel_trace_OR_medium_opto_control} = [raw_vel_trace_OR_medium_opto_control{i, last_col_raw_vel_trace_OR_medium_opto_control}; raw_vel_trace_OR_medium_opto_control{i, j};];
%                     else
% 						raw_vel_trace_OR_medium_opto_control{i, last_col_raw_vel_trace_OR_medium_opto_control} = [raw_vel_trace_OR_medium_opto_control{i, last_col_raw_vel_trace_OR_medium_opto_control}; raw_vel_trace_OR_medium_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_OR_medium_opto_control(i, 1) = size(raw_vel_trace_OR_medium_opto_control{i, last_col_raw_vel_trace_OR_medium_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_OR_medium_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_OR_medium_opto_target_1{i, last_col_raw_vel_trace_OR_medium_opto_target_1} = [];
%                 		raw_vel_trace_OR_medium_opto_target_1{i, last_col_raw_vel_trace_OR_medium_opto_target_1} = [raw_vel_trace_OR_medium_opto_target_1{i, last_col_raw_vel_trace_OR_medium_opto_target_1}; raw_vel_trace_OR_medium_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_OR_medium_opto_target_1{i, last_col_raw_vel_trace_OR_medium_opto_target_1} = [raw_vel_trace_OR_medium_opto_target_1{i, last_col_raw_vel_trace_OR_medium_opto_target_1}; raw_vel_trace_OR_medium_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_OR_medium_opto_target_1(i, 1) = size(raw_vel_trace_OR_medium_opto_target_1{i, last_col_raw_vel_trace_OR_medium_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_OR_long_opto_control - 1)
%                     if j == 1
% 						raw_vel_trace_OR_long_opto_control{i, last_col_raw_vel_trace_OR_long_opto_control} = [];
%                 		raw_vel_trace_OR_long_opto_control{i, last_col_raw_vel_trace_OR_long_opto_control} = [raw_vel_trace_OR_long_opto_control{i, last_col_raw_vel_trace_OR_long_opto_control}; raw_vel_trace_OR_long_opto_control{i, j};];
%                     else
% 						raw_vel_trace_OR_long_opto_control{i, last_col_raw_vel_trace_OR_long_opto_control} = [raw_vel_trace_OR_long_opto_control{i, last_col_raw_vel_trace_OR_long_opto_control}; raw_vel_trace_OR_long_opto_control{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_OR_long_opto_control(i, 1) = size(raw_vel_trace_OR_long_opto_control{i, last_col_raw_vel_trace_OR_long_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_raw_vel_trace_OR_long_opto_target_1 - 1)
%                     if j == 1
% 						raw_vel_trace_OR_long_opto_target_1{i, last_col_raw_vel_trace_OR_long_opto_target_1} = [];
%                 		raw_vel_trace_OR_long_opto_target_1{i, last_col_raw_vel_trace_OR_long_opto_target_1} = [raw_vel_trace_OR_long_opto_target_1{i, last_col_raw_vel_trace_OR_long_opto_target_1}; raw_vel_trace_OR_long_opto_target_1{i, j};];
%                     else
% 						raw_vel_trace_OR_long_opto_target_1{i, last_col_raw_vel_trace_OR_long_opto_target_1} = [raw_vel_trace_OR_long_opto_target_1{i, last_col_raw_vel_trace_OR_long_opto_target_1}; raw_vel_trace_OR_long_opto_target_1{i, j};];
%                     end

% 				data_sizes_raw_vel_trace_OR_long_opto_target_1(i, 1) = size(raw_vel_trace_OR_long_opto_target_1{i, last_col_raw_vel_trace_OR_long_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_OR_short_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_OR_short_opto_control{i, last_col_smooth_vel_trace_OR_short_opto_control} = [];
%                 		smooth_vel_trace_OR_short_opto_control{i, last_col_smooth_vel_trace_OR_short_opto_control} = [smooth_vel_trace_OR_short_opto_control{i, last_col_smooth_vel_trace_OR_short_opto_control}; smooth_vel_trace_OR_short_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_OR_short_opto_control{i, last_col_smooth_vel_trace_OR_short_opto_control} = [smooth_vel_trace_OR_short_opto_control{i, last_col_smooth_vel_trace_OR_short_opto_control}; smooth_vel_trace_OR_short_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_OR_short_opto_control(i, 1) = size(smooth_vel_trace_OR_short_opto_control{i, last_col_smooth_vel_trace_OR_short_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_OR_short_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_OR_short_opto_target_1{i, last_col_smooth_vel_trace_OR_short_opto_target_1} = [];
%                 		smooth_vel_trace_OR_short_opto_target_1{i, last_col_smooth_vel_trace_OR_short_opto_target_1} = [smooth_vel_trace_OR_short_opto_target_1{i, last_col_smooth_vel_trace_OR_short_opto_target_1}; smooth_vel_trace_OR_short_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_OR_short_opto_target_1{i, last_col_smooth_vel_trace_OR_short_opto_target_1} = [smooth_vel_trace_OR_short_opto_target_1{i, last_col_smooth_vel_trace_OR_short_opto_target_1}; smooth_vel_trace_OR_short_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_OR_short_opto_target_1(i, 1) = size(smooth_vel_trace_OR_short_opto_target_1{i, last_col_smooth_vel_trace_OR_short_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_OR_medium_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_OR_medium_opto_control{i, last_col_smooth_vel_trace_OR_medium_opto_control} = [];
%                 		smooth_vel_trace_OR_medium_opto_control{i, last_col_smooth_vel_trace_OR_medium_opto_control} = [smooth_vel_trace_OR_medium_opto_control{i, last_col_smooth_vel_trace_OR_medium_opto_control}; smooth_vel_trace_OR_medium_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_OR_medium_opto_control{i, last_col_smooth_vel_trace_OR_medium_opto_control} = [smooth_vel_trace_OR_medium_opto_control{i, last_col_smooth_vel_trace_OR_medium_opto_control}; smooth_vel_trace_OR_medium_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_OR_medium_opto_control(i, 1) = size(smooth_vel_trace_OR_medium_opto_control{i, last_col_smooth_vel_trace_OR_medium_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_OR_medium_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_OR_medium_opto_target_1{i, last_col_smooth_vel_trace_OR_medium_opto_target_1} = [];
%                 		smooth_vel_trace_OR_medium_opto_target_1{i, last_col_smooth_vel_trace_OR_medium_opto_target_1} = [smooth_vel_trace_OR_medium_opto_target_1{i, last_col_smooth_vel_trace_OR_medium_opto_target_1}; smooth_vel_trace_OR_medium_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_OR_medium_opto_target_1{i, last_col_smooth_vel_trace_OR_medium_opto_target_1} = [smooth_vel_trace_OR_medium_opto_target_1{i, last_col_smooth_vel_trace_OR_medium_opto_target_1}; smooth_vel_trace_OR_medium_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_OR_medium_opto_target_1(i, 1) = size(smooth_vel_trace_OR_medium_opto_target_1{i, last_col_smooth_vel_trace_OR_medium_opto_target_1}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_OR_long_opto_control - 1)
%                     if j == 1
% 						smooth_vel_trace_OR_long_opto_control{i, last_col_smooth_vel_trace_OR_long_opto_control} = [];
%                 		smooth_vel_trace_OR_long_opto_control{i, last_col_smooth_vel_trace_OR_long_opto_control} = [smooth_vel_trace_OR_long_opto_control{i, last_col_smooth_vel_trace_OR_long_opto_control}; smooth_vel_trace_OR_long_opto_control{i, j};];
%                     else
% 						smooth_vel_trace_OR_long_opto_control{i, last_col_smooth_vel_trace_OR_long_opto_control} = [smooth_vel_trace_OR_long_opto_control{i, last_col_smooth_vel_trace_OR_long_opto_control}; smooth_vel_trace_OR_long_opto_control{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_OR_long_opto_control(i, 1) = size(smooth_vel_trace_OR_long_opto_control{i, last_col_smooth_vel_trace_OR_long_opto_control}, 1);

%                 end

%                 for j = 1:(last_col_smooth_vel_trace_OR_long_opto_target_1 - 1)
%                     if j == 1
% 						smooth_vel_trace_OR_long_opto_target_1{i, last_col_smooth_vel_trace_OR_long_opto_target_1} = [];
%                 		smooth_vel_trace_OR_long_opto_target_1{i, last_col_smooth_vel_trace_OR_long_opto_target_1} = [smooth_vel_trace_OR_long_opto_target_1{i, last_col_smooth_vel_trace_OR_long_opto_target_1}; smooth_vel_trace_OR_long_opto_target_1{i, j};];
%                     else
% 						smooth_vel_trace_OR_long_opto_target_1{i, last_col_smooth_vel_trace_OR_long_opto_target_1} = [smooth_vel_trace_OR_long_opto_target_1{i, last_col_smooth_vel_trace_OR_long_opto_target_1}; smooth_vel_trace_OR_long_opto_target_1{i, j};];
%                     end

% 				data_sizes_smooth_vel_trace_OR_long_opto_target_1(i, 1) = size(smooth_vel_trace_OR_long_opto_target_1{i, last_col_smooth_vel_trace_OR_long_opto_target_1}, 1);

%                 end


%                 for j = 1:(last_col_pre_rw_lick_rates_opto_control - 1)
%                     if j == 1
% 						pre_rw_lick_rates_opto_control{i, last_col_pre_rw_lick_rates_opto_control} = [];
%                 		pre_rw_lick_rates_opto_control{i, last_col_pre_rw_lick_rates_opto_control} = [pre_rw_lick_rates_opto_control{i, last_col_pre_rw_lick_rates_opto_control}; pre_rw_lick_rates_opto_control{i, j};];
%                     else
% 						pre_rw_lick_rates_opto_control{i, last_col_pre_rw_lick_rates_opto_control} = [pre_rw_lick_rates_opto_control{i, last_col_pre_rw_lick_rates_opto_control}; pre_rw_lick_rates_opto_control{i, j};];
%                     end

% 				data_sizes_pre_rw_lick_rates_opto_control(i, 1) = size(pre_rw_lick_rates_opto_control{i, last_col_pre_rw_lick_rates_opto_control}, 1);

%                 end


%                 for j = 1:(last_col_pre_rw_lick_rates_opto_target_1 - 1)
%                     if j == 1
% 						pre_rw_lick_rates_opto_target_1{i, last_col_pre_rw_lick_rates_opto_target_1} = [];
%                 		pre_rw_lick_rates_opto_target_1{i, last_col_pre_rw_lick_rates_opto_target_1} = [pre_rw_lick_rates_opto_target_1{i, last_col_pre_rw_lick_rates_opto_target_1}; pre_rw_lick_rates_opto_target_1{i, j};];
%                     else
% 						pre_rw_lick_rates_opto_target_1{i, last_col_pre_rw_lick_rates_opto_target_1} = [pre_rw_lick_rates_opto_target_1{i, last_col_pre_rw_lick_rates_opto_target_1}; pre_rw_lick_rates_opto_target_1{i, j};];
%                     end

% 				data_sizes_pre_rw_lick_rates_opto_target_1(i, 1) = size(pre_rw_lick_rates_opto_target_1{i, last_col_pre_rw_lick_rates_opto_target_1}, 1);

%                 end

% 			end



% for i = 1:length(output_combined)

%             output_combined(i).RW_Prop_distcont_optocont = output_combined(i).Rewards_distcont_optocont / output_combined(i).Total_Trials_distcont_optocont;
%             output_combined(i).RW_Prop_distcont_optotarg = output_combined(i).Rewards_distcont_optotarg / output_combined(i).Total_Trials_distcont_optotarg;

%             output_combined(i).RW_Prop_disttarg_optocont = output_combined(i).Rewards_disttarg_optocont / output_combined(i).Total_Trials_disttarg_optocont;
%             output_combined(i).RW_Prop_disttarg_optotarg = output_combined(i).Rewards_disttarg_optotarg / output_combined(i).Total_Trials_disttarg_optotarg;

%             output_combined(i).DR_Prop_distcont_optocont = output_combined(i).Distracted_Responding_distcont_optocont / output_combined(i).Total_Trials_distcont_optocont;
%             output_combined(i).DR_Prop_distcont_optotarg = output_combined(i).Distracted_Responding_distcont_optotarg / output_combined(i).Total_Trials_distcont_optotarg;

%             output_combined(i).DR_Prop_disttarg_optocont = output_combined(i).Distracted_Responding_disttarg_optocont / output_combined(i).Total_Trials_disttarg_optocont;
%             output_combined(i).DR_Prop_disttarg_optotarg = output_combined(i).Distracted_Responding_disttarg_optotarg / output_combined(i).Total_Trials_disttarg_optotarg;

%             output_combined(i).OR_Prop_distcont_optocont = output_combined(i).Overruns_distcont_optocont / output_combined(i).Total_Trials_distcont_optocont;
%             output_combined(i).OR_Prop_distcont_optotarg = output_combined(i).Overruns_distcont_optotarg / output_combined(i).Total_Trials_distcont_optotarg;

%             output_combined(i).OR_Prop_disttarg_optocont = output_combined(i).Overruns_disttarg_optocont / output_combined(i).Total_Trials_disttarg_optocont;
%             output_combined(i).OR_Prop_disttarg_optotarg = output_combined(i).Overruns_disttarg_optotarg / output_combined(i).Total_Trials_disttarg_optotarg;

%             output_combined(i).SR_Prop_distcont_optocont = output_combined(i).Spontaneous_Responding_distcont_optocont / output_combined(i).Total_Trials_distcont_optocont;
%             output_combined(i).SR_Prop_distcont_optotarg = output_combined(i).Spontaneous_Responding_distcont_optotarg / output_combined(i).Total_Trials_distcont_optotarg;

%             output_combined(i).SR_Prop_disttarg_optocont = output_combined(i).Spontaneous_Responding_disttarg_optocont / output_combined(i).Total_Trials_disttarg_optocont;
%             output_combined(i).SR_Prop_disttarg_optotarg = output_combined(i).Spontaneous_Responding_disttarg_optotarg / output_combined(i).Total_Trials_disttarg_optotarg;

%             output_combined(i).SR_PreWN_distcont_optocont = output_combined(i).Spontaneous_Responding_Presound_distcont_optocont / output_combined(i).Total_Trials_distcont_optocont;
%             output_combined(i).SR_PreWN_distcont_optotarg = output_combined(i).Spontaneous_Responding_Presound_distcont_optotarg / output_combined(i).Total_Trials_distcont_optotarg;

%             output_combined(i).SR_PreWN_disttarg_optocont = output_combined(i).Spontaneous_Responding_Presound_disttarg_optocont / output_combined(i).Total_Trials_disttarg_optocont;
%             output_combined(i).SR_PreWN_disttarg_optotarg = output_combined(i).Spontaneous_Responding_Presound_disttarg_optotarg / output_combined(i).Total_Trials_disttarg_optotarg;

%             output_combined(i).SR_PostWN_distcont_optocont = output_combined(i).Spontaneous_Responding_Postsound_distcont_optocont / output_combined(i).Total_Trials_distcont_optocont;
%             output_combined(i).SR_PostWN_distcont_optotarg = output_combined(i).Spontaneous_Responding_Postsound_distcont_optotarg / output_combined(i).Total_Trials_distcont_optotarg;

%             output_combined(i).SR_PostWN_disttarg_optocont = output_combined(i).Spontaneous_Responding_Postsound_disttarg_optocont / output_combined(i).Total_Trials_disttarg_optocont;     
%             output_combined(i).SR_PostWN_disttarg_optotarg = output_combined(i).Spontaneous_Responding_Postsound_disttarg_optotarg / output_combined(i).Total_Trials_disttarg_optotarg; 


% 	% output_combined(i).Reward_Prop_opto_control = output_combined(i).Complete_opto_control / output_combined(i).Total_Running_Trials_Late_opto_control;   
% 	% output_combined(i).Reward_Prop_opto_target_1 = output_combined(i).Complete_opto_target_1 / output_combined(i).Total_Running_Trials_Late_opto_target_1;   
% 	% output_combined(i).Reward_Prop_short_opto_control = output_combined(i).Complete_short_opto_control / output_combined(i).Total_Running_Trials_Late_short_opto_control; 
% 	% output_combined(i).Reward_Prop_short_opto_target_1 = output_combined(i).Complete_short_opto_target_1 / output_combined(i).Total_Running_Trials_Late_short_opto_target_1;   
% 	% output_combined(i).Reward_Prop_medium_opto_control = output_combined(i).Complete_medium_opto_control / output_combined(i).Total_Running_Trials_Late_medium_opto_control;   
% 	% output_combined(i).Reward_Prop_medium_opto_target_1 = output_combined(i).Complete_medium_opto_target_1 / output_combined(i).Total_Running_Trials_Late_medium_opto_target_1;   
% 	% output_combined(i).Reward_Prop_long_opto_control = output_combined(i).Complete_long_opto_control / output_combined(i).Total_Running_Trials_Late_long_opto_control;   
% 	% output_combined(i).Reward_Prop_long_opto_target_1 = output_combined(i).Complete_long_opto_target_1 / output_combined(i).Total_Running_Trials_Late_long_opto_target_1;   

% 	% output_combined(i).PreTarget_Error_Prop_opto_control = (output_combined(i).Premature_slowdown_late_opto_control + output_combined(i).Incomplete_late_opto_control) / output_combined(i).Total_Running_Trials_Late_opto_control;
% 	% output_combined(i).PreTarget_Error_Prop_opto_target_1 = (output_combined(i).Premature_slowdown_late_opto_target_1 + output_combined(i).Incomplete_late_opto_target_1) / output_combined(i).Total_Running_Trials_Late_opto_target_1;
% 	% output_combined(i).PreTarget_Error_Prop_short_opto_control = (output_combined(i).Premature_slowdown_late_short_opto_control + output_combined(i).Incomplete_late_short_opto_control) / output_combined(i).Total_Running_Trials_Late_short_opto_control;
% 	% output_combined(i).PreTarget_Error_Prop_short_opto_target_1 = (output_combined(i).Premature_slowdown_late_short_opto_target_1 + output_combined(i).Incomplete_late_short_opto_target_1) / output_combined(i).Total_Running_Trials_Late_short_opto_target_1;
% 	% output_combined(i).PreTarget_Error_Prop_medium_opto_control = (output_combined(i).Premature_slowdown_late_medium_opto_control + output_combined(i).Incomplete_late_medium_opto_control) / output_combined(i).Total_Running_Trials_Late_medium_opto_control;
% 	% output_combined(i).PreTarget_Error_Prop_medium_opto_target_1 = (output_combined(i).Premature_slowdown_late_medium_opto_target_1 + output_combined(i).Incomplete_late_medium_opto_target_1) / output_combined(i).Total_Running_Trials_Late_medium_opto_target_1;
% 	% output_combined(i).PreTarget_Error_Prop_long_opto_control = (output_combined(i).Premature_slowdown_late_long_opto_control + output_combined(i).Incomplete_late_long_opto_control) / output_combined(i).Total_Running_Trials_Late_long_opto_control;
% 	% output_combined(i).PreTarget_Error_Prop_long_opto_target_1 = (output_combined(i).Premature_slowdown_late_long_opto_target_1 + output_combined(i).Incomplete_late_long_opto_target_1) / output_combined(i).Total_Running_Trials_Late_long_opto_target_1;

% 	% output_combined(i).Overrun_Prop_opto_control = output_combined(i).Overrun_opto_control / output_combined(i).Total_Running_Trials_Late_opto_control;
% 	% output_combined(i).Overrun_Prop_opto_target_1 = output_combined(i).Overrun_opto_target_1 / output_combined(i).Total_Running_Trials_Late_opto_target_1;
% 	% output_combined(i).Overrun_Prop_short_opto_control = output_combined(i).Overrun_short_opto_control / output_combined(i).Total_Running_Trials_Late_short_opto_control;
% 	% output_combined(i).Overrun_Prop_short_opto_target_1 = output_combined(i).Overrun_short_opto_target_1 / output_combined(i).Total_Running_Trials_Late_short_opto_target_1;
% 	% output_combined(i).Overrun_Prop_medium_opto_control = output_combined(i).Overrun_medium_opto_control / output_combined(i).Total_Running_Trials_Late_medium_opto_control;
% 	% output_combined(i).Overrun_Prop_medium_opto_target_1 = output_combined(i).Overrun_medium_opto_target_1 / output_combined(i).Total_Running_Trials_Late_medium_opto_target_1;
% 	% output_combined(i).Overrun_Prop_long_opto_control = output_combined(i).Overrun_long_opto_control / output_combined(i).Total_Running_Trials_Late_long_opto_control;
% 	% output_combined(i).Overrun_Prop_long_opto_target_1 = output_combined(i).Overrun_long_opto_target_1 / output_combined(i).Total_Running_Trials_Late_long_opto_target_1;

% 	% output_combined(i).Early_Error_Ratio_Acceleration_opto_control = output_combined(i).Premature_slowdown_imm_opto_control / (output_combined(i).Total_Running_Trials_opto_control - output_combined(i).Total_Running_Trials_Late_opto_control);
% 	% output_combined(i).Early_Error_Ratio_Acceleration_opto_target_1 = output_combined(i).Premature_slowdown_imm_opto_target_1 / (output_combined(i).Total_Running_Trials_opto_target_1 - output_combined(i).Total_Running_Trials_Late_opto_target_1);
% 	% output_combined(i).Early_Error_Ratio_Acceleration_short_opto_control = output_combined(i).Premature_slowdown_imm_short_opto_control / (output_combined(i).Total_Running_Trials_short_opto_control - output_combined(i).Total_Running_Trials_Late_short_opto_control);
% 	% output_combined(i).Early_Error_Ratio_Acceleration_short_opto_target_1 = output_combined(i).Premature_slowdown_imm_short_opto_target_1 / (output_combined(i).Total_Running_Trials_short_opto_target_1 - output_combined(i).Total_Running_Trials_Late_short_opto_target_1);
% 	% output_combined(i).Early_Error_Ratio_Acceleration_medium_opto_control = output_combined(i).Premature_slowdown_imm_medium_opto_control / (output_combined(i).Total_Running_Trials_medium_opto_control - output_combined(i).Total_Running_Trials_Late_medium_opto_control);
% 	% output_combined(i).Early_Error_Ratio_Acceleration_medium_opto_target_1 = output_combined(i).Premature_slowdown_imm_medium_opto_target_1 / (output_combined(i).Total_Running_Trials_medium_opto_target_1 - output_combined(i).Total_Running_Trials_Late_medium_opto_target_1);
% 	% output_combined(i).Early_Error_Ratio_Acceleration_long_opto_control = output_combined(i).Premature_slowdown_imm_long_opto_control / (output_combined(i).Total_Running_Trials_long_opto_control - output_combined(i).Total_Running_Trials_Late_long_opto_control);
% 	% output_combined(i).Early_Error_Ratio_Acceleration_long_opto_target_1 = output_combined(i).Premature_slowdown_imm_long_opto_target_1 / (output_combined(i).Total_Running_Trials_long_opto_target_1 - output_combined(i).Total_Running_Trials_Late_long_opto_target_1);

% 	% output_combined(i).Acceleration_Error_Prop_opto_control = output_combined(i).Premature_slowdown_imm_opto_control / output_combined(i).Total_Running_Trials_opto_control;
% 	% output_combined(i).Acceleration_Error_Prop_opto_target_1 = output_combined(i).Premature_slowdown_imm_opto_target_1 / output_combined(i).Total_Running_Trials_opto_target_1;
% 	% output_combined(i).Acceleration_Error_Prop_short_opto_control = output_combined(i).Premature_slowdown_imm_short_opto_control / output_combined(i).Total_Running_Trials_short_opto_control;
% 	% output_combined(i).Acceleration_Error_Prop_short_opto_target_1 = output_combined(i).Premature_slowdown_imm_short_opto_target_1 / output_combined(i).Total_Running_Trials_short_opto_target_1;
% 	% output_combined(i).Acceleration_Error_Prop_medium_opto_control = output_combined(i).Premature_slowdown_imm_medium_opto_control / output_combined(i).Total_Running_Trials_medium_opto_control;
% 	% output_combined(i).Acceleration_Error_Prop_medium_opto_target_1 = output_combined(i).Premature_slowdown_imm_medium_opto_target_1 / output_combined(i).Total_Running_Trials_medium_opto_target_1;
% 	% output_combined(i).Acceleration_Error_Prop_long_opto_control = output_combined(i).Premature_slowdown_imm_long_opto_control / output_combined(i).Total_Running_Trials_long_opto_control;
% 	% output_combined(i).Acceleration_Error_Prop_long_opto_target_1 = output_combined(i).Premature_slowdown_imm_long_opto_target_1 / output_combined(i).Total_Running_Trials_long_opto_target_1;


% 	output_combined(i).pretarget_error_distance_optocont = pretarget_error_dist_optocont{i, last_col_pretarget_error_dist_optocont}(:, :);
% 	output_combined(i).pretarget_error_distance_optotarg = pretarget_error_dist_optotarg{i, last_col_pretarget_error_dist_optotarg}(:, :);

% 	output_combined(i).pretarget_error_short_distance_optocont = pretarget_error_short_dist_optocont{i, last_col_pretarget_error_short_dist_optocont}(:, :);
% 	output_combined(i).pretarget_error_medium_distance_optocont = pretarget_error_medium_dist_optocont{i, last_col_pretarget_error_medium_dist_optocont}(:, :);
% 	output_combined(i).pretarget_error_long_distance_optocont = pretarget_error_long_dist_optocont{i, last_col_pretarget_error_long_dist_optocont}(:, :);

% 	output_combined(i).pretarget_error_short_distance_optotarg = pretarget_error_short_dist_optotarg{i, last_col_pretarget_error_short_dist_optotarg}(:, :);
% 	output_combined(i).pretarget_error_medium_distance_optotarg = pretarget_error_medium_dist_optotarg{i, last_col_pretarget_error_medium_dist_optotarg}(:, :);
% 	output_combined(i).pretarget_error_long_distance_optotarg = pretarget_error_long_dist_optotarg{i, last_col_pretarget_error_long_dist_optotarg}(:, :);


% 	output_combined(i).reward_distances_opto_control = reward_distances_opto_control{i, last_col_reward_distances_opto_control}(:, :);
% 	output_combined(i).reward_distances_opto_target = reward_distances_opto_target{i, last_col_reward_distances_opto_target}(:, :);

% 	output_combined(i).reward_distances_opto_control_short = reward_distances_opto_control_short{i, last_col_reward_distances_opto_control_short}(:, :);
% 	output_combined(i).reward_distances_opto_control_medium = reward_distances_opto_control_medium{i, last_col_reward_distances_opto_control_medium}(:, :);
% 	output_combined(i).reward_distances_opto_control_long = reward_distances_opto_control_long{i, last_col_reward_distances_opto_control_long}(:, :);

% 	output_combined(i).reward_distances_opto_target_short = reward_distances_opto_target_short{i, last_col_reward_distances_opto_target_short}(:, :);
% 	output_combined(i).reward_distances_opto_target_medium = reward_distances_opto_target_medium{i, last_col_reward_distances_opto_target_medium}(:, :);
% 	output_combined(i).reward_distances_opto_target_long = reward_distances_opto_target_long{i, last_col_reward_distances_opto_target_long}(:, :);

% 	output_combined(i).overall_go_latency_opto_control_1 = overall_go_latency_opto_control_1{i, last_col_overall_go_latency_opto_control_1}(:, :);
% 	output_combined(i).overall_go_latency_opto_target_1 = overall_go_latency_opto_target_1{i, last_col_overall_go_latency_opto_target_1}(:, :);

% 	output_combined(i).short_go_latency_opto_control_1 = short_go_latency_opto_control_1{i, last_col_short_go_latency_opto_control_1}(:, :);
% 	output_combined(i).short_go_latency_opto_target_1 = short_go_latency_opto_target_1{i, last_col_short_go_latency_opto_target_1}(:, :);
% 	output_combined(i).medium_go_latency_opto_control_1 = medium_go_latency_opto_control_1{i, last_col_medium_go_latency_opto_control_1}(:, :);
% 	output_combined(i).medium_go_latency_opto_target_1 = medium_go_latency_opto_target_1{i, last_col_medium_go_latency_opto_target_1}(:, :);
% 	output_combined(i).long_go_latency_opto_control_1 = long_go_latency_opto_control_1{i, last_col_long_go_latency_opto_control_1}(:, :);
% 	output_combined(i).long_go_latency_opto_target_1 = long_go_latency_opto_target_1{i, last_col_long_go_latency_opto_target_1}(:, :);

% 	output_combined(i).False_Start_Error_Prop_opto_control = output_combined(i).Incomplete_early_opto_control / output_combined(i).Total_Running_Trials_opto_control;
% 	output_combined(i).False_Start_Error_Prop_opto_target_1 = output_combined(i).Incomplete_early_opto_target_1 / output_combined(i).Total_Running_Trials_opto_target_1;
% 	output_combined(i).False_Start_Error_Prop_short_opto_control = output_combined(i).Incomplete_early_short_opto_control / output_combined(i).Total_Running_Trials_short_opto_control;
% 	output_combined(i).False_Start_Error_Prop_short_opto_target_1 = output_combined(i).Incomplete_early_short_opto_target_1 / output_combined(i).Total_Running_Trials_short_opto_target_1;
% 	output_combined(i).False_Start_Error_Prop_medium_opto_control = output_combined(i).Incomplete_early_medium_opto_control / output_combined(i).Total_Running_Trials_medium_opto_control;
% 	output_combined(i).False_Start_Error_Prop_medium_opto_target_1 = output_combined(i).Incomplete_early_medium_opto_target_1 / output_combined(i).Total_Running_Trials_medium_opto_target_1;
% 	output_combined(i).False_Start_Error_Prop_long_opto_control = output_combined(i).Incomplete_early_long_opto_control / output_combined(i).Total_Running_Trials_long_opto_control;
% 	output_combined(i).False_Start_Error_Prop_long_opto_target_1 = output_combined(i).Incomplete_early_long_opto_target_1 / output_combined(i).Total_Running_Trials_long_opto_target_1;

% 	output_combined(i).Early_Error_Ratio_Stopping_opto_control = output_combined(i).Incomplete_early_opto_control / (output_combined(i).Total_Running_Trials_opto_control - output_combined(i).Total_Running_Trials_Late_opto_control);
% 	output_combined(i).Early_Error_Ratio_Stopping_opto_target_1 = output_combined(i).Incomplete_early_opto_target_1 / (output_combined(i).Total_Running_Trials_opto_target_1 - output_combined(i).Total_Running_Trials_Late_opto_target_1);
% 	output_combined(i).Early_Error_Ratio_Stopping_short_opto_control = output_combined(i).Incomplete_early_short_opto_control / (output_combined(i).Total_Running_Trials_short_opto_control - output_combined(i).Total_Running_Trials_Late_short_opto_control);
% 	output_combined(i).Early_Error_Ratio_Stopping_short_opto_target_1 = output_combined(i).Incomplete_early_short_opto_target_1 / (output_combined(i).Total_Running_Trials_short_opto_target_1 - output_combined(i).Total_Running_Trials_Late_short_opto_target_1);
% 	output_combined(i).Early_Error_Ratio_Stopping_medium_opto_control = output_combined(i).Incomplete_early_medium_opto_control / (output_combined(i).Total_Running_Trials_medium_opto_control - output_combined(i).Total_Running_Trials_Late_medium_opto_control);
% 	output_combined(i).Early_Error_Ratio_Stopping_medium_opto_target_1 = output_combined(i).Incomplete_early_medium_opto_target_1 / (output_combined(i).Total_Running_Trials_medium_opto_target_1 - output_combined(i).Total_Running_Trials_Late_medium_opto_target_1);
% 	output_combined(i).Early_Error_Ratio_Stopping_long_opto_control = output_combined(i).Incomplete_early_long_opto_control / (output_combined(i).Total_Running_Trials_long_opto_control - output_combined(i).Total_Running_Trials_Late_long_opto_control);
% 	output_combined(i).Early_Error_Ratio_Stopping_long_opto_target_1 = output_combined(i).Incomplete_early_long_opto_target_1 / (output_combined(i).Total_Running_Trials_long_opto_target_1 - output_combined(i).Total_Running_Trials_Late_long_opto_target_1);

% 	output_combined(i).overall_early_restart_distances_opto_control_1 = overall_early_restart_distances_opto_control_1{i, last_col_overall_early_restart_distances_opto_control_1}(:, :);
% 	output_combined(i).overall_early_restart_distances_opto_target_1 = overall_early_restart_distances_opto_target_1{i, last_col_overall_early_restart_distances_opto_target_1}(:, :);

% 	output_combined(i).short_early_restart_distances_opto_control_1 = short_early_restart_distances_opto_control_1{i, last_col_short_early_restart_distances_opto_control_1}(:, :);
% 	output_combined(i).short_early_restart_distances_opto_target_1 = short_early_restart_distances_opto_target_1{i, last_col_short_early_restart_distances_opto_target_1}(:, :);

% 	output_combined(i).medium_early_restart_distances_opto_control_1 = medium_early_restart_distances_opto_control_1{i, last_col_medium_early_restart_distances_opto_control_1}(:, :);
% 	output_combined(i).medium_early_restart_distances_opto_target_1 = medium_early_restart_distances_opto_target_1{i, last_col_medium_early_restart_distances_opto_target_1}(:, :);

% 	output_combined(i).long_early_restart_distances_opto_control_1 = long_early_restart_distances_opto_control_1{i, last_col_long_early_restart_distances_opto_control_1}(:, :);
% 	output_combined(i).long_early_restart_distances_opto_target_1 = long_early_restart_distances_opto_target_1{i, last_col_long_early_restart_distances_opto_target_1}(:, :);



% % 	output_combined(i).optocont_short_repeat_blocks = optocont_short_repeat_blocks{i, last_col_optocont_short_repeat_blocks}(:, 1); % Only taking first col
% % 	output_combined(i).optotarg_short_repeat_blocks = optotarg_short_repeat_blocks{i, last_col_optotarg_short_repeat_blocks}(:, 1);
% % 	output_combined(i).optocont_medium_repeat_blocks = optocont_medium_repeat_blocks{i, last_col_optocont_medium_repeat_blocks}(:, 1);
% % 	output_combined(i).optotarg_medium_repeat_blocks = optotarg_medium_repeat_blocks{i, last_col_optotarg_medium_repeat_blocks}(:, 1);
% % 	output_combined(i).optocont_long_repeat_blocks = optocont_long_repeat_blocks{i, last_col_optocont_long_repeat_blocks}(:, 1);
% % 	output_combined(i).optotarg_long_repeat_blocks = optotarg_long_repeat_blocks{i, last_col_optotarg_long_repeat_blocks}(:, 1);

% 	% output_combined(i).precue_data_rawvel_opto_control = precue_data_rawvel_opto_control{i, last_col_precue_data_rawvel_opto_control}(:, 1);
% 	% output_combined(i).precue_data_rawvel_short_opto_control = precue_data_rawvel_short_opto_control{i, last_col_precue_data_rawvel_short_opto_control}(:, 1);
% 	% output_combined(i).precue_data_rawvel_medium_opto_control = precue_data_rawvel_medium_opto_control{i, last_col_precue_data_rawvel_medium_opto_control}(:, 1);
% 	% output_combined(i).precue_data_rawvel_long_opto_control = precue_data_rawvel_long_opto_control{i, last_col_precue_data_rawvel_long_opto_control}(:, 1);

% 	% output_combined(i).precue_data_rawvel_opto_target_1 = precue_data_rawvel_opto_target_1{i, last_col_precue_data_rawvel_opto_target_1}(:, 1);
% 	% output_combined(i).precue_data_rawvel_short_opto_target_1 = precue_data_rawvel_short_opto_target_1{i, last_col_precue_data_rawvel_short_opto_target_1}(:, 1);
% 	% output_combined(i).precue_data_rawvel_medium_opto_target_1 = precue_data_rawvel_medium_opto_target_1{i, last_col_precue_data_rawvel_medium_opto_target_1}(:, 1);
% 	% output_combined(i).precue_data_rawvel_long_opto_target_1 = precue_data_rawvel_long_opto_target_1{i, last_col_precue_data_rawvel_long_opto_target_1}(:, 1);


% 	output_combined(i).raw_vel_trace_all_short_opto_control = raw_vel_trace_all_short_opto_control{i, last_col_raw_vel_trace_all_short_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_all_short_opto_target_1 = raw_vel_trace_all_short_opto_target_1{i, last_col_raw_vel_trace_all_short_opto_target_1}(:, :);
% 	output_combined(i).raw_vel_trace_all_medium_opto_control = raw_vel_trace_all_medium_opto_control{i, last_col_raw_vel_trace_all_medium_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_all_medium_opto_target_1 = raw_vel_trace_all_medium_opto_target_1{i, last_col_raw_vel_trace_all_medium_opto_target_1}(:, :);
% 	output_combined(i).raw_vel_trace_all_long_opto_control = raw_vel_trace_all_long_opto_control{i, last_col_raw_vel_trace_all_long_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_all_long_opto_target_1 = raw_vel_trace_all_long_opto_target_1{i, last_col_raw_vel_trace_all_long_opto_target_1}(:, :);

% 	output_combined(i).raw_vel_trace_RW_short_opto_control = raw_vel_trace_RW_short_opto_control{i, last_col_raw_vel_trace_RW_short_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_RW_short_opto_target_1 = raw_vel_trace_RW_short_opto_target_1{i, last_col_raw_vel_trace_RW_short_opto_target_1}(:, :);
% 	output_combined(i).raw_vel_trace_RW_medium_opto_control = raw_vel_trace_RW_medium_opto_control{i, last_col_raw_vel_trace_RW_medium_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_RW_medium_opto_target_1 = raw_vel_trace_RW_medium_opto_target_1{i, last_col_raw_vel_trace_RW_medium_opto_target_1}(:, :);
% 	output_combined(i).raw_vel_trace_RW_long_opto_control = raw_vel_trace_RW_long_opto_control{i, last_col_raw_vel_trace_RW_long_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_RW_long_opto_target_1 = raw_vel_trace_RW_long_opto_target_1{i, last_col_raw_vel_trace_RW_long_opto_target_1}(:, :);

% 	output_combined(i).raw_vel_trace_PT_short_opto_control = raw_vel_trace_PT_short_opto_control{i, last_col_raw_vel_trace_PT_short_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_PT_short_opto_target_1 = raw_vel_trace_PT_short_opto_target_1{i, last_col_raw_vel_trace_PT_short_opto_target_1}(:, :);
% 	output_combined(i).raw_vel_trace_PT_medium_opto_control = raw_vel_trace_PT_medium_opto_control{i, last_col_raw_vel_trace_PT_medium_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_PT_medium_opto_target_1 = raw_vel_trace_PT_medium_opto_target_1{i, last_col_raw_vel_trace_PT_medium_opto_target_1}(:, :);
% 	output_combined(i).raw_vel_trace_PT_long_opto_control = raw_vel_trace_PT_long_opto_control{i, last_col_raw_vel_trace_PT_long_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_PT_long_opto_target_1 = raw_vel_trace_PT_long_opto_target_1{i, last_col_raw_vel_trace_PT_long_opto_target_1}(:, :);

% 	output_combined(i).raw_vel_trace_OR_short_opto_control = raw_vel_trace_OR_short_opto_control{i, last_col_raw_vel_trace_OR_short_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_OR_short_opto_target_1 = raw_vel_trace_OR_short_opto_target_1{i, last_col_raw_vel_trace_OR_short_opto_target_1}(:, :);
% 	output_combined(i).raw_vel_trace_OR_medium_opto_control = raw_vel_trace_OR_medium_opto_control{i, last_col_raw_vel_trace_OR_medium_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_OR_medium_opto_target_1 = raw_vel_trace_OR_medium_opto_target_1{i, last_col_raw_vel_trace_OR_medium_opto_target_1}(:, :);
% 	output_combined(i).raw_vel_trace_OR_long_opto_control = raw_vel_trace_OR_long_opto_control{i, last_col_raw_vel_trace_OR_long_opto_control}(:, :);
% 	output_combined(i).raw_vel_trace_OR_long_opto_target_1 = raw_vel_trace_OR_long_opto_target_1{i, last_col_raw_vel_trace_OR_long_opto_target_1}(:, :);

% 	output_combined(i).smooth_vel_trace_all_short_opto_control = smooth_vel_trace_all_short_opto_control{i, last_col_smooth_vel_trace_all_short_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_all_short_opto_target_1 = smooth_vel_trace_all_short_opto_target_1{i, last_col_smooth_vel_trace_all_short_opto_target_1}(:, :);
% 	output_combined(i).smooth_vel_trace_all_medium_opto_control = smooth_vel_trace_all_medium_opto_control{i, last_col_smooth_vel_trace_all_medium_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_all_medium_opto_target_1 = smooth_vel_trace_all_medium_opto_target_1{i, last_col_smooth_vel_trace_all_medium_opto_target_1}(:, :);
% 	output_combined(i).smooth_vel_trace_all_long_opto_control = smooth_vel_trace_all_long_opto_control{i, last_col_smooth_vel_trace_all_long_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_all_long_opto_target_1 = smooth_vel_trace_all_long_opto_target_1{i, last_col_smooth_vel_trace_all_long_opto_target_1}(:, :);

% 	output_combined(i).smooth_vel_trace_RW_short_opto_control = smooth_vel_trace_RW_short_opto_control{i, last_col_smooth_vel_trace_RW_short_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_RW_short_opto_target_1 = smooth_vel_trace_RW_short_opto_target_1{i, last_col_smooth_vel_trace_RW_short_opto_target_1}(:, :);
% 	output_combined(i).smooth_vel_trace_RW_medium_opto_control = smooth_vel_trace_RW_medium_opto_control{i, last_col_smooth_vel_trace_RW_medium_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_RW_medium_opto_target_1 = smooth_vel_trace_RW_medium_opto_target_1{i, last_col_smooth_vel_trace_RW_medium_opto_target_1}(:, :);
% 	output_combined(i).smooth_vel_trace_RW_long_opto_control = smooth_vel_trace_RW_long_opto_control{i, last_col_smooth_vel_trace_RW_long_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_RW_long_opto_target_1 = smooth_vel_trace_RW_long_opto_target_1{i, last_col_smooth_vel_trace_RW_long_opto_target_1}(:, :);

% 	output_combined(i).smooth_vel_trace_PT_short_opto_control = smooth_vel_trace_PT_short_opto_control{i, last_col_smooth_vel_trace_PT_short_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_PT_short_opto_target_1 = smooth_vel_trace_PT_short_opto_target_1{i, last_col_smooth_vel_trace_PT_short_opto_target_1}(:, :);
% 	output_combined(i).smooth_vel_trace_PT_medium_opto_control = smooth_vel_trace_PT_medium_opto_control{i, last_col_smooth_vel_trace_PT_medium_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_PT_medium_opto_target_1 = smooth_vel_trace_PT_medium_opto_target_1{i, last_col_smooth_vel_trace_PT_medium_opto_target_1}(:, :);
% 	output_combined(i).smooth_vel_trace_PT_long_opto_control = smooth_vel_trace_PT_long_opto_control{i, last_col_smooth_vel_trace_PT_long_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_PT_long_opto_target_1 = smooth_vel_trace_PT_long_opto_target_1{i, last_col_smooth_vel_trace_PT_long_opto_target_1}(:, :);

% 	output_combined(i).smooth_vel_trace_OR_short_opto_control = smooth_vel_trace_OR_short_opto_control{i, last_col_smooth_vel_trace_OR_short_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_OR_short_opto_target_1 = smooth_vel_trace_OR_short_opto_target_1{i, last_col_smooth_vel_trace_OR_short_opto_target_1}(:, :);
% 	output_combined(i).smooth_vel_trace_OR_medium_opto_control = smooth_vel_trace_OR_medium_opto_control{i, last_col_smooth_vel_trace_OR_medium_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_OR_medium_opto_target_1 = smooth_vel_trace_OR_medium_opto_target_1{i, last_col_smooth_vel_trace_OR_medium_opto_target_1}(:, :);
% 	output_combined(i).smooth_vel_trace_OR_long_opto_control = smooth_vel_trace_OR_long_opto_control{i, last_col_smooth_vel_trace_OR_long_opto_control}(:, :);
% 	output_combined(i).smooth_vel_trace_OR_long_opto_target_1 = smooth_vel_trace_OR_long_opto_target_1{i, last_col_smooth_vel_trace_OR_long_opto_target_1}(:, :);

% 	output_combined(i).pre_rw_lick_rates_opto_control = pre_rw_lick_rates_opto_control{i, last_col_pre_rw_lick_rates_opto_control}(:, :);
% 	output_combined(i).pre_rw_lick_rates_opto_target_1 = pre_rw_lick_rates_opto_target_1{i, last_col_pre_rw_lick_rates_opto_target_1}(:, :);

%end

output = output_combined;

end