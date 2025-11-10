function mesh = precompute_bounding_spheres(mesh)
% Precompute bounding sphere for each triangle
% Returns smallest sphere that contains all three vertices

    N_triangles = size(mesh.triangles, 1);
    centers = zeros(N_triangles, 3);
    radii = zeros(N_triangles, 1);
    
    for i = 1:N_triangles
        v_indices = mesh.triangles(i, :);
        v1 = mesh.vertices(v_indices(1), :);
        v2 = mesh.vertices(v_indices(2), :);
        v3 = mesh.vertices(v_indices(3), :);
        
        % Centroid of triangle
        center = (v1 + v2 + v3) / 3;
        
        % Radius is max distance from center to any vertex
        d1 = norm(v1 - center);
        d2 = norm(v2 - center);
        d3 = norm(v3 - center);
        radius = max([d1, d2, d3]);
        
        centers(i, :) = center;
        radii(i) = radius;
    end
    
    mesh.bounding_spheres.centers = centers;
    mesh.bounding_spheres.radii = radii;
end
