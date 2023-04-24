figure;
for i = 1:size(hm,3)
    subplot(1,size(hmr,3),i)
    heatmap(hmr(:,:,i),'Colormap',turbo,'ColorLimits',[0 1]);
end
figure;
for i = 1:size(hm,3)
    subplot(1,size(hmr,3),i)
    heatmap(hm(:,:,i),'Colormap',turbo,'ColorLimits',[-20 20]);
end