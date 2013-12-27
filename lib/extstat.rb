require 'optparse';
require 'ostruct';
require 'find';

class ExtStat

	VERSION = '0.5.2';


	def self.parse(args)


		arg_data = OpenStruct.new;
		arg_data.verbose         = false;
		arg_data.human_readable  = false;
		arg_data.directory       = Dir.pwd;
		arg_data.extension       = "";
		arg_data.all             = false;

		opt_parser = OptionParser.new do |opts|
			opts.banner = "\nUsage: extstat [OPTIONS] [DIRECTORY]";
			opts.separator("");
			opts.separator("Options:");

			#search all directories, including hidden directories
			opts.on('-a', 'Traverse all directories and files including those that are hidden') do
				arg_data.all = true;
			end

			#only search for the specified extension
			opts.on('-e', '--extension EXTENSION', 'Search for only the specified EXTENSION') do |e|
				arg_data.extension = e;
			end

			#output help message
			opts.on('--help', 'Display this message') do 
				puts opts;
				exit 0;
			end

			#output values in human-readable format
			opts.on('-h','--human-readable','Display file sizes in a human-readable format') do 
				arg_data.human_readable = true;
			end

			#Set verbose mode
			opts.on('-v','--verbose', 'Run verbosely') do
				arg_data.verbose = true;
			end

			#Return the version
			opts.on('--version','Return the version of this tool') do
				puts VERSION;
				exit 0;
			end

			opts.separator("");

		end

		begin 
			#parse ARGV
			leftover = opt_parser.parse!(args);

			#grab the directory to search through
			if leftover.length != 0

				arg_data.directory = leftover[0];
				#arg_data.directory = (args[args.length-1][-1] === "/") ? args[args.length-1] : "#{args[args.length-1]}/";
				#arg_data.directory = (arg_data.directory[0]   === "/") ? arg_data.directory  : "./#{arg_data.directory}";
			end


			#return the specified data
			arg_data;

		rescue OptionParser::InvalidOption, OptionParser::MissingArgument => err
			#tell the user what happened,
			puts err.message;

			#show the user the correct syntax
			puts opt_parser;

			#exit with non-zero code because there was an error
			exit 1;
		end

	end

	def self.search(options) 
		stats = OpenStruct.new;
		stats.filecount  = 0;
		stats.dircount   = 0;
		stats.totalsize  = 0;
		stats.countsize  = 0;
		stats.extentions = [];
		stats.files      = [];
		stats.skipped    = [];
		stats.startTime  = Time.new;

		begin

			Find.find(options.directory) do |path|

				#output to user if verbose
				puts "Traversing: #{path}" if options.verbose;

				if (FileTest.directory?(path))
					stats.dircount += 1;

					#skip hidden folders unless specified
					if (File.basename(path)[0] == "." && options.all == false)
						puts "Skipping: #{path}" if options.verbose;
						stats.skipped.push(path);
						Find.prune();

					#don't search through the /dev folder but count it's directory size
					elsif (File.basename(path) =~ /(dev)/)
						puts "Skipping #{path}" if options.verbose;

						stats.totalsize += FileTest.size?(path) if FileTest.size?(path) != nil;

						Find.prune();
						

					#don't search through connected volumes unless specified
					elsif (File.basename(path) =~ /(Volumes)/ && options.all == false)
						puts "Skipping: #{path}" if options.verbose;
						stats.skipped.push(path);
						Find.prune();
					end

				else
					if (File.basename(path) =~ /\.(#{options.extension})/)
						stats.filecount += 1;
						stats.files.push(path);
						stats.countsize += FileTest.size?(path) if FileTest.size?(path) != nil;
						stats.totalsize += FileTest.size?(path) if FileTest.size?(path) != nil;
					else
						stats.totalsize += FileTest.size?(path) if FileTest.size?(path) != nil;
					end
				end
			end
		rescue Errno::EBADF, Errno::ENOENT => err
			puts err.message;
			exit 1;
		end

		stats.endTime = Time.new;
		stats.dTime = stats.endTime - stats.startTime;
		stats;
	end
end

