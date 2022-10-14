/*
 * Copyright © 2019-2022 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "bbc_native.h"

#define BASIC_LINE_START (char)0x0d
#define BASIC_T_LINE_NUM (char)0x8d
#define BASIC_T_DATA     (char)0xdc
#define BASIC_T_REM      (char)0xf4

#define MAX_TOKEN_LEN    8

static char* Tokens[] = {
"AND",   "DIV",    "EOR",     "MOD",   "OR",      "ERROR", "LINE",   "OFF",
"STEP",  "SPC",    "TAB(",    "ELSE",  "THEN",    NULL,    "OPENIN", "PTR",
"PAGE",  "TIME",   "LOMEM",   "HIMEM", "ABS",     "ACS",   "ADVAL",  "ASC",
"ASN",   "ATN",    "BGET",    "COS",   "COUNT",   "DEG",   "ERL",    "ERR",
"EVAL",  "EXP",    "EXT",     "FALSE", "FN",      "GET",   "INKEY",  "INSTR(",
"INT",   "LEN",    "LN",      "LOG",   "NOT",     "OPENUP","OPENOUT","PI",
"POINT(","POS",    "RAD",     "RND",   "SGN",     "SIN",   "SQR",    "TAN",
"TO",    "TRUE",   "USR",     "VAL",   "VPOS",    "CHR$",  "GET$",   "INKEY$",
"LEFT$(","MID$(",  "RIGHT$(", "STR$",  "STRING$(","EOF",   "AUTO",   "DELETE",
"LOAD",  "LIST",   "NEW",     "OLD",   "RENUMBER","SAVE",  NULL,     "PTR",
"PAGE",  "TIME",   "LOMEM",   "HIMEM", "SOUND",   "BPUT",  "CALL",   "CHAIN",
"CLEAR", "CLOSE",  "CLG",     "CLS",   "DATA",    "DEF",   "DIM",    "DRAW",
"END",   "ENDPROC","ENVELOPE","FOR",   "GOSUB",   "GOTO",  "GCOL",   "IF",
"INPUT", "LET",    "LOCAL",   "MODE",  "MOVE",    "NEXT",  "ON",     "VDU",
"PLOT",  "PRINT",  "PROC",    "READ",  "REM",     "REPEAT","REPORT", "RESTORE",
"RETURN","RUN",    "STOP",    "COLOUR","TRACE",   "UNTIL", "WIDTH",  "OSCLI" };

VALUE cBasicFile;

static VALUE basicfile_initialize(VALUE self, VALUE data, VALUE lines)
{
    rb_iv_set(self, "@data", data);
    rb_iv_set(self, "@lines", lines);
    return self;
}

static void process_data_vals(VALUE data, int line_num, char* p,
                              const char* nextline)
{
    while(*p == ' ')
    {
        p++;
    }

    if(*p != BASIC_T_DATA)
    {
        return;
    }

    VALUE linedata = rb_ary_new();
    p++;

    do
    {
        char* start = p;

        while(p < nextline && *p != ',')
        {
            p++;
        }

        char* end = p - 1;

        while(*start == ' ')
        {
            start++;
        }

        rb_ary_push(linedata, rb_str_new(start, (end - start) + 1));
    }
    while(p++ < nextline);

    rb_hash_aset(data, INT2NUM(line_num), linedata);
}

static void inline_line_num(const uint8_t* p, char** lp)
{
    // Many thanks to Matt Godbolt for describing the line number format:
    // https://xania.org/200711/bbc-basic-line-number-format

    int top2 = (p[1] << 2) & 0xc0;  // Top two bits of LSB
    int lsb = top2 ^ p[2];          // XOR with middle byte to form the LSB

    top2 = (p[1] << 4) & 0xc0;      // Top two bits of MSB
    int msb = top2 ^ p[3];          // XOR with final byte to form the MSB

    *lp += sprintf(*lp, "%d", lsb | (msb << 8));
}

static VALUE parse(VALUE self, VALUE bbcfile)
{
    VALUE content = rb_funcall(bbcfile, rb_intern("content"), 0);

    char* input = RSTRING_PTR(content);
    char* endinput = input + RSTRING_LEN(content);

    VALUE data = rb_hash_new();
    VALUE lines = rb_hash_new();

    char line[MAX_TOKEN_LEN * 251];

    for(char* p = input; p <= endinput; )
    {
        char* linestart = p;
        char* lp = line;

        if(*p++ != BASIC_LINE_START)
        {
            return Qnil;
        }

        if((*p & 0x80) != 0)
        {
            // BASIC sets the first byte of the line number to 0xff to signify
            // EOF but actually only checks the first bit when reading a file
            break;
        }

        int line_num = (uint8_t)*p++ << 8;
        line_num |= (uint8_t)*p++;

        char* nextline = linestart + (uint8_t)*p++;
        process_data_vals(data, line_num, p, nextline);

        int in_string = FALSE;

        while(p < nextline)
        {
            if(*p == '"')
            {
                in_string = !in_string;
            }

            if(!in_string && (*p & 0x80) != 0)
            {
                if(*p == BASIC_T_LINE_NUM)
                {
                    inline_line_num((uint8_t*)p, &lp);
                    p += 4;
                }
                else
                {
                    char* token = Tokens[*p & 0x7f];

                    if(token == NULL)
                    {
                        return Qnil;
                    }

                    size_t length = strlen(token);
                    memcpy(lp, token, length);
                    lp += length;

                    if(*p++ == BASIC_T_REM)
                    {
                        length = (size_t)(nextline - p);
                        memcpy(lp, p, length);
                        lp += length;
                        break;
                    }
                }
            }
            else
            {
                *lp++ = *p++;
            }
        }

        VALUE linestr = rb_str_new(line, lp - line);
        rb_hash_aset(lines, INT2NUM(line_num), linestr);

        p = nextline;
    }

    VALUE argv[] = {data, lines};
    return rb_class_new_instance(ARRAY_LEN(argv), argv, cBasicFile);
}

static VALUE to_html(VALUE self)
{
    VALUE lines = rb_iv_get(self, "@lines");
    size_t size = RHASH_SIZE(lines);

    VALUE* linenums = RARRAY_PTR(rb_funcall(lines, rb_intern("keys"), 0));
    VALUE text = rb_str_new_cstr("");

    for(int i = 0; i < size; i++)
    {
        VALUE linenum = linenums[i];

        rb_str_catf(text, "%5d", NUM2INT(linenum));
        rb_str_append(text, rb_hash_aref(lines, linenum));
        rb_str_cat_cstr(text, "\r");
    }

    return mode7_mem_to_html(mode7_text_to_mem(text));
}

void init_basic_file(VALUE mBBC)
{
    cBasicFile = rb_define_class_under(mBBC, "BasicFile", rb_cObject);

    rb_define_attr(cBasicFile, "data", 1, 0);
    rb_define_attr(cBasicFile, "lines", 1, 0);

    rb_define_method(cBasicFile, "initialize", basicfile_initialize, 2);
    rb_define_method(cBasicFile, "to_html", to_html, 0);

    rb_define_singleton_method(cBasicFile, "parse", parse, 1);
}
