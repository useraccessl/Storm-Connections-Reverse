0000000140a6b2e0: mov      rax, rsp
0000000140a6b2e3: mov      qword ptr [rax + 0x20], rbx
0000000140a6b2e7: push     rbp
0000000140a6b2e8: push     rsi
0000000140a6b2e9: push     rdi
0000000140a6b2ea: push     r12
0000000140a6b2ec: push     r13
0000000140a6b2ee: push     r14
0000000140a6b2f0: push     r15
0000000140a6b2f2: lea      rbp, [rax - 0x478]
0000000140a6b2f9: sub      rsp, 0x540
0000000140a6b300: movaps   xmmword ptr [rax - 0x48], xmm6
0000000140a6b304: movaps   xmmword ptr [rax - 0x58], xmm7
0000000140a6b308: movaps   xmmword ptr [rax - 0x68], xmm8
0000000140a6b30d: movaps   xmmword ptr [rax - 0x78], xmm9
0000000140a6b312: movaps   xmmword ptr [rax - 0x88], xmm10
0000000140a6b31a: movaps   xmmword ptr [rax - 0x98], xmm11
0000000140a6b322: movaps   xmmword ptr [rax - 0xa8], xmm12
0000000140a6b32a: mov      rax, qword ptr [rip + 0x167b097]
0000000140a6b331: xor      rax, rsp
0000000140a6b334: mov      qword ptr [rbp + 0x3c0], rax
0000000140a6b33b: mov      r14, r8
0000000140a6b33e: mov      r15, rdx
0000000140a6b341: mov      rsi, rcx
0000000140a6b344: mov      r13d, dword ptr [rdx + 0x44]
0000000140a6b348: mov      edi, dword ptr [rdx + 0x48]
0000000140a6b34b: call     0x1400bfa80
0000000140a6b350: movsd    xmm0, qword ptr [rax]
0000000140a6b354: movsd    qword ptr [rsp + 0x20], xmm0
0000000140a6b35a: mov      eax, dword ptr [rax + 8]
0000000140a6b35d: mov      dword ptr [rsp + 0x28], eax
0000000140a6b361: call     0x1400bfa80
0000000140a6b366: movsd    xmm0, qword ptr [rax]
0000000140a6b36a: movsd    qword ptr [rsp + 0x30], xmm0
0000000140a6b370: mov      eax, dword ptr [rax + 8]
0000000140a6b373: mov      dword ptr [rsp + 0x38], eax
0000000140a6b377: movss    xmm3, dword ptr [rip + 0xd0c3a5]
0000000140a6b37f: xorps    xmm8, xmm8
0000000140a6b383: xorps    xmm2, xmm2
0000000140a6b386: xorps    xmm1, xmm1
0000000140a6b389: lea      rcx, [rbp - 0x78]
0000000140a6b38d: call     0x1411ab440
0000000140a6b392: movsd    xmm0, qword ptr [rsi + 0x34]
0000000140a6b397: movsd    qword ptr [rsp + 0x50], xmm0
0000000140a6b39d: mov      eax, dword ptr [rsi + 0x3c]
0000000140a6b3a0: mov      dword ptr [rsp + 0x58], eax
0000000140a6b3a4: movsd    xmm12, qword ptr [rsi + 0x40]
0000000140a6b3aa: mov      r12d, dword ptr [rsi + 0x48]
0000000140a6b3ae: mov      edx, dword ptr [rsi + 0x4c]
0000000140a6b3b1: cmp      edx, dword ptr [rip + 0x110cb75]
0000000140a6b3b7: je       0x140a6b427
0000000140a6b3b9: mov      r9, qword ptr [rip + 0x176c0e0]
0000000140a6b3c0: mov      r8, qword ptr [r9 + 0x58]
0000000140a6b3c4: mov      rax, qword ptr [r8 + 8]
0000000140a6b3c8: mov      rcx, r8
0000000140a6b3cb: cmp      byte ptr [rax + 0x19], 0
0000000140a6b3cf: jne      0x140a6b3e8
0000000140a6b3d1: cmp      dword ptr [rax + 0x20], edx
0000000140a6b3d4: jae      0x140a6b3dc
0000000140a6b3d6: mov      rax, qword ptr [rax + 0x10]
0000000140a6b3da: jmp      0x140a6b3e2
0000000140a6b3dc: mov      rcx, rax
0000000140a6b3df: mov      rax, qword ptr [rax]
0000000140a6b3e2: cmp      byte ptr [rax + 0x19], 0
0000000140a6b3e6: je       0x140a6b3d1
0000000140a6b3e8: cmp      byte ptr [rcx + 0x19], 0
0000000140a6b3ec: jne      0x140a6b3f3
0000000140a6b3ee: cmp      edx, dword ptr [rcx + 0x20]
0000000140a6b3f1: jae      0x140a6b3f6
0000000140a6b3f3: mov      rcx, r8
0000000140a6b3f6: cmp      rcx, r8
0000000140a6b3f9: je       0x140a6b427
0000000140a6b3fb: mov      rax, qword ptr [rcx + 0x28]
0000000140a6b3ff: test     rax, rax
0000000140a6b402: je       0x140a6b427
0000000140a6b404: movsd    xmm7, qword ptr [rax + 0x70]
0000000140a6b409: mov      eax, dword ptr [rax + 0x78]
0000000140a6b40c: mov      dword ptr [rsp + 0x28], eax
0000000140a6b410: movsd    qword ptr [rsp + 0x20], xmm7
0000000140a6b416: movaps   xmm10, xmm7
0000000140a6b41a: movss    xmm9, dword ptr [rsp + 0x24]
0000000140a6b421: movaps   xmm11, xmm9
0000000140a6b425: jmp      0x140a6b442
0000000140a6b427: movss    xmm9, dword ptr [rsp + 0x24]
0000000140a6b42e: movss    xmm7, dword ptr [rsp + 0x20]
0000000140a6b434: movss    xmm11, dword ptr [rsp + 0x34]
0000000140a6b43b: movss    xmm10, dword ptr [rsp + 0x30]
0000000140a6b442: mov      dword ptr [rsp + 0x38], 0
0000000140a6b44a: lea      ebx, [rdi + rdi]
0000000140a6b44d: call     0x14127da70
0000000140a6b452: cdq      
0000000140a6b453: idiv     ebx
0000000140a6b455: sub      edx, edi
0000000140a6b457: movd     xmm6, edx
0000000140a6b45b: cvtdq2ps xmm6, xmm6
0000000140a6b45e: call     0x14127da70
0000000140a6b463: cdq      
0000000140a6b464: idiv     ebx
0000000140a6b466: sub      edx, edi
0000000140a6b468: movd     xmm0, edx
0000000140a6b46c: cvtdq2ps xmm0, xmm0
0000000140a6b46f: addss    xmm10, xmm6
0000000140a6b474: movss    dword ptr [rsp + 0x30], xmm10
0000000140a6b47b: addss    xmm11, xmm0
0000000140a6b480: movss    dword ptr [rsp + 0x34], xmm11
0000000140a6b487: movaps   xmm3, xmm8
0000000140a6b48b: movaps   xmm2, xmm8
0000000140a6b48f: movaps   xmm1, xmm8
0000000140a6b493: lea      rcx, [rsp + 0x68]
0000000140a6b498: call     0x1411ab440
0000000140a6b49d: lea      rcx, [rsp + 0x74]
0000000140a6b4a2: call     0x1412b2110
0000000140a6b4a7: nop      
0000000140a6b4a8: movss    dword ptr [rsp + 0x40], xmm10
0000000140a6b4af: movss    dword ptr [rsp + 0x44], xmm11
0000000140a6b4b6: mov      dword ptr [rsp + 0x48], 0
0000000140a6b4be: lea      rdx, [rsp + 0x40]
0000000140a6b4c3: lea      rcx, [rsp + 0x74]
0000000140a6b4c8: call     0x1412b3280
0000000140a6b4cd: movd     xmm1, r13d
0000000140a6b4d2: cvtdq2ps xmm1, xmm1
0000000140a6b4d5: lea      rcx, [rsp + 0x74]
0000000140a6b4da: call     0x1412b2610
0000000140a6b4df: movsd    xmm0, qword ptr [rbp - 0x78]
0000000140a6b4e4: movsd    qword ptr [rsp + 0x68], xmm0
0000000140a6b4ea: mov      eax, dword ptr [rbp - 0x70]
0000000140a6b4ed: mov      dword ptr [rsp + 0x70], eax
0000000140a6b4f1: mov      rcx, qword ptr [rip + 0x1762cb8]
0000000140a6b4f8: mov      r13d, 1
0000000140a6b4fe: test     rcx, rcx
0000000140a6b501: je       0x140a6b5cf
0000000140a6b507: call     0x140a7c500
0000000140a6b50c: mov      rbx, rax
0000000140a6b50f: test     rax, rax
0000000140a6b512: je       0x140a6b5cf
0000000140a6b518: lea      rcx, [rbp + 0x200]
0000000140a6b51f: call     0x14021d2d0
0000000140a6b524: nop      
0000000140a6b525: mov      r9d, r13d
0000000140a6b528: mov      r8, rbx
0000000140a6b52b: lea      rdx, [rsp + 0x68]
0000000140a6b530: lea      rcx, [rbp + 0x200]
0000000140a6b537: call     0x140acb1c0
0000000140a6b53c: comiss   xmm0, xmm8
0000000140a6b540: jae      0x140a6b5b2
0000000140a6b542: mulss    xmm7, dword ptr [rip + 0xd6fb42]
0000000140a6b54a: cvttss2si ebx, xmm7
0000000140a6b54e: mulss    xmm9, dword ptr [rip + 0xd6fb35]
0000000140a6b557: cvttss2si edi, xmm9
0000000140a6b55c: call     0x14127da70
0000000140a6b561: lea      ecx, [rbx + rbx]
0000000140a6b564: cdq      
0000000140a6b565: idiv     ecx
0000000140a6b567: sub      edx, ebx
0000000140a6b569: movd     xmm7, edx
0000000140a6b56d: cvtdq2ps xmm7, xmm7
0000000140a6b570: call     0x14127da70
0000000140a6b575: lea      ecx, [rdi + rdi]
0000000140a6b578: cdq      
0000000140a6b579: idiv     ecx
0000000140a6b57b: sub      edx, edi
0000000140a6b57d: movd     xmm6, edx
0000000140a6b581: cvtdq2ps xmm6, xmm6
0000000140a6b584: call     0x1400bfa80
0000000140a6b589: movsd    xmm0, qword ptr [rax]
0000000140a6b58d: movsd    qword ptr [rsp + 0x40], xmm0
0000000140a6b593: mov      eax, dword ptr [rax + 8]
0000000140a6b596: mov      dword ptr [rsp + 0x48], eax
0000000140a6b59a: movss    dword ptr [rsp + 0x30], xmm7
0000000140a6b5a0: movss    dword ptr [rsp + 0x34], xmm6
0000000140a6b5a6: movss    xmm0, dword ptr [rsp + 0x48]
0000000140a6b5ac: movss    dword ptr [rsp + 0x38], xmm0
0000000140a6b5b2: lea      r9, [rip - 0x84e179]
0000000140a6b5b9: mov      edx, 0x20
0000000140a6b5be: lea      r8d, [rdx - 0x18]
0000000140a6b5c2: lea      rcx, [rbp + 0x208]
0000000140a6b5c9: call     0x14144142c
0000000140a6b5ce: nop      
0000000140a6b5cf: cmp      dword ptr [r15 + 0x50], 0
0000000140a6b5d4: je       0x140a6b6a1
0000000140a6b5da: movsd    xmm0, qword ptr [rsp + 0x50]
0000000140a6b5e0: movsd    qword ptr [rsp + 0x40], xmm0
0000000140a6b5e6: mov      eax, dword ptr [rsp + 0x58]
0000000140a6b5ea: mov      dword ptr [rsp + 0x48], eax
0000000140a6b5ee: mov      r8d, dword ptr [rsi + 0x4c]
0000000140a6b5f2: lea      rdx, [rsp + 0x20]
0000000140a6b5f7: lea      rcx, [rsp + 0x50]
0000000140a6b5fc: call     0x140a6a340
0000000140a6b601: lea      rdx, [rsp + 0x50]
0000000140a6b606: lea      rcx, [rsp + 0x40]
0000000140a6b60b: call     0x1411ac380
0000000140a6b610: ucomiss  xmm0, xmm8
0000000140a6b614: jp       0x140a6b61c
0000000140a6b616: je       0x140a6b6a1
0000000140a6b61c: movaps   xmm3, xmm8
0000000140a6b620: movaps   xmm2, xmm8
0000000140a6b624: movaps   xmm1, xmm8
0000000140a6b628: lea      rcx, [rsp + 0x20]
0000000140a6b62d: call     0x1411ab440
0000000140a6b632: lea      r8, [rsp + 0x50]
0000000140a6b637: lea      rdx, [rbp - 0x68]
0000000140a6b63b: lea      rcx, [rsp + 0x40]
0000000140a6b640: call     0x1411ac0f0
0000000140a6b645: movsd    xmm0, qword ptr [rax]
0000000140a6b649: movsd    qword ptr [rsp + 0x20], xmm0
0000000140a6b64f: mov      eax, dword ptr [rax + 8]
0000000140a6b652: mov      dword ptr [rsp + 0x28], eax
0000000140a6b656: lea      rcx, [rsp + 0x20]
0000000140a6b65b: call     0x1411ac880
0000000140a6b660: comiss   xmm0, xmm8
0000000140a6b664: jbe      0x140a6b6a1
0000000140a6b666: lea      rdx, [rbp - 0x68]
0000000140a6b66a: lea      rcx, [rsp + 0x20]
0000000140a6b66f: call     0x1411acc30
0000000140a6b674: movsd    xmm0, qword ptr [rax]
0000000140a6b678: movsd    qword ptr [rsp + 0x20], xmm0
0000000140a6b67e: mov      eax, dword ptr [rax + 8]
0000000140a6b681: mov      dword ptr [rsp + 0x28], eax
0000000140a6b685: lea      r8, [rsp + 0x50]
0000000140a6b68a: lea      rdx, [rbp - 0x68]
0000000140a6b68e: lea      rcx, [rsp + 0x20]
0000000140a6b693: call     0x1411ac0f0
0000000140a6b698: movsd    xmm12, qword ptr [rax]
0000000140a6b69d: mov      r12d, dword ptr [rax + 8]
0000000140a6b6a1: mov      rdx, rsi
0000000140a6b6a4: lea      rcx, [rbp - 0x50]
0000000140a6b6a8: call     0x140a6a250
0000000140a6b6ad: nop      
0000000140a6b6ae: movsd    xmm0, qword ptr [rsp + 0x30]
0000000140a6b6b4: movsd    qword ptr [rbp - 0x40], xmm0
0000000140a6b6b9: mov      eax, dword ptr [rsp + 0x38]
0000000140a6b6bd: mov      dword ptr [rbp - 0x38], eax
0000000140a6b6c0: movsd    xmm0, qword ptr [rsp + 0x50]
0000000140a6b6c6: movsd    qword ptr [rbp - 0x1c], xmm0
0000000140a6b6cb: mov      eax, dword ptr [rsp + 0x58]
0000000140a6b6cf: mov      dword ptr [rbp - 0x14], eax
0000000140a6b6d2: movsd    qword ptr [rbp - 0x10], xmm12
0000000140a6b6d8: mov      dword ptr [rbp - 8], r12d
0000000140a6b6dc: mov      eax, dword ptr [rbp + 0x10]
0000000140a6b6df: cmp      dword ptr [rsi + 0x60], 0
0000000140a6b6e3: cmovne   eax, r13d
0000000140a6b6e7: mov      dword ptr [rbp + 0x10], eax
0000000140a6b6ea: mov      eax, dword ptr [rbp + 0x14]
0000000140a6b6ed: cmp      dword ptr [rsi + 0x64], 0
0000000140a6b6f1: cmovne   eax, r13d
0000000140a6b6f5: mov      dword ptr [rbp + 0x14], eax
0000000140a6b6f8: mov      rcx, qword ptr [rsi + 0x58]
0000000140a6b6fc: mov      rax, qword ptr [rbp + 8]
0000000140a6b700: test     rcx, rcx
0000000140a6b703: cmovne   rax, rcx
0000000140a6b707: mov      qword ptr [rbp + 8], rax
0000000140a6b70b: lea      rdx, [rsi + 0x78]
0000000140a6b70f: lea      rcx, [rbp + 0x200]
0000000140a6b716: call     0x140a6a0f0
0000000140a6b71b: lea      rax, [rbp + 0x28]
0000000140a6b71f: lea      rcx, [rbp + 0x200]
0000000140a6b726: mov      edx, 3
0000000140a6b72b: nop      dword ptr [rax + rax]
0000000140a6b730: movups   xmm0, xmmword ptr [rcx]
0000000140a6b733: movups   xmmword ptr [rax], xmm0
0000000140a6b736: movups   xmm1, xmmword ptr [rcx + 0x10]
0000000140a6b73a: movups   xmmword ptr [rax + 0x10], xmm1
0000000140a6b73e: movups   xmm0, xmmword ptr [rcx + 0x20]
0000000140a6b742: movups   xmmword ptr [rax + 0x20], xmm0
0000000140a6b746: movups   xmm1, xmmword ptr [rcx + 0x30]
0000000140a6b74a: movups   xmmword ptr [rax + 0x30], xmm1
0000000140a6b74e: movups   xmm0, xmmword ptr [rcx + 0x40]
0000000140a6b752: movups   xmmword ptr [rax + 0x40], xmm0
0000000140a6b756: movups   xmm1, xmmword ptr [rcx + 0x50]
0000000140a6b75a: movups   xmmword ptr [rax + 0x50], xmm1
0000000140a6b75e: movups   xmm0, xmmword ptr [rcx + 0x60]
0000000140a6b762: movups   xmmword ptr [rax + 0x60], xmm0
0000000140a6b766: lea      rax, [rax + 0x80]
0000000140a6b76d: movups   xmm1, xmmword ptr [rcx + 0x70]
0000000140a6b771: movups   xmmword ptr [rax - 0x10], xmm1
0000000140a6b775: lea      rcx, [rcx + 0x80]
0000000140a6b77c: sub      rdx, 1
0000000140a6b780: jne      0x140a6b730
0000000140a6b782: movups   xmm0, xmmword ptr [rcx]
0000000140a6b785: movups   xmmword ptr [rax], xmm0
0000000140a6b788: movups   xmm1, xmmword ptr [rcx + 0x10]
0000000140a6b78c: movups   xmmword ptr [rax + 0x10], xmm1
0000000140a6b790: movups   xmm0, xmmword ptr [rcx + 0x20]
0000000140a6b794: movups   xmmword ptr [rax + 0x20], xmm0
0000000140a6b798: movups   xmm1, xmmword ptr [rcx + 0x30]
0000000140a6b79c: movups   xmmword ptr [rax + 0x30], xmm1
0000000140a6b7a0: movzx    eax, byte ptr [rsi + 0x50]
0000000140a6b7a4: mov      byte ptr [rbp], al
0000000140a6b7a7: lea      rcx, [rbp - 0x50]
0000000140a6b7ab: call     0x140a66080
0000000140a6b7b0: mov      dword ptr [rsp + 0x60], eax
0000000140a6b7b4: mov      rdx, qword ptr [r14 + 0x20]
0000000140a6b7b8: cmp      rdx, qword ptr [r14 + 0x28]
0000000140a6b7bc: je       0x140a6b7c7
0000000140a6b7be: mov      dword ptr [rdx], eax
0000000140a6b7c0: add      qword ptr [r14 + 0x20], 4
0000000140a6b7c5: jmp      0x140a6b7d5
0000000140a6b7c7: lea      r8, [rsp + 0x60]
0000000140a6b7cc: mov      rcx, r14
0000000140a6b7cf: call     0x1400e33a0
0000000140a6b7d4: nop      
0000000140a6b7d5: lea      rax, [rip + 0xcfed9c]
0000000140a6b7dc: mov      qword ptr [rbp - 0x50], rax
0000000140a6b7e0: lea      rcx, [rsp + 0x74]
0000000140a6b7e5: call     0x1412b2180
0000000140a6b7ea: mov      rcx, qword ptr [rbp + 0x3c0]
0000000140a6b7f1: xor      rcx, rsp
0000000140a6b7f4: call     0x141441dc0
0000000140a6b7f9: lea      r11, [rsp + 0x540]
0000000140a6b801: mov      rbx, qword ptr [r11 + 0x58]
0000000140a6b805: movaps   xmm6, xmmword ptr [r11 - 0x10]
0000000140a6b80a: movaps   xmm7, xmmword ptr [r11 - 0x20]
0000000140a6b80f: movaps   xmm8, xmmword ptr [r11 - 0x30]
0000000140a6b814: movaps   xmm9, xmmword ptr [r11 - 0x40]
0000000140a6b819: movaps   xmm10, xmmword ptr [r11 - 0x50]
0000000140a6b81e: movaps   xmm11, xmmword ptr [r11 - 0x60]
0000000140a6b823: movaps   xmm12, xmmword ptr [r11 - 0x70]
0000000140a6b828: mov      rsp, r11
0000000140a6b82b: pop      r15
0000000140a6b82d: pop      r14
0000000140a6b82f: pop      r13
0000000140a6b831: pop      r12
0000000140a6b833: pop      rdi
0000000140a6b834: pop      rsi
0000000140a6b835: pop      rbp
0000000140a6b836: ret      
