# Design considerations

## Syntax considerations
- Very very limited
- Pure text should not be disturbed
- Reuse syntax rather than introducing new
	- eg. LaTeX allows \section{}, \includegraphics{} and \usepackage even though they mean very different things and do different things
- Reserved characters should be very limited
- General purpose programming language should be available instead of macros
- Content should not be interpreted as a programming language like LaTeX as in \iffalse is allowed anywhere
	- To replace this, take inspiration from templating engines like ejs, handlebars and jade
- Prioritize builtin library over modularity, which avoids relying on packages for basic functionality
- Prioritize builtin scripting support over bianry packages
	- This could be done by have a lua interface
- Avoid at all cost: Syntax changing because of an environment. The syntax should be understandable by looking at one file without looking at the importing ones
	- Problem: how to do tikz and code snippets
	- Solution: create a general builtin "escaped" block which ignores any reserved syntax and give that to the script. The tikz package can generate svg using lua scripting and put that directly into the IR.


## Compiler structure
- Two phase
	- Compile to simple IR
	- Compiler IR to PDF
- The user, packages and scripts should only be able to interact with the generated IR, not the IR to PDF generator
- IR	
	- IR is layout independent, no absolute sizes are decided or any consideration of paper size has been made
	- All text content except for page references is decided
		- All page references should reserve reasonable space (eg. enough to fit given pages)
		- layout and page splits are calculated
		- References are backpatched
		- layout adjusts the page references back to actual size and layout is calculated again without changing page splits

## Layout considerations:
page layout affectors:
- document class
- content margin
- body margin
- header margin
- footer margin
- orientation
- paper type


## Input files
Layout description:
- json or lua (layout sometimes needs to be calculated so lua would be handy)
	- Describes layout and only layout
	- Has a name which is used to refer to the layout
Style description:
- json, lua or css
	- with lua, the styling could be set by using IR commands
	- with json, the styling could be set declaratively
	- with css, the styling could be very flexible and the syntax is already well understood by programmers. However we dont use the CSS box model, so big modifications would be needed, which would be very hard to understand for the writer.
		- CSS is great for resizing devices, but SciText does not resize ever, so might be overkill
Content description:
- ST file which uses the SciText syntax, should only be content, not description of layout
	- Can change layout and give arguments to that layout but not describe it directly
	- Header and footer is described in seperate ST files

## IR "instructions"
ContentFragment
- Line break
- Page break
- BoxFragment
	- outer margin
	- inner padding
	- color
	- background color
	- padding color
- TextFragment
	- Thickness
	- Italic
	- Size
	- TextFragment
	- **PageReferenceFragment**
- ImageFragment
	- size
	- RasterImageFragment
		- Image size
	- SVGImageFragment
		- SVG content
- Table Fragment
