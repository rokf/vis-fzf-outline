# vis-fzf-outline

This repository contains an outline navigation plugin for the [Vis](https://github.com/martanne/vis) editor.

## Installation

Clone the repository into your Vis configuration folder:

```sh
cd ~/.config/vis
git clone https://github.com/rokf/vis-fzf-outline
```

Import the plugin in your `visrc.lua` file:

```lua
require('vis-fzf-outline/init')
```

## Usage

Requiring this plugin's `init.lua` file (see installation section above) should register an `outline` command. Executing the command should show a list of matching outline entries for the current syntax. Each syntax can have multiple outline matchers - the appropriate one is chosen through a matcher function, which expects a File structure. The specific matcher is chosen if it returns a truthy value.

The `init.lua` file contains a few default outline matchers.

I suggest adding a key map if you're planning to use the command often. Example (`visrc.lua`):

```lua
vis:command('map! normal <C-t> :outline<Enter>')
```

### Registering your own matchers

The plugin returns its matcher table and it can be modified. Example (`visrc.lua`):

```lua
local outline = require('vis-fzf-outline/init')

outline['lua'][
	function (file)
		return string.match(file.name, '_test.lua$')
	end
] = {
	'^%s*describe'
}
```

## License

This library is free software; you can redistribute it and/or modify it under the terms of the MIT license. See LICENSE for details.
