#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "flann/flann.h"

struct FLANNParameters p;

struct FLANNParameters* create_params(
    enum flann_algorithm_t algorithm, /* the algorithm to use */

    /* search time parameters */
    int checks,                /* how many leafs (features) to check in one search */
    float eps,     /* eps parameter for eps-knn search */
    int sorted,     /* indicates if results returned by radius search should be sorted or not */
    int max_neighbors,  /* limits the maximum number of neighbors should be returned by radius search */
    int cores,      /* number of paralel cores to use for searching */

    /*  kdtree index parameters */
    int trees,                 /* number of randomized trees to use (for kdtree) */
    int leaf_max_size,

    /* kmeans index parameters */
    int branching,             /* branching factor (for kmeans tree) */
    int iterations,            /* max iterations to perform in one kmeans cluetering (kmeans tree) */
    enum flann_centers_init_t centers_init,  /* algorithm used for picking the initial cluster centers for kmeans tree */
    float cb_index,            /* cluster boundary index. Used when searching the kmeans tree */

    /* autotuned index parameters */
    float target_precision,    /* precision desired (used for autotuning, -1 otherwise) */
    float build_weight,        /* build tree time weighting factor */
    float memory_weight,       /* index memory weigthing factor */
    float sample_fraction,     /* what fraction of the dataset to use for autotuning */

    /* LSH parameters */
    unsigned int table_number_, /** The number of hash tables to use */
    unsigned int key_size_,     /** The length of the key in the hash tables */
    unsigned int multi_probe_level_, /** Number of levels to use in multi-probe LSH, 0 for standard LSH */

    /* other parameters */
    enum flann_log_level_t log_level,    /* determines the verbosity of each flann function */
    long random_seed,            /* random seed to use */

    enum flann_distance_t distance_type, /* Distance type*/
    int order
	)
{
	p = DEFAULT_FLANN_PARAMETERS;

	p.algorithm = algorithm;

	p.checks = checks;
	p.eps = eps;
	p.sorted = sorted;
	p.max_neighbors = max_neighbors;
	p.cores = cores;

	p.trees = trees;
	p.leaf_max_size = leaf_max_size;

	p.branching = branching;
	p.iterations = iterations;
	p.centers_init = centers_init;
	p.cb_index = cb_index;

	p.target_precision = target_precision;
	p.build_weight = build_weight;
	p.memory_weight = memory_weight;
	p.sample_fraction = sample_fraction;

	p.table_number_ = table_number_;
	p.key_size_ = key_size_;
	p.multi_probe_level_ = multi_probe_level_;

	p.log_level = log_level;
	p.random_seed = random_seed;

	flann_set_distance_type(distance_type, order);

	return &p;
}

void get_params(struct FLANNParameters* p)
{
	printf("algorithm: %d\n", (int)(p->algorithm));
    printf("distance: %d\n", (int)flann_get_distance_type());
}
