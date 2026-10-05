00000001411bb590: mov      rax, rsp
00000001411bb593: sub      rsp, 0x68
00000001411bb597: movaps   xmmword ptr [rax - 0x18], xmm6
00000001411bb59b: movss    xmm6, dword ptr [rdx + 4]
00000001411bb5a0: movaps   xmmword ptr [rax - 0x28], xmm7
00000001411bb5a4: movaps   xmm2, xmm6
00000001411bb5a7: movss    xmm7, dword ptr [rdx]
00000001411bb5ab: movaps   xmmword ptr [rax - 0x38], xmm8
00000001411bb5b0: movss    xmm8, dword ptr [rip + 0x5a6027]
00000001411bb5b9: movaps   xmmword ptr [rax - 0x48], xmm9
00000001411bb5be: movaps   xmm0, xmm8
00000001411bb5c2: movss    xmm9, dword ptr [rdx + 8]
00000001411bb5c8: movaps   xmmword ptr [rax - 0x58], xmm10
00000001411bb5cd: movaps   xmm5, xmm9
00000001411bb5d1: movaps   xmmword ptr [rsp], xmm11
00000001411bb5d6: movaps   xmm10, xmm6
00000001411bb5da: movss    xmm11, dword ptr [rdx + 0xc]
00000001411bb5e0: movaps   xmm4, xmm9
00000001411bb5e4: mulss    xmm2, xmm7
00000001411bb5e8: movaps   xmm3, xmm11
00000001411bb5ec: mulss    xmm10, xmm6
00000001411bb5f1: mulss    xmm5, xmm9
00000001411bb5f6: mulss    xmm4, xmm7
00000001411bb5fa: movaps   xmm1, xmm10
00000001411bb5fe: addss    xmm1, xmm5
00000001411bb602: mulss    xmm3, xmm6
00000001411bb606: addss    xmm1, xmm1
00000001411bb60a: subss    xmm0, xmm1
00000001411bb60e: movaps   xmm1, xmm11
00000001411bb612: mulss    xmm1, xmm9
00000001411bb617: mulss    xmm11, xmm7
00000001411bb61c: movss    dword ptr [rcx], xmm0
00000001411bb620: movaps   xmm0, xmm2
00000001411bb623: subss    xmm0, xmm1
00000001411bb627: mulss    xmm9, xmm6
00000001411bb62c: movaps   xmm6, xmmword ptr [rax - 0x18]
00000001411bb630: addss    xmm1, xmm2
00000001411bb634: movaps   xmm2, xmm7
00000001411bb637: mulss    xmm2, xmm7
00000001411bb63b: movaps   xmm7, xmmword ptr [rax - 0x28]
00000001411bb63f: addss    xmm0, xmm0
00000001411bb643: addss    xmm1, xmm1
00000001411bb647: movss    dword ptr [rcx + 4], xmm0
00000001411bb64c: movaps   xmm0, xmm4
00000001411bb64f: addss    xmm0, xmm3
00000001411bb653: subss    xmm4, xmm3
00000001411bb657: addss    xmm0, xmm0
00000001411bb65b: addss    xmm4, xmm4
00000001411bb65f: movss    dword ptr [rcx + 8], xmm0
00000001411bb664: movaps   xmm0, xmm8
00000001411bb668: movss    dword ptr [rcx + 0xc], xmm1
00000001411bb66d: movaps   xmm1, xmm2
00000001411bb670: addss    xmm2, xmm10
00000001411bb675: movaps   xmm10, xmmword ptr [rax - 0x58]
00000001411bb67a: addss    xmm1, xmm5
00000001411bb67e: addss    xmm2, xmm2
00000001411bb682: addss    xmm1, xmm1
00000001411bb686: subss    xmm8, xmm2
00000001411bb68b: subss    xmm0, xmm1
00000001411bb68f: movss    dword ptr [rcx + 0x10], xmm0
00000001411bb694: movaps   xmm0, xmm9
00000001411bb698: subss    xmm0, xmm11
00000001411bb69d: addss    xmm11, xmm9
00000001411bb6a2: movaps   xmm9, xmmword ptr [rax - 0x48]
00000001411bb6a7: addss    xmm0, xmm0
00000001411bb6ab: addss    xmm11, xmm11
00000001411bb6b0: movss    dword ptr [rcx + 0x14], xmm0
00000001411bb6b5: movss    dword ptr [rcx + 0x18], xmm4
00000001411bb6ba: movss    dword ptr [rcx + 0x1c], xmm11
00000001411bb6c0: movaps   xmm11, xmmword ptr [rsp]
00000001411bb6c5: movss    dword ptr [rcx + 0x20], xmm8
00000001411bb6cb: movaps   xmm8, xmmword ptr [rax - 0x38]
00000001411bb6d0: add      rsp, 0x68
00000001411bb6d4: ret      
