clear;
clc;

A_filename = "C:\Users\A.txt";
b_filename = "C:\Users\b.txt";
x_filename = "C:\Users\x.txt";
output_filename_X = "C:\Users\X_solutions_output.txt";
output_filename_info = "C:\Users\run_info_output.txt";

try
    temp_A = readmatrix(A_filename);
    A = temp_A(:, 2:end);
    temp_b = readmatrix(b_filename);
    b = temp_b(:, 2);
    x0 = readmatrix(x_filename);

    if size(x0, 2) > 1 && size(x0, 1) == 1
        x0 = x0';
    end
catch ME
    fprintf(2, 'Error reading input files: %s\n', ME.message);
    return;
end

if size(A, 1) ~= size(b, 1)
    fprintf(2, 'Matrix A has %d rows, but vector b has %d elements.\n', size(A, 1), size(b, 1));
    return;
end

if size(A, 2) ~= size(x0, 1)
    fprintf(2, 'Matrix A has %d columns, but x0 has %d elements.\n', size(A, 2), size(x0, 1));
    return;
end

K = 1:40;
options = struct();
options.relaxpar = 0.2;
options.lbound = x0 / 2;
options.verbose = 0;
options.waitbar = false;

try
    [X_solutions, run_info] = kaczmarz(A, b, K, x0, options);
catch ME
    fprintf(2, 'Error running kaczmarz: %s\n', ME.message);
    return;
end

try
    writematrix(X_solutions, output_filename_X);
catch ME
    fprintf(2, 'Error writing %s: %s\n', output_filename_X, ME.message);
end

try
    fileID = fopen(output_filename_info, 'w');
    if fileID == -1
        error('Unable to open %s for writing.', output_filename_info);
    end

    fprintf(fileID, 'Kaczmarz Run Information\n');
    fprintf(fileID, '---------------------------\n');

    fields = fieldnames(run_info);
    for i = 1:length(fields)
        fieldName = fields{i};
        fieldValue = run_info.(fieldName);

        fprintf(fileID, '%s: ', fieldName);
        if isnumeric(fieldValue)
            if isscalar(fieldValue)
                fprintf(fileID, '%g\n', fieldValue);
            else
                fprintf(fileID, '%s\n', mat2str(fieldValue));
            end
        elseif ischar(fieldValue)
            fprintf(fileID, '%s\n', fieldValue);
        elseif isstring(fieldValue)
            fprintf(fileID, '%s\n', char(fieldValue));
        elseif islogical(fieldValue)
            fprintf(fileID, '%s\n', mat2str(fieldValue));
        else
            fprintf(fileID, '[Unsupported data type]\n');
        end
    end

    fclose(fileID);
catch ME
    fprintf(2, 'Error writing %s: %s\n', output_filename_info, ME.message);
    if exist('fileID', 'var') && fileID ~= -1
        try
            if any(fopen('all') == fileID)
                fclose(fileID);
            end
        catch
        end
    end
end
