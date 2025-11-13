function body = create_random_body(n_markers)
% Generates random rigid body data for d_k unit tests 
    % create random body definition
    body.markers = randn(n_markers, 3) * 10;
    body.tip = randn(1, 3) * 15;
    body.N_markers = n_markers;
    body.name = 'RandomBody';
end
