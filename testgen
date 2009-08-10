#!/usr/bin/ruby

# Copyright (c) 2009, Florian Rivoal
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY Florian Rivoal ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Florian Rivoal BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class TestSuite
	attr_reader :name
	def initialize(name)
		@name = name.sub(/\.o$/, "")
		@tests = []
		find_tests
	end

	private
	def find_tests
		symbols = `readelf -sW #{@name}.o `.split "\n"
		symbols.each do |line|
			if line =~ /FUNC *GLOBAL.*test_(.*)/
				@tests << $1
			end
		end
	end

	public
	def size
		@tests.size
	end
	def each
		@tests.each { |test| yield test }
	end
	def declarations
		code = ""
		each { |test| code += "void test_#{test}();\n" }
		return code
	end

	def body
		code = "void suite_#{@name}()\n{\n"
		each do |test|
			code += "\ttest_#{test}();\n"
			code += "\tif( mt_status->aborting ) { mt_status->aborting = 0; } else { mt_status->nb_test_run++; }\n"
		end
		code += "}\n"
	end	
	def runner
		code = <<EOS
	printf("Running test suite: \\"#{name}\\"...\\n");
	suite_#{name}();
EOS
	end
	private :find_tests
end

class TesterGenerator
	def initialize
		@suites = []
	end

	private
	def generate_includes
		@program = <<EOS
#include "mt.h"
#include "stdlib.h"
#include "stdio.h"

EOS
	end
	def generate_suites
		@suites.each do |suite|
			@program += suite.declarations
			@program += suite.body
			@program += "\n"
		end
	end
	def generate_main_opening
		@program += <<EOS
int main()
{
	int res;
	mt_status = malloc( sizeof( mt_status_t ) );
	mt_init_status( mt_status, #{@suites.inject(0) {|sum, suite| sum + suite.size }} );

EOS
	end
	def generate_main_body
		@suites.each do |suite|
			@program += suite.runner
		end
	end
	def generate_main_closing
		@program += <<EOS
	mt_print_status( mt_status );

	res = !mt_success( mt_status );
	mt_cleanup_status( mt_status );
	return res;
}
EOS
	end
	def generate_program
		generate_includes
		generate_suites
		generate_main_opening
		generate_main_body
		generate_main_closing
	end

	public
	def add_suite(file)
		@suites << (TestSuite.new file)
	end
	def write_output(file)
		generate_program
		File.open(ARGV[0],"w") do |file|
			file.write @program
		end
	end
end

if ARGV.size < 2 || ARGV[0] == "-h" || ARGV[0] == "--help"
	print <<EOS
Testgen is part of Mini Tester
Copyright (c) 2009, Florian Rivoal

Usage:
	testgen <out.c> <test_suite_1> [<test_suite_2> ...]

The files designated as test suites must be .o files. Testgen will automatically
find all the functions in these .o files beginning with the word "test_", and
generate a simple c program to run all these tests.

This programm should be compiled, then linked against mt.o, the test suites' o
files, and all the .o files that the test suites depend on themselves.
EOS
	exit 1
end

generator = TesterGenerator.new
ARGV[1..-1].each do |file|
	generator.add_suite file
end
generator.write_output ARGV[0]




