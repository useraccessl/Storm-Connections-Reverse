0000000140a6a5f0: mov      rax, rsp
0000000140a6a5f3: mov      qword ptr [rax + 0x10], rbx
0000000140a6a5f7: mov      qword ptr [rax + 0x20], rsi
0000000140a6a5fb: push     rbp
0000000140a6a5fc: push     rdi
0000000140a6a5fd: push     r14
0000000140a6a5ff: lea      rbp, [rax - 0x3d8]
0000000140a6a606: sub      rsp, 0x4c0
0000000140a6a60d: movaps   xmmword ptr [rax - 0x28], xmm6
0000000140a6a611: movaps   xmmword ptr [rax - 0x38], xmm7
0000000140a6a615: movaps   xmmword ptr [rax - 0x48], xmm8
0000000140a6a61a: mov      rax, qword ptr [rip + 0x167bda7]
0000000140a6a621: xor      rax, rsp
0000000140a6a624: mov      qword ptr [rbp + 0x380], rax
0000000140a6a62b: mov      rsi, r8
0000000140a6a62e: mov      rbx, rdx
0000000140a6a631: mov      rdi, rcx
0000000140a6a634: movsd    xmm8, qword ptr [rcx + 0x10]
0000000140a6a63a: movsd    qword ptr [rsp + 0x40], xmm8
0000000140a6a641: mov      r14d, dword ptr [rcx + 0x18]
0000000140a6a645: mov      dword ptr [rsp + 0x48], r14d
0000000140a6a64a: movsd    xmm0, qword ptr [rcx + 0x34]
0000000140a6a64f: movsd    qword ptr [rsp + 0x20], xmm0
0000000140a6a655: mov      eax, dword ptr [rcx + 0x3c]
0000000140a6a658: mov      dword ptr [rsp + 0x28], eax
0000000140a6a65c: call     0x140136c20
0000000140a6a661: movsd    xmm0, qword ptr [rax]
0000000140a6a665: movsd    qword ptr [rsp + 0x30], xmm0
0000000140a6a66b: mov      eax, dword ptr [rax + 8]
0000000140a6a66e: mov      dword ptr [rsp + 0x38], eax
0000000140a6a672: cmp      dword ptr [rbx + 0x50], 0
0000000140a6a676: je       0x140a6a68b
0000000140a6a678: mov      r8d, dword ptr [rdi + 0x4c]
0000000140a6a67c: lea      rdx, [rsp + 0x40]
0000000140a6a681: lea      rcx, [rsp + 0x20]
0000000140a6a686: call     0x140a6a340
0000000140a6a68b: lea      rdx, [rsp + 0x30]
0000000140a6a690: lea      rcx, [rsp + 0x20]
0000000140a6a695: call     0x1411ac380
0000000140a6a69a: movaps   xmm6, xmm0
0000000140a6a69d: xorps    xmm7, xmm7
0000000140a6a6a0: xorps    xmm3, xmm3
0000000140a6a6a3: xorps    xmm2, xmm2
0000000140a6a6a6: xorps    xmm1, xmm1
0000000140a6a6a9: lea      rcx, [rsp + 0x58]
0000000140a6a6ae: call     0x1411ab440
0000000140a6a6b3: movss    xmm1, dword ptr [rsp + 0x30]
0000000140a6a6b9: mulss    xmm1, xmm6
0000000140a6a6bd: movss    xmm3, dword ptr [rsp + 0x34]
0000000140a6a6c3: mulss    xmm3, xmm6
0000000140a6a6c7: movss    xmm4, dword ptr [rsp + 0x38]
0000000140a6a6cd: mulss    xmm4, xmm6
0000000140a6a6d1: movss    dword ptr [rsp + 0x58], xmm1
0000000140a6a6d7: movss    dword ptr [rsp + 0x5c], xmm3
0000000140a6a6dd: movss    dword ptr [rsp + 0x60], xmm4
0000000140a6a6e3: movss    xmm2, dword ptr [rsp + 0x20]
0000000140a6a6e9: subss    xmm2, xmm1
0000000140a6a6ed: movss    xmm1, dword ptr [rsp + 0x24]
0000000140a6a6f3: subss    xmm1, xmm3
0000000140a6a6f7: movss    xmm0, dword ptr [rsp + 0x28]
0000000140a6a6fd: subss    xmm0, xmm4
0000000140a6a701: movss    dword ptr [rsp + 0x20], xmm2
0000000140a6a707: movss    dword ptr [rsp + 0x24], xmm1
0000000140a6a70d: movss    dword ptr [rsp + 0x28], xmm0
0000000140a6a713: lea      rcx, [rsp + 0x20]
0000000140a6a718: call     0x1411ac880
0000000140a6a71d: comiss   xmm7, xmm0
0000000140a6a720: jb       0x140a6a73a
0000000140a6a722: call     0x140145f60
0000000140a6a727: movsd    xmm0, qword ptr [rax]
0000000140a6a72b: movsd    qword ptr [rsp + 0x20], xmm0
0000000140a6a731: mov      eax, dword ptr [rax + 8]
0000000140a6a734: mov      dword ptr [rsp + 0x28], eax
0000000140a6a738: jmp      0x140a6a773
0000000140a6a73a: lea      rdx, [rsp + 0x40]
0000000140a6a73f: lea      rcx, [rsp + 0x20]
0000000140a6a744: call     0x1411acc30
0000000140a6a749: movsd    xmm1, qword ptr [rax]
0000000140a6a74d: mov      eax, dword ptr [rax + 8]
0000000140a6a750: mov      dword ptr [rsp + 0x48], eax
0000000140a6a754: movss    dword ptr [rsp + 0x20], xmm1
0000000140a6a75a: movaps   xmm0, xmm1
0000000140a6a75d: shufps   xmm0, xmm0, 0x55
0000000140a6a761: movss    dword ptr [rsp + 0x24], xmm0
0000000140a6a767: movss    xmm0, dword ptr [rsp + 0x48]
0000000140a6a76d: movss    dword ptr [rsp + 0x28], xmm0
0000000140a6a773: mov      rdx, rdi
0000000140a6a776: lea      rcx, [rbp + 0x130]
0000000140a6a77d: call     0x140a6a250
0000000140a6a782: nop      
0000000140a6a783: movsd    qword ptr [rbp + 0x140], xmm8
0000000140a6a78c: mov      dword ptr [rbp + 0x148], r14d
0000000140a6a793: movsd    xmm0, qword ptr [rsp + 0x20]
0000000140a6a799: movsd    qword ptr [rbp + 0x164], xmm0
0000000140a6a7a1: mov      eax, dword ptr [rsp + 0x28]
0000000140a6a7a5: mov      dword ptr [rbp + 0x16c], eax
0000000140a6a7ab: movsd    xmm0, qword ptr [rsp + 0x30]
0000000140a6a7b1: movsd    qword ptr [rbp + 0x170], xmm0
0000000140a6a7b9: mov      eax, dword ptr [rsp + 0x38]
0000000140a6a7bd: mov      dword ptr [rbp + 0x178], eax
0000000140a6a7c3: mov      rcx, qword ptr [rdi + 0x58]
0000000140a6a7c7: mov      rax, qword ptr [rbp + 0x188]
0000000140a6a7ce: test     rcx, rcx
0000000140a6a7d1: cmovne   rax, rcx
0000000140a6a7d5: mov      qword ptr [rbp + 0x188], rax
0000000140a6a7dc: lea      rdx, [rdi + 0x78]
0000000140a6a7e0: lea      rcx, [rsp + 0x70]
0000000140a6a7e5: call     0x140a6a0f0
0000000140a6a7ea: lea      rax, [rbp + 0x1a8]
0000000140a6a7f1: lea      rcx, [rsp + 0x70]
0000000140a6a7f6: mov      edx, 3
0000000140a6a7fb: nop      dword ptr [rax + rax]
0000000140a6a800: movups   xmm0, xmmword ptr [rcx]
0000000140a6a803: movups   xmmword ptr [rax], xmm0
0000000140a6a806: movups   xmm1, xmmword ptr [rcx + 0x10]
0000000140a6a80a: movups   xmmword ptr [rax + 0x10], xmm1
0000000140a6a80e: movups   xmm0, xmmword ptr [rcx + 0x20]
0000000140a6a812: movups   xmmword ptr [rax + 0x20], xmm0
0000000140a6a816: movups   xmm1, xmmword ptr [rcx + 0x30]
0000000140a6a81a: movups   xmmword ptr [rax + 0x30], xmm1
0000000140a6a81e: movups   xmm0, xmmword ptr [rcx + 0x40]
0000000140a6a822: movups   xmmword ptr [rax + 0x40], xmm0
0000000140a6a826: movups   xmm1, xmmword ptr [rcx + 0x50]
0000000140a6a82a: movups   xmmword ptr [rax + 0x50], xmm1
0000000140a6a82e: movups   xmm0, xmmword ptr [rcx + 0x60]
0000000140a6a832: movups   xmmword ptr [rax + 0x60], xmm0
0000000140a6a836: lea      rax, [rax + 0x80]
0000000140a6a83d: movups   xmm1, xmmword ptr [rcx + 0x70]
0000000140a6a841: movups   xmmword ptr [rax - 0x10], xmm1
0000000140a6a845: lea      rcx, [rcx + 0x80]
0000000140a6a84c: sub      rdx, 1
0000000140a6a850: jne      0x140a6a800
0000000140a6a852: movups   xmm0, xmmword ptr [rcx]
0000000140a6a855: movups   xmmword ptr [rax], xmm0
0000000140a6a858: movups   xmm1, xmmword ptr [rcx + 0x10]
0000000140a6a85c: movups   xmmword ptr [rax + 0x10], xmm1
0000000140a6a860: movups   xmm0, xmmword ptr [rcx + 0x20]
0000000140a6a864: movups   xmmword ptr [rax + 0x20], xmm0
0000000140a6a868: movups   xmm1, xmmword ptr [rcx + 0x30]
0000000140a6a86c: movups   xmmword ptr [rax + 0x30], xmm1
0000000140a6a870: movzx    eax, byte ptr [rdi + 0x50]
0000000140a6a874: mov      byte ptr [rbp + 0x180], al
0000000140a6a87a: lea      rcx, [rbp + 0x130]
0000000140a6a881: call     0x140a66080
0000000140a6a886: mov      dword ptr [rsp + 0x50], eax
0000000140a6a88a: mov      rdx, qword ptr [rsi + 0x20]
0000000140a6a88e: cmp      rdx, qword ptr [rsi + 0x28]
0000000140a6a892: je       0x140a6a89d
0000000140a6a894: mov      dword ptr [rdx], eax
0000000140a6a896: add      qword ptr [rsi + 0x20], 4
0000000140a6a89b: jmp      0x140a6a8ab
0000000140a6a89d: lea      r8, [rsp + 0x50]
0000000140a6a8a2: mov      rcx, rsi
0000000140a6a8a5: call     0x1400e33a0
0000000140a6a8aa: nop      
0000000140a6a8ab: mov      rcx, qword ptr [rbp + 0x380]
0000000140a6a8b2: xor      rcx, rsp
0000000140a6a8b5: call     0x141441dc0
0000000140a6a8ba: lea      r11, [rsp + 0x4c0]
0000000140a6a8c2: mov      rbx, qword ptr [r11 + 0x28]
0000000140a6a8c6: mov      rsi, qword ptr [r11 + 0x38]
0000000140a6a8ca: movaps   xmm6, xmmword ptr [r11 - 0x10]
0000000140a6a8cf: movaps   xmm7, xmmword ptr [r11 - 0x20]
0000000140a6a8d4: movaps   xmm8, xmmword ptr [r11 - 0x30]
0000000140a6a8d9: mov      rsp, r11
0000000140a6a8dc: pop      r14
0000000140a6a8de: pop      rdi
0000000140a6a8df: pop      rbp
0000000140a6a8e0: ret      
