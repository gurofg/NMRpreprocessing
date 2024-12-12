function [ppm_scale] = make_ppm(ppm_1,var_1,ppm_2,var_2,end_var);

% a function for defining a ppm scale to your spectra
% [ppm_scale] = make_ppm(ppm_1,var_1,ppm_2,var_2,end_var);
% ppm_1 = ppm value of point 1 with highest value ppm
% var_1 = corresponding variable number
% ppm_2 = ppm value of point 2 with lower ppm value
% var_2 = corresponding variable number
% end_var = lenght of matrix

ppm_x = ppm_2 - ppm_1; 
var_x = var_2-var_1; 
y = ppm_x/var_x; % each variable is y ppms (negative number)
ppm_start = ppm_1 - (y*(var_1-1)); %ppm value of first variable
ppm_end = ppm_1 +(y*(end_var-var_1));  %ppm value of last variable

steps = (ppm_start-ppm_end)/(end_var-0.5); %minus 0.5 to get right nr of points
ppm_scale = [ppm_end:steps:ppm_start];
ppm_scale = fliplr(ppm_scale);

end



%Noen ppm
% Creatin: 3.03 og 3.92
% Glycine: 3.55 
% TSP: 0
% formate: 8.46

