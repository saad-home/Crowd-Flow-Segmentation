% select a set of configuration parameters


pfx_crowd_dataset          = 'Data';
pfx_crowd_video            = 'IM05';

img_ext                    = 'bmp';

pfx_optical_flow           = 'OpticalFlow';

pfx_FTLE                   = 'FTLE';

optical_flow_method       = 'Brox';


%%%Optical flow paramters
oflow_options.ITT = 16; %intterogation size in pixels, same on in X and Y direction

oflow_options.SPC = 1;

oflow_options.S2NM = 2;

oflow_options.S2NL = 1;

oflow_options.SCLT = 1;

oflow_options.OUTL = 10;

oflow_options.frame_jump = 1;


%%%%%%%For multiscale (in time) FTLE computation
ftle_options.minimum_integration_time = 95; %frames

ftle_options.maximum_integration_time = 95; %frames

ftle_options.jump_integration_time    = 5; %frames

ftle_options.frame_rate               = 8; %frames per second

ftle_options.step_size                = 1/ftle_options.frame_rate;

ftle_options.modes                     = 2;

ftle_options.remove_noise              = false;

ftle_options.smoothing                  = true;

ftle_options.smoothing_sigma            = 1;

ftle_options.smoothing_filter_size      = 7;

ftle_options.pixels_to_remove           = 10;

ftle_options.directional_segmentation   = true;

ftle_options.gradient_line_integration_length = 50;


segmentation_options.sample_rate   = 0.005;

segmentation_options.number_of_subsegments_fine     = 500;

segmentation_options.use_mean_field = true;

