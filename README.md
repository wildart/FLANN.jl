FLANN.jl [![Build Status](https://travis-ci.org/wildart/FLANN.jl.svg?branch=master)](https://travis-ci.org/wildart/FLANN.jl) [![Coverage Status](https://coveralls.io/repos/wildart/FLANN.jl/badge.svg?branch=master)](https://coveralls.io/r/wildart/FLANN.jl?branch=master)
========
A simple wrapper for [FLANN](https://github.com/flann-lib/flann), Fast Library for Approximate Nearest Neighbors. It has an interface similar to the [NearestNeighbors](https://github.com/KristofferC/NearestNeighbors.jl) package API.

# Installation
Prerequisites for building binary dependency: `gcc`, `cmake`, `liblz4`.

Use the package manager to install:

	pkg> add FLANN

# Usage Example

```julia
using Distances
using FLANN

X = readdlm(Pkg.dir("FLANN", "test", "iris.csv"), ',')
v = X[:, 84]
k = 3
r = 10.0

idxs, dsts = knn(X, v, k, FLANNParameters())

# or

t = flann(X, FLANNParameters(), Minkowski(3))
inds, dists = knn(t, v, k)

# or

idxs, dsts = inrange(t, v, r)

# Do not forget to close index!
close(t)
```

# TODO
* Documentation
