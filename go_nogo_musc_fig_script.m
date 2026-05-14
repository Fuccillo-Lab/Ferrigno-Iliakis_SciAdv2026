% Muscimol Figs

[D_Prime_musc_data, D_Prime_musc_anIDs] = group_learning(Go_NoGo, "D_Prime", 1, 0);

mean_D_Prime = mean(D_Prime_musc_data(1:3, :), 2, 'omitnan');
error_D_Prime = std(D_Prime_musc_data(1:3, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_musc_data(1:3, :)')));
hold on
group = errorbar(mean_D_Prime, error_D_Prime, "-o", 'Color', 'black', 'LineWidth', 0.75)


axis square
    ylim([-1 5])
    ylabel("d'")

    xlim([1 size(D_Prime_musc_data, 1)])
    xticks([1:size(D_Prime_musc_data, 1)])
    %xticklabels({'PBS', '30 min', '150 min', '24 hrs'})
    xticklabels({'PBS', '30 min', '2.5 hours'})    
    xlabel("Time Post Injection")
    xlim([0.5 3.5])

title("Muscimol", "Discrimination Index")
%legend([D_Prime_musc_anIDs], 'Location','southwest')
legend('off')


[Hit_Rate_musc_data, Hit_Rate_musc_anIDs] = group_learning(Go_NoGo, "Hit_Rate", 2, 0);

mean_Hit_Rate = mean(Hit_Rate_musc_data(1:3, :), 2, 'omitnan');
error_Hit_Rate = std(Hit_Rate_musc_data(1:3, :)', 'omitnan') ./ sqrt(sum(~isnan(Hit_Rate_musc_data(1:3, :)')));
hold on
group = errorbar(mean_Hit_Rate, error_Hit_Rate, "-o", 'Color', 'black', 'LineWidth', 0.75)

axis square
    ylim([0 1])
    ylabel("Hit Rate")

    xlim([1 size(Hit_Rate_musc_data, 1)])
    xticks([1:size(Hit_Rate_musc_data, 1)])
    %xticklabels({'PBS', '30 min', '150 min', '24 hrs'})
    xticklabels({'PBS', '30 min', '2.5 hours'})  
    xlabel("Time Post Injection")
    xlim([0.5 3.5])

title("Muscimol", "Hit Rate")
%legend([Hit_Rate_musc_anIDs], 'Location','southeast')
legend('off')

[FA_Rate_musc_data, FA_Rate_musc_anIDs] = group_learning(Go_NoGo, "FA_Rate", 3, 0);

mean_FA_Rate = mean(FA_Rate_musc_data(1:3, :), 2, 'omitnan');
error_FA_Rate = std(FA_Rate_musc_data(1:3, :)', 'omitnan') ./ sqrt(sum(~isnan(FA_Rate_musc_data(1:3, :)')));
hold on
group = errorbar(mean_FA_Rate, error_FA_Rate, "-o", 'Color', 'black', 'LineWidth', 0.75)

axis square
    ylim([0 1])
    ylabel("FA Rate")

    xlim([1 size(FA_Rate_musc_data, 1)])
    xticks([1:size(FA_Rate_musc_data, 1)])
    %xticklabels({'PBS', '30 min', '150 min', '24 hrs'})
    xticklabels({'PBS', '30 min', '2.5 hours'}) 
    xlabel("Time Post Injection")
    xlim([0.5 3.5])
    
title("Muscimol", "False Alarm Rate")
%legend([FA_Rate_musc_anIDs], 'Location','northeast')
legend('off')



[Mean_LPS_cue_musc_data, Mean_LPS_cue_musc_anIDs] = group_learning(Non_Operant, "mean_lps_during_cue_uncut", 4, 0);

mean_Mean_LPS_cue = mean(Mean_LPS_cue_musc_data(1:3, :), 2, 'omitnan');
error_Mean_LPS_cue = std(Mean_LPS_cue_musc_data(1:3, :)', 'omitnan') ./ sqrt(sum(~isnan(Mean_LPS_cue_musc_data(1:3, :)')));
hold on
group = errorbar(mean_Mean_LPS_cue, error_Mean_LPS_cue, "-o", 'Color', 'black', 'LineWidth', 0.75)
hold on

