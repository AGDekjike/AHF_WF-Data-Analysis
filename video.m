clear all;
path = 'X:\Mingxuan\WF\data\080500020A05\COMBINED\combined_stage';
data = cell(1,6);
data_duration = cell(1,6);
duration = cell(1,6);
iMax = cell(1,6);
tMax = cell(1,6);
text = cell(1,6);
text{1} = 'stage 1: day 1-3';
text{2} = 'stage 2: day 4-11';
text{3} = 'stage 3: day 12-16';
text{4} = 'stage 4: day 17-24';
text{5} = 'stage 5: day 24.5-28';
text{6} = 'stage 6: day 29-37';
%I = load(fullfile(path,'FRA_contour.mat'));
%I = I.C;
%I(I<1)=0;
v = VideoWriter(fullfile(path,'stage2.avi'),'Uncompressed AVI');
v.FrameRate = 30;
open(v)
%fcanv = figure;
%fstats = figure;%('Position',[100,100,800,1600]);
%iMax = max(max(data.data_df{1,1},[],"all"),max(data.data_df{2,1},[],"all"),max(data.data_df{3,1},[],"all"));
%% load data
pre = 30;
post = 90;
for stage = 1%:size(data,2)
    data_temp = load(fullfile(path,strcat('stage2','.mat')));
    data{stage} = data_temp.data_dff;
    data_duration{stage} = data_temp.data_duration;
    iMax{stage} = [0 0 0];
    for i = 1:3
        for j = [1 11]
            if max(data{stage}{i,j},[],"all") > iMax{stage}(i)
                iMax{stage}(i) = max(data{stage}{i,j},[],"all");
            end
        end
    end
    if stage >= 1
        iMax{stage} = iMax{stage}*0.5;
    else
        iMax{stage} = iMax{stage}*0.5;
    end
    data_duration{stage} = cat(2,zeros(3,pre,11),data_duration{stage}(:,1:post+1,:));
    step = size(data{stage}{1,1},1)/(pre+post+1);
    duration{stage} = zeros(3,size(data{stage}{1,1},1),11);
    for i = 1:11
        duration{stage}(:,:,i) = imresize(data_duration{stage}(:,:,i),[3,size(data{stage}{1,1},1)]);
    end
    tMax{stage} = max(duration{stage},[],"all");
    duration{stage} = duration{stage}/tMax{stage};
end
%iMax = 0.2;
upper_margin = 10;
% For each frame
for i = 1:pre+post+1
    imwf_all = zeros(2*(size(data{stage}{1,1},2)+upper_margin),0,3);
    for stage = 1%:size(data,2)
        imwf_hf = zeros(size(data{stage}{1,1},2)+upper_margin,size(data{stage}{1,1},1),3);
        imwf_hf(upper_margin+1:end,:,1) = fliplr(rot90(imgaussfilt((data{stage}{3,11}(:,:,i))./(max(iMax{stage})))));
        imwf_hf(upper_margin+1:end,:,2) = fliplr(rot90(imgaussfilt((data{stage}{1,11}(:,:,i))./(max(iMax{stage})))));
        imwf_hf(upper_margin+1:end,:,3) = fliplr(rot90(imgaussfilt((data{stage}{2,11}(:,:,i))./(max(iMax{stage})))));
        %imwf_hf(upper_margin+1:end,:,:) = (imwf_hf(upper_margin+1:end,:,:)).*(I==0) + I;
    
        imwf_lf = zeros(size(data{stage}{1,1},2)+upper_margin,size(data{stage}{1,1},1),3);
        imwf_lf(upper_margin+1:end,:,1) = fliplr(rot90(imgaussfilt((data{stage}{3,1}(:,:,i))./(max(iMax{stage})))));
        imwf_lf(upper_margin+1:end,:,2) = fliplr(rot90(imgaussfilt((data{stage}{1,1}(:,:,i))./(max(iMax{stage})))));
        imwf_lf(upper_margin+1:end,:,3) = fliplr(rot90(imgaussfilt((data{stage}{2,1}(:,:,i))./(max(iMax{stage})))));
        %imwf_lf(upper_margin+1:end,:,:) = imwf_lf(upper_margin+1:end,:,:).*(I==0) + I;
        imwf_lf = insertText(imwf_lf,[0,0],text{stage},'FontSize',9,'BoxOpacity',0,'TextColor','white');
        
        imwf_hf(1:int16(upper_margin/2),1:ceil(i*step),1) = repmat(reshape(duration{stage}(3,1:ceil(i*step),1),[1 ceil(i*step) 1]),int16(upper_margin/2),1,1);
        imwf_hf(1:int16(upper_margin/2),1:ceil(i*step),2) = repmat(reshape(duration{stage}(1,1:ceil(i*step),1),[1 ceil(i*step) 1]),int16(upper_margin/2),1,1);
        imwf_hf(1:int16(upper_margin/2),1:ceil(i*step),3) = repmat(reshape(duration{stage}(2,1:ceil(i*step),1),[1 ceil(i*step) 1]),int16(upper_margin/2),1,1);
        imwf_hf(int16(upper_margin/2)+1:upper_margin,1:ceil(i*step),1) = repmat(reshape(duration{stage}(3,1:ceil(i*step),11),[1 ceil(i*step) 1]),int16(upper_margin/2),1,1);
        imwf_hf(int16(upper_margin/2)+1:upper_margin,1:ceil(i*step),2) = repmat(reshape(duration{stage}(1,1:ceil(i*step),11),[1 ceil(i*step) 1]),int16(upper_margin/2),1,1);
        imwf_hf(int16(upper_margin/2)+1:upper_margin,1:ceil(i*step),3) = repmat(reshape(duration{stage}(2,1:ceil(i*step),11),[1 ceil(i*step) 1]),int16(upper_margin/2),1,1);
        imwf_hf = insertText(imwf_hf,[0,0],'sound:','FontSize',9,'BoxOpacity',0,'TextColor','white');
    
        imwf_lf(imwf_lf>1) = 1;
        imwf_lf(imwf_lf<0) = 0;
        imwf_hf(imwf_hf>1) = 1;
        imwf_hf(imwf_hf<0) = 0;
        imwf = cat(1,imwf_lf,imwf_hf);
        imwf_all = cat(2,imwf_all,imwf);
    end
    writeVideo(v,imwf_all);
    imshow(imwf_all)
end
close(v)

%% rv
%854
text{1} = 'stage 1: day 1-4';
text{2} = 'stage 2: day 5-12';
text{3} = 'stage 3: day 13-15';
text{4} = 'stage 4: day 16-21';
text{5} = 'stage 5: day 22-28';
text{6} = 'stage 6: day 29-31';
%438
text{1} = 'stage 1: day 1-3';
text{2} = 'stage 2: day 4-7';
text{3} = 'stage 3: day 8-14';
text{4} = 'stage 4: day 15-22';
text{5} = 'stage 5: day 22.5-27';
text{6} = 'stage 6: day 27.5-31';
%7DA
text{1} = 'stage 1: day 1-3';
text{2} = 'stage 2: day 4-9';
text{3} = 'stage 3: day 10-16';
text{4} = 'stage 4: day 17-18';
text{5} = 'stage 5: day 19-22';
text{6} = 'stage 6: day 22.5-24';
%C6
text{1} = 'stage 1: day 1-2';
text{2} = 'stage 2: day 3-7';
text{3} = 'stage 3: day 8-13';
text{4} = 'stage 4: day 14-19';
text{5} = 'stage 5: day 20-24';
text{6} = 'stage 6: day 25-27';