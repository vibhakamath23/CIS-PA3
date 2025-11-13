function body = read_body_file(filename)
% readBodyFile - Reads rigid body definition file
%
% Input:
%   filename - Path to body definition file (e.g., 'Problem3-BodyA.txt')
%
% Output:
%   body - Structure containing:
%     .name - Body name
%     .N_markers - Number of LED markers
%     .markers - N_markers x 3 array of marker positions in body coords
%     .tip - 1 x 3 vector of tip position in body coordinates
%
% File format:
%   Line 0: N_markers, filename
%   Lines 1 to N_markers: x, y, z coordinates of markers
%   Last line: x, y, z coordinates of tip

    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end
    
    % first line
    line = fgetl(fid);

    numbers = regexp(line, '[\d.]+', 'match');

    body.N_markers = str2double(numbers{1});
    
    % body name
    [~, body.name, ~] = fileparts(filename);
  
    
    % marker positions
    body.markers = zeros(body.N_markers, 3);
    for i = 1:body.N_markers
        line = fgetl(fid);

        % Parse comma or space separated values
        values = str2double(regexp(line, '[-\d.]+', 'match'));
        
        body.markers(i, :) = values(1:3);
    end
    
    % tip position
    line = fgetl(fid);
    values = str2double(regexp(line, '[-\d.]+', 'match'));
    body.tip = values(1:3);
    
    fclose(fid);
    
    fprintf('Read body file: %s markers, %d markers\n', body.name, body.N_markers);
end
