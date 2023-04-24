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
              '080500020A05' [44 10 228 179];
              '210805001438' [20 17 234 181];
              '000D2491CA72' [25 5 224 194];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};
%C28
%stage = [[202207010000 202207039999];[202207040000 202207089999];[202207090000 202207199999];[202207200000 202207239999];[202207240000 202207299999];[202207300000 202208041304];[202208041305 202208129999]];
%438
%stage = [[202207010000 202207049999];[202207050000 202207089999];[202207100000 202207189999];[202207200000 202207281650];[202207281650 202208021615];[202208021615 202208069999]];
%854
%stage = [[202207010000 202207059999];[202207070000 202207159999];[202207160000 202207209999];[202207210000 202207269999];[202207270000 202208039999];[202208040000 202208069999]];
%7DA
%stage = [[202207010000 202207049999];[202207050000 202207119999];[202207120000 202207209999];[202207210000 202207229999];[202207230000 202207261630];[202207261630 202207289999]];
%C6
%stage = [[202207010000 202207039999];[202207040000 202207089999];[202207100000 202207159999];[202207180000 202207239999];[202207240000 202207289999];[202207290000 202207311700]];
%3C
%stage = [[202207010000 202207039999];[202207040000 202207139999];[202207180000 202207229999];[202207230000 202207301320];[202207301320 202208049999];[202208050000 202208139999]];
num_t_all = [];
num_s_all = [];
x_all = zeros(6,4,25);
p_all = [];
figure;
hold on
for ani = 0:5
    if ani<=1
        stage = [202302000000 202303019999];
    else
        stage = [202212000000 202212299999];
    end
    a = 0;
    AnimalID = AnimalList{end-ani,1};
    path = fullfile("X:\Mingxuan\WF\data",AnimalID);
    subfolder = dir(path);
    subfolder_archive = dir(fullfile(path,'archive'));
    %figure;
    for s = 1:size(stage,1)
        subplot(size(stage,1),1,s);
        to_do_list = cell(0);
        for i = 1:size(subfolder)
            sub_name = subfolder(i).name;
            if size(sub_name,2) == 19
                time = str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10),sub_name(12:13),sub_name(15:16)));
                if time >= stage(s,1) && time <= stage(s,2)
                    to_do_list{end+1} = sub_name;
                end
            end
        end
        for i = 1:size(subfolder_archive)
            sub_name = subfolder_archive(i).name;
            if size(sub_name,2) == 19
                time = str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10),sub_name(12:13),sub_name(15:16)));
                if time >= stage(s,1) && time <= stage(s,2)
                    for j = 1:size(to_do_list,2)
                        sn = to_do_list{1,j};
                        time_temp = str2num(strcat(sn(1:4),sn(6:7),sn(9:10),sn(12:13),sn(15:16)));
                        if time < time_temp
                            to_do_list = to_do_list([1:j-1,j,j:end]);
                            to_do_list{j} = sub_name;
                            break
                        end
                    end
                end
            end
        end
        trial_number = zeros(1,size(to_do_list,2));
        fileID_si = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{1},'Trial_Info_Sequence.txt'),'r');
        fgets(fileID_si);
        sti = fscanf(fileID_si,'%d %d %d %d %f %f %f %f',[8 Inf]);
        fclose(fileID_si);
        indices = find(mod(sti(1,:),10) ~= 1);
        if size(indices,2) > 0
            %sti(1,indices) = [];
        end
        trial_number(1) = size(sti,2);
        for i = 1:size(to_do_list,2)
            if i ~= 1
                fileID_si = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'Trial_Info_Sequence.txt'),'r');
                fgets(fileID_si);
                sti_temp = fscanf(fileID_si,'%d %d %d %d %f %f %f %f',[8 Inf]);
                fclose(fileID_si);
                indices = find(mod(sti_temp(1,:),10) ~= 1);
                if size(indices,2) > 0
                    %sti_temp(:,indices) = [];
                end
                sti = cat(2,sti,sti_temp);
                trial_number(i) = size(sti_temp,2);
            end
        end

        all = zeros(4,11);
        for j = 1:size(sti,2)
            if sti(4,j) >= 0
                all(2-sti(4,j),sti(1,j)) = all(2-sti(4,j),sti(1,j)) + 1;
            elseif sti(7,j) == sti(8,j)
                all(4,sti(1,j)) = all(4,sti(1,j)) + 1;
            else
                all(3,sti(1,j)) = all(3,sti(1,j)) + 1;
            end
        end
        
        %heatmap(all,'Colormap',summer);
        %ax = gca;
        %ax.YData = ["correct" "unattended" "wrong"];
        %ax.XData = ["10.0k" "14.1k" "16.8k" "18.3k" "19.2k" "20.0k" "20.9k" "21.8" "23.8k" "28.3k" "40.0k"];
        %ax.XData = ["10.0k" "40.0k"];
        %xlabel('frequency');
        %ylabel('choice');
        %title(strcat('stage',string(s)));
        a = (a + size(sti,2));
        a/300
        x = [all(1,1) all(3,1) all(1,11) all(3,11)];
        x_all(animal,:,end+1) = x;
    end

    x = [all(1,1) all(3,1);all(3,11) all(1,11)];
    [h,p] = fishertest(x,'Tail','both','Alpha',0.05);
    %x_all(:,:,end+1) = x;
    p_all(end+1) = p;
    %acc = split_by_interval(sti,to_do_list,trial_number,1);
    %acc1 = MaxHitRate_hr(sti,to_do_list,trial_number,25000);
    [num_t,num_s] = TrialNumber(sti,to_do_list,trial_number);
    num_t_all(end+1,:) = num_t;
    num_s_all(end+1,:) = num_s;
    %bin25 for 4 mice data
    %figure;
    %hold on
    %plot(num_s);
    %plot(num_s);
    %hold off
    %xlabel('training day')
    %ylabel('max hit rate over 50 trials')
    %ylim([0 1]);
