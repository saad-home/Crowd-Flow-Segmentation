function [u, v] = normalize_magnitude(U,V)

magnitude = sqrt(U.^2 + V.^2);

[N,X]  = hist(magnitude(:));
Thresh = X(2) - X(1);
% keyboard;
ind = find(magnitude <  Thresh);

U_th = U;
V_th = V;
U_th(ind) = 0;
V_th(ind) = 0;

magnitude = sqrt(U_th.^2 + V_th.^2);
ind = find(magnitude ~= 0);
% 
maxu = mean(U_th(:));
maxv = mean(V_th(:));
% 
maxmag = sqrt(maxu^2 + maxv^2);
scalefactor = maxmag./magnitude; 
% 
ind = find(isinf(scalefactor)==1);
scalefactor(ind) = 0;
% 
u = U_th .* scalefactor; 
v = V_th .* scalefactor;