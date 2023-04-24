clearvars -except L H A
AnimalList = {'000D2491CA72' [25 5 224 194];
              '080500020A05' [44 10 228 179];
              '210805001438' [20 17 234 181];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};
animal = 1;
AnimalID = AnimalList{animal,1};
path = fullfile('X:\Mingxuan\WF\data',AnimalID,'COMBINED\combined_stage');


I = load(fullfile(path,'FRA_contour.mat'));
I = I.C;
I(I<1)=0;
I_fill = imfill(I(:,:,1),'holes');

avg_img = imread(fullfile('X:\Mingxuan\WF\data',AnimalID,'avg\m.png'));
avg_img = double(avg_img(AnimalList{animal,2}(1,1):AnimalList{animal,2}(1,3),AnimalList{animal,2}(1,2):AnimalList{animal,2}(1,4),:));
avg_img = fliplr(rot90(avg_img/255));

avg_img_n = imread(fullfile('X:\Mingxuan\WF\data',AnimalID,'avg\n.png'));
avg_img_n = double(avg_img_n(AnimalList{animal,2}(1,1)+6:AnimalList{animal,2}(1,3)+6,AnimalList{animal,2}(1,2)+1:AnimalList{animal,2}(1,4)+1,:));
avg_img_n = fliplr(rot90(avg_img_n/255));

M = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\region_mask.mat'));
region_mask = M.region_mask;
region_mask = imresize(region_mask,size(I_fill));
region_mask(region_mask>0.5) = 1;
region_mask(region_mask<1) = 0;
kernel = reshape([0 1 0;1 1 1;0 1 0],[3 3 1]);
region_mask = region_mask + (convn((1-region_mask),kernel,"same")>0) - 1;
%fcanv = figure;
%fstats = figure;%('Position',[100,100,800,1600]);
%iMax = max(max(data.data_df{1,1},[],"all"),max(data.data_df{2,1},[],"all"),max(data.data_df{3,1},[],"all"));
%% load data
pre = 30;
post = 60;
%data_temp = load(fullfile(path,strcat('2022-08-09_13-19-40','.mat')));
data_temp = load(fullfile(path,strcat('stage_21_25','.mat')));
data = data_temp.data_dff;

X = zeros(size(data{1,1},1),size(data{1,1},2),3);
interval = 41:60;
norm_factor = 0.04;
% 0-1/3 = 0.025 % 1/3 - 1 = 0.04
lfc = data{1,1};
lfc_map = mean(lfc(:,:,interval),3);
lfc_norm = lfc_map/norm_factor;
lfc_norm(lfc_norm >= 1) = 1;
lfc_norm(lfc_norm < 0) = 0;
lfc_norm = fliplr(rot90(lfc_norm));
lfc_norm = medfilt2(lfc_norm,[1 1]);
% after:0.05
% for new 0.1+0.05
hfc = data{1,11};
hfc_map = mean(hfc(:,:,interval),3);
hfc_norm = hfc_map/norm_factor;
hfc_norm(hfc_norm >= 1) = 1;
hfc_norm(hfc_norm < 0) = 0;
hfc_norm = fliplr(rot90(hfc_norm));
hfc_norm = medfilt2(hfc_norm,[1 1]);

hfu = data{2,11};
hfu_map = mean(hfu(:,:,interval),3);
hfu_norm = hfu_map/norm_factor;
hfu_norm(hfu_norm >= 1) = 1;
hfu_norm(hfu_norm < 0) = 0;
hfu_norm = fliplr(rot90(hfu_norm));
hfu_norm = medfilt2(hfu_norm,[1 1]);

hfw = data{3,11};
hfw_map = mean(hfw(:,:,interval),3);
hfw_norm = hfw_map/norm_factor;
hfw_norm(hfw_norm >= 1) = 1;
hfw_norm(hfw_norm < 0) = 0;
hfw_norm = fliplr(rot90(hfw_norm));
hfw_norm = medfilt2(hfw_norm,[1 1]);

lfw = data{3,1};
lfw_map = mean(lfw(:,:,interval),3);
lfw_norm = lfw_map/norm_factor;
lfw_norm(lfw_norm >= 1) = 1;
lfw_norm(lfw_norm < 0) = 0;
lfw_norm = fliplr(rot90(lfw_norm));
lfw_norm = medfilt2(lfw_norm,[1 1]);

lfu = data{2,1};
lfu_map = mean(lfu(:,:,interval),3);
lfu_norm = lfu_map/norm_factor;
lfu_norm(lfu_norm >= 1) = 1;
lfu_norm(lfu_norm < 0) = 0;
lfu_norm = fliplr(rot90(lfu_norm));
lfu_norm = medfilt2(lfu_norm,[1 1]);

