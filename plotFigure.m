function plotFigure(xAxis1,xAxis2,yAxis1,yAxis2,titles,...
    label1,label2,sameYAxis)

    if (nargin < 2) || isempty(xAxis2), xAxis2 = xAxis1; end
    if (nargin < 8) || isempty(sameYAxis)
        figure
        yyaxis left
        plot(xAxis1, yAxis1)
        ylabel('Amplitude (V)')
        yyaxis right
        plot(xAxis2, yAxis2)
        title(titles);
        xlabel('Frekuensi (Hz)')
        leg = legend(label1, label2);
        leg.ItemHitFcn = @legendToggle;
    elseif sameYAxis == "true"
        figure
        plot(xAxis1, yAxis1)
        ylabel('Amplitude (V)')
        hold on
        plot(xAxis2, yAxis2)
        title(titles);
        xlabel('Frekuensi (Hz)')
        leg = legend(label1, label2);
        leg.ItemHitFcn = @legendToggle;
    else
        error(['Unrecognized last argument input. Accepted argument:' ...
            ' "true" or no input'])
    end
    
end