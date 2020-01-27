struct CoNLL{S}
    filepaths::Vector{S}
    year::Int
    trainpath::String
    testpath::String
    devpath::String
end

"""
    CoNLL()

Creates a CoNLL instance for lazy loading the corpus.

# Example Usage

```jldoctest
train = load(CoNLL(), "train") # training set
test = load(CoNLL(), "test") # test set
dev = load(CoNLL(), "dev") # dev set

julia> no_sent_boundary = flatten_levels(train, lvls(CoNLL, :sentence)) |> full_consolidate

julia> typeof(no_sent_boundary)
Document{Array{Array{CorpusLoaders.NERTaggedWord,1},1},String}

julia> no_sent_boundary[1]
469-element Array{CorpusLoaders.NERTaggedWord,1}:
 CorpusLoaders.NERTaggedWord("B-ORG", "B-NP", "NNP", "EU")
 CorpusLoaders.NERTaggedWord("O", "B-VP", "VBZ", "rejects")
 ⋮
 CorpusLoaders.NERTaggedWord("O", "I-NP", "NN", "percent")
 CorpusLoaders.NERTaggedWord("O", "B-PP", "IN", "of")
 CorpusLoaders.NERTaggedWord("O", "B-NP", "JJ", "overall")
 CorpusLoaders.NERTaggedWord("O", "I-NP", "NNS", "imports")
 CorpusLoaders.NERTaggedWord("O", "O", ".", ".")

julia> dataset = flatten_levels(train, lvls(CoNLL, :document)) |> full_consolidate

julia> typeof(dataset)
Document{Array{Array{CorpusLoaders.NERTaggedWord,1},1},String}

julia> length(dataset) # Total number of sentences.
14041

julia> for tagged_word in dataset[1]
           ner_tag = named_entity(tagged_word)
           w = word(tagged_word)
           println("$w => $ner_tag")
       end
EU => B-ORG
rejects => O
German => B-MISC
call => O
to => O
boycott => O
British => B-MISC
lamb => O
. => O

julia> for tagged_word in dataset[1]
           pos_tag = part_of_speech(tagged_word)
           w = word(tagged_word)
           println("$w => $pos_tag")
       end
EU => NNP
rejects => VBZ
German => JJ
call => NN
to => TO
boycott => VB
British => JJ
lamb => NN
. => .
```

The CoNLL-2003 shared task data files is made from the the Reuters Corpus, is a collection of news wire articles.

Each word has been tagger three labels to it - a part-of-speech (POS) tag, a syntactic chunk tag and the named entity tag. 

The chunk tags and the named entity tags are tagged with the BIO1 or IOB format.


Please cite the following publication if you use the corpora:
        Erik F. Tjong Kim Sang, Fien De Meulder. "Introduction to the CoNLL-2003 Shared Task: Language-Independent Named Entity Recognition." Proceedings of CoNLL-2003, Edmonton, Canada, 2003.
https://www.clips.uantwerpen.be/conll2003/pdf/14247tjo.pdf

"""
function CoNLL(dirpath, year=2003)
    @assert(isdir(dirpath), dirpath)

    files = Dict()

    if year == 2003
        inner_files = readdir(dirpath)
        if "train.txt" ∈ inner_files
            files["train"] = "train.txt"
        end
        if "test.txt" ∈ inner_files
            files["test"] = "test.txt"
        end
        if "valid.txt" ∈ inner_files
            files["valid"] = "valid.txt"
        end
        for tuple in files
            files[tuple[1]] = joinpath(dirpath, tuple[2])
        end
    end
    return CoNLL(collect(values(files)), year, files["train"],
                  files["test"], files["valid"])
end

CoNLL() = CoNLL(datadep"CoNLL 2003")

MultiResolutionIterators.levelname_map(::Type{CoNLL}) = [
    :doc=>1, :document=>1, :article=>1,
    :sent=>2, :sentence=>2,
    :word=>3, :token=>3,
    :char=>4, :character=>4
    ]

function parse_conll2003_tagged_word(line::AbstractString)
    tokens_tags = split(line)
    length(tokens_tags) != 4 && throw("Error parsing line: \"$line\". Invalid Format.")
    return NERTaggedWord(tokens_tags[4], tokens_tags[3],
                         tokens_tags[2], tokens_tags[1])
end

function parse_conll2003file(filename)
    local sent
    local doc
    docs = @NestedVector(NERTaggedWord,3)()
    context = Document(intern(basename(filename)), docs)

    # structure
    function new_document()
        doc = @NestedVector(NERTaggedWord,2)()
        push!(docs, doc)
    end

    function new_sentence()
        sent = @NestedVector(NERTaggedWord,1)()
        push!(doc, sent)
    end

    # words
    get_tagged(line) = push!(sent, parse_conll2003_tagged_word(line))

    # parse
    for line in eachline(filename)
        if length(line) == 0
            new_sentence()
        elseif startswith(strip(line), "-DOCSTART-")
            length(docs) > 0 && isempty(doc[end]) && deleteat!(doc, lastindex(doc))
            new_document()
        else
            get_tagged(line)
        end
    end
    isempty(doc[end]) && deleteat!(doc, lastindex(doc))

    return context
end

function load(corpus::CoNLL, file="train")
    if (corpus.year == 2003)
        file == "train" && return parse_conll2003file(corpus.trainpath)
        file == "test" && return parse_conll2003file(corpus.testpath)
        file == "dev" && return parse_conll2003file(corpus.devpath)
        throw("Invalid filename! Available datasets are `train`, `test` and `dev`")
    end
end
