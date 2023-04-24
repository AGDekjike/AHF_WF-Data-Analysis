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
color = {[1 0 0],[0 1 0],[0 0 1],[1 0.6 1],[1 0.6 1],[1 0.6 1],[1 0.6 1],[1 0.6 1]};
categ = [1 2 3 31 32 33];

d = 5:29;
stage = zeros(size(d,2),1);
for i = 1:size(d,2)
    stage(i,1) = 20221200 + d(i);
end

for ani = 5:-1:0
    AnimalID = AnimalList{end-ani,1};
    path = fullfile("X:\Mingxuan\WF\data",AnimalID);
    if ~exist(fullfile(path,'combined_stage'), 'dir')
       mkdir(fullfile(path,'combined_stage'));
    end

    if ani > 1
        d = 5:29;
        stage = zeros(size(d,2),1);
        for i = 1:size(d,2)
            stage(i,1) = 20221200 + d(i);
        end
    else
        d = cat(2,3:7,9:10,12:28,101);
        stage = zeros(size(d,2),1);
        for i = 1:size(d,2)
            stage(i,1) = 20230200 + d(i);
        end
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
    trend_matrix = ones(size(S{1,1}{1,1},1)*size(S,2),size(S{1,1}{1,1},2));
    for i = 1:size(S{1,1}{1,1},1)
        for j = 1:size(S{1,1}{1,1},2)
            P = zeros(size(S,2),25); % 25 fm
            for stage = 1:size(S,2)
                P(stage,:) = mean(S{1,stage}{1,1}(i,j,1:25,:),[1 2 4]);
            end
            sub_trend_matrix = trend_xc(P);
            trend_matrix((i-1)*size(S,2)+1:i*size(S,2),j) = sub_trend_matrix;
        end
    end
    save(fullfile(path,'ana/LF_25_trend_matrix_hrt.mat'),"trend_matrix")
    trend_matrix = ones(size(S{1,1}{1,1},1)*size(S,2),size(S{1,1}{1,1},2));
    for i = 1:size(S{1,1}{1,1},1)
        for j = 1:size(S{1,1}{1,1},2)
            P = zeros(size(S,2),25); % 25 fm
            for stage = 1:size(S,2)
                P(stage,:) = mean(S{1,stage}{1,4}(i,j,1:25,:),[1 2 4]);
            end
            sub_trend_matrix = trend_xc(P);
            trend_matrix((i-1)*size(S,2)+1:i*size(S,2),j) = sub_trend_matrix;
        end
    end
    save(fullfile(path,'ana/HF_25_trend_matrix_hrt.mat'),"trend_matrix")
end





function trend_matrix = trend_xc(P)
    trend_matrix = ones(size(P,1),1);
    for i = 1:size(trend_matrix,1)
        [~,half_rise_time] = max(P(i,16:25) >= 0.5*max(P(i,16:25),[],"all"));
        trend_matrix(i,1) = max(0,min(half_rise_time))/(max(P(i,16:25),[],"all") > 3*std(P(i,1:15),[],"all"));
    end
end
