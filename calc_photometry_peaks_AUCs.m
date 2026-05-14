window = [40:55]; 
% 40 = 0ms from sound start
% 45 = 125ms from sound start
% 50 = 250ms from sound start
% 55 = 375ms from sound start
% 60 = 500ms from sound start
samplingInterval = 1/40; % 40Hz sampling rate
timeVec = (window - 1) * samplingInterval;



% Hits
	% Find trial by trial peaks and AUCs (hits)
		for i = 1:size(mean_hit_traces, 1)
			try
				peak_amplitude_hit_trials{i, 1} = mean_hit_traces{i, 1};
				peak_amplitude_hit_trials{i, 2} = max(mean_hit_traces{i, 5}(:, window), [], 2);

				AUC_hit_trials{i, 1} = mean_hit_traces{i, 1};
				AUC_hit_trials{i, 2} = trapz(timeVec, mean_hit_traces{i, 5}(:, window), 2);

			end
		end

		for i = (size(mean_hit_traces, 1) + 1):(size(mean_hit_traces, 1)*2)
			try
				
				peak_amplitude_hit_trials{i, 1} = mean_hit_traces{i - size(mean_hit_traces, 1), 1};
				peak_amplitude_hit_trials{i, 2} = max(mean_hit_traces{i - size(mean_hit_traces, 1), 7}(:, window), [], 2);

				AUC_hit_trials{i, 1} = mean_hit_traces{i - size(mean_hit_traces, 1), 1};
				AUC_hit_trials{i, 2} = trapz(timeVec, mean_hit_traces{i - size(mean_hit_traces, 1), 7}(:, window), 2);

			end
		end

	% Calculate Means (hits)
		for i = 1:size(AUC_hit_trials, 1)

		peak_amplitude_hit_trials{i, 3} = mean(peak_amplitude_hit_trials{i, 2});
		AUC_hit_trials{i, 3} = mean(AUC_hit_trials{i, 2});

		end

% crs
	% Find trial by trial peaks and AUCs (crs)
		for i = 1:size(mean_cr_traces, 1)
			try

				peak_amplitude_cr_trials{i, 1} = mean_cr_traces{i, 1};
				peak_amplitude_cr_trials{i, 2} = max(mean_cr_traces{i, 5}(:, window), [], 2);

				AUC_cr_trials{i, 1} = mean_cr_traces{i, 1};
				AUC_cr_trials{i, 2} = trapz(timeVec, mean_cr_traces{i, 5}(:, window), 2);

			end
		end

		for i = (size(mean_cr_traces, 1) + 1):(size(mean_cr_traces, 1)*2)
			try
				peak_amplitude_cr_trials{i, 1} = mean_cr_traces{i - size(mean_cr_traces, 1), 1};
				peak_amplitude_cr_trials{i, 2} = max(mean_cr_traces{i - size(mean_cr_traces, 1), 7}(:, window), [], 2);

				AUC_cr_trials{i, 1} = mean_cr_traces{i - size(mean_cr_traces, 1), 1};
				AUC_cr_trials{i, 2} = trapz(timeVec, mean_cr_traces{i - size(mean_cr_traces, 1), 7}(:, window), 2);

			end
		end

	% Calculate Means (crs)
		for i = 1:size(AUC_cr_trials, 1)

		peak_amplitude_cr_trials{i, 3} = mean(peak_amplitude_cr_trials{i, 2});
		AUC_cr_trials{i, 3} = mean(AUC_cr_trials{i, 2});

		end

% fas
	% Find trial by trial peaks and AUCs (fas)
		for i = 1:size(mean_fa_traces, 1)
			try
				peak_amplitude_fa_trials{i, 1} = mean_fa_traces{i, 1};
				peak_amplitude_fa_trials{i, 2} = max(mean_fa_traces{i, 5}(:, window), [], 2);

				AUC_fa_trials{i, 1} = mean_fa_traces{i, 1};
				AUC_fa_trials{i, 2} = trapz(timeVec, mean_fa_traces{i, 5}(:, window), 2);

			end
		end

		for i = (size(mean_fa_traces, 1) + 1):(size(mean_fa_traces, 1)*2)
			try
				peak_amplitude_fa_trials{i, 1} = mean_fa_traces{i - size(mean_fa_traces, 1), 1};
				peak_amplitude_fa_trials{i, 2} = max(mean_fa_traces{i - size(mean_fa_traces, 1), 7}(:, window), [], 2);

				AUC_fa_trials{i, 1} = mean_fa_traces{i - size(mean_fa_traces, 1), 1};
				AUC_fa_trials{i, 2} = trapz(timeVec, mean_fa_traces{i - size(mean_fa_traces, 1), 7}(:, window), 2);

			end
		end

	% Calculate Means (fas)
		for i = 1:size(AUC_fa_trials, 1)

		peak_amplitude_fa_trials{i, 3} = mean(peak_amplitude_fa_trials{i, 2});
		AUC_fa_trials{i, 3} = mean(AUC_fa_trials{i, 2});

		end
