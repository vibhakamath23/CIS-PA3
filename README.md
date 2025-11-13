# CIS-PA3

## File Directory

### Programs
- **pa3.m** — Main executable for Programming Assignment 3. Runs the ICP pipeline: reads input, computes pointer tip positions, finds closest points on the mesh, and writes output/timing/error files.  
- **read_body_file.m** — Parses rigid body definition files containing LED marker positions and tip location.  
- **read_mesh_file.m** — Reads surface mesh files containing vertex coordinates and triangle connectivity.  
- **read_sample_file.m** — Reads tracked marker position data across all frames.  
- **split_marker_values.m** — Splits combined marker arrays into separate A, B, and D marker arrays.  
- **point_cloud_registration.m** — Computes optimal rigid transformation aligning two point sets using SVD.  
- **inv_homog.m** — Computes the inverse of a homogeneous transformation matrix.  
- **transform_point.m** — Applies a homogeneous transformation to a 3D point.  
- **dk_from_sample_input.m** — Computes pointer tip positions (`d_k`) in body B frame across all sample frames.  
- **find_closest_point_tri.m** — Finds the closest point on a triangle to a query point using barycentric coordinates.  
- **project_on_segment.m** — Projects a point onto a line segment, clamped to segment endpoints.  
- **find_closest_point_mesh.m** — Performs a linear search to find the closest point on the mesh by testing all triangles.  
- **build_octree.m** — Builds an octree structure by recursively subdividing the mesh space.  
- **subdivide_node.m** — Recursively subdivides octree nodes based on triangle count and depth.  
- **find_triangles_in_box.m** — Determines which triangles intersect a bounding box.  
- **search_octree.m** — Searches the octree for the closest point on a mesh with early termination.  
- **point_to_box_distance.m** — Computes minimum distance from a point to an axis-aligned bounding box.  
- **precompute_bounding_spheres.m** — Precomputes bounding spheres (center + radius) for each triangle.  
- **bounding_sphere_find_closest_point_mesh.m** — Accelerated closest point search using bounding sphere culling and early termination.  
- **write_output3.m** — Writes output files containing tip positions, closest points, and difference magnitudes.  
- **write_aux_file.m** — Writes auxiliary logs with search method, timing, and error statistics.  

---

### Testing Files
- **test_find_closest_point_tri.m** — Unit tests for `find_closest_point_tri`, covering projections, edge cases, and collinearity.  
- **octree_unit_tests.m** — Unit tests for octree construction/search accuracy and bounding box calculations.  
- **dk_unit_tests.m** — Unit tests for `d_k` computation and marker splitting; includes random data checks.  
- **create_random_body.m** — Generates random rigid body data for unit tests.  
- **create_random_samples.m** — Generates random sample data for testing.  
- **bounding_sphere_unit_tests.m** — Unit tests for bounding sphere acceleration, correctness, and early termination.  
- **sampleTriangle.m** — Returns a fixed non-trivial 3D triangle used for testing.  
- **visualize_find_closest_point_tri_3D.m** — Visualizes a triangle and query points with closest point projections for debugging.  
- **test_pivot_calibration.m** — Unit tests for pivot calibration with known solutions and edge case handling.  
- **generate_random_data.m** — Generates random 3D point sets and true parameters for pivot calibration tests.  
- **generate_random_pivot.m** — Generates a random pivot frame with rotation and translation applied.  
