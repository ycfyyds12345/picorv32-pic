#!/usr/bin/env python3
import argparse
from PIL import Image
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('input');p.add_argument('output');a=p.parse_args()
data=Path(a.input).read_bytes()
if len(data)!=65536: raise ValueError('expected 65536 bytes')
Image.frombytes('L',(256,256),data).save(a.output)
