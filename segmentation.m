function mask = segmentation(data, factor)
    % Display the first channel of the data
    figure;
    imshow(data(:, :, 10), []);
    title('Select a patch of the image');

    % Let user select a rectangle and get the coordinates
    rect = getrect;
    rect = round(rect); % Ensure the coordinates are integers
    x1 = rect(1);
    y1 = rect(2);
    width = rect(3);
    height = rect(4);

    % Extract the patch based on selected rectangle
    patch = data(y1:y1+height-1, x1:x1+width-1, :);

    % Calculate the mean spectrum of the patch
    referenceSpectrum = squeeze(mean(mean(patch, 1), 2));

    % Initialize RMSE matrix
    [rows, cols, ~] = size(data);
    rmse = zeros(rows, cols);

    % Calculate RMSE for each pixel's spectrum
    for i = 1:rows
        for j = 1:cols
            pixelSpectrum = squeeze(data(i, j, :));
            rmse(i, j) = sqrt(mean((pixelSpectrum - referenceSpectrum).^2));
        end
    end

    % Find the minimum RMSE to set a threshold
    minRMSE = min(rmse(:));
    %threshold = minRMSE * factor; % Adjust the threshold as needed

    threshold = prctile(rmse(:), factor);  % Use the 10th percentile

    % Create a mask where RMSE is below the threshold
    mask = rmse <= threshold;

    % Display the mask
    figure;
    imshow(mask);
    title('Mask of selected color');
end
