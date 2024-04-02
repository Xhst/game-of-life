
#[compute]
#version 450
/*
Compute shader for cellular automaton simulation.

This shader calculates the next state of each cell in a grid-based cellular automaton
simulation using Conway's Game of Life rules. It reads the current state of cells
from an input image and writes the next state to an output image.
*/

// Colors representing alive and dead cells
const vec4 alive_color = vec4(1.0, 1.0, 1.0, 1.0);
const vec4 dead_color = vec4(0.0, 0.0, 0.0, 1.0);

// Invocations in the (x, y, z) dimension
layout (local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

// Buffer binding for grid size
layout(set = 0, binding = 0, std430) restrict buffer grid_buffer {
    // size[0] is the grid size X, size[1] is the grid size Y
    int size[];
}
grid;

// Image bindings for input and output
layout (set = 0, binding = 1, r8) restrict uniform readonly image2D input_image;
layout (set = 0, binding = 2, r8) restrict uniform writeonly image2D output_image;

// Function to check if a cell is alive
bool is_cell_alive(int x, int y) {
    vec4 pixel = imageLoad(input_image, ivec2(x, y));
    return pixel.r > 0.5;
}

// Function to count alive neighbors of a cell
int count_alive_neighbors(int x, int y) {
    int count = 0;

    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if (i == 0 && j == 0) continue;

            int neighbor_x = (x + i + grid.size[0]) % grid.size[0];
            int neighbor_y = (y + j + grid.size[1]) % grid.size[1];

            vec4 pixel = imageLoad(input_image, ivec2(neighbor_x, neighbor_y));

            count += int(is_cell_alive(neighbor_x, neighbor_y));
        }
    }

    return count;
}

// Main entry point of the compute shader
void main() {
    // Get the cell position
    ivec2 pos = ivec2(gl_GlobalInvocationID.xy);

    int alive_neighbors = count_alive_neighbors(pos.x, pos.y);
    
    bool is_alive = is_cell_alive(pos.x, pos.y);

    // Apply Conway's Game of Life rules
    bool next_state = is_alive && !(alive_neighbors < 2 || alive_neighbors > 3) || (!is_alive && alive_neighbors == 3);
    
    vec4 color = next_state ? alive_color : dead_color;
    
    // Write the next state to the output image
    imageStore(output_image, pos, color);
}
