%% Run list
AnimalList = {'080500026C63' [23 7 223 186];
              '080500020A05' [20 25 219 199];
              '08050002242B' [21 4 220 183];
              '08050000D7DA' [34 8 233 192];
              '210805001438' [22 6 226 195];
              '210805007854' [36 7 235 191];
              '007DA64A57C6' [25 9 229 193];
              '210531013C28' [32 12 231 196];
              '21053101283C' [21 13 225 197];
              '000D2491CA72' [25 5 224 194];
              '210805001438' [20 17 234 181];
              '080500020A05' [44 10 228 179];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};
range = [202212050000 202212299999];
AnimalID = AnimalList{end,1};
path = fullfile("X:\Mingxuan\WF\data",AnimalID);
M = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\region_mask.mat'));
region_mask = M.region_mask;
if ~exist(fullfile(path,'combined_stage'), 'dir')
   mkdir(fullfile(path,'combined_stage'));
end
%%
color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56]];
color_idx = [9 7 5 3 1 10 8 6 4 2];
color = color(color_idx,:)/255;
c = 1:8;
categ = [1 2 3 31 32 33];

d = cat(2,3:7,9:10,12:28,101);
%d = 5:29;
stage = zeros(size(d,2),1);
for i = 1:size(d,2)
    stage(i,1) = 20230200 + d(i);
end

S = cell(0);
for s = 1:size(stage,1)
    data_dff = load(fullfile(path,'combined_dff',strcat(num2str(stage(s)),'.mat')));
    data_dff = data_dff.data_dff;
    sti = load(fullfile(path,'combined_sti',strcat(num2str(stage(s)),'.mat')));
    sti = sti.sti;
    data_dff = reshape(data_dff,[size(data_dff,1) size(data_dff,2) int32(size(data_dff,3)/size(sti,2)) size(sti,2)]);
    
    CCC = cell(0);
    for ct = 1:size(categ,2)
        fq = ceil(categ(ct)/3);
        rst = ceil(categ(ct)/3)*3-categ(ct)-1;
        fq_m = sti(1,:);
        fq_m(fq_m~=fq)=0;
        fq_m(fq_m~=0)=1;
        rst_m = sti(4,:);
        rst_m(rst_m~=rst)=-99;
        rst_m(rst_m~=-99)=1;
        rst_m(rst_m~=1)=0;
        cg = rst_m.*fq_m;

        data_dff_ct = data_dff.*reshape(cg,[1 1 1 size(cg,2)]);
        data_dff_ct(:,:,:,all(data_dff_ct == 0,[1 2 3])) = [];

        CCC{end+1} = fliplr(rot90(data_dff_ct));
    end
    S{end+1} = CCC;
end
P = zeros(size(S,2),61);
P_all = cell(1,size(S,2));
% 20 34;33 12
%baseline for 830 24:25,22:23
%baseline for A52 29:31,17:19
%baseline for C8  26:28,19:21

%A1L:27:28;29:30
%A1L:22:23;33:34
%DM:24:25;22:23
%DP:=17:19;24:25
%AAFL:30:31;14:15
%A2L:34:35;21:22
%DA:22:23;12:13 wrong > correct


loc1 =16:18;
loc2 =22:22;
figure;
hold on
for region = 1:14
    for cls = [1 4]
        for i = 1:size(S,2)
            %P(i,:) = mean(S{1,i}{1,cls}(loc1,loc2,:,:),[1 2 4]);
            %P_all{1,i} = permute(mean(S{1,i}{1,cls}(loc1,loc2,:,:),[1 2]),[4 3 1 2]);
            P(i,:) = sum(S{1,i}{1,cls}.*(repmat(region_mask(:,:,region),[1 1 size(S{1,i}{1,cls},3) size(S{1,i}{1,cls},4)])),[1 2 4])./sum(repmat(region_mask(:,:,region),[1 1 size(S{1,i}{1,cls},3) size(S{1,i}{1,cls},4)])>0,[1 2 4]);
            P_all{1,i} = permute(sum(S{1,i}{1,cls}.*(repmat(region_mask(:,:,region),[1 1 size(S{1,i}{1,cls},3) size(S{1,i}{1,cls},4)])),[1 2])./sum(repmat(region_mask(:,:,region),[1 1 size(S{1,i}{1,cls},3) size(S{1,i}{1,cls},4)])>0,[1 2]),[4 3 1 2]);
        end
        %17:19,24:25;
        t = -15:45;
        t = t/30;
        subplot(4,7,14*floor((region-1)/7)+(cls>1)*7+mod(region-1,7)+1)
        hold on;
        for i = 1:5
            y = P_all{1,ceil((i-1)*5+1)};
            for j = ceil((i-1)*5+2):ceil(i*5)
                y = cat(1,y,P_all{1,j});
            end
            N = size(y,1);
            yMean = mean(y);
            ySEM = std(y)/sqrt(N);
            CI95 = tinv([0.025 0.975], N-1);
            yCI95 = bsxfun(@times, ySEM, CI95(:));
            patch([t fliplr(t)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], color(i,:), 'EdgeColor','none', 'FaceAlpha',0.25);
            plot(t,mean(y),Color = color(i,:));
        end
        %legend()
        xlabel('Time (s)')
        ylabel('df/f')
        ylim([-0.01 0.06])
        xlim([-0.5 1.5]);
        hold off;
    end
end
hold off

PP = medfilt2(P,[1 1]);
figure;
heatmap(PP,'Colormap',turbo,'GridVisible','off','ColorLimits',[-0.15 0.15]);
%surf(P);

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