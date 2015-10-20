module FLANN

using Distances
using BinDeps
#for compatibility to older versions
using Compat

depsfile = normpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depsfile)
    include(depsfile)
else
    error("FLANN not properly installed. Please run Pkg.build(\"FLANN\")")
end

export FLANNParameters, flann, nearest, inball, close

include("params.jl")
include("wrapper.jl")

# Interface compatible with Distances package
function flann(X::Matrix, p::FLANNParameters, metric::PreMetric)
    m, o = FLANNMetric(metric)
    return flann(X, p, m, o)
end

function FLANNMetric(metric::PreMetric)
    d = FLANN_DIST_EUCLIDEAN
    o = 2
    if isa(metric, Euclidean)
        d = FLANN_DIST_EUCLIDEAN
    elseif isa(metric, Cityblock)
        d = FLANN_DIST_MANHATTAN
    elseif isa(metric, Minkowski)
        d = FLANN_DIST_MINKOWSKI
        @compat o = round(Int,metric.p)
    elseif isa(metric, ChiSqDist)
        d = FLANN_DIST_CHI_SQUARE
    elseif isa(metric, KLDivergence)
        d = FLANN_DIST_KULLBACK_LEIBLER
        # elseif isa(metric, HistIntersection)
        # 	d = FLANN_DIST_HIST_INTERSECT
    else
        error("Distances metric $(metric) is not supported. Euclidean distance is used.")
    end
    return d, o
end

end # module
