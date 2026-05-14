function [outputArg1,outputArg2] = photometry_ttl_align(photometryStruct)
% Aligns photometry system TTL data with the processed photometry signal

% Align TTLs with Photometry Data Timestamps

    % System Timestamps (TS differences have a range of ~0.025ms)
        % Box 1
            photometryTimestamps_box1 = photometryStruct.deltafoverf_normalized(:, 2);
            photometryTTLs_box1 = photometryStruct.final_photoTTLs_box1;

            % Find indices of the closest photometry timestamps
                closestIdx_box1 = knnsearch(photometryTimestamps_box1, photometryTTLs_box1);

            % Get the corresponding photometry timestamps
                alignedPhotometryTimestamps_box1 = photometryTimestamps_box1(closestIdx_box1);
                TS_differences_box1 = photometryTTLs_box1 - alignedPhotometryTimestamps_box1;

            % Make binary TTL flags to add to data
                TTL_log_array_box1 = zeros(size(photometryTimestamps_box1));
                TTL_log_array_box1(closestIdx_box1) = 1;

        % Box 4
            photometryTimestamps_box4 = Fiber1_sig_processing(:,2);
            photometryTTLs_box4 = TTLs_box4(:,2);

            % Find indices of the closest photometry timestamps
                closestIdx_box4 = knnsearch(photometryTimestamps_box4, photometryTTLs_box4);

            % Get the corresponding photometry timestamps
                alignedPhotometryTimestamps_box4 = photometryTimestamps_box4(closestIdx_box4);
                TS_differences_box4 = photometryTTLs_box4 - alignedPhotometryTimestamps_box4;

            % Make binary TTL flags to add to data
                TTL_log_array_box4 = zeros(size(photometryTimestamps_box4));
                TTL_log_array_box4(closestIdx_box4) = 1;

    % % Computer Timestamps (WORSE TO USE-- TS differences have a range of ~25ms)
    %     % Box 1
    %         photometryTimestamps_box1 = Fiber1_sig_processing(:,4);
    %         photometryTTLs_box1 = TTLs_box1(:,3);

    %         % Find indices of the closest photometry timestamps
    %             closestIdx_box1 = knnsearch(photometryTimestamps_box1, photometryTTLs_box1);

    %         % Get the corresponding photometry timestamps
    %             alignedPhotometryTimestamps_box1 = photometryTimestamps_box1(closestIdx_box1);
    %             TS_differences_box1 = photometryTTLs_box1 - alignedPhotometryTimestamps_box1;

    %     % Box 4
    %         photometryTimestamps_box4 = Fiber1_sig_processing(:,4);
    %         photometryTTLs_box4 = TTLs_box4(:,3);

    %         % Find indices of the closest photometry timestamps
    %             closestIdx_box4 = knnsearch(photometryTimestamps_box4, photometryTTLs_box4);

    %         % Get the corresponding photometry timestamps
    %             alignedPhotometryTimestamps_box4 = photometryTimestamps_box4(closestIdx_box4);
    %             TS_differences_box4 = photometryTTLs_box4 - alignedPhotometryTimestamps_box4;

       photometryStruct.TTLs_box1 = TTLs_box1;
       photometryStruct.TTLs_box4 = TTLs_box4; 
       photometryStruct.number_TTLs_box1 = size(TTLs_box1, 1);
       photometryStruct.number_TTLs_box4 = size(TTLs_box4, 1);    

       photometryStruct.alignedTTL_differences_box1 = TS_differences_box1;
       photometryStruct.alignedTTL_differences_box4 = TS_differences_box4;
       photometryStruct.mean_abs_TTL_differences_box1 = mean(abs(TS_differences_box1)); % in seconds
       photometryStruct.std_abs_TTL_differences_box1 = std(abs(TS_differences_box1)); % in seconds
       photometryStruct.mean_abs_TTL_differences_box4 = mean(abs(TS_differences_box4));
       photometryStruct.std_abs_TTL_differences_box4 = std(abs(TS_differences_box4));      

end