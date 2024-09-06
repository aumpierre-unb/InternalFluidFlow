@doc raw"""
```
hDeps2fRe(h,D,L,ε,ρ,μ,g,fig)
```

`hDeps2fRe` computes the Reynolds number Re and
the Darcy friction factor f given
the head loss h,
the pipe's hydraulic diameter D,
the pipe's length L,
the pipe's relative roughness ε,
the fluid's density ρ,
the fluid's dynamic viscosity μ, and
the gravitational accelaration g.

By default, pipe is assumed to be 1 m long,
L = 100 (in cm).

By default, pipe is assumed to be smooth,
ε = 0. Relative roughness ε is reset to ε = 0.05,
if ε > 0.05.

By default, fluid is assumed to be water at 25 °C,
ρ = 0.997 (in g/cc) and
μ = 0.0091 (in P),
and gravitational acceleration is assumed to be
g = 981 (in cm/s/s).
Please, notice that these default values are given in the cgs unit system and,
if taken, all other parameters must as well be given in cgs units.

If parameter fig = true is given, a schematic Moody diagram
is plotted as a graphical representation
of the solution.

`hDeps2fRe` is an internal function of
the `InternalFluidFlow` toolbox for Julia.
"""
function hDeps2fRe(
    h::Number,
    D::Number,
    L::Number,
    ε::Number,
    ρ::Number,
    μ::Number,
    g::Number,
    fig::Bool
)
    if ε > 5e-2
        ε = 5e-2
    end
    K = 2 * g * h * ρ^2 * D^3 / μ^2 / L
    f = (-2 * log10(ε / 3.7 + 2.51 / K^(1 / 2)))^-2
    Re = (K / f)^(1 / 2)
    if Re > 2.3e3
        islam = false
    else
        Re = K / 64
        f = 64 / Re
        islam = true
    end
    if fig
        doPlot(ε)
        if !(Re < 2.3e3) && ε != 0
            turb(ε)
        end
        plot!([Re], [f],
            seriestype=:scatter,
            markerstrokecolor=:red,
            color=:red)
        display(plot!(
            (K ./ [6e-3; 1e-1]) .^ (1 / 2),
            [6e-3; 1e-1],
            seriestype=:line,
            color=:red,
            linestyle=:dash))
    end
    Re, f
end
