function mesh = read_mesh_file(filename)
% readMeshFile - Reads surface mesh definition file
%
% Input:
%   filename - Path to mesh file (e.g., 'Problem3Mesh.sur')
%
% Output:
%   mesh - Structure containing:
%     .N_vertices - Number of vertices
%     .vertices - N_vertices x 3 array of vertex coordinates in CT coords
%     .N_triangles - Number of triangles
%     .triangles - N_triangles x 3 array of vertex indices for each triangle
%     .neighbors - N_triangles x 3 array of neighbor triangle indices
%
% File format:
%   Line 0: N_vertices
%   Lines 1 to N_vertices: x, y, z coordinates of vertices
%   Next line: N_triangles
%   Next N_triangles lines: i1, i2, i3, n1, n2, n3

    fid = fopen(filename, 'r');
    if fid == -1
        error('Cannot open file: %s', filename);
    end
    
    % read number of vertices
    line = fgetl(fid);
    mesh.N_vertices = str2double(strtrim(line));
    
    % read vertices
    mesh.vertices = zeros(mesh.N_vertices, 3);
    for i = 1:mesh.N_vertices
        line = fgetl(fid);

        % extract all numbers
        values = str2double(regexp(line, '[-\d.eE]+', 'match'));

        mesh.vertices(i, :) = values(1:3);
    end
    
    % read number of triangles
    line = fgetl(fid);
    mesh.N_triangles = str2double(strtrim(line));
    
    % read triangles
    mesh.triangles = zeros(mesh.N_triangles, 3);
    mesh.neighbors = zeros(mesh.N_triangles, 3);
    for i = 1:mesh.N_triangles
        line = fgetl(fid);

        % use regex to extract all numbers (handles negative indices for neighbors)
        values = str2double(regexp(line, '[-\d.eE]+', 'match'));

        % convert from 0-based to 1-based indexing for MATLAB
        mesh.triangles(i, :) = values(1:3) + 1;  % Add 1 for MATLAB indexing
        mesh.neighbors(i, :) = values(4:6) + 1;  % Add 1 for MATLAB indexing (note: -1 becomes 0, which is still invalid but not used)
    end
    
    fclose(fid);
    
    fprintf('Mesh loaded: %d vertices, %d triangles\n', mesh.N_vertices, mesh.N_triangles);
end
