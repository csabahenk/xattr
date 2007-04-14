# Copyright (c) 2007 Daniel Harple <dharple@generalconsumption.org>

require "hoe"
require "lib/xattr"

hoe = Hoe.new("xattr", Xattr::VERSION) do |t|
  t.author = "Daniel Harple"
  t.changes = t.paragraphs_of("History.txt", 0..1).join("\n\n")
  readme = File.read("README.txt")
  t.description = readme[0, readme.index("== LICENSE")]
  t.summary = t.paragraphs_of("README.txt", 1).to_s
  t.email = "dharple@generalconsumption.org"
  t.url = "http://rubyforge.org/projects/xattr"
  t.clean_globs << ".DS_Store"
end

# Remove dependency on hoe for gem
hoe.extra_deps = []
hoe.spec.__send__(:dependencies=, [])
