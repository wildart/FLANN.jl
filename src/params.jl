type FLANNParameters
	flann_algorithm::Uint8  # the algorithm to use

	# search parameters
	checks::Int 			# how many leafs (features) to check in one search
	cb_index::Float64 		# cluster boundary index. Used when searching the kmeans tree

	# kdtree index parameters
	trees::Int 				# number of randomized trees to use (for kdtree) kmeans index parameters

	# kmeans index parameters
	branching::Int 			 # branching factor (for kmeans tree)
	iterations::Int 		 # max iterations to perform in one kmeans cluetering (kmeans tree)
	flann_centers_init::UInt # algorithm used for picking the initial cluster centers for kmeans tree

	# autotuned index parameters
	target_precision::Float64 	# precision desired (used for autotuning, -1 otherwise)
	build_weight::Float64 		# build tree time weighting factor
	memory_weight::Float64 		# index memory weigthing factor
	sample_fraction::Float64 	# what fraction of the dataset to use for autotuning

	# LSH parameters
	table_number::Uint 		# number of hash tables to use
	key_size::Uint 			# length of the key in the hash tables
	multi_probe_level::Uint	# number of levels to use in multi-probe LSH, 0 for standard LSH

	# other parameters
	log_level::Uint			# determines the verbosity of each flann function
	random_seed::Int 		# random seed to use
end

const flann_algorithms = Dict{Symbol, Uint8}({
	:FLANN_INDEX_LINEAR => 0x0,
	:FLANN_INDEX_KDTREE => 0x1,
	:FLANN_INDEX_KMEANS => 0x2,
	:FLANN_INDEX_COMPOSITE => 0x3,
	:FLANN_INDEX_KDTREE_SINGLE => 0x3,
	:FLANN_INDEX_SAVED => 0xFE,
	:FLANN_INDEX_AUTOTUNED => 0xFF
}

const flann_centers_init = Dict{Symbol, Uint8}({
	:FLANN_CENTERS_RANDOM => 0,
	:FLANN_CENTERS_GONZALES => 1,
	:FLANN_CENTERS_KMEANSPP => 2
})

const FLANN_LOG_NONE  = 0x0
const FLANN_LOG_FATAL = 0x1
const FLANN_LOG_ERROR = 0x2
const FLANN_LOG_WARN  = 0x3
const FLANN_LOG_INFO  = 0x4