lfe = data{4,1};
lfe_map = mean(lfe(:,:,interval),3);
lfe_norm = lfe_map/norm_factor;
lfe_norm(lfe_norm >= 1) = 1;
lfe_norm(lfe_norm < 0) = 0;
lfe_norm = fliplr(rot90(lfe_norm));
lfe_norm = medfilt2(lfe_norm,[1 1]);

hfe = data{4,11};
hfe_map = mean(hfe(:,:,interval),3);
hfe_norm = hfe_map/norm_factor;
hfe_norm(hfe_norm >= 1) = 1;
hfe_norm(hfe_norm < 0) = 0;
hfe_norm = fliplr(rot90(hfe_norm));
hfe_norm = medfilt2(hfe_norm,[1 1]);

img = zeros(size(lfc_norm,1),size(lfc_norm,2),3);
img(:,:,1) = hfc_norm;
img(:,:,3) = lfc_norm;
img(:,:,2) = 0.5*lfc_norm;
img = medfilt3(img,[3,3,1]);
img = img + max(avg_img_n.*(1-sum(img,3)),0) + sum(region_mask,3);

X(81:90,[101,110],:) = 1;
X([81,90],101:110,:) = 1;

X(71:80,[12,21],:) = 1;
X([71,80],12:21,:) = 1;

X(71:80,[55,64],:) = 1;
X([71,80],55:64,:) = 1;
X = fliplr(rot90(X));

%img = img + X;

ROI_3_lfc = mean(lfc(81:90,101:110,:),[1 2]);
ROI_3_hfc = mean(hfc(81:90,101:110,:),[1 2]);
ROI_1_lfc = mean(lfc(71:80,12:21,:),[1 2]);
ROI_1_hfc = mean(hfc(71:80,12:21,:),[1 2]);
ROI_2_lfc = mean(lfc(71:80,55:64,:),[1 2]);
ROI_2_hfc = mean(hfc(71:80,55:64,:),[1 2]);
figure;
hold on;
%plot(permute(ROI_3_lfc,[3 2 1]))
%plot(permute(ROI_4_lfc,[3 2 1]))
hold off;

imshow(img)
%figure;
%heatmap(lfc_map,'Colormap',turbo,'ColorLimits',[-0.01 0.05],'GridVisible','off');
%corr();
lfc = data{3,1};
lfc_mean = mean(lfc(:,:,interval),3);
lfc_std = std(lfc(:,:,1:30),0,3);
lfc_z = lfc_mean./lfc_std;
lfc_z(abs(lfc_z) < 1.5) = 0;
%lfc_z(lfc_z > 1) = 1;
lfc_z_norm = lfc_z/10;%/max(lfc_z,[],"all");
lfc_z_norm = fliplr(rot90(lfc_z_norm));
img = lfc_z_norm;
img = medfilt2(img,[2 2]);
ZZZ = zeros(size(img,1),size(img,2),3);
ZZZ(:,:,2) = img;
ZZZ = ZZZ + I;
%img = img.*I_fill;
%img(img>0)=1;
%A(end+1) = sum(img)/sum(I_fill)
% z for first stage norm factor 10

data_temp = load(fullfile(path,strcat('stage_1_5','.mat')));
data_base = data_temp.data_dff;
lfc_base = data_base{1,1};
lfc_base_mean = mean(lfc_base(:,:,interval),3);
lfc_base_std = std(lfc_base(:,:,1:30),0,3);
lfc_base_z = lfc_base_mean./lfc_base_std;
lfc_base_z(abs(lfc_base_z) < 1.5) = 0;

%sub = normcdf(lfc_z,0,1) - normcdf(lfc_base_z,0,1);
sub = lfc_z - lfc_base_z;
%sub = sub/max(abs(sub),[],"all");
sub = fliplr(rot90(sub));
%sub = sub.*I_fill;

heat_sub = zeros(size(sub,1),size(sub,2),3);
sub_above = sub;
sub_below = sub;
sub_above(sub_above<1)=0;
sub_below(sub_below>-1)=0;
sub_below = -sub_below;
sub_above = sub_above/max(abs(sub),[],"all");%3
sub_below = sub_below/max(abs(sub),[],"all");%3
% in manuscript normalized by 3
% norm factor = 5 (z - z)
heat_sub(:,:,1) = medfilt2(sub_above,[2 2]);
heat_sub(:,:,3) = medfilt2(sub_below,[2 2]);
heat_sub(:,:,2) = medfilt2(sub_below/2,[2 2]);
figure;
imshow(heat_sub+sum(region_mask,3))

sub_above(sub_above>0)=1;
sub_below(sub_below>0)=1;
%H(end+1) = sum(sub_above.*I_fill,"all")/sum(I_fill,"all");
%L(end+1) = sum(sub_below.*I_fill,"all")/sum(I_fill,"all");
