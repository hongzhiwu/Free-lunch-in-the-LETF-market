%%%%%%%%treading strategy
clear;
Date = xlsread('SPY_SSO_OPTION.xlsx','SPY_0116','A2:A220');
a = datenum(2015,1,2);
Date = Date+a-Date(1);
Date = datevec(Date);
Date = Date(:,1:3);

SPY =  xlsread('SPY_SSO_OPTION.xlsx','SPY_0116','B2:IS220');
SPY_K = SPY(:,1:3:end);
SPY_C = SPY(:,2:3:end);
SPY_Vol = SPY(:,3:3:end);
SPY_L = xlsread('SPY_SSO_OPTION.xlsx','SPY_price','G2:G220');

SSO =  xlsread('SPY_SSO_OPTION.xlsx','SSO_0116','B2:EF220');
SSO_K = SSO(:,1:3:end);
SSO_C = SSO(:,2:3:end);
SSO_Vol = SSO(:,3:3:end);
SSO_L = xlsread('SPY_SSO_OPTION.xlsx','SSO_price','G2:G220');
alpha = log(SSO_L)./log(SPY_L);

T = length(alpha);
SPY_K_2use = zeros(size(SSO_K));
for i = 1:T;
    SPY_K_2use(i,:) = sqrt(SSO_K(i,:)./SPY_L(i)^(alpha(i)-2));
end
SPY_K_2use = round(SPY_K_2use);
SPY_C_2use = -999*ones(size(SSO_C));
SPY_Vol_2use = -999*ones(size(SSO_C)); 
for t = 1:T;
    for k = 1:size(SPY_K_2use,2);
        for j = 1: size(SPY_K,2);
            if SPY_K_2use(t,k) == SPY_K(t,j);
                SPY_C_2use(t,k) = SPY_C(t,j);
                SPY_Vol_2use(t,k) = SPY_Vol(t,j);
            end
        end
    end
end
for i= 1:T;
    v = find(SPY_C_2use(i,:)~=-999);
    L1(i).K = SPY_K_2use(i,v);
    L1(i).C = SPY_C_2use(i,v);
    L1(i).Vol = SPY_Vol_2use(i,v);
    L2(i).K = SSO_K(i,v);
    L2(i).C = SSO_C(i,v);
    L2(i).Vol = SSO_Vol(i,v);
end
k = 0;
for i = 1:T;
    Result(i).INV = - SPY_L(i)...
        +L1(i).C...
        +SPY_L(i)^2./L1(i).K...
        -L2(i).C*SPY_L(i)^(2-alpha(i))./L1(i).K;
    v = find(Result(i).INV>=0);
    Result(i).index = v;
    Result(i).K1 = L1(i).K(v);
    Result(i).K2 = L2(i).K(v);
    Result(i).C1 = L1(i).C(v);
    Result(i).C2 = L2(i).C(v);
    Result(i).Vol1 = L1(i).Vol(v);
    Result(i).Vol2 = L2(i).Vol(v);
    Result(i).profit = Result(i).INV(v);
    if sum(v)~=0;
        k = k+1;
        RR(k).Date = Date(i,:);
        RR(k).index = v;
        RR(k).L1 = SPY_L(i);
        RR(k).L2 = SSO_L(i);
        RR(k).K1 = L1(i).K(v);
        RR(k).K2 = L2(i).K(v);
        RR(k).C1 = L1(i).C(v);
        RR(k).C2 = L2(i).C(v);
        RR(k).Vol1 = L1(i).Vol(v);
        RR(k).Vol2 = L2(i).Vol(v)
        RR(k).share2 = SPY_L(i)^(2-alpha(i))./RR(k).K1;
        RR(k).profit = Result(i).INV(v);
    end
end
%%%%%%%%%
for k = 1:length(RR);
    h = figure;
    set (gcf,'Position',[200,100,900,600])
    str = [num2str(RR(k).Date(1)),'/',num2str(RR(k).Date(2)),'/',num2str(RR(k).Date(3))];
    subplot(3,1,2)
    plot(RR(k).K1,RR(k).K2,'o','MarkerSize',8,'MarkerEdgeColor','r',...
        'MarkerFaceColor',[1,0.0,0.0])
    set(gca,'FontName','Times New Roman','FontSize',24)
    xlim([130 200])
    ylim([27 61])
    xlabel('K_{1}')
    ylabel('K_{2}')
    %title(str)
    for i = 1:length(RR(k).K1);
        hold on
        plot([RR(k).K1(i),RR(k).K1(i)],[0,RR(k).K2(i)])
    end
    subplot(3,1,1)
    plot(RR(k).K1,RR(k).share2,'d','MarkerSize',8,'MarkerEdgeColor','b',...
        'MarkerFaceColor',[0,0.6,0])
    set(gca,'FontName','Times New Roman','FontSize',24)
    xlim([130 200])
    ylim([3 5])
    xlabel('K_{1}')
    ylabel('Share of L_2')
    title(str)
    for i = 1:length(RR(k).K1);
        hold on
        plot([RR(k).K1(i),RR(k).K1(i)],[0,RR(k).share2(i)])
    end   
    subplot(3,1,3);
    plot(RR(k).K1,RR(k).profit,'s','MarkerSize',8,'MarkerEdgeColor','b',...
        'MarkerFaceColor',[0,0.0,1])
    set(gca,'FontName','Times New Roman','FontSize',24)
    xlim([130 200])
    ylim([0 5.2])
    xlabel('K_{1}')
    ylabel('Initial profit')
    %title(str)
    for i = 1:length(RR(k).K1);
        hold on
        plot([RR(k).K1(i),RR(k).K1(i)],[0,RR(k).profit(i)])
    end
    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(h,['Profit_',num2str(k)],'-dpdf','-r0')
    close;
end
for k = 1:length(RR);
    h = figure;
    set (gcf,'Position',[200,100,900,600])
    str = [num2str(RR(k).Date(1)),'/',num2str(RR(k).Date(2)),'/',num2str(RR(k).Date(3))];
    plot(RR(k).K1/RR(k).L1,RR(k).Vol1,'o','MarkerSize',8,'MarkerEdgeColor','r',...
        'MarkerFaceColor',[1,0.0,0.0])
    hold on
    plot(RR(k).K2/RR(k).L2,RR(k).Vol2,'o','MarkerSize',8,'MarkerEdgeColor','b',...
        'MarkerFaceColor',[0,0.0,1.0])
    set(gca,'FontName','Times New Roman','FontSize',24)
    xlim([0.4 1])
    ylim([0.1 0.9])
    xlabel('k= K/L')
    ylabel('Implied vol')
    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(h,['IV_',num2str(k)],'-dpdf','-r0')
    close;
end
