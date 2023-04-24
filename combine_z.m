clear all;
AnimalID = '08050002242B';
Day = 20220608;
if ~exist(fullfile('D:\WF\data',AnimalID,'combined_zscore'), 'dir')
   mkdir(fullfile('D:\WF\data',AnimalID,'combined_zscore'));
end
subfolder = dir(fullfile('D:\WF\data',AnimalID,'dff'));
to_do_list = cell(0);
for i = 1:size(subfolder)
    sub_name = subfolder(i).name;
    if size(sub_name,2) == 23
        if str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10))) == Day
            to_do_list{end+1} = sub_name;
        end
    end
end
size(to_do_list,2)
data_dff = load(fullfile('D:\WF\data',AnimalID,'dff',to_do_list{1}));
data_dff = data_dff.data_dff;
data_z = combine_zscore(data_dff,0.2);
for i = 2:size(to_do_list,2)
    i
    clearvars -except i to_do_list AnimalID data_z Day
    data_dff = load(fullfile('D:\WF\data',AnimalID,'dff',to_do_list{i}));
    data_dff = data_dff.data_dff;
    data_temp = combine_zscore(data_dff,0.2);
    data_z = cat(3,data_z,data_temp);
end
save(fullfile('D:\WF\data',AnimalID,'combined_zscore',strcat(string(Day),'.mat')),'data_z','-v7.3');
%% functions
function data_z = combine_zscore(data_dff,rescale)
    data_dff = imresize(data_dff,rescale);
    STD = zeros(size(data_dff,1),size(data_dff,2),int16(size(data_dff,3)/61));
    data_z = zeros(size(data_dff,1),size(data_dff,2),size(data_dff,3));
    for i = 1:int16(size(data_dff,3)/61)
        STD(:,:,i) = std(data_dff(:,:,(i-1)*61+1:i*61),0,3);
        data_z(:,:,(i-1)*61+1:i*61) = data_dff(:,:,(i-1)*61+1:i*61)./STD(:,:,i);
    end
end