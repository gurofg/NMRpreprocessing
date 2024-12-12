

function RAW = bbio_spec_read1d( FileList, varargin)
%
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
% bbio_spec_read1d = Read 1R-NMR files 
%
% This function reads the spectra of all given filenames
% and returns a struct RAW with the Data and almost all
% available parameters
%
% INPUT:
%       FileList:
%            is a cell-array containing the filenames
%            of the files to be read (with 1r)
% Paramters
%       ppmRange: [min max]
%            is a 1x2-array defining the ppm-Range for
%            reading (optional)
%       imaginary: (true/false)
%            boolean, "true" for reading imaginary-part
%
% ------------------------------------------------------

    % Dealing with the input
    p = inputParser;
    p.addParamValue('imaginary',false);
    p.addParamValue('ppmRange',[-1E99 1E99]);
    p.parse(varargin{:});
    PARS = p.Results;
    
    n   = length(FileList);
    RAW = struct('Data',cell(n,1),'Imag',cell(n,1));

    if n>=10
        fprintf('1D-Reading (%d spectra)...\n', n);
    end;
    for k=1:n
        
        cFileName = FileList{k}; 
        cDir      = strrep( cFileName, '1r', '');
        
        if mod(k,100)==0 && k>2
            fprintf(' %d (%.02f%%)\n', k, 100*k/n);
        end;           

        if mod(k,10)==1 && n>=10
            fprintf('.');
        end;           
        
        if exist(cFileName, 'file')~=2
            fprintf('\nFile "%s" does not exist!\n', cFileName);
            continue;
        end;
        
        % loading jcamp-info files acqus, procs
        
        [ACQUS, ACQUSTXT] = bbio_internal_JCAMP_read( [cDir '..\..\acqus']);
        [PROCS, PROCSTXT] = bbio_internal_JCAMP_read( [cDir 'procs']);
        
        AUDITA = bbio_internal_loadtext([cDir '..\..\audita.txt']);
        AUDITP = bbio_internal_loadtext([cDir 'auditp.txt']);        

        titlefile = [cDir 'title'];
        if exist(titlefile,'file')
            myTitle = strtrim(bbio_internal_loadtext(titlefile));
        else
            myTitle = '';
        end;
        
        RAW(k).TITLE     = myTitle;
        RAW(k).ACQUS     = ACQUS;
        RAW(k).PROCS     = PROCS;
        RAW(k).ACQUSTXT  = ACQUSTXT;
        RAW(k).PROCSTXT  = PROCSTXT;
        RAW(k).AUDITA    = AUDITA;
        RAW(k).AUDITP    = AUDITP;

        % save important parameters at top-level

        RAW(k).O1           = ACQUS.O1;
        RAW(k).RG           = ACQUS.RG;
        RAW(k).PULPROG      = ACQUS.PULPROG;
        RAW(k).BF1          = ACQUS.BF1;
        RAW(k).TD           = ACQUS.TD;
        RAW(k).NS           = ACQUS.NS;
        RAW(k).ByteOrder    = PROCS.BYTORDP;
        RAW(k).LB           = PROCS.LB;
        RAW(k).PHC0         = PROCS.PHC0;
        RAW(k).PHC1         = PROCS.PHC1;
        RAW(k).SF           = PROCS.SF;
        RAW(k).Date         = bbio_internal_UnixToMatLabDate(ACQUS.DATE);
        RAW(k).file         = cFileName;
        
        % extract lists like pulses, powerlevels, delays
        
        [PULSES, PL, D, SPECT] = internal_add_customfields_acqus(ACQUS,...
                                        ACQUSTXT);
        RAW(k).PULSES       = PULSES;
        RAW(k).POWERLEVEL   = PL;
        RAW(k).D            = D;
        RAW(k).SPECT        = SPECT;

        RAW(k).PULSES32     = PULSES(1:32);
        RAW(k).D32          = D(1:32);
        RAW(k).POWERLEVEL32 = PL(1:32);

        % reading the spectrum
        
        [si, ofs, sw, real, ncproc, imag] = internal_read_spectrum(...
                                    cFileName, PARS.ppmRange(1), ...
                                    PARS.ppmRange(2), PROCS, ACQUS, PARS);
        RAW(k).Data   = real.*(2^(ncproc));
        RAW(k).Imag   = imag.*(2^(ncproc));
        RAW(k).maxppm = ofs;
        RAW(k).minppm = ofs-sw;
        RAW(k).sw     = sw;
        RAW(k).size   = si;
        
    end;

    if n>=10
        fprintf('\n');
    end;
    

