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
%%
categ = [1 2 3 31 32 33];
rng('default')
d = 5:29;
stage = zeros(size(d,2),1);
for i = 1:size(d,2)
    stage(i,1) = 20221200 + d(i);
end
I_all = cell(0);
A = cell(0);
TS = cell(0);
a_size = [0];
for animal = 10:13
    AnimalID = AnimalList{animal,1};
    path = fullfile("X:\Mingxuan\WF\data",AnimalID);


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
    I = load(fullfile(path,'COMBINED\combined_stage\FRA_contour.mat'));
    I = I.C;
    I(I<1)=0;
    I_fill = imfill(I(:,:,1),'holes');
    I_fill = imresize(I_fill,[size(CCC{1,1},1),size(CCC{1,1},2)]);
    I_fill = I_fill > 0.5;
    M = load(fullfile(path,'ana\region_mask.mat'));
    region_mask = M.region_mask;
    region_mask = imresize(region_mask,size(I_fill));
    region_mask(region_mask>0.5) = 1;
    region_mask(region_mask<1) = 0;
    if AnimalID == '080500020A05'
        I_fill(end-2:end,:) = zeros(size(I_fill(end-2:end,:)));
        I_fill(1:4,:) = zeros(size(I_fill(1:4,:)));
        I_fill(:,1:4) = zeros(size(I_fill(:,1:4)));
        I_fill(:,end-3:end) = zeros(size(I_fill(:,end-3:end)));
    end
    I_all{end+1} = (sum(region_mask,3)>0);
    A{end+1} = S;
end
d = cat(2,3:7,9:10,12:28,101);
stage = zeros(size(d,2),1);
for i = 1:size(d,2)
    stage(i,1) = 20230200 + d(i);
end
for animal = 14:15
    AnimalID = AnimalList{animal,1};
    path = fullfile("X:\Mingxuan\WF\data",AnimalID);


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
    I = load(fullfile(path,'COMBINED\combined_stage\FRA_contour.mat'));
    I = I.C;
    I(I<1)=0;
    I_fill = imfill(I(:,:,1),'holes');
    I_fill = imresize(I_fill,[size(CCC{1,1},1),size(CCC{1,1},2)]);
    I_fill = I_fill > 0.5;
    M = load(fullfile(path,'ana\region_mask.mat'));
    region_mask = M.region_mask;
    region_mask = imresize(region_mask,size(I_fill));
    region_mask(region_mask>0.5) = 1;
    region_mask(region_mask<1) = 0;
    if AnimalID == '080500020A05'
        I_fill(end-2:end,:) = zeros(size(I_fill(end-2:end,:)));
        I_fill(1:4,:) = zeros(size(I_fill(1:4,:)));
        I_fill(:,1:4) = zeros(size(I_fill(:,1:4)));
        I_fill(:,end-3:end) = zeros(size(I_fill(:,end-3:end)));
    end
    I_all{end+1} = (sum(region_mask,3)>0);
    A{end+1} = S;
end
k = 10;
M = zeros(0,size(S{1,1}{1,1},3));
I = [];
for animal = 1:size(A,2)
    for stage = 1:25
        for catg = [1 4]
            I_temp = I_all{1,animal};
            I_temp = reshape(I_temp,[size(I_temp,1)*size(I_temp,2) 1]);
            I = cat(1,I,I_temp);
            temp_sub = A{1,animal}{1,stage}{1,catg};
            P = reshape(temp_sub,[(size(temp_sub,1)*size(temp_sub,2)) size(temp_sub,3) size(temp_sub,4)]);
            M_temp = mean(P,3);
            %PP = permute(P,[1 3 2]);
            %M = reshape(PP,[size(P,1)*size(P,3) size(P,2)]);
            M = cat(1,M,M_temp);
        end
    end
    a_size(end+1) = size(M,1);
    TS{end+1} = temp_sub;
