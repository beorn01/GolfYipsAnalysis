

clear
clc
% % Creating the cell array from the provided participant data
% list_of_participants_to_process = {
%     '001', '002', '004', '005', '006', '007', '008', '009', '011', '012', '013', '014', '015', '016', '017', '018', '019', '020', '021', '025', '028', '029', '035', '037', '038', '041', '042', '043', '044', '045', '049', '050', '051';
%     '01', '02', '04', '05', '06', '07', '08', '09', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '25', '28', '29', '35', '37', '38', '41', '42', '43', '44', '45', '49', '50', '51';
%    'Yips','Yips', 'Control', 'Control', 'Yips', 'Control', 'Yips', 'Control', 'Control', 'Control', 'Control', 'Control', 'Yips', 'Control', 'Yips', 'Control', 'Yips', 'Control', 'Yips', 'Yips', 'Control', 'Control', 'Yips', 'Control', 'Yips', 'Control', 'Yips', 'Control', 'Control', 'Yips', 'Control', 'Yips', 'Yips',
% };

% Creating the cell array from the provided table in the image without 'SDC_'
list_of_participants_to_process = {
    '046', '062', '063',  '064', '065', '066', '067';
    '46', '62', '63', '64', '65', '66', '67';
    'Yips', 'Control', 'Control', 'Yips', 'Control', 'Control', 'Yips'
};

% list_of_participants_to_process = {
%      '041' ;
%      '41';
%      'Yips'
% };


% % Creating the cell array from the provided table in the image without 'SDC_'
% list_of_participants_to_process = {
%     '004', '005';
%     '4', '5';
%     'Control', 'Yips'
% };

% Loop through each participant to process
for which_participants_to_process = 1:size(list_of_participants_to_process, 2)
    % Extract participant details
    codename = list_of_participants_to_process{1, which_participants_to_process};
    Participant_number = str2double(list_of_participants_to_process{2, which_participants_to_process});
    Type_of_participant = list_of_participants_to_process{3, which_participants_to_process};
    name_participant = sprintf('Participant %d', Participant_number);

% Participant_number = 15;
% name_participant = 'Participant 15';
% codename = '015';
% Type_of_participant = 'Control';

show_the_figure = false;
show_the_figure_liveview = false;
show_the_figure_liveview_noball = false;
check_if_hole_is_correctly_classified = true;

width_of_side_cutoff_left = .25;
width_of_side_cutoff_right = .75;

Time_Axis_Alignment_Labels = {
    'LH';
    'RH';
    'BH';
};

%aligned_data_directory = ['/Users/beorn/Dropbox/0WORK/3Project Wensen/EMG Kin Research Experiment/Data/Experiment Data/SDC_', codename, '/aligned_data.mat'];
aligned_data_directory = ['/Volumes/Beorn_4T/Experiment Data/SDC_', codename, '/aligned_data.mat'];
load(aligned_data_directory);

% Define the cell array for analysis
puttinghandtolookat = {
    'Left_Hand', 'SDC_%s_Ball_LH_R.mp4';
    'Right_Hand', 'SDC_%s_Ball_RH_R.mp4';
    'Both_Hands', 'SDC_%s_Ball_BH_R.mp4';
};

% CREATE FILE NAMES FOR PROCESSING BASED ON CODE.
for counterputtinghandtolookat = 1:size(puttinghandtolookat, 1)
    % Get the current code and convert it to string
    baseFilename = puttinghandtolookat{counterputtinghandtolookat, 2};
    currentSensorName = puttinghandtolookat{counterputtinghandtolookat, 1};
    FILEtoProcess = sprintf(baseFilename, codename);
    
    [~, ~, ext] = fileparts(FILEtoProcess);
    
    if strcmp(ext, '.mp4')
        filetorename = VideoReader(FILEtoProcess); %mag 1
    else
        % Try to launch it as a .mov file
        FILEtoProcess = strrep(FILEtoProcess, '.mp4', '.mov');
        filetorename = VideoReader(FILEtoProcess);
    end
    
    eval([puttinghandtolookat{counterputtinghandtolookat, 1} ' = filetorename;']);
end

allputtData = struct();

for LH_RH_BH = 1:size(puttinghandtolookat,1)


