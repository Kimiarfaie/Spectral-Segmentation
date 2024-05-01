clc
clear all
plateData = load('Plate02.mat');
WhiteData = load("White.mat");
DarkData = load("DarkCorrection.mat");
WhiteRef = load("WhiteRef.mat");

data = plateData.cube.DataCube;

white = WhiteData.cube.DataCube;

dark = DarkData.cube.DataCube;

Rw = WhiteRef.Multi_90white;

whiteDataCropped = white(1:1295, :, :);
darkDataExpanded = repmat(dark, [ceil(1295/size(dark,1)), 1, 1]);
darkDataExpanded = darkDataExpanded(1:1295, :, :);  % Trim excess rows after repetition
ref = WhiteRef.Multi_90white;

% Later the correctedCube will have infinite values, so we are replacing
% the zero in whiteDataCropped - darkDataExpanded with the second min in
% that 


nonzero = correctingzero(whiteDataCropped - darkDataExpanded);


% Flat-field correction
correctedCube = ((data - darkDataExpanded) ./ (nonzero));

[~,M] = size(ref);
corrected=zeros(1295,900,121);
RadianceIncident=zeros(1295,900,121);

for i=1:M
    temp = ones(1295,900)*ref(:,i);
    corrected(:,:,i)=correctedCube(:,:,i).*temp;
    RadianceIncident(:,:,i) = whiteDataCropped(:,:,i)./temp;
end

% Correcting the white

RadianceIncident = correctingzero(RadianceIncident);

Reflectance = corrected./RadianceIncident;

function output = correctingzero(input)

tmp = input;
tmp(tmp==0) = Inf;
minvalue = min(tmp,[],"all");

output = input;
output(output==0) = minvalue;

end








