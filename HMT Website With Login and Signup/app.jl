using Oxygen
using HTTP
using Mustache
using JSON
using Dates
using CSV
using Hyperelastics
using ComponentArrays, ForwardDiff, ADTypes
using Optimization, OptimizationOptimJL
using InteractiveUtils
using DataFrames

#==================================================================================================================================

    GLOBAL VARIABLES

==================================================================================================================================#

characters = "abcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*_-?`~/.\\" # list of accepted characters to be encrypted
key = "green" # encryption / decryption key

global data # CSV data
global model_data = [] # optimized values
global session = Dict{String, String}()  # stores session data - key: session_id, value: user_id

#==================================================================================================================================

    HELPER FUNCTIONS

==================================================================================================================================#

# generates a random session ID
function generateSessionId()
    return Base64.encode(random_string(32)) # generates a random base64 encoded string to use as session id
end

# checks if a session is valid
function isValidSession(session_id::String)
    haskey(session, session_id) && session[session_id] != ""
end

# gets the user ID from a valid session
function getUserIdFromSession(session_id::String)
    if isValidSession(session_id)
        return session[session_id]
    end
    return nothing
end

# grabs the last entered entry's id
function lastId()  
    rawJSON = JSON.parsefile("db.json"; use_mmap = false) # grab file
    lastId = rawJSON[end]["id"] # goes to end of json file and grabs that entry's id
    return lastId # return the id from the last entry
end

global id = lastId() # the current global id

# increments the global id so that users don't have the same id
function nextId()
    global id = string(parse(Int, id) + 1) # increments the id by 1
    return id # returns the new id
end

# checks to see if a user account has been created with the same email
function checkForDuplicates(email::String)
    emailFound = false # default is that the email is not a duplicate

    rawJSON = JSON.parsefile("db.json"; use_mmap = false) # grab file
    for obj in rawJSON # loop through each object (user account) in the JSON file
        if obj["email"] == email # if the email is the same as the user's email
            emailFound = true # if it's the same, set emailFound to true so an error message can be triggered
        end
    end

    return emailFound # return emailFound for use in triggering an error message if necessary
end

# get HTML, CSS, JavaScript, and any context values and display them to the screen
function renderHTML(htmlFile::String, cssFile::String, jsFile::String, context::Dict = Dict(); status = 200, headers = ["Content-Type" => "text/html; charset=utf-8"]) :: HTTP.Response
    isContextEmpty = isempty(context) # check to see if any context values were provided

    # Read HTML file
    io = open("html/" * htmlFile, "r") do file # open the HTML file
        read(file, String) # read the file
    end
    template = isContextEmpty ? io |> String : String(Mustache.render(io, context)) # create a template variable with the rendered HTML

    # Read CSS file
    css = ""
    if !isempty(cssFile) # if a CSS file was provided, do the following
        css_io = open("css/" * cssFile, "r") do file # open the CSS file
            read(file, String) # read the file
        end
        css = "<style>$css_io</style>" # HTML-ify the CSS
    end

    # Read JS file
    js = ""
    if !isempty(jsFile) # if a JS file was provided, do the following
        js_io = open("js/" * jsFile, "r") do file # open the JS file
            read(file, String) # read the file
        end
        js = "<script>$js_io</script>" # HTML-ify the JS
    end

    # Combine HTML, CSS, and JS
    template = "<html><head>" * css * "</head><body>" * template * js * "</body></html>"

    return HTTP.Response(status, headers, body = template) # return the HTTP webpage
end

# add new user data to the JSON database file
function signup(fName::String, lName::String, email::String, password::String, status::String)
    encryptedData = Dict("id" => nextId(), "first_name" => fName, "last_name" => lName, "email" => email, "password" => password, "status" => status) # encrypt email and password
    rawJSON = JSON.parsefile("db.json"; use_mmap = false) # parse JSON file to allow modification
    push!(rawJSON, encryptedData) # add new user's data to the JSON array
    userData = JSON.json(rawJSON) # convert Julia Array to a JSON object

    @info encryptedData
    @info userData

    try
        file = open("db.json", "w")
        write(file, userData)
        close(file)
        
        return renderHTML("login.html", "style.css", "")
    catch e
        @info e
    end
