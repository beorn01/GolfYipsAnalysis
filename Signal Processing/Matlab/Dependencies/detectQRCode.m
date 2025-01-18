% % 
% % % Define the function to detect QR code in an image
% % function isQRCodePresent = detectQRCode(croppedFrame)
% %     % Convert the frame to grayscale if it is not already
% %     if size(croppedFrame, 3) == 3
% %         croppedFrame = rgb2gray(croppedFrame);
% %     end
% %     
% %     % Binarize the image using automatic thresholding
% %     imgbw = im2bw(croppedFrame, graythresh(croppedFrame));  
% %     imgfiltered = filter2(fspecial('average', 3), imgbw); % Filter the image using a 3x3 averaging filter
% %     imgbw2 = im2bw(imgfiltered, graythresh(imgfiltered)); % Binarize the filtered image again
% % 
% %     % Initialize variables for edge detection
% %     xpixelsize = 0;
% %     nxpixelsize = 0;
% %     [nrow, ncol] = size(imgbw);
% %     matcenterx = [];
% % 
% %     % Row-wise edge detection
% %     for i = 1:nrow
% %         pieces = zeros(1, 1);
% %         count = 0;
% %         for j = 1:(ncol-1)
% %             if (imgbw2(i, j) ~= imgbw2(i, j+1))  % If the current pixel is different from the next
% %                 pieces = [pieces, count];
% %                 count = 0;
% %             else
% %                 count = count + 1;
% %             end
% %         end
% %         pieces = [pieces, count];
% %         pieces = pieces(1, 2:end);
% %         npieces = size(pieces, 2);
% % 
% %         if (npieces > 6)
% %             for k = 3:(npieces-2)
% %                 ratio = 1;
% %                 if (abs(pieces(k)/pieces(k-1) - 3) < ratio && ...
% %                     abs(pieces(k)/pieces(k-2) - 3) < ratio && ...
% %                     abs(pieces(k)/pieces(k+1) - 3) < ratio && ...
% %                     abs(pieces(k)/pieces(k+2) - 3) < ratio)
% %                     
% %                     % Position sign edge found
% %                     matcenterx = [matcenterx; i, round((k-1 + k) / 2)];
% %                     nxpixelsize = nxpixelsize + 1;
% %                     xpixelsize = xpixelsize * (nxpixelsize - 1) + round(pieces(k) / 3);
% %                     xpixelsize = round(xpixelsize / nxpixelsize);
% %                 end
% %             end
% %         end
% %     end
% % 
% %     % If any center points were found, a QR code is likely present
% %     if ~isempty(matcenterx)
% %         isQRCodePresent = true;
% %     else
% %         isQRCodePresent = false;
% %     end
% % end






% % % 
% % % function isQRCodePresent = detectQRCode(croppedFrame)
% % %     % Step 1: Convert the frame to grayscale if it is not already
% % %     if size(croppedFrame, 3) == 3
% % %         croppedFrame = rgb2gray(croppedFrame);
% % %     end
% % %     
% % %     % Step 2: Binarize the image using adaptive thresholding
% % %     imgbw = imbinarize(croppedFrame, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.4);  
% % %     
% % %     % Step 3: Apply a median filter to reduce noise while preserving edges
% % %     imgfiltered = medfilt2(imgbw, [3 3]);
% % %     
% % %     % Step 4: Convert the filtered image back to a suitable data type
% % %     imgfiltered = im2uint8(imgfiltered);
% % %     
% % %     % Step 5: Binarize the filtered image again
% % %     imgbw2 = imbinarize(imgfiltered);
% % %     
% % %     % Step 6: Initialize variables for edge detection and pattern matching
% % %     [nrow, ncol] = size(imgbw2);
% % %     matcenterx = [];
% % %     
% % %     % Step 7: Row-wise edge detection and pattern matching
% % %     for i = 1:nrow
% % %         pieces = zeros(1, 1);
% % %         count = 0;
% % %         for j = 1:(ncol-1)
% % %             if imgbw2(i, j) ~= imgbw2(i, j+1)  % If the current pixel is different from the next
% % %                 pieces = [pieces, count];
% % %                 count = 0;
% % %             else
% % %                 count = count + 1;
% % %             end
% % %         end
% % %         pieces = [pieces, count];
% % %         pieces = pieces(1, 2:end);  % Remove the first element which is always zero
% % %         npieces = length(pieces);
% % % 
% % %         % Step 8: Check for patterns that match QR code finder patterns
% % %         if npieces > 6  % If the row has enough segments
% % %             for k = 3:(npieces-2)
% % %                 ratio = 0.5;  % Adjust the ratio for less sensitivity
% % %                 if abs(pieces(k)/pieces(k-1) - 3) < ratio && ...
% % %                    abs(pieces(k)/pieces(k-2) - 3) < ratio && ...
% % %                    abs(pieces(k)/pieces(k+1) - 3) < ratio && ...
% % %                    abs(pieces(k)/pieces(k+2) - 3) < ratio
% % %                 
% % %                     % Potential QR code pattern found
% % %                     matcenterx = [matcenterx; i, round((k-1 + k) / 2)];
% % %                 end
% % %             end
% % %         end
% % %     end
% % % 
% % %     % Step 9: Determine if a QR code is present based on detected patterns
% % %     if ~isempty(matcenterx)
% % %         isQRCodePresent = true;
% % %     else
% % %         isQRCodePresent = false;
% % %     end
% % % end


