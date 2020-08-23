function [Imask] = detectMyo(I,threshold,centroid_LV,Imask_LV,se_size)
% Function detects region surrounded by outer boundary of myocardium
% by using circle detection and and using weight consisting of area
% size and closeness to LV
% param I: Image
% param threshold: minimum roundness to be considered myocardium
% param Imask_LV: Image mask of LV
% param se_size: Determines how much to dilate myocardium by
% Returns Image mask of myocardium

[B,L] = bwboundaries(I,'noholes'); %Get boundaries and regions in image
%Show regions in image
figure;
imshow(label2rgb(L,@jet,[.5 .5 .5])); 
hold on;

%Get Area and Centroid of regions in image
stats = regionprops(L,'Area','Centroid'); 
maxWeight = 0;
k_myo=0;
% loop over the boundaries
for k = 1:length(B)

  % obtain (X,Y) boundary coordinates corresponding to label 'k'
  boundary = B{k};

  % compute a simple estimate of the object's perimeter
  delta_sq = diff(boundary).^2;    
  perimeter = sum(sqrt(sum(delta_sq,2)));
  
  % obtain the area calculation corresponding to label 'k'
  area = stats(k).Area;
  
  % compute the roundness metric
  metric = 4*pi*area/perimeter^2;
  
  
  % obtain centroid corresponding to label 'k'
  centroid = stats(k).Centroid;
  % compute the weight
  weight = area/sqrt(sum((centroid_LV-centroid).^2))^2;
  
  % Object with the largest weight that has a metric above threshold
  if metric > threshold && weight>maxWeight
    maxWeight=weight;
    k_myo=k;
  end
end

boundary = B{k_myo}; % Get boundary of myocardium
delta_sq = diff(boundary).^2;    
perimeter = sum(sqrt(sum(delta_sq,2))); % Get perimeter of myocardium
area = stats(k_myo).Area; % Get area of myocardium
metric = 4*pi*area/perimeter^2; % Calculate metric of myocardium
centroid = stats(k_myo).Centroid; % Centroid of myocardium
region_string = sprintf('Myocardium - roundness metric\n of %2.2f and weight of %2.2f', ...
    metric, maxWeight);
text(boundary(1,2)-35,boundary(1,1)+13,region_string,'Color','y',...
       'FontSize',10,'FontWeight','bold')
plot(centroid(1),centroid(2),'ko');
hold off;
title('Regions in MRI image with area enclosed by myocardium+LV highlighted');


Imask = zeros(size(I));
% Get index corresponding to boundary
index = sub2ind(size(Imask),boundary(:,1),boundary(:,2)); 
Imask(index) = 1; % Set boundary pixels to 1
Imask = imfill(Imask,'holes'); % Fill boundary region with white pixels
se = strel('disk',se_size);
Imask = imdilate(Imask, se); % Dilate image to compensate size
Imask = bwareaopen(Imask,30); % Remove any stray, small irrelavant objects
Imask(Imask_LV == 1) = 0; % Remove LV to obtain myocardium
end

