/*==================================================================================================================================

    Global Variables

=================================================================================================================================*/

const TRACK = document.querySelector('.carousel__track');
const SLIDES = Array.from(TRACK.children);
const NEXT_BUTTON = document.querySelector('.carousel__button--right');
const PREV_BUTTON = document.querySelector('.carousel__button--left');
const flowNav = document.querySelector('.carousel__nav');
const bubbles = Array.from(flowNav.children);
const SLIDE_WIDTH = SLIDES[0].getBoundingClientRect().width;

// Hyperelastics Data Object
var HMTData = {
    verificationData: {
        x: [],
        y: []
    },
    stressLabel: "Nominal Stress [kgf/cm^2]",
    model: "",
    parameters: [],
    lowerBounds: [],
    upperBounds: [],
    userValues: [],
    optimizer: "",
    optimizedValues: [],
    optimizedData: {
        x: [],
        y: []
    }
}

/*==================================================================================================================================

    CAROUSEL VARIABLES AND FUNCTIONS

=================================================================================================================================*/

// arranges the slides next to one another
const SET_SLIDE_POSITION = (slide, index) => {
    slide.style.left = SLIDE_WIDTH * index + 'px';
}

SLIDES.forEach(SET_SLIDE_POSITION); // calls above function for each slide putting them in place next to one another on the track

// moves the current slide to the target slide with the right arguments
const MOVE_TO_SLIDE = (TRACK, CURRENT_SLIDE, TARGET_SLIDE) => {
    TRACK.style.transform = 'translateX(-' + TARGET_SLIDE.style.left + ')'; // accesses the style property of the track to translate it horizontally so the target slide is in view of container 
    console.log(TARGET_SLIDE.style.left)
    CURRENT_SLIDE.classList.remove('current-slide'); // removes class from current slide 
    TARGET_SLIDE.classList.add('current-slide'); // adds 'current-slide' class to target slide
}

// move slides to the left when the next button is clicked
NEXT_BUTTON.addEventListener('click', e => {
    const CURRENT_SLIDE = TRACK.querySelector('.current-slide'); // makes a variable for the current slide by selecting the slide with class 'current-slide' from index.html
    const NEXT_SLIDE = CURRENT_SLIDE.nextElementSibling; // makes a variable for the next slide by selecting the next sibling of the current slide
    MOVE_TO_SLIDE(TRACK, CURRENT_SLIDE, NEXT_SLIDE); // calls the function that actually moves the slides and passes in these new assigned variables

    var currentBubble = flowNav.querySelector('.current_slide');  // makes a variable for the indicator bubble that has the class 'current_slide'
    currentBubble.classList.remove('current_slide'); // removes 'current_slide' indicator from this bubble

    currentBubble = currentBubble.nextElementSibling // assigns the current bubble to the next sibling of currentBubble

    while (!currentBubble.classList.contains('carousel__indicator')) {
        currentBubble = currentBubble.nextElementSibling;
    }

    currentBubble.classList.add('current_slide');
})

// move slides to the right when the previous button is clicked
PREV_BUTTON.addEventListener('click', e => {
    const CURRENT_SLIDE = TRACK.querySelector('.current-slide'); // makes a variable for the current slide by selecting the slide with class 'current-slide' from index.html
    const PREV_SLIDE = CURRENT_SLIDE.previousElementSibling; // makes a variable for the previous slide by selecting the previous sibling of the current slide

    MOVE_TO_SLIDE(TRACK, CURRENT_SLIDE, PREV_SLIDE); // calls the function that actually moves the slides and passes in these new assigned variables

    var currentBubble = flowNav.querySelector('.current_slide'); // makes a variable for the indicator bubble that has the class 'current_slide'
    currentBubble.classList.remove('current_slide'); // removes 'current_slide' indicator from this bubble

    currentBubble = currentBubble.previousElementSibling // assigns the current bubble to the next sibling of currentBubble

    while (!currentBubble.classList.contains('carousel__indicator')) {
        currentBubble = currentBubble.previousElementSibling;
    }

    currentBubble.classList.add('current_slide');
})

/*==================================================================================================================================

    API Variables and Functions

=================================================================================================================================*/

