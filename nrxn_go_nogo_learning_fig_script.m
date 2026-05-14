% Creates behavioral learning figures comparing genotypes


[D_Prime_learning_data_WT, D_Prime_learning_anIDs_WT, D_Prime_learning_data_KO, D_Prime_learning_anIDs_KO] = nrxn_group_learning(WT, KO, "D_Prime", 1);

mean_D_Prime_WT = mean(D_Prime_learning_data_WT(1:5, :), 2, 'omitnan');
error_D_Prime_WT = std(D_Prime_learning_data_WT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_learning_data_WT(1:5, :)')));
hold on
errorbar(mean_D_Prime_WT, error_D_Prime_WT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_D_Prime_KO = mean(D_Prime_learning_data_KO(1:5, :), 2, 'omitnan');
error_D_Prime_KO = std(D_Prime_learning_data_KO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_learning_data_KO(1:5, :)')));
hold on
errorbar(mean_D_Prime_KO, error_D_Prime_KO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([-1 5])
    ylabel("d'")

    xlim([0.5 5.5])
    xticks([1:5])
    xticklabels([1:5])
    xlabel("Days of Go/NoGo Training")

title("WT vs KO Learning", "Discrimination Index")
legend_info = {'','','','','','','', 'WT', 'KO'};
legend(legend_info, 'Location','southeast')



[Hit_Rate_learning_data_WT, Hit_Rate_learning_anIDs_WT, Hit_Rate_learning_data_KO, Hit_Rate_learning_anIDs_KO] = nrxn_group_learning(WT, KO, "Hit_Rate", 2);

mean_Hit_Rate_WT = mean(Hit_Rate_learning_data_WT(1:5, :), 2, 'omitnan');
error_Hit_Rate_WT = std(Hit_Rate_learning_data_WT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Hit_Rate_learning_data_WT(1:5, :)')));
hold on
errorbar(mean_Hit_Rate_WT, error_Hit_Rate_WT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_Hit_Rate_KO = mean(Hit_Rate_learning_data_KO(1:5, :), 2, 'omitnan');
error_Hit_Rate_KO = std(Hit_Rate_learning_data_KO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Hit_Rate_learning_data_KO(1:5, :)')));
hold on
errorbar(mean_Hit_Rate_KO, error_Hit_Rate_KO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1])
    ylabel("Hit Rate")

    xlim([0.5 5.5])
    xticks([1:5])
    xticklabels([1:5])
    xlabel("Days of Go/NoGo Training")

title("WT vs KO Learning", "Hits")
%legend_info = {'','','','','','','','','','', 'WT', 'KO'};
legend(legend_info, 'Location','southeast')





[FA_Rate_learning_data_WT, FA_Rate_learning_anIDs_WT, FA_Rate_learning_data_KO, FA_Rate_learning_anIDs_KO] = nrxn_group_learning(WT, KO, "FA_Rate", 3);

mean_FA_Rate_WT = mean(FA_Rate_learning_data_WT(1:5, :), 2, 'omitnan');
error_FA_Rate_WT = std(FA_Rate_learning_data_WT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(FA_Rate_learning_data_WT(1:5, :)')));
hold on
errorbar(mean_FA_Rate_WT, error_FA_Rate_WT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_FA_Rate_KO = mean(FA_Rate_learning_data_KO(1:5, :), 2, 'omitnan');
error_FA_Rate_KO = std(FA_Rate_learning_data_KO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(FA_Rate_learning_data_KO(1:5, :)')));
hold on
errorbar(mean_FA_Rate_KO, error_FA_Rate_KO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1])
    ylabel("False Alarm Rate")

    xlim([0.5 5.5])
    xticks([1:5])
    xticklabels([1:5])
    xlabel("Days of Go/NoGo Training")

title("WT vs KO Learning", "False Alarms")
%legend_info = {'','','','','','','','','','', 'WT', 'KO'};
legend(legend_info, 'Location','northeast')






[Response_Bias_learning_data_WT, Response_Bias_learning_anIDs_WT, Response_Bias_learning_data_KO, Response_Bias_learning_anIDs_KO] = nrxn_group_learning(WT, KO, "Response_Bias", 4);

mean_Response_Bias_WT = mean(Response_Bias_learning_data_WT(1:5, :), 2, 'omitnan');
error_Response_Bias_WT = std(Response_Bias_learning_data_WT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Response_Bias_learning_data_WT(1:5, :)')));
hold on
errorbar(mean_Response_Bias_WT, error_Response_Bias_WT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_Response_Bias_KO = mean(Response_Bias_learning_data_KO(1:5, :), 2, 'omitnan');
error_Response_Bias_KO = std(Response_Bias_learning_data_KO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Response_Bias_learning_data_KO(1:5, :)')));
hold on
errorbar(mean_Response_Bias_KO, error_Response_Bias_KO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([-2 2])
    ylabel("Response Bias")
    xlabel("Days of Go/NoGo Training")

title("WT vs KO Learning", "Response Bias")
%legend_info = {'','','','','','','','','','', 'WT', 'KO'};
legend(legend_info, 'Location','northeast')




[mean_RW_latency_learning_data_WT, mean_RW_latency_learning_anIDs_WT, mean_RW_latency_learning_data_KO, mean_RW_latency_learning_anIDs_KO] = nrxn_group_learning(WT, KO, "mean_RW_latency", 5);

mean_mean_RW_latency_WT = mean(mean_RW_latency_learning_data_WT(1:5, :), 2, 'omitnan');
error_mean_RW_latency_WT = std(mean_RW_latency_learning_data_WT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_RW_latency_learning_data_WT(1:5, :)')));
hold on
errorbar(mean_mean_RW_latency_WT, error_mean_RW_latency_WT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_mean_RW_latency_KO = mean(mean_RW_latency_learning_data_KO(1:5, :), 2, 'omitnan');
error_mean_RW_latency_KO = std(mean_RW_latency_learning_data_KO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_RW_latency_learning_data_KO(1:5, :)')));
hold on
errorbar(mean_mean_RW_latency_KO, error_mean_RW_latency_KO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1200])
    ylabel("Mean Go Response Time (ms)")

    xlim([0.5 5.5])
    xticks([1:5])
    xticklabels([1:5])
    xlabel("Days of Go/NoGo Training")

title("WT vs KO Learning", "Hit Reaction Time")
legend_info = {'','','','','','','', 'WT', 'KO'};
legend(legend_info, 'Location','southeast')





[mean_FA_latency_learning_data_WT, mean_FA_latency_learning_anIDs_WT, mean_FA_latency_learning_data_KO, mean_FA_latency_learning_anIDs_KO] = nrxn_group_learning(WT, KO, "mean_FA_latency", 6);

mean_mean_FA_latency_WT = mean(mean_FA_latency_learning_data_WT(1:5, :), 2, 'omitnan');
error_mean_FA_latency_WT = std(mean_FA_latency_learning_data_WT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_FA_latency_learning_data_WT(1:5, :)')));
hold on
errorbar(mean_mean_FA_latency_WT, error_mean_FA_latency_WT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_mean_FA_latency_KO = mean(mean_FA_latency_learning_data_KO(1:5, :), 2, 'omitnan');
error_mean_FA_latency_KO = std(mean_FA_latency_learning_data_KO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_FA_latency_learning_data_KO(1:5, :)')));
hold on
errorbar(mean_mean_FA_latency_KO, error_mean_FA_latency_KO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1200])
    ylabel("Mean NoGo Response Time (ms)")

    xlim([0.5 5.5])
    xticks([1:5])
    xticklabels([1:5])
    xlabel("Days of Go/NoGo Training")

title("WT vs KO Learning", "False Alarm Reaction Time")
legend_info = {'','','','','','','', 'WT', 'KO'};
legend(legend_info, 'Location','southeast')








[Restart_Rate_learning_data_WT, Restart_Rate_learning_anIDs_WT, Restart_Rate_learning_data_KO, Restart_Rate_learning_anIDs_KO] = nrxn_group_learning(WT, KO, "Restart_Rate", 7);

mean_Restart_Rate_WT = mean(Restart_Rate_learning_data_WT(1:5, :), 2, 'omitnan');
error_Restart_Rate_WT = std(Restart_Rate_learning_data_WT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Restart_Rate_learning_data_WT(1:5, :)')));
hold on
errorbar(mean_Restart_Rate_WT, error_Restart_Rate_WT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_Restart_Rate_KO = mean(Restart_Rate_learning_data_KO(1:5, :), 2, 'omitnan');
error_Restart_Rate_KO = std(Restart_Rate_learning_data_KO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Restart_Rate_learning_data_KO(1:5, :)')));
hold on
errorbar(mean_Restart_Rate_KO, error_Restart_Rate_KO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1])
    ylabel("Premature Licks / Total Trials")

    xlim([0.5 5.5])
    xticks([1:5])
    xticklabels([1:5])
    xlabel("Days of Go/NoGo Training")

title("WT vs KO Learning", "Premature Trial Rate")
legend_info = {'','','','','','','', 'WT', 'KO'};
legend(legend_info, 'Location','southeast')












% FOR GO TRAINING ANALYSIS
% 
% [mean_RW_latency_go_training_learning_data_WT, mean_RW_latency_go_training_learning_anIDs_WT, mean_RW_latency_go_training_learning_data_KO, mean_RW_latency_go_training_learning_anIDs_KO] = nrxn_group_learning(output_go_trainingWT, output_go_trainingKO, "mean_RW_latency", 1);
% 
% mean_mean_RW_latency_go_training_WT = mean(mean_RW_latency_go_training_learning_data_WT(1:5, :), 2, 'omitnan');
% error_mean_RW_latency_go_training_WT = std(mean_RW_latency_go_training_learning_data_WT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_RW_latency_go_training_learning_data_WT(1:5, :)')));
% hold on
% errorbar(mean_mean_RW_latency_go_training_WT, error_mean_RW_latency_go_training_WT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)
% 
% mean_mean_RW_latency_go_training_KO = mean(mean_RW_latency_go_training_learning_data_KO(1:5, :), 2, 'omitnan');
% error_mean_RW_latency_go_training_KO = std(mean_RW_latency_go_training_learning_data_KO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_RW_latency_go_training_learning_data_KO(1:5, :)')));
% hold on
% errorbar(mean_mean_RW_latency_go_training_KO, error_mean_RW_latency_go_training_KO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)
% 
% 
% axis square
%     ylim([-1 5])
%     ylabel("d'")
% 
%     xlim([0.5 5.5])
%     xticks([1:5])
%     xticklabels([1:5])
%     xlabel("Days of Go/NoGo Training")
% 
% title("WT vs KO Learning", "Discrimination Index")
% legend_info = {'','','','','','','', 'WT', 'KO'};
% legend(legend_info, 'Location','southeast')
% 
% 
% 




[Hit_Rate_learning_data_gotrainingWT, Hit_Rate_learning_anIDs_gotrainingWT, Hit_Rate_learning_data_gotrainingKO, Hit_Rate_learning_anIDs_gotrainingKO] = nrxn_group_learning(gotrainingWT, gotrainingKO, "Hit_Rate", 2);

mean_Hit_Rate_gotrainingWT = mean(Hit_Rate_learning_data_gotrainingWT(1:5, :), 2, 'omitnan');
error_Hit_Rate_gotrainingWT = std(Hit_Rate_learning_data_gotrainingWT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Hit_Rate_learning_data_gotrainingWT(1:5, :)')));
hold on
errorbar(mean_Hit_Rate_gotrainingWT, error_Hit_Rate_gotrainingWT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_Hit_Rate_gotrainingKO = mean(Hit_Rate_learning_data_gotrainingKO(1:5, :), 2, 'omitnan');
error_Hit_Rate_gotrainingKO = std(Hit_Rate_learning_data_gotrainingKO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Hit_Rate_learning_data_gotrainingKO(1:5, :)')));
hold on
errorbar(mean_Hit_Rate_gotrainingKO, error_Hit_Rate_gotrainingKO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1])
    ylabel("Hit Rate")

    xlim([0.5 5.5])
    xticks([1:5])
    xticklabels([1:5])
    xlabel("Days of Go/NoGo Training")

title("gotrainingWT vs gotrainingKO Learning", "Hits")
%legend_info = {'','','','','','','','','','', 'gotrainingWT', 'gotrainingKO'};
legend(legend_info, 'Location','southeast')





[Restart_Rate_learning_data_gotrainingWT, Restart_Rate_learning_anIDs_gotrainingWT, Restart_Rate_learning_data_gotrainingKO, Restart_Rate_learning_anIDs_gotrainingKO] = nrxn_group_learning(gotrainingWT, gotrainingKO, "Restart_Rate", 6);

mean_Restart_Rate_gotrainingWT = mean(Restart_Rate_learning_data_gotrainingWT(1:5, :), 2, 'omitnan');
error_Restart_Rate_gotrainingWT = std(Restart_Rate_learning_data_gotrainingWT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Restart_Rate_learning_data_gotrainingWT(1:5, :)')));
hold on
errorbar(mean_Restart_Rate_gotrainingWT, error_Restart_Rate_gotrainingWT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_Restart_Rate_gotrainingKO = mean(Restart_Rate_learning_data_gotrainingKO(1:5, :), 2, 'omitnan');
error_Restart_Rate_gotrainingKO = std(Restart_Rate_learning_data_gotrainingKO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Restart_Rate_learning_data_gotrainingKO(1:5, :)')));
hold on
errorbar(mean_Restart_Rate_gotrainingKO, error_Restart_Rate_gotrainingKO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1])
    ylabel("Restart Rate")

    xlim([1 size(Restart_Rate_learning_data_gotrainingKO, 1)])
    xticks([1:size(Restart_Rate_learning_data_gotrainingKO, 1)])
    xticklabels([1:7])
    xlabel("Days of Go Training")

title("gotrainingWT vs gotrainingKO Learning (Phase 2)", "Restart Rate")
legend_info = {'','','','','','','','','','', 'gotrainingWT', 'gotrainingKO'};
legend(legend_info, 'Location','northeast')



[D_Prime_Light_learning_data_gotrainingWT, D_Prime_Light_learning_anIDs_gotrainingWT, D_Prime_Light_learning_data_gotrainingKO, D_Prime_Light_learning_anIDs_gotrainingKO] = nrxn_group_learning(gotrainingWT, gotrainingKO, "D_Prime_Light", 5);

mean_D_Prime_Light_gotrainingWT = mean(D_Prime_Light_learning_data_gotrainingWT(1:5, :), 2, 'omitnan');
error_D_Prime_Light_gotrainingWT = std(D_Prime_Light_learning_data_gotrainingWT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_Light_learning_data_gotrainingWT(1:5, :)')));
hold on
errorbar(mean_D_Prime_Light_gotrainingWT, error_D_Prime_Light_gotrainingWT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_D_Prime_Light_gotrainingKO = mean(D_Prime_Light_learning_data_gotrainingKO(1:5, :), 2, 'omitnan');
error_D_Prime_Light_gotrainingKO = std(D_Prime_Light_learning_data_gotrainingKO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_Light_learning_data_gotrainingKO(1:5, :)')));
hold on
errorbar(mean_D_Prime_Light_gotrainingKO, error_D_Prime_Light_gotrainingKO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([-1 5])
    ylabel("d'")

    xlim([1 size(D_Prime_Light_learning_data_gotrainingKO, 1)])
    xticks([1:size(D_Prime_Light_learning_data_gotrainingKO, 1)])
    xticklabels([1:7])
    xlabel("Days of Go Training")

title("gotrainingWT vs gotrainingKO Learning (Phase 2)", "Discrimination Index")
legend_info = {'','','','','','','','','','', 'gotrainingWT', 'gotrainingKO'};
legend(legend_info, 'Location','northeast')







[Response_Bias_Light_learning_data_gotrainingWT, Response_Bias_Light_learning_anIDs_gotrainingWT, Response_Bias_Light_learning_data_gotrainingKO, Response_Bias_Light_learning_anIDs_gotrainingKO] = nrxn_group_learning(gotrainingWT, gotrainingKO, "Response_Bias_Light", 7);

mean_Response_Bias_Light_gotrainingWT = mean(Response_Bias_Light_learning_data_gotrainingWT(1:5, :), 2, 'omitnan');
error_Response_Bias_Light_gotrainingWT = std(Response_Bias_Light_learning_data_gotrainingWT(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Response_Bias_Light_learning_data_gotrainingWT(1:5, :)')));
hold on
errorbar(mean_Response_Bias_Light_gotrainingWT, error_Response_Bias_Light_gotrainingWT, "-o", 'Color', 'black', "MarkerFaceColor","black", 'LineWidth', 0.75)

mean_Response_Bias_Light_gotrainingKO = mean(Response_Bias_Light_learning_data_gotrainingKO(1:5, :), 2, 'omitnan');
error_Response_Bias_Light_gotrainingKO = std(Response_Bias_Light_learning_data_gotrainingKO(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Response_Bias_Light_learning_data_gotrainingKO(1:5, :)')));
hold on
errorbar(mean_Response_Bias_Light_gotrainingKO, error_Response_Bias_Light_gotrainingKO, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([-2 2])
    ylabel("Response Bias")
    xlabel("Days of Go Training")

title("gotrainingWT vs gotrainingKO Learning (Phase 2)", "Response Bias")
%legend_info = {'','','','','','','','','','', 'gotrainingWT', 'gotrainingKO'};
legend(legend_info, 'Location','northeast')
