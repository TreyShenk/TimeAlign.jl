include("LagLoss.jl")
using ProgressMeter
using Statistics

"""
align_signals_naive(signals, max_lag)

Aligns all signals using the first column as the reference signal. This
naive approach simply uses the one measurement for each estimate.



"""
function align_signals_naive(signals, max_lag)

    num_sigs = size(signals)[2]
    shifts = zeros(Int, num_sigs)
    
    aligned_signals = copy(signals)
    aligned_signals[1, :] = signals[1, :]

    @showprogress desc="Computing shifts" for ii in 2:num_sigs
        shifts[ii] = find_optimal_lag(signals[:, 1], signals[:, ii], max_lag = max_lag)
        aligned_signals[:, ii] = apply_lag_shift(signals[:, ii], shifts[ii])
    end

    return aligned_signals, shifts
end

function apply_lag_shift(signal::AbstractVector{<:Real}, lag::Int)
    n = length(signal)
    shifted = zeros(n)
    
    if lag == 0
        return copy(signal)
    end
    
    if lag > 0
        # Positive lag: delay the signal (shift right)
        shifted[(lag+1):end] = signal[1:(n-lag)]
    else
        # Negative lag: advance the signal (shift left)
        # Copy shifted signal
        abs_lag = abs(lag)
        shifted[1:(n-abs_lag)] = signal[(abs_lag+1):end]
    end
    
    return shifted
end