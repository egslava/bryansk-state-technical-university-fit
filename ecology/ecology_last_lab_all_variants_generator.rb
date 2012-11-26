require "./ecology_last_lab.rb"

(1..31).each{ |variant|
	File.open( "variant-#{variant}.txt", "w"){ |variantFile|
		print_solution(variant){|str|
			variantFile.puts (str);
		};
	}
}