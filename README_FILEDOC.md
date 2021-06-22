# File structure
The file is a TODO compressed archive.  
It is structured using the following schema:

📦File  
 ┣ 📂Attachments  
 ┣ 📂Section1  
 ┣ 📂Section2  
 ┗ 📂SectionX  
 ┃ ┣ 📜note.document  
 ┃ ┣ 📂Group1  
 ┃ ┃ ┗ 📜note1.document  
 ┃ ┗ 📂GroupX  
 ┃ ┃ ┗ 📜noteX.document  

Details:
- Attachment contains files and images to be inserted in documents.
- Groups are optional. They provide a further way to aggregate notes.
- Documents filename are used for their title. In case the title is left empty, default name is TODO.
# File structure implementation
A file is made of multiple related xml subfiles.
- File structure: every uninote file has its structure defined in a proper xml document (Example in repository at assets/filename.xml) 
- Note content: every note has its content defined in a dedicated xml document (Example in repository at assets/doc.xml)
# Document format
Notation:
- [Foo]: data of type Foo
- [[Foo]]: data array of type Foo
- [TODO]: type is not defined yet
## Header
### version
- app [string]
- document [Date]
### background
- colour [Colour]
- pattern [TODO]
### theme
- colours [ColourPalette]
- default-font [TODO]  

## Main components
### text
- data [string]: The actual text content
- type [TODO] *optional* : how should it be interpreted? Plaintext, Markdown, HTML, LaTeX... Default is TODO
- width[float]
- style [TextStyle] *optional*
### stroke
 Contains as a child an svg element. Currently a polyline with attribute "points".
- width [float]
- colour [Colour]
### image
- location [Location]
- width [float]
- height [float]
- type [TODO]
### file
- location [Location]
- type [TODO]
- icon [TODO]
## Common data
Every main component requires:
- x [float]: Horizontal distance from the leftmost point in screen(origin is at the top-left corner of the screen)
- y [float]: Vertical distance from the highest point in screen(origin is at the top-left corner of the screen)
- id [string]: Identifies the single component to support a bookmark system
Every main component can have optional data:
- bookmark [string]: the component is designated as a bookmark of name equal to this string.
## Types definition

### Date
Timestamp format (DD/MM/YYYY hh:mm)
### Colour
Represent the colour of the component in TODO format.
### ColourPalette
It is a list of ordered pairs defined as (scope[string], colour[Colour]).

Example: [ ["Title", red] , ["heading1", green] , ... , ["definition", blue] ]
### TextStyle
Override the document theme if any of this parameters are defined
- font [TODO] *optional*
- colour [Colour] *optional*
- type [string] : It is used to follow the document theme. If not defined or of unknown type it is interpreted as plaintext. Examples are "h1","h2","customType".
