clear all;
AnimalID = '080500026C63';
BaseROI = [23 7 223 186]; % x1 y1 x2 y2 [21 4 220 183](2B) [23 7 223 186](63) [20 25 219 199](A05)
if ~exist(fullfile('D:\WF\data',AnimalID,'dff_nos'), 'dir')
   mkdir(fullfile('D:\WF\data',AnimalID,'dff_nos'));
end
subfolder = dir(fullfile('D:\WF\data',AnimalID));
to_do_list = cell(0);
for i = 1:size(subfolder)
    sub_name = subfolder(i).name;
    if size(sub_name,2) == 19
        if str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10))) == 20220613
            to_do_list{end+1} = sub_name;
        end
    end
end
size(to_do_list,2)
for i = 1:size(to_do_list,2)
    i
    Time = to_do_list{i};
    [data,sti] = load_data(AnimalID,Time,BaseROI);
    data_dff = df_f(data,sti);
    save(fullfile('D:\WF\data',AnimalID,'dff_nos',strcat(Time,'.mat')),'data_dff','-v7.3');
    clearvars -except i to_do_list AnimalID BaseROI
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

function data_dff = df_f(data,sti)
    pre = 15;
    post = 45;
    data_dff = zeros(size(data,1),size(data,2),size(sti,2)*(pre+post+1));
    for i = 1:size(sti,2)
        avg = mean(data(:,:,sti(i)-pre:sti(i)-1),3);
        data_dff(:,:,(i-1)*(pre+post+1)+1:i*(pre+post+1)) = (data(:,:,sti(i)-pre:sti(i)+post) - avg)./avg;
    end
end

function [data,sti] = load_data(AnimalID,Time,BaseROI)
    % read data
    data = readMultipageTiff(fullfile('D:\WF\data',AnimalID,Time,'MC00001.tiff'));
    files = dir(fullfile('D:\WF\data',AnimalID,Time));
    for i = 1:size(files)
        fn = files(i).name;
        if size(fn,2) == 12
            if str2num(fn(7)) ~= 1
                temp = readMultipageTiff(fullfile('D:\WF\data',AnimalID,Time,fn));
                data = cat(3,data,temp);
            end
        end
    end
    % read sti
    fileID = fopen(fullfile('Z:\behavior_training\Manual\JL\BehaviorData',AnimalID,Time,'SyncData\Trial_On_Frame.txt'),'r');
    sti = fscanf(fileID,'%f').';
    fclose(fileID);
    % match shift file
    Shifts = load(fullfile('D:\WF\data',AnimalID,'avg','Shifts.mat'));
    Shifts = Shifts.Shifts;
    shift = [0 0];
    for i = 1:size(Shifts)
        if Time == Shifts{i}
            shift = [Shifts{i,2} Shifts{i,3}];
        end
    end
    CorrectROI = BaseROI;
    data_t = data(max(1,CorrectROI(1)):min(CorrectROI(3),size(data,1)),max(1,CorrectROI(2)):min(CorrectROI(4),size(data,2)),:);
    if size(imresize(data_t,0.2),[1 2]) == [int32(0.2*(BaseROI(3)-BaseROI(1)+1)) int32(0.2*(BaseROI(4)-BaseROI(2)+1))]
    else
        if CorrectROI(1) < 1
            data_t = cat(1,data(1:1-CorrectROI(1),max(1,CorrectROI(2)):min(CorrectROI(4),size(data,2)),:),data_t);
        elseif CorrectROI(3) > size(data,1)
            data_t = cat(1,data_t,data(2*size(data,1)-CorrectROI(3):end,max(1,CorrectROI(2)):min(CorrectROI(4),size(data,2)),:));
        end
        if CorrectROI(2) < 1
            data_t = cat(2,data(max(1,CorrectROI(1)):min(CorrectROI(3),size(data,1)),1:1-CorrectROI(2),:),data_t);
        elseif CorrectROI(4) > size(data,2)
            data_t = cat(2,data_t,data(max(1,CorrectROI(1)):min(CorrectROI(3),size(data,1)),2*size(data,2)-CorrectROI(3):end,:));
        end
    end
    data = data_t;
end