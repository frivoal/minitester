/* Copyright (c) 2009, Florian Rivoal
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY Florian Rivoal ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL Florian Rivoal BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef MT_H
#define MT_H

#define _MT_QUOTEME(x) #x
#define MT_QUOTEME(x) _MT_QUOTEME(x)

#define MT_ASSERT(expr) \
do \
{ \
	mt_status->nb_assert++; \
	if(expr) \
	{ \
		mt_status->nb_assert_passed++; \
	} \
	else \
	{ \
		mt_append_message( mt_status, __FILE__ ":" MT_QUOTEME(__LINE__) ": Assertion failed: " #expr ); \
	} \
} while(0)

#define MT_ABORT()\
do \
{ \
	mt_status->aborting = 1; \
	mt_append_message( mt_status, __FILE__ ":" MT_QUOTEME(__LINE__) ": Aborting" ); \
	return; \
} while(0)

typedef struct _mt_message_node
{
	char * msg;
	struct _mt_message_node * next;
} mt_message_node;

typedef struct _mt_message_list
{
	mt_message_node * first;
	mt_message_node * last;

} mt_message_list;

typedef struct
{
	unsigned int nb_test;
	unsigned int nb_test_run;
	unsigned int nb_assert;
	unsigned int nb_assert_passed;
	mt_message_list messages;
	unsigned int aborting;
} mt_status_t;

mt_status_t * mt_status;

void mt_init_status( mt_status_t * stat, unsigned int total_test );
void mt_cleanup_status( mt_status_t * stat );
void mt_append_message( mt_status_t * stat, char * msg );
void mt_print_status( mt_status_t * stat, int verbose );
int mt_success( mt_status_t * stat );
void mt_process_args( int argc, const char ** argv, int * verbose );


#endif // MT_H
