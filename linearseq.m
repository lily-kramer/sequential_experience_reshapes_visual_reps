function [SSE,slope,pslope,intercept] = linearseq(A, B, C, D)

[~, numtrials] = size(A);

SSE = NaN(1, numtrials);

for i = 1:numtrials
    % Collect the 4 points for this trial as columns
    X = [A(:,i), B(:,i), C(:,i), D(:,i)];   % [numneurons x 4]

    % Compute mean and center data
    mu = mean(X, 2);                        % [numneurons x 1]
    Xc = X - mu;                            % centered data

    % SVD to get principal direction (best-fit line)
    [~, S, ~] = svd(Xc, 'econ');

    % First left-singular vector is line direction; S(2:end,2:end) carry residual variance
    % Orthogonal residual sum of squares = sum of squared singular values except first
    singvals = diag(S);
    SSE(i) = sum(singvals(2:end).^2);
end

SSE = SSE(:);                          % ensure column

trialIdx = (1:numtrials)';             % predictor = trial number

mdl = fitlm(trialIdx, SSE);            % simple linear regression [web:35]

% Extract slope and its p-value
slope   = mdl.Coefficients.Estimate(2);    % coefficient for trialIdx [web:35]
pslope = mdl.Coefficients.pValue(2);      % p-value for H0: slope = 0 [web:29]
intercept=mdl.Coefficients.Estimate(1);