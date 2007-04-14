= xattr
	
== DESCRIPTION

Xattr provides the xattr (setxattr, getxattr, removexattr, listxattr)
functions in a nice object-oriented wrapper. Ruby/DL is used so no compilation
of modules is necessary.

Extended attributes extend the basic attributes associated with files and
directories in the file system. They are stored as name:data pairs associated
with file system objects (files, directories, symlinks, etc).

== SYNOPSIS

Using the library:

	require "xattr"

	xattr = Xattr.new("/path/to/file")
	xattr.list # => [...]
	xattr.get("...")
	xattr.set("...", "...")
	xattr.remove("...")
	
Using the provided command-line tool:
	
	$ xattr README.txt
	com.macromates.caret
	$ xattr README.txt com.macromates.caret 
	{column = 9; line = 26; }
	$ xattr README.txt com.macromates.caret "{column = 0; line = 0; }"
	{column = 0; line = 0; }
	$ xattr README.txt -com.macromates.caret
	{column = 0; line = 0; }
	$ xattr README.txt
	$ 
	
== REQUIREMENTS

* Mac OS X 10.4 (for now...)

== INSTALL

Using rubygems:

	$ sudo gem install xattr
	
Using setup.rb:

	$ sudo ruby setup.rb

== LICENSE

(The MIT License)

Copyright (c) 2007 Daniel Harple <dharple@generalconsumption.org>
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
