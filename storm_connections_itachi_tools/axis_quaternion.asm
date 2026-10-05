00000001411f1870: mov      qword ptr [rsp + 8], rbx
00000001411f1875: push     rdi
00000001411f1876: sub      rsp, 0x40
00000001411f187a: movaps   xmmword ptr [rsp + 0x30], xmm6
00000001411f187f: mov      rbx, rdx
00000001411f1882: movaps   xmm6, xmm2
00000001411f1885: movaps   xmmword ptr [rsp + 0x20], xmm7
00000001411f188a: mulss    xmm6, dword ptr [rip + 0x578bb6]
00000001411f1892: mov      rdi, rcx
00000001411f1895: movaps   xmm0, xmm6
00000001411f1898: call     0x1411db7d0
00000001411f189d: movaps   xmm7, xmm0
00000001411f18a0: movaps   xmm0, xmm6
00000001411f18a3: call     0x1411dbd00
00000001411f18a8: movaps   xmm6, xmmword ptr [rsp + 0x30]
00000001411f18ad: movaps   xmm1, xmm0
00000001411f18b0: mulss    xmm1, dword ptr [rbx]
00000001411f18b4: movaps   xmm2, xmm0
00000001411f18b7: mov      rax, rdi
00000001411f18ba: movss    dword ptr [rdi], xmm1
00000001411f18be: mulss    xmm2, dword ptr [rbx + 4]
00000001411f18c3: movss    dword ptr [rdi + 4], xmm2
00000001411f18c8: mulss    xmm0, dword ptr [rbx + 8]
00000001411f18cd: mov      rbx, qword ptr [rsp + 0x50]
00000001411f18d2: movss    dword ptr [rdi + 0xc], xmm7
00000001411f18d7: movaps   xmm7, xmmword ptr [rsp + 0x20]
00000001411f18dc: movss    dword ptr [rdi + 8], xmm0
00000001411f18e1: add      rsp, 0x40
00000001411f18e5: pop      rdi
00000001411f18e6: ret      
