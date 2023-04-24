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

interval = 16:25;
xcorr_matrix = zeros(size(A,2),5,2,14,14);
for animal = 1:size(A,2)
    AnimalID = AnimalList{animal,1};
    animal
    figure
    M = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\region_mask.mat'));
    region_mask = M.region_mask;
    for stage = 1:5
        stage
        for cls = [1 4]
            for region_1 = 1:14
                if sum(region_mask(:,:,region_1),'all') ~= 0
                    for region_2 = 1:14
                        if sum(region_mask(:,:,region_2),'all') ~= 0
                            X = [];
                            Y = X;
                            for i = (stage-1)*5+1:stage*5
                                X = cat(1,X,permute(sum(A{1,animal}{1,i}{1,cls}.*(repmat(region_mask(:,:,region_1),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])),[1 2])./sum(repmat(region_mask(:,:,region_1),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])>0,[1 2]),[4 3 1 2]));
                                Y = cat(1,Y,permute(sum(A{1,animal}{1,i}{1,cls}.*(repmat(region_mask(:,:,region_2),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])),[1 2])./sum(repmat(region_mask(:,:,region_2),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])>0,[1 2]),[4 3 1 2]));
                            end
                            x = mean(X(:,interval),1);
                            y = mean(Y(:,interval),1);
                            %x = medfilt1(x,5);%%%%%%%%%%%%%%%%%filter!!!!!!!!!!!!!!!!!!!!!!
                            %y = medfilt1(y,5);%%%%%%%%%%%%%%%%%filter!!!!!!!!!!!!!!!!!!!!!!
                            [r,p] = corrcoef(x,y);
                            xcorr_matrix(animal,stage,(cls>1)+1,region_1,region_2) = r(1,2)^2;%xcorr(x/max([x y],[],"all"),y/max([x y],[],"all"),0)/(size(interval,2));
                        end
                    end
                end
            end
            subplot(2,5,(cls>1)*5+stage)
            heatmap(permute(xcorr_matrix(animal,stage,(cls>1)+1,:,:),[4 5 1 2 3]),'Colormap',hot,'GridVisible','off','ColorLimits',[0 1])
        end
    end
end

figure
for stage = 1:5
    for cls = [1 4]
        rs_matrix = permute(xcorr_matrix(:,stage,(cls>1)+1,:,:),[4 5 1 2 3]);
        rs_matrix(rs_matrix==0) = nan;
        avg_matrix = nanmean(rs_matrix,3);
        subplot(2,5,(cls>1)*5+stage)
        heatmap(avg_matrix,'Colormap',hot,'GridVisible','off','ColorLimits',[0.75 1])
    end
end

p_img = zeros(14*2+1,14*5+4,3);
figure;
for stage = 1:5
    for cls = [1 4]
        p_matrix = zeros(14,14,2);
        for region_1 = 1:14
            for region_2 = 1:14
                y = permute(xcorr_matrix(:,[max(3,stage-100) stage],(cls>1)+1,region_1,region_2),[1 2 3 4 5]);
                y(y==0) = nan;
                %y(any(isnan(y), 2), :) = [];
                h0 = kstest(y(:,1));
                h = kstest(y(:,2));
                if (h0 + h) == 0
                    [~,p] = ttest(y(:,2),y(:,1));
                else
                    p = ranksum(y(:,2),y(:,1));
                end
                if isnan(p)
                    p = 1;
                end
                if p < 0.05
                    p_matrix(region_1,region_2,(cls>1)+1) = 1-5*p;
                    if  nanmean(y(:,2),"all") >  nanmean(y(:,1),"all")
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,1) = 1-10*p;
                    else
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,3) = 1-10*p;
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,2) = (1-10*p)/2;
                    end
                end
                if region_1 > region_2
                    p_matrix(region_1,region_2,(cls>1)+1) = nanmean(y(:,2),"all");
                    if (nanmean(y(:,2),"all")-0.7)/0.3 > 2/3
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,3) = (nanmean(y(:,2),"all")-0.7)/0.1-2;
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,2) = 1;
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,1) = 1;
                    elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 1/3
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,2) = (nanmean(y(:,2),"all")-0.7)/0.1-1;
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,1) = 1;
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,3) = 0;
                    elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 0
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,1) = (nanmean(y(:,2),"all")-0.7)/0.1;
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,2) = 0;
                        p_img((cls>1)*15+region_1,(stage-1)*15+region_2,3) = 0;
                    end
                end
            end
        end
        p_matrix(isnan(p_matrix)) = 1;
        subplot(2,5,(cls>1)*5+stage)
        heatmap(p_matrix(:,:,(cls>1)+1),'Colormap',hot,'GridVisible','off','ColorLimits',[0.7 1])
    end
end

p_img(15,:,:) = 1;
for i = 1:4
    p_img(:,15*i,:) = 1;
end
figure;
imshow(p_img)
%p = kruskalwallis(y,{'1','2','3','4','5'},"off");