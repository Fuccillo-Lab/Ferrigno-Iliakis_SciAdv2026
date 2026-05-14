function [output] = photometry_go_nogo_analysis_funct(data_animal1, data_animal2) %filename is the "c:\path", '9-7-21' and 'number'
% Performance analysis for go no-go task photometry

% Start up Animal 1

if size(data_animal1, 1) > 0
    output.session_duration_animal1 = (data_animal1(end, 1) - data_animal1(2, 1))/60;  

    
        go_sound_start_index_animal1 = find(data_animal1(:, 2) == 20);
        go_sound_start_timestamps_animal1 = data_animal1(go_sound_start_index_animal1, 1);

        nogo_sound_start_index_animal1 = find(data_animal1(:, 2) == 22);
        nogo_sound_start_timestamps_animal1 = data_animal1(nogo_sound_start_index_animal1, 1);

        reward_dispensed_index_animal1 = find(data_animal1(:, 2) == 2);
        reward_dispensed_timestamps_animal1 = data_animal1(reward_dispensed_index_animal1, 1);    

        hit_index_animal1 = reward_dispensed_index_animal1;
        hit_timestamps_animal1 = reward_dispensed_timestamps_animal1;

        miss_index_animal1 = find(data_animal1(:, 2) == 11);
        miss_timestamps_animal1 = data_animal1(miss_index_animal1, 1);

        cr_index_animal1 = find(data_animal1(:, 2) == 12);
        cr_timestamps_animal1 = data_animal1(cr_index_animal1, 1);        

        fa_index_animal1 = find(data_animal1(:, 2) == 13);
        fa_timestamps_animal1 = data_animal1(fa_index_animal1, 1);

        trial_start_index_animal1 =  find(data_animal1(:, 2) == 9);
        trial_start_timestamps_animal1 = data_animal1(trial_start_index_animal1, 1); 
        
        restart_index_animal1 =  find(data_animal1(:, 2) == 10);
        restart_timestamps_animal1 = data_animal1(restart_index_animal1, 1); 
        
% Obtain hit go sound timestamps

    if ~isempty(hit_timestamps_animal1)
        for i = 1:length(hit_timestamps_animal1)

            hit_go_sound_start_index_animal1(i, 1) = find(data_animal1(:, 2) == 20 & data_animal1(:, 1) > (hit_timestamps_animal1(i, 1) - 1.2) & data_animal1(:, 1) < hit_timestamps_animal1(i, 1)); 
            hit_go_sound_timestamps_animal1(i, 1) = data_animal1(hit_go_sound_start_index_animal1(i, 1), 1);

        end
    else
        hit_timestamps_animal1 = [];
        hit_go_sound_timestamps_animal1 = [];
    end


% Obtain miss go sound timestamps
    if ~isempty(miss_timestamps_animal1)
        for i = 1:length(miss_timestamps_animal1)

            miss_go_sound_start_index_animal1(i, 1) = find(data_animal1(:, 2) == 20 & data_animal1(:, 1) > (miss_timestamps_animal1(i, 1) - 1.2) & data_animal1(:, 1) < miss_timestamps_animal1(i, 1)); 
            miss_go_sound_timestamps_animal1(i, 1) = data_animal1(miss_go_sound_start_index_animal1(i, 1), 1);

        end
    else
        miss_timestamps_animal1 = [];
        miss_go_sound_timestamps_animal1 = [];
    end

% Obtain cr nogo sound timestamps
    if ~isempty(cr_timestamps_animal1)
        for i = 1:length(cr_timestamps_animal1)

            cr_nogo_sound_start_index_animal1(i, 1) = find(data_animal1(:, 2) == 22 & data_animal1(:, 1) > (cr_timestamps_animal1(i, 1) - 1.2) & data_animal1(:, 1) < cr_timestamps_animal1(i, 1)); 
            cr_nogo_sound_timestamps_animal1(i, 1) = data_animal1(cr_nogo_sound_start_index_animal1(i, 1), 1);

        end
    else
        cr_timestamps_animal1 = [];
        cr_nogo_sound_timestamps_animal1 = [];
    end
    
