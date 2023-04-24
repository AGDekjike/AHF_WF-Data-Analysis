AnimalList = {'080500026C63' [23 7 223 186];
              '080500020A05' [20 25 219 199];
              '08050002242B' [21 4 220 183];
              '08050000D7DA' [34 8 233 192];
              '210805001438' [22 6 226 195];
              '210805007854' [36 7 235 191];
              '007DA64A57C6' [25 9 229 193];
              '210531013C28' [32 12 231 196];
              '21053101283C' [21 13 225 197]};
idx = 8;
path = fullfile("X:\Mingxuan\WF\data",AnimalList{idx,1},'COMBINED');
m = imread(fullfile('X:\Mingxuan\WF\data',AnimalList{idx,1},'avg\m.png'));
m = double(m(AnimalList{idx,2}(1):AnimalList{idx,2}(3),AnimalList{idx,2}(2):AnimalList{idx,2}(4)));
m = m/255;
I = load(fullfile(path,'combined_stage\FRA_contour.mat'));
I = I.C;
I(I<1)=0;
Z = repmat(m,1,1,3);
m = repmat(m,1,1,3);
C = cell(0);
list = 10;
list2 = [1];
for i = 1:size(list,2)
    C_temp = load(fullfile("X:\Mingxuan\WF\data",AnimalList{idx,1},'COMBINED',strcat('combined_stage\mask\loc',string(list(i)),'.mat')));
    C{list(i)} = C_temp.C;
    if i == 3
        %Z(:,:,i) = Z(:,:,i)+0.8*C{list(i)};
    else
        %Z(:,:,i) = Z(:,:,i)+0.5*C{list(i)};
    end
    m(:,:,3) = m(:,:,3)+0.5*C{list(i)};
end

for i = 1:size(list2,2)
    C_temp = load(fullfile("X:\Mingxuan\WF\data",AnimalList{idx,1},'COMBINED',strcat('combined_stage\mask\loc',string(list2(i)),'.mat')));
    C{list2(i)} = C_temp.C;
    if i == 3
        %Z(:,:,i) = Z(:,:,i)+0.8*C{list(i)};
    else
        %Z(:,:,i) = Z(:,:,i)+0.5*C{list(i)};
    end
    %m(:,:,1) = m(:,:,1)+0.5*C{list2(i)};
end


m = fliplr(rot90(m));
Z = fliplr(rot90(Z));
m(:,:,2) = m(:,:,2).*(I(:,:,2)==0)+I(:,:,2);
m(:,:,1) = m(:,:,1).*(I(:,:,1)==0)+I(:,:,1);
Z(:,:,1) = Z(:,:,1).*(I(:,:,1)==0)+I(:,:,1);
Z(:,:,2) = Z(:,:,2).*(I(:,:,2)==0)+I(:,:,2);
figure;
imshow(m);