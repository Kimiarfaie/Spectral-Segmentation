clc
clear all
plateData = load('Plate02.mat');
WhiteData = load("White.mat");
DarkData = load("DarkCorrection.mat");
WhiteRef = load("WhiteRef.mat");

data = plateData.cube.DataCube;
white = WhiteData.cube.DataCube;

dark = DarkData.cube.DataCube;
ref = WhiteRef.Multi_90white;


%%
white_band = white(213:500,:,:);
white_band = mean(white_band, 1);
whiteDataExtended = repmat(white_band, [1295, 1, 1]);
darkDataExpanded = repmat(dark, [ceil(1295/size(dark, 1)), 1, 1]);
darkDataExpanded = darkDataExpanded(1:1295, :, :);  % Trim excess rows after repetition

% Later the correctedCube will have infinite values, so we are replacing
% the zero in whiteDataCropped - darkDataExpanded with the second min in
% that 


% Flat-field correction
dark_corrected = max(0, data - darkDataExpanded);
correctedCube =  dark_corrected./ (whiteDataExtended - darkDataExpanded);

[~, M] = size(ref);

corrected=zeros(1295,900,121);

for i=1:M
    temp = ones(1295,900)*ref(:,i);
    corrected(:,:,i)=correctedCube(:,:,i).*temp;
    RadianceIncident(:,:,i) = whiteDataExtended(:,:,i)./temp;
end

% Handle zeros in Radiance Incident
RadianceIncident = correctingzero(RadianceIncident); % To prevent getting Inf in the reflectance

% Calculate Reflectance
Reflectance = corrected./RadianceIncident;

mean(Reflectance,'all')
max(Reflectance,[],'all')
min(Reflectance,[],'all')

%%
% Normalizing the reflectance 
for i = 1:size(Reflectance, 3)
    % Extract the band
    band = Reflectance(:,:,i);
    
    % Find the minimum and maximum values in the band
    minVal = min(band(:));
    maxVal = max(band(:));
    
    % Perform min-max normalization
    if maxVal > minVal  % Avoid division by zero in case maxVal equals minVal
        NormalizedReflectance(:,:,i) = (band - minVal) / (maxVal - minVal);
    else
        % In case all values are the same in the band
        NormalizedReflectance(:,:,i) = zeros(size(band)); % Optionally, set all to 0 or some other value
    end
end
%%
%Visualization with Normalized

REF = NormalizedReflectance(:,:,1:77);
D65 = table2array(readtable("D65.csv")); %21:97
D65 = D65(21:97,2);
CMF = readmatrix("AllCMFs.xlsx","Sheet","CIE 1931 2 deg","Range","B9:D85"); 

k = 100/(CMF(:,2)'*D65);
REF = reshape(REF,[],77);
XYZ = k*REF*diag(D65)*CMF;
RGB = xyz2srgb(XYZ);
mean(RGB,'all')
max( RGB,[],'all')
min(RGB,[],'all')
image = reshape(RGB,1295,900,3);
figure;imshow(uint8(image));

%%
%Visualization with D50

D50 = readmatrix("Illuminants.xls","Sheet","Illuminant SPDs 5nm","Range","C10:C86"); 
CMF = readmatrix("AllCMFs.xlsx","Sheet","CIE 1931 2 deg","Range","B9:D85"); 

k = 100/(CMF(:,2)'*D65);
REF = reshape(REF,[],77);
XYZ = k*REF*diag(D50)*CMF;
RGB = xyz2srgb(XYZ);
mean(RGB,'all')
max( RGB,[],'all')
min(RGB,[],'all')
image2 = reshape(RGB,1295,900,3);
figure;imshow(uint8(image2));
%%
figure;
subplot(1,2,1)
imshow(uint8(image))
title("Visualization under D65")
subplot(1,2,2)
imshow(uint8(image2))
title("Visualization under D50")
%%
function output = correctingzero(input)

tmp = input;
tmp(tmp==0) = Inf;
minvalue = min(tmp,[],"all");

output = input;     
output(output==0) = minvalue;
end




