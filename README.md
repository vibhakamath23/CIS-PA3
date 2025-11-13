# CIS-PA3

## File Directory

### Data

- **Debug Files**: In the format `PA3-Debug-[A-F]-.....txt`, each set of letter files contain input and debug output data used for validating `pa3.m`.

- **Unknown Files**: In the format `PA3-Unknown-[G,H,J]-.....txt`, each letter file contain only input data, used to produce final results with `pa3.m`.

### Output

- **Output Files from Debug Input**: In the format `pa3-[a-f]-debug-Output.txt`, each file contains input output data from running `pa3.m` on the corresponding debug data.

- - **Output Files from Unknown Input**: In the format `pa3-[g,h,j]-unknown-Output.txt`, each file contains input output data from running `pa3.m` on the corresponding unknown data.
  
- - **Auxiliary Files**: In the format `pa3-[a-h,j]-[unknown, debug]-[linear, octree, boundingSphere]-aux.txt`, each file contains runtime and error statistics for the corresponding data, mode, and search method

### Programs
- `pa3.m`: Main executable for Programming Assignment 3. Runs the ICP pipeline — reads input files, computes pointer tip positions, finds closest points on the mesh surface, and writes output files with timing and error statistics.  

- `read_body_file.m`: Parses rigid body definition files containing LED marker positions and tip location.  

- `read_mesh_file.m`: Reads surface mesh files containing vertex coordinates and triangle connectivity.  

- `read_sample_file.m`: Reads tracked marker position data across all frames.  

- `split_marker_values.m`: Splits combined marker arrays into separate A, B, and D marker arrays based on body definitions.  

- `point_cloud_registration.m`: Computes the optimal rigid transformation (rotation and translation) that aligns two corresponding point sets using an SVD-based method.  

- `inv_homog.m`: Computes the inverse of a homogeneous transformation matrix.  

- `transform_point.m`: Applies a homogeneous transformation to a 3D point.  

- `dk_from_sample_input.m`: Computes pointer tip positions (`d_k`) in body B frame across all sample frames using point cloud registration.  

- `find_closest_point_tri.m`: Finds the closest point on a triangle to a query point using barycentric coordinates and edge projection.  

- `project_on_segment.m`: Projects a point onto a line segment, clamping the result to the segment endpoints.  

- `find_closest_point_mesh.m`: Performs a linear search to find the closest point on the mesh by testing all triangles sequentially.  

- `build_octree.m`: Constructs an octree spatial data structure for the mesh by recursively subdividing space into eight octants.  

- `subdivide_node.m`: Recursively subdivides an octree node into eight children based on depth and triangle count criteria.  

- `find_triangles_in_box.m`: Determines which triangles from a list intersect a given axis-aligned bounding box using overlap tests.  

- `search_octree.m`: Searches the octree for the closest point on the mesh using recursive traversal and early termination based on bounding box distances.  

- `point_to_box_distance.m`: Computes the minimum distance from a point to an axis-aligned bounding box (returns 0 if the point is inside the box).  

- `precompute_bounding_spheres.m`: Precomputes bounding spheres (center and radius) for each triangle in the mesh, defined by the centroid and maximum vertex distance.  

- `bounding_sphere_find_closest_point_mesh.m`: Accelerated closest point search using bounding sphere culling and sorted candidate evaluation with early termination.  

- `write_output3.m`: Writes PA3 output files containing pointer tip positions (`d_k`), closest points (`c_k`), and difference magnitudes for each frame.  

- `write_aux_file.m`: Creates auxiliary results files logging the search method, timing statistics, and error summaries compared to debug output when applicable.  

---

### Testing & Utility Files

- `test_find_closest_point_tri.m`: Unit tests for `find_closest_point_tri`, including projections onto triangle surfaces, edges, and vertices, and handling of collinear/degenerate cases.  

- `octree_unit_tests.m`: Unit tests for octree construction and search — includes tests for subdivision, bounding boxes, and accuracy vs. brute-force search.  

- `dk_unit_tests.m`: Unit tests for `d_k` computation and marker splitting, verifying dimensions, identity transforms, and consistency across frames using random data.  

- `create_random_body.m`: Generates random rigid body data (markers, tip, and name fields) for unit tests.  

- `create_random_samples.m`: Generates random sample data (A, B, and dummy markers) for `d_k` unit tests.  

- `bounding_sphere_unit_tests.m`: Unit tests for bounding sphere acceleration — checks correctness, early termination, and multi-triangle consistency.  

- `sampleTriangle.m`: Helper function returning a fixed non-trivial 3D triangle for consistent testing across files.  

- `visualize_find_closest_point_tri_3D.m`: Visualization utility that plots a 3D triangle and query points with their closest point projections for verification.  

- `test_pivot_calibration.m`: Unit tests for pivot calibration, verifying known-solution recovery and error handling for edge cases.  

- `generate_random_data.m`: Generates a random centered 3D point set and true parameters for pivot calibration tests.  

- `generate_random_pivot.m`: Generates a random pivot frame by applying random rotation and translation to a given 3D point set.  
