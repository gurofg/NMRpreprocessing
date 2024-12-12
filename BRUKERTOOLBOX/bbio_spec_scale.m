
function [RAW,SCALE] = bbio_spec_scale( RAWIN, varargin)
%
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
% bbio_spec_scale = Scaling 1D NMR Spectra 
%
%
% ------------------------------------------------------

    % Dealing with the input
    p = inputParser;
    p.addParamValue('mode','int');
    p.addParamValue('ppm',[0.5 4.5]);
    p.addParamValue('exclusions',[4.5 6]);
    p.addParamValue('noiseregion',[]);
    p.addParamValue('minHZ',10);
    p.addParamValue('custom',[]);
    p.parse(varargin{:});
    PARS = p.Results;

    % Possible modes are
    %   int    = integral
    %   max    = maximum
    %   min    = minimum-baseline-scale
    %   custom = user provides scaling factor for each spectrum
    %   noise  = scaling to a defined noise region
    
    if strcmpi(PARS.mode,'int')
        SCALE = internal_int(RAWIN, PARS);
    end;
    
    if strcmpi(PARS.mode,'max')
        SCALE = internal_max(RAWIN, PARS);
    end;

    if strcmpi(PARS.mode,'min')
        SCALE = internal_min(RAWIN, PARS);
    end;

    if strcmpi(PARS.mode,'custom')
        SCALE = PARS.custom;
    end;

    if strcmpi(PARS.mode,'noise')
        SCALE = internal_noise(RAWIN, PARS);
    end;
    
    % Apply the Scaling
    RAW = RAWIN;
    for i=1:length(RAW)
        RAW(i).Data = RAW(i).Data ./ SCALE(i);
    end;
    
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

function idx = getppmforuse(p, PARS)

    idx   = find(p>PARS.ppm(1) & p<PARS.ppm(2));
    if ~isempty(PARS.exclusions)
        for i=1:size(PARS.exclusions,1)
            idx   = setdiff(idx, find(p>PARS.exclusions(i,1) & ...
                                      p<PARS.exclusions(i,2)));
        end;
    end;


function SCALE = internal_int(RAWIN, PARS)
    % Simple integration
    SCALE = ones(length(RAWIN),1);
    for i=1:length(RAWIN)
        p     = bbio_spec_ppm(RAWIN(i));
        delta = abs(p(2)-p(1));
        
        idx   = getppmforuse(p, PARS);
        
        S     = sum(RAWIN(i).Data(idx));
        SCALE(i) = S*delta;
    end;


function SCALE = internal_max(RAWIN, PARS)
    % Maximum in region = 1
    SCALE = ones(length(RAWIN),1);
    for i=1:length(RAWIN)
        p     = bbio_spec_ppm(RAWIN(i));
        
        idx   = getppmforuse(p, PARS);
        
        S     = max(RAWIN(i).Data(idx));
        SCALE(i) = S;
    end;    

function SCALE = internal_min(RAWIN, PARS)

    SCALE = ones(length(RAWIN),1);
    for i=1:length(RAWIN)
        p     = bbio_spec_ppm(RAWIN(i));
        
        idx   = (p>PARS.ppm(1) & p<PARS.ppm(2));
        
        STEP  = PARS.minHZ/(abs(p(2)-p(1))*RAWIN(i).SF);
        STEP  = ceil(STEP);
        
        MIN   = bbio_internal_minbase( RAWIN(i).Data(idx), STEP,0);
        SCALE(i) = sum(MIN);
    end;

function SCALE = internal_noise(RAWIN, PARS)
    % MAD of region = 1
    SCALE = ones(length(RAWIN),1);
    for i=1:length(RAWIN)
        p     = bbio_spec_ppm(RAWIN(i));
        
        idx   = getppmforuse(p, PARS);
        
        S     = mad(RAWIN(i).Data(idx));
        SCALE(i) = S;
    end;  
