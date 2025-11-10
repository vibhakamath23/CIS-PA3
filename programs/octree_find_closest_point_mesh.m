function point = octree_find_closest_point_mesh(a, mesh)
% find_closest_point_mesh_octree: uses octree 
%
% Input:
%   a - 1x3 coordinates of a point
%   mesh - struct containing mesh data and optional .octree field
%
% Output:
%   point - 1x3 closest point on mesh
%

    % build octree if not present
    if ~isfield(mesh, 'octree')
        mesh.octree = build_octree(mesh);
    end
    
    % search octree
    [point, ~] = search_octree(a, mesh.octree, mesh);
end

function octree = build_octree(mesh, max_depth, max_triangles_per_node)
% build octree structure
%
% Parameters:
%   max_depth - maximum tree depth (default: 8)
%   max_triangles_per_node - split threshold (default: 10)

    if nargin < 2, max_depth = 8; end
    if nargin < 3, max_triangles_per_node = 10; end
    
    % compute bounding box of entire mesh
    all_vertices = mesh.vertices;
    min_bound = min(all_vertices, [], 1);
    max_bound = max(all_vertices, [], 1);
    
    % add small margin
    margin = 0.01 * norm(max_bound - min_bound);
    min_bound = min_bound - margin;
    max_bound = max_bound + margin;
    
    % create root node
    octree.min_bound = min_bound;
    octree.max_bound = max_bound;
    octree.center = (min_bound + max_bound) / 2;
    octree.triangle_indices = 1:size(mesh.triangles, 1);
    octree.is_leaf = true;
    octree.children = [];
    
    % recursively subdivide
    octree = subdivide_node(octree, mesh, 0, max_depth, max_triangles_per_node);
end

function node = subdivide_node(node, mesh, depth, max_depth, max_triangles)
% recursively subdivide octree node

    % stop conditions
    if depth >= max_depth || length(node.triangle_indices) <= max_triangles
        return;
    end
    
    % create 8 children
    min_b = node.min_bound;
    max_b = node.max_bound;
    center = node.center;
    
    children = cell(8, 1);
    child_bounds = {
        [min_b(1), min_b(2), min_b(3); center(1), center(2), center(3)];  % 1: ---
        [center(1), min_b(2), min_b(3); max_b(1), center(2), center(3)];  % 2: +--
        [min_b(1), center(2), min_b(3); center(1), max_b(2), center(3)];  % 3: -+-
        [center(1), center(2), min_b(3); max_b(1), max_b(2), center(3)];  % 4: ++-
        [min_b(1), min_b(2), center(3); center(1), center(2), max_b(3)];  % 5: --+
        [center(1), min_b(2), center(3); max_b(1), center(2), max_b(3)];  % 6: +-+
        [min_b(1), center(2), center(3); center(1), max_b(2), max_b(3)];  % 7: -++
        [center(1), center(2), center(3); max_b(1), max_b(2), max_b(3)];  % 8: +++
    };
    
    for i = 1:8
        bounds = child_bounds{i};
        child_min = bounds(1, :);
        child_max = bounds(2, :);
        child_center = (child_min + child_max) / 2;
        
        % find triangles that intersect this child's bounding box
        child_triangles = find_triangles_in_box(node.triangle_indices, ...
                                                 mesh, child_min, child_max);
        
        if ~isempty(child_triangles)
            children{i}.min_bound = child_min;
            children{i}.max_bound = child_max;
            children{i}.center = child_center;
            children{i}.triangle_indices = child_triangles;
            children{i}.is_leaf = true;
            children{i}.children = [];
            
            % recursively subdivide
            children{i} = subdivide_node(children{i}, mesh, depth + 1, ...
                                        max_depth, max_triangles);
        end
    end
    
    node.is_leaf = false;
    node.children = children;
end

function tri_indices = find_triangles_in_box(triangle_indices, mesh, min_bound, max_bound)
% find which triangles intersect the bounding box

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

function [point, min_dist] = search_octree(query, node, mesh)
% aearch octree for closest point

    if node.is_leaf
        % leaf node: check all triangles
        min_dist = inf;
        point = [0, 0, 0];
        
        for i = 1:length(node.triangle_indices)
            tri_idx = node.triangle_indices(i);
            v_indices = mesh.triangles(tri_idx, :);
            triangle = mesh.vertices(v_indices, :);
            closest_pt = find_closest_point_tri(query, triangle);
            dist = norm(query - closest_pt);
            
            if dist < min_dist
                min_dist = dist;
                point = closest_pt;
            end
        end
        return;
    end
    
    % interior node: search children in order of distance to query point
    child_dists = [];
    valid_children = [];
    
    for i = 1:length(node.children)
        if ~isempty(node.children{i})
            % Distance from query to child's bounding box
            dist = point_to_box_distance(query, node.children{i}.min_bound, ...
                                        node.children{i}.max_bound);
            child_dists = [child_dists; dist];
            valid_children = [valid_children; i];
        end
    end
    
    % sort children by distance
    [sorted_dists, sort_idx] = sort(child_dists);
    
    % search children in order
    min_dist = inf;
    point = [0, 0, 0];
    
    for idx = 1:length(valid_children)
        child_idx = valid_children(sort_idx(idx));
        
        % early termination: if box distance exceeds current best, skip
        if sorted_dists(idx) > min_dist
            continue;
        end
        
        [child_point, child_dist] = search_octree(query, node.children{child_idx}, mesh);
        
        if child_dist < min_dist
            min_dist = child_dist;
            point = child_point;
        end
    end
end

function dist = point_to_box_distance(point, box_min, box_max)
% compute minimum distance from point to axis-aligned bounding box

    % for each dimension, find closest point on box
    closest = zeros(1, 3);
    for i = 1:3
        if point(i) < box_min(i)
            closest(i) = box_min(i);
        elseif point(i) > box_max(i)
            closest(i) = box_max(i);
        else
            closest(i) = point(i);  % point is inside box in this dimension
        end
    end
    
    dist = norm(point - closest);
end
