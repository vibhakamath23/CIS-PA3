function c = find_closest_point_on_triangle(a, p, q, r)
% CHATGPT GENERATED findClosestPointOnTriangle - Finds closest point on a triangle to query point
%
% Input:
%   a - 1x3 query point
%   p, q, r - 1x3 vertices of triangle
%
% Output:
%   c - 1x3 closest point on triangle
%
% Algorithm (from lecture notes):
%   1. Project point onto triangle plane
%   2. Check if projection is inside triangle using barycentric coordinates
%   3. If inside, return projection
%   4. If outside, find closest point on edges

    % Ensure all inputs are row vectors
    if size(a, 1) ~= 1, a = a'; end
    if size(p, 1) ~= 1, p = p'; end
    if size(q, 1) ~= 1, q = q'; end
    if size(r, 1) ~= 1, r = r'; end
    
    % Compute vectors
    pq = q - p;
    pr = r - p;
    pa = a - p;
    
    % Compute normal to triangle plane
    n = cross(pq, pr);
    n_norm = norm(n);
    
    if n_norm < 1e-10
        % Degenerate triangle, just return closest vertex
        dp = norm(a - p);
        dq = norm(a - q);
        dr = norm(a - r);
        [~, idx] = min([dp, dq, dr]);
        vertices = [p; q; r];
        c = vertices(idx, :);
        return;
    end
    
    n = n / n_norm;
    
    % Project point onto triangle plane
    dist_to_plane = dot(pa, n);
    a_proj = a - dist_to_plane * n;
    
    % Check if projection is inside triangle using barycentric coordinates
    % Express a_proj = p + lambda*pq + mu*pr
    % Solve: [pq' pr'] * [lambda; mu] = (a_proj - p)'
    
    A_mat = [pq; pr]';  % 3x2
    b_vec = (a_proj - p)';  % 3x1
    
    % Least squares solution
    params = (A_mat' * A_mat) \ (A_mat' * b_vec);
    lambda = params(1);
    mu = params(2);
    
    % Check if inside triangle
    if lambda >= 0 && mu >= 0 && (lambda + mu) <= 1
        c = a_proj;
        return;
    end
    
    % Point is outside triangle, find closest point on edges
    % Check three edges: pq, qr, rp
    
    c1 = closestPointOnSegment(a, p, q);
    c2 = closestPointOnSegment(a, q, r);
    c3 = closestPointOnSegment(a, r, p);
    
    % Find which is closest
    d1 = norm(a - c1);
    d2 = norm(a - c2);
    d3 = norm(a - c3);
    
    [~, idx] = min([d1, d2, d3]);
    candidates = [c1; c2; c3];
    c = candidates(idx, :);
end

function c = closestPointOnSegment(a, p, q)
% closestPointOnSegment - Finds closest point on line segment pq to point a
%
% Input:
%   a - 1x3 query point
%   p, q - 1x3 endpoints of segment
%
% Output:
%   c - 1x3 closest point on segment

    pq = q - p;
    pa = a - p;
    
    % Parameter t for closest point: c = p + t*(q-p)
    t = dot(pa, pq) / dot(pq, pq);
    
    % Clamp t to [0, 1] to stay on segment
    t = max(0, min(1, t));
    
    c = p + t * pq;
end