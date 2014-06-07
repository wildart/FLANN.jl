module FLANN
	using NearestNeighbors

	export FLANNParameters, flann, nearest, close

	include("params.jl")
	include("wrapper.jl")
end # module
