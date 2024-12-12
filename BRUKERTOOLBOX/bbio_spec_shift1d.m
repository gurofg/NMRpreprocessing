
function RAW = bbio_spec_shift1d(RAW, shift)
%
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
%
% function RAW = bbio_spec_shift1d(RAW, shift)
%  - Shifts Spectrum RAW by "shift" ppm
%
% ------------------------------------------------------   

    RAW.minppm = RAW.minppm - shift;
    RAW.maxppm = RAW.maxppm - shift;
    
    