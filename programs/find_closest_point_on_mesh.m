function closest_point = find_closest_point_on_mesh(point, mesh)
% CHATGPT GENERATED findClosestPointOnMesh - Finds closest point on triangular mesh
%
% Input:
%   point - 1x3 query point coordinates
%   mesh - Structure containing:
%     .vertices - N_vertices x 3 array of vertex coordinates
%     .triangles - N_triangles x 3 array of vertex indices
%
% Output:
%   closest_point - 1x3 coordinates of closest point on mesh
%
% Algorithm:
%   Linear search through all triangles to find closest point

    min_distance = inf;
    closest_point = [0, 0, 0];
    
    % Search through all triangles
    for i = 1:mesh.N_triangles
        % Get triangle vertices
        v_indices = mesh.triangles(i, :);
        p = mesh.vertices(v_indices(1), :);
        q = mesh.vertices(v_indices(2), :);
        r = mesh.vertices(v_indices(3), :);
        
        % Find closest point on this triangle
        c = find_closest_point_on_triangle(point, p, q, r);
        
        % Compute distance
        dist = norm(point - c);
        
        % Update if this is closer
        if dist < min_distance
            min_distance = dist;
            closest_point = c;
        end
    end
end