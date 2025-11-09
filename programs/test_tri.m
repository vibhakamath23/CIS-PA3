tri = [0 0 0; 1 0 0; 0 1 0];
pts = [0.2 0.2 0; 1.1 0.2 0; -0.1 0.4 0; 0.3 -0.2 0];
for i=1:size(pts,1)
    c = find_closest_point_tri(pts(i,:), tri);
    plot3(pts(i,1), pts(i,2), pts(i,3), 'rx'); hold on
    plot3(c(1), c(2), c(3), 'bo');
end
fill3(tri(:,1), tri(:,2), tri(:,3), 'g','FaceAlpha',0.2);
axis equal
