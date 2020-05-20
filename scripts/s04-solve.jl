using Quaycle
using HDF5
using LinearAlgebra

if BLAS.vendor() == :openblas64
    @info ccall((:openblas_get_num_threads64_, Base.libblas_name), Cint, ())
end

function solve_from_para_01(pf, output; offsetinit=true, stride=50, yearto=300.0)
    @info "Loading $(pf) ..."
    pff = joinpath(@__DIR__, pf)
    pe = @getprop pff

    gffile = joinpath(@__DIR__, "gf.h5")
    @info "Loading Green's function " * basename(gffile) * " ..."
    gf = h5read(gffile, "ee")

    @info "Initializing ..."
    if offsetinit == true
        @info "Manual offset ..."
        vinit = pe.vpl .* ones(size(pe.a))
        θinit = pe.L ./ vinit
        halflen = size(pe.a, 1) ÷ 2
        θinit[1:halflen,:] ./= 1.1
        θinit[halflen+1:end,:] ./= 2.5 # for smaller VW
    end
    δinit = zeros(size(pe.a))
    uinit = ArrayPartition(vinit, θinit, δinit)
    prob = assemble(gf, pe, uinit, (0.0, yearto * 365 * 86400))
    @info "Solving $(output) ..."
    output_ = joinpath(@__DIR__, output)
    @time sol = wsolve(prob, VCABM5(), output_, 1000, 𝐕𝚯𝚫, ["v", "θ", "δ"], "t";
        reltol=1e-6, abstol=1e-8, dtmax=0.2*365*86400, dt=1e-6, maxiters=1e9, stride=stride, force=true)
end

include(@__DIR__, "scanfunc.jl"))

model2output_orgin = Dict(
    "otf-00.h5"     => ( "pf-00.h5",  ),
    "otf-s200.h5"   => ( "pf-s200.h5",),
    "otf-s150.h5"   => ( "pf-s150.h5",),
    "otf-s100.h5"   => ( "pf-s100.h5",),
    "otf-s80.h5"    => ( "pf-s80.h5", ),
    "otf-s60.h5"    => ( "pf-s60.h5", ),
    "otf-s25.h5"    => ( "pf-s25.h5", ),
    "otf-s10.h5"    => ( "pf-s10.h5", ),
    "otf-s5.h5"     => ( "pf-s5.h5",  ),
    "otf-s1.h5"     => ( "pf-s1.h5",  ),
    "otf-w2.h5"     => ( "pf-w2.h5",  ),
    "otf-w3.h5"     => ( "pf-w3.h5",  ),
    "otf-w5.h5"     => ( "pf-w5.h5",  ),
    "otf-w15.h5"    => ( "pf-w15.h5", ),
    "otf-w20.h5"    => ( "pf-w20.h5", ),
    "otf-w30.h5"    => ( "pf-w30.h5", ),
    "otf-w40.h5"    => ( "pf-w40.h5", ),
    "otf-b4.0.h5"   => ( "pf-b4.0.h5",),
    "otf-b3.0.h5"   => ( "pf-b3.0.h5",),
    "otf-b2.0.h5"   => ( "pf-b2.0.h5",),
    "otf-b1.35.h5"  => ( "pf-b1.35.h5"),
    "otf-b0.5.h5"   => ( "pf-b0.5.h5",),
    "otf-b0.2.h5"   => ( "pf-b0.2.h5",),
    "otf-a4.0.h5"   => ( "pf-a4.0.h5",),
    "otf-a3.0.h5"   => ( "pf-a3.0.h5",),
    "otf-a2.0.h5"   => ( "pf-a2.0.h5",),
    "otf-a1.35.h5"  => ( "pf-a1.35.h5"),
    "otf-a0.5.h5"   => ( "pf-a0.5.h5",),
    "otf-a0.2.h5"   => ( "pf-a0.2.h5",),
    "otf-l1.0.h5"   => ( "pf-l1.0.h5",),
    "otf-l2.0.h5"   => ( "pf-l2.0.h5",),
    "otf-l5.0.h5"   => ( "pf-l5.0.h5",),
    "otf-l7.0.h5"   => ( "pf-l7.0.h5",),
    "otf-l8.0.h5"   => ( "pf-l8.0.h5",),
    "otf-l12.0.h5"  => ( "pf-l12.0.h5"),
    "otf-l16.0.h5"  => ( "pf-l16.0.h5"),
    "otf-l20.0.h5"  => ( "pf-l20.0.h5"),
    "otf-l40.0.h5"  => ( "pf-l40.0.h5"),
    "otf-l60.0.h5"  => ( "pf-l60.0.h5"),
    "otf-l80.0.h5"  => ( "pf-l80.0.h5"),
)

mkey = keys(model2output_orgin) |> collect |> sort
k = mkey[parse(Int64, ARGS[1])] # output name
v = model2output_orgin[k] # prop name
solve_from_para_01(v[1], k, yearto=600.0, stride=100, offsetinit=true)
scan_output_01(k)
slip_ratio(k, -6e3)
