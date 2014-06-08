import Base.close

immutable FLANNIndex <: NearestNeighborTree
	dim::Int
	dt::DataType
	index::Ptr{Void}
	flann_params::Ptr{Void}
	params::FLANNParameters
end

function setparameters(p::FLANNParameters)
	params = ccall((:create_params, flann_wrapper), Ptr{Void},
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
	elemtype = eltype(X)

	if elemtype == Cfloat
		index = ccall((:flann_build_index_float, libflann), Ptr{Void},
			(Ptr{Cfloat}, Cint, Cint, Ptr{Cfloat}, Ptr{Void}),
			X, r, c, speedup, flann_params)
	elseif elemtype == Cdouble
		index = ccall((:flann_build_index_double, libflann), Ptr{Void},
			(Ptr{Cdouble}, Cint, Cint, Ptr{Cfloat}, Ptr{Void}),
			X, r, c, speedup, flann_params)
	elseif elemtype == Cint
		index = ccall((:flann_build_index_int, libflann), Ptr{Void},
			(Ptr{Cint}, Cint, Cint, Ptr{Cfloat}, Ptr{Void}),
			X, r, c, speedup, flann_params)
	elseif elemtype == Cuchar
		index = ccall((:flann_build_index_byte, libflann), Ptr{Void},
			(Ptr{Cuchar}, Cint, Cint, Ptr{Cfloat}, Ptr{Void}),
			X, r, c, speedup, flann_params)
	else
		error("Unsupported data type")
	end

	return FLANNIndex(c, elemtype, index, flann_params, p)
end

function nearest(index::FLANNIndex, xs, k = 1)

	@assert isa(xs, Array) "Test data must be of type Vector or Matrix"
	@assert index.dt == eltype(xs) "Train and test data must have same type"
	distancetype = index.dt == Cdouble ? Cdouble : Cfloat

	# handle input as matrix or vector
	if length(size(xs)) == 1
		xsd, trows = length(xs), 1
		indices = Array(Cint, k)
		dists = Array(distancetype, k)
	else
		xsd, trows = size(xs)
		indices = Array(Cint, k, trows)
		dists = Array(distancetype, k, trows)
	end
	@assert xsd == index.dim "Train and test data of different dimensionality"

	if index.dt == Cfloat
		res = ccall((:flann_find_nearest_neighbors_index_float, libflann), Cint,
			(Ptr{Void}, Ptr{Cfloat}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
			index.index, xs, trows, indices, dists, k, index.flann_params)
	elseif index.dt == Cdouble
		res = ccall((:flann_find_nearest_neighbors_index_double, libflann), Cint,
			(Ptr{Void}, Ptr{Cdouble}, Cint, Ptr{Cint}, Ptr{Cdouble}, Cint, Ptr{Void}),
			index.index, xs, trows, indices, dists, k, index.flann_params)

	elseif index.dt == Cint
		res = ccall((:flann_find_nearest_neighbors_index_int, libflann), Cint,
			(Ptr{Void}, Ptr{Cint}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
			index.index, xs, trows, indices, dists, k, index.flann_params)

	elseif index.dt == Cuchar
		res = ccall((:flann_find_nearest_neighbors_index_byte, libflann), Cint,
			(Ptr{Void}, Ptr{Cuchar}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
			index.index, xs, trows, indices, dists, k, index.flann_params)
	else
		error("Unsupported data type")
	end

	@assert (res == 0) "Unable to search"

	return indices.+1, dists
end

function nearest(X::Matrix, xs, k, p::FLANNParameters)
	c, r = size(X)

	@assert isa(xs, Array) "Test data must be of type Vector or Matrix"

	elemtype = eltype(X)
	@assert elemtype == eltype(xs) "Train and test data must have same type"
	distancetype = elemtype == Cdouble ? Cdouble : Cfloat

	# handle input as matrix or vector
	if length(size(xs)) == 1
		xsd, trows = length(xs), 1
		indices = Array(Cint, k)
		dists = Array(distancetype, k)
	else
		xsd, trows = size(xs)
		indices = Array(Cint, k, trows)
		dists = Array(distancetype, k, trows)
	end
	@assert xsd == c "Train and test data of different dimensionality"

	flann_params = setparameters(p)

	if elemtype == Cfloat
		res = ccall((:flann_find_nearest_neighbors_float, libflann), Cint,
			(Ptr{Cfloat}, Cint, Cint, Ptr{Cfloat}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
			X, r, c, xs, trows, indices, dists, k, flann_params)
	elseif elemtype == Cdouble
		res = ccall((:flann_find_nearest_neighbors_double, libflann), Cint,
			(Ptr{Cdouble}, Cint, Cint, Ptr{Cdouble}, Cint, Ptr{Cint}, Ptr{Cdouble}, Cint, Ptr{Void}),
			X, r, c, xs, trows, indices, dists, k, flann_params)
	elseif elemtype == Cint
		res = ccall((:flann_find_nearest_neighbors_int, libflann), Cint,
			(Ptr{Cint}, Cint, Cint, Ptr{Cint}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
			X, r, c, xs, trows, indices, dists, k, flann_params)
	elseif elemtype == Cuchar
		res = ccall((:flann_find_nearest_neighbors_byte, libflann), Cint,
			(Ptr{Cuchar}, Cint, Cint, Ptr{Cuchar}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
			X, r, c, xs, trows, indices, dists, k, flann_params)
	else
		error("Unsupported data type")
	end

	@assert (res == 0) "Search failed!"

	return indices.+1, dists
end

function Base.close(index::FLANNIndex)
	ccall((:flann_free_index, libflann), Void, (Ptr{Void},), index.index)
end

function getparameters(model::FLANNIndex)
	ccall((:get_params, flann_wrapper), Void, (Ptr{Void},), model.flann_params)
end