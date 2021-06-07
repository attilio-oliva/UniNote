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
# Document format
Notation:
- [Foo]: data of type Foo
- [[Foo]]: data array of type Foo
- [TODO]: type is not defined yet
## Header
Documents always starts with "UniNote" encoded as a UTF-8 string, for any kind of serialization implemented. It is used for validation purposes.
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
- position [Coordinate]
- type [TODO] *optional* : how should it be interpreted? Plaintext, Markdown, HTML, LaTeX... Default is TODO
- style [TextStyle] *optional*
### stroke
- data [TODO]
- position [Coordinate]
- width [float]
- colour [Colour]
### image
- data-location [Location]
- boundary [[Coordinate]]
- type [TODO]
### file
- data-location [Location]
- position [Coordinate]
- type [TODO]
- icon [TODO]
## Common data
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
