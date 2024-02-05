#[compute]
#version 450

const vec4 alive_color = vec4(1.0, 1.0, 1.0, 1.0);
const vec4 dead_color = vec4(0.0, 0.0, 0.0, 1.0);

// Invocations in the (x, y, z) dimension
layout (local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

// bindings 
layout(set = 0, binding = 0, std430) restrict buffer grid_buffer {
    int size[];
}
grid;

layout (set = 0, binding = 1, r8) restrict uniform readonly image2D input_image;
layout (set = 0, binding = 2, r8) restrict uniform writeonly image2D output_image;

bool is_cell_alive(int x, int y) {
    vec4 pixel = imageLoad(input_image, ivec2(x, y));
    return pixel.r > 0.5;
}

int count_alive_neighbours(int x, int y) {
    int count = 0;

    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if ( i == 0 && j == 0) continue;

            int neighbour_x = x + i;
            int neighbour_y = y + j;

            if (neighbour_x < 0) {
                neighbour_x = grid.size[0] - 1;
            }
            if (neighbour_x >= grid.size[0]) {
                neighbour_x = 0;
            }
            if (neighbour_y < 0) {
                neighbour_y = grid.size[1] - 1;
            }
            if (neighbour_y >= grid.size[1]) {
                neighbour_y = 0;
            }

            vec4 pixel = imageLoad(input_image, ivec2(neighbour_x, neighbour_y));

            count += int(is_cell_alive(neighbour_x, neighbour_y));
        }
    }

    return count;
}

void main() {
    ivec2 pos = ivec2(gl_GlobalInvocationID.xy);

    if (pos.x >= grid.size[0] || pos.y >= grid.size[1]) return;

    int liveNeighbours = count_alive_neighbours(pos.x, pos.y);

    bool isAlive = is_cell_alive(pos.x, pos.y);
    bool next_state = isAlive;

    if (isAlive && (liveNeighbours < 2 || liveNeighbours > 3)) {
        next_state = false;
    } else if (!isAlive && liveNeighbours == 3) {
        next_state = true;
    }
    
    vec4 color = next_state ? alive_color : dead_color;
    
    imageStore(output_image, pos, color);
    
}
