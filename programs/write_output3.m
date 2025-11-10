function write_output3(output_filename, N_samps, d_k, c_k, diff_mag)
% writeOutputPA3 - Writes output file for PA3
%
% Input:
%   filename - Output filename (e.g., 'pa3-a-Output.txt')
%   N_samps - Number of sample frames
%   d_k - N_samps x 3 array of d_k coordinates
%   c_k - N_samps x 3 array of c_k (closest point) coordinates
%   diff_mag - N_samps x 1 array of difference magnitudes
%
% Output format:
%   Line 0: N_samps, filename
%   Next N_samps lines: d_x, d_y, d_z, c_x, c_y, c_z, |d_k - c_k|

    fid = fopen(output_filename, 'w');
    if fid == -1
        error('Cannot open output file: %s', output_filename);
    end
    
    % Write header
    [~, name, ext] = fileparts(output_filename);
    fprintf(fid, '%d, %s%s\n', N_samps, name, ext);
    
    % Write data for each sample
    for i = 1:N_samps
        fprintf(fid, '%8.2f, %8.2f, %8.2f, %8.2f, %8.2f, %8.2f, %8.3f\n', ...
                d_k(i, 1), d_k(i, 2), d_k(i, 3), ...
                c_k(i, 1), c_k(i, 2), c_k(i, 3), ...
                diff_mag(i));
    end
    
    fclose(fid);
end
