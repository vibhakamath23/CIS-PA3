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
    % search octree
    [point, ~] = search_octree(a, mesh.octree, mesh);
end


