import Base: close, write, read, length, getindex

const FLANN_DataTypes = Union{Cfloat, Cdouble, Cint, Cuchar}

immutable FLANNIndex{T<:FLANN_DataTypes}
    dim::Int
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

function getmetric()
    ccall((:flann_get_distance_type, libflann), Cint, ()), ccall((:flann_get_distance_order, libflann), Cint, ())
end

"This function constructs a near neighbor search index for a given dataset (columns of `X` correspond to points)."
function flann{T<:FLANN_DataTypes}(X::Matrix{T}, p::FLANNParameters, metric::Int = FLANN_DIST_EUCLIDEAN, order::Int = 2)
    c, r = size(X)
    speedup = fill(Cfloat(0))
    setmetric(Cint(metric), Cint(order))
    flann_params = setparameters(p)

    index = _flann(X, r, c, speedup, flann_params)

    return FLANNIndex{T}(c, index, p, metric, order)
end

"This function adds points to a pre-built near neighbor search index."
function addpoints!{T<:FLANN_DataTypes}(index::FLANNIndex{T}, X::VecOrMat{T}, rebuild_threshold = 2)
    if ndims(X) == 1
        c, r = length(X), 1
    else
        c, r = size(X)
    end

    @assert c == index.dim "Existing index data and additional data of different dimensionality"

    res = _addpoints!(index, X, r, c, rebuild_threshold)

    @assert res == 0 "Adding points unsuccessful"

    return index
end

"This function removes a point from a pre-built near neighbor search index at the specified position `id`."
function removepoint!(index::FLANNIndex, id::Int)
    @assert 0 < id <= length(index) "Point id must be within bounds of index"

    res = _removepoint!(index, id-1)

    @assert res == 0 "Removing point unsuccessful"

    return index
end

"This function gets the point at the specified position `id` in a near neighbor search index."
function Base.getindex(index::FLANNIndex, id::Int)
    @assert 0 < id <= length(index) "Point id must be within bounds of index"

    return _getindex(index, id-1)
end

"This function returns the number of points stored in a near neighbor search index."
Base.length(index::FLANNIndex) = Int(_length(index))

"This function saves an index to a file. The dataset for which the index was built is not saved with the index."
function Base.write(filename::AbstractString, index::FLANNIndex)
    res = _write(index, filename)

    @assert res == 0 "Writing index unsuccessful"

    nothing    # Julia convention is to return number of bytes written; that seems impossible to get here
end

"This function loads a previously saved index from a file. Since the dataset is not saved with the index, it must be provided to this function."
function Base.read{T<:FLANN_DataTypes}(filename::AbstractString, X::Matrix{T}, p::FLANNParameters, metric::Int = FLANN_DIST_EUCLIDEAN, order::Int = 2)
    c, r = size(X)
    index = _read(filename, X, r, c)
    return FLANNIndex{T}(c, index, p, metric, order)
end

"This function builds a search index and uses it to find the `k` nearest neighbors of `xs` points using an already built `index`."
function knn{T<:FLANN_DataTypes}(X::Matrix{T}, xs::VecOrMat{T}, k, p::FLANNParameters)
    c, r = size(X)

    distancetype = T == Cdouble ? Cdouble : Cfloat

    # handle input as matrix or vector
    if ndims(xs) == 1
        xsd, trows = length(xs), 1
        indices = Array{Cint}(k)
        dists = Array{distancetype}(k)
    else
        xsd, trows = size(xs)
        indices = Array{Cint}(k, trows)
        dists = Array{distancetype}(k, trows)
    end
    @assert xsd == c "Dataset and query set of different dimensionality"

    flann_params = setparameters(p)

    res = _knn(X, r, c, xs, trows, indices, dists, k, flann_params)

    @assert res == 0 "Search failed!"

    return indices.+1, dists
end

"This function searches for the `k` nearest neighbors of `xs` points using an already built `index`."
function knn{T<:FLANN_DataTypes}(index::FLANNIndex{T}, xs::VecOrMat{T}, k = 1)
    distancetype = T == Cdouble ? Cdouble : Cfloat

    # handle input as matrix or vector
    if ndims(xs) == 1
        xsd, trows = length(xs), 1
        indices = Array{Cint}(k)
        dists = Array{distancetype}(k)
    else
        xsd, trows = size(xs)
        indices = Array{Cint}(k, trows)
        dists = Array{distancetype}(k, trows)
    end
    @assert xsd == index.dim "Dataset and query set of different dimensionality"

    flann_params = getparameters()

    res = _knn(index, xs, trows, indices, dists, k, flann_params)

    @assert res == 0 "Search failed!"

    return indices.+1, dists
