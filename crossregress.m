function[cors,axiscors]=crossregress(counts,groups,plotflg)
%counts is numneurons x nummoves
%groups is numaxes x nummoves
%plotflg is 1 if you want to plot the results
%cors is numaxesxnumaxes matrix of correlations between projections onto
%one axis (columns) and the actual values in groups (rows)
%axiscors is numaxesxnumaxes matrix of correlations between the rows of
%groups

% suppress warning:
warning('off', 'stats:regress:RankDefDesignMat');

if nargin<3, plotflg=1; end

%deal with nans
good=find(isfinite(sum(counts)));
counts=counts(:,good);
groups=groups(:,good);

nummoves=size(counts,2);
numaxes=size(groups,1);

groups=nanzscore(groups);

proj=NaN(numaxes,nummoves);
for i=1:nummoves
    this=1:nummoves;
    this(i)=nan;
    this=this(isfinite(this));
    icounts=counts(:,i);
    thiscounts=counts(:,this);
    for ax=1:numaxes
        B=regress(groups(ax,this)',[thiscounts; ones(1,nummoves-1)]');
        proj(ax,i)=[icounts; ones(1,1)]'*B;
    end
end

cors=NaN(numaxes,numaxes);
for i=1:numaxes
    g=groups(i,:);
    for j=1:numaxes
        p=proj(j,:);
        cors(i,j)=mccorrcoef(g,p);
    end
end

axiscors=corrcoef(groups');

%plot correlations between projections onto each axis 
if plotflg
    figure;
    imagesc(cors) 
    set(gca,'ydir','normal')
    xlabel('axis of actual values')
    ylabel('axis onto which neural responses were projected')
    m=max(max(cors));
    set(gca,'clim',[-m m])
    colorbar
    colormap(cmap_posneg_yck_linear)
    axis square
end

