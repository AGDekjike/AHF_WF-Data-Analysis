clear all;
path = 'X:\Mingxuan\WF\data\000C95238D37';
if ~exist(fullfile(path,'avg'), 'dir')
   mkdir(fullfile(path,'avg'));
end
subfolder = dir(path);
to_do_list = cell(0);
for i = 1:size(subfolder)
    sub_name = subfolder(i).name;
    if size(sub_name,2) == 19
        if str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10))) >= 20221001
            to_do_list{end+1} = sub_name;
        end
    end
end
size(to_do_list,2)
for i = 1:size(to_do_list,2)
    clearvars -except i to_do_list path
    i
    data = readMultipageTiff(fullfile(path,to_do_list{i},'MC00001.tiff'));
    files = dir(fullfile(path,to_do_list{i}));
    for j = 1:size(files)
        fn = files(j).name;
        if size(fn,2) == 12
            if str2num(fn(7)) ~= 1
                temp = readMultipageTiff(fullfile(path,to_do_list{i},fn));
                data = cat(3,data,temp);
            end
        end
    end
    data_avg = double(mean(data,3));
    data_avg = uint8(255.*(data_avg-min(min(data_avg)))./(max(max(data_avg))-min(min(data_avg))));
    imwrite(data_avg,fullfile(path,'avg',strcat(to_do_list{i},'.png')));
end
%% functions
function subimages = readMultipageTiff(filename)
% Read a multipage tiff, assuming each file is the same size
    t = Tiff(filename,'r');
    subimages(:,:,1) = t.read(); % Read the first image to get the array dimensions correct.
    if t.lastDirectory()
         return; % If the file only contains one page, we do not need to continue.
    end
% Read all remaining pages (directories) in the file
    t.nextDirectory();
    while true
        subimages(:,:,end+1) = t.read();
        if t.lastDirectory()
            break;
        else
            t.nextDirectory();
        end
    end
end