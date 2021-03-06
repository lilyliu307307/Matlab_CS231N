classdef SquareErrorLoss < BaseLossFunction
    % Square Error Loss implementation class    
        
    methods                
        % Here the smalles value will be zero (Perfect, no loss) and the
        % biggest value is unbounded
        function [lossResult, dw] = getLoss(obj, scores, correct)
                                    
            lossResult = sum((scores - correct).^2);
            lossResult = lossResult / 2;
            
            % Derivative of loss related to the scores
            dw = scores - correct;
        end
    end
end

