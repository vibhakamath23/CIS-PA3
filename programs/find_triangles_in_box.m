function tri_indices = find_triangles_in_box(triangle_indices, mesh, min_bound, max_bound)
% Determines which triangles from a list intersect a given axis-aligned bounding box using
bounding box overlap test.
% 
% 
% Inputs: 
%   triangle indices (list of candidate triangles), mesh, min bound, max bound (1 × 3 box corners)
% Outputs: 
%   tri indices (list of triangles intersecting box)

    tri_indices = [];
    
    for i = 1:length(triangle_indices)
        tri_idx = triangle_indices(i);
        v_indices = mesh.triangles(tri_idx, :);
        
        % get triangle vertices
        v1 = mesh.vertices(v_indices(1), :);
        v2 = mesh.vertices(v_indices(2), :);
        v3 = mesh.vertices(v_indices(3), :);
        
        % check if any vertex is in box or triangle intersects box
        % simplified: check if triangle bounding box intersects node box
        tri_min = min([v1; v2; v3], [], 1);
        tri_max = max([v1; v2; v3], [], 1);
        
        % Box intersection test
        if all(tri_max >= min_bound) && all(tri_min <= max_bound)
            tri_indices = [tri_indices, tri_idx];
        end
    end
end
