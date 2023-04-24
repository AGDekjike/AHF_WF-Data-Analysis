%% Run list
AnimalList = {'000D2491CA72' [25 5 224 194];
              '210805001438' [20 17 234 181];
              '080500020A05' [44 10 228 179];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};
color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56]];
color_idx = [9 7 5 3 1 10 8 6 4 2];
color = color(color_idx,:)/255;
interval = 23:25;

A = cell(0);

%d = cat(2,3:7,9:10,12:28,101);
d = 5:29;
stage = zeros(size(d,2),1);
for i = 1:size(d,2)
    stage(i,1) = 20221200 + d(i);
end
for animal = 1:4
    S = cell(0);
    AnimalID = AnimalList{animal,1};
    path = fullfile("X:\Mingxuan\WF\data",AnimalID);
    M = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\region_mask.mat'));
    region_mask = M.region_mask;
    categ = [1 2 3 31 32 33];
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
    A{end+1} = S;
end

d = cat(2,3:7,9:10,12:28,101);
stage = zeros(size(d,2),1);
for i = 1:size(d,2)
    stage(i,1) = 20230200 + d(i);
end
for animal = 5:6
    S = cell(0);
    AnimalID = AnimalList{animal,1};
    path = fullfile("X:\Mingxuan\WF\data",AnimalID);
    categ = [1 2 3 31 32 33];
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
    A{end+1} = S;
end


num_t = zeros(6,25,2);
t = -15:45;
t = t/30;
figure;
hold on
for region = 1:14
    region
    num_t = zeros(6,25,2);%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for cls = [1 4]
        subplot(2,14,(cls>1)*14+mod(region-1,14)+1)
        hold on
        P_all = cell(1,size(A{1,1},2));
        for animal = 1:size(A,2)
            AnimalID = AnimalList{animal,1};
            M = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\region_mask.mat'));
            region_mask = M.region_mask;
            %region_mask = cat(3,region_mask,(sum(region_mask,3)>0));
            if sum(region_mask(:,:,region),'all') ~= 0
                for i = 1:size(A{1,animal},2)
                    num_before = size(P_all{1,i},1);
                    P_all{1,i} = cat(1,P_all{1,i},mean(permute(sum(A{1,animal}{1,i}{1,cls}.*(repmat(region_mask(:,:,region),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])),[1 2])./sum(repmat(region_mask(:,:,region),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])>0,[1 2]),[4 3 1 2]),[1]));
                    num_after = size(P_all{1,i},1);
                    num_t(animal,i,(cls>1)+1) = size(permute(sum(A{1,animal}{1,i}{1,cls}.*(repmat(region_mask(:,:,region),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])),[1 2])./sum(repmat(region_mask(:,:,region),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])>0,[1 2]),[4 3 1 2]),1);
                end
            end
        end

        y_pre = [];
        for i = [1 5]
            tt = zeros(size(P_all{1,1},1),1);
            num_tt = num_t(:,:,(cls>1)+1);
            num_tt(~any(num_tt,2),:) = [];
            y = P_all{1,ceil((i-1)*5+1)}.*num_tt(:,ceil((i-1)*5+1));%%%%%%%%%%%%%
            tt = tt + num_tt(:,ceil((i-1)*5+1));
            if size(y,1) >= 0 %%%%%%%%%%%%%
                for j = ceil((i-1)*5+2):ceil(i*5)
                    y = cat(3,y,P_all{1,j}.*num_tt(:,j));
                    tt = tt + num_tt(:,j);
                end
                y = nansum(y,[3])./tt;
                yy = y;
                yy(isnan(yy)) = [];
                N = size(yy,1);
                yMean = nanmean(y);
                ySEM = nanstd(y)/sqrt(N);
                CI95 = tinv([0.025 0.975], N-1);
                yCI95 = bsxfun(@times, ySEM, CI95(:));
                for each = 1:size(y,1)
                    %plot(t,y(each,:),Color = color(i,:),LineWidth=0.25,LineStyle="-.");
                end
                %patch([t fliplr(t)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], color(i,:), 'EdgeColor','none', 'FaceAlpha',0.25);
                %plot(t,yMean,Color = color(i,:),LineWidth=0.75);
                xticks([]);
                yticks([]);
                xline(0,"Color",[0.5 0.5 0.5],"LineStyle",":")
                xline(0.33334,"Color",[0.5 0.5 0.5],"LineStyle",":")
                xline(1,"Color",[0.5 0.5 0.5],"LineStyle",":")
                ylim([-0.01 0.01])
                %ylim([-0.05 0.05])
                xlim([-0.5 1.5]);
                if size(y_pre,1) ~= 0
                    y_sub = y - y_pre;
                    %y_sub = medfilt2(y_sub,[1 5]);
                    %de_sub = y_sub;
                    de_sub = (cat(2,y_sub(:,2:end),y_sub(:,end)) - cat(2,y_sub(:,1),y_sub(:,1:end-1)))./cat(2,[1],2*ones(1,size(y_sub,2)-2),[1]);
                    de_sub = medfilt2(de_sub,[1 5]);
                    p_res = [];
                    for fm = 1:size(de_sub,2)
                        h = kstest(de_sub(:,fm));
                        if h == 0
                            [h,p] = ttest(de_sub(:,fm));
                        else
                            p = ranksum(de_sub(:,fm));
                        end
                        p_res(end+1) = p;
                        if p <= 0.05
                            if mean(de_sub(:,fm)) > 0
                                plot([(fm-16)/30;(fm-16)/30],[-0.01;-p/5],Color = [1 0 0],LineWidth=0.5)
                                %plot([(fm-16)/30;(fm-16)/30],[-0.05;-p],Color = [1 0 0],LineWidth=0.5)
                            else
                                plot([(fm-16)/30;(fm-16)/30],[p/5;0.01],Color = [1 0 0],LineWidth=0.5)
                                %plot([(fm-16)/30;(fm-16)/30],[p;0.05],Color = [1 0 0],LineWidth=0.5)
                            end
                        end
                    end
                    for each = 1:size(y,1)
                        plot(t(1,1:end),de_sub(each,:),Color = color(2,:),LineWidth=0.25,LineStyle="-.");
                    end
                    plot(t(1,1:end),nanmean(de_sub),Color = color(1,:),LineWidth=0.75);
                    %plot(t(1,1:end),p_res,Color = [1 0 0],LineWidth=1);
                else
                    y_pre = y;
                end
            end
        end
        hold off
    end
end
hold off