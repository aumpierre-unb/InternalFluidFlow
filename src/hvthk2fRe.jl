using Plots
include("Re2f.jl")
include("figure.jl")

@doc raw"""
`Re,f=hvthk2fRe(h,v,L,thk[,rho=0.997[,mu=9.1e-3[,g=981[,fig=true]]]])`

``hvthk2fRe`` compute the Reynolds number ``Re`` and
the Darcy friction factor ``f``, given
the head loss ``h``,
the flow speed ``v``,
the pipe's length ``L``,
the pipe's roughness ``thk``,
the fluid's density ``rho``,
the fluid's dynamic viscosity ``mu``, and
the gravitational accelaration ``g``.

If ``fig=true`` is given, a schematic Moody diagram
is plotted as a graphical representation
of the solution.

See also: `Re2f`, `f2Re`, `hDeps2fRe`, `hveps2fRe`, `hQeps2fRe`, `hQthk2fRe`.

Examples
==========
Compute the Reynolds number Re and
the Darcy friction factor f, given
the head loss h = 40 cm,
the flow speed v = 1e2 cm/s,
the pipe's length L = 2.5e3 cm and
roughness thk = 2.5e-2 cm,
for water flow.

Compute Re and f:
```
    h=40;v=1e2;L=2.5e3;thk=2.5e-2;
    Re,f=hvthk2fRe(h,v,L,thk)
```

Compute the Reynolds number Re and
the Darcy friction factor f, given
in addition
the fluid's density rho = 0.989 g/cc and
dynamic viscosity mu = 8.9e-3 g/cm/s.

Compute Re and f:
```
    h=40;v=1e2;L=2.5e3;thk=2.5e-2;rho=0.989;mu=8.9e-3;
    Re,f=hvthk2fRe(h,v,L,thk,rho,mu)
```
Compute Re and f and plot a schematic Moody diagram:
```
    Re,f=hvthk2fRe(40,1e2,2.5e3,2.5e-2,0.997,9.1e-3,981,true)
```
"""
function hvthk2fRe(h::Float64, v::Float64, L::Float64, thk::Float64, rho::Float64=0.997, mu::Float64=0.91, g::Float64==981, fig::Bool=false)
    M = 2 * g * mu * h / v^3 / rho / L
    isturb = true
    Re = 1e4
    f = M * Re
    D = Re * mu / v / rho
    eps = thk / D
    f = 64 / Re
    while abs(f - Re * M) / f > 5e-3
        if f - Re * M > 0
            Re = Re * 1.02
        else
            Re = Re * 0.98
            if Re < 2.3e3
                isturb = false
                Re = sqrt(64 / M)
                f = 64 / Re
                D = Re * mu / v / rho
                eps = thk / D
                break
            end
        end
        f = M * Re
        D = Re * mu / v / rho
        eps = thk / D
        f = Re2f(Re, eps)
    end
    if isturb && sqrt(64 / M) < 2.3e3
        Re = [sqrt(64 / M); Re]
        f = [64 / sqrt(64 / M); f]
    end
    if fig
        figure(eps)
        display(plot!([Re], [f],
            seriestype=:scatter,
            markerstrokecolor=:red,
            color=:red))
        display(plot!([Re / 10; Re * 10], [M * Re / 10; M * Re * 10],
            seriestype=:line,
            color=:red,
            linestyle=:dash))
    end
    return [Re; f]
end
