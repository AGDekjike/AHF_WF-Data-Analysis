rng('default');
AnimalList = {'080500026C63' [23 7 223 186];
              '080500020A05' [20 25 219 199];
              '08050002242B' [21 4 220 183];
              '08050000D7DA' [34 8 233 192];
              '210805001438' [22 6 226 195];
              '210805007854' [36 7 235 191];
              '007DA64A57C6' [25 9 229 193];
              '210531013C28' [32 12 231 196];
              '21053101283C' [21 13 225 197];
              '000D2491CA72' [25 5 224 194];
              '210805001438' [20 17 234 181];
              '080500020A05' [44 10 228 179]};
path = 'X:\Mingxuan\WF\data';
Animal = AnimalList{end-2,1};
%netLSTM = load(fullfile(path,Animal,'ana','LSTM_1_5_LF_HF_m_36_45_AC5f.mat'));
%netLSTM = load(fullfile(path,'ANA','LSTM_s1_5_16_45_LHC_438_A05.mat'));
netLSTM = netLSTM.netLSTM;

ACC = zeros(1,5);
AUC = ACC;
for stage = 1:5
    %label = load(fullfile(path,Animal,'ana',strcat('label_AC_',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
    %label = label.label;
    %sequence = load(fullfile(path,Animal,'ana',strcat('sequence_AC_',num2str(5*(stage-1)+1),'_',num2str(stage*5),'.mat')));
    %sequence = sequence.sequence;

    LF = (label==2)+(label==5);
    label = label(LF==1);
    %label = label-1;
    sequence = sequence(LF==1,:,:);
    sequences = cell(size(sequence,1),1);
    labels = categorical(label);
    for i = 1:size(sequence,1)
        sequences{i,1} = permute(sequence(i,:,16:45),[2 3 1]);
    end
    miniBatchSize = 32;

    [YPred,scores] = classify(netLSTM,sequences,'MiniBatchSize',miniBatchSize);
    YValidation = labels;
    accuracy = mean(YPred == YValidation);
    scores = log10(scores);
    scores(scores(:,1)==0,1) = -scores(scores(:,1)==0,2);
    scores(scores(:,2)==0,2) = -scores(scores(:,2)==0,1);
    [~,~,~,auc_score] = perfcurve(YValidation,scores(:,1),netLSTM.Layers(6).Classes(1))
    ACC(1,stage) = accuracy;
    AUC(1,stage) = auc_score;
end
