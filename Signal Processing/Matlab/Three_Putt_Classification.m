

%%
clear
clc

Participant_number = 67;
name_participant = 'Participant 67';
codename = '067';
Type_of_participant = 'Yipper';

      

% Define the cell array for analysis
participants = {   
    'MagSensor_1', 'SDC_%s_Session1_Shimmer_7ED1_Calibrated_SD';
    'MagSensor_2', 'SDC_%s_Session1_Shimmer_7EDB_Calibrated_SD';
    'Right_Arm', 'SDC_%s_Session1_Shimmer_8AAA_Calibrated_SD';
    'Left_Arm', 'SDC_%s_Session1_Shimmer_8009_Calibrated_SD';
    'Supinator_Flex_Carp_Uln_R', 'SDC_%s_Session1_Shimmer_88F1_Calibrated_SD';
    'Pron_Teres_pron_quad_R', 'SDC_%s_Session1_Shimmer_88F4_Calibrated_SD';
    'Supinator_Flex_Carp_Uln_L', 'SDC_%s_Session1_Shimmer_88F6_Calibrated_SD';
    'Pron_Teres_pron_quad_L', 'SDC_%s_Session1_Shimmer_8FCF_Calibrated_SD';
    'Putter_Sensor', 'SDC_%s_Session1_Shimmer_541A_Calibrated_SD';
};

% CREATE FILE NAMES FOR PROCESSING BASED ON CODE.
for i = 1:height(participants)
    % Get the current code and convert it to strin
    baseFilename = participants{i,2};
    currentSensorName = participants{i,1};
    FILEtoProcess = sprintf(baseFilename, codename);
    filetorename = readtable(FILEtoProcess); %mag 1
    eval([participants{i,1} ' = filetorename;']);
end



MagSensor_1 = table2array(MagSensor_1(:,[1 2 3 4]));

MagSensor_2 = table2array(MagSensor_2(:,[1 2 3 4]));

Putter_Sensor = table2array(Putter_Sensor(:,[1 2 3 4 5 6 7 8 9 10]));

Right_Arm = table2array(Right_Arm(:,[1 2 3 4 5 6 7 8 9 10]));

Left_Arm = table2array(Left_Arm(:,[1 2 3 4 5 6 7 8 9 10]));

Supinator_Flex_Carp_Uln_R = table2array(Supinator_Flex_Carp_Uln_R(:,[1 3 4]));
Pron_Teres_pron_quad_R = table2array(Pron_Teres_pron_quad_R(:,[1 3 4]));
Supinator_Flex_Carp_Uln_L = table2array(Supinator_Flex_Carp_Uln_L(:,[1 3 4]));
Pron_Teres_pron_quad_L = table2array(Pron_Teres_pron_quad_L(:,[1 3 4]));


% Apply checkAndFixFinite function to each dataset
MagSensor_1 = checkAndFixFinite(MagSensor_1);
MagSensor_2 = checkAndFixFinite(MagSensor_2);
Putter_Sensor = checkAndFixFinite(Putter_Sensor);
Right_Arm = checkAndFixFinite(Right_Arm);
Left_Arm = checkAndFixFinite(Left_Arm);
Supinator_Flex_Carp_Uln_R = checkAndFixFinite(Supinator_Flex_Carp_Uln_R);
Pron_Teres_pron_quad_R = checkAndFixFinite(Pron_Teres_pron_quad_R);
Supinator_Flex_Carp_Uln_L = checkAndFixFinite(Supinator_Flex_Carp_Uln_L);
Pron_Teres_pron_quad_L = checkAndFixFinite(Pron_Teres_pron_quad_L);

% 
% Apply function
MagSensor_1 = checkAndFixTime(MagSensor_1);
MagSensor_2 = checkAndFixTime(MagSensor_2);
Putter_Sensor = checkAndFixTime(Putter_Sensor);
Right_Arm = checkAndFixTime(Right_Arm);
Left_Arm = checkAndFixTime(Left_Arm);
Supinator_Flex_Carp_Uln_R = checkAndFixTime(Supinator_Flex_Carp_Uln_R);
Pron_Teres_pron_quad_R = checkAndFixTime(Pron_Teres_pron_quad_R);
Supinator_Flex_Carp_Uln_L = checkAndFixTime(Supinator_Flex_Carp_Uln_L);
Pron_Teres_pron_quad_L = checkAndFixTime(Pron_Teres_pron_quad_L);



