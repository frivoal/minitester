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

#include "mt.h"
#include "stdlib.h"
#include "stdio.h"

void mt_append_message( mt_status * stat, char * msg)
{
	mt_message_node * node;
	mt_message_list * list;

	list = &stat->messages;

	node = malloc( sizeof( mt_message_node ) );
	if(!node) return;
	node->msg = msg;
	node->next = NULL;

	if (list->last)
	{
		list->last->next = node;
		list->last = node;
	}
	else
	{
		list->first = list->last = node;
	}
}

void mt_cleanup_status( mt_status * stat)
{
	mt_message_node * current;
	mt_message_node * next;

	for( current = stat->messages.first; current != NULL; current = next)
	{
		next = current->next;
		free(current);
	}

	stat->messages.first = NULL;
	stat->messages.last = NULL;
	free(stat);
}

void mt_init_status( mt_status * stat, unsigned int total_test)
{
	stat->nb_test = total_test;
	stat->nb_test_run = 0;
	stat->nb_assert = 0;
	stat->nb_assert_passed = 0;
	stat->messages.first = NULL;
	stat->messages.last = NULL;
}

void mt_print_status( mt_status * stat )
{
	mt_message_node * node;

	for( node = stat->messages.first; node != NULL; node = node->next)
	{
		printf(" * %s\n",node->msg);
	}
	printf( "Number of tests executed: %d / %d\n", stat->nb_test_run, stat->nb_test);
	printf( "Number of asserts passed: %d / %d\n", stat->nb_assert_passed, stat->nb_assert);

}

int mt_success( mt_status * stat )
{
	return stat->nb_test == stat->nb_test_run && stat->nb_assert == stat->nb_assert_passed;
}
