function mesh = precompute_bounding_spheres(mesh)
% Precomputes bounding sphere (center and radius) for each triangle in mesh. Sphere is
% defined by triangle centroid and maximum distance to vertices.
%
% Inputs: 
%    mesh (struct with vertices and triangles)
% Outputs: 
%    mesh (updated with bounding spheres field containing centers and radii)

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
