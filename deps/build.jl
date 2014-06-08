using BinDeps

@BinDeps.setup

deps = [
	libflann = library_dependency("libflann", aliases = ["libflann1.8"], os = :Unix)
]

if !BinDeps.issatisfied(libflann)
	provides(AptGet, {"libflann1.8" => libflann})
end

@BinDeps.install
