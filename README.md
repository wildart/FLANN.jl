FLANN.jl [![Build Status](https://travis-ci.org/wildart/FLANN.jl.svg)](https://travis-ci.org/wildart/FLANN.jl) [![Coverage Status](https://img.shields.io/coveralls/wildart/FLANN.jl.svg)](https://coveralls.io/r/wildart/FLANN.jl?branch=master)
========
A simple wrapper for [FLANN](http://www.cs.ubc.ca/research/flann/), Fast Library for Approximate Nearest Neighbors. It has an interface similar to the [NearestNeighbors](https://github.com/wildart/NearestNeighbors.jl) package API.

# Installation
Use the package manager to install

	julia> Pkg.add("FLANN")

or clone the package from this repository and build it.

	julia> Pkg.clone("https://github.com/wildart/FLANN.jl.git")
	julia> Pkg.build("FLANN")

## Linux
Depending on the version of your operation system, you'll be prompted to install a FLANN binary or it is going be built from the sources.

# Usage Example

```julia
	using Distances
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
