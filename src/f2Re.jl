using Plots
include("bissecao.jl")
include("laminar.jl")
include("turb.jl")
include("smooth.jl")
include("rough.jl")

function f2Re(f, eps=0, fig=false)
    # [Re]=f2Re(f,[eps[,s]]) computes
    # the Reynolds number Re, given
    # the Darcy friction factor f and
    # the relative roughness eps for
    # for laminar regime and,
    # when possible, also
    # for turbulent regime.
    # By default eps=2e-3.
    # If eps>5e-2, execution is aborted.
    # If s=true is given,a schematic Moody diagram
    #  is plotted as a graphical representation
    #  of the computation.
    #
    # # e.g. Compute Reynolds number Re for
    # # Darcy friction factor f=0.028 and
    # # relative roughness eps=0.001.
    # # In this case, both laminar and turbulent
    # # solutions are possible:
    # f=0.028;eps=0.001;
    # Re=f2Re(f,eps)
    # # Alternatively:
    # Re=f2Re(0.028,0.001)
    # # This call computes Re given
    # # f=0.028 and eps=0.001 and
    # # displays a schematic Moody Diagram:
    # Re=f2Re(0.028,0.001,true)
    #
    # # e.g. Compute the Reynolds number Re given
    # # the Darcy friction factor f=0.023 and
    # # the default smooth condition, eps=0.
    # # In this case, only the turbulent
    # # solution is possible:
    # Re=f2Re(0.028,0.001,true)
    #
    # See also: Re2f, hDeps2fRe, hveps2fRe, hvthk2fRe, hQeps2fRe, hQthk2fRe
    if eps > 5e-2
        eps = 5e-2
    end
    Re = []
    fD = []
    if 64 / f < 2.3e3
        Re = [Re; 64 / f]
        fD = [fD; f]
    end
    if f > (2 * log10(3.7 / eps))^-2
        function foo(Re)
            return 1 / sqrt(f) + 2 * log10(eps / 3.7 + 2.51 / Re / sqrt(f))
        end
        r = bissecao(foo, 1e3, 1e8, 1e-4)
        if r > 2.3e3
            Re = [Re; r]
            fD = [fD; f]
        end
    end
    if !isempty(fD) & fig
        plot(xlabel="Re",
            ylabel="f",
            xlims=(1e2, 1e8),
            ylims=(6e-3, 1e-1),
            legend=false,
            framestyle=:box,
            scale=:log10,
            grid=:true,
            minorgrid=:true)
        laminar()
        turb(eps)
        if eps < 1e-4
            turb(5e-4)
        elseif eps * 3 < 5e-2
            turb(eps * 3)
        else
            turb(eps / 2)
        end
        if eps < 1e-4
            turb(1e-3)
        elseif eps * 10 < 5e-2
            turb(eps * 10)
        else
            turb(eps / 2)
        end
        if eps < 1e-4
            turb(5e-3)
        else
            turb(eps / 3)
        end
        if eps < 1e-4
            turb(1e-2)
        else
            turb(eps / 10)
        end
        rough()
        if eps != 0
            smooth()
        end
        display(plot!([Re], [f],
            seriestype=:scatter,
            markerstrokecolor=:red,
            color=:red))
        display(plot!([1e2; 1e8], [f; f],
            seriestype=:line,
            color=:red,
            linestyle=:dash))
    end
    return Re
end
