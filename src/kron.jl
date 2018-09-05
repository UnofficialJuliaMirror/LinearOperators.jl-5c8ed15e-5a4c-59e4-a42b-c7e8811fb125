import Base.kron

# (A ⊗ B)×vec(X) = vec(BXAᵀ)
"""`kron(A, B)`

Kronecker tensor product of A and B in linear operator form, if either
or both are linear operators. If both A and B are matrices, then
`Base.kron` is used.
"""
function kron(A :: AbstractLinearOperator, B :: AbstractLinearOperator)
  m, n = size(A)
  p, q = size(B)
  T = promote_type(eltype(A), eltype(B))
  function prod(x)
    X = reshape(convert(Vector{T}, x), q, n)
    return full(B * X * transpose(A))[:]
  end
  function tprod(x)
    X = reshape(convert(Vector{T}, x), p, m)
    return full(transpose(B) * X * A)[:]
  end
  function ctprod(x)
    X = reshape(convert(Vector{T}, x), p, m)
    return full(B' * X * conj(A))[:]
  end
  symm = issymmetric(A) && issymmetric(B)
  herm = ishermitian(A) && ishermitian(B)
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T,F1,F2,F3}(m * p, n * q, symm, herm, prod, tprod, ctprod)
end

kron(A :: AbstractMatrix, B :: AbstractLinearOperator) =
    kron(LinearOperator(A), B)

kron(A :: AbstractLinearOperator, B :: AbstractMatrix) =
    kron(A, LinearOperator(B))
