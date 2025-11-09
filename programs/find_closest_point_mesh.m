function point = find_closest_point_mesh(a, mesh)
% finds closest point on triangular mesh

% Input:
%   a - 1x3 coordinates of a point
%   mesh - struct containing:
%     .vertices - N_vertices x 3 array of vertex coordinates
%     .triangles - N_triangles x 3 array of vertex indices

% Output:
%   point - 1x3 coordinates of closest point on mesh
    
    min_dist = inf;

    N_triangles = size(mesh.triangles, 1);
    for i = 1:N_triangles
        v_indices = mesh.triangles(i, :);
        triangle = mesh.vertices(v_indices, :);
        closest_pt = find_closest_point_tri(a, triangle);
        dist = norm(a - closest_pt);
     
        if dist < min_dist
            min_dist = dist;
            point = closest_pt;
        end
    end
end



