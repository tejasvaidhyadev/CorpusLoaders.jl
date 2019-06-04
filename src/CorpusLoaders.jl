module CorpusLoaders
using DataDeps
using WordTokenizers
using MultiResolutionIterators
using InternedStrings
using Glob
using StringEncodings
using CSV

export Document, TaggedWord, SenseAnnotatedWord, PosTaggedWord
export title, sensekey, word
export load

export WikiCorpus, SemCor, Senseval3, IMDB, Twitter, StanfordSentimentTreebank

function __init__()
    include(joinpath(@__DIR__, "WikiCorpus_DataDeps.jl"))
    include(joinpath(@__DIR__, "SemCor_DataDeps.jl"))
    include(joinpath(@__DIR__, "SemEval2007Task7_DataDeps.jl"))
    include(joinpath(@__DIR__, "Senseval3_DataDeps.jl"))
    include(joinpath(@__DIR__, "IMDB_DataDeps.jl"))
    include(joinpath(@__DIR__, "Twitter_DataDeps.jl"))
    include(joinpath(@__DIR__, "StanfordSentimentTreebank_DataDeps.jl"))
end

include("types.jl")
include("apply_subparsers.jl")
include("WikiCorpus.jl")
include("SemCor.jl")
include("SemEval2007Task7.jl")
include("Senseval3.jl")
include("IMDB.jl")
include("Twitter.jl")
include("StanfordSentimentTreebank.jl")

end
