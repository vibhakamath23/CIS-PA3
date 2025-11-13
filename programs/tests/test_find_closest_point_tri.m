function tests = test_find_closest_point_tri
    addpath('../programs');
    tests = functiontests(localfunctions);
end

function tri = sampleTriangle()
    % random triangle (not an easy one)
    tri = [0 0 0; 1 0.2 0.5; 0.2 1 0.8];
end

% general test; projection should go to the surface inside triangle
function testPointOnSurface(testCase)
    tri = sampleTriangle();
    a = [0.3, 0.3, 1.5];
    point = find_closest_point_tri(a, tri);
    % projection should lie on the plane of the triangle
    n = cross(tri(2,:)-tri(1,:), tri(3,:)-tri(1,:));
    d = dot(n, tri(1,:));
    dist = abs(dot(n, point) - d) / norm(n);
    verifyLessThan(testCase, dist, 1e-10);
end

% edge case; point near P
function testPointNear_V_P(testCase)
    tri = sampleTriangle();
    a = [-0.5, -0.5, -0.5];
    point = find_closest_point_tri(a, tri);
    verifyEqual(testCase, point, tri(1,:), 'AbsTol', 1e-10);
end

% edge case; point near Q
function testPointNear_V_Q(testCase)
    tri = sampleTriangle();
    a = [2, 0.5, 1];
    point = find_closest_point_tri(a, tri);
    verifyEqual(testCase, point, tri(2,:), 'AbsTol', 1e-10);
end

% edge case; point near R
function testPointNear_V_R(testCase)
    tri = sampleTriangle();
    a = [0.1, 1.8, 1.5];
    point = find_closest_point_tri(a, tri);
    verifyEqual(testCase, point, tri(3,:), 'AbsTol', 1e-10);
end

% edge case; point near edge (p;q)
function testPointNear_E_PQ(testCase)
    tri = sampleTriangle();
    % point under PQ
    a = [0.5, -0.3, 0.1];
    point = find_closest_point_tri(a, tri);
    % check projection on to PQ
    v1 = tri(2,:) - tri(1,:);
    rel = point - tri(1,:);
    lambda = dot(rel, v1) / dot(v1, v1);
    verifyGreaterThanOrEqual(testCase, lambda, 0);
    verifyLessThanOrEqual(testCase, lambda, 1);
end

% edge case; point near edge (p;r)
function testPointNear_E_PR(testCase)
    tri = sampleTriangle();
    a = [-0.1, 0.7, 0.4];
    point = find_closest_point_tri(a, tri);
    v1 = tri(3,:) - tri(1,:);
    rel = point - tri(1,:);
    mu = dot(rel, v1) / dot(v1, v1);
    verifyGreaterThanOrEqual(testCase, mu, 0);
    verifyLessThanOrEqual(testCase, mu, 1);
end

% edge case; point near edge (Q;r)
function testPointNear_E_QR(testCase)
    tri = sampleTriangle();
    a = [0.8, 0.6, 1.0];
    point = find_closest_point_tri(a, tri);
    % check that it is on edge QR
    v1 = tri(3,:) - tri(2,:);
    rel = point - tri(2,:);
    t = dot(rel, v1) / dot(v1, v1);
    verifyGreaterThanOrEqual(testCase, t, 0);
    verifyLessThanOrEqual(testCase, t, 1);
end

% point is already on the triangle
function testPointOnTriangle(testCase)
    tri = sampleTriangle();
    a = 0.2*tri(1,:) + 0.4*tri(2,:) + 0.4*tri(3,:);
    point = find_closest_point_tri(a, tri);
    verifyEqual(testCase, point, a, 'AbsTol', 1e-10);
end

% edge case; check the projection 
function testFarAbove(testCase)
    tri = sampleTriangle();
    a = [0.5, 0.4, 5];
    point = find_closest_point_tri(a, tri);
    % check projection
    n = cross(tri(2,:)-tri(1,:), tri(3,:)-tri(1,:));
    d = dot(n, tri(1,:));
    dist = abs(dot(n, point) - d) / norm(n);
    verifyLessThan(testCase, dist, 1e-10);
end

% collinear case
function testNearlyCollinear(testCase)
    tri = [0 0 0; 1 0.001 0; 2 0.002 0];
    a = [0.5, 0.2, 0];
    point = find_closest_point_tri(a, tri);
    % projection is on x-axis
    verifyLessThan(testCase, abs(point(2)), 1e-3);
end
