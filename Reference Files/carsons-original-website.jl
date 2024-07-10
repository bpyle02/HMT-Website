### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ e5a18d4c-14cd-11ed-36d5-69de0fd02830
# ╠═╡ show_logs = false
begin
	local_dir = joinpath(splitpath(@__FILE__)[1:end-1])
	import Pkg
	Pkg.activate(local_dir)
	Pkg.instantiate()
	using PlutoUI, ForwardDiff, CSV, ComponentArrays, DataFrames, Optimization, OptimizationOptimJL, InverseLangevinApproximations, LabelledArrays,HypertextLiteral, ColorSchemes, LossFunctions, AbstractPlutoDingetjes, AbstractPlutoDingetjes.Bonds
	using CairoMakie
	using Hyperelastics
end;

# ╔═╡ 73ab5774-dc3c-4759-92c4-7f7917c18cbf
HTML("""<center><h1> Hyperelastic Model <br> Fitting Toolbox</h1></center>
		<center><h2>Upload Uniaxial Test Data</h2></center>
		<center><p style="color:red;"><b>This tool is currently available for beta testing. Please provide any feedback to <i>contact@vagusllc.com</i>. By default, the data from <i>Treloar et al.</i>* is loaded. 
		</b></p>
		</center>
		<br>
		<p style="font-size:9pt">*(Treloar LR. Stress-strain data for vulcanized rubber under various types of deformation. Rubber Chemistry and Technology. 1944 Dec;17(4):813-25).</p>
		""")

# ╔═╡ f12538a9-f595-4fae-b76c-078179bc5109
HTML("""<center><h3 >Verification Plot</h3></center>""")

# ╔═╡ d0319d95-f335-48fa-b789-59daf9a0f1a4
HTML("""<center><h2 >Select Hyperelastic Model</h2></center>""")

# ╔═╡ 9343a51e-5002-4489-a55f-12c49f5b8cf3
md"""
!!! note "Note"
	- When selecting a phenomenological model, be aware that using higher order models may result in overfitting of the data.
	- All moduli in models are in the defined stress units above
	- The model selection may take a couple seconds to load.
"""

# ╔═╡ da3634ea-48d7-4d4f-a853-c631a6fa7bf4
html"""<center><h3 > Model Information</h3></center>"""

# ╔═╡ c6e726ab-ea78-4129-a662-338976633cd5
html"""<center><h2 style = "font-family:Archivo Black"> Set initial parameter guess</h2></center>"""

# ╔═╡ 7196aa51-e86d-4f0e-ae40-cc6aa74aa237
md"---"

# ╔═╡ 9e411ed3-0061-4831-b047-44c920959c83
HTML("""
<style>
	select, button, input {
   		font-size: 12px;
		font-family: "Archivo Black";
		}
	p, h2 {
		font-family: "Archivo Black";
	}
</style>""")

