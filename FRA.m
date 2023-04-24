path = 'X:\Mingxuan\WF\FRA\MH0114_figures\MH0114_WF_act_foci_ON.png';
img = imread(path);
I = img(210:1110,95:995,:);
figure;
imshow(I)
for i = 1:size(I,1)
    for j = 1:size(I,2)
        if I(i,j,1) == I(i,j,2) && I(i,j,1) == I(i,j,3)
            I(i,j,:) = zeros(1,1,3);
        end
    end
end
I = imresize(I,0.205);
I = double(I);
I = I/max(I,[],"all");
J = mean(I,3);
J(J>0.2) = 1;
J(J<1) = 0;
p = zeros(2,0);
for i = 1:size(J,1)
    for j = 1:size(J,2)
        if J(i,j) == 1
            p(:,end+1) = [i;j];
        end
    end
end
k = convhull(p(1,:),p(2,:));
d = zeros(1,size(k,1)*2);
for i = 1:size(k,1)
    d(2*i-1:2*i) = [p(2,k(i)) p(1,k(i))];
end
C = zeros(size(J));
C = insertShape(C,"Polygon",d,'Color','white');
C(C>0.2) = 1;
C(C<1) = 0;


figure;
imshow(C)
%save('X:\Mingxuan\WF\data\000D2491EA52\COMBINED\combined_stage\FRA.mat',"I");
%save('X:\Mingxuan\WF\data\000D249170C8\COMBINED\combined_stage\FRA_contour.mat',"C");

%%
%854
I = img(255:1155,40:1010,:);
%438
p = zeros(2,0);
for i = 95:size(J,1)
    for j = 60:size(J,2)
        if J(i,j) == 1
            J(i,j) = 0;
            p(:,end+1) = [i;j];
        end
    end
end
k = convhull(p(1,:),p(2,:));
d = zeros(1,size(k,1)*2);
for i = 1:size(k,1)
    d(2*i-1:2*i) = [p(2,k(i)) p(1,k(i))];
end
C = zeros(size(J));
C = insertShape(C,"Polygon",d,'Color','white');
C(C>0.2) = 1;
C(C<1) = 0;
p = zeros(2,0);
for i = 1:size(J,1)
    for j = 1:size(J,2)
        if J(i,j) == 1
            p(:,end+1) = [i;j];
        end
    end
end
k = convhull(p(1,:),p(2,:));
d = zeros(1,size(k,1)*2);
for i = 1:size(k,1)
    d(2*i-1:2*i) = [p(2,k(i)) p(1,k(i))];
end
C2 = zeros(size(J));
C2 = insertShape(C2,"Polygon",d,'Color','white');
C2(C2>0.2) = 0.5;
C2(C2<0.5) = 0;
C = C + C2;
%7DA
I = img(255:1155,40:1010,:);
%C6
I = img(255:1155,37:1032,:);
%3C
I = img(290:1190,37:1032,:);