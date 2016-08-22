module Sundials

using Compat

const depsfile = joinpath(dirname(dirname(@__FILE__)),"deps","deps.jl")
if isfile(depsfile)
    include(depsfile)
else
    error("Sundials not properly installed. Please run Pkg.build(\"Sundials\")")
end

##################################################################
# Deprecations
##################################################################

@deprecate nvlength length
@deprecate asarray convert
@deprecate nvector NVector

##################################################################
#
# Read in the wrapping code generated by the Clang.jl package.
#
##################################################################

recurs_sym_type(ex::Any) =
  (ex==Union{} || typeof(ex)==Symbol || length(ex.args)==1) ? eval(ex) : Expr(ex.head, ex.args[1], recurs_sym_type(ex.args[2]))
macro c(ret_type, func, arg_types, lib)
  local _arg_types = Expr(:tuple, [recurs_sym_type(a) for a in arg_types.args]...)
  local _ret_type = recurs_sym_type(ret_type)
  local _args_in = Any[ @compat Symbol(string('a',x)) for x in 1:length(_arg_types.args) ]
  local _lib = eval(lib)
  quote
    $(esc(func))($(_args_in...)) = ccall( ($(string(func)), $(Expr(:quote, _lib)) ), $_ret_type, $_arg_types, $(_args_in...) )
  end
end

macro ctypedef(fake_t,real_t)
  real_t = recurs_sym_type(real_t)
  quote
    typealias $fake_t $real_t
  end
end

# some definitions from the system C headers wrapped into the types_and_consts.jl
const DBL_MAX = prevfloat(Inf)
const DBL_MIN = nextfloat(-Inf)
const DBL_EPSILON = eps(Cdouble)

typealias FILE Void
typealias __builtin_va_list Ptr{Void}

if isdefined(:libsundials_cvodes)
    const libsundials_cvode = libsundials_cvodes
    const libsundials_ida = libsundials_idas
end

include("types_and_consts.jl")

include("handle.jl")
include("nvector_wrapper.jl")

include("nvector.jl")
include("libsundials.jl")
if isdefined(:libsundials_cvodes)
    include("cvodes.jl")
else
    include("cvode.jl")
end
shlib = libsundials_ida
if isdefined(:libsundials_cvodes)
    include("idas.jl")
else
    include("ida.jl")
end
shlib = libsundials_kinsol
include("kinsol.jl")

include("simple.jl")

end # module