% Obtain fa nogo sound timestamps
    if ~isempty(fa_timestamps_animal1)
        for i = 1:length(fa_timestamps_animal1)

            fa_nogo_sound_start_index_animal1(i, 1) = find(data_animal1(:, 2) == 22 & data_animal1(:, 1) > (fa_timestamps_animal1(i, 1) - 1.2) & data_animal1(:, 1) < fa_timestamps_animal1(i, 1)); 
            fa_nogo_sound_timestamps_animal1(i, 1) = data_animal1(fa_nogo_sound_start_index_animal1(i, 1), 1);

        end
    else
        fa_timestamps_animal1 = [];
        fa_nogo_sound_timestamps_animal1 = [];
    end


output.go_sound_start_timestamps_animal1 = go_sound_start_timestamps_animal1;
output.nogo_sound_start_timestamps_animal1 = nogo_sound_start_timestamps_animal1;
output.reward_dispensed_timestamps_animal1 = reward_dispensed_timestamps_animal1;
output.hit_timestamps_animal1 = hit_timestamps_animal1;
output.miss_timestamps_animal1 = miss_timestamps_animal1;
output.cr_timestamps_animal1 = cr_timestamps_animal1;
output.fa_timestamps_animal1 = fa_timestamps_animal1;
output.trial_start_timestamps_animal1 = trial_start_timestamps_animal1;
output.restart_timestamps_animal1 = restart_timestamps_animal1;
output.hit_go_sound_timestamps_animal1 = hit_go_sound_timestamps_animal1;
output.miss_go_sound_timestamps_animal1 = miss_go_sound_timestamps_animal1;
output.cr_nogo_sound_timestamps_animal1 = cr_nogo_sound_timestamps_animal1;
output.fa_nogo_sound_timestamps_animal1 = fa_nogo_sound_timestamps_animal1;

output.RW_Per_Min_animal1 = size(hit_timestamps_animal1, 1) / output.session_duration_animal1;

output.Hit_Rate_animal1 = size(hit_timestamps_animal1, 1) / (size(hit_timestamps_animal1, 1) + size(miss_timestamps_animal1, 1));
output.FA_Rate_animal1 = size(fa_timestamps_animal1, 1) / (size(fa_timestamps_animal1, 1) + size(cr_timestamps_animal1, 1));

if output.Hit_Rate_animal1 == 1
    dprime_hr = 1-1/(2*(size(hit_timestamps_animal1, 1) + size(miss_timestamps_animal1, 1)));
elseif output.Hit_Rate_animal1 == 0
    dprime_hr = 0 + 1/(2*(size(hit_timestamps_animal1, 1) + size(miss_timestamps_animal1, 1)));
else
    dprime_hr = output.Hit_Rate_animal1;
end

if output.FA_Rate_animal1 == 0
    dprime_fa = 0 + 1/(2*(size(fa_timestamps_animal1, 1) + size(cr_timestamps_animal1, 1)));
elseif output.FA_Rate_animal1 == 1
    dprime_fa = 1-1/(2*(size(fa_timestamps_animal1, 1) + size(cr_timestamps_animal1, 1)));
else
    dprime_fa = output.FA_Rate_animal1;
end

[d, c] = dprime_simple(dprime_hr, dprime_fa);

output.D_Prime_animal1 = d;
output.Response_Bias_animal1 = c;

output.Restart_Rate_animal1 = size(restart_timestamps_animal1, 1) / size(trial_start_timestamps_animal1, 1);

if output.Restart_Rate_animal1 == 0
    dprime_fa = 0 + 1/(2*size(trial_start_timestamps_animal1, 1));
elseif output.Restart_Rate_animal1 == 1
    dprime_fa = 1-1/(2*size(trial_start_timestamps_animal1, 1));
else
    dprime_fa = output.Restart_Rate_animal1;
end

[d, c] = dprime_simple(dprime_hr, dprime_fa);

output.D_Prime_Light_animal1 = d;
output.Response_Bias_Light_animal1 = c;

output.Hit_Number_animal1 = size(hit_timestamps_animal1, 1);
output.Miss_Number_animal1 = size(miss_timestamps_animal1, 1);
output.Correct_Rejection_Number_animal1 = size(cr_timestamps_animal1, 1);
output.False_Alarm_Number_animal1 = size(fa_timestamps_animal1, 1);

