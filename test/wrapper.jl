module TestFLANN
	using FLANN

	X = float32(readdlm(Pkg.dir("FLANN", "test", "iris.csv"), ','))
	v = X[:, [84,85]]

	params = FLANNParameters()
	model = flann(X, params)
	idxs, dsts = nearest(model, v, 3)
	println(idxs, dsts)
	close(model)

	idxs, dsts = nearest(X, v, 3, params)
	println(idxs, dsts)
end

#flann_params = setparameters(params)
#ccall((:get_params, "deps/flann_wrapper.so"), Void, (Ptr{Void},), flann_params)