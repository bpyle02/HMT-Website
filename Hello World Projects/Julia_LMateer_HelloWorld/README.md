# HMT-Web-Frontend
 This is the frontend web application built for Vagus LLC's Hyperelastic Modeling Tool

## Setup
1. Clone the repository
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
    5. Type `add Oxygen HTTP Mustache`
    6. Press backspace and type `exit()` to exit Julia
4. Start the Web Server
    1. From the project directory, type `julia --project app.jl`
