

function lag_loss(
    ref::AbstractVector{<:Real},
    sig::AbstractVector{<:Real},
    lag::Int,
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

    sum((ref_view - sig_view).^2)
end

function find_optimal_lag(
    ref::AbstractVector{<:Real},
    sig::AbstractVector{<:Real};
    min_lag::Union{Int, Nothing} = nothing,
    max_lag::Union{Int, Nothing} = nothing
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

    for (index, lag) in enumerate(min_lag:max_lag)
            all_losses[index] = lag_loss(ref, sig, lag)
    end

    min_ind = argmin(all_losses)

    #TODO Peak interpolation can be performed here

    best_lag = Int(min_ind + min_lag - 1)
    return best_lag
end