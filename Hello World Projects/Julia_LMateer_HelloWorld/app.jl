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

# Creating Home Page Route
@get "/hello" function(req::HTTP.Request)
    return "Hello World!"
end

# Serialize Dict to JSON
@get "/json" function(req::HTTP.Request)
    return Dict("name" => "Laura")
end

# Render HTML with context
@get "/" function(reg::HTTP.Request)
    context = Dict("name" => "Laura")
    return renderHTML("index.html", context)
end

# Receiving query params
@get "/query" function(req::HTTP.Request)
    return queryparams(req)
end

# Receiving form data
@get "/form" function(req::HTTP.Request)
    formData = queryparams(req)
    name = get(formData, "name", 0)
    context = Dict("name" => name)
    return renderHTML("form.html", context)
end

# Path params
@get "/add/{num1}/{num2}" function(req::HTTP.Request, num1::Float64, num2::Float64)
    return num1 + num2
end

serve(port=8443)