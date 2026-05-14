function photometryStruct = photometry_data_prep(photo_filename, session_date, session_time)

% Photometry data pre-processing code adapted from Evan Illiakis's importNeuroPhotoData code (Nov 2024)
% Filters, debleaches, and normalizes photometry data

photometryStruct.animalID_1 = [];
photometryStruct.phase_animal1 = [];

photometryStruct.animalID_2 = [];
photometryStruct.phase_animal2 = [];

photometryStruct.Fiber1_ID = [];
photometryStruct.Fiber2_ID = [];
photometryStruct.Fiber3_ID = [];
photometryStruct.Fiber4_ID = [];

photometryStruct.session_date = session_date;
photometryStruct.session_time = session_time;

% Open the data
    data_photo = importdata(photo_filename);

    raw_data = data_photo.data;


% Select data from each fiber/channel
    Fiber1_iso_processing = raw_data(find(raw_data(:,3) == 1), [1:4, 5]); 
    Fiber1_sig_processing = raw_data(find(raw_data(:,3) == 2), [1:4, 5]);

    Fiber2_iso_processing = raw_data(find(raw_data(:,3) == 1), [1:4, 6]);
    Fiber2_sig_processing = raw_data(find(raw_data(:,3) == 2), [1:4, 6]);

    Fiber3_iso_processing = raw_data(find(raw_data(:,3) == 1), [1:4, 7]);
    Fiber3_sig_processing = raw_data(find(raw_data(:,3) == 2), [1:4, 7]);

    Fiber4_iso_processing = raw_data(find(raw_data(:,3) == 1), [1:4, 8]);
    Fiber4_sig_processing = raw_data(find(raw_data(:,3) == 2), [1:4, 8]);

% Fix for if iso/sig files are different size 
    if size(Fiber1_iso_processing, 1) > size(Fiber1_sig_processing, 1) % test this out when issue of different sice iso/sig files arises

    	Fiber1_iso_processing = Fiber1_iso_processing(1:size(Fiber1_sig_processing, 1), :);  
    	Fiber2_iso_processing = Fiber2_iso_processing(1:size(Fiber2_sig_processing, 1), :);
    	Fiber3_iso_processing = Fiber3_iso_processing(1:size(Fiber3_sig_processing, 1), :);
    	Fiber4_iso_processing = Fiber4_iso_processing(1:size(Fiber4_sig_processing, 1), :);

    end

    if size(Fiber1_sig_processing, 1) > size(Fiber1_iso_processing, 1) % test this out when issue of different sice iso/sig files arises

        Fiber1_sig_processing = Fiber1_sig_processing(1:size(Fiber1_iso_processing, 1), :);  
        Fiber2_sig_processing = Fiber2_sig_processing(1:size(Fiber2_iso_processing, 1), :);
        Fiber3_sig_processing = Fiber3_sig_processing(1:size(Fiber3_iso_processing, 1), :);
        Fiber4_sig_processing = Fiber4_sig_processing(1:size(Fiber4_iso_processing, 1), :);

    end

% Assign signal timestamps to the iso data
	
	% System Timestamps
		Fiber1_iso_processing(:,2) = Fiber1_sig_processing(:,2);
		Fiber2_iso_processing(:,2) = Fiber2_sig_processing(:,2);
		Fiber3_iso_processing(:,2) = Fiber3_sig_processing(:,2);
		Fiber4_iso_processing(:,2) = Fiber4_sig_processing(:,2);

	% Computer Timestamps
		Fiber1_iso_processing(:,4) = Fiber1_sig_processing(:,4);
		Fiber2_iso_processing(:,4) = Fiber2_sig_processing(:,4);
		Fiber3_iso_processing(:,4) = Fiber3_sig_processing(:,4);
		Fiber4_iso_processing(:,4) = Fiber4_sig_processing(:,4);