video = eval(puttinghandtolookat{LH_RH_BH});

% Step 1: Import the Video
%video = VideoReader('/Users/beorn/Dropbox/0WORK/3Project Wensen/EMG Kin Research Experiment/Data/Experiment Data/SDC_001/Videos/Results/SDC_001_Ball_BH_R_test1.mp4');
totalFrames = floor(video.FrameRate * video.Duration);

skipBecauseEndofPutt = false;


% Initialize a flag to indicate whether the hole mask has been created
CorrectHoleMaskYes_NO = false;
% Initialize the hole mask
holeMask = [];
% Initialize previous frame for frame differencing
previousFrame = [];




% Initialize motion detection variables for top watchbox
consecutiveMotionFrames = 0; % Counter for consecutive frames with detected motion
motionDetected = false; % Flag to indicate motion detection

% Initialize motion detection variables for bottomwatchbox
bottommotionDetected = false;
    % Define the watchbox at the bottom of the cropped frame
    bottomwatchBoxHeight = 200; % The height of the watchbox
    % Calculate the y position for the bottom watchbox to start at the bottom of the frame
    bottomWatchBoxY = [];
    % Define the watchbox with the new y position
    bottomwatchBox = []; % [x, y, width, height]
    ball_overshot_the_frame = false;

% initialize flag, designating whether it was a successful pot or not
it_was_a_succesful_putt = false;

    
    
 % Initialize a struct to log successful putts
successfulPutts = struct('frameIndex', [], 'distance', []);



% Initialize variables for tracking the ball's previous center position
prevCenterOfBallX = NaN;
prevCenterOfBallY = NaN;
stopThreshold = 2; % Threshold for minimal movement
stopFrameCountThreshold = 100; % Number of consecutive frames with minimal movement to consider the ball stopped
currentStopFrameCount = 0; % Counter for the number of consecutive frames with minimal movement

% stopFrameCountThresholdRHlastPutt = 7;

putt_counter = 1;
Observations_Counter_Per_Putt = 0;

 frame_counter = 0;


% Loop through each frame
for frameIndex = 1:totalFrames

    if ~hasFrame(video)
        disp('No more frames available, exiting the loop.');
        break;
    end
    
% Read the current frame
currentFrame = readFrame(video);

