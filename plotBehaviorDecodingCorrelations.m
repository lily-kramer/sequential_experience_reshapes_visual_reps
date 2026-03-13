function []=plotBehaviorDecodingCorrelations(decodingDiff,behaviorDiff,R)
% plot the correlation b/w difference in behavioral measures and difference
% in decoding over frequent and infrequent trials for each session. For
% supplemental figure 2.

    figure;
    hold on;
    plot(decodingDiff,behaviorDiff,'k^','MarkerFaceColor',...
        [0.4 0.4 0.4],'LineWidth',1.1,'MarkerSize',12);
    xlabel({'decoding perf. difference','frequent better                           frequent worse'});
    ylabel({'time to complete difference','frequent slower                          frequent faster'});
    set(gca,'FontSize',12);
    xline(0,'LineWidth',0.7);
    yline(0,'LineWidth',0.7);
    txt=['r = ' num2str(R)];
    text(-0.35,-0.25,txt,'FontSize',13);
    legend('one session','FontSize',13);
     xlim([-0.4 0.3]);
    axis square


end