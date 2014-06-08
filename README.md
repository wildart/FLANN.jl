FLANN.jl
========

A simple wrapper for [FLANN](http://www.cs.ubc.ca/research/flann/), Fast Library for Approximate Nearest Neighbors. It has similar to [NearestNeighbors](https://github.com/wildart/NearestNeighbors.jl) package API.

# Requirements
Package requires FLANN 1.8.4 development library installed.

	$ sudo apt-get install libflann1.8 libflann-dev

# Installation
Not all package dependencies are published into the official package repository. Fastest way to install them is to clone development forks.

	julia> Pkg.clone("https://github.com/wildart/Distance.jl.git")'
	julia> Pkg.clone("https://github.com/wildart/NearestNeighbors.jl.git")
	julia> Pkg.clone("https://github.com/wildart/FLANN.jl.git")
	julia> Pkg.resolve()
	julia> Pkg.build("FLANN")

Last 'build' command is needed to build wrapper library.
All dependencies resolves with help of [BinDeps](https://github.com/JuliaLang/BinDeps.jl) package.
Dependency resolution works only for Linux and GCC.
If you need other OS or compiler, look at 'deps' folder scripts.

# Usage Example

```julia
    using FLANN

    X = readdlm(Pkg.dir("FLANN", "test", "iris.csv"), ',')
	v = X[:, 84]

	t = flann(X, FLANNParameters())
	inds, dists = nearest(t, v, 1)

	# or

	idxs, dsts = nearest(X, v, k, FLANNParameters())
```

# TODO

* Implement a ball search
* Support of different operation systems
* Documentation