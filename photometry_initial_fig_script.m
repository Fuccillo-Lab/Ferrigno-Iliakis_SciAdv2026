% Makes initial photometry figure for photometry session data

for i = 1:size(photometryStruct, 2)

% Get behavioral data metrics
photo_behavioral(i) = photometry_go_nogo_analysis_funct(photometryStruct(i).behavioral_data_animal1_photoclock, photometryStruct(i).behavioral_data_animal2_photoclock);

end

        % Convert structures to tables
        table1 = struct2table(photometryStruct, 'AsArray', true);
        table2 = struct2table(photo_behavioral, 'AsArray', true);
        
        % Merge tables
        mergedTable = [table1, table2];
        
        % Convert back to structure
        photometryStruct = table2struct(mergedTable);
        photometryStruct = photometryStruct';
        
        clear photo_behavioral

% Use behavioral timestamps to construct figure

for i = 1:size(photometryStruct, 2)

p = 1;    
figure(i)

    subplot(6, 4, p);  % First subplot in row
    plot(photometryStruct(i).deltafoverf_unfiltered(1:100:end, 3));
    ylabel('\DeltaF/F');
    title(strcat(photometryStruct(i).Fiber1_ID, ' unfilt'), 'Interpreter', 'none');
    p = p + 1;
    
    subplot(6, 4, p);  % Second subplot in row
    plot(photometryStruct(i).deltafoverf_unfiltered(1:100:end, 4));
    title(strcat(photometryStruct(i).Fiber2_ID, ' unfilt'), 'Interpreter', 'none');
    p = p + 1;
    
    subplot(6, 4, p);  % Third subplot in row
    plot(photometryStruct(i).deltafoverf_unfiltered(1:100:end, 5));
    title(strcat(photometryStruct(i).Fiber3_ID, ' unfilt'), 'Interpreter', 'none');
    p = p + 1;
    
    subplot(6, 4, p);  % Fourth subplot in row
    plot(photometryStruct(i).deltafoverf_unfiltered(1:100:end, 6));
    title(strcat(photometryStruct(i).Fiber4_ID, ' unfilt'), 'Interpreter', 'none');
    p = p + 1;


    subplot(6, 4, p);  % First subplot in row
    plot(photometryStruct(i).deltafoverf_normalized(1:100:end, 3));
    ylabel('\DeltaF/F');
    title(strcat(photometryStruct(i).Fiber1_ID, ' final'), 'Interpreter', 'none');
    p = p + 1;
    
    subplot(6, 4, p);  % Second subplot in row
    plot(photometryStruct(i).deltafoverf_normalized(1:100:end, 4));
    title(strcat(photometryStruct(i).Fiber2_ID, ' final'), 'Interpreter', 'none');
    p = p + 1;
    
    subplot(6, 4, p);  % Third subplot in row
    plot(photometryStruct(i).deltafoverf_normalized(1:100:end, 5));
    title(strcat(photometryStruct(i).Fiber3_ID, ' final'), 'Interpreter', 'none');
    p = p + 1;
    
    subplot(6, 4, p);  % Fourth subplot in row
    plot(photometryStruct(i).deltafoverf_normalized(1:100:end, 6));
    title(strcat(photometryStruct(i).Fiber4_ID, ' final'), 'Interpreter', 'none');
    p = p + 1;


    % Plot Hit traces

        photosignal_hit_go_sound_fiber1 = [];
        photosignal_hit_go_sound_fiber2 = [];
        photosignal_hit_go_sound_fiber3 = [];
        photosignal_hit_go_sound_fiber4 = [];

        for q = 1:size(photometryStruct(i).hit_go_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            photosignal_hit_go_sound_index = find(photometryStruct(i).deltafoverf_normalized(:, 2) >= (photometryStruct(i).hit_go_sound_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_normalized(:, 2) < (photometryStruct(i).hit_go_sound_timestamps_animal1(q, 1) + 1));
                if size(photosignal_hit_go_sound_index, 1) > 80
                    photosignal_hit_go_sound_index = photosignal_hit_go_sound_index(1:80, 1);
                elseif size(photosignal_hit_go_sound_index, 1) < 80
                    photosignal_hit_go_sound_fiber1(q, :) = NaN(1, 80);
                    photosignal_hit_go_sound_fiber2(q, :) = NaN(1, 80);
                    continue
                end
            photosignal_hit_go_sound_fiber1(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_hit_go_sound_index, 3);
            photosignal_hit_go_sound_fiber2(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_hit_go_sound_index, 4);

        end

        for q = 1:size(photometryStruct(i).hit_go_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            photosignal_hit_go_sound_index = find(photometryStruct(i).deltafoverf_normalized(:, 2) >= (photometryStruct(i).hit_go_sound_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_normalized(:, 2) < (photometryStruct(i).hit_go_sound_timestamps_animal2(q, 1) + 1));
                if size(photosignal_hit_go_sound_index, 1) > 80
                    photosignal_hit_go_sound_index = photosignal_hit_go_sound_index(1:80, 1);
                elseif size(photosignal_hit_go_sound_index, 1) < 80
                    photosignal_hit_go_sound_fiber3(q, :) = NaN(1, 80);
                    photosignal_hit_go_sound_fiber4(q, :) = NaN(1, 80);
                    continue
                end
            photosignal_hit_go_sound_fiber3(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_hit_go_sound_index, 5);
            photosignal_hit_go_sound_fiber4(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_hit_go_sound_index, 6);

        end

        if size(photosignal_hit_go_sound_fiber1, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_hit_go_sound_fiber1, 1, 'omitnan');
                if size(photosignal_hit_go_sound_fiber1, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_hit_go_sound_fiber1, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_hit_go_sound_fiber1(:, 1))));
                end
            x = [1:size(photosignal_hit_go_sound_fiber1, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("Hits");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_hit_go_sound_fiber1, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_hit_go_sound_fiber2, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_hit_go_sound_fiber2, 1, 'omitnan');
                if size(photosignal_hit_go_sound_fiber2, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_hit_go_sound_fiber2, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_hit_go_sound_fiber2(:, 1))));
                end
            x = [1:size(photosignal_hit_go_sound_fiber2, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("Hits");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_hit_go_sound_fiber2, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_hit_go_sound_fiber3, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_hit_go_sound_fiber3, 1, 'omitnan');
                if size(photosignal_hit_go_sound_fiber3, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_hit_go_sound_fiber3, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_hit_go_sound_fiber3(:, 1))));
                end
            x = [1:size(photosignal_hit_go_sound_fiber3, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("Hits");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_hit_go_sound_fiber3, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 nanmax(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_hit_go_sound_fiber4, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_hit_go_sound_fiber4, 1, 'omitnan');
                if size(photosignal_hit_go_sound_fiber4, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_hit_go_sound_fiber4, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_hit_go_sound_fiber4(:, 1))));
                end
            x = [1:size(photosignal_hit_go_sound_fiber4, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("Hits");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_hit_go_sound_fiber4, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

    % Plot Miss traces

        photosignal_miss_go_sound_fiber1 = [];
        photosignal_miss_go_sound_fiber2 = [];
        photosignal_miss_go_sound_fiber3 = [];
        photosignal_miss_go_sound_fiber4 = [];

        for q = 1:size(photometryStruct(i).miss_go_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            photosignal_miss_go_sound_index = find(photometryStruct(i).deltafoverf_normalized(:, 2) >= (photometryStruct(i).miss_go_sound_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_normalized(:, 2) < (photometryStruct(i).miss_go_sound_timestamps_animal1(q, 1) + 1));
                if size(photosignal_miss_go_sound_index, 1) > 80
                    photosignal_miss_go_sound_index = photosignal_miss_go_sound_index(1:80, 1);
                elseif size(photosignal_miss_go_sound_index, 1) < 80
                    photosignal_miss_go_sound_fiber1(q, :) = NaN(1, 80);
                    photosignal_miss_go_sound_fiber2(q, :) = NaN(1, 80);
                    continue
                end
            photosignal_miss_go_sound_fiber1(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_miss_go_sound_index, 3);
            photosignal_miss_go_sound_fiber2(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_miss_go_sound_index, 4);

        end

        for q = 1:size(photometryStruct(i).miss_go_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            photosignal_miss_go_sound_index = find(photometryStruct(i).deltafoverf_normalized(:, 2) >= (photometryStruct(i).miss_go_sound_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_normalized(:, 2) < (photometryStruct(i).miss_go_sound_timestamps_animal2(q, 1) + 1));
                if size(photosignal_miss_go_sound_index, 1) > 80
                    photosignal_miss_go_sound_index = photosignal_miss_go_sound_index(1:80, 1);
                elseif size(photosignal_miss_go_sound_index, 1) < 80
                    photosignal_miss_go_sound_fiber3(q, :) = NaN(1, 80);
                    photosignal_miss_go_sound_fiber4(q, :) = NaN(1, 80);
                    continue
                end
            photosignal_miss_go_sound_fiber3(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_miss_go_sound_index, 5);
            photosignal_miss_go_sound_fiber4(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_miss_go_sound_index, 6);

        end

        if size(photosignal_miss_go_sound_fiber1, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_miss_go_sound_fiber1, 1, 'omitnan');
                if size(photosignal_miss_go_sound_fiber1, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_miss_go_sound_fiber1, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_miss_go_sound_fiber1(:, 1))));
                end
            x = [1:size(photosignal_miss_go_sound_fiber1, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("Misses");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_miss_go_sound_fiber1, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_miss_go_sound_fiber2, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_miss_go_sound_fiber2, 1, 'omitnan');
                if size(photosignal_miss_go_sound_fiber2, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_miss_go_sound_fiber2, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_miss_go_sound_fiber2(:, 1))));
                end
            x = [1:size(photosignal_miss_go_sound_fiber2, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("Misses");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_miss_go_sound_fiber2, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_miss_go_sound_fiber3, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_miss_go_sound_fiber3, 1, 'omitnan');
                if size(photosignal_miss_go_sound_fiber3, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_miss_go_sound_fiber3, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_miss_go_sound_fiber3(:, 1))));
                end
            x = [1:size(photosignal_miss_go_sound_fiber3, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("Misses");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_miss_go_sound_fiber3, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_miss_go_sound_fiber4, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_miss_go_sound_fiber4, 1, 'omitnan');
                if size(photosignal_miss_go_sound_fiber4, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_miss_go_sound_fiber4, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_miss_go_sound_fiber4(:, 1))));
                end
            x = [1:size(photosignal_miss_go_sound_fiber4, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("Misses");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_miss_go_sound_fiber4, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

    % Plot CR traces

        photosignal_cr_nogo_sound_fiber1 = [];
        photosignal_cr_nogo_sound_fiber2 = [];
        photosignal_cr_nogo_sound_fiber3 = [];
        photosignal_cr_nogo_sound_fiber4 = [];

        for q = 1:size(photometryStruct(i).cr_nogo_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            photosignal_cr_nogo_sound_index = find(photometryStruct(i).deltafoverf_normalized(:, 2) >= (photometryStruct(i).cr_nogo_sound_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_normalized(:, 2) < (photometryStruct(i).cr_nogo_sound_timestamps_animal1(q, 1) + 1));
                if size(photosignal_cr_nogo_sound_index, 1) > 80
                    photosignal_cr_nogo_sound_index = photosignal_cr_nogo_sound_index(1:80, 1);
                elseif size(photosignal_cr_nogo_sound_index, 1) < 80
                    photosignal_cr_nogo_sound_fiber1(q, :) = NaN(1, 80);
                    photosignal_cr_nogo_sound_fiber2(q, :) = NaN(1, 80);
                    continue
                end
            photosignal_cr_nogo_sound_fiber1(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_cr_nogo_sound_index, 3);
            photosignal_cr_nogo_sound_fiber2(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_cr_nogo_sound_index, 4);

        end

        for q = 1:size(photometryStruct(i).cr_nogo_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            photosignal_cr_nogo_sound_index = find(photometryStruct(i).deltafoverf_normalized(:, 2) >= (photometryStruct(i).cr_nogo_sound_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_normalized(:, 2) < (photometryStruct(i).cr_nogo_sound_timestamps_animal2(q, 1) + 1));
                if size(photosignal_cr_nogo_sound_index, 1) > 80
                    photosignal_cr_nogo_sound_index = photosignal_cr_nogo_sound_index(1:80, 1);
                elseif size(photosignal_cr_nogo_sound_index, 1) < 80
                    photosignal_cr_nogo_sound_fiber3(q, :) = NaN(1, 80);
                    photosignal_cr_nogo_sound_fiber4(q, :) = NaN(1, 80);
                    continue
                end
            photosignal_cr_nogo_sound_fiber3(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_cr_nogo_sound_index, 5);
            photosignal_cr_nogo_sound_fiber4(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_cr_nogo_sound_index, 6);

        end

        if size(photosignal_cr_nogo_sound_fiber1, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_cr_nogo_sound_fiber1, 1, 'omitnan');
                if size(photosignal_cr_nogo_sound_fiber1, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_cr_nogo_sound_fiber1, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_cr_nogo_sound_fiber1(:, 1))));
                end
            x = [1:size(photosignal_cr_nogo_sound_fiber1, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("CR");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_cr_nogo_sound_fiber1, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_cr_nogo_sound_fiber2, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_cr_nogo_sound_fiber2, 1, 'omitnan');
                if size(photosignal_cr_nogo_sound_fiber2, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_cr_nogo_sound_fiber2, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_cr_nogo_sound_fiber2(:, 1))));
                end
            x = [1:size(photosignal_cr_nogo_sound_fiber2, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("CR");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_cr_nogo_sound_fiber2, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_cr_nogo_sound_fiber3, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_cr_nogo_sound_fiber3, 1, 'omitnan');
                if size(photosignal_cr_nogo_sound_fiber3, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_cr_nogo_sound_fiber3, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_cr_nogo_sound_fiber3(:, 1))));
                end
            x = [1:size(photosignal_cr_nogo_sound_fiber3, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("CR");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_cr_nogo_sound_fiber3, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_cr_nogo_sound_fiber4, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_cr_nogo_sound_fiber4, 1, 'omitnan');
                if size(photosignal_cr_nogo_sound_fiber4, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_cr_nogo_sound_fiber4, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_cr_nogo_sound_fiber4(:, 1))));
                end
            x = [1:size(photosignal_cr_nogo_sound_fiber4, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("CR");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            %xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_cr_nogo_sound_fiber4, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

    % Plot FA traces

        photosignal_fa_nogo_sound_fiber1 = [];
        photosignal_fa_nogo_sound_fiber2 = [];
        photosignal_fa_nogo_sound_fiber3 = [];
        photosignal_fa_nogo_sound_fiber4 = [];

        for q = 1:size(photometryStruct(i).fa_nogo_sound_timestamps_animal1, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            photosignal_fa_nogo_sound_index = find(photometryStruct(i).deltafoverf_normalized(:, 2) >= (photometryStruct(i).fa_nogo_sound_timestamps_animal1(q, 1) - 1) & photometryStruct(i).deltafoverf_normalized(:, 2) < (photometryStruct(i).fa_nogo_sound_timestamps_animal1(q, 1) + 1));
                if size(photosignal_fa_nogo_sound_index, 1) > 80
                    photosignal_fa_nogo_sound_index = photosignal_fa_nogo_sound_index(1:80, 1);
                elseif size(photosignal_fa_nogo_sound_index, 1) < 80
                    photosignal_fa_nogo_sound_fiber1(q, :) = NaN(1, 80);
                    photosignal_fa_nogo_sound_fiber2(q, :) = NaN(1, 80);
                    continue
                end
            photosignal_fa_nogo_sound_fiber1(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_fa_nogo_sound_index, 3);
            photosignal_fa_nogo_sound_fiber2(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_fa_nogo_sound_index, 4);

        end

        for q = 1:size(photometryStruct(i).fa_nogo_sound_timestamps_animal2, 1) % i is the index for the photometry struct, q is the index for the trial of that session
            photosignal_fa_nogo_sound_index = find(photometryStruct(i).deltafoverf_normalized(:, 2) >= (photometryStruct(i).fa_nogo_sound_timestamps_animal2(q, 1) - 1) & photometryStruct(i).deltafoverf_normalized(:, 2) < (photometryStruct(i).fa_nogo_sound_timestamps_animal2(q, 1) + 1));
                if size(photosignal_fa_nogo_sound_index, 1) > 80
                    photosignal_fa_nogo_sound_index = photosignal_fa_nogo_sound_index(1:80, 1);
                elseif size(photosignal_fa_nogo_sound_index, 1) < 80
                    photosignal_fa_nogo_sound_fiber3(q, :) = NaN(1, 80);
                    photosignal_fa_nogo_sound_fiber4(q, :) = NaN(1, 80);
                    continue
                end
            photosignal_fa_nogo_sound_fiber3(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_fa_nogo_sound_index, 5);
            photosignal_fa_nogo_sound_fiber4(q, :) = photometryStruct(i).deltafoverf_normalized(photosignal_fa_nogo_sound_index, 6);

        end

        if size(photosignal_fa_nogo_sound_fiber1, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_fa_nogo_sound_fiber1, 1, 'omitnan');
                if size(photosignal_fa_nogo_sound_fiber1, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_fa_nogo_sound_fiber1, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_fa_nogo_sound_fiber1(:, 1))));
                end
            x = [1:size(photosignal_fa_nogo_sound_fiber1, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("FA");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_fa_nogo_sound_fiber1, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end

            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_fa_nogo_sound_fiber2, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_fa_nogo_sound_fiber2, 1, 'omitnan');
                if size(photosignal_fa_nogo_sound_fiber2, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_fa_nogo_sound_fiber2, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_fa_nogo_sound_fiber2(:, 1))));
                end
            x = [1:size(photosignal_fa_nogo_sound_fiber2, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("FA");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_fa_nogo_sound_fiber2, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end
            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_fa_nogo_sound_fiber3, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_fa_nogo_sound_fiber3, 1, 'omitnan');
                if size(photosignal_fa_nogo_sound_fiber3, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_fa_nogo_sound_fiber3, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_fa_nogo_sound_fiber3(:, 1))));
                end
            x = [1:size(photosignal_fa_nogo_sound_fiber3, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("FA");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_fa_nogo_sound_fiber3, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end
            p = p + 1;
        else
            p = p + 1;
        end

        if size(photosignal_fa_nogo_sound_fiber4, 1) > 0
            subplot(6, 4, p)
            y = mean(photosignal_fa_nogo_sound_fiber4, 1, 'omitnan');
                if size(photosignal_fa_nogo_sound_fiber4, 1) == 1
                    err = zeros(1, 80);
                else
                     err = std(photosignal_fa_nogo_sound_fiber4, 1, 'omitnan') / sqrt(sum(~isnan(photosignal_fa_nogo_sound_fiber4(:, 1))));
                end
            x = [1:size(photosignal_fa_nogo_sound_fiber4, 2)];
            shadedErrorBar(x, y, err,'lineProps','b') 
            title("FA");
            xticks([0:20:80])
            xticklabels([-1 -0.5 0 0.5 1])
            xlabel("Time from Sound Start (s)")
            ylabel(strcat('n =', ' ', string(size(photosignal_fa_nogo_sound_fiber4, 1))))
            if(max(y) < 1)
                ylim([-1 1])
            else
                ylim([-1 max(y)])
            end
            p = p + 1;
        else
            p = p + 1;
        end


if photometryStruct(i).animalID_1 ~= "n/a" & photometryStruct(i).animalID_2 ~= "n/a"
	figname = strcat('InitialFig_', photometryStruct(i).session_date, '_', photometryStruct(i).session_time, '_', photometryStruct(i).animalID_1, '_', photometryStruct(i).animalID_2, '.fig');


elseif photometryStruct(i).animalID_1 ~= "n/a"
	figname = strcat('InitialFig_', photometryStruct(i).session_date, '_', photometryStruct(i).session_time, '_', photometryStruct(i).animalID_1,  '.fig');

elseif photometryStruct(i).animalID_2 ~= "n/a"
	figname = strcat('InitialFig_', photometryStruct(i).session_date, '_', photometryStruct(i).session_time, '_', photometryStruct(i).animalID_2,  '.fig');

end

savefig(gcf, fullfile(filepath, figname));
close all
       

end

