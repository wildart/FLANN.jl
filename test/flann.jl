module TestFLANN
	using Base.Test
	using FLANN

	# load test data
	X = readdlm(Pkg.dir("FLANN", "test", "iris.csv"), ',')
	x = X[:, 84]
	xs = X[:, [84,85]]

	# set parameters
	params = FLANNParameters()
	k = 3

	# build and search vector
	idxs, dsts = nearest(float32(X), float32(x), k, params)
	@test size(idxs) == (k,)
	@test size(dsts) == (k,)
	@test eltype(dsts) == Float32

	# build and search matrix
	idxs, dsts = nearest(X, xs, k, params)
	@test size(idxs) == (k, size(xs,2))
	@test size(dsts) == (k, size(xs,2))
	@test eltype(dsts) == eltype(xs)

	# build model
	model = flann(X, params)

	# search vector
	idxs, dsts = nearest(model, x, k)
	@test size(idxs) == (k,)
	@test size(dsts) == (k,)
	@test eltype(dsts) == eltype(x)

	# close model
	close(model)

	# build model
	model = flann(float32(X), params)

	# search matrix
	idxs, dsts = nearest(model, float32(xs), k)
	@test size(idxs) == (k, size(xs,2))
	@test size(dsts) == (k, size(xs,2))
	@test eltype(dsts) == Float32

	# close model
	close(model)

	# using Distance package for metrics
	using Distance
	metric = JSDivergence()
	model = flann(X, params, metric)
	idxs, dsts = nearest(model, x, k)
	close(model)
end