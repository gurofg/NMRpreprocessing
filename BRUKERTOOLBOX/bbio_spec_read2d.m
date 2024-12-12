

function RAW2D = bbio_spec_read2d( FileList)
%
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
%
% function RAW2D = bbio_spec_read2d( FileList)
%
% This function reads the spectra of all given filenames
% and returns a struct RAW2D with the Data and almost all
% available parameters
%
% INPUT:
%       FileList:
%           cell-array of filenames (ending with 2rr)
%
%
% OUTPUT:
%       RAW2D:
%           a struct containing all spectra information
%
% ----------------------------------------------------------------
    n     = length(FileList);
    RAW2D = struct('Data',cell(n,1));

    if n>5
        fprintf('2D-Reading (%d spectra)...\n', n);
    end;
    for k = 1:n
        if n>5
            if mod(k,50)==0
                fprintf('\n');
            end;
            fprintf('.');
        end;
        SPECPATH =  strrep( FileList{k},'2rr','');
        
        % Loading Parameters
        ACQUS  = bbio_internal_JCAMP_read([SPECPATH '..\..\acqus']);
        ACQU2S = bbio_internal_JCAMP_read([SPECPATH '..\..\acqu2s']);

        PROCS  = bbio_internal_JCAMP_read([SPECPATH 'procs']);
        PROC2S = bbio_internal_JCAMP_read([SPECPATH 'proc2s']);

        % Loading Data
        f = fopen ( FileList{k}, 'r','l');
        count = PROCS.SI*PROC2S.SI;
        real  = fread(f,count, 'int32'); 
        fclose(f);

        % Converting Data
        F  = zeros(PROCS.SI,PROC2S.SI).*NaN;
        X  = PROCS.XDIM;
        Y  = PROC2S.XDIM;
        nX = PROCS.SI/X;
        nY = PROC2S.SI/Y;

        idx = 1:X*Y;
        for j=1:nY
            for i=1:nX
                F( (1:X) + (i-1)*X,(1:Y) + (j-1)*Y) = ...
                    reshape(real(idx),X,Y);
                idx = idx + X*Y;
            end;
        end;

        % Storing to Struct
        RAW2D(k).SPECPATH = SPECPATH;
        RAW2D(k).FILE     = FileList{k};
        RAW2D(k).ACQUS    = ACQUS;
        RAW2D(k).ACQU2S   = ACQU2S;
        RAW2D(k).PROCS    = PROCS;
        RAW2D(k).PROC2S   = PROC2S; 
        RAW2D(k).Data     = F;
        RAW2D(k).Date     = bbio_internal_UnixToMatLabDate(ACQUS.DATE);
        RAW2D(k).file     = FileList{k};

        RAW2D(k).PPM1     = getppmaxis(ACQUS.SW,PROCS.SI,...
                                PROCS.OFFSET,PROCS.OFFSET -ACQUS.SW );
        RAW2D(k).PPM2     = getppmaxis(ACQU2S.SW,PROC2S.SI,...
                                PROC2S.OFFSET,PROC2S.OFFSET -ACQU2S.SW );

        RAW2D(k).HZFactor = PROC2S.SF;
        
    end;
    if n>5
        fprintf('\n');
    end;
    
    function ppm = getppmaxis(SW,SIZE,MAXPPM,MINPPM)
        step = SW / (SIZE-1);
        ppm  = MAXPPM:-step:MINPPM;     
    
    
    
    
    