clf; clc; clear; close all;load_RPlex;
% Initialize the global enviroment.
import edu.stanford.math.plex4.*;
% We give each run a unique temporary file name as signature.
simulation_signature = char(floor(25*rand(1, 7)) + 65);
% This implementation is based on vietoris_rips_example.m in JavaPlex4.
% The maximum epsilon value of Vietoris-Rips filtration we shall implement.
max_filtration_value = 1;
% This is how many steps from 0 to 1.
num_divisions = 20;
probability_ratio = [1 1 4];
scaling_factor = [1 1 1];
total_runs=1000;
thinning=100;
bin_scale = 0.25;
% create the set of points
% n = 10;
% point_cloud = examples.PointCloudExamples.getRandomSpherePoints(n, dimension);
% addpath('C:\Program Files\R\R-3.4.1\bin\');
% If the Rpath is not set up appropriately, we need to include the full
% lengthy set path commands.
Rpath = 'C:\Program Files\R\R-3.4.1\bin';
% Use the scaled iterative function system to generate a dataset.
fid = fopen('Rargs_Gen.data','wt');
fprintf(fid,num2str(probability_ratio));
fprintf(fid,'\n');
fprintf(fid,num2str(scaling_factor));
fprintf(fid,'\n');
fprintf(fid,num2str(total_runs));
fprintf(fid,'\n');
fprintf(fid,num2str(thinning));
fprintf(fid,'\n');
fclose(fid);

RscriptFileName = 'rIFS.R'; 
RunRcode(RscriptFileName, Rpath);
% Use the binning scheme to sparsify the point_cloud
fid = fopen('Rargs.data','wt');
fprintf(fid,num2str(bin_scale));
fprintf(fid,'\n');
fprintf(fid,simulation_signature);
fprintf(fid,'\n');
fclose(fid);

RscriptFileName = 'IFS_bin.R'; 
RunRcode(RscriptFileName, Rpath); 

% Table object is more like R's dataframe object and is supported since
% MATLAB2013. We highly prefer this kind of data.
csv_data = readtable(strcat('tmp_bin.csv'));
point_cloud = table2array(csv_data(:,{'V1','V2'}));
% automatically detect the size of the table.
[n,dimension] = size(point_cloud);
dimension = dimension-1;
csvwrite(strcat('BinnedData_',simulation_signature,'.csv'),point_cloud);
% Before we invoke computation, we need to somehow have a visual image of
% the data, depending on its dimension we implement scatter plots in
% different dimensions correspondingly.
% if dimension<=1 
%     scatter(point_cloud(:,1),point_cloud(:,2),'filled');
% elseif dimension==2
%     scatter3(point_cloud(:,1),point_cloud(:,2),point_cloud(:,3),'filled');
% end     
% saveas(gcf,strcat('Data_Plot_',simulation_signature,'.png'));


% create a Vietoris-Rips stream, since the dimension till dimension + 1 can
% be calcualted, the stream shall consider up to dimension + 1.
stream = api.Plex4.createVietorisRipsStream(point_cloud, dimension + 1, max_filtration_value, num_divisions);


% get the default persistence algorithm
persistence = api.Plex4.getDefaultSimplicialAlgorithm(dimension + 1);

% compute intervals
intervals = persistence.computeIntervals(stream);

% create the barcode plots
options.filename = strcat('PH_Plot_',simulation_signature,'.png');
options.max_filtration_value = max_filtration_value;
options.caption=strcat('Barcode,','Step long=',num2str(max_filtration_value/num_divisions));
options.line_width=2;
plot_barcodes(intervals, options);
% use my implementation of Persistent Rank Function module, we can obtain a
% matrix of persistent rank function of dim 1 with specified range
% [0.8,1.5] at steplong 0.1.
grid_range=[0,max_filtration_value];
grid_increment=max_filtration_value/num_divisions;

% PRF plot for Betti number of order 0.
PRF_matrix=plotPRF(point_cloud,0,grid_range,grid_increment);
im = figure;
clf;
xr=grid_range+0.000001;
yr=grid_range+0.000001;
im = imagesc(xr+.5*grid_increment,yr+.5*grid_increment,PRF_matrix);
colorbar;
step_num=round( diff(grid_range)/grid_increment );
set(gca,'XTick',[0:step_num]*grid_increment,'YTick',[0:step_num]*grid_increment,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
xticklabels([0,[0:step_num]*grid_increment]);
yticklabels([0,[0:step_num]*grid_increment]);
xlabel('\beta(\beta\geq\alpha)');
ylabel('\alpha');
title('Plot of PRF order 0 (Betti_0)');
grid on;
hold on;
saveas(im,strcat('PRF_Plot_0_',simulation_signature,'.png'));
csvwrite(strcat('PRF_CSV_0_',simulation_signature,'.csv'),PRF_matrix);

% PRF plot for Betti number of order 1.
PRF_matrix=plotPRF(point_cloud,1,grid_range,grid_increment);
im = figure;
clf;
xr=grid_range+0.000001;
yr=grid_range+0.000001;
im = imagesc(xr+.5*grid_increment,yr+.5*grid_increment,PRF_matrix);
colorbar;
step_num=round( diff(grid_range)/grid_increment );
set(gca,'XTick',[0:step_num]*grid_increment,'YTick',[0:step_num]*grid_increment,'XAxisLocation','top','YAxisLocation','left','ydir','reverse');
xticklabels([0,[0:step_num]*grid_increment]);
yticklabels([0,[0:step_num]*grid_increment]);
xlabel('\beta(\beta\geq\alpha)');
ylabel('\alpha');
title('Plot of PRF order 1 (Betti_1)');
grid on;
hold on;
saveas(im,strcat('PRF_Plot_1_',simulation_signature,'.png'));
csvwrite(strcat('PRF_CSV_1_',simulation_signature,'.csv'),PRF_matrix);

RscriptFileName = 'R_wrap.R'; 
RunRcode(RscriptFileName, Rpath); 

p = profile('info');
save(strcat('Profile_',simulation_signature,'.mat'), 'p');
