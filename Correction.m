clc
clear all
plateData = load('plate02.mat');
WhiteData = load("White.mat");
DarkData = load("Dark Correction.mat");

data = plateData.cube.DataCube;

white = WhiteData.cube.DataCube;

dark = DarkData.cube.DataCube;

whiteDataCropped = white(1:1295, :, :);
darkDataExpanded = repmat(dark, [ceil(1295/size(dark,1)), 1, 1]);
darkDataExpanded = darkDataExpanded(1:1295, :, :);  % Trim excess rows after repetition


% Flat-field correction
correctedCube = ((data - darkDataExpanded) ./ (whiteDataCropped - darkDataExpanded));

% Replace any infinite or NaN values
correctedCube(isinf(correctedCube) | isnan(correctedCube)) = 0;






