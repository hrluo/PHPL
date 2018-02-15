clc; clear; close all;
% Initialize the global enviroment.
import edu.stanford.math.plex4.*;
% We give each run a unique temporary file name as signature.
simulation_signature = char(floor(25*rand(1, 7)) + 65);
% This implementation is based on vietoris_rips_example.m in JavaPlex4.
% The maximum epsilon value of Vietoris-Rips filtration we shall implement.
max_filtration_value = 1;
% This is how many steps from 0 to 1.3
num_divisions = 5;
% create the set of points
% n = 10;
% point_cloud = examples.PointCloudExamples.getRandomSpherePoints(n, dimension);

% Table object is more like R's dataframe object and is supported since
% MATLAB2013. We highly prefer this kind of data.
csv_data = readtable('tmp.csv');
point_cloud = table2array(csv_data(:,{'V1','V2'}));
% automatically detect the size of the table.
[n,dimension] = size(point_cloud);
dimension = dimension-1;
csvwrite(strcat('Data_CSV_',simulation_signature,'.csv'),point_cloud);
% Before we invoke computation, we need to somehow have a visual image of
% the data, depending on its dimension we implement scatter plots in
% different dimensions correspondingly.
if dimension<=1 
    scatter(point_cloud(:,1),point_cloud(:,2),'filled');
elseif dimension==2
    scatter3(point_cloud(:,1),point_cloud(:,2),point_cloud(:,3),'filled');
end     
saveas(gcf,strcat('Data_Plot_',simulation_signature,'.png'));


% create a Vietoris-Rips stream, since the dimension till dimension + 1 can
% be calcualted, the stream shall consider up to dimension + 1.
stream = api.Plex4.createVietorisRipsStream(point_cloud, dimension + 1, max_filtration_value, num_divisions);


% get the default persistence algorithm
persistence = api.Plex4.getDefaultSimplicialAlgorithm(dimension + 1);

% compute intervals
intervals = persistence.computeIntervals(stream);

% create the barcode plots
options.filename = strcat('VR_IFS_Plot_',simulation_signature,'.png');
options.max_filtration_value = max_filtration_value;
plot_barcodes(intervals, options);
% use my implementation of Persistent Rank Function module, we can obtain a
% matrix of persistent rank function of dim 1 with specified range
% [0.8,1.5] at steplong 1.
PRF_matrix=plotPRF(point_cloud,1,[0.8,1.5],.1)
csvwrite(strcat('PRF_CSV_',simulation_signature,'.csv'),PRF_matrix);