const dropdowns = document.querySelectorAll('.dropdown'); // gets the dropdowns

// loop through all dropdown elements
dropdowns.forEach(dropdown => {
    // get inner elements from each dropdown
    const select = dropdown.querySelector('.select');
    const caret = dropdown.querySelector('.caret');
    const menu = dropdown.querySelector('.menu');
    const options = dropdown.querySelectorAll('.menu li');
    const selected = dropdown.querySelector('.selected');

    // modify styles when the dropdown is clicked
    select.addEventListener('click', () => {
        select.classList.toggle('select-clicked'); // add the clicked select styles to the select element
        caret.classList.toggle('caret-rotate'); // add the rotate styles to the caret element
        menu.classList.toggle('menu-open'); // add the open styles to the menu element
    });

    // loop through all option elements
    options.forEach(option => {

        option.addEventListener('click', () => {
            selected.innerText = option.innerText; // change selected inner text to clicked option for inner text
            select.classList.remove('select-clicked'); // add the clicked seleted styles to the select element
            caret.classList.remove('caret-rotate'); // add the rotate styles to the caret element
            menu.classList.remove('menu-open'); // add the open styles to the menu element

            // remove active class from all option elements
            options.forEach(option => {
                option.classList.remove('active');
            });

            option.classList.add('active'); // add active class to clicked option element

            if (selected.id == "stress_label") {
                console.log("STRESS LABEL CLICKED");
                console.log(selected);
                console.log(selected.id);
                HMTData.stressLabel = "Nominal Stress [" + option.innerHTML + "]" // sets the HMTData stress label variable to the selected stress label
                updateGraph(); // updates the graph to reflect stress label change
            } else if (selected.id == "stretch_col") {
                updateGraph(); // updates the graph to reflect change
            } else if (selected.id == "stress_col") {
                updateGraph(); // updates the graph to reflect change
            } else if (selected.id == "hyperelastic-model") {
                HMTData.model = selected.innerText; // gets the selected model

                // makes sure there is data in the csv file
                if (VERIFICATION_PLOT_GRAPH.data.datasets[0].data.length > 0) {

                    // fetch function for getting the parameters and user input boxes
                    fetch('/getModelParams/' + HMTData.model)
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }
                        return response.json();
                    })
                    .then(data => {
                        // create variables
                        var paramString = "";
                        var paramString2 = "";
                        var paramString3 = "";
                        var valueInput = "";

                        HMTData.parameters = []; // reset parameters array

                        // loop however many parameters there are
                        for (i = 0; i < data.params.length; i++) {
                            HMTData.parameters.push(data.params[i]); // add the parameter the the HMTData object

                            paramString += "<li class='math'>$$ " + data.params[i] + " $$</li>"; // create a string of parameters in HTML format for display on page 2
                            paramString2 += "<p class='param-spread' " + "id='param" + i + "'>$$ " + data.params[i] + " $$</p>"; // create a string of parameters in HTML format for display on page 3
                            paramString3 += "<p id='final-param' class='paramValues'>$$ " + data.params[i] + " $$</p>"; // create a string of parameters in HTML format for display on page 4
                            valueInput += "<input type='text' id='value" + i + "' name='value" + i + "'></input>"; // create input boxes for each parameter
                        }

                        // set the inner HTML of each section to the strings created above
                        document.getElementById("paramBox").innerHTML = paramString;
                        document.getElementById("paramBox2").innerHTML = paramString2;
                        document.getElementById("final-param-container").innerHTML = paramString3;
                        document.getElementById("valueBox").innerHTML = valueInput;

                        MathJax.typeset(); // load mathematical formatting
                    })
                    .catch(error => {
                        console.error('There was a problem with the fetch operation:', error);
                    });

                    //fetch function for getting the upper and lower bounds
                    fetch('/getBounds/' + HMTData.model + '/uniaxial')
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }
                        return response.clone().json();
                    })
                    .then(data => {
                        // create variables
                        var upperBoundsString = "";
                        var lowerBoundsString = "";
                        var lb_iterator = 0;
                        var ub_iterator = 0;

                        // reset lower and upper bounds arrays
                        HMTData.lowerBounds = [];
                        HMTData.upperBounds = [];

                        // loop through the upper and lower bounds
                        for (let key in data) {
                            // loop through the actual bounds in each lower and upper section
                            for (let innerKey in data[key]) {
                                if (key == "lb") {
                                    HMTData.lowerBounds.push(data[key][innerKey]); // add values to lower bounds array

                                    lowerBoundsString += "<p class='param-spread' id='lb" + lb_iterator + "'>" + data[key][innerKey] + "</p>"; // create HTML string for lower bounds
                                    lb_iterator++; // increment the iterator
                                } else if (key == "ub") {
                                    HMTData.upperBounds.push(data[key][innerKey]); // add values to upper bounds array

                                    upperBoundsString += "<p class='param-spread' id='ub" + ub_iterator + "'>" + data[key][innerKey] + "</p>"; // create HTML string for upper bounds
                                    ub_iterator++; // increment the iteraror
                                }
                            }
                        }

                        // set the inner HTML of each section to the strings created above
                        document.getElementById("lowerBoundsBox").innerHTML = lowerBoundsString;
                        document.getElementById("upperBoundsBox").innerHTML = upperBoundsString;
                    })
                    .catch(error => {
                        console.error('There was a problem with the fetch operation:', error);
                    });

                    // fetch function for getting the model doc string (model equation, arguments, and info)
                    fetch('/getModelDocString/' + HMTData.model)
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }
                        return response.clone().json();
                    })
                    .then(data => {
                        let arguments_string_split = convertToHTMLList(data.arguments_string); // converts arguments string to HTML for displaying to the screen

                        // enclose everything surrounded by ` with <p> tags so they can be formatted as code
                        let arguments_string_code = arguments_string_split.replace(/`(.*?)`/g, function (match, p1) {
                            return "<p class='code'>" + p1 + "</p>";
                        });

                        // set the inner HTML of each section to the strings created above
                        document.getElementById("textbubble").innerHTML = data.model_info_string;
                        document.getElementById("modelBox").innerHTML = data.model_string;
                        document.getElementById("argumentBox").innerHTML = arguments_string_code;

                        MathJax.typeset(); // load math formatting
                    })
                    .catch(error => {
                        console.error('There was a problem with the fetch operation:', error);
                    });
                } else {
                    window.alert("Please upload CSV test data first");
                }
            }
        });
    });
});

