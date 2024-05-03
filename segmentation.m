function [maskRMSE, maskRCGFC] = segmentation(data, patch, RMSEfactor, RCGFCfactor)

    % Calculate the mean spectrum of the patch
    referenceSpectrum = squeeze(mean(mean(patch, 1), 2));

    % Initialize RMSE & RCGFC matrices
    [rows, cols, ~] = size(data);
    rmse = zeros(rows, cols);
    rcgfc = zeros(rows, cols);

    % Calculate RMSE & RCGFC for each pixel's spectrum
    for i = 1:rows
        for j = 1:cols
            pixelSpectrum = squeeze(data(i, j, :));
            rmse(i, j) = sqrt(mean((pixelSpectrum - referenceSpectrum).^2));
            rcgfc(i,j) = RCGFC(referenceSpectrum, pixelSpectrum);
        end
    end

    % setting the thresholds as the percentile defined by the factors
    threshold1 = prctile(rmse(:), RMSEfactor);  % Use the factor percentile
    threshold2 = prctile(rcgfc(:), RCGFCfactor);  % Use the factor percentile

    % Create a mask where RMSE & RCGFC are below the thresholds
    maskRMSE = rmse <= threshold1;
    maskRCGFC= rcgfc <= threshold2;
end