end
hold off;



function acc = split_by_interval(sti,to_do_list,trial_number,interval)
    acc = [];
    group_count = 0;
    count_start = 1;
    while count_start <= size(to_do_list,2)
        group_count = group_count + trial_number(count_start);
        if group_count >= interval
            group_sti = sti(:,sum(trial_number(1:count_start))-group_count+1:sum(trial_number(1:count_start)));
            all = zeros(3,11);
            for i = 1:size(group_sti,2)
                all(2-group_sti(4,i),group_sti(1,i)) = all(2-group_sti(4,i),group_sti(1,i)) + 1;
            end
            acc(end+1) = sum(all(1,:))/(sum(all,"all"));
            group_count = 0;
        end
        count_start = count_start + 1;
    end
    if group_count > 0
        group_sti = sti(:,sum(trial_number(1:count_start-1))-group_count+1:sum(trial_number(1:count_start-1)));
        all = zeros(3,11);
        for i = 1:size(group_sti,2)
            all(2-group_sti(4,i),group_sti(1,i)) = all(2-group_sti(4,i),group_sti(1,i)) + 1;
        end
        acc(end+1) = sum(all(1,:))/(sum(all,"all"));
    end
end
function acc = split_fix_interval(sti,interval)
    acc = [];
    for i = 1:ceil(size(sti,2)/interval)
        group_sti = sti(:,(i-1)*interval+1:min(i*interval,size(sti,2)));
        all = zeros(3,11);
        for j = 1:size(group_sti,2)
            all(2-group_sti(4,j),group_sti(1,j)) = all(2-group_sti(4,j),group_sti(1,j)) + 1;
        end
        acc(end+1) = sum(all(1,:))/(sum(all,"all"));
        %acc(end+1) = norminv(sum(all(1,[1 11]))/sum(all([1 3],[1 11]),"all")) - norminv(sum(all(3,[1 11]))/sum(all([1 3],[1 11]),"all"));
    end
end
function acc = MaxHitRate(sti,to_do_list,trial_number,bin_size)
    acc = [];
    group_count = 0;
    count_start = 1;
    first_day = to_do_list{1,1};
    training_day = str2num(strcat(first_day(1:4),first_day(6:7),first_day(9:10)));
    while count_start <= size(to_do_list,2)
        group_count = group_count + trial_number(count_start);
        current_day = to_do_list{1,count_start};
        current_training_day = str2num(strcat(current_day(1:4),current_day(6:7),current_day(9:10)));
        if current_training_day ~= training_day
            if (size(acc,2) + 1) == 30
                disp(training_day);
            end
            group_sti = sti(4,sum(trial_number(1:count_start))-group_count+1:sum(trial_number(1:count_start-1)));
            max_hit_count = 0;
            if size(group_sti,2) < bin_size
                acc(end+1) = sum(group_sti(:) == 1)/size(group_sti,2);
            else
                for i = 1:(size(group_sti,2) - bin_size + 1)
                    if sum(group_sti(i:i + bin_size - 1) == 1) > max_hit_count
                        max_hit_count = sum(group_sti(i:i + bin_size - 1) == 1);
                    end
                end
                acc(end+1) = max_hit_count/bin_size;
            end
            group_count = trial_number(count_start);
            training_day = current_training_day;
        end
        count_start = count_start + 1;
    end
    group_sti = sti(4,sum(trial_number(1:count_start-1))-group_count+1:sum(trial_number(1:count_start-1)));
    max_hit_count = 0;
    for i = 1:(size(group_sti,2) - bin_size + 1)
        if sum(group_sti(i:i + bin_size - 1) == 1) > max_hit_count
            max_hit_count = sum(group_sti(i:i + bin_size - 1) == 1);
        end
    end
    acc(end+1) = max_hit_count/bin_size;
