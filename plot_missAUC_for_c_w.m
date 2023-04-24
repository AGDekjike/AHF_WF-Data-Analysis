color = [[187 37 72];[217 89 89];[247 134 100];[255 206 92];[118 208 118];[6 239 177];[13 191 182];[16 130 168];[10 87 112];[5 43 56]];
color_idx = [1 3 4 6 8 10 9 9 9 9];
color = color(color_idx,:)/255;

rng('default');
AnimalList = {'000D2491CA72' [25 5 224 194];
              '210805001438' [20 17 234 181];
              '080500020A05' [44 10 228 179]};
path = 'X:\Mingxuan\WF\data';
ACC_c = zeros(3,5,3);
AUC_c = ACC_c;
ACC_w = ACC_c;
AUC_w = ACC_c;
Frame = [16:25;26:35;36:45];
for fm = 1:3
    frame = Frame(fm,:);
    for am = 1:3
        Animal = AnimalList{am,1};
        netLSTM = load(fullfile(path,Animal,'ana',strcat('LSTM_1_5_LF_HF_m_',num2str(frame(1)),'_',num2str(frame(end)),'_','AC5f.mat')));
        netLSTM = netLSTM.netLSTM;
        
        for stage = 1:5
            label = load(fullfile(path,Animal,'ana',strcat('label_AC_',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
            label = label.label;
            sequence = load(fullfile(path,Animal,'ana',strcat('sequence_AC_',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
            sequence = sequence.sequence;
        
            LF = (label==1)+(label==4);
            label = label(LF==1);
            label = label+1;
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
            ACC_c(am,stage,fm) = accuracy;
            AUC_c(am,stage,fm) = auc_score;
        end
    
        for stage = 1:5
            label = load(fullfile(path,Animal,'ana',strcat('label_AC_',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
            label = label.label;
            sequence = load(fullfile(path,Animal,'ana',strcat('sequence_AC_',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
            sequence = sequence.sequence;
        
            LF = (label==3)+(label==6);
            label = label(LF==1);
            label = label-1;
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
            ACC_w(am,stage,fm) = accuracy;
            AUC_w(am,stage,fm) = auc_score;
        end
    end
end

x = 1:5;
for fm = 1:3
    figure;
    hold on;
    for am = 1:3
        plot(x-(2-fm)*0.1,AUC_c(am,:,fm),'.','MarkerSize',10,'Color',color(3+fm,:))
        plot(x-(2-fm)*0.1,AUC_w(am,:,fm),'.','MarkerSize',10,'Color',color(4-fm,:))
    end
    plot(mean(AUC_c(:,:,fm)),'Color',color(3+fm,:))
    plot(mean(AUC_w(:,:,fm)),'Color',color(4-fm,:))
    hold off;
end
ylim([0.3 1.03])
yline(0.5)
xlim([0.85 5.15])
