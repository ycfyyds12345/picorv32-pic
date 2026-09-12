#!/usr/bin/env python3
"""Upload raw frames in acknowledged 256-byte blocks; validate returned pixels."""
import argparse
from pathlib import Path
from golden import apply

def read_exact(port,n):
    data=bytearray()
    while len(data)<n:
        part=port.read(n-len(data))
        if not part: raise TimeoutError(f'UART timeout at {len(data)}/{n} bytes')
        data.extend(part)
    return bytes(data)

def ack(port,expected):
    got=read_exact(port,1)
    if got!=expected:raise RuntimeError(f'expected {expected!r}, got {got!r}')

def upload(port,cmd,data):
    port.write(bytes([cmd]));ack(port,b'R')
    for i in range(0,len(data),256):port.write(data[i:i+256]);ack(port,b'K')

def main():
    p=argparse.ArgumentParser();p.add_argument('port');p.add_argument('a');p.add_argument('b');p.add_argument('output');p.add_argument('--op',choices=['abs','thresh','addus','max','min','motion'],default='motion');p.add_argument('--threshold',type=int,default=40);p.add_argument('--baud',type=int,default=115200);args=p.parse_args()
    import serial
    a=Path(args.a).read_bytes();b=Path(args.b).read_bytes()
    if len(a)!=65536 or len(b)!=65536:raise ValueError('both raw frames must contain 65536 bytes')
    if not 0<=args.threshold<=255:raise ValueError('threshold must be 0..255')
    with serial.Serial(args.port,args.baud,timeout=10,write_timeout=10) as port:
        # Startup banner may already have been consumed. Clear stale bytes before commands.
        port.reset_input_buffer();upload(port,1,a);upload(port,2,b)
        port.write(bytes([0x30,args.threshold]));ack(port,b'K')
        port.write(bytes([0x10+['abs','thresh','addus','max','min','motion'].index(args.op)]));ack(port,b'K')
        port.write(b'\x20');result=read_exact(port,65536)
    Path(args.output).write_bytes(result)
    expected=apply(args.op,a,b,args.threshold);m=sum(x!=y for x,y in zip(result,expected))
    print(f'pixels=65536 mismatch={m}')
    if m:raise SystemExit(1)
if __name__=='__main__':main()
