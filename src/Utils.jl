
#TODO: Look at paper on "Splitting the Unit Delay" for methods to perform a subsample shift
function subsample_shift(signal, shift)
end

#TODO: Implement from https://ccrma.stanford.edu/~jos/sasp/Quadratic_Interpolation_Spectral_Peaks.html
function peak_interp_quad(signal_peak)
    @assert length(signal_peak)==3
    α = signal_peak[1]
    β = signal_peak[2]
    γ = signal_peak[3]

    p = (1/2)*(α - γ)/(α - 2*β + γ)
    return p
end