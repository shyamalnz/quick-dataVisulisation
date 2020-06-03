
try
    fig_c = fig_number;
    
    keep_vars = {
        ''
        };
    str_line = '-------------------------------------';
    
    
    dispstat('','init');
    disp_str = [newline,str_line,newline,'quick_dataVisulisation',newline,str_line];
    dispstat(disp_str,'keepthis');
    
    %% loading, croping, zero regions
    quick_loadCropData
    
    %% make slices
    if plot_slices || plot_slices_LSQ
        quick_do_traces
    end
    
    %%
    dispstat(newline,'keepthis');
    
    %% Plot Simple
    if plot_slices
        quick_plot_simple
        pause(1);
    end
    % this produces 1 figure
    fig_c = fig_c + 1;
    
    %% Plot LSW
    if plot_slices_LSQ
        quick_plot_LSQ
        pause(1);
    end
    % this produces 1 figure
    fig_c = fig_c + 1;
    
    %% SVD
    if do_SVD
        % Update Command Line
        disp_str = ['Figures ',num2str(fig_c),' to ',num2str(fig_c+1),' - SVD'];
        dispstat(disp_str,'keepthis');
        
        [ U,S,V,diagS ] = f_SVD( data_no_nan, time, wave,'NumPlotted',components_to_plot,'fig',fig_c);
    end
    % this produces 2 figure
    fig_c = fig_c + 2;
    
    %% Global Fit
    if do_global_fit
        quick_do_GF
        pause(1);
    end
    % this produces 2 figure
    fig_c = fig_c + 2;
    
catch ME
    
    %% Error Code
    
    %pause(1)
    close all
    save('error_dump')
    strErr = [
        'Unable to continue.',newline,...
        ];
    fprintf(2,strErr)
    strErr = [
        'Closing figures. Please send "error_dump.mat" with description of what you are doing',newline,...
        newline,...
        ME.stack(end).name,' (line ',num2str(ME.stack(end).line),')',newline,...
        newline,...
        ME.message
        ];
    disp(strErr)
    %
    if error_reporting
        save('error_dump')
        warning('Error reporting enabled. Please send "error_dump.mat" with description of what you are doing')
    end
end

%% Clean up workspace
disp_str = [newline,'Finished',newline,str_line];
dispstat(disp_str,'keepthis');