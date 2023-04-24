AnimalCenter = {'080500020A05' [28 17];
                '210805001438' [19 18];
                '000D2491CA72' [31 19];
                '000D24918830' [25 22];
                '000D2491EA52' [29 15];
                '000D249170C8' [26 16]};
color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56]];
color = 255*ones(10,3);
color = cat(1,color/255,color/255);
DFF_L = load_DFF(AnimalCenter,[1 0 0]);
DFF_H = load_DFF(AnimalCenter,[11 0 0]);

for i = 3
    region_mask = zeros(size(DFF_L{1,i},1),size(DFF_L{1,i},2),14);%A1L,H;A1;A2L,H;A2;AAFL,H;AAF;DM;DA;DP;DA(non);DP(non)
    %dff_map_L = medfilt2(DFF_L{1,i},[3 3]);
    %dff_map_H = medfilt2(DFF_H{1,i},[3 3]);
    kernel = [1/15 2/15 1/15;2/15 3/15 2/15;1/15 2/15 1/15];
    dff_map_L = conv2(DFF_L{1,i},kernel,"same");
    dff_map_H = conv2(DFF_H{1,i},kernel,"same");
    dff_locM_L = find_LocalMaxima(dff_map_L);
    dff_locM_H = find_LocalMaxima(dff_map_H);
    dff_ep_L = conv2(dff_locM_L,ones(1,1),"same");
    dff_c_L = dff_map_L.*(dff_ep_L>0).*(conv2((dff_ep_L<=0),ones(1,1),"same")<=0);
    dff_ep_H = conv2(dff_locM_H,ones(1,1),"same");
    dff_c_H = dff_map_H.*(dff_ep_H>0).*(conv2((dff_ep_H<=0),ones(1,1),"same")<=0);

    group_matrix_c_L = separate_Group(dff_c_L);
    group_matrix_c_H = separate_Group(dff_c_H);
    [group_matrix,c_value,num_L,num_H] = expand_Group(dff_map_L,dff_map_H,group_matrix_c_L,group_matrix_c_H,0.5);

    figure;
    heatmap(dff_c_H-dff_c_L,'Colormap',redblue,'GridVisible','off','ColorLimits',[-0.03 0.03]);
    figure;
    heatmap(dff_c_H,'Colormap',redblue,'GridVisible','off','ColorLimits',[-0.03 0.03]);



    group_img = ones(size(group_matrix,1),size(group_matrix,2),3);
    group_matrix = medfilt3(group_matrix,[3 3 1]); % remove single *
    for group = 1:size(group_matrix,3)
        %figure;
        %heatmap(group_matrix(:,:,group),'Colormap',redblue,'GridVisible','off');
        group_img = group_img.*(group_matrix(:,:,group)==0) + (group_matrix(:,:,group)>0).*repmat(reshape([group>num_L group/size(group_matrix,3) group<=num_L]*c_value(1,1,group)/max(c_value,[],'all'),[1 1 3]),[size(group_img,1) size(group_img,2) 1]);
    end

    group_idx = {[],[],[],[],[],[],[],[],[],[],[],[]};
    group_idx_non = {[],[]};

    group_idx = {[4 5 6],[14],[4 5 6 14],[3],[13],[3 13],[1],[9],[1 9],[11 12],[8],[10]}; % A72(i = 3)
    group_idx_non = {[1],[3]}; % A72(i = 3)

    %group_idx = {[3 5 6],[12],[3 5 6 12],[],[],[],[1],[],[1],[9 10],[8],[2 4]}; % A05(i = 1)
    %group_idx_non = {[1],[4]}; % A05(i = 1)

    %group_idx = {[4],[9],[4 9],[3],[8],[3 8],[6],[1],[6 1],[2],[],[5]}; % 438(i = 2)
    %group_idx_non = {[1],[2]}; % 438(i = 2)

    %group_idx = {[5 6],[9],[5 6 9],[],[],[],[3],[7],[3 7],[2 4],[1],[10]}; % 830
    %group_idx_non = {[1],[2]}; % 830

    %group_idx = {[4 5],[9],[4 5 9],[10],[],[10],[2],[],[2],[6],[7],[8]}; % A52
    %group_idx_non = {[],[1]}; % A52

    %group_idx = {[6],[13 15],[6 13 15],[4],[12],[4 12],[3],[9],[3 9],[10],[],[5 7 8]}; % 0C8
    %group_idx_non = {[2],[4]}; % 0C8
    
    for group = 1:size(group_idx,2)
        if size(group_idx{1,group},2) > 0
            mask = group_matrix(:,:,group_idx{1,group}(1,1));
            if size(group_idx{1,group},2) > 1
                for g = 2:size(group_idx{1,group},2)
                    mask = mask + group_matrix(:,:,group_idx{1,group}(1,g));
                end
            end
            region_mask(:,:,group) = mask;
            %figure;
            %heatmap(mask,'Colormap',redblue,'GridVisible','off');
        end
    end
    
    [p,q] = find(sum(group_img,3)<3);
    p = cat(1,p.',q.');
    k = convhull(p(1,:),p(2,:));
    d = zeros(1,size(k,1)*2);
    for j = 1:size(k,1)
        d(2*j-1:2*j) = [p(2,k(j)) p(1,k(j))];
    end
    C = zeros(size(group_img));
    C = insertShape(C,"Polygon",d,'Color','white');
    C(C>0.2) = 1;
    C(C<1) = 0;
    C_fill = imfill(C(:,:,1),'holes');
    kernel = [0 1 0;1 1 1;0 1 1];
    non_region = C_fill.*(conv2((sum(group_img,3)<3),ones(3,3),'same')==0);
    non_region = medfilt3(non_region,[3 3 1]); % remove single *

    figure;
    heatmap(non_region,'Colormap',redblue,'GridVisible','off');

    non_region_group = separate_Group(non_region);

    for g = 1:size(non_region_group,3)
        %figure;
        %heatmap(non_region_group(:,:,g),'Colormap',redblue,'GridVisible','off');
    end
    for group = 1:size(group_idx_non,2)
        if size(group_idx_non{1,group},2) > 0
            mask = non_region_group(:,:,group_idx_non{1,group}(1,1));
            if size(group_idx_non{1,group},2) > 1
                for g = 2:size(group_idx_non{1,group},2)
                    mask = mask + non_region_group(:,:,group_idx_non{1,group}(1,g));
                end
            end
            region_mask(:,:,size(group_idx,2) + group) = mask;
            %figure;
            %heatmap(mask,'Colormap',redblue,'GridVisible','off');
        end
    end

    %figure;
    %heatmap(non_region,'Colormap',redblue,'GridVisible','off');
    %group_img = C;
    %group_img(p(1,k),p(2,k),:) = zeros(size(k,1),size(k,1),3);
    
    figure;
    heatmap(-sum(group_img,3)-sum(non_region_group,3),'Colormap',redblue);
    
    norm_factor = 0.03;
    TEMP_img = zeros(size(region_mask,1),size(region_mask,2),3);
    TEMP = zeros(size(region_mask,1),size(region_mask,2));
    TEMP(:,:,[1 4 7]) = dff_map_L.*region_mask(:,:,[1 4 7]);
    TEMP(:,:,[2 5 8]) = dff_map_H.*region_mask(:,:,[2 5 8]);
    TEMP_img(:,:,1) = sum((dff_map_L+dff_map_H).*region_mask(:,:,[13 14]),3)/2+sum(dff_map_H.*region_mask(:,:,[2 5 8]),3);
    TEMP_img(:,:,2) = sum((dff_map_L+dff_map_H).*region_mask(:,:,[13 14]),3)/2+sum(dff_map_L.*region_mask(:,:,[1 4 7]),3)/2 + sum((dff_map_L+dff_map_H).*region_mask(:,:,[10 11 12]),3)/2;
    TEMP_img(:,:,3) = sum((dff_map_L+dff_map_H).*region_mask(:,:,[13 14]),3)/2+sum(dff_map_L.*region_mask(:,:,[1 4 7]),3);
    %TEMP(:,:,[10 11 12]) = (dff_map_L + dff_map_H).*region_mask(:,:,[10 11 12]);

    figure;
    %heatmap(sum(TEMP,3),'Colormap',redblue,'GridVisible','off','ColorLimits',[-0.03 0.03])
    imshow(TEMP_img/0.03)

    figure
    heatmap(sum(group_img,3),'Colormap',redblue);
    %imshow(imresize(group_img,10))
    %save(fullfile('X:\Mingxuan\WF\data',AnimalCenter{i,1},'ana\region_mask.mat'),'region_mask')
