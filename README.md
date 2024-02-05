# Conway's Game of Life

Conway's **Game of Life** implementation in the **Godot Engine** (v4.2.1).

---

## 👾 About Conway's Game of Life
The **Game of Life** (by John Horton Conway in 1970) is a **cellular automaton** (a model of computation studied in **computational theory**) and it's **evolution** is determined by its **initial state**.

The game consists of an orthogonal, two-dimensional grid of square cells, each of which is in one of two possible states, **alive** or **dead**. 
Each cell interacts with its **neighbors** (the cells that are horizontally, vertically, or diagonally adjacent). 

At each step one of the following actions occurs:
  + Each live cell with two or three live neighbors moves on to the next generation (**surviving**).
  + Each live cell with fewer than two live neighbors dies (**underpopulated**).
  + Each live cell with more than three live neighbors dies (**overpopulated**).
  + Every dead cell with exactly three live neighbors becomes a live cell (**reproduction**).

> [!IMPORTANT]
> The Game of Life is Turing Complete! 🤩

## 🍩 Torus
Usually the Game of Life universe is defined as an infinite, two-dimensional, orthogonal grid of square cells, in this case it is defined on a topological torus.

A topological torus is a topological space homeomorphic to a torus in Euclidean space. It can be defined as the product of two circumferences $C^1 \times C^2$
or equivalently consider a square and "glue" the opposite sides together. This corresponds to defining on the square $S = [0, 1] \times [0,1] \subseteq \\mathbb{R}^2$
the equivalence relation $∼_T$ such that $x ∼_T y \Longleftrightarrow x = y$ is a unique interior point or $x$ and $y$ are on two opposite sides and have an equal coordinate. 
With this equivalence relation, one can define the quotient space $S / {∼_T}$ wich is a topological torus.

## 🖼️ Screenshots
#### Simulation with the sample "Gosper's gliders cannon"
![screenshot 128 cells](./images/screenshots/screenshot-gosper-glider.png)

#### Simulation 128x128 cells, with initial state from a [Simplex noise](https://en.wikipedia.org/wiki/Simplex_noise) image.
![screenshot 128 cells](./images/screenshots/screenshot-128.png)

#### Simulation 1024x1024 cells, with initial state from a [Simplex noise](https://en.wikipedia.org/wiki/Simplex_noise) image.
![screenshot 1024 cells](./images/screenshots/screenshot-1024.png)
