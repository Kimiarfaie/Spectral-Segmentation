clc
clear all
plateData = load('Plate02.mat');
WhiteData = load("White.mat");
DarkData = load("DarkCorrection.mat");
WhiteRef = load("WhiteRef.mat");

data = plateData.cube.DataCube;
white = WhiteData.cube.DataCube;
whitenew = white(213:500,:,:);
whitenew = correctingzero(whitenew);
dark = DarkData.cube.DataCube;
Rw = WhiteRef.Multi_90white;

% Pre-process Dark and White Data
whiteDataExtended = repmat(whitenew, [ceil(1295/size(whitenew,1)), 1, 1]);
whiteDataExtended = whiteDataExtended(1:1295, :, :);
darkDataExpanded = repmat(dark, [ceil(1295/size(dark,1)), 1, 1]);
darkDataExpanded = darkDataExpanded(1:1295, :, :);  % Trim excess rows after repetition
ref = WhiteRef.Multi_90white;

%%
% Flat-field correction
dark_corrected = max(0, data - darkDataExpanded); % To prevent having negative values
correctedCube =  dark_corrected./ (whiteDataExtended - darkDataExpanded);

%%
[~,M] = size(ref);
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
max = max(Reflectance,[],'all');
min = min(Reflectance,[],'all');

%%

%%
function output = correctingzero(input)

tmp = input;
tmp(tmp==0) = Inf;
minvalue = min(tmp,[],"all");

output = input;     
output(output==0) = minvalue;

end








