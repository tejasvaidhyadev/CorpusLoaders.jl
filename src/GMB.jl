struct GMB
    filepath :: String
end

function GMB(dirpath)
    @assert(isdir(dirpath), dirpath)


        tagfile_paths = joinpath.(dirpath, "data")

        paths = joinpath.(tagfile_paths, readdir(tagfile_paths))
        path2= joinpath.(paths, readdir(paths))
        path3=joinpath.(path2,readdir(path2))
        final=joinpath.(path3,readdir(en.tags))
end
GMB() = GMB(datadep"GMB 2.2.0") 
  
MultiResolutionIterators.levelname_map(::Type{GMB}) = [
    :documents => 1,
    :sentences => 2,
    :words => 3, :tokens => 3,
    :characters => 4]


function load(dataset::GMB)
    Channel(ctype=@NestedVector(String, 2), csize=4) do docs
        for path in dataset.filepaths   #extract data from the files in directory and put into channel
            open(path) do fileio
                cur_text = read(fileio, String)
                sents = [intern.(tokenize(sent)) for sent in split_sentences(cur_text)]
                put!(docs, sents)
            end #open
        end #for
    end #channel
end


