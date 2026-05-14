% Creates behavioral learning figures comparing genotypes


[D_Prime_learning_data_mal, D_Prime_learning_anIDs_mal, D_Prime_learning_data_fem, D_Prime_learning_anIDs_fem] = group_learning_by_sex(output_mal, output_fem, "D_Prime", 1);

mean_D_Prime_mal = mean(D_Prime_learning_data_mal(1:4, :), 2, 'omitnan');
error_D_Prime_mal = std(D_Prime_learning_data_mal(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_learning_data_mal(1:4, :)')));
hold on
errorbar(mean_D_Prime_mal, error_D_Prime_mal, "-o", 'Color', 'blue', "MarkerFaceColor","blue", 'LineWidth', 0.75)

mean_D_Prime_fem = mean(D_Prime_learning_data_fem(1:4, :), 2, 'omitnan');
error_D_Prime_fem = std(D_Prime_learning_data_fem(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_learning_data_fem(1:4, :)')));
hold on
errorbar(mean_D_Prime_fem, error_D_Prime_fem, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([-1 5])
    ylabel("d'")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")

title("Learning by Sex", "Discrimination Index")
legend_info = {'','','','','','','', strcat('Male (n=', string(size(D_Prime_learning_anIDs_mal, 2)), ')'), strcat('Female (n=', string(size(D_Prime_learning_anIDs_fem, 2)), ')')};
legend(legend_info, 'Location','southeast')

% [h,p] = kstest2(mean_D_Prime_mal, mean_D_Prime_fem);  % Not sure this test makes sense for the data tbh
% text(1.5, 2, strcat("p = ", string(p)))
% text(1.5, 1.75, 'Two-sample Kolmogorov-Smirnov test')
% clear h p


[Hit_Rate_learning_data_mal, Hit_Rate_learning_anIDs_mal, Hit_Rate_learning_data_fem, Hit_Rate_learning_anIDs_fem] = group_learning_by_sex(output_mal, output_fem, "Hit_Rate", 2);

mean_Hit_Rate_mal = mean(Hit_Rate_learning_data_mal(1:4, :), 2, 'omitnan');
error_Hit_Rate_mal = std(Hit_Rate_learning_data_mal(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(Hit_Rate_learning_data_mal(1:4, :)')));
hold on
errorbar(mean_Hit_Rate_mal, error_Hit_Rate_mal, "-o", 'Color', 'blue', "MarkerFaceColor","blue", 'LineWidth', 0.75)

mean_Hit_Rate_fem = mean(Hit_Rate_learning_data_fem(1:4, :), 2, 'omitnan');
error_Hit_Rate_fem = std(Hit_Rate_learning_data_fem(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(Hit_Rate_learning_data_fem(1:4, :)')));
hold on
errorbar(mean_Hit_Rate_fem, error_Hit_Rate_fem, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1])
    ylabel("Hit Rate")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")

title("Learning by Sex", "Hits")
%legend_info = {'','','','','','','','','','', 'mal', 'fem'};
legend(legend_info, 'Location','southeast')

% [h,p] = kstest2(mean_Hit_Rate_mal, mean_Hit_Rate_fem);
% text(1.5, 0.75, strcat("p = ", string(p)))
% text(1.5, 0.65, 'Two-sample Kolmogorov-Smirnov test')
% clear h p




[FA_Rate_learning_data_mal, FA_Rate_learning_anIDs_mal, FA_Rate_learning_data_fem, FA_Rate_learning_anIDs_fem] = group_learning_by_sex(output_mal, output_fem, "FA_Rate", 3);

mean_FA_Rate_mal = mean(FA_Rate_learning_data_mal(1:4, :), 2, 'omitnan');
error_FA_Rate_mal = std(FA_Rate_learning_data_mal(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(FA_Rate_learning_data_mal(1:4, :)')));
hold on
errorbar(mean_FA_Rate_mal, error_FA_Rate_mal, "-o", 'Color', 'blue', "MarkerFaceColor","blue", 'LineWidth', 0.75)

mean_FA_Rate_fem = mean(FA_Rate_learning_data_fem(1:4, :), 2, 'omitnan');
error_FA_Rate_fem = std(FA_Rate_learning_data_fem(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(FA_Rate_learning_data_fem(1:4, :)')));
hold on
errorbar(mean_FA_Rate_fem, error_FA_Rate_fem, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1])
    ylabel("False Alarm Rate")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")

title("Learning by Sex", "False Alarms")
%legend_info = {'','','','','','','','','','', 'mal', 'fem'};
legend(legend_info, 'Location','northeast')

% [h,p] = kstest2(mean_FA_Rate_mal, mean_FA_Rate_fem);
% text(1.5, 0.75, strcat("p = ", string(p)))
% text(1.5, 0.65, 'Two-sample Kolmogorov-Smirnov test')
% clear h p





[Response_Bias_learning_data_mal, Response_Bias_learning_anIDs_mal, Response_Bias_learning_data_fem, Response_Bias_learning_anIDs_fem] = group_learning_by_sex(output_mal, output_fem, "Response_Bias", 4);

mean_Response_Bias_mal = mean(Response_Bias_learning_data_mal(1:4, :), 2, 'omitnan');
error_Response_Bias_mal = std(Response_Bias_learning_data_mal(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(Response_Bias_learning_data_mal(1:4, :)')));
hold on
errorbar(mean_Response_Bias_mal, error_Response_Bias_mal, "-o", 'Color', 'blue', "MarkerFaceColor","blue", 'LineWidth', 0.75)

mean_Response_Bias_fem = mean(Response_Bias_learning_data_fem(1:4, :), 2, 'omitnan');
error_Response_Bias_fem = std(Response_Bias_learning_data_fem(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(Response_Bias_learning_data_fem(1:4, :)')));
hold on
errorbar(mean_Response_Bias_fem, error_Response_Bias_fem, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([-2 2])
    ylabel("Response Bias")
    xlabel("Days of Go/NoGo Training")

title("Learning by Sex", "Response Bias")
%legend_info = {'','','','','','','','','','', 'mal', 'fem'};
legend(legend_info, 'Location','northeast')

% [h,p] = kstest2(mean_FA_Rate_mal, mean_FA_Rate_fem);
% text(1.5, 0.75, strcat("p = ", string(p)))
% text(1.5, 0.5, 'Two-sample Kolmogorov-Smirnov test')
% clear h p


% FOR GO TRAINING ANALYSIS

% [D_Prime_Light_learning_data_mal, D_Prime_Light_learning_anIDs_mal, D_Prime_Light_learning_data_fem, D_Prime_Light_learning_anIDs_fem] = group_learning_by_sex(mal, fem, "D_Prime_Light", 5);

% mean_D_Prime_Light_mal = mean(D_Prime_Light_learning_data_mal(1:5, :), 2, 'omitnan');
% error_D_Prime_Light_mal = std(D_Prime_Light_learning_data_mal(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_Light_learning_data_mal(1:5, :)')));
% hold on
% errorbar(mean_D_Prime_Light_mal, error_D_Prime_Light_mal, "-o", 'Color', 'blue', "MarkerFaceColor","blue", 'LineWidth', 0.75)

% mean_D_Prime_Light_fem = mean(D_Prime_Light_learning_data_fem(1:5, :), 2, 'omitnan');
% error_D_Prime_Light_fem = std(D_Prime_Light_learning_data_fem(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_Light_learning_data_fem(1:5, :)')));
% hold on
% errorbar(mean_D_Prime_Light_fem, error_D_Prime_Light_fem, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


% axis square
%     ylim([-1 5])
%     ylabel("d'")

%     xlim([1 size(D_Prime_Light_learning_data_fem, 1)])
%     xticks([1:size(D_Prime_Light_learning_data_fem, 1)])
%     xticklabels([1:7])
%     xlabel("Days of Go Training")

% title("Learning by Sex (Phase 2)", "Discrimination Index")
% legend_info = {'','','','','','','','','','', 'mal', 'fem'};
% legend(legend_info, 'Location','northeast')




% [Restart_Rate_learning_data_mal, Restart_Rate_learning_anIDs_mal, Restart_Rate_learning_data_fem, Restart_Rate_learning_anIDs_fem] = group_learning_by_sex(mal, fem, "Restart_Rate", 6);

% mean_Restart_Rate_mal = mean(Restart_Rate_learning_data_mal(1:5, :), 2, 'omitnan');
% error_Restart_Rate_mal = std(Restart_Rate_learning_data_mal(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Restart_Rate_learning_data_mal(1:5, :)')));
% hold on
% errorbar(mean_Restart_Rate_mal, error_Restart_Rate_mal, "-o", 'Color', 'blue', "MarkerFaceColor","blue", 'LineWidth', 0.75)

% mean_Restart_Rate_fem = mean(Restart_Rate_learning_data_fem(1:5, :), 2, 'omitnan');
% error_Restart_Rate_fem = std(Restart_Rate_learning_data_fem(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Restart_Rate_learning_data_fem(1:5, :)')));
% hold on
% errorbar(mean_Restart_Rate_fem, error_Restart_Rate_fem, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


% axis square
%     ylim([0 1])
%     ylabel("Restart Rate")

%     xlim([1 size(Restart_Rate_learning_data_fem, 1)])
%     xticks([1:size(Restart_Rate_learning_data_fem, 1)])
%     xticklabels([1:7])
%     xlabel("Days of Go Training")

% title("Learning by Sex (Phase 2)", "Restart Rate")
% legend_info = {'','','','','','','','','','', 'mal', 'fem'};
% legend(legend_info, 'Location','northeast')



% [Response_Bias_Light_learning_data_mal, Response_Bias_Light_learning_anIDs_mal, Response_Bias_Light_learning_data_fem, Response_Bias_Light_learning_anIDs_fem] = group_learning_by_sex(mal, fem, "Response_Bias_Light", 7);

% mean_Response_Bias_Light_mal = mean(Response_Bias_Light_learning_data_mal(1:5, :), 2, 'omitnan');
% error_Response_Bias_Light_mal = std(Response_Bias_Light_learning_data_mal(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Response_Bias_Light_learning_data_mal(1:5, :)')));
% hold on
% errorbar(mean_Response_Bias_Light_mal, error_Response_Bias_Light_mal, "-o", 'Color', 'blue', "MarkerFaceColor","blue", 'LineWidth', 0.75)

% mean_Response_Bias_Light_fem = mean(Response_Bias_Light_learning_data_fem(1:5, :), 2, 'omitnan');
% error_Response_Bias_Light_fem = std(Response_Bias_Light_learning_data_fem(1:5, :)', 'omitnan') ./ sqrt(sum(~isnan(Response_Bias_Light_learning_data_fem(1:5, :)')));
% hold on
% errorbar(mean_Response_Bias_Light_fem, error_Response_Bias_Light_fem, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


% axis square
%     ylim([-2 2])
%     ylabel("Response Bias")
%     xlabel("Days of Go Training")

% title("Learning by Sex (Phase 2)", "Response Bias")
% %legend_info = {'','','','','','','','','','', 'mal', 'fem'};
% legend(legend_info, 'Location','northeast')



[mean_RW_latency_learning_data_mal, mean_RW_latency_learning_anIDs_mal, mean_RW_latency_learning_data_fem, mean_RW_latency_learning_anIDs_fem] = group_learning_by_sex(output_mal, output_fem, "mean_RW_latency", 6);

mean_mean_RW_latency_mal = mean(mean_RW_latency_learning_data_mal(1:4, :), 2, 'omitnan');
error_mean_RW_latency_mal = std(mean_RW_latency_learning_data_mal(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_RW_latency_learning_data_mal(1:4, :)')));
hold on
errorbar(mean_mean_RW_latency_mal, error_mean_RW_latency_mal, "-o", 'Color', 'blue', "MarkerFaceColor","blue", 'LineWidth', 0.75)

mean_mean_RW_latency_fem = mean(mean_RW_latency_learning_data_fem(1:4, :), 2, 'omitnan');
error_mean_RW_latency_fem = std(mean_RW_latency_learning_data_fem(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_RW_latency_learning_data_fem(1:4, :)')));
hold on
errorbar(mean_mean_RW_latency_fem, error_mean_RW_latency_fem, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1200])
    ylabel("Mean Go Response Time (ms)")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")

title("Learning by Sex", "Go Response Time")
%legend_info = {'','','','','','','','','','', 'mal', 'fem'};
legend(legend_info, 'Location','southeast')

% [h,p] = kstest2(mean_mean_RW_latency_mal, mean_mean_RW_latency_fem);
% text(1.5, 600, strcat("p = ", string(p)))
% text(1.5, 550, 'Two-sample Kolmogorov-Smirnov test')
% clear h p






[mean_FA_latency_learning_data_mal, mean_FA_latency_learning_anIDs_mal, mean_FA_latency_learning_data_fem, mean_FA_latency_learning_anIDs_fem] = group_learning_by_sex(output_mal, output_fem, "mean_FA_latency", 7);

mean_mean_FA_latency_mal = mean(mean_FA_latency_learning_data_mal(1:4, :), 2, 'omitnan');
error_mean_FA_latency_mal = std(mean_FA_latency_learning_data_mal(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_FA_latency_learning_data_mal(1:4, :)')));
hold on
errorbar(mean_mean_FA_latency_mal, error_mean_FA_latency_mal, "-o", 'Color', 'blue', "MarkerFaceColor","blue", 'LineWidth', 0.75)

mean_mean_FA_latency_fem = mean(mean_FA_latency_learning_data_fem(1:4, :), 2, 'omitnan');
error_mean_FA_latency_fem = std(mean_FA_latency_learning_data_fem(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_FA_latency_learning_data_fem(1:4, :)')));
hold on
errorbar(mean_mean_FA_latency_fem, error_mean_FA_latency_fem, "-o", 'Color', 'red', "MarkerFaceColor","red", 'LineWidth', 0.75)


axis square
    ylim([0 1200])
    ylabel("Mean NoGo Response Time (ms)")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")

title("Learning by Sex", "Go Response Time")
%legend_info = {'','','','','','','','','','', 'mal', 'fem'};
legend(legend_info, 'Location','southeast')

% [h,p] = kstest2(mean_mean_FA_latency_mal, mean_mean_FA_latency_fem);
% text(1.5, 900, strcat("p = ", string(p)))
% text(1.5, 850, 'Two-sample Kolmogorov-Smirnov test')
% clear h p