output.Restart_Number_animal1 = size(restart_timestamps_animal1, 1);

output.Total_Trials_Go_Sound_animal1 = (size(hit_timestamps_animal1, 1) + size(miss_timestamps_animal1, 1));
output.Total_Trials_Nogo_Sound_animal1 = (size(fa_timestamps_animal1, 1) + size(cr_timestamps_animal1, 1));

output.Total_Trials_Plus_Restarts_animal1 = size(trial_start_timestamps_animal1, 1);

else
    output.session_duration_animal1 = [];
    output.go_sound_start_timestamps_animal1 = [];
    output.nogo_sound_start_timestamps_animal1 = [];
    output.reward_dispensed_timestamps_animal1 = [];
    output.hit_timestamps_animal1 = [];
    output.miss_timestamps_animal1 = [];
    output.cr_timestamps_animal1 = [];
    output.fa_timestamps_animal1 = [];
    output.trial_start_timestamps_animal1 = [];
    output.restart_timestamps_animal1 = [];
    output.hit_go_sound_timestamps_animal1 = [];
    output.miss_go_sound_timestamps_animal1 = [];
    output.cr_nogo_sound_timestamps_animal1 = [];
    output.fa_nogo_sound_timestamps_animal1 = [];
    output.RW_Per_Min_animal1 = [];
    output.Hit_Rate_animal1 = [];
    output.FA_Rate_animal1 = [];
    output.D_Prime_animal1 = [];
    output.Response_Bias_animal1 = [];
    output.Restart_Rate_animal1 = [];
    output.D_Prime_Light_animal1 = [];
    output.Response_Bias_Light_animal1 = [];
    output.Hit_Number_animal1 = [];
    output.Miss_Number_animal1 = [];
    output.Correct_Rejection_Number_animal1 = [];
    output.False_Alarm_Number_animal1 = [];
    output.Restart_Number_animal1 = [];
    output.Total_Trials_Go_Sound_animal1 = [];
    output.Total_Trials_Nogo_Sound_animal1 = [];
    output.Total_Trials_Plus_Restarts_animal1 = [];

end  

% Start up Animal 2

if size(data_animal2, 1) > 0
    output.session_duration_animal2 = (data_animal2(end, 1) - data_animal2(2, 1))/60;  

    
        go_sound_start_index_animal2 = find(data_animal2(:, 2) == 20);
        go_sound_start_timestamps_animal2 = data_animal2(go_sound_start_index_animal2, 1);

        nogo_sound_start_index_animal2 = find(data_animal2(:, 2) == 22);
        nogo_sound_start_timestamps_animal2 = data_animal2(nogo_sound_start_index_animal2, 1);

        reward_dispensed_index_animal2 = find(data_animal2(:, 2) == 2);
        reward_dispensed_timestamps_animal2 = data_animal2(reward_dispensed_index_animal2, 1);    

        hit_index_animal2 = reward_dispensed_index_animal2;
        hit_timestamps_animal2 = reward_dispensed_timestamps_animal2;

        miss_index_animal2 = find(data_animal2(:, 2) == 11);
        miss_timestamps_animal2 = data_animal2(miss_index_animal2, 1);

        cr_index_animal2 = find(data_animal2(:, 2) == 12);
        cr_timestamps_animal2 = data_animal2(cr_index_animal2, 1);        

        fa_index_animal2 = find(data_animal2(:, 2) == 13);
        fa_timestamps_animal2 = data_animal2(fa_index_animal2, 1);

        trial_start_index_animal2 =  find(data_animal2(:, 2) == 9);
        trial_start_timestamps_animal2 = data_animal2(trial_start_index_animal2, 1); 
        
        restart_index_animal2 =  find(data_animal2(:, 2) == 10);
        restart_timestamps_animal2 = data_animal2(restart_index_animal2, 1); 
        
