module TestFLANN
    using Test
    using DelimitedFiles
    using FLANN

    # load test data
    X = readdlm(normpath(dirname(@__FILE__), "iris.csv"), ',')
    float32X = map(Float32,X)
    x = X[:, 84]
    float32x = map(Float32,x)
    xs = X[:, [84,85]]
    float32xs = map(Float32,xs)

    # set parameters
    params = FLANNParameters()
    k = 10

    # build and search vector
    idxs, dsts = knn(float32X, float32x, k, params)
    @test size(idxs) == (k,)
    @test size(dsts) == (k,)
    @test eltype(dsts) == Float32

    # build and search matrix
    idxs, dsts = knn(X, xs, k, params)
    @test size(idxs) == (k, size(xs,2))
    @test size(dsts) == (k, size(xs,2))
    @test eltype(dsts) == eltype(xs)

    # build model
    model = flann(float32X, params)

    # search matrix
    idxs, dsts = knn(model, float32xs, k)
    @test size(idxs) == (k, size(xs,2))
    @test size(dsts) == (k, size(xs,2))
    @test eltype(dsts) == Float32

    # close model
    close(model)

    # build model
    model = flann(X, params)

    # search vector
    idxs, dsts = knn(model, x, k)
    @test size(idxs) == (k,)
    @test size(dsts) == (k,)
    @test eltype(dsts) == eltype(x)

    # inrange search
    r = 0.44
    max_nn = 10
    idxs, dsts = inrange(model, x, r^2)
    @test size(idxs)[1] < max_nn
    @test eltype(dsts) == eltype(x)

    # limited inrange search
    idxs, dsts = inrange(model, x, 1.0, max_nn)
    @test size(idxs) == (max_nn, )

    # preallocated inrange! and knn! tests
    idxs = fill(Cint(-1), k)
    dists = fill(eltype(X)(-1), k)
    knn!(X, x, k, params, idxs, dists)
    @test all(idxs .>= 1)
    @test all(dists .>= 0)

    idxs = fill(Cint(-1), k)
    dists = fill(eltype(X)(-1), k)
    knn!(model, x, k, idxs, dists)
    @test all(idxs .>= 1)
    @test all(dists .>= 0)

    idxs = fill(Cint(-1), k)
    dists = fill(eltype(X)(-1), k)
    idxs_view, dists_view = inrange!(model, x, r^2, max_nn, idxs, dists)
    @test all(idxs_view .>= 1)
    @test all(dists_view .>= 0)

    # close model
    close(model)

    # testing incremental operations (add, remove, length)
    traindata = ones(3) * (.1:.1:1)'
    model = flann(traindata, FLANNParameters(checks = -1, trees = 1))
    @test knn(model, .47*ones(3), 2)[1] == [5,4]
    @test length(model) == 10
    addpoints!(model, .45*ones(3))
    @test knn(model, .47*ones(3), 2)[1] == [11,5]
    @test length(model) == 11
    removepoint!(model, 11)
    @test knn(model, .47*ones(3), 2)[1] == [5,4]
    @test length(model) == 10

    # testing getindex
    @test model[5] == .5*ones(3)

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
    idxs, dsts = knn(model, x, k)
    @test size(idxs) == (k,)
    @test size(dsts) == (k,)
    @test eltype(dsts) == eltype(x)

    tmpfile = joinpath(tempdir(), tempname())
    write(tmpfile, model)
    close(model)

    loaded = read(tmpfile, X, params)
    idxs2, dsts2 = knn(loaded, x, k)
    @test idxs == idxs2
    @test dsts == dsts2
    @test eltype(dsts) == eltype(dsts2)
    isfile(tmpfile) && rm(tmpfile)
end
