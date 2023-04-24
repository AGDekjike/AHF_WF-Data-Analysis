Performance = load('X:\Mingxuan\WF\data\ANA\Performance_C-W_stage1-5_4seg.mat');
AUC = Performance.AUC;
AUC(AUC<=0) = nan;

color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56];[0 0 0];[127 127 127]];
color_idx = [1 3 4 5 6 8];
color = color(color_idx,:)/255;
stage = 5;
t = 1:4;
figure;
hold on;
for stage = 1:5
    for region = 1:15
        subplot(5,15,(stage-1)*15+region)
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
                %patch([t fliplr(t)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], color(i,:), 'EdgeColor','none', 'FaceAlpha',0.25);
                plot(t,nanmean(y),Color = [0.3 0.4 0.5],LineStyle="-.",LineWidth=0.25);
            end
        end
        y = permute(nanmean(AUC(:,stage,region,:,:,1),[5]),[1 4 2 3 5 6]);
        if sum(y,"all") ~= 0
            y(y<=0) = nan;
            N = size(y,1);
            yMean = nanmean(y);
            ySEM = nanstd(y)/sqrt(N);
            CI95 = tinv([0.025 0.975], N-1);
            yCI95 = bsxfun(@times, ySEM, CI95(:));
            %patch([t fliplr(t)], [yMean-nanstd(y) fliplr(yMean+nanstd(y))], color(i,:), 'EdgeColor','none', 'FaceAlpha',0.25);
            plot(t,nanmean(y),Color = [0 0.5 0.25],LineWidth=0.75);
        end
    
        ylim([0 1.01]);
        xlim([1 4]);
        yticks([])
        xticks([])
        yline(0.5)
        for frame = 2:4
            h0 = kstest(y(:,1));
            h = kstest(y(:,frame));
            if (h0 + h) == 0
                [~,p] = ttest(y(:,1),y(:,frame));
            else
                p = ranksum(y(:,1),y(:,frame));
            end
            if p < 0.001
                plot([frame-0.3 frame frame+0.3],[1 1 1],'*',color=[0 0 0])
            elseif p < 0.01
                plot([frame-0.15 frame+0.15],[1 1],'*',color=[0 0 0])
                
            elseif p < 0.05
                plot([frame],[1],'*',color=[0 0 0])
            end
        end
        hold off
    end
end
hold off;