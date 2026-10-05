00000001413946b0: xor      eax, eax
00000001413946b2: mov      qword ptr [rcx + 0x18], rdx
00000001413946b6: mov      word ptr [rcx + 8], ax
00000001413946ba: mov      qword ptr [rcx + 0xc], rax
00000001413946be: lea      rax, [rip + 0x810ae3]
00000001413946c5: mov      qword ptr [rcx], rax
00000001413946c8: mov      rax, rcx
00000001413946cb: ret      
00000001413946cc: int3     
00000001413946cd: int3     
00000001413946ce: int3     
00000001413946cf: int3     
00000001413946d0: lea      rax, [rip + 0x80b919]
00000001413946d7: mov      qword ptr [rcx], rax
00000001413946da: ret      
00000001413946db: int3     
00000001413946dc: int3     
00000001413946dd: int3     
00000001413946de: int3     
00000001413946df: int3     
00000001413946e0: push     rbx
00000001413946e2: sub      rsp, 0x20
00000001413946e6: lea      rax, [rip + 0x80b903]
00000001413946ed: mov      rbx, rcx
00000001413946f0: mov      qword ptr [rcx], rax
00000001413946f3: test     dl, 1
00000001413946f6: je       0x141394702
00000001413946f8: mov      edx, 0x20
00000001413946fd: call     0x141272800
0000000141394702: mov      rax, rbx
0000000141394705: add      rsp, 0x20
0000000141394709: pop      rbx
000000014139470a: ret      
000000014139470b: int3     
000000014139470c: int3     
000000014139470d: int3     
000000014139470e: int3     
000000014139470f: int3     
0000000141394710: push     rbx
0000000141394712: push     rsi
0000000141394713: push     rdi
0000000141394714: sub      rsp, 0x40
0000000141394718: mov      rax, qword ptr [rip + 0xd51ca9]
000000014139471f: xor      rax, rsp
0000000141394722: mov      qword ptr [rsp + 0x30], rax
0000000141394727: mov      rbx, rcx
000000014139472a: mov      edi, r8d
000000014139472d: lea      rcx, [rsp + 0x20]
0000000141394732: mov      rsi, rdx
0000000141394735: call     0x1412aa0a0
000000014139473a: mov      rax, qword ptr [rbx]
000000014139473d: lea      rdx, [rsp + 0x20]
0000000141394742: mov      r8d, edi
0000000141394745: mov      rcx, rbx
0000000141394748: call     qword ptr [rax + 0x30]
000000014139474b: lea      rdx, [rsp + 0x20]
0000000141394750: mov      rcx, rsi
0000000141394753: call     0x14127e760
0000000141394758: mov      rcx, qword ptr [rsp + 0x30]
000000014139475d: xor      rcx, rsp
0000000141394760: call     0x141441dc0
0000000141394765: add      rsp, 0x40
0000000141394769: pop      rdi
000000014139476a: pop      rsi
000000014139476b: pop      rbx
000000014139476c: ret      
000000014139476d: int3     
000000014139476e: int3     
000000014139476f: int3     
0000000141394770: push     rbx
0000000141394772: push     rsi
0000000141394773: push     rdi
0000000141394774: sub      rsp, 0x40
0000000141394778: mov      rax, qword ptr [rip + 0xd51c49]
000000014139477f: xor      rax, rsp
0000000141394782: mov      qword ptr [rsp + 0x30], rax
0000000141394787: mov      rbx, rcx
000000014139478a: mov      edi, r8d
000000014139478d: lea      rcx, [rsp + 0x20]
0000000141394792: mov      rsi, rdx
0000000141394795: call     0x1412aa0a0
000000014139479a: mov      rax, qword ptr [rbx]
000000014139479d: lea      rdx, [rsp + 0x20]
00000001413947a2: mov      r8d, edi
00000001413947a5: mov      rcx, rbx
00000001413947a8: call     qword ptr [rax + 0x30]
00000001413947ab: lea      rdx, [rsp + 0x20]
00000001413947b0: mov      rcx, rsi
00000001413947b3: call     0x14127e760
00000001413947b8: mov      rcx, qword ptr [rsp + 0x30]
00000001413947bd: xor      rcx, rsp
00000001413947c0: call     0x141441dc0
00000001413947c5: add      rsp, 0x40
00000001413947c9: pop      rdi
00000001413947ca: pop      rsi
00000001413947cb: pop      rbx
00000001413947cc: ret      
00000001413947cd: int3     
00000001413947ce: int3     
00000001413947cf: int3     
00000001413947d0: push     rbx
00000001413947d2: push     rbp
00000001413947d3: push     rsi
00000001413947d4: push     rdi
00000001413947d5: push     r14
00000001413947d7: sub      rsp, 0x90
00000001413947de: mov      rax, qword ptr [rip + 0xd51be3]
00000001413947e5: xor      rax, rsp
00000001413947e8: mov      qword ptr [rsp + 0x70], rax
00000001413947ed: mov      rbx, qword ptr [rcx + 0x18]
00000001413947f1: mov      eax, r8d
00000001413947f4: mov      rsi, rdx
00000001413947f7: mov      rbp, rcx
00000001413947fa: xor      edx, edx
00000001413947fc: div      dword ptr [rbx]
00000001413947fe: mov      edi, eax
0000000141394800: mov      r14d, edx
0000000141394803: movsx    eax, word ptr [rbx + rax*8 + 4]
0000000141394808: movsx    r8d, word ptr [rbx + rdi*8 + 8]
000000014139480e: movsx    ecx, word ptr [rbx + rdi*8 + 6]
0000000141394813: movsx    r9d, word ptr [rbx + rdi*8 + 0xa]
0000000141394819: movd     xmm0, eax
000000014139481d: movd     xmm1, r8d
0000000141394822: cvtdq2ps xmm1, xmm1
0000000141394825: cvtdq2ps xmm0, xmm0
0000000141394828: test     edx, edx
000000014139482a: jne      0x14139487d
000000014139482c: movss    xmm2, dword ptr [rip + 0x8109cc]
0000000141394834: lea      rdx, [rsp + 0x20]
0000000141394839: mulss    xmm0, xmm2
000000014139483d: mulss    xmm1, xmm2
0000000141394841: movss    dword ptr [rsp + 0x20], xmm0
0000000141394847: movd     xmm0, ecx
000000014139484b: mov      rcx, rsi
000000014139484e: cvtdq2ps xmm0, xmm0
0000000141394851: movss    dword ptr [rsp + 0x28], xmm1
0000000141394857: mulss    xmm0, xmm2
000000014139485b: movss    dword ptr [rsp + 0x24], xmm0
0000000141394861: movd     xmm0, r9d
0000000141394866: cvtdq2ps xmm0, xmm0
0000000141394869: mulss    xmm0, xmm2
000000014139486d: movss    dword ptr [rsp + 0x2c], xmm0
0000000141394873: call     0x1412ab8b0
0000000141394878: jmp      0x14139498a
000000014139487d: movaps   xmmword ptr [rsp + 0x80], xmm6
0000000141394885: movss    xmm6, dword ptr [rip + 0x810973]
000000014139488d: mulss    xmm0, xmm6
0000000141394891: mulss    xmm1, xmm6
0000000141394895: movss    dword ptr [rsp + 0x20], xmm0
000000014139489b: movd     xmm0, ecx
000000014139489f: lea      rcx, [rsp + 0x50]
00000001413948a4: cvtdq2ps xmm0, xmm0
00000001413948a7: movss    dword ptr [rsp + 0x28], xmm1
00000001413948ad: mulss    xmm0, xmm6
00000001413948b1: movss    dword ptr [rsp + 0x24], xmm0
00000001413948b7: movd     xmm0, r9d
00000001413948bc: cvtdq2ps xmm0, xmm0
00000001413948bf: mulss    xmm0, xmm6
00000001413948c3: movss    dword ptr [rsp + 0x2c], xmm0
00000001413948c9: call     0x1412aa0a0
00000001413948ce: lea      rdx, [rsp + 0x20]
00000001413948d3: lea      rcx, [rsp + 0x50]
00000001413948d8: call     0x1412ab8b0
00000001413948dd: movsx    eax, word ptr [rbx + rdi*8 + 0xc]
00000001413948e2: lea      rcx, [rsp + 0x40]
00000001413948e7: movd     xmm0, eax
00000001413948eb: movsx    eax, word ptr [rbx + rdi*8 + 0xe]
00000001413948f0: cvtdq2ps xmm0, xmm0
00000001413948f3: movd     xmm1, eax
00000001413948f7: movsx    eax, word ptr [rbx + rdi*8 + 0x10]
00000001413948fc: cvtdq2ps xmm1, xmm1
00000001413948ff: mulss    xmm0, xmm6
0000000141394903: mulss    xmm1, xmm6
0000000141394907: movss    dword ptr [rsp + 0x30], xmm0
000000014139490d: movd     xmm0, eax
0000000141394911: movsx    eax, word ptr [rbx + rdi*8 + 0x12]
0000000141394916: movss    dword ptr [rsp + 0x34], xmm1
000000014139491c: cvtdq2ps xmm0, xmm0
000000014139491f: movd     xmm1, eax
0000000141394923: cvtdq2ps xmm1, xmm1
0000000141394926: mulss    xmm0, xmm6
000000014139492a: mulss    xmm1, xmm6
000000014139492e: movss    dword ptr [rsp + 0x38], xmm0
0000000141394934: movss    dword ptr [rsp + 0x3c], xmm1
000000014139493a: call     0x1412aa0a0
000000014139493f: lea      rdx, [rsp + 0x30]
0000000141394944: lea      rcx, [rsp + 0x40]
0000000141394949: call     0x1412ab8b0
000000014139494e: mov      rax, qword ptr [rbp + 0x18]
0000000141394952: lea      r8, [rsp + 0x40]
0000000141394957: xorps    xmm3, xmm3
000000014139495a: lea      rdx, [rsp + 0x60]
000000014139495f: xorps    xmm0, xmm0
0000000141394962: cvtsi2ss xmm3, r14
0000000141394967: mov      ecx, dword ptr [rax]
0000000141394969: cvtsi2ss xmm0, rcx
000000014139496e: lea      rcx, [rsp + 0x50]
0000000141394973: divss    xmm3, xmm0
0000000141394977: call     0x1412ab9c0
000000014139497c: movaps   xmm6, xmmword ptr [rsp + 0x80]
0000000141394984: movups   xmm0, xmmword ptr [rax]
0000000141394987: movups   xmmword ptr [rsi], xmm0
000000014139498a: mov      rcx, qword ptr [rsp + 0x70]
000000014139498f: xor      rcx, rsp
0000000141394992: call     0x141441dc0
0000000141394997: add      rsp, 0x90
000000014139499e: pop      r14
00000001413949a0: pop      rdi
00000001413949a1: pop      rsi
00000001413949a2: pop      rbp
00000001413949a3: pop      rbx
00000001413949a4: ret      
00000001413949a5: int3     
00000001413949a6: int3     
00000001413949a7: int3     
00000001413949a8: int3     
00000001413949a9: int3     
00000001413949aa: int3     
00000001413949ab: int3     
00000001413949ac: int3     
00000001413949ad: int3     
00000001413949ae: int3     
00000001413949af: int3     
