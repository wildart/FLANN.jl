using MNIST
using StatsBase
using NearestNeighbors

function full_test(X_test, y_test, model, k::Int = 3)
	errors = 0
	n = length(y_test)

	for i in 1:n
		is, ds = nearest(model, X_test[:, i], k)
		if mode(y_train[is]) != y_test[i]
			errors += 1
		end
	end
	println("Errors: ", errors/n)
end

X_train, y_train = traindata()
X_test, y_test = testdata()

# make it byte
X_train = uint8(X_train)
X_test  = uint8(X_test)
y_train = uint8(y_train)
y_test  = uint8(y_test)
v = X_train[:, 1]

@elapsed t1 = NaiveNeighborTree(X_train)
@elapsed t2 = KDTree(X_train)

@elapsed nearest(t1, v, 30)
@elapsed nearest(t2, v, 30)

@time full_test(X_train, y_train, t1, 5) # VERY SLOW!!
@time full_test(X_train, y_train, t2, 5) # VERY SLOW!!

using FLANN
params = FLANNParameters()
params.cores = 2
@elapsed t3 = flann(X_train, params) # SLOW!!
@elapsed nearest(t3, v, 30)
@time full_test(X_train, y_train, t3, 15)
close(t3)