FLANN.jl
========

A simple wrapper for [FLANN](http://www.cs.ubc.ca/research/flann/), Fast Library for Approximate Nearest Neighbors. It has similar to [NearestNeighbors](https://github.com/wildart/NearestNeighbors.jl) package API.

# Requirements
Package requires FLANN 1.8.4 library to be installed.

	$ sudo apt-get install libflann1.8

# Installation
Not all package dependencies are published into the official package repository. Fastest way to get them is cloning development forks.

	julia> Pkg.clone("https://github.com/wildart/Distance.jl.git")'
	julia> Pkg.clone("https://github.com/wildart/NearestNeighbors.jl.git")
	julia> Pkg.clone("https://github.com/wildart/FLANN.jl.git")

# Usage Example

```julia
	using Distance
    using FLANN

    X = readdlm(Pkg.dir("FLANN", "test", "iris.csv"), ',')
	v = X[:, 84]
	k = 3

	t = flann(X, FLANNParameters(), Minkowski(3))
	inds, dists = nearest(t, v, k)
	close(t)

	# or

	idxs, dsts = nearest(X, v, k, FLANNParameters())
```

# TODO

* Implement a ball search
* Documentation