function [ppm] = bbio_spec_ppm(Spec)
%
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
%
% function [ppm] = bbio_spec_ppm(Spec)
%  - Returns the ppm-axis of the given Spectrum "Spec"
%
% ------------------------------------------------------   

    step = Spec.sw / (Spec.size-1);
    ppm = Spec.maxppm:-step:Spec.minppm;