end

# vigenere cipher algorithm adapted from https://github.com/TheAlgorithms/Julia/blob/main/src/cipher/vigenere.jl
function encrypt_decrypt(text::String, key::String, encrypt = true)
    encoded = ""
    key_index = 1 # set index to 1
    key = lowercase(key) # make sure the key is lowercase

    for symbol in text # loop through each symbol in the text variable
        num = findfirst(isequal(lowercase(symbol)), characters) # set num to the position of the symbol in the characters string

        if !isnothing(num) # if the value isn't found in the characters string, skip it
            if encrypt
                num += findfirst(isequal(key[key_index]), characters) - 1 # shift the value of num based on the current key character (encryption only)
            else
                num -= findfirst(isequal(key[key_index]), characters) - 1 # reverse the shifting for decryption
            end

            num %= length(characters) # add the remainder of num / the length of the characters string to the num variable

            if encrypt
                num = num == 0 ? 26 : num # if num is 0, set it to 26, otherwise do nothing
            else
                num = num <= 0 ? num + length(characters) : num # if num is less than or equal to 0, add the length of the characters string to it. Otherwise do noting
            end

            encoded *= islowercase(symbol) ? characters[num] : lowercase(characters[num]) # append the character at position num to the encoded string and make sure it is lowercase
            key_index = key_index == length(key) ? 1 : key_index + 1 # increment the key index or reset it if it is at the max
        else
            encoded *= symbol # append the symbol to the encoded string
        end
    end

    return encoded # return the encoded string
end

# get the hyperelastic models
function getHyperelasticModels()
    hyperelastic_models_html = ""

    st = subtypes(Hyperelastics.AbstractIncompressibleModel)
    hyperelastic_models = filter(x -> typeof(x()) <: Hyperelastics.AbstractIncompressibleModel, st)
    hyperelastic_models_string = map(x -> split(string(x), ".")[end], hyperelastic_models) # creates an array with all the model names

    for model in hyperelastic_models_string 
        hyperelastic_models_html *= "<li>" * model * "</li>" # loops through all the models and adds list item tags so they can be added to the HTML
    end
    
    return hyperelastic_models_html
end

#==================================================================================================================================

    WEBSITE PATH FUNCTIONS

==================================================================================================================================#

# render the home screen
@get "/" function(req::HTTP.Request)
    context = Dict("hyperelastic_models" => getHyperelasticModels()) # load the hyperelastic models

    return renderHTML("index.html", "style.css", "carousel.js", context) # render the content to the screen
end

# render the signup page
@get "/signup" function(req::HTTP.Request)
    form_data = queryparams(req) # create form_data variable ready for user input

    @info form_data

    # get the variables from user input sections of the HTML
    fName = get(form_data, "first_name", "")
    lName = get(form_data, "last_name", "")
    email = get(form_data, "email", "")
    password = get(form_data, "password", "")
    status = get(form_data, "status", "")

    @info "WHAT ?????"

    @info fName
    
    if password != "" # prevent blank value being added in when page is loaded
        # encrypt the user data
        fName_encrypted = encrypt_decrypt(fName, key)
        lName_encrypted = encrypt_decrypt(lName, key)
        email_encrypted = encrypt_decrypt(email, key)
        password_encrypted = encrypt_decrypt(password, key)

        @info fName
        @info fName_encrypted
        
        # if an account has alrready been created with that email, show an error message. Otherwise add the data to the JSON database
        if !checkForDuplicates(email_encrypted)
            signup(fName_encrypted, lName_encrypted, email_encrypted, password_encrypted, status)
        else
            context = Dict("error_message" => "An account with this email has already been created. Please return to the sign up page and try again with a different email.")
            return renderHTML("error_template.html", "style.css", "", context)
        end
    end

    return renderHTML("signup.html", "style.css", "")
end