end

    
STD = std(M(:,1:15).');
AVG = mean(M(:,1:15).');
M_max = max(M(:,1:45),[],2);
M_min = min(M(:,1:45),[],2);
%Z = M(:,16:45);
Z = (M(:,16:45)./(M_max - M_min)).*(mean(((M(:,16:45) - AVG.')./(STD.')),[2])>3);% + (M(:,16:45)./(max(M_max,[],"all") - min(M_min,[],"all"))).*(mean(((M(:,16:45) - AVG.')./(STD.')),[2])<=3);
%Z = (M(:,16:45) - AVG.')./(STD.');
%Z = Z./(max(Z,[],2)-min(Z,[],2));
target = I > 0;
Z = Z(target,:);

idx = zeros(size(M,1),1);
[coeff,score,latent,tsquared,explained,mu] = pca(Z);
N = Z*coeff;
[idx_sub,C,sumd] = kmeans(N(:,1:5),k,'MaxIter',10000);
idx(target) = idx_sub;

categ = cell(1,k);
for i = 1:k
    categ{1,i} = zeros(0,size(M,2));
end
for i = 1:size(idx,1)
    if ~isnan(idx(i))
        if idx(i) > 0
            temp = categ{1,idx(i)};
            temp(end+1,:) = M(i,:);
            categ{1,idx(i)} = temp;
        end
    end
end

color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56];[0 0 0];[127 127 127]];
%color_idx = [1 3 5 7 9 2 4 6 8 10];
%color_idx = [2 6 10 3 5 7 8 9 1 4];
%color_idx = [9 4 2 5 7 10 8 3 1 6];
color_idx = [1 2 3 4 5 6 7 8 9 10 11 12];
%color_idx = [3 8 7 2 4 9 5 10 1 6];
%color_idx = [5 6 10 4 2 3 9 1 8 7];
%color_idx = [4 12 3 9 10 8 5 11 2 6 7 1];
color_idx = [2 10 7 6 4 1 9 5 3 8];
color = color(color_idx,:)/255;
%color = cat(1,color,color);

%figure;
%hold on
for i = 1:size(idx_sub,1)
    if ~isnan(idx_sub(i))
        if idx_sub(i) > 0
            %plot(N(i,1), N(i,2),'.', Color=color(idx_sub(i),:));
        end
    end
end
%hold off

%figure;
%hold on
for i = 1:size(idx_sub,1)
    if ~isnan(idx_sub(i))
        if idx_sub(i) == 1
            %plot(Z(i,:), Color=color(idx_sub(i),:));
        end
    end
end
%hold off

t = -15:45;
t = t/30;
figure;
hold on
for i = 1:k
    y = categ{1,i};
    yMean = mean(y);
    number = size(y,1);
    ySEM = std(y)/sqrt(number);
    CI95 = tinv([0.025 0.975], number-1);
    yCI95 = bsxfun(@times, ySEM, CI95(:));
    patch([t fliplr(t)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], color(i,:), 'EdgeColor','none', 'FaceAlpha',0.25);
    %patch([t fliplr(t)], [yMean-std(y) fliplr(yMean+std(y))], color(i,:), 'EdgeColor','none', 'FaceAlpha',0.25);
    plot(t,mean(y),Color = color(i,:));
    %plot(mean(categ{1,i}), Color=color(i,:));
end
hold off
xlabel('Time (s)')
ylabel('dff');

m_idxp = cell(1,6);
for animal = 1:size(A,2)
    idxp = zeros(a_size(animal+1)-a_size(animal),1);
    clear distribution
    temp_sub = TS{1,animal};
    distribution = zeros(size(temp_sub,1),size(temp_sub,2),3);
    for i = a_size(animal)+1:a_size(animal+1)
        pi = i - a_size(animal);
        if ~isnan(idx(i))
            if idx(i) > 0
                idxp(pi) = idx(i);
                distribution(size(temp_sub,1)*mod(floor((pi-1)/(size(temp_sub,1)*size(temp_sub,2))),2)+mod((pi-1),size(temp_sub,1))+1,floor((pi-1)/size(temp_sub,1))+1-size(temp_sub,2)*ceil((pi-size(temp_sub,1)*size(temp_sub,2))/(2*size(temp_sub,1)*size(temp_sub,2))),:) = reshape(color(idx(i),:),[1 1 3]);
            end
        end
    end
    figure;
    imshow(imresize(distribution,10));
    idxp(target(a_size(animal)+1:a_size(animal+1),1) == 0) = [];
    m_idxp{1,animal} = idxp;
end


x = Z.';
% Create a Self-Organizing Map
dimension1 = 2;
dimension2 = 2;
%net = selforgmap([dimension1 dimension2]);

% Train the Network
%[net,tr] = train(net,x);

% Test the Network
%y = net(x);

%classes = vec2ind(y);
