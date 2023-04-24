clear all;
%% Run list
AnimalList = {'080500026C63' [23 7 223 186];
              '080500020A05' [20 25 219 199];
              '08050002242B' [21 4 220 183];
              '08050000D7DA' [34 8 233 192];
              '210805001438' [22 6 226 195];
              '210805007854' [36 7 235 191];
              '007DA64A57C6' [25 9 229 193];
              '210531013C28' [32 12 231 196];
              '21053101283C' [21 13 225 197];
              '000C9522CA71' [38 8 227 192];
              '000C9524ED50' [46 9 235 193];
              '000C95238D37' [21 13 230 194];
              '000C95238B31' [34 6 228 190];
              '000C95243984' [14 16 203 191];
              '000C9522DD66' [25 15 219 199];
              '000D2491CA72' [25 5 224 194];
              '080500020A05' [44 10 228 179]};
range = [202212040000 202212299999];
AnimalID = AnimalList{end,1};
path = fullfile("X:\Mingxuan\WF\data",AnimalID);
subfolder = dir(path);
to_do_list = cell(0);
for i = 1:size(subfolder)
    sub_name = subfolder(i).name;
    if size(sub_name,2) == 19
        time = str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10),sub_name(12:13),sub_name(15:16)));
        if time >= range(1) && time <= range(2)
            to_do_list{end+1} = sub_name;
        end
    end
end
check(to_do_list,AnimalID)
for i = 1:size(to_do_list,2)
    path_rot = fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'Rotary');
    subfolder = dir(path_rot);
    to_do_list_r = cell(0);
    for j = 1:size(subfolder)
        sub_name = subfolder(j).name;
        if size(sub_name,2) == 23
            to_do_list_r{end+1} = sub_name;
        end
    end
    path_config = fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'Config');
    subfolder = dir(path_config);
    for j = 1:size(subfolder)
        sub_name = subfolder(j).name;
        if size(sub_name,2) == 33 && sub_name(end-6) == '1'
            fileID_config = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'Config',sub_name),'r');
            threshold = str2double(extractAfter(fgets(fileID_config),":"));
            fclose(fileID_config);
        end
    end
    fileID_si = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'Trial_Info_Sequence.txt'),'r');
    fgets(fileID_si);
    sti = fscanf(fileID_si,'%d %d %d %d %f %f %f %f',[8 Inf]);
    fclose(fileID_si);
    duration = zeros(3,240,11);
    sound_time = sti(5,:);
    for j = 1:size(to_do_list_r,2)
        if sti(4,j) == -1
            fileID_rot = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'Rotary',to_do_list_r{j}),'r');
            fgets(fileID_rot);
            time_deg = fscanf(fileID_rot,'%f %f',[2 Inf]);
            fclose(fileID_rot);
            %t = time_deg(1,abs(time_deg(2,:))>threshold);
            %if size(t,2) >= 1
                %sound_time(j) = t(1);
            %else
                %[~,idx_max] = max(abs(time_deg(2,:)));
                %sound_time(j) = time_deg(1,idx_max);
            %end
        elseif sti(4,j) == 0
            sound_time(j) = 1;
        end
        sound_time(j) = 1;
        duration(2-sti(4,j),1:ceil(sound_time(j)*30),sti(1,j)) = duration(2-sti(4,j),1:ceil(sound_time(j)*30),sti(1,j)) + ones(1,ceil(sound_time(j)*30));
    end
    save(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'sound_time.mat'),'sound_time','duration');
end





%% functions
function check(to_do_list,AnimalID)
    for i = 1:size(to_do_list,2)
        fileID = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'SyncData\Trial_On_Frame.txt'),'r');
        sti_fc = fscanf(fileID,'%f').';
        fclose(fileID);
        path_rot = fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'Rotary');
        subfolder = dir(path_rot);
        to_do_list_r = cell(0);
        for j = 1:size(subfolder)
            sub_name = subfolder(j).name;
            if size(sub_name,2) == 23
                to_do_list_r{end+1} = sub_name;
            end
        end
        if size(to_do_list_r,2) ~= size(sti_fc,2)
            to_do_list{i}
            size(to_do_list_r,2)
            size(sti_fc,2)
        end
    end
end