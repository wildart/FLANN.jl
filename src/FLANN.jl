module FLANN

	using BinDeps
	@BinDeps.load_dependencies

	using Distance
	using NearestNeighbors

	export FLANNParameters, flann, nearest, close

	include("params.jl")
	include("wrapper.jl")

	# Interface compatible with Distance package
	function flann(X::Matrix, p::FLANNParameters, metric::SemiMetric)
		m, o = FLANNMetric(metric)
		return flann(X, p, m, o)
	end

	function FLANNMetric(metric::SemiMetric)
		d = FLANN_DIST_EUCLIDEAN
		o = 2
		if isa(metric, Euclidean)
			d = FLANN_DIST_EUCLIDEAN
		elseif isa(metric, Cityblock)
			d = FLANN_DIST_MANHATTAN
		elseif isa(metric, Minkowski)
			d = FLANN_DIST_MINKOWSKI
			o = int32(metric.p)
		elseif isa(metric, ChiSqDist)
			d = FLANN_DIST_CHI_SQUARE
		elseif isa(metric, KLDivergence)
			d = FLANN_DIST_KULLBACK_LEIBLER
		elseif isa(metric, HistIntersection)
			d = FLANN_DIST_HIST_INTERSECT
		else
			warn("Distance metric $(metric) is not supported. Euclidean distance is used.")
		end
		return d, o
	end
end # module
