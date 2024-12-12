
function [TXT, TXTO] = bbio_internal_loadtext( aFile)
%
% ----------------------------------------------------------------
% -------------------- Bruker Biospin Toolbox --------------------
% ----------------------------------------------------------------
% bbio_internal_loadtext = Reading Text-Files
%
% This function reads a text-file.
%
% INPUT:
%       aFile:
%           the text-file to be readed
%
%
% OUTPUT:
%       TXT:
%           string containing the file as text
%
% ----------------------------------------------------------------

    if ~exist( aFile, 'file')
        TXT  = '';TXTO = '';
        return;
    end;

    f = fopen(aFile); 
    if f<0 
        TXT = '';TXTO = '';
       return;
    end;
    TXTO = fread(f);
    fclose(f);
    TXT = char(TXTO');