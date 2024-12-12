function[Mshift] = Shiftcorr(X,a,b); 
% [Mshift] = Shiftcorr(X,a,b); 
% Function to reference the spectra to a certain peak 
% Input: X: input matrix
%        a: lowest variable number of region to reference to
%        b: highest variable number of region to reference to
% Output: Shiftcorrected matrix Mshift
% Eldrid Borgan 2011; GFG 2012
Mshift = [];
cre = X(:,a:b)'; %find max point in this area
nsamp = size(X,1);
nfreq = size(X,2);
[m,I] = max(cre); %spekter med cre-peaken tidligst forblir som den er
I2 = I - min(I)+1; % de andre flyttes tilsvarende den, ved å kutte på starten
tmp = zeros(nsamp,nfreq); %legger til nuller på enden tilsvarende det som er kuttet på starten

for i = 1:nsamp
   tmp(i,:) = [X(i,I2(i):nfreq)'; zeros(I2(i)-1,1)]; 
   Mshift = tmp(:,1:nfreq-max(I2));
end