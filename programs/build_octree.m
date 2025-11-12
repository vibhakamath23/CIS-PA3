function octree = build_octree(mesh, max_depth, max_triangles_per_node)
% Constructs octree spatial data structure for mesh by recursively subdividing space into
% eight octants.
%
% Inputs:
%    mesh: (mesh struct)
%    max depth: (maximum tree depth, default: 8)
%    max triangles per node (subdivide threshold, default: 10)
% Outputs: 
%    octree (root node struct with bounding box, triangle indices, and children)

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
