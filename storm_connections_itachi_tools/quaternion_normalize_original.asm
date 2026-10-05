00000001411f2000: movups   xmm0, xmmword ptr [rcx]
00000001411f2003: xorps    xmm0, xmmword ptr [rip + 0x85160e6]
00000001411f200a: movups   xmmword ptr [rcx], xmm0
00000001411f200d: ret      
00000001411f200e: int3     
00000001411f200f: int3     
00000001411f2010: movups   xmm0, xmmword ptr [rcx]
00000001411f2013: mov      rax, rdx
00000001411f2016: xorps    xmm0, xmmword ptr [rip + 0x85160d3]
00000001411f201d: movups   xmmword ptr [rdx], xmm0
00000001411f2020: ret      
00000001411f2021: int3     
00000001411f2022: int3     
00000001411f2023: int3     
00000001411f2024: int3     
00000001411f2025: int3     
00000001411f2026: int3     
00000001411f2027: int3     
00000001411f2028: int3     
00000001411f2029: int3     
00000001411f202a: int3     
00000001411f202b: int3     
00000001411f202c: int3     
00000001411f202d: int3     
00000001411f202e: int3     
00000001411f202f: int3     
00000001411f2030: movups   xmm0, xmmword ptr [rdx]
00000001411f2033: mulps    xmm0, xmmword ptr [rcx]
00000001411f2036: pshufd   xmm2, xmm0, 0x4e
00000001411f203b: addps    xmm2, xmm0
00000001411f203e: pshufd   xmm0, xmm2, 0x39
00000001411f2043: addps    xmm0, xmm2
00000001411f2046: ret      
00000001411f2047: int3     
00000001411f2048: int3     
00000001411f2049: int3     
00000001411f204a: int3     
00000001411f204b: int3     
00000001411f204c: int3     
00000001411f204d: int3     
00000001411f204e: int3     
00000001411f204f: int3     
00000001411f2050: mov      qword ptr [rsp + 8], rbx
00000001411f2055: push     rdi
00000001411f2056: sub      rsp, 0x30
00000001411f205a: movss    xmm1, dword ptr [rdx]
00000001411f205e: mov      rbx, rdx
00000001411f2061: movss    xmm0, dword ptr [rcx]
00000001411f2065: mov      rdi, rcx
00000001411f2068: movaps   xmmword ptr [rsp + 0x20], xmm6
00000001411f206d: movaps   xmm6, xmm2
00000001411f2070: call     0x1411f0750
00000001411f2075: test     al, al
00000001411f2077: je       0x1411f20cd
00000001411f2079: movss    xmm1, dword ptr [rbx + 4]
00000001411f207e: movaps   xmm2, xmm6
00000001411f2081: movss    xmm0, dword ptr [rdi + 4]
00000001411f2086: call     0x1411f0750
00000001411f208b: test     al, al
00000001411f208d: je       0x1411f20cd
00000001411f208f: movss    xmm1, dword ptr [rbx + 8]
00000001411f2094: movaps   xmm2, xmm6
00000001411f2097: movss    xmm0, dword ptr [rdi + 8]
00000001411f209c: call     0x1411f0750
00000001411f20a1: test     al, al
00000001411f20a3: je       0x1411f20cd
00000001411f20a5: movss    xmm1, dword ptr [rbx + 0xc]
00000001411f20aa: movaps   xmm2, xmm6
00000001411f20ad: movss    xmm0, dword ptr [rdi + 0xc]
00000001411f20b2: call     0x1411f0750
00000001411f20b7: test     al, al
00000001411f20b9: je       0x1411f20cd
00000001411f20bb: mov      al, 1
00000001411f20bd: mov      rbx, qword ptr [rsp + 0x40]
00000001411f20c2: movaps   xmm6, xmmword ptr [rsp + 0x20]
00000001411f20c7: add      rsp, 0x30
00000001411f20cb: pop      rdi
00000001411f20cc: ret      
00000001411f20cd: mov      rbx, qword ptr [rsp + 0x40]
00000001411f20d2: xor      al, al
00000001411f20d4: movaps   xmm6, xmmword ptr [rsp + 0x20]
00000001411f20d9: add      rsp, 0x30
00000001411f20dd: pop      rdi
00000001411f20de: ret      
00000001411f20df: int3     
00000001411f20e0: mov      rax, rsp
00000001411f20e3: mov      qword ptr [rax + 8], rbx
00000001411f20e7: push     rdi
00000001411f20e8: sub      rsp, 0x100
00000001411f20ef: movaps   xmmword ptr [rax - 0x18], xmm6
00000001411f20f3: mov      rdi, rcx
00000001411f20f6: movaps   xmmword ptr [rax - 0x28], xmm7
00000001411f20fa: lea      rcx, [rsp + 0x20]
00000001411f20ff: movaps   xmmword ptr [rax - 0x38], xmm8
00000001411f2104: movaps   xmm6, xmm3
00000001411f2107: movaps   xmmword ptr [rax - 0x48], xmm9
00000001411f210c: movaps   xmm7, xmm2
00000001411f210f: movaps   xmmword ptr [rax - 0x58], xmm10
00000001411f2114: movaps   xmm9, xmm1
00000001411f2118: movaps   xmmword ptr [rax - 0x68], xmm11
00000001411f211d: xorps    xmm3, xmm3
00000001411f2120: movaps   xmmword ptr [rax - 0x78], xmm12
00000001411f2125: xorps    xmm2, xmm2
00000001411f2128: movaps   xmmword ptr [rax - 0x88], xmm13
00000001411f2130: movss    xmm13, dword ptr [rip + 0x56f4a7]
00000001411f2139: movaps   xmm1, xmm13
00000001411f213d: movaps   xmmword ptr [rsp + 0x70], xmm14
00000001411f2143: movaps   xmmword ptr [rsp + 0x60], xmm15
00000001411f2149: call     0x1411ab440
00000001411f214e: movss    xmm8, dword ptr [rip + 0x5782f1]
00000001411f2157: mov      rbx, rax
00000001411f215a: mulss    xmm6, xmm8
00000001411f215f: movaps   xmm0, xmm6
00000001411f2162: call     0x1411db7d0
00000001411f2167: movss    dword ptr [rsp + 0x118], xmm0
00000001411f2170: movaps   xmm0, xmm6
00000001411f2173: call     0x1411dbd00
00000001411f2178: movaps   xmm15, xmm0
