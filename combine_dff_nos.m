clear all;
AnimalID = '080500026C63';
Day = 20220620;
if ~exist(fullfile('D:\WF\data',AnimalID,'combined_dff_nos'), 'dir')
   mkdir(fullfile('D:\WF\data',AnimalID,'combined_dff_nos'));
end
subfolder = dir(fullfile('D:\WF\data',AnimalID,'dff_nos'));
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
data_dff = load(fullfile('D:\WF\data',AnimalID,'dff_nos',to_do_list{1}));
data_dff = data_dff.data_dff;
data_dff = imresize(data_dff,0.2);
for i = 2:size(to_do_list,2)
    i
    clearvars -except i to_do_list AnimalID data_dff Day
    data_temp = load(fullfile('D:\WF\data',AnimalID,'dff_nos',to_do_list{i}));
    data_temp = data_temp.data_dff;
    data_temp = imresize(data_temp,0.2);
    data_dff = cat(3,data_dff,data_temp);
end
save(fullfile('D:\WF\data',AnimalID,'combined_dff_nos',strcat(string(Day),'.mat')),'data_dff','-v7.3');