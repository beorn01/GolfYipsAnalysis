
%%%%
%%

clear
clc
% 


% Creating the cell array from the provided table in the image without 'SDC_'
list_of_participants_to_process = {
    '046', '062', '063',  '064', '065', '066', '067';
    '46', '62', '63', '64', '65', '66', '67';
    'Yips', 'Control', 'Control', 'Yips', 'Control', 'Control', 'Yips'
};



% Loop through each participant to process
for which_participants_to_process = 1:size(list_of_participants_to_process, 2)
    % Extract participant details
    codename = list_of_participants_to_process{1, which_participants_to_process};
    Participant_number = str2double(list_of_participants_to_process{2, which_participants_to_process});
    Type_of_participant = list_of_participants_to_process{3, which_participants_to_process};
    name_participant = sprintf('Participant %d', Participant_number);



show_the_figure = false;
show_the_figure_liveview = false;
show_the_figure_liveview_noball = false;
check_if_hole_is_correctly_classified = false;

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




                                                % Adjusted lower and upper thresholds to include darker reds and browns
                                                    lowerRed = [100, 0, 0]; % Lower R value to include darker shades
                                                    upperRed = [200, 100, 100]; % Increase G and B upper limits to include browner shades
                                                       holeMask = croppedFramehole(:,:,1) >= lowerRed(1) & croppedFramehole(:,:,1) <= upperRed(1) & ...
                                                                   croppedFramehole(:,:,2) >= lowerRed(2) & croppedFramehole(:,:,2) <= upperRed(2) & ...
                                                                   croppedFramehole(:,:,3) >= lowerRed(3) & croppedFramehole(:,:,3) <= upperRed(3);


                                                        
                                                     
                                                
                                                
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
                                                % figure(66) 
                                                % imshow(solidMask);
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
                                               figure(22222)
                                               imshow(croppedFrame)
                                               end
                                    
                                   
                

                                              % if show_the_figure_liveview_noball
                                              %  figure(2222)
                                              %  imshow(croppedFrame)
                                              % end
                                    



                                              
                                    


% Define the watchbox at the top of the cropped frame
   watchBoxHeight = 200; % Adjust the height as necessary
   watchBox = [1, 1, size(croppedFrame, 2), watchBoxHeight]; % [x, y, width, height]

   % Motion detection within the watchbox across frames
   if ~motionDetected % Only check for motion if it hasn't been detected yet
       if frameIndex > 1 % Ensure there's a previous frame to compare with
           currentWatchBoxArea = imcrop(rgb2gray(croppedFrame), watchBox);
           previousWatchBoxArea = imcrop(rgb2gray(previousFrame), watchBox);
          
           
           frameDiffWatchBox = abs(currentWatchBoxArea - previousWatchBoxArea);
           motionMaskWatchBox = frameDiffWatchBox > 20; % Motion detection threshold
           motionMaskWatchBox = bwareaopen(motionMaskWatchBox, 50); % Clean up noise
           motionMaskWatchBox = imfill(motionMaskWatchBox, 'holes'); % Fill holes in the mask

           if any(motionMaskWatchBox(:))
               consecutiveMotionFrames = consecutiveMotionFrames + 1;
               if consecutiveMotionFrames >= 5 % Check for motion over 5 consecutive frames
                   motionDetected = true;
                   consecutiveMotionFrames = 0; % Reset counter
               end
           else
               consecutiveMotionFrames = 0; % Reset counter if no motion is detected
           end
       end
   end

   
   
if motionDetected
       % Proceed with existing ball tracking and processing logic
       % Starting from "if ~isempty(previousFrame)" section





