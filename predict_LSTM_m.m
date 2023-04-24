rng('default');
%LF = (label==4)+(label==6);
%label = label(LF==1);
%sequence = sequence(LF==1,:,:);
ACC = zeros(1,61);
for ac = 61
    sequences = cell(size(sequence,1),1);
    labels = categorical(label);
    for i = 1:size(sequence,1)
        sequences{i,1} = permute(sequence(i,:,16:61),[2 3 1]);
    end
    
    numObservations = numel(sequences);
    idx = randperm(numObservations);
    N1 = floor(0.7 * numObservations);
    N2 = floor(0.9 * numObservations);%ori 0.9
    
    idxTrain = idx(1:N1);
    sequencesTrain = sequences(idxTrain);
    labelsTrain = labels(idxTrain);
    
    idxValidation = idx(N1+1:N2);
    sequencesValidation = sequences(idxValidation);
    labelsValidation = labels(idxValidation);

    idxTesting = idx(N2+1:end);
    sequencesTesting = sequences(idxTesting);
    labelsTesting = labels(idxTesting);
    
    numFeatures = size(sequencesTrain{1},1);
    numClasses = numel(categories(labelsTrain));
    
    layers = [
        sequenceInputLayer(numFeatures,'Name','sequence')
        bilstmLayer(2000,'OutputMode','last','Name','bilstm')
        dropoutLayer(0.5,'Name','drop')
        fullyConnectedLayer(numClasses,'Name','fc')
        softmaxLayer('Name','softmax')
        classificationLayer('Name','classification')];
    
    miniBatchSize = 32;
    numObservations = numel(sequencesTrain);
    numIterationsPerEpoch = floor(numObservations / miniBatchSize);
    
    options = trainingOptions('adam', ...
        'MaxEpochs',30,...
        'MiniBatchSize',miniBatchSize, ...
        'InitialLearnRate',1e-4, ...
        'GradientThreshold',2, ...
        'Shuffle','every-epoch', ...
        'ValidationData',{sequencesValidation,labelsValidation}, ...
        'ValidationFrequency',numIterationsPerEpoch, ...
        'Plots','training-progress', ...
        'Verbose',false);
    
    [netLSTM,info] = trainNetwork(sequencesTrain,labelsTrain,layers,options);
    
    YPred = classify(netLSTM,sequencesTesting,'MiniBatchSize',miniBatchSize);
    YValidation = labelsTesting;
    accuracy = mean(YPred == YValidation)
    ACC(1,ac) = accuracy;
end