# render the login page
@get "/login" function(req::HTTP.Request)
    form_data = queryparams(req) # create form_data variable ready for user input

    # get the variables from user input sections of the HTML
    email = get(form_data, "email", "")
    password = get(form_data, "password", "")
    @info email
    rawJSON = JSON.parsefile("db.json"; use_mmap = false) # read JSON file

    loc = 1 # create location variable
    found = false # set found to false as default
    
    # encrypt the data
    email_encrypted = encrypt_decrypt(email, key)
    password_encrypted = encrypt_decrypt(password, key)

    if email != "" && password != "" # prevent blank value being processed when page is first loaded
        for obj in rawJSON # loop through each object in the JSON database
            if obj["email"] == email_encrypted # check if the email is equal to the email in the current JSON object
                found = true # if it's the same, set found to true end exit the loop
                break
            loc += 1 # increment the location if a match is not found
            end
        end
    
        if found # if an email match is found, do the following
            if password_encrypted == rawJSON[loc]["password"] # check if password matches
                return renderHTML("index.html", "style.css", "carousel.js") # if it does, loac the home page
            else # otherwise, load the error message page
                context = Dict("error_message" => "Either the Email/Password you put was wrong. Go back and try again!")
                return renderHTML("error_template.html", "style.css", "", context)
            end
        else # if an email match is not found, load the error message page
            context = Dict("error_message" => "Either the Email/Password you put was wrong. Go back and try again!")
            return renderHTML("error_template.html", "style.css", "", context)
        end
    end

    # Render the HTML page and pass in the Dict object with necessary data
    return renderHTML("login.html", "style.css", "")
end

# render the reset password page
@get "/reset" function(req::HTTP.Request)
    return renderHTML("resetPass.html", "style.css", "")
end

@get "/sendEmail" function(req::HTTP.Request)
    return renderHTML("sendResetEmail.html", "style.css", "")
end

#==================================================================================================================================

    API FUNCTIONS

==================================================================================================================================#

# render the upload post api function for downloading the CSV file
@post "/upload" function(req::HTTP.Request)
    global data # gets the global data variable for use within the function

    content = HTTP.parse_multipart_form(req) # get data from the HTML form

    # error checking to make sure invalid files aren't submitted
    if isnothing(file)
        return HTTP.Response(400, "No file uploaded")
    elseif content[1].contenttype != "text/csv"
        return HTTP.Response(400, "Please upload a .CSV file")
    else
        filename = content[1].filename
        data = CSV.read(content[1].data, DataFrame) # saves the CSV data to the global data value
        return HTTP.Response(200, "File uploaded successfully: $filename")
    end
end

# sends the model equation, arguments, and model info string to the client side for rendering to the user
@get "/getModelDocString/{model}" function (request::HTTP.Request, model::String)
    doc_strings = eval(:(@doc $(getfield(Hyperelastics, Symbol(model))())))|>string
    doc_strings = split(string(doc_strings), "\n")

    model_line = findfirst(x -> occursin("Model", x), doc_strings)
    arguments_line = findfirst(x -> occursin("Arguments", x), doc_strings)
    parameters_line = findfirst(x -> occursin("Parameters", x), doc_strings)

    if isnothing(arguments_line)
        arguments_line = parameters_line
    end

    model_string = join(doc_strings[model_line+1:arguments_line-1]," ")
    arguments_string = join(doc_strings[arguments_line+1:parameters_line-1], " ")

    parameters_string = join(doc_strings[parameters_line+1:end], " ")
    parameters_string_split = split(parameters_string, '>')
    model_info_string = parameters_string_split[2]

    return JSON.json(Dict("model_string" => model_string, "arguments_string" => arguments_string, "model_info_string" => model_info_string))
end

# sends the model parameters to the client side for rendering to the user
@get "/getModelParams/{model}" function (req::HTTP.Request, model::String)
    model = getfield(Hyperelastics, Symbol(model))
    params = parameters(model())
    return JSON.json(Dict("params" => params))
end

