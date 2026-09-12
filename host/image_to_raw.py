#!/usr/bin/env python3
import argparse
from PIL import Image
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('input');p.add_argument('output');a=p.parse_args()
with Image.open(a.input) as im: data=im.convert('L').resize((256,256)).tobytes()
Path(a.output).write_bytes(data)
