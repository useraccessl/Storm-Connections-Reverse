"""Verify linear edge/border shader formula against independent bilinear taps."""
import math,random
# Synthetic nonuniform texture detects addressing mistakes, not just constants.
tex=[[((x*7+y*11)%17)/17 for x in range(8)] for y in range(4)]
def tap(x,y,border):
    if border and (x<0 or y<0 or x>=8 or y>=4):return 0
    return tex[min(3,max(0,y))][min(7,max(0,x))]
def linear(u,v,border):
    x,y=u*8-.5,v*4-.5;i,j=math.floor(x),math.floor(y);a,b=x-i,y-j
    return sum(tap(i+dx,j+dy,border)*(a if dx else 1-a)*(b if dy else 1-b) for dx in (0,1) for dy in (0,1))
def port(u,v,border):
    s=lambda x:max(0,min(1,x))
    weight=s(u*8+.5)*s((1-u)*8+.5)*s(v*4+.5)*s((1-v)*4+.5) if border else 1
    return linear(max(.5/8,min(1-.5/8,u)),max(.5/4,min(1-.5/4,v)),False)*weight
rng=random.Random(9301)
for u,v in [(0,0),(1,1),(-.0625,.5),(.5,1.125)]+[(rng.uniform(-.2,1.2),rng.uniform(-.3,1.3)) for _ in range(1000)]:
    for border in [False,True]:assert abs(linear(u,v,border)-port(u,v,border))<1e-12
print('PASS: 2008 independent bilinear ClampEdge/transparent ClampBorder comparisons.')
print('LIMIT: Source GPU sampler execution still needs live validation.')
