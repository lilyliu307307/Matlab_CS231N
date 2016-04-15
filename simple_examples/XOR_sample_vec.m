%% Vectorized XOR example
% Implement a simple Neural network to handle the XOR problem with a 3
% layer perceptron (MLP) with 2 neurons on the input, 2 on the hidden layer
% and 1 on the output, we also use bias.
%
% <</home/leo/work/Matlab_CS231N/docs/imgs/XOR_NeuralNetwork.txt.png>>
%
%
% Every neuron on this ANN is connected to 3 weights, 2 weights coming from
% other neurons connections plus 1 connection with the bias, you can
% consider this as a 9 parmeter function

%% Tutorials
% http://matlabgeeks.com/tips-tutorials/neural-networks-a-multilayer-perceptron-in-matlab/
%
% http://www.holehouse.org/mlclass/09_Neural_Networks_Learning.html
%
% http://github.com/rasmusbergpalm/DeepLearnToolbox
%
% http://ufldl.stanford.edu/wiki/index.php/Neural_Network_Vectorization
%
% http://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/
%
% http://github.com/stephencwelch/Neural-Networks-Demystified
%
% http://outlace.com/Beginner-Tutorial-Backpropagation/
%

%% Define training dataset
% XOR input for x1 and x2
X = [0 0; 0 1; 1 0; 1 1];
% Desired output of XOR
Y_train = [0;1;1;0];
sizeTraining = size(X,1);

%% Define the sigmoid and dsigmoid
% Define the sigmoid (logistic) function and it's first derivative
sigmoid = @(x) 1.0 ./ ( 1.0 + exp(-x) );
dsigmoid = @(x) sigmoid(x) .* ( 1 - sigmoid(x) );

%% Initialization of meta parameters
% Learning coefficient
learnRate = 2; % Start to oscilate with 15
regularization = 0.01;
% Number of learning iterations
epochs = 2000;
smallStep = 0.0001;

%% Define neural network structure
% More neurons means more local minimas, which means easier training and
% even if you get stuck on a local minima it's error will be close to the
% global minima (For large deep networks)
%
% Who is afraid of non convex loss-functions?
%
% http://videolectures.net/eml07_lecun_wia/
%
input_layer_size = 2;
hidden_layer_size = 2;
output_layer_size = 1;

%% Cost function definition
% On this case we will use the Cross entropy cost(or loss) function, the
% idea of the loss function is to give a number to show how bad/good your
% current set of parameters are. Here the definition of good means that our
% ANN output matches the training dataset
J_vec = zeros(1,epochs);
lossFunction = CrossEntropy();

%% Weights random initialization
% Initialize all the weights(parameters) of the neural network, layer by
% layer, the rule to create them is W(layer)=[next_layer X prev_layer+1].
% Where W1 is the layer that map the activations of the input layer to the
% hidden layer and W2 map the activations of the hidden layer to the output
%
% The way that the random values are distributed changes a lot the training
% performance, check chapter 3 on coursera (Weight initialization)
%
% http://neuralnetworksanddeeplearning.com/chap3.html#weight_initialization
%
%rand('state',0); % Put random number generator on state 0
% Same thing but new syntax
rng(0,'v5uniform');
INIT_EPISLON = 0.8;
W1 = rand(hidden_layer_size,input_layer_size+1) * (2*INIT_EPISLON) - INIT_EPISLON;
W2 = rand(output_layer_size,hidden_layer_size+1) * (2*INIT_EPISLON) - INIT_EPISLON;
% Override manually to debug both vectorized and non vectorized
% implementation
%W1 = [-0.7690    0.6881   -0.2164; -0.0963    0.2379   -0.1385];
%W2 = [-0.1433   -0.4840   -0.6903];

