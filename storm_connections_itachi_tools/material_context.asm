00000001412f7530: xor      eax, eax
00000001412f7532: ret      
00000001412f7533: int3     
00000001412f7534: int3     
00000001412f7535: int3     
00000001412f7536: int3     
00000001412f7537: int3     
00000001412f7538: int3     
00000001412f7539: int3     
00000001412f753a: int3     
00000001412f753b: int3     
00000001412f753c: int3     
00000001412f753d: int3     
00000001412f753e: int3     
00000001412f753f: int3     
00000001412f7540: mov      qword ptr [rsp + 8], rbx
00000001412f7545: mov      qword ptr [rsp + 0x10], rsi
00000001412f754a: push     rdi
00000001412f754b: sub      rsp, 0x20
00000001412f754f: lea      rsi, [rcx + 0x38]
00000001412f7553: mov      rbx, rcx
00000001412f7556: mov      rcx, rsi
00000001412f7559: mov      rdi, rdx
00000001412f755c: call     0x1412a7920
00000001412f7561: mov      rcx, qword ptr [rbx + 0x20]
00000001412f7565: lea      r8, [rdi + 0xf]
00000001412f7569: and      r8, 0xfffffffffffffff0
00000001412f756d: mov      rdx, qword ptr [rcx + 0x28]
00000001412f7571: add      r8, rdx
00000001412f7574: cmp      r8, 0x300000
00000001412f757b: jbe      0x1412f7581
00000001412f757d: xor      ebx, ebx
00000001412f757f: jmp      0x1412f758c
00000001412f7581: mov      rbx, qword ptr [rcx + 0x20]
00000001412f7585: add      rbx, rdx
00000001412f7588: mov      qword ptr [rcx + 0x28], r8
00000001412f758c: mov      rcx, rsi
