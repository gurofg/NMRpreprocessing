function z = asysm(y, lambda, p, d);

% function z = asysm(y, lambda, p, d);
% Baseline estimation with asymmetric least squares. gives the baseline,
% this must be subtracted from sample
% y:      signal, one sample
% lambda: smoothing parameter (generally 1e5 to 1e8)
% p:      asymmetry parameter (generally 0.001)
% d:      order of differences in penalty (generally 2)
% see asysm_dataset for correcting whole matrix, GFG
% Paul Eilers, 2002

m = length(y);
w = ones(m, 1);
repeat = 1;
while repeat ;
   z = difsmw(y, lambda, w, d);
   w0 = w;
   w = p * (y > z) + (1 - p) * (y <= z);
   repeat = sum(abs(w - w0)) > 0;
end


