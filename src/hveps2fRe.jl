using Plots
include("Re2f.jl")
include("figure.jl")

@doc raw"""
`Re,f=hveps2fRe(h,v,L,eps,g,mu,rho[,fig])` computes
the Reynolds number Re and
the Darcy friction factor f, given
the head loss h,
the flow speed v,
the pipe's length L,
the pipe's relative roughness eps,
the gravitational accelaration g,
the fluid's dynamic viscosity mu and
the fluid's density rho.

If fig = true is given, a schematic Moody diagram
is plotted as a graphical representation
of the solution.

See also: `Re2f`, `f2Re`, `hDeps2fRe`, `hvthk2fRe`, `hQeps2fRe`, `hQthk2fRe`.

Examples
==========
Compute the Reynolds number Re and
the Darcy friction factor f, given
the head loss h = 40 cm,
the flow speed v = 1e2 cm/s,
the pipe's length L = 2.5e3 cm and
relative roughness eps = 2.5e-3,
the gravitational acceleration g = 981 cm/s/s, and
the fluid's dynamic viscosity mu = 8.9e-3 g/cm/s and
density rho = 0.989 g/cc.
This call computes Re and f:
```
    h=40;v=1e2;L=2.5e3;eps=2.5e-3;g=981;mu=8.9e-3;rho=0.989;
    Re,f=hveps2fRe(h,v,L,eps,g,mu,rho)
```
This call computes Re and f and plots a schematic Moody diagram:
```
    Re,f=hveps2fRe(40,1e2,2.5e3,2.5e-3,981,8.9e-3,0.989,true)
```
"""
function hveps2fRe(h, v, L, eps, g, mu, rho, fig=false)
    M = 2 * g * mu * h / v^3 / rho / L
    isturb = true
    Re = 1e4
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
                break
            end
        end
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