% Remove first 400 data points

    Fiber1_iso_unfiltered = Fiber1_iso_processing(400:end, 5);
    Fiber1_sig_unfiltered = Fiber1_sig_processing(400:end, 5);
    Fiber2_iso_unfiltered = Fiber2_iso_processing(400:end, 5);
    Fiber2_sig_unfiltered = Fiber2_sig_processing(400:end, 5);
    Fiber3_iso_unfiltered = Fiber3_iso_processing(400:end, 5);
    Fiber3_sig_unfiltered = Fiber3_sig_processing(400:end, 5);
    Fiber4_iso_unfiltered = Fiber4_iso_processing(400:end, 5);
    Fiber4_sig_unfiltered = Fiber4_sig_processing(400:end, 5);

	Fiber1_iso_processing = Fiber1_iso_processing(400:end, :);
	Fiber1_sig_processing = Fiber1_sig_processing(400:end, :);
	Fiber2_iso_processing = Fiber2_iso_processing(400:end, :);
	Fiber2_sig_processing = Fiber2_sig_processing(400:end, :);
	Fiber3_iso_processing = Fiber3_iso_processing(400:end, :);
	Fiber3_sig_processing = Fiber3_sig_processing(400:end, :);
	Fiber4_iso_processing = Fiber4_iso_processing(400:end, :);
	Fiber4_sig_processing = Fiber4_sig_processing(400:end, :);


% Filter signal

    fs = numel(Fiber1_iso_processing(:,2))/(max(Fiber1_iso_processing(:,2))-min(Fiber1_iso_processing(:,2))); % Sampling frequency (Hz- should be around 40Hz)
    cutoff = 5; % Cutoff frequency of the filter (Hz)
    order = 4; % Filter order

    [item2, item1] = butter(order, cutoff/(fs/2), 'low');

    if ~isempty(Fiber1_iso_processing)
        Fiber1_iso_processing(:, 5) = filtfilt(item2, item1, Fiber1_iso_processing(:, 5));
    end

    if ~isempty(Fiber1_sig_processing)
        Fiber1_sig_processing(:, 5) = filtfilt(item2, item1, Fiber1_sig_processing(:, 5));
    end

    if ~isempty(Fiber2_iso_processing)
        Fiber2_iso_processing(:, 5) = filtfilt(item2, item1, Fiber2_iso_processing(:, 5));
    end

    if ~isempty(Fiber2_sig_processing)
        Fiber2_sig_processing(:, 5) = filtfilt(item2, item1, Fiber2_sig_processing(:, 5));
    end

    if ~isempty(Fiber3_iso_processing)
        Fiber3_iso_processing(:, 5) = filtfilt(item2, item1, Fiber3_iso_processing(:, 5));
    end

    if ~isempty(Fiber3_sig_processing)
        Fiber3_sig_processing(:, 5) = filtfilt(item2, item1, Fiber3_sig_processing(:, 5));
    end

    if ~isempty(Fiber4_iso_processing)
        Fiber4_iso_processing(:, 5) = filtfilt(item2, item1, Fiber4_iso_processing(:, 5));
    end

    if ~isempty(Fiber4_sig_processing)
        Fiber4_sig_processing(:, 5) = filtfilt(item2, item1, Fiber4_sig_processing(:, 5));
    end

    Fiber1_iso_filtered = Fiber1_iso_processing(:, 5);
    Fiber1_sig_filtered = Fiber1_sig_processing(:, 5);
    Fiber2_iso_filtered = Fiber2_iso_processing(:, 5);
    Fiber2_sig_filtered = Fiber2_sig_processing(:, 5);
    Fiber3_iso_filtered = Fiber3_iso_processing(:, 5);
    Fiber3_sig_filtered = Fiber3_sig_processing(:, 5);
    Fiber4_iso_filtered = Fiber4_iso_processing(:, 5);
    Fiber4_sig_filtered = Fiber4_sig_processing(:, 5);


