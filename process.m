%% database 
% +1 for value in imageJ!!! -1 or +4
% 080500026C63 [23 7 223 186]
% 080500020A05 [20 25 219 199]
% 08050002242B [21 4 220 183]
% 08050000D7DA [34 8 233 192]
% 210805001438 [22 6 226 195]
% 210805007854 [17 8 221 192]
% 007DA64A57C6 [25 9 229 193]
% 210531013C28 [32 12 231 196]
% 21053101283C [21 13 225   197]
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
for i = 19:28
    Day(end+1) = 20220700+i;
end
Day = [20220805];
for d = 1:size(Day,2)
    disp(strcat('processing day:',string(Day(d))));
    for i = size(AnimalList,1):-1:1
        clearvars -except i AnimalList Day d
        disp(strcat('PROCESSING:',AnimalList{i,1}));
        PROCESS(AnimalList{i,1},AnimalList{i,2},Day(d));
    end
end
%%
function PROCESS(AnimalID,BaseROI,Day)
    % Match WF and behavior file name first!
    %uiwait(msgbox('CHECK! Does WF date match behavior date?'));
    %AnimalID = '210531013C28'; % change BaseROI accordingly!
    %Day = 20220703;
    %BaseROI = [32 12 231 196]; % x1 y1 x2 y2
    %uiwait(msgbox('CHECK! Does ROI match ID?'));
    %% initialization
    path = fullfile('X:\Mingxuan\WF\data',AnimalID);
    addpath('C:\WF\analysis\NoRMCorre-master\');
    addpath('C:\WF\syn\'); % for motion correction
    if ~exist(fullfile(path,'avg'), 'dir')
       mkdir(fullfile(path,'avg'));
    end
    Shifts = cell(0,3);
    if ~exist(fullfile(path,'avg','Shifts.mat'), 'file')
       save(fullfile(path,'avg','Shifts.mat'),'Shifts');
    end
    if ~exist(fullfile('X:\Mingxuan\WF\data',AnimalID,'dff'), 'dir')
       mkdir(fullfile('X:\Mingxuan\WF\data',AnimalID,'dff'));
    end
    if ~exist(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_sti'), 'dir')
       mkdir(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_sti'));
    end
    if ~exist(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_dff'), 'dir')
       mkdir(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_dff'));
    end
    if ~exist(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_zscore'), 'dir')
       mkdir(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_zscore'));
    end
    %% searching
    subfolder = dir(path);
    to_do_list = cell(0);
    for i = 1:size(subfolder)
        sub_name = subfolder(i).name;
        if size(sub_name,2) == 19
            if str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10))) == Day
                to_do_list{end+1} = sub_name;
            end
        end
    end
    disp(strcat(string(size(to_do_list,2)),' in total'));
    %% individual process
    if size(to_do_list,2) == 0
        return;
    end
    for i = 1:size(to_do_list,2)
        disp(strcat('(',string(i),'/',string(size(to_do_list,2)),')',' processing:',string(to_do_list{i}),' for motion correction ...'));
        if ~exist(fullfile(path,to_do_list{i},'MC00001.tiff'),'file')
            sub_file = dir(fullfile(path,to_do_list{i}));
            for k = 1:size(sub_file)
                fn = sub_file(k).name;
                fb = sub_file(k).bytes;
                if size(fn,2) == 15 && fb > 10
                    clearvars -except i k fn fb sub_file path to_do_list AnimalID Day BaseROI
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
            disp('done motion correction!')
        else
            disp('motion correction already done!');
        end
        clearvars -except i to_do_list AnimalID BaseROI path Day
        disp(strcat('(',string(i),'/',string(size(to_do_list,2)),')',' processing:',string(to_do_list{i}),' for averaging figures ...'));
        if ~exist(fullfile(path,'avg',strcat(string(to_do_list{i}),'.png')),'file')
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
            disp('done averaging figures!');
        else
            disp('averaged figure already existed!');
        end
        clearvars -except i to_do_list AnimalID BaseROI path Day
        disp(strcat('(',string(i),'/',string(size(to_do_list,2)),')',' processing:',string(to_do_list{i}),' for calculating shifts ...'));
        Shifts = load(fullfile(path,'avg','Shifts.mat'));
        Shifts = Shifts.Shifts;
        name = to_do_list{i};
        Index = find(ismember(Shifts(:,1), string(name)));
        if size(Index,1) == 0
            search_size = [-30 30 -30 30];
            [min_tx,min_ty] = loc_shift(fullfile(path,'avg','m.png'),fullfile(path,'avg',strcat(to_do_list{i},'.png')),search_size);
            Shifts{end+1,1} = name(1:19);
            Shifts{end,2} = min_tx;
            Shifts{end,3} = min_ty;
            disp('done calculating shifts!');
        else
            disp('shifts already calculated!');
        end
        save(fullfile(path,'avg','Shifts.mat'),'Shifts');
        clearvars -except i to_do_list AnimalID BaseROI path Day name
        disp(strcat('(',string(i),'/',string(size(to_do_list,2)),')',' processing:',string(to_do_list{i}),' for calculating df/f ...'));
        [data,sti] = load_data(AnimalID,name);
        data_dff = df_f(data,sti);
        data_dff = match_data(data_dff,AnimalID,name,BaseROI);
        save(fullfile('X:\Mingxuan\WF\data',AnimalID,'dff',strcat(name,'.mat')),'data_dff','-v7.3');
        disp('done calculating df/f!');
        clearvars -except i to_do_list AnimalID path Day BaseROI
    end
    disp('done individual data processing!');
    %% combining data
    disp('combining stimulation data ...');
    fileID_si = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{1},'Trial_Info_Sequence.txt'),'r');
    fgets(fileID_si);
    sti = fscanf(fileID_si,'%d %d %d %d %f %f %f %f',[8 Inf]);
    fclose(fileID_si);
    for i = 2:size(to_do_list,2)
        clearvars -except i to_do_list AnimalID sti Day
        fileID_si = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,to_do_list{i},'Trial_Info_Sequence.txt'),'r');
        fgets(fileID_si);
        sti_temp = fscanf(fileID_si,'%d %d %d %d %f %f %f %f',[8 Inf]);
        fclose(fileID_si);
        sti = cat(2,sti,sti_temp);
    end
    save(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_sti',strcat(string(Day),'.mat')),'sti','-v7.3');
    disp('done combining stimulation data!');
    disp(strcat('(',string(1),'/',string(size(to_do_list,2)),')',' combining df/f and z-score'));
    data_dff = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'dff',to_do_list{1}));
    data_dff = data_dff.data_dff;
    data_z = combine_zscore(data_dff,0.2);
    data_dff = imresize(data_dff,0.2);
    for i = 2:size(to_do_list,2)
        disp(strcat('(',string(i),'/',string(size(to_do_list,2)),')',' combining df/f and z-score'));
        clearvars -except i to_do_list AnimalID data_dff data_z Day
        data_temp = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'dff',to_do_list{i}));
        data_temp = data_temp.data_dff;
        data_temp_z = combine_zscore(data_temp,0.2);
        if size(data_temp_z,[1 2]) == size(data_z,[1 2])
            data_temp = imresize(data_temp,0.2);
        else
            data_temp_z = combine_zscore(data_temp,0.203);
            data_temp = imresize(data_temp,0.203);
        end
        data_z = cat(3,data_z,data_temp_z);
        data_dff = cat(3,data_dff,data_temp);
    end
    save(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_dff',strcat(string(Day),'.mat')),'data_dff','-v7.3');
    save(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_zscore',strcat(string(Day),'.mat')),'data_z','-v7.3');
    disp('done combining df/f and z-score!');
    disp(strcat(AnimalID,':Done analysis for day:',string(Day)));
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

function [Img,ori,s] = load_image(path,margin,tx,ty)
    img = imread(path);
    img = histeq(img);
    Img = uint8(zeros(int16((1+margin)*size(img,1)),int16((1+margin)*size(img,2))));
    Img(int16((margin/2)*size(img,1))+1+tx:int16((margin/2)*size(img,1))+tx+size(img,1),...
        int16((margin/2)*size(img,2))+1+ty:int16((margin/2)*size(img,2))+ty+size(img,2)) = img;
    ori = [int16((margin/2)*size(img,1))+1+tx int16((margin/2)*size(img,2))+1+ty];
    s = [size(img,1) size(img,2)];
end
function mean_dif = dif(Image_1_path,Image_2_path,tx,ty)
    margin = 0.3;
    [Img_1,ori_1,s_1] = load_image(Image_1_path,margin,0,0);
    Img_1 = imgaussfilt(Img_1,2);
    [Img_2,ori_2,s_2] = load_image(Image_2_path,margin,tx,ty);
    Img_2 = imgaussfilt(Img_2,2);
    dif = abs(Img_1-Img_2);
    dif = dif(max(ori_1(1),ori_2(1)):max(ori_1(1),ori_2(1))+s_1(1)-abs(tx)-1,...
        max(ori_1(2),ori_2(2)):max(ori_1(2),ori_2(2))+s_1(2)-abs(ty)-1);
    mean_dif = mean(mean(dif));
end
function [min_tx,min_ty] = loc_shift(Image_mother_path,Image_path,search_size)
    min_dif = 99999;
    for i = search_size(1):search_size(2)
        for j = search_size(3):search_size(4)
            mean_dif = dif(Image_mother_path,Image_path,i,j);
            if mean_dif < min_dif
                min_dif = mean_dif;
                min_t = [i j];
            end
        end
    end
    min_tx = min_t(1);
    min_ty = min_t(2);
end
function data_dff = df_f(data,sti)
    pre = 15;
    post = 45;
    data_dff = zeros(size(data,1),size(data,2),size(sti,2)*(pre+post+1));
    for i = 1:size(sti,2)
        avg = mean(data(:,:,sti(i)-pre:sti(i)-1),3);
        data_dff(:,:,(i-1)*(pre+post+1)+1:i*(pre+post+1)) = (data(:,:,sti(i)-pre:sti(i)+post) - avg)./avg;
    end
end

function [data,sti] = load_data(AnimalID,Time)
    % read data
    data = readMultipageTiff(fullfile('X:\Mingxuan\WF\data',AnimalID,Time,'MC00001.tiff'));
    files = dir(fullfile('X:\Mingxuan\WF\data',AnimalID,Time));
    for i = 1:size(files)
        fn = files(i).name;
        if size(fn,2) == 12
            if str2num(fn(7)) ~= 1
                temp = readMultipageTiff(fullfile('X:\Mingxuan\WF\data',AnimalID,Time,fn));
                data = cat(3,data,temp);
            end
        end
    end
    % read sti
    fileID = fopen(fullfile('X:\behavior_training\Manual\JL\BehaviorData',AnimalID,Time,'SyncData\Trial_On_Frame.txt'),'r');
    sti = fscanf(fileID,'%f').';
    fclose(fileID);
end

function data_m = match_data(data,AnimalID,Time,BaseROI)
    % match shift file
    Shifts = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'avg','Shifts.mat'));
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

function data_z = combine_zscore(data_dff,rescale)
    data_dff = imresize(data_dff,rescale);
    STD = zeros(size(data_dff,1),size(data_dff,2),int16(size(data_dff,3)/61));
    data_z = zeros(size(data_dff,1),size(data_dff,2),size(data_dff,3));
    for i = 1:int16(size(data_dff,3)/61)
        STD(:,:,i) = std(data_dff(:,:,(i-1)*61+1:i*61),0,3);
        data_z(:,:,(i-1)*61+1:i*61) = data_dff(:,:,(i-1)*61+1:i*61)./STD(:,:,i);
    end
end