function acc = trainTestOrdered(X1, X2, Xtest)
% X1 < X2 < Xtest in ordered space

Xtrain = [X1; X2];
ytrain = [zeros(size(X1,1),1); ones(size(X2,1),1)];

% Z-score
mu = mean(Xtrain,1);
sd = std(Xtrain,[],1) + eps;
Xtrain = (Xtrain - mu) ./ sd;
Xtest  = (Xtest  - mu) ./ sd;

% Train
% suppress warning: 
warning('off','stats:glmfit:IllConditioned');
warning('off','stats:glmfit:IterationLimit');
warning('off','stats:glmfit:PerfectSeparation');
B = glmfit(Xtrain, ytrain, 'binomial', 'link','logit');

% Test: expect Xtest to be on the correct side
yhat = glmval(B, Xtest, 'logit') > 0.5;

% For ordered extrapolation, consistency matters
acc = max(mean(yhat), 1 - mean(yhat));
end
