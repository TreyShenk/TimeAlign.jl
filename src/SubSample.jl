using DSP

abstract type SubsampleShiftMethod end

struct LagrangeInterpolation <: SubsampleShiftMethod
    order::Int
end

struct ThiranAllPass <: SubsampleShiftMethod
    order::Int
end

function subsample_shift(x, D, m::SubsampleShiftMethod)
    b, a = calc_filter(D, m)
    output = filt(b, a, x)
    
    #TODO: Trim the output
    return output
end

function calc_filter(D, m::LagrangeInterpolation)
    # Construct and apply filter
    N = m.order
    h = ones(Float64, N+1)
    for n in 0:N, k in 0:N
        if k != n
            new_factor = (D-k)/(n-k)
            h[n+1] = h[n+1]*new_factor
        end
    end
    return (h, 1)
end


function calc_filter(D, m::ThiranAllPass)
    N = m.order
    a = ones(Float64, N+1)
    for k in 0:N
        a[k+1] = ((-1)^k)*binomial(N, k)
    end

    for k in 1:N, n = 0:N
        new_factor = (D - N + n)/(D - N + k + n)
        a[k+1] = a[k+1]*new_factor
    end

    return (1, a)
end