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

require 'lib/testsuite.rb'
require 'lib/testgenerator.rb'

if ARGV.size < 2 || ARGV[0] == "-h" || ARGV[0] == "--help"
	print <<EOS
Testgen is part of Mini Tester
Copyright (c) 2009, Florian Rivoal

Usage:
	testgen.rb <out.c> <test_suite_1> [<test_suite_2> ...]

The files designated as test suites must be .o files. Testgen will automatically
find all the functions in these .o files beginning with the word "test_", and
generate a simple c program to run all these tests.

This programm should be compiled, then linked against mt.o, the test suites' o
files, and all the .o files that the test suites depend on themselves.
EOS
	exit 1
end

generator = MiniTester::Generator.new
ARGV[1..-1].each do |file|
	generator.add_suite(MiniTester::Suite.new file)
end
File.open(ARGV[0],"w") do |file|
	generator.write_output file
end




