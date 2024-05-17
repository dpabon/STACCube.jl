using YAXArrayBase
using YAXArrays 

const rastertypes = ["image/tiff", "image/jp2"]
checkraster(asset::Asset) = checkraster(type(asset))
checkraster(::Any) = false
function checkraster(assettype::String) 
    @show assettype
    @show startswith.(Ref(assettype), rastertypes)
    any(startswith.(Ref(assettype), rastertypes))
end

function staccube(item::STAC.Item;token="", assets=keys(item.assets))
    assetcubes = Dict()
    for assetkey in assets
        asset = item.assets[assetkey]
        if checkraster(asset)
                    @show asset

            uri = signed_uri(asset, token)
            path = if startswith(uri, "file://")
                replace(uri, "file://" => "")
            else
                string("/vsicurl/", uri)
            end
            @show path
            yax = YAXArray(AG.readraster(path))
            push!(assetcubes,Symbol(title(asset)) => yax)
            #@show asset
        end
    end
    varax = Dim{:Title}([first(it) for it in item.assets if checkraster(last(it))])

    ds = Dataset(;assetcubes...)
    return ds
end
