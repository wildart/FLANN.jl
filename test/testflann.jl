module TestFLANN
	using Base.Test
	using FLANN

	# load test data
	X = readdlm(Pkg.dir("FLANN", "test", "iris.csv"), ',')
	x = X[:, 84]
	xs = X[:, [84,85]]

	# set parameters
	params = FLANNParameters()
	k = 10

	# build and search vector
	idxs, dsts = nearest(map(Float32, X), map(Float32, x), k, params)
	@test size(idxs) == (k,)
	@test size(dsts) == (k,)
	@test eltype(dsts) == Float32

	# build and search matrix
	idxs, dsts = nearest(X, xs, k, params)
	@test size(idxs) == (k, size(xs,2))
	@test size(dsts) == (k, size(xs,2))
	@test eltype(dsts) == eltype(xs)

	# build model
	model = flann(map(Float32, X), params)

	# search matrix
	idxs, dsts = nearest(model, map(Float32, xs), k)
	@test size(idxs) == (k, size(xs,2))
	@test size(dsts) == (k, size(xs,2))
	@test eltype(dsts) == Float32

	# close model
	close(model)

	# build model
	model = flann(X, params)

	# search vector
	idxs, dsts = nearest(model, x, k)
	@test size(idxs) == (k,)
	@test size(dsts) == (k,)
	@test eltype(dsts) == eltype(x)

	# inball search
	r = 0.44
	max_nn = 10
	idxs, dsts = inball(model, x, r^2)
	@test size(idxs)[1] < max_nn
	@test eltype(dsts) == eltype(x)

	# limited inball search
	idxs, dsts = inball(model, x, 1.0, max_nn)
	@test size(idxs) == (max_nn, )

	# close model
	close(model)

	# using Distances package for metrics
	using Distances
	metric = JSDivergence()
	@test_throws ErrorException flann(X, params, metric)

	metric = Euclidean()
	m, _ = FLANN.FLANNMetric(metric)
	@test m == FLANN.FLANN_DIST_EUCLIDEAN

	metric = Cityblock()
	m, _ = FLANN.FLANNMetric(metric)
	@test m == FLANN.FLANN_DIST_MANHATTAN

	metric = ChiSqDist()
	m, _ = FLANN.FLANNMetric(metric)
	@test m == FLANN.FLANN_DIST_CHI_SQUARE

	metric = KLDivergence()
	m, _ = FLANN.FLANNMetric(metric)
	@test m == FLANN.FLANN_DIST_KULLBACK_LEIBLER

	metric = Minkowski(2.0)
	m, o = FLANN.FLANNMetric(metric)
	@test m == FLANN.FLANN_DIST_MINKOWSKI
	@test o == 2.0

	model = flann(X, params, metric)
	idxs, dsts = nearest(model, x, k)
	@test size(idxs) == (k,)
	@test size(dsts) == (k,)
	@test eltype(dsts) == eltype(x)
	close(model)
end