% Crop 25% off both sides of the current frame
originalWidth = size(currentFrame, 2);
cropStart = floor(originalWidth * width_of_side_cutoff_left) + 1;
cropEnd = floor(originalWidth * width_of_side_cutoff_right);
croppedFrame = currentFrame(:, cropStart:cropEnd, :);

  

   
                                    if ~CorrectHoleMaskYes_NO 


                                    % If the hole mask has not been created and we are within the first 10 frames
                                    for findtheholemask = 1:totalFrames
                                        findtheholeframe = readFrame(video);


                                    % Crop 25% off both sides of the current frame
                                    originalWidthhole = size(findtheholeframe, 2);
                                    cropStarthole = floor(originalWidthhole * width_of_side_cutoff_left) + 1;
                                    cropEndhole = floor(originalWidthhole * width_of_side_cutoff_right);
                                    croppedFramehole = findtheholeframe(:, cropStarthole:cropEndhole, :);
                                    imshow(croppedFramehole);


                                                    % % % Crop 25% off both sides (left and right) of the current frame
                                                    % % originalWidth = size(findtheholeframe, 2);
                                                    % % cropStartWidth = floor(originalWidth * 0.25) + 1;
                                                    % % cropEndWidth = floor(originalWidth * 0.75);
                                                    % % % Crop 25% off both top and bottom of the current frame
                                                    % % originalHeight = size(findtheholeframe, 1);
                                                    % % cropStartHeight = floor(originalHeight * 0.25) + 1;
                                                    % % cropEndHeight = floor(originalHeight * 0.75);
                                                    % % % Applying the crop to both dimensions
                                                    % % doublecroppedFramehole = findtheholeframe(cropStartHeight:cropEndHeight, cropStartWidth:cropEndWidth, :);
                                                    % % % Display the cropped image
                                                    % % imshow(doublecroppedFramehole);





                                    % Locate the hole and create a mask for it
                                    % This step is where you integrate your method to detect the hole
                                  % Attempt to Locate the Hole on the Cropped Frame (existing code)
                                            % Loop through each frame
                                                % %Step 2: Attempt to Locate the Hole on the Cropped Frame
                                                % lowerWhite = [200, 200, 200];
                                                % upperWhite = [255, 255, 255];
                                                % holeMask = croppedFramehole(:,:,1) >= lowerWhite(1) & croppedFramehole(:,:,1) <= upperWhite(1) & ...
                                                %            croppedFramehole(:,:,2) >= lowerWhite(2) & croppedFramehole(:,:,2) <= upperWhite(2) & ...
                                                %            croppedFramehole(:,:,3) >= lowerWhite(3) & croppedFramehole(:,:,3) <= upperWhite(3);


                                                % Adjusted lower and upper thresholds to include darker reds and browns
                                                    lowerRed = [100, 0, 0]; % Lower R value to include darker shades
                                                    upperRed = [200, 100, 100]; % Increase G and B upper limits to include browner shades
                                                       holeMask = croppedFramehole(:,:,1) >= lowerRed(1) & croppedFramehole(:,:,1) <= upperRed(1) & ...
                                                                   croppedFramehole(:,:,2) >= lowerRed(2) & croppedFramehole(:,:,2) <= upperRed(2) & ...
                                                                   croppedFramehole(:,:,3) >= lowerRed(3) & croppedFramehole(:,:,3) <= upperRed(3);


                                                                            % % Define the base color and tolerance
                                                                            % base_color = [80, 3, 4]; % The alpha channel is not used in RGB color space for masks
                                                                            % tolerance = 50;
                                                                            % 
                                                                            % % Calculate the lower and upper thresholds based on the tolerance
                                                                            % lower_threshold = max(base_color - tolerance, 0); % Ensure the lower threshold is not below 0
                                                                            % upper_threshold = min(base_color + tolerance, 255); % Ensure the upper threshold does not exceed 255
                                                                            % 
                                                                            % % Adjusted lower and upper thresholds to include the specified color range
                                                                            % lowerRed = lower_threshold; % New lower threshold based on base color and tolerance
                                                                            % upperRed = upper_threshold; % New upper threshold based on base color and tolerance
                                                                            % 
                                                                            % % Creation of the mask with the adjusted color range
                                                                            % HoleMaskDark = croppedFramehole(:,:,1) >= lowerRed(1) & croppedFramehole(:,:,1) <= upperRed(1) & ...
                                                                            %            croppedFramehole(:,:,2) >= lowerRed(2) & croppedFramehole(:,:,2) <= upperRed(2) & ...
                                                                            %            croppedFramehole(:,:,3) >= lowerRed(3) & croppedFramehole(:,:,3) <= upperRed(3);
                                                                            % 



                                                        
                                                     
                                                
                                                
                                                holeMask = holeMask;
                                                holeMask = bwareaopen(holeMask, 1250); % Clean up the mask
                                                holeMask = imfill(holeMask, 'holes'); 
                                                
                                                stats = regionprops(holeMask, 'Area', 'BoundingBox' ,'Centroid', 'Image');
                                                [~, idx] = sort([stats.Area], 'descend');
                                                
                                                if ~isempty(idx) % Ensure at least one white object was found
                                                    holeLocation = stats(idx(1)).BoundingBox;
                                                    holeLocation(1) = holeLocation(1) + cropStart - 1; % Adjust for cropping

                                                else
                                                end

                                              % Initialize currentFrameWithBoth using currentFrame to ensure we are drawing on the original frame
                                                findtheholeframe = currentFrame;
                                                % Check and draw hole location if detected
if exist('holeLocation', 'var')
    rectangle('Position', holeLocation, 'EdgeColor', 'red', 'LineWidth', 5);
end

                                               
                                              % Assuming 'holeMask' is the binary mask of the hole
                                                
                                                % Step 1: Dilate the Mask to Create a Larger Circular Disk
                                                se = strel('disk', 3); % Adjust the size ('10' here) to control the diameter of the final disk
                                                expandedMask = imdilate(holeMask, se); % Dilate the mask
                                                % Step 2: Fill in any holes to ensure the mask is a solid circular disk
                                                solidMask = imfill(expandedMask, 'holes');
                                                %solidMask = imfill(holeMask, 'holes');

                                                                                                
                                                
                                                % 'expandedMask' is now your modified hole mask, expanded to a larger, solid circular disk.
                                                
