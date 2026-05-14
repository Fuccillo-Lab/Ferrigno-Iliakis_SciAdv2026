% Creates behavioral learning figures

addpath("C:\Users\sarfe\Box\Documents\MATLAB\shadedErrorBar") %for shaded error bar funct

[D_Prime_learning_data, D_Prime_learning_anIDs] = group_learning(go_nogo_learning, "D_Prime", 1, 0);

mean_D_Prime = mean(D_Prime_learning_data(1:4, :), 2, 'omitnan');
error_D_Prime = std(D_Prime_learning_data(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_learning_data(1:4, :)')));
hold on
group = errorbar(mean_D_Prime, error_D_Prime, "-", 'Color', 'black', 'LineWidth', 1)

axis square
    ylim([-1 5])
    ylabel("d'")

    % xlim([1 size(D_Prime_learning_data, 1)])
    % xticks([1:size(D_Prime_learning_data, 1)])
    % xticklabels([1:size(D_Prime_learning_data, 1)])
    % xlabel("Days of Go/NoGo Training")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")

title("Go/NoGo Learning", "Discrimination Index")
%legend([D_Prime_learning_anIDs], 'Location','southeast')
legend off

[Hit_Rate_learning_data, Hit_Rate_learning_anIDs] = group_learning(go_nogo_learning, "Hit_Rate", 2, 0);

mean_Hit_Rate = mean(Hit_Rate_learning_data(1:4, :), 2, 'omitnan');
error_Hit_Rate = std(Hit_Rate_learning_data(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(Hit_Rate_learning_data(1:4, :)')));
hold on
group = errorbar(mean_Hit_Rate, error_Hit_Rate, "-", 'Color', 'black', 'LineWidth', 1)

axis square
    ylim([0 1])
    ylabel("Hit Rate")

    % xlim([1 size(D_Prime_learning_data, 1)])
    % xticks([1:size(D_Prime_learning_data, 1)])
    % xticklabels([1:size(D_Prime_learning_data, 1)])
    % xlabel("Days of Go/NoGo Training")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")
    
title("Go/NoGo Learning", "Hit Rate")
%legend([Hit_Rate_learning_anIDs], 'Location','southeast')
legend off

[FA_Rate_learning_data, FA_Rate_learning_anIDs] = group_learning(go_nogo_learning, "FA_Rate", 3, 0);

mean_FA_Rate = mean(FA_Rate_learning_data(1:4, :), 2, 'omitnan');
error_FA_Rate = std(FA_Rate_learning_data(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(FA_Rate_learning_data(1:4, :)')));
hold on
group = errorbar(mean_FA_Rate, error_FA_Rate, "-", 'Color', 'black', 'LineWidth', 1)

axis square
    ylim([0 1])
    ylabel("False Alarm Rate")

    % xlim([1 size(D_Prime_learning_data, 1)])
    % xticks([1:size(D_Prime_learning_data, 1)])
    % xticklabels([1:size(D_Prime_learning_data, 1)])
    % xlabel("Days of Go/NoGo Training")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")
    
title("Go/NoGo Learning", "False Alarm Rate")
%legend([FA_Rate_learning_anIDs],'Location','northeast')
legend off

% figure(4)
%     mean_D_Prime = mean(D_Prime_learning_data(1:6, :), 2, 'omitnan');
%     error_D_Prime = std(D_Prime_learning_data(1:6, :)', 'omitnan') ./ sqrt(sum(~isnan(D_Prime_learning_data(1:6, :)')));
%     shadedErrorBar(1:6, mean_D_Prime,error_D_Prime)
% 
% axis square
%     ylim([0 5])
%     ylabel("d'")
%     yticks([0:5])
% 
%     xlim([1 6])
%     xticks([1:6])
%     xticklabels([0:5])
%     xlabel("Days of Go/NoGo Training")
% 
% title("Go/NoGo Learning", "Discrimination Index-- Group")
% text(5, 1, strcat('n =',[], string(size(D_Prime_learning_anIDs, 2))))
% 
% figure(5)
%     mean_Hit_Rate = mean(Hit_Rate_learning_data(1:6, :), 2, 'omitnan');
%     error_Hit_Rate = std(Hit_Rate_learning_data(1:6, :)', 'omitnan') ./ sqrt(sum(~isnan(Hit_Rate_learning_data(1:6, :)')));
%     shadedErrorBar(1:6, mean_Hit_Rate,error_Hit_Rate)
% 
% axis square
%     ylim([0 1])
%     ylabel("Hit Rate")
%     yticks([0:0.2:1])
% 
%     xlim([1 6])
%     xticks([1:6])
%     xticklabels([1:5])
%     xlabel("Days of Go/NoGo Training")
% 
% title("Go/NoGo Learning", "False Alarm Rate-- Group")
% text(5, 0.2, strcat('n =',[], string(size(Hit_Rate_learning_anIDs, 2))))
% 
% 
% figure(6)
%     mean_FA_Rate = mean(FA_Rate_learning_data(1:6, :), 2, 'omitnan');
%     error_FA_Rate = std(FA_Rate_learning_data(1:6, :)', 'omitnan') ./ sqrt(sum(~isnan(FA_Rate_learning_data(1:6, :)')));
%     shadedErrorBar(1:6, mean_FA_Rate,error_FA_Rate)
% 
% axis square
%     ylim([0 1])
%     ylabel("False Alarm Rate")
%     yticks([0:0.2:1])
% 
%     xlim([1 6])
%     xticks([1:6])
%     xticklabels([1:5])
%     xlabel("Days of Go/NoGo Training")
% 
% title("Go/NoGo Learning", "Hit Rate-- Group")
% text(5, 0.8, strcat('n =',[], string(size(FA_Rate_learning_anIDs, 2))))

if exist("nogo_testing")

    [nogo_test_D_Prime_learning_data, nogo_test_D_Prime_learning_anIDs] = group_learning(nogo_testing, "D_Prime", 4, 0);
    
    mean_nogo_test_D_Prime = mean(nogo_test_D_Prime_learning_data(1:4, :), 2, 'omitnan');
    error_nogo_test_D_Prime = std(nogo_test_D_Prime_learning_data(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(nogo_test_D_Prime_learning_data(1:4, :)')));
    hold on
    group = errorbar(mean_nogo_test_D_Prime, error_nogo_test_D_Prime, "-", 'Color', 'black', 'LineWidth', 1)
    
    axis square
        ylim([-1 5])
        ylabel("d'")
    
        xlim([1 size(nogo_test_D_Prime_learning_data, 1)])
        xticks([1:size(nogo_test_D_Prime_learning_data, 1)])
        xticklabels({'0.8889', '0.4448', '-0.040', '0.8889'})
        xlabel("Octave Difference b/w Stimuli")
        xlim([0.5 4.5])
    
    title("NoGo Testing", "Discrimination Index")
    %legend([nogo_test_D_Prime_learning_anIDs], 'Location','southeast')
    
    
    [nogo_test_Hit_Rate_learning_data, nogo_test_Hit_Rate_learning_anIDs] = group_learning(nogo_testing, "Hit_Rate", 5, 0);
    
    mean_nogo_test_Hit_Rate = mean(nogo_test_Hit_Rate_learning_data(1:4, :), 2, 'omitnan');
    error_nogo_test_Hit_Rate = std(nogo_test_Hit_Rate_learning_data(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(nogo_test_Hit_Rate_learning_data(1:4, :)')));
    hold on
    group = errorbar(mean_nogo_test_Hit_Rate, error_nogo_test_Hit_Rate, "-", 'Color', 'black', 'LineWidth', 1)
    
    axis square
        ylim([0 1])
        ylabel("d'")
    
        xlim([1 size(nogo_test_Hit_Rate_learning_data, 1)])
        xticks([1:size(nogo_test_Hit_Rate_learning_data, 1)])
        xticklabels({'0.8889', '0.4448', '-0.040', '0.8889'})
        xlabel("Octave Difference b/w Stimuli")
        xlim([0.5 4.5])
    
    title("NoGo Testing", "Hit Rate")
    %legend([nogo_test_Hit_Rate_learning_anIDs], 'Location','southeast')
    
    
    [nogo_test_FA_Rate_learning_data, nogo_test_FA_Rate_learning_anIDs] = group_learning(nogo_testing, "FA_Rate", 6, 0);
    
    mean_nogo_test_FA_Rate = mean(nogo_test_FA_Rate_learning_data(1:4, :), 2, 'omitnan');
    error_nogo_test_FA_Rate = std(nogo_test_FA_Rate_learning_data(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(nogo_test_FA_Rate_learning_data(1:4, :)')));
    hold on
    group = errorbar(mean_nogo_test_FA_Rate, error_nogo_test_FA_Rate, "-", 'Color', 'black', 'LineWidth', 1)
    
    axis square
        ylim([0 1])
        ylabel("d'")
    
        xlim([1 size(nogo_test_FA_Rate_learning_data, 1)])
        xticks([1:size(nogo_test_FA_Rate_learning_data, 1)])
        xticklabels({'0.8889', '0.4448', '-0.040', '0.8889'})
        xlabel("Octave Difference b/w Stimuli")
        xlim([0.5 4.5])
    
    title("NoGo Testing", "False Alarm Rate")
    %legend([nogo_test_FA_Rate_learning_anIDs], 'Location','northeast')


end




[mean_RW_latency_learning_data, mean_RW_latency_learning_anIDs] = group_learning(go_nogo_learning, "mean_RW_latency", 7, 0);

mean_mean_RW_latency = mean(mean_RW_latency_learning_data(1:4, :), 2, 'omitnan');
error_mean_RW_latency = std(mean_RW_latency_learning_data(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_RW_latency_learning_data(1:4, :)')));
hold on
group = errorbar(mean_mean_RW_latency, error_mean_RW_latency, "-", 'Color', 'black', 'LineWidth', 1)

axis square
    ylim([0 1200])
    ylabel("Mean Go Response Time (ms)")

    % xlim([1 size(mean_RW_latency_learning_data, 1)])
    % xticks([1:size(mean_RW_latency_learning_data, 1)])
    % xticklabels([1:size(mean_RW_latency_learning_data, 1)])
    % xlabel("Days of Go/NoGo Training")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")
    
title("Go/NoGo Learning", "Go Response Time")
%legend([mean_RW_latency_learning_anIDs], 'Location','southeast')
legend off





[mean_FA_latency_learning_data, mean_FA_latency_learning_anIDs] = group_learning(go_nogo_learning, "mean_FA_latency", 8, 0);

mean_mean_FA_latency = mean(mean_FA_latency_learning_data(1:4, :), 2, 'omitnan');
error_mean_FA_latency = std(mean_FA_latency_learning_data(1:4, :)', 'omitnan') ./ sqrt(sum(~isnan(mean_FA_latency_learning_data(1:4, :)')));
hold on
group = errorbar(mean_mean_FA_latency, error_mean_FA_latency, "-", 'Color', 'black', 'LineWidth', 1)

axis square
    ylim([0 1200])
    ylabel("Mean False Alarm Response Time (ms)")

    % xlim([1 size(mean_FA_latency_learning_data, 1)])
    % xticks([1:size(mean_FA_latency_learning_data, 1)])
    % xticklabels([1:size(mean_FA_latency_learning_data, 1)])
    % xlabel("Days of Go/NoGo Training")

    xlim([1 4])
    xticks([1:4])
    xticklabels([1:4])
    xlabel("Days of Go/NoGo Training")
    
title("Go/NoGo Learning", "NoGo Response Time")
%legend([mean_FA_latency_learning_anIDs], 'Location','southeast')
legend off