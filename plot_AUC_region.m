Performance = load('X:\Mingxuan\WF\data\ANA\Performance_LC-HC_stage1-5_12seg.mat');
AUC = Performance.AUC;

color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56];[0 0 0];[127 127 127]];
color_idx = [1 3 4 5 6 8];
color = color(color_idx,:)/255;
stage = 5;
t = 1:12;
figure;
hold on;
for stage = 5
    for region = 1:15
        subplot(15,1,region)
        hold on
        for i = 1:6
            y = permute(AUC(i,stage,region,:,:,1),[5 4 1 2 3 6]);
            if sum(y,"all") ~= 0
                y(y<=0) = nan;
                N = size(y,1);
                yMean = nanmean(y);
                ySEM = nanstd(y)/sqrt(N);
                CI95 = tinv([0.025 0.975], N-1);
                yCI95 = bsxfun(@times, ySEM, CI95(:));
                patch([t fliplr(t)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], color(i,:), 'EdgeColor','none', 'FaceAlpha',0.25);
                plot(t,nanmean(y),Color = color(i,:));
            end
        end
        ylim([0 1.01]);
        xlim([1 12]);
        yline(0.5)
        xticks([])
        yticks([])
        hold off
    end
end
hold off;