# ╔═╡ 36cf277a-2683-43b2-a406-7eb8a0fcac07
const toc_js = toc -> @htl """
<script>

const indent = $(toc.indent)
const aside = $(toc.aside)
const title_text = $(toc.title)
const include_definitions = $(toc.include_definitions)
const tocNode = html`<nav class="plutoui-toc">
	<header>
	 <span class="toc-toggle open-toc"></span>
	 <span class="toc-toggle closed-toc"></span>
	 \${title_text}
	</header>
	<section></section>
</nav>`
tocNode.classList.toggle("aside", aside)
tocNode.classList.toggle("indent", indent)
const getParentCell = el => el.closest("pluto-cell")
const getHeaders = () => {
	const depth = Math.max(1, Math.min(6, $(toc.depth))) // should be in range 1:6
	const range = Array.from({length: depth}, (x, i) => i+1) // [1, ..., depth]

	const selector = [
		...(include_definitions ? [
			`pluto-notebook pluto-cell .pluto-docs-binding`,
			`pluto-notebook pluto-cell assignee:not(:empty)`,
		] : []),
		...range.map(i => `pluto-notebook pluto-cell h\${i}`)
	].join(",")
	return Array.from(document.querySelectorAll(selector)).filter(el =>
		// exclude headers inside of a pluto-docs-binding block
		!(el.nodeName.startsWith("H") && el.closest(".pluto-docs-binding"))
	)
}
const document_click_handler = (event) => {
	const path = (event.path || event.composedPath())
	const toc = path.find(elem => elem?.classList?.contains?.("toc-toggle"))
	if (toc) {
		event.stopImmediatePropagation()
		toc.closest(".plutoui-toc").classList.toggle("hide")
	}
}
document.addEventListener("click", document_click_handler)
const header_to_index_entry_map = new Map()
const currently_highlighted_set = new Set()
const last_toc_element_click_time = { current: 0 }
const intersection_callback = (ixs) => {
	let on_top = ixs.filter(ix => ix.intersectionRatio > 0 && ix.intersectionRect.y < ix.rootBounds.height / 2)
	if(on_top.length > 0){
		currently_highlighted_set.forEach(a => a.classList.remove("in-view"))
		currently_highlighted_set.clear()
		on_top.slice(0,1).forEach(i => {
			let div = header_to_index_entry_map.get(i.target)
			div.classList.add("in-view")
			currently_highlighted_set.add(div)

			/// scroll into view
			/*
			const toc_height = tocNode.offsetHeight
			const div_pos = div.offsetTop
			const div_height = div.offsetHeight
			const current_scroll = tocNode.scrollTop
			const header_height = tocNode.querySelector("header").offsetHeight

			const scroll_to_top = div_pos - header_height
			const scroll_to_bottom = div_pos + div_height - toc_height

			// if we set a scrollTop, then the browser will stop any currently ongoing smoothscroll animation. So let's only do this if you are not currently in a smoothscroll.
			if(Date.now() - last_toc_element_click_time.current >= 2000)
				if(current_scroll < scroll_to_bottom){
					tocNode.scrollTop = scroll_to_bottom
				} else if(current_scroll > scroll_to_top){
					tocNode.scrollTop = scroll_to_top
				}
			*/
		})
	}
}
let intersection_observer_1 = new IntersectionObserver(intersection_callback, {
	root: null, // i.e. the viewport
  	threshold: 1,
	rootMargin: "-15px", // slightly smaller than the viewport
	// delay: 100,
})
let intersection_observer_2 = new IntersectionObserver(intersection_callback, {
	root: null, // i.e. the viewport
  	threshold: 1,
	rootMargin: "15px", // slightly larger than the viewport
	// delay: 100,
})
const render = (elements) => {
	header_to_index_entry_map.clear()
	currently_highlighted_set.clear()
	intersection_observer_1.disconnect()
	intersection_observer_2.disconnect()
		let last_level = `H1`
	return html`\${elements.map(h => {
	const parent_cell = getParentCell(h)
		let [className, title_el] = h.matches(`.pluto-docs-binding`) ? ["pluto-docs-binding-el", h.firstElementChild] : [h.nodeName, h]
	const a = html`<a
		class="\${className}"
		title="\${title_el.innerText}"
		href="#\${parent_cell.id}"
	>\${title_el.innerHTML}</a>`
	/* a.onmouseover=()=>{
		parent_cell.firstElementChild.classList.add(
			'highlight-pluto-cell-shoulder'
		)
	}
	a.onmouseout=() => {
		parent_cell.firstElementChild.classList.remove(
			'highlight-pluto-cell-shoulder'
		)
	} */


	a.onclick=(e) => {
		e.preventDefault();
		last_toc_element_click_time.current = Date.now()
		h.scrollIntoView({
			behavior: 'smooth',
			block: 'start'
		})
	}
	const row =  html`<div class="toc-row \${className} after-\${last_level}">\${a}</div>`
		intersection_observer_1.observe(title_el)
		intersection_observer_2.observe(title_el)
		header_to_index_entry_map.set(title_el, row)
	if(className.startsWith("H"))
		last_level = className

	return row
})}`
}
const invalidated = { current: false }
const updateCallback = () => {
	if (!invalidated.current) {
		tocNode.querySelector("section").replaceWith(
			html`<section>\${render(getHeaders())}</section>`
		)
	}
}
updateCallback()
setTimeout(updateCallback, 100)
setTimeout(updateCallback, 1000)
setTimeout(updateCallback, 5000)
const notebook = document.querySelector("pluto-notebook")
// We have a mutationobserver for each cell:
const mut_observers = {
	current: [],
}
const createCellObservers = () => {
	mut_observers.current.forEach((o) => o.disconnect())
	mut_observers.current = Array.from(notebook.querySelectorAll("pluto-cell")).map(el => {
		const o = new MutationObserver(updateCallback)
		o.observe(el, {attributeFilter: ["class"]})
		return o
	})
}
createCellObservers()
// And one for the notebook's child list, which updates our cell observers:
const notebookObserver = new MutationObserver(() => {
	updateCallback()
	createCellObservers()
})
notebookObserver.observe(notebook, {childList: true})
// And finally, an observer for the document.body classList, to make sure that the toc also works when it is loaded during notebook initialization
const bodyClassObserver = new MutationObserver(updateCallback)
bodyClassObserver.observe(document.body, {attributeFilter: ["class"]})
// Hide/show the ToC when the screen gets small
let m = matchMedia("(max-width: 2000px)")
let match_listener = () =>
	tocNode.classList.toggle("hide", m.matches)
match_listener()
m.addListener(match_listener)
invalidation.then(() => {
	invalidated.current = true
	intersection_observer_1.disconnect()
	intersection_observer_2.disconnect()
	notebookObserver.disconnect()
	bodyClassObserver.disconnect()
	mut_observers.current.forEach((o) => o.disconnect())
	document.removeEventListener("click", document_click_handler)
	m.removeListener(match_listener)
})
return tocNode
</script>
""";

