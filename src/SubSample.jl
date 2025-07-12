using DSP

abstract type SubsampleShiftMethod end

struct LagrangeInterpolation <: SubsampleShiftMethod
    order::Int
end

function subsample_shift(x, D, m::LagrangeInterpolation)
    # Construct and apply filter
    N = m.order
    h = ones(Float64, N+1)
    for n in 0:N, k in 0:N
        if k != n
            new_factor = (D-k)/(n-k)
            h[n+1] = h[n+1]*new_factor
        end
    end

    output = conv(x, h)

    #TODO See if this needs to be trimmed to match the length of x
    
    return output
end