// copy of above code except fo this is for the parameter dropdown because this is the only way it works
const paramdropdowns = document.querySelectorAll('.param_dropdown');

// loop through all parameter dropdown elements
paramdropdowns.forEach(param_dropdown => {
    // get inner elements from each dropdown
    const select = param_dropdown.querySelector('.select');
    const caret = param_dropdown.querySelector('.caret');
    const menu = param_dropdown.querySelector('.menu');
    const options = param_dropdown.querySelectorAll('.menu li');
    const selected = param_dropdown.querySelector('.selected');

    // add a click event to the select element
    select.addEventListener('click', () => {
        select.classList.toggle('select-clicked'); // add the clicked select styles to the select element
        caret.classList.toggle('caret-rotate'); // add the rotate styles to the caret element
        menu.classList.toggle('menu-open'); // add the open styles to the menu element
    });

    // loop through all option elements
    options.forEach(option => {

        option.addEventListener('click', () => {
            selected.innerText = option.innerText; // change selected inner text to clicked option for inner text
            select.classList.remove('select-clicked'); // add the clicked seleted styles to the select element
            caret.classList.remove('caret-rotate'); // add the rotate styles to the caret element
            menu.classList.remove('menu-open'); // add the open styles to the menu element

            // remove active class from all option elements
            options.forEach(option => {
                option.classList.remove('active');
            });

            option.classList.add('active'); // add active class to clicked option element
        });
    });
});

