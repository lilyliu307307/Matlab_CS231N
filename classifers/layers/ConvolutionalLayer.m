classdef ConvolutionalLayer < BaseLayer
    %FULLYCONNECTEDLAYER Define the convolutional layer
    %   Actually this is the normal hidden layer on Neural Networks
    % More information:
    % http://www.slideshare.net/deview/251-implementing-deep-learning-using-cu-dnn
    
    properties
        typeLayer
    end
    
    properties (Access = 'private')
        activationObject
        kernelSize
        numFilters
        stepStride
        numPad
    end
    
    methods (Access = 'public')
        function obj = ConvolutionalLayer(pKernelSize, pFilters, pStride, pPad, pActType)
            % Initialize type
            obj.typeLayer = LayerType.Convolutional;
            obj.kernelSize = pKernelSize;
            obj.numFilters = pFilters;
            obj.stepStride = pStride;
            obj.numPad = pPad;
            
            switch pActType
                case ActivationType.Sigmoid
                    obj.activationObject = SigmoidActivation();
                case ActivationType.Tanh
                    obj.activationObject = TanhActivation();
                case ActivationType.Relu
                    obj.activationObject = ReluActivation();
                otherwise
                    obj.activationObject = SigmoidActivation();
            end
        end
        
        function [result] = feedForward(obj, inputs)
            result = 0;
        end
        
        function [gradient] = backPropagate(obj, targets)
            gradient = 0;
        end
        
        function [result] = getData(obj)
            result = 0;
        end
        
        function [type] = getType(obj)
            type = obj.typeLayer;
        end
        
        function [numN] = getKernelSize(obj)
            numN = obj.kernelSize;
        end
        
        function [numN] = getNumberOfFilters(obj)
            numN = obj.numFilters;
        end
        
        function [numN] = getStride(obj)
            numN = obj.stepStride;
        end
        
        function [numN] = getPad(obj)
            numN = obj.numPad;
        end
        
        function [actFunc] = getActivation(obj)
            actFunc = obj.activationObject;
        end
    end
end
