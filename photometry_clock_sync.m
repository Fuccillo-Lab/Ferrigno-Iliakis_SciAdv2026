function output = photometry_clock_sync(behavior_TTLs, photometry_TTLs, behavioral_data_file, box_number, pervasive_errors, short_TTLs)

% Align behavioral timestamps to photometry clock

    
    if short_TTLs == false
    fit_index = [1:size(behavior_TTLs, 1)]';
    else
    fit_index = [1:size(photometry_TTLs, 1)]';    
    end

    if size(pervasive_errors, 1) > 5
        pervasive_errors_ind = (pervasive_errors - 1);
        pervasive_errors_ind = [(pervasive_errors_ind(1,1) - 1); pervasive_errors_ind; (pervasive_errors_ind(end,1) + 1)];
        fit_index = setxor(fit_index, pervasive_errors_ind);
    end

        % Edit box 1 behavior times

	        % Fit the transformation
	                %coeffs = polyfit((behavior_TTLs ./ 1000000), photometry_TTLs, 1);
            coeffs = polyfit((behavior_TTLs(fit_index, :) ./ 1000000), photometry_TTLs(fit_index, :), 1);
	        a = coeffs(1); % Scaling factor
	        b = coeffs(2); % Offset

	        % Transform behavioral timestamps
	        behavior_times = (behavioral_data_file(2:end, 1) ./ 1000000); % All behavioral timestamps
	        photo_aligned_times = a * behavior_times + b;


	        behavior_data_new = behavioral_data_file(:, :);
	        behavior_data_new(2:end, 1) = photo_aligned_times;

	        new_behavior_ttls = behavior_data_new(find(behavior_data_new(:, 2) == 9), 1);


	        % Data validation metrics

		        behavior_ttls_comp(:, 1) = diff(behavior_TTLs) / 1000000;
		        behavior_ttls_comp(:, 2) = diff(new_behavior_ttls);
		        behavior_ttls_comp(:, 3) = abs(behavior_ttls_comp(:, 1) - behavior_ttls_comp(:, 2));
            
            if box_number == 1
                output.behavioral_data_animal1_photoclock = behavior_data_new;
                output.behavioral_ttls_animal1_photoclock = new_behavior_ttls;
		        output.fit_coefficents_box1 = coeffs;
		        output.mean_fitted_ttl_difference_box1 = mean(behavior_ttls_comp(:, 3));
		        output.std_fitted_ttl_difference_box1 = std(behavior_ttls_comp(:, 3));
		        output.max_fitted_ttl_difference_box1 = max(behavior_ttls_comp(:, 3));
            elseif box_number == 4
                output.behavioral_data_animal2_photoclock = behavior_data_new;
                output.behavioral_ttls_animal2_photoclock = new_behavior_ttls;
 		        output.fit_coefficents_box4 = coeffs;
		        output.mean_fitted_ttl_difference_box4 = mean(behavior_ttls_comp(:, 3));
		        output.std_fitted_ttl_difference_box4 = std(behavior_ttls_comp(:, 3));
		        output.max_fitted_ttl_difference_box4 = max(behavior_ttls_comp(:, 3));
            end
end