using BenchmarkTools, SIMD

const SUITE = BenchmarkGroup()

function perf_LoopVecRange_long(x, a)
    s = Vec{8, eltype(x)}(0)

    @inbounds for j in a
        for i in LoopVecRange{8}(1, j)
            s += x[i]
        end
    end

    return sum(s)
end

function perf_LoopVecRange(x)
    s = Vec{8, eltype(x)}(0)

    @inbounds for i in LoopVecRange{8}(x)
        s += x[i]
    end

    return sum(s)
end

function perf_steprange_long(x, a)
    s = Vec{8, eltype(x)}(0)

    lane = VecRange{8}(0)
    @inbounds for j in a
        for i in 1:8:j
            s += x[lane + i]
        end
    end

    return sum(s)
end

function perf_steprange(x)
    s = Vec{8, eltype(x)}(0)

    lane = VecRange{8}(0)
    @inbounds for i in 1:8:length(x)
        s += x[lane + i]
    end

    return sum(s)
end

SUITE["LoopVecRange"] = BenchmarkGroup(["string", "unicode"])

SUITE["LoopVecRange"]["LoopVecRange"] = @benchmarkable perf_LoopVecRange(x) setup=(x=rand(Float32, 800))

tmp_x=rand(Float32, 800)
SUITE["LoopVecRange"]["LoopVecRange_long"] = @benchmarkable perf_LoopVecRange_long($tmp_x, $(rand(round(Int, length(tmp_x) / 2):length(tmp_x), 10^6)))

SUITE["LoopVecRange"]["StepRange"] = @benchmarkable perf_steprange(x) setup=(x=rand(Float32, 800))

SUITE["LoopVecRange"]["StepRange_long"] = @benchmarkable perf_steprange_long($tmp_x, $(rand(round(Int, length(tmp_x) / 2):length(tmp_x), 10^6)))
