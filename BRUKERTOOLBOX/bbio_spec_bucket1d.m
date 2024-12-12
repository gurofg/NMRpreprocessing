
function MDATA = bbio_spec_bucket1d( RAW, varargin)
%
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
%
% function MDATA = bbio_spec_bucket1d( RAW, varargin)
%
% Bucketing of 1D-Spectra
%
% Available Parameters are:
%
%    ('ppm',[0.5 9.5])    = ppm-area for bucketing
%    ('buckets',[])       = number of buckets
%    ('delta',[])         = bucket-width
%    ('null',[])          = list of ranges, buckets will be set to 0
%
%    Either "buckets" or "delta" has to be defined!
% ------------------------------------------------------

    % Dealing with the input
    p = inputParser;
    p.addParamValue('ppm',[0.5 9.5]);
    p.addParamValue('buckets',[]);
    p.addParamValue('delta',[]);
    p.addParamValue('null',[]);
    p.parse(varargin{:});
    PARS = p.Results;

    n = length(RAW);
    
    % Build the output struct
    MDATA = [];
    
    if isempty(PARS.buckets) && isempty(PARS.delta)
        error('Either variable "buckets" or "delta" must be defined!');
    end;

    ppm    = PARS.ppm;
    maxppm = max(ppm);
    minppm = min(ppm);
    
    if ~isempty(PARS.buckets)
        % number of buckets is given
        buckets = PARS.buckets;
        bsize   = (maxppm-minppm)/(buckets-1);
    else
        % size of each bucket is given
        bsize   = PARS.delta;
        buckets = floor((maxppm-minppm)/bsize)+1;
    end;
    
    % Generate PPM-Axis
    
    PPM = ones(1, buckets);

    BucketList = zeros(buckets, 2);
    for i=1:buckets
        BucketList(i,1) = (bsize*(i-1)) + minppm - bsize/2;
        BucketList(i,2) = (bsize*(i))   + minppm - bsize/2;
        PPM(i)          = (BucketList(i,1) + BucketList(i,2))/2;
    end;
    
    MDATA.PPM   = PPM;
    MDATA.BLIST = BucketList;
    MDATA.DATA  = zeros(n, buckets);
    
    % test, if PPM is finer or as fine as RAW(1)
    INTERPOL = false;
    p = bbio_spec_ppm(RAW(1));
    deltaPPM = abs(PPM(2)-PPM(1));
    deltaRAW = abs(p(2)-p(1));
    if deltaPPM<deltaRAW*2
        % turn on interpolation-Mode
        INTERPOL = true;
    end;
    
    TMPDATA = MDATA.DATA;
    for k=1:n
        
        % simple but slow method
        %{
        for i=1:buckets
            p   = bbio_spec_ppm(RAW(k));
            idx = p>BucketList(i,1) & p<=BucketList(i,2);
            MDATA.DATA(k,i) = mean(RAW(k).Data(idx));
        end;
        %}
        
        % fast method
        if INTERPOL == false
            SPEC = RAW(k);

            si   = SPEC.size;
            ofs  = SPEC.maxppm;
            sw   = SPEC.sw;
            S    = SPEC.Data;

            tmpV = zeros(1,buckets);
            for i=1:buckets
                % fast method
                [tmp, minind] = internal_ppmindex(ofs, sw, si,  BucketList(i,1)); %#ok<PFBNS>
                [tmp, maxind] = internal_ppmindex(ofs, sw, si,  BucketList(i,2));

                if round(minind) ~= minind
                    minind = ceil(minind);
                end;
                if round(maxind) ~= maxind
                    maxind = ceil(maxind)+1;
                end;
                c = (minind -maxind)+1;
                tmpV(i)=sum(S(maxind:minind))./c;
            end;
            TMPDATA(k,:) = tmpV;
        else
            % Bucketing via Interpolation
            p   = bbio_spec_ppm(RAW(k));
            TMPDATA(k,:) = interp1(p,RAW(k).Data,PPM);
        end;
    end;    
    MDATA.DATA = TMPDATA;
    
    % applying the "null-space", exclusions
    if ~isempty(PARS.null)
        for i=1:size(PARS.null,1)
            MDATA.DATA(:,PPM>PARS.null(i,1) & PPM<PARS.null(i,2)) = 0;
        end;
    end;
    
    
function [index, exactindex] = internal_ppmindex(ofs, sw, size, ppm)

    exactindex = (ofs-ppm)/sw*(size-1);
    index = ceil(exactindex);    
    