end
%CA72 1:38,4:43
%% functions
function [group_matrix,c_value,num_L,num_H] = expand_Group(dff_map_L,dff_map_H,group_matrix_c_L,group_matrix_c_H,de_ratio)
    c_value_L = sum(group_matrix_c_L.*repmat(dff_map_L,[1 1 size(group_matrix_c_L,3)]),[1 2])./sum(group_matrix_c_L,[1 2]);
    c_value_H = sum(group_matrix_c_H.*repmat(dff_map_H,[1 1 size(group_matrix_c_H,3)]),[1 2])./sum(group_matrix_c_H,[1 2]);
    num_L = size(c_value_L,3);
    num_H = size(c_value_H,3);
    c_value = cat(3,c_value_L,c_value_H);
    group_matrix = cat(3,group_matrix_c_L,group_matrix_c_H);

    % check overlay
    overlay = sum((group_matrix>0),3)>1;
    [~,idx] = max(group_matrix./cat(3,repmat(max(dff_map_L,[],"all"),size(group_matrix_c_L)),repmat(max(dff_map_H,[],"all"),size(group_matrix_c_H))).*repmat(overlay,[1 1 size(group_matrix,3)]),[],3);
    group_matrix = group_matrix.*repmat(overlay==0,[1 1 size(group_matrix,3)]);
    group = repmat(reshape((1:size(group_matrix,3)),[1 1 size(group_matrix,3)]),[size(group_matrix,1) size(group_matrix,2) 1]);
    group_matrix = group_matrix + (group==idx.*overlay);

    de_c = ones(size(group_matrix));
    sred = sum(group_matrix,3)>0;
    num_rep = 0;
    kernel = reshape([0 1 0; 1 1 1; 0 1 0],[3 3 1]);
    while sum(de_c,"all") > 0 && num_rep < 5
        group_matrix_expand = convn(group_matrix,kernel,"same");
        new_group_matrix = (group_matrix_expand>0) - repmat((sred>0),[1 1 size(de_c,3)]);
        sred = sred + sum(group_matrix_expand,3)>0;
        de_c = (new_group_matrix>0).*cat(3,repmat(dff_map_L,[1 1 num_L]),repmat(dff_map_H,[1 1 num_H]))./c_value;
        %de_c(de_c<de_ratio*max(c_value,[],"all")./repmat(c_value,[size(de_c,1) size(de_c,2) 1])) = 0;
        de_c(de_c<1-(1-de_ratio)*repmat(c_value,[size(de_c,1) size(de_c,2) 1])./cat(3,repmat(max(c_value_L,[],"all"),size(group_matrix_c_L)),repmat(max(c_value_H,[],"all"),size(group_matrix_c_H)))) = 0;
        overlay = sum((de_c>0),3)>1;
        [~,idx] = max(de_c.*repmat(overlay,[1 1 size(de_c,3)]),[],3);
        de_c = de_c.*repmat(overlay==0,[1 1 size(de_c,3)]);
        group = repmat(reshape((1:size(de_c,3)),[1 1 size(de_c,3)]),[size(de_c,1) size(de_c,2) 1]);
        de_c = de_c + (group==idx.*overlay);
        group_matrix = group_matrix + (de_c>0);
        num_rep = num_rep + 1;
    end
