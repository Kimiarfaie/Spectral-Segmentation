function RGB=xyz2srgb(XYZ)
% XYZ2SRGB: calculates IEC:61966 sRGB values from XYZ
%
%   Colour Engineering Toolbox
%   author:    © Phil Green
%   version:   1.1
%   date:  	   17-01-2001
%   book:      http://www.wileyeurope.com/WileyCDA/WileyTitle/productCd-0471486884.html
%   web:       http://www.digitalcolour.org

% define 3x3 matrix
M =[3.2410,-1.5374,-0.4986
-0.9692,1.8760,0.0416
0.0556,-0.2040,1.0570];

if ischar(XYZ)
   xyz=dlmread(XYZ,'\t');
elseif isnumeric(XYZ)
   xyz=XYZ;
else
   error('No valid input data')
end

sRGB=(M*(xyz./100)')';

sR=sRGB(:,1);sG=sRGB(:,2);sB=sRGB(:,3);
sR(sR>1)=1;sG(sG>1)=1;sB(sB>1)=1;
sR(sR<0)=0;sG(sG<0)=0;sB(sB<0)=0;

% test for the dark colours in the non-linear part of the function
j=find(sR<=0.00304);
k=find(sG<=0.00304);
l=find(sB<=0.00304);

%apply gamma function
g=1/2.4;

%% scale to range 0-255
R=(1.055*sR.^g-0.055)*255;
G=(1.055*sG.^g-0.055)*255;
B=(1.055*sB.^g-0.055)*255;
   %non-linear bit for dark colours
R(j)=(sR(j)*12.92)*255;
G(k)=(sG(k)*12.92)*255;
B(l)=(sB(l)*12.92)*255;

% clip to range
R(R>255)=255;G(G>255)=255;B(B>255)=255;
R(R<0)=0;G(G<0)=0;B(B<0)=0;

RGB=[R,G,B];


