00000001411f4e90: mov      rax, rsp
00000001411f4e93: push     rbx
00000001411f4e94: sub      rsp, 0x80
00000001411f4e9b: movups   xmm4, xmmword ptr [r8]
00000001411f4e9f: mov      rbx, rdx
00000001411f4ea2: movaps   xmmword ptr [rax - 0x48], xmm9
00000001411f4ea7: movss    xmm9, dword ptr [rip + 0x56c730]
00000001411f4eb0: mov      qword ptr [rax + 0x10], rsi
00000001411f4eb4: mov      rsi, rcx
00000001411f4eb7: mov      qword ptr [rax + 0x18], rdi
00000001411f4ebb: mov      rdi, r8
00000001411f4ebe: movaps   xmmword ptr [rax - 0x38], xmm8
00000001411f4ec3: movaps   xmmword ptr [rax - 0x58], xmm10
00000001411f4ec8: movaps   xmm10, xmm3
00000001411f4ecc: movups   xmm3, xmmword ptr [rcx]
00000001411f4ecf: movaps   xmmword ptr [rax - 0x68], xmm11
00000001411f4ed4: movaps   xmm11, xmm9
00000001411f4ed8: movaps   xmm0, xmm3
00000001411f4edb: mulps    xmm0, xmm4
00000001411f4ede: pshufd   xmm1, xmm0, 0x4e
00000001411f4ee3: addps    xmm1, xmm0
00000001411f4ee6: xorps    xmm0, xmm0
00000001411f4ee9: pshufd   xmm2, xmm1, 0x39
00000001411f4eee: addps    xmm2, xmm1
00000001411f4ef1: comiss   xmm0, xmm2
00000001411f4ef4: jbe      0x1411f4f06
00000001411f4ef6: xorps    xmm2, xmmword ptr [rip + 0x56c2a3]
00000001411f4efd: movss    xmm11, dword ptr [rip + 0x58281e]
00000001411f4f06: movss    xmm1, dword ptr [rip + 0x6571e2]
00000001411f4f0e: movaps   xmm8, xmm9
00000001411f4f12: comiss   xmm1, xmm2
00000001411f4f15: subss    xmm8, xmm10
00000001411f4f1a: jb       0x1411f4f7b
00000001411f4f1c: movaps   xmmword ptr [rsp + 0x70], xmm6
00000001411f4f21: movaps   xmm0, xmm2
00000001411f4f24: movaps   xmmword ptr [rsp + 0x60], xmm7
00000001411f4f29: call     0x1411db5c0
00000001411f4f2e: movaps   xmm7, xmm0
00000001411f4f31: call     0x1411dbd00
00000001411f4f36: mulss    xmm8, xmm7
00000001411f4f3b: movaps   xmm6, xmm9
00000001411f4f3f: divss    xmm6, xmm0
00000001411f4f43: movaps   xmm0, xmm8
00000001411f4f47: call     0x1411dbd00
00000001411f4f4c: movaps   xmm8, xmm0
00000001411f4f50: mulss    xmm7, xmm10
00000001411f4f55: mulss    xmm8, xmm6
00000001411f4f5a: movaps   xmm0, xmm7
00000001411f4f5d: call     0x1411dbd00
00000001411f4f62: movups   xmm3, xmmword ptr [rsi]
00000001411f4f65: movups   xmm4, xmmword ptr [rdi]
00000001411f4f68: movaps   xmm7, xmmword ptr [rsp + 0x60]
00000001411f4f6d: movaps   xmm10, xmm0
00000001411f4f71: mulss    xmm10, xmm6
00000001411f4f76: movaps   xmm6, xmmword ptr [rsp + 0x70]
00000001411f4f7b: mov      rdi, qword ptr [rsp + 0xa0]
00000001411f4f83: movaps   xmm0, xmm10
00000001411f4f87: movaps   xmm10, xmmword ptr [rsp + 0x30]
00000001411f4f8d: mov      rax, rbx
00000001411f4f90: mov      rsi, qword ptr [rsp + 0x98]
00000001411f4f98: shufps   xmm0, xmm0, 0
00000001411f4f9c: mulps    xmm0, xmm4
00000001411f4f9f: mulss    xmm8, xmm11
00000001411f4fa4: movaps   xmm11, xmmword ptr [rsp + 0x20]
00000001411f4faa: movaps   xmm2, xmm8
00000001411f4fae: movaps   xmm8, xmmword ptr [rsp + 0x50]
00000001411f4fb4: shufps   xmm2, xmm2, 0
00000001411f4fb8: mulps    xmm2, xmm3
00000001411f4fbb: addps    xmm2, xmm0
00000001411f4fbe: movaps   xmm1, xmm2
00000001411f4fc1: mulps    xmm1, xmm2
00000001411f4fc4: movups   xmmword ptr [rbx], xmm2
00000001411f4fc7: pshufd   xmm0, xmm1, 0x4e
00000001411f4fcc: addps    xmm1, xmm0
00000001411f4fcf: pshufd   xmm0, xmm1, 0x39
00000001411f4fd4: addps    xmm0, xmm1
00000001411f4fd7: sqrtps   xmm3, xmm0
00000001411f4fda: movss    xmm0, dword ptr [rip + 0x641abe]
00000001411f4fe2: comiss   xmm0, xmm3
00000001411f4fe5: ja       0x1411f4ffa
00000001411f4fe7: divss    xmm9, xmm3
00000001411f4fec: movaps   xmm0, xmm9
00000001411f4ff0: shufps   xmm0, xmm0, 0
00000001411f4ff4: mulps    xmm0, xmm2
00000001411f4ff7: movups   xmmword ptr [rbx], xmm0
00000001411f4ffa: movaps   xmm9, xmmword ptr [rsp + 0x40]
00000001411f5000: add      rsp, 0x80
00000001411f5007: pop      rbx
00000001411f5008: ret      
