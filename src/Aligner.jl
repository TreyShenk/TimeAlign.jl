include("LagLoss.jl")
using ProgressMeter

"""
align_signals_naive(signals, max_lag)

Aligns all signals using the first column as the reference signal. This
naive approach simply uses the one measurement for each estimate.



"""
function align_signals_naive(signals, max_lag)

    num_sigs = size(signals)[2]
    shifts = zeros(num_sigs)
    
    @showprogress desc="Computing shifts" for ii in 2:num_sigs
        shifts[ii] = calc_shift_single(signals[:, 1], signals[:, ii], max_lag)
    end

    output = apply_shifts(signals, shifts)

    return output, shifts
end

#TODO Find out if the direction/sign relationship for the shifts
function apply_shifts(signals, shifts)
    @assert len(shifts) == size(signals)[2]
end