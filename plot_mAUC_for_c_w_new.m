color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56]];
color_idx = [1 3 4 6 8 10 5 9 9 9];
color = color(color_idx,:)/255;
rng('default');
AnimalList = {'080500020A05' [44 10 228 179];
              '210805001438' [20 17 234 181];
              '000D2491CA72' [25 5 224 194];
              '000D24918830' [26 27 225 191];
              '000D2491EA52' [34 15 223 189];
              '000D249170C8' [50 11 234 195]};
path = 'X:\Mingxuan\WF\data';
test_result = ones(3,5,15);
ACC_c = -ones(6,5,15,3);
AUC_c = ACC_c;
ACC_w = ACC_c;
AUC_w = ACC_c;
Frame = [16:25;26:35;36:45];
for stage = 1:5
    stage
    figure
    hold on
    for region = 1:15
        region
        for fm = 1:3
            frame = Frame(fm,:);
            for am = 1:6
                Animal = AnimalList{am,1};
                if exist(fullfile(path,Animal,'ana\LSTM',strcat('LSTM_LM-HM_stage1_region',num2str(region),'_frame',num2str(frame(1)),'-',num2str(frame(end)),'_','fold10.mat')))
                    netLSTM = load(fullfile(path,Animal,'ana\LSTM',strcat('LSTM_LM-HM_stage1_region',num2str(region),'_frame',num2str(frame(1)),'-',num2str(frame(end)),'_','fold10.mat')));
                    netLSTM = netLSTM.netLSTM;
                    
                    label = load(fullfile(path,Animal,'ana',strcat('label_allregions',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
                    label = label.label;
                    sequence = load(fullfile(path,Animal,'ana',strcat('sequence_allregions',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
                    sequence = sequence.sequence;
                    
                    LF = (label==1)+(label==4);
                    label = label(LF==1);
                    label = label+1;
                    sequence = sequence{1,region};
                    if size(sequence,1) ~= 0
                        sequence = sequence(LF==1,:,:);
                        sequences = cell(size(sequence,1),1);
                        labels = categorical(label);
                        for i = 1:size(sequence,1)
                            sequences{i,1} = permute(sequence(i,:,frame),[2 3 1]);
                        end
                        miniBatchSize = 32;
                    
                        [YPred,scores] = classify(netLSTM,sequences,'MiniBatchSize',miniBatchSize);
                        YValidation = labels;
                        accuracy = mean(YPred == YValidation);
                        scores = log10(scores);
                        scores(scores(:,1)==0,1) = -scores(scores(:,1)==0,2);
                        scores(scores(:,2)==0,2) = -scores(scores(:,2)==0,1);
                        [~,~,~,auc_score] = perfcurve(YValidation,scores(:,1),netLSTM.Layers(6).Classes(1));
                        ACC_c(am,stage,region,fm) = accuracy;
                        AUC_c(am,stage,region,fm) = auc_score;
                    end
                
                    label = load(fullfile(path,Animal,'ana',strcat('label_allregions',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
                    label = label.label;
                    sequence = load(fullfile(path,Animal,'ana',strcat('sequence_allregions',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
                    sequence = sequence.sequence;
                
                    LF = (label==3)+(label==6);
                    label = label(LF==1);
                    label = label-1;
                    sequence = sequence{1,region};
                    if size(sequence,1) ~= 0
                        sequence = sequence(LF==1,:,:);
                        sequences = cell(size(sequence,1),1);
                        labels = categorical(label);
                        for i = 1:size(sequence,1)
                            sequences{i,1} = permute(sequence(i,:,frame),[2 3 1]);
                        end
                        miniBatchSize = 32;
                    
                        [YPred,scores] = classify(netLSTM,sequences,'MiniBatchSize',miniBatchSize);
                        YValidation = labels;
                        accuracy = mean(YPred == YValidation);
                        scores = log10(scores);
                        scores(scores(:,1)==0,1) = -scores(scores(:,1)==0,2);
                        scores(scores(:,2)==0,2) = -scores(scores(:,2)==0,1);
                        [~,~,~,auc_score] = perfcurve(YValidation,scores(:,1),netLSTM.Layers(6).Classes(1));
                        ACC_w(am,stage,region,fm) = accuracy;
                        AUC_w(am,stage,region,fm) = auc_score;
                    end
                end
            end
        end
    
        ACC_c(ACC_c==-1) = nan;
        ACC_w(ACC_w==-1) = nan;
        AUC_c(AUC_c==-1) = nan;
        AUC_w(AUC_w==-1) = nan;
        subplot(15,1,region)
        hold on
        x = 1:5;
        for fm = 1:3
            for am = 1:6
                if sum((~isnan(AUC_c(am,stage,region,fm))).*(~isnan(AUC_w(am,stage,region,fm)))) == 1
                    plot(fm,AUC_c(am,stage,region,fm),'.','MarkerSize',5,'Color',color(7,:))
                    plot(fm,AUC_w(am,stage,region,fm),'.','MarkerSize',5,'Color',color(1,:))
                end
            end
            plot(permute(nanmean(AUC_c(:,stage,region,:),[1]),[4 3 2 1]),'Color',color(7,:)/2)
            plot(permute(nanmean(AUC_w(:,stage,region,:),[1]),[4 3 2 1]),'Color',color(1,:))
        end
        hold off
        ylim([0 1.03])
        yline(0.5)
        xlim([0.85 3.15])
        xticks([])
        yticks([])
        for fm = 1:3
            h0 = kstest(AUC_c(:,stage,region,fm));
            h = kstest(AUC_w(:,stage,region,fm));
            if (h0 + h) == 0
                [~,p] = ttest(AUC_c(:,stage,region,fm),AUC_w(:,stage,region,fm));
            else
                p = ranksum(AUC_c(:,stage,region,fm),AUC_w(:,stage,region,fm));
            end
            if isnan(p)
                p = 1;
            end
            test_result(fm,stage,region) = p;
        end
    end
    hold off
end