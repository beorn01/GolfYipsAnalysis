function saveParticipantData4(Participant_Number, name, code, group)
    % Retrieve the codename from the base workspace
    codename = evalin('base', 'codename');
    
    % Specify the directory and file name
    directoryPath = ['/Volumes/Beorn_4T/Experiment Data/SDC_', codename, '/'];
    fileName = ['Data_Subject_', codename, '.mat'];
    %fileName = 'Data_Experiment.mat'; % Name of the file to save

    
    fullFilePath = fullfile(directoryPath, fileName);

    % Create the directory if it does not exist
    if ~exist(directoryPath, 'dir')
        mkdir(directoryPath);
    end

    % Initialize the participant structure with all fields possibly required
    participantStruct = struct('Participant_Number', Participant_Number, 'Name', name, 'Code', code, 'Group', group, 'EMG_Kin_Matrix', [], 'EMG_Kin_Table', [], 'Putt_Scoring', [], 'Putt_Contact_Indices', [], 'Video_Kinematic_Allignment', []);

    % Load Data_Experiment if it exists, otherwise, initialize it
    if exist(fullFilePath, 'file')
        load(fullFilePath, 'Data_Experiment'); % Load existing Data_Experiment structure array
    else
        Data_Experiment = []; % Initialize as an empty structure array if not present
    end

    % Check for each specific variable and load it if it exists in the base workspace
    varsToCheck = {'PUTTSCYCLESMATRIX', 'TablePutts', 'allputtData', 'clusteredPeaks', 'Time_Axis_Alignment' };
    fieldNames = {'EMG_Kin_Matrix', 'EMG_Kin_Table', 'Putt_Scoring', 'Putt_Contact_Indices', 'Video_Kinematic_Allignment'};
    for i = 1:length(varsToCheck)
        if evalin('base', sprintf('exist(''%s'', ''var'')', varsToCheck{i}))
            participantStruct.(fieldNames{i}) = evalin('base', varsToCheck{i});
        end
    end

    % Add or update participant data
    index = [];
    if ~isempty(Data_Experiment)
        % Try to find the participant by number in the existing array
        index = find([Data_Experiment.Participant_Number] == Participant_Number, 1);
    end

    if isempty(index) % Add new participant if not found
        if isempty(Data_Experiment)
            Data_Experiment = participantStruct; % Initialize with the first entry
        else
            Data_Experiment(end + 1) = participantStruct; % Append as a new element
        end
    else % Update existing participant data
        % Only update fields that are not empty in participantStruct
        fieldsToUpdate = fieldnames(participantStruct);
        for i = 1:length(fieldsToUpdate)
            if ~isempty(participantStruct.(fieldsToUpdate{i}))
                Data_Experiment(index).(fieldsToUpdate{i}) = participantStruct.(fieldsToUpdate{i});
            end
        end
    end

    % Save the updated structure array to the file
    save(fullFilePath, 'Data_Experiment');
end