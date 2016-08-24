using Sundials

## f routine. Compute function f(t,y).

function f(t, y, ydot)
    ydot[1] = -0.04*y[1] + 1.0e4*y[2]*y[3]
    ydot[3] = 3.0e7*y[2]*y[2]
    ydot[2] = -ydot[1] - ydot[3]
    return Sundials.CV_SUCCESS
end


t = [0.0; 4 * logspace(-1., 7., 9)]
y0= [1.0, 0.0, 0.0]

# Get only specific values from the simplified interface
yout = Sundials.cvode(f,y0, t)

# Or get the full solver output via fullouput. It will match cvode at specified timepoints
res = Sundials.cvode(f, y0, [0.0,1.0])
res2 = Sundials.cvode(f, y0, [0.0,0.1,0.16],integrator=:Adams) # Not a stable method, will fail if too long.
ts1, res3 = Sundials.cvode_fulloutput(f, y0, [0.0,1.0])
ts2, res4 = Sundials.cvode_fulloutput(f, y0, [0.0,0.1,0.16],integrator=:Adams)
