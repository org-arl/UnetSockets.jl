# UnetStack Julia API

Julia gateway that can connect to the [UnetStack](https://unetstack.net).

## Installation

In Julia REPL:
```julia
julia> # press "]" to enter package manager
pkg> add https://github.com/org-arl/Unet.jl
```

## Example usage

In Julia REPL:
```julia
julia> using Fjage, Unet
julia> sock = UnetSocket("localhost", 1100);
julia> send(sock, "hello world!", 2)
true
julia> close(sock)
```

For more details, see help (press "?" in Julia REPL) for `Unet`.
