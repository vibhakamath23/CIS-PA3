function samples = create_random_samples(n_A, n_B, n_frames)
% Creates random sample data for d_k unit tests
    samples.N_samps = n_frames;
    samples.N_A = n_A;
    samples.N_B = n_B;
    samples.N_D = 0;
    samples.N_S = n_A + n_B;
    
    samples.A_markers = randn(n_A, 3, n_frames) * 100;
    samples.B_markers = randn(n_B, 3, n_frames) * 100;
    samples.D_markers = zeros(0, 3, n_frames);
end
