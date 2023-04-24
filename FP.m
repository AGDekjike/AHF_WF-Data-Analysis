path = 'X:\Mingxuan\FP.tif';
X = readMultipageTiff(path);

DEG = zeros(1,size(X,3));
for i = 1:size(X,3)
    imageData2 = X(:,:,i);
    imgS = double(imageData2);
    M = 594;
    mi = 206;
    imgS = double((imgS-mi)./(M-mi));
    Heq = histeq(imgS);
    %imshow(imgS)
    %figure(1),imagesc(Heq), colormap(gray), colorbar
    deg = detect(imageData2);
    DEG(i) = deg;
end




function deg = detect(Img)
    [l,w] = size(Img);
    cx = l./2;
    cy = w./2;
    ImgT = Img(round(0.7.*cy):round(1.3.*cy),round(0.7.*cx):round(1.3.*cx));
    [l,w] = size(ImgT);
    cx = l./2;
    cy = w./2;
    F_ImgT = fft2(ImgT);
    %SF_ImgT = fftshift(F_ImgT);
    SF_ImgT = F_ImgT;
    %SF_ImgT(round(0.75.*w./2):round(1.25.*w./2),round(0.75.*l./2):round(1.25.*l./2)) = 0;
    magnitude = log(abs(SF_ImgT));
    deg = mean(mean(magnitude(round(cx-8):round(cx+8),round(cy-8):round(cy+8))));
end

function subimages = readMultipageTiff(filename)
% Read a multipage tiff, assuming each file is the same size
    t = Tiff(filename,'r');
    subimages(:,:,1) = t.read(); % Read the first image to get the array dimensions correct.
    if t.lastDirectory()
         return; % If the file only contains one page, we do not need to continue.
    end
% Read all remaining pages (directories) in the file
    t.nextDirectory();
    while true
        subimages(:,:,end+1) = t.read();
        if t.lastDirectory()
            break;
        else
            t.nextDirectory();
        end
    end
end