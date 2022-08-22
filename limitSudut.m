function [sudut] = limitSudut(sudut,lower,upper)
    if (nargin < 3) || isempty(upper)
        for i = 1:length(sudut)
            if sudut(i) < lower
                sudut(i) = lower;
            end
        end
    else
        for i = 1:length(sudut)
            if sudut(i) < lower
                sudut(i) = lower;
            elseif sudut(i) > upper
                sudut(i) = upper;
            end
        end
    end
end