function isQRCodePresent = detectQRCode(croppedFrame)
    % Step 1: Convert the frame to grayscale if it is not already
    if size(croppedFrame, 3) == 3
        croppedFrame = rgb2gray(croppedFrame);
    end
    
    % Step 2: Binarize the image using adaptive thresholding
    imgbw = imbinarize(croppedFrame, 'adaptive', 'ForegroundPolarity', 'dark', 'Sensitivity', 0.4);
    
    % Step 3: Apply a median filter to reduce noise while preserving edges
    imgfiltered = medfilt2(imgbw, [3 3]);
    
    % Step 4: Convert the filtered image back to a suitable data type
    imgfiltered = im2uint8(imgfiltered);
    
    % Step 5: Binarize the filtered image again
    imgbw2 = imbinarize(imgfiltered);
    
    % Step 6: Initialize variables for edge detection and pattern matching
    [nrow, ncol] = size(imgbw2);
    matcenterx = [];
    
    % Step 7: Row-wise edge detection and pattern matching
    for i = 1:nrow
        pieces = zeros(1, 1);
        count = 0;
        for j = 1:(ncol-1)
            if imgbw2(i, j) ~= imgbw2(i, j+1)  % If the current pixel is different from the next
                pieces = [pieces, count];
                count = 0;
            else
                count = count + 1;
            end
        end
        pieces = [pieces, count];
        pieces = pieces(1, 2:end);  % Remove the first element which is always zero
        npieces = length(pieces);

        % Step 8: Check for patterns that match QR code finder patterns
        if npieces > 6  % If the row has enough segments
            for k = 3:(npieces-2)
                ratio = 0.5;  % Adjust the ratio for less sensitivity
                if abs(pieces(k)/pieces(k-1) - 3) < ratio && ...
                   abs(pieces(k)/pieces(k-2) - 3) < ratio && ...
                   abs(pieces(k)/pieces(k+1) - 3) < ratio && ...
                   abs(pieces(k)/pieces(k+2) - 3) < ratio
                
                    % Potential QR code pattern found
                    matcenterx = [matcenterx; i, round((k-1 + k) / 2)];
                end
            end
        end
    end
    
    % Additional geometric checks to reduce false positives
    if ~isempty(matcenterx)
        stats = regionprops(imgbw2, 'BoundingBox', 'Area');
        for k = 1:length(stats)
            bbox = stats(k).BoundingBox;
            aspectRatio = bbox(3) / bbox(4);
            % Check for aspect ratio close to 1 (square) and area threshold
            if aspectRatio > 0.9 && aspectRatio < 1.1 && stats(k).Area > 50
                isQRCodePresent = true;
                return;
            end
        end
    end

    % If no valid patterns were found, return false
    isQRCodePresent = false;
end