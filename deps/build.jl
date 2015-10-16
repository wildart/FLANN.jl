using BinDeps
#for compatibility to older versions
using Compat

@BinDeps.setup

const flann_version = "flann-1.8.4"
libflann = library_dependency("libflann", aliases = ["libflann1.8", "flann.dll", "flann"])

@compat provides(AptGet, Dict("libflann1.8" => libflann))
@compat provides(Yum, Dict("$flann_version-2" => libflann))

@osx_only begin
    if Pkg.installed("Homebrew") === nothing
        error("Homebrew package not installed, please run Pkg.add(\"Homebrew\")")
	end
    using Homebrew
    provides( Homebrew.HB, "flann", libflann, os = :Darwin )
end

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

@compat @BinDeps.install Dict( :libflann => :libflann )
