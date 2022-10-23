/*
 * Copyright © 2007-2022 Matt Robinson
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <ruby/encoding.h>

#include "bbc_native.h"

typedef enum
{
    COL_BLACK = 0,
    COL_RED = 1,
    COL_GREEN = 2,
    COL_YELLOW = 3,
    COL_BLUE = 4,
    COL_MAGENTA = 5,
    COL_CYAN = 6,
    COL_WHITE = 7
} Colour;

const char* fgClasses[] = { "t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7" };
const char* bgClasses[] = { "b0", "b1", "b2", "b3", "b4", "b5", "b6", "b7" };

typedef enum
{
    OFS_TXT_DBL_UPPER = 0xE000,
    OFS_TXT_DBL_LOWER = 0xE100,
    OFS_GFX_STANDARD  = 0xE200,
    OFS_GFX_DBL_UPPER = 0xE240,
    OFS_GFX_DBL_LOWER = 0xE280,
    OFS_GFX_SEPARATED = 0xC0
} Offsets;

typedef enum
{
    MODE_TEXT,
    MODE_GRAPHICS
} Mode;

typedef enum
{
    HEIGHT_STANDARD,
    HEIGHT_DBL_UPPER,
    HEIGHT_DBL_LOWER
} Height;

uint32_t textval(uint32_t chval, Height height)
{
    switch(height)
    {
        case HEIGHT_STANDARD:
            return chval;
        case HEIGHT_DBL_LOWER:
            return OFS_TXT_DBL_LOWER + chval;
        default:
            return OFS_TXT_DBL_UPPER + chval;
    }
}

uint32_t graphval(uint32_t value, Height height, bool separated)
{
    uint32_t charval;

    switch(height)
    {
        case HEIGHT_STANDARD:
            charval = OFS_GFX_STANDARD + value;
            break;
        case HEIGHT_DBL_UPPER:
            charval = OFS_GFX_DBL_UPPER + value;
            break;
        default:
            charval = OFS_GFX_DBL_LOWER + value;
            break;
    }

    if(separated)
    {
        charval += OFS_GFX_SEPARATED;
    }

    return charval;
}

VALUE mode7_mem_to_html(VALUE input)
{
    int row = 0;
    int column = 0;

    Mode mode = MODE_TEXT;
    Colour forecolour = COL_WHITE;
    Colour nextfore = COL_WHITE;
    Colour backcolour = COL_BLACK;
    Height height = HEIGHT_STANDARD;

    bool flash = false;
    bool separated = false;
    bool graphicshold = false;
    bool concealed = false;
    bool spanopen = false;

    uint32_t lastchar = '\0';

    Height prevheights[MODE7_COLS];

    for(int i = 0; i < MODE7_COLS; i++)
    {
        prevheights[i] = HEIGHT_STANDARD;
    }

    char* data = RSTRING_PTR(input);
    long dataLen = RSTRING_LEN(input);

    VALUE output = rb_str_buf_new(dataLen);
    rb_enc_set_index(output, rb_utf8_encindex());

    for(long i = 0; i < dataLen; i++)
    {
        bool stylechange;
        uint32_t thischar;

        char c = data[i] & 0x7F;

        if(forecolour != nextfore)
        {
            forecolour = nextfore;
            stylechange = true;
        }
        else
        {
            stylechange = false;
        }

        switch(c)
        {
            case 0:
            case 11:
            case 14:
            case 15:
            case 16:
            case 27:
                // "Nothing" in the user guide - displays as a space
            case 32:
                thischar = ' ';
                break;
            case 33:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('!', height);
                }
                else
                {
                    thischar = graphval(1, height, separated);
                }

                break;
            case 34:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('"', height);
                }
                else
                {
                    thischar = graphval(2, height, separated);
                }

                break;
            case 35:
                if(mode == MODE_TEXT)
                {
                    thischar = textval(0xA3, height); // £
                }
                else
                {
                    thischar = graphval(3, height, separated);
                }

                break;
            case 36:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('$', height);
                }
                else
                {
                    thischar = graphval(4, height, separated);
                }

                break;
            case 37:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('%', height);
                }
                else
                {
                    thischar = graphval(5, height, separated);
                }

                break;
            case 38:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('&', height);
                }
                else
                {
                    thischar = graphval(6, height, separated);
                }

                break;
            case 39:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('\'', height);
                }
                else
                {
                    thischar = graphval(7, height, separated);
                }

                break;
            case 40:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('(', height);
                }
                else
                {
                    thischar = graphval(8, height, separated);
                }

                break;
            case 41:
                if(mode == MODE_TEXT)
                {
                    thischar = textval(')', height);
                }
                else
                {
                    thischar = graphval(9, height, separated);
                }

                break;
            case 42:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('*', height);
                }
                else
                {
                    thischar = graphval(10, height, separated);
                }

                break;
            case 43:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('+', height);
                }
                else
                {
                    thischar = graphval(11, height, separated);
                }

                break;
            case 44:
                if(mode == MODE_TEXT)
                {
                    thischar = textval(',', height);
                }
                else
                {
                    thischar = graphval(12, height, separated);
                }

                break;
            case 45:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('-', height);
                }
                else
                {
                    thischar = graphval(13, height, separated);
                }

                break;
            case 46:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('.', height);
                }
                else
                {
                    thischar = graphval(14, height, separated);
                }

                break;
            case 47:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('/', height);
                }
                else
                {
                    thischar = graphval(15, height, separated);
                }

                break;
            case 48:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('0', height);
                }
                else
                {
                    thischar = graphval(16, height, separated);
                }

                break;
            case 49:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('1', height);
                }
                else
                {
                    thischar = graphval(17, height, separated);
                }

                break;
            case 50:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('2', height);
                }
                else
                {
                    thischar = graphval(18, height, separated);
                }

                break;
            case 51:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('3', height);
                }
                else
                {
                    thischar = graphval(19, height, separated);
                }

                break;
            case 52:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('4', height);
                }
                else
                {
                    thischar = graphval(20, height, separated);
                }

                break;
            case 53:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('5', height);
                }
                else
                {
                    thischar = graphval(21, height, separated);
                }

                break;
            case 54:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('6', height);
                }
                else
                {
                    thischar = graphval(22, height, separated);
                }

                break;
            case 55:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('7', height);
                }
                else
                {
                    thischar = graphval(23, height, separated);
                }

                break;
            case 56:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('8', height);
                }
                else
                {
                    thischar = graphval(24, height, separated);
                }

                break;
            case 57:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('9', height);
                }
                else
                {
                    thischar = graphval(25, height, separated);
                }

                break;
            case 58:
                if(mode == MODE_TEXT)
                {
                    thischar = textval(':', height);
                }
                else
                {
                    thischar = graphval(26, height, separated);
                }

                break;
            case 59:
                if(mode == MODE_TEXT)
                {
                    thischar = textval(';', height);
                }
                else
                {
                    thischar = graphval(27, height, separated);
                }

                break;
            case 60:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('<', height);
                }
                else
                {
                    thischar = graphval(28, height, separated);
                }

                break;
            case 61:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('=', height);
                }
                else
                {
                    thischar = graphval(29, height, separated);
                }

                break;
            case 62:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('>', height);
                }
                else
                {
                    thischar = graphval(30, height, separated);
                }

                break;
            case 63:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('?', height);
                }
                else
                {
                    thischar = graphval(31, height, separated);
                }

                break;
            case 64:
                thischar = textval('@', height);
                break;
            case 65:
                thischar = textval('A', height);
                break;
            case 66:
                thischar = textval('B', height);
                break;
            case 67:
                thischar = textval('C', height);
                break;
            case 68:
                thischar = textval('D', height);
                break;
            case 69:
                thischar = textval('E', height);
                break;
            case 70:
                thischar = textval('F', height);
                break;
            case 71:
                thischar = textval('G', height);
                break;
            case 72:
                thischar = textval('H', height);
                break;
            case 73:
                thischar = textval('I', height);
                break;
            case 74:
                thischar = textval('J', height);
                break;
            case 75:
                thischar = textval('K', height);
                break;
            case 76:
                thischar = textval('L', height);
                break;
            case 77:
                thischar = textval('M', height);
                break;
            case 78:
                thischar = textval('N', height);
                break;
            case 79:
                thischar = textval('O', height);
                break;
            case 80:
                thischar = textval('P', height);
                break;
            case 81:
                thischar = textval('Q', height);
                break;
            case 82:
                thischar = textval('R', height);
                break;
            case 83:
                thischar = textval('S', height);
                break;
            case 84:
                thischar = textval('T', height);
                break;
            case 85:
                thischar = textval('U', height);
                break;
            case 86:
                thischar = textval('V', height);
                break;
            case 87:
                thischar = textval('W', height);
                break;
            case 88:
                thischar = textval('X', height);
                break;
            case 89:
                thischar = textval('Y', height);
                break;
            case 90:
                thischar = textval('Z', height);
                break;
            case 91:
                thischar = textval('[', height);
                break;
            case 92:
                thischar = textval(0x00BD, height); // ½
                break;
            case 93:
                thischar = textval(']', height);
                break;
            case 94:
                thischar = textval('^', height);
                break;
            case 95:
                thischar = textval('#', height);
                break;
            case 96:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('`', height);
                }
                else
                {
                    thischar = graphval(32, height, separated);
                }

                break;
            case 97:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('a', height);
                }
                else
                {
                    thischar = graphval(33, height, separated);
                }

                break;
            case 98:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('b', height);
                }
                else
                {
                    thischar = graphval(34, height, separated);
                }

                break;
            case 99:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('c', height);
                }
                else
                {
                    thischar = graphval(35, height, separated);
                }

                break;
            case 100:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('d', height);
                }
                else
                {
                    thischar = graphval(36, height, separated);
                }

                break;
            case 101:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('e', height);
                }
                else
                {
                    thischar = graphval(37, height, separated);
                }

                break;
            case 102:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('f', height);
                }
                else
                {
                    thischar = graphval(38, height, separated);
                }

                break;
            case 103:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('g', height);
                }
                else
                {
                    thischar = graphval(39, height, separated);
                }

                break;
            case 104:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('h', height);
                }
                else
                {
                    thischar = graphval(40, height, separated);
                }

                break;
            case 105:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('i', height);
                }
                else
                {
                    thischar = graphval(41, height, separated);
                }

                break;
            case 106:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('j', height);
                }
                else
                {
                    thischar = graphval(42, height, separated);
                }

                break;
            case 107:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('k', height);
                }
                else
                {
                    thischar = graphval(43, height, separated);
                }

                break;
            case 108:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('l', height);
                }
                else
                {
                    thischar = graphval(44, height, separated);
                }

                break;
            case 109:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('m', height);
                }
                else
                {
                    thischar = graphval(45, height, separated);
                }

                break;
            case 110:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('n', height);
                }
                else
                {
                    thischar = graphval(46, height, separated);
                }

                break;
            case 111:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('o', height);
                }
                else
                {
                    thischar = graphval(47, height, separated);
                }

                break;
            case 112:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('p', height);
                }
                else
                {
                    thischar = graphval(48, height, separated);
                }

                break;
            case 113:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('q', height);
                }
                else
                {
                    thischar = graphval(49, height, separated);
                }

                break;
            case 114:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('r', height);
                }
                else
                {
                    thischar = graphval(50, height, separated);
                }

                break;
            case 115:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('s', height);
                }
                else
                {
                    thischar = graphval(51, height, separated);
                }

                break;
            case 116:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('t', height);
                }
                else
                {
                    thischar = graphval(52, height, separated);
                }

                break;
            case 117:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('u', height);
                }
                else
                {
                    thischar = graphval(53, height, separated);
                }

                break;
            case 118:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('v', height);
                }
                else
                {
                    thischar = graphval(54, height, separated);
                }

                break;
            case 119:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('w', height);
                }
                else
                {
                    thischar = graphval(55, height, separated);
                }

                break;
            case 120:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('x', height);
                }
                else
                {
                    thischar = graphval(56, height, separated);
                }

                break;
            case 121:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('y', height);
                }
                else
                {
                    thischar = graphval(57, height, separated);
                }

                break;
            case 122:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('z', height);
                }
                else
                {
                    thischar = graphval(58, height, separated);
                }

                break;
            case 123:
                if(mode == MODE_TEXT)
                {
                    thischar = textval(0x00BC, height); // ¼
                }
                else
                {
                    thischar = graphval(59, height, separated);
                }

                break;
            case 124:
                if(mode == MODE_TEXT)
                {
                    thischar = textval('|', height);
                }
                else
                {
                    thischar = graphval(60, height, separated);
                }

                break;
            case 125:
                if(mode == MODE_TEXT)
                {
                    thischar = textval(0x00BE, height); // ¾
                }
                else
                {
                    thischar = graphval(61, height, separated);
                }

                break;
            case 126:
                if(mode == MODE_TEXT)
                {
                    thischar = textval(0x00F7, height); // ÷
                }
                else
                {
                    thischar = graphval(62, height, separated);
                }

                break;
            case 127:
                if(mode == MODE_TEXT)
                {
                    thischar = textval(0x00B6, height);
                }
                else
                {
                    thischar = graphval(63, height, separated);
                }

                break;
            case 1:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_TEXT;
                nextfore = COL_RED;
                concealed = false;
                graphicshold = false;
                break;
            case 2:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_TEXT;
                nextfore = COL_GREEN;
                concealed = false;
                graphicshold = false;
                break;
            case 3:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_TEXT;
                nextfore = COL_YELLOW;
                concealed = false;
                graphicshold = false;
                break;
            case 4:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_TEXT;
                nextfore = COL_BLUE;
                concealed = false;
                graphicshold = false;
                break;
            case 5:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_TEXT;
                nextfore = COL_MAGENTA;
                concealed = false;
                graphicshold = false;
                break;
            case 6:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_TEXT;
                nextfore = COL_CYAN;
                concealed = false;
                graphicshold = false;
                break;
            case 7:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_TEXT;
                nextfore = COL_WHITE;
                concealed = false;
                graphicshold = false;
                break;
            case 8:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                flash = true;
                stylechange = true;
                break;
            case 9:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                flash = false;
                stylechange = true;
                break;
            case 12:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    rb_fatal("Check if held graphics would be valid here");
                }

                thischar = ' ';
                height = HEIGHT_STANDARD;
                break;
            case 10:
            case 13:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    rb_fatal("Check if held graphics would be valid here");
                }

                thischar = ' ';

                if(prevheights[column] == HEIGHT_DBL_UPPER)
                {
                    height = HEIGHT_DBL_LOWER;
                }
                else
                {
                    height = HEIGHT_DBL_UPPER;
                }

                break;
            case 17:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_GRAPHICS;
                nextfore = COL_RED;
                concealed = false;
                break;
            case 18:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_GRAPHICS;
                nextfore = COL_GREEN;
                concealed = false;
                break;
            case 19:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_GRAPHICS;
                nextfore = COL_YELLOW;
                concealed = false;
                break;
            case 20:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_GRAPHICS;
                nextfore = COL_BLUE;
                concealed = false;
                break;
            case 21:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_GRAPHICS;
                nextfore = COL_MAGENTA;
                concealed = false;
                break;
            case 22:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_GRAPHICS;
                nextfore = COL_CYAN;
                concealed = false;
                break;
            case 23:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                mode = MODE_GRAPHICS;
                nextfore = COL_WHITE;
                concealed = false;
                break;
            case 24:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    rb_fatal("Check if held graphics would be valid here");
                }

                thischar = ' ';
                concealed = true;
                break;
            case 25:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                separated = false;
                break;
            case 26:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                separated = true;
                break;
            case 28:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                backcolour = COL_BLACK;
                stylechange = true;
                break;
            case 29:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                backcolour = forecolour;
                stylechange = true;
                break;
            case 30:
                if(lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                graphicshold = true;
                break;
            case 31:
                if(graphicshold == true && lastchar > OFS_GFX_STANDARD)
                {
                    thischar = lastchar;
                }
                else
                {
                    thischar = ' ';
                }

                graphicshold = false;
                break;
            default:
                rb_fatal("Unknown character value %d at line %d column %d", c, row, column);
        }

        if(concealed)
        {
            thischar = ' ';
        }

        if(stylechange)
        {
            if(spanopen)
            {
                rb_str_cat(output, STR_AND_LEN("</span>"));
                spanopen = false;
            }

            const char* classes[3];
            int classcount = 0;

            if(forecolour != COL_WHITE)
            {
                classes[classcount++] = fgClasses[forecolour];
            }

            if(backcolour != COL_BLACK)
            {
                classes[classcount++] = bgClasses[backcolour];
            }

            if(flash)
            {
                classes[classcount++] = "flash";
            }

            if(classcount > 0)
            {
                rb_str_cat(output, STR_AND_LEN("<span class="));

                if(classcount > 1)
                {
                    rb_str_cat(output, STR_AND_LEN("\""));
                }

                for(int j = 0; j < classcount; j++)
                {
                    if(j != 0)
                    {
                        rb_str_cat(output, STR_AND_LEN(" "));
                    }

                    rb_str_cat2(output, classes[j]);
                }

                if(classcount > 1)
                {
                    rb_str_cat(output, STR_AND_LEN("\""));
                }

                rb_str_cat(output, STR_AND_LEN(">"));
                spanopen = true;
            }
        }

        prevheights[column] = height;

        switch(thischar)
        {
            case '<':
                rb_str_cat(output, STR_AND_LEN("&lt;"));
                break;
            case '>':
                rb_str_cat(output, STR_AND_LEN("&gt;"));
                break;
            case '&':
                rb_str_cat(output, STR_AND_LEN("&amp;"));
                break;
            default:
                rb_str_concat(output, INT2FIX(thischar));
        }

        column++;

        if(column == MODE7_COLS)
        {
            column = 0;
            row++;
            mode = MODE_TEXT;
            forecolour = nextfore = COL_WHITE;
            backcolour = COL_BLACK;
            height = HEIGHT_STANDARD;
            flash = false;
            separated = false;
            graphicshold = false;
            concealed = false;

            lastchar = '\0';

            if(spanopen)
            {
                rb_str_cat(output, STR_AND_LEN("</span>"));
                spanopen = false;
            }

            rb_str_cat(output, STR_AND_LEN("\n"));
        }
        else
        {
            if(height != HEIGHT_STANDARD)
            {
                if(prevheights[column] == HEIGHT_DBL_UPPER)
                {
                    height = HEIGHT_DBL_LOWER;
                }
                else
                {
                    height = HEIGHT_DBL_UPPER;
                }
            }

            lastchar = thischar;
        }
    }

    if(RSTRING_PTR(output)[RSTRING_LEN(output) - 1] == '\n')
    {
        rb_str_set_len(output, RSTRING_LEN(output) - 1);
    }

    return output;
}
