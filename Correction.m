clc
clear all
plateData = load('Plate02.mat');
WhiteData = load("White.mat");
DarkData = load("DarkCorrection.mat");

data = plateData.cube.DataCube;

white = WhiteData.cube.DataCube;

dark = DarkData.cube.DataCube;

whiteDataCropped = white(1:1295, :, :);
darkDataExpanded = repmat(dark, [ceil(1295/size(dark,1)), 1, 1]);
darkDataExpanded = darkDataExpanded(1:1295, :, :);  % Trim excess rows after repetition


% Flat-field correction
correctedCube = ((data - darkDataExpanded) ./ (whiteDataCropped - darkDataExpanded));

% Replace any NaN values
correctedCube(isinf(correctedCube) | isnan(correctedCube)) = 0;

% The white has some black spots, which has a value of 0 radiance. so we
% will be replacing them with the non-zero minimum of the whole white

tmp = whiteDataCropped;
tmp(tmp==0) = Inf;
minNonZero = min(tmp,[],"all");

whitedatanz = whiteDataCropped;
whitedatanz(whiteDataCropped==0) = minNonZero;

% Calculating Refltance 
Reflectance = correctedCube./whitedatanz;






