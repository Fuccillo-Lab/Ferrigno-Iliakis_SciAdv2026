
sessions_list_path_day1 = "C:\Users\sarfe\Box\Documents\Go_NoGo\March2025\Fig3_Fig4_Photometry\Association_Training\D1C_AssociationTraining_Day1_SessionsList.xlsx";
sessions_list_path_expert = "C:\Users\sarfe\Box\Documents\Go_NoGo\March2025\Fig3_Fig4_Photometry\Association_Training\D1C_AssociationTraining_Expert_SessionsList.xlsx";
path_for_ws_save = 'C:\Users\sarfe\Box\Documents\Go_NoGo\March2025\Fig3_Fig4_Photometry\Tone_Frequency_Across_Training\D1C_AssociationTraining_ws.mat';



[matchingSessions_day1, mean_hit_traces_day1, mean_cr_traces_day1, mean_miss_traces_day1, mean_fa_traces_day1] = select_photo_data(sessions_list_path_day1, photometryStruct)
[matchingSessions_expert, mean_hit_traces_expert, mean_cr_traces_expert, mean_miss_traces_expert, mean_fa_traces_expert] = select_photo_data(sessions_list_path_expert, photometryStruct)



[peak_amplitude_hit_traces_day1, AUC_hit_traces_day1] = calc_peak_AUC_function(mean_hit_traces_day1);
[peak_amplitude_hit_traces_expert, AUC_hit_traces_expert] = calc_peak_AUC_function(mean_hit_traces_expert);

[peak_amplitude_cr_traces_day1, AUC_cr_traces_day1] = calc_peak_AUC_function(mean_cr_traces_day1);
[peak_amplitude_cr_traces_expert, AUC_cr_traces_expert] = calc_peak_AUC_function(mean_cr_traces_expert);

[peak_amplitude_miss_traces_day1, AUC_miss_traces_day1] = calc_peak_AUC_function(mean_miss_traces_day1);
[peak_amplitude_miss_traces_expert, AUC_miss_traces_expert] = calc_peak_AUC_function(mean_miss_traces_expert);

[peak_amplitude_fa_traces_day1, AUC_fa_traces_day1] = calc_peak_AUC_function(mean_fa_traces_day1);
[peak_amplitude_fa_traces_expert, AUC_fa_traces_expert] = calc_peak_AUC_function(mean_fa_traces_expert);



% Save WS
vars = setdiff(who, {'photometryStruct'});
save(path_for_ws_save, vars{:});

clearvars -except photometryStruct