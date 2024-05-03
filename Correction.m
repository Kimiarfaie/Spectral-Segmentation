%% Data Loading
clc
clear all
plateData = load('Plate02.mat');
WhiteData = load("White.mat");
DarkData = load("DarkCorrection.mat");
WhiteRef = load("WhiteRef.mat");

data = plateData.cube.DataCube;
white_radiance = WhiteData.cube.DataCube;
white_reflect = WhiteRef.Multi_90white;
dark = DarkData.cube.DataCube;

%% Spectral Data Processing
% Selecting the reference white band and averaging it into one line
white_band = white_radiance(213:500, :, :);
white_band = mean(white_band, 1);
% Expanding the white reference to fit the data size
[data_length, data_width, channels] = size(data);
whiteRadExtended = repmat(white_band, [data_length, 1, 1]);
% Expanding the dark correction sample to fit the data size
darkRadExpanded = repmat(dark, [ceil(data_length/size(dark, 1)), 1, 1]);
darkRadExpanded = darkRadExpanded(1:data_length, :, :);  % Trim excess rows after repetition


% Flat-field correction
dark_corrected = max(0, data - darkRadExpanded); % handling negative values
correctedCube =  dark_corrected./ (whiteRadExtended - darkRadExpanded); % applying the formula


correctedRadiance = zeros(data_length, data_width, channels);
radianceIncident = zeros(data_length, data_width, channels);

for i = 1:channels
    whiteRefExpanded = ones(data_length, data_width) * white_reflect(:, i);
    % calculating the corrected radiance data
    correctedRadiance(:, :, i) = correctedCube(:, :, i) .* whiteRefExpanded;
    % calculating the radiance of the incident light
    radianceIncident(:, :, i) = whiteRadExtended(:, :, i) ./ whiteRefExpanded;
end

% Later, the correctedCube will have infinite values, so we are replacing
% the zero in RadianceIncident with the second smallest value
radianceIncident = correct_zero(radianceIncident); % To prevent getting Inf in the reflectance

% Calculate Data Reflectance
reflectance = correctedRadiance ./ radianceIncident;

% checking the reflectance values --> need for normalization
mean(reflectance, 'all');
max(reflectance, [], 'all');
min(reflectance, [], 'all');

%% Normalizing the reflectance for each one of the RGB channels
normalizedReflectance = zeros(size(data));
for i = 1 : size(reflectance, 3)
    % Extract the band
    band = reflectance(:, :, i);
    
    % Find the minimum and maximum values in the band
    minVal = min(band(:));
    maxVal = max(band(:));
    
    % Perform min-max normalization
    if maxVal > minVal  % Avoid division by zero in case maxVal equals minVal
        normalizedReflectance(:,:,i) = (band - minVal) / (maxVal - minVal);
    else
        % In case all values are the same in the band
        normalizedReflectance(:,:,i) = zeros(size(band)); % Optionally, set all to 0 or some other value
    end
end

% checking the reflectance values after normalization
mean(normalizedReflectance, 'all')
max(normalizedReflectance, [], 'all')
min(normalizedReflectance, [], 'all')

%% Segmentation

% Display the first channel of the data
figure;
imshow(normalizedReflectance(:, :, 10), []);
title('Select a patch of the image');

% Let user select a rectangle and get the coordinates
rect = getrect;
rect = round(rect); % Ensure the coordinates are integers
x1 = rect(1);
y1 = rect(2);
width = rect(3);
height = rect(4);

% Extract the patch based on selected rectangle
patch = normalizedReflectance(y1:y1+height-1, x1:x1+width-1, :);

% setting the values of the percentile thresholds to be considered
percentiles = 7:1:10;
figure;
for i = 1:length(percentiles)
    % performing data segmentation for each threshold
    % and identifying regions with similar pigments using RMSE and RCGFC
    [RMSEmask, RCGFCmask] = segmentation(normalizedReflectance, patch, ...
        percentiles(i), percentiles(i));

    % displaying the mask of the segmented regions
    subplot(2,3,i);
    hold on
    imshow(RCGFCmask);
    title(["RCGFC : factor of ", num2str(percentiles(i))]);
    hold off
end

%% Function to replace the zero values with the second smallest value
function output = correct_zero(input)
output = input; 

% making a copy of the input and replacing all the zeroes with infinity
% to calculate the second smallest value
tmp = input;
tmp(tmp==0) = Inf;
second_minvalue = min(tmp,[],"all");

% replacing the zeroes with the second smallest value
output(output==0) = second_minvalue;
end








