00000001411ed500: push     rbx
00000001411ed502: sub      rsp, 0x40
00000001411ed506: movaps   xmmword ptr [rsp + 0x30], xmm6
00000001411ed50b: movaps   xmm0, xmm1
00000001411ed50e: movaps   xmmword ptr [rsp + 0x20], xmm7
00000001411ed513: movaps   xmm6, xmm1
00000001411ed516: mov      rbx, rcx
00000001411ed519: call     0x1411db7d0
00000001411ed51e: movaps   xmm7, xmm0
00000001411ed521: movaps   xmm0, xmm6
00000001411ed524: call     0x1411dbd00
00000001411ed529: movaps   xmm6, xmmword ptr [rsp + 0x30]
00000001411ed52e: xor      eax, eax
00000001411ed530: mov      qword ptr [rbx], 0x3f800000
00000001411ed537: movaps   xmm1, xmm0
00000001411ed53a: xorps    xmm1, xmmword ptr [rip + 0x573c5f]
00000001411ed541: mov      qword ptr [rbx + 8], rax
00000001411ed545: mov      dword ptr [rbx + 0x10], eax
00000001411ed548: movss    dword ptr [rbx + 0x14], xmm7
00000001411ed54d: movss    dword ptr [rbx + 0x18], xmm1
00000001411ed552: mov      qword ptr [rbx + 0x1c], rax
00000001411ed556: movss    dword ptr [rbx + 0x24], xmm0
00000001411ed55b: movaps   xmm0, xmmword ptr [rip + 0x5b1a1e]
00000001411ed562: movss    dword ptr [rbx + 0x28], xmm7
00000001411ed567: movaps   xmm7, xmmword ptr [rsp + 0x20]
00000001411ed56c: movups   xmmword ptr [rbx + 0x30], xmm0
00000001411ed570: mov      dword ptr [rbx + 0x2c], eax
00000001411ed573: mov      rax, rbx
00000001411ed576: add      rsp, 0x40
00000001411ed57a: pop      rbx
00000001411ed57b: ret      
