color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56]];
%color_idx = [1 3 5 7 9 2 4 6 8 10];
%color_idx = [2 6 10 3 5 7 8 9 1 4];
%color_idx = [9 4 2 5 7 10 8 3 1 6];
color_idx = [1 2 3 4 5 6 7 8 9 10];
color = color(color_idx,:)/255;
color = cat(1,color,color);
hist_x = [0.5 1.5 1.5 2.5 2.5 3.5 3.5 4.5 4.5 5.5 5.5 6.5 6.5 7.5 7.5 8.5 8.5 9.5 9.5 10.5];
color_hist = [[0 0 1];[1 0 0];[0 1 0]];
color_hist_2 = [[0.1 0.5 1];[1 0 1];[0 0.9 0.1]];

f_ct = 2;
k = 10;
all_day = 25;

%figure;
%hold on;
rt_lf = zeros(k,all_day,size(m_idxp,2));
rt_hf = zeros(k,all_day,size(m_idxp,2));
min_D = zeros(all_day,k,size(m_idxp,2));
min_d = zeros(all_day,size(m_idxp,2));
abs_d = min_D;

figure;
hold on;
for mice = 1:size(m_idxp,2)
    target_m = m_idxp{1,mice};
    per_day_f = size(target_m,1)/(f_ct*all_day);
    lf = [];
    hf = [];
    for i = 1:all_day
        lf = cat(1,lf,ones(per_day_f,1));
        lf = cat(1,lf,zeros(per_day_f,1));
        hf = cat(1,hf,zeros(per_day_f,1));
        hf = cat(1,hf,ones(per_day_f,1));
    end
    lf = target_m(lf>0);
    hf = target_m(hf>0);
    
    lf_img = zeros(100,100,3);
    hf_img = zeros(100,100,3);
    for i = 1:all_day
        point_lf = 1;
        point_hf = 1;
        for j = 1:k
            ratio_lf = sum(lf((i-1)*per_day_f+1:i*per_day_f)==j)/per_day_f;
            lf_img(point_lf:point_lf+round(100*ratio_lf)-1,(i-1)*4+1:i*4,:) = repmat(reshape(color(j,:),[1 1 3]),[round(100*ratio_lf) 4 1]);
            point_lf = point_lf + round(100*ratio_lf);
            rt_lf(j,i,mice) = ratio_lf;
    
            ratio_hf = sum(hf((i-1)*per_day_f+1:i*per_day_f)==j)/per_day_f;
            hf_img(point_hf:point_hf+round(100*ratio_hf)-1,(i-1)*4+1:i*4,:) = repmat(reshape(color(j,:),[1 1 3]),[round(100*ratio_hf) 4 1]);
            point_hf = point_hf + round(100*ratio_hf);
            rt_hf(j,i,mice) = ratio_hf;
        end
    end
    for i = 1:25
        %plot(repmat([i],[10 1]),rt_lf(:,i,mice),'.','MarkerSize',15,'Color',color_hist(mice,:));
        %plot(repmat([i],[10 1]),rt_hf(:,i,mice),'.','MarkerSize',15,'Color',color_hist(mice,:));
        plot3(repmat(i,[10 1]),rt_lf(:,i,mice),rt_hf(:,i,mice),'.','MarkerSize',10,'Color',log(i)*color_hist_2(mice,:)/log(25));
        [~,~,sumd,D] = kmeans(cat(2,rt_lf(:,i,mice),rt_hf(:,i,mice)),1);
        min_D(i,:,mice) = D;
        min_d(i,mice) = sumd;
        abs_d(i,:,mice) = sqrt((rt_lf(:,i,mice)-0.2).^2+(rt_hf(:,i,mice)-0.2).^2);
    end
    %[h,p] = kstest2(lf(1:per_day_f*5),lf(per_day_f*20+1:per_day_f*25))
    [h,p] = ttest(std(rt_lf(:,1:5,mice),[1]),std(rt_lf(:,21:25,mice),[1]))
    %vartestn(reshape(lf,[size(lf,1)/25 25]));
    %vartestn(reshape(hf,[size(hf,1)/25 25]));
    %figure;
    %imshow(lf_img)
    %figure;
    %imshow(hf_img)
    %histogram(hf(1:per_day_f*5),10,'Normalization','probability','BinEdges',hist_x,'FaceColor',color_hist(mice,:))
    %histogram(hf(per_day_f*20+1:per_day_f*25),10,'Normalization','probability','BinEdges',hist_x,'FaceColor',color_hist(mice,:))
end
hold off;
xlim([1 25])
ylim([0 1])
zlim([0 1])
%hold off;
%xlim([0.5 10.5])
%ylim([0 0.7])