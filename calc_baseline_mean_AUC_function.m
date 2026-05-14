function [baseline_mean_traces_of_interest, baseline_AUC_traces_of_interest, peak_amplitude_traces_of_interest_bl] = calc_baseline_mean_AUC_function(mean_traces_of_interest)
% Calculates the peak amplitudes and AUC for the outputs of select_photo_data

windowRange = [19:39]; % 500ms before sound
peak_windowRange = [40:55]; % after sound
%windowRange = [40:50]; % after sound
% 40 = 0ms from sound start
% 45 = 125ms from sound start
% 50 = 250ms from sound start
% 55 = 375ms from sound start
% 60 = 500ms from sound start
samplingInterval = 1/40; % 40Hz sampling rate
timeVec = linspace(0, (size(windowRange, 2) - 1)*samplingInterval, size(windowRange, 2)); % seconds from start of window


% Find trial by trial peaks and AUCs (hits)
	for i = 1:size(mean_traces_of_interest, 1)
		baseline_mean_traces_of_interest{i, 1} = mean_traces_of_interest{i, 4};
		baseline_AUC_traces_of_interest{i, 1} = mean_traces_of_interest{i, 4};
		peak_amplitude_traces_of_interest_bl{i, 1} = mean_traces_of_interest{i, 4};

		try
			baseline_mean_traces_of_interest{i, 2} = mean(mean_traces_of_interest{i, 6}(:, windowRange), 2);
			baseline_AUC_traces_of_interest{i, 2} = trapz(timeVec, mean_traces_of_interest{i, 6}(:, windowRange), 2);
            peak_amplitude_traces_of_interest_bl{i, 2} = max(mean_traces_of_interest{i, 6}(:, peak_windowRange), [], 2);

		end
	end

	for i = (size(mean_traces_of_interest, 1) + 1):(size(mean_traces_of_interest, 1)*2)
		baseline_mean_traces_of_interest{i, 1} = mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 7};	
		baseline_AUC_traces_of_interest{i, 1} = mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 7};	
		peak_amplitude_traces_of_interest_bl{i, 1} = mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 7};

		try
			baseline_mean_traces_of_interest{i, 2} = mean(mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}(:, windowRange), 2);
			baseline_AUC_traces_of_interest{i, 2} = trapz(timeVec, mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}(:, windowRange), 2);
		    peak_amplitude_traces_of_interest_bl{i, 2} = max(mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}(:, peak_windowRange), [], 2);
		end
	end

% Calculate Means (hits)
	for i = 1:size(baseline_AUC_traces_of_interest, 1)

		baseline_mean_traces_of_interest{i, 3} = mean(baseline_mean_traces_of_interest{i, 2}, 'omitnan');
		baseline_AUC_traces_of_interest{i, 3} = mean(baseline_AUC_traces_of_interest{i, 2}, 'omitnan');
        peak_amplitude_traces_of_interest_bl{i, 3} = mean(peak_amplitude_traces_of_interest_bl{i, 2}, 'omitnan');

	end


end