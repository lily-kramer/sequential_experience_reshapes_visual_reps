function result = orderedCCGP_ABCD(data)
% data{1}=A, {2}=B, {3}=C, {4}=D

assert(numel(data) == 4, 'Requires exactly 4 conditions');

%% Condition means
mu = cellfun(@(x) mean(x,1), data, 'UniformOutput', false);
mu = cat(1, mu{:});
mu0 = mu - mean(mu,1);

%% Rank-1 fraction
[~, S, ~] = svd(mu0, 'econ');
rank1Frac = S(1,1)^2 / sum(diag(S).^2);

%% Ordered generalization
pairs = [1 2; 2 3; 3 4];
acc = nan(size(pairs,1),1);

for i = 1:size(pairs,1)
    i1 = pairs(i,1);
    i2 = pairs(i,2);
    testIdx = setdiff(1:4, [i1 i2]);

    acc(i) = trainTestOrdered( ...
        data{i1}, data{i2}, ...
        vertcat(data{testIdx(1)}, data{testIdx(2)}) );
end

%% Output
result.orderedCCGP = mean(acc);
result.rank1Frac   = rank1Frac;
result.perSplitAcc = acc;

end
