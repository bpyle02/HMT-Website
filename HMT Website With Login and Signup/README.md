# Julia HMT Website
## Table Of Contents
1. Setup
2. Code Explanation
3. Files
   * 3.1 CSS
     - 3.1.1 style.css
   * 3.2 HTML
     - 3.2.1 error_template.html
     - 3.2.2 index.html
     - 3.2.3 login.html
     - 3.2.4 popup_template.html
     - 3.2.5 resetPass.html
     - 3.2.6 sendResetEmail.html
     - 3.2.7 signup.html
   * 3.3 JS
     - 3.3.1 carousel.js
   * 3.4 JL
     - 3.4.1 app.jl
     - 3.4.2 decrypt.jl
   * 3.5 JSON
     - 3.5.1 db.json
   * 3.6 uploads
4. Notes
######
______________________________________________
# 1. Setup
1. Download the files and make a note of the path to it
2. Install Julia
    1. Linux
        1. Type the command `sudo snap install julia --classic`
        2. Type `julia` to test if it is working
    2. Windows
        1. Download the installer from [this link](https://julialang.org/downloads/)
        2. Run the installer. Make sure to check add Julia to PATH
        3. Double click the .exe file to test if it is working
3. Set up the project
    1. Navigate to the project directory using the terminal
    2. Type the command `julia`
    3. Type `]` to enter package mode
    4. Type `activate .` to activate the current directory and apply package installations to it
    5. Type `add Oxygen HTTP Mustache JSON`
    6. Press backspace and type `exit()` to exit Julia
4. Start the Web Server
    1. From the project directory, type `julia --project app.jl`
 ______________________________________ 
# 2. Code Explanation
The provided code is the comprehensive HMT Website Julia code. The documentation can be found below. 
_____________________________________
# 3. Files
The HMT Website contains 11 files of code. The descriptions of each file and its functions are provided.
_____________________________________
## 3.1 CSS Files
The following file contains the CSS code for the HMT Website
## 3.1.1 style.css
This file contains all the stylization for the HMT Website
### Functions
This CSS code sets the colour and placement for the comprehensive HMT Website
#### `Colour Palette`
This code contains the colour palette used within the Website
#### `Stylization`
This portion of the CSS file contains the general styling for the body, fonts, buttons, labels, inputs and background of the Website. It sets the colour, fonts and sizes for all visuals.
#### `Graph Area`
This section of the code creates a box for the area where the graph is displayed.
#### `Dropdown Styling`
The code styles the dropdown menus for the parameters and graph with specific colours, sizing and fonts. 
#### `Information Bubble`
This code sets the style for the Informational Bubble the user can hover over, for more information/helpful hints. It also configures the information visualization. 
#### `Carousel` 
This section of the code sets the stylization for the Carousel portion of the Webpage. It sets the sizing, colour, and positioning. 
#### `Arrow Navigation`
This code sets the style of the left and right buttons for navigating the carousel. If sets the sizing, colour, positioning, and alignment.
#### `Carousel Indicator`
This section of the code sets the visuals for the tool indicator flow chart at the bottom of the page. It configures the colour, alignment, sizing, font, and positioning. 
#### `Alignment`
This bit of code sets the parameters for the alignment of inlabel items and vertical alignment. 
#### `Login` 
This section of the code sets the styling for the Login page. It sets the colour, text data, alignment, and background colour. 
#### `Signup` 
This portion of the code sets the designs for the Signup page. It sets the alignment, colour and font size. 
#### `Input` 
This section of the code sets the styles for the input container. It sets the sizing and alignment.
#### `Navigation Bar` 
This section of the code sets the stylization for the Navigation bar. It sets the parameters for the colour, alignment, sizing and positioning.
#### `Parameters` 
This part of the code sets the styles for the Parameter Container. It defines the sizing, alignment, font, colour and orientation. 
_______________________________________
## 3.2 HTML Files
The following files contain the HTML code for the HMT Website
## 3.2.1 error_template.html
This file contains a simple error message
## 3.2.2 index.html
This file contains the functions that define the web page structure. 
### Functions
This file contains the functions for setting up the main webpage, which contains the graph data.  
#### `Tags, Titles and External Resources`
The first segment is providing the metadata and title information for the webpage. It also contains the external resources, with links to external resources, such as fonts, libraries and charting. 
#### `Navigation Bar`
This function contains the navigation bar, which includes sections such as Home, Login, Reset Password, Sign Up and Email Reset.
#### `Carousel`
This segment contains the main webpage content.
It sets up the navigation and includes the graph, columns, menu, buttons, dropdown, files, stretch and stress. It sets the code for selecting a model, setting parameters, and displaus the final parameters with an option to download the chart. 

## 3.2.3 login.html
This file contains the functions for the login page
### Functions
#### `Tags, Titles and External Resources`
The first segment is providing the metadata and title information for the webpage. It also contains the external resources, with links to external resources, such as fonts, libraries and charting.
#### `Login Page`
This function contains the navigation bar, which includes sections such as Home, Login, Reset Password, Sign Up and Email Reset.  
#### `Sign Up Page`
This function contains the set up for the Sign Up page. 
#### `Login Form`
This function configures the login form. This sets up the input for the email and password. It also ensures that the appropriate message for sending an email in the instance a password is forgotten. 
## 3.2.4 popup_template.html
This file contains the code for a popup display
### Functions
#### `Popup`
This function contains the code for configuring a popup using JavaScript 
## 3.2.5 resetPass.html
The file contains the code for resetting a password  
### Functions
#### `Tags, Titles and External Resources`
The first segment is providing the metadata and title information for the webpage. It also contains the external resources, with links to external resources, such as fonts, libraries and charting.
#### `Login Page`
This function contains the navigation bar, which includes sections such as Home, Login, Reset Password, Sign Up and Email Reset. 
#### `Selection`
This function sets up the various selections the user can make, including a reset password choice.
#### `New Password`
This section provides the user with the choice to make a new password
#### `Repeat Password`
This section of the code ensures the password is input correctly for a second time, then submits the result. 
## 3.2.6 sendResetEmail.html
This file contains the code for sending a `Reset Password` email.
### Functions
#### `Tags, Titles and External Resources`
The first segment is providing the metadata and title information for the webpage. It also contains the external resources, with links to external resources, such as fonts, libraries and charting.
#### `Send Mail`
This function takes the email ID and sends the email to the user upon the user selecting the submit button. 
#### `Initialization` 
This function initializes the EmailJS code with a public key. This key is utilized to authenticate the communication between the client-side code and the EmailJS service conducted. 
#### `Login Page`
This function contains the navigation bar, which includes sections such as Home, Login, Reset Password, Sign Up and Email Reset.  
#### `Reset Password Form`
This function contains the code for setting up the header, entering the email for the reset link message, the `Remember Your Password` link, and the Reset Password Form. This form includes an Email input and a Submit button, which triggers the `sendMail()` function.
## 3.2.7 signup.html
This file contains the code for Signing Up for the website. 
### Functions
#### `Tags, Titles and External Resources`
The first segment is providing the metadata and title information for the webpage. It also contains the external resources, with links to external resources, such as fonts, libraries and charting.
#### `Login Page`
This function contains the navigation bar, which includes sections such as Home, Login, Reset Password, Sign Up and Email Reset. 
#### `Signup`
This function contains the code for inputting the new user information. It takes the First Name, Last Name, Email, Password, Status - Undergrad Student, Graduate Student, Employer, Employee. The next snippet of code then requires the user to select submit and log in. 
#### `Redirection`
This portion of the file navigates the browser to the specified URL, returning to the log in page. 
______________________________________
# 3.3 JS File
The following files contain the JS code for the HMT Website
## 3.3.1 carousel.js
This file is responsible for handling user interactions, managing data, updating the interface, and performing operations related to the HMT graph.
### Functions
#### `const SET_SLIDE_POSITION = (slide, index) =>`
This function arranges the slide, and sets them side-by-side.
#### `const MOVE_TO_SLIDE = (TRACK, CURRENT_SLIDE, TARGET_SLIDE) =>`
This function tracks the slide, and permits the flow of slides. When the user clicks 'left', it moves the slides to the left. 
#### `NEXT_BUTTON.addEventListener('click', e => `
This function is responsible for the 'next' button, which manipulates the slides.
#### `PREV_BUTTON.addEventListener('click', e =>`
This function is responsible for the 'previous' button, which manipulates the slides. When clicked right, it moves the slides to the right. When a specific navigation indicator is selected, it will move to that slide. 
#### `dropdowns.forEach(dropdown =>`
This function loops through all the dropdown elements. It is responsible for the following:
- Select
- Caret
- Menu
- Options
- Selected
  ####
This method ensures that multiple dropdowns can be utilized. 
This function also ensures that there is a click event to select the appropriate element. 
#### `options.forEach(option =>`
This function loops through all option elements. It adds styles to the select elements and removes active class from all option elements.
It also updates the graph options, such as the `stress label`, `stretch column`, and `stress column`. 
#### `csvUpload.addEventListener('submit', (event) =>`
This function retrieves the the appropriate .CSV file and uploads it. 
#### `fileInput.addEventListener('change', (event) =>`
This function permits the input of the .CSV file. 
#### `readSingleFile(url)`
This function reads the .CSV file and displays it to the screen. It ensures that the file is uploaded successfully, and permits the manipulation of the graph to be performed on the data. It then updates the graph. If there is an error retrieving the file, it will return an error message. 
#### `VERIFICATION_PLOT_GRAPH = new Chart`
This function writes the type and style of tthe graph. It also styles the visual plots of the graph. 
#### `updateGraph()`
This function updates the graph, based on the selections and the .CSV file provided. It updates the `stress column` as well as the `stretch column`.
______________________________________
# 3.4 JL File
## 3.4.1 app.jl
This file updates the database with new users' data, performs encryption and decryption, ensures that a user is logged in, ensures that there are no matches in input data, renders the HTML and uploads the .CSV file. 
### Functions
#### `generateSessionID()`
This function generates a random encoded string to use as a Session ID
#### `isValidSession(session_is::String)`
This function checks to see if a session is valid
#### `getUserIdFromSession(session_id::String)`
This function gets the User ID from a valid session
#### `lastId()`
This function grabs the last ID from the json file, `db.json`
#### `nextId()`
This function increments the ID by 1 and returns the nect ID from `db.json`
#### `checkForDuplicates(email::String)`
This function ensures that there are no duplicate emails entered in to the database. If there is a match, it will return an error message.
#### `renderHTML(htmlFile::String, cssFile::String, jsFile::String, context::Dict = Dict(); status = 200, headers = ["Content-Type" => "text/html; charset=utf-8"]) :: HTTP.Response`
This function retrieves the HTML, CSS, JavaScript and any context values, to display to the screen. It reads in the HTML, CSS, and JS files and combines them.
#### `signup(fName::String, lName::String, email::String, password::String, status::String)`
This function adds a new user's information into the JSON database, `db.json`
It encrypts the email and password, permits modification, adds the data to the array and converts the Julia array to a JSON object.
#### `encrypt_decrypt(text::String, key::String, encrypt = true)`
This function performs encryption/decryption. It loops through each symbol in the text variable and either reverses or shifts the number, appends the sybols, and returns an encoded string.
#### `getHyperelasticModels()`
This function retrieves the hyperelastic models
#### `@get "/" function(req::HTTP.Request)`
This function renders the home screen. It calls `index.html`, `style.css`, and `carousel.js`.
#### `@get "/login" function(req::HTTP.Request)`
This function renders the login page. It gets the variables from the user input sections of the HTML:
- First Name
- Last Name
- Email
- Password
####
It then encrypts the data. It also checks for duplicates and ensures that there are actual values being entered in. 
If an account has already been created with the same email, it ensures there are no duplicates and returns an error message.
#### `@get "/login" function(req::HTTP.Request)`
This function retrieved the variables from the user input sections of the HTML. It then creates a location variable and encrypts the data. It also ensures that there are no duplicates. If there is a duplicate, it returns an error message. 
#### `@get "/reset" function(req::HTTP.Request)`
This function renders the HTML
#### `@get "/sendEmail" function(req::HTTP.Request)`
This function sends an email during the login process.
#### `@post "/upload" function(req::HTTP.Request)`
This function uploads the file to the graph. It ensures the file is .CSV, and returns an error message if it is an incorrect format. Upon successful recognition, the function then adds a timestamp to the filename. It saves the file and returns the message: `"File uploaded successfully: "`.
#### `@get "/getModelDocString/{model}" function (request::HTTP.Request, model::String)`
This function sends the model, equations, arguments and model info to the client side for rendering to the user. If there is data, it is read in to the JSON database.
#### `@get "/getModelParams/{model}" function (req::HTTP.Request, model::String)`
This function sends the model parameters to the client side for rendering to the user.
#### `@post "/getParams" function (req::HTTP.Request)`
This function creates and returns a form.
#### `@get "/getBounds/{model}/{testType}" function (request::HTTP.Request, model::String, testType::String)`
This function is responsible for setting the boundaries witht he model data. It sets the boundaries for the map, and processed the combined bounds. 
#### `@get "/optimizeModel/{model}/{testType}/{optimizer}/{vals}/{parameters}" function (req::HTTP.Request, model::String, testType::String, optimizer::String, vals::String, parameters::String)`
This function curates the graph from the input of the model. 
#### `@get "/finalGraphData" function (req::HTTP.Request)`
This function sets the X and the Y values on the graph. It then sends the values to the JSON database.
## 3.4.2 decrypt.jl
This is a simple file used to decrypt an entry in the database given an ID. The user will be asked to enter an ID, and upon entering a valid ID, will be presented with the decrypted information from that entry in the database.
### Functions
#### `decrypt()`
This is a modified version of the encrypt_decrypt() function in app.jl used for only encryption
___________________________________________
## 3.5 JSON File
## 3.5.1 db.json
This file acts as the 'database' for the Website User credentials
### Functions
#### [{"first_name":"John","password":"ZyX123!","status":"Graduate Student","id":"6","last_name":"Doe","email":"JD@email.com"}]
This is the database where user data is stored. It can be expanded to include 
- First Name
- Password
- Status
- ID
- Last Name
- Email
#### To update this file, enter the new data into the specific location in the following template:
  {"first_name":" ", "password": " ","status": " ", "id": " ", "last_name": " ", "email": " "}
####  Ensure that this added user is within '[ ]' to be added to the complete database
________________________________________
# 3.6 Uploads
The uploads are .CSV files for testing the graph. Please refer to each .CSV file for further information regarding the contents, as these are subject to change.
__________________________________________
# 4. Notes
### A. Within the `IMG` folder, there are various images that have been implemented within the website. These are as follows, and can be viewed individually by double-clicking on each file: Asset 34.png, Asset 35.png, UploadVerify.png, backArrow.png, back_arrow.png, frontArrow.png, lockIcon.png, mailIcon.ong, seedata.png, textIcon.png
### B. `Manifest.toml` contains the optimizer colours - It is machine-generated.
### C. `Project.toml` contains the added API for Model Selection
________________________________________
