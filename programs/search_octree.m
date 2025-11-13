function [point, min_dist] = search_octree(query, node, mesh)
% Searches octree for closest point on mesh using recursive traversal with early termination
% based on bounding box distances.
%
% Inputs: 
%    query (1 × 3 point)
%    node (octree node)
%    mesh
% Outputs: 
%    point (1 × 3 closest point)
%    min dist (distance to closest point)

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
            % distance from query to child's bounding box
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
        
        % early termination: if box distance is larger than current best, skip
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

