00000001412ab9c0: mov      qword ptr [rsp + 8], rbx
00000001412ab9c5: push     rdi
00000001412ab9c6: sub      rsp, 0x70
00000001412ab9ca: movss    xmm0, dword ptr [r8 + 0xc]
00000001412ab9d0: mov      rbx, rcx
00000001412ab9d3: movss    xmm2, dword ptr [r8 + 4]
00000001412ab9d9: lea      rcx, [rsp + 0x30]
00000001412ab9de: movss    xmm1, dword ptr [r8]
00000001412ab9e3: mov      rdi, rdx
00000001412ab9e6: movaps   xmmword ptr [rsp + 0x60], xmm6
00000001412ab9eb: movaps   xmm6, xmm3
00000001412ab9ee: movss    xmm3, dword ptr [r8 + 8]
00000001412ab9f4: movss    dword ptr [rsp + 0x20], xmm0
00000001412ab9fa: call     0x1411f1950
00000001412ab9ff: movss    xmm0, dword ptr [rbx + 0xc]
00000001412aba04: lea      rcx, [rsp + 0x40]
00000001412aba09: movss    xmm3, dword ptr [rbx + 8]
00000001412aba0e: movss    xmm2, dword ptr [rbx + 4]
00000001412aba13: movss    xmm1, dword ptr [rbx]
00000001412aba17: movss    dword ptr [rsp + 0x20], xmm0
00000001412aba1d: call     0x1411f1950
00000001412aba22: movaps   xmm3, xmm6
00000001412aba25: lea      r8, [rsp + 0x30]
00000001412aba2a: lea      rdx, [rsp + 0x50]
00000001412aba2f: lea      rcx, [rsp + 0x40]
00000001412aba34: call     0x1411f4e90
00000001412aba39: mov      rcx, rax
00000001412aba3c: mov      rbx, rax
00000001412aba3f: call     0x1411f5f30
00000001412aba44: mov      ecx, dword ptr [rax]
00000001412aba46: mov      dword ptr [rdi], ecx
00000001412aba48: mov      rcx, rbx
00000001412aba4b: call     0x1411f5f30
00000001412aba50: mov      ecx, dword ptr [rax + 4]
00000001412aba53: mov      dword ptr [rdi + 4], ecx
00000001412aba56: mov      rcx, rbx
00000001412aba59: call     0x1411f5f30
00000001412aba5e: mov      ecx, dword ptr [rax + 8]
00000001412aba61: mov      dword ptr [rdi + 8], ecx
00000001412aba64: mov      rcx, rbx
00000001412aba67: call     0x1411f5f30
00000001412aba6c: mov      rbx, qword ptr [rsp + 0x80]
00000001412aba74: movaps   xmm6, xmmword ptr [rsp + 0x60]
00000001412aba79: mov      ecx, dword ptr [rax + 0xc]
00000001412aba7c: mov      rax, rdi
00000001412aba7f: mov      dword ptr [rdi + 0xc], ecx
00000001412aba82: add      rsp, 0x70
00000001412aba86: pop      rdi
00000001412aba87: ret      
