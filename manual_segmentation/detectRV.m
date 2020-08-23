function [Imask, area] = detectRV(I,area_LV,centroid_LV, Imask_myo, se_size)
% Function detects RV region by finding region closest to LV with
% the largest area.
% param I: Image
% param area_LV: area of LV
% param centroid_LV: centroid of LV
% param Imask_myo: Image mask of myocardium
% Returns mask, pixel area of RV

[B,L] = bwboundaries(I,'noholes');

figure;
imshow(label2rgb(L,@jet,[.5 .5 .5]))
hold on

stats = regionprops(L,'Area','Centroid');

maxWeight = 0;
k_RV=0;
% loop over the boundaries
for k = 1:length(B)

  % obtain (X,Y) boundary coordinates corresponding to label 'k'
  boundary = B{k};

  % compute a simple estimate of the object's perimeter
  delta_sq = diff(boundary).^2;    
  perimeter = sum(sqrt(sum(delta_sq,2)));
  
  % obtain the area calculation corresponding to label 'k'
  area = stats(k).Area;
  % obtain centroid corresponding to label 'k'
  centroid = stats(k).Centroid;
  
  % compute the weight
  weight = area/sqrt(sum((centroid_LV-centroid).^2))^2;
  
  % If weight exceeds maxWeight and RV area size if lower 
  % but similar size to LV size update k_RV
  if weight>maxWeight && area>0.25*area_LV && area<area_LV
    maxWeight = weight;
    k_RV = k;
  end
end
boundary = B{k_RV}; % Get boundary of RV
delta_sq = diff(boundary).^2;    
area = stats(k_RV).Area; % Get area of RV
centroid = stats(k_RV).Centroid; % Centroid of RV
region_string = sprintf('Right Ventricle - weight of %2.2f', maxWeight);
text(boundary(1,2)-35,boundary(1,1)+13,region_string,'Color','y',...
       'FontSize',10,'FontWeight','bold')
plot(centroid(1),centroid(2),'ko');
hold off;
title('Regions in MRI image with area enclosed by RV highlighted');

Imask = zeros(size(I));
% Get index corresponding to right ventricle
index = sub2ind(size(Imask),boundary(:,1),boundary(:,2));
Imask(index) = 1; % Set boundary to white
se = strel('disk',se_size);
Imask = imfill(Imask,'holes'); % Fill boundary region
Imask = imdilate(Imask,se); % Dilate to compensate for size
Imask(Imask_myo==1) = 1; % Fill in myocardium
Imask = imclose(Imask,se); % Dilate until RV reaches myocardium
Imask(Imask_myo==1) = 0; % Remove myocardium
Imask = bwareaopen(Imask,30); % Remove any stray small objects
end

