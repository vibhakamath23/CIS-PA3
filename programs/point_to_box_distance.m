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
