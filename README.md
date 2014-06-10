FLANN.jl
========

A simple wrapper for [FLANN](http://www.cs.ubc.ca/research/flann/), Fast Library for Approximate Nearest Neighbors. It has similar to [NearestNeighbors](https://github.com/wildart/NearestNeighbors.jl) package API.

# Requirements
Package requires FLANN 1.8.4 library to be installed.

	$ sudo apt-get install libflann1.8

# Installation
Just clone it from this repository.

	julia> Pkg.clone("https://github.com/wildart/FLANN.jl.git")

# Usage Example

```julia
	using Distance
    using FLANN

    X = readdlm(Pkg.dir("FLANN", "test", "iris.csv"), ',')
	v = X[:, 84]
	k = 3
	r = 10.0

	idxs, dsts = nearest(X, v, k, FLANNParameters())

	# or

	t = flann(X, FLANNParameters(), Minkowski(3))
	inds, dists = nearest(t, v, k)

	# or

	idxs, dsts = inball(t, v, r)

	# Do not forget to close index!
	close(t)
```

# TODO
* Documentation
