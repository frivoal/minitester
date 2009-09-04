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

module MiniTester
class Generator
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
		@program += @suites.inject("") { |code, suite| code + suite.runner }
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
	def add_suite(suite)
		@suites << suite
	end
	def write_output(file)
		generate_program
		file.write @program
	end
end
end
