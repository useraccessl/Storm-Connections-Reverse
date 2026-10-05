000000014131d460: mov      qword ptr [rsp + 8], rbx
000000014131d465: mov      qword ptr [rsp + 0x10], rdi
000000014131d46a: push     rbp
000000014131d46b: lea      rbp, [rsp - 0x57]
000000014131d470: sub      rsp, 0xa0
000000014131d477: mov      rbx, rcx
000000014131d47a: xorps    xmm3, xmm3
000000014131d47d: lea      rcx, [rbp - 9]
000000014131d481: xorps    xmm2, xmm2
000000014131d484: xorps    xmm1, xmm1
000000014131d487: mov      rdi, rdx
000000014131d48a: call     0x1411ab440
000000014131d48f: xorps    xmm3, xmm3
000000014131d492: lea      rcx, [rbp - 0x19]
000000014131d496: xorps    xmm2, xmm2
000000014131d499: xorps    xmm1, xmm1
000000014131d49c: call     0x1411ab440
000000014131d4a1: mov      rax, qword ptr [rbx + 0x98]
000000014131d4a8: lea      rcx, [rbp + 0x27]
000000014131d4ac: movss    xmm3, dword ptr [rax + 0x54]
000000014131d4b1: movss    xmm2, dword ptr [rax + 0x50]
000000014131d4b6: movss    xmm1, dword ptr [rax + 0x4c]
000000014131d4bb: call     0x1411ab440
000000014131d4c0: mov      eax, dword ptr [rbp + 0x2f]
000000014131d4c3: movsd    xmm0, qword ptr [rbp + 0x27]
000000014131d4c8: mov      dword ptr [rbp - 1], eax
000000014131d4cb: mov      rax, qword ptr [rbx + 0x98]
000000014131d4d2: movsd    qword ptr [rbp - 9], xmm0
000000014131d4d7: test     byte ptr [rax + 6], 1
000000014131d4db: je       0x14131d561
000000014131d4e1: movss    xmm0, dword ptr [rax + 0x60]
000000014131d4e6: movaps   xmmword ptr [rsp + 0x90], xmm6
000000014131d4ee: movaps   xmmword ptr [rsp + 0x80], xmm8
000000014131d4f7: call     0x1412cd5f0
000000014131d4fc: mov      rax, qword ptr [rbx + 0x98]
000000014131d503: movaps   xmm8, xmm0
000000014131d507: andps    xmm8, xmmword ptr [rip + 0x483931]
000000014131d50f: movss    xmm0, dword ptr [rax + 0x5c]
000000014131d514: call     0x1412cd5f0
000000014131d519: mov      rax, qword ptr [rbx + 0x98]
000000014131d520: movaps   xmm6, xmm0
000000014131d523: andps    xmm6, xmmword ptr [rip + 0x483916]
000000014131d52a: movss    xmm0, dword ptr [rax + 0x58]
000000014131d52f: call     0x1412cd5f0
000000014131d534: andps    xmm0, xmmword ptr [rip + 0x483905]
000000014131d53b: lea      rcx, [rbp - 0x19]
000000014131d53f: movaps   xmm1, xmm0
000000014131d542: movaps   xmm3, xmm8
000000014131d546: movaps   xmm2, xmm6
000000014131d549: call     0x1411adb80
000000014131d54e: movaps   xmm8, xmmword ptr [rsp + 0x80]
000000014131d557: movaps   xmm6, xmmword ptr [rsp + 0x90]
000000014131d55f: jmp      0x14131d59d
000000014131d561: movss    xmm0, dword ptr [rip + 0x444077]
000000014131d569: call     0x1412cd5f0
000000014131d56e: andps    xmm0, xmmword ptr [rip + 0x4838cb]
000000014131d575: lea      rcx, [rbp - 0x19]
000000014131d579: mov      rax, qword ptr [rbx + 0x98]
000000014131d580: movaps   xmm3, xmm0
000000014131d583: movaps   xmm2, xmm0
000000014131d586: mulss    xmm0, dword ptr [rax + 0x58]
000000014131d58b: mulss    xmm3, dword ptr [rax + 0x60]
000000014131d590: mulss    xmm2, dword ptr [rax + 0x5c]
000000014131d595: movaps   xmm1, xmm0
000000014131d598: call     0x1411adb80
000000014131d59d: xorps    xmm3, xmm3
000000014131d5a0: lea      rcx, [rbp + 0x17]
000000014131d5a4: xorps    xmm2, xmm2
000000014131d5a7: xorps    xmm1, xmm1
000000014131d5aa: call     0x1411ab440
000000014131d5af: xorps    xmm3, xmm3
000000014131d5b2: lea      rcx, [rbp + 7]
000000014131d5b6: xorps    xmm2, xmm2
000000014131d5b9: xorps    xmm1, xmm1
000000014131d5bc: call     0x1411ab440
000000014131d5c1: mov      rax, qword ptr [rbx + 0x98]
000000014131d5c8: lea      rcx, [rbp + 0x27]
000000014131d5cc: movss    xmm3, dword ptr [rbp - 0x11]
000000014131d5d1: movss    xmm2, dword ptr [rbp - 0x15]
000000014131d5d6: movss    xmm1, dword ptr [rbp - 0x19]
000000014131d5db: mulss    xmm3, dword ptr [rax + 0x54]
000000014131d5e0: mulss    xmm2, dword ptr [rax + 0x50]
000000014131d5e5: mulss    xmm1, dword ptr [rax + 0x4c]
000000014131d5ea: call     0x1411ab440
000000014131d5ef: lea      rdx, [rbp + 0x27]
000000014131d5f3: lea      rcx, [rbp - 9]
000000014131d5f7: call     0x1411ab760
000000014131d5fc: mov      rax, qword ptr [rbx + 0x98]
000000014131d603: lea      rcx, [rbp + 0x27]
000000014131d607: movss    xmm3, dword ptr [rax + 0x6c]
000000014131d60c: movss    xmm2, dword ptr [rax + 0x68]
000000014131d611: movss    xmm1, dword ptr [rax + 0x64]
000000014131d616: call     0x1411ab440
000000014131d61b: mov      eax, dword ptr [rbp + 0x2f]
000000014131d61e: lea      rcx, [rbp + 0x27]
000000014131d622: movsd    xmm0, qword ptr [rbp + 0x27]
000000014131d627: movss    xmm3, dword ptr [rbp - 0x11]
000000014131d62c: movss    xmm2, dword ptr [rbp - 0x15]
000000014131d631: movss    xmm1, dword ptr [rbp - 0x19]
000000014131d636: mov      dword ptr [rbp + 0x1f], eax
000000014131d639: mov      rax, qword ptr [rbx + 0x98]
000000014131d640: movsd    qword ptr [rbp + 0x17], xmm0
000000014131d645: mulss    xmm3, dword ptr [rax + 0x6c]
000000014131d64a: mulss    xmm2, dword ptr [rax + 0x68]
000000014131d64f: mulss    xmm1, dword ptr [rax + 0x64]
000000014131d654: call     0x1411ab440
000000014131d659: lea      rdx, [rbp + 0x27]
000000014131d65d: lea      rcx, [rbp + 0x17]
000000014131d661: call     0x1411ab760
000000014131d666: mov      rax, qword ptr [rbx + 0x98]
000000014131d66d: lea      rcx, [rbp + 0x27]
000000014131d671: movss    xmm3, dword ptr [rax + 0x78]
000000014131d676: movss    xmm2, dword ptr [rax + 0x74]
000000014131d67b: movss    xmm1, dword ptr [rax + 0x70]
000000014131d680: call     0x1411ab440
000000014131d685: mov      eax, dword ptr [rbp + 0x2f]
000000014131d688: lea      rcx, [rbp + 0x27]
000000014131d68c: movsd    xmm0, qword ptr [rbp + 0x27]
000000014131d691: movss    xmm3, dword ptr [rbp - 0x11]
000000014131d696: movss    xmm2, dword ptr [rbp - 0x15]
000000014131d69b: movss    xmm1, dword ptr [rbp - 0x19]
000000014131d6a0: mov      dword ptr [rbp + 0xf], eax
000000014131d6a3: mov      rax, qword ptr [rbx + 0x98]
000000014131d6aa: movsd    qword ptr [rbp + 7], xmm0
000000014131d6af: mulss    xmm3, dword ptr [rax + 0x78]
000000014131d6b4: mulss    xmm2, dword ptr [rax + 0x74]
000000014131d6b9: mulss    xmm1, dword ptr [rax + 0x70]
000000014131d6be: call     0x1411ab440
000000014131d6c3: lea      rdx, [rbp + 0x27]
000000014131d6c7: lea      rcx, [rbp + 7]
000000014131d6cb: call     0x1411ab760
000000014131d6d0: mov      rax, qword ptr [rbx + 0x98]
000000014131d6d7: lea      r9, [rbp + 7]
000000014131d6db: lea      r8, [rbp + 0x17]
000000014131d6df: mov      rcx, rdi
000000014131d6e2: lea      rdx, [rbp - 9]
000000014131d6e6: movss    xmm0, dword ptr [rax + 0x7c]
000000014131d6eb: movss    dword ptr [rsp + 0x20], xmm0
000000014131d6f1: call     0x14130c470
000000014131d6f6: mov      rax, qword ptr [rbx + 0x98]
000000014131d6fd: mov      rcx, rdi
000000014131d700: movss    xmm0, dword ptr [rax + 0xb0]
000000014131d708: lea      r9, [rax + 0xa0]
000000014131d70f: movss    dword ptr [rsp + 0x20], xmm0
000000014131d715: lea      r8, [rax + 0x90]
000000014131d71c: lea      rdx, [rax + 0x80]
000000014131d723: call     0x14130c260
000000014131d728: lea      rdx, [rbp - 9]
000000014131d72c: mov      rcx, rdi
000000014131d72f: call     0x14130c450
000000014131d734: lea      r11, [rsp + 0xa0]
000000014131d73c: mov      rbx, qword ptr [r11 + 0x10]
000000014131d740: mov      rdi, qword ptr [r11 + 0x18]
000000014131d744: mov      rsp, r11
000000014131d747: pop      rbp
000000014131d748: ret      