% Debleach data

    % Fiber 1
        timee = Fiber1_iso_processing(:, 2);
        sig = Fiber1_iso_processing(:, 5);
        %fit2 = fit(timee,sig,'exp2','Normalize', 'on'); %fit filtered 415 data with biexponential (Evan uses)
        fit2 = fit(timee,sig,'poly3','Normalize', 'on'); %fit filtered 415 data with cubic polynomial (Elizabeth used)
        Fiber1_iso_processing(:, 5) = (sig-fit2(timee))./fit2(timee);
            clear timee sig fit2

        timee = Fiber1_sig_processing(:, 2);
        sig = Fiber1_sig_processing(:, 5);
        %fit2 = fit(timee,sig,'exp2','Normalize', 'on'); %fit filtered 470 data with biexponential
        fit2 = fit(timee,sig,'poly3','Normalize', 'on'); %fit filtered 470 data with cubic polynomial
        Fiber1_sig_processing(:, 5) = (sig-fit2(timee))./fit2(timee);
            clear timee sig fit2

    % Fiber 2
        timee = Fiber2_iso_processing(:, 2);
        sig = Fiber2_iso_processing(:, 5);
        %fit2 = fit(timee,sig,'exp2','Normalize', 'on'); %fit filtered 415 data with biexponential
        fit2 = fit(timee,sig,'poly3','Normalize', 'on'); %fit filtered 415 data with cubic polynomial
        Fiber2_iso_processing(:, 5) = (sig-fit2(timee))./fit2(timee);
            clear timee sig fit2

        timee = Fiber2_sig_processing(:, 2);
        sig = Fiber2_sig_processing(:, 5);
        %fit2 = fit(timee,sig,'exp2','Normalize', 'on'); %fit filtered 470 data with biexponential
        fit2 = fit(timee,sig,'poly3','Normalize', 'on'); %fit filtered 470 data with cubic polynomial
        Fiber2_sig_processing(:, 5) = (sig-fit2(timee))./fit2(timee);
            clear timee sig fit2

    % Fiber 3
        timee = Fiber3_iso_processing(:, 2);
        sig = Fiber3_iso_processing(:, 5);
        %fit2 = fit(timee,sig,'exp2','Normalize', 'on'); %fit filtered 415 data with biexponential
        fit2 = fit(timee,sig,'poly3','Normalize', 'on'); %fit filtered 415 data with cubic polynomial
        Fiber3_iso_processing(:, 5) = (sig-fit2(timee))./fit2(timee);
            clear timee sig fit2

        timee = Fiber3_sig_processing(:, 2);
        sig = Fiber3_sig_processing(:, 5);
        %fit2 = fit(timee,sig,'exp2','Normalize', 'on'); %fit filtered 470 data with biexponential
        fit2 = fit(timee,sig,'poly3','Normalize', 'on'); %fit filtered 470 data with cubic polynomial
        Fiber3_sig_processing(:, 5) = (sig-fit2(timee))./fit2(timee);
            clear timee sig fit2

    % Fiber 4
        timee = Fiber4_iso_processing(:, 2);
        sig = Fiber4_iso_processing(:, 5);
        %fit2 = fit(timee,sig,'exp2','Normalize', 'on'); %fit filtered 415 data with biexponential
        fit2 = fit(timee,sig,'poly3','Normalize', 'on'); %fit filtered 415 data with cubic polynomial
        Fiber4_iso_processing(:, 5) = (sig-fit2(timee))./fit2(timee);
            clear timee sig fit2

        timee = Fiber4_sig_processing(:, 2);
        sig = Fiber4_sig_processing(:, 5);
        %fit2 = fit(timee,sig,'exp2','Normalize', 'on'); %fit filtered 470 data with biexponential
        fit2 = fit(timee,sig,'poly3','Normalize', 'on'); %fit filtered 470 data with cubic polynomial
        Fiber4_sig_processing(:, 5) = (sig-fit2(timee))./fit2(timee);
            clear timee sig fit2

    Fiber1_iso_debleached = Fiber1_iso_processing(:, 5);
    Fiber1_sig_debleached = Fiber1_sig_processing(:, 5);
    Fiber2_iso_debleached = Fiber2_iso_processing(:, 5);
    Fiber2_sig_debleached = Fiber2_sig_processing(:, 5);
    Fiber3_iso_debleached = Fiber3_iso_processing(:, 5);
    Fiber3_sig_debleached = Fiber3_sig_processing(:, 5);
    Fiber4_iso_debleached = Fiber4_iso_processing(:, 5);
    Fiber4_sig_debleached = Fiber4_sig_processing(:, 5);