// gets everything necessary to display lower bounds, upper bounds, selected optimizer, user values, and optimized values
function getParamGuesses() {
    HMTData.userValues = []; // resets the userValues array
    var initial_guess_errors = false; // sets the error boolean to false
    var i = 0; // creates the iterator

    HMTData.optimizer = document.getElementById("optimizer").innerText; // gets the selected optimizer

    // only proceeds if the user has selected an optimizer
    if (optimizer === "Select Optimizer") {
        window.alert("Please select and optimizer");
    } else {
        // loop until there are no more input fields with IDs 'value' + i
        while (true) {
            var initial_guess_id = 'value' + i; // gets the HTML ID of the initial guess
            var initial_guess = document.getElementById(initial_guess_id) // gets the HTML element associated with that ID

            // makes sure initial guess isn't null
            if (initial_guess) {
                HMTData.userValues.push(initial_guess.value); // adds the value of the initial guess input box to the array
                i++; // increments i for creating the next ID
            } else {
                break;
            }
        }

        // makes sure there are no missing values (indicated by extra commas at the end of the array strintg)
        if (checkForErrors(HMTData.userValues.join(','))) {
            window.alert("Please fill in all value fields");
        } else {
            initial_guess_errors = false; // no errors

            // loops through each lower and upper bound
            for (i = 0; i < HMTData.lowerBounds.length; i++) {
                var lbTemp = HMTData.lowerBounds[i]; // temporary lower bound variable
                var ubTemp = HMTData.upperBounds[i]; // temporary upper bound variable

                // converts Inf and -Inf to javascript Infinity and -Infinity values
                if (lbTemp == "Inf") {
                    lbTemp = Infinity;
                } else if (lbTemp == "-Inf") {
                    lbTemp = -Infinity;
                } else {
                    lbTemp = Number(lbTemp);
                }

                if (ubTemp == "Inf") {
                    ubTemp = Infinity;
                } else if (ubTemp == "-Inf") {
                    ubTemp = -Infinity;
                } else {
                    ubTemp = Number(ubTemp);
                }

                // checks if user input is lower than the lower bound
                if (lbTemp > Number(HMTData.userValues[i])) {
                    window.alert(Number(HMTData.userValues[i]) + " is not greater than " + lbTemp);
                    initial_guess_errors = true;
                }

                // checks if user input is higher than the upper bound
                if (ubTemp < Number(HMTData.userValues[i])) {
                    window.alert(Number(HMTData.userValues[i]) + " is not less than " + ubTemp);
                    initial_guess_errors = true;
                }
            }

            // this only gets executed if there are no errors
            if (!initial_guess_errors) {
                var finalUserValuesBoxText = "" // creates the variable that will hold the HTML string

                // loops through each value and adds the HTML version to the string
                for (var i in HMTData.userValues) {
                    finalUserValuesBoxText += "<p class ='datavalues'>" + HMTData.userValues[i] + "</p>";
                }

                document.getElementById('final-user').innerHTML = finalUserValuesBoxText; // displays the HTML string to the screen

                // creates the optimizeModel API URL
                var url = '/optimizeModel/' + HMTData.model + '/uniaxial/' + HMTData.optimizer + '/' + HMTData.userValues.join(',') + '/' + HMTData.parameters.join(',');

                // fetch function for getting the optimized model values
                fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(async data => { // async function to make sure all of this gets executed before the next fetch function
                    var optimizedValueBoxText = "" // creates the variable that will hold the HTML string

                    // loops through each value and adds the HTML version to the string and updates the HMTData array
                    for (var i in HMTData.userValues) {
                        optimizedValueBoxText += "<p class ='datavalues'>" + Object.values(data)[i] + '</p>';
                        HMTData.optimizedValues[i] = Object.values(data)[i];
                    }

                    document.getElementById('final-optimized').innerHTML = optimizedValueBoxText; // displays the HTML string to the screen

                    // creates the finalGraphData API URL
                    var url = '/finalGraphData/' + HMTData.model + '/' + HMTData.parameters.join(',');

                    // attempts to fetch this api only if the previous one is finished
                    try {
                        const response = await fetch(url); // fetches the data from the api
                        const data_2 = await response.text(); // gets the response
                        graphData = JSON.parse(data_2); // parses the data

                        // adds the x and y data for the final graph to the HMTData object
                        HMTData.optimizedData.x = graphData.x;
                        HMTData.optimizedData.y = graphData.y;

                        updateGraph(); // call function to create graph with parsed data
                    } catch (error) {
                        console.error('Error fetching or parsing final graph data: ', error);
                    }
                })
                .catch(error => {
                    console.error('There was a problem with the fetch operation: ', error);
                });
            }
        }
    }
}

