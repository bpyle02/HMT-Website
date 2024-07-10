using Oxygen
using HTTP
using Mustache

# Render HTML from file
function renderHTML(htmlFile::String, context::Dict = Dict(); status = 200, headers = ["Content-Type" => "text/html; charset=utf-8"]) :: HTTP.Response
    isContextEmpty = isempty(context) === true

    # Return raw HTML without context
    if isContextEmpty
        io = open(htmlFile, "r") do file
            read(file, String)
        end
        template = io |> String

    # Return HTML with context
    else
        io = open(htmlFile, "r") do file
            read(file, String)
        end
        template = String(Mustache.render(io, context))
    end
        return HTTP.Response(status, headers, body = template)
end

# Render HTML with context
@get "/" function(reg::HTTP.Request)
    context = Dict("n" => "Jeremiah")
    return renderHTML("index.html",context)
end

serve(port=8443)