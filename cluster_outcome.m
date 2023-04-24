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
              '080500020A05' [44 10 228 179]};
range = [202212050000 202212299999];
%%
rng('default');
categ = [1 2 3 31 32 33];
d = 5:29;
stage = zeros(size(d,2),1);
for i = 1:size(d,2)
    stage(i,1) = 20221200 + d(i);
end
I_all = cell(0);
A = cell(0);
TS = cell(0);
a_size = [0];
for animal = 10%:12
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
            if rst == -1
                true_wrong = sti(7,:).*sti(8,:);
                true_wrong = true_wrong < 0;
            else
                true_wrong = ones(size(rst_m));
            end
            rst_m(rst_m~=rst)=-99;
            rst_m(rst_m~=-99)=1;
            rst_m(rst_m~=1)=0;
            cg = rst_m.*fq_m.*true_wrong;
    
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
    if AnimalID == '080500020A05'
        I_fill(end-2:end,:) = zeros(size(I_fill(end-2:end,:)));
        I_fill(1:4,:) = zeros(size(I_fill(1:4,:)));
        I_fill(:,1:4) = zeros(size(I_fill(:,1:4)));
        I_fill(:,end-3:end) = zeros(size(I_fill(:,end-3:end)));
    end
    I_all{end+1} = I_fill;
    A{end+1} = S;
end
k = 4;
M = zeros(0,size(S{1,1}{1,1},3));
outcome = zeros(0,0);
I = [];
sequence = [];
label = [];
for animal = 1:size(A,2)
    for stage = 1:25
        for catg = [1 3 4 6]
            I_temp = I_all{1,animal};
            I_temp = reshape(I_temp,[size(I_temp,1)*size(I_temp,2) 1]);
            temp_sub = A{1,animal}{1,stage}{1,catg};
            P = reshape(temp_sub,[(size(temp_sub,1)*size(temp_sub,2)) size(temp_sub,3) size(temp_sub,4)]);
            seq_temp = permute(P,[3 1 2]).*repmat(I_temp.',[size(temp_sub,4) 1 size(temp_sub,3)]);
            seq_temp( :, all( ~any( temp_sub ),[1 3]),:) = [];
            M_temp = reshape(permute(P,[1 3 2]),[size(temp_sub,1)*size(temp_sub,2)*size(temp_sub,4) size(temp_sub,3)]);
            %PP = permute(P,[1 3 2]);
            %M = reshape(PP,[size(P,1)*size(P,3) size(P,2)]);
            M = cat(1,M,M_temp);
            I = cat(1,I,repmat(I_temp,[size(temp_sub,4) 1]));
            outcome = cat(1,outcome,repmat(catg,[size(M_temp,1) 1]));
            label = cat(1,label,repmat(catg,[size(temp_sub,4) 1]));
            sequence = cat(1,sequence,seq_temp);
        end
    end
    a_size(end+1) = size(M,1);
    TS{end+1} = temp_sub;
end

    
STD = std(M(:,1:15).');
AVG = mean(M(:,1:15).');
M_max = max(M,[],2);
M_min = min(M,[],2);
Z = M./(M_max - M_min);
%Z = (M - AVG.')./(STD.');
%Z = Z./(max(Z,[],2)-min(Z,[],2));
target = I > 0;
Z = Z(target,1:25);

idx = zeros(size(M,1),1);
N_all = zeros(size(M,1),size(Z,2));
[coeff,score,latent,tsquared,explained,mu] = pca(Z);
N = Z*coeff;
%[idx_sub,C,sumd] = kmeans(N(:,1:5),k,'MaxIter',10000);
idx(target) = idx_sub;
N_all(target,:) = N;
figure;
hold on
for i = 1:size(N_all,1)
    if ~isnan(N_all(i,1)) && sum(N_all(i,:),"all") ~= 0
        if outcome(i) ~= 0
            %plot(N_all(i,1),N_all(i,2),'.',"Color",color_outcome(outcome(i),:))
        end
    end
end
hold off

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

color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56]];
%color_idx = [1 3 5 7 9 2 4 6 8 10];
%color_idx = [2 6 10 3 5 7 8 9 1 4];
%color_idx = [9 4 2 5 7 10 8 3 1 6];
color_idx = [10 2 1 6 5 4 7 8 9 10];
color_outcome_idx = [10 2 1 6 4 4 6 8 9 10];
color_outcome = color(color_outcome_idx,:)/255;
color = color(color_idx,:)/255;
color = cat(1,color,color);

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
for i = 1:size(idx,1)
    if ~isnan(idx(i))
        if idx(i) > 0
            %plot(M(i,:), Color=color(idx(i),:));
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
    plot(t,mean(y),Color = color(i,:));
    %plot(mean(categ{1,i}), Color=color(i,:));
end
hold off
xlabel('Time (s)')
ylabel('dff');


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