end

function acc = MaxHitRate_d(sti,to_do_list,trial_number,bin_size)
    acc = [];
    group_count = 0;
    count_start = 1;
    first_day = to_do_list{1,1};
    training_day = str2num(strcat(first_day(1:4),first_day(6:7),first_day(9:10)));
    while count_start <= size(to_do_list,2)
        group_count = group_count + trial_number(count_start);
        current_day = to_do_list{1,count_start};
        current_training_day = str2num(strcat(current_day(1:4),current_day(6:7),current_day(9:10)));
        if current_training_day ~= training_day
            group_sti = sti(:,sum(trial_number(1:count_start))-group_count+1:sum(trial_number(1:count_start-1)));
            max_hit_count = 0;
            if size(group_sti,2) < bin_size
                all = zeros(4,11);
                for j = 1:size(group_sti,2)
                    if group_sti(4,j) >= 0
                        all(2-group_sti(4,j),group_sti(1,j)) = all(2-group_sti(4,j),group_sti(1,j)) + 1;
                    elseif group_sti(7,j) == group_sti(8,j)
                        all(4,group_sti(1,j)) = all(4,group_sti(1,j)) + 1;
                    else
                        all(3,group_sti(1,j)) = all(3,group_sti(1,j)) + 1;
                    end
                end
                %acc(end+1) = norminv(sum(all(1,[1 11]))/sum(all([1 3],[1 11]),"all")) - norminv(sum(all(3,[1 11]))/sum(all([1 3],[1 11]),"all"));
                if all(1,1) == 0
                    all(1,1) = all(1,1) + 1;
                end
                if all(3,1) == 0
                    all(3,1) = all(3,1) + 1;
                end
                if all(1,11) == 0
                    all(1,11) = all(1,11) + 1;
                end
                if all(3,11) == 0
                    all(3,11) = all(3,11) + 1;
                end
                acc(end+1) = norminv(all(1,1)/(all(1,1)+all(3,1))) - norminv(all(3,11)/(all(1,11)+all(3,11)));
                %[h,p,stats] = fishertest([all(1,1),all(3,1);all(3,11),all(1,11)],'Tail','both','Alpha',0.001);
                %acc(end+1) = p;
                %acc(end+1) = all(1,1)/(all(1,1)+all(3,1));
            else
                for i = 1:(size(group_sti,2) - bin_size + 1)
                    all = zeros(4,11);
                    for j = i:i + bin_size - 1
                        if group_sti(4,j) >= 0
                            all(2-group_sti(4,j),group_sti(1,j)) = all(2-group_sti(4,j),group_sti(1,j)) + 1;
                        elseif group_sti(7,j) == group_sti(8,j)
                            all(4,group_sti(1,j)) = all(4,group_sti(1,j)) + 1;
                        else
                            all(3,group_sti(1,j)) = all(3,group_sti(1,j)) + 1;
                        end
                    end
                    if all(1,1) == 0
                        all(1,1) = all(1,1) + 1;
                    end
                    if all(3,1) == 0
                        all(3,1) = all(3,1) + 1;
                    end
                    if all(1,11) == 0
                        all(1,11) = all(1,11) + 1;
                    end
                    if all(3,11) == 0
                        all(3,11) = all(3,11) + 1;
                    end
                    if norminv(sum(all(1,[1 11]))/sum(all([1 3],[1 11]),"all")) - norminv(sum(all(3,[1 11]))/sum(all([1 3],[1 11]),"all")) > max_hit_count
                        max_hit_count = norminv(sum(all(1,[1 11]))/sum(all([1 3],[1 11]),"all")) - norminv(sum(all(3,[1 11]))/sum(all([1 3],[1 11]),"all"));
                    end
                end
                acc(end+1) = max_hit_count;
            end
            group_count = trial_number(count_start);
            training_day = current_training_day;
        end
        count_start = count_start + 1;
    end
    group_sti = sti(:,sum(trial_number(1:count_start-1))-group_count+1:sum(trial_number(1:count_start-1)));
    if size(group_sti,2) < bin_size
        all = zeros(4,11);
        for j = 1:size(group_sti,2)
            if group_sti(4,j) >= 0
                all(2-group_sti(4,j),group_sti(1,j)) = all(2-group_sti(4,j),group_sti(1,j)) + 1;
            elseif group_sti(7,j) == group_sti(8,j)
                all(4,group_sti(1,j)) = all(4,group_sti(1,j)) + 1;
            else
                all(3,group_sti(1,j)) = all(3,group_sti(1,j)) + 1;
            end
        end
        if all(1,1) == 0
            all(1,1) = all(1,1) + 1;
        end
        if all(3,1) == 0
            all(3,1) = all(3,1) + 1;
        end
        if all(1,11) == 0
            all(1,11) = all(1,11) + 1;
        end
        if all(3,11) == 0
            all(3,11) = all(3,11) + 1;
        end
        acc(end+1) = norminv(all(1,1)/(all(1,1)+all(3,1))) - norminv(all(3,11)/(all(1,11)+all(3,11)));
        %acc(end+1) = norminv(sum(all(1,[1 11]))/sum(all([1 3],[1 11]),"all")) - norminv(sum(all(3,[1 11]))/sum(all([1 3],[1 11]),"all"));
        %acc(end+1) = norminv(all(1,1)/(all(1,1)+all(3,1))) - norminv(all(3,11)/(all(1,11)+all(3,11)));
        %[h,p,stats] = fishertest([all(1,1),all(3,1);all(3,11),all(1,11)],'Tail','both','Alpha',0.001);
        %acc(end+1) = p;
    else
        max_hit_count = 0;
        for i = 1:(size(group_sti,2) - bin_size + 1)
            all = zeros(4,11);
            for j = 1:size(group_sti,2)
                if group_sti(4,j) >= 0
                    all(2-group_sti(4,j),group_sti(1,j)) = all(2-group_sti(4,j),group_sti(1,j)) + 1;
                elseif group_sti(7,j) == group_sti(8,j)
                    all(4,group_sti(1,j)) = all(4,group_sti(1,j)) + 1;
                else
                    all(3,group_sti(1,j)) = all(3,group_sti(1,j)) + 1;
                end
            end
            if norminv(sum(all(1,[1 11]))/sum(all([1 3],[1 11]),"all")) - norminv(sum(all(3,[1 11]))/sum(all([1 3],[1 11]),"all")) > max_hit_count
                max_hit_count = norminv(sum(all(1,[1 11]))/sum(all([1 3],[1 11]),"all")) - norminv(sum(all(3,[1 11]))/sum(all([1 3],[1 11]),"all"));
            end
        end
        acc(end+1) = max_hit_count;
    end
