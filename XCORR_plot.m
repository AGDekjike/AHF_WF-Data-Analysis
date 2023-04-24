%%%%%%%% run this after XCORR.m
p_img = zeros(14*6+4,14*6+4,3);

xcorr_matrix = load('C:\MW\manuscript\xcorr_matrix_16-45.mat');
xcorr_matrix = xcorr_matrix.xcorr_matrix;
for stage = 1:5
    for cls = [1 4]
        for region_1 = 1:14
            for region_2 = 1:14
                if stage < 2
                    y = permute(xcorr_matrix(:,[1 stage],(cls>1)+1,region_1,region_2),[1 2 3 4 5]);
                    y(y==0) = nan;
                else
                    for stage_base = 1:stage
                        y = permute(xcorr_matrix(:,[stage_base stage],(cls>1)+1,region_1,region_2),[1 2 3 4 5]);
                        y(y==0) = nan;
                        h0 = kstest(y(:,1));
                        h = kstest(y(:,2));
                        if (h0 + h) == 0
                            [~,p] = ttest(y(:,2),y(:,1));
                        else
                            p = ranksum(y(:,2),y(:,1));
                        end
                        if isnan(p)
                            p = 1;
                        end
                        if p < 0.05
                            if cls <= 3
                                if region_1 > region_2
                                    if  nanmean(y(:,2),"all") >  nanmean(y(:,1),"all")
                                        p_img(stage*15+region_1,stage_base*15+region_2,1) = 1-10*p;
                                    else
                                        p_img(stage*15+region_1,stage_base*15+region_2,3) = 1-10*p;
                                        p_img(stage*15+region_1,stage_base*15+region_2,2) = (1-10*p)/2;
                                    end
                                end
                            else
                                if region_2 > region_1
                                    if  nanmean(y(:,2),"all") >  nanmean(y(:,1),"all")
                                        p_img(stage*15+region_1,stage_base*15+region_2,1) = 1-10*p;
                                    else
                                        p_img(stage*15+region_1,stage_base*15+region_2,3) = 1-10*p;
                                        p_img(stage*15+region_1,stage_base*15+region_2,2) = (1-10*p)/2;
                                    end
                                end
                            end
                        end
                    end
                end

                if cls <= 3
                    if region_1 > region_2
                        if (nanmean(y(:,2),"all")-0.7)/0.3 > 2/3
                            p_img(stage*15+region_1,region_2,3) = (nanmean(y(:,2),"all")-0.7)/0.1-2;
                            p_img(stage*15+region_1,region_2,2) = 1;
                            p_img(stage*15+region_1,region_2,1) = 1;
                        elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 1/3
                            p_img(stage*15+region_1,region_2,2) = (nanmean(y(:,2),"all")-0.7)/0.1-1;
                            p_img(stage*15+region_1,region_2,1) = 1;
                            p_img(stage*15+region_1,region_2,3) = 0;
                        elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 0
                            p_img(stage*15+region_1,region_2,1) = (nanmean(y(:,2),"all")-0.7)/0.1;
                            p_img(stage*15+region_1,region_2,2) = 0;
                            p_img(stage*15+region_1,region_2,3) = 0;
                        end
                    end
                else
                    if region_2 > region_1
                        if (nanmean(y(:,2),"all")-0.7)/0.3 > 2/3
                            p_img(stage*15+region_1,region_2,3) = (nanmean(y(:,2),"all")-0.7)/0.1-2;
                            p_img(stage*15+region_1,region_2,2) = 1;
                            p_img(stage*15+region_1,region_2,1) = 1;
                        elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 1/3
                            p_img(stage*15+region_1,region_2,2) = (nanmean(y(:,2),"all")-0.7)/0.1-1;
                            p_img(stage*15+region_1,region_2,1) = 1;
                            p_img(stage*15+region_1,region_2,3) = 0;
                        elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 0
                            p_img(stage*15+region_1,region_2,1) = (nanmean(y(:,2),"all")-0.7)/0.1;
                            p_img(stage*15+region_1,region_2,2) = 0;
                            p_img(stage*15+region_1,region_2,3) = 0;
                        end
                    end
                end
                if region_2 == region_1
                    p_img(stage*15+region_1,region_2,:) = 1;
                end
            end
        end
    end
end

