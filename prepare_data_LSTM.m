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
              '080500020A05' [44 10 228 179];
              '210805001438' [20 17 234 181];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};
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
mask_all = cell(0);
A = cell(0);
TS = cell(0);
a_size = [0];
for animal = 10:13
    AnimalID = AnimalList{animal,1};
    path = fullfile("X:\Mingxuan\WF\data",AnimalID);

    M = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\region_mask.mat'));
    region_mask = M.region_mask;
    region_mask = cat(3,region_mask,(sum(region_mask,3)>0));
    mask_all{end+1} = region_mask;

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
                true_wrong = true_wrong < 0; %true_wrong < 0 for wrong trials!!!!!!!!!!!!!!!!!!!!!!!!!!
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
    I_all{end+1} = I_fill;
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

    M = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\region_mask.mat'));
    region_mask = M.region_mask;
    region_mask = cat(3,region_mask,(sum(region_mask,3)>0));
    mask_all{end+1} = region_mask;

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
                true_wrong = true_wrong < 0; %true_wrong < 0 for wrong trials!!!!!!!!!!!!!!!!!!!!!!!!!!
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
    I_all{end+1} = I_fill;
    A{end+1} = S;
end


for animal = 1:size(A,2)
    mask_temp = mask_all{1,animal};
    mask_temp = reshape(mask_temp,[size(mask_temp,1)*size(mask_temp,2) size(mask_temp,3)]);
    for stage = 1:5
        path = fullfile("X:\Mingxuan\WF\data",AnimalList{animal+9,1});
        k = 4;
        %M = zeros(0,size(S{1,1}{1,1},3));
        outcome = zeros(0,0);
        %I = [];
        sequence = cell(1,size(mask_temp,2));
        label = [];
        for day = (stage-1)*5+1:stage*5
            for catg = [1 2 3 4 5 6]
                %I_temp = I_all{1,animal};
                %I_temp = reshape(I_temp,[size(I_temp,1)*size(I_temp,2) 1]);

                temp_sub = A{1,animal}{1,day}{1,catg}(:,:,:,:);
                P = reshape(temp_sub,[(size(temp_sub,1)*size(temp_sub,2)) size(temp_sub,3) size(temp_sub,4)]);
                for mask = 1:size(mask_temp,2)
                    seq_temp = reshape(permute(P,[3 1 2]),[size(P,3) size(P,1) size(P,2)]);
                    seq_temp = seq_temp( :,mask_temp(:,mask)==1,:); %middle I_temp==1 for AC
                    if sum(seq_temp,'all') ~= 0
                        sequence{1,mask} = cat(1,sequence{1,mask},seq_temp);
                        if mask == 1
                            label = cat(1,label,repmat(catg,[size(temp_sub,4) 1]));
                        end
                    end
                end
                %M_temp = reshape(permute(P,[1 3 2]),[size(temp_sub,1)*size(temp_sub,2)*size(temp_sub,4) size(temp_sub,3)]);
                %PP = permute(P,[1 3 2]);
                %M = reshape(PP,[size(P,1)*size(P,3) size(P,2)]);
                %M = cat(1,M,M_temp);
                %I = cat(1,I,repmat(I_temp,[size(temp_sub,4) 1]));
                %outcome = cat(1,outcome,repmat(catg,[size(M_temp,1) 1]));
            end
        end
        %a_size(end+1) = size(M,1);
        %TS{end+1} = temp_sub;
        save(fullfile(path,strcat('ana\sequence_allregions',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')),'sequence');
        save(fullfile(path,strcat('ana\label_allregions',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')),'label');
    end
end