# ╔═╡ 93e75cbf-946a-4244-a8ae-a54120169824
const toc_css = @htl """
<style>
@media not print {
.plutoui-toc {
	font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Cantarell, Helvetica, Arial, "Apple Color Emoji",
		"Segoe UI Emoji", "Segoe UI Symbol", system-ui, sans-serif;
	--main-bg-color: #fafafa;
	--pluto-output-color: hsl(0, 0%, 36%);
	--pluto-output-h-color: hsl(0, 0%, 21%);
	--sidebar-li-active-bg: rgb(235, 235, 235);
	--icon-filter: unset;
}
@media (prefers-color-scheme: dark) {
	.plutoui-toc {
		--main-bg-color: #303030;
		--pluto-output-color: hsl(0, 0%, 90%);
		--pluto-output-h-color: hsl(0, 0%, 97%);
		--sidebar-li-active-bg: rgb(82, 82, 82);
		--icon-filter: invert(1);
	}
}
.plutoui-toc.aside {
	color: var(--pluto-output-color);
	position: fixed;
	right: 1rem;
	top: 5rem;
	width: min(80vw, 300px);
	padding: 0.5rem;
	padding-top: 0em;
	/* border: 3px solid rgba(0, 0, 0, 0.15); */
	border-radius: 10px;
	/* box-shadow: 0 0 11px 0px #00000010; */
	max-height: calc(100vh - 5rem - 90px);
	overflow: auto;
	z-index: 40;
	background-color: var(--main-bg-color);
	transition: transform 300ms cubic-bezier(0.18, 0.89, 0.45, 1.12);
}
.plutoui-toc.aside.hide {
	transform: translateX(calc(100% - 28px));
}
.plutoui-toc.aside.hide section {
	display: none;
}
.plutoui-toc.aside.hide header {
	margin-bottom: 0em;
	padding-bottom: 0em;
	border-bottom: none;
}
}  /* End of Media print query */
.plutoui-toc.aside.hide .open-toc,
.plutoui-toc.aside:not(.hide) .closed-toc,
.plutoui-toc:not(.aside) .closed-toc {
	display: none;
}
@media (prefers-reduced-motion) {
  .plutoui-toc.aside {
	transition-duration: 0s;
  }
}
.toc-toggle {
	cursor: pointer;
    padding: 1em;
    margin: -1em;
    margin-right: -0.7em;
    line-height: 1em;
    display: flex;
}
.toc-toggle::before {
    content: "";
    display: inline-block;
    height: 1em;
    width: 1em;
    background-image: url("https://cdn.jsdelivr.net/gh/ionic-team/ionicons@5.5.1/src/svg/list-outline.svg");
	/* generated using https://dopiaza.org/tools/datauri/index.php */
    background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiB2aWV3Qm94PSIwIDAgNTEyIDUxMiI+PHRpdGxlPmlvbmljb25zLXY1LW88L3RpdGxlPjxsaW5lIHgxPSIxNjAiIHkxPSIxNDQiIHgyPSI0NDgiIHkyPSIxNDQiIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiMwMDA7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDozMnB4Ii8+PGxpbmUgeDE9IjE2MCIgeTE9IjI1NiIgeDI9IjQ0OCIgeTI9IjI1NiIgc3R5bGU9ImZpbGw6bm9uZTtzdHJva2U6IzAwMDtzdHJva2UtbGluZWNhcDpyb3VuZDtzdHJva2UtbGluZWpvaW46cm91bmQ7c3Ryb2tlLXdpZHRoOjMycHgiLz48bGluZSB4MT0iMTYwIiB5MT0iMzY4IiB4Mj0iNDQ4IiB5Mj0iMzY4IiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDAwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2Utd2lkdGg6MzJweCIvPjxjaXJjbGUgY3g9IjgwIiBjeT0iMTQ0IiByPSIxNiIgc3R5bGU9ImZpbGw6bm9uZTtzdHJva2U6IzAwMDtzdHJva2UtbGluZWNhcDpyb3VuZDtzdHJva2UtbGluZWpvaW46cm91bmQ7c3Ryb2tlLXdpZHRoOjMycHgiLz48Y2lyY2xlIGN4PSI4MCIgY3k9IjI1NiIgcj0iMTYiIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiMwMDA7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDozMnB4Ii8+PGNpcmNsZSBjeD0iODAiIGN5PSIzNjgiIHI9IjE2IiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDAwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2Utd2lkdGg6MzJweCIvPjwvc3ZnPg==");
    background-size: 1em;
	filter: var(--icon-filter);
}
.aside .toc-toggle.open-toc:hover::before {
    background-image: url("https://cdn.jsdelivr.net/gh/ionic-team/ionicons@5.5.1/src/svg/arrow-forward-outline.svg");
	/* generated using https://dopiaza.org/tools/datauri/index.php */
    background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiB2aWV3Qm94PSIwIDAgNTEyIDUxMiI+PHRpdGxlPmlvbmljb25zLXY1LWE8L3RpdGxlPjxwb2x5bGluZSBwb2ludHM9IjI2OCAxMTIgNDEyIDI1NiAyNjggNDAwIiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDAwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2Utd2lkdGg6NDhweCIvPjxsaW5lIHgxPSIzOTIiIHkxPSIyNTYiIHgyPSIxMDAiIHkyPSIyNTYiIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiMwMDA7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDo0OHB4Ii8+PC9zdmc+");
}
.aside .toc-toggle.closed-toc:hover::before {
    background-image: url("https://cdn.jsdelivr.net/gh/ionic-team/ionicons@5.5.1/src/svg/arrow-back-outline.svg");
	/* generated using https://dopiaza.org/tools/datauri/index.php */
    background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiB2aWV3Qm94PSIwIDAgNTEyIDUxMiI+PHRpdGxlPmlvbmljb25zLXY1LWE8L3RpdGxlPjxwb2x5bGluZSBwb2ludHM9IjI0NCA0MDAgMTAwIDI1NiAyNDQgMTEyIiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDAwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2Utd2lkdGg6NDhweCIvPjxsaW5lIHgxPSIxMjAiIHkxPSIyNTYiIHgyPSI0MTIiIHkyPSIyNTYiIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiMwMDA7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDo0OHB4Ii8+PC9zdmc+");
}
.plutoui-toc header {
	display: flex;
	align-items: center;
	gap: .3em;
	font-size: 1.5em;
	/* margin-top: -0.1em; */
	margin-bottom: 0.4em;
	padding: 0.5rem;
	margin-left: 0;
	margin-right: 0;
	font-weight: bold;
	border-bottom: 2px solid rgba(0, 0, 0, 0.15);
	position: sticky;
	top: 0px;
	background: var(--main-bg-color);
	z-index: 41;
}
.plutoui-toc.aside header {
	padding-left: 0;
	padding-right: 0;
}
.plutoui-toc section .toc-row {
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	padding: .1em;
	border-radius: .2em;
}
.plutoui-toc section .toc-row.H1 {
	margin-top: 1em;
}
.plutoui-toc.aside section .toc-row.in-view {
	background: var(--sidebar-li-active-bg);
}

.highlight-pluto-cell-shoulder {
	background: rgba(0, 0, 0, 0.05);
	background-clip: padding-box;
}
.plutoui-toc section a {
	text-decoration: none;
	font-weight: normal;
	color: var(--pluto-output-color);
}
.plutoui-toc section a:hover {
	color: var(--pluto-output-h-color);
}
.plutoui-toc.indent section a.H1 {
	font-weight: 700;
	line-height: 1em;
}
.plutoui-toc.indent section .after-H2 a { padding-left: 10px; }
.plutoui-toc.indent section .after-H3 a { padding-left: 20px; }
.plutoui-toc.indent section .after-H4 a { padding-left: 30px; }
.plutoui-toc.indent section .after-H5 a { padding-left: 40px; }
.plutoui-toc.indent section .after-H6 a { padding-left: 50px; }
.plutoui-toc.indent section a.H1 { padding-left: 0px; }
.plutoui-toc.indent section a.H2 { padding-left: 10px; }
.plutoui-toc.indent section a.H3 { padding-left: 20px; }
.plutoui-toc.indent section a.H4 { padding-left: 30px; }
.plutoui-toc.indent section a.H5 { padding-left: 40px; }
.plutoui-toc.indent section a.H6 { padding-left: 50px; }
.plutoui-toc.indent section a.pluto-docs-binding-el,
.plutoui-toc.indent section a.ASSIGNEE
	{
	font-family: JuliaMono, monospace;
	font-size: .8em;
	/* background: black; */
	font-weight: 700;
    font-style: italic;
	color: var(--cm-var-color); /* this is stealing a variable from Pluto, but it's fine if that doesnt work */
}
.plutoui-toc.indent section a.pluto-docs-binding-el::before,
.plutoui-toc.indent section a.ASSIGNEE::before
	{
	content: "> ";
	opacity: .3;
}
</style>
""";

