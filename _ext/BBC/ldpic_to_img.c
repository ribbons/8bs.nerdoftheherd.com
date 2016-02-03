/*
 * This file is part of the 8BS Online Conversion.
 * Copyright © 2016 by the authors - see the AUTHORS file for details.
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
#include <BbcImageLoader.h>

#include "native_filters.h"

png_bytep *row_pointers;

void callback(int x, int y, uint8_t colour)
{
    if(colour > 7)
    {
        rb_fatal("Encountered flashing colour value %u", colour);
    }

    row_pointers[y][x] = colour;
}

VALUE method_ldpic_to_img(VALUE self, VALUE input)
{
    char* data = RSTRING_PTR(input);
    long dataLen = RSTRING_LEN(input);

    BbcScreenP screen = BbcImageLoader_LoadLdPic((uint8_t*)data, (int)dataLen);

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

    png_set_IHDR(png_ptr, info_ptr, width, height, 8, PNG_COLOR_TYPE_PALETTE,
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
    g_string_printf(output, "<img src=\"/%s\" width=640 height=512>", fileNameCommon->str);
    g_string_free(fileNameCommon, TRUE);

    VALUE outputR = rb_str_new(output->str, (long)output->len);
    g_string_free(output, TRUE);

    return outputR;
}
