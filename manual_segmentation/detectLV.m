function [Imask,centroid,area] = detectLV(I, threshold)
% Function detects LV region by using circle detection
% algorithm.
% param I: Image
% param threshold: minimum roundness to be considered LV
% Returns mask, centroid and pixel area of LV

[B,L] = bwboundaries(I,'noholes'); %Get boundaries and regions in image
%Show regions in image
figure;
imshow(label2rgb(L,@jet,[.5 .5 .5])); 
hold on;

%Get Area and Centroid of regions in image
stats = regionprops(L,'Area','Centroid'); 
k_LV = 0;
maxArea = 0;
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

  % Object with the largest area that has a metric above threshold and 
  % below 1 is considered the left ventricle
  if metric > threshold && metric < 1 && area>maxArea
      maxArea = area;
      k_LV=k; 
  end
end

boundary = B{k_LV}; % Get boundary of left ventricle
delta_sq = diff(boundary).^2;    
perimeter = sum(sqrt(sum(delta_sq,2))); % Get perimeter of left ventricle
area = stats(k_LV).Area; % Get area of left ventricle
metric = 4*pi*area/perimeter^2; % Calculate metric of left ventricle
metric_string = sprintf('Left Ventricle - roundness metric of %2.2f', metric);
text(boundary(1,2)-35,boundary(1,1)+13,metric_string,'Color','y',...
       'FontSize',10,'FontWeight','bold');
centroid = stats(k_LV).Centroid; % Centroid of left ventricle
plot(centroid(1),centroid(2),'ko');
hold off;
title('Regions in MRI image with left ventricle highlighted');

Imask = zeros(size(I)); %Initialize mask as black image
% Get index values of boundary
index = sub2ind(size(Imask),boundary(:,1),boundary(:,2));
Imask(index)=1; %Set boundary pixels to white
Imask = imfill(Imask,'holes'); %Fill boundary to get LV
end

