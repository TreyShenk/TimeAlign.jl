using DSP

abstract type SubsampleShiftMethod end

struct LagrangeInterpolation <: SubsampleShiftMethod
    N::Int
end

struct ThiranAllPass <: SubsampleShiftMethod
    N::Int
end

function subsample_shift(x, D, m::SubsampleShiftMethod)
    h = calc_filter(D, m)
    output = conv(x, h)
end

function calc_filter(D, m::LagrangeInterpolation)
    # Construct and apply filter
    N = m.N
    h = ones(Float64, N+1)
    for n in 0:N, k in 0:N
        if k != n
            new_factor = (D-k)/(n-k)
            h[n+1] = h[n+1]*new_factor
        end
    end
    return h
end

function calc_filter(D, m::ThiranAllPass)
    N = m.N
    a = ones(Float64, N+1)
    for k in 0:N
        a[k+1] = -1*binomial(N, k)
    end

    for k in 0:N, n = 0:N
        new_factor = (D - N + n)/(D - N + k + n)
        a[k+1] = a[k+1]*new_factor
    end

    return a
end