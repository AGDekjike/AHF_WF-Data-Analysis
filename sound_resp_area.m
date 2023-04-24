AnimalList = {'080500020A05' [44 10 228 179];
              '210805001438' [20 17 234 181];
              '000D2491CA72' [25 5 224 194];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};
%fcanv = figure;
%fstats = figure;%('Position',[100,100,800,1600]);
%iMax = max(max(data.data_df{1,1},[],"all"),max(data.data_df{2,1},[],"all"),max(data.data_df{3,1},[],"all"));
%% load data
pre = 30;
post = 60;
num_r = 14;
%data_temp = load(fullfile(path,strcat('2022-08-09_13-19-40','.mat')));
Area = zeros(size(AnimalList,1),5,num_r);
L = Area;
H = Area;
DFF = Area;
weight = [];
interval = 31:40;
norm_factor = 0.025;


for animal = 1:size(AnimalList,1)
    path = fullfile('X:Mingxuan\WF\data',AnimalList{animal,1},'COMBINED\combined_stage');
    I = load(fullfile(path,'FRA_contour.mat'));
    I = I.C;
    I(I<1)=0;
    I_fill = imfill(I(:,:,1),'holes');

    avg_img = imread(fullfile('X:\Mingxuan\WF\data',AnimalList{animal,1},'avg\m.png'));
    avg_img = double(avg_img(AnimalList{animal,2}(1,1):AnimalList{animal,2}(1,3),AnimalList{animal,2}(1,2):AnimalList{animal,2}(1,4),:));
    avg_img = fliplr(rot90(avg_img/255));

    M = load(fullfile('X:\Mingxuan\WF\data',AnimalList{animal,1},'ana\region_mask.mat'));
    region_mask = M.region_mask;
    region_mask = imresize(region_mask,size(I_fill));
    region_mask(region_mask>0.5) = 1;
    region_mask(region_mask<1) = 0;
    kernel = reshape([0 1 0;1 1 1;0 1 0],[3 3 1]);
    region_mask_c = region_mask + (convn((1-region_mask),kernel,"same")>0) - 1;

    data_temp = load(fullfile(path,strcat('stage_1_5','.mat')));
    data_base = data_temp.data_dff;
    lfc_base = data_base{1,1};%%%%%%%%%%%1/11
    lfc_base = medfilt3(lfc_base,[9 9 3]);
    lfc_base_mean = mean(lfc_base(:,:,interval),3);
    lfc_base_std = std(lfc_base(:,:,1:30),0,3);
    lfc_base_z = lfc_base_mean./lfc_base_std;%%%%%%
    %lfc_base_z(lfc_base_z < 0) = 0;%%%%%%%%%%
    lfc_base_z = medfilt2(lfc_base_z,[1 1]);
    lfc_base_mean = medfilt2(lfc_base_mean,[1 1]);

    hfc_base = data_base{1,11};%%%%%%%%%%%1/11
    hfc_base = medfilt3(hfc_base,[9 9 3]);
    hfc_base_mean = mean(hfc_base(:,:,interval),3);
    hfc_base_std = std(hfc_base(:,:,1:30),0,3);
    hfc_base_z = hfc_base_mean./hfc_base_std;%%%%%%
    %lfc_base_z(lfc_base_z < 0) = 0;%%%%%%%%%%
    hfc_base_z = medfilt2(hfc_base_z,[1 1]);
    hfc_base_mean = medfilt2(hfc_base_mean,[1 1]);

    for day = 1:5
        data_temp = load(fullfile(path,strcat('stage_',num2str((day-1)*5+1),'_',num2str(day*5),'.mat')));
        data = data_temp.data_dff;
        data_stat = data_temp.data_stat;
        
        lfc = data{1,1};%%%%%%%%%%%%%%%%1/11
        lfc = medfilt3(lfc,[1 1 3]);
        lfc_mean = mean(lfc(:,:,interval),3);
        lfc_std = std(lfc(:,:,1:30),0,3);
        lfc_z = lfc_mean./lfc_std;%%%%%%
        %lfc_z(lfc_z < 0) = 0;%%%%%%%%%%%%%%%
        lfc_z_norm = lfc_z/max(lfc_z,[],"all");
        lfc_z_norm = fliplr(rot90(lfc_z_norm));
        img = cat(3,zeros(size(lfc_z_norm)),lfc_z_norm,zeros(size(lfc_z_norm)));
        lfc_z = medfilt2(lfc_z,[1 1]);
        lfc_mean = medfilt2(lfc_mean,[1 1]);

        hfc = data{1,11};%%%%%%%%%%%%%%%%1/11
        hfc = medfilt3(hfc,[1 1 3]);
        hfc_mean = mean(hfc(:,:,interval),3);
        hfc_std = std(hfc(:,:,1:30),0,3);
        hfc_z = hfc_mean./hfc_std;%%%%%%
        %lfc_z(lfc_z < 0) = 0;%%%%%%%%%%%%%%%
        hfc_z_norm = hfc_z/max(hfc_z,[],"all");
        hfc_z_norm = fliplr(rot90(hfc_z_norm));
        %img = cat(3,zeros(size(lfc_z_norm)),lfc_z_norm,zeros(size(lfc_z_norm)));
        hfc_z = medfilt2(hfc_z,[1 1]);
        hfc_mean = medfilt2(hfc_mean,[1 1]);

        %sub = (((lfc_base_z>3)+(lfc_z>3))>0).*(lfc_mean - lfc_base_mean)./((max(lfc_mean,0) + max(lfc_base_mean,0))+((lfc_base_z<=3).*(lfc_z<=3)));
        %sub = (((lfc_base_z>3)+(lfc_z>3))>0).*(lfc_mean - lfc_base_mean)./((max(lfc_mean,0) + max(lfc_base_mean,0))+((lfc_base_z<=3).*(lfc_z<=3)));
        sub = abs((lfc_mean - hfc_mean));
        %%%%%%%%%%%%%%%%%%% 31-40 = 1.5
        sub(sub >= 1) = 1;
        sub(sub <= -1) = -1;
        sub = fliplr(rot90(sub));
        sub = medfilt2(sub,[1 1]);
        heat_sub = zeros(size(sub,1),size(sub,2),3);
        sub_above = sub;
        sub_below = sub;
        sub_above(sub_above<0)=0;
        sub_below(sub_below>-0)=0;
        sub_below = -sub_below;
        sub_above = sub_above/1;%max(abs(sub),[],"all");
        sub_below = sub_below/1;%max(abs(sub),[],"all");
        % norm factor = 5 (z - z)
        heat_sub(:,:,1) = medfilt2(sub_above,[1 1]);
        heat_sub(:,:,3) = medfilt2(sub_below,[1 1]);
        heat_sub(:,:,2) = medfilt2(sub_below/2,[1 1]);
        %figure;
        heat_sub = heat_sub.*(sum(region_mask,3)>0);
        %imshow(heat_sub+max(avg_img.*(1-sum(heat_sub,3)),0)+(sum(region_mask_c,3)>0))%+max(avg_img.*(1-sum(heat_sub,3)),0)
        %imshow(img+(sum(region_mask_c,3)>0))
        
        %sub_above(sub_above>0)=1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %sub_below(sub_below>0)=1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        H(animal,day,:) = sum(repmat(sub_above,[1 1 num_r]).*region_mask,[1 2])./sum(region_mask,[1 2]);
        L(animal,day,:) = sum(repmat(sub_below,[1 1 num_r]).*region_mask,[1 2])./sum(region_mask,[1 2]);
        Area(animal,day,:) = sum(repmat((fliplr(rot90(lfc_z))>3),[1 1 num_r]).*region_mask,[1 2])./sum(region_mask,[1 2]);
        DFF(animal,day,:) = sum(repmat(sub,[1 1 num_r]).*region_mask,[1 2])./sum(region_mask,[1 2]);
        %lfc_base_z = lfc_z;
    end
end

LF = cat(4,L,H);
HF = cat(4,L,H);
%save(fullfile('X:Mingxuan\WF\data','ANA','HF_38_40_6_dff_z3.mat'),"HF");
%save(fullfile('X:Mingxuan\WF\data','ANA','LF_Area_41_60_6_z3_med9.mat'),"Area");
save(fullfile('X:Mingxuan\WF\data','ANA','LH_DFF_31_40.mat'),"DFF");

function corr(loc_1,loc_2)
    c = zeros(121,121);
    for i = 1:121
        for j = 1:121
            mdl = fitlm(loc_1(:,i).',loc_2(:,j).');
            c(i,j) = mdl.Rsquared.Adjusted;
        end
    end
    figure;
    heatmap(c,'Colormap',turbo,'ColorLimits',[0 1]);
    dc = zeros(61,61);
    for i = 1:61
        for j = 1:61
            %dc(i,j) = c(i,j) - c(j,i);
        end
    end
    %figure;
    %heatmap(dc,'Colormap',turbo,'ColorLimits',[-1 1]);
end