function point = bounding_sphere_find_closest_point_mesh(a, mesh)
% closest point search using bounding spheres lower bound sort and search
%
% Input:
%   a - 1x3 coordinates of a point
%   mesh - struct containing:
%     .vertices - N_vertices x 3 array of vertex coordinates
%     .triangles - N_triangles x 3 array of vertex indices
%     .octree (optional) - precomputed octree structure
%     .bounding_spheres (optional) - precomputed bounding spheres
%
% Output:
%   point - 1x3 coordinates of closest point on mesh
%
% - Uses bounding spheres to eliminate distant triangles
% - Sorts remaining triangles by distance to query point (lower bound)
% - Uses early termination when possible
    
    N_triangles = size(mesh.triangles, 1);
    
    % eliminate distant triangles using bounding spheres
    candidate_triangles = [];
    candidate_dists = [];
    
    for i = 1:N_triangles
        center = mesh.bounding_spheres.centers(i, :);
        radius = mesh.bounding_spheres.radii(i);
        
        % distance from query point to sphere center
        dist_to_center = norm(a - center);
        
        % lower bound on distance to any point in triangle
        lower_bound = max(0, dist_to_center - radius);
        
        % keep triangle as candidate
        candidate_triangles = [candidate_triangles; i];
        candidate_dists = [candidate_dists; lower_bound];
    end
    
    % sort candidates by lower bound distance
    [sorted_dists, sort_idx] = sort(candidate_dists);
    sorted_triangles = candidate_triangles(sort_idx);
    
    % search sorted triangles with early termination
    min_dist = inf;
    point = [0, 0, 0];
    
    for idx = 1:length(sorted_triangles)
        i = sorted_triangles(idx);
        
        % if lower bound exceeds current best, finish and ignore rest of triangles
        if sorted_dists(idx) > min_dist
            break;
        end
        
        % compute actual closest point on this triangle
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

