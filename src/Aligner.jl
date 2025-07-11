include("LagLoss.jl")
include("Constructors.jl")
using ProgressMeter
using Statistics



##############################################
## Naive Calculation
##############################################
"""
align_signals_naive(signals, max_lag)

Aligns all signals using the first column as the reference signal. This
naive approach simply uses the one measurement for each estimate.



"""
function align_signals_naive(signals, max_lag)

    aligned_signals = zeros(eltype(signals), size(signals))
    aligned_signals[1, :] = signals[1, :]

    shifts = calc_alignment_naive(signals, max_lag)

    aligned_signals = apply_lag_shift(signals, shifts)

    return aligned_signals, shifts
end

function calc_alignment_naive(signals, max_lag)
    num_sigs = size(signals)[2]
    shifts = zeros(Float64, num_sigs)
    @showprogress desc="Computing shifts"  for ii in 2:num_sigs
        shifts[ii] = find_optimal_lag(signals[:, 1], signals[:, ii], max_lag = max_lag)
    end
    return shifts
end



##############################################
## Complete  Method
##############################################

function align_signals_complete(signals, max_lag)
    shifts = calc_alignment_complete(signals, max_lag)
    aligned_signals = apply_lag_shift(signals, shifts)
    return aligned_signals, shifts
end

function _calc_ind(ii, jj)
    while (ii>0)
        
    end
end

function calc_alignment_complete(signals, max_lag)
    num_sigs = size(signals)[2]
    num_pairs = Int((num_sigs)*(num_sigs-1)/2)
    all_shifts = zeros(Float64, num_pairs)

    pairs = [(ii, jj) for ii in 1:(num_sigs -1) for jj in (ii+1):num_sigs]
    @showprogress desc="Computing complete shifts" Threads.@threads for k in eachindex(pairs)
        ii, jj = pairs[k]
        all_shifts[k] = find_optimal_lag(signals[:, ii], signals[:, jj], max_lag = max_lag)
    end

    shifts = zeros(Float32, num_sigs)
    A = construct_A(num_sigs)
    shifts[2:end] = A\all_shifts
    return shifts
end


##############################################
## Helpers
##############################################
# Maybe move to utils?
function apply_lag_shift(signals, shifts)
    println(size(signals))
    num_sigs = size(signals)[2]
    aligned_signals = zeros(eltype(signals), size(signals))
    aligned_signals[:, 1] = signals[:, 1]
    for ii in 2:num_sigs
        sig_view = view(signals, :, ii)
        aligned_signals[:, ii] = _apply_lag_shift_ind(sig_view, Int(round(shifts[ii])))
    end

    return aligned_signals
end

function _apply_lag_shift_ind(signal::AbstractVector{<:Real}, lag::Int)
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