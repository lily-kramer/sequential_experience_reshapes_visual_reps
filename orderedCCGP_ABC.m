function result = orderedCCGP_ABC(data)
% data{1}=A, data{2}=B, data{3}=C
% each: trials x neurons

assert(numel(data) == 3, 'Requires exactly 3 conditions');

%% Compute condition means
mu = cellfun(@(x) mean(x,1), data, 'UniformOutput', false);
mu = cat(1, mu{:});  % 3 x neurons

%% Center
mu0 = mu - mean(mu,1);

%% Rank-1 score (variance explained by first PC)
[~, S, ~] = svd(mu0, 'econ');
rank1Frac = S(1,1)^2 / sum(diag(S).^2);

%% Ordered generalization tests
acc = nan(2,1);

% Test 1: train A vs B, test on C
acc(1) = trainTestOrdered(data{1}, data{2}, data{3});

% Test 2: train B vs C, test on A
acc(2) = trainTestOrdered(data{2}, data{3}, data{1});

%% Output
result.orderedCCGP = mean(acc);
result.rank1Frac   = rank1Frac;
result.perSplitAcc = acc;

end
