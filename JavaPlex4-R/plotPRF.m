function plotprffunc = plotPRF(data_point_cloud,Betti_dimension,grid_range,grid_increment)
    import edu.stanford.math.plex4.*;
    total_long = diff(grid_range);
    step_num = total_long/grid_increment;
    % disp(step_num);
    step_num = round(step_num);
    grid_matrix = zeros(step_num+1,step_num+1);
    lower_bound = grid_range(1);
    % disp(grid_matrix);
    for i = 0:step_num
        for j = i:step_num
            grid_matrix(i+1,j+1) = PRF(data_point_cloud,Betti_dimension,lower_bound+i*grid_increment,lower_bound+j*grid_increment);
            % disp(i)
        end
    end
    
    %c_max=max(grid_matrix);
    %c_min=min(grid_matrix);
    %clims=[min(c_min),min(c_max)];
    % disp(clims)
    % plot_matrix=flip(grid_matrix,2);
    % plot_matrix=grid_matrix;
    % im = imagesc(plot_matrix,clims);
    
    %axis([grid_range(1),grid_range(2),grid_range(2),grid_range(1)]);
    % colorbar;
    % disp(grid_matrix);
    plotprffunc = grid_matrix;
end