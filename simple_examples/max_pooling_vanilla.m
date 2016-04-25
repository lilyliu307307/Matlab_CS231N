%% Vanila Max pooling with n-dimensions
% Parameters:
% F: Kernel size
% S: stride

function outConv = max_pooling_vanila(input, F, S)
%% Get the input size in terms of rows and cols
[rowsIn, colsIn, numDims] = size(input);

kernel = ones(F,F);

%% Initialize outputs to have the same size of the input
sizeRowsOut = ((rowsIn-F)/S) + 1;
sizeColsOut = ((colsIn-F)/S) + 1;
outConv = zeros(sizeRowsOut , sizeColsOut, numDims);

%% Get kernel size
[rowsKernel, colsKernel] = size(kernel);

%% Initialize a sampling window
window = zeros(rowsKernel , colsKernel);

%% Sample the input signal to form the window
% Iterate on every dimension
for idxDims=1:numDims
    %paddedInput = padarray(input(:,:,idxDims),[num2Pad num2Pad]);
    paddedInput = input(:,:,idxDims);
    % Iterate on every element of the input signal
    % Iterate on every row
    for idxRowsIn = 1 : sizeRowsOut
        % Iterate on every col
        for idxColsIn = 1 : sizeColsOut
            % Populate our window (same size of the kernel)
            for idxRowsKernel = 1 : rowsKernel
                for idxColsKernel = 1 : colsKernel
                    % Slide the window
                    slideRow = (idxRowsIn-1)*S;
                    slideCol = (idxColsIn-1)*S;
                    
                    % Sample the window, but avoid going out of the input
                    if (idxRowsKernel + slideRow) <= size(paddedInput,1) && idxColsKernel + slideCol <= size(paddedInput,2)
                        window(idxRowsKernel,idxColsKernel) = ...
                            paddedInput(idxRowsKernel + slideRow, idxColsKernel + slideCol);
                    end                    
                end
            end
            % Calculate the convolution here...
            outConv(idxRowsIn, idxColsIn,idxDims) = getMax(window,kernel);
        end
    end
end

%% Moving window effect
% The previous inner for loop updates the variables slideRow, and slideCol
% those updates will create the following effect
%
% <<../../docs/imgs/3D_Convolution_Animation.gif>>
%

end

%% Get the biggest value on the (window .* kernel(ones))
% The convolution is all about the sum of product of the window and kernel,
% bye the way this is a dot product
function result = getMax(window, kernel)
result = max(max(window .* kernel));
end