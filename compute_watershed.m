function [seg_mask] = compute_watershed( fLCS, bLCS, optical_flow_folder, frames, pixels_to_remove )

cLCS = abs(fLCS) + abs(bLCS);
%  cLCS  = filter_ftle(fLCS); 

wat_shed = watershed(cLCS);

%%%%First remove small segments -- less than 150 pixels -- -you can pick
%%%%your own number
clabs = unique(wat_shed(:));

for i = 1 : length(clabs)
    
    inds = find(wat_shed == clabs(i));
    
    if length(inds) <= 150
        
        wat_shed(inds) = 0;
        
    end
    
end

vaccum_inds  = compute_vaccum_inds(optical_flow_folder, frames, pixels_to_remove); %%%where there is no motion information

clabs = unique(wat_shed(:));

if clabs(1) == 0
    clabs = clabs(2:end); 
end

for i = 1 : length(clabs)
    
    inds = find(wat_shed == clabs(i));
    
    common_inds = intersect(inds, vaccum_inds);
    if length(common_inds)/length(inds) > .5
        
        wat_shed(inds) = 0;
        
    end
    
end


clabs = unique(wat_shed(:));

label_counter = 1;

ord =  randperm(length(clabs));

counter = 1;
for i = ord
    
    
    if clabs(i) == 0
        continue;
    end

    ins{counter}.in = find(wat_shed == clabs(i));
    
     counter = counter + 1;
    
end

counter = 1;
for i = ord
    
    if clabs(i) == 0
        continue;
    end

    wat_shed(ins{counter}.in) = label_counter;
        
    label_counter     = label_counter + 10;
    
    counter = counter + 1;
    
end

seg_mask = wat_shed;


function vaccum_inds = compute_vaccum_inds(optical_flow_folder, frames, pixels_to_remove)

optical_flow_file_names = dir([optical_flow_folder, '\*.mat']);

matMotionFileName = fullfile ( optical_flow_folder, optical_flow_file_names(frames(1)).name );

load(matMotionFileName);

um = u;
vm = v;

counter = 1;
for i = frames(1) + 1  : frames(2)

    matMotionFileName = fullfile ( optical_flow_folder, optical_flow_file_names(i).name );

    load(matMotionFileName);

    um = um + u;
    vm = vm + v;

    counter = counter + 1;

end

um = um ./ counter;
vm = vm ./ counter;

[um]                 = cleanboundary(um, pixels_to_remove);
[vm]                 = cleanboundary(vm, pixels_to_remove);

mag = sqrt(um.^2 + vm.^2);

[N,X]  = hist(mag(:));
Thresh = X(2) - X(1);
vaccum_inds = find(mag <= Thresh/3);


  