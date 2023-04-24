% 080500026C63
% 080500020A05
% 08050002242B
% 08050000D7DA  s0603L
% 210805001438  s0603H
% 210805007854  s0611L
% 007DA64A57C6  s0611H
% 210531013C28  s0612L
% 21053101283C  s0612H
% 000C9522CA71  FL_S0917
% 000C9524ED50  FH_S0917
% 000C95238B31  FL_S0918
% 000C95238D37  FH_S0918
% 000C95243984 
% 000C9522DD66 
% 08050000D7DA 
%'080500020A05' [44 10 228 179];
%'210805001438' [20 17 234 181];
%'000D2491CA72' [25 5 224 194];
%'000D24918830' [26 27 225 191];
%'000D2491EA52' [34 15 223 189];
%'000D249170C8' [50 11 234 195]
AnimalID = '000D249170C8';
Day = 20230225;
data_z = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_dff',strcat(string(Day),'.mat')));
data_z = data_z.data_dff;
color_res = {'#cc0000' '#00dd00'};
sti = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_sti',strcat(string(Day),'.mat')));
sti = sti.sti;
info = load('X:\Mingxuan\WF\data\stim_info.mat');
%% bi
bi_t = zeros(size(data_z,1),size(data_z,2),0);
bi_f = zeros(size(data_z,1),size(data_z,2),0);
bi_l = zeros(size(data_z,1),size(data_z,2),0);
bi_m = zeros(size(data_z,1),size(data_z,2),0);
bi_h = zeros(size(data_z,1),size(data_z,2),0);
bi_z = zeros(size(data_z,1),size(data_z,2),size(sti,2));
bi_std = zeros(size(data_z,1),size(data_z,2),size(sti,2));
idx_max = zeros(size(data_z,1),size(data_z,2),size(sti,2));
bi_lf = zeros(size(data_z,1),size(data_z,2),0);
bi_hf = zeros(size(data_z,1),size(data_z,2),0);
for i = 1:size(sti,2)
    bi_z(:,:,i)= mean(data_z(:,:,(i-1)*61+16:(i-1)*61+30),3);
    bi_std(:,:,i)= std(data_z(:,:,(i-1)*61+1:(i-1)*61+15),0,3);
    if mod(sti(1,i),16) >= 0 && mod(sti(1,i),16) <= 3
        bi_l(:,:,end+1) = mean(data_z(:,:,(i-1)*61+16:(i-1)*61+30),3);
    elseif mod(sti(1,i),16) >= 6 && mod(sti(1,i),16) <= 9
        bi_m(:,:,end+1) = mean(data_z(:,:,(i-1)*61+16:(i-1)*61+45),3);
    elseif mod(sti(1,i),16) >= 12 && mod(sti(1,i),16) <= 15
        bi_h(:,:,end+1) = mean(data_z(:,:,(i-1)*61+16:(i-1)*61+45),3);
    end
    if sti(1,i) < 6 && sti(4,i) == 1
        bi_lf(:,:,end+1) = mean(data_z(:,:,(i-1)*61+16:(i-1)*61+45),3);
    elseif sti(1,i) > 6 && sti(4,i) == 1
        bi_hf(:,:,end+1) = mean(data_z(:,:,(i-1)*61+16:(i-1)*61+45),3);
    end
    if sti(4,i) == 1
        bi_t(:,:,end+1) = mean(data_z(:,:,(i-1)*61+16:(i-1)*61+25),3);
    else
        bi_f(:,:,end+1) = mean(data_z(:,:,(i-1)*61+50),3);
    end
end

%%
d_t = mean(bi_t,3);
d_t = medfilt2(d_t);
d_f = mean(bi_f,3);
d_f = medfilt2(d_f);
d_z = median(bi_z,3);
d_z = medfilt2(d_z);
d_std = mean(bi_std,3);
d_std = medfilt2(d_std);
d_lf = median(bi_lf,3);
%d_lf(d_lf<1)=0;
d_lf = medfilt2(d_lf);
d_hf = median(bi_hf,3);
%d_hf(d_hf<1)=0;
d_hf = medfilt2(d_hf);
%figure;
%heatmap(median(bi_l,3),'Colormap',turbo,'ColorLimits',[-0.005 0.1]);
%figure;
%heatmap(median(bi_m,3),'Colormap',turbo,'ColorLimits',[-0.005 0.1]);
%figure;
%heatmap(median(bi_h,3),'Colormap',turbo,'ColorLimits',[-0.005 0.1]);
%figure;
%heatmap(d_t,'Colormap',turbo,'ColorLimits',[-0.005 0.15]);
figure;
heatmap(fliplr(rot90(d_lf)),'Colormap',redblue);
%heatmap(d_lf,'Colormap',turbo,'ColorLimits',[-0.01 0.05]);
figure;
heatmap(fliplr(rot90(d_hf)),'Colormap',redblue);
%heatmap(d_hf,'Colormap',turbo,'ColorLimits',[-0.01 0.05]);
%figure;
%plot(permute(data_z(4,22,611:1300),[3 2 1]))
%figure;
%heatmap(mean(bi_t,3),'Colormap',turbo,'ColorLimits',[-0.5 3]);
%figure;
%heatmap(mean(bi_f,3),'Colormap',turbo,'ColorLimits',[-0.5 3]);
%figure;
%plot(permute(bi_t(19,8,:),[3 2 1]),permute(bi_f(34,14,:),[3 2 1]),'.');