# sends the lower and upper bounds to the client side for rendering to the user
@get "/getBounds/{model}/{testType}" function (request::HTTP.Request, model::String, testType::String)
    global data
    stress = data.Stress
    stretch = data.Stretch

    test = HyperelasticUniaxialTest(stretch, stress, name="test")
    model = getfield(Hyperelastics, Symbol(model))
    bounds = parameter_bounds(model(), test)
    ps = parameters(model())
    lb = isnothing(bounds.lb) ? NamedTuple(ps .=> -Inf) : bounds.lb
    ub = isnothing(bounds.ub) ? NamedTuple(ps .=> Inf) : bounds.ub
    processed_bounds = (lb=lb, ub=ub)

    processed_bounds_updated_lb = map(x -> isinf(x) ? string(sign(x) * Inf) : x, processed_bounds.lb)
    processed_bounds_updated_ub = map(x -> isinf(x) ? string(sign(x) * Inf) : x, processed_bounds.ub)
    processed_bounds_combined = Dict("lb" => processed_bounds_updated_lb, "ub" => processed_bounds_updated_ub)

    @info processed_bounds_combined
    @info JSON.json(processed_bounds_combined)
    return JSON.json(processed_bounds_combined)
end

# sends the optimized values to the client side for rendering to the user
@get "/optimizeModel/{model}/{testType}/{optimizer}/{vals}/{parameters}" function (req::HTTP.Request, model::String, testType::String, optimizer::String, vals::String, parameters::String)
    global data, model_data

    stretch = data.Stretch
    stress = data.Stress

    model = getfield(Hyperelastics, Symbol(model))
    test = HyperelasticUniaxialTest(stretch, stress, name="test")
    vals = split(vals, ",")
    parameters = split(parameters, ",")

    initial_guesses = Dict(zip(Symbol.(parameters), Base.Fix1(parse, Float64).(vals)))

    k = keys(initial_guesses)
    v = values(initial_guesses)
    cv = ComponentVector(NamedTuple(k .=> v))
    prob = HyperelasticProblem(model(), test, cv; ad_type=AutoForwardDiff())
    sol = solve(prob, getfield(OptimizationOptimJL, Symbol(optimizer))())

    display(NamedTuple(sol.u))

    optimized_values = JSON.json(NamedTuple(sol.u))
    model_data = collect(values(JSON.parse(optimized_values)))

    return optimized_values
end

# sends the final x and y data to the client side for rendering to the user
@get "/finalGraphData/{model}/{parameters}" function (request::HTTP.Request, model::String, parameters::String)
    global DataType, model_data

    stretch_data = data.Stretch
    stress_data = data.Stress
    
    model = getfield(Hyperelastics, Symbol(model))
    parameters = split(parameters, ",").|>Symbol
    cv = ComponentVector(NamedTuple(parameters .=> model_data))
    test = HyperelasticUniaxialTest(stretch_data, stress_data, name="test")
    results = predict(model(), test, cv, ad_type=AutoForwardDiff())
    x = getindex.(results.data.λ, 1)
    y = getindex.(results.data.s, 1)

    return JSON.json(Dict("x" => x, "y" => y))
end

#==================================================================================================================================

    UNUSED FUNCTIONS

==================================================================================================================================#

# const SESSIONS = Dict()

# function createSession()
#     session_id = uuid4()
#     SESSIONS[session_id] = Dict()  # Initialize session data
#     return session_id
# end

# function getSessionData(session_id)
#     return get(SESSIONS, session_id, Dict())
# end

# function handleRequest(request::HTTP.Request)
#     cookies = HTTP.Cookies(request)
#     session_id = get(cookies, "session_id", createSession())

#     session_data = getSessionData(session_id)

#     # handle the request and update session_data
#     if req.method == "POST"
#         @info "This is a post request"
#         @info req.body
#     else if req.method == "GET"
#         @info "This is a get request"
#         @info req.body
#     end

#     response_body = Mustache.render(template, session_data)
#     response = HTTP.Response(200, response_body)

#     # Set the session_id cookie in the response
#     HTTP.setcookie!(response, "session_id", string(session_id))

