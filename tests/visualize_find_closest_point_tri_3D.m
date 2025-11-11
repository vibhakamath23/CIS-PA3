function visualize_find_closest_point_tri_3D()
    tri = sampleTriangle();

    % points to visualize
    pts = [
        0.3 0.3 0.3;   
        0.8 0.1 1.0;
        0.1 0.8 0.0;
        0.4 0.4 1.2;
        -0.2 0.2 -0.3;
        0.7 0.7 0.4;
    ];

    figure; hold on; grid on; axis equal;
    title('Visualization of find\_closest\_point\_tri function on a 3D triangle');
    xlabel('X'); ylabel('Y'); zlabel('Z');
    view(45,30);

    fill3(tri(:,1), tri(:,2), tri(:,3), 'g', 'FaceAlpha', 0.3, ...
        'EdgeColor', 'k', 'LineWidth', 1.5);

    % run function for finding closest point on triangle
    for i = 1:size(pts,1)
        a = pts(i,:);
        c = find_closest_point_tri(a, tri);
        plot3(a(1), a(2), a(3), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
        plot3(c(1), c(2), c(3), 'bo', 'MarkerSize', 8, 'LineWidth', 2);
        plot3([a(1) c(1)], [a(2) c(2)], [a(3) c(3)], 'k--', 'LineWidth', 1);
        text(a(1)+0.05, a(2), a(3)+0.05, sprintf('P%d', i), 'Color', 'r');
    end

    legend({'Triangle','Points for which finding projections','Closest point','Projection line'}, ...
        'Location', 'bestoutside');
end