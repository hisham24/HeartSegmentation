function [I_localEq] = localhisteq(I, A, wSize, km_low,km_high,ks_low,ks_high)
% Performs local histogram equalisation
% param I: Image
% param A: Intensity scaling constant
% param wSize: Region size (must be odd)
% param km_low: km_low*global mean is lower bound of region mean to be scaled
% param km_high: km_high*global mean is upper bound of region mean to be scaled
% param ks_low: ks_low*global std is lower bound of region std to be scaled
% param ks_high: ks_high*global std is upper bound of region std to be scaled
% returns image after local histogram equalisation

[numR, numC] = size(I); % Get size of image
mGlobal = mean(I(:)); % Get global mean
stdGlobal = std(I(:)); % Get global standard deviation
w2 = floor(wSize/2); 
% Pad image such that every pixel in original image can be used as a centre
% for a region
Ipad = padarray(I, [w2 w2], 'replicate', 'both');
I_localEq = I; % Default 

% Loo[ through original image using each pixel as the centre of a region
for i=w2+1:numR+w2
    for j=w2+1:numC+w2
        localR = Ipad(i-w2:i+w2,j-w2:j+w2); % Get local region
        mLocal = mean(localR(:)); % Get local mean
        stdLocal = std(localR(:)); % Get local standard deviation
        
        % Check if satisfies inequality and scale intensity of centre
        % pixel if satisfy
        if (km_low*mGlobal<mLocal)&&(km_high*mGlobal>mLocal) && ...
            (ks_low*stdGlobal<stdLocal)&&(ks_high*stdGlobal>stdLocal)    
            I_localEq(i-w2,j-w2) = I_localEq(i-w2,j-w2)*A;
        end
        
    end
end
        
end
