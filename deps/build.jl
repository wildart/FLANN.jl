using BinDeps

@BinDeps.setup

const flann_version = "1.9.1"
check_built_from_source(name, handle) = startswith(name, Pkg.dir("FLANN"))
libflann = library_dependency("libflann",
                              aliases = ["libflann1.9", "flann.dll", "flann"],
                              validate = check_built_from_source)

provides(Sources,
         URI("https://github.com/mariusmuja/flann/archive/$(flann_version).tar.gz"),
         libflann,
         unpacked_dir="flann-$(flann_version)",
         os = :Unix)
provides(Binaries,
         URI("https://github.com/wildart/FLANN.jl/releases/download/v0.0.5/libflann-windows-amd64-$(flann_version)-julia-0.5.1.tar.gz"),
         libflann,
         unpacked_dir=BinDeps.libdir(libflann) ,
         os = :Windows)

flannusrdir = BinDeps.usrdir(libflann)
flannsrcdir = joinpath(BinDeps.srcdir(libflann),"flann-$(flann_version)")
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

@BinDeps.install Dict( :libflann => :libflann )
