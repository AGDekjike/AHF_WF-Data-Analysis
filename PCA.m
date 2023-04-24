% 080500026C63
% 080500020A05
% 08050002242B
% 08050000D7DA  s0603L
% 210805001438  s0603H
% 210805007854  s0611L
% 007DA64A57C6  s0611H
% 210531013C28  s0612L
% 21053101283C  s0612H
AnimalID = '210531013C28';
Day = 20220809;
data_z = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_dff',strcat(string(Day),'.mat')));
data_z = data_z.data_dff;
color_res = {'#cc0000' '#00dd00'};
sti = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'combined_sti',strcat(string(Day),'.mat')));
sti = sti.sti;
info = load('X:\Mingxuan\WF\data\stim_info.mat');
%% pre
data = cell(3,11);
gp = zeros(1,size(sti,2));
for i = 1:3
    for j = 1:11
        data{i,j} = zeros(0,61);
    end
end
data_new = reshape(permute(mean(data_z(14:16,13:15,:),[1 2]),[3 2 1]).',[61,size(sti,2)]).';
for i = 1:size(sti,2)
    data{2-sti(4,i),sti(1,i)} = cat(1,data{2-sti(4,i),sti(1,i)},data_new(i,:));
    gp(i) = floor(sti(1,i)/6)*3 + 2 - sti(4,i);
end
%% pca
coef = pca(data_new(:,16:45));
W = data_new(:,16:45)*coef;
figure;
hold on
for i = 1:size(gp,2)
    if gp(i) <= 3
        plot(W(i,1),W(i,2),'.','Color','b');
    elseif gp(i) >= 4
        plot(W(i,1),W(i,2),'.','Color','r');
    end
end
hold off;

figure;
hold on
for i = 1:size(gp,2)
    if gp(i) <= 3
        plot(data_new(i,:),'Color','b');
    else
        plot(data_new(i,:),'Color','r');
    end
end
hold off;