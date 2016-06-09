function [smth_sigma]  = smooth_ftle(sigma, ftle_options)

sz = ftle_options.smoothing_filter_size;

if ftle_options.smoothing == true

    sg = ftle_options.smoothing_sigma; 
    
    hsize = [sz*sg+1, sz*sg+1]; gaussian = fspecial('gaussian',hsize,sg);

    smth_sigma  = filter2(gaussian, sigma);        % Smoothed FTLE.
else
    smth_sigma = sigma;
end

