x = [20 13;11 22];
[h,p,stats] = fishertest(x,'Tail','both','Alpha',0.05)
%norminv(x(1,1)/(x(1,1)+x(1,2))) - norminv(x(2,1)/(x(2,1)+x(2,2)))
norminv((47+75)/(47+5+75+19)) - norminv((5+19)/(47+5+75+19))


x = 1:30;
figure;
hold on;
y = hr;
N = size(y,1);
yMean = mean(y);
ySEM = std(y)/sqrt(N);
CI95 = tinv([0.025 0.975], N-1);
yCI95 = bsxfun(@times, ySEM, CI95(:));
yCI95 = cat(1,-ySEM,ySEM);
plot(x,yMean);
patch([x fliplr(x)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], [0 0.1 1], 'EdgeColor','none', 'FaceAlpha',0.15);
ylim([0 1])

y = fr;
N = size(y,1);
yMean = mean(y);
ySEM = std(y)/sqrt(N);
CI95 = tinv([0.025 0.975], N-1);
yCI95 = bsxfun(@times, ySEM, CI95(:));
yCI95 = cat(1,-ySEM,ySEM);
plot(x,yMean);
patch([x fliplr(x)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], [1 0 0.9], 'EdgeColor','none', 'FaceAlpha',0.15);

y = ACC;
N = size(y,1);
yMean = mean(y);
ySEM = std(y)/sqrt(N);
CI95 = tinv([0.025 0.975], N-1);
yCI95 = bsxfun(@times, ySEM, CI95(:));
yCI95 = cat(1,-ySEM,ySEM);
plot(x,yMean,"Color",[0.1 0.3 0.1],"LineWidth",2);
patch([x fliplr(x)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], 'g', 'EdgeColor','none', 'FaceAlpha',0.4);

legend('hit rate','','false alarm rate','','max accuracy','');
hold off;


figure;
hold on;
y = d_prime;
N = size(y,1);
yMean = mean(y);
ySEM = std(y)/sqrt(N);
CI95 = tinv([0.025 0.975], N-1);
yCI95 = bsxfun(@times, ySEM, CI95(:));
yCI95 = cat(1,-ySEM,ySEM);
plot(x,yMean,"LineWidth",2);
yline(1,"Color",'b','LineWidth',2);
patch([x fliplr(x)], [yMean+yCI95(1,:) fliplr(yMean+yCI95(2,:))], 'g', 'EdgeColor','none', 'FaceAlpha',0.4);
legend('','threshold','');
hold off;