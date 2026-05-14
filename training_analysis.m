% Specify the folder of data to be analyzed

%folder = "C:\Users\sarfe\July2023_Behavior_Analysis";
%folder = "C:\Users\sarfe\Jan2023_Behavior";
%folder = "C:\Users\sarfe\Nov2023_Behavior_Analysis";
folder = "C:\Users\sarfe\Desktop\Data_Analysis\Feb2024_Behavior";


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
            output(i + num_files(1, 1)) = treadmill_training_funct(files(i).name, file_array{i, 2}, file_array{i, 11}, file_array{i, 12}, file_array{i, 1});
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

      output = clean_output(output, 1);
      output = reformat_output(output);

% Sort output 

    [~,index] = sortrows({output.date}.'); output = output(index); clear index
    [~,index] = sortrows({output.animalID}.'); output = output(index); clear index   

% Save workspace
    save_name = inputdlg("What should the workspace be saved as?");
    save(convertCharsToStrings(save_name));
