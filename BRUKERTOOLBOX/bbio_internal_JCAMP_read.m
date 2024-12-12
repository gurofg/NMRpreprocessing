

function [STRUCT, TXT] = bbio_internal_JCAMP_read( aFile)
%
% ----------------------------------------------------------------
% -------------------- Bruker Biospin Toolbox --------------------
% ----------------------------------------------------------------
% bbio_internal_JCAMP_read = Reading JCAMP files (acqus, procs)
%
%
% INPUT:
%       aFile:
%           JCAMP-File like acqus or procs
%
%
% OUTPUT:
%       STRUCT:
%           a struct containing all JCAMP information
%       TXT:
%           string containing the file as text
%
% ----------------------------------------------------------------
    STRUCT = [];
    TXT    = [];

    if exist( aFile, 'file')
    
        TXT = bbio_internal_loadtext( aFile);

        REG = regexp(TXT,'#\$([^\=])*=\s*(.*?)\s+#','tokens');

        for i=1:length(REG)
            x = strtrim(REG{i}{2});

            % convertable to double? (fast method)
            [a,count,errmsg,nextindex] = sscanf(x,'%f',1);
            if count == 1 && isempty(errmsg) && nextindex > length(x)
                x = a;
            end;
            % saving
            STRUCT.(REG{i}{1}) = x;
        end;
        
    end;