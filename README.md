![CI](https://github.com/org-arl/UnetSockets.jl/workflows/CI/badge.svg)<br>
_[ UnetStack 3.1.0 ]_

# UnetStack Julia API

Julia UnetSocket API to connect to [UnetStack](https://unetstack.net).

## Installation

In Julia REPL:
```julia
julia> # press "]" to enter package manager
pkg> add https://github.com/org-arl/UnetSockets.jl
```

## Example usage

In Julia REPL:
```julia
julia> using UnetSockets
julia> sock = UnetSocket("localhost", 1100);
julia> send(sock, "hello world!", 2)
true
julia> close(sock)
```

For more details, see help (press "?" in Julia REPL) for `UnetSockets`.
