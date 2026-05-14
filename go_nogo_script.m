% Specify the folder of data to be analyzed

%folder = "C:\Users\sarfe\Desktop\Data_Analysis\April2024_GoNogo_Muscimol";
%folder = "C:\Users\sarfe\Desktop\Data_Analysis\May2024_Nrxn_Analysis";
%folder = "C:\Users\sarfe\Desktop\Data_Analysis\Go_Nogo_Learning_Fig"
%folder = "C:\Users\sarfe\Desktop\Data_Analysis\Aug2024_Analysis";
%folder = "C:\Users\sarfe\Desktop\Data_Analysis\Nov2024_Analysis";
%folder = "C:\Users\sarfe\Desktop\Data_Analysis\Jan2025_Analysis";
%folder = "C:\Users\sarfe\Box\Documents\Go_NoGo\March2025\Fig3_Fig4_Photometry\All_Photometry";
%folder = "C:\Users\sarfe\Desktop\Data_Analysis\May2025_Analysis";
%folder = "C:\Users\sarfe\Desktop\Data_Analysis\July2025_Analysis";
folder = "C:\Users\sarfe\Box\Documents\Go_NoGo\Final_folder_Jan2026\DREADDsz";

% Open the data
filepath = convertStringsToChars(folder);
cd(filepath);
files = dir('*.txt');
clear('num_files');

    if exist('output')
        num_files(1, 1) = size(output, 2);
    else
        num_files(1, 1) = 0;
    end

num_files(1, 2) = size(files, 1);
h = waitbar(0,'Analysis in progress...');

    for i = 1:num_files(1, 2)
        file_array{i, 4} = extractAfter(files(i).name, "Capture ");
        file_array{i, 5} = extractAfter(file_array{i, 4}, "_");
        file_array{i, 6} = extractAfter(file_array{i, 5}, "_");

        file_array{i, 1} = extractBefore(file_array{i, 4}, " "); % date
        file_array{i, 3} = extractBefore(file_array{i, 6}, ".txt"); % phase and day
        file_array{i, 2} = extractBefore(file_array{i, 5}, "_"); % animal num

        file_array{i, 7} = extractBefore(file_array{i, 1}, "-");
        file_array{i, 8} = extractAfter(file_array{i, 1}, "-");  
        file_array{i, 9} = extractBefore(file_array{i, 8}, "-"); 
        file_array{i, 10} = extractAfter(file_array{i, 8}, "-"); 

        file_array{i, 11} = extractBefore(file_array{i, 3}, "_"); % phase
        file_array{i, 12} = extractAfter(file_array{i, 3}, "_"); % day
    
        try
            output(i + num_files(1, 1)) = go_nogo_analysis_funct(files(i).name, file_array{i, 2}, file_array{i, 11}, file_array{i, 12}, file_array{i, 1}, 'true');
        catch e
                    fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
        % more error handling...
            skipping{i, 1} = files(i).name;
        end
        waitbar(i / num_files(1, 2))
    end
    close(h);

% Clean data
    
    try
      output = clean_output(output, 1);
    catch
        disp('Error cleaning output');
    end

    try
      output = reformat_output(output);
    catch
        disp('Error reformating output');
    end

% Sort output 

    [~,index] = sortrows({output.date}.'); output = output(index); clear index
    [~,index] = sortrows({output.animalID}.'); output = output(index); clear index   

% % Restore original power settings
% if ispc
%     system('powercfg -setactive original_power_scheme.txt');
% elseif ismac
%     system('sudo systemsetup -setcomputersleep On');
% elseif isunix
%     % Add Linux command to restore original power settings if needed
% else
%     disp('Unsupported OS');
% end

% Save workspace
    save_name = inputdlg("What should the workspace be saved as?");
    save(convertCharsToStrings(save_name));
