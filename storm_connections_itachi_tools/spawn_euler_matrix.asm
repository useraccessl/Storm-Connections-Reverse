00000001411e9ec0: mov      rax, rsp
00000001411e9ec3: push     rbx
00000001411e9ec4: sub      rsp, 0x90
00000001411e9ecb: movaps   xmm0, xmmword ptr [rip + 0x5b50ae]
00000001411e9ed2: mov      rbx, rcx
00000001411e9ed5: movaps   xmmword ptr [rax - 0x18], xmm6
00000001411e9ed9: movaps   xmm6, xmm1
00000001411e9edc: movaps   xmmword ptr [rax - 0x28], xmm7
00000001411e9ee0: movaps   xmm7, xmm3
00000001411e9ee3: movaps   xmmword ptr [rax - 0x38], xmm8
00000001411e9ee8: movaps   xmm8, xmm2
00000001411e9eec: movaps   xmmword ptr [rax - 0x48], xmm9
00000001411e9ef1: movaps   xmmword ptr [rax - 0x58], xmm10
00000001411e9ef6: movaps   xmmword ptr [rax - 0x68], xmm11
00000001411e9efb: movaps   xmmword ptr [rax - 0x78], xmm12
00000001411e9f00: xor      eax, eax
00000001411e9f02: mov      dword ptr [rcx + 0xc], eax
00000001411e9f05: mov      dword ptr [rcx + 0x1c], eax
00000001411e9f08: mov      dword ptr [rcx + 0x2c], eax
00000001411e9f0b: movups   xmmword ptr [rcx + 0x30], xmm0
00000001411e9f0f: movaps   xmm0, xmm1
00000001411e9f12: call     0x1414430a2
00000001411e9f17: movaps   xmm9, xmm0
00000001411e9f1b: movaps   xmm0, xmm7
00000001411e9f1e: call     0x1414430a2
00000001411e9f23: movaps   xmm10, xmm0
00000001411e9f27: movaps   xmm0, xmm8
00000001411e9f2b: call     0x1414430a2
00000001411e9f30: movaps   xmm12, xmm0
00000001411e9f34: movaps   xmm0, xmm6
00000001411e9f37: call     0x1414430a8
00000001411e9f3c: movaps   xmm11, xmm0
00000001411e9f40: movaps   xmm0, xmm7
00000001411e9f43: call     0x1414430a8
00000001411e9f48: movaps   xmm6, xmm0
00000001411e9f4b: movaps   xmm0, xmm8
00000001411e9f4f: call     0x1414430a8
00000001411e9f54: movaps   xmm7, xmmword ptr [rsp + 0x70]
00000001411e9f59: lea      r11, [rsp + 0x90]
00000001411e9f61: movaps   xmm8, xmmword ptr [r11 - 0x30]
00000001411e9f66: movaps   xmm2, xmm0
00000001411e9f69: xorps    xmm2, xmmword ptr [rip + 0x577230]
00000001411e9f70: movaps   xmm4, xmm0
00000001411e9f73: movaps   xmm1, xmm12
00000001411e9f77: movaps   xmm3, xmm9
00000001411e9f7b: mulss    xmm1, xmm10
00000001411e9f80: mov      rax, rbx
00000001411e9f83: mulss    xmm3, xmm10
00000001411e9f88: movss    dword ptr [rbx], xmm1
00000001411e9f8c: movaps   xmm1, xmm6
00000001411e9f8f: movss    dword ptr [rbx + 4], xmm2
00000001411e9f94: movaps   xmm2, xmm6
00000001411e9f97: mulss    xmm1, xmm12
00000001411e9f9c: movaps   xmm0, xmm3
00000001411e9f9f: mulss    xmm0, xmm4
00000001411e9fa3: movss    dword ptr [rbx + 8], xmm1
00000001411e9fa8: movaps   xmm1, xmm11
00000001411e9fac: mulss    xmm2, xmm11
00000001411e9fb1: mulss    xmm6, xmm9
00000001411e9fb6: addss    xmm0, xmm2
00000001411e9fba: mulss    xmm1, xmm10
00000001411e9fbf: movaps   xmm10, xmmword ptr [r11 - 0x50]
00000001411e9fc4: mulss    xmm2, xmm4
00000001411e9fc8: movss    dword ptr [rbx + 0x10], xmm0
00000001411e9fcd: movaps   xmm0, xmm12
00000001411e9fd1: mulss    xmm0, xmm9
00000001411e9fd6: movaps   xmm9, xmmword ptr [r11 - 0x40]
00000001411e9fdb: addss    xmm2, xmm3
00000001411e9fdf: mulss    xmm12, xmm11
00000001411e9fe4: movaps   xmm11, xmmword ptr [r11 - 0x60]
00000001411e9fe9: movss    dword ptr [rbx + 0x14], xmm0
00000001411e9fee: movaps   xmm0, xmm6
00000001411e9ff1: mulss    xmm0, xmm4
00000001411e9ff5: subss    xmm0, xmm1
00000001411e9ff9: mulss    xmm1, xmm4
00000001411e9ffd: subss    xmm1, xmm6
00000001411ea001: movaps   xmm6, xmmword ptr [r11 - 0x10]
00000001411ea006: movss    dword ptr [rbx + 0x18], xmm0
00000001411ea00b: movss    dword ptr [rbx + 0x20], xmm1
00000001411ea010: movss    dword ptr [rbx + 0x24], xmm12
00000001411ea016: movaps   xmm12, xmmword ptr [r11 - 0x70]
00000001411ea01b: movss    dword ptr [rbx + 0x28], xmm2
00000001411ea020: mov      rsp, r11
00000001411ea023: pop      rbx
00000001411ea024: ret      
