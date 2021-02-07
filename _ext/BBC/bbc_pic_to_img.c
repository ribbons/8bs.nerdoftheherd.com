/*
 * This file is part of the 8BS Online Conversion.
 * Copyright © 2016-2021 by the authors - see the AUTHORS file for details.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <png.h>
#include <zlib.h>
#include <BbcImageLoader.h>

#include "bbc_native.h"

png_bytep *row_pointers;

void callback(int x, int y, uint8_t colour)
{
    if(colour > 7)
    {
        rb_fatal("Encountered flashing colour value %u", colour);
    }

    row_pointers[y][x] = colour;
}

VALUE method_bbc_pic_to_img(VALUE self, VALUE input, VALUE type, VALUE mode)
{
    uint8_t* data = (uint8_t*)RSTRING_PTR(input);
    long dataLen = RSTRING_LEN(input);

    char* typeString = RSTRING_PTR(type);
    BbcScreenP screen;

    if(strcmp(typeString, "ldpic") == 0)
    {
        screen = BbcImageLoader_LoadLdPic(data, (int)dataLen);
    }
    else if(strcmp(typeString, "screendump") == 0)
    {
        VALUE modeVals = rb_ary_to_ary(mode);

        screen = BbcImageLoader_LoadMemDump(data, (int)dataLen);
        BbcScreen_setMode(screen, (uint8_t)NUM2UINT(rb_ary_shift(modeVals)));

        for(uint8_t i = 0; i < RARRAY_LEN(modeVals); i++)
        {
            BbcScreen_setColour(screen, i, (uint8_t)NUM2UINT(rb_ary_entry(modeVals, i)));
        }
    }
    else if(strcmp(typeString, "scrload") == 0)
    {
        VALUE modeVals = rb_ary_to_ary(mode);

        if(RTEST(rb_ary_shift(modeVals)))
        {
            screen = BbcImageLoader_LoadScrLoad(data, (int)dataLen);
        }
        else
        {
            screen = BbcImageLoader_LoadMemDump(data, (int)dataLen);
        }

        uint8_t bbcmode = (uint8_t)NUM2UINT(rb_ary_shift(modeVals));
        BbcScreen_setMode(screen, bbcmode);

        if(bbcmode == 2)
        {
            // ScrLoad saves mappings for colours 9-16 in the first four bytes
            // of the image and then copies the next four over to hide this
            for(int i = 0; i < 4; i++)
            {
                BbcScreen_setScreenByte(screen, i, BbcScreen_getScreenByte(screen, i + 4));
            }
        }

        for(uint8_t i = 0; i < RARRAY_LEN(modeVals); i++)
        {
            BbcScreen_setColour(screen, i, (uint8_t)NUM2UINT(rb_ary_entry(modeVals, i)));
        }
    }
    else
    {
        rb_fatal("Unknown image type \"%s\"", typeString);
    }

    unsigned width = (unsigned)BbcScreen_getScreenWidth(screen);
    unsigned height = (unsigned)BbcScreen_getScreenHeight(screen);

    size_t bufsize = sizeof(png_bytep) * height;
    row_pointers = (png_bytep*)malloc(bufsize);

    for(int i = 0; i < height; i++)
    {
        row_pointers[i] = (png_bytep)malloc(width);
    }

    BbcScreen_draw(screen, &callback);
    BbcScreen_delete(screen);

    GChecksum *checksum = g_checksum_new(G_CHECKSUM_SHA1);

    for(int i = 0; i < height; i++)
    {
        g_checksum_update(checksum, row_pointers[i], width);
    }

    // Get the base destination directory
    VALUE context = rb_ivar_get(self, rb_intern("@context"));
    VALUE registers = rb_funcall(context, rb_intern("registers"), 0);
    VALUE site = rb_hash_lookup(registers, ID2SYM(rb_intern("site")));
    VALUE dest_dir = rb_funcall(site, rb_intern("in_dest_dir"), 1, rb_str_new("", 0));

    GString *fileNameCommon = g_string_new(NULL);
    g_string_printf(fileNameCommon, "assets/convimages/%s.png", g_checksum_get_string(checksum));

    GString *fileName = g_string_new(NULL);
    g_string_assign(fileName, RSTRING_PTR(dest_dir));
    g_string_append(fileName, fileNameCommon->str);

    FILE *handle = fopen(fileName->str, "wb");

    if(handle == NULL)
    {
        rb_fatal("Failed to open \"%s\" for write", fileName->str);
    }

    g_string_free(fileName, TRUE);

    png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);

    if(png_ptr == NULL)
    {
        rb_fatal("Failed to create PNG write struct");
    }

    png_infop info_ptr = png_create_info_struct(png_ptr);

    if(info_ptr == NULL)
    {
        rb_fatal("Failed to create PNG info struct");
    }

    if(setjmp(png_jmpbuf(png_ptr)))
    {
        // Execution jumps to here if libpng encounters an error
        rb_fatal("Error encountered writing PNG file");
    }

    png_init_io(png_ptr, handle);
    png_set_compression_level(png_ptr, Z_BEST_COMPRESSION);

    png_set_IHDR(png_ptr, info_ptr, width, height, 4, PNG_COLOR_TYPE_PALETTE,
        PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);

    png_color palette[] = {
        { 0,   0,   0 },
        { 255, 0,   0 },
        { 0,   255, 0 },
        { 255, 255, 0 },
        { 0,   0,   255 },
        { 255, 0,   255 },
        { 0,   255, 255 },
        { 255, 255, 255 }
    };

    png_set_PLTE(png_ptr, info_ptr, palette, sizeof(palette) / sizeof(palette[0]));
    png_write_info(png_ptr, info_ptr);

    png_set_packing(png_ptr);
    png_write_image(png_ptr, row_pointers);

    png_write_end(png_ptr, NULL);
    png_destroy_write_struct(&png_ptr, &info_ptr);

    fclose(handle);

    for(int i = 0; i < height; i++)
    {
        free(row_pointers[i]);
    }

    free(row_pointers);

    GString *output = g_string_new(NULL);
    g_string_printf(output, "<img src=\"/%s\" width=640 height=%d>", fileNameCommon->str, height * 2);
    g_string_free(fileNameCommon, TRUE);

    VALUE outputR = rb_str_new(output->str, (long)output->len);
    g_string_free(output, TRUE);

    return outputR;
}
