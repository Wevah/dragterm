#  dragterm 1.0.1

Drag and drop from the command-line, updated to use modern API.

The tool itself is called "drag", as that's a lot nicer to type than "dragterm".

Moving the mouse too far before dragging will cancel the invocation, though I'm not sure that this is the best behavior.

## Usage

`drag <file>`

And drag the icon that appears under the mouse cursor.

## History

- 1.0.2
	- Escape key cancels invocation even before the drag (requires Terminal to have accessibility access).
	- Increased drag-start area to 256 × 256.
- 1.0.1
	- Supports multiple files.
- 1.0
	- Initial release.

## Notes

Starting a drag without a view (as <https://github.com/ciaran/drag> does) doesn't seem to work anymore, hence the transparent window appearing under the mouse.