# ╔═╡ 0e13bf9e-67c8-4f4e-865b-13c05ecaa984
set_theme!(Theme(
    palette=(
        color=collect(ColorSchemes.seaborn_colorblind6),
    ),
    Lines=(
        linewidth=2,
        cycle=Cycle([:color], covary=true)
    ),
    Axis=(
        # aspect=1,
        xticksvisible=false,
        yticksvisible=false,
        xgridcolor=Makie.RGBAf(0.0f0, 0.0f0, 0.0f0, 0.24f0),
        ygridcolor=Makie.RGBAf(0.0f0, 0.0f0, 0.0f0, 0.24f0)
    ),
    Legend=(
        bgcolor=Makie.RGBAf(1.0f0, 1.0f0, 1.0f0, 1.0f0),
    ),
    fonts=(
        regular="MathJax_Main",
    )
))

# ╔═╡ e0e7407d-fe60-4583-8060-3ba38c22c409
begin
	st = subtypes(Hyperelastics.AbstractIncompressibleModel)
	hyperelastic_models = filter(x->typeof(x())<:Hyperelastics.AbstractIncompressibleModel, st)
	hyperelastic_models_string = map(x->split(string(x), ".")[end], hyperelastic_models)	
	doc_strings = Dict(map(x->x=>eval(:(@doc $(x()))), hyperelastic_models))
