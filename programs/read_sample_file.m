function samples = read_sample_file(filename, bodyA, bodyB)
% readSampleFile - Reads sample readings file
%
% Input:
%   filename - Path to sample file (e.g., 'pa3-a-SampleReadingsTest.txt')
%
% Output:
%   samples - Structure containing:
%     .N_A - Number of A body markers
%     .N_B - Number of B body markers
%     .N_D - Number of dummy markers
%     .N_samps - Number of sample frames
%     .filename - Original filename
%     .A_markers - N_A x 3 x N_samps array of A marker positions
%     .B_markers - N_B x 3 x N_samps array of B marker positions
%     .D_markers - N_D x 3 x N_samps array of dummy marker positions
%
% File format:
%   Line 0: N_A, N_B, N_D, N_samps, filename
%   For each frame (repeated N_samps times):
%     Next N_A lines: x, y, z of A markers
%     Next N_B lines: x, y, z of B markers
%     Next N_D lines: x, y, z of dummy markers

     fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end
    
    % Read first line
    line = fgetl(fid);
    
    % Extract all numbers from the first line
    number_strings = regexp(line, '[-\d.]+', 'match');
    
    numbers = str2double(number_strings);
    
    N_S = round(numbers(1));  % Total markers per frame
    samples.N_samps = round(numbers(2));
    
    % Extract filename from the line
    tokens = strsplit(line, ',');
    if length(tokens) >= 3
        samples.filename = strtrim(tokens{3});
        samples.filename = strrep(samples.filename, '"', '');
    else
        [~, samples.filename, ext] = fileparts(filename);
        samples.filename = [samples.filename ext];
    end

    all_markers = zeros(N_S, 3, samples.N_samps);
    
    % Read each frame
    for frame = 1:samples.N_samps
        for i = 1:N_S
            line = fgetl(fid);

            values = str2double(regexp(line, '[-\d.eE]+', 'match'));

            all_markers(i, :, frame) = values(1:3);
        end
        
        if mod(frame, 100) == 0
            fprintf('  Read frame %d/%d\n', frame, samples.N_samps);
        end
    end
    
    fclose(fid);
    
    % Store the full marker array
    samples.all_markers = all_markers;
    samples.N_S = N_S;

    % Split markers
    samples = split_marker_values(samples, bodyA, bodyB);
    
    fprintf('Sample file loaded: %d markers x %d frames\n', N_S, samples.N_samps);
end
