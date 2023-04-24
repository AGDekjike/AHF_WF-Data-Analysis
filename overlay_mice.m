AnimalCenter = {'080500020A05' [28 17];
                '210805001438' [19 18];
                '000D2491CA72' [31 19];
                '000D24918830' [25 22];
                '000D2491EA52' [29 15];
                '000D249170C8' [26 16]};
boundary = zeros(size(AnimalCenter,1),4);
DFF = cell(1,size(AnimalCenter,1));
stage = 20221225:20221229;
condition = [1 -1 -1];
for i = 1:size(DFF,2)-2
    for s = 1:size(stage,2)
        if s == 1
            [n,mean_dff] = MeanZ(AnimalCenter{i,1},stage(1,s),condition);
        else
            [n_temp,mean_dff_temp] = MeanZ(AnimalCenter{i,1},stage(1,s),condition);
            mean_dff = (mean_dff*n + mean_dff_temp*n_temp)/(n + n_temp);
            n = n + n_temp;
        end
    end
    mean_dff(isnan(mean_dff)) = 0;
    DFF{1,i} = mean_dff;
    boundary(i,:) = [AnimalCenter{i,2}(1,1) (size(mean_dff,1)-AnimalCenter{i,2}(1,1)) AnimalCenter{i,2}(1,2) (size(mean_dff,2)-AnimalCenter{i,2}(1,2))];
end

%d = cat(2,3:7,9:10,12:28,101);
d = cat(2,25:28,101);
stage = zeros(size(d,2),1);
for i = 1:size(d,2)
    stage(i,1) = 20230200 + d(i);
end
for i = size(DFF,2)-1:size(DFF,2)
    for s = 1:size(stage,2)
        if s == 1
            [n,mean_dff] = MeanZ(AnimalCenter{i,1},stage(1,s),condition);
        else
            [n_temp,mean_dff_temp] = MeanZ(AnimalCenter{i,1},stage(1,s),condition);
            mean_dff = (mean_dff*n + mean_dff_temp*n_temp)/(n + n_temp);
            n = n + n_temp;
        end
    end
    mean_dff(isnan(mean_dff)) = 0;
    DFF{1,i} = mean_dff;
    boundary(i,:) = [AnimalCenter{i,2}(1,1) (size(mean_dff,1)-AnimalCenter{i,2}(1,1)) AnimalCenter{i,2}(1,2) (size(mean_dff,2)-AnimalCenter{i,2}(1,2))];
end

overlay_dff = zeros(sum(max(boundary(:,1:2))),sum(max(boundary(:,3:4))));
overlay = zeros(sum(max(boundary(:,1:2))),sum(max(boundary(:,3:4))));
center = [max(boundary(:,1)) max(boundary(:,3))];
for i = 1:size(DFF,2)
    overlay_dff(center(1,1)-AnimalCenter{i,2}(1,1)+1:center(1,1)-AnimalCenter{i,2}(1,1)+size(DFF{1,i},1),center(1,2)-AnimalCenter{i,2}(1,2)+1:center(1,2)-AnimalCenter{i,2}(1,2)+size(DFF{1,i},2)) = DFF{1,i} + overlay_dff(center(1,1)-AnimalCenter{i,2}(1,1)+1:center(1,1)-AnimalCenter{i,2}(1,1)+size(DFF{1,i},1),center(1,2)-AnimalCenter{i,2}(1,2)+1:center(1,2)-AnimalCenter{i,2}(1,2)+size(DFF{1,i},2));
    overlay(center(1,1)-AnimalCenter{i,2}(1,1)+1:center(1,1)-AnimalCenter{i,2}(1,1)+size(DFF{1,i},1),center(1,2)-AnimalCenter{i,2}(1,2)+1:center(1,2)-AnimalCenter{i,2}(1,2)+size(DFF{1,i},2)) = ones(size(DFF{1,i})) + overlay(center(1,1)-AnimalCenter{i,2}(1,1)+1:center(1,1)-AnimalCenter{i,2}(1,1)+size(DFF{1,i},1),center(1,2)-AnimalCenter{i,2}(1,2)+1:center(1,2)-AnimalCenter{i,2}(1,2)+size(DFF{1,i},2));
end
overlay_dff = overlay_dff./max(overlay,[],"all");
overlay_dff = medfilt2(overlay_dff,[3 3]);
figure;
heatmap(overlay_dff(:,:),'Colormap',redblue,'ColorLimits',[0 1.2],'GridVisible','off');
%CA72 1:38,4:43

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