clear all;
AnimalID = '08050002242B';
Time = '2022-06-03_11-45-45';
Time_b = Time;
%% loading data
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
%% sti time
fileID = fopen(fullfile('Z:\behavior_training\Manual\JL\BehaviorData',AnimalID,Time_b,'SyncData\Trial_On_Frame.txt'),'r');
sti = fscanf(fileID,'%f').';
fclose(fileID);
%% sti info
fileID_si = fopen(fullfile('Z:\behavior_training\Manual\JL\BehaviorData',AnimalID,Time_b,'Trial_Info_Sequence.txt'),'r');
fgets(fileID_si);
si = fscanf(fileID_si,'%d %d %d %d %f %f %f %f',[8 Inf]);
fclose(fileID_si);
info = load('D:\WF\data\08050002242B\stim_info.mat');
%% match file
Shifts = load(fullfile('D:\WF\data',AnimalID,'avg','Shifts.mat'));
Shifts = Shifts.Shifts;
shift = [0 0];
for i = 1:size(Shifts)
    if Time == Shifts{i}
        shift = [Shifts{i,2} Shifts{i,3}];
    end
end
%% no needs if corrected
fileID_fc = fopen('D:\WF\FC\data\08050002242B\2022-05-27_13-28-50\fc.txt','r');
fc = fscanf(fileID_fc,'%f');
fclose(fileID_fc);
%sti(:) = int32(sti(:)-((fc-size(data,3))*exp((sti(:)/fc).^2-1)));
%% shift ROI
BaseROI = [21 4 220 183]; % x1 y1 x2 y2
CorrectROI = BaseROI;
for i = 1:size(BaseROI,2)
    CorrectROI(i) = BaseROI(i) - shift(mod(i-1,2)+1);
end
%% analyze
dim = [20 20]; % x,y
data_divided = divide(data,CorrectROI(1),CorrectROI(2),CorrectROI(3),CorrectROI(4),dim(1),dim(2)); %x1,y1,x2,y2
figure;
for i = 1:size(data_divided,1)
    for j = 1:size(data_divided,2)
        [Window_dff,count] = analyze(data_divided{i,j},sti);
        subplot(size(data_divided,1),size(data_divided,2),(i-1)*size(data_divided,2)+j);
        hold on;
        plot_acc(Window_dff,si);
        hold off;
    end
end
%%
data_dff = df_f(data,sti);
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

function data_divided = divide(data,x1_ROI,y1_ROI,x2_ROI,y2_ROI,dimx,dimy) % dim = grid size in pixels
    data_divided = cell(floor((x2_ROI-x1_ROI+1)/dimx),floor((y2_ROI-y1_ROI+1)/dimy));
    for i = 1:size(data_divided,1)
        for j = 1:size(data_divided,2)
            data_divided{i,j} = data((i-1)*dimx+x1_ROI:i*dimx+x1_ROI-1,(j-1)*dimy+y1_ROI:j*dimy+y1_ROI-1,:);
        end
    end
end

function [Window_dff,count] = analyze(data,sti) % data of ROI*t
    avg = permute(mean(data,[1 2]),[3 2 1]).';
    Window_dff = cell(size(sti));
    pre = 15;
    post = 45;
    count = 0;
    threshold = 3;
    for i = 1:size(sti,2)
        f0 = mean(avg(1,sti(i)-pre:sti(i)-1));
        s = std(avg(1,sti(i)-pre:sti(i)-1));
        Window_dff{i} = (avg(1,sti(i)-pre:sti(i)+post)-f0)/s;
        if (mean(avg(1,sti(i):sti(i)+30))-f0)/s > threshold
            count = count + 1;
        end
    end
end

function plot_acc(Window,si)
    color_res = {'#cc0000' '#00dd00'};
    tru = cell(0);
    fal = cell(0);
    for i = 1:size(Window,2)
        if si(4,i) == 1
            %plot(Window{i},'Color',color_res{si(4,i)+1});
            tru{end+1} = Window{i};
        else
            fal{end+1} = Window{i};
        end
        %plot(Window{i},'Color',color_res{si(4,i)+1});
    end
    plot(mean(cat(1,tru{:})),'Color',color_res{2});
    plot(mean(cat(1,fal{:})),'Color',color_res{1});
    xlim([1 61]);
    ylim([-3 15]);
    xline(15);
end

function plot_freq(Window,si,info)
    color_res = {'#0000ff' '#00ffff' '#ff00ff' '#9900ff' '#980000' '#ff0000' '#ff9900' '#00ff00'};
    for i = 1:size(Window,2)
        fs = info.stim_param.freq2use(1,info.stim_param.freqid_attenid_array(si(1,i),1));
        plot(Window{i},'Color',color_res{int16(fs/7)});
    end
    xlim([1 61]);
    xline(16);
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