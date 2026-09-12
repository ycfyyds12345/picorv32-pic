#!/usr/bin/env python3
from pathlib import Path
from PIL import Image,ImageDraw
import argparse
p=argparse.ArgumentParser();p.add_argument('--out',default='build/images');args=p.parse_args()
out=Path(args.out);out.mkdir(parents=True,exist_ok=True)
for name,pos in [('moving_square_a',(48,72,111,135)),('moving_square_b',(80,88,143,151))]:
    im=Image.new('L',(256,256),20);ImageDraw.Draw(im).rectangle(pos,fill=220)
    im.save(out/(name+'.png'));(out/(name+'.raw')).write_bytes(im.tobytes())
g=Image.frombytes('L',(256,256),bytes(range(256))*256);g.save(out/'gradient.png');(out/'gradient.raw').write_bytes(g.tobytes())
# Two full-size datasets: application frames and exhaustive byte-pair arithmetic coverage.
sets={'motion':((out/'moving_square_a.raw').read_bytes(),(out/'moving_square_b.raw').read_bytes()),
      'gradient':(bytes(range(256))*256,bytes(y for y in range(256) for x in range(256)))}
for name,(a,b) in sets.items():
    (out/(name+'_a.raw')).write_bytes(a);(out/(name+'_b.raw')).write_bytes(b)
    raw=a+b
    (out/(name+'.hex')).write_text(''.join(f'{int.from_bytes(raw[i:i+4],"little"):08x}\n' for i in range(0,len(raw),4)))
print('HOST_IMAGES_PASS two 256x256 datasets generated')
