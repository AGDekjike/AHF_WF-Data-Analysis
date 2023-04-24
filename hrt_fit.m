AnimalList = {'000C9522CA71' [38 8 227 192];
              '000C9524ED50' [46 9 235 193];
              '000C95238D37' [21 13 230 194];
              '000C95238B31' [34 6 228 190];
              '000C95243984' [14 16 203 191];
              '000C9522DD66' [25 15 219 199];
              '08050000D7DA' [24 12 228 196];
              '000D2491CA72' [25 5 224 194];
              '080500020A05' [44 10 228 179];
              '210805001438' [20 17 234 181];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};
AnimalID = AnimalList{end,1};
path = fullfile('X:\Mingxuan\WF\data',AnimalID,'COMBINED\combined_stage');
I = load(fullfile(path,'FRA_contour.mat'));
I = I.C;
I(I<1)=0;
I_fill = imfill(I(:,:,1),'holes');
trend_matrix = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\LF_45_trend_matrix_hrt.mat'));
X = trend_matrix.trend_matrix;
X(isnan(X)) = 0;
%Y = -log10(20*X);
Y = X;
%Y = Y(351:375,484:504);
%figure;
%heatmap(Y/20,'Colormap',hot,'ColorLimits',[0 1])

target_matrix = zeros(size(Y,1),round(21*size(Y,2)/21));
lag_value = zeros(round(size(Y,1)/25),round(size(Y,2)/21));
I_fill = imresize(I_fill,size(lag_value));
I_fill = I_fill > 0.5;
for stage = 1:round(size(Y,1)/25)
    for j = 1:size(Y,2)
        x = 1:25;
        y = Y((stage-1)*25+1:stage*25,j).';
        x(isinf(y)) = [];
        y(isinf(y)) = [];
        P = polyfit(x,y,1);
        lag_value(stage,j) = P(1)*24;
    end
end
figure;
heatmap(lag_value,'Colormap',redblue,'ColorLimits',[-10 10],'GridVisible','off');
%figure;
%imshow(img_lag_value)

%figure;
%hold on;
%histogram(lag_value(I_fill),'Normalization','probability','BinWidth',1)
%histogram(LF_1,'Normalization','probability','BinWidth',1,'FaceColor',[0 0 1])
%histogram(LF_2,'Normalization','probability','BinWidth',1,'FaceColor',[1 0 0])
%histogram(LF_3,'Normalization','probability','BinWidth',1,'FaceColor',[0 1 0])
%hold off;
%legend()
%[h,p] = ttest(lag_value(I_fill))

%figure;
%imshow(1-imresize(5*target_matrix/max(target_matrix,[],"all"),[950 1000]));