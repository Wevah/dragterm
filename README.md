#  dragterm 1.0.3

Drag and drop from the command-line, updated to use modern API.

The tool itself is called “`drag`”, as that's a lot nicer to type than “`dragterm`”.

Moving the mouse far enough away from the displayed icon before dragging will cancel.

## Usage

`drag <files>`

And drag the icon that appears under the mouse cursor.

## History

- 1.0.3
	- Fixes a crash when passing an unrecognized option.
- 1.0.2
	- Increased drag-start area to 256 × 256.
	- Supports dragging files to the Trash.
	- Added `--version` and `--help` options.
- 1.0.1
	- Supports multiple files.
- 1.0
	- Initial release.

## Notes

Starting a drag without a view (as <https://github.com/ciaran/drag> does) doesn't seem to work anymore, hence the transparent window appearing under the mouse (which should mostly behave the same).
