clear; clc; close all;
target_depth = 332.5; 
uniform_file = 'C:\Users\centsize0.4.txt'; 
uniform_file_02 = 'C:\Users\centsize_0.2.txt'; 
mixed_file   = 'C:\Users\centsize_mix40.txt';     
coarse_grid_size_manual = 0.4;
fine_grid_size_manual   = 0.2;
axis_lon_range = [118, 122];
axis_lat_range = [27, 31];   
colorbar_range = [0, 80];    
data_uniform_raw = readmatrix(uniform_file);
data_uniform_cols = data_uniform_raw(:, [2, 3, 4]);
depth_mask_u = abs(data_uniform_cols(:, 3) - target_depth) < 1e-5;
data_uniform_slice = data_uniform_cols(depth_mask_u, 1:2);
[unique_coords_u, ~, ic_u] = unique(data_uniform_slice, 'rows');
counts_u = accumarray(ic_u, 1);
data_uniform_02_raw = readmatrix(uniform_file_02);
data_uniform_02_cols = data_uniform_02_raw(:, [2, 3, 4]);
depth_mask_u_02 = abs(data_uniform_02_cols(:, 3) - target_depth) < 1e-5;
data_uniform_02_slice = data_uniform_02_cols(depth_mask_u_02, 1:2);
[unique_coords_u_02, ~, ic_u_02] = unique(data_uniform_02_slice, 'rows');
counts_u_02 = accumarray(ic_u_02, 1);
data_mixed_raw = readmatrix(mixed_file);
data_mixed_cols = data_mixed_raw(:, [2, 3, 4]);
depth_mask_m = abs(data_mixed_cols(:, 3) - target_depth) < 1e-5;
data_mixed_slice = data_mixed_cols(depth_mask_m, 1:2);
[unique_coords_m, ~, ic_m] = unique(data_mixed_slice, 'rows');
counts_m = accumarray(ic_m, 1);
fig_width_cm          = 12.9;     
fig_height_cm         = 5.6;     
margin_left_cm        = 1;    
margin_right_cm       = 0.8;     
margin_bottom_cm      = 1;     
margin_top_cm         = 0.5;     
spacing_horizontal_cm = 0.3;     
colorbar_width_cm     = 0.3;     
total_plot_width_cm = fig_width_cm - margin_left_cm - margin_right_cm;
subplot_width_cm = (total_plot_width_cm - 2*spacing_horizontal_cm - colorbar_width_cm) / 3;
subplot_height_cm = fig_height_cm - margin_bottom_cm - margin_top_cm;
norm_subplot_w = subplot_width_cm / fig_width_cm;
norm_subplot_h = subplot_height_cm / fig_height_cm;
norm_margin_L = margin_left_cm / fig_width_cm;
norm_margin_B = margin_bottom_cm / fig_height_cm;
norm_spacing_H = spacing_horizontal_cm / fig_width_cm;
norm_cbar_w = colorbar_width_cm / fig_width_cm;
figure;
set(gcf, 'Units', 'centimeters');
set(gcf, 'Position', [10, 5, fig_width_cm, fig_height_cm]);
cmap = colormap('jet');
c_levels = size(cmap, 1);
max_count = colorbar_range(2);
pos1 = [norm_margin_L, norm_margin_B, norm_subplot_w, norm_subplot_h];
ax1 = axes('Position', pos1);
pos2 = [pos1(1) + norm_subplot_w + norm_spacing_H, norm_margin_B, norm_subplot_w, norm_subplot_h];
ax2 = axes('Position', pos2);
pos3 = [pos2(1) + norm_subplot_w + norm_spacing_H, norm_margin_B, norm_subplot_w, norm_subplot_h];
ax3 = axes('Position', pos3);
axes(ax1);
hold on;
map_u = containers.Map('KeyType','char','ValueType','double'); for i=1:size(unique_coords_u,1), key=sprintf('%.4f_%.4f',unique_coords_u(i,1),unique_coords_u(i,2)); map_u(key)=counts_u(i); end
lon_centers_coarse = (axis_lon_range(1)+coarse_grid_size_manual/2):coarse_grid_size_manual:(axis_lon_range(2)-coarse_grid_size_manual/2);
lat_centers_coarse = (axis_lat_range(1)+coarse_grid_size_manual/2):coarse_grid_size_manual:(axis_lat_range(2)-coarse_grid_size_manual/2);
for lon_center = lon_centers_coarse, for lat_center = lat_centers_coarse, key=sprintf('%.4f_%.4f',lon_center,lat_center); count_val=0; if isKey(map_u,key), count_val=map_u(key); end; x_pos=lon_center-coarse_grid_size_manual/2; y_pos=lat_center-coarse_grid_size_manual/2; clipped_count=min(count_val,max_count); color_index=max(1,ceil(clipped_count/max_count*c_levels)); face_color=cmap(color_index,:); rectangle('Position',[x_pos,y_pos,coarse_grid_size_manual,coarse_grid_size_manual],'FaceColor',face_color,'EdgeColor','none'); end, end
hold off;
axes(ax2);
hold on;
map_u_02 = containers.Map('KeyType','char','ValueType','double'); for i=1:size(unique_coords_u_02,1), key=sprintf('%.4f_%.4f',unique_coords_u_02(i,1),unique_coords_u_02(i,2)); map_u_02(key)=counts_u_02(i); end
lon_centers_fine = (axis_lon_range(1)+fine_grid_size_manual/2):fine_grid_size_manual:(axis_lon_range(2)-fine_grid_size_manual/2);
lat_centers_fine = (axis_lat_range(1)+fine_grid_size_manual/2):fine_grid_size_manual:(axis_lat_range(2)-fine_grid_size_manual/2);
for lon_center = lon_centers_fine, for lat_center = lat_centers_fine, key=sprintf('%.4f_%.4f',lon_center,lat_center); count_val=0; if isKey(map_u_02,key), count_val=map_u_02(key); end; x_pos=lon_center-fine_grid_size_manual/2; y_pos=lat_center-fine_grid_size_manual/2; clipped_count=min(count_val,max_count); color_index=max(1,ceil(clipped_count/max_count*c_levels)); face_color=cmap(color_index,:); rectangle('Position',[x_pos,y_pos,fine_grid_size_manual,fine_grid_size_manual],'FaceColor',face_color,'EdgeColor','none'); end, end
hold off;
axes(ax3);
hold on;
map_m = containers.Map('KeyType','char','ValueType','double'); for i=1:size(unique_coords_m,1), key=sprintf('%.4f_%.4f',unique_coords_m(i,1),unique_coords_m(i,2)); map_m(key)=counts_m(i); end
coarse_ref_map=containers.Map('KeyType','char','ValueType','logical'); for lon_c=lon_centers_coarse, for lat_c=lat_centers_coarse, key=sprintf('%.4f_%.4f',lon_c,lat_c); coarse_ref_map(key)=true; end, end
for lon_c=lon_centers_coarse, for lat_c=lat_centers_coarse, rectangle('Position',[lon_c-coarse_grid_size_manual/2,lat_c-coarse_grid_size_manual/2,coarse_grid_size_manual,coarse_grid_size_manual],'FaceColor',cmap(1,:),'EdgeColor','none'); end, end
all_data_keys=keys(map_m); for i=1:length(all_data_keys), current_key=all_data_keys{i}; coords=sscanf(current_key,'%f_%f'); lon_center=coords(1); lat_center=coords(2); if isKey(coarse_ref_map,current_key), grid_size_to_use=coarse_grid_size_manual; else, grid_size_to_use=fine_grid_size_manual; end; x_pos=lon_center-grid_size_to_use/2; y_pos=lat_center-grid_size_to_use/2; count_val=map_m(current_key); clipped_count=min(count_val,max_count); color_index=max(1,ceil(clipped_count/max_count*c_levels)); face_color=cmap(color_index,:); rectangle('Position',[x_pos,y_pos,grid_size_to_use,grid_size_to_use],'FaceColor',face_color,'EdgeColor','none'); end
hold off;
all_axes = [ax1, ax2, ax3];
title_font_size          = 10; 
label_font_size          = 13; 
axes_tick_font_size      = 9;  
colorbar_tick_font_size  = 9; 
colorbar_title_font_size = 10; 
for ax = all_axes
    axes(ax);
    xlim(axis_lon_range);
    ylim(axis_lat_range);
    grid on;
    caxis(colorbar_range);
    xticks(119:1:122);
    yticks(27:1:31);
end
ylabel(ax1, 'Latitude');
xlabel(ax2, 'Longitude');
set(ax2, 'YTickLabel', []);
set(ax3, 'YTickLabel', []);
title(ax1, '(a) 0.4° grid', 'FontWeight', 'bold', 'FontSize', title_font_size);
title(ax2, '(b) 0.2° grid', 'FontWeight', 'bold', 'FontSize', title_font_size);
title(ax3, '(c) Hybrid grid', 'FontWeight', 'bold', 'FontSize', title_font_size);
set(all_axes, 'FontSize', axes_tick_font_size);
set(ax1.YLabel, 'FontSize', label_font_size);
set(ax2.XLabel, 'FontSize', label_font_size);
linkaxes(all_axes, 'xy');
cb_pos = [pos3(1) + norm_subplot_w + norm_spacing_H, norm_margin_B, norm_cbar_w, norm_subplot_h];
cb = colorbar('Position', cb_pos);
set(cb, 'FontSize', colorbar_tick_font_size);
title(cb, 'Rays', 'FontSize', colorbar_title_font_size);