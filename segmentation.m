function [maskRMSE, maskRCGFC] = segmentation(data, patch, RMSEfactor, RCGFCfactor)

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
            rcgfc(i,j) = RCGFC(referenceSpectrum, pixelSpectrum);
        end
    end

    threshold1 = prctile(rmse(:), RMSEfactor);  % Use the 10th percentile
    threshold2 = prctile(rcgfc(:), RCGFCfactor);  % Use the 10th percentile

    % Create a mask where RMSE is below the threshold
    maskRMSE = rmse <= threshold1;
    maskRCGFC= rcgfc <= threshold2;

    % Display the mask
    % figure;
    % imshow(maskRMSE);
    % title('Mask of selected color - RMSE');
    % figure;
    % imshow(maskRCGFC);
    % title('Mask of selected color - RCGFC');
end