end

"This function performs a radius search from a single query point to points in an already built `index`."
function inrange{T<:FLANN_DataTypes}(index::FLANNIndex{T}, x::Vector{T}, r2::Real, max_nn::Int = 10)
    distancetype = T == Cdouble ? Cdouble : Cfloat

    @assert length(x) == index.dim "Dataset and query point of different dimensionality"

    indices = Array{Cint}(max_nn)
    dists = Array{distancetype}(max_nn)
    flann_params = getparameters()

    res = _inrange(index, x, indices, dists, max_nn, r2, flann_params)

    @assert res >= 0 "Search failed!"

    return (indices.+1)[1:res], dists[1:res]
end

"This function deletes a previously constructed index and frees all the memory used by it."
function Base.close(index::FLANNIndex)
    flann_params = getparameters()

    res = _close(index, flann_params)

    @assert res == 0 "Deleting index unsuccessful"

    nothing
end

for (T, Tname) in ((Cfloat, "float"), (Cdouble, "double"), (Cint, "int"), (Cuchar, "byte"))
    @eval @inline function _flann(X::Matrix{$T}, r, c, speedup, flann_params)
        ccall(($("flann_build_index_" * Tname), libflann), Ptr{Void},
              (Ptr{$T}, Cint, Cint, Ptr{Cfloat}, Ptr{Void}), X, r, c, speedup, flann_params)
    end

    @eval @inline function _addpoints!(index::FLANNIndex{$T}, X, r, c, rebuild_threshold)
        ccall(($("flann_add_points_" * Tname), libflann), Cint,
              (Ptr{Void}, Ptr{$T}, Cint, Cint, Cfloat), index.index, X, r, c, rebuild_threshold)
    end

    @eval @inline function _removepoint!(index::FLANNIndex{$T}, id)
        ccall(($("flann_remove_point_" * Tname), libflann), Cint,
              (Ptr{Void}, Cuint), index.index, id)
    end

    @eval @inline function _getindex(index::FLANNIndex{$T}, id)
        ptr = ccall(($("flann_get_point_" * Tname), libflann), Ptr{$T},
                    (Ptr{Void}, Cuint), index.index, id)

        @assert ptr != C_NULL "Getting point unsuccessful"

        unsafe_wrap(Array, ptr, index.dim)
    end

    @eval @inline function _length(index::FLANNIndex{$T})
        ccall(($("flann_size_" * Tname), libflann), Cuint,
              (Ptr{Void},), index.index)
    end

    @eval @inline function _write(index::FLANNIndex{$T}, filename)
        ccall(($("flann_save_index_" * Tname), libflann), Cint,
              (Ptr{Void}, Cstring), index.index, filename)
    end

    @eval @inline function _read(filename, X::Matrix{$T}, r, c)
        ccall(($("flann_load_index_" * Tname), libflann), Ptr{Void},
              (Cstring, Ptr{$T}, Cint, Cint), filename, X, r, c)
    end

    @eval @inline function _knn{S}(X::Matrix{$T}, r, c, xs, trows, indices, dists::Array{S}, k, flann_params)
        ccall(($("flann_find_nearest_neighbors_" * Tname), libflann), Cint,
              (Ptr{$T}, Cint, Cint, Ptr{$T}, Cint, Ptr{Cint}, Ptr{S}, Cint, Ptr{Void}),
              X, r, c, xs, trows, indices, dists, k, flann_params)
    end

    @eval @inline function _knn{S}(index::FLANNIndex{$T}, xs, trows, indices, dists::Array{S}, k, flann_params)
        ccall(($("flann_find_nearest_neighbors_index_" * Tname), libflann), Cint,
              (Ptr{Void}, Ptr{$T}, Cint, Ptr{Cint}, Ptr{S}, Cint, Ptr{Void}),
              index.index, xs, trows, indices, dists, k, flann_params)
    end

    @eval @inline function _inrange{S}(index::FLANNIndex{$T}, x, indices, dists::Array{S}, max_nn, r2, flann_params)
        ccall(($("flann_radius_search_" * Tname), libflann), Cint,
              (Ptr{Void}, Ptr{$T}, Ptr{Cint}, Ptr{S}, Cint, Cfloat, Ptr{Void}),
              index.index, x, indices, dists, max_nn, r2, flann_params)
    end

    @eval @inline function _close(index::FLANNIndex{$T}, flann_params)
        ccall(($("flann_free_index_" * Tname), libflann), Cint,
              (Ptr{Void}, Ptr{Void}), index.index, flann_params)
    end
end