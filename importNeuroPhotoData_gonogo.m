%importNeuroPhotoData

filePath = ['C:\Users\walki\Box\grp-psom-fuccillo-lab\Joystick Behavior\CanISac221'];

%are you also importing TDT photometry data?
importTDT = 0; %1 = yes, 0 = no
TDTPath = 'C:\Users\walki\Box\grp-psom-fuccillo-lab\Joystick Behavior\PhotometryDataTDT\EI-FibPho-4-23-230414-181222';

%do a similar system to TDT where you have data stored in folders and you
%cue the super-folder.

%make struct
masterPhotoStruct = [];
a = 0;

%extract subfolder names so you can call those directories and import stuff
%from them
contents = dir(filePath);
subfolders = contents([contents.isdir]);
clear contents;
subfolderNames = {subfolders.name}';
clear subfolders;
sizeFiles = size(subfolderNames,1);
for i = sizeFiles:-1:1
    if strcmp(subfolderNames(i,1),'.') == 1 || strcmp(subfolderNames(i,1),'..') == 1
        subfolderNames(i) = [];
    end
end
clear sizeFiles;
%%
%start a loop that will iterate through all the subfolders and generate
%masterPhotoStruct entries
for i = 1:size(subfolderNames,1)
    %1. pull in the photometry data and the info file
    dataPath = cell2mat(strcat(filePath,'\',subfolderNames(i,1)));
    cd(dataPath);
    if ~isempty(dir(fullfile(dataPath, 'Photometry*')))
        photoFile = dir(fullfile(dataPath, 'Photometry*')); % You can adjust the extension as needed
        if size(photoFile,1) > 1
            fprintf('There are too many photometry files found for index %d! Which one is real? Check and delete extraneous. Skipping %d.\n',i,i);
            continue;
        end
    else
        fprintf('No photometry file found for index %d! Check the folder and make sure it is all there. Skipping %d.\n',i);
        continue;
    end
    if ~isempty(dir(fullfile(dataPath, 'Info*')))
        infoFile = dir(fullfile(dataPath, 'Info*')); % You can adjust the extension as needed
        if size(infoFile,1) > 1
            fprintf('There are too many info files found for index %d! Which one is real? Check and delete extraneous. Skipping %d.\n',i,i);
            continue;
        end
    else
        fprintf('No info file found for index %d! Check the folder and make sure it is all there. Skipping %d.\n',i);
        continue;
    end
    if ~isempty(dir(fullfile(dataPath, 'TTL*')))
        TTLFile = dir(fullfile(dataPath, 'TTL*')); % You can adjust the extension as needed
        if size(TTLFile,1) > 1
            fprintf('There are too many TTL files found for index %d! Which one is real? Check and delete extraneous. Skipping %d.\n',i,i);
            continue;
        end
    else
        fprintf('No TTL file found for index %d! Check the folder and make sure it is all there. Skipping %d.\n',i);
        continue;
    end
    if ~isempty(dir(fullfile(dataPath, 'CoolTerm*.txt')))
        allFiles = dir(fullfile(dataPath, 'CoolTerm*.txt'));
        CoolTermFile = allFiles(cellfun(@(x) isempty(strfind(x, '_')), {allFiles.name}));
        if size(CoolTermFile,1) > 1
            fprintf('There are too many CoolTerm TTL config files found for index %d! Which one is real? Check and delete extraneous. Skipping %d.\n',i,i);
            continue;
        elseif size(CoolTermFile,1) ==  0
            fprintf('No CoolTerm TTL config file found for index %d! Check the folder and make sure it is all there. Skipping %d.\n',i,i);
            continue;
        end
    else
        fprintf('No CoolTerm TTL config file found for index %d! Check the folder and make sure it is all there. Skipping %d.\n',i,i);
        continue;
    end




    %2. Pull in the data from the file.
    photoData = importdata(photoFile.name);
    infoData = readtable(infoFile.name);
    TTLData = importdata(TTLFile.name);
    CoolTermData = importdata(CoolTermFile.name);

    %3. Determine how many data entries are in the info file.
    numEntr = size(infoData,1);

    %4. Import each entry into the masterPhotoStruct as its own field based on
    %the information in the infoData.
    for k = 1:numEntr
        a = a+1;
        %incorporate essential info
        branch = infoData.Branch(k);
        animal = infoData.Animal(k);
        side = infoData.Side(k);
        masterPhotoStruct(a).animal = animal;
        masterPhotoStruct(a).branch = branch;
        masterPhotoStruct(a).side = side;
        masterPhotoStruct(a).photoData = photoData;
        masterPhotoStruct(a).filePath = photoFile;
        masterPhotoStruct(a).infoData = infoData;
        masterPhotoStruct(a).TTLData = TTLData;
        masterPhotoStruct(a).coolTermData = CoolTermData;



        %incorporate behavioral file and data
        behFileStr = strcat('*_',num2str(animal),'_*');
        masterPhotoStruct(a).fileName = dir(strcat('*_',num2str(animal),'_*')).name;
        fileEdit = extractAfter(masterPhotoStruct(a).fileName, 'Capture ');
        masterPhotoStruct(a).date = extractBefore(fileEdit,' ');
        fileEdit = extractAfter(fileEdit, ' ');
        masterPhotoStruct(a).time = extractBefore(fileEdit,'_');
        fileEdit = extractAfter(fileEdit,'_');
        masterPhotoStruct(a).box = str2num(extractBefore(fileEdit,'_'));
        fileEdit = extractAfter(fileEdit,'_');
        masterPhotoStruct(a).animalID = str2num(extractBefore(fileEdit,'_'));
        fileEdit = extractAfter(fileEdit,'_');
        masterPhotoStruct(a).phase = str2num(extractBefore(fileEdit,'_'));
        fileEdit = extractAfter(fileEdit,'_');
        masterPhotoStruct(a).sessionNumber = str2num(extractBefore(fileEdit,'.txt'));
        myData = importdata(masterPhotoStruct(a).fileName);
        masterPhotoStruct(a).raw = array2table(myData(1).data);
        masterPhotoStruct(a).raw.Properties.VariableNames = myData(1).colheaders;

        %incorporate TTL file and corresponding coolterm

        %a. get the relevant photometry data
        %find system timestamp index
        sysTimeIndex = find(strcmp(photoData.textdata,'SystemTimestamp'));
        %find LEDState index
        ledStateIndex = find(strcmp(photoData.textdata,'LedState'));
        masterPhotoStruct(a).systemTimes = photoData.data(find(photoData.data(:,ledStateIndex) == 2),sysTimeIndex);
        if isempty(photoData.data(find(photoData.data(:,ledStateIndex) == 2),sysTimeIndex))
            masterPhotoStruct(a).systemTimes = photoData.data(find(photoData.data(:,ledStateIndex) == 4),sysTimeIndex);
        end
        masterPhotoStruct(a).startTime = masterPhotoStruct(a).systemTimes(1,1);
        masterPhotoStruct(a).ts = masterPhotoStruct(a).systemTimes-masterPhotoStruct(a).startTime;
        if ismember(strcat('G',num2str(branch)), photoData.textdata)
            fprintf('There is 415nm/470nm (green) in index %d, entry %d.\n',i,k);
            GIndex = find(strcmp(photoData.textdata,strcat('G',num2str(branch))));
            masterPhotoStruct(a).e415 = photoData.data(find(photoData.data(:,ledStateIndex)==1),GIndex);
            masterPhotoStruct(a).e470 = photoData.data(find(photoData.data(:,ledStateIndex)==2),GIndex);
            if size(masterPhotoStruct(a).e415,1) < size(masterPhotoStruct(a).e470,1)
                masterPhotoStruct(a).e470 = masterPhotoStruct(a).e470(1:size(masterPhotoStruct(a).e415,1),:);
                masterPhotoStruct(a).systemTimes = masterPhotoStruct(a).systemTimes(1:size(masterPhotoStruct(a).e415,1),:);
                masterPhotoStruct(a).ts = masterPhotoStruct(a).ts(1:size(masterPhotoStruct(a).e415,1),:);
            end
        else
            fprintf('There is no 415nm/470nm (green) in index %d, entry %d.\n',i,k);
            %masterPhotoStruct(a).e415 = [];
            masterPhotoStruct(a).e470 = [];
            GIndex = [];
        end
        if ismember(strcat('R',num2str(branch+4)), photoData.textdata) && ~isempty(find(photoData.data(:,ledStateIndex) == 4))
            fprintf('There is 560nm (red) in index %d, entry %d.\n',i,k);
            RIndex = find(strcmp(photoData.textdata,strcat('R',num2str(branch+4))));
            masterPhotoStruct(a).e560 = photoData.data(find(photoData.data(:,ledStateIndex)==4),RIndex);
            if isempty(GIndex)
                masterPhotoStruct(a).e415 = photoData.data(find(photoData.data(:,ledStateIndex)==1),RIndex);
            end
            if size(masterPhotoStruct(a).e415,1) < size(masterPhotoStruct(a).e560,1)
                masterPhotoStruct(a).e560 = masterPhotoStruct(a).e560(1:size(masterPhotoStruct(a).e415,1),:);
                masterPhotoStruct(a).systemTimes = masterPhotoStruct(a).systemTimes(1:size(masterPhotoStruct(a).e415,1),:);
                masterPhotoStruct(a).ts = masterPhotoStruct(a).ts(1:size(masterPhotoStruct(a).e415,1),:);
            end
            if size(masterPhotoStruct(a).e560,1) < size(masterPhotoStruct(a).e415,1)
                if ~isempty(GIndex)
                    masterPhotoStruct(a).e470 = masterPhotoStruct(a).e470(1:size(masterPhotoStruct(a).e560,1),:);
                end
                masterPhotoStruct(a).e415 = masterPhotoStruct(a).e415(1:size(masterPhotoStruct(a).e560,1),:);
                masterPhotoStruct(a).systemTimes = masterPhotoStruct(a).systemTimes(1:size(masterPhotoStruct(a).e560,1),:);
                masterPhotoStruct(a).ts = masterPhotoStruct(a).ts(1:size(masterPhotoStruct(a).e560,1),:);
            end
        else
            fprintf('There is no 560nm (red) in index %d, entry %d.\n',i,k);
            masterPhotoStruct(a).e560 = [];
        end
    end

    fs = numel(masterPhotoStruct(i).ts)/(max(masterPhotoStruct(i).ts)-min(masterPhotoStruct(i).ts)); % Sampling frequency (Hz)
    cutoff = 5; % Cutoff frequency of the filter (Hz)
    order = 4; % Filter order

    [item2, item1] = butter(order, cutoff/(fs/2), 'low');

    %filter
    if ~isempty(masterPhotoStruct(a).e415)
        %masterPhotoStruct(a).e415 = filtfilt(ones(1,4)/4,1, masterPhotoStruct(a).e415);
        masterPhotoStruct(a).e415 = filtfilt(item2, item1, masterPhotoStruct(a).e415);
    end
    if ~isempty(masterPhotoStruct(a).e470)
        %masterPhotoStruct(a).e470 = filtfilt(ones(1,4)/4,1, masterPhotoStruct(a).e470);
        masterPhotoStruct(a).e470 = filtfilt(item2, item1, masterPhotoStruct(a).e470);
    end
    if ~isempty(masterPhotoStruct(a).e560)
        %masterPhotoStruct(a).e560 = filtfilt(ones(1,4)/4,1, masterPhotoStruct(a).e560);
        masterPhotoStruct(a).e560 = filtfilt(item2, item1, masterPhotoStruct(a).e560);
    end
end
%% Extract behavioral info
[masterPhotoStruct] = sortByTrial(masterPhotoStruct);
[masterPhotoStruct] = extractVars(masterPhotoStruct);

% %% Delete the first 500 frames
%
% masterPhotoStruct(i).e415 = masterPhotoStruct(i).e415(501:end,:);
% masterPhotoStruct(i).ts = masterPhotoStruct(i).ts(501:end,:);
% if ~isempty(masterPhotoStruct(i).e470)
%     masterPhotoStruct(i).e470 = masterPhotoStruct(i).e470(501:end,:);
% end
% if ~isempty(masterPhotoStruct(i).e560)
%     masterPhotoStruct(i).e560 = masterPhotoStruct(i).e560(501:end,:);
% end

%% Get deltaF/F for 470/560 as applicable
for i = 1:size(masterPhotoStruct,2)
    %debleach the data
    %[dfof_415, mod_415, fit_415, offset_415] =debleachBDH(masterPhotoStruct(i).ts',masterPhotoStruct(i).e415,1);
    time = masterPhotoStruct(i).ts(400:end);
    sig = masterPhotoStruct(i).e415(400:end);
    fit2 = fit(time,sig,'exp2','Normalize', 'on'); %fit raw 415 with biexponential.
    dfof_415 = (sig-fit2(time))./fit2(time);
    masterPhotoStruct(i).dfof_415 = dfof_415;

    if ~isempty(masterPhotoStruct(i).e470)
        %[dfof_470, mod_470, fit_470, offset_470]=debleachBDH(masterPhotoStruct(i).ts',masterPhotoStruct(i).e470,1);
        %masterPhotoStruct(i).dfof_470 = dfof_470;
        time = masterPhotoStruct(i).ts(400:end);
        sig = masterPhotoStruct(i).e470(400:end);
        fit2 = fit(time,sig,'exp2','Normalize', 'on'); %fit raw 470 with biexponential.
        dfof_470 = (sig-fit2(time))./fit2(time);
        masterPhotoStruct(i).dfof_470 = dfof_470;
    end

    if ~isempty(masterPhotoStruct(i).e560)
        %         [dfof_560, mod_560, fit_560, offset_560]=debleachBDH(masterPhotoStruct(i).ts',masterPhotoStruct(i).e560,1);
        %         masterPhotoStruct(i).dfof_560 = dfof_560;
        time = masterPhotoStruct(i).ts(400:end);
        sig = masterPhotoStruct(i).e560(400:end);
        fit2 = fit(time,sig,'exp2','Normalize', 'on'); %fit raw 560 with biexponential.
        dfof_560 = (sig-fit2(time))./fit2(time);
        masterPhotoStruct(i).dfof_560 = dfof_560;
    end

    %fit signals and get dff
    if ~isempty(masterPhotoStruct(i).e470)
        %Get green
        fitdata = fit(masterPhotoStruct(i).e415, masterPhotoStruct(i).e470,fittype('poly1'),'Robust','on');
        isosfitted=fitdata(masterPhotoStruct(i).e415);
        correctedData=(masterPhotoStruct(i).e470-isosfitted)./isosfitted;
        masterPhotoStruct(i).normDat_green = 100*correctedData;

        %get green_DB
        fitdata = fit(masterPhotoStruct(i).dfof_415, masterPhotoStruct(i).dfof_470,fittype('poly1'),'Robust','on');
        isosfitted=fitdata(masterPhotoStruct(i).dfof_415);
        correctedData=masterPhotoStruct(i).dfof_470-isosfitted;
        masterPhotoStruct(i).normDat_green_DB = 100*correctedData;

        %get green_DBZ
        masterPhotoStruct(i).normDat_green_DBZ = (masterPhotoStruct(i).normDat_green_DB-mean(masterPhotoStruct(i).normDat_green_DB))/std(masterPhotoStruct(i).normDat_green_DB);


        %         reg_green = polyfit(masterPhotoStruct(i).e415, masterPhotoStruct(i).e470, 1);
        %         a_green = reg_green(1);
        %         b_green = reg_green(2);
        %         controlFit_green = a_green.*masterPhotoStruct(i).e415 + b_green; %I want to keep this
        %         masterPhotoStruct(i).normDat_green = (masterPhotoStruct(i).e470 - controlFit_green)./ controlFit_green; %this gives deltaF/F
        %         masterPhotoStruct(i).normDat_green = masterPhotoStruct(i).normDat_green * 100; % get %I want to keep this
        %
        %         dfofCorr=subtract_refBDH(time,dfof_470,dfof_415,'None'); % I want to keep this %for some stupid reason, it still says subtract, but it isn't. on the other one, it is.
        %         dfofCorr_sub=subtract_refBDH(time,dfof_470,dfof_415,'Subtract'); % I want to keep this
        %         masterPhotoStruct(i).normDat_green_DB = 100*dfofCorr_sub'; % I want to keep this
        %         masterPhotoStruct(i).normDat_green_DBZ = (masterPhotoStruct(i).normDat_green_DB-mean(masterPhotoStruct(i).normDat_green_DB))/std(masterPhotoStruct(i).normDat_green_DB); % I want to keep this
    end
    if ~isempty(masterPhotoStruct(i).e560)
        %Get red
        fitdata = fit(masterPhotoStruct(i).e415, masterPhotoStruct(i).e560,fittype('poly1'),'Robust','on');
        isosfitted=fitdata(masterPhotoStruct(i).e415);
        correctedData=(masterPhotoStruct(i).e560-isosfitted)./isosfitted;
        masterPhotoStruct(i).normDat_red = 100*correctedData;

        %get red_DB
        fitdata = fit(masterPhotoStruct(i).dfof_415, masterPhotoStruct(i).dfof_560,fittype('poly1'),'Robust','on');
        isosfitted=fitdata(masterPhotoStruct(i).dfof_415);
        correctedData=masterPhotoStruct(i).dfof_560-isosfitted;
        masterPhotoStruct(i).normDat_red_DB = 100*correctedData;

        %get red_DBZ
        masterPhotoStruct(i).normDat_red_DBZ = (masterPhotoStruct(i).normDat_red_DB-mean(masterPhotoStruct(i).normDat_red_DB))/std(masterPhotoStruct(i).normDat_red_DB);
        %         reg_red = polyfit(masterPhotoStruct(i).e415, masterPhotoStruct(i).e560, 1);
        %         a_red = reg_red(1);
        %         b_red = reg_red(2);
        %         controlFit_red = a_red.*masterPhotoStruct(i).e415 + b_red; %I want to keep this
        %         masterPhotoStruct(i).normDat_red = (masterPhotoStruct(i).e560 - controlFit_red)./ controlFit_red; %this gives deltaF/F
        %         masterPhotoStruct(i).normDat_red = masterPhotoStruct(i).normDat_red * 100; % get %I want to keep this
        %
        %         dfofCorr=subtract_refBDH(masterPhotoStruct(i).ts',dfof_560,dfof_415,'None'); % I want to keep this %for some stupid reason, it still says subtract, but it isn't. on the other one, it is.
        %         dfofCorr_sub=subtract_refBDH(masterPhotoStruct(i).ts',dfof_560,dfof_415,'Subtract'); % I want to keep this
        %         masterPhotoStruct(i).normDat_red_DB = 100*dfofCorr_sub'; % I want to keep this
        %         masterPhotoStruct(i).normDat_red_DBZ = (masterPhotoStruct(i).normDat_red_DB-mean(masterPhotoStruct(i).normDat_red_DB))/std(masterPhotoStruct(i).normDat_red_DB); % I want to keep this


    end
end

%% Synchronize the clocks and get BxTs.
synchronizeClocks;

%% Get rid of anything that isn't phase 5 or up.
for i = size(masterPhotoStruct,2):-1:1
    if masterPhotoStruct(i).phase < 5
        masterPhotoStruct(i) = [];
    end
end



%% Import TDT if applicable
if importTDT == 1
    masterPhotoStructNP = masterPhotoStruct;
    [masterPhotoStruct] = importPhotoData(TDTPath);
    for i = 1:numel(masterPhotoStructNP)
        masterPhotoStructNP(i).origin = 'NP';
        masterPhotoStructNP(i).S = [];
        masterPhotoStructNP(i).startUnix = [];
        masterPhotoStructNP(i).dat1 = [];
        masterPhotoStructNP(i).dat2 = [];
        masterPhotoStructNP(i).controlFit = [];
        masterPhotoStructNP(i).dfofCorr = [];
        masterPhotoStructNP(i).dfofCorr_sub = [];
        if ~isfield(masterPhotoStructNP(i),'normDat_red')
            masterPhotoStructNP(i).normDat_red = [];
        end
        if ~isfield(masterPhotoStructNP(i),'normDat_green')
            masterPhotoStructNP(i).normDat_green = [];
        end
        if ~isfield(masterPhotoStructNP(i),'normDat_red_DB')
            masterPhotoStructNP(i).normDat_red_DB = [];
        end
        if ~isfield(masterPhotoStructNP(i),'normDat_green_DB')
            masterPhotoStructNP(i).normDat_green_DB = [];
        end
        if ~isfield(masterPhotoStructNP(i),'normDat_red_DBZ')
            masterPhotoStructNP(i).normDat_red_DBZ = [];
        end
        if ~isfield(masterPhotoStructNP(i),'normDat_green_DBZ')
            masterPhotoStructNP(i).normDat_green_DBZ = [];
        end
        if ~isfield(masterPhotoStructNP(i),'dfof_560')
            masterPhotoStructNP(i).dfof_560 = [];
        end
        if ~isfield(masterPhotoStructNP(i),'dfof_470')
            masterPhotoStructNP(i).dfof_470 = [];
        end


    end
    for i = 1:numel(masterPhotoStruct)
        masterPhotoStruct(i).origin = 'TDT';
        masterPhotoStruct(i).e415 = masterPhotoStruct(i).dat2;
        masterPhotoStruct(i).e470 = masterPhotoStruct(i).dat1;
        masterPhotoStruct(i).e560 = [];

        %fit and debleach
        time = masterPhotoStruct(i).ts(400:end);
        sig = masterPhotoStruct(i).e415(400:end);
        fit2 = fit(time,sig,'exp2','Normalize', 'on'); %fit raw 415 with biexponential.
        dfof_415 = (sig-fit2(time))./fit2(time);
        masterPhotoStruct(i).dfof_415 = dfof_415;
        time = masterPhotoStruct(i).ts(400:end);
        sig = masterPhotoStruct(i).e470(400:end);
        fit2 = fit(time,sig,'exp2','Normalize', 'on'); %fit raw 470 with biexponential.
        dfof_470 = (sig-fit2(time))./fit2(time);
        masterPhotoStruct(i).dfof_470 = dfof_470;

        %Get green
        fitdata = fit(masterPhotoStruct(i).e415, masterPhotoStruct(i).e470,fittype('poly1'),'Robust','on');
        isosfitted=fitdata(masterPhotoStruct(i).e415);
        correctedData=(masterPhotoStruct(i).e470-isosfitted)./isosfitted;
        masterPhotoStruct(i).normDat_green = 100*correctedData;

        %get green_DB
        fitdata = fit(masterPhotoStruct(i).dfof_415, masterPhotoStruct(i).dfof_470,fittype('poly1'),'Robust','on');
        isosfitted=fitdata(masterPhotoStruct(i).dfof_415);
        correctedData=masterPhotoStruct(i).dfof_470-isosfitted;
        masterPhotoStruct(i).normDat_green_DB = 100*correctedData;

        %get green_DBZ
        masterPhotoStruct(i).normDat_green_DBZ = (masterPhotoStruct(i).normDat_green_DB-mean(masterPhotoStruct(i).normDat_green_DB))/std(masterPhotoStruct(i).normDat_green_DB);

        masterPhotoStruct(i).animal = masterPhotoStruct(i).animalID;
        masterPhotoStruct(i).branch = [];
        masterPhotoStruct(i).side = [];
        masterPhotoStruct(i).photoData = [];
        masterPhotoStruct(i).filePath = [];
        masterPhotoStruct(i).infoData = [];
        masterPhotoStruct(i).TTLData = [];
        masterPhotoStruct(i).coolTermData = [];
        masterPhotoStruct(i).systemTimes = [];
        masterPhotoStruct(i).startTime = [];
        masterPhotoStruct(i).dfof_560 = [];
        masterPhotoStruct(i).normDat_red = [];
        masterPhotoStruct(i).normDat_red_DB = [];
        masterPhotoStruct(i).normDat_red_DBZ = [];
        masterPhotoStruct(i).bxTs = [];



    end
    masterPhotoStruct = rmfield(masterPhotoStruct,'normDat');
    masterPhotoStruct = rmfield(masterPhotoStruct,'normDat_DB');
    masterPhotoStruct = rmfield(masterPhotoStruct,'normDat_DBZ');

    %get the bxTs

    %extract timings of TTL1 and 2 from raw behavioral output
    for i = 1:size(masterPhotoStruct,2)
        if any("BNCTTL1old" == string(masterPhotoStruct(i).raw.Properties.VariableNames)) == 1
            if masterPhotoStruct(i).raw.BNCTTL1old(1) == 1 && masterPhotoStruct(i).raw.BNCTTL1(1) == 0
                masterPhotoStruct(i).raw.BNCTTL1(1) = 1;
            end
        end
        masterPhotoStruct(i).TTL1bx = masterPhotoStruct(i).raw.runTime(find(masterPhotoStruct(i).raw.BNCTTL1 == 1));
        masterPhotoStruct(i).TTL2bx = masterPhotoStruct(i).raw.runTime(find(masterPhotoStruct(i).raw.BNCTTL2 == 1));
        if masterPhotoStruct(i).phase < 1
            diffs = masterPhotoStruct(i).TTL2 - masterPhotoStruct(i).TTL1;
            toDel = find(diffs < 0.66*mean(diffs));
            masterPhotoStruct(i).TTL2(toDel) = [];
            masterPhotoStruct(i).S{1,4}.timestamps(toDel,:) = [];
            masterPhotoStruct(i).TTL1(toDel) = [];
            masterPhotoStruct(i).S{1,3}.timestamps(toDel,:) = [];
        end
    end


    %delete TTLs related to starting and stopping the program.
    for i = 1:size(masterPhotoStruct,2)
        if size(masterPhotoStruct(i).TTL1,1) == size(masterPhotoStruct(i).TTL2,1)
            sizeTTLs = size(masterPhotoStruct(i).TTL1,1);
            for j = 1:sizeTTLs
                jInv = 1 + sizeTTLs - j;
                if masterPhotoStruct(i).TTL1(jInv) == masterPhotoStruct(i).TTL2(jInv)
                    masterPhotoStruct(i).TTL1(jInv) = [];
                    masterPhotoStruct(i).S{1,3}.timestamps(jInv,:) = [];
                    masterPhotoStruct(i).TTL2(jInv) = [];
                    masterPhotoStruct(i).S{1,4}.timestamps(jInv,:) = [];
                end
            end
        end
        if ~isempty(masterPhotoStruct(i).TTL2) && ~isempty(masterPhotoStruct(i).TTL1)
            if masterPhotoStruct(i).TTL2(end,1) == masterPhotoStruct(i).TTL1(end,1)
                masterPhotoStruct(i).TTL1(end,:) = [];
                masterPhotoStruct(i).S{1,3}.timestamps(end,:) = [];
                masterPhotoStruct(i).TTL2(end,:) = [];
                masterPhotoStruct(i).S{1,4}.timestamps(end,:) = [];
            end
        end
        if size(masterPhotoStruct(i).TTL1bx,1) ~= size(masterPhotoStruct(i).TTL2bx,1)
            if masterPhotoStruct(i).TTL2bx(1,1) < masterPhotoStruct(i).TTL1bx(1,1)
                masterPhotoStruct(i).TTL2bx(1,:) = [];
            end
        end
        if size(masterPhotoStruct(i).TTL1bx,1) < size(masterPhotoStruct(i).TTL1,1)
            masterPhotoStruct(i).TTL1(end,:) = [];
            masterPhotoStruct(i).S{1,3}.timestamps(end,:) = [];
        end
        if size(masterPhotoStruct(i).TTL1bx,1) > size(masterPhotoStruct(i).TTL1,1)
            masterPhotoStruct(i).TTL1bx(end,:) = [];
        end
        if size(masterPhotoStruct(i).TTL1bx,1) > size(masterPhotoStruct(i).TTL1,1)
            masterPhotoStruct(i).TTL1bx(end,:) = [];
        end

    end

    %convert ts to behavioral tx (bxTs)
    for i = 1:size(masterPhotoStruct,2)
        if ~isempty(masterPhotoStruct(i).TTL1)
            bxTs = [masterPhotoStruct(i).TTL1 masterPhotoStruct(i).TTL1bx];
            bxTs = array2table(bxTs);
            mdl = fitlm(bxTs);
            c = table2array(mdl.Coefficients(1,1));
            b = table2array(mdl.Coefficients(2,1));
            bxTs = [];
            masterPhotoStruct(i).bxTs = (masterPhotoStruct(i).ts*b) + c;
        else
            %use TTL2 if TTL1 is dropped
            if numel(masterPhotoStruct(i).TTL2bx) > numel(masterPhotoStruct(i).TTL2)
                masterPhotoStruct(i).TTL2bx = masterPhotoStruct(i).TTL2bx(1:numel(masterPhotoStruct(i).TTL2),:);
            end
            bxTs = [masterPhotoStruct(i).TTL2 masterPhotoStruct(i).TTL2bx];
            bxTs = array2table(bxTs);
            mdl = fitlm(bxTs);
            c = table2array(mdl.Coefficients(1,1));
            b = table2array(mdl.Coefficients(2,1));
            bxTs = [];
            masterPhotoStruct(i).bxTs = (masterPhotoStruct(i).ts*b) + c;
        end
    end
    masterPhotoStruct = rmfield(masterPhotoStruct,'TTL1');
    masterPhotoStruct = rmfield(masterPhotoStruct,'TTL1bx');
    masterPhotoStruct = rmfield(masterPhotoStruct,'TTL2');
    masterPhotoStruct = rmfield(masterPhotoStruct,'TTL2bx');



masterPhotoStruct = [masterPhotoStruct masterPhotoStructNP];
end

%% Get frame rates
for i = 1:numel(masterPhotoStruct)
    masterPhotoStruct(i).frameRate = numel(masterPhotoStruct(i).ts)/(max(masterPhotoStruct(i).ts)-min(masterPhotoStruct(i).ts));
end

%% Adjust lengths
for i = 1:numel(masterPhotoStruct)
    %if numel(masterPhotoStruct(i).ts) ~= numel(masterPhotoStruct(i).normDat_green_DB)
    % Adjust lengths of other variables to exclude first 400 frames
    masterPhotoStruct(i).systemTimes = masterPhotoStruct(i).systemTimes(400:end);
    masterPhotoStruct(i).ts = masterPhotoStruct(i).ts(400:end);
    masterPhotoStruct(i).bxTs = masterPhotoStruct(i).bxTs(400:end);
    masterPhotoStruct(i).e415 = masterPhotoStruct(i).e415(400:end);

    if ~isempty(masterPhotoStruct(i).e470)
        masterPhotoStruct(i).e470 = masterPhotoStruct(i).e470(400:end);
        masterPhotoStruct(i).normDat_green = masterPhotoStruct(i).normDat_green(400:end);
    end
    if ~isempty(masterPhotoStruct(i).e560)
        masterPhotoStruct(i).e560 = masterPhotoStruct(i).e560(400:end);
        masterPhotoStruct(i).normDat_red = masterPhotoStruct(i).normDat_red(400:end);
    end
    %end
end


