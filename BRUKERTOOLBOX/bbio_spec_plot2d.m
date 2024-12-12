
function bbio_spec_plot2d( RAW2D, varargin)
%
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
%
% function bbio_spec_plot2d( RAW2D, varargin)
%
% Available Parameters:
%
%    ('ppm1',[]);
%    ('ppm2',[]);
%    ('smooth',2);
%    ('yscale',1);
%    ('drawmode','raster');
%    ('clevels',1:1:64);
%    ('patchalpha',0.1);
%    ('patchfilled',true);
%    ('colormap',[]);
%    ('JRES',false);
%    ('normalize',true);
%
% ------------------------------------------------------

    % Dealing with the input
    p = inputParser;
    p.addParamValue('ppm1',[]);
    p.addParamValue('ppm2',[]);
    p.addParamValue('smooth',2);
    p.addParamValue('yscale',1);
    p.addParamValue('drawmode','raster');
    p.addParamValue('clevels',1:1:64);
    p.addParamValue('patchalpha',0.1);
    p.addParamValue('patchfilled',true);
    p.addParamValue('colormap',[]);
    p.addParamValue('JRES',false);
    p.addParamValue('normalize',true);
    p.parse(varargin{:});
    PARS = p.Results;


    i1 = 1:length(RAW2D.PPM1);
    i2 = 1:length(RAW2D.PPM2);
    
    if ~isempty(PARS.ppm1)
        i1 = find(RAW2D.PPM1>PARS.ppm1(1) & RAW2D.PPM1<PARS.ppm1(2));
    end;
    if ~isempty(PARS.ppm2)
        i2 = find(RAW2D.PPM2>PARS.ppm2(1) & RAW2D.PPM2<PARS.ppm2(2));
    end;
    
    DATA2D = RAW2D.Data(i1,i2);
    PPM1   = RAW2D.PPM1(i1);
    PPM2   = RAW2D.PPM2(i2);
    if PARS.JRES
        PPM2 = PPM2*RAW2D.HZFactor;
    end;
    
    
    % Get the Noise (prel.)
    Noise = mad(RAW2D.Data(1,:)')*5;
    DATA2D(DATA2D<Noise) = 0;

    % Smoothing filter
    if PARS.smooth>0
        F = [.05 .1 .05; .1 .4 .1; .05 .1 .05];
        B = F;
        for j=1:PARS.smooth
            F = conv2(F,B);
        end;
        DATA2D = conv2(DATA2D,F,'same');
    end;

    % define the colormap
    CM = jet(128);
    CM(1,:) = [1 1 1];
            

    if strcmpi(PARS.drawmode,'raster')
        % Drawing a fast raster image
        if PARS.normalize
            DATA2D = NormalizeMatrix(DATA2D);
        end;
        colormap(CM);
        image(PPM1,PPM2,DATA2D' * PARS.yscale)
    end;
    
    if strcmpi(PARS.drawmode,'contour')
        % Drawing filled contours
        DrawContour(DATA2D, PPM1,PPM2, PARS);
     end;
    
    set(gca,'xdir','reverse');  
    set(gca,'ydir','reverse');  
    xlabel('[ppm]');
    ylabel('[Hz]');
    grid on;
    box on;    

% -------------------------------------------------------------------------

function DrawContour(DATA2D, PPM1,PPM2, PARS)
        
    LEVELS = PARS.clevels;
    
    % get the contours
    DATA2D = NormalizeMatrix(DATA2D);
    C  = contourc(PPM1,PPM2,DATA2D', LEVELS);
    CM = jet(length(LEVELS));
    
    if ~isempty(PARS.colormap)
        CM = PARS.colormap;
    end;
    
    pos = 1;
    while pos<size(C,2) 
        v = C(:,pos);
        mpos = find(LEVELS==v(1));
        if mpos>size(CM,1)
            mpos = size(CM,1);
        end;
        col  = CM(mpos,:);

        if PARS.patchfilled == true
            myFaceColor = col;
            myEdgeColor = 'none';
        else
            myFaceColor = 'none';
            myEdgeColor = col;
        end;
        
        patch(C(1,(pos+1):(pos+v(2))),C(2,(pos+1):(pos+v(2))),...,
                ones(1,v(2))+mpos,'k',...
                'FaceColor',myFaceColor,...
                'EdgeColor',myEdgeColor,...
                'FaceAlpha',PARS.patchalpha);
        
        pos = pos + v(2) + 1;
    end;

    
 function M = NormalizeMatrix(MIN)
        
        M = MIN;
        
        M = M./max(M(:));
        M = M*64;
        