clear all;
AnimalID = '080500026C63';
Day = 20220613;
if ~exist(fullfile('D:\WF\data',AnimalID,'combined_sti_nos'), 'dir')
   mkdir(fullfile('D:\WF\data',AnimalID,'combined_sti_nos'));
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
fileID_si = fopen(fullfile('Z:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{1}(1:19),'Trial_Info_Sequence.txt'),'r');
fgets(fileID_si);
sti = fscanf(fileID_si,'%d %d %d %d %f %f %f %f',[8 Inf]);
fclose(fileID_si);
% no ends
sti = sti(:,1:end-1);
for i = 2:size(to_do_list,2)
    i
    clearvars -except i to_do_list AnimalID sti Day
    fileID_si = fopen(fullfile('Z:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i}(1:19),'Trial_Info_Sequence.txt'),'r');
    fgets(fileID_si);
    sti_temp = fscanf(fileID_si,'%d %d %d %d %f %f %f %f',[8 Inf]);
    fclose(fileID_si);
    sti = cat(2,sti,sti_temp(:,1:end-1));
end
save(fullfile('D:\WF\data',AnimalID,'combined_sti_nos',strcat(string(Day),'.mat')),'sti','-v7.3');