% Get ∆F/F

    % Fiber 1

        % Unfiltered data
            fitdata = fit(Fiber1_iso_unfiltered, Fiber1_sig_unfiltered,fittype('poly1'),'Robust','on');
            isosfitted = fitdata(Fiber1_iso_unfiltered);
            correctedData = (Fiber1_sig_unfiltered - isosfitted)./isosfitted;
            Fiber1_unfiltered_deltafoverf = 100*correctedData;         
                clear  fitdata isosfitted correctedData

        % Filtered and debleached data
            fitdata = fit(Fiber1_iso_processing(:, 5), Fiber1_sig_processing(:, 5),fittype('poly1'),'Robust','on');
            isosfitted = fitdata(Fiber1_iso_processing(:, 5));
            correctedData = Fiber1_sig_processing(:, 5) - isosfitted;
            Fiber1_debleached_deltafoverf = 100*correctedData;   
                clear  fitdata isosfitted correctedData

        % Normalized
            Fiber1_debleached_deltafoverf_norm = (Fiber1_debleached_deltafoverf-mean(Fiber1_debleached_deltafoverf))/std(Fiber1_debleached_deltafoverf);

    % Fiber 2

        % Unfiltered data
            fitdata = fit(Fiber2_iso_unfiltered, Fiber2_sig_unfiltered,fittype('poly1'),'Robust','on');
            isosfitted = fitdata(Fiber2_iso_unfiltered);
            correctedData = (Fiber2_sig_unfiltered - isosfitted)./isosfitted;
            Fiber2_unfiltered_deltafoverf = 100*correctedData;         
                clear  fitdata isosfitted correctedData

        % Filtered and debleached data
            fitdata = fit(Fiber2_iso_processing(:, 5), Fiber2_sig_processing(:, 5),fittype('poly1'),'Robust','on');
            isosfitted = fitdata(Fiber2_iso_processing(:, 5));
            correctedData = Fiber2_sig_processing(:, 5) - isosfitted;
            Fiber2_debleached_deltafoverf = 100*correctedData;   
                clear  fitdata isosfitted correctedData
                
        % Normalized
            Fiber2_debleached_deltafoverf_norm = (Fiber2_debleached_deltafoverf-mean(Fiber2_debleached_deltafoverf))/std(Fiber2_debleached_deltafoverf);

    % Fiber 3

        % Unfiltered data
            fitdata = fit(Fiber3_iso_unfiltered, Fiber3_sig_unfiltered,fittype('poly1'),'Robust','on');
            isosfitted = fitdata(Fiber3_iso_unfiltered);
            correctedData = (Fiber3_sig_unfiltered - isosfitted)./isosfitted;
            Fiber3_unfiltered_deltafoverf = 100*correctedData;         
                clear  fitdata isosfitted correctedData

        % Filtered and debleached data
            fitdata = fit(Fiber3_iso_processing(:, 5), Fiber3_sig_processing(:, 5),fittype('poly1'),'Robust','on');
            isosfitted = fitdata(Fiber3_iso_processing(:, 5));
            correctedData = Fiber3_sig_processing(:, 5) - isosfitted;
            Fiber3_debleached_deltafoverf = 100*correctedData;   
                clear  fitdata isosfitted correctedData
                
        % Normalized
            Fiber3_debleached_deltafoverf_norm = (Fiber3_debleached_deltafoverf-mean(Fiber3_debleached_deltafoverf))/std(Fiber3_debleached_deltafoverf);
    
    % Fiber 4

        % Unfiltered data
            fitdata = fit(Fiber4_iso_unfiltered, Fiber4_sig_unfiltered,fittype('poly1'),'Robust','on');
            isosfitted = fitdata(Fiber4_iso_unfiltered);
            correctedData = (Fiber4_sig_unfiltered - isosfitted)./isosfitted;
            Fiber4_unfiltered_deltafoverf = 100*correctedData;         
                clear  fitdata isosfitted correctedData

        % Filtered and debleached data
            fitdata = fit(Fiber4_iso_processing(:, 5), Fiber4_sig_processing(:, 5),fittype('poly1'),'Robust','on');
            isosfitted = fitdata(Fiber4_iso_processing(:, 5));
            correctedData = Fiber4_sig_processing(:, 5) - isosfitted;
            Fiber4_debleached_deltafoverf = 100*correctedData;   
                clear  fitdata isosfitted correctedData
                
        % Normalized
            Fiber4_debleached_deltafoverf_norm = (Fiber4_debleached_deltafoverf-mean(Fiber4_debleached_deltafoverf))/std(Fiber4_debleached_deltafoverf);

