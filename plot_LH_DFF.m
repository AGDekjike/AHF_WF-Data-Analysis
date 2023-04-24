AnimalList = {'080500020A05' [44 10 228 179];
              '210805001438' [20 17 234 181];
              '000D2491CA72' [25 5 224 194];
              '000D24918830' [26 27 225 191]};
color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56];[0 127 60]];
color_idx = [1 8 10 3 9 6 5 2 7 8 11];
color = color(color_idx,:)/255;
t = 1:5;
figure
hold on
for r = 1:14
    LF_L = zeros(0,5);
    HF_L = zeros(0,5);
    LF_H = zeros(0,5);
    HF_H = zeros(0,5);
    LF_base = zeros(0,5);
    HF_base = zeros(0,5);
    LF = load(fullfile('X:Mingxuan\WF\data','ANA','LF_38_40_6_dff_z3.mat'));
    LF = LF.LF;
    LF_L = LF(:,:,r,1);
    LF_H = LF(:,:,r,2);
    LF_L(any(isnan(LF_L), 2), :) = [];
    LF_H(any(isnan(LF_H), 2), :) = [];
    HF = load(fullfile('X:Mingxuan\WF\data','ANA','HF_38_40_6_dff_z3.mat'));
    HF = HF.HF;
    HF_L = HF(:,:,r,1);
    HF_H = HF(:,:,r,2);
    HF_L(any(isnan(HF_L), 2), :) = [];
    HF_H(any(isnan(HF_H), 2), :) = [];
    
    LF_base = load(fullfile('X:Mingxuan\WF\data','ANA','LF_Area_41_60_6_z3.mat'));
    LF_base = LF_base.Area;
    LF_base = LF_base(:,:,r);
    LF_base(any(isnan(LF_base), 2), :) = [];
    HF_base = load(fullfile('X:Mingxuan\WF\data','ANA','HF_Area_41_60_6_z3.mat'));
    HF_base = HF_base.Area;
    HF_base = HF_base(:,:,r);
    HF_base(any(isnan(HF_base), 2), :) = [];

    LH = load(fullfile('X:Mingxuan\WF\data','ANA','LH_DFF_41_60.mat'));
    LH = LH.DFF;
    LH = LH(:,:,r);
    LH(any(isnan(LH), 2), :) = [];
    
    %LF_L = LF_L./repmat(LF_base(:,1),1,5);
    %LF_H = LF_H./repmat(LF_base(:,1),1,5);
    %HF_L = HF_L./repmat(HF_base(:,1),1,5);
    %HF_H = HF_H./repmat(HF_base(:,1),1,5);
    
    subplot(1,14,r)
    hold on
    for i = 1:size(LF_L,1)
        %plot(LF_L(i,:),Color=[0 0 1])
        %plot(LF_H(i,:),Color=[1 0 0])
        %plot(1:5,LF_L(i,:),'*','Color',color(2,:),'MarkerSize',5)
        %plot(1:5,LF_H(i,:),'*','Color',color(1,:),'MarkerSize',5)
        %plot(mean(LF_L),Color=color(2,:))
        %plot(mean(LF_H),Color=color(1,:))
        y = LH;
        N = size(y,1);
        yMean = mean(y);
        ySEM = std(y)/sqrt(N);
        CI95 = tinv([0.025 0.975], N-1);
        yCI95 = bsxfun(@times, ySEM, CI95(:));
        patch([t fliplr(t)], [yMean-ySEM fliplr(yMean+ySEM)], color(6,:), 'EdgeColor','none', 'FaceAlpha',0.25);
        for each = 1:size(y,1)
            %plot(t,y(each,:),Color = color(2,:),LineWidth=0.5,LineStyle='-.')
        end
        plot(t,mean(y),Color = color(7,:)/2,LineWidth=1);
        for stage = 1:5
            h0 = kstest(y(:,1));
            h = kstest(y(:,stage));
            if (h0 + h) == 0
                [~,p] = ttest(y(:,stage),y(:,1));
            else
                p = ranksum(y(:,stage),y(:,1));
            end
            if p < 0.001
                %plot([stage-0.1 stage stage+0.1],[0.045 0.045 0.045],'*')
            elseif p < 0.01
                %plot([stage-0.05 stage+0.05],[0.045 0.045],'*')
            elseif p < 0.05
                %plot([stage],[0.045],'*')
            end
            %plot(LF_base(:,stage),HF_base(:,stage),'.','Color',[0 0.2 0]*stage)
        end
        p = kruskalwallis(y,{'1','2','3','4','5'},"off");
        if p < 0.001
            plot([3-0.3 3 3+0.3],[0.045 0.045 0.045],'*',color=[0 0 0])
        elseif p < 0.01
            plot([3-0.15 3+0.15],[0.045 0.045],'*',color=[0 0 0])
            
        elseif p < 0.05
            plot([3],[0.045],'*',color=[0 0 0])
            zzz = y;
        end
        for animal = 1:size(LF_base,1)
            %plot(LF_base(animal,[1 5]),HF_base(animal,[1 5]))
        end
        y = LF_base;
        N = size(y,1);
        yMean = mean(y);
        ySEM = std(y)/sqrt(N);
        CI95 = tinv([0.025 0.975], N-1);
        yCI95 = bsxfun(@times, ySEM, CI95(:));
        %patch([t fliplr(t)], [yMean-ySEM fliplr(yMean+ySEM)], color(1,:), 'EdgeColor','none', 'FaceAlpha',0.25);
        %plot(t,mean(y),Color = color(1,:));
    end
    hold off
    xticks([])
    yticks([])
    %yticks([0 0.5 1])
    %xlabel('Stage')
    %ylabel('Ratio of area')
    ylim([0 0.05])
    xlim([1 5])
    %legend()
    
end
hold off