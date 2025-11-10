function point = fast_find_closest_point_mesh(a, mesh)
% efficient closest point search using spatial partitioning
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
% Strategy:
%   1. Use bounding sphere culling to eliminate distant triangles
%   2. Sort remaining triangles by distance to query point
%   3. Use early termination when possible

    % Build acceleration structures if not present
    if ~isfield(mesh, 'bounding_spheres')
        mesh = precompute_bounding_spheres(mesh);
    end
    
    N_triangles = size(mesh.triangles, 1);
    
    % Phase 1: Quickly eliminate distant triangles using bounding spheres
    candidate_triangles = [];
    candidate_dists = [];
    
    for i = 1:N_triangles
        center = mesh.bounding_spheres.centers(i, :);
        radius = mesh.bounding_spheres.radii(i);
        
        % Distance from query point to sphere center
        dist_to_center = norm(a - center);
        
        % Lower bound on distance to any point in triangle
        lower_bound = max(0, dist_to_center - radius);
        
        % Keep triangle as candidate
        candidate_triangles = [candidate_triangles; i];
        candidate_dists = [candidate_dists; lower_bound];
    end
    
    % Phase 2: Sort candidates by lower bound distance
    [sorted_dists, sort_idx] = sort(candidate_dists);
    sorted_triangles = candidate_triangles(sort_idx);
    
    % Phase 3: Search sorted triangles with early termination
    min_dist = inf;
    point = [0, 0, 0];
    
    for idx = 1:length(sorted_triangles)
        i = sorted_triangles(idx);
        
        % Early termination: if lower bound exceeds current best, we're done
        if sorted_dists(idx) > min_dist
            break;
        end
        
        % Compute actual closest point on this triangle
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

function mesh = precompute_bounding_spheres(mesh)
% Precompute bounding sphere for each triangle
% Returns smallest sphere that contains all three vertices

    N_triangles = size(mesh.triangles, 1);
    centers = zeros(N_triangles, 3);
    radii = zeros(N_triangles, 1);
    
    for i = 1:N_triangles
        v_indices = mesh.triangles(i, :);
        v1 = mesh.vertices(v_indices(1), :);
        v2 = mesh.vertices(v_indices(2), :);
        v3 = mesh.vertices(v_indices(3), :);
        
        % Centroid of triangle
        center = (v1 + v2 + v3) / 3;
        
        % Radius is max distance from center to any vertex
        d1 = norm(v1 - center);
        d2 = norm(v2 - center);
        d3 = norm(v3 - center);
        radius = max([d1, d2, d3]);
        
        centers(i, :) = center;
        radii(i) = radius;
    end
    
    mesh.bounding_spheres.centers = centers;
    mesh.bounding_spheres.radii = radii;
end
