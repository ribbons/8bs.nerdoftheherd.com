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
    OFS_GFX_DBL_UPPER = 0x40,
    OFS_GFX_DBL_LOWER = 0x80,
    OFS_GFX_SEPARATED = 0xC0
} Offsets;

typedef enum
{
    MODE_TEXT = 0x2,
    MODE_GRAPHICS = 0x1
} Mode;

typedef enum
{
    GFX_STYLE_CONTIGUOUS = 0x2,
    GFX_STYLE_SEPARATED = 0x3
} GraphicsStyle;

typedef enum
{
    HEIGHT_STANDARD = 0x2,
    HEIGHT_DOUBLE = 0x1
} Height;

typedef enum
{
    DOUBLE_UPPER = 0x2,
    DOUBLE_LOWER = 0x3
} HeightState;

typedef struct
{
    int length;
    char data[5];
} CharSequence;

CharSequence mappingTables[3][3][0x80];

enum
{
    MOSAIC_BITS = 0x20
};

static void set_mapping(CharSequence *dest, unsigned int codepoint)
{
    dest->length = rb_enc_codelen((int)codepoint, rb_utf8_encoding());
    rb_enc_mbcput(codepoint, dest->data, rb_utf8_encoding());
}

static void set_mapping_str(CharSequence *dest, char *str, int length)
{
    dest->length = length;
    memcpy(dest->data, str, (unsigned int)length);
}

void init_mode7_mapping_tables()
{
    for(unsigned int mode = 0; mode <= MODE_TEXT; mode++)
    {
        for(unsigned int height = 0; height <= HEIGHT_STANDARD; height++)
        {
            set_mapping(&mappingTables[mode][height][' '], ' ');
        }
    }

    for(unsigned int i = '!'; i < ARRAY_LEN(mappingTables[0][0]); i++)
    {
        unsigned int charbase;

        switch(i)
        {
            case 0x23:
                charbase = 0xA3; // £
                break;
            case 0x5C:
                charbase = 0xBD; // ½
                break;
            case 0x5F:
                charbase = '#';
                break;
            case 0x7B:
                charbase = 0xBC; // ¼
                break;
            case 0x7D:
                charbase = 0xBE; // ¾
                break;
            case 0x7E:
                charbase = 0xF7; // ÷
                break;
            case 0x7F:
                charbase = 0xB6;
                break;
            default:
                charbase = i;
        }

        for(unsigned int mode = 0; mode <= MODE_TEXT; mode++)
        {
            set_mapping(&mappingTables[mode][HEIGHT_STANDARD][i], charbase);
            set_mapping(&mappingTables[mode][HEIGHT_DOUBLE & DOUBLE_UPPER][i],
                        charbase + OFS_TXT_DBL_UPPER);
            set_mapping(&mappingTables[mode][HEIGHT_DOUBLE & DOUBLE_LOWER][i],
                        charbase + OFS_TXT_DBL_LOWER);
        }
    }

    set_mapping_str(&mappingTables[MODE_TEXT][HEIGHT_STANDARD]['<'], STR_AND_LEN("&lt;"));
    set_mapping_str(&mappingTables[MODE_TEXT][HEIGHT_STANDARD]['>'], STR_AND_LEN("&gt;"));
    set_mapping_str(&mappingTables[MODE_TEXT][HEIGHT_STANDARD]['&'], STR_AND_LEN("&amp;"));

    enum
    {
        GFX_CON = MODE_GRAPHICS & GFX_STYLE_CONTIGUOUS,
        GFX_SEP = MODE_GRAPHICS & GFX_STYLE_SEPARATED
    };

    unsigned int charbase = OFS_GFX_STANDARD;

    for(unsigned int i = '!'; i < ARRAY_LEN(mappingTables[0][0]); i++)
    {
        if(i == '@')
        {
            i = '`';
        }

        charbase++;

        set_mapping(&mappingTables[GFX_CON][HEIGHT_STANDARD][i],
                    charbase);
        set_mapping(&mappingTables[GFX_CON][HEIGHT_DOUBLE & DOUBLE_UPPER][i],
                    charbase + OFS_GFX_DBL_UPPER);
        set_mapping(&mappingTables[GFX_CON][HEIGHT_DOUBLE & DOUBLE_LOWER][i],
                    charbase + OFS_GFX_DBL_LOWER);

        set_mapping(&mappingTables[GFX_SEP][HEIGHT_STANDARD][i],
                    charbase + OFS_GFX_SEPARATED);
        set_mapping(&mappingTables[GFX_SEP][HEIGHT_DOUBLE & DOUBLE_UPPER][i],
                    charbase + OFS_GFX_DBL_UPPER + OFS_GFX_SEPARATED);
        set_mapping(&mappingTables[GFX_SEP][HEIGHT_DOUBLE & DOUBLE_LOWER][i],
                    charbase + OFS_GFX_DBL_LOWER + OFS_GFX_SEPARATED);
    }
}

