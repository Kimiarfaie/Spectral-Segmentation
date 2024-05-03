function visualise_relighting(normalizedReflectance)

REF = normalizedReflectance(:,:,1:77);
[ref_length, ref_width, ~] = size(normalizedReflectance);
D65 = table2array(readtable("D65.csv")); %21:97
D65 = D65(21:97,2);
CMF = readmatrix("AllCMFs.xlsx","Sheet","CIE 1931 2 deg","Range","B9:D85"); 

% Visualization with D65
k = 100 / (CMF(:,2)' * D65);
REF = reshape(REF, [], 77);
XYZ = k * REF * diag(D65) * CMF;
RGB = xyz2srgb(XYZ);
mean(RGB,'all')
max( RGB,[],'all')
min(RGB,[],'all')
image = reshape(RGB, ref_length, ref_width, 3);
figure; imshow(uint8(image));


% Visualization with D50
D50 = readmatrix("Illuminants.xls","Sheet","Illuminant SPDs 5nm","Range","C10:C86"); 
CMF = readmatrix("AllCMFs.xlsx","Sheet","CIE 1931 2 deg","Range","B9:D85"); 

k = 100 / (CMF(:,2)' * D65);
REF = reshape(REF,[],77);
XYZ = k * REF * diag(D50) * CMF;
RGB = xyz2srgb(XYZ);
mean(RGB,'all')
max( RGB,[],'all')
min(RGB,[],'all')
image2 = reshape(RGB, ref_length, ref_width, 3);
figure; imshow(uint8(image2));

% Displaying the results
figure;
subplot(1,2,1)
imshow(uint8(image))
title("Visualization under D65")
subplot(1,2,2)
imshow(uint8(image2))
title("Visualization under D50")
end