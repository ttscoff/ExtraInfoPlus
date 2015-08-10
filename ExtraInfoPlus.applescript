--  TaskPaper Actions | Extra Info++
--
--  For use with TaskPaper and Alfred
--  For further instructions read the README.md or visit http://palobo.tumblr.com
--
--  Copyright (C) 2012  Pedro Lobo <palobo@gmail.com>
--
-- Modified by Brett Terpstra 2015
-- Added rudimentary templating and additional examples
--
-- Updated 8/10/15
--   Added ability to find [[wiki links]] in task text, open using first item in workList
--   Use ML+ notification center if Growl isn't running
--
-- Template variables
-- %%TITLE%% is generated from the tag value, or the task name if that's empty
-- %%DATE%% is the ISO date at the runtime
-- %%FILENAME%% is the document title of the originating TaskPaper document
-- %%FILEPATH%% is the originating TaskPaper document as a file URL
--
-- Configure settings below
--
-- The base folder all paths will be relative to. If blank, use absolute paths
property baseFolder : "/Users/ttscoff/Dropbox/"
-- The folder where your templates are stored, must end in trailing slash
property templateFolder : "Notes/Templates/"
-- Your keywords for app triggers, and their associated target paths, template names, extension and app name
set workList to {{"note", "node", "map", "mmap", "outline"}, ¬
	{docPath:"nvALT2.2/", template:"Template.md", ext:"md", appname:"nvALT"}, ¬
	{docPath:"Notes/Brainstorming/", template:"Template.mindnode", ext:"mindnode", appname:"MindNode Pro"}, ¬
	{docPath:"Notes/Brainstorming/", template:"map.itm", ext:"itmz", appname:"iThoughtsX"}, ¬
	{docPath:"Notes/Brainstorming/", template:"Template.mindmanager", ext:"mmap", appname:"Mindjet MindManager"}, ¬
	{docPath:"Notes/Brainstorming/", template:"Template.opml", ext:"opml", appname:"Tree 2"}}


-- Change nothing bellow this point unless you know what you're doing. Magic starts here.
property srcPath : missing value
property fileName : missing value
property dateNow : missing value
set dateNow to do shell script "date '+%Y-%m-%d %H:%M'"

tell application "TaskPaper"
	my displayMessage("Operations", "Opened File", "Successfully opened")
	set _doc to document of window 1
	set _file to file of _doc
	set srcPath to "file://" & POSIX path of _file
	set _filename to name of _doc as string
	set fileName to rich text 1 thru ((offset of ".taskpaper" in _filename) - 1) of _filename
	tell selected entry
		set marker to 0
		set tagList to name of tags
		set watchList to list 1 of workList
		set propList to rest of workList
		repeat with _item in watchList
			set marker to marker + 1
			repeat with _tag in tagList
				if _tag as rich text = _item as rich text then
					set _name to value of tag named _tag
					if _name is missing value or _name is "" then
						set _name to text content
					end if
					set rec to record marker of propList
					my accessInfo(_name, baseFolder & (docPath of rec), ext of rec, appname of rec, template of rec)
				end if
			end repeat
		end repeat

		set wikiLink to my findBetween("[[", "]]", text content)
		if (count of wikiLink) > 0 then
			set rec to record 1 of propList
			my accessInfo(wikiLink, baseFolder & (docPath of rec), ext of rec, appname of rec, template of rec)
		end if
	end tell
end tell



to accessInfo(_name, _path, _ext, _appname, _template)
	set extraInfo to _path & snr("/", "_", _name) & "." & _ext
	set extraAlias to extraInfo as POSIX file
	set _template_path to templateFolder & _template
	tell application "Finder"

		if exists extraAlias then
			try
				if _appname is "nvALT" then
					do shell script "open 'nvalt://find/" & _name & "'"
				else
					do shell script "open -a " & quoted form of _appname & " " & quoted form of extraInfo
				end if
				my displayMessage("Operations", "Opened File", "Successfully opened " & _name & "." & _ext)
			on error errStr number errorNumber
				my displayMessage("Errors", "Error", "Problem Opening " & _name & "." & _ext & " : " & errStr & "(" & errorNumber & ")")
			end try
		else
			try
				if _appname is "iThoughtsX" then
					do shell script "cp " & quoted form of _template_path & " " & _path & _template
					my updateTemplate(_path & _template, _name, _appname, _path)
					do shell script "open -a " & quoted form of _appname & " " & quoted form of extraInfo
				else if _appname is "Mindjet MindManager" then
					set tmpFolder to extraInfo & ".tmp"
					do shell script "cp -r " & quoted form of _template_path & " " & quoted form of tmpFolder
					my updateTemplate(tmpFolder, _name, _appname, _path)
					do shell script "open -a " & quoted form of _appname & " " & quoted form of extraInfo
				else
					do shell script "cp -r " & quoted form of _template_path & " " & quoted form of extraInfo
					my updateTemplate(extraInfo, _name, _appname, _path)
					if _appname is "nvALT" then
						do shell script "open \"nvalt://find/" & _name & "\""
					else
						do shell script "open -a " & quoted form of _appname & " " & quoted form of extraInfo
					end if
				end if
				my displayMessage("Operations", "Created New File", "Successfully Created and Opened " & _name & "." & _ext)
			on error errStr number errorNumber
				my displayMessage("Errors", "Error", "Problem Creating/Opening " & _name & "." & _ext & " : " & errStr & "(" & errorNumber & ")")
			end try

		end if
	end tell

