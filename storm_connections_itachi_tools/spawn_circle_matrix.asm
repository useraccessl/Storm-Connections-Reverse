00000001411ed810: push     rbx
00000001411ed812: sub      rsp, 0x40
00000001411ed816: movaps   xmmword ptr [rsp + 0x30], xmm6
00000001411ed81b: movaps   xmm0, xmm1
00000001411ed81e: movaps   xmmword ptr [rsp + 0x20], xmm7
00000001411ed823: movaps   xmm6, xmm1
00000001411ed826: mov      rbx, rcx
00000001411ed829: call     0x1411db7d0
00000001411ed82e: movaps   xmm7, xmm0
00000001411ed831: movaps   xmm0, xmm6
00000001411ed834: call     0x1411dbd00
00000001411ed839: movaps   xmm6, xmmword ptr [rsp + 0x30]
00000001411ed83e: xor      eax, eax
00000001411ed840: movss    dword ptr [rbx], xmm7
00000001411ed844: movaps   xmm1, xmm0
00000001411ed847: xorps    xmm1, xmmword ptr [rip + 0x573952]
00000001411ed84e: movss    dword ptr [rbx + 4], xmm1
00000001411ed853: mov      qword ptr [rbx + 8], rax
00000001411ed857: movss    dword ptr [rbx + 0x10], xmm0
00000001411ed85c: movaps   xmm0, xmmword ptr [rip + 0x5b171d]
00000001411ed863: movss    dword ptr [rbx + 0x14], xmm7
00000001411ed868: movaps   xmm7, xmmword ptr [rsp + 0x20]
00000001411ed86d: mov      qword ptr [rbx + 0x18], rax
00000001411ed871: mov      qword ptr [rbx + 0x20], rax
00000001411ed875: mov      rax, rbx
00000001411ed878: mov      qword ptr [rbx + 0x28], 0x3f800000
00000001411ed880: movups   xmmword ptr [rbx + 0x30], xmm0
00000001411ed884: add      rsp, 0x40
00000001411ed888: pop      rbx
00000001411ed889: ret      
