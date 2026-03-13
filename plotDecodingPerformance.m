function []=plotDecodingPerformance(decodingNumbers,plotOption)
% decodingNumbers is structure with means and errors of decoding performance for all
% task variables. plotOption is self-decoding(1), or cross-decoding(2)

if plotOption==1

    figure;
    hold on;
    % x pos (gold)
    h=plot([decodingNumbers.xpos(1,:)-decodingNumbers.sxpos(1,:);decodingNumbers.xpos(1,:)+decodingNumbers.sxpos(1,:)],[decodingNumbers.xpos(2,:);decodingNumbers.xpos(2,:)],'k-');
    set(h,'linewidth',1);
    h=plot(decodingNumbers.xpos(1,:),decodingNumbers.xpos(2,:),'k^','MarkerSize',13,"LineWidth",1.8);
    set(h,'markerfacecolor',"#FFC20A");
    % y pos (blue)
    h=plot([decodingNumbers.ypos(1,:)-decodingNumbers.sypos(1,:);decodingNumbers.ypos(1,:)+decodingNumbers.sypos(1,:)],[decodingNumbers.ypos(2,:);decodingNumbers.ypos(2,:)],'k-');
    set(h,'linewidth',1)
    h=plot(decodingNumbers.ypos(1,:), decodingNumbers.ypos(2,:),'k^','MarkerSize',13,"LineWidth",1.8);
    set(h,'markerfacecolor',"#0C7BDC")
    % rew dist (green)
    h=plot([decodingNumbers.rewdist(1,:)-decodingNumbers.srewdist(1,:);decodingNumbers.rewdist(1,:)+decodingNumbers.srewdist(1,:)],[decodingNumbers.rewdist(2,:);decodingNumbers.rewdist(2,:)],'k-');
    set(h,'linewidth',1.5)
    h=plot(decodingNumbers.rewdist(1,:), decodingNumbers.rewdist(2,:),'k^','MarkerSize',13,"LineWidth",1.8);
    set(h,'markerfacecolor',"#1AFF1A")
    % rew loc (pink)
    h=plot([decodingNumbers.config(1,:)-decodingNumbers.sconfig(1,:);decodingNumbers.config(1,:)+decodingNumbers.sconfig(1,:)],[decodingNumbers.config(2,:);decodingNumbers.config(2,:)],'k-');
    set(h,'linewidth',1.5)
    h=plot(decodingNumbers.config(1,:), decodingNumbers.config(2,:),'k^','MarkerSize',13,"LineWidth",1.8);
    set(h,'markerfacecolor',"#D35FB7")
    plot([-.2 1],[-.2 1],'k--',"LineWidth",1.8)
    marleneaxes
    axis([-.2 1 -.2 1])
    plot([0 0],[-.2 1],'k--',"LineWidth",1.8)
    plot([-.2 1],[0 0],'k--',"LineWidth",1.8)
    axis square
    ylabel('infrequent')
    xlabel({'correlation coefficient','frequent'});
    title('task-variable decoding','correlation b/w actual and predicted');
    set(gca,'FontSize',14);


elseif plotOption==2

    figure;
    hold on;
    % x and y
    h=plot(decodingNumbers.crossXY(1,:),decodingNumbers.crossXY(2,:)','k^','MarkerSize',13,"LineWidth",1.8,...
        'MarkerEdgeColor',"#0C7BDC"); % blue outline
    set(h,'markerfacecolor',"#FFC20A"); % gold inside
    % reward distnace and location
    h=plot(decodingNumbers.crossLD(1,:),decodingNumbers.crossLD(2,:)','k^','MarkerSize',13,"LineWidth",1.8,...
        'markeredgecolor',"#D35FB7"); % pink outline
    set(h,'markerfacecolor',"#1AFF1A"); % green inside
    plot([0 .5],[0 .5],'k--',"LineWidth",1.7)
    marleneaxes
    axis([0 .5 0 .5])
    xlabel({'correlation coefficient','frequent'});
    ylabel('infrequent');
    title('cross-decoding all task variable pairs');
    axis square
    set(gca,'FontSize',15);



end

end