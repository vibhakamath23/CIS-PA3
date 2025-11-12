function tests = octree_unit_tests
% Unit tests for build_octree and search_octree functions
%
% Tests:
%   - Bounding box and subdivision correctness
%   - Closest point accuracy
%   - point_to_box_distance behavior

    addpath('../programs');  % adjust path as needed
    tests = functiontests(localfunctions);
end

function testSingleTriangle(testCase)
    % One triangle in XY plane
    mesh.vertices = [0 0 0; 1 0 0; 0 1 0];
    mesh.triangles = [1 2 3];

    octree = build_octree(mesh, 3, 1);

    % Check properties
    verifyTrue(testCase, octree.is_leaf);
    verifyEqual(testCase, length(octree.triangle_indices), 1);

    % Query above triangle
    query = [0.2, 0.2, 1];
    [pt, dist] = search_octree(query, octree, mesh);

    expected_pt = [0.2, 0.2, 0];
    verifyEqual(testCase, pt, expected_pt, 'AbsTol', 1e-6);
    verifyEqual(testCase, dist, 1, 'AbsTol', 1e-6);
end

function testBoundingBox(testCase)
    % Test bounding box computation
    mesh.vertices = [0 0 0; 2 2 2];
    mesh.triangles = [1 2 2]; % dummy triangle

    octree = build_octree(mesh);

    expected_min = [0 0 0] - 0.01 * norm([2 2 2]);
    expected_max = [2 2 2] + 0.01 * norm([2 2 2]);

    verifyEqual(testCase, octree.min_bound, expected_min, 'AbsTol', 1e-8);
    verifyEqual(testCase, octree.max_bound, expected_max, 'AbsTol', 1e-8);
end

function testSubdivision(testCase)
    % Create mesh with many triangles to trigger subdivision
    mesh.vertices = rand(50, 3);
    mesh.triangles = randi([1, 50], [30, 3]);

    octree = build_octree(mesh, 3, 5);

    % Expect subdivision (non-leaf)
    verifyFalse(testCase, octree.is_leaf);
    verifyGreaterThan(testCase, length(octree.children), 0);
end

function testSearchMatchesBruteForce(testCase)
    % Compare octree search to brute-force search
    mesh.vertices = rand(20, 3);
    mesh.triangles = randi([1, 20], [10, 3]);
    octree = build_octree(mesh, 4, 3);
    query = [0.5, 0.5, 0.5];

    [pt_tree, dist_tree] = search_octree(query, octree, mesh);

    % Brute-force check
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
    box_min = [0, 0, 0];
    box_max = [1, 1, 1];
    query = [0.5, 0.5, 0.5];
    d = point_to_box_distance(query, box_min, box_max);
    verifyEqual(testCase, d, 0, 'AbsTol', 1e-12);
end

function testPointOutsideBox(testCase)
    box_min = [0, 0, 0];
    box_max = [1, 1, 1];
    query = [2, 0.5, 0.5];
    d = point_to_box_distance(query, box_min, box_max);
    verifyEqual(testCase, d, 1, 'AbsTol', 1e-12);
end

