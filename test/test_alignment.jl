#!/usr/bin/env julia

"""
Test script for matrix-based signal alignment functionality.

This script tests the align_signals_matrix function which aligns all signals
in a matrix to the first column as reference.
"""

using LinearAlgebra
using Statistics
using Random

# Activate the project environment
using Pkg
Pkg.activate(".")

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

function test_matrix_alignment()
    """Test the align_signals_matrix function."""
    println("=== Testing Matrix Signal Alignment ===")
    
    # Create test data
    signals, true_lags = create_test_signals_matrix()
    n_samples, n_signals = size(signals)
    
    println("Created test matrix: $n_samples samples × $n_signals signals")
    println("True lags: $true_lags")
    
    # Test alignment with sequential processing
    max_lag = 30
    println("\nAligning signals with max_lag = $max_lag (sequential)...")
    
    aligned_signals, estimated_lags = align_signals_naive(signals, max_lag)
    
    println("Estimated lags (sequential): $estimated_lags")
    

    
    # Use sequential results for analysis
    # Compute accuracy
    lag_errors = estimated_lags .- true_lags
    println("Lag errors (estimated - true): $lag_errors")
    
    accuracy = sum(lag_errors .== 0) / length(lag_errors)
    println("Exact accuracy: $(round(accuracy * 100, digits=1))%")
    
    mae = mean(abs.(lag_errors))
    println("Mean Absolute Error: $(round(mae, digits=2))")
    
    # Compare signal quality before and after alignment
    println("\n=== Signal Quality Comparison ===")
    
    reference = signals[:, 1]
    
    # Before alignment
    mse_before = mean([mean((reference .- signals[:, i]).^2) for i in 2:n_signals])
    
    # After alignment  
    mse_after = mean([mean((reference .- aligned_signals[:, i]).^2) for i in 2:n_signals])
    
    println("Average MSE before alignment: $(round(mse_before, digits=4))")
    println("Average MSE after alignment:  $(round(mse_after, digits=4))")
    println("Improvement factor: $(round(mse_before / mse_after, digits=2))x")
    
    return signals, aligned_signals, true_lags, estimated_lags
end

function plot_matrix_alignment_results(signals, aligned_signals, true_lags, estimated_lags)
    """Create visualization of matrix alignment results."""
    n_samples, n_signals = size(signals)
    
    # Plot original and aligned signals
    p1 = plot(title="Original Signals", xlabel="Sample", ylabel="Amplitude")
    for i in 1:n_signals
        plot!(p1, signals[:, i], label="Signal $i (lag=$(true_lags[i]))", alpha=0.8)
    end
    
    p2 = plot(title="Aligned Signals", xlabel="Sample", ylabel="Amplitude")
    for i in 1:n_signals
        plot!(p2, aligned_signals[:, i], label="Signal $i (est_lag=$(estimated_lags[i]))", alpha=0.8)
    end
    
    # Plot lag comparison
    p3 = scatter(true_lags, estimated_lags, 
                title="Lag Estimation Accuracy",
                xlabel="True Lag", ylabel="Estimated Lag",
                label="Estimates", markersize=6)
    # Add perfect alignment line
    lag_range = [minimum([true_lags; estimated_lags]), maximum([true_lags; estimated_lags])]
    plot!(p3, lag_range, lag_range, label="Perfect", linestyle=:dash, color=:black)
    
    # Plot error analysis
    lag_errors = estimated_lags .- true_lags
    p4 = bar(1:n_signals, lag_errors,
            title="Lag Estimation Errors",
            xlabel="Signal Index", ylabel="Error (Estimated - True)",
            label="Lag Error", alpha=0.7)
    hline!(p4, [0], color=:black, linestyle=:dash, label="Zero Error")
    
    final_plot = plot(p1, p2, p3, p4, layout=(2,2), size=(1000, 800))
    
    savefig(final_plot, "matrix_alignment_results.png")
    println("Saved visualization to: matrix_alignment_results.png")
    
    return final_plot
end



# Run all tests
function main()
    println("Matrix Signal Alignment Test Suite")
    println("="^50)
    
    # Main functionality test
    signals, aligned_signals, true_lags, estimated_lags = test_matrix_alignment()
    
    # Create visualization
    plot_matrix_alignment_results(signals, aligned_signals, true_lags, estimated_lags)
    
    
    println("="^50)
    println("Matrix alignment testing completed!")
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