end;

# ╔═╡ 86f7e74f-c0a9-4561-85b9-f3ed6559facc
function ShearModulus(ψ, ps; adb = AD.ForwardDiffBackend())
	s(x) = AD.gradient(adb,x->StrainEnergyDensity(ψ, x, ps), x)[1][1]-AD.gradient(adb,x->StrainEnergyDensity(ψ, x, ps), x)[1][3]*x[3]
	AD.gradient(adb,y->s(y)[1], [1.0, 1.0, 1.0])[1][1]
end;

# ╔═╡ 8ea07dab-06dc-456d-9769-5e9c3980a777
ElasticModulus(ψ, ps) = ShearModulus(ψ, ps)*3;

# ╔═╡ b67eac91-eeaa-4582-b404-61be6b22eb15
function UniaxialPlot(he_data, names; modes = ["markers"], stress_units = "")
	f = Figure()
	ax = CairoMakie.Axis(f[1, 1], xlabel = "Stretch [-]", ylabel = "Nominal Stress [$stress_units]")
	for (i,data) in enumerate(he_data)
		modes[i](ax, 
			getindex.(data.data.λ, 1),
			getindex.(data.data.s, 1),
			label = names[i],
		)
	end
	axislegend(ax, position = :lt)
	f
end;

# ╔═╡ 34620e92-2d67-4610-a9a5-e961f20e6a0b
param_dict = map(model->model=>Hyperelastics.parameters(model()), hyperelastic_models)|>Dict;

# ╔═╡ 05a47268-e872-4d8d-898a-06af5285d282
bounds = map(model -> model=>Base.Fix1(Hyperelastics.parameter_bounds, model), hyperelastic_models)|>Dict;

