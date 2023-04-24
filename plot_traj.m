%% Run list
%color = [[0.7 1 0.1];[0.8 0.8 0.8];[1 0.7 0.9]];
%color_d = [[0.4 0.7 0];[0.8 0.8 0.8];[1 0 0.7]];
color = [[0.2 0.9 1];[1 0.7 0.9]];
color_f = [[0 0 1];[1 0 0]];
color_m = [[0.6 0.6 0.8];[0.7 0.5 0.6]];
color_d = [[0.2 0.3 1];[1 0 0.7]];
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
              '080500020A05' [44 10 228 179];
              '210805001438' [20 17 234 181];
              '000D2491CA72' [25 5 224 194];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};
range = [202302220000 202302229999];
AnimalID = AnimalList{end-17,1};
path = fullfile("X:\Mingxuan\WF\data",AnimalID);
%path = fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID);
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
%check(to_do_list,AnimalID)
time_count = [];
rot_info = cell(1,3);
for i = 1:3
    rot_info{1,i} = cell(0);
end
figure;
hold on
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
    path_config = fullfile('X:\behavior_training\Manual\JL\BehaviorData\',AnimalID,to_do_list{i},'Config');
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
    %sti(1,:) = sti(1,:)*3;
    fclose(fileID_si);
    for j = 1:size(to_do_list_r,2)
            fileID_rot = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'Rotary',to_do_list_r{j}),'r');
            fgets(fileID_rot);
            time_deg = fscanf(fileID_rot,'%f %f',[2 Inf]);
            fclose(fileID_rot);
            rot_info{1,2-sti(4,j)}{end+1} = time_deg;
            %plot(time_deg(1,:),time_deg(2,:),'Color',color(2-sti(4,j),:));
            %plot(time_deg(1,end),time_deg(2,end),'.',MarkerSize=10,Color=color_d(2-sti(4,j),:));
            if sti(4,j) < 0
                if sti(7,j) == sti(8,j)
                    end_point = min(33,size(time_deg,2));
                else
                    hit_time = HT(time_deg,threshold);
                    end_point = min(int32(100*hit_time)+5,size(time_deg,2));
                end
            elseif sti(4,j) == 0
                end_point = min(450,size(time_deg,2));
            else
                end_point = min(int32(100*sti(5,j))+5,size(time_deg,2));%size(time_deg,2);%min(int32(100*sti(5,j))+11,451);
            end
            if sti(4,j) == 1% && (sti(1,j) == 1 || sti(1,j) == 11)
                time_count(end+1) = sti(5,j);
                plot(time_deg(1,1:end_point),time_deg(2,1:end_point),'Color',color(ceil(sti(1,j)/6),:));
                plot(time_deg(1,end_point),time_deg(2,end_point),'.',MarkerSize=10,Color=color_d(ceil(sti(1,j)/6),:));
            elseif sti(4,j) == -1
                plot(time_deg(1,1:end_point),time_deg(2,1:end_point),'Color',color(ceil(sti(1,j)/6),:),'LineStyle','--');
                plot(time_deg(1,end_point),time_deg(2,end_point),'o',MarkerSize=3,Color=color_d(ceil(sti(1,j)/6),:));
            else
                plot(time_deg(1,1:end_point),time_deg(2,1:end_point),'Color',color(ceil(sti(1,j)/6),:),'LineStyle',':');
                plot(time_deg(1,end_point),time_deg(2,end_point),'*',MarkerSize=3,Color=color_d(ceil(sti(1,j)/6),:));
            end
    end
end
yline(10);
yline(-10);
xline(0.3334);
ylim([-30 30])
xlabel('Time (s)');
ylabel('Degree');
hold off
%figure;
%hold on;
for i = 1:size(rot_info,2)
    for j = 1:size(rot_info{1,i},2)
        %plot(rot_info{1,i}{1,j}(1,:),rot_info{1,i}{1,j}(2,:),'Color',color(i,:));
        %plot(rot_info{1,i}{1,j}(1,end),rot_info{1,i}{1,j}(2,end),'.',MarkerSize=10,Color=color_d(i,:));
    end
end
%hold off;
figure;
histogram(time_count,15)
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
function hit_time = HT(rot,threshold)
    hit_time = 0;
    for i = 1:size(rot,2)
        if abs(rot(2,i)) >= threshold
            hit_time = rot(1,i);
            break
        end
    end
end