%% Training
for i = 1:epochs
    
    %%% Numeric estimation
    % Used to debug backpropagation, it will calculate numerically the
    % partial derivative of the cost function related to every
    % parameter, but much slower than backpropagation, just to have an
    % idea every time you have to calculate the partial derivative
    % related to one specific weight, you need to calculate the cost
    % function to every item on the training twice (J1,J2), and to
    % calculate the cost function you need to do foward propagation on
    % the whole network and this must be done every time the gradient
    % descent change the weight on the local minima direction
    %
    % <</home/leo/work/Matlab_CS231N/docs/imgs/GradientChecking.PNG>>
    %
    %
    % <</home/leo/work/Matlab_CS231N/docs/imgs/GradientChecking2.png>>
    %
    %
    % http://www.coursera.org/learn/machine-learning/lecture/Y3s6r/gradient-checking
    %
    Thetas = [W1(:) ; W2(:)];
    numgrad = zeros(size(Thetas));
    perturb = zeros(size(Thetas));    
    for p = 1:numel(Thetas)
        % Set perturbation vector
        perturb(p) = smallStep;
        ThetasLoss1 = Thetas - perturb;
        ThetasLoss2 = Thetas + perturb;
        
        % Loss 1
        % Reshape Theta on the W1,W2 format
        nW1 = reshape(ThetasLoss1(1:hidden_layer_size * ...
            (input_layer_size + 1)), hidden_layer_size, ...
            (input_layer_size + 1));
        nW2 = reshape(ThetasLoss1((1 + (hidden_layer_size * ...
            (input_layer_size + 1))):end), output_layer_size, ...
            (hidden_layer_size + 1));
        p_loss1 = sum(sum(nW1(:, 2:end).^2, 2))+sum(sum(nW2(:, 2:end).^2, 2));        
        
        % Forward prop
        A1 = [ones(sizeTraining, 1) X];
        Z2 = A1 * nW1';
        A2 = sigmoid(Z2);
        A2 = [ones(sizeTraining, 1) A2];
        Z3 = A2 * nW2';
        A3 = sigmoid(Z3);
        h1 = A3;
        
        % Loss 2
        % Reshape Theta on the W1,W2 format
        nW1 = reshape(ThetasLoss2(1:hidden_layer_size * ...
            (input_layer_size + 1)), hidden_layer_size, ...
            (input_layer_size + 1));
        nW2 = reshape(ThetasLoss2((1 + (hidden_layer_size * ...
            (input_layer_size + 1))):end), output_layer_size, ...
            (hidden_layer_size + 1));
        p_loss2 = sum(sum(nW1(:, 2:end).^2, 2))+sum(sum(nW2(:, 2:end).^2, 2));        
        
        % Forward prop
        A1 = [ones(sizeTraining, 1) X];
        Z2 = A1 * nW1';
        A2 = sigmoid(Z2);
        A2 = [ones(sizeTraining, 1) A2];
        Z3 = A2 * nW2';
        A3 = sigmoid(Z3);
        h2 = A3;
        
        % Calculate both losses...        
        loss1 = lossFunction.getLoss(h1,Y_train) + regularization*p_loss1/(2*sizeTraining);
        loss2 = lossFunction.getLoss(h2,Y_train) + regularization*p_loss2/(2*sizeTraining);
        
        % Compute Numerical Gradient
        numgrad(p) = (loss2 - loss1) / (2*smallStep);
        perturb(p) = 0;
    end
    numDeltaW1 = reshape(numgrad(1:hidden_layer_size * ...
        (input_layer_size + 1)), hidden_layer_size, ...
        (input_layer_size + 1));
    numDeltaW2 = reshape(numgrad((1 + (hidden_layer_size * ...
        (input_layer_size + 1))):end), output_layer_size, ...
        (hidden_layer_size + 1));
    
    %%% Backpropagation
    % Find the partial derivative of the cost function related to all
    % weights on the neural network (on our case 9 weights)
    
    %%% Forward pass
    % Move from left(input) layer to the right (output), observe that every
    % previous activation get a extra collumn of ones (Include Bias)
    %
    % First Activation (Input-->Hidden)
    A1 = [ones(sizeTraining, 1) X];
    Z2 = A1 * W1';
    A2 = sigmoid(Z2);
    
    % Second Activation (Hidden-->Output)
    A2=[ones(sizeTraining, 1) A2];
    Z3 = A2 * W2';
    A3 = sigmoid(Z3);
    h = A3;
    
    %%% Backward pass
    % Move from right(output) layer to the left (input), actually stopping
    % on the last hidden layer before the input. Here we want to calculate
    % the error of every layer (desired - actual). The trap here is that
    % you calculate the output layer differenly than the input layers
    %
    % Output layer: (Why different tutorials have differ here?)    
    %delta_out_layer = A3.*(1-A3).*(A3-Y_train); % Other
    %delta_out_layer = (Y_train-A3); % Andrew Ng
    delta_output = (A3-Y_train); % Andrew Ng (Invert weight update signal)
    
    % Hidden layer, same idea of adding collumn of ones to include bias
    Z2=[ones(sizeTraining,1) Z2];    
    % Observe that we use the delta of the next layer
    delta_hidden=delta_output*W2.*dsigmoid(Z2);
    
    % Take out first column (bias column), to force the complete delta
    % to have the same size of it's respective weight
    delta_hidden=delta_hidden(:,2:end);
    
    % Calculate complete delta for every weight
    complete_delta_1 = (delta_hidden'*A1);
    complete_delta_2 = (delta_output'*A2);
    
    % Computing the partial derivatives with regularization, here we're
    % avoiding regularizing the bias term by substituting the first col of
    % weights with zeros
    p1 = ((regularization/sizeTraining)* [zeros(size(W1, 1), 1) W1(:, 2:end)]);
    p2 = ((regularization/sizeTraining)* [zeros(size(W2, 1), 1) W2(:, 2:end)]);
    D1 = (complete_delta_1 ./ sizeTraining) + p1;
    D2 = (complete_delta_2 ./ sizeTraining) + p2;
    
    %%% Check backpropagation
    % Compare backpropagation partial derivatives with numerical gradients
    % We should do this check just few times. This is because calculating
    % the numeric gradient every time is heavy.
    errorBackPropD1 = sum(sum(abs(D1 - numDeltaW1)));
    errorBackPropD2 = sum(sum(abs(D2 - numDeltaW2)));
    % Stop if backpropagation error bigger than 0.0001
    if (errorBackPropD1 > 0.0001) || (errorBackPropD2 > 0.0001)
        fprintf('Backpropagation error %d %d\n',errorBackPropD1,errorBackPropD2);
        pause;
    end
    
    %%% Weight Update
    % Gradient descent Update after all training set deltas are calculated
    % Increment or decrement depending on delta_output sign
    % Stochastic Gradient descent Update at every new input....
    % The stochastic gradient descent with luck converge faster ...
    % Increment or decrement depending on delta_output sign
    W1 = W1 - learnRate*(D1);
    W2 = W2 - learnRate*(D2);
    
    %%% Calculate cost
    % After all calculations on the epoch are finished, calculate the cost
    % function between all your predictions (during) training and your
    % actual desired training output. The cost is a number representing how
    % well you are going on the training. For improving overfitting we also
    % include a regularization term that will avoid your training weights
    % get bigger values during training
    %
    % Calculate p (Regularization term)
    p = sum(sum(W1(:, 2:end).^2, 2))+sum(sum(W2(:, 2:end).^2, 2));
    % calculate Loss(or cost)    
    J = lossFunction.getLoss(h,Y_train) + regularization*p/(2*sizeTraining);
    
    %%% Early stop
    % Stop if error is smaller than 0.01
    J_vec(i) = J;
    % Break if error is already low
    if J < 0.01
        J_vec = J_vec(1:i);
        break;
    end
end

%% Plot some information
% Plot Prediction surface and Cost vs epoch curve
testInpx1 = [-1:0.1:1];
testInpx2 = [-1:0.1:1];
[X1, X2] = meshgrid(testInpx1, testInpx2);
testOutRows = size(X1, 1);
testOutCols = size(X1, 2);
testOut = zeros(testOutRows, testOutCols);
for row = [1:testOutRows]
    for col = [1:testOutCols]
        test = [X1(row, col), X2(row, col)];
        % Forward pass
        % First Activation (Input-->Hidden)
        A1 = [ones(1, 1) test];
        Z2 = A1 * W1';
        A2 = sigmoid(Z2);
        
        % Second Activation (Hidden-->Output)
        A2=[ones(1, 1) A2];
        Z3 = A2 * W2';
        A3 = sigmoid(Z3);
        testOut(row, col) = A3;
        
        % Print XOR table
        if isequal(test,[0 0]) || ...
                isequal(test,[0 1]) || ...
                isequal(test,[1 0]) || ...
                isequal(test,[1 1])
           fprintf('%d XOR %d ==> %d\n',test(1),test(2),round(A3)); 
        end
    end
end
figure(2);
surf(X1, X2, testOut);
title('Prediction surface');

figure(1);
plot(J_vec);
title('Cost vs epochs');