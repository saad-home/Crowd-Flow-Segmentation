function [sigma] = filter_ftle(sigma)

[ dx , dy ]   = gradient( sigma );
%%%%%Find indices where the gradient of FTLE is zero
grad_mag = sqrt(dx.^2 + dy.^2);

[N,X]  = hist(grad_mag(:));
Thresh = X(2) - X(1);

ind = find(grad_mag <  Thresh);
sigma(ind) = 0;