# ╔═╡ c91ed60e-dd9b-427c-be79-9e46942dcf5c
# function BiaxialPlot(he_data, names1, names2; modes = ["markers"])
# 	layout = Config(
# 		template = PlotlyLight.template("simple_white"),
# 		grid = Config(rows = 1, columns = 2, pattern = "independent")
# 	)
# 	p = Plot()
# 	for (i,data) in enumerate(he_data)
# 		p(
# 			x = getindex.(data.data.λ, 1),
# 			y = getindex.(data.data.s, 1),
# 			name = names1[i],
# 			type = "scatter",
# 			mode = modes[i],
# 			legendgroup = names1[i]
# 		)(
# 			x = getindex.(data.data.λ, 1),
# 			y = getindex.(data.data.s, 2),
# 			name = names2[i],
# 			type = "scatter",
# 			mode = modes[i],
# 			legendgroup = names2[i],
# 		)(
# 			x = getindex.(data.data.λ, 2),
# 			y = getindex.(data.data.s, 1),
# 			xaxis = "x2",
# 			yaxis = "y2",
# 			name = names1[i],
# 			type = "scatter",
# 			mode = modes[i],
# 			legendgroup = names1[i],
# 			showlegend = false
# 		)(
# 			x = getindex.(data.data.λ, 2),
# 			y = getindex.(data.data.s, 2),
# 			xaxis = "x2",
# 			yaxis = "y2",
# 			name = names2[i],
# 			type = "scatter",
# 			mode = modes[i],
# 			legendgroup = names2[i],
# 			showlegend = false
# 		)
# 	end
# 		p.layout = layout
# 		p.layout.xaxis.title = "λ₁ Stretch [-]"
# 		p.layout.yaxis.title = "Stress"
# 		p.layout.xaxis2.title = "λ₂ Stretch [-]"
# 		p.layout.yaxis2.title = "Stress"
# 		p
# end;

# ╔═╡ b61bffb0-94ed-4fd3-b5a6-cce4aef81d46
begin
	treloar_df = CSV.read(joinpath([splitpath(@__FILE__)[1:end-1];"uniaxial.csv"]), DataFrame)
	struct HEUpload
	    accept::Array{MIME,1}
	end
	HEUpload() = HEUpload(MIME[])
	function Base.show(io::IO, m::MIME"text/html", filepicker::HEUpload)
		show(io, m, @htl("""<input type='file' accept=$(join(string.(filepicker.accept), ","))>"""))
	end

	Base.get(select::HEUpload) = treloar_df;
	
	Bonds.initial_value(select::HEUpload) = treloar_df;
	Bonds.possible_values(select::HEUpload) = Bonds.InfinitePossibilities()
	function Bonds.validate_value(select::HEUpload, val)
		val isa Nothing || (val <: Hyperelastics.AbstractHyperelasticTest)
	end
	function Bonds.transform_value(s::HEUpload, v)
		if isnothing(v)
			return treloar_df
		else
			data = CSV.read(v["data"], DataFrame)
		end
	end
end

# ╔═╡ f055137f-17ef-4926-9d5c-599a9af6e85c
@bind data_df HEUpload([MIME("text/csv")])

# ╔═╡ 6e9811d6-8622-4453-8fb9-5ce75d9d891e
if size(data_df)[1] != 0
	md"""
	Stress Column: $(@bind stress_column Select(names(data_df)))
	
	Stretch Column: $(@bind stretch_column Select(names(data_df)))
	"""
end

# ╔═╡ 7f40b545-e048-4913-b69d-7bd0577d1823
md"""
Stress Label: $(@bind stress_units Select([Symbol("MPa"), Symbol("kPA"), Symbol("Pa"), Symbol("kgf/cm^2"), Symbol("lbf/inch^2")], default=Symbol("kgf/cm^2")))
"""

# ╔═╡ 2f1fde4b-6bd8-42b4-bf5c-d61006d55f10
@bind model Select(hyperelastic_models .=> hyperelastic_models_string, default="Gent")

# ╔═╡ a75d209e-93cb-4b21-899e-4c567f0dfb09
eval(:(@doc $(model())))

# ╔═╡ 08d775f2-94fc-4ca8-bcdd-e9535cfd129a
md"""
Optimizer: $(@bind optimizer Select([:LBFGS, :BFGS, :NelderMead])) - *If parameters are not converging, try using a different optimizer or changing your initial guess*
"""

# ╔═╡ ea9f6a58-a5df-4a2e-aadd-5ff1107d8b55
begin
	Base.@kwdef struct TableOfContents_NEW
		title::AbstractString="Table of Contents"
		indent::Bool=true
		depth::Integer=3
		aside::Bool=true
		include_definitions::Bool=false
	end
	function Base.show(io::IO, m::MIME"text/html", toc::TableOfContents_NEW)
		Base.show(io, m, @htl("$(toc_js(toc))$(toc_css)"))
	end
end

# ╔═╡ 0dd8b7de-570d-41a7-b83d-d1bbe39c017e
TableOfContents_NEW()