end


function acc = MaxHitRate_hr(sti,to_do_list,trial_number,bin_size)
    acc = [];
    group_count = 0;
    count_start = 1;
    first_day = to_do_list{1,1};
    training_day = str2num(strcat(first_day(1:4),first_day(6:7),first_day(9:10)));
    while count_start <= size(to_do_list,2)
        group_count = group_count + trial_number(count_start);
        current_day = to_do_list{1,count_start};
        current_training_day = str2num(strcat(current_day(1:4),current_day(6:7),current_day(9:10)));
        if current_training_day ~= training_day
            group_sti = sti(:,sum(trial_number(1:count_start))-group_count+1:sum(trial_number(1:count_start-1)));
            max_hit_count = 0;
            if size(group_sti,2) < bin_size
                all = zeros(4,11);
                for j = 1:size(group_sti,2)
                    if group_sti(4,j) >= 0
                        all(2-group_sti(4,j),group_sti(1,j)) = all(2-group_sti(4,j),group_sti(1,j)) + 1;
                    elseif group_sti(7,j) == group_sti(8,j)
                        all(4,group_sti(1,j)) = all(4,group_sti(1,j)) + 1;
                    else
                        all(3,group_sti(1,j)) = all(3,group_sti(1,j)) + 1;
                    end
                end
                acc(end+1) = sum(all(1,1))/(sum(all(1,1))+sum(all(3,1)));
                %acc(end+1) = all(3,11)/(all(1,11)+all(3,11));
            else
                for i = 1:(size(group_sti,2) - bin_size + 1)
                    if sum(group_sti(4,i:i + bin_size - 1) == 1) > max_hit_count
                        max_hit_count = sum(group_sti(i:i + bin_size - 1) == 1);
                        all = zeros(4,11);
                        for j = i:i + bin_size - 1
                            if group_sti(4,j) >= 0
                                all(2-group_sti(4,j),group_sti(1,j)) = all(2-group_sti(4,j),group_sti(1,j)) + 1;
                            elseif group_sti(7,j) == group_sti(8,j)
                                all(4,group_sti(1,j)) = all(4,group_sti(1,j)) + 1;
                            else
                                all(3,group_sti(1,j)) = all(3,group_sti(1,j)) + 1;
                            end
                        end
                    end
                end
                acc(end+1) = sum(all(1,1))/(sum(all(1,1))+sum(all(3,1)));
                %acc(end+1) = all(3,11)/(all(1,11)+all(3,11));
            end
            group_count = trial_number(count_start);
            training_day = current_training_day;
        end
        count_start = count_start + 1;
    end
    group_sti = sti(:,sum(trial_number(1:count_start-1))-group_count+1:sum(trial_number(1:count_start-1)));
    if size(group_sti,2) < bin_size
        all = zeros(4,11);
        for j = 1:size(group_sti,2)
            if group_sti(4,j) >= 0
                all(2-group_sti(4,j),group_sti(1,j)) = all(2-group_sti(4,j),group_sti(1,j)) + 1;
            elseif group_sti(7,j) == group_sti(8,j)
                all(4,group_sti(1,j)) = all(4,group_sti(1,j)) + 1;
            else
                all(3,group_sti(1,j)) = all(3,group_sti(1,j)) + 1;
            end
        end
        acc(end+1) = sum(all(1,1))/(sum(all(1,1))+sum(all(3,1)));
        %acc(end+1) = all(3,11)/(all(1,11)+all(3,11));
    else
        max_hit_count = 0;
        for i = 1:(size(group_sti,2) - bin_size + 1)
            if sum(group_sti(4,i:i + bin_size - 1) == 1) > max_hit_count
                max_hit_count = sum(group_sti(i:i + bin_size - 1) == 1);
                all = zeros(4,11);
                for j = 1:size(group_sti,2)
                    if group_sti(4,j) >= 0
                        all(2-group_sti(4,j),group_sti(1,j)) = all(2-group_sti(4,j),group_sti(1,j)) + 1;
                    elseif group_sti(7,j) == group_sti(8,j)
                        all(4,group_sti(1,j)) = all(4,group_sti(1,j)) + 1;
                    else
                        all(3,group_sti(1,j)) = all(3,group_sti(1,j)) + 1;
                    end
                end
            end
        end
        acc(end+1) = sum(all(1,1))/(sum(all(1,1))+sum(all(3,1)));
        %acc(end+1) = all(3,11)/(all(1,11)+all(3,11));
    end
end

function [num_t,num_s] = TrialNumber(sti,to_do_list,trial_number)
    num_t = [];
    num_s = [];
    group_count = 0;
    z = 0;
    count_start = 1;
    first_day = to_do_list{1,1};
    training_day = str2num(strcat(first_day(1:4),first_day(6:7),first_day(9:10)));
    while count_start <= size(to_do_list,2)
        z = z + 1;
        group_count = group_count + trial_number(count_start);
        current_day = to_do_list{1,count_start};
        current_training_day = str2num(strcat(current_day(1:4),current_day(6:7),current_day(9:10)));
        if current_training_day ~= training_day
            group_sti = sti(4,sum(trial_number(1:count_start))-group_count+1:sum(trial_number(1:count_start-1)));
            num_t(end+1) = size(group_sti,2);
            num_s(end+1) = z;
            z = 0;
            group_count = trial_number(count_start);
            training_day = current_training_day;
        end
        count_start = count_start + 1;
    end
    group_sti = sti(4,sum(trial_number(1:count_start-1))-group_count+1:sum(trial_number(1:count_start-1)));
    num_t(end+1) = size(group_sti,2);
    num_s(end+1) = z;
end