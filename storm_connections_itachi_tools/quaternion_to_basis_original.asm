00000001412ac260: push     rbx
00000001412ac262: sub      rsp, 0x30
00000001412ac266: movss    xmm0, dword ptr [rcx + 0xc]
00000001412ac26b: mov      rbx, rdx
00000001412ac26e: movss    xmm3, dword ptr [rcx + 8]
00000001412ac273: movss    xmm2, dword ptr [rcx + 4]
00000001412ac278: movss    xmm1, dword ptr [rcx]
00000001412ac27c: mov      rcx, rdx
00000001412ac27f: movss    dword ptr [rsp + 0x20], xmm0
00000001412ac285: call     0x1411f1950
00000001412ac28a: mov      rax, rbx
00000001412ac28d: add      rsp, 0x30
00000001412ac291: pop      rbx
00000001412ac292: ret      
