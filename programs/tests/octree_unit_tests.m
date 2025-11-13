function tests = octree_unit_tests
% Unit tests for build_octree and search_octree functions with random synthetic data
%
% Tests:
%   - Bounding box and subdivision correctness
%   - Closest point accuracy vs brute-force
%   - point_to_box_distance correctness

    addpath('../programs');  % adjust path as needed
    rng(42); % reproducibility
    tests = functiontests(localfunctions);
end

function testSingleTriangle(testCase)
    % Random single triangle in space
    mesh.vertices = rand(3, 3);
    mesh.triangles = [1 2 3];

    octree = build_octree(mesh, 3, 1);

    % Check properties
    verifyTrue(testCase, octree.is_leaf);
    verifyEqual(testCase, length(octree.triangle_indices), 1);

    % Random query point slightly offset from triangle plane
    query = mean(mesh.vertices) + [0, 0, rand() + 0.5];
    [pt, dist] = search_octree(query, octree, mesh);

    % Compute expected (closest) point manually
    tri = mesh.vertices(mesh.triangles, :);
    expected_pt = find_closest_point_tri(query, tri);
    expected_dist = norm(query - expected_pt);

    verifyEqual(testCase, pt, expected_pt, 'AbsTol', 1e-6);
    verifyEqual(testCase, dist, expected_dist, 'AbsTol', 1e-6);
end

function testBoundingBox(testCase)
    % Random bounding box test
    verts = rand(2, 3) * 10;
    mesh.vertices = verts;
    mesh.triangles = [1 1 2]; % dummy triangle to keep structure valid

    octree = build_octree(mesh);

    % Expected min and max with small padding
    span = norm(verts(2, :) - verts(1, :));
    expected_min = min(verts) - 0.01 * span;
    expected_max = max(verts) + 0.01 * span;

    verifyEqual(testCase, octree.min_bound, expected_min, 'AbsTol', 1e-8);
    verifyEqual(testCase, octree.max_bound, expected_max, 'AbsTol', 1e-8);
end

function testSubdivision(testCase)
    % Generate random dense mesh to trigger subdivision
    mesh.vertices = rand(100, 3);
    mesh.triangles = randi([1, 100], [60, 3]);

    octree = build_octree(mesh, 3, 5);

    % Expect subdivision (non-leaf)
    verifyFalse(testCase, octree.is_leaf);
    verifyGreaterThan(testCase, numel(octree.children), 0);
end

function testSearchMatchesBruteForce(testCase)
    % Compare octree search vs brute-force for random mesh and query
    mesh.vertices = rand(30, 3);
    mesh.triangles = randi([1, 30], [15, 3]);
    octree = build_octree(mesh, 4, 3);

    query = rand(1, 3);

    [pt_tree, dist_tree] = search_octree(query, octree, mesh);

    % Brute-force closest point search
    best_dist = inf;
    best_pt = [0, 0, 0];
    for i = 1:size(mesh.triangles, 1)
        tri = mesh.vertices(mesh.triangles(i, :), :);
        cp = find_closest_point_tri(query, tri);
        d = norm(query - cp);
        if d < best_dist
            best_dist = d;
            best_pt = cp;
        end
    end

    verifyEqual(testCase, pt_tree, best_pt, 'AbsTol', 1e-6);
    verifyEqual(testCase, dist_tree, best_dist, 'AbsTol', 1e-6);
end

function testPointInsideBox(testCase)
    % Random box and query inside
    box_min = rand(1, 3);
    box_max = box_min + rand(1, 3) + 0.5;
    query = box_min + rand(1, 3) .* (box_max - box_min); % inside
    d = point_to_box_distance(query, box_min, box_max);
    verifyEqual(testCase, d, 0, 'AbsTol', 1e-12);
end

function testPointOutsideBox(testCase)
    % Random box and query outside
    box_min = rand(1, 3);
    box_max = box_min + rand(1, 3) + 0.5;

    % Move query outside in one random direction
    dir = randi(3);
    query = box_max;
    query(dir) = box_max(dir) + rand() + 0.5;

    d = point_to_box_distance(query, box_min, box_max);

    expected_d = query(dir) - box_max(dir);
    verifyEqual(testCase, d, expected_d, 'AbsTol', 1e-12);
end


