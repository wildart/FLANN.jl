using BinDeps
using Libdl

@BinDeps.setup

const flann_version = "1d04523"
libflann = library_dependency("libflann", aliases = ["libflann1.9", "flann.dll", "flann"])

provides(Sources,
#         URI("https://github.com/mariusmuja/flann/archive/$(flann_version).tar.gz"),
         URI("https://github.com/wildart/FLANN.jl/releases/download/v1.1.0/flann-$(flann_version).tar.gz"),
         libflann,
         unpacked_dir="flann-$(flann_version)",
         os = :Unix)
provides(Binaries,
         URI("https://github.com/wildart/FLANN.jl/releases/download/v0.1.0/libflann-$(flann_version)-julia-$VERSION-x86_64.tar.gz"),
         libflann,
         unpacked_dir=".",
         os = :Windows)

flannusrdir = BinDeps.usrdir(libflann)
flannlib = joinpath(flannusrdir,"lib","libflann."*Libdl.dlext)
flannsrcdir = joinpath(BinDeps.srcdir(libflann),"flann-$(flann_version)")
flannbuilddir = joinpath(BinDeps.builddir(libflann),flann_version)
provides(BuildProcess,
(@build_steps begin
    GetSources(libflann)
    CreateDirectory(flannbuilddir)
    @build_steps begin
        ChangeDirectory(flannbuilddir)
        FileRule(flannlib, @build_steps begin
            `cmake -Wno-dev -DCMAKE_BUILD_TYPE="Release" \\
            -DCMAKE_INSTALL_PREFIX="$flannusrdir" $flannsrcdir`
            `make`
            `make install`
        end)
    end
end), libflann, os = :Unix)

@BinDeps.install Dict( :libflann => :libflann )
