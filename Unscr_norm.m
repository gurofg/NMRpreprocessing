function [Y,snitt] =Unscr_norm(X);

%function [Y,snitt] =Unscr_norm(X);
%Mean normalization of matrix (like in Unscrambler)
%input: matrix X
%output: Y: Normalized matrix
%        snitt: average used in normalization
% GFG, 2010

[m,n]=size(X);

for i=1:m;
    Y(i,:)=X(i,:)./abs(mean(X(i,:)));
    snitt(i) = abs(mean(X(i,:)));
end