% Create final output arrays

    frame_ts_info = Fiber1_sig_processing(:, 1:2); % frame number and system timestamps

    % Output Final Normalized ∆F/F

        array_deltafoverf_norm(:, 1:2) = frame_ts_info;
        array_deltafoverf_norm(:, 3) = Fiber1_debleached_deltafoverf_norm; % Fiber 1 final data
        array_deltafoverf_norm(:, 4) = Fiber2_debleached_deltafoverf_norm; % Fiber 2 final data
        array_deltafoverf_norm(:, 5) = Fiber3_debleached_deltafoverf_norm; % Fiber 3 final data
        array_deltafoverf_norm(:, 6) = Fiber4_debleached_deltafoverf_norm; % Fiber 4 final data

    % Output Debleached, Non-Normalized ∆F/F

        array_deltafoverf_debleached(:, 1:2) = frame_ts_info;
        array_deltafoverf_debleached(:, 3) = Fiber1_debleached_deltafoverf;
        array_deltafoverf_debleached(:, 4) = Fiber2_debleached_deltafoverf;
        array_deltafoverf_debleached(:, 5) = Fiber3_debleached_deltafoverf;
        array_deltafoverf_debleached(:, 6) = Fiber4_debleached_deltafoverf;

    % Output Unfiltered ∆F/F (esentially raw)

        array_deltafoverf_unfiltered(:, 1:2) = frame_ts_info;
        array_deltafoverf_unfiltered(:, 3) = Fiber1_unfiltered_deltafoverf;
        array_deltafoverf_unfiltered(:, 4) = Fiber2_unfiltered_deltafoverf;
        array_deltafoverf_unfiltered(:, 5) = Fiber3_unfiltered_deltafoverf;
        array_deltafoverf_unfiltered(:, 6) = Fiber4_unfiltered_deltafoverf;

    % Unfiltered individual channels

        array_Fiber1_unfiltered(:, 1:2) = frame_ts_info;
        array_Fiber1_unfiltered(:, 3) = Fiber1_iso_unfiltered; % iso
        array_Fiber1_unfiltered(:, 4) = Fiber1_sig_unfiltered; % sig

        array_Fiber2_unfiltered(:, 1:2) = frame_ts_info;
        array_Fiber2_unfiltered(:, 3) = Fiber2_iso_unfiltered; % iso
        array_Fiber2_unfiltered(:, 4) = Fiber2_sig_unfiltered; % sig

        array_Fiber3_unfiltered(:, 1:2) = frame_ts_info;
        array_Fiber3_unfiltered(:, 3) = Fiber3_iso_unfiltered; % iso
        array_Fiber3_unfiltered(:, 4) = Fiber3_sig_unfiltered; % sig

        array_Fiber4_unfiltered(:, 1:2) = frame_ts_info;
        array_Fiber4_unfiltered(:, 3) = Fiber4_iso_unfiltered; % iso
        array_Fiber4_unfiltered(:, 4) = Fiber4_sig_unfiltered; % sig

    % Filtered individual channels

        array_Fiber1_filtered(:, 1:2) = frame_ts_info;
        array_Fiber1_filtered(:, 3) = Fiber1_iso_filtered; % iso
        array_Fiber1_filtered(:, 4) = Fiber1_sig_filtered; % sig

        array_Fiber2_filtered(:, 1:2) = frame_ts_info;
        array_Fiber2_filtered(:, 3) = Fiber2_iso_filtered; % iso
        array_Fiber2_filtered(:, 4) = Fiber2_sig_filtered; % sig

        array_Fiber3_filtered(:, 1:2) = frame_ts_info;
        array_Fiber3_filtered(:, 3) = Fiber3_iso_filtered; % iso
        array_Fiber3_filtered(:, 4) = Fiber3_sig_filtered; % sig

        array_Fiber4_filtered(:, 1:2) = frame_ts_info;
        array_Fiber4_filtered(:, 3) = Fiber4_iso_filtered; % iso
        array_Fiber4_filtered(:, 4) = Fiber4_sig_filtered; % sig

    % Debleached individual channels

        array_Fiber1_debleached(:, 1:2) = frame_ts_info;
        array_Fiber1_debleached(:, 3) = Fiber1_iso_debleached; % iso
        array_Fiber1_debleached(:, 4) = Fiber1_sig_debleached; % sig

        array_Fiber2_debleached(:, 1:2) = frame_ts_info;
        array_Fiber2_debleached(:, 3) = Fiber2_iso_debleached; % iso
        array_Fiber2_debleached(:, 4) = Fiber2_sig_debleached; % sig

        array_Fiber3_debleached(:, 1:2) = frame_ts_info;
        array_Fiber3_debleached(:, 3) = Fiber3_iso_debleached; % iso
        array_Fiber3_debleached(:, 4) = Fiber3_sig_debleached; % sig

        array_Fiber4_debleached(:, 1:2) = frame_ts_info;
        array_Fiber4_debleached(:, 3) = Fiber4_iso_debleached; % iso
        array_Fiber4_debleached(:, 4) = Fiber4_sig_debleached; % sig

