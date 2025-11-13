function point = find_closest_point_tri(a, triangle)
% find closest point on triangular mesh
%
% Input:
%   a - 1x3 query point coordinates
%   triangle - 1 x 3 array of vertex coordinates
%
% Output:
%   closest_point - 1x3 coordinates of closest point on triangle
    p = triangle(1, :);
    q = triangle(2, :);
    r = triangle(3, :);

    edge_1 = q - p;
    edge_2 = r - p;
    
    % a - p = [q-p r-p] * [lambda mu]^T; find [lambda mu]
    A = [edge_1; edge_2].';
    b = (a - p).';
    
    % solve for lambda and mu
    lambda_mu = A \ b;
    lambda = lambda_mu(1);
    mu = lambda_mu(2);

    point = p + lambda * edge_1 + mu * edge_2;

    u = 1 - lambda - mu;

    if (lambda >= 0) && (mu >= 0) && (u >= 0)
        return;
    end
    
    % edge cases
    % u = 1 - lambda - mu;   % weight for vertex p
    % lambda;            % weight for vertex q
    % mu;  % weight for vertex r
    
    % vertex p region
    if (lambda <= 0) && (mu <= 0)
        % closest point - vertex p
        point = p;
        return;
    end
    if (u <= 0) && (mu <= 0)
        % closest point - vertex q
        point = q;
        return;
    end
    if (u <= 0) && (lambda <= 0)
        % closest point - vertex r
        point = r;
        return;
    end
    if (lambda <= 0) && (u >= 0) && (mu >= 0)
        % ProjectOnSegment(c,p,r)
        point = project_on_segment(point, p, r);
        return;
    end
    if (mu <= 0) && (u >= 0) && (lambda >= 0)
        % ProjectOnSegment(c,p,q)
        point = project_on_segment(point, p, q);
        return;
    end
    if (u <= 0) && (mu >= 0) && (lambda >= 0)
        % ProjectOnSegment(c,q,r)
        point = project_on_segment(point, q, r);
        return;
    end

end