end accessInfo

to updateTemplate(_template, _name, _app, _docPath)
	if _app is "MindNode Pro" then
		set template_file to _template & "/contents.xml"
	else if _app is "Mindjet MindManager" then
		set template_file to _template & "/Document.xml"
	else
		set template_file to _template
	end if
	set _contents to readFile(template_file)
	set _res to snr("%%TITLE%%", _name, _contents)
	set _res to snr("%%DATE%%", dateNow, _res)
	set _res to snr("%%FILEPATH%%", srcPath, _res)
	set _res to snr("%%FILENAME%%", fileName, _res)
	set eof of template_file to 0
	writeFile(template_file, _res)
	if _app is "iThoughtsX" then
		set _target to snr("/", "_", _name) & ".itmz"
		do shell script "cd " & _docPath & " && zip " & quoted form of _target & " map.itm && rm map.itm"
	else if _app is "Mindjet MindManager" then
		set _target to _name & ".mmap"
		do shell script "cd " & quoted form of _template & " && zip ../" & quoted form of _target & " * && cd .. && rm -rf " & quoted form of _template
	end if
end updateTemplate

to readFile(unixPath)
	set foo to (open for access (POSIX file unixPath))
	set txt to (read foo for (get eof foo) as «class utf8»)
	close access foo
	return txt
end readFile

on writeFile(unixPath, _content)
	set newFile to POSIX file unixPath
	open for access newFile with write permission
	set eof of newFile to 0
	write _content to newFile
	close access newFile
end writeFile

to displayMessage(msgName, msgTitle, msgText)

	-- Check to see if it's running
	tell application "System Events"
		set growlRunning to (count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
	end tell

	-- Register Growl
	if growlRunning then
		tell application id "com.Growl.GrowlHelperApp"
			-- Make a list of all the notification types
			-- that this script will ever send:
			set the allNotificationsList to ¬
				{"Operations", "Errors"}

			-- Make a list of the notifications
			-- that will be enabled by default.
			-- Those not enabled by default can be enabled later
			-- in the 'Applications' tab of the Growl preferences.
			set the enabledNotificationsList to ¬
				{"Operations", "Errors"}

			-- Register our script with growl.
			-- You can optionally (as here) set a default icon
			-- for this script's notifications.
			register as application ¬
				"TaskPaper Extended Notes" all notifications allNotificationsList ¬
				default notifications enabledNotificationsList ¬
				icon of application "TaskPaper"
		end tell
	end if

	-- Display the Message
	if growlRunning then
		tell application id "com.Growl.GrowlHelperApp"
			notify with name ¬
				msgName title ¬
				msgTitle description ¬
				msgText application name ¬
				"TaskPaper Extended Notes"
		end tell
	else

		display notification msgText with title msgName

	end if

end displayMessage

on findBetween(startTag, endTag, theString)
	set atid to text item delimiters
	set text item delimiters to startTag
	set _output to ""
	set textItems to text items of theString
	if (count of textItems) > 1 then
		set _right to item 2 of textItems
		set text item delimiters to endTag
		set textItems to text items of _right
		if (count of textItems) > 1 then
			set _output to item 1 of textItems as string
		end if
	end if

	set text item delimiters to atid
	return _output
end findBetween

--search and replace function for template
on snr(tofind, toreplace, theString)
	set atid to text item delimiters
	set text item delimiters to tofind
	set textItems to text items of theString
	set text item delimiters to toreplace
	if (class of theString is string) then
		set res to textItems as string
	else -- (assume Unicode)
		set res to textItems as Unicode text
	end if
	set text item delimiters to atid
	return res
end snr

-- urlencode
on urlencode(theText) -- http://harvey.nu/applescript_url_encode_routine.html
	set theTextEnc to ""
	repeat with eachChar in characters of theText
		set useChar to eachChar
		set eachCharNum to ASCII number of eachChar
		if eachCharNum = 32 then
			set useChar to "+"
		else if (eachCharNum ≠ 42) and (eachCharNum ≠ 95) and (eachCharNum < 45 or eachCharNum > 46) and (eachCharNum < 48 or eachCharNum > 57) and (eachCharNum < 65 or eachCharNum > 90) and (eachCharNum < 97 or eachCharNum > 122) then
			set firstDig to round (eachCharNum / 16) rounding down
			set secondDig to eachCharNum mod 16
			if firstDig > 9 then
				set aNum to firstDig + 55
				set firstDig to ASCII character aNum
			end if
			if secondDig > 9 then
				set aNum to secondDig + 55
				set secondDig to ASCII character aNum
			end if
			set numHex to ("%" & (firstDig as string) & (secondDig as string)) as string
			set useChar to numHex
		end if
		set theTextEnc to theTextEnc & useChar as string
	end repeat
	return theTextEnc
end urlencode

--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