# ╔═╡ cfec08c5-383d-401f-bafa-851deb9d2ec5
he_data = HyperelasticUniaxialTest(data_df[!,stretch_column], data_df[!,stress_column], name = "");

# ╔═╡ 9cf84ce0-8a82-4715-8069-dbb1d60e36ff
UniaxialPlot([he_data], ["Experimental"]; modes = [scatter!], stress_units = stress_units)

# ╔═╡ c1a38496-46fb-4dd0-9249-0b92e51ff1df
begin
	ps_model = param_dict[model]
	num_ps = length(ps_model)
	lb, ub = Hyperelastics.parameter_bounds(model(), he_data);
		if isnothing(lb) && !isnothing(ub)
			ub_tab = LVector(ub)
			lb_tab = LVector(NamedTuple(param_dict[model].=> ones(length(ub))*-Inf))
		elseif !isnothing(lb) && isnothing(ub)
			lb_tab = LVector(lb)
			ub_tab = LVector(NamedTuple(param_dict[model].=> ones(length(lb))*Inf))
		elseif !isnothing(lb) && !isnothing(ub)
			lb_tab = LVector(lb)
			ub_tab = LVector(ub)
		else
			lb_tab =  LVector(NamedTuple(param_dict[model].=> ones(length(param_dict[model]))*-Inf))
			ub_tab =  LVector(NamedTuple(param_dict[model].=> ones(length(param_dict[model]))*Inf))
		end
	str = let
	_str = "<span>"
	columns = ["Value"]
	output_string = ""
	# output_string = "{"
	for column ∈ columns
		output_string *= """Array("""
		for i ∈ 1:num_ps
			output_string *= """$(ps_model[i]).value,"""
		end
		output_string *= """) """
	end
####################             HTML        ##############################
	_str *= """<center><h5> Parameter Entry</h5></center>"""
	_str *= """<table>"""
	_str *=	"""<th>Parameter</th>"""
	_str *= """<th>Lower Bound</th>"""
	_str *= """<th>Value</th>"""
	_str *= """<th>Upper Bound</th>"""
	for i ∈ 1:num_ps
		_str *= """<tr>"""
		for column ∈ columns
			_str *= """<td><center>$(ps_model[i])</center></td>"""
			#<td>"""<center>$(round(lb[ps[i]], digits = 3))</center></td><td><center>$(round(ub[ps[i]], digits = 3))</center></td>"""
			_str *= """<td>$(getindex(lb_tab, ps_model[i]))</td><td><input type = "text" id = "$(ps_model[i])" value = "0"></input></td><td>$(getindex(ub_tab, ps_model[i]))</td>"""
		end
		_str *= """</tr>"""
	end
	_str *= """</table>"""
######################        JAVASCRIPT            ####################
	_str *= """
		<script>
			var span = currentScript.parentElement
		"""
	for i ∈ 1:num_ps
		for column ∈ columns
		_str*="""
			var $(ps_model[i]) = document.getElementById("$(ps_model[i])")

			$(ps_model[i]).addEventListener("input", (e) => {
				span.value = $(output_string)
				span.dispatchEvent(new CustomEvent("input"))
				e.preventDefault()
			})
		"""
		end

	end

	_str*="""
		span.value = $(output_string)
		</script>
		</span>
		"""
	end
	@bind ps confirm(HTML(str))
end

# ╔═╡ 419d65dc-a7f6-4834-b2ca-8aaf9f6d6a05
ps_new_lv = try
		ps_nt = NamedTuple(param_dict[model].=>ps);
		pair_ps = map(x->x.first => parse.(Float64, replace.(replace.(split(x.second, ","), " "=>""), ","=>"")), collect(pairs(ps_nt)))
		ps_new = []
		for i in eachindex(pair_ps)
			if length(pair_ps[i].second) == 1
				push!(ps_new, pair_ps[i].first => pair_ps[i].second[1])
			else 
				push!(ps_new, pair_ps[i])
			end
		end
		ComponentVector(NamedTuple(ps_new))
catch
	nothing
end;

# ╔═╡ 7a30d9d4-7808-4745-af47-5c083beb8603
begin
	if !isnothing(ps_new_lv)
		prob = HyperelasticProblem(model(), he_data, ps_new_lv; ad_type = AutoForwardDiff());
		if !isnothing(prob)
			sol = solve(prob, getfield(OptimizationOptimJL, optimizer)())
		end
	end
end;