#     return response
# end

# Function to handle login and set session
# @get "/login" function(req::HTTP.Request)
#     @info "ON LOGIN PAGE"
#     form_data = queryparams(req)

#     @info form_data

#     # get the variables from user input sections of the HTML
#     email = get(form_data, "email", "")
#     password = get(form_data, "password", "")

#     @info "Email: " * email
#     @info email

#     rawJSON = JSON.parsefile("db.json"; use_mmap = false) # read JSON file

#     loc = 1 # create location variable
#     found = false # set found to false as default
    
#     # encrypt the data
#     email_encrypted = encrypt_decrypt(email, key)
#     password_encrypted = encrypt_decrypt(password, key)

#     @info "Encrypted Email: " * email_encrypted

#     if email != "" && password != "" # prevent blank value being processed when page is first loaded
#         for obj in rawJSON # loop through each object in the JSON database
#             if obj["email"] == email_encrypted # check if the email is equal to the email in the current JSON object
#                 found = true # if it's the same, set found to true end exit the loop
#                 break
#             loc += 1 # increment the location if a match is not found
#             end
#         end
    
#         if found # if an email match is found, do the following
#             @info "EMAIL FOUND"
#             if password_encrypted == rawJSON[loc]["password"] # check if password matches
#                 @info "PASSWORD MATCH"
#                 # Generate a new session ID and store the user ID in the session
#                 session_id = generateSessionId()
#                 @info "SESSION ID: " * session_id
#                 @info "USER ID: " * rawJSON[loc]["id"]
#                 session[session_id] = rawJSON[loc]["id"]
                
#                 # Set a cookie with the session ID in the response
#                 response = renderHTML("index.html", "style.css", "carousel.js")
#                 response.headers["Set-Cookie"] = "session_id=$session_id; Path=/"
#                 @info "RESPONSE HEADERS: " * response.headers
#                 return response
#             else # otherwise, load the error message page
#                 context = Dict("error_message" => "Either the Email/Password you put was wrong. Go back and try again!")
#                 return renderHTML("error_template.html", "style.css", "", context)
#             end
#         else # if an email match is not found, load the error message page
#             context = Dict("error_message" => "Either the Email/Password you put was wrong. Go back and try again!")
#             return renderHTML("error_template.html", "style.css", "", context)
#         end
#     else
#         @info "There's been a serious error"
#     end

#     # Render the login HTML page and pass in the Dict object with necessary data
#     return renderHTML("login.html", "style.css", "")
# end

# @get "/" function(req::HTTP.Request)
#     cookie_header = findfirst(h -> h[1] == "Cookie", req.headers)  # Find "Cookie" header

#     @info cookie_header

#     session_id = ""

#     if isnothing(cookie_header) || isempty(cookie_header)
#         session_id = ""
#     else 
#         session_id = cookie_header[2]
#     end  # Extract value or default to ""

#     if isValidSession(session_id)  # Check for valid session
#         user_id = getUserIdFromSession(session_id)
#         context = Dict("hyperelastic_models" => getHyperelasticModels(), "user_id" => user_id)
#         return renderHTML("index.html", "style.css", "carousel.js", context)
#     else  # Redirect to login page if session is invalid
#         return renderHTML("login.html", "style.css", "")
#     end
# end

# @post "/getModel" function(req::HTTP.Request)
#     json_str = match(r"\{.*\}", String(req.body)).match # extract JSON string from request body
#     json_data = JSON.parse(json_str) # parse JSON string to Julia object
#     selection = json_data["selection"]  # access the "selection" field

#     getModelParams(selection)
# end

# function getModelParams(model::String)
#     model = getfield(Hyperelastics, Symbol(model))
#     params = parameters(model())
#     @info JSON.json(Dict("params" => params))
#     return JSON.json(Dict("params" => params))
# end

# gets the user's selection of the optimizer for use in the server side functions
# @post "/getOptimizer" function (req::HTTP.Request)
#     @info JSON.json(req.body)
#     return JSON.json(req.body)
# end

serve(port = 8001)