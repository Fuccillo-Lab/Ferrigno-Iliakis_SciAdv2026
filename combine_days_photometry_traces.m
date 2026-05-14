function output_combined = combine_days_photometry_traces(output)
% Takes output array with multiple days of photoemtry data and combines the
% multi-session data for each animal

	data = array2table(output, 'VariableNames',{'animalID', 'date', 'time', 'fiber1_ID', 'fiber1_mean', 'fiber1_trial_data', 'fiber2_ID', 'fiber2_mean', 'fiber2_trial_data'});
	%data = sortrows(data,'phase','ascend');

	anID = findgroups(string(data.animalID));


n_groups_ID = max(anID);
n_groups_ID_list = [1:n_groups_ID];

	for i = 1:(n_groups_ID)

		anID_{i, 1} = find(anID == n_groups_ID_list(1, i));
		anID_leg(i, 1) = data.animalID(anID_{i, 1}(1,1), 1);

    end

    	% Get fiber 1 data together

			for i = 1:size(anID_, 1)

		            % Combine arrays
            
			            for p = 1:size(anID_{i, :}, 1)
            
				            if size(data.fiber1_trial_data{anID_{i, :}(p, 1), :}, 1) > 0
				            	fiber1_ID{i, p} = data.fiber1_ID{anID_{i, :}(p, 1), :};
					            fiber1_trial_data{i, p} = data.fiber1_trial_data{anID_{i, :}(p, 1), :};
					            fiber1_trial_data_sizes(i, p) = size(data.fiber1_trial_data{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
				            else
					            fiber1_ID{i, p} = [];
					            fiber1_trial_data{i, p} = [];
					            fiber1_trial_data_sizes(i, p) = NaN;
                            end

                        end
                        
            end


 			last_col_fiber1_trial_data = (size(fiber1_trial_data, 2) + 1);

			for i = 1:size(anID_, 1)

			    for j = 1:(last_col_fiber1_trial_data - 1)
			        if j == 1
						fiber1_trial_data{i, last_col_fiber1_trial_data} = [];
			    		fiber1_trial_data{i, last_col_fiber1_trial_data} = [fiber1_trial_data{i, last_col_fiber1_trial_data}; fiber1_trial_data{i, j};];
			        else
						fiber1_trial_data{i, last_col_fiber1_trial_data} = [fiber1_trial_data{i, last_col_fiber1_trial_data}; fiber1_trial_data{i, j};];
			        end

				data_sizes_fiber1_trial_data(i, 1) = size(fiber1_trial_data{i, last_col_fiber1_trial_data}, 1);

			    end

			output_combined_fiber1(i).animalID = string(anID_leg(i));
			output_combined_fiber1(i).fiberID = string(fiber1_ID(i, 1))
			output_combined_fiber1(i).trial_data = fiber1_trial_data{i, last_col_fiber1_trial_data}(:, :);
			output_combined_fiber1(i).mean = mean(output_combined_fiber1(i).trial_data);

			end


		% Get fiber 2 data together

			for i = 1:size(anID_, 1)

		            % Combine arrays
            
			            for p = 1:size(anID_{i, :}, 1)
            
				            if size(data.fiber2_trial_data{anID_{i, :}(p, 1), :}, 1) > 0
				            	fiber2_ID{i, p} = data.fiber2_ID{anID_{i, :}(p, 1), :};
					            fiber2_trial_data{i, p} = data.fiber2_trial_data{anID_{i, :}(p, 1), :};
					            fiber2_trial_data_sizes(i, p) = size(data.fiber2_trial_data{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
				            else
					            fiber2_ID{i, p} = [];
					            fiber2_trial_data{i, p} = [];
					            fiber2_trial_data_sizes(i, p) = NaN;
                            end

                        end
                        
            end


 			last_col_fiber2_trial_data = (size(fiber2_trial_data, 2) + 1);

			for i = 1:size(anID_, 1)

			    for j = 1:(last_col_fiber2_trial_data - 1)
			        if j == 1
						fiber2_trial_data{i, last_col_fiber2_trial_data} = [];
			    		fiber2_trial_data{i, last_col_fiber2_trial_data} = [fiber2_trial_data{i, last_col_fiber2_trial_data}; fiber2_trial_data{i, j};];
			        else
						fiber2_trial_data{i, last_col_fiber2_trial_data} = [fiber2_trial_data{i, last_col_fiber2_trial_data}; fiber2_trial_data{i, j};];
			        end

				data_sizes_fiber2_trial_data(i, 1) = size(fiber2_trial_data{i, last_col_fiber2_trial_data}, 1);

			    end

			output_combined_fiber2(i).animalID = string(anID_leg(i));
			output_combined_fiber2(i).fiberID = string(fiber2_ID(i, 1))
			output_combined_fiber2(i).trial_data = fiber2_trial_data{i, last_col_fiber2_trial_data}(:, :);
			output_combined_fiber2(i).mean = mean(output_combined_fiber2(i).trial_data);

			end

output_combined = [output_combined_fiber1 output_combined_fiber2];

end