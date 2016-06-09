function [sigma, xflowmap, yflowmap] = ComputeForwardFTLE(start_frame, end_frame, optical_flow_folder, ftle_options)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

optical_flow_file_names = dir([optical_flow_folder, '\*.mat']);

matMotionFileName = fullfile ( optical_flow_folder, optical_flow_file_names(start_frame).name );

load(matMotionFileName);

um = nan2zeros(u);
vm = nan2zeros(v);

counter = 1;

for i = start_frame + 1  : end_frame

    matMotionFileName = fullfile ( optical_flow_folder, optical_flow_file_names(i).name );

    load(matMotionFileName);

    um = um + nan2zeros(u);
    vm = vm + nan2zeros(v);

    counter = counter + 1;

end

um = um ./ counter;
vm = vm ./ counter;

x1 = min(x(:));
x2 = max(x(:));
y1 = min(y(:));
y2 = max(y(:));

xmesh = x;

ymesh = y;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dt       = ftle_options.step_size;

frame_rate = ftle_options.frame_rate;

t_length = end_frame - start_frame + 1;

T_span  = (end_frame/frame_rate) - (start_frame/frame_rate) + (1/frame_rate);

fprintf('Forward particle advection --- Frame range: %d....%d \n', start_frame, end_frame);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Assuming that the mean field is representative of the motion in this
%%% block of frames. Since algorithm is working on a sliding window any
%%% changes in the dynamic behavior of the underlying flow will be captured
%%% by later blocks. This step also helps in reducing the effect of noise
%%% from the optical flow algorithm.
u = um;
v = vm;

for t_integration = 1 : t_length - 1;

    index = start_frame + t_integration - 1;

    if ftle_options.directional_segmentation == true

        [u, v] = normalize_magnitude(u,v);

        u = nan2zeros(u);

        v = nan2zeros(v);
    end

 
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%Advection%%%%%%%%%%
    if t_integration == 1

        xflowmap{t_integration} = xmesh;

        yflowmap{t_integration} = ymesh;

    else

        xflowmap{t_integration} = xflowmap{t_integration-1} + dt*interp2(xmesh, ymesh, u, xflowmap{t_integration-1}, yflowmap{t_integration-1}, 'linear', 0);

        yflowmap{t_integration} = yflowmap{t_integration-1} + dt*interp2(xmesh, ymesh, v, xflowmap{t_integration-1}, yflowmap{t_integration-1}, 'linear', 0);

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%

end

fprintf('Computing forward FTLE \n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[xFX,xFY] = gradient(xflowmap{end}, xmesh(1,2) - xmesh(1,1));
[yFX,yFY] = gradient(yflowmap{end},  ymesh(2,1)- ymesh(1,1));

sigma = zeros(size(xFX));

for i =1 : size(xFX,1)

    for j = 1 : size(xFX,2)

        A11= xFX(i, j);
        A12= xFY(i, j);
        A21= yFX(i, j);
        A22= yFY(i, j);

        A=[A11 A12;A21 A22];

        B=A'*A;

        delta=max(eig(B));

        sigma(i,j) = log(delta)/(2*T_span);

    end

end

%%%%%%%Save FTLE data
[pfx_crowd_folder,garbage] = fileparts(optical_flow_folder);

ftle_folder     = fullfile(pfx_crowd_folder, 'FTLE');

if ~exist([ftle_folder])
    mkdir(ftle_folder);
end

matFTLEFileName = fullfile ( ftle_folder, sprintf('ForwardFTLE%04d-%04d.mat', start_frame, end_frame ));

% save(matFTLEFileName, 'ftle_options', 'xflowmap', 'yflowmap', 'xFX', 'yFX', 'xFY', 'yFY', 'sigma');
save(matFTLEFileName, 'ftle_options', 'sigma');

