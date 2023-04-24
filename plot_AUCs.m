color = [[0.1 0.5 1];[1 0 1];[0 0.9 0.1]];
t = 1:5;
figure;
hold on;
for i = 1:3
    y = permute(P(:,:,1,i),[2 1 3 4]);
    %y = AUC_c;
    N = size(y,1);
    yMean = mean(y);
    ySEM = std(y)/sqrt(N);
    CI95 = tinv([0.025 0.975], N-1);
    yCI95 = bsxfun(@times, ySEM, CI95(:));
    patch([t fliplr(t)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], color(i,:), 'EdgeColor','none', 'FaceAlpha',0.25);
    plot(t,mean(y),Color = color(i,:));
end
hold off;
ylim([0.3 1.01]);
xlim([1 12]);
yline(0.5)