function  [CGFC, RCGFC] = RCGFC(checker,reconstructedData)
% Calculate the means
mean_original = mean(checker, 1);
mean_reconstructed = mean(reconstructedData, 1);

% Calculate the numerator of GFC
numerator = sum((checker - mean_original) .* (reconstructedData - mean_reconstructed), 1);

% Calculate the denominator of GFC
denominator = sqrt(sum((checker - mean_original).^2, 1)) .* sqrt(sum((reconstructedData - mean_reconstructed).^2, 1));

% Calculate GFC for each column (spectrum)
GFC = (numerator ./ denominator) .^ 2;

% Calculate the mean GFC to get an overall quality measure

% Calculate CGFC and RCGFC
CGFC = 1 - GFC;
RCGFC = sqrt(CGFC);
end