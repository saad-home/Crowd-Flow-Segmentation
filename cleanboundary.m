function [sigma] = cleanboundary(sigma, pixels_to_remove)

sigma(1:pixels_to_remove,:) = 0;
sigma(:,1:pixels_to_remove) = 0;
sigma(end-pixels_to_remove:end,:) = 0;
sigma(:,end-pixels_to_remove:end) = 0;

sigma = sigma(pixels_to_remove+1:end-pixels_to_remove-1,pixels_to_remove+1:end-pixels_to_remove-1);