%                                                 figure(444)
%                                                 imshow(holeMask);
                                                % figure(333)
                                                % % imshow(expandedMask);
%                                                 figure(66) 
%                                                 imshow(solidMask);
                                                % 
                                                % Assuming 'solidMask' is your current mask
                                                
                                                % Step 1: Calculate the properties of the solid mask
                                                props = regionprops(solidMask, 'Centroid', 'MajorAxisLength');

                                                        % Check if there are multiple objects detected
                                                            if length(props) > 1
                                                                disp('Multiple objects detected, exiting the loop.');
                                                            clear props solidMask


                                                            else
                                                % Step 2: Extract the centroid and calculate the radius
                                                % Assuming there is only one object in 'solidMask'
                                                centroid = props.Centroid;
                                                centroid_of_hole = props.Centroid;
                                                % The radius is half of the major axis length (assuming a roughly circular object)
                                                radius = props.MajorAxisLength / 2;
                                                
                                                % Step 3: Create a new, blank mask of the same size as 'solidMask'
                                                CorrectHoleMask = false(size(solidMask));
                                                
                                                % Step 4: Generate coordinates for a grid covering the entire mask
                                                [x, y] = meshgrid(1:size(CorrectHoleMask, 2), 1:size(CorrectHoleMask, 1));
                                                
                                                % Step 5: Create a circular mask based on the calculated centroid and radius
                                                % This creates a mask where pixels inside the circle are set to true
                                                CorrectHoleMask(((x - centroid(1)).^2 + (y - centroid(2)).^2) <= radius^2) = true;


                                                                                                % Assuming 'radius' is already calculated and represents the radius of the outer circle
                                                                                                outerRadius = radius; % Radius of the outer circle
                                                                                                innerRadius = outerRadius - 5; % Radius of the inner circle, making the ring thickness 10 pixels
                                                                                                
                                                                                                % Create the outer circular mask
                                                                                                outerCircleMask = false(size(CorrectHoleMask));
                                                                                                [x, y] = meshgrid(1:size(outerCircleMask, 2), 1:size(outerCircleMask, 1));
                                                                                                outerCircleMask(((x - centroid(1)).^2 + (y - centroid(2)).^2) <= outerRadius^2) = true;
                                                                                                
                                                                                                % Create the inner circular mask
                                                                                                innerCircleMask = false(size(CorrectHoleMask));
                                                                                                innerCircleMask(((x - centroid(1)).^2 + (y - centroid(2)).^2) <= innerRadius^2) = true;
                                                                                                
                                                                                                % Subtract the inner circle from the outer circle to create a ring
                                                                                                ringMask = outerCircleMask & ~innerCircleMask;
                                                                                                
                                                                                                % 'ringMask' is now your annular mask with the specified thickness
                                                
                                                % 'newMask' is now your more circular mask
                                                
