"""Independent unsigned-byte models; no NumPy required."""
def apply(op,a,b,threshold=40):
    if len(a)!=len(b): raise ValueError('length mismatch')
    fs={'abs':lambda x,y:abs(x-y),'thresh':lambda x,y:255 if x>=y else 0,
        'addus':lambda x,y:min(x+y,255),'max':max,'min':min,
        'motion':lambda x,y:255 if abs(x-y)>=threshold else 0}
    return bytes(fs[op](x,y) for x,y in zip(a,b))
