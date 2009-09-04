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
class Suite
	include Enumerable
	attr_reader :name
	def initialize(name)
		@name = name.sub(/\.o$/, "")
		@tests = []
		find_tests
	end

	private
	def find_tests
		symbols = `readelf -sW #{@name}.o `
		symbols.each_line do |line|
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
		inject("") { |code,test| code + "void test_#{test}();\n" }
	end

	def body
		inject("void suite_#{@name}()\n{\n") do |code, test|
			code + "\ttest_#{test}();\n" +
			"\tif( mt_status->aborting ) { mt_status->aborting = 0; } else { mt_status->nb_test_run++; }\n"
		end + "}\n"
	end	
	def runner
		code = <<EOS
	printf("Running test suite: \\"#{name}\\"...\\n");
	suite_#{name}();
EOS
	end
	private :find_tests
end
end
