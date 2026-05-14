function [outputArg1,outputArg2] = create_rt_cdfs(combined_output)


group_RW_latencies_light_off = [];
group_RW_latencies_light_on = [];
group_FA_latencies_light_off = [];
group_FA_latencies_light_on = [];

for i = 1:size(combined_output, 2)
group_RW_latencies_light_off = cat(1, group_RW_latencies_light_off, combined_output(i).RW_latencies_light_off);
group_RW_latencies_light_on = cat(1, group_RW_latencies_light_on, combined_output(i).RW_latencies_light_on);

group_FA_latencies_light_off = cat(1, group_FA_latencies_light_off, combined_output(i).FA_latencies_light_off);
group_FA_latencies_light_on = cat(1, group_FA_latencies_light_on, combined_output(i).FA_latencies_light_on);

end






figure(1)
ecdf(group_RW_latencies_light_off)
hold on
ecdf(group_RW_latencies_light_on)
axis square
    ylabel("Cumulative Fraction")

    xlim([0 650]) 
    xlabel("Hit Reaction Time (ms)")

title("Group Reaction Times", "Opto-- Hits")

label_group_RW_latencies_light_off = strcat('Light Off (n =', ' ', string(sum(~isnan(group_RW_latencies_light_off))), ' trials)');
label_group_RW_latencies_light_on = strcat('Light On (n =', ' ', string(sum(~isnan(group_RW_latencies_light_on))), ' trials)');
legend(label_group_RW_latencies_light_off, label_group_RW_latencies_light_on, 'Location', 'southeast')

[h, p, ks2stat] = kstest2(group_RW_latencies_light_off, group_RW_latencies_light_on)
%[h, p, cmstat] = cmtest2(group_RW_latencies_light_off, group_RW_latencies_light_on);

text(300, 0.5, strcat('p = ', string(p)))


for i = 1:size(combined_output, 2)

    if i > 1
        group_FA_latencies_light_off = [group_FA_latencies_light_off; combined_output(i).FA_latencies_light_off];
        group_FA_latencies_light_on = [group_FA_latencies_light_on; combined_output(i).FA_latencies_light_on];
               
    else
        group_FA_latencies_light_off = combined_output(i).FA_latencies_light_off;
        group_FA_latencies_light_on = combined_output(i).FA_latencies_light_on;
    end

end

figure(2)
ecdf(group_FA_latencies_light_off)
hold on
ecdf(group_FA_latencies_light_on)
axis square
    ylabel("Cumulative Fraction")

    xlim([0 1200]) 
    xlabel("False Alarm Reaction Time (ms)")

title("Group Reaction Times", "Opto-- False Alarms")

label_group_FA_latencies_light_off = strcat('Light Off (n =', ' ', string(sum(~isnan(group_FA_latencies_light_off))), ' trials)');
label_group_FA_latencies_light_on = strcat('Light On (n =', ' ', string(sum(~isnan(group_FA_latencies_light_on))), ' trials)');
legend(label_group_FA_latencies_light_off, label_group_FA_latencies_light_on, 'Location', 'southeast')

[h, p, ks2stat] = kstest2(group_FA_latencies_light_off, group_FA_latencies_light_on)
%[h, p, cmstat] = cmtest2(group_FA_latencies_light_off, group_FA_latencies_light_on);
text(600, 0.5, strcat('p = ', string(p)))

end