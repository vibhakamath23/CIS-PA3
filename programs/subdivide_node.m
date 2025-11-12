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
