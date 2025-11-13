function dist = point_to_box_distance(point, box_min, box_max)
% Computes minimum distance from a point to an axis-aligned bounding box. Returns 0
% if point is inside box.
% 
% Inputs: 
%    point (1 × 3)
%    box min
%    box max (1 × 3 box corners)
% Outputs: 
%    dist (scalar minimum distance)

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