MagSensor2_aligned = interp1(MagSensor_2(:,1),MagSensor_2(:,2:4),MagSensor_1(:,1));

Right_Arm_aligned = interp1(Right_Arm(:,1),Right_Arm(:,2:10),MagSensor_1(:,1));
Left_Arm_aligned = interp1(Left_Arm(:,1),Left_Arm(:,2:10),MagSensor_1(:,1));

Supinator_Flex_Carp_Uln_R_aligned = interp1(Supinator_Flex_Carp_Uln_R(:,1),Supinator_Flex_Carp_Uln_R(:,2:3),MagSensor_1(:,1));
Pron_Teres_pron_quad_R_aligned = interp1(Pron_Teres_pron_quad_R(:,1),Pron_Teres_pron_quad_R(:,2:3),MagSensor_1(:,1));
Supinator_Flex_Carp_Uln_L_aligned = interp1(Supinator_Flex_Carp_Uln_L(:,1),Supinator_Flex_Carp_Uln_L(:,2:3),MagSensor_1(:,1));
Pron_Teres_pron_quad_L_aligned = interp1(Pron_Teres_pron_quad_L(:,1),Pron_Teres_pron_quad_L(:,2:3),MagSensor_1(:,1));

Putter_Sensor_aligned = interp1(Putter_Sensor(:,1),Putter_Sensor(:,2:10),MagSensor_1(:,1));



sensorcat = horzcat(MagSensor_1,MagSensor2_aligned,Right_Arm_aligned,Left_Arm_aligned,Supinator_Flex_Carp_Uln_R_aligned,Pron_Teres_pron_quad_R_aligned,Supinator_Flex_Carp_Uln_L_aligned,Pron_Teres_pron_quad_L_aligned,Putter_Sensor_aligned);




% Find NaN values using isnan
nanIndices = isnan(sensorcat);
% Replace NaN values with 0 using logical indexing
sensorcat(nanIndices) = 0;

AbsNormMag = horzcat(sensorcat(:,1),(abs(sensorcat(:,(2:7))-mean(sensorcat(:,(2:7))))),(sensorcat(:,(8:end))));


if Participant_number == 45
AbsNormMag = AbsNormMag((150000:end),:);
end

%AbsNormMag = horzcat(sensorcat(:,1),((sensorcat(:,(2:19)))));
%AbsNormMag = AbsNormMag((27000:end),:);
%AbsNormMag = AbsNormMag((5000:44000),:);

% AbsNormMag_edited1 = AbsNormMag((19966:end),(5:end));
% AbsNormMag_edited2 = AbsNormMag((1:end-19965),(1:4));
% AbsNormMag = horzcat(AbsNormMag_edited2, AbsNormMag_edited1);
%

%%

clearvars -except AbsNormMag Participant_number name_participant codename Type_of_participant Participant_number name_participant codename Type_of_participant threshold_of_putt_speed Threshold_of_MAG_Detection;


% clf(100);
% clf(20);
% clf(2);



threshold_of_putt_speed = 0;

Threshold_of_MAG_Detection = .04;

%Find all examples of peaks that have another peak within 
within_certain_observations = 40;
%but no other peaks within 
no_peaks_within_observsatinos = 400;

PeakHeight_For_Blocks = 30000;

Magsensorone = 4;
Magsensortwo = 7;

figure(20)
[peaks,locs1] = findpeaks(AbsNormMag(:,Magsensorone),'MinPeakHeight',Threshold_of_MAG_Detection,'MinPeakDistance',50);%
[peaks,locs2] = findpeaks(AbsNormMag(:,Magsensortwo),'MinPeakHeight',Threshold_of_MAG_Detection,'MinPeakDistance',50);%

