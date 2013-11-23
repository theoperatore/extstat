Gem::Specification.new do |s|
	s.name        = 'extstat'
	s.version     = '0.5.2'
	s.date        = '2013-11-23'
	s.summary     = "Traverse a file hierarchy and return statistics about that hierarchy"
	s.description = "Uses Find to traverse a file hierarchy and log which extentions occur, file sizes, directory count, ratios of file sizes to entire size of hierarchy per extension."
	s.authors     = ["Alex Petersen"]
	s.email       = 'theoperatore@gmail.com'
	s.files       = ["lib/extstat.rb"]
	s.homepage    = 'http://theoperatore.github.io/extstat'
	s.license     = 'MIT'
	s.bindir      = 'bin'
	s.executables << 'extstat'
end