end

function loc_max = find_LocalMaxima(m)
    m_all = cat(3,m,cat(1,zeros(1,size(m,2)),m(1:end-1,:)), ...
        cat(1,m(2:end,:),zeros(1,size(m,2))), ...
        cat(2,zeros(size(m,1),1),m(:,1:end-1)), ...
        cat(2,m(:,2:end),zeros(size(m,1),1)), ...
        cat(2,zeros(size(m,1),1),cat(1,zeros(1,size(m,2)-1),m(1:end-1,1:end-1))),...
        cat(2,zeros(size(m,1),1),cat(1,m(2:end,1:end-1),zeros(1,size(m,2)-1))),...
        cat(2,cat(1,m(2:end,2:end),zeros(1,size(m,2)-1)),zeros(size(m,1),1)),...
        cat(2,cat(1,zeros(1,size(m,2)-1),m(1:end-1,2:end)),zeros(size(m,1),1)));
    m(m~=max(m_all,[],3)) = 0;
    loc_max = m.*(m > prctile(m_all(:,:,1),75,"all"));%(m>0).*mean(m_all,3);
    %loc_max = m.*(m > 0.5*max(m_all(:,:,1),[],"all"));
end

function group_matrix = separate_Group(m)
    CC = bwconncomp(m>0);
    group_matrix = zeros(size(m,1),size(m,2),CC.NumObjects);
    for i = 1:size(group_matrix,3)
        x = zeros(1,size(m,1)*size(m,2));
        x(1,CC.PixelIdxList{i}) = 1;
        group_matrix(:,:,i) = reshape(x,[size(m,1) size(m,2)]);
    end
end