axis square
    ylim([0 25])
    ylabel("Mean(Licks/s) During Go Cue")

    xlim([1 size(Mean_LPS_cue_musc_data, 1)])
    xticks([1:size(Mean_LPS_cue_musc_data, 1)])
    %xticklabels({'60 min', '180 min'})
    xticklabels({'PBS', '30 min', '2.5 hours'}) 
    xlabel("Time Post Injection")
    xlim([0.5 3.5])
    
title("Muscimol NonOperant", "Lick Rate During Go Cue")
%legend([Mean_LPS_cue_musc_anIDs], 'Location','northwest')
legend('off')




[Mean_LPS_RW_musc_data, Mean_LPS_RW_musc_anIDs] = group_learning(Non_Operant, "mean_lps_postRW", 5, 0);

mean_Mean_LPS_RW = mean(Mean_LPS_RW_musc_data(1:3, :), 2, 'omitnan');
error_Mean_LPS_RW = std(Mean_LPS_RW_musc_data(1:3, :)', 'omitnan') ./ sqrt(sum(~isnan(Mean_LPS_RW_musc_data(1:3, :)')));
hold on
group = errorbar(mean_Mean_LPS_RW, error_Mean_LPS_RW, "-o", 'Color', 'black', 'LineWidth', 0.75)
hold on

axis square
    ylim([0 25])
    ylabel("Mean(Licks/s) after RW")

    xlim([1 size(Mean_LPS_RW_musc_data, 1)])
    xticks([1:size(Mean_LPS_RW_musc_data, 1)])
    %xticklabels({'60 min', '180 min'})
    xticklabels({'PBS', '30 min', '2.5 hours'}) 
    xlabel("Time Post Injection")
    xlim([0.5 3.5])
    
title("Muscimol NonOperant", "Lick Rate Ingesting RW")
%legend([Mean_LPS_RW_musc_anIDs], 'Location','northwest')
legend('off')




[mean_RW_latency_musc_data, mean_RW_latency_musc_anIDs] = group_learning(Go_NoGo, "mean_RW_latency", 6, 0);

mean_mean_RW_latency = mean(mean_RW_latency_musc_data(1:3, :), 2, 'omitnan');
error_mean_RW_latency = std(mean_RW_latency_musc_data(1:3, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_RW_latency_musc_data(1:3, :)')));
hold on
group = errorbar(mean_mean_RW_latency, error_mean_RW_latency, "-o", 'Color', 'black', 'LineWidth', 0.75)


axis square
    ylim([0 1200])
    ylabel("Mean Go Reaction Time (ms)")

    xlim([1 size(mean_RW_latency_musc_data, 1)])
    xticks([1:size(mean_RW_latency_musc_data, 1)])
    %xticklabels({'PBS', '30 min', '150 min', '24 hrs'})
    xticklabels({'PBS', '30 min', '2.5 hours'})    
    xlabel("Time Post Injection")
    xlim([0.5 3.5])

title("Muscimol", "Go Reaction Time")
%legend([mean_RW_latency_musc_anIDs], 'Location','southwest')
legend('off')



[mean_FA_latency_musc_data, mean_FA_latency_musc_anIDs] = group_learning(Go_NoGo, "mean_FA_latency", 7, 0);

mean_mean_FA_latency = mean(mean_FA_latency_musc_data(1:3, :), 2, 'omitnan');
error_mean_FA_latency = std(mean_FA_latency_musc_data(1:3, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_FA_latency_musc_data(1:3, :)')));
hold on
group = errorbar(mean_mean_FA_latency, error_mean_FA_latency, "-o", 'Color', 'black', 'LineWidth', 0.75)


axis square
    ylim([0 1200])
    ylabel("Mean NoGo Reaction Time (ms)")

    xlim([1 size(mean_FA_latency_musc_data, 1)])
    xticks([1:size(mean_FA_latency_musc_data, 1)])
    %xticklabels({'PBS', '30 min', '150 min', '24 hrs'})
    xticklabels({'PBS', '30 min', '2.5 hours'})    
    xlabel("Time Post Injection")
    xlim([0.5 3.5])

title("Muscimol", "NoGo Reaction Time")
%legend([mean_FA_latency_musc_anIDs], 'Location','southwest')
legend('off')