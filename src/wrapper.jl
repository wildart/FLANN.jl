import Base.close

immutable FLANNIndex
	index
	parameters
end

function flann_build_index(dataset, build_params)
	return index, parameters, speedup
end

function flann_free_index(index::FLANNIndex)
end