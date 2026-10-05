000000014131c560: mov      rax, rsp
000000014131c563: mov      qword ptr [rax + 0x20], rbx
000000014131c567: push     rbp
000000014131c568: push     rsi
000000014131c569: push     rdi
000000014131c56a: push     r14
000000014131c56c: push     r15
000000014131c56e: lea      rbp, [rax - 0x128]
000000014131c575: sub      rsp, 0x200
000000014131c57c: movaps   xmmword ptr [rax - 0x38], xmm6
000000014131c580: movaps   xmmword ptr [rax - 0x48], xmm7
000000014131c584: movaps   xmmword ptr [rax - 0x58], xmm8
000000014131c589: movaps   xmmword ptr [rax - 0x68], xmm9
000000014131c58e: movaps   xmmword ptr [rax - 0x78], xmm10
000000014131c593: movaps   xmmword ptr [rax - 0x88], xmm11
000000014131c59b: movaps   xmmword ptr [rax - 0x98], xmm12
000000014131c5a3: movaps   xmmword ptr [rax - 0xa8], xmm13
000000014131c5ab: movaps   xmmword ptr [rax - 0xb8], xmm14
000000014131c5b3: mov      rax, qword ptr [rip + 0xdc9e0e]
000000014131c5ba: xor      rax, rsp
000000014131c5bd: mov      qword ptr [rbp + 0x60], rax
000000014131c5c1: movaps   xmm14, xmm3
000000014131c5c5: movaps   xmm12, xmm2
000000014131c5c9: mov      rsi, rdx
000000014131c5cc: mov      rdi, rcx
000000014131c5cf: lea      rcx, [rbp - 0x30]
000000014131c5d3: call     0x14131b3b0
000000014131c5d8: lea      rax, [rip + 0x87f179]
000000014131c5df: mov      qword ptr [rbp - 0x30], rax
000000014131c5e3: mov      dword ptr [rbp + 8], 1
000000014131c5ea: mov      qword ptr [rbp + 0x18], 0
000000014131c5f2: mov      rcx, qword ptr [rdi + 0x180]
000000014131c5f9: xor      r14d, r14d
000000014131c5fc: mov      rax, qword ptr [rcx]
000000014131c5ff: lea      rdx, [rbp - 0x30]
000000014131c603: call     qword ptr [rax + 0x18]
000000014131c606: mov      ebx, dword ptr [rbp + 0x150]
000000014131c60c: cmp      ebx, 1
000000014131c60f: jle      0x14131c649
000000014131c611: call     0x1412cd5c0
000000014131c616: xor      edx, edx
000000014131c618: div      ebx
000000014131c61a: mov      r14d, edx
000000014131c61d: mov      rcx, qword ptr [rdi + 0x180]
000000014131c624: test     edx, edx
000000014131c626: jle      0x14131c63f
000000014131c628: mov      eax, r14d
000000014131c62b: nop      dword ptr [rax + rax]
000000014131c630: test     rcx, rcx
000000014131c633: je       0x14131c639
000000014131c635: mov      rcx, qword ptr [rcx + 0x30]
000000014131c639: sub      rax, 1
000000014131c63d: jne      0x14131c630
000000014131c63f: mov      rax, qword ptr [rcx]
000000014131c642: lea      rdx, [rbp - 0x30]
000000014131c646: call     qword ptr [rax + 0x18]
000000014131c649: mov      rbx, qword ptr [rbp + 0x18]
000000014131c64d: mov      rax, qword ptr [rbx + 0x88]
000000014131c654: movss    xmm3, dword ptr [rax + 8]
000000014131c659: movss    xmm2, dword ptr [rax + 4]
000000014131c65e: movss    xmm1, dword ptr [rax]
000000014131c662: lea      rcx, [rsp + 0x60]
000000014131c667: call     0x1411ab440
000000014131c66c: lea      rcx, [rsp + 0x60]
000000014131c671: call     0x1411ac880
000000014131c676: movss    xmm10, dword ptr [rip + 0x543ec9]
000000014131c67f: movss    xmm7, dword ptr [rip + 0x444f59]
000000014131c687: xorps    xmm8, xmm8
000000014131c68b: comiss   xmm10, xmm0
000000014131c68f: jbe      0x14131c6a4
000000014131c691: movaps   xmm3, xmm7
000000014131c694: xorps    xmm2, xmm2
000000014131c697: xorps    xmm1, xmm1
000000014131c69a: lea      rcx, [rsp + 0x60]
000000014131c69f: call     0x1411adb80
000000014131c6a4: xorps    xmm3, xmm3
000000014131c6a7: xorps    xmm2, xmm2
000000014131c6aa: xorps    xmm1, xmm1
000000014131c6ad: lea      rcx, [rsp + 0x70]
000000014131c6b2: call     0x1411ab440
000000014131c6b7: movaps   xmm9, xmm7
000000014131c6bb: mov      rcx, qword ptr [rbx]
000000014131c6be: test     rcx, rcx
000000014131c6c1: je       0x14131c84b
000000014131c6c7: mov      rax, qword ptr [rcx]
000000014131c6ca: call     qword ptr [rax + 0x28]
000000014131c6cd: mov      rcx, qword ptr [rbx]
000000014131c6d0: movzx    eax, byte ptr [rcx + 0x120]
000000014131c6d7: shl      rax, 6
000000014131c6db: lea      rdx, [rcx + 0x7c]
000000014131c6df: add      rdx, rax
000000014131c6e2: lea      rcx, [rbp + 0x20]
000000014131c6e6: call     0x14127e3b0
000000014131c6eb: xorps    xmm3, xmm3
000000014131c6ee: xorps    xmm2, xmm2
000000014131c6f1: xorps    xmm1, xmm1
000000014131c6f4: lea      rcx, [rsp + 0x30]
000000014131c6f9: call     0x1411ab440
000000014131c6fe: mov      rax, qword ptr [rbx + 0x88]
000000014131c705: lea      rdx, [rsp + 0x50]
000000014131c70a: lea      rcx, [rbp + 0x20]
000000014131c70e: cmp      dword ptr [rax + 0x10], 0
000000014131c712: jne      0x14131c7e3
000000014131c718: call     0x141283ee0
000000014131c71d: movsd    xmm0, qword ptr [rax]
000000014131c721: movsd    qword ptr [rsp + 0x30], xmm0
000000014131c727: mov      eax, dword ptr [rax + 8]
000000014131c72a: mov      dword ptr [rsp + 0x38], eax
000000014131c72e: cmp      dword ptr [rdi + 0x88], 0
000000014131c735: jne      0x14131c7a3
000000014131c737: lea      rdx, [rsp + 0x50]
000000014131c73c: lea      rcx, [rbp + 0x20]
000000014131c740: call     0x1412840b0
000000014131c745: lea      rdx, [rbp - 0x50]
000000014131c749: lea      rcx, [rbp + 0x20]
000000014131c74d: call     0x141284120
000000014131c752: lea      rdx, [rbp - 0x60]
000000014131c756: lea      rcx, [rbp + 0x20]
000000014131c75a: call     0x1412840b0
000000014131c75f: lea      rcx, [rsp + 0x50]
000000014131c764: call     0x1411ac880
000000014131c769: movaps   xmm6, xmm0
000000014131c76c: lea      rcx, [rbp - 0x50]
000000014131c770: call     0x1411ac880
000000014131c775: movaps   xmm9, xmm0
000000014131c779: lea      rcx, [rbp - 0x60]
000000014131c77d: call     0x1411ac880
000000014131c782: movss    xmm1, dword ptr [rip + 0x55ce92]
000000014131c78a: comiss   xmm6, xmm1
000000014131c78d: jb       0x14131c7a3
000000014131c78f: comiss   xmm9, xmm1
000000014131c793: jb       0x14131c7a3
000000014131c795: comiss   xmm0, xmm1
000000014131c798: jb       0x14131c7a3
000000014131c79a: lea      rcx, [rbp + 0x20]
000000014131c79e: call     0x141281520
000000014131c7a3: lea      r8, [rsp + 0x60]
000000014131c7a8: lea      rdx, [rsp + 0x50]
000000014131c7ad: lea      rcx, [rbp + 0x20]
000000014131c7b1: call     0x141283c40
000000014131c7b6: movsd    xmm0, qword ptr [rax]
000000014131c7ba: movsd    qword ptr [rsp + 0x60], xmm0
000000014131c7c0: mov      eax, dword ptr [rax + 8]
000000014131c7c3: mov      dword ptr [rsp + 0x68], eax
000000014131c7c7: lea      rcx, [rsp + 0x60]
000000014131c7cc: call     0x1411ac880
000000014131c7d1: comiss   xmm0, xmm8
000000014131c7d5: jbe      0x14131c7f9
000000014131c7d7: lea      rcx, [rsp + 0x60]
000000014131c7dc: call     0x1411acbb0
000000014131c7e1: jmp      0x14131c7f9
000000014131c7e3: call     0x141283ee0
000000014131c7e8: movsd    xmm0, qword ptr [rax]
000000014131c7ec: movsd    qword ptr [rsp + 0x30], xmm0
000000014131c7f2: mov      eax, dword ptr [rax + 8]
000000014131c7f5: mov      dword ptr [rsp + 0x38], eax
000000014131c7f9: xorps    xmm3, xmm3
000000014131c7fc: xorps    xmm2, xmm2
000000014131c7ff: movaps   xmm1, xmm7
000000014131c802: lea      rcx, [rbp - 0x80]
000000014131c806: call     0x1411ab440
000000014131c80b: lea      r8, [rbp - 0x80]
000000014131c80f: lea      rdx, [rsp + 0x50]
000000014131c814: lea      rcx, [rbp + 0x20]
000000014131c818: call     0x141283c40
000000014131c81d: movsd    xmm0, qword ptr [rax]
000000014131c821: movsd    qword ptr [rbp - 0x80], xmm0
000000014131c826: mov      eax, dword ptr [rax + 8]
000000014131c829: mov      dword ptr [rbp - 0x78], eax
000000014131c82c: lea      rcx, [rbp - 0x80]
000000014131c830: call     0x1411ac850
000000014131c835: movaps   xmm9, xmm0
000000014131c839: movsd    xmm1, qword ptr [rsp + 0x30]
000000014131c83f: movsd    qword ptr [rsp + 0x70], xmm1
000000014131c845: mov      eax, dword ptr [rsp + 0x38]
000000014131c849: jmp      0x14131c860
000000014131c84b: mov      rcx, rbx
000000014131c84e: call     0x141387bc0
000000014131c853: movsd    xmm0, qword ptr [rax]
000000014131c857: movsd    qword ptr [rsp + 0x70], xmm0
000000014131c85d: mov      eax, dword ptr [rax + 8]
000000014131c860: mov      dword ptr [rsp + 0x78], eax
000000014131c864: movss    xmm1, dword ptr [rip + 0x880420]
000000014131c86c: movaps   xmm0, xmm1
000000014131c86f: xorps    xmm0, xmmword ptr [rip + 0x44492a]
000000014131c876: call     0x1412cd630
000000014131c87b: movaps   xmm11, xmm0
000000014131c87f: movss    xmm1, dword ptr [rip + 0x880405]
000000014131c887: movaps   xmm0, xmm1
000000014131c88a: xorps    xmm0, xmmword ptr [rip + 0x44490f]
000000014131c891: call     0x1412cd630
000000014131c896: movaps   xmm13, xmm0
000000014131c89a: mov      rax, qword ptr [rdi + 0x98]
000000014131c8a1: movss    xmm0, dword ptr [rax + 0x18]
000000014131c8a6: call     0x1412cd5f0
000000014131c8ab: movaps   xmm6, xmm7
000000014131c8ae: subss    xmm6, xmm0
000000014131c8b2: mulss    xmm6, xmm12
000000014131c8b7: xorps    xmm3, xmm3
000000014131c8ba: xorps    xmm2, xmm2
000000014131c8bd: xorps    xmm1, xmm1
000000014131c8c0: lea      rcx, [rsp + 0x40]
000000014131c8c5: call     0x1411ab440
000000014131c8ca: xorps    xmm3, xmm3
000000014131c8cd: xorps    xmm2, xmm2
000000014131c8d0: movaps   xmm1, xmm7
000000014131c8d3: lea      rcx, [rsp + 0x30]
000000014131c8d8: call     0x1411ab440
000000014131c8dd: mulss    xmm12, xmm9
000000014131c8e2: mulss    xmm6, xmm9
000000014131c8e7: movaps   xmm1, xmm12
000000014131c8eb: movaps   xmm0, xmm6
000000014131c8ee: call     0x1412cd630
000000014131c8f3: movaps   xmm6, xmm0
000000014131c8f6: ucomiss  xmm14, xmm8
000000014131c8fa: jp       0x14131c90d
000000014131c8fc: jne      0x14131c90d
000000014131c8fe: movaps   xmm1, xmm11
000000014131c902: lea      rcx, [rbp + 0x20]
000000014131c906: call     0x1412818f0
000000014131c90b: jmp      0x14131c921
000000014131c90d: movaps   xmm3, xmm13
000000014131c911: movaps   xmm2, xmm11
000000014131c915: xorps    xmm1, xmm1
000000014131c918: lea      rcx, [rbp + 0x20]
000000014131c91c: call     0x14127fd60
000000014131c921: lea      r8, [rsp + 0x30]
000000014131c926: lea      rdx, [rsp + 0x50]
000000014131c92b: lea      rcx, [rbp + 0x20]
000000014131c92f: call     0x141283c40
000000014131c934: movsd    xmm0, qword ptr [rax]
000000014131c938: movsd    qword ptr [rsp + 0x30], xmm0
000000014131c93e: mov      eax, dword ptr [rax + 8]
000000014131c941: mov      dword ptr [rsp + 0x38], eax
000000014131c945: movss    xmm3, dword ptr [rsp + 0x38]
000000014131c94b: movss    xmm2, dword ptr [rsp + 0x34]
000000014131c951: movss    xmm1, dword ptr [rsp + 0x30]
000000014131c957: mulss    xmm3, xmm6
000000014131c95b: mulss    xmm2, xmm6
000000014131c95f: mulss    xmm1, xmm6
000000014131c963: movss    dword ptr [rsp + 0x48], xmm3
000000014131c969: movss    dword ptr [rsp + 0x44], xmm2
000000014131c96f: movss    dword ptr [rsp + 0x40], xmm1
000000014131c975: mov      rcx, qword ptr [rbx]
000000014131c978: test     rcx, rcx
000000014131c97b: je       0x14131c9d7
000000014131c97d: mov      rax, qword ptr [rbx + 0x88]
000000014131c984: cmp      dword ptr [rax + 0x10], 0
000000014131c988: jne      0x14131c9d7
000000014131c98a: mov      rax, qword ptr [rcx]
000000014131c98d: call     qword ptr [rax + 0x28]
000000014131c990: mov      rcx, qword ptr [rbx]
000000014131c993: movzx    eax, byte ptr [rcx + 0x120]
000000014131c99a: shl      rax, 6
000000014131c99e: add      rcx, 0x7c
000000014131c9a2: add      rcx, rax
000000014131c9a5: lea      r8, [rsp + 0x40]
000000014131c9aa: lea      rdx, [rsp + 0x50]
000000014131c9af: call     0x141283c40
000000014131c9b4: movsd    xmm0, qword ptr [rax]
000000014131c9b8: movsd    qword ptr [rsp + 0x40], xmm0
000000014131c9be: mov      eax, dword ptr [rax + 8]
000000014131c9c1: mov      dword ptr [rsp + 0x48], eax
000000014131c9c5: movss    xmm3, dword ptr [rsp + 0x48]
000000014131c9cb: movss    xmm2, dword ptr [rsp + 0x44]
000000014131c9d1: movss    xmm1, dword ptr [rsp + 0x40]
000000014131c9d7: movss    xmm0, dword ptr [rsp + 0x70]
000000014131c9dd: addss    xmm0, xmm1
000000014131c9e1: movss    dword ptr [rbp - 0x70], xmm0
000000014131c9e6: movss    xmm1, dword ptr [rsp + 0x74]
000000014131c9ec: addss    xmm1, xmm2
000000014131c9f0: movss    dword ptr [rbp - 0x6c], xmm1
000000014131c9f5: movss    xmm0, dword ptr [rsp + 0x78]
000000014131c9fb: addss    xmm0, xmm3
000000014131c9ff: movss    dword ptr [rbp - 0x68], xmm0
000000014131ca04: mov      rax, qword ptr [rdi + 0x98]
000000014131ca0b: test     byte ptr [rax + 6], 0x10
000000014131ca0f: je       0x14131cb28
000000014131ca15: lea      rcx, [rbx + 0x68]
000000014131ca19: call     0x1411ac880
000000014131ca1e: comiss   xmm0, xmm10
000000014131ca22: jbe      0x14131cb28
000000014131ca28: lea      rcx, [rbx + 0x74]
000000014131ca2c: call     0x1411ac880
000000014131ca31: comiss   xmm0, xmm10
000000014131ca35: jbe      0x14131cb28
000000014131ca3b: movaps   xmm0, xmm7
000000014131ca3e: call     0x1412cd5f0
000000014131ca43: movaps   xmm7, xmm0
000000014131ca46: movsd    xmm1, qword ptr [rbx + 0x68]
000000014131ca4b: movsd    qword ptr [rbp - 0x80], xmm1
000000014131ca50: mov      eax, dword ptr [rbx + 0x70]
000000014131ca53: mov      dword ptr [rbp - 0x78], eax
000000014131ca56: movsd    xmm1, qword ptr [rbx + 0x74]
000000014131ca5b: movsd    qword ptr [rbp - 0x60], xmm1
000000014131ca60: mov      eax, dword ptr [rbx + 0x7c]
000000014131ca63: mov      dword ptr [rbp - 0x58], eax
000000014131ca66: lea      rdx, [rbp - 0x40]
000000014131ca6a: lea      rcx, [rbp - 0x80]
000000014131ca6e: call     0x1411acc30
000000014131ca73: movsd    xmm0, qword ptr [rax]
000000014131ca77: movsd    qword ptr [rsp + 0x50], xmm0
000000014131ca7d: mov      eax, dword ptr [rax + 8]
000000014131ca80: mov      dword ptr [rsp + 0x58], eax
000000014131ca84: lea      rdx, [rbp - 0x40]
000000014131ca88: lea      rcx, [rbp - 0x60]
000000014131ca8c: call     0x1411acc30
000000014131ca91: movsd    xmm0, qword ptr [rax]
000000014131ca95: movsd    qword ptr [rbp - 0x50], xmm0
000000014131ca9a: mov      eax, dword ptr [rax + 8]
000000014131ca9d: mov      dword ptr [rbp - 0x48], eax
000000014131caa0: movaps   xmm3, xmm7
000000014131caa3: mulss    xmm3, dword ptr [rip + 0x44d99d]
000000014131caab: addss    xmm3, dword ptr [rip + 0x44d995]
000000014131cab3: lea      r8, [rbp - 0x50]
000000014131cab7: lea      rdx, [rbp - 0x40]
000000014131cabb: lea      rcx, [rsp + 0x50]
000000014131cac0: call     0x1411ac8b0
000000014131cac5: movsd    xmm0, qword ptr [rax]
000000014131cac9: movsd    qword ptr [rsp + 0x30], xmm0
000000014131cacf: mov      eax, dword ptr [rax + 8]
000000014131cad2: mov      dword ptr [rsp + 0x38], eax
000000014131cad6: lea      rcx, [rbp - 0x80]
000000014131cada: call     0x1411ac850
000000014131cadf: movaps   xmm6, xmm0
000000014131cae2: lea      rcx, [rsp + 0x30]
000000014131cae7: call     0x1411acbb0
000000014131caec: mulss    xmm6, xmm7
000000014131caf0: movaps   xmm1, xmm6
000000014131caf3: lea      rcx, [rsp + 0x30]
000000014131caf8: call     0x1411ab730
000000014131cafd: lea      rdx, [rbp - 0x80]
000000014131cb01: lea      rcx, [rsp + 0x30]
000000014131cb06: call     0x1411ab790
000000014131cb0b: lea      rdx, [rsp + 0x30]
000000014131cb10: lea      rcx, [rbp - 0x70]
000000014131cb14: call     0x1411ab760
000000014131cb19: lea      rdx, [rsp + 0x30]
000000014131cb1e: lea      rcx, [rsp + 0x70]
000000014131cb23: call     0x1411ab760
000000014131cb28: lea      rdx, [rbp - 0x70]
000000014131cb2c: mov      rcx, rsi
000000014131cb2f: call     0x14130c410
000000014131cb34: mov      dword ptr [rsi + 0x190], r14d
000000014131cb3b: movss    dword ptr [rsi + 0x108], xmm9
000000014131cb44: mov      rax, qword ptr [rdi + 0x98]
000000014131cb4b: cmp      byte ptr [rax + 2], 3
000000014131cb4f: je       0x14131cb5c
000000014131cb51: mov      qword ptr [rsp + 0x20], 0
000000014131cb5a: jmp      0x14131cb80
000000014131cb5c: lea      rcx, [rsp + 0x60]
000000014131cb61: call     0x1411ac880
000000014131cb66: comiss   xmm0, xmm8
000000014131cb6a: jbe      0x14131cb76
000000014131cb6c: lea      rcx, [rsp + 0x60]
000000014131cb71: call     0x1411acbb0
000000014131cb76: lea      rax, [rsp + 0x60]
000000014131cb7b: mov      qword ptr [rsp + 0x20], rax
000000014131cb80: lea      r9, [rsp + 0x70]
000000014131cb85: lea      r8, [rbp - 0x70]
000000014131cb89: mov      rdx, rsi
000000014131cb8c: mov      rcx, rdi
000000014131cb8f: call     0x14131d750
000000014131cb94: nop      
000000014131cb95: mov      rcx, qword ptr [rbp + 0x60]
000000014131cb99: xor      rcx, rsp
000000014131cb9c: call     0x141441dc0
000000014131cba1: lea      r11, [rsp + 0x200]
000000014131cba9: mov      rbx, qword ptr [r11 + 0x48]
000000014131cbad: movaps   xmm6, xmmword ptr [r11 - 0x10]
000000014131cbb2: movaps   xmm7, xmmword ptr [r11 - 0x20]
000000014131cbb7: movaps   xmm8, xmmword ptr [r11 - 0x30]
000000014131cbbc: movaps   xmm9, xmmword ptr [r11 - 0x40]
000000014131cbc1: movaps   xmm10, xmmword ptr [r11 - 0x50]
000000014131cbc6: movaps   xmm11, xmmword ptr [r11 - 0x60]
000000014131cbcb: movaps   xmm12, xmmword ptr [r11 - 0x70]
000000014131cbd0: movaps   xmm13, xmmword ptr [r11 - 0x80]
000000014131cbd5: movaps   xmm14, xmmword ptr [r11 - 0x90]
000000014131cbdd: mov      rsp, r11
000000014131cbe0: pop      r15
000000014131cbe2: pop      r14
000000014131cbe4: pop      rdi
000000014131cbe5: pop      rsi
000000014131cbe6: pop      rbp
000000014131cbe7: ret      
