using Sundials
using Base.Test

# run cvode example
println("== start cvode Roberts example (simplified)")
include("../examples/cvode_Roberts_simplified.jl")

println("result at t=$(t[end]):")
println(yout[end,:], "\n")

@test size(yout) == (length(t),length(y0))
@test length(ts1) < length(ts2)  #BDF should take less steps, even with less time
@test minimum(abs(res3[end] - res[end,:]) .< 1e-16) # Difference at end should be 0
@test minimum(abs(res4[end] - res2[end,:]) .< 1e-16) # Difference at end should be 0
@test 0.1 ∈ ts2 #Intermediate specified values should be in the time
loc = find((x)->x==0.1,ts2)
@test minimum(abs(res4[loc...] - res2[2,:]) .< 1e-16) # Difference at t=0.1 should be 0

println("== start cvode Roberts example")
include("../examples/cvode_Roberts_dns.jl")

# run ida examples
println("== start ida_Roberts example (simplified)")
include("../examples/ida_Roberts_simplified.jl")

println("== start ida_Roberts example")
include("../examples/ida_Roberts_dns.jl")

println("result at t=$(t[end]):")
println(yout[end,:], "\n")

println("== start ida_Heat2D example")
include("../examples/ida_Heat2D.jl")

println("result at t=$(t[end]):")
println(yout[end,:], "\n")

# run kinsol example
println("== start kinsol example (simplified)")
include("../examples/kinsol_mkin_simplified.jl")

println("solution:")
println(res)
residual = ones(2)
sysfn(res, residual)
println("residual:")
println(residual, "\n")

println("== start kinsol example")
include("../examples/kinsol_mkinTest.jl")

@test abs(minimum(residual)) < 1e-5
