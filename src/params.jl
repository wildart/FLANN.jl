const FLANN_INDEX_LINEAR = 0
const FLANN_INDEX_KDTREE = 1
const FLANN_INDEX_KMEANS = 2
const FLANN_INDEX_COMPOSITE = 3
const FLANN_INDEX_KDTREE_SINGLE = 4
const FLANN_INDEX_HIERARCHICAL = 5
const FLANN_INDEX_LSH = 6
const FLANN_INDEX_SAVED = 254
const FLANN_INDEX_AUTOTUNED = 255

const FLANN_CENTERS_RANDOM = 0
const FLANN_CENTERS_GONZALES = 1
const FLANN_CENTERS_KMEANSPP = 2
const FLANN_CENTERS_GROUPWISE = 3

const FLANN_LOG_NONE  = 0
const FLANN_LOG_FATAL = 1
const FLANN_LOG_ERROR = 2
const FLANN_LOG_WARN  = 3
const FLANN_LOG_INFO  = 4
const FLANN_LOG_DEBUG = 5

const FLANN_DIST_EUCLIDEAN 			= 1
const FLANN_DIST_L2 				= 1
const FLANN_DIST_MANHATTAN 			= 2
const FLANN_DIST_L1 				= 2
const FLANN_DIST_MINKOWSKI 			= 3
const FLANN_DIST_MAX   				= 4
const FLANN_DIST_HIST_INTERSECT  	= 5
const FLANN_DIST_HELLINGER 			= 6
const FLANN_DIST_CHI_SQUARE		 	= 7
const FLANN_DIST_KULLBACK_LEIBLER  	= 8
const FLANN_DIST_HAMMING         	= 9
const FLANN_DIST_HAMMING_LUT		= 10
const FLANN_DIST_HAMMING_POPCNT   	= 11
const FLANN_DIST_L2_SIMPLE	   		= 12

struct FLANNParameters
    algorithm::Cint  		# the algorithm to use

    # search time parameters
    checks::Cint 			# how many leafs (features) to check in one search
    eps::Cfloat     		# eps parameter for eps-knn search
    sorted::Cint     		# indicates if results returned by radius search should be sorted or not
    max_neighbors::Cint     # limits the maximum number of neighbors should be returned by radius search
    cores::Cint    			# number of paralel cores to use for searching

    # kdtree index parameters
    trees::Cint				# number of randomized trees to use (for kdtree) kmeans index parameters
    leaf_max_size::Cint

    # kmeans index parameters
    branching::Cint 		# branching factor (for kmeans tree)
    iterations::Cint 		# max iterations to perform in one kmeans cluetering (kmeans tree)
    centers_init::Cint 		# algorithm used for picking the initial cluster centers for kmeans tree
    cb_index::Cfloat 		# cluster boundary index. Used when searching the kmeans tree

    # autotuned index parameters
    target_precision::Cfloat 	# precision desired (used for autotuning, -1 otherwise)
    build_weight::Cfloat 		# build tree time weighting factor
    memory_weight::Cfloat 		# index memory weigthing factor
    sample_fraction::Cfloat 	# what fraction of the dataset to use for autotuning

    # LSH parameters
    table_number::Cuint 		# number of hash tables to use
    key_size::Cuint 			# length of the key in the hash tables
    multi_probe_level::Cuint	# number of levels to use in multi-probe LSH, 0 for standard LSH

    # other parameters
    log_level::Cint			# determines the verbosity of each flann function
    random_seed::Clong		# random seed to use

end

FLANNParameters(;
    algorithm=FLANN_INDEX_KDTREE,
    checks=32,
    eps=0.0,
    sorted=0,
    max_neighbours=-1,
    cores=0,
    trees=4,
    leaf_max_size=4,
    branching=32,
    iterations=11,
    centers_init=FLANN_CENTERS_RANDOM,
    cb_index=0.2,
    target_precision=0.9,
    build_weight=0.01,
    memory_weight=0,
    sample_fraction=0.1,
    table_number=12,
    key_size=20,
    multi_probe_level=2,
    log_level=FLANN_LOG_NONE,
    random_seed=0)=
FLANNParameters(algorithm,checks, eps, sorted, max_neighbours,
    cores,trees, leaf_max_size,branching, iterations, centers_init, cb_index,
    target_precision, build_weight, memory_weight, sample_fraction,table_number,
    key_size, multi_probe_level,log_level, random_seed)
