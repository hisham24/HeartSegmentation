%% Load MRI and Labeled Images
clear all;
I1 = double(niftiread('training/patient001/patient001_frame01.nii')); %Get MRI Image
I2= double(niftiread('training/patient001/patient001_frame01_gt.nii')); %Ground Truth Labeled Images

I1 = I1(:,:,4); %Get Slice of MRI image
I1 = (I1-min(I1(:)))/max(I1(:)); %Normalize

I2 = I2(:,:,4); %Get slice of Ground Truth Labled Image
I2 = (I2-min(I2(:)))/max(I2(:)); %Normalize

figure;
subplot(121),imshow(I1,[],'Border','tight');
title('MRI Image of Heart (Slice 4 of Patient 1)');
subplot(122),imshow(I2,[],'Border','tight');
title('Ground Truth Label (Slice 4 of Patient 1)');

%% Get Histogram of MRI Image
figure;
imhist(I1);
title('Histogram of Original MRI image');

%% Image Enhancement

% Perform Local Histogram Equalization to Accentuate Myocardium
J = localhisteq(I1,2.5,15,0,1.5,0,0.55); %Change parameters appropriately if needed
J = (J-min(J(:)))/max(J(:)); % Normalise
figure;
imshow(J);
title('MRI image of heart after local histogram equalization');

figure;
imhist(J);
title('Histogram of image after local histogram equalisation');

%% Image Filtering

% Use Gaussian Filter to smooth image to reduce noise
Jblur = imgaussfilt(J,1); 
figure, imshow(Jblur), title('Gaussian Filter applied to image');

% Use Canny Edge Detection to get outline of Right Ventricle
J_edge = edge(Jblur,'Canny',[0.22 0.28]);  %Edit lower and upper threshold as appropriate
figure, imshow(J_edge), title('Canny Edge Detector Applied to Image');

%% Left Ventricle Detection
Ibw = imbinarize(Jblur); % Binarize smoothed image 
Ibw = bwareaopen(Ibw,30); % Remove stray objects
Ibw = imfill(Ibw,'holes'); % Fill boundaries with holes
figure, imshow(Ibw), title('Morphological processing of binary image');
[Imask_LV,centroid_LV, area_LV] = detectLV(Ibw,0.8); % Get LV mask
figure,imshow(Imask_LV),title('Mask of Left Ventricle');

%% Myocardium Detection
Ibw_ = imbinarize(Jblur); % Binarize smoothed image
figure, imshow(Ibw), title('Binary Image of MRI');
Ibw_(Imask_LV==1) = 0; % Remove LV region
se = strel('square',2);
Ibw = imdilate(Ibw_, se); % Dilate image to reduce myocardium discontinuity
Ibw = bwareaopen(Ibw,30); % Remove stray small objects
Ibw = ~Ibw; % Get image negative of image
figure;
subplot(121),imshow(Ibw_),title('Binary Image of MRI with Left Ventricle removed');
subplot(122), imshow(Ibw), title('Inverted Binary Image of MRI');
se1 = strel('square',2);
se2 = strel('disk',2);
% Erode image to isolate myocardium outer boundary
Ibw = imerode(Ibw,se1);
Ibw = imerode(Ibw,se2);
figure,imshow(Ibw), title('Inverted Binary Image after erosion');

[Imask_myo] = detectMyo(Ibw,0.7,centroid_LV,Imask_LV,4); % Obtain myocardium mask
figure, imshow(Imask_myo), title('Mask of Myocardium');

%% Right Ventricle Detection
se = strel('square',6);
Ibw = bwareaopen(J_edge,20); % Remove stray small objects 
figure,imshow(Ibw);
Ibw = imdilate(Ibw,se); % Dilate image to reduce discontinuity in edges
Ibw(Imask_LV==1) = 0; % Remove LV
Ibw = bwareaopen(Ibw,30); % Remove stray small objects
Jbw = ~Ibw; % Get image negative of image
se1 = strel('square',3);
Jbw = imdilate(Jbw,se1); % Dilate to increase RV size
figure
subplot(121), imshow(Ibw), title('Binary image of edge detection output with LV removed');
subplot(122), imshow(Jbw), title('Image negative of binary image');

[Imask_RV,area_RV] = detectRV(Jbw, area_LV, centroid_LV,Imask_myo,4); % Get RV mask
figure, imshow(Imask_RV), title('Mask of Right Ventricle');
%% Predicted Label
% Get predicted image mask of heart
pred = zeros(size(I1));
pred(Imask_RV==1) = 0.3333;
pred(Imask_myo==1) = 0.6666;
pred(Imask_LV==1) = 1;
figure;
subplot(121),imshow(pred),title('Predicted Image Mask of Heart');
subplot(122),imshow(I2), title('Ground Truth Label');

% Get difference between prediction and ground truth
Idiff = pred-I2;
Idiff(abs(Idiff) > 10^(-3)) = 1;
figure, imshow(Idiff), title('Difference between predicted image mask and ground truth');

%% LV and RV cross-sectional area
ind = unique(I2);

tmpLV = zeros(size(pred));
tmpLV(I2==ind(4)) = 1; % Count number of pixels corresponding to LV
LV_gt = 1.525*sum(tmpLV,'all'); % Get ground truth cross-sectional area of LV

tmpRV = zeros(size(pred));
tmpRV(I2==ind(2)) = 1; % Count number of pixels corresponding to RV
RV_gt = 1.525*sum(tmpRV,'all'); % Get ground truth cross-sectional area of RV

tmpLV = zeros(size(pred));
tmpLV(pred==1) = 1; % Count number of pixels corresponding to LV
LV_pred = 1.525*sum(tmpLV,'all'); % Get predicted cross-sectional area of LV

tmpRV = zeros(size(pred));
tmpRV(pred==0.3333) = 1; % Count number of pixels corresponding to RV
RV_pred = 1.525*sum(tmpRV,'all'); % Get predicted cross-sectional area of RV