/*==================================================================================================================================

    Graph Objects and Functions

=================================================================================================================================*/

const fileInput = document.getElementById("fileInput");
const csvUpload = document.getElementById("csvUpload");

// sends the file to the Julia backend whenever the upload button is clicked
csvUpload.addEventListener('submit', (event) => {
    console.log("uploading file");
    fetch(csvUpload.action, {
        method: 'POST',
        body: new FormData(csvUpload)
    });
    event.preventDefault();

    window.alert("File uploaded successfully");
})

// calls the readSingleFile function whenever a new file is uploaded
fileInput.addEventListener('change', (event) => {
    if (event.target.files && event.target.files[0]) {
        readSingleFile(URL.createObjectURL(event.target.files[0]));
    }
});

// reads the data from the CSV file and converts it to x and y arrays for use when creating the graphs
function readSingleFile(url) {
    // resets the arrays so new data replaces old data rather than appending to it
    HMTData.verificationData.x = [];
    HMTData.verificationData.y = [];

    fetch(url)
        .then(response => response.text())
        .then(data => {
            const parsedData = Papa.parse(data, { header: true }).data; // Parse CSV data

            // loop through and add each data point to the correct arrays
            for (var i = 0; i < parsedData.length; i++) {
                HMTData.verificationData.x.push(Number(parsedData[i].Stretch));
                HMTData.verificationData.y.push(Number(parsedData[i].Stress));
            }

            updateGraph(); // call function to create graph with parsed data
        })
        .catch(error => {
            console.error('Error fetching or parsing CSV data:', error);
        });
}

// initial graph
const ctx = document.getElementById('chart');

// creates the verification plot graph
const VERIFICATION_PLOT_GRAPH = new Chart(ctx, {
    type: 'scatter',
    data: {
        datasets: [{
            label: 'Experimental',
            data: HMTData.verificationData.x.map((value, index) => ({ x: value, y: HMTData.verificationData.y[index] })),
            borderWidth: 1,
            pointRadius: 3,
            pointHoverRadius: 5
        }]
    },
    options: {
        responsive: true,
        scales: {
            x: {
                type: 'linear',
                position: 'bottom',
                title: {
                    display: true,
                    align: 'center',
                    text: 'Stretch'
                }
            },
            y: {
                type: 'linear',
                position: 'left',
                title: {
                    display: true,
                    align: 'center',
                    text: HMTData.stressLabel
                }
            }
        }
    },
    plugins: [chartAreaBackgroundColor = {
        id: 'chartAreaBackgroundColor',
        beforeDraw(chart) {
            const ctx = chart.canvas.getContext('2d');
            ctx.save();
            ctx.globalCompositeOperation = 'destination-over';
            ctx.fillStyle = '#f0f0f0';
            ctx.fillRect(0, 0, chart.canvas.width, chart.canvas.height);
            ctx.restore();
        }
    }]
});

// final graph
const ctxFinal = document.getElementById('chartFinal');

// creates the final graph
const FINAL_PLOT_GRAPH = new Chart(ctxFinal, {
    data: {
        datasets: [{
            type: 'scatter',
            label: 'Experimental',
            data: HMTData.verificationData.x.map((value, index) => ({ x: value, y: HMTData.verificationData.y[index] })),
            borderWidth: 1,
            pointRadius: 3,
            pointHoverRadius: 5
        }, {
            type: 'line',
            label: 'Optimized',
            data: HMTData.optimizedData.x.map((value, index) => ({ x: value, y: HMTData.optimizedData.y[index] })),
            borderWidth: 1,
            pointRadius: 3,
            pointHoverRadius: 5
        }]
    },
    options: {
        responsive: true,
        scales: {
            x: {
                type: 'linear',
                position: 'bottom',
                title: {
                    display: true,
                    align: 'center',
                    text: 'Stretch'
                }
            },
            y: {
                type: 'linear',
                position: 'left',
                title: {
                    display: true,
                    align: 'center',
                    text: HMTData.stressLabel
                }
            }
        }
    },
    plugins: [chartAreaBackgroundColor = {
        id: 'chartAreaBackgroundColor',
        beforeDraw(chart) {
            const ctxFinal = chart.canvas.getContext('2d');
            ctxFinal.save();
            ctxFinal.globalCompositeOperation = 'destination-over';
            ctxFinal.fillStyle = '#f0f0f0';
            ctxFinal.fillRect(0, 0, chart.canvas.width, chart.canvas.height);
            ctxFinal.restore();
        }
    }]
});

