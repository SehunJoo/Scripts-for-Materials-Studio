%close all
%clear all
na=17;  % number of points of interpolation
nb=17;
 
%% Get data
%DELIMITER = ' ';
%field=importdata('ddpostprocess1.out',DELIMITER, HEADERLINES);
%data=field.data;
%[n,n2]=size(data);
clear x y z xx yy zz xmin xmax ymin ymax zmin zmax Xq Yq XXq YYq ZZq 

x=data(:,2); % a
y=data(:,3); % b
z=data(:,8); % Energy
z = z; % for 2L

xx=reshape(x,nb,na);
yy=reshape(y,nb,na);
zz=reshape(z,nb,na);

xmin = min(min(xx))
xmax = max(max(xx))
ymin = min(min(yy))
ymax = max(max(yy))
zmin = min(min(zz));
zmax = max(max(zz));

zz=zz-zmin;


Xq=linspace(xmin,xmax,1000)'
Yq=linspace(ymin,ymax,1000)'

[XXq,YYq] = meshgrid(Xq,Yq);



ZZq = interp2(xx,yy,zz,XXq,YYq,'spline');
ZZq=ZZq-min(min(ZZq));

%%
% Figure 생성
figure1 = figure
colormap('jet');

% axes 생성
axes1 = axes('Parent',figure1);
axis off
hold(axes1,'on');

surface(xx,yy,zz,'MarkerFaceColor','none','MarkerEdgeColor','none','MarkerSize',1,'Marker','o','LineWidth',0.1,'EdgeColor','none')
%surface(xx,yy,zz,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerSize',1,'Marker','o','LineWidth',0.1,'EdgeColor','none')
%shading interp
xlabel('displacement along a (Angstrom)')
ylabel('displacement along b (Angstrom)')
zlabel('z')

%caxis([min(z), max(z)])

figure2 = figure
surface(xx,yy,zz,'MarkerFaceColor','none','MarkerEdgeColor','none','MarkerSize',1,'Marker','o','LineWidth',0.1,'EdgeColor','none')
%surface(xx,yy,zz,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerSize',1,'Marker','o','LineWidth',0.1,'EdgeColor','none')
shading interp
xlabel('displacement along a (Angstrom)')
ylabel('displacement along b (Angstrom)')
zlabel('z')
colormap('jet');
%caxis([min(z), max(z)])


fIgure3 = figure;
surface(XXq,YYq,ZZq,'MarkerFaceColor','none','MarkerEdgeColor','none','MarkerSize',1,'Marker','o','LineWidth',0.1,'EdgeColor','none')
%surface(XXq,YYq,ZZq,'MarkerFaceColor',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerSize',1,'Marker','o','LineWidth',0.1,'EdgeColor','none');
%shading interp
axis tight;
axis off;
colormap('jet');
%caxis([min(z), max(z)])
