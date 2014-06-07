module FLANN
	using NearestNeighbors

	export flann, close

	include("params.jl")
	include("wrapper.jl")
end # module