// update graph function
function updateGraph() {
    newXData = HMTData.verificationData.x;
    newYData = HMTData.verificationData.y;

    const stressCol = document.getElementById('stress_col');
    const stretchCol = document.getElementById('stretch_col');

    // modify the data if stress and stretch dropdowns both have the same value
    if (stressCol.innerText == stretchCol.innerText) {
        if (stressCol.innerText == "Stretch") {
            newXData = newYData;
        } else {
            newYData = newXData;
        }

    // modify the data if the stretch and stress dropdowns have opposite values
    } else if (stressCol.innerText == "Stretch" && stretchCol.innerText == "Stress") {
        tempData = newXData;

        newXData = newYData;
        newYData = tempData;
    }

    // update the data and the labels
    VERIFICATION_PLOT_GRAPH.data.datasets[0].data = newXData.map((value, index) => ({ x: value, y: newYData[index] }))
    VERIFICATION_PLOT_GRAPH.options.scales.y.title.text = HMTData.stressLabel;
    VERIFICATION_PLOT_GRAPH.update();

    FINAL_PLOT_GRAPH.options.scales.y.title.text = HMTData.stressLabel;

    // only update the final graph if it has data
    if (HMTData.optimizedData.x != '') {
        FINAL_PLOT_GRAPH.data.datasets[0].data = newXData.map((value, index) => ({ x: value, y: newYData[index] }))
        FINAL_PLOT_GRAPH.data.datasets[1].data = HMTData.optimizedData.x.map((value, index) => ({ x: value, y: HMTData.optimizedData.y[index] }))
        FINAL_PLOT_GRAPH.update();
    }
}

/*==================================================================================================================================

    HELPER FUNCTIONS

=================================================================================================================================*/

// creates a link to the graph with allows it to be downloaded as a png
function downloadChart(chartId) {
    const imageLink = document.createElement('a');
    const canvas = document.getElementById(chartId);

    imageLink.download = 'hyperChart.png';
    imageLink.href = canvas.toDataURL('image/png', 1);

    imageLink.click();
}

// if there are multiple comments at the end of the string, then something went wrong. In this case, return true to indicate an error.
// otherwise, return false
function checkForErrors(arrayString) {
    if (arrayString.endsWith(",")) {
        return true;
    } else {
        return false;
    }
}

// argument string from the Hyperelastics function has markdown formatting. THis function converts the markdown bullet points to HTML list items
function convertToHTMLList(str) {
    var items = str.split("*"); // split the string at every occurrence of "*"

    // remove the first empty item if present
    if (items[0] === '   ') {
        items.shift();
    }

    // iterate through the items and wrap each in <li> tags
    var htmlList = items.map(function (item) {
        return "<li class='argument-item'>" + item.trim() + "</li>";
    });

    return htmlList.join(""); // join the items to form a single string and return it
}

// loads MathJax to allow mathematical formatting
window.onload = function () {
    MathJax.typeset();
}

// search functionality for model dropdown
var input = document.getElementById("modelSearch"); // gets the model dropdown HTML element

// runs the search every time a character is input
input.addEventListener("input", function() {
    var filter = input.value.toUpperCase();
    var ul = document.getElementById("modelmenu");
    var li = ul.getElementsByTagName("li");

    // loop through all list items, and hide those who don't match the search query
    for (var i = 0; i < li.length; i++) {
        var model = li[i].textContent || li[i].innerText;
        if (model.toUpperCase().indexOf(filter) > -1) {
            li[i].style.display = "";
        } else {
            li[i].style.display = "none";
        }
    }
});