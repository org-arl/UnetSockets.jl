# special handling of message properties

function Base.getproperty(msg::BasebandSignal, p::Symbol)
  if p === :signal
    s = getfield(msg, :signal)
    return s === nothing ? nothing : transpose(reshape(s, Int64(msg.channels), :))
  end
  getfield(msg, p)
end

function Base.setproperty!(msg::BasebandSignal, p::Symbol, v::AbstractVecOrMat)
  if p === :signal
    msg.channels = size(v, 2)
    v = vec(transpose(v))
    if eltype(v) == Complex{Float64}
      v = convert(Array{ComplexF32}, v)
    elseif eltype(v) == Float64
      v = Float32.(v)
    end
  end
  setfield!(msg, p, v)
end
