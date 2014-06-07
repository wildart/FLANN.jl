import Base.close

immutable FLANNIndex <: NearestNeighborTree
	index::Ptr{Void}
	flann_params::Ptr{Void}
	params::FLANNParameters
end

function setparameters(p::FLANNParameters)
	params = ccall((:create_params, "deps/flann_wrapper.so"), Ptr{Void},
		(Cint, Cint, Cfloat, Cint, Cint, Cint, Cint, Cint, Cint, Cint, Cint, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cuint, Cuint, Cuint, Cint, Clong, Cint, Cint),
		p.algorithm,
		p.checks,
		p.eps,
		p.sorted,
		p.max_neighbors,
		p.cores,
		p.trees,
		p.leaf_max_size,
		p.branching,
		p.iterations,
		p.centers_init,
		p.cb_index,
		p.target_precision,
		p.build_weight,
		p.memory_weight,
		p.sample_fraction,
		p.table_number,
		p.key_size,
		p.multi_probe_level,
		p.log_level,
		p.random_seed,
		p.distance_type,
		p.order)
	return params
end

function flann(X::Matrix, p::FLANNParameters)
	c, r = size(X)
	speedup = Cfloat[0]
	flann_params = setparameters(p)

	index = ccall((:flann_build_index, "libflann"), Ptr{Void},
		(Ptr{Cfloat}, Cint, Cint, Ptr{Cfloat}, Ptr{Void}),
		X, r, c, speedup, flann_params)

	return FLANNIndex(index, flann_params, p)
end

function nearest(index::FLANNIndex, xs, k = 1)
	trows = length(size(xs)) == 2 ? size(xs, 2) : 1
	datatype = eltype(xs)
	indices = Array(Cint, k, trows)
	dists = Array(Cfloat, k, trows)
	res = ccall((:flann_find_nearest_neighbors_index, "libflann"),
		Cint,
		(Ptr{Void}, Ptr{Cfloat}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
		index.index, xs, trows, indices, dists, k, index.flann_params)
	@assert (res == 0) "Unable to search"
	return indices.+1, dists
end

function nearest(X::Matrix, xs, k, p::FLANNParameters)
	c, r = size(X)
	trows = length(size(xs)) == 2 ? size(xs, 2) : 1
	indices = Array(Cint, k, trows)
	dists = Array(Cfloat, k, trows)
	flann_params = setparameters(p)

	#params = ccall((:set_params, "deps/flann_wrapper.so"), Ptr{Void}, (Int32, ), 0)
	#ccall((:get_params, "deps/flann_wrapper.so"), Void, (Ptr{Void},), params)

	res = ccall((:flann_find_nearest_neighbors, "libflann"),
		Cint,
		(Ptr{Cfloat}, Cint, Cint, Ptr{Cfloat}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
		X, r, c, xs, trows, indices, dists, k, flann_params)

	@assert (res == 0) "Unable to search"
	return indices.+1, dists
end

function Base.close(index::FLANNIndex)
	ccall((:flann_free_index, "libflann"), Void, (Ptr{Void},), index.index)
end

