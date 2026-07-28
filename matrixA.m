centsize_filename = "C:\Users\centsize_mix40_8.45.txt";
iri_filename = "C:\Users\iri_mix40_8.45.txt";
output_filename = "C:\Users\A.txt";
TOLERANCE = 1e-9;

if isempty(gcp('nocreate'))
    try
        evalc('parpool();');
    catch ME
        fprintf(2, 'Error starting the parallel pool: %s\n', ME.message);
        return;
    end
end

try
    all_centsize_data = readmatrix(centsize_filename);
    centsize_data = all_centsize_data(:, [1, 2, 3, 4, 8]);
    if isempty(centsize_data)
        error('The input ray-intercept data is empty or invalid.');
    end
catch ME
    fprintf(2, 'Error reading or processing %s: %s\n', centsize_filename, ME.message);
    return;
end

try
    all_iri_data = readmatrix(iri_filename);
    iri_grid_coords = all_iri_data(:, 1:3);
    if isempty(iri_grid_coords)
        error('The grid-definition data is empty or invalid.');
    end
    num_grid_cells = size(iri_grid_coords, 1);
    if num_grid_cells == 0
        error('No grid cells are defined.');
    end
catch ME
    fprintf(2, 'Error reading or processing %s: %s\n', iri_filename, ME.message);
    return;
end

unique_ray_ids = unique(centsize_data(:, 1));
num_unique_rays = length(unique_ray_ids);

if num_unique_rays == 0
    fid = fopen(output_filename, 'w');
    if fid ~= -1
        fclose(fid);
    else
        fprintf(2, 'Error creating %s.\n', output_filename);
    end
    return;
end

output_matrix = zeros(num_unique_rays, 1 + num_grid_cells);

parfor i = 1:num_unique_rays
    current_ray_id = unique_ray_ids(i);
    current_row_data = zeros(1, 1 + num_grid_cells);
    current_row_data(1) = current_ray_id;
    segments_for_current_ray = centsize_data(centsize_data(:, 1) == current_ray_id, :);

    for j = 1:size(segments_for_current_ray, 1)
        segment_info = segments_for_current_ray(j, :);
        segment_coord = segment_info(2:4);
        segment_intercept = segment_info(5);
        coord_diffs = abs(bsxfun(@minus, iri_grid_coords, segment_coord));
        matched_grid_indices = find(all(coord_diffs < TOLERANCE, 2), 1, 'first');

        if ~isempty(matched_grid_indices)
            output_column_index = 1 + matched_grid_indices;
            current_row_data(output_column_index) = segment_intercept;
        end
    end

    output_matrix(i, :) = current_row_data;
end

try
    fid = fopen(output_filename, 'w');
    if fid == -1
        error('Unable to open %s for writing.', output_filename);
    end

    format_string = '%d';
    for k_fmt = 1:(size(output_matrix, 2) - 1)
        format_string = [format_string, '\t%.4f'];
    end
    format_string = [format_string, '\n'];

    for row_idx = 1:size(output_matrix, 1)
        fprintf(fid, format_string, output_matrix(row_idx, :));
    end

    fclose(fid);
catch ME
    fprintf(2, 'Error writing %s: %s\n', output_filename, ME.message);
    if exist('fid', 'var') && fid ~= -1
        try
            if any(fopen('all') == fid)
                fclose(fid);
            end
        catch
        end
    end
    return;
end
