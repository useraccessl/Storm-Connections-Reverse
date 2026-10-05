00000001412cd160: mov      rax, rsp
00000001412cd163: push     rbx
00000001412cd164: sub      rsp, 0x100
00000001412cd16b: movaps   xmmword ptr [rax - 0x28], xmm8
00000001412cd170: movaps   xmmword ptr [rax - 0x38], xmm9
00000001412cd175: movaps   xmmword ptr [rax - 0x48], xmm10
00000001412cd17a: movaps   xmmword ptr [rax - 0x58], xmm11
00000001412cd17f: mov      rax, qword ptr [rip + 0xe19242]
00000001412cd186: xor      rax, rsp
00000001412cd189: mov      qword ptr [rsp + 0xa0], rax
00000001412cd191: mov      rbx, rcx
00000001412cd194: lea      rcx, [rsp + 0x20]
00000001412cd199: call     0x1411ab440
00000001412cd19e: lea      rcx, [rsp + 0x20]
00000001412cd1a3: call     0x1411ac880
00000001412cd1a8: xorps    xmm8, xmm8
00000001412cd1ac: comiss   xmm0, xmm8
00000001412cd1b0: jbe      0x1412cd1bc
00000001412cd1b2: lea      rcx, [rsp + 0x20]
00000001412cd1b7: call     0x1411acbb0
00000001412cd1bc: movss    xmm0, dword ptr [rip + 0x4aa560]
00000001412cd1c4: movss    xmm11, dword ptr [rsp + 0x24]
00000001412cd1cb: movss    xmm10, dword ptr [rsp + 0x28]
00000001412cd1d2: movss    xmm9, dword ptr [rsp + 0x20]
00000001412cd1d9: mulss    xmm10, xmm0
00000001412cd1de: mulss    xmm11, xmm0
00000001412cd1e3: mulss    xmm9, xmm0
00000001412cd1e8: movaps   xmm1, xmm10
00000001412cd1ec: movaps   xmm0, xmm11
00000001412cd1f0: mulss    xmm1, xmm10
00000001412cd1f5: mulss    xmm0, xmm11
00000001412cd1fa: movss    dword ptr [rsp + 0x20], xmm9
00000001412cd201: movss    dword ptr [rsp + 0x24], xmm11
00000001412cd208: addss    xmm1, xmm0
00000001412cd20c: movss    dword ptr [rsp + 0x28], xmm10
00000001412cd213: xorps    xmm0, xmm0
00000001412cd216: ucomiss  xmm0, xmm1
00000001412cd219: ja       0x1412cd224
00000001412cd21b: xorps    xmm0, xmm0
00000001412cd21e: sqrtss   xmm0, xmm1
00000001412cd222: jmp      0x1412cd22c
00000001412cd224: movaps   xmm0, xmm1
00000001412cd227: call     0x1414430c6
00000001412cd22c: ucomiss  xmm0, xmm8
00000001412cd230: jp       0x1412cd2c1
00000001412cd236: jne      0x1412cd2c1
00000001412cd23c: ucomiss  xmm9, xmm8
00000001412cd240: jp       0x1412cd251
00000001412cd242: jne      0x1412cd251
00000001412cd244: mov      rcx, rbx
00000001412cd247: call     0x1412826b0
00000001412cd24c: jmp      0x1412cd36b
00000001412cd251: movaps   xmm2, xmm9
00000001412cd255: lea      rcx, [rsp + 0x50]
00000001412cd25a: xorps    xmm2, xmmword ptr [rip + 0x493f3f]
00000001412cd261: xorps    xmm3, xmm3
00000001412cd264: xorps    xmm1, xmm1
00000001412cd267: call     0x1411ab440
00000001412cd26c: xorps    xmm3, xmm3
00000001412cd26f: lea      rcx, [rsp + 0x40]
00000001412cd274: xorps    xmm2, xmm2
00000001412cd277: movaps   xmm1, xmm9
00000001412cd27b: call     0x1411ab440
00000001412cd280: movss    xmm3, dword ptr [rip + 0x494358]
00000001412cd288: lea      rcx, [rsp + 0x30]
00000001412cd28d: xorps    xmm2, xmm2
00000001412cd290: xorps    xmm1, xmm1
00000001412cd293: call     0x1411ab440
00000001412cd298: lea      r9, [rsp + 0x30]
00000001412cd29d: lea      r8, [rsp + 0x40]
00000001412cd2a2: lea      rdx, [rsp + 0x50]
00000001412cd2a7: lea      rcx, [rsp + 0x60]
00000001412cd2ac: call     0x141281640
00000001412cd2b1: mov      rdx, rax
00000001412cd2b4: mov      rcx, rbx
00000001412cd2b7: call     0x14127e710
00000001412cd2bc: jmp      0x1412cd36b
00000001412cd2c1: movaps   xmm2, xmm9
00000001412cd2c5: movaps   xmmword ptr [rsp + 0xf0], xmm7
00000001412cd2cd: xorps    xmm2, xmmword ptr [rip + 0x493ecc]
00000001412cd2d4: lea      rcx, [rsp + 0x30]
00000001412cd2d9: movss    xmm7, dword ptr [rip + 0x4942ff]
00000001412cd2e1: movaps   xmm3, xmm2
00000001412cd2e4: divss    xmm7, xmm0
00000001412cd2e8: mulss    xmm3, xmm10
00000001412cd2ed: movaps   xmm1, xmm0
00000001412cd2f0: mulss    xmm2, xmm11
00000001412cd2f5: mulss    xmm3, xmm7
00000001412cd2f9: mulss    xmm2, xmm7
00000001412cd2fd: call     0x1411ab440
00000001412cd302: movaps   xmm3, xmm10
00000001412cd306: lea      rcx, [rsp + 0x40]
00000001412cd30b: movaps   xmm2, xmm11
00000001412cd30f: movaps   xmm1, xmm9
00000001412cd313: call     0x1411ab440
00000001412cd318: xorps    xmm10, xmmword ptr [rip + 0x493e80]
00000001412cd320: lea      rcx, [rsp + 0x50]
00000001412cd325: mulss    xmm10, xmm7
00000001412cd32a: xorps    xmm1, xmm1
00000001412cd32d: mulss    xmm11, xmm7
00000001412cd332: movaps   xmm2, xmm10
00000001412cd336: movaps   xmm3, xmm11
00000001412cd33a: call     0x1411ab440
00000001412cd33f: lea      r9, [rsp + 0x50]
00000001412cd344: lea      r8, [rsp + 0x40]
00000001412cd349: lea      rdx, [rsp + 0x30]
00000001412cd34e: lea      rcx, [rsp + 0x60]
00000001412cd353: call     0x141281640
00000001412cd358: mov      rdx, rax
00000001412cd35b: mov      rcx, rbx
00000001412cd35e: call     0x14127e710
00000001412cd363: movaps   xmm7, xmmword ptr [rsp + 0xf0]
00000001412cd36b: mov      rcx, qword ptr [rsp + 0xa0]
00000001412cd373: xor      rcx, rsp
00000001412cd376: call     0x141441dc0
00000001412cd37b: lea      r11, [rsp + 0x100]
00000001412cd383: movaps   xmm8, xmmword ptr [r11 - 0x20]
00000001412cd388: movaps   xmm9, xmmword ptr [r11 - 0x30]
00000001412cd38d: movaps   xmm10, xmmword ptr [r11 - 0x40]
00000001412cd392: movaps   xmm11, xmmword ptr [r11 - 0x50]
00000001412cd397: mov      rsp, r11
00000001412cd39a: pop      rbx
00000001412cd39b: ret      
