function write_aux_file(letter_index, mode, search_method, ...
    outputFile, data_dir, output_dir, ...
    build_time, query_time, diff_mag)
% Creates an auxiliary file that logs:
%   - Search method and timing (build/query/total)
%   - Summary statistics of diff_mag
%   - Comparison between output file and provided debug file (if debug mode)
%
% Inputs:
%   letter_index : char or string identifying the problem letter (a–k)
%   mode          : 'debug' or 'unknown'
%   search_method : search method used 
%   outputFile    : path to generated output file
%   data_dir      : path to Data directory 
%   output_dir    : path to outputs directory
%   build_time    : time spent constructing data structure (s)
%   query_time    : time spent on queries (s)
%   diff_mag      : vector of difference magnitudes for each point

    aux_filename = sprintf('pa3-%s-%s-%s-aux.txt', letter_index, mode, search_method);
    auxFile = fullfile(output_dir, aux_filename);
    fid = fopen(auxFile, 'w');
    if fid == -1
        error('Could not create auxiliary file: %s', auxFile);
    end

    % === Timing Summary ===
    total_time = build_time + query_time;
    fprintf(fid, 'Auxiliary Report for pa3-%s-%s-%s-aux.txt:', letter_index, mode, search_method);
    fprintf(fid, '\nSearch method: %s\n', search_method);
    fprintf(fid, 'Build time: %.6f s\n', build_time);
    fprintf(fid, 'Query time: %.6f s\n', query_time);
    fprintf(fid, 'Total runtime: %.6f s\n\n', total_time);

    % === Summary statistics on diff_mag ===
    fprintf(fid, '--- Summary Statistics on diff_mag ---\n');
    fprintf(fid, 'Mean difference magnitude: %.6f mm\n', mean(diff_mag));
    fprintf(fid, 'RMS difference magnitude: %.6f mm\n', sqrt(mean(diff_mag.^2)));
    fprintf(fid, 'Std deviation: %.6f mm\n', std(diff_mag));
    fprintf(fid, 'Max difference magnitude: %.6f mm\n', max(diff_mag));
    fprintf(fid, 'Min difference magnitude: %.6f mm\n\n', min(diff_mag));

    % === Comparison with debug file (if applicable) ===
    if strcmp(mode, 'debug')
        debug_pattern = sprintf('PA3-%s-Debug-Output.txt', upper(letter_index));
        debugFile = fullfile(data_dir, debug_pattern);

        if exist(debugFile, 'file')
            fprintf(fid, '--- Comparison with Provided Debug Output ---\n');

            try
                userData = readmatrix(outputFile);
                refData  = readmatrix(debugFile);
            catch
                fclose(fid);
                error('Could not read one or both output files.');
            end

            % Extract coordinates for comparison
            userPts = userData(:, 1:3);
            refPts  = refData(:, 1:3);

            % Compute pointwise errors
            errors = userPts - refPts;
            errorMag = sqrt(sum(errors.^2, 2));

            % Summary metrics
            meanErr = mean(errorMag);
            rmsErr = sqrt(mean(errorMag.^2));
            stdErr = std(errorMag);
            maxErr = max(errorMag);
            minErr = min(errorMag);

            fprintf(fid, 'Mean error: %.6f\n', meanErr);
            fprintf(fid, 'RMS error: %.6f\n', rmsErr);
            fprintf(fid, 'Std deviation: %.6f\n', stdErr);
            fprintf(fid, 'Max error: %.6f\n', maxErr);
            fprintf(fid, 'Min error: %.6f\n\n', minErr);

            fprintf(fid, 'Index   Error_X    Error_Y    Error_Z    |Error|\n');
            for i = 1:size(errors, 1)
                fprintf(fid, '%5d  %9.4f  %9.4f  %9.4f  %9.4f\n', ...
                        i, errors(i,1), errors(i,2), errors(i,3), errorMag(i));
            end
        else
            fprintf(fid, 'Debug output file not found for comparison.\n');
        end
    end

    fclose(fid);
    fprintf('Auxiliary file written to pa3-%s-%s-%s-aux.txt.\n', letter_index, mode, search_method);
end
