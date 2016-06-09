function [out] = nan2zeros(im)
% Converts matrices with NaNs to Zeros

if(size(im,3) == 1)
    
    temp = im(:);
    pts = isnan(temp);
    temp(pts) = 0;
    out = reshape(temp, size(im,1), size(im,2));
    
else
    
    temp = im(:);
    pts = isnan(temp);
    temp(pts) = 0;
    out = reshape(temp, size(im,1), size(im,2), size(im,3));
end

