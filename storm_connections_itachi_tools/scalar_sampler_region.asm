0000000141353900: int1     
0000000141353901: dec      dword ptr [rax - 0x75]
0000000141353904: ret      
0000000141353905: add      rsp, 0x20
0000000141353909: pop      rbx
000000014135390a: ret      
000000014135390b: int3     
000000014135390c: int3     
000000014135390d: int3     
000000014135390e: int3     
000000014135390f: int3     
0000000141353910: push     rbx
0000000141353912: sub      rsp, 0x20
0000000141353916: lea      rax, [rip + 0x84c6d3]
000000014135391d: mov      rbx, rcx
0000000141353920: mov      qword ptr [rcx], rax
0000000141353923: test     dl, 1
0000000141353926: je       0x141353932
0000000141353928: mov      edx, 0x18
000000014135392d: call     0x141272800
0000000141353932: mov      rax, rbx
0000000141353935: add      rsp, 0x20
0000000141353939: pop      rbx
000000014135393a: ret      
000000014135393b: int3     
000000014135393c: int3     
000000014135393d: int3     
000000014135393e: int3     
000000014135393f: int3     
0000000141353940: mov      qword ptr [rsp + 8], rbx
0000000141353945: push     rdi
0000000141353946: sub      rsp, 0x20
000000014135394a: mov      ebx, edx
000000014135394c: mov      rdi, rcx
000000014135394f: call     0x141391d40
0000000141353954: test     bl, 1
0000000141353957: je       0x141353966
0000000141353959: mov      edx, 0x28
000000014135395e: mov      rcx, rdi
0000000141353961: call     0x141272800
0000000141353966: mov      rbx, qword ptr [rsp + 0x30]
000000014135396b: mov      rax, rdi
000000014135396e: add      rsp, 0x20
0000000141353972: pop      rdi
0000000141353973: ret      
0000000141353974: int3     
0000000141353975: int3     
0000000141353976: int3     
0000000141353977: int3     
0000000141353978: int3     
0000000141353979: int3     
000000014135397a: int3     
000000014135397b: int3     
000000014135397c: int3     
000000014135397d: int3     
000000014135397e: int3     
000000014135397f: int3     
0000000141353980: push     rbx
0000000141353982: sub      rsp, 0x20
0000000141353986: lea      rax, [rip + 0x84c663]
000000014135398d: mov      rbx, rcx
0000000141353990: mov      qword ptr [rcx], rax
0000000141353993: test     dl, 1
0000000141353996: je       0x1413539a2
0000000141353998: mov      edx, 0x28
000000014135399d: call     0x141272800
00000001413539a2: mov      rax, rbx
00000001413539a5: add      rsp, 0x20
00000001413539a9: pop      rbx
00000001413539aa: ret      
00000001413539ab: int3     
00000001413539ac: int3     
00000001413539ad: int3     
00000001413539ae: int3     
00000001413539af: int3     
00000001413539b0: ret      0
00000001413539b3: int3     
00000001413539b4: int3     
00000001413539b5: int3     
00000001413539b6: int3     
00000001413539b7: int3     
00000001413539b8: int3     
00000001413539b9: int3     
00000001413539ba: int3     
00000001413539bb: int3     
00000001413539bc: int3     
00000001413539bd: int3     
00000001413539be: int3     
00000001413539bf: int3     
00000001413539c0: mov      eax, 1
00000001413539c5: cmp      ax, dx
00000001413539c8: jae      0x1413539e4
00000001413539ca: mov      rax, qword ptr [rcx + 0x18]
00000001413539ce: movzx    edx, dx
00000001413539d1: mov      r8d, dword ptr [rax + rdx*8 - 0x10]
00000001413539d6: add      r8d, 0x64
00000001413539da: xor      eax, eax
00000001413539dc: mov      dword ptr [rcx + 0xc], r8d
00000001413539e0: mov      dword ptr [rcx + 0x10], eax
00000001413539e3: ret      
00000001413539e4: xor      eax, eax
00000001413539e6: mov      qword ptr [rcx + 0xc], rax
00000001413539ea: ret      
00000001413539eb: int3     
00000001413539ec: int3     
00000001413539ed: int3     
00000001413539ee: int3     
00000001413539ef: int3     
00000001413539f0: mov      eax, 1
00000001413539f5: cmp      ax, dx
00000001413539f8: jae      0x141353a1b
00000001413539fa: movzx    eax, dx
00000001413539fd: sub      rax, 2
0000000141353a01: lea      rdx, [rax + rax*4]
0000000141353a05: mov      rax, qword ptr [rcx + 0x18]
0000000141353a09: mov      r8d, dword ptr [rax + rdx*4]
0000000141353a0d: add      r8d, 0x64
0000000141353a11: xor      eax, eax
0000000141353a13: mov      dword ptr [rcx + 0xc], r8d
0000000141353a17: mov      dword ptr [rcx + 0x10], eax
0000000141353a1a: ret      
0000000141353a1b: xor      eax, eax
0000000141353a1d: mov      qword ptr [rcx + 0xc], rax
0000000141353a21: ret      
0000000141353a22: int3     
0000000141353a23: int3     
0000000141353a24: int3     
0000000141353a25: int3     
0000000141353a26: int3     
0000000141353a27: int3     
0000000141353a28: int3     
0000000141353a29: int3     
0000000141353a2a: int3     
0000000141353a2b: int3     
0000000141353a2c: int3     
0000000141353a2d: int3     
0000000141353a2e: int3     
0000000141353a2f: int3     
0000000141353a30: mov      eax, 1
0000000141353a35: cmp      ax, dx
0000000141353a38: jae      0x141353a57
0000000141353a3a: mov      rax, qword ptr [rcx + 0x18]
0000000141353a3e: movzx    edx, dx
0000000141353a41: sub      rdx, 2
0000000141353a45: add      rdx, rdx
0000000141353a48: mov      edx, dword ptr [rax + rdx*8]
0000000141353a4b: add      edx, 0x64
0000000141353a4e: xor      eax, eax
0000000141353a50: mov      dword ptr [rcx + 0xc], edx
0000000141353a53: mov      dword ptr [rcx + 0x10], eax
0000000141353a56: ret      
0000000141353a57: xor      eax, eax
0000000141353a59: mov      qword ptr [rcx + 0xc], rax
0000000141353a5d: ret      
0000000141353a5e: int3     
0000000141353a5f: int3     
0000000141353a60: movss    dword ptr [rcx + 0x15c], xmm2
0000000141353a68: lea      rdx, [rcx + 0x150]
0000000141353a6f: mov      dword ptr [rcx + 0x158], r9d
0000000141353a76: mov      rax, qword ptr [rcx + 0x158]
0000000141353a7d: mov      qword ptr [rcx + 0x160], rax
0000000141353a84: movss    dword ptr [rcx + 0x154], xmm1
0000000141353a8c: mov      dword ptr [rdx], 0
0000000141353a92: mov      dword ptr [rcx + 0x160], 0xffffffff
0000000141353a9c: mov      qword ptr [rcx + 0x180], rdx
0000000141353aa3: mov      qword ptr [rcx + 0x188], rdx
0000000141353aaa: ret      
0000000141353aab: int3     
0000000141353aac: int3     
0000000141353aad: int3     
0000000141353aae: int3     
0000000141353aaf: int3     
0000000141353ab0: mov      qword ptr [rsp + 0x20], rbx
0000000141353ab5: push     rbp
0000000141353ab6: push     rsi
0000000141353ab7: push     rdi
0000000141353ab8: sub      rsp, 0x50
0000000141353abc: mov      rax, qword ptr [rip + 0xd92905]
0000000141353ac3: xor      rax, rsp
0000000141353ac6: mov      qword ptr [rsp + 0x40], rax
0000000141353acb: mov      rbp, rcx
0000000141353ace: mov      esi, r9d
0000000141353ad1: lea      rcx, [rsp + 0x20]
0000000141353ad6: mov      rdi, r8
0000000141353ad9: mov      rbx, rdx
0000000141353adc: call     0x1412aa0a0
0000000141353ae1: mov      rdx, rbx
0000000141353ae4: lea      rcx, [rsp + 0x20]
0000000141353ae9: call     0x1412ab900
0000000141353aee: movups   xmm0, xmmword ptr [rsp + 0x20]
0000000141353af3: lea      rcx, [rsp + 0x30]
0000000141353af8: mov      dword ptr [rbp + 0x90], 0
0000000141353b02: movups   xmmword ptr [rbp + 0x94], xmm0
0000000141353b09: call     0x1412aa0a0
0000000141353b0e: mov      rdx, rdi
0000000141353b11: lea      rcx, [rsp + 0x30]
0000000141353b16: call     0x1412ab900
0000000141353b1b: movups   xmm0, xmmword ptr [rsp + 0x30]
0000000141353b20: mov      dword ptr [rbp + 0xa4], esi
0000000141353b26: lea      rcx, [rbp + 0xd0]
0000000141353b2d: lea      rdx, [rbp + 0x90]
0000000141353b34: movups   xmmword ptr [rbp + 0xa8], xmm0
0000000141353b3b: mov      eax, dword ptr [rbp + 0xb4]
0000000141353b41: movups   xmm0, xmmword ptr [rbp + 0xa4]
0000000141353b48: movups   xmmword ptr [rbp + 0xb8], xmm0
0000000141353b4f: mov      dword ptr [rbp + 0xc8], eax
0000000141353b55: mov      dword ptr [rbp + 0xb8], 0xffffffff
0000000141353b5f: call     0x141392090
0000000141353b64: mov      rcx, qword ptr [rsp + 0x40]
0000000141353b69: xor      rcx, rsp
0000000141353b6c: call     0x141441dc0
0000000141353b71: mov      rbx, qword ptr [rsp + 0x88]
0000000141353b79: add      rsp, 0x50
0000000141353b7d: pop      rdi
0000000141353b7e: pop      rsi
0000000141353b7f: pop      rbp
0000000141353b80: ret      
0000000141353b81: int3     
0000000141353b82: int3     
0000000141353b83: int3     
0000000141353b84: int3     
0000000141353b85: int3     
0000000141353b86: int3     
0000000141353b87: int3     
0000000141353b88: int3     
0000000141353b89: int3     
0000000141353b8a: int3     
0000000141353b8b: int3     
0000000141353b8c: int3     
0000000141353b8d: int3     
0000000141353b8e: int3     
0000000141353b8f: int3     
0000000141353b90: lea      r10, [rcx + 0xf8]
0000000141353b97: mov      dword ptr [r10], 0
0000000141353b9e: mov      eax, dword ptr [rdx]
0000000141353ba0: mov      dword ptr [rcx + 0xfc], eax
0000000141353ba6: mov      eax, dword ptr [rdx + 4]
0000000141353ba9: mov      dword ptr [rcx + 0x100], eax
0000000141353baf: mov      eax, dword ptr [rdx + 8]
0000000141353bb2: mov      dword ptr [rcx + 0x108], r9d
0000000141353bb9: mov      dword ptr [rcx + 0x104], eax
0000000141353bbf: mov      eax, dword ptr [r8]
0000000141353bc2: mov      dword ptr [rcx + 0x10c], eax
0000000141353bc8: mov      eax, dword ptr [r8 + 4]
0000000141353bcc: mov      dword ptr [rcx + 0x110], eax
0000000141353bd2: mov      eax, dword ptr [r8 + 8]
0000000141353bd6: mov      dword ptr [rcx + 0x114], eax
0000000141353bdc: movups   xmm0, xmmword ptr [rcx + 0x108]
0000000141353be3: movups   xmmword ptr [rcx + 0x118], xmm0
0000000141353bea: mov      dword ptr [rcx + 0x118], 0xffffffff
0000000141353bf4: mov      qword ptr [rcx + 0x140], r10
0000000141353bfb: mov      qword ptr [rcx + 0x148], r10
0000000141353c02: ret      
0000000141353c03: int3     
0000000141353c04: int3     
0000000141353c05: int3     
0000000141353c06: int3     
0000000141353c07: int3     
0000000141353c08: int3     
0000000141353c09: int3     
0000000141353c0a: int3     
0000000141353c0b: int3     
0000000141353c0c: int3     
0000000141353c0d: int3     
0000000141353c0e: int3     
0000000141353c0f: int3     
0000000141353c10: mov      dword ptr [rcx + 0x38], 0
0000000141353c17: lea      r10, [rcx + 0x38]
0000000141353c1b: mov      eax, dword ptr [rdx]
0000000141353c1d: mov      dword ptr [rcx + 0x3c], eax
0000000141353c20: mov      eax, dword ptr [rdx + 4]
0000000141353c23: mov      dword ptr [rcx + 0x40], eax
0000000141353c26: mov      eax, dword ptr [rdx + 8]
0000000141353c29: mov      dword ptr [rcx + 0x48], r9d
0000000141353c2d: mov      dword ptr [rcx + 0x44], eax
0000000141353c30: mov      eax, dword ptr [r8]
0000000141353c33: mov      dword ptr [rcx + 0x4c], eax
0000000141353c36: mov      eax, dword ptr [r8 + 4]
0000000141353c3a: mov      dword ptr [rcx + 0x50], eax
0000000141353c3d: mov      eax, dword ptr [r8 + 8]
0000000141353c41: mov      dword ptr [rcx + 0x54], eax
0000000141353c44: movups   xmm0, xmmword ptr [rcx + 0x48]
0000000141353c48: movups   xmmword ptr [rcx + 0x58], xmm0
0000000141353c4c: mov      dword ptr [rcx + 0x58], 0xffffffff
0000000141353c53: mov      qword ptr [rcx + 0x80], r10
0000000141353c5a: mov      qword ptr [rcx + 0x88], r10
0000000141353c61: ret      
0000000141353c62: int3     
0000000141353c63: int3     
0000000141353c64: int3     
0000000141353c65: int3     
0000000141353c66: int3     
0000000141353c67: int3     
0000000141353c68: int3     
0000000141353c69: int3     
0000000141353c6a: int3     
0000000141353c6b: int3     
0000000141353c6c: int3     
0000000141353c6d: int3     
0000000141353c6e: int3     
0000000141353c6f: int3     
0000000141353c70: ret      0
0000000141353c73: int3     
0000000141353c74: int3     
0000000141353c75: int3     
0000000141353c76: int3     
0000000141353c77: int3     
0000000141353c78: int3     
0000000141353c79: int3     
0000000141353c7a: int3     
0000000141353c7b: int3     
0000000141353c7c: int3     
0000000141353c7d: int3     
0000000141353c7e: int3     
0000000141353c7f: int3     
0000000141353c80: mov      r9, qword ptr [rcx + 0x20]
0000000141353c84: cmp      dword ptr [r9 + 8], r8d
0000000141353c88: lea      rax, [r9 + 8]
0000000141353c8c: ja       0x141353c9e
0000000141353c8e: nop      
0000000141353c90: mov      r9, rax
0000000141353c93: add      rax, 8
0000000141353c97: cmp      dword ptr [rax], r8d
0000000141353c9a: jbe      0x141353c90
0000000141353c9c: jmp      0x141353cac
0000000141353c9e: cmp      dword ptr [r9], r8d
0000000141353ca1: jbe      0x141353cac
0000000141353ca3: sub      r9, 8
0000000141353ca7: cmp      dword ptr [r9], r8d
0000000141353caa: ja       0x141353ca3
0000000141353cac: movss    xmm1, dword ptr [rip + 0x40d92c]
0000000141353cb4: xorps    xmm2, xmm2
0000000141353cb7: mov      qword ptr [rcx + 0x20], r9
0000000141353cbb: xorps    xmm0, xmm0
0000000141353cbe: sub      r8d, dword ptr [r9]
0000000141353cc1: mov      eax, r8d
0000000141353cc4: cvtsi2ss xmm2, rax
0000000141353cc9: mov      eax, dword ptr [r9 + 8]
0000000141353ccd: sub      eax, dword ptr [r9]
0000000141353cd0: cvtsi2ss xmm0, rax
0000000141353cd5: divss    xmm2, xmm0
0000000141353cd9: subss    xmm1, xmm2
0000000141353cdd: mulss    xmm2, dword ptr [r9 + 0xc]
0000000141353ce3: mulss    xmm1, dword ptr [r9 + 4]
0000000141353ce9: addss    xmm1, xmm2
0000000141353ced: movss    dword ptr [rdx], xmm1
0000000141353cf1: ret      
0000000141353cf2: int3     
0000000141353cf3: int3     
0000000141353cf4: int3     
0000000141353cf5: int3     
0000000141353cf6: int3     
0000000141353cf7: int3     
0000000141353cf8: int3     
0000000141353cf9: int3     
0000000141353cfa: int3     
0000000141353cfb: int3     
0000000141353cfc: int3     
0000000141353cfd: int3     
0000000141353cfe: int3     
0000000141353cff: int3     
0000000141353d00: ret      0
0000000141353d03: int3     
0000000141353d04: int3     
0000000141353d05: int3     
0000000141353d06: int3     
0000000141353d07: int3     
0000000141353d08: int3     
0000000141353d09: int3     
0000000141353d0a: int3     
0000000141353d0b: int3     
0000000141353d0c: int3     
0000000141353d0d: int3     
0000000141353d0e: int3     
0000000141353d0f: int3     
0000000141353d10: ret      0
0000000141353d13: int3     
0000000141353d14: int3     
0000000141353d15: int3     
0000000141353d16: int3     
0000000141353d17: int3     
0000000141353d18: int3     
0000000141353d19: int3     
0000000141353d1a: int3     
0000000141353d1b: int3     
0000000141353d1c: int3     
0000000141353d1d: int3     
0000000141353d1e: int3     
0000000141353d1f: int3     
0000000141353d20: ret      0
0000000141353d23: int3     
0000000141353d24: int3     
0000000141353d25: int3     
0000000141353d26: int3     
0000000141353d27: int3     
0000000141353d28: int3     
0000000141353d29: int3     
0000000141353d2a: int3     
0000000141353d2b: int3     
0000000141353d2c: int3     
0000000141353d2d: int3     
0000000141353d2e: int3     
0000000141353d2f: int3     
0000000141353d30: ret      0
0000000141353d33: int3     
0000000141353d34: int3     
0000000141353d35: int3     
0000000141353d36: int3     
0000000141353d37: int3     
0000000141353d38: int3     
0000000141353d39: int3     
0000000141353d3a: int3     
0000000141353d3b: int3     
0000000141353d3c: int3     
0000000141353d3d: int3     
0000000141353d3e: int3     
0000000141353d3f: int3     
0000000141353d40: ret      0
0000000141353d43: int3     
0000000141353d44: int3     
0000000141353d45: int3     
0000000141353d46: int3     
0000000141353d47: int3     
0000000141353d48: int3     
0000000141353d49: int3     
0000000141353d4a: int3     
0000000141353d4b: int3     
0000000141353d4c: int3     
0000000141353d4d: int3     
0000000141353d4e: int3     
0000000141353d4f: int3     
0000000141353d50: ret      0
0000000141353d53: int3     
0000000141353d54: int3     
0000000141353d55: int3     
0000000141353d56: int3     
0000000141353d57: int3     
0000000141353d58: int3     
0000000141353d59: int3     
0000000141353d5a: int3     
0000000141353d5b: int3     
0000000141353d5c: int3     
0000000141353d5d: int3     
0000000141353d5e: int3     
0000000141353d5f: int3     
0000000141353d60: ret      0
0000000141353d63: int3     
0000000141353d64: int3     
0000000141353d65: int3     
0000000141353d66: int3     
0000000141353d67: int3     
0000000141353d68: int3     
0000000141353d69: int3     
0000000141353d6a: int3     
0000000141353d6b: int3     
0000000141353d6c: int3     
0000000141353d6d: int3     
0000000141353d6e: int3     
0000000141353d6f: int3     
0000000141353d70: ret      0
0000000141353d73: int3     
0000000141353d74: int3     
0000000141353d75: int3     
0000000141353d76: int3     
0000000141353d77: int3     
0000000141353d78: int3     
0000000141353d79: int3     
0000000141353d7a: int3     
0000000141353d7b: int3     
0000000141353d7c: int3     
0000000141353d7d: int3     
0000000141353d7e: int3     
0000000141353d7f: int3     
0000000141353d80: mov      qword ptr [rsp + 0x10], rbx
0000000141353d85: mov      qword ptr [rsp + 0x18], rbp
0000000141353d8a: mov      qword ptr [rsp + 0x20], rsi
0000000141353d8f: mov      qword ptr [rsp + 8], rcx
0000000141353d94: push     rdi
0000000141353d95: sub      rsp, 0x20
0000000141353d99: mov      rbp, r9
0000000141353d9c: mov      rdi, r8
0000000141353d9f: mov      rbx, rdx
0000000141353da2: mov      rsi, rcx
0000000141353da5: call     0x141273620
0000000141353daa: mov      qword ptr [rsi + 0x20], 0
0000000141353db2: lea      rax, [rip + 0x84c40f]
0000000141353db9: mov      qword ptr [rsi], rax
0000000141353dbc: mov      qword ptr [rsi + 0x18], rbx
0000000141353dc0: mov      qword ptr [rsi + 0x28], rdi
0000000141353dc4: test     rbp, rbp
0000000141353dc7: je       0x141353dd5
0000000141353dc9: mov      rdx, rsi
0000000141353dcc: mov      rcx, rbp
0000000141353dcf: call     0x141330b10
0000000141353dd4: nop      
0000000141353dd5: mov      rax, rsi
0000000141353dd8: mov      rbx, qword ptr [rsp + 0x38]
0000000141353ddd: mov      rbp, qword ptr [rsp + 0x40]
0000000141353de2: mov      rsi, qword ptr [rsp + 0x48]
0000000141353de7: add      rsp, 0x20
0000000141353deb: pop      rdi
0000000141353dec: ret      
0000000141353ded: int3     
0000000141353dee: int3     
0000000141353def: int3     
0000000141353df0: push     rbx
0000000141353df2: sub      rsp, 0x20
0000000141353df6: lea      rax, [rip + 0x40d58b]
0000000141353dfd: mov      rbx, rcx
0000000141353e00: mov      qword ptr [rcx], rax
0000000141353e03: test     dl, 1
0000000141353e06: je       0x141353e12
0000000141353e08: mov      edx, 0x30
0000000141353e0d: call     0x141272800
0000000141353e12: mov      rax, rbx
0000000141353e15: add      rsp, 0x20
0000000141353e19: pop      rbx
0000000141353e1a: ret      
0000000141353e1b: int3     
0000000141353e1c: int3     
0000000141353e1d: int3     
0000000141353e1e: int3     
0000000141353e1f: int3     
0000000141353e20: mov      eax, 1
0000000141353e25: ret      
0000000141353e26: int3     
0000000141353e27: int3     
0000000141353e28: int3     
0000000141353e29: int3     
0000000141353e2a: int3     
0000000141353e2b: int3     
0000000141353e2c: int3     
0000000141353e2d: int3     
0000000141353e2e: int3     
0000000141353e2f: int3     
0000000141353e30: lea      rax, [rip + 0x84c3c1]
0000000141353e37: mov      qword ptr [rcx], rax
0000000141353e3a: xor      eax, eax
0000000141353e3c: mov      qword ptr [rcx + 8], rax
0000000141353e40: mov      qword ptr [rcx + 0x10], rax
0000000141353e44: mov      rax, rcx
0000000141353e47: ret      
0000000141353e48: int3     
0000000141353e49: int3     
0000000141353e4a: int3     
0000000141353e4b: int3     
0000000141353e4c: int3     
0000000141353e4d: int3     
0000000141353e4e: int3     
0000000141353e4f: int3     
0000000141353e50: push     rdi
0000000141353e52: sub      rsp, 0x20
0000000141353e56: lea      rax, [rip + 0x84c39b]
0000000141353e5d: mov      rdi, rcx
0000000141353e60: mov      qword ptr [rcx], rax
0000000141353e63: mov      rcx, qword ptr [rcx + 8]
0000000141353e67: test     rcx, rcx
0000000141353e6a: je       0x141353e8c
0000000141353e6c: mov      qword ptr [rsp + 0x30], rbx
0000000141353e71: mov      rax, qword ptr [rcx]
0000000141353e74: mov      edx, 1
0000000141353e79: mov      rbx, qword ptr [rcx + 0x10]
0000000141353e7d: call     qword ptr [rax]
0000000141353e7f: mov      rcx, rbx
0000000141353e82: test     rbx, rbx
0000000141353e85: jne      0x141353e71
0000000141353e87: mov      rbx, qword ptr [rsp + 0x30]
0000000141353e8c: xor      eax, eax
0000000141353e8e: mov      qword ptr [rdi + 8], rax
0000000141353e92: mov      qword ptr [rdi + 0x10], rax
0000000141353e96: add      rsp, 0x20
0000000141353e9a: pop      rdi
0000000141353e9b: ret      
0000000141353e9c: int3     
0000000141353e9d: int3     
0000000141353e9e: int3     
0000000141353e9f: int3     
0000000141353ea0: push     rdi
0000000141353ea2: sub      rsp, 0x20
0000000141353ea6: lea      rax, [rip + 0x84c34b]
0000000141353ead: mov      qword ptr [rsp + 0x38], rsi
0000000141353eb2: mov      qword ptr [rcx], rax
0000000141353eb5: mov      rdi, rcx
0000000141353eb8: mov      rcx, qword ptr [rcx + 8]
0000000141353ebc: mov      esi, edx
0000000141353ebe: test     rcx, rcx
0000000141353ec1: je       0x141353eeb
0000000141353ec3: mov      qword ptr [rsp + 0x30], rbx
0000000141353ec8: nop      dword ptr [rax + rax]
0000000141353ed0: mov      rax, qword ptr [rcx]
0000000141353ed3: mov      edx, 1
0000000141353ed8: mov      rbx, qword ptr [rcx + 0x10]
0000000141353edc: call     qword ptr [rax]
0000000141353ede: mov      rcx, rbx
0000000141353ee1: test     rbx, rbx
0000000141353ee4: jne      0x141353ed0
0000000141353ee6: mov      rbx, qword ptr [rsp + 0x30]
0000000141353eeb: xor      eax, eax
0000000141353eed: test     sil, 1
0000000141353ef1: mov      qword ptr [rdi + 8], rax
0000000141353ef5: mov      rsi, qword ptr [rsp + 0x38]
0000000141353efa: mov      qword ptr [rdi + 0x10], rax
0000000141353efe: je       0x141353f0b
0000000141353f00: lea      edx, [rax + 0x18]
0000000141353f03: mov      rcx, rdi
0000000141353f06: call     0x141272800
0000000141353f0b: mov      rax, rdi
0000000141353f0e: add      rsp, 0x20
0000000141353f12: pop      rdi
0000000141353f13: ret      
0000000141353f14: int3     
0000000141353f15: int3     
0000000141353f16: int3     
0000000141353f17: int3     
0000000141353f18: int3     
0000000141353f19: int3     
0000000141353f1a: int3     
0000000141353f1b: int3     
0000000141353f1c: int3     
0000000141353f1d: int3     
0000000141353f1e: int3     
0000000141353f1f: int3     
0000000141353f20: mov      r8, qword ptr [rcx + 0x10]
0000000141353f24: lea      rax, [rcx + 8]
0000000141353f28: mov      qword ptr [rdx + 8], r8
0000000141353f2c: test     r8, r8
0000000141353f2f: lea      r9, [r8 + 0x10]
0000000141353f33: cmove    r9, rax
0000000141353f37: mov      rax, qword ptr [r9]
0000000141353f3a: mov      qword ptr [rdx + 0x10], rax
0000000141353f3e: mov      qword ptr [rcx + 0x10], rdx
0000000141353f42: mov      qword ptr [r9], rdx
0000000141353f45: ret      
0000000141353f46: int3     
0000000141353f47: int3     
0000000141353f48: int3     
0000000141353f49: int3     
0000000141353f4a: int3     
0000000141353f4b: int3     
0000000141353f4c: int3     
0000000141353f4d: int3     
0000000141353f4e: int3     
0000000141353f4f: int3     
0000000141353f50: mov      qword ptr [rsp + 8], rbx
0000000141353f55: push     rdi
0000000141353f56: sub      rsp, 0x20
0000000141353f5a: mov      rbx, qword ptr [rcx + 8]
0000000141353f5e: mov      rdi, rdx
0000000141353f61: test     rbx, rbx
0000000141353f64: je       0x141353f85
0000000141353f66: nop      word ptr [rax + rax]
0000000141353f70: mov      rax, qword ptr [rbx]
0000000141353f73: mov      rdx, rdi
0000000141353f76: mov      rcx, rbx
0000000141353f79: call     qword ptr [rax + 8]
0000000141353f7c: mov      rbx, qword ptr [rbx + 0x10]
0000000141353f80: test     rbx, rbx
0000000141353f83: jne      0x141353f70
0000000141353f85: mov      rbx, qword ptr [rsp + 0x30]
0000000141353f8a: add      rsp, 0x20
0000000141353f8e: pop      rdi
0000000141353f8f: ret      
0000000141353f90: mov      r9, qword ptr [rdx + 0x10]
0000000141353f94: lea      rax, [rcx + 0x10]
0000000141353f98: mov      r10, qword ptr [rdx + 8]
0000000141353f9c: test     r9, r9
