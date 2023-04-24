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
AnimalID = AnimalList{end-5,1};
path = fullfile('X:\Mingxuan\WF\data',AnimalID,'COMBINED\combined_stage');
I = load(fullfile(path,'FRA_contour.mat'));
I = I.C;
I(I<1)=0;
I_fill = imfill(I(:,:,1),'holes');
trend_matrix = load(fullfile('X:\Mingxuan\WF\data',AnimalID,'ana\LF_45_trend_matrix_xcorr_allbaseline.mat'));
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
    for j = 1:round(size(Y,2)/21)
        [lg,line_matrix] = fit_line(Y((stage-1)*25+1:stage*25,(j-1)*21+1:j*21));
        target_matrix((stage-1)*25+1:stage*25,(j-1)*21+1:j*21) = line_matrix;
        [~,id_1] = max(line_matrix(1,:));
        [~,id_2] = max(line_matrix(25,:));
        id_2 = lg(25);
        id_1 = lg(1);
        lag_value(stage,j) = id_2 - id_1;
    end
end
figure;
heatmap(-lag_value,'Colormap',redblue,'ColorLimits',[-15 15],'GridVisible','off');
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

function [lg,line_matrix] = fit_line(p_matrix)
    line_matrix = zeros(size(p_matrix,1),21);
    [M,I] = max(p_matrix,[],2);
    x = I.'-ceil(size(p_matrix,2)/2);
    y = 1:size(p_matrix,1);
    z = M.';
    xyz = cat(1,x,y,z);
    xyz0 = mean(xyz,2);
    A = xyz-xyz0;
    [U,S,~] = svd(A);
    d = U(:,1);
    range = (-10*size(p_matrix):10*size(p_matrix))/10;
    xzyl = xyz0 + range.*d;
    %xzyl
    lg = [];
    for i = y
        [~,id] = min(abs(xzyl(2,:) - i));
        %id
        lg(end+1) = min(21,max(1,xzyl(1,id)+ceil(size(p_matrix,2)/2)));
        line_matrix(i,min(21,max(1,round((xzyl(1,id)+ceil(size(p_matrix,2)/2)))))) = xzyl(3,id);
    end
    % Check
    x = xyz(1,:);
    y = xyz(2,:);
    z = xyz(3,:);
    xl = xzyl(1,:);
    yl = xzyl(2,:);
    zl = xzyl(3,:);
end