findpeaks(AbsNormMag(:,Magsensorone),'MinPeakHeight',Threshold_of_MAG_Detection,'MinPeakDistance',50);%
hold on
findpeaks(AbsNormMag(:,Magsensortwo),'MinPeakHeight',Threshold_of_MAG_Detection,'MinPeakDistance',50);%
% hold on
% findpeaks(AbsNormMag(:,7),'MinPeakHeight',Threshold_of_MAG_Detection,'MinPeakDistance',50);%
% hold on
% findpeaks(AbsNormMag(:,8),'MinPeakHeight',Threshold_of_MAG_Detection,'MinPeakDistance',50);%
% hold on
% findpeaks(AbsNormMag(:,17),'MinPeakHeight',Threshold_of_MAG_Detection,'MinPeakDistance',50);%
% hold on
% findpeaks(AbsNormMag(:,34),'MinPeakHeight',Threshold_of_MAG_Detection,'MinPeakDistance',50);%




% % participant 22 problems (19966:end)
% 
% findpeaks(AbsNormMag(:,34),'MinPeakHeight',100,'MinPeakDistance',50);%
% hold on
% findpeaks(AbsNormMag(:,35),'MinPeakHeight',100,'MinPeakDistance',50);%
% findpeaks(AbsNormMag(:,36),'MinPeakHeight',100,'MinPeakDistance',50);%



%Find all examples of peaks that have another peak within 30 observations,
%but no other peaks within 1000 observations. 
for i = 1:length(locs1)
    value_to_search = locs1(i);

    indices_within_range = find(locs2 >= value_to_search - within_certain_observations & locs2 <= value_to_search + within_certain_observations);
    value_within_range = locs2(locs2 >= value_to_search - no_peaks_within_observsatinos & locs2 <= value_to_search + no_peaks_within_observsatinos);      

    
    if length(indices_within_range) == 1
        if size(value_within_range,1)== 1
            vector_of_locations(i,:) = horzcat(locs1(i),value_within_range, (value_within_range-locs1(i)));
            


        end
    end

end
% Find rows containing zeros, that indicate the incorrect order or peaks
% (the club is moving back over the sensors not forward)
rows_all_zeros = all(vector_of_locations == 0, 2);
% Remove rows with zeros
vector_of_locations(rows_all_zeros, :) = [];
vector_of_locations(vector_of_locations(:,3) < threshold_of_putt_speed, :) = [];

 
Putt_Contact_Unix_Timestamp = AbsNormMag((vector_of_locations(:,1)),1);


%AbsNormMag = AbsNormMag((vector_of_locations(1,1)):(vector_of_locations(end,1)),:);


