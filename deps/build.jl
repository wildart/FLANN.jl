using BinDeps

@BinDeps.setup

const flann_version = "flann-1.8.4"
libflann = library_dependency("libflann", aliases = ["libflann1.8", "flann.dll", "flann"])

provides(AptGet, {"libflann1.8" => libflann})
provides(Yum, {"$flann_version-2" => libflann})
provides(Sources, URI("http://www.cs.ubc.ca/research/flann/uploads/FLANN/$flann_version-src.zip"),	libflann)

flannusrdir = BinDeps.usrdir(libflann)
flannsrcdir = joinpath(BinDeps.srcdir(libflann),"$flann_version-src")
flannbuilddir = joinpath(BinDeps.builddir(libflann),flann_version)
provides(BuildProcess,
	(@build_steps begin
		GetSources(libflann)
		CreateDirectory(flannbuilddir)
		@build_steps begin
			ChangeDirectory(flannbuilddir)
			FileRule(joinpath(flannusrdir,"lib","libflann."*BinDeps.shlib_ext), @build_steps begin
				`cmake -DCMAKE_BUILD_TYPE="Release" \\
					   -DCMAKE_INSTALL_PREFIX="$flannusrdir" \\
					   -DBUILD_PYTHON_BINDINGS=OFF \\
					   -DBUILD_MATLAB_BINDINGS=OFF $flannsrcdir
					   -Wno-dev`
				`make`
				`make install`
			end)
		end
	end), libflann, os = :Unix)

@BinDeps.install [ :libflann => :libflann ]
