function [point, min_dist] = search_octree(query, mesh)
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
