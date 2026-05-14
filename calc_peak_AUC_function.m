function [peak_amplitude_traces_of_interest, AUC_traces_of_interest, peak_latency_traces_of_interest, slope_traces_of_interest] = calc_peak_AUC_function(mean_traces_of_interest)
% Calculates the peak amplitudes and AUC for the outputs of select_photo_data

%windowRange = [24:39]; % before sound
windowRange = [40:55]; % after sound
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
		peak_amplitude_traces_of_interest{i, 1} = mean_traces_of_interest{i, 4};
		AUC_traces_of_interest{i, 1} = mean_traces_of_interest{i, 4};
		peak_latency_traces_of_interest{i, 1} = mean_traces_of_interest{i, 4};
		slope_traces_of_interest{i, 1} = mean_traces_of_interest{i, 4};
		try
			peak_amplitude_traces_of_interest{i, 2} = max(mean_traces_of_interest{i, 6}(:, windowRange), [], 2);
			AUC_traces_of_interest{i, 2} = trapz(timeVec, mean_traces_of_interest{i, 6}(:, windowRange), 2);

			for p = 1:size(mean_traces_of_interest{i, 6}, 1)
				peak_latency_traces_of_interest{i, 2}(p, 1) = (find(mean_traces_of_interest{i, 6}(p, windowRange) == max(mean_traces_of_interest{i, 6}(p, windowRange))) - 1) * 25; % each bin is 25 ms from the start of the windowRange
				
				% Slope to Peak calculation
				if peak_latency_traces_of_interest{i, 2}(p, 1) == 0
    				slope_traces_of_interest{i, 2}(p, 1) = NaN;  % or 0, depending on your philosophy
    			else
    				slope_traces_of_interest{i, 2}(p, 1) = peak_amplitude_traces_of_interest{i, 2}(p, 1) / (peak_latency_traces_of_interest{i, 2}(p, 1) / 1000); % using latency in s
				end

				% % Slope calculation by linear fit
				% s = polyfit(timeVec, mean_traces_of_interest{i, 6}(p, windowRange), 1); 
				% slope_traces_of_interest{i, 2}(p, 1) = s(1);
				% clear s

				% % Slope calculation by Maximum Derivative
				% slope_traces_of_interest{i, 2}(p, 1) = max(diff(mean_traces_of_interest{i, 6}(p, windowRange), 1, 2), [], 2) / samplingInterval;
			end
		end
	end

	for i = (size(mean_traces_of_interest, 1) + 1):(size(mean_traces_of_interest, 1)*2)
		peak_amplitude_traces_of_interest{i, 1} = mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 7};	
		AUC_traces_of_interest{i, 1} = mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 7};	
		peak_latency_traces_of_interest{i, 1} = mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 7};
		slope_traces_of_interest{i, 1} = mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 7};					
		try
			peak_amplitude_traces_of_interest{i, 2} = max(mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}(:, windowRange), [], 2);
			AUC_traces_of_interest{i, 2} = trapz(timeVec, mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}(:, windowRange), 2);


			for p = 1:size(mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}, 1)
				peak_latency_traces_of_interest{i, 2}(p, 1) = (find(mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}(p, windowRange) == max(mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}(p, windowRange))) - 1) * 25; % each bin is 25 ms from the start of the windowRange

				% Slope to Peak calculation
				if peak_latency_traces_of_interest{i, 2}(p, 1) == 0
    				slope_traces_of_interest{i, 2}(p, 1) = NaN;  % or 0, depending on your philosophy
    			else
    				slope_traces_of_interest{i, 2}(p, 1) = peak_amplitude_traces_of_interest{i, 2}(p, 1) / (peak_latency_traces_of_interest{i, 2}(p, 1) / 1000); % using latency in s
				end

				% s = polyfit(timeVec, mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}(p, windowRange), 1); 
				% slope_traces_of_interest{i, 2}(p, 1) = s(1);
				% clear s  

				% % Slope calculation by Maximum Derivative
				% slope_traces_of_interest{i, 2}(p, 1) = max(diff(mean_traces_of_interest{i - size(mean_traces_of_interest, 1), 9}(p, windowRange), 1, 2), [], 2) / samplingInterval;
			end			
		end
	end

% Calculate Means (hits)
	for i = 1:size(AUC_traces_of_interest, 1)

		peak_amplitude_traces_of_interest{i, 3} = mean(peak_amplitude_traces_of_interest{i, 2}, 'omitnan');
		AUC_traces_of_interest{i, 3} = mean(AUC_traces_of_interest{i, 2}, 'omitnan');
		peak_latency_traces_of_interest{i, 3} = mean(peak_latency_traces_of_interest{i, 2}, 'omitnan');
		slope_traces_of_interest{i, 3} = mean(slope_traces_of_interest{i, 2}, 'omitnan');

	end


end