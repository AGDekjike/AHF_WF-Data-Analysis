AnimalList = {'000D2491CA72' [25 5 224 194];
              '080500020A05' [44 10 228 179];
              '210805001438' [20 17 234 181];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};

AnimalID = AnimalList{1,1};
path = fullfile('X:\Mingxuan\WF\data',AnimalID);
Day = 20221227;
data_z = load(fullfile(path,'combined_dff',strcat(string(Day),'.mat')));
data_z = data_z.data_dff;
color_res = {'#cc0000' '#00dd00'};
sti = load(fullfile(path,'combined_sti',strcat(string(Day),'.mat')));
sti = sti.sti;
M = load(fullfile(path,'ana\region_mask.mat'));
region_mask = M.region_mask;
%% bi
bi_lf = zeros(size(data_z,1),size(data_z,2),0);
bi_hf = zeros(size(data_z,1),size(data_z,2),0);
for i = 1:size(sti,2)
    if sti(1,i) < 6 && sti(4,i) == 0
        bi_lf(:,:,end+1) = mean(data_z(:,:,(i-1)*61+16:(i-1)*61+45),3);
    elseif sti(1,i) > 6 && sti(4,i) == 0
        bi_hf(:,:,end+1) = mean(data_z(:,:,(i-1)*61+16:(i-1)*61+45),3);
    end
end

%%
d_lf = median(bi_lf,3);
%d_lf(d_lf<1)=0;
d_lf = medfilt2(d_lf);
d_hf = median(bi_hf,3);
%d_hf(d_hf<1)=0;
d_hf = medfilt2(d_hf);
figure;
heatmap((sum(region_mask(:,:,[1 4 7 11 12]),3)>0).*fliplr(rot90(d_lf)),'Colormap',redblue,'GridVisible','off');
%heatmap(d_lf,'Colormap',turbo,'ColorLimits',[-0.01 0.05]);
figure;
heatmap((sum(region_mask(:,:,[2 5 8 10 11 12]),3)>0).*fliplr(rot90(d_hf)),'Colormap',redblue,'GridVisible','off');