path = 'X:\Mingxuan\WF\data\210531013C28\COMBINED\combined_stage';
data_temp = load(fullfile(path,strcat('stage6','.mat')));
data = data_temp.data_dff;
data_stat = data_temp.data_stat;
dff_lf_all = (data{1,1});%*data_stat(3,1)+data{2,1}*data_stat(2,1)+data{3,1}*data_stat(3,1))/(sum(data_stat(:,1)));
max_ROI = 19;
C = cell(max_ROI);
LOC = cell(max_ROI);
for i = [19 2 7 12]
    C_temp = load(strcat('X:\Mingxuan\WF\data\210531013C28\COMBINED\combined_stage\mask\loc',string(i-1),'.mat'));
    C{i} = C_temp.C;
    LOC{i} = permute(sum(dff_lf_all.*C{i},[1 2]),[3 2 1])/sum(C{i},"all");
end
figure;
hold on;
for i = 1:max_ROI
    plot(LOC{i});
end
hold off;
legend;
ylim([-0.05 0.1]);