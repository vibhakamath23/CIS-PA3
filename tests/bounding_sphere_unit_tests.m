function tests = bounding_sphere_unit_tests
% Unit tests for bounding_sphere_find_closest_point_mesh
%
% Uses randomized mesh and query data to verify:
%   - Correctness vs brute-force search
%   - Proper use of bounding spheres
%   - Early termination behavior

    addpath('../programs'); % adjust as needed
    rng(42); % for reproducibility
    tests = functiontests(localfunctions);
end

function testRandomSingleTriangle(testCase)
    % Random single triangle
    mesh.vertices = rand(3,3) * 10;
    mesh.triangles = [1 2 3];

    % Precompute bounding sphere
    mesh = precompute_bounding_spheres(mesh);

    % Random query point near triangle
    c = mean(mesh.vertices,1);
    query = c + rand(1,3)*2 - 1;

    % Closest point using tested function
    pt = bounding_sphere_find_closest_point_mesh(query, mesh);

    % Reference using existing helper
    ref = find_closest_point_mesh(query, mesh);

    verifyEqual(testCase, pt, ref, 'AbsTol', 1e-6);
end

function testRandomMultipleTriangles(testCase)
    % Random mesh with multiple triangles
    Nverts = 30;
    Ntris = 10;
    mesh.vertices = rand(Nverts,3) * 20 - 10;
    mesh.triangles = randi([1, Nverts], [Ntris,3]);

    mesh = precompute_bounding_spheres(mesh);

    query = rand(1,3)*20 - 10;

    pt_bs = bounding_sphere_find_closest_point_mesh(query, mesh);
    pt_ref = find_closest_point_mesh(query, mesh);

    verifyEqual(testCase, pt_bs, pt_ref, 'AbsTol', 1e-6);
end

function testEarlyTerminationRandom(testCase)
    % Two clusters far apart
    cluster1 = rand(10,3);
    cluster2 = rand(10,3) + 50; % far away
    mesh.vertices = [cluster1; cluster2];
    mesh.triangles = [randi([1,10],[5,3]); randi([11,20],[5,3])];

    mesh = precompute_bounding_spheres(mesh);

    query = [0,0,0]; % near first cluster

    global CALL_COUNT
    CALL_COUNT = 0;

    pt = bounding_sphere_find_closest_point_mesh(query, mesh);

    verifyLessThan(testCase, CALL_COUNT, 10);
    verifyNotEmpty(testCase, pt);
end

function testConsistencyAcrossQueries(testCase)
    % Fixed mesh, multiple queries
    Nverts = 25;
    Ntris = 8;
    mesh.vertices = rand(Nverts,3) * 5;
    mesh.triangles = randi([1,Nverts],[Ntris,3]);

    mesh = precompute_bounding_spheres(mesh);

    for k = 1:5
        query = rand(1,3)*5;
        pt_bs = bounding_sphere_find_closest_point_mesh(query, mesh);
        pt_ref = find_closest_point_mesh(query, mesh);
        verifyEqual(testCase, pt_bs, pt_ref, 'AbsTol', 1e-6);
    end
end
