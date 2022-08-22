function prediction = predict(EMG, threshold, window, NARX)
    Aci = load(sprintf('FD-%d.mat', window));
    assignin('base', 'Aci', Aci);
    Xci = load(sprintf('ID-%d.mat', window));
    EMGfilter = dfilter(EMG);
    feature = extractEMG(EMGfilter, threshold, window);
    X = tonndata(feature.ft,false,false);
    prediction = NARX(X,Xci.Xci,Aci.Aci);
    prediction = cell2mat(prediction');
    for i = 1:length(prediction)
        if prediction(i) < 0
            prediction(i) = 0;
        end
    end