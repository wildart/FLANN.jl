using BinDeps

@BinDeps.setup

deps = [
	libflann = library_dependency("libflann", aliases = ["libflann","libflann1.8"], os = :Unix)
	flann_wrapper = library_dependency("flann_wrapper",
		aliases = ["flann_wrapper.so"],
		depends = [libflann],
		os = :Unix)
]

if !BinDeps.issatisfied(libflann)
	provides(AptGet, {"libflann-dev" => libflann})
end

provides(SimpleBuild,
	(@build_steps begin
		ChangeDirectory(BinDeps.depsdir(flann_wrapper))
		MakeTargets()
	end), flann_wrapper, os = :Unix)

@BinDeps.install
