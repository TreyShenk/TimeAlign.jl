using SparseArrays

"""
"""
function construct_A(N)

    num_pairs = Int(N*(N-1)/2)

    # Populate the row, column, and value vectors
    total_nonzero = Int(num_pairs*2 - (N-1))
    col_inds = zeros(Int, total_nonzero)
    row_inds = zeros(Int, total_nonzero)
    values = zeros(Float64, total_nonzero)
    row_inds[1:(N-1)] = 1:(N-1)

    # Populate the standard shifts with the main reference
    for ind in 1:(N-1)
        row_inds[ind] = ind
        col_inds[ind] = ind
        values[ind] = 1
    end
    
    # Populate matrix for all extra pairs
    ref_ind = 1
    sig_ind = 2
    raw_ind = N
    for ii in N:num_pairs
        row_inds[raw_ind] = ii
        col_inds[raw_ind] = ref_ind
        values[raw_ind] = -1

        raw_ind = raw_ind + 1
        
        row_inds[raw_ind] = ii
        col_inds[raw_ind] = sig_ind
        values[raw_ind] = 1

        raw_ind = raw_ind + 1

        sig_ind = sig_ind + 1
        if sig_ind == N
            ref_ind = ref_ind + 1
            sig_ind = ref_ind + 1
        end


    end

    # Construct the sparse A matrix
    A = sparse(row_inds, col_inds, values)
    
    return A
end

"""
    construct_AtA_inv(N)

Computes the (A^T A)^-1 matrix given by Equation 21. This is needed to solve for the 
estimated offsets, as shown in Equation 17.
"""
function construct_AtA_inv(N)
    AtA_inv = fill(1/N, (N-1, N-1))
    for ii in 1:(N-1)
        AtA_inv[ii, ii] = 2/N
    end
    return AtA_inv
end