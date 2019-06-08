#  dragterm 1.0.1

Drag and drop from the command-line, updated to use modern API.

The tool itself is called "drag", as that's a lot nicer to type than "dragterm".

Moving the mouse outside too far before dragging will cancel the invocation, though I'm not sure that this is the best behavior.

1.0.1 supports multiple files.

## Usage

`drag <file>`

And drag the icon that appears under the mouse cursor.

## Notes

Starting a drag without a view (as <https://github.com/ciaran/drag> does) doesn't seem to work anymore, hence the transparent window appearing under the mouse.
