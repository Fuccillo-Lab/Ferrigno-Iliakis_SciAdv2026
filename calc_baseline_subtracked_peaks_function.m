function [baseline_subtracted_peak_amplitude_traces_of_interest] = calc_baseline_subtracked_peaks_function(peak_amplitude_traces_of_interest, baseline_mean_traces_of_interest)
% Takes the peak amplitudes for each trial and subtracts the average
% pre-sound baseline from that trial

    for i = 1:size(peak_amplitude_traces_of_interest, 1)
    
	    if peak_amplitude_traces_of_interest{i, 1} == baseline_mean_traces_of_interest{i, 1}
		    baseline_subtracted_peak_amplitude_traces_of_interest{i, 1} = peak_amplitude_traces_of_interest{i, 1};
		    baseline_subtracted_peak_amplitude_traces_of_interest{i, 2} = peak_amplitude_traces_of_interest{i, 2} - baseline_mean_traces_of_interest{i, 2};
		    baseline_subtracted_peak_amplitude_traces_of_interest{i, 3} = mean(baseline_subtracted_peak_amplitude_traces_of_interest{i, 2}, 'omitnan');
    
	    end
    
    end

end