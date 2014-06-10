import Base.close

immutable FLANNIndex
	dim::Int
	dt::DataType
	index::Ptr{Void}
	params::FLANNParameters
	metric::Cint
	order::Cint
end

getparameters() = cglobal((:DEFAULT_FLANN_PARAMETERS, libflann), FLANNParameters)

function setparameters(p::FLANNParameters)
	pp = getparameters()
	unsafe_store!(pp, p, 1)
	return pp
end

function setmetric(metric::Cint, order::Cint = 2)
	ccall((:flann_set_distance_type, libflann), Void, (Cint, Cint), metric, order)
end

function flann(X::Matrix, p::FLANNParameters, metric::Int = FLANN_DIST_EUCLIDEAN, order::Int = 2)
	c, r = size(X)
	speedup = Cfloat[0]
	setmetric(int32(metric), int32(order))
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

	return FLANNIndex(c, elemtype, index, p, metric, order)
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

	flann_params = getparameters()

	if index.dt == Cfloat
		res = ccall((:flann_find_nearest_neighbors_index_float, libflann), Cint,
			(Ptr{Void}, Ptr{Cfloat}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
			index.index, xs, trows, indices, dists, k, flann_params)
	elseif index.dt == Cdouble
		res = ccall((:flann_find_nearest_neighbors_index_double, libflann), Cint,
			(Ptr{Void}, Ptr{Cdouble}, Cint, Ptr{Cint}, Ptr{Cdouble}, Cint, Ptr{Void}),
			index.index, xs, trows, indices, dists, k, flann_params)

	elseif index.dt == Cint
		res = ccall((:flann_find_nearest_neighbors_index_int, libflann), Cint,
			(Ptr{Void}, Ptr{Cint}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
			index.index, xs, trows, indices, dists, k, flann_params)

	elseif index.dt == Cuchar
		res = ccall((:flann_find_nearest_neighbors_index_byte, libflann), Cint,
			(Ptr{Void}, Ptr{Cuchar}, Cint, Ptr{Cint}, Ptr{Cfloat}, Cint, Ptr{Void}),
			index.index, xs, trows, indices, dists, k, flann_params)
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

function inball(index::FLANNIndex, xs, r2::Real, max_nn::Int = 10)
	@assert isa(xs, Array) "Test data must be of type Vector or Matrix"
	@assert index.dt == eltype(xs) "Train and test data must have same type"
	distancetype = index.dt == Cdouble ? Cdouble : Cfloat

	# handle input as matrix or vector
	if length(size(xs)) == 1
		xsd, trows = length(xs), 1
		indices = Array(Cint, max_nn)
		dists = Array(distancetype, max_nn)
	else
		xsd, trows = size(xs)
		indices = Array(Cint, max_nn, trows)
		dists = Array(distancetype, max_nn, trows)
	end
	@assert xsd == index.dim "Train and test data of different dimensionality"

	flann_params = getparameters()

	if index.dt == Cfloat
		res = ccall((:flann_radius_search_float, libflann), Cint,
			(Ptr{Void}, Ptr{Cfloat}, Ptr{Cint}, Ptr{Cfloat}, Cint, Cfloat, Ptr{Void}),
			index.index, xs, indices, dists, int32(max_nn), float32(r2), flann_params)
	elseif index.dt == Cdouble
		res = ccall((:flann_radius_search_double, libflann), Cint,
			(Ptr{Void}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cdouble}, Cint, Cfloat, Ptr{Void}),
			index.index, xs, indices, dists, int32(max_nn), float32(r2), flann_params)

	elseif index.dt == Cint
		res = ccall((:flann_radius_search_int, libflann), Cint,
			(Ptr{Void}, Ptr{Cint}, Ptr{Cint}, Ptr{Cfloat}, Cint, Cfloat, Ptr{Void}),
			index.index, xs, indices, dists, int32(max_nn), float32(r2), flann_params)

	elseif index.dt == Cuchar
		res = ccall((:flann_radius_search_byte, libflann), Cint,
			(Ptr{Void}, Ptr{Cuchar}, Ptr{Cint}, Ptr{Cfloat}, Cint, Cfloat, Ptr{Void}),
			index.index, xs, indices, dists, int32(max_nn), float32(r2), flann_params)
	else
		error("Unsupported data type")
	end

	@assert (res >= 0) "Unable to search"

	return (indices.+1)[1:res], dists[1:res]
end