if ~isempty(previousFrame) % Ensure there is a previous frame to compare

  

    % Calculate the absolute difference between the current and previous frame
    frameDiff = abs(rgb2gray(croppedFrame) - rgb2gray(previousFrame));
    
    % Threshold to highlight moving objects (the ball)
    motionMask = frameDiff > 20; % Adjust threshold based on your video
    
    % Clean up the motion mask
    motionMask = bwareaopen(motionMask, 50); % Adjust size threshold as needed
    motionMask = imfill(motionMask, 'holes');
    
    % Detect moving objects
    stats = regionprops(motionMask, 'Area', 'BoundingBox', 'Perimeter', 'Circularity', 'Centroid');
    ballDetected = false;
    
    for k = 1:length(stats)
    % Assuming stats(k) is the detected ball
    centroid = stats(k).Centroid;
    % Define a new, smaller bounding box around the centroid
    % This size can be adjusted based on the expected size of the ball
    boxSize = [100, 200]; % Example size, adjust as needed
    focusedBox = [centroid(1) - boxSize(1)/2, centroid(2) - boxSize(2)/2, boxSize(1), boxSize(2)];
    % Extract the region defined by focusedBox for further processing
    focusedBox(1) = max(1, focusedBox(1));
    focusedBox(2) = max(1, focusedBox(2));
    focusedBox(3) = min(size(croppedFrame, 2) - focusedBox(1), focusedBox(3));
    focusedBox(4) = min(size(croppedFrame, 1) - focusedBox(2), focusedBox(4));

    % Extract the region defined by focusedBox for further processing
    focusedRegion = imcrop(croppedFrame, focusedBox);
    hsvRegion = rgb2hsv(focusedRegion);

                                
    
                            % Define thresholds for the specific gray-blue color (approximations for #667086)
                            hueThresholdLowGrayBlue = 0.55; % Normalized hue, adjusted for the cooler, less vibrant hue
                            hueThresholdHighGrayBlue = 0.65; % Normalized hue, reflecting the subdued blue tones
                            satThresholdLowGrayBlue = 0.2; % Lower saturation, indicative of the grayish component
                            satThresholdHighGrayBlue = 0.5; % Reflecting the subdued nature of the color
                            valThresholdLowGrayBlue = 0.3; % Moderate brightness, accommodating the gray-blue's lightness
                            valThresholdHighGrayBlue = 0.7; % Not too bright, to preserve the subdued feel
                            % Create a binary mask for the specific gray-blue parts
                            grayBlueMask = (hsvRegion(:,:,1) >= hueThresholdLowGrayBlue) & (hsvRegion(:,:,1) <= hueThresholdHighGrayBlue) & ...
                                           (hsvRegion(:,:,2) >= satThresholdLowGrayBlue) & (hsvRegion(:,:,2) <= satThresholdHighGrayBlue) & ...
                                           (hsvRegion(:,:,3) >= valThresholdLowGrayBlue) & (hsvRegion(:,:,3) <= valThresholdHighGrayBlue);
                            
                            
                                
                                % Define thresholds for the specific blue color (approximations for #4169E1)
                                hueThresholdLowBlue = 0.58; % Normalized hue for 210 degrees
                                hueThresholdHighBlue = 0.67; % Normalized hue for 240 degrees
                                satThresholdLowBlue = 0.7; % Estimated low end of saturation
                                satThresholdHighBlue = 1.0; % High saturation
                                valThresholdLowBlue = 0.4; % Moderate to high brightness
                                valThresholdHighBlue = 0.9; % Up to high brightness
                                % Create a binary mask for the specific blue parts
                                blueMask = (hsvRegion(:,:,1) >= hueThresholdLowBlue) & (hsvRegion(:,:,1) <= hueThresholdHighBlue) & ...
                                           (hsvRegion(:,:,2) >= satThresholdLowBlue) & (hsvRegion(:,:,2) <= satThresholdHighBlue) & ...
                                           (hsvRegion(:,:,3) >= valThresholdLowBlue) & (hsvRegion(:,:,3) <= valThresholdHighBlue);



                                % Define thresholds for white color
                                hueThresholdLowWhite = 0;   % Adjust as necessary
                                hueThresholdHighWhite = 1;  % White has a wide range of hue
                                satThresholdLowWhite = 0;   % Low saturation
                                satThresholdHighWhite = 0.2; % Adjust as necessary
                                valThresholdLowWhite = 0.8; % High value/brightness for white
                                valThresholdHighWhite = 1;
                                % Create a binary mask for the white parts of the ball
                                whiteMask = (hsvRegion(:,:,1) >= hueThresholdLowWhite) & (hsvRegion(:,:,1) <= hueThresholdHighWhite) & ...
                                            (hsvRegion(:,:,2) >= satThresholdLowWhite) & (hsvRegion(:,:,2) <= satThresholdHighWhite) & ...
                                            (hsvRegion(:,:,3) >= valThresholdLowWhite) & (hsvRegion(:,:,3) <= valThresholdHighWhite);
                                

                                % Define thresholds for the blue logo color
                                % Note: Adjust these values based on the specific hue, saturation, and value of the blue logo in your images
                                hueThresholdLowGray = 0; % Gray spans all hues, so we include the entire range
                                hueThresholdHighGray = 1;
                                satThresholdLowGray = 0; % Gray has low saturation
                                satThresholdHighGray = 0.2; % Adjust this based on the saturation of the gray you're targeting
                                valThresholdLowGray = 0.2; % Value can be adjusted based on the brightness of the gray
                                valThresholdHighGray = 0.8;
                                % Create a binary mask for the gray parts
                                grayMask = (hsvRegion(:,:,1) >= hueThresholdLowGray) & (hsvRegion(:,:,1) <= hueThresholdHighGray) & ...
                                           (hsvRegion(:,:,2) >= satThresholdLowGray) & (hsvRegion(:,:,2) <= satThresholdHighGray) & ...
                                           (hsvRegion(:,:,3) >= valThresholdLowGray) & (hsvRegion(:,:,3) <= valThresholdHighGray);

                                
                                % hueThresholdLowDarkGray = 0; % Hue is irrelevant for dark gray, so we can set it to span the entire range
                                % hueThresholdHighDarkGray = 1; % Hue is irrelevant for dark gray
                                % satThresholdLowDarkGray = 0; % Very low saturation is key for dark gray
                                % satThresholdHighDarkGray = 0.05; % Setting a very low upper limit to ensure we target dark gray accurately
                                % valThresholdLowDarkGray = 0.2; % Lower limit of brightness for dark gray
                                % valThresholdHighDarkGray = 0.8; % Upper limit of brightness for dark gray
                                % 
                                % % Create a binary mask for the dark gray parts
                                % darkGrayMask = (hsvRegion(:,:,1) >= hueThresholdLowDarkGray) & (hsvRegion(:,:,1) <= hueThresholdHighDarkGray) & ...
                                %                (hsvRegion(:,:,2) >= satThresholdLowDarkGray) & (hsvRegion(:,:,2) <= satThresholdHighDarkGray) & ...
                                %                (hsvRegion(:,:,3) >= valThresholdLowDarkGray) & (hsvRegion(:,:,3) <= valThresholdHighDarkGray);
                                % 




                                % Combine the white and blue masks to get a complete mask of the ball
                                ballMask = whiteMask | grayMask | blueMask | grayBlueMask ;
                                ballMask = imfill(ballMask, 'holes'); % Fill holes in the binary mask
                                % Clean up the combined mask
                                ballMask = bwareaopen(ballMask, 50); % Remove small objects from the binary image

                                % Inside your frame loop, after calculating ballMask...
                                currentBallMaskArea = sum(ballMask(:)); % Calculate the current area of ballMask

                                aaaacurrentBallMaskArea(frameIndex) = currentBallMaskArea;


                                % figure(8787)
                                % imshow(ballMask);

                                
                                % Apply object detection algorithm here
                                % This step may involve using edge detection, contour finding, etc.
                                % Ensure focusedBox remains within the bounds of the croppedFrame
                                % Assuming ballMask is already defined and is a binary mask
                                boundaries = bwboundaries(ballMask, 'noholes');




                                                
                                                for i = 1:length(boundaries)
                                                    boundary = boundaries{i};
                                                    % Create a binary mask from the current boundary
                                                    tempMask = poly2mask(boundary(:,2), boundary(:,1), size(ballMask, 1), size(ballMask, 2));
                                                    
                                                    % Calculate the area using polyarea
                                                    areaboundary = polyarea(boundary(:,2), boundary(:,1));
                                                    % Calculate the perimeter
                                                    perimeter = sum(sqrt(sum(diff(boundary([1:end, 1], :)).^2, 2)));
                                                    % Calculate circularity
                                                    circularity = (4 * pi * areaboundary) / (perimeter ^ 2);
                                                    
                                                    %Initialize the maximum diameter
                                                    maxDiameter = 0;
                                                    % Calculate distances between all pairs of points to find the maximum (widest diameter)
                                                                for p1 = 1:length(boundary)
                                                                    for p2 = p1+1:length(boundary)
                                                                        distance = sqrt((boundary(p1,1) - boundary(p2,1))^2 + (boundary(p1,2) - boundary(p2,2))^2);
                                                                        if distance > maxDiameter
                                                                            maxDiameter = distance; % Update maxDiameter if a new maximum is found
                                                                        end
                                                                    end
                                                                end
                                                    


                                                    % Define desired area or diameter range
                                                    minArea = 1000; % Minimum area threshold
                                                    maxArea = 6000; % Maximum area threshold
                                                    minDiameter = 10; % Minimum diameter threshold
                                                    maxDiameter = 300; % Maximum diameter threshold


                                                    if exist('distanceMovedX', 'var')
                                                    % Length of the vector
                                                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%% use frame count to stop it. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                        frame_counter = frame_counter+1;

                                                                     if frame_counter > 420
                                                                            disp(['puttnumber ', num2str(putt_counter, '%.2f'),' frame count over the 450 ball stoppped at ', num2str(distance_mm)]);
    
                                                                            motionDetected = false; % Example action
                                                                           
                                                                                              if distance_mm < 0
                                                                                                %Log this as a successful putt
                                                                                                successfulPutts.frameIndex(end+1) = frameIndex;
                                                                                                successfulPutts.distance(end+1) = distance_pixels;
                                                                                                it_was_a_succesful_putt = true;
                                                                                                % Display a message in the command window (optional)
                                                                                                disp(['puttnumber ', num2str(putt_counter, '%.2f'),' Successful putt detected at frame ', num2str(Observations_Counter_Per_Putt), ' with distance ', num2str(distance_mm, '%.2f'), ' mm.']);
                                                                                              end 
    
                                                                            skipBecauseEndofPutt = true; % Set the flag to skip remaining processing
                                                                            % frame_counter = 0;
                                                                            %putt_counter = putt_counter + 1; 
                                                                            break; % Or use other logic to exit or continue the script
                                                                    else
                                                                        % disp('The first row contains zero or not all rows are identical.');
                                                                     end
                                                                 
                                                                
                                                             
                                                        
                                                    end

                                                    
                                                    % Check if the circularity is close to 1 and area/diameter within the desired range
                                                    if circularity > 0.7 && areaboundary >= minArea && areaboundary <= maxArea && maxDiameter >= minDiameter && maxDiameter <= maxDiameter
                                                        % Check the overlap with the color mask
                                                        overlap = tempMask & ballMask;
                                                        % Calculate the percentage of the boundary area that matches the color mask
                                                        colorMatchRatio = sum(overlap(:)) / sum(tempMask(:));
                                                        
                                                        % If a significant portion of the boundary matches the color criteria
                                                        if colorMatchRatio > 0.7 % Adjust this threshold as needed
                                                            % % % % Optionally, plot the boundary
                                                            % figure(125); imshow(ballMask); hold on;
                                                            % plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
                                                            % title(sprintf('Object %d with Circularity %.2f, Color Match, and Size Filter', i, circularity));
                                                            % hold off;
                                                            Observations_Counter_Per_Putt_vector =Observations_Counter_Per_Putt + 1;
                                                            
                                                            % Adjust and plot the boundary on top of the current frame
                                                            adjustedBoundaryX = boundary(:,2) + focusedBox(1) - 1;
                                                            adjustedBoundaryY = boundary(:,1) + focusedBox(2) - 1;

                                                            % Calculate mean of the boundary coordinates within the focused box
                                                            boundaryCenterX = mean(boundary(:,2));
                                                            boundaryCenterY = mean(boundary(:,1));

                                                            % Adjust the center coordinates to the cropped frame's coordinate system
                                                            centerOfBallX = boundaryCenterX + focusedBox(1) - 1;
                                                            centerOfBallY = boundaryCenterY + focusedBox(2) - 1;

                                                             % Display the current frame with bounding boxes around both the ball and the hole
                                                            if show_the_figure_liveview
                                                            figure(1);
                                                            imshow(croppedFrame); hold on;
                                                            title(['Frame ', num2str(frameIndex), ' with Ball and Hole Detected']);

                                                            plot(adjustedBoundaryX, adjustedBoundaryY, 'r', 'LineWidth', 2); % Existing boundary plot
                                                            plot(centerOfBallX, centerOfBallY, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); % Add center of the ball as a red dot
                                                            plot(centroid_of_hole(1), centroid_of_hole(2), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); % Add center of the ball as a red dot


                                                            % Assuming 'hold on' is still active from previous plotting commands
                                                            plot([centerOfBallX, centroid_of_hole(1)], [centerOfBallY, centroid_of_hole(2)], 'g-', 'LineWidth', 2); % Draw the connecting line
                                                            hold off; % Now that plotting is done
                                                            end
                                                            
                                                            % Calculate the distance between the center of the ball and the centroid of the hole
                                                            distance_pixels = sqrt((centroid_of_hole(1) - centerOfBallX)^2 + (centroid_of_hole(2) - centerOfBallY)^2);

                                                            % subtract radius of the hole and Convert distance from pixels to millimeters (650 pixels = 1000 millimeters) 
                                                            distance_mm = (distance_pixels * (609.6 / 650)-54);

                                                            %aaaadistance_pixels(frameIndex) = distance_pixels;

                                                            % Choose a position for displaying the distance. For clarity, you might want to position this
                                                            % near the midpoint of the line connecting the ball and hole or at an edge of the figure.
                                                            midpointX = (centerOfBallX + centroid_of_hole(1)) / 2;
                                                            midpointY = (centerOfBallY + centroid_of_hole(2)) / 2;
                                                            
                                                            if show_the_figure_liveview
                                                            % Display the calculated distance on the figure
                                                            text(midpointX, midpointY, ['Distance: ', num2str(distance_mm, '%.2f'), ' millimeters'], ...
                                                            'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'black');
                                                            hold off;
                                                            end



                                                                            %%%%%%%%%%SAVE THE PUTTCYCLES COORDINATES AND ANY OTHER SALIENT INFORMATION FOR EACH PUTT-CYCLE 
                                                                                    % Initialize 'puttData' struct if it does not exist
                                                                                    if ~exist('puttData', 'var')
                                                                                        puttData = struct();
                                                                                        puttData.puttCyclesLocations = struct(); % Initialize 'puttCyclesLocations' as an empty struct
                                                                                    end
                                                                                    
                                                                                    % Create a unique identifier for each putt cycle based on 'putt_counter'
                                                                                    puttIdentifier = sprintf('putt%d', putt_counter);
                                                                                    
                                                                                    % Initialize or update the matrix for the current putt cycle
                                                                                    % If the putt cycle does not exist, initialize it with an empty matrix
                                                                                    % Otherwise, append the new observation (centerOfBallX, centerOfBallY)
                                                                                    if ~isfield(puttData.puttCyclesLocations, puttIdentifier)
                                                                                        puttData.puttCyclesLocations.(puttIdentifier) = [centerOfBallX, centerOfBallY]; % Initialize with the first observation
                                                                                    else
                                                                                        % Append new observation to the existing matrix for the putt cycle
                                                                                        puttData.puttCyclesLocations.(puttIdentifier)(end+1, :) = [centerOfBallX, centerOfBallY];
                                                                                    end
                                                                            %%%%%%%%%%SAVE THE PUTTCYCLES COORDINATES AND ANY OTHER SALIENT INFORMATION FOR EACH PUTT-CYCLE 

                                                                            %%%%%%%%%%SAVE THE PUTTCYCLES TIME AXES SYNCED WITH KINEMATICS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                                                                                    % Initialize 'Time_Axis_Aligned' struct if it does not exist
                                                                                                if ~isfield(puttData, 'Time_Axis_Aligned')
                                                                                                    puttData.Time_Axis_Aligned = struct();
                                                                                                end
                                                                                    % Create a unique identifier for each putt cycle based on 'putt_counter'
                                                                                    %%%%%puttIdentifier = sprintf('putt%d', putt_counter);
                                                                                    
                                                                                    % Initialize or update the matrix for the current putt cycle
                                                                                    % If the putt cycle does not exist, initialize it with an empty matrix
                                                                                    % Otherwise, append the new observation (centerOfBallX, centerOfBallY)
                                                                                    if ~isfield(puttData.Time_Axis_Aligned, puttIdentifier)
                                                                                        puttData.Time_Axis_Aligned.(puttIdentifier) = Time_Axis_Alignment.Ball.(Time_Axis_Alignment_Labels{LH_RH_BH}){1,1}(frameIndex,:); % Initialize with the first observation
                                                                                    else
                                                                                        % Append new observation to the existing matrix for the putt cycle
                                                                                        puttData.Time_Axis_Aligned.(puttIdentifier)(end+1, :) = Time_Axis_Alignment.Ball.(Time_Axis_Alignment_Labels{LH_RH_BH}){1,1}(frameIndex,:);
                                                                                    end
                                                                             %%%%%%%%%%SAVE THE PUTTCYCLES TIME AXES SYNCED WITH KINEMATICS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


                                                                            %%%%%%%%%%SAVE THE PUTTCYCLES OFFSET Time%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                                                                                                if ~isfield(puttData, 'Offset')
                                                                                                    puttData.Offset = struct();
                                                                                                end
                                                                                    % Create a unique identifier for each putt cycle based on 'putt_counter'
                                                                                    %%%%%puttIdentifier = sprintf('putt%d', putt_counter);
                                                                                    
                                                                                    % Initialize or update the matrix for the current putt cycle
                                                                                    % If the putt cycle does not exist, initialize it with an empty matrix
                                                                                    % Otherwise, append the new observation (centerOfBallX, centerOfBallY)
                                                                                    if ~isfield(puttData.Offset,Time_Axis_Alignment_Labels{LH_RH_BH})
                                                                                        puttData.Offset.(Time_Axis_Alignment_Labels{LH_RH_BH}) = Time_Axis_Alignment.Ball.(Time_Axis_Alignment_Labels{LH_RH_BH}){1,2}; % Initialize with the first observation
                                                                                    else
%                                                                                         puttData.Offset.(Time_Axis_Alignment_Labels{LH_RH_BH})(end, :) = Time_Axis_Alignment.(Time_Axis_Alignment_Labels{LH_RH_BH}){1,2}; % Initialize with the first observation
                                                                                       
                                                                                    end
                                                                            %%%%%%%%%%SAVE THE PUTTCYCLES OFFSET Time%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 



                                                                                            % After calculating centerOfBallX and centerOfBallY for the current frame
                                                                                            if ~isnan(prevCenterOfBallX) && ~isnan(prevCenterOfBallY) 
                                                                                                % Calculate the distance moved since the last frame
                                                                                                distanceMoved = sqrt((centerOfBallX - prevCenterOfBallX)^2 + (centerOfBallY - prevCenterOfBallY)^2);
                                                                                                distanceMovedX(frameIndex) = distanceMoved;
                                                                                            % 
                                                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
                                                                                            displacement_mm = (distanceMoved * (609.6 / 650)); 
                                                                                            displacement_mm_index(frameIndex,1) = displacement_mm;

                                                                                          
                                                                                                 % Calculate velocity 
                                                                                                  velocity_of_ball = displacement_mm / .01; % velocity between two consecutive frames
                                                                                                  velocity_of_ball_index(frameIndex,1) = velocity_of_ball;
                                                                                                    % Calculate acceleration 
                                                                                                   acceleration_of_ball = velocity_of_ball / .01;
                                                                                            %         disp(acceleration);
                                                                                                   acceleration_of_ball_index(frameIndex,1) = acceleration_of_ball;
                                                                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

                                                                                                                                                                                            
                                                                                                % Check if the ball has moved less than the stop threshold
                                                                                                if distanceMoved < stopThreshold || distanceMoved == 0
                                                                                                    currentStopFrameCount = currentStopFrameCount + 1;
                                                                                                else
                                                                                                    currentStopFrameCount = 0; % Reset counter if the ball has moved more than the threshold


                                                                                                                                                        % IF THE BALL OVERSHOOTS
                                                                                                                                                        % Calculate the y position for the bottom watchbox to start at the bottom of the frame
                                                                                                                                                        bottomWatchBoxY = size(croppedFrame, 1) - bottomwatchBoxHeight + 1;
                                                                                                                                                        % Define the watchbox with the new y position
                                                                                                                                                        bottomwatchBox = [1, bottomWatchBoxY, size(croppedFrame, 2), bottomwatchBoxHeight]; % [x, y, width, height]
                                                                                                                                                        % 
                                                                                                                                                        % % Display the frame with the watchbox drawn on it
                                                                                                                                                        % % Draw the watchbox on the cropped frame for visualization
                                                                                                                                                        % frameWithWatchBox =  Shape(croppedFrame, 'Rectangle', bottomwatchBox, 'Color', 'yellow', 'LineWidth', 5);
                                                                                                                                                        % % Display the frame with the watchbox drawn on it
                                                                                                                                                        % imshow(frameWithWatchBox);
                                                                                                                                                        % title('Cropped Frame with Bottom WatchBox');
                        
                                                                                                                                                        % Motion detection within the bottom watchbox across frames
                                                                                                                                                        if ~bottommotionDetected % Only check for motion if it hasn't been detected yet
                                                                                                                                                            if frameIndex > 1 % Ensure there's a previous frame to compare with
                                                                                                                                                                bottomcurrentWatchBoxArea = imcrop(rgb2gray(croppedFrame), bottomwatchBox);
                                                                                                                                                                bottompreviousWatchBoxArea = imcrop(rgb2gray(previousFrame), bottomwatchBox);
                                                                                                                                                        
                                                                                                                                                                bottomframeDiffWatchBox = abs(bottomcurrentWatchBoxArea - bottompreviousWatchBoxArea);
                                                                                                                                                                bottommotionMaskWatchBox = bottomframeDiffWatchBox > 10; % Motion detection threshold
                                                                                                                                                                bottommotionMaskWatchBox = bwareaopen(bottommotionMaskWatchBox, 50); % Clean up noise
                                                                                                                                                                bottommotionMaskWatchBox = imfill(bottommotionMaskWatchBox, 'holes'); % Fill holes in the mask
                                                                                                                                                        
                                                                                                                                                                if any(bottommotionMaskWatchBox(:))
                                                                                                                                                                    bottomconsecutiveMotionFrames = bottomconsecutiveMotionFrames + 1;
                                                                                                                                                                    if bottomconsecutiveMotionFrames >= 3 % Check for motion over 5 consecutive frames
                                                                                                                                                                        
                                                                                                                                                                        bottomconsecutiveMotionFrames = 0; % Reset counter
                                                                                                                                                                        
                                                                                                                                                                        ball_overshot_the_frame = true;
                                                                                                                                                                        final_location = NaN;
                                                                                                                                                                        skipBecauseEndofPutt = true; % Set the flag to skip remaining processing
                                                                                                                                                                        motionDetected = false; % Example action
                                                                                                                                                                       

                                                                                                                                                                        disp(['puttnumber ', num2str(putt_counter, '%.2f'),' Overshooting the Camera ', num2str(Observations_Counter_Per_Putt), ' with distance ', num2str(distance_pixels, '%.2f'), ' pixels.']);



                                                                                                                                                                        break; % Or use other logic to exit or continue the scrip
                                                                                                                                                                    end
                                                                                                                                                                else
                                                                                                                                                                    bottomconsecutiveMotionFrames = 0; % Reset counter if no motion is detected
                                                                                                                                                                end
                                                                                                                                                            end
                                                                                                                                                        end




                                                                                                end


       
                                                                                                                % Check if the ball is considered stopped
                                                                                                                if currentStopFrameCount >= stopFrameCountThreshold
                                                                                                                    disp(['puttnumber ', num2str(putt_counter, '%.2f'),' Ball slowed to stop at distance ', num2str(distance_mm)]);
                                                                                                                    % Reset counters or perform any action needed when the ball stops
                                                                                                                    % For example, setting a flag to end the script or skip further processing
                                                                                                                    motionDetected = false; % Example action
                                                                                                                                       % Check if the distance is less than 110 pixels for a successful putt
                                                                                                                                 
                                                                                                                                      if distance_pixels < 30
                                                                                                                                        %Log this as a successful putt
                                                                                                                                        successfulPutts.frameIndex(end+1) = frameIndex;
                                                                                                                                        successfulPutts.distance(end+1) = distance_pixels;
                                                                                                                                        it_was_a_succesful_putt = true;

                                                                                                                                        % Display a message in the command window (optional)
                                                                                                                                         disp(['puttnumber ', num2str(putt_counter, '%.2f'), ' Successful putt detected at frame ', num2str(Observations_Counter_Per_Putt), ' with distance ', num2str(distance_mm, '%.2f')]);
                                                                                                                                      end 
                                                                                                                    skipBecauseEndofPutt = true; % Set the flag to skip remaining processing

                                                                                                                    %putt_counter = putt_counter + 1; 


                                                                                                                    break; % Or use other logic to exit or continue the script
                                                                                                                end




                                                                     



                                                                                            else

                                                                                                % Initialize previous center positions for the first frame where the ball is detected
                                                                                                prevCenterOfBallX = centerOfBallX;
                                                                                                prevCenterOfBallY = centerOfBallY;
                                                                                            end
                                                                                            
                                                                                            % Update the previous center position for the next iteration
                                                                                            prevCenterOfBallX = centerOfBallX;
                                                                                            prevCenterOfBallY = centerOfBallY;

                                                                                            
                                                            



                                                   


                                                         break; % Assuming only one moving object of interest
                                                        end
                                                    end
                                                end





                                                            


                                        
                        if skipBecauseEndofPutt


                                        % Create a unique identifier for each putt cycle based on 'putt_counter'
                                        puttIdentifier = sprintf('putt%d', putt_counter);
                                    
                                        % Initialize substructures if they do not exist
                                        if ~isfield(puttData, 'PuttOutcome')
                                            puttData.PuttOutcome = struct();
                                        end
                                        if ~isfield(puttData, 'PuttCoordinates')
                                            puttData.PuttCoordinates = struct();
                                        end
                                        if ~isfield(puttData, 'PuttAccuracy')
                                            puttData.PuttAccuracy = struct();
                                        end

                                        if ~isfield(puttData, 'PuttAccuracy')
                                            puttData.PuttAccuracy = struct();
                                        end
                                    
                                        % Record the Putt Outcome
                                        if it_was_a_succesful_putt
                                            puttData.PuttOutcome.(puttIdentifier) = 'successful putt';
                                        elseif ball_overshot_the_frame
                                            puttData.PuttOutcome.(puttIdentifier) = 'overshot the frame';
                                        else
                                            puttData.PuttOutcome.(puttIdentifier) = 'miss';
                                        end
                                    
                                        % Store Putt Coordinates or Outcome Message
                                        if it_was_a_succesful_putt || ball_overshot_the_frame
                                            puttData.PuttCoordinates.(puttIdentifier) = puttData.PuttOutcome.(puttIdentifier);
                                        else
                                            puttData.PuttCoordinates.(puttIdentifier) = [centerOfBallX, centerOfBallY];
                                        end
                                    
                                        % Record Putt Accuracy or Outcome Message
                                        if it_was_a_succesful_putt
                                            puttData.PuttAccuracy.(puttIdentifier) = 0;
                                            elseif ball_overshot_the_frame
                                            puttData.PuttOutcome.(puttIdentifier) = 'overshot the frame';
                                            puttData.PuttAccuracy.(puttIdentifier) = 'overshot the frame';

                                        else
                                            puttData.PuttAccuracy.(puttIdentifier) = distance_mm;
                                        end



if show_the_figure
% Check if figure(2) exists, if not, create it and store the axes handle
% Check if figure(2) exists by its figure number
fig2Exists = findall(0, 'Type', 'Figure', 'Number', 2);
if isempty(fig2Exists)
    fig2 = figure(2);
    ax2 = axes('Parent', fig2); % Create new axes in new figure
else
    fig2 = figure(2); % Make figure(2) the current figure
    ax2 = gca; % Get the handle to the current axes, assuming it already exists
end
% Attempt to find an existing image object in the axes
imgHandle = findobj(ax2, 'Type', 'Image');

% Update the image data if the image object exists, otherwise create a new image object
if isempty(imgHandle)
    % First frame or no existing image object: display the image
    imshow(croppedFrame, 'Parent', ax2);
else
    % Image object exists: update its 'CData' property with the new frame
    set(imgHandle, 'CData', croppedFrame);
end

% Ensure subsequent plots are added on top of the image
hold(ax2, 'on');

% [Your plotting commands here]
% Ensure to specify 'Parent', ax2 for all plotting functions if they accept a parent argument
% Example:
% plot(ax2, centerOfBallX, centerOfBallY, 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
% and other plotting commands as needed...
if ~it_was_a_succesful_putt
plot(ax2, centerOfBallX, centerOfBallY, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); % Add center of the ball as a red dot
plot(ax2, centroid_of_hole(1), centroid_of_hole(2), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'b'); % Add center of the ball as a red dot
% Assuming 'hold on' is still active from previous plotting commands
%plot(ax2, [centerOfBallX, centroid_of_hole(1)], [centerOfBallY, centroid_of_hole(2)], 'g-', 'LineWidth', 2); % Draw the connecting line

% % Calculate the distance between the center of the ball and the centroid of the hole
% distance_pixels = sqrt((centroid_of_hole(1) - centerOfBallX)^2 + (centroid_of_hole(2) - centerOfBallY)^2);
% 
% % Convert distance from pixels to millimeters (650 pixels = 1000
% % millimeters) and subtracing the radius of the hole
% distance_mm = (distance_pixels * (609.6 / 650));
% Choose a position for displaying the distance. For clarity, you might want to position this
% near the midpoint of the line connecting the ball and hole or at an edge of the figure.
midpointX = (centerOfBallX + centroid_of_hole(1)) / 2;
midpointY = (centerOfBallY + centroid_of_hole(2)) / 2;

% Display the calculated distance on the figure
text(ax2, centerOfBallX, centerOfBallY, [num2str(distance_mm, '%.2f'),'mm'], ...
'Color', 'yellow', 'FontSize', 8, 'BackgroundColor', 'black');
hold on
else

end

% After plotting, you can optionally release the hold state
 hold(ax2, 'off'); 

% Note: With 'hold on', you don't need to call 'hold off' unless you specifically want to clear the figure or reset its state before the next loop iteration
end
                                       
                                        


                            putt_counter = putt_counter + 1; 
                            Observations_Counter_Per_Putt_vector = 1;
                            frame_counter = 0;
                            skipBecauseEndofPutt = false; % Reset the flag for the next iteration
                            it_was_a_succesful_putt = false;
                            ball_overshot_the_frame = false;
                            break; % Skip to the next iteration of the outer loop
                        end

    end
        

    
end

else
   % Skip to the next frame in "for frameIndex = 1:totalFrames" loop
   %continue; % This will skip the rest of the code in the loop and move to the next iteration



end

    % Update previousFrame for the next iteration
    previousFrame = croppedFrame;

%     if frameIndex == totalFrames-150
%     break
%     end

end


%%%%%%%%%%%%%%%%%%%%%filter putcycles for miss classifications and doubles%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the field names in puttCyclesLocations
fields = fieldnames(puttData.puttCyclesLocations);

% Loop over each field to check its size and delete if it has fewer than 50 rows
for i = 1:numel(fields)
    % Retrieve the data for the current field
    fieldData = puttData.puttCyclesLocations.(fields{i});
    
    % If the number of rows in the data is less than 50, delete the field
    if size(fieldData, 1) < 100
        puttData.puttCyclesLocations = rmfield(puttData.puttCyclesLocations, fields{i});
    end
end

% The puttCyclesLocations now only contains fields with 50 or more rows.
% Assuming puttData is already loaded into the workspace
% Get the list of fields in puttCyclesLocations
fieldsToKeep = fieldnames(puttData.puttCyclesLocations);

% List of substructures to process
subStructs = {'PuttAccuracy', 'PuttCoordinates', 'PuttOutcome', 'Time_Axis_Aligned'};

% Loop over each substructure
for i = 1:length(subStructs)
    % Get current substructure's fields
    currentFields = fieldnames(puttData.(subStructs{i}));
    
    % Determine fields that are not in puttCyclesLocations
    fieldsToDelete = setdiff(currentFields, fieldsToKeep);
    
    % Delete the fields not in puttCyclesLocations from current substructure
    puttData.(subStructs{i}) = rmfield(puttData.(subStructs{i}), fieldsToDelete);
end

% Now all substructures only contain fields that are also in puttCyclesLocations

% Define all the substructure names that need to be renamed
subStructs = {'puttCyclesLocations', 'Time_Axis_Aligned', 'PuttOutcome', 'PuttCoordinates', 'PuttAccuracy'};

% Loop through each substructure
for k = 1:length(subStructs)
    % Get the field names for the current substructure
    currentFields = fieldnames(puttData.(subStructs{k}));
    
    % Rename fields to be sequential (putt1, putt2, etc.)
    for i = 1:numel(currentFields)
        % Generate new field name
        newFieldName = ['putt', num2str(i)];
        
        % Check if the field needs to be renamed
        if ~strcmp(currentFields{i}, newFieldName)
            % Rename the field
            [puttData.(subStructs{k}).(newFieldName)] = puttData.(subStructs{k}).(currentFields{i});
            
            % Remove the old field
            puttData.(subStructs{k}) = rmfield(puttData.(subStructs{k}), currentFields{i});
        end
    end
end
% Now all specified substructures should have sequentially named fields
%%%%%%%%%%%%%%%%%%%%%filter putcycles for miss classifications and
%%%%%%%%%%%%%%%%%%%%%doubles%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   


% Save in a struct the putt data from left, right and both hands. 
    fieldName = puttinghandtolookat{LH_RH_BH};    
    % Ensure the field is initialized correctly to hold a struct array.
    if ~isfield(allputtData, fieldName) || isempty(allputtData.(fieldName))
        allputtData.(fieldName) = puttData; % Directly assign the first struct.
    else
        % For subsequent structs, append them.
        allputtData.(fieldName)(end+1) = puttData;
    end

clearvars -except Time_Axis_Alignment Time_Axis_Alignment_Labels Participant_number name_participant codename Type_of_participant croppedFrame allputtData puttinghandtolookat baseFilename Both_Hands baseFilename Both_Hands codename currentSensorName Left_Hand Right_Hand show_the_figure show_the_figure_liveview show_the_figure_liveview_noball check_if_hole_is_correctly_classified bottomconsecutiveMotionFrames  width_of_side_cutoff_left width_of_side_cutoff_right list_of_participants_to_process which_participants_to_process
end

allputtData.croppedframe = croppedFrame;


saveParticipantData4(Participant_number, name_participant, codename, Type_of_participant)


clearvars -except list_of_participants_to_process which_participants_to_process

end

%%