%_Find the clusters of peaks (the sets of putts. For each experiment the particpant putts 6 times 30 putts.
% We use K-Means nearest neighbours here to find the "clumps" or clusters
% of putts in teh data. 

            % Assuming 'peaks' is your list of peak timestamps
            % Extract features: inter-peak intervals and peak frequencies
            peaks = vector_of_locations(:,1)';

            %to check that they are all positive i.e. the right direction
            difference_in_peaks = vector_of_locations(:,3)';
            
            interPeakIntervals = diff(peaks);
            
            peakFrequencies = 1 ./ interPeakIntervals;
            
            % Create a feature matrix
            X = [interPeakIntervals', peakFrequencies'];
            
            % Specify the number of clusters, using this analysis there are two
            % clusters - i.e. dense and sparse. The k-means finds the gaps and
            % classifies them as different from the densely packed peaks.

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%KMEAN NEAREST NEIGHBOURS %%%%%%%%%%%%%%%%%%%%
%this code to group the clusters of putts and
%insure we get 6 clusters if possible, we give it a hundred tries and otherwise we
%get the message 'can't get the right number of clusters'
% % Specify the number of clusters
% numClusters = 2;
% 
% maxIterations = 100; % Maximum number of iterations
% desiredClusterCount = 6; % Desired number of clusters
% 
% iteration = 0; % Initialize iteration counter
% actualClusterCount = 0; % Initialize the actual cluster count
% while (iteration < maxIterations) && (actualClusterCount ~= desiredClusterCount)
% 
% 
%     % Perform k-Means clustering
%     [idx, centroids] = kmeans(X, (1:size(numClusters)));
% 
% 
%     % Find indices where clusters change
%     changeIndices = find(diff([0; idx; 0]) ~= 0); 
%     % Separate peaks into clusters based on the change indices
%     clusteredPeaks = cell(1, numel(changeIndices) - 1);
% 
%    % Plot the clusters using gscatter
%     gscatter(X(:,1), X(:,2));
% 
% 
% 
%             for i = 1:numel(changeIndices) - 1
%             startIndex = changeIndices(i) + 1;
%             endIndex = changeIndices(i + 1) - 1;
%             clusteredPeaks{i} = peaks(startIndex:endIndex);
% 
%             STD_of_Clusters{i} = std(difference_in_peaks(startIndex:endIndex));
%             MEAN_of_Clusters{i} = mean(difference_in_peaks(startIndex:endIndex));
% 
% 
%             end
%             % Remove empty cells
%             clusteredPeaks = clusteredPeaks(~cellfun('isempty', clusteredPeaks));
%             STD_of_Clusters = STD_of_Clusters(~cellfun(@isnan, STD_of_Clusters));
%             MEAN_of_Clusters = MEAN_of_Clusters(~cellfun(@isnan, MEAN_of_Clusters));
% 
% 
%     % Count the number of unique clusters
%     actualClusterCount = size(clusteredPeaks,2);
% 
%     % Check if the actual number of clusters is what we want
%     if actualClusterCount == desiredClusterCount
%         break; % Exit loop if the desired number of clusters is achieved
%     end
% 
%     iteration = iteration + 1; % Increment iteration count
% 
% end
% 
% if iteration == 100
%     disp('cannot get desired numbers of clusters ');
% 
% end
%organzing the cell array to represent the fact that there should
%always be ball no ball (the two rows) and 3 hand conditions.  
% clusteredPeaks = vertcat(clusteredPeaks(1,(1:3)),clusteredPeaks(1,(4:6)));
%clearvars -except AbsNormMag clusteredPeaks vector_of_locations STD_of_Clusters MEAN_of_Clusters vector_of_locations



%%%%%%%%%%%%%%%%%%%visually checking on  whether we are capturing the %%%%%%%%%%%%%%%%%%%% right peaks
%Plot the time series data
figure(100)
plot(AbsNormMag(:,Magsensorone));
hold on;  % Keep the plot open to add vertical lines
plot(AbsNormMag(:,Magsensortwo));
% Plot vertical lines
for i = 1:length(peaks)
    x = peaks(:,i);  % Location for the vertical line
    xline(x, 'Color', 'red');  % Replace 'red' with your desired color
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%using peaks to find the sets_of_putts%%%%%%%%%%%%%%%%%%%%


figure(2)
findpeaks(X(:,1),'MinPeakHeight',PeakHeight_For_Blocks,'MinPeakDistance',17);%                     
[peaks_of_clusters,locations_of_clusters] = findpeaks(X(:,1),'MinPeakHeight',PeakHeight_For_Blocks,'MinPeakDistance',17);%


%%

% Initialize cell array to store the result
resulting_arrays = cell(1, length(locations_of_clusters) + 1);

% Iterate through each location in 'locations_of_clusters'
for i = 1:length(locations_of_clusters)
    if i == 1
        % First segment: from start to first location
        resulting_arrays{i} = peaks(1:locations_of_clusters(i)-1);
    else
        % Intermediate segments
        resulting_arrays{i} = peaks(locations_of_clusters(i-1):locations_of_clusters(i)-1);
    end
end

% Last segment: from last location to end
resulting_arrays{end} = peaks(locations_of_clusters(end):end);

resulting_arrays = vertcat(resulting_arrays(1,(1:3)),resulting_arrays(1,(4:6)));

clusteredPeaks = resulting_arrays;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% produce 5D Matrix file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    for ball_no_ball = 1:size(clusteredPeaks,1)
    
        for which_arm_RL_R_L = 1:size(clusteredPeaks,2)
    
        
            for which_obs_per_cluster =  1:size(clusteredPeaks{ball_no_ball,which_arm_RL_R_L}, 2)
    
        
                        istart = (clusteredPeaks{ball_no_ball,which_arm_RL_R_L}(which_obs_per_cluster))-500;
                        istop = (clusteredPeaks{ball_no_ball,which_arm_RL_R_L}(which_obs_per_cluster))+500;
                        puttcycle = AbsNormMag(istart:istop,:);
                        %puttcycle = puttcycle';
    
                        PUTTSCYCLESMATRIX(:,:,which_obs_per_cluster,which_arm_RL_R_L,ball_no_ball) = puttcycle;
                       
    
    
            end
        
        end
    end


clearvars -except AbsNormMag clusteredPeaks PUTTSCYCLESMATRIX jsonEntries StructPutts Participant_number name_participant codename Type_of_participant Threshold_of_MAG_Detection;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%produce TABLE file
%%%%%%%%%%%%%%%%%%%%%%%%%%%

matrix5D = PUTTSCYCLESMATRIX;

% Initialize variables for table columns
channels = [];
set_of_putts = [];
which_hand = [];
ball_no_ball = [];
values = zeros(size(matrix5D, 2)*size(matrix5D, 3)*size(matrix5D, 4)*size(matrix5D, 5), 1001);

% Counter for row index in 'values'
rowIndex = 1;

% Data_Experiment.EMG_Kin_Matrix(observations, channels, setofputts, whichhand, ballnoball)
% Iterate over the last four dimensions
for m = 1:size(matrix5D, 5)
    for l = 1:size(matrix5D, 4)
        for k = 1:size(matrix5D, 3)
            for j = 1:size(matrix5D, 2)
                % Extract the data across all time blocks for this combination
                dataAcrossTime = squeeze(matrix5D(:, j, k, l, m));

                % Assign values to the corresponding arrays
                channels = [channels; j];
                set_of_putts = [set_of_putts; k];
                which_hand = [which_hand; l];
                ball_no_ball = [ball_no_ball; m];
                values(rowIndex, :) = dataAcrossTime';

                % Increment row index
                rowIndex = rowIndex + 1;
            end
        end
    end
end

% Create a table with the collected data
TablePutts = table(channels, set_of_putts, which_hand, ball_no_ball, values);
TablePutts.Properties.VariableNames = {'Channel', 'SetOfPutts', 'WhichHand', 'BallNoBall', 'Values'};


clearvars -except clusteredPeaks  PUTTSCYCLESMATRIX TablePutts Participant_number name_participant codename Type_of_participant Threshold_of_MAG_Detection; 

%create structure to store participant data based on participant numnber,
%name codename and type of participant, and if structure exists add to
%existing structure. 
% aligned_data_directory = ['/Users/beorn/Dropbox/0WORK/3Project Wensen/EMG Kin Research Experiment/Data/Experiment Data/SDC_', codename, '/aligned_data.mat'];
aligned_data_directory = ['/Volumes/Beorn_4T/Experiment Data/SDC_', codename, '/aligned_data.mat'];
load(aligned_data_directory);
saveParticipantData4(Participant_number, name_participant, codename, Type_of_participant)

%%%%%%%%%%%%%%%%%produce JSON file from clsuteredPeaks in main directory participant%%%%%%%%%%%%%%%%%%%%
% Clear and initialize 'data' as a structured variable with nested structures
clear data;
data = struct();
data.ball = struct();
data.no_ball = struct();

% Ensure 'clusteredPeaks' is indeed a cell array
if ~iscell(clusteredPeaks)
    error('clusteredPeaks must be a cell array.');
end
% Assign values from 'clusteredPeaks' to 'data'
data.Ball.BH = clusteredPeaks{1,1};
data.Ball.RH = clusteredPeaks{1,2};
data.Ball.LH = clusteredPeaks{1,3};
data.NB.BH = clusteredPeaks{2,1};
data.NB.RH = clusteredPeaks{2,2};
data.NB.LH = clusteredPeaks{2,3};
% Convert the structured data to a JSON string
jsonString = jsonencode(data);
% Display the JSON string
disp(jsonString);

% Write JSON string to a file
% filename = ['/Users/beorn/Dropbox/0WORK/3Project Wensen/EMG Kin Research Experiment/Data/Experiment Data/SDC_', codename, '/Putt_Index_Locations.json'];
filename = ['/Volumes/Beorn_4T/Experiment Data/SDC_', codename, '/Putt_Index_Locations.json'];

fid = fopen(filename, 'w');
if fid == -1
    error('File cannot be opened');
else
    fprintf(fid, '%s', jsonString);
    fclose(fid);
end
%%%%%%%%%%%%%%%%%produce JSON file from clsuteredPeaks%%%%%%%%%%%%%%%%%%%%


%%