# ╔═╡ db2465a8-fdbc-4679-8cf6-9c3f1ba7b98f
if @isdefined he_data
	if !isnothing(he_data)
		if !(isnothing(ps))
			if @isdefined sol
			str_table = let
				_str = "<span>"
				columns = string.(param_dict[model])
				####################     HTML        #######################
				_str *= """<center><h2  style = "font-family:Archivo Black"> Final Parameters</h2></center>"""
				_str *= """<table><th></th>"""
				for column ∈ columns
					_str *=	"""<th>$(replace(column, "_" => " "))</th>"""
				end

				_str *= """<tr><td>Initial Value</td>"""
				for column ∈ columns
					_str *= """<td>$(round.(getindex(ps_new_lv, Symbol(column)), sigdigits = 6))</input></td>"""
				end
				_str *= """</tr>"""
				
				_str *= """<tr><td>Optimized Value</td>"""
				for column ∈ columns
					_str *= """<td>$(round.(getindex(sol.u, Symbol(column)), sigdigits = 6))</input></td>"""
				end
				_str *= """</tr>"""
				_str *= """<tfoot><tr><td></td>"""
				_str *= """<td></td></tr></tfoot>"""
				_str *= """</table>"""
				_str *= """</span>"""
			end
			HTML(str_table)
			end
		end
	end
end

# ╔═╡ d734efdf-c9d3-498b-baaa-cd16ac1c1146
let
	if @isdefined sol
		pred = predict(model(), he_data, sol.u, ad_type = AutoForwardDiff())
		UniaxialPlot(
			[pred, he_data], 
			["Predicted", "Experimental"], 
			modes = [lines!, scatter!], 
			stress_units = stress_units
		)
	end
end

# ╔═╡ Cell order:
# ╟─0dd8b7de-570d-41a7-b83d-d1bbe39c017e
# ╟─73ab5774-dc3c-4759-92c4-7f7917c18cbf
# ╟─f055137f-17ef-4926-9d5c-599a9af6e85c
# ╟─6e9811d6-8622-4453-8fb9-5ce75d9d891e
# ╟─7f40b545-e048-4913-b69d-7bd0577d1823
# ╟─f12538a9-f595-4fae-b76c-078179bc5109
# ╟─9cf84ce0-8a82-4715-8069-dbb1d60e36ff
# ╟─d0319d95-f335-48fa-b789-59daf9a0f1a4
# ╟─9343a51e-5002-4489-a55f-12c49f5b8cf3
# ╟─2f1fde4b-6bd8-42b4-bf5c-d61006d55f10
# ╟─da3634ea-48d7-4d4f-a853-c631a6fa7bf4
# ╟─a75d209e-93cb-4b21-899e-4c567f0dfb09
# ╟─c6e726ab-ea78-4129-a662-338976633cd5
# ╟─c1a38496-46fb-4dd0-9249-0b92e51ff1df
# ╟─08d775f2-94fc-4ca8-bcdd-e9535cfd129a
# ╟─7a30d9d4-7808-4745-af47-5c083beb8603
# ╟─db2465a8-fdbc-4679-8cf6-9c3f1ba7b98f
# ╟─d734efdf-c9d3-498b-baaa-cd16ac1c1146
# ╟─7196aa51-e86d-4f0e-ae40-cc6aa74aa237
# ╟─419d65dc-a7f6-4834-b2ca-8aaf9f6d6a05
# ╟─9e411ed3-0061-4831-b047-44c920959c83
# ╟─36cf277a-2683-43b2-a406-7eb8a0fcac07
# ╟─93e75cbf-946a-4244-a8ae-a54120169824
# ╟─ea9f6a58-a5df-4a2e-aadd-5ff1107d8b55
# ╟─e5a18d4c-14cd-11ed-36d5-69de0fd02830
# ╟─0e13bf9e-67c8-4f4e-865b-13c05ecaa984
# ╟─e0e7407d-fe60-4583-8060-3ba38c22c409
# ╟─86f7e74f-c0a9-4561-85b9-f3ed6559facc
# ╟─8ea07dab-06dc-456d-9769-5e9c3980a777
# ╟─b67eac91-eeaa-4582-b404-61be6b22eb15
# ╟─34620e92-2d67-4610-a9a5-e961f20e6a0b
# ╟─05a47268-e872-4d8d-898a-06af5285d282
# ╟─c91ed60e-dd9b-427c-be79-9e46942dcf5c
# ╟─b61bffb0-94ed-4fd3-b5a6-cce4aef81d46
# ╟─cfec08c5-383d-401f-bafa-851deb9d2ec5
