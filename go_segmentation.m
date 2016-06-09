clear all
close all
warning off;

%%%%Select one of the two sample videos provided with the code
Video = 'IM05';
%Video = 'IM03';

if strcmp(Video, 'IM03')
    go_config_im03;
elseif strcmp(Video, 'IM05')
    go_config_im05;
end

video_folder = fullfile(pfx_crowd_dataset, pfx_crowd_video);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Find out resolution of the grid used for the optical flow computation
optical_flow_folder     = fullfile(pfx_crowd_dataset, pfx_crowd_video, pfx_optical_flow);

optical_flow_file_names = dir([optical_flow_folder, '\*.mat']);

matMotionFileName = fullfile ( optical_flow_folder, optical_flow_file_names(1).name );

load(matMotionFileName);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ftle_folder     = fullfile(pfx_crowd_dataset, pfx_crowd_video, pfx_FTLE);

ftle_options.ftle_folder = ftle_folder;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(ftle_folder, 'dir');
    mkdir(ftle_folder);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_frame = 1;

end_frame   = length(optical_flow_file_names);


for start_time = start_frame : end_frame

        end_time = start_time + ftle_options.maximum_integration_time - 1;
    
        if end_time > end_frame
            break
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%For forward integration and analysis%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [forward_sigma, forward_xflowmap, forward_yflowmap]      =  ComputeForwardFTLE(start_time, end_time, optical_flow_folder, ftle_options);
        clear forward_xflowmap forward_yflowmap
        
        %%%%%%remove the boundary data of the FTLE field --- due to noisy optical flow at the image boundary
        [forward_sigma]                 = cleanboundary(forward_sigma, ftle_options.pixels_to_remove);

        %%%%%%%%Smooth the computed ftle by a Guassian
        [smth_forward_sigma]            = smooth_ftle(forward_sigma, ftle_options);
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%For reverse integration and analysis%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [backward_sigma, backward_xflowmap, backward_yflowmap]   =  ComputeBackwardFTLE(end_time, start_time, optical_flow_folder, ftle_options);
        clear forward_xflowmap forward_yflowmap

        %%%%%%remove the boundary data of the FTLE field --- due to noisy optical flow at the image boundary
        [backward_sigma]                = cleanboundary(backward_sigma, ftle_options.pixels_to_remove);

        %%%%%%%%Smooth the computed ftle by a Guassian
        [smth_backward_sigma]           = smooth_ftle(backward_sigma, ftle_options); 
       
        smth_forward_sigma = filter_ftle(smth_forward_sigma);
        smth_backward_sigma = filter_ftle(smth_backward_sigma);
        
        [seg_mask] = compute_watershed( smth_forward_sigma, smth_backward_sigma, optical_flow_folder, [start_time, end_time], ftle_options.pixels_to_remove);

        if ~exist(fullfile(video_folder, 'Segmentation'), 'dir')
            mkdir(fullfile(video_folder, 'Segmentation'));
        end
        
        seg_file_name = fullfile(video_folder, 'Segmentation', sprintf('SegmentationMask%d-%d.mat', start_time, end_time));
        
        save(seg_file_name, 'seg_mask');
        
        seg_image_name = fullfile(video_folder, 'Segmentation', sprintf('Segmentation%d-%d.jpg', start_time, end_time));
        
        imwrite(cat(3,seg_mask, seg_mask, seg_mask)./255,seg_image_name);
        
end

disp('Done');







