# Extra Info++

The heavy lifing on this was all done by [Pedro Lobo](http://palobo.tumblr.com)

*Original Copyright (C) 2012 Pedro Lobo*

*Modified by Brett Terpstra 2013*

* Added basic templating and additional app examples
* If the tag value is empty, the task title is used for filename and templating
* Routines for handling peculiarities of each app

This is a hot mess as far as the AppleScript goes. To many logic forks and redundancies were introduced in this process. It works well, but it's not as easily extensible as I'd like. Feel free to fix it...

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