% -------------------------------------------------------------------------    
% -------------------------------------------------------------------------    
% -------------------------------------------------------------------------    
% -------------------------------------------------------------------------    
% -------------------------------------------------------------------------    
    
function [PULSES, PL, D, SPECT] = internal_add_customfields_acqus( ACQUS, ...
                                               ACQUSTXT)

    SPECT = [];
    
    P  = ACQUS.P;
    P1 = strrep(P,sprintf('\n'),' ');
    v1 = regexp(P1,'(\S+)(\s*)','tokens');
    PULSES = zeros(length(v1)-1,1);
    for i=2:length(v1)
       PULSES(i-1) = str2double(v1{i}{1});
    end;

    P  = ACQUS.PL;
    P1 = strrep(P,sprintf('\n'),' ');
    v1 = regexp(P1,'(\S+)(\s*)','tokens');
    PL = zeros(length(v1)-1,1);
    for i=2:length(v1)
       PL(i-1) = str2double(v1{i}{1});
    end;

    P  = ACQUS.D;
    P1 = strrep(P,sprintf('\n'),' ');
    v1 = regexp(P1,'(\S+)(\s*)','tokens');
    D = zeros(length(v1)-1,1);
    for i=2:length(v1)
       D(i-1) = str2double(v1{i}{1});
    end;

    v1 = regexp(ACQUSTXT,'##OWNER=([^\n]*)\n([^\n]*)\n','tokens','once');
    if length(v1)==2
        lin = (v1{2}); 
        atpos = strfind(lin,'@');
        if ~isempty(atpos)
            SPECT = strtrim(lin((atpos(1)+1):end));
        end;        
    end;    



function [si, ofs, sw, real, ncproc, imag] = internal_read_spectrum( aFile,...
                                            minppm, maxppm, INFO, INFO2,...
                                            PARS)

    % byteorder?
    dataformat = 'l';
    if INFO.BYTORDP == 1
        dataformat = 'b';
    end;
    
    % get important parameters
    ofs    = INFO.OFFSET;
    sw     = INFO2.SW;
    ncproc = INFO.NC_proc;
    si     = INFO.SI;

    minppmindex = floor((ofs-minppm)/sw*(si-1));
    maxppmindex = ceil((ofs-maxppm)/sw*(si-1));

    if maxppmindex<0;
        maxppmindex = 0;
        minppmindex = si-1;
    end;

    if ~exist(aFile,'file')
        si     = 0;
        ofs    = 0;
        sw     = 0;
        real   = NaN;
        ncproc = 0;
        return;
    end;

    count = minppmindex - maxppmindex + 1;
    if count>0
        f = fopen (aFile, 'r',dataformat);
        fseek(f, maxppmindex*4,0);
        [real,si2]=fread(f,count, 'int32'); 
        fclose (f);
        if PARS.imaginary == true
            % loading the imaginary part
            iFile = strrep(aFile,'1r','1i');
            f = fopen (iFile, 'r',dataformat);
            fseek(f, maxppmindex*4,0);
            imag = fread(f,count, 'int32'); 
            fclose (f);
        else
            imag = [];
        end;
    else
        real = [];
        si2 = 0;
    end;
    ofs = (ofs - sw/(si-1)*maxppmindex);
    sw  = (ofs - sw/(si-1)*maxppmindex) - (ofs - sw/(si-1)*minppmindex);
    si = si2;
    