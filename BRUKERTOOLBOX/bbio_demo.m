
% ------------------------------------------------------
% --------------- Bruker Biospin Toolbox ---------------
% ------------------------------------------------------
%
%      DEMO File
%

%% Getting all 1r-files inside a Directory

    aDirectory = '.\demo-data\1D';
    FILELIST   = bbio_all_1r_files( aDirectory);


%% Loading 1-Data

    % Reading Pure Real RAW Data
    RAW = bbio_spec_read1d( FILELIST);
    % --> RAW is a structure with all spectra

    % Reading with imaginary data
    RAW_withImag = bbio_spec_read1d( FILELIST,'imaginary',true);


%% Plotting Data with BBIO-Toolbox

    figure(1);
    clf;
    bbio_spec_plot1d(RAW,'ppm',[-1 13]);

%% Plotting Data manually

    figure(2);
    clf;
    % Getting ppm-axis of a spectrum
    ppm = bbio_spec_ppm(RAW(1));
    % Plotting
    plot(ppm,RAW(1).Data);
    set(gca,'xdir','reverse');


%% Creating a Bucket-Table

    % Scale to integral from 0.5 to 9.5 ppm without 4.5-6
    [RAW_SCALED,SCALE]  = bbio_spec_scale( RAW, 'mode','int','ppm',[0.5 4.5],...
                                        'exclusions',[4.5 6]);

    % We will have 450 buckets    
    MDATA1 = bbio_spec_bucket1d(RAW,'ppm',[0.5 9.5],'buckets',450,...
                                'null',[]);

    % Bucket width = 0.001
    MDATA2 = bbio_spec_bucket1d(RAW,'ppm',[0.5 9.5],'delta',0.001,...
                                'null',[4.5 6; 8 8.5]);                            

%% Plotting Bucketed-Data

    figure(3);
    clf;
    plot(MDATA2.PPM, MDATA2.DATA);
    set(gca,'xdir','reverse');

%% Reading 2D-Files

    a2D = '.\demo-data\2D\13\pdata\1\2rr';

    RAW2D = bbio_spec_read2d({a2D});

    % Plotting 2D Files
    figure(4);
    clf;
    subplot(2,1,1);
    bbio_spec_plot2d( RAW2D,'ppm1',[2.4 3.4],'drawmode','raster','yscale',40,...
                            'JRES',true);

    subplot(2,1,2);
    bbio_spec_plot2d( RAW2D,'ppm1',[2.4 3.4],'drawmode','contour',...
                        'clevels',[0.05:0.05:3 10 15 20 40],'JRES',true);
                            