% Obtain hit go sound timestamps

    if ~isempty(hit_timestamps_animal2)
        for i = 1:length(hit_timestamps_animal2)

            hit_go_sound_start_index_animal2(i, 1) = find(data_animal2(:, 2) == 20 & data_animal2(:, 1) > (hit_timestamps_animal2(i, 1) - 1.2) & data_animal2(:, 1) < hit_timestamps_animal2(i, 1)); 
            hit_go_sound_timestamps_animal2(i, 1) = data_animal2(hit_go_sound_start_index_animal2(i, 1), 1);

        end
    else
        hit_timestamps_animal2 = [];
        hit_go_sound_timestamps_animal2 = [];
    end


% Obtain miss go sound timestamps
    if ~isempty(miss_timestamps_animal2)
        for i = 1:length(miss_timestamps_animal2)

            miss_go_sound_start_index_animal2(i, 1) = find(data_animal2(:, 2) == 20 & data_animal2(:, 1) > (miss_timestamps_animal2(i, 1) - 1.2) & data_animal2(:, 1) < miss_timestamps_animal2(i, 1)); 
            miss_go_sound_timestamps_animal2(i, 1) = data_animal2(miss_go_sound_start_index_animal2(i, 1), 1);

        end
    else
        miss_timestamps_animal2 = [];
        miss_go_sound_timestamps_animal2 = [];
    end

% Obtain cr nogo sound timestamps
    if ~isempty(cr_timestamps_animal2)
        for i = 1:length(cr_timestamps_animal2)

            cr_nogo_sound_start_index_animal2(i, 1) = find(data_animal2(:, 2) == 22 & data_animal2(:, 1) > (cr_timestamps_animal2(i, 1) - 1.2) & data_animal2(:, 1) < cr_timestamps_animal2(i, 1)); 
            cr_nogo_sound_timestamps_animal2(i, 1) = data_animal2(cr_nogo_sound_start_index_animal2(i, 1), 1);

        end
    else
        cr_timestamps_animal2 = [];
        cr_nogo_sound_timestamps_animal2 = [];
    end
    
% Obtain fa nogo sound timestamps
    if ~isempty(fa_timestamps_animal2)
        for i = 1:length(fa_timestamps_animal2)

            fa_nogo_sound_start_index_animal2(i, 1) = find(data_animal2(:, 2) == 22 & data_animal2(:, 1) > (fa_timestamps_animal2(i, 1) - 1.2) & data_animal2(:, 1) < fa_timestamps_animal2(i, 1)); 
            fa_nogo_sound_timestamps_animal2(i, 1) = data_animal2(fa_nogo_sound_start_index_animal2(i, 1), 1);

        end
    else
        fa_timestamps_animal2 = [];
        fa_nogo_sound_timestamps_animal2 = [];
    end


output.go_sound_start_timestamps_animal2 = go_sound_start_timestamps_animal2;
output.nogo_sound_start_timestamps_animal2 = nogo_sound_start_timestamps_animal2;
output.reward_dispensed_timestamps_animal2 = reward_dispensed_timestamps_animal2;
output.hit_timestamps_animal2 = hit_timestamps_animal2;
output.miss_timestamps_animal2 = miss_timestamps_animal2;
output.cr_timestamps_animal2 = cr_timestamps_animal2;
output.fa_timestamps_animal2 = fa_timestamps_animal2;
output.trial_start_timestamps_animal2 = trial_start_timestamps_animal2;
output.restart_timestamps_animal2 = restart_timestamps_animal2;
output.hit_go_sound_timestamps_animal2 = hit_go_sound_timestamps_animal2;
output.miss_go_sound_timestamps_animal2 = miss_go_sound_timestamps_animal2;
output.cr_nogo_sound_timestamps_animal2 = cr_nogo_sound_timestamps_animal2;
output.fa_nogo_sound_timestamps_animal2 = fa_nogo_sound_timestamps_animal2;

output.RW_Per_Min_animal2 = size(hit_timestamps_animal2, 1) / output.session_duration_animal2;

output.Hit_Rate_animal2 = size(hit_timestamps_animal2, 1) / (size(hit_timestamps_animal2, 1) + size(miss_timestamps_animal2, 1));
output.FA_Rate_animal2 = size(fa_timestamps_animal2, 1) / (size(fa_timestamps_animal2, 1) + size(cr_timestamps_animal2, 1));

