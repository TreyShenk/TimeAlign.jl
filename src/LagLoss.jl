include("Utils.jl")

abstract type MetricType end
struct MSE <: MetricType end
struct Correlation <: MetricType end


function lag_loss(
    ref::AbstractVector{<:Real},
    sig::AbstractVector{<:Real},
    lag::Int,
    ::MSE
)
    n = length(ref)
    
    if lag > 0
        ref_view = view(ref, (1+lag):n)
        sig_view = view(sig, 1:(n-lag))
    elseif lag < 0
        ref_view = view(ref, 1:(n+lag))
        sig_view = view(sig, (1-lag):n)
    else
        ref_view = view(ref, 1:n)
        sig_view = view(sig, 1:n)
    end

    return sum((ref_view - sig_view).^2)
end

function lag_loss(
    ref::AbstractVector{<:Real},
    sig::AbstractVector{<:Real},
    lag::Int,
    ::Correlation
)
    n = length(ref)
    
    if lag > 0
        ref_view = view(ref, (1+lag):n)
        sig_view = view(sig, 1:(n-lag))
    elseif lag < 0
        ref_view = view(ref, 1:(n+lag))
        sig_view = view(sig, (1-lag):n)
    else
        ref_view = view(ref, 1:n)
        sig_view = view(sig, 1:n)
    end

    return sum(ref_view.*conj.(sig_view))
end

best_lag_selector(::MSE) = argmin
best_lag_selector(::Correlation) = argmax

function find_optimal_lag(
    ref::AbstractVector{<:Real},
    sig::AbstractVector{<:Real};
    min_lag::Union{Int, Nothing} = nothing,
    max_lag::Union{Int, Nothing} = nothing,
    lag_metric::MetricType = MSE()
)
    if length(ref) != length(sig)
        error("ref and sig must have the same length")
    end
    
    n = length(ref)
    
    # Set default max_lag if not provided
    if max_lag === nothing
        max_lag = min(n ÷ 4, 100)  # Default: quarter of signal length, max 100
    end
    
    # Set default min_lag if not provided
    if min_lag === nothing
        min_lag = -max_lag  # Default: symmetric range
    end
    
    # Ensure valid range
    max_lag = min(max_lag, n - 1)
    min_lag = max(min_lag, -(n - 1))
    
    # Validate range
    if min_lag > max_lag
        error("min_lag ($min_lag) must be ≤ max_lag ($max_lag)")
    end

    
    
    # Search all lags in the range
    all_losses = zeros(max_lag - min_lag + 1)
    all_lags = min_lag:max_lag
    for (index, lag) in enumerate(all_lags)
            all_losses[index] = lag_loss(ref, sig, lag, lag_metric)
    end
    selector = best_lag_selector(lag_metric)

    min_ind = selector(all_losses)

    #TODO Take care of the edge cases
    peak_adjust = peak_interp_quad(all_losses[(min_ind-1):min_ind+1])

    best_lag = all_lags[min_ind] + peak_adjust
    return best_lag
end