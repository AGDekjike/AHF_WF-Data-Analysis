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
%%
Day = [];
for i = 9
    Day(end+1) = 20220800+i;
end
for d = 1:size(Day,2)
    disp(strcat('processing day:',string(Day(d))));
    for i = size(AnimalList,1)-1%:-1:1
        clearvars -except i AnimalList Day d
        disp(strcat('PROCESSING:',AnimalList{i,1}));
        process(AnimalList{i,1},AnimalList{i,2},Day(d));
    end
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

function [data_dff,sti] = df_f(data,sti,pre,post)
    if sti(end) + post > size(data,3)
        sti = sti(1:end-1);
    end
    data_df = zeros(size(data,1),size(data,2),size(sti,2)*(pre+post+1));
    data_dff = zeros(size(data,1),size(data,2),size(sti,2)*(pre+post+1));
    data_z = zeros(size(data,1),size(data,2),size(sti,2)*(pre+post+1));
    for i = 1:size(sti,2)
        avg = mean(data(:,:,sti(i)-pre:sti(i)-1),3);
        data_df(:,:,(i-1)*(pre+post+1)+1:i*(pre+post+1)) = (data(:,:,sti(i)-pre:sti(i)+post) - avg);
        data_dff(:,:,(i-1)*(pre+post+1)+1:i*(pre+post+1)) = data_df(:,:,(i-1)*(pre+post+1)+1:i*(pre+post+1))./avg;
        STD = std(data_dff(:,:,(i-1)*(pre+post+1)+1:i*(pre+post+1)),0,3);
        data_z(:,:,(i-1)*(pre+post+1)+1:i*(pre+post+1)) = data_dff(:,:,(i-1)*(pre+post+1)+1:i*(pre+post+1))./STD;
    end
end

function data_m = match_data(data,AnimalID,Time,BaseROI)
    % match shift file
    Shifts = load(fullfile('X:\Mingxuan\WF\data\archive',AnimalID,'avg','Shifts.mat'));
    Shifts = Shifts.Shifts;
    shift = [0 0];
    for i = 1:size(Shifts)
        if Time == Shifts{i}
            shift = [Shifts{i,2} Shifts{i,3}];
        end
    end
    CorrectROI = BaseROI;
    for i = 1:size(BaseROI,2)
        CorrectROI(i) = BaseROI(i) - shift(mod(i-1,2)+1);
    end
    data_t = data(max(1,CorrectROI(1)):min(CorrectROI(3),size(data,1)),max(1,CorrectROI(2)):min(CorrectROI(4),size(data,2)),:);
    if size(data_t,[1 2]) == [int32(BaseROI(3)-BaseROI(1)+1) int32(BaseROI(4)-BaseROI(2)+1)]
    else
        if CorrectROI(1) < 1
            data_t = cat(1,zeros(1-CorrectROI(1),size(data_t,2),size(data,3)),data_t);
        elseif CorrectROI(3) > size(data,1)
            data_t = cat(1,data_t,zeros(-size(data,1)+CorrectROI(3),size(data_t,2),size(data,3)));
        end
        if CorrectROI(2) < 1
            data_t = cat(2,zeros(size(data_t,1),1-CorrectROI(2),size(data,3)),data_t);
        elseif CorrectROI(4) > size(data,2)
            data_t = cat(2,data_t,zeros(size(data_t,1),-size(data,2)+CorrectROI(4),size(data,3)));
        end
    end
    data_m = data_t;
end

function process(AnimalID,BaseROI,Day)
    pre = 30;
    post = 120;
    path = fullfile('X:\Mingxuan\WF\data\archive',AnimalID);
    subfolder = dir(path);
    if ~exist(fullfile(path,'ROInew'), 'dir')
       mkdir(fullfile(path,'ROInew'));
    end
    to_do_list = cell(0);
    for i = 1:size(subfolder)
        sub_name = subfolder(i).name;
        if size(sub_name,2) == 19
            if str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10))) == Day
                to_do_list{end+1} = sub_name;
            end
        end
    end
    for i = 1:size(to_do_list,2)
        clearvars -except i to_do_list AnimalID Day BaseROI pre post path AnimalList ROI
        fileID = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData\archive',AnimalID,to_do_list{i},'SyncData\Trial_On_Frame.txt'),'r');
        sti_fc = fscanf(fileID,'%f').';
        fclose(fileID);
        fileID_si = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData\archive',AnimalID,to_do_list{i},'Trial_Info_Sequence.txt'),'r');
        fgets(fileID_si);
        sti = fscanf(fileID_si,'%d %d %d %d %f %f %f %f',[8 Inf]);
        fclose(fileID_si);
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
        %ROI = [71 80 12 21;71 80 55 64;81 90 101 110;10 10 10 10];
        %ROI = [1 1 1 1;1 1 2 2;2 2 1 1];
        [data_dff,sti_fc] = df_f(data,sti_fc,pre,post);
        clear data;
        dff_match = match_data(data_dff,AnimalID,to_do_list{i},BaseROI);
        clear data_dff;
        dff_new = reshape(dff_match,[size(dff_match,1),size(dff_match,2),pre+post+1,int32(size(dff_match,3)/(pre+post+1))]);
        clear dff_match;
        
        dff_ROI = zeros(size(ROI,1),size(dff_new,3),size(dff_new,4));
        for r = 1:size(ROI,1)
            dff_ROI(r,:,:) = permute(mean(dff_new(ROI(r,1):ROI(r,2),ROI(r,3):ROI(r,4)),[1 2]),[3 4 1 2]);
        end
        data_sti = sti(:,1:size(sti_fc,2));
        save(fullfile(path,'ROInew',strcat(string(to_do_list{i}),'.mat')),'dff_ROI','data_sti','-v7.3');
    end
end