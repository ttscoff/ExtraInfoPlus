# Extra Info++

A script to provide tag-based linking to external notes from within TaskPaper documents, allowing you to elaborate on tasks and ideas, collect additional resources and generally keep your TaskPaper files void of dozens of notes.

The heavy lifting on this was all done by [Pedro Lobo](http://palobo.tumblr.com)

*Original Copyright (C) 2012 Pedro Lobo*

*Modified by Brett Terpstra 2013:*

* Added basic template capabilities and additional app examples
* If the tag value is empty, the task title is used for filename and templating
* Routines for handling peculiarities of each app

This is a hot mess as far as the AppleScript goes (my fault). Too many logic forks and redundancies were introduced in this process. It works well, but it's not as easily extensible as I'd like. Feel free to fix it...

## Setup

1. Open the `ExtraInfoPlus.applescript` file in AppleScript Editor and save it as a script in `~/Library/Scripts/Applications/TaskPaper`. 
2. You'll need to edit the template path to point to wherever you put this repo. 
3. Edit the docPath values for each app you want to use. These are the locations where new note files will be created for each app.
4. Use a launcher like [FastScripts](http://www.red-sweater.com/fastscripts/) for hotkey access to the script from within TaskPaper.

## Apps

* `@map` triggers **MindNode** using *Template.mindnode*
* `@mmap` triggers **Mindjet MindManager** using *Template.mindmanager*
* `@mapx` triggers **iThoughtsX** using *map.itm*
* `@outline` triggers **OmniOutliner** using *Template.opml*
* `@note` triggers **nvALT** using *Template.md*

## Template variables

* %%TITLE%% is generated from the tag value, or the task name if that's empty
* %%DATE%% is the ISO date at the runtime
* %%FILENAME%% is the document title of the originating TaskPaper document
* %%FILEPATH%% is the originating TaskPaper document as a file URL
