function [korrigert] = baselinje(matrise)
% [korrigert] = baselinje(matrise);
%corrects the baseline of each spectum by subtracting the minimum point
%from each variable (= the minimum point of each spectrum is zero)

% input: matrix matrise
% output: baseline corrected matrix korrigert
% GFG 2010 

korrigert = [];
[n,m] = size(matrise);

for i = 1:n
    sample = matrise(i,:);
    minste = min(sample);
    korr = sample - minste;
    korrigert(i,:) = korr;
end

