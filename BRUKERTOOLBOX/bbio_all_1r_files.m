
function FILELIST = bbio_all_1r_files( START_DIR)
%
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
%
% function FILELIST = bbio_all_1r_files(START_DIR)
%  - Gives a list of all 1r-files in directory 
%    START_DIR (recursive reading)
%  - ignores Expno=99999
%  - FILELIST is a cellarray
%
% ------------------------------------------------------    

    FILELIST = recursive_reading(START_DIR);
 
    
function FILELIST = recursive_reading(BASEDIR)

    FILELIST = {};

    D = dir(BASEDIR);
    
    for i=1:length(D)
        s = D(i).name;
        c = [BASEDIR '\' s];
        if strcmp(s,'.') || strcmp(s,'..')
            continue;
        end;
        if isdir(c)
            tmpL = recursive_reading(c);
            FILELIST = union(FILELIST, tmpL);
        end;
        if strcmp(s,'1r') && (isempty(findstr(c,'\99999\pdata\')))
            FILELIST = union(FILELIST, c);
        end;
    end;
    