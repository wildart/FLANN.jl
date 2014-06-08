module FLANN

	using BinDeps
	@BinDeps.load_dependencies

	using NearestNeighbors

	export FLANNParameters, flann, nearest, close

	include("params.jl")
	include("wrapper.jl")
end # module
