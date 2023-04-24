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

sub = -ones(size(A,2),15,6,5);

for animal = 1:size(A,2)
    AnimalID = AnimalList{animal,1}
    M = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\region_mask.mat'));
    region_mask = M.region_mask;
    region_mask = cat(3,region_mask,(sum(region_mask,3)>0));
    for region = 1:15
        if sum(region_mask(:,:,region),'all') ~= 0
            for cls = [1 2 3 4 5 6]
                P = zeros(size(A{1,animal},2),61);
                P_all = cell(1,size(A{1,animal},2));
                for i = 1:size(A{1,animal},2)
                    P(i,:) = sum(A{1,animal}{1,i}{1,cls}.*(repmat(region_mask(:,:,region),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])),[1 2 4])./sum(repmat(region_mask(:,:,region),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])>0,[1 2 4]);
                    P_all{1,i} = permute(sum(A{1,animal}{1,i}{1,cls}.*(repmat(region_mask(:,:,region),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])),[1 2])./sum(repmat(region_mask(:,:,region),[1 1 size(A{1,animal}{1,i}{1,cls},3) size(A{1,animal}{1,i}{1,cls},4)])>0,[1 2]),[4 3 1 2]);
                end
                for i = 1:5
                    if i == 1
                        y_base = P_all{1,ceil((i-1)*5+1)};%%%%%%
                        for j = ceil((i-1)*5+2):ceil(i*5)
                            y_base = cat(1,y_base,P_all{1,j});
                        end
                        y_base_mean = mean(y_base,1);
                    else
                        y = P_all{1,ceil((i-1)*5+1)};%%%%%%%%%%%%%
                        if size(y,1) >= 0 %%%%%%%%%%%%%
                            for j = ceil((i-1)*5+2):ceil(i*5)
                                y = cat(1,y,P_all{1,j});
                            end
                            y_mean = mean(y,1);
                            sub(animal,region,cls,i) = sum((y_mean(interval)-y_base_mean(interval)),"all");
                        end
                        %y_base_mean = y_mean;
                    end
                end
            end
        end
    end
end
p = [];
cls = [1 4];
x = 1:5;
figure
hold on
for region = 1:15
    y = [];
    subplot(3,5,region)
    hold on
    for animal = 1:size(A,2)
        y(end+1,:) = permute(mean(sub(animal,region,cls(1:2),1:5),[3]),[1 4 2 3]);%/(interval(1,end)-interval(1,1)+1);
    end
    y(y==-1) = nan;
    y = y/(interval(1,end)-interval(1,1)+1);
    yy = y;
    yy(isnan(yy)) = [];
    N = size(yy,1);
    DF = N - 1;
    y(:,1) = 0;
    yMean = nanmean(y,1);
    ySEM = nanstd(y,1)/sqrt(N);
    CI95 = tinv([0.025 0.975], N-1);
    yCI95 = bsxfun(@times, ySEM, CI95(:));
    %patch([x fliplr(x)], [yMean-ySEM fliplr(yMean+ySEM)], [0 0 1], 'EdgeColor','none', 'FaceAlpha',0.25);
    plot(x,yMean./ySEM,'Color',[0 0 1])
    
    y = [];
    for animal = 1:size(A,2)
        y(end+1,:) = permute(mean(sub(animal,region,cls(2),1:5),[3]),[1 4 2 3]);%/(interval(1,end)-interval(1,1)+1);
    end
    y(y==-1) = nan;
    y = y/(interval(1,end)-interval(1,1)+1);
    yy = y;
    yy(isnan(yy)) = [];
    N = size(yy,1);
    DF = N - 1;
    y(:,1) = 0;
    yMean = nanmean(y,1);
    ySEM = nanstd(y,1)/sqrt(N);
    CI95 = tinv([0.025 0.975], N-1);
    yCI95 = bsxfun(@times, ySEM, CI95(:));
    %patch([x fliplr(x)], [yMean-ySEM fliplr(yMean+ySEM)], [1 0 0], 'EdgeColor','none', 'FaceAlpha',0.25);
    plot(x,yMean./ySEM,'Color',[1 0 0])

    hold off
    %ylim([-0.015 0.02])
    yline(0);
    xlim([1 5]);
end
hold off