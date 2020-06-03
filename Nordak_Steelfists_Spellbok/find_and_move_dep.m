opt.move = 0;
end_dir = 'H:\OneDrive\UNSW\Software\quick-2D-plots\';

if ~exist(end_dir,'dir'), mkdir(end_dir); end

%% Matlab files to check
script_list = {
    'quick_dataVisulisation'
    };
exclusion_list = {
    %'f_UserPref.m'
    %'onedrive.m'
    'PushBulletAPI.m'
    };

%% Checks about move
if opt.move
    button = questdlg('Do you really want to move files');
    if ~strcmp(button,'Yes')
        opt.move = 0;
    end
end

%% Find dependancies
fList = matlab.codetools.requiredFilesAndProducts(script_list);

fList = fList';

%% Move Files
for n = 1 : length(fList)
    f_name = strsplit(fList{n},'\');
    if ~any(strcmp(f_name{end},exclusion_list))
        if ~strcmp(fList{n},[end_dir,f_name{end}])
            if opt.move
                movefile(fList{n},[end_dir,f_name{end}])
            else
                copyfile(fList{n},[end_dir,f_name{end}])
            end
        end
    end
end

