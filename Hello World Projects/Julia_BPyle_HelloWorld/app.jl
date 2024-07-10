using Oxygen
using HTTP
using Mustache
using JSON

# Render HTML from file
function renderHTML(htmlFile::String, cssFile::String, context::Dict = Dict(); status = 200, headers = ["Content-Type" => "text/html; charset=utf-8"]) :: HTTP.Response
    isContextEmpty = isempty(context)

    # Read HTML file
    io = open(htmlFile, "r") do file
        read(file, String)
    end
    template = isContextEmpty ? io |> String : String(Mustache.render(io, context))

    # Read CSS file
    css = ""
    if !isempty(cssFile)
        css_io = open(cssFile, "r") do file
            read(file, String)
        end
        css = "<style>$css_io</style>"
    end

    # Combine HTML and CSS
    template = "<html><head>$css</head><body>$template</body></html>"

    return HTTP.Response(status, headers, body = template)
end

# Render HTML with context
@get "/" function(reg::HTTP.Request)
    context = Dict("name" => "Brandon")
    return renderHTML("index.html", "style.css", context)
end

serve(port=8443)