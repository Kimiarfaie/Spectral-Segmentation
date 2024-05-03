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
    rcgfc = zeros(rows, cols);

    % Calculate RMSE for each pixel's spectrum
    for i = 1:rows
        for j = 1:cols
            pixelSpectrum = squeeze(data(i, j, :));
            rmse(i, j) = sqrt(mean((pixelSpectrum - referenceSpectrum).^2));

            angle = sam(pixelSpectrum, referenceSpectrum);
            gfc = cos(angle);
            rcgfc(i,j) = sqrt(1-gfc);

            % % Calculate the means
            % mean_original = mean(referenceSpectrum, 1);
            % mean_reconstructed = mean(pixelSpectrum, 1);
            % 
            % % Calculate the numerator of GFC
            % numerator = sum((referenceSpectrum - mean_original) .* ...
            %     (pixelSpectrum - mean_reconstructed), 1);
            % 
            % % Calculate the denominator of GFC
            % denominator = sqrt(sum((referenceSpectrum - mean_original).^2, 1)) .* ...
            %     sqrt(sum((pixelSpectrum - mean_reconstructed).^2, 1));
            % 
            % % Calculate GFC for each column (spectrum)
            % GFC = (numerator ./ denominator) .^ 2;
            % 
            % % Calculate the mean GFC to get an overall quality measure
            % 
            % % Calculate CGFC and RCGFC
            % CGFC = 1 - GFC;
            % RCGFC(i,j) = sqrt(CGFC);
        end
    end

    
    threshold_rmse = prctile(rmse(:), factor);  % Use the factor percentile
    threshold_rcgfc = prctile(rcgfc(:), factor);  

    % Create a mask where RMSE is below the threshold
    mask_rmse = rmse <= threshold_rmse;
    mask_rcgfc = rcgfc <= threshold_rcgfc;

    % Display the mask
    figure;
    imshow(mask_rmse);
    title('Mask of selected color based on RMSE');

    figure;
    imshow(mask_rcgfc);
    title('Mask of selected color based on RCGFC');
    mask = mask_rmse;
end
