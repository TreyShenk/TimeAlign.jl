#!/usr/bin/env julia

"""
Test script for matrix-based signal alignment functionality.

This script tests the align_signals_matrix function which aligns all signals
in a matrix to the first column as reference.
"""

using Pkg
Pkg.activate(".")

using Distributions
using LinearAlgebra
using Statistics
using Random

# Activate the project environment


# Ensure Statistics is available in the current environment
# This is needed because TimeAlign internally uses Statistics
try
    using Statistics
catch
    Pkg.add("Statistics")
    using Statistics
end

println("Active project: $(Pkg.project().path)")

# Now load packages (they'll be resolved from the project environment)
using Plots

using TimeAlign
# include("./src/TimeAlign.jl")


function create_test_signals_matrix()
    """Create a matrix of test signals with known phase shifts."""
    n_samples = 200
    n_signals = 5
    t = range(0, 4π, length=n_samples)
    
    signals = zeros(n_samples, n_signals)
    true_lags = [0, 10, -15, 25, -8]  # Known true lags
    
    # Create base signal
    base_signal = sin.(t) + 0.3 * sin.(3 * t) + 0.1 * randn(n_samples)
    
    for i in 1:n_signals
        lag = true_lags[i]
        if lag >= 0
            # Positive lag: advance signal
            M = n_samples-lag

            signals[1:M, i] .= base_signal[(lag+1):(lag+M)]
            # signals[(lag+1):end, i] = base_signal[1:(n_samples-lag)]
        else
            # Negative lag: delay signal
            abs_lag = abs(lag)
            M = n_samples - abs_lag
            signals[(abs_lag+1):(abs_lag+M), i] = base_signal[1:M]
        end
    end
    
    return signals, true_lags
end

function create_test_signals_matrix2(n_samples, n_signals, max_offset)
    """Create a matrix of test signals with known phase shifts."""
    # n_samples = 200
    # n_signals = 5
    t = range(0, 4π, length=n_samples)
    
    signals = zeros(n_samples, n_signals)
    true_lags = rand(-max_offset:max_offset, n_signals)  # Known true lags
    true_lags[1] = 0
    
    # Create base signal
    base_signal = sin.(t) + 0.3 * sin.(3 * t) + 0.1 * randn(n_samples)
    
    for i in 1:n_signals
        lag = true_lags[i]
        if lag >= 0
            # Positive lag: advance signal
            M = n_samples-lag

            signals[1:M, i] .= base_signal[(lag+1):(lag+M)]
            # signals[(lag+1):end, i] = base_signal[1:(n_samples-lag)]
        else
            # Negative lag: delay signal
            abs_lag = abs(lag)
            M = n_samples - abs_lag
            signals[(abs_lag+1):(abs_lag+M), i] = base_signal[1:M]
        end
    end
    
    return signals, true_lags
end

function create_test_signals_matrix_subsample(n_samples, n_signals, max_offset)
    """Create a matrix of test signals with known phase shifts."""
    # n_samples = 200
    # n_signals = 5
    n = 1:n_samples
    # t = range(0, 4π, length=n_samples)
    # dt = t[2]-t[1]
    signals = zeros(n_samples, n_signals)
    true_lags = rand(Uniform(-max_offset, max_offset), n_signals)  # Known true lags
    true_lags[1] = 0
    
    fs = n_samples
    # Create base signal
    f(n) = sin.(2*pi*(1/fs)n) + 0.3 * sin.(2*pi*(3/fs)* n) + 0.1 * randn(n_samples)
    
    for ii in 1:n_signals
        signals[:, ii] = f(n .+ true_lags[ii])
    end
    
    return signals, true_lags
end

function test_matrix_alignment(align_func, signals, true_lags)
    """Test the align_signals_matrix function."""


    # n_samples, n_signals = size(signals)
    

    # println("True lags: $true_lags")
    
    # Test alignment with sequential processing
    max_lag = 50
    println("\nAligning signals with max_lag = $max_lag ...")
    
    aligned_signals, estimated_lags = align_func(signals, max_lag)
    
    # println("Estimated lags (sequential): $estimated_lags")
    

    
    # Use sequential results for analysis
    # Compute accuracy
    lag_errors = estimated_lags[2:end] .- true_lags[2:end]
    # println("Lag errors (estimated - true): $lag_errors")
    
    accuracy = sum(lag_errors .<= 0.1) / length(lag_errors)
    println("Within 0.1 lag accuracy: $(round(accuracy * 100, digits=1))%")
    println("Max abs error: $(maximum(abs.(lag_errors)))")
    mae = mean(abs.(lag_errors))
    println("Mean Absolute Error: $(round(mae, digits=2))")
    println("Mean error: $(mean(lag_errors))")
    println("MSE: $(mean(lag_errors.^2))")
    return signals, aligned_signals, true_lags, estimated_lags
end

function plot_matrix_alignment_results(true_lags, estimated_lags)
    """Create visualization of matrix alignment results."""
    
    # Plot lag comparison
    p3 = plot(true_lags - estimated_lags, 
                title="Lag Estimation Accuracy",
                xlabel="True Lag", ylabel="Estimated Lag",
                label="Estimates", markersize=6)
    # Add perfect alignment line
    # lag_range = [minimum([true_lags; estimated_lags]), maximum([true_lags; estimated_lags])]
    # plot!(p3, lag_range, lag_range, label="Perfect", linestyle=:dash, color=:black)
    
    # Plot error analysis
    # lag_errors = estimated_lags .- true_lags
    # p4 = bar(1:n_signals, lag_errors,
    #         title="Lag Estimation Errors",
    #         xlabel="Signal Index", ylabel="Error (Estimated - True)",
    #         label="Lag Error", alpha=0.7)
    # hline!(p4, [0], color=:black, linestyle=:dash, label="Zero Error")
    
    # final_plot = plot(p3, p4, layout=(1,2), size=(500, 800))
    final_plot = plot(p3, size = (400, 400))
    savefig(final_plot, "matrix_alignment_results.png")
    println("Saved visualization to: matrix_alignment_results.png")
    
    return final_plot
end



# Run all tests
function main()
    println("Matrix Signal Alignment Test Suite")
    println("="^50)
    
    println("=== Testing Matrix Signal Alignment ===")
    
    # Create test data
    Random.seed!(42)
    signals, true_lags = create_test_signals_matrix()
    n_samples, n_signals = size(signals)

    n_samples = 2000
    n_signals = 80
    max_offset = 10

    # signals, true_lags = create_test_signals_matrix2(n_samples, n_signals, max_offset)
    # println("Created test matrix: $n_samples samples × $n_signals signals")
    # # Main functionality test
    # align_signals_naive, align_signals_complete
    # signals, aligned_signals, true_lags, estimated_lags = test_matrix_alignment(align_signals_naive, signals, true_lags)
    # signals, aligned_signals, true_lags, estimated_lags = test_matrix_alignment(align_signals_complete, signals, true_lags)
    


    signals, true_lags = create_test_signals_matrix_subsample(n_samples, n_signals, max_offset)

    println("Created test matrix with subsample shifts: $n_samples samples × $n_signals signals")
    signals, aligned_signals, true_lags, estimated_lags = test_matrix_alignment(align_signals_naive, signals, true_lags)
    signals, aligned_signals, true_lags, estimated_lags = test_matrix_alignment(align_signals_complete, signals, true_lags)
    # println("$(true_lags)")
    # println("$(estimated_lags)")
    # Create visualization
    # plot_matrix_alignment_results(true_lags, estimated_lags)
    
    
    println("="^50)
    println("Matrix alignment testing completed!")
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
