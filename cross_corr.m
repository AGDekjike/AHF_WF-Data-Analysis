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
              '21053101283C' [21 13 225 197]};
range = [202207010000 202207039999];
AnimalID = AnimalList{end-1,1};
path = fullfile("X:\Mingxuan\WF\data\archive",AnimalID,'ROInew');
if ~exist(fullfile(path,'combined_stage'), 'dir')
   mkdir(fullfile(path,'combined_stage'));
end
%% corr
%corr(loc_1,loc_2);
%h = zeros(1,size(data_dff,3));
%p = zeros(1,size(data_dff,3));
%figure;
%hold on;
%sum(h)/size(loc_1,2)
%hold off;
%ylim([-1 1])
windowSize = 3; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

color = {[1 0 0],[0 1 0],[0 0 1],[1 0.6 1],[1 0.6 1],[1 0.6 1],[1 0.6 1],[1 0.6 1]};
c = [1 2 3];
categ = [1 31];
%C28
stage = [[202207010000 202207039999];[202208090000 202208099999]];
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
S = cell(0);
for s = 1:size(stage,1)
    [data_dff,data_sti,data_duration] = load_data(AnimalID,path,stage(s,:));
    duration = zeros(33,size(data_duration,2));
    for i = 1:11
        for j = 1:3
            duration((i-1)*3+j,:) = data_duration(j,:,i);
        end
    end
    x = 0:size(data_dff,2)-1;
    CCC = cell(0);
    for ct = 1:size(categ,2)
        cg = floor((data_sti(1,:)-1))*3+2-data_sti(4,:);
        cg(cg~=categ(ct))=0;
        cg(cg~=0)=1;
        data_dff_ct = data_dff.*reshape(cg,[1 1 size(cg,2)]);
        data_dff_ct(:,:,all(data_dff_ct == 0,[1 2])) = [];
        loc = cell(0);
        for i = c
            loc{end+1} = permute(data_dff_ct(i,:,:),[3 2 1]);
        end
        CCC{end+1} = loc;
        for curve = 1:size(loc,2)
            y = loc{curve};
            N = size(y,1);
            if N > 0
                if N >= 5
                    yMean = mean(y);
                    ySEM = std(y)/sqrt(N);
                    CI95 = tinv([0.025 0.975], N-1);
                    yCI95 = bsxfun(@times, ySEM, CI95(:));
                end
            end
        end
    end
    S{end+1} = CCC;
end
X = mean(S{1,2}{1,1}{1,1}(:,31:60));
Y = mean(S{1,2}{1,1}{1,3}(:,31:60));
[h,p]=gctest(X.',Y.')

figure;
hold on;
plot(X);
plot(Y);
hold off;

function corr(loc_1,loc_2)
    c = zeros(61,61);
    for i = 1:61
        for j = 1:61
            mdl = fitlm(loc_1(i,:).',loc_2(j,:).');
            c(i,j) = mdl.Rsquared.Adjusted;
        end
    end
    figure;
    heatmap(c,'Colormap',turbo,'ColorLimits',[0 1]);
    dc = zeros(61,61);
    for i = 1:61
        for j = 1:61
            dc(i,j) = c(i,j) - c(j,i);
        end
    end
    figure;
    heatmap(dc,'Colormap',turbo,'ColorLimits',[-1 1]);
end

function [data_dff,data_sti,data_duration] = load_data(AnimalID,path,range)
    subfolder = dir(path);
    to_do_list = cell(0);
    for i = 1:size(subfolder)
        sub_name = subfolder(i).name;
        if size(sub_name,2) == 23
            time = str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10),sub_name(12:13),sub_name(15:16)));
            if time >= range(1) && time <= range(2)
                to_do_list{end+1} = sub_name;
            end
        end
    end
    data_time = load(fullfile("X:\behavior_training\Manual\JL\BehaviorData\archive",AnimalID,to_do_list{1}(1:end-4),'sound_time.mat'));
    data_duration = data_time.duration;
    data = load(fullfile(path,to_do_list{1}));
    data_dff = data.dff_ROI;
    data_sti = data.data_sti;
    clear data;
    for i = 1:size(to_do_list,2)
        if i > 1
            data_time = load(fullfile("X:\behavior_training\Manual\JL\BehaviorData\archive",AnimalID,to_do_list{i}(1:end-4),'sound_time.mat'));
            data_duration = data_duration + data_time.duration;
            data = load(fullfile(path,to_do_list{i}));
            data_dff = cat(3,data_dff,data.dff_ROI);
            data_sti = cat(2,data_sti,data.data_sti);
            clear data;
        end
    end
end