function DFF = load_DFF(AnimalCenter,condition)
    boundary = zeros(size(AnimalCenter,1),4);
    DFF = cell(1,size(AnimalCenter,1));
    stage = 20221205:20221205;
    for i = 1:size(DFF,2)-2
        for s = 1:size(stage,2)
            if s == 1
                [n,mean_dff] = MeanDff(AnimalCenter{i,1},stage(1,s),condition);
            else
                [n_temp,mean_dff_temp] = MeanDff(AnimalCenter{i,1},stage(1,s),condition);
                mean_dff = (mean_dff*n + mean_dff_temp*n_temp)/(n + n_temp);
                n = n + n_temp;
            end
        end
        mean_dff(isnan(mean_dff)) = 0;
        DFF{1,i} = mean_dff;
        boundary(i,:) = [AnimalCenter{i,2}(1,1) (size(mean_dff,1)-AnimalCenter{i,2}(1,1)) AnimalCenter{i,2}(1,2) (size(mean_dff,2)-AnimalCenter{i,2}(1,2))];
    end
    
    %d = cat(2,3:7,9:10,12:28,101);
    d = cat(2,3);
    stage = zeros(size(d,2),1);
    for i = 1:size(d,2)
        stage(i,1) = 20230200 + d(i);
    end
    for i = size(DFF,2)-1:size(DFF,2)
        for s = 1:size(stage,2)
            if s == 1
                [n,mean_dff] = MeanDff(AnimalCenter{i,1},stage(1,s),condition);
            else
                [n_temp,mean_dff_temp] = MeanDff(AnimalCenter{i,1},stage(1,s),condition);
                mean_dff = (mean_dff*n + mean_dff_temp*n_temp)/(n + n_temp);
                n = n + n_temp;
            end
        end
        mean_dff(isnan(mean_dff)) = 0;
        DFF{1,i} = mean_dff;
        boundary(i,:) = [AnimalCenter{i,2}(1,1) (size(mean_dff,1)-AnimalCenter{i,2}(1,1)) AnimalCenter{i,2}(1,2) (size(mean_dff,2)-AnimalCenter{i,2}(1,2))];
    end
end

function [n,mean_dff] = MeanDff(AnimalID,Day,condition)
    data_dff = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_dff',strcat(string(Day),'.mat')));
    data_dff = data_dff.data_dff;
    sti = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_sti',strcat(string(Day),'.mat')));
    sti = sti.sti;
    dff = zeros(size(data_dff,1),size(data_dff,2),0);
    n = 0;
    for i = 1:size(sti,2)
        if sti(1,i) == condition(1,1) && sti(4,i) == condition(1,2)
            if condition(1,2) ~= -1
                dff(:,:,end+1) = mean(data_dff(:,:,(i-1)*61+16:(i-1)*61+45),3);
                n = n + 1;
            elseif condition(1,3) == -1
                if sti(7,i)*sti(8,i) < 0
                    dff(:,:,end+1) = mean(data_dff(:,:,(i-1)*61+16:(i-1)*61+45),3);
                    n = n + 1;
                end
            else
                if sti(7,i)*sti(8,i) > 0
                    dff(:,:,end+1) = mean(data_dff(:,:,(i-1)*61+16:(i-1)*61+45),3);
                    n = n + 1;
                end
            end
        end
    end
    mean_dff = mean(dff,3);
    mean_dff = fliplr(rot90(mean_dff));
end

function [n,mean_z] = MeanZ(AnimalID,Day,condition)
    data_z = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_zscore',strcat(string(Day),'.mat')));
    data_z = data_z.data_z;
    sti = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_sti',strcat(string(Day),'.mat')));
    sti = sti.sti;
    z = zeros(size(data_z,1),size(data_z,2),0);
    n = 0;
    for i = 1:size(sti,2)
        if sti(1,i) == condition(1,1) && sti(4,i) == condition(1,2)
            if condition(1,2) ~= -1
                z(:,:,end+1) = median(data_z(:,:,(i-1)*61+16:(i-1)*61+45),3);
                n = n + 1;
            elseif condition(1,3) == -1
                if sti(7,i)*sti(8,i) < 0
                    z(:,:,end+1) = median(data_z(:,:,(i-1)*61+16:(i-1)*61+45),3);
                    n = n + 1;
                end
            else
                if sti(7,i)*sti(8,i) > 0
                    z(:,:,end+1) = median(data_z(:,:,(i-1)*61+16:(i-1)*61+45),3);
                    n = n + 1;
                end
            end
        end
    end
    mean_z = median(z,3);
    mean_z = fliplr(rot90(mean_z));
end