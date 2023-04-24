id = '000C95238B31';
path = fullfile('X:\Mingxuan\WF\data',id,'avg');
sub_img = dir(path);
to_do_list = cell(0);
for i = 1:size(sub_img)
    sub_name = sub_img(i).name;
    if size(sub_name,2) == 23
        if str2num(strcat(sub_name(1:4),sub_name(6:7),sub_name(9:10))) >= 20220725
            to_do_list{end+1} = sub_name;
        end
    end
end
Shifts = cell(0,3);
if ~exist(fullfile(path,'Shiftsm.mat'), 'file')
   save(fullfile(path,'Shiftsm.mat'),'Shifts');
end
if ~exist(fullfile(path,'corrected'), 'dir')
   mkdir(fullfile(path,'corrected'));
end
Shifts = load(fullfile(path,'Shiftsm.mat'));
Shifts = Shifts.Shifts;
search_size = [-25 25 -20 20];
size(to_do_list,2)
for i = 1:size(to_do_list,2)
    i
    [min_tx,min_ty] = loc_shift(fullfile(path,'m.png'),fullfile(path,to_do_list{i}),search_size);
    name = to_do_list{i};
    Shifts{end+1,1} = name(1:19);
    Shifts{end,2} = min_tx;
    Shifts{end,3} = min_ty;
    [Img,ori,s] = load_image(fullfile(path,to_do_list{i}),0.3,min_tx,min_ty);
    imwrite(Img,fullfile(path,'corrected',strcat(string(to_do_list{i}),'.png')));
end
save(fullfile(path,'Shiftsm.mat'),'Shifts');
%% functions
function [Img,ori,s] = load_image(path,margin,tx,ty)
    img = imread(path);
    %cover = uint8(zeros(size(img)));
    %cover(int32(0.25*size(img,1)):int32(0.75*size(img,1)),int32(0.25*size(img,2)):int32(0.75*size(img,2))) = 1;
    img = histeq(img);
    %img = img.*cover;
    Img = uint8(zeros(int16((1+margin)*size(img,1)),int16((1+margin)*size(img,2))));
    Img(int16((margin/2)*size(img,1))+1+tx:int16((margin/2)*size(img,1))+tx+size(img,1),...
        int16((margin/2)*size(img,2))+1+ty:int16((margin/2)*size(img,2))+ty+size(img,2)) = img;
    ori = [int16((margin/2)*size(img,1))+1+tx int16((margin/2)*size(img,2))+1+ty];
    s = [size(img,1) size(img,2)];
end
function mean_dif = dif(Image_1_path,Image_2_path,tx,ty)
    margin = 0.3;
    [Img_1,ori_1,s_1] = load_image(Image_1_path,margin,0,0);
    Img_1 = imgaussfilt(Img_1,2);
    [Img_2,ori_2,s_2] = load_image(Image_2_path,margin,tx,ty);
    Img_2 = imgaussfilt(Img_2,2);
    dif = (Img_1-Img_2).^2;
    dif = dif(max(ori_1(1),ori_2(1)):max(ori_1(1),ori_2(1))+s_1(1)-abs(tx)-1,...
        max(ori_1(2),ori_2(2)):max(ori_1(2),ori_2(2))+s_1(2)-abs(ty)-1);
    mean_dif = mean(dif,"all");
end
function [min_tx,min_ty] = loc_shift(Image_mother_path,Image_path,search_size)
    min_dif = 9999;
    for i = search_size(1):search_size(2)
        for j = search_size(3):search_size(4)
            mean_dif = dif(Image_mother_path,Image_path,i,j);
            if mean_dif < min_dif
                min_dif = mean_dif;
                min_t = [i j];
            end
        end
    end
    min_tx = min_t(1);
    min_ty = min_t(2);
end