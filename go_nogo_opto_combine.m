% Formats go/nogo opto data by combining multiple days and calculating d primes

%combined_output = combine_days(viral_arch);
%combined_output = combine_days(output2);
combined_output = combine_days(output_CreNeg_post_sound_stim);

for i = 1:size(combined_output, 2)

    combined_output(i).Hit_Rate_Light_Off = combined_output(i).Hits_Light_Off / combined_output(i).Total_Go_Sound_Light_Off;
    combined_output(i).Hit_Rate_Light_On = combined_output(i).Hits_Light_On / combined_output(i).Total_Go_Sound_Light_On;

    combined_output(i).FA_Rate_Light_Off = combined_output(i).FAs_Light_Off / combined_output(i).Total_NoGo_Sound_Light_Off;
    combined_output(i).FA_Rate_Light_On = combined_output(i).FAs_Light_On / combined_output(i).Total_NoGo_Sound_Light_On;

    if combined_output(i).Hit_Rate_Light_Off == 1
        dprime_hr_Light_Off = 1-1/(2*combined_output(i).Total_Go_Sound_Light_Off);
    elseif combined_output(i).Hit_Rate_Light_Off == 0
        dprime_hr_Light_Off = 0 + 1/(2*combined_output(i).Total_Go_Sound_Light_Off);
    else
        dprime_hr_Light_Off = combined_output(i).Hit_Rate_Light_Off;
    end

    if combined_output(i).FA_Rate_Light_Off == 0
        dprime_fa_Light_Off = 0 + 1/(2*combined_output(i).Total_NoGo_Sound_Light_Off);
    elseif combined_output(i).FA_Rate_Light_Off == 1
        dprime_fa_Light_Off = 1-1/(2*combined_output(i).Total_NoGo_Sound_Light_Off);
    else
        dprime_fa_Light_Off = combined_output(i).FA_Rate_Light_Off;
    end


    if combined_output(i).Hit_Rate_Light_On == 1
        dprime_hr_Light_On = 1-1/(2*combined_output(i).Total_Go_Sound_Light_On);
    elseif combined_output(i).Hit_Rate_Light_On == 0
        dprime_hr_Light_On = 0 + 1/(2*combined_output(i).Total_Go_Sound_Light_On);
    else
        dprime_hr_Light_On = combined_output(i).Hit_Rate_Light_On;
    end

    if combined_output(i).FA_Rate_Light_On == 0
        dprime_fa_Light_On = 0 + 1/(2*combined_output(i).Total_NoGo_Sound_Light_On);
    elseif combined_output(i).FA_Rate_Light_On == 1
        dprime_fa_Light_On = 1-1/(2*combined_output(i).Total_NoGo_Sound_Light_On);
    else
        dprime_fa_Light_On = combined_output(i).FA_Rate_Light_On;
    end

    [d_off, c_off] = dprime_simple(dprime_hr_Light_Off, dprime_fa_Light_Off);
    [d_on, c_on] = dprime_simple(dprime_hr_Light_On, dprime_fa_Light_On);

    combined_output(i).D_Prime_Light_Off = d_off;
    combined_output(i).D_Prime_Light_On = d_on;   

    combined_output(i).Response_Bias_Light_Off = c_off;
    combined_output(i).Response_Bias_Light_On = c_on;


    combined_output(i).mean_RW_latencies_light_off = mean(combined_output(i).RW_latencies_light_off, 'omitnan');
    combined_output(i).mean_RW_latencies_light_on = mean(combined_output(i).RW_latencies_light_on, 'omitnan');

    combined_output(i).mean_FA_latencies_light_off = mean(combined_output(i).FA_latencies_light_off, 'omitnan');
    combined_output(i).mean_FA_latencies_light_on = mean(combined_output(i).FA_latencies_light_on, 'omitnan');

    combined_output(i).std_RW_latencies_light_off = std(combined_output(i).RW_latencies_light_off, 'omitnan');
    combined_output(i).std_RW_latencies_light_on = std(combined_output(i).RW_latencies_light_on, 'omitnan');

    combined_output(i).std_FA_latencies_light_off = std(combined_output(i).FA_latencies_light_off, 'omitnan');
    combined_output(i).std_FA_latencies_light_on = std(combined_output(i).FA_latencies_light_on, 'omitnan');

    combined_output(i).n_RW_latencies_light_off = sum(combined_output(i).RW_latencies_light_off > 0);
    combined_output(i).n_RW_latencies_light_on = sum(combined_output(i).RW_latencies_light_on > 0);

    combined_output(i).n_FA_latencies_light_off = sum(combined_output(i).FA_latencies_light_off > 0);
    combined_output(i).n_FA_latencies_light_on = sum(combined_output(i).FA_latencies_light_on > 0);


    combined_output(i).median_RW_latencies_light_off = median(combined_output(i).RW_latencies_light_off, 'omitnan');
    combined_output(i).median_RW_latencies_light_on = median(combined_output(i).RW_latencies_light_on, 'omitnan');

    combined_output(i).median_FA_latencies_light_off = median(combined_output(i).FA_latencies_light_off, 'omitnan');
    combined_output(i).median_FA_latencies_light_on = median(combined_output(i).FA_latencies_light_on, 'omitnan');



end