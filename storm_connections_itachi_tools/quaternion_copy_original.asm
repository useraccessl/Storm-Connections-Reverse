00000001412ab8b0: push     rbx
00000001412ab8b2: sub      rsp, 0x40
00000001412ab8b6: movss    xmm0, dword ptr [rdx + 0xc]
00000001412ab8bb: mov      rbx, rcx
00000001412ab8be: movss    xmm3, dword ptr [rdx + 8]
00000001412ab8c3: lea      rcx, [rsp + 0x30]
00000001412ab8c8: movss    xmm2, dword ptr [rdx + 4]
00000001412ab8cd: movss    xmm1, dword ptr [rdx]
00000001412ab8d1: movss    dword ptr [rsp + 0x20], xmm0
00000001412ab8d7: call     0x1411f1950
00000001412ab8dc: lea      rcx, [rsp + 0x30]
00000001412ab8e1: call     0x1411f2000
00000001412ab8e6: lea      rcx, [rsp + 0x30]
00000001412ab8eb: call     0x1411f5f20
00000001412ab8f0: movups   xmm0, xmmword ptr [rax]
00000001412ab8f3: movups   xmmword ptr [rbx], xmm0
00000001412ab8f6: add      rsp, 0x40
00000001412ab8fa: pop      rbx
00000001412ab8fb: ret      
00000001412ab8fc: int3     
00000001412ab8fd: int3     
00000001412ab8fe: int3     
00000001412ab8ff: int3     
00000001412ab900: mov      qword ptr [rsp + 8], rbx
00000001412ab905: push     rdi
00000001412ab906: sub      rsp, 0x80
00000001412ab90d: movss    xmm0, dword ptr [rdx + 0xc]
00000001412ab912: mov      rdi, rcx
00000001412ab915: movss    xmm3, dword ptr [rdx + 8]
00000001412ab91a: lea      rcx, [rsp + 0x30]
00000001412ab91f: movss    xmm2, dword ptr [rdx + 4]
00000001412ab924: movss    xmm1, dword ptr [rdx]
00000001412ab928: movaps   xmmword ptr [rsp + 0x70], xmm6
00000001412ab92d: movaps   xmmword ptr [rsp + 0x60], xmm7
00000001412ab932: movss    dword ptr [rsp + 0x20], xmm0
00000001412ab938: movaps   xmmword ptr [rsp + 0x50], xmm8
00000001412ab93e: call     0x1411f1950
00000001412ab943: lea      rdx, [rsp + 0x40]
00000001412ab948: lea      rcx, [rsp + 0x30]
00000001412ab94d: call     0x1411f2010
00000001412ab952: mov      rcx, rax
00000001412ab955: mov      rbx, rax
00000001412ab958: call     0x1411f5f30
00000001412ab95d: mov      rcx, rbx
00000001412ab960: movss    xmm8, dword ptr [rax]
00000001412ab965: call     0x1411f5f30
00000001412ab96a: mov      rcx, rbx
00000001412ab96d: movss    xmm7, dword ptr [rax + 4]
00000001412ab972: call     0x1411f5f30
00000001412ab977: mov      rcx, rbx
00000001412ab97a: movss    xmm6, dword ptr [rax + 8]
00000001412ab97f: call     0x1411f5f30
00000001412ab984: movss    xmm0, dword ptr [rax + 0xc]
00000001412ab989: movss    dword ptr [rdi], xmm8
00000001412ab98e: movss    dword ptr [rdi + 4], xmm7
00000001412ab993: movss    dword ptr [rdi + 8], xmm6
00000001412ab998: movss    dword ptr [rdi + 0xc], xmm0
00000001412ab99d: mov      rbx, qword ptr [rsp + 0x90]
00000001412ab9a5: movaps   xmm6, xmmword ptr [rsp + 0x70]
00000001412ab9aa: movaps   xmm7, xmmword ptr [rsp + 0x60]
00000001412ab9af: movaps   xmm8, xmmword ptr [rsp + 0x50]
00000001412ab9b5: add      rsp, 0x80
00000001412ab9bc: pop      rdi
00000001412ab9bd: ret      
00000001412ab9be: int3     
00000001412ab9bf: int3     
