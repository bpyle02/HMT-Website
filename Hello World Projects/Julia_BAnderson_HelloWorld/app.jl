using Oxygen
using HTTP
using Mustache
using JSON

struct Subscriber
    name::String
    email::String
end

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
@get "/help" function(req::HTTP.Request)
    return "Help World!"
end

# Serialize Dict to JSON
@get "/json" function(req::HTTP.Request)
    return Dict("name" => "NotBrynlee")
end

# Render HTML with context
@get "/" function(reg::HTTP.Request)
    context = Dict("name" => "NotBrynlee")
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
@get "/useradd/{name}/{email}" function(req::HTTP.Request, name::String, email::String)

    newUser = JSON.json(Dict("user_data"=>[Dict("id"=>"123456", "name"=>name, "email"=>email)]))

    open("db.json","a") do f
        write(f, newUser)
    end

    return 0
end

serve(port=8443)