VALUE mode7_mem_to_html(VALUE input)
{
    int column = 0;

    Mode mode = MODE_TEXT;
    GraphicsStyle gfxstyle = GFX_STYLE_CONTIGUOUS;
    Colour forecolour = COL_WHITE;
    Colour nextfore = COL_WHITE;
    Colour backcolour = COL_BLACK;
    Height height = HEIGHT_STANDARD;

    bool flash = false;
    bool graphicshold = false;
    bool concealed = false;
    bool spanopen = false;

    CharSequence* lastgfxchar = NULL;
    CharSequence* holdchar = &mappingTables[MODE_TEXT][HEIGHT_STANDARD][' '];

    HeightState heightstates[MODE7_COLS];

    for(int i = 0; i < MODE7_COLS; i++)
    {
        heightstates[i] = DOUBLE_UPPER;
    }

    char* data = RSTRING_PTR(input);
    long dataLen = RSTRING_LEN(input);

    VALUE output = rb_str_buf_new(dataLen);
    rb_enc_set_index(output, rb_utf8_encindex());

    for(long i = 0; i < dataLen; i++)
    {
        bool stylechange;
        CharSequence* thischar;

        unsigned char c = data[i] & 0x7F;

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
            case 0x00:
            case 0x0A:
            case 0x0B:
            case 0x0E:
            case 0x0F:
            case 0x10:
            case 0x1B:
                thischar = holdchar;
                break;
            case 0x01:
            case 0x02:
            case 0x03:
            case 0x04:
            case 0x05:
            case 0x06:
            case 0x07:
                thischar = holdchar;
                mode = MODE_TEXT;
                nextfore = c;
                concealed = false;
                graphicshold = false;
                holdchar = &mappingTables[MODE_TEXT][HEIGHT_STANDARD][' '];
                break;
            case 0x08:
                thischar = holdchar;
                flash = true;
                stylechange = true;
                break;
            case 0x09:
                thischar = holdchar;
                flash = false;
                stylechange = true;
                break;
            case 0x0C:
                if(height != HEIGHT_STANDARD)
                {
                    graphicshold = false;
                    holdchar = &mappingTables[MODE_TEXT][HEIGHT_STANDARD][' '];
                }

                thischar = holdchar;
                height = HEIGHT_STANDARD;
                break;
            case 0x0D:
                if(height == HEIGHT_STANDARD)
                {
                    graphicshold = false;
                    holdchar = &mappingTables[MODE_TEXT][HEIGHT_STANDARD][' '];
                }

                thischar = holdchar;
                height = HEIGHT_DOUBLE;
                break;
            case 0x11:
            case 0x12:
            case 0x13:
            case 0x14:
            case 0x15:
            case 0x16:
            case 0x17:
                thischar = holdchar;
                mode = MODE_GRAPHICS;
                nextfore = c & 0xF;
                concealed = false;
                break;
            case 0x18:
                thischar = holdchar;
                concealed = true;
                break;
            case 0x19:
                thischar = holdchar;
                gfxstyle = GFX_STYLE_CONTIGUOUS;
                break;
            case 0x1A:
                thischar = holdchar;
                gfxstyle = GFX_STYLE_SEPARATED;
                break;
            case 0x1C:
                thischar = holdchar;
                backcolour = COL_BLACK;
                stylechange = true;
                break;
            case 0x1D:
                thischar = holdchar;
                backcolour = forecolour;
                stylechange = true;
                break;
            case 0x1E:
                if(lastgfxchar != NULL)
                {
                    holdchar = lastgfxchar;
                }

                thischar = holdchar;
                graphicshold = true;
                break;
            case 0x1F:
                thischar = holdchar;
                graphicshold = false;
                holdchar = &mappingTables[MODE_TEXT][HEIGHT_STANDARD][' '];
                break;
            default:
                thischar = &mappingTables[mode & gfxstyle][height & heightstates[column]][c];

                if(graphicshold && mode == MODE_GRAPHICS && c & MOSAIC_BITS)
                {
                    holdchar = thischar;
                }
        }

        heightstates[column] = (heightstates[column] ^ 0x1) & (height | 0x2);

        if(concealed)
        {
            thischar = &mappingTables[MODE_TEXT][HEIGHT_STANDARD][' '];
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

        rb_str_cat(output, thischar->data, thischar->length);

        column++;

        if(column == MODE7_COLS)
        {
            column = 0;
            mode = MODE_TEXT;
            forecolour = nextfore = COL_WHITE;
            backcolour = COL_BLACK;
            height = HEIGHT_STANDARD;
            flash = false;
            gfxstyle = GFX_STYLE_CONTIGUOUS;
            graphicshold = false;
            holdchar = &mappingTables[MODE_TEXT][HEIGHT_STANDARD][' '];
            concealed = false;

            lastgfxchar = NULL;

            if(spanopen)
            {
                rb_str_cat(output, STR_AND_LEN("</span>"));
                spanopen = false;
            }

            rb_str_cat(output, STR_AND_LEN("\n"));
        }
        else if(mode == MODE_GRAPHICS && c & MOSAIC_BITS)
        {
            lastgfxchar = thischar;
        }
        else
        {
            lastgfxchar = NULL;
        }
    }

    if(RSTRING_PTR(output)[RSTRING_LEN(output) - 1] == '\n')
    {
        rb_str_set_len(output, RSTRING_LEN(output) - 1);
    }

    return output;
}
