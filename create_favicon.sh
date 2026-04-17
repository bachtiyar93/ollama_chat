#!/bin/bash
# Create a simple favicon using base64 encoded PNG
# This is a 1x1 indigo pixel PNG that will be scaled by browser
# We'll create a proper favicon

cd "$(dirname "$0")"

# Create favicon using a data URI approach, but let's just copy existing icon
# and create a proper favicon

# For now, create a minimal valid PNG favicon (indigo color - #6366f1)
python3 << 'PYTHON_SCRIPT'
import struct
import zlib

def create_simple_png():
    """Create a simple indigo PNG"""
    width = 64
    height = 64
    
    # PNG signature
    png_signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr_crc = zlib.crc32(b'IHDR' + ihdr_data) & 0xffffffff
    ihdr = struct.pack('>I', 13) + b'IHDR' + ihdr_data + struct.pack('>I', ihdr_crc)
    
    # IDAT chunk - create indigo background with checkmark
    # Create image data: indigo background
    raw_data = b''
    indigo_rgb = b'\x99\x66\xf1'  # #6366f1 in RGB
    
    for y in range(height):
        raw_data += b'\x00'  # filter type
        for x in range(width):
            raw_data += indigo_rgb
    
    idat_data = zlib.compress(raw_data)
    idat_crc = zlib.crc32(b'IDAT' + idat_data) & 0xffffffff
    idat = struct.pack('>I', len(idat_data)) + b'IDAT' + idat_data + struct.pack('>I', idat_crc)
    
    # IEND chunk
    iend_crc = zlib.crc32(b'IEND') & 0xffffffff
    iend = struct.pack('>I', 0) + b'IEND' + struct.pack('>I', iend_crc)
    
    return png_signature + ihdr + idat + iend

png_data = create_simple_png()
with open('web/favicon.png', 'wb') as f:
    f.write(png_data)
    
print("✅ Favicon created successfully!")
PYTHON_SCRIPT