if output.Hit_Rate_animal2 == 1
    dprime_hr = 1-1/(2*(size(hit_timestamps_animal2, 1) + size(miss_timestamps_animal2, 1)));
elseif output.Hit_Rate_animal2 == 0
    dprime_hr = 0 + 1/(2*(size(hit_timestamps_animal2, 1) + size(miss_timestamps_animal2, 1)));
else
    dprime_hr = output.Hit_Rate_animal2;
end

if output.FA_Rate_animal2 == 0
    dprime_fa = 0 + 1/(2*(size(fa_timestamps_animal2, 1) + size(cr_timestamps_animal2, 1)));
elseif output.FA_Rate_animal2 == 1
    dprime_fa = 1-1/(2*(size(fa_timestamps_animal2, 1) + size(cr_timestamps_animal2, 1)));
else
    dprime_fa = output.FA_Rate_animal2;
end

[d, c] = dprime_simple(dprime_hr, dprime_fa);

output.D_Prime_animal2 = d;
output.Response_Bias_animal2 = c;

output.Restart_Rate_animal2 = size(restart_timestamps_animal2, 1) / size(trial_start_timestamps_animal2, 1);

if output.Restart_Rate_animal2 == 0
    dprime_fa = 0 + 1/(2*size(trial_start_timestamps_animal2, 1));
elseif output.Restart_Rate_animal2 == 1
    dprime_fa = 1-1/(2*size(trial_start_timestamps_animal2, 1));
else
    dprime_fa = output.Restart_Rate_animal2;
end

[d, c] = dprime_simple(dprime_hr, dprime_fa);

output.D_Prime_Light_animal2 = d;
output.Response_Bias_Light_animal2 = c;

output.Hit_Number_animal2 = size(hit_timestamps_animal2, 1);
output.Miss_Number_animal2 = size(miss_timestamps_animal2, 1);
output.Correct_Rejection_Number_animal2 = size(cr_timestamps_animal2, 1);
output.False_Alarm_Number_animal2 = size(fa_timestamps_animal2, 1);

output.Restart_Number_animal2 = size(restart_timestamps_animal2, 1);

output.Total_Trials_Go_Sound_animal2 = (size(hit_timestamps_animal2, 1) + size(miss_timestamps_animal2, 1));
output.Total_Trials_Nogo_Sound_animal2 = (size(fa_timestamps_animal2, 1) + size(cr_timestamps_animal2, 1));

output.Total_Trials_Plus_Restarts_animal2 = size(trial_start_timestamps_animal2, 1);

else
    output.session_duration_animal2 = [];
    output.go_sound_start_timestamps_animal2 = [];
    output.nogo_sound_start_timestamps_animal2 = [];
    output.reward_dispensed_timestamps_animal2 = [];
    output.hit_timestamps_animal2 = [];
    output.miss_timestamps_animal2 = [];
    output.cr_timestamps_animal2 = [];
    output.fa_timestamps_animal2 = [];
    output.trial_start_timestamps_animal2 = [];
    output.restart_timestamps_animal2 = [];
    output.hit_go_sound_timestamps_animal2 = [];
    output.miss_go_sound_timestamps_animal2 = [];
    output.cr_nogo_sound_timestamps_animal2 = [];
    output.fa_nogo_sound_timestamps_animal2 = [];
    output.RW_Per_Min_animal2 = [];
    output.Hit_Rate_animal2 = [];
    output.FA_Rate_animal2 = [];
    output.D_Prime_animal2 = [];
    output.Response_Bias_animal2 = [];
    output.Restart_Rate_animal2 = [];
    output.D_Prime_Light_animal2 = [];
    output.Response_Bias_Light_animal2 = [];
    output.Hit_Number_animal2 = [];
    output.Miss_Number_animal2 = [];
    output.Correct_Rejection_Number_animal2 = [];
    output.False_Alarm_Number_animal2 = [];
    output.Restart_Number_animal2 = [];
    output.Total_Trials_Go_Sound_animal2 = [];
    output.Total_Trials_Nogo_Sound_animal2 = [];
    output.Total_Trials_Plus_Restarts_animal2 = [];

end  


end