% Final output structure

    % Processed Data
        photometryStruct.deltafoverf_normalized = array_deltafoverf_norm;
        photometryStruct.deltafoverf_debleached = array_deltafoverf_debleached;
        photometryStruct.deltafoverf_unfiltered = array_deltafoverf_unfiltered;
        % photometryStruct.Fiber1_unfiltered = array_Fiber1_unfiltered;
        % photometryStruct.Fiber2_unfiltered = array_Fiber2_unfiltered;
        % photometryStruct.Fiber3_unfiltered = array_Fiber3_unfiltered;
        % photometryStruct.Fiber4_unfiltered = array_Fiber4_unfiltered;
        % photometryStruct.Fiber1_filtered = array_Fiber1_filtered;
        % photometryStruct.Fiber2_filtered = array_Fiber2_filtered;
        % photometryStruct.Fiber3_filtered = array_Fiber3_filtered;
        % photometryStruct.Fiber4_filtered = array_Fiber4_filtered;
        % photometryStruct.Fiber1_debleached = array_Fiber1_debleached;
        % photometryStruct.Fiber2_debleached = array_Fiber2_debleached;
        % photometryStruct.Fiber3_debleached = array_Fiber3_debleached;
        % photometryStruct.Fiber4_debleached = array_Fiber4_debleached;

    % Raw data and quality control metrics

       %photometryStruct.raw_data = raw_data;

end