%                                                 figure(111)
%                                                 imshow(CorrectHoleMask);


     
                                            CorrectHoleBoundaries = bwboundaries(CorrectHoleMask, 'noholes');
                                            
                                            % check to see if the hole mask
                                            % works
                                            % figure(1111); imshow(holeMask); hold on;
                                            % plot(CorrectHoleBoundaries{1,1}(:,2), CorrectHoleBoundaries{1,1}(:,1), 'r', 'LineWidth', 2);

                                                                    %%%try
                                                                    %%%motion
                                                                    %%%detection
                                                                    % if isempty(previousFrame) % Ensure there is a previous frame to compare
                                                                    % else
                                                                    % frameDiffhole = abs(rgb2gray(croppedFrame) - rgb2gray(previousFrame));
                                                                    % 
                                                                    % % Threshold to highlight moving objects (the ball)
                                                                    % motionMaskhole = frameDiffhole > 20; % Adjust threshold based on your video
                                                                    % 
                                                                    % % Clean up the motion mask
                                                                    % motionMaskhole = bwareaopen(motionMaskhole, 50); % Adjust size threshold as needed
                                                                    % motionMaskhole = imfill(motionMaskhole, 'holes');
                                                                    % 
                                                                    % % Detect moving objects
                                                                    % statshole = regionprops(motionMaskhole, 'Area', 'BoundingBox', 'Perimeter', 'Circularity', 'Centroid');
                                                                    % imshow(statshole, 'Boundingbox')
                                                                    % end

                                                    
                                                    % Once the mask is created, set the flag to true
                                                    CorrectHoleMaskYes_NO = true;




                                                    
                                            break
            
                                            end 
                                            end
                                            end
            
         
                                                % Apply the hole mask if it has been created
                                                if CorrectHoleMaskYes_NO
                                                    % For each pixel in the holeMask set to 1, set the corresponding pixel in currentFrame to black
                                                    % Assuming holeMask is a logical array of the same size as the currentFrame
                                                    for channel = 1:3 % Apply to all RGB channels
                                                        currentFrameChannel = croppedFrame(:,:,channel); % Extract one color channel
                                                        currentFrameChannel(ringMask) = 0; % Set masked pixels to black (0)
                                                        croppedFrame(:,:,channel) = currentFrameChannel; % Put the modified channel back
                                                    end
                                                end

   
                                               if check_if_hole_is_correctly_classified
                                               
                                               %imshow(croppedFrame)
                                                                    % Convert the coordinates to integers
                                                                    x = (centroid_of_hole(1,1));
                                                                    y = (centroid_of_hole(1,2));
                                                                    
                                                                    figure(22222)
                                                                    % Display the image
                                                                    imshow(croppedFrame);
                                                                    hold on;
                                                                    
                                                                    % Plot the black spot (assuming the spot size is 5x5 pixels)
                                                                    spotSize = 10;
                                                                    rectangle('Position', [x-spotSize/2, y-spotSize/2, spotSize, spotSize],...
                                                                              'FaceColor', 'k', 'EdgeColor', 'k');
                                                                    
                                                                    hold off;

                                               end
                                    
                                   
                                               if check_if_hole_is_correctly_classified
                                               break
                                               end


end

                                               if check_if_hole_is_correctly_classified
                                               break
                                               end

end

clearvars -except ringMask centroid_of_hole list_of_participants_to_process which_participants_to_process croppedFrame


% Directory containing the data folders
baseDir = '/Volumes/Beorn_4T/Experiment Data/';

% Loop through each participant folder
    % Construct the folder and file names
    codename = list_of_participants_to_process{1, which_participants_to_process};
    folderName = sprintf('SDC_%s', codename);
    matFileName = sprintf('Data_Subject_%s.mat', codename);
    matFilePath = fullfile(baseDir, folderName, matFileName);

    % Load the .mat file
    if exist(matFilePath, 'file')
        load(matFilePath, 'Data_Experiment');

        % Assuming centroid_of_hole and ringMask have been calculated:
        % Add these fields to the Putt_Scoring sub-structure
        Data_Experiment.Putt_Scoring.centroid_of_hole = centroid_of_hole;
        Data_Experiment.Putt_Scoring.ringMask = ringMask;
        Data_Experiment.Putt_Scoring.croppedframe = croppedFrame;

        % Save the updated structure back to the .mat file
        save(matFilePath, 'Data_Experiment');
    else
        warning('File %s does not exist.', matFilePath);
    end

clearvars -except list_of_participants_to_process which_participants_to_process


end

%%



% Load the image data (assuming the image is stored in a variable called 'croppedFrame')
% If the image data is in a .mat file, load it first using:
% load('Data_Subject_001.mat', 'croppedFrame');

% Convert the coordinates to integers
x = (Data_Experiment.Putt_Scoring.centroid_of_hole(1,1));
y = (Data_Experiment.Putt_Scoring.centroid_of_hole(1,2));

% Display the image
imshow(Data_Experiment.Putt_Scoring.croppedframe);
hold on;

% Plot the black spot (assuming the spot size is 5x5 pixels)
spotSize = 5;
rectangle('Position', [x-spotSize/2, y-spotSize/2, spotSize, spotSize],...
          'FaceColor', 'k', 'EdgeColor', 'k');

hold off;

%%

