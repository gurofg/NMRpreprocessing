
function bbio_spec_plot1d( RAW, varargin)
%
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
%
% function bbio_spec_plot1d( RAW, varargin)
%
% Plots a list of 1r-Spectra
%
% Available Parameters are:
%
%    ('ppm',[])             = ppm-area to plot [min max]
%    ('linewidth',1);       = linewidth
%    ('colormap','jet');    = colormap used for set of spectra
%    ('color',[]);          = all spectra will be plotted in this color
%    ('colors',[]);         = one color for each spectrum
%    ('yoffset',0);         = y-offset for set of spectra
%    ('xoffset',0);         = x-offset for set of spectra
%    ('factors',[]);        = Multplies all spectra by a factor
%    ('zoffset',0);         = z-offset for set of spectra
%    ('filled',false);      = plots a filled spectrum
%    ('filledalpha',1);     = AlphaBlending for filled spectrum
%
%
% ------------------------------------------------------

    % Dealing with the input
    p = inputParser;
    p.addParamValue('ppm',[]);
    p.addParamValue('linewidth',1);
    p.addParamValue('colormap','jet');
    p.addParamValue('color',[]);
    p.addParamValue('colors',[]);
    p.addParamValue('yoffset',0);
    p.addParamValue('xoffset',0);
    p.addParamValue('factors',[]);
    p.addParamValue('zoffset',0);
    p.addParamValue('filled',false);
    p.addParamValue('filledalpha',1);
    p.addParamValue('dataname','Data');
    p.parse(varargin{:});
    PARS = p.Results;
    
    % doing the plotting
    n = length(RAW);
    
    COL = eval([PARS.colormap '(n)']);
    if n==1
        COL = [0 0 0];
    end;
    if n==2
        COL = [0 0 0;1 0 0];
    end;
    if n==3
        COL = [0 0 0;1 0 0;0 0 1];
    end;
    if n==4
        COL = [0 0 0;1 0 0;0 0 1;0 1 0];
    end;
    
    hold on;
    for i=n:-1:1
        
        p = bbio_spec_ppm(RAW(i));
        D = RAW(i).(PARS.dataname);
        
        if ~isempty(PARS.ppm)
            idx = p>PARS.ppm(1) & p<PARS.ppm(2);
            p = p(idx);
            D = D(idx);
        end;
        
        color = COL(i,:);
        
        if ~isempty(PARS.color)
            color = PARS.color;
        end;
        
        if ~isempty(PARS.colors)
            color = PARS.colors(i,:);
        end;        
        
        factor = 1;
        if ~isempty(PARS.factors)
            factor = PARS.factors(i);
        end;
        
        if PARS.filled
            p   = p(:)';
            tmp = D(:)';
            patch([p fliplr(p)],[tmp zeros(1,length(tmp))],'r','FaceColor',color,...
                'EdgeColor',color, 'FaceAlpha',PARS.filledalpha);
        else
            plot3(p + PARS.xoffset*(i), D*factor + PARS.yoffset*(i),...
                ones(length(p),1)*PARS.zoffset,'Color', color,...
                'LineWidth', PARS.linewidth);        
        end;
    end;

    if ~isempty(PARS.ppm)
        set(gca,'xlim',PARS.ppm)
    end;
    
    set(gca,'xdir','reverse');
    xlabel('[ppm]');
    grid on;
    box on;
    hold off;
    
    