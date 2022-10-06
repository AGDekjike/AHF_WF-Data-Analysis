%% Motion Correction
% change line 4 & line 10 to specify your data location!
clear all;
path = 'W:\Mingxuan\WF\data\000C9522CA71'; % specify path for storing WF imaging data
subfolder = dir(path);
to_do_list = cell(0);
for i = 1:size(subfolder)
    sub_name = subfolder(i).name;
    if size(sub_name,2) == 19
        if str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10))) >= 20220702 % date range for data to be processed
            to_do_list{end+1} = sub_name;
        end
    end
end
%size(to_do_list,2) % showing total number of folders for processing
for i = 1:size(to_do_list,2)
    %i %processing the i-th folder
    sub_file = dir(fullfile(path,to_do_list{i}));
    for k = 1:size(sub_file)
        fn = sub_file(k).name;
        fb = sub_file(k).bytes;
        if size(fn,2) == 15 && fb > 10
            clearvars -except i k fn fb sub_file path to_do_list
            sub_path = fullfile(path,to_do_list{i},fn);
            sub_save_path = fullfile(path,to_do_list{i},strcat('MC',fn(6:10),'.tiff'));
            Y = read_file(sub_path); % read the file (optional, you can also pass the path in the function instead of Y)
            Y = single(Y);                 % convert to single precision 
            T = size(Y,ndims(Y));
            Y = Y - min(Y(:));
            options_rigid = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),'bin_width',200,'max_shift',15,'us_fac',50,'init_batch',200);
            [M1,shifts1,template1,options_rigid] = normcorre(Y,options_rigid);
            FTIF = Fast_Tiff_Write(sub_save_path);
            for j = 1:size(M1,3)
                FTIF.WriteIMG(imresize(M1(:,:,j),0.5));
            end
            FTIF.close;
        end
    end
end