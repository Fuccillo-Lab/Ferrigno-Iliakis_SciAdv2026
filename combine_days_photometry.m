function output_combined = combine_days_photometry(output)
% Takes output array with multiple days of photoemtry data and combines the
% multi-session data for each animal

	data = array2table(output, 'VariableNames',{'animalID','trial_data','means'});
	%data = sortrows(data,'phase','ascend');

	anID = findgroups(string(data.animalID));


n_groups_ID = max(anID);
n_groups_ID_list = [1:n_groups_ID];

	for i = 1:(n_groups_ID)

		anID_{i, 1} = find(anID == n_groups_ID_list(1, i));
		anID_leg(i, 1) = data.animalID(anID_{i, 1}(1,1), 1);

    end

    	% For outputs that can just be easily added together across days

			for i = 1:size(anID_, 1)

		            % Combine arrays
            
			            for p = 1:size(anID_{i, :}, 1)
            
				            if size(data.trial_data{anID_{i, :}(p, 1), :}, 1) > 0
					            trial_data{i, p} = data.trial_data{anID_{i, :}(p, 1), :};
					            trial_data_sizes(i, p) = size(data.trial_data{anID_{i, :}(p, 1), :}, 1); % need sizes to put session divisions in figure
				            else
					            trial_data{i, p} = [];
					            trial_data_sizes(i, p) = NaN;
                            end

                        end
                        
            end


 			last_col_trial_data = (size(trial_data, 2) + 1);

for i = 1:size(anID_, 1)

    for j = 1:(last_col_trial_data - 1)
        if j == 1
			trial_data{i, last_col_trial_data} = [];
    		trial_data{i, last_col_trial_data} = [trial_data{i, last_col_trial_data}; trial_data{i, j};];
        else
			trial_data{i, last_col_trial_data} = [trial_data{i, last_col_trial_data}; trial_data{i, j};];
        end

	data_sizes_trial_data(i, 1) = size(trial_data{i, last_col_trial_data}, 1);

    end

output_combined(i).animalID = string(anID_leg(i));
output_combined(i).trial_data = trial_data{i, last_col_trial_data}(:, :);
output_combined(i).mean = mean(output_combined(i).trial_data);

end



end