xcorr_matrix = load('C:\MW\manuscript\xcorr_matrix_16-25.mat');
xcorr_matrix = xcorr_matrix.xcorr_matrix;
for stage = 1:5
    for cls = [1 4]
        for region_1 = 1:14
            for region_2 = 1:14
                if stage < 2
                    y = permute(xcorr_matrix(:,[1 stage],(cls>1)+1,region_1,region_2),[1 2 3 4 5]);
                    y(y==0) = nan;
                else
                    for stage_base = 1:stage
                        y = permute(xcorr_matrix(:,[stage_base stage],(cls>1)+1,region_1,region_2),[1 2 3 4 5]);
                        y(y==0) = nan;
                        h0 = kstest(y(:,1));
                        h = kstest(y(:,2));
                        if (h0 + h) == 0
                            [~,p] = ttest(y(:,2),y(:,1));
                        else
                            p = ranksum(y(:,2),y(:,1));
                        end
                        if isnan(p)
                            p = 1;
                        end
                        if p < 0.05
                            if cls <= 3
                                if region_1 < region_2
                                    if  nanmean(y(:,2),"all") >  nanmean(y(:,1),"all")
                                        p_img(stage_base*15+region_1,stage*15+region_2,1) = 1-10*p;
                                    else
                                        p_img(stage_base*15+region_1,stage*15+region_2,3) = 1-10*p;
                                        p_img(stage_base*15+region_1,stage*15+region_2,2) = (1-10*p)/2;
                                    end
                                end
                            else
                                if region_2 < region_1
                                    if  nanmean(y(:,2),"all") >  nanmean(y(:,1),"all")
                                        p_img(stage_base*15+region_1,stage*15+region_2,1) = 1-10*p;
                                    else
                                        p_img(stage_base*15+region_1,stage*15+region_2,3) = 1-10*p;
                                        p_img(stage_base*15+region_1,stage*15+region_2,2) = (1-10*p)/2;
                                    end
                                end
                            end
                        end
                    end
                end

                if cls <= 3
                    if region_1 < region_2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%reverse of previous
                        if (nanmean(y(:,2),"all")-0.7)/0.3 > 2/3
                            p_img(region_1,stage*15+region_2,3) = (nanmean(y(:,2),"all")-0.7)/0.1-2;
                            p_img(region_1,stage*15+region_2,2) = 1;
                            p_img(region_1,stage*15+region_2,1) = 1;
                        elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 1/3
                            p_img(region_1,stage*15+region_2,2) = (nanmean(y(:,2),"all")-0.7)/0.1-1;
                            p_img(region_1,stage*15+region_2,1) = 1;
                            p_img(region_1,stage*15+region_2,3) = 0;
                        elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 0
                            p_img(region_1,stage*15+region_2,1) = (nanmean(y(:,2),"all")-0.7)/0.1;
                            p_img(region_1,stage*15+region_2,2) = 0;
                            p_img(region_1,stage*15+region_2,3) = 0;
                        end
                    end
                else
                    if region_2 < region_1
                        if (nanmean(y(:,2),"all")-0.7)/0.3 > 2/3
                            p_img(region_1,stage*15+region_2,3) = (nanmean(y(:,2),"all")-0.7)/0.1-2;
                            p_img(region_1,stage*15+region_2,2) = 1;
                            p_img(region_1,stage*15+region_2,1) = 1;
                        elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 1/3
                            p_img(region_1,stage*15+region_2,2) = (nanmean(y(:,2),"all")-0.7)/0.1-1;
                            p_img(region_1,stage*15+region_2,1) = 1;
                            p_img(region_1,stage*15+region_2,3) = 0;
                        elseif (nanmean(y(:,2),"all")-0.7)/0.3 > 0
                            p_img(region_1,stage*15+region_2,1) = (nanmean(y(:,2),"all")-0.7)/0.1;
                            p_img(region_1,stage*15+region_2,2) = 0;
                            p_img(region_1,stage*15+region_2,3) = 0;
                        end
                    end
                end
                if region_2 == region_1
                    p_img(region_1,stage*15+region_2,:) = 1;
                end
            end
        end
    end
end



for i = 1:5
    p_img(:,15*i,:) = 1;
end
for i = 1:5
    p_img(15*i,:,:) = 1;
end
for i = 1:6
    p_img((i-1)*15+1:min(i*15,size(p_img,1)),(i-1)*15+1:min(i*15,size(p_img,2)),:) = 1;
end
figure;
imshow(p_img)