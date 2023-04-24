figure;
hold on

for i = 1:size(ACC,1)
    plot(ACC(i,:),'LineStyle','-.','Color',[0 0.65 1],'LineWidth',0.5)%[1 0.65 0]  %[0 0.65 1]
end


N = size(ACC,1);
yMean = mean(ACC);
x = 1:size(yMean,2);
plot(yMean,'LineWidth',1,'Color',[0 0.4 0]);%[0.8 0.4 0]  %[0 0.4 0]
ySEM = std(ACC)/sqrt(N);
CI95 = tinv([0.025 0.975], N-1);
yCI95 = bsxfun(@times, ySEM, CI95(:));
patch([x fliplr(x)], [yMean-ySEM fliplr(yMean+ySEM)], [0 1 0] , 'EdgeColor','none', 'FaceAlpha',0.3);%[1 0.5 0]  % [0 1 0]
%yline(1);
%hold off;
xlabel('Training day');
ylabel('Max accuarcy over 25 trials');
%ylim([0 1]);
%legend();