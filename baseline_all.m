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
AnimalID = AnimalList{end-5,1};
path = fullfile("X:\Mingxuan\WF\data",AnimalID);
if ~exist(fullfile(path,'combined_stage'), 'dir')
   mkdir(fullfile(path,'combined_stage'));
end
%%
color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56]];
color_idx = [9 7 5 3 1 10 8 6 4 2];
color = color(color_idx,:)/255;
c = 1:8;
categ = [1 2 3 31 32 33];

%d = cat(2,3:7,9:10,12:28,101);
d = 5:29;
stage = zeros(size(d,2),1);
for i = 1:size(d,2)
    stage(i,1) = 20221200 + d(i);
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

cls = 4;
Baseline = S{1,1}{1,cls};
for i = 2:5
    Baseline = cat(4,Baseline,S{1,i}{1,cls});
end
Baseline = mean(Baseline,4);

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