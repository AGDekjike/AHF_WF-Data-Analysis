AnimalList = {'080500026C63' [23 7 223 186];
              '080500020A05' [20 25 219 199];
              '08050002242B' [21 4 220 183];
              '08050000D7DA' [34 8 233 192];
              '210805001438' [22 6 226 195];
              '210805007854' [36 7 235 191];
              '007DA64A57C6' [25 9 229 193];
              '210531013C28' [32 12 231 196];
              '21053101283C' [21 13 225 197]};
idx = 7;
path = fullfile("X:\Mingxuan\WF\data",AnimalList{idx,1},'COMBINED');
if ~exist(fullfile(path,'combined_stage\mask'), 'dir')
   mkdir(fullfile(path,'combined_stage\mask'));
end

m = imread(fullfile('X:\Mingxuan\WF\data',AnimalList{idx,1},'avg\m.png'));
m = double(m(AnimalList{idx,2}(1):AnimalList{idx,2}(3),AnimalList{idx,2}(2):AnimalList{idx,2}(4)));
m = m/255;


path = fullfile('X:\Mingxuan\WF\data',AnimalList{idx,1},'COMBINED\combined_stage');
data_temp = load(fullfile(path,strcat('stage1','.mat')));
data = data_temp.data_dff;
data_stat = data_temp.data_stat;
dff_lf_all = (data{1,11}*data_stat(1,11)+data{2,11}*data_stat(2,11)+data{3,11}*data_stat(3,11))/(sum(data_stat(:,11)));
baseline_std = std(dff_lf_all(:,:,:),[],3);
z = (dff_lf_all-mean(dff_lf_all(:,:,1:30),3))./baseline_std;
sound_mean = mean(baseline_std(:,:,:),3);
sound_mean = imgaussfilt(sound_mean,3);
Max = max(sound_mean,[],"all");
sound_mean(sound_mean<Max*0.08) = 0;
%sound_mean(sound_mean>Max*0.7) = 0;
sound_mean(sound_mean~=0) = 1;
%sound_mean = imgaussfilt(sound_mean,1);
J = sound_mean;
cc = bwconncomp(J);
for i = 1:size(cc.PixelIdxList,2)
    if (i-4)*(i-0) ~= 0
        %J(cc.PixelIdxList{i})=0;
    end
end
p = zeros(2,0);
for i = 1:size(J,1)
    for j = 1:size(J,2)
        if J(i,j) == 1
            J(i,j) = 0.5;
            p(:,end+1) = [i;j];
        end
    end
end
k = convhull(p(1,:),p(2,:));
d = zeros(1,size(k,1)*2);
for i = 1:size(k,1)
    d(2*i-1:2*i) = [p(2,k(i)) p(1,k(i))];
end
C = zeros(size(J));
C = insertShape(C,"FilledPolygon",d,'Color','white');
C = mean(C,3);
C(C>0) = 1;
C(C<1) = 0;

figure;
imshow(fliplr(rot90(m+J)));
%imshow(C)
save(fullfile('X:\Mingxuan\WF\data',AnimalList{idx,1},'COMBINED\combined_stage\mask\loc16.mat'),"C");

%%