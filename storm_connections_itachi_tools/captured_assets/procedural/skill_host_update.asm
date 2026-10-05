00000001405e5240: push     rbp
00000001405e5242: push     rsi
00000001405e5243: push     r13
00000001405e5245: lea      rbp, [rsp - 0x190]
00000001405e524d: sub      rsp, 0x290
00000001405e5254: mov      rax, qword ptr [rip + 0x1b0116d]
00000001405e525b: xor      rax, rsp
00000001405e525e: mov      qword ptr [rbp + 0x150], rax
00000001405e5265: mov      edx, dword ptr [rcx + 0x10c]
00000001405e526b: mov      rsi, rcx
00000001405e526e: mov      qword ptr [rbp - 0x50], rcx
00000001405e5272: mov      rcx, qword ptr [rip + 0x1bf221f]
00000001405e5279: call     0x140a63f90
00000001405e527e: mov      qword ptr [rbp - 0x68], rax
00000001405e5282: mov      r13, rax
00000001405e5285: test     rax, rax
00000001405e5288: jne      0x1405e52a5
00000001405e528a: lea      rcx, [rip + 0x11f5897]
00000001405e5291: call     0x14127bf80
00000001405e5296: mov      dword ptr [rsi + 0x3a8], 1
00000001405e52a0: jmp      0x1405e669e
00000001405e52a5: cmp      dword ptr [rsi + 0x3b8], 0
00000001405e52ac: jne      0x1405e669e
00000001405e52b2: cmp      dword ptr [rsi + 0x1dc], 0
00000001405e52b9: je       0x1405e52c8
00000001405e52bb: call     0x140985560
00000001405e52c0: test     eax, eax
00000001405e52c2: jne      0x1405e669e
00000001405e52c8: mov      ecx, 5
00000001405e52cd: call     0x140985590
00000001405e52d2: test     eax, eax
00000001405e52d4: je       0x1405e52e3
00000001405e52d6: cmp      dword ptr [rsi + 0x1e0], 0
00000001405e52dd: je       0x1405e669e
00000001405e52e3: cmp      dword ptr [rsi + 0x5c4], 0
00000001405e52ea: je       0x1405e531e
00000001405e52ec: mov      ecx, dword ptr [rsi + 0x108]
00000001405e52f2: call     0x140ad8880
00000001405e52f7: test     rax, rax
00000001405e52fa: je       0x1405e531e
00000001405e52fc: mov      eax, dword ptr [rax + 0xe64]
00000001405e5302: cmp      eax, 0x52
00000001405e5305: je       0x1405e530c
00000001405e5307: cmp      eax, 0x5f
00000001405e530a: jne      0x1405e531e
00000001405e530c: mov      ecx, 8
00000001405e5311: call     0x140985590
00000001405e5316: test     eax, eax
00000001405e5318: jne      0x1405e669e
00000001405e531e: mov      rcx, qword ptr [rip + 0x1d509b3]
00000001405e5325: mov      qword ptr [rsp + 0x2b8], rbx
00000001405e532d: mov      qword ptr [rsp + 0x2c0], rdi
00000001405e5335: mov      qword ptr [rsp + 0x2c8], r12
00000001405e533d: mov      qword ptr [rsp + 0x288], r14
00000001405e5345: mov      qword ptr [rsp + 0x280], r15
00000001405e534d: movaps   xmmword ptr [rsp + 0x270], xmm6
00000001405e5355: movaps   xmmword ptr [rsp + 0x260], xmm7
00000001405e535d: call     0x14109e1d0
00000001405e5362: movss    xmm7, dword ptr [rip + 0x117c276]
00000001405e536a: xor      r15d, r15d
00000001405e536d: cmp      eax, 0x89
00000001405e5372: xorps    xmm6, xmm6
00000001405e5375: sete     r15b
00000001405e5379: jne      0x1405e5741
00000001405e537f: mov      r14, qword ptr [rip + 0x1b8f1ea]
00000001405e5386: test     r14, r14
00000001405e5389: je       0x1405e5741
00000001405e538f: lea      rdx, [rip + 0x11f9b7a]
00000001405e5396: lea      rcx, [r13 + 8]
00000001405e539a: call     0x141443072
00000001405e539f: test     eax, eax
00000001405e53a1: je       0x1405e5741
00000001405e53a7: xor      ebx, ebx
00000001405e53a9: lea      rdx, [rsp + 0x30]
00000001405e53ae: cmp      dword ptr [r14 + 0x140], ebx
00000001405e53b5: mov      r9d, 5
00000001405e53bb: mov      rcx, r14
00000001405e53be: setne    bl
00000001405e53c1: mov      r8d, ebx
00000001405e53c4: call     0x14026f4f0
00000001405e53c9: xor      r9d, r9d
00000001405e53cc: lea      rdx, [rbp - 0x80]
00000001405e53d0: mov      r8d, ebx
00000001405e53d3: mov      rcx, r14
00000001405e53d6: call     0x14026f4f0
00000001405e53db: movsd    xmm0, qword ptr [rsi + 0x70]
00000001405e53e0: mov      eax, dword ptr [rsi + 0x78]
00000001405e53e3: mov      ecx, dword ptr [rsi + 0x108]
00000001405e53e9: movsd    qword ptr [rbp - 0x60], xmm0
00000001405e53ee: mov      dword ptr [rbp - 0x58], eax
00000001405e53f1: call     0x140ad8880
00000001405e53f6: mov      rbx, rax
00000001405e53f9: test     rax, rax
00000001405e53fc: je       0x1405e54c7
00000001405e5402: cmp      qword ptr [rsi + 0x100], 0
00000001405e540a: jne      0x1405e54c7
00000001405e5410: lea      rdx, [rip + 0x12a9459]
00000001405e5417: lea      rcx, [r13 + 8]
00000001405e541b: call     0x141443072
00000001405e5420: test     eax, eax
00000001405e5422: je       0x1405e54c7
00000001405e5428: lea      rdx, [rip + 0x12a9451]
00000001405e542f: lea      rcx, [r13 + 8]
00000001405e5433: call     0x141443072
00000001405e5438: test     eax, eax
00000001405e543a: je       0x1405e54c7
00000001405e5440: lea      rdx, [rip + 0x1234b19]
00000001405e5447: lea      rcx, [r13 + 8]
00000001405e544b: call     0x141443072
00000001405e5450: test     eax, eax
00000001405e5452: je       0x1405e54c7
00000001405e5454: lea      rdx, [rip + 0x12a943d]
00000001405e545b: lea      rcx, [r13 + 8]
00000001405e545f: call     0x141443072
00000001405e5464: test     eax, eax
00000001405e5466: je       0x1405e54c7
00000001405e5468: lea      rdx, [rip + 0x12a9449]
00000001405e546f: lea      rcx, [r13 + 8]
00000001405e5473: call     0x141443072
00000001405e5478: test     eax, eax
00000001405e547a: je       0x1405e54c7
00000001405e547c: lea      rdx, [rip + 0x12a9455]
00000001405e5483: lea      rcx, [r13 + 8]
00000001405e5487: call     0x141443072
00000001405e548c: test     eax, eax
00000001405e548e: je       0x1405e54c7
00000001405e5490: lea      rdx, [rip + 0x12a9461]
00000001405e5497: lea      rcx, [r13 + 8]
00000001405e549b: call     0x141443072
00000001405e54a0: test     eax, eax
00000001405e54a2: je       0x1405e54c7
00000001405e54a4: movsd    xmm0, qword ptr [rbx + 0x12ee4]
00000001405e54ac: lea      rdx, [rbp - 0x48]
00000001405e54b0: mov      eax, dword ptr [rbx + 0x12eec]
00000001405e54b6: lea      rcx, [rbp - 0x60]
00000001405e54ba: movsd    qword ptr [rbp - 0x48], xmm0
00000001405e54bf: mov      dword ptr [rbp - 0x40], eax
00000001405e54c2: call     0x1411ab760
00000001405e54c7: movss    xmm0, dword ptr [rbp - 0x60]
00000001405e54cc: lea      rcx, [rbp]
00000001405e54d0: subss    xmm0, dword ptr [rsp + 0x30]
00000001405e54d6: movss    xmm1, dword ptr [rbp - 0x5c]
00000001405e54db: subss    xmm1, dword ptr [rsp + 0x34]
00000001405e54e1: movss    dword ptr [rsp + 0x50], xmm0
00000001405e54e7: movss    xmm0, dword ptr [rbp - 0x58]
00000001405e54ec: subss    xmm0, dword ptr [rsp + 0x38]
00000001405e54f2: movss    dword ptr [rsp + 0x54], xmm1
00000001405e54f8: movss    dword ptr [rsp + 0x58], xmm0
00000001405e54fe: call     0x14127e6d0
00000001405e5503: lea      rcx, [rbp + 0x50]
00000001405e5507: call     0x14127e6d0
00000001405e550c: xorps    xmm3, xmm3
00000001405e550f: lea      rcx, [rsp + 0x20]
00000001405e5514: movaps   xmm2, xmm7
00000001405e5517: xorps    xmm1, xmm1
00000001405e551a: call     0x1411ab440
00000001405e551f: movss    xmm0, dword ptr [rbp - 0x80]
00000001405e5524: lea      rcx, [rsp + 0x20]
00000001405e5529: subss    xmm0, dword ptr [rsp + 0x30]
00000001405e552f: movss    xmm1, dword ptr [rbp - 0x7c]
00000001405e5534: subss    xmm1, dword ptr [rsp + 0x34]
00000001405e553a: movss    dword ptr [rsp + 0x20], xmm0
00000001405e5540: movss    xmm0, dword ptr [rbp - 0x78]
00000001405e5545: subss    xmm0, dword ptr [rsp + 0x38]
00000001405e554b: movss    dword ptr [rsp + 0x24], xmm1
00000001405e5551: movss    dword ptr [rsp + 0x28], xmm0
00000001405e5557: call     0x1411ac850
00000001405e555c: ucomiss  xmm0, xmm6
00000001405e555f: jp       0x1405e556d
00000001405e5561: jne      0x1405e556d
00000001405e5563: mov      dword ptr [rsp + 0x24], 0x3f800000
00000001405e556b: jmp      0x1405e558c
00000001405e556d: lea      rdx, [rbp - 0x48]
00000001405e5571: lea      rcx, [rsp + 0x20]
00000001405e5576: call     0x1411acc30
00000001405e557b: movsd    xmm0, qword ptr [rax]
00000001405e557f: movsd    qword ptr [rsp + 0x20], xmm0
00000001405e5585: mov      eax, dword ptr [rax + 8]
00000001405e5588: mov      dword ptr [rsp + 0x28], eax
00000001405e558c: xorps    xmm2, xmm2
00000001405e558f: lea      rdx, [rsp + 0x50]
00000001405e5594: lea      rcx, [rbp - 0x18]
00000001405e5598: call     0x1412a7d80
00000001405e559d: xorps    xmm2, xmm2
00000001405e55a0: lea      rdx, [rsp + 0x20]
00000001405e55a5: lea      rcx, [rbp + 0x40]
00000001405e55a9: call     0x1412a7d80
00000001405e55ae: lea      rcx, [rbp + 0xd0]
00000001405e55b5: call     0x14127e6d0
00000001405e55ba: lea      rcx, [rbp + 0x90]
00000001405e55c1: call     0x14127e6d0
00000001405e55c6: lea      rdx, [rsp + 0x20]
00000001405e55cb: lea      rcx, [rbp + 0x90]
00000001405e55d2: call     0x141095a80
00000001405e55d7: lea      r8, [rbp + 0x90]
00000001405e55de: lea      rdx, [rbp + 0x110]
00000001405e55e5: lea      rcx, [rbp + 0xd0]
00000001405e55ec: call     0x141280a10
00000001405e55f1: mov      rdx, rax
00000001405e55f4: lea      rcx, [rbp]
00000001405e55f8: call     0x14127e710
00000001405e55fd: lea      rdx, [rbp + 0x110]
00000001405e5604: lea      rcx, [rbp]
00000001405e5608: call     0x141280750
00000001405e560d: mov      rdx, rax
00000001405e5610: lea      rcx, [rbp + 0x50]
00000001405e5614: call     0x14127e710
00000001405e5619: xorps    xmm2, xmm2
00000001405e561c: lea      rdx, [rsi + 0x4b4]
00000001405e5623: lea      rcx, [rbp - 0x28]
00000001405e5627: call     0x1412a7d80
00000001405e562c: cmp      qword ptr [rsi + 0x100], 0
00000001405e5634: jne      0x1405e566a
00000001405e5636: lea      r8, [rbp - 0x18]
00000001405e563a: lea      rdx, [rbp - 0x48]
00000001405e563e: lea      rcx, [rbp + 0x50]
00000001405e5642: call     0x141283bb0
00000001405e5647: lea      rcx, [rsi + 0x4b4]
00000001405e564e: movups   xmm1, xmmword ptr [rax]
00000001405e5651: movaps   xmm3, xmm1
00000001405e5654: movaps   xmm2, xmm1
00000001405e5657: shufps   xmm3, xmm1, 0xaa
00000001405e565b: shufps   xmm2, xmm1, 0x55
00000001405e565f: movups   xmmword ptr [rbp - 0x28], xmm1
00000001405e5663: call     0x1411adb80
00000001405e5668: jmp      0x1405e56e0
00000001405e566a: lea      rdx, [rsp + 0x20]
00000001405e566f: lea      rcx, [rsi + 0x4c0]
00000001405e5676: call     0x1411ac380
00000001405e567b: cvtss2sd xmm0, xmm0
00000001405e567f: call     0x141443096
00000001405e5684: xorps    xmm1, xmm1
00000001405e5687: movaps   xmm2, xmm0
00000001405e568a: comisd   xmm1, xmm0
00000001405e568e: jbe      0x1405e569a
00000001405e5690: movss    xmm0, dword ptr [rip + 0x1184ddc]
00000001405e5698: jmp      0x1405e56a2
00000001405e569a: movss    xmm0, dword ptr [rip + 0x1184da6]
00000001405e56a2: mulsd    xmm2, qword ptr [rip + 0x1184db6]
00000001405e56aa: lea      rcx, [rbp + 0x110]
00000001405e56b1: cvtps2pd xmm0, xmm0
00000001405e56b4: divsd    xmm2, qword ptr [rip + 0x1184d94]
00000001405e56bc: addsd    xmm2, xmm0
00000001405e56c0: cvttsd2si eax, xmm2
00000001405e56c4: movd     xmm1, eax
00000001405e56c8: cvtdq2ps xmm1, xmm1
00000001405e56cb: mulss    xmm1, dword ptr [rip + 0x11d38a1]
00000001405e56d3: mulss    xmm1, dword ptr [rip + 0x1184d65]
00000001405e56db: call     0x1412818f0
00000001405e56e0: movsd    xmm0, qword ptr [rsp + 0x20]
00000001405e56e6: lea      r8, [rbp - 0x28]
00000001405e56ea: mov      eax, dword ptr [rsp + 0x28]
00000001405e56ee: lea      rdx, [rbp - 0x38]
00000001405e56f2: movsd    qword ptr [rsi + 0x4c0], xmm0
00000001405e56fa: lea      rcx, [rbp]
00000001405e56fe: mov      dword ptr [rsi + 0x4c8], eax
00000001405e5704: call     0x141283bb0
00000001405e5709: movss    xmm3, dword ptr [rbp - 0x30]
00000001405e570e: lea      rcx, [rsp + 0x70]
00000001405e5713: movss    xmm2, dword ptr [rbp - 0x34]
00000001405e5718: movss    xmm1, dword ptr [rbp - 0x38]
00000001405e571d: addss    xmm3, dword ptr [rsp + 0x38]
00000001405e5723: addss    xmm2, dword ptr [rsp + 0x34]
00000001405e5729: addss    xmm1, dword ptr [rsp + 0x30]
00000001405e572f: call     0x1411ab440
00000001405e5734: lea      rdx, [rsp + 0x70]
00000001405e5739: mov      rcx, rsi
00000001405e573c: call     0x1410a9400
00000001405e5741: mov      rcx, qword ptr [rsi + 0x110]
00000001405e5748: test     rcx, rcx
00000001405e574b: je       0x1405e5855
00000001405e5751: cmp      qword ptr [rsi + 0x100], 0
00000001405e5759: jbe      0x1405e5855
00000001405e575f: mov      rax, qword ptr [rcx]
00000001405e5762: mov      rdx, qword ptr [rsi + 0x98]
00000001405e5769: call     qword ptr [rax + 0x10]
00000001405e576c: mov      ecx, dword ptr [rsi + 0x108]
00000001405e5772: call     0x140ad8880
00000001405e5777: mov      rbx, rax
00000001405e577a: test     rax, rax
00000001405e577d: je       0x1405e5799
00000001405e577f: cmp      dword ptr [rax + 0xe64], 0x15
00000001405e5786: jne      0x1405e5799
00000001405e5788: cmp      dword ptr [rsi + 0x5c4], 0
00000001405e578f: je       0x1405e5799
00000001405e5791: mov      rcx, rax
00000001405e5794: call     0x14084cf80
00000001405e5799: cmp      dword ptr [rsi + 0x238], 0
00000001405e57a0: je       0x1405e5855
00000001405e57a6: mov      rax, qword ptr [rbx]
00000001405e57a9: mov      rcx, rbx
00000001405e57ac: call     qword ptr [rax + 0xdc0]
00000001405e57b2: lea      rcx, [rsp + 0x20]
00000001405e57b7: movsd    xmm0, qword ptr [rax + 0x70]
00000001405e57bc: movsd    qword ptr [rsp + 0x20], xmm0
00000001405e57c2: mov      eax, dword ptr [rax + 0x78]
00000001405e57c5: movss    xmm2, dword ptr [rsp + 0x20]
00000001405e57cb: movss    xmm1, dword ptr [rsp + 0x24]
00000001405e57d1: subss    xmm2, dword ptr [rbx + 0x70]
00000001405e57d6: subss    xmm1, dword ptr [rbx + 0x74]
00000001405e57db: mov      dword ptr [rsp + 0x28], eax
00000001405e57df: movss    xmm0, dword ptr [rsp + 0x28]
00000001405e57e5: subss    xmm0, dword ptr [rbx + 0x78]
00000001405e57ea: movss    dword ptr [rsp + 0x20], xmm2
00000001405e57f0: movss    dword ptr [rsp + 0x24], xmm1
00000001405e57f6: movss    dword ptr [rsp + 0x28], xmm0
00000001405e57fc: call     0x1411acbb0
00000001405e5801: lea      rcx, [rsi + 0xa0]
00000001405e5808: call     0x1411ac850
00000001405e580d: movss    xmm3, dword ptr [rsp + 0x20]
00000001405e5813: movss    xmm2, dword ptr [rsp + 0x24]
00000001405e5819: movss    xmm1, dword ptr [rsp + 0x28]
00000001405e581f: mov      rcx, qword ptr [rsi + 0x98]
00000001405e5826: mulss    xmm1, xmm0
00000001405e582a: mulss    xmm3, xmm0
00000001405e582e: mulss    xmm2, xmm0
00000001405e5832: movaps   xmm0, xmm3
00000001405e5835: movss    dword ptr [rsp + 0x78], xmm1
00000001405e583b: mov      eax, dword ptr [rsp + 0x78]
00000001405e583f: unpcklps xmm0, xmm2
00000001405e5842: movsd    qword ptr [rsi + 0xa0], xmm0
00000001405e584a: mov      dword ptr [rsi + 0xa8], eax
00000001405e5850: call     0x140a61c20
00000001405e5855: test     r15d, r15d
00000001405e5858: je       0x1405e5a61
00000001405e585e: lea      rcx, [r13 + 8]
00000001405e5862: lea      rdx, [rip + 0x11f96a7]
00000001405e5869: call     0x141443072
00000001405e586e: test     eax, eax
00000001405e5870: je       0x1405e5a61
00000001405e5876: mov      rdi, qword ptr [rip + 0x1b8ecf3]
00000001405e587d: test     rdi, rdi
00000001405e5880: je       0x1405e5a61
00000001405e5886: xor      ebx, ebx
00000001405e5888: lea      rdx, [rsp + 0x30]
00000001405e588d: cmp      dword ptr [rdi + 0x140], ebx
00000001405e5893: mov      r9d, 5
00000001405e5899: mov      rcx, rdi
00000001405e589c: setne    bl
00000001405e589f: mov      r8d, ebx
00000001405e58a2: call     0x14026f4f0
00000001405e58a7: xor      r9d, r9d
00000001405e58aa: lea      rdx, [rsp + 0x50]
00000001405e58af: mov      r8d, ebx
00000001405e58b2: mov      rcx, rdi
00000001405e58b5: call     0x14026f4f0
00000001405e58ba: movsd    xmm2, qword ptr [rsi + 0x70]
00000001405e58bf: lea      rcx, [rbp + 0x90]
00000001405e58c6: mov      eax, dword ptr [rsi + 0x78]
00000001405e58c9: movaps   xmm0, xmm2
00000001405e58cc: subss    xmm0, dword ptr [rsp + 0x30]
00000001405e58d2: movaps   xmm1, xmm2
00000001405e58d5: mov      dword ptr [rbp - 0x40], eax
00000001405e58d8: shufps   xmm1, xmm1, 0x55
00000001405e58dc: subss    xmm1, dword ptr [rsp + 0x34]
00000001405e58e2: movsd    qword ptr [rbp - 0x48], xmm2
00000001405e58e7: movss    dword ptr [rbp - 0x80], xmm0
00000001405e58ec: movss    xmm0, dword ptr [rbp - 0x40]
00000001405e58f1: subss    xmm0, dword ptr [rsp + 0x38]
00000001405e58f7: movss    dword ptr [rbp - 0x7c], xmm1
00000001405e58fc: movss    dword ptr [rbp - 0x78], xmm0
00000001405e5901: call     0x14127e6d0
00000001405e5906: lea      rcx, [rbp]
00000001405e590a: call     0x14127e6d0
00000001405e590f: xorps    xmm3, xmm3
00000001405e5912: lea      rcx, [rsp + 0x20]
00000001405e5917: movaps   xmm2, xmm7
00000001405e591a: xorps    xmm1, xmm1
00000001405e591d: call     0x1411ab440
00000001405e5922: movss    xmm0, dword ptr [rsp + 0x50]
00000001405e5928: lea      rcx, [rsp + 0x20]
00000001405e592d: subss    xmm0, dword ptr [rsp + 0x30]
00000001405e5933: movss    xmm1, dword ptr [rsp + 0x54]
00000001405e5939: subss    xmm1, dword ptr [rsp + 0x34]
00000001405e593f: movss    dword ptr [rsp + 0x20], xmm0
00000001405e5945: movss    xmm0, dword ptr [rsp + 0x58]
00000001405e594b: subss    xmm0, dword ptr [rsp + 0x38]
00000001405e5951: movss    dword ptr [rsp + 0x24], xmm1
00000001405e5957: movss    dword ptr [rsp + 0x28], xmm0
00000001405e595d: call     0x1411ac850
00000001405e5962: ucomiss  xmm0, xmm6
00000001405e5965: jp       0x1405e5973
00000001405e5967: jne      0x1405e5973
00000001405e5969: mov      dword ptr [rsp + 0x24], 0x3f800000
00000001405e5971: jmp      0x1405e5993
00000001405e5973: lea      rdx, [rsp + 0x70]
00000001405e5978: lea      rcx, [rsp + 0x20]
00000001405e597d: call     0x1411acc30
00000001405e5982: movsd    xmm0, qword ptr [rax]
00000001405e5986: movsd    qword ptr [rsp + 0x20], xmm0
00000001405e598c: mov      eax, dword ptr [rax + 8]
00000001405e598f: mov      dword ptr [rsp + 0x28], eax
00000001405e5993: xorps    xmm2, xmm2
00000001405e5996: lea      rdx, [rbp - 0x80]
00000001405e599a: lea      rcx, [rbp - 0x18]
00000001405e599e: call     0x1412a7d80
00000001405e59a3: xorps    xmm2, xmm2
00000001405e59a6: lea      rdx, [rsp + 0x20]
00000001405e59ab: lea      rcx, [rbp + 0x40]
00000001405e59af: call     0x1412a7d80
00000001405e59b4: lea      rcx, [rbp + 0xd0]
00000001405e59bb: call     0x14127e6d0
00000001405e59c0: lea      rcx, [rbp + 0x50]
00000001405e59c4: call     0x14127e6d0
00000001405e59c9: lea      rdx, [rsp + 0x20]
00000001405e59ce: lea      rcx, [rbp + 0x50]
00000001405e59d2: call     0x141095a80
00000001405e59d7: lea      r8, [rbp + 0x50]
00000001405e59db: lea      rdx, [rbp + 0x110]
00000001405e59e2: lea      rcx, [rbp + 0xd0]
00000001405e59e9: call     0x141280a10
00000001405e59ee: mov      rdx, rax
00000001405e59f1: lea      rcx, [rbp + 0x90]
00000001405e59f8: call     0x14127e710
00000001405e59fd: lea      rdx, [rbp + 0x110]
00000001405e5a04: lea      rcx, [rbp + 0x90]
00000001405e5a0b: call     0x141280750
00000001405e5a10: mov      rdx, rax
00000001405e5a13: lea      rcx, [rbp]
00000001405e5a17: call     0x14127e710
00000001405e5a1c: xorps    xmm2, xmm2
00000001405e5a1f: lea      rdx, [rsi + 0x4b4]
00000001405e5a26: lea      rcx, [rbp - 0x28]
00000001405e5a2a: call     0x1412a7d80
00000001405e5a2f: lea      r8, [rbp - 0x18]
00000001405e5a33: lea      rdx, [rbp - 0x38]
00000001405e5a37: lea      rcx, [rbp]
00000001405e5a3b: call     0x141283bb0
00000001405e5a40: lea      rcx, [rsi + 0x4b4]
00000001405e5a47: movups   xmm1, xmmword ptr [rax]
00000001405e5a4a: movaps   xmm3, xmm1
00000001405e5a4d: movaps   xmm2, xmm1
00000001405e5a50: shufps   xmm3, xmm1, 0xaa
00000001405e5a54: shufps   xmm2, xmm1, 0x55
00000001405e5a58: movups   xmmword ptr [rbp - 0x28], xmm1
00000001405e5a5c: call     0x1411adb80
00000001405e5a61: mov      rax, qword ptr [rsi]
00000001405e5a64: xor      edx, edx
00000001405e5a66: mov      rcx, rsi
00000001405e5a69: lea      r8d, [rdx + 1]
00000001405e5a6d: call     qword ptr [rax + 0x88]
00000001405e5a73: mov      eax, dword ptr [rip + 0x15aee6f]
00000001405e5a79: xorps    xmm1, xmm1
00000001405e5a7c: mov      r8, qword ptr [rsi]
00000001405e5a7f: cvtsi2ss xmm1, rax
00000001405e5a84: mov      rax, qword ptr [rip + 0x9123a8d]
00000001405e5a8b: movzx    ecx, byte ptr [rax + 0x952]
00000001405e5a92: mulss    xmm1, dword ptr [rip + 0x1beadea]
00000001405e5a9a: movd     xmm0, ecx
00000001405e5a9e: mov      rcx, rsi
00000001405e5aa1: cvtdq2ps xmm0, xmm0
00000001405e5aa4: divss    xmm1, xmm0
00000001405e5aa8: cvttss2si edx, xmm1
00000001405e5aac: call     qword ptr [r8 + 0x78]
00000001405e5ab0: mov      rcx, rsi
00000001405e5ab3: call     0x1405ebb60
00000001405e5ab8: mov      rax, qword ptr [rsi]
00000001405e5abb: mov      rcx, rsi
00000001405e5abe: call     qword ptr [rax + 0x80]
00000001405e5ac4: cmp      dword ptr [rsi + 0x258], 0
00000001405e5acb: je       0x1405e5ae9
00000001405e5acd: mov      ecx, dword ptr [rsi + 0x108]
00000001405e5ad3: call     0x140ad8880
00000001405e5ad8: test     rax, rax
00000001405e5adb: je       0x1405e5ae9
00000001405e5add: mov      rcx, rax
00000001405e5ae0: call     0x1409ce020
00000001405e5ae5: test     eax, eax
00000001405e5ae7: jg       0x1405e5af0
00000001405e5ae9: inc      qword ptr [rsi + 0x100]
00000001405e5af0: mov      ecx, dword ptr [rsi + 0x108]
00000001405e5af6: call     0x140ad8880
00000001405e5afb: mov      rbx, rax
00000001405e5afe: test     rax, rax
00000001405e5b01: je       0x1405e5b89
00000001405e5b07: cmp      dword ptr [rax + 0xe64], 0xc4
00000001405e5b11: jne      0x1405e5b89
00000001405e5b13: mov      rdx, qword ptr [rax]
00000001405e5b16: mov      rcx, rax
00000001405e5b19: call     qword ptr [rdx + 0x1278]
00000001405e5b1f: test     eax, eax
00000001405e5b21: je       0x1405e5b89
00000001405e5b23: mov      rcx, rbx
00000001405e5b26: call     0x1409a2860
00000001405e5b2b: cmp      eax, 0x1be
00000001405e5b30: jne      0x1405e5b89
00000001405e5b32: lea      rdx, [rip + 0x12a8ddf]
00000001405e5b39: lea      rcx, [r13 + 8]
00000001405e5b3d: call     0x141443072
00000001405e5b42: test     eax, eax
00000001405e5b44: je       0x1405e5b5a
00000001405e5b46: lea      rdx, [rip + 0x12a8deb]
00000001405e5b4d: lea      rcx, [r13 + 8]
00000001405e5b51: call     0x141443072
00000001405e5b56: test     eax, eax
00000001405e5b58: jne      0x1405e5b89
00000001405e5b5a: mov      rcx, qword ptr [rbx + 0x208]
00000001405e5b61: test     rcx, rcx
00000001405e5b64: je       0x1405e5b89
00000001405e5b66: call     0x1405fbeb0
00000001405e5b6b: mov      ebx, eax
00000001405e5b6d: call     0x1409bdb30
00000001405e5b72: movzx    eax, al
00000001405e5b75: xor      edx, edx
00000001405e5b77: imul     eax, ebx
00000001405e5b7a: div      dword ptr [rip + 0x15aed68]
00000001405e5b80: mov      ecx, eax
00000001405e5b82: mov      qword ptr [rsi + 0x100], rcx
00000001405e5b89: mov      eax, dword ptr [rip + 0x15aed59]
00000001405e5b8f: xorps    xmm1, xmm1
00000001405e5b92: cvtsi2ss xmm1, rax
00000001405e5b97: mov      rax, qword ptr [rip + 0x912397a]
00000001405e5b9e: movzx    ecx, byte ptr [rax + 0x952]
00000001405e5ba5: mulss    xmm1, dword ptr [rip + 0x1beacd7]
00000001405e5bad: movd     xmm0, ecx
00000001405e5bb1: cvtdq2ps xmm0, xmm0
00000001405e5bb4: divss    xmm1, xmm0
00000001405e5bb8: cvttss2si eax, xmm1
00000001405e5bbc: movd     xmm1, eax
00000001405e5bc0: cvtdq2ps xmm1, xmm1
00000001405e5bc3: addss    xmm1, dword ptr [rsi + 0x484]
00000001405e5bcb: movss    dword ptr [rsi + 0x484], xmm1
00000001405e5bd3: test     r15d, r15d
00000001405e5bd6: je       0x1405e5c3f
00000001405e5bd8: cmp      qword ptr [rsi + 0x100], 0x258
00000001405e5be3: jbe      0x1405e5c3f
00000001405e5be5: lea      rdx, [rip + 0x12a8d6c]
00000001405e5bec: lea      rcx, [r13 + 8]
00000001405e5bf0: call     0x141443072
00000001405e5bf5: test     eax, eax
00000001405e5bf7: je       0x1405e5c35
00000001405e5bf9: lea      rdx, [rip + 0x12a8d68]
00000001405e5c00: lea      rcx, [r13 + 8]
00000001405e5c04: call     0x141443072
00000001405e5c09: test     eax, eax
00000001405e5c0b: je       0x1405e5c35
00000001405e5c0d: lea      rdx, [rip + 0x11f92fc]
00000001405e5c14: lea      rcx, [r13 + 8]
00000001405e5c18: call     0x141443072
00000001405e5c1d: test     eax, eax
00000001405e5c1f: je       0x1405e5c35
00000001405e5c21: lea      rdx, [rip + 0x12a8d50]
00000001405e5c28: lea      rcx, [r13 + 8]
00000001405e5c2c: call     0x141443072
00000001405e5c31: test     eax, eax
00000001405e5c33: jne      0x1405e5c3f
00000001405e5c35: mov      dword ptr [rsi + 0x3a8], 1
00000001405e5c3f: mov      rcx, qword ptr [rip + 0x1d50092]
00000001405e5c46: call     0x14109e1d0
00000001405e5c4b: cmp      eax, 0xa4
00000001405e5c50: je       0x1405e5c69
00000001405e5c52: mov      rcx, qword ptr [rip + 0x1d5007f]
00000001405e5c59: call     0x14109e1d0
00000001405e5c5e: cmp      eax, 0xa5
00000001405e5c63: jne      0x1405e5cfe
00000001405e5c69: mov      rax, qword ptr [rip + 0x91238a8]
00000001405e5c70: movss    xmm1, dword ptr [rip + 0x117dcf4]
00000001405e5c78: movss    xmm2, dword ptr [rip + 0x1191c18]
00000001405e5c80: movzx    ecx, byte ptr [rax + 0x952]
00000001405e5c87: movd     xmm0, ecx
00000001405e5c8b: xor      ecx, ecx
00000001405e5c8d: cvtdq2ps xmm0, xmm0
00000001405e5c90: divss    xmm1, xmm0
00000001405e5c94: movss    xmm0, dword ptr [rip + 0x11c1c84]
00000001405e5c9c: divss    xmm2, xmm1
00000001405e5ca0: comiss   xmm2, xmm0
00000001405e5ca3: jb       0x1405e5cbb
00000001405e5ca5: subss    xmm2, xmm0
00000001405e5ca9: comiss   xmm2, xmm0
00000001405e5cac: jae      0x1405e5cbb
00000001405e5cae: movabs   rax, 0x8000000000000000
00000001405e5cb8: mov      rcx, rax
00000001405e5cbb: cvttss2si rax, xmm2
00000001405e5cc0: add      rax, rcx
00000001405e5cc3: cmp      qword ptr [rsi + 0x100], rax
00000001405e5cca: jbe      0x1405e5cfe
00000001405e5ccc: lea      rdx, [rip + 0x12a8cbd]
00000001405e5cd3: lea      rcx, [r13 + 8]
00000001405e5cd7: call     0x141443072
00000001405e5cdc: test     eax, eax
00000001405e5cde: je       0x1405e5cf4
00000001405e5ce0: lea      rdx, [rip + 0x12a8cb9]
00000001405e5ce7: lea      rcx, [r13 + 8]
00000001405e5ceb: call     0x141443072
00000001405e5cf0: test     eax, eax
00000001405e5cf2: jne      0x1405e5cfe
00000001405e5cf4: mov      dword ptr [rsi + 0x3a8], 1
00000001405e5cfe: movss    xmm1, dword ptr [rip + 0x11a69f2]
00000001405e5d06: lea      rcx, [rsp + 0x60]
00000001405e5d0b: movaps   xmm3, xmm1
00000001405e5d0e: movaps   xmm2, xmm1
00000001405e5d11: xor      r12d, r12d
00000001405e5d14: call     0x1411ab440
00000001405e5d19: movss    xmm1, dword ptr [rip + 0x1290dc7]
00000001405e5d21: lea      rcx, [rsp + 0x40]
00000001405e5d26: movaps   xmm3, xmm1
00000001405e5d29: movaps   xmm2, xmm1
00000001405e5d2c: call     0x1411ab440
00000001405e5d31: mov      rcx, qword ptr [rip + 0x1be8478]
00000001405e5d38: test     rcx, rcx
00000001405e5d3b: je       0x1405e5e5d
00000001405e5d41: call     0x140a7c500
00000001405e5d46: mov      r13, rax
00000001405e5d49: test     rax, rax
00000001405e5d4c: je       0x1405e5e59
00000001405e5d52: mov      rcx, rax
00000001405e5d55: call     0x140a844f0
00000001405e5d5a: xor      r15d, r15d
00000001405e5d5d: test     eax, eax
00000001405e5d5f: je       0x1405e5e59
00000001405e5d65: mov      esi, eax
00000001405e5d67: nop      word ptr [rax + rax]
00000001405e5d70: mov      edx, r15d
00000001405e5d73: mov      rcx, r13
00000001405e5d76: call     0x140a844c0
00000001405e5d7b: mov      r14, rax
00000001405e5d7e: test     rax, rax
00000001405e5d81: je       0x1405e5e49
00000001405e5d87: mov      rcx, qword ptr [rax + 0x30]
00000001405e5d8b: xor      edi, edi
00000001405e5d8d: mov      rdx, qword ptr [rax + 0x38]
00000001405e5d91: sub      rdx, rcx
00000001405e5d94: sar      rdx, 3
00000001405e5d98: test     rdx, rdx
00000001405e5d9b: je       0x1405e5e49
00000001405e5da1: xor      edx, edx
00000001405e5da3: mov      rcx, qword ptr [rcx + rdx*8]
00000001405e5da7: call     0x1410d3140
00000001405e5dac: mov      rbx, rax
00000001405e5daf: test     rax, rax
00000001405e5db2: je       0x1405e5e2d
00000001405e5db4: mov      rdx, qword ptr [rax]
00000001405e5db7: mov      rcx, rax
00000001405e5dba: call     qword ptr [rdx + 8]
00000001405e5dbd: test     eax, eax
00000001405e5dbf: jle      0x1405e5e2d
00000001405e5dc1: movss    xmm0, dword ptr [rbx + 8]
00000001405e5dc6: mov      r12d, 1
00000001405e5dcc: movss    xmm1, dword ptr [rsp + 0x60]
00000001405e5dd2: comiss   xmm0, xmm1
00000001405e5dd5: movss    xmm3, dword ptr [rsp + 0x68]
00000001405e5ddb: movss    xmm2, dword ptr [rsp + 0x64]
00000001405e5de1: minss    xmm3, dword ptr [rbx + 0x10]
00000001405e5de6: minss    xmm2, dword ptr [rbx + 0xc]
00000001405e5deb: ja       0x1405e5df0
00000001405e5ded: movaps   xmm1, xmm0
00000001405e5df0: lea      rcx, [rsp + 0x60]
00000001405e5df5: call     0x1411adb80
00000001405e5dfa: movss    xmm0, dword ptr [rbx + 0x14]
00000001405e5dff: movss    xmm1, dword ptr [rsp + 0x40]
00000001405e5e05: comiss   xmm1, xmm0
00000001405e5e08: movss    xmm3, dword ptr [rsp + 0x48]
00000001405e5e0e: movss    xmm2, dword ptr [rsp + 0x44]
00000001405e5e14: maxss    xmm3, dword ptr [rbx + 0x1c]
00000001405e5e19: maxss    xmm2, dword ptr [rbx + 0x18]
00000001405e5e1e: ja       0x1405e5e23
00000001405e5e20: movaps   xmm1, xmm0
00000001405e5e23: lea      rcx, [rsp + 0x40]
00000001405e5e28: call     0x1411adb80
00000001405e5e2d: mov      rcx, qword ptr [r14 + 0x30]
00000001405e5e31: inc      edi
00000001405e5e33: mov      rax, qword ptr [r14 + 0x38]
00000001405e5e37: sub      rax, rcx
00000001405e5e3a: mov      edx, edi
00000001405e5e3c: sar      rax, 3
00000001405e5e40: cmp      rdx, rax
00000001405e5e43: jb       0x1405e5da3
00000001405e5e49: inc      r15d
00000001405e5e4c: cmp      r15d, esi
00000001405e5e4f: jb       0x1405e5d70
00000001405e5e55: mov      rsi, qword ptr [rbp - 0x50]
00000001405e5e59: mov      r13, qword ptr [rbp - 0x68]
00000001405e5e5d: mov      ecx, dword ptr [rsi + 0x108]
00000001405e5e63: call     0x140ad8880
00000001405e5e68: test     rax, rax
00000001405e5e6b: je       0x1405e5e7d
00000001405e5e6d: cmp      dword ptr [rax + 0xea4], 0x95
00000001405e5e77: je       0x1405e5fc1
00000001405e5e7d: test     r12d, r12d
00000001405e5e80: je       0x1405e5fc1
00000001405e5e86: movss    xmm0, dword ptr [rsp + 0x68]
00000001405e5e8c: subss    xmm0, dword ptr [rip + 0x11978f0]
00000001405e5e94: movss    xmm2, dword ptr [rip + 0x11ff620]
00000001405e5e9c: movss    xmm3, dword ptr [rsp + 0x48]
00000001405e5ea2: comiss   xmm2, xmm3
00000001405e5ea5: movss    dword ptr [rsp + 0x68], xmm0
00000001405e5eab: jbe      0x1405e5eb6
00000001405e5ead: movss    dword ptr [rsp + 0x48], xmm2
00000001405e5eb3: movaps   xmm3, xmm2
00000001405e5eb6: cmp      dword ptr [rsi + 0x1d0], 0
00000001405e5ebd: jne      0x1405e5ecd
00000001405e5ebf: subss    xmm0, dword ptr [rip + 0x11a0fad]
00000001405e5ec7: movss    dword ptr [rsp + 0x68], xmm0
00000001405e5ecd: cmp      qword ptr [rip + 0x1b931eb], 0
00000001405e5ed5: movss    xmm1, dword ptr [rsp + 0x44]
00000001405e5edb: je       0x1405e5eeb
00000001405e5edd: comiss   xmm2, xmm1
00000001405e5ee0: jbe      0x1405e5eeb
00000001405e5ee2: movss    dword ptr [rsp + 0x44], xmm2
00000001405e5ee8: movaps   xmm1, xmm2
00000001405e5eeb: movss    xmm2, dword ptr [rsi + 0x70]
00000001405e5ef0: movss    xmm7, dword ptr [rsp + 0x60]
00000001405e5ef6: comiss   xmm7, xmm2
00000001405e5ef9: movss    xmm6, dword ptr [rsp + 0x64]
00000001405e5eff: ja       0x1405e5f2a
00000001405e5f01: movss    xmm5, dword ptr [rsi + 0x74]
00000001405e5f06: comiss   xmm6, xmm5
00000001405e5f09: ja       0x1405e5f2a
00000001405e5f0b: movss    xmm4, dword ptr [rsi + 0x78]
00000001405e5f10: comiss   xmm0, xmm4
00000001405e5f13: ja       0x1405e5f2a
00000001405e5f15: comiss   xmm2, dword ptr [rsp + 0x40]
00000001405e5f1a: ja       0x1405e5f2a
00000001405e5f1c: comiss   xmm5, xmm1
00000001405e5f1f: ja       0x1405e5f2a
00000001405e5f21: comiss   xmm4, xmm3
00000001405e5f24: jbe      0x1405e5fc1
00000001405e5f2a: cvtps2pd xmm3, xmm0
00000001405e5f2d: lea      rcx, [rip + 0x12a8a7c]
00000001405e5f34: cvtps2pd xmm2, xmm6
00000001405e5f37: cvtps2pd xmm1, xmm7
00000001405e5f3a: movq     r9, xmm3
00000001405e5f3f: movq     r8, xmm2
00000001405e5f44: movq     rdx, xmm1
00000001405e5f49: call     0x14127bf80
00000001405e5f4e: movss    xmm3, dword ptr [rsp + 0x48]
00000001405e5f54: lea      rcx, [rip + 0x12a8a75]
00000001405e5f5b: movss    xmm2, dword ptr [rsp + 0x44]
00000001405e5f61: movss    xmm1, dword ptr [rsp + 0x40]
00000001405e5f67: cvtps2pd xmm3, xmm3
00000001405e5f6a: cvtps2pd xmm2, xmm2
00000001405e5f6d: cvtps2pd xmm1, xmm1
00000001405e5f70: movq     r9, xmm3
00000001405e5f75: movq     r8, xmm2
00000001405e5f7a: movq     rdx, xmm1
00000001405e5f7f: call     0x14127bf80
00000001405e5f84: movss    xmm3, dword ptr [rsi + 0x78]
00000001405e5f89: lea      rcx, [rip + 0x12a8a60]
00000001405e5f90: movss    xmm2, dword ptr [rsi + 0x74]
00000001405e5f95: movss    xmm1, dword ptr [rsi + 0x70]
00000001405e5f9a: cvtps2pd xmm3, xmm3
00000001405e5f9d: cvtps2pd xmm2, xmm2
00000001405e5fa0: cvtps2pd xmm1, xmm1
00000001405e5fa3: movq     r9, xmm3
00000001405e5fa8: movq     r8, xmm2
00000001405e5fad: movq     rdx, xmm1
00000001405e5fb2: call     0x14127bf80
00000001405e5fb7: mov      dword ptr [rsi + 0x3a8], 1
00000001405e5fc1: mov      r11d, dword ptr [rip + 0x1591f64]
00000001405e5fc8: mov      r15, 0xffffffffffffffff
00000001405e5fcf: movaps   xmm7, xmmword ptr [rsp + 0x260]
00000001405e5fd7: movaps   xmm6, xmmword ptr [rsp + 0x270]
00000001405e5fdf: mov      r12, qword ptr [rsp + 0x2c8]
00000001405e5fe7: cmp      dword ptr [rsi + 0x600], r11d
00000001405e5fee: je       0x1405e61a6
00000001405e5ff4: mov      edx, dword ptr [rsi + 0x10c]
00000001405e5ffa: mov      rcx, qword ptr [rip + 0x1bf1497]
00000001405e6001: call     0x140a63f90
00000001405e6006: test     rax, rax
00000001405e6009: je       0x1405e619f
00000001405e600f: mov      ecx, dword ptr [rsi + 0x148]
00000001405e6015: mov      r14, qword ptr [rax + rcx*8 + 0x360]
00000001405e601d: test     r14, r14
00000001405e6020: je       0x1405e619f
00000001405e6026: xor      ebx, ebx
00000001405e6028: cmp      qword ptr [rsi + 0x608], rbx
00000001405e602f: je       0x1405e619f
00000001405e6035: xor      edi, edi
00000001405e6037: cmp      dword ptr [r14 + 0x160], ebx
00000001405e603e: jbe      0x1405e619f
00000001405e6044: mov      r11d, dword ptr [rip + 0x1591ee1]
00000001405e604b: nop      dword ptr [rax + rax]
00000001405e6050: mov      rcx, qword ptr [rsi + 0x6b0]
00000001405e6057: mov      rax, qword ptr [rsi + 0x6a8]
00000001405e605e: cmp      rax, rcx
00000001405e6061: je       0x1405e614f
00000001405e6067: nop      word ptr [rax + rax]
00000001405e6070: mov      rdx, qword ptr [rax + 8]
00000001405e6074: mov      r10, qword ptr [rsi + 0x608]
00000001405e607b: sub      r10, rdx
00000001405e607e: nop      
00000001405e6080: movzx    r9d, byte ptr [rdx]
00000001405e6084: movzx    r8d, byte ptr [rdx + r10]
00000001405e6089: sub      r9d, r8d
00000001405e608c: jne      0x1405e6096
00000001405e608e: inc      rdx
00000001405e6091: test     r8d, r8d
00000001405e6094: jne      0x1405e6080
00000001405e6096: test     r9d, r9d
00000001405e6099: jne      0x1405e6142
00000001405e609f: mov      rdx, qword ptr [rip + 0x1bf13fa]
00000001405e60a6: mov      r9d, dword ptr [rax]
00000001405e60a9: mov      r10, qword ptr [rdx + 0x58]
00000001405e60ad: mov      r8, r10
00000001405e60b0: mov      rdx, qword ptr [r10 + 8]
00000001405e60b4: cmp      byte ptr [rdx + 0x19], 0
00000001405e60b8: jne      0x1405e60d8
00000001405e60ba: nop      word ptr [rax + rax]
00000001405e60c0: cmp      dword ptr [rdx + 0x20], r9d
00000001405e60c4: jae      0x1405e60cc
00000001405e60c6: mov      rdx, qword ptr [rdx + 0x10]
00000001405e60ca: jmp      0x1405e60d2
00000001405e60cc: mov      r8, rdx
00000001405e60cf: mov      rdx, qword ptr [rdx]
00000001405e60d2: cmp      byte ptr [rdx + 0x19], 0
00000001405e60d6: je       0x1405e60c0
00000001405e60d8: cmp      byte ptr [r8 + 0x19], 0
00000001405e60dd: jne      0x1405e6142
00000001405e60df: cmp      r9d, dword ptr [r8 + 0x20]
00000001405e60e3: jb       0x1405e6142
00000001405e60e5: cmp      r8, r10
00000001405e60e8: je       0x1405e6142
00000001405e60ea: mov      rdx, qword ptr [r8 + 0x28]
00000001405e60ee: test     rdx, rdx
00000001405e60f1: je       0x1405e6142
00000001405e60f3: cmp      dword ptr [rdx + 0x600], r11d
00000001405e60fa: jne      0x1405e6142
00000001405e60fc: movups   xmm0, xmmword ptr [rsi + 0x600]
00000001405e6103: mov      ebx, 1
00000001405e6108: movups   xmmword ptr [rdx + 0x600], xmm0
00000001405e610f: movups   xmm1, xmmword ptr [rsi + 0x610]
00000001405e6116: movups   xmmword ptr [rdx + 0x610], xmm1
00000001405e611d: movups   xmm0, xmmword ptr [rsi + 0x620]
00000001405e6124: movups   xmmword ptr [rdx + 0x620], xmm0
00000001405e612b: movsd    xmm1, qword ptr [rsi + 0x630]
00000001405e6133: movsd    qword ptr [rdx + 0x630], xmm1
00000001405e613b: mov      r11d, dword ptr [rip + 0x1591dea]
00000001405e6142: add      rax, 0x10
00000001405e6146: cmp      rax, rcx
00000001405e6149: jne      0x1405e6070
00000001405e614f: inc      edi
00000001405e6151: cmp      edi, dword ptr [r14 + 0x160]
00000001405e6158: jb       0x1405e6050
00000001405e615e: xor      r9d, r9d
00000001405e6161: test     ebx, ebx
00000001405e6163: je       0x1405e61a9
00000001405e6165: mov      dword ptr [rsi + 0x600], r11d
00000001405e616c: mov      qword ptr [rsi + 0x608], r9
00000001405e6173: mov      qword ptr [rsi + 0x610], r9
00000001405e617a: mov      qword ptr [rsi + 0x618], r9
00000001405e6181: mov      dword ptr [rsi + 0x620], r15d
00000001405e6188: mov      qword ptr [rsi + 0x628], r9
00000001405e618f: mov      dword ptr [rsi + 0x630], r9d
00000001405e6196: mov      r11d, dword ptr [rip + 0x1591d8f]
00000001405e619d: jmp      0x1405e61a9
00000001405e619f: mov      r11d, dword ptr [rip + 0x1591d86]
00000001405e61a6: xor      r9d, r9d
00000001405e61a9: mov      edx, dword ptr [rsi + 0x600]
00000001405e61af: cmp      edx, r11d
00000001405e61b2: je       0x1405e631a
00000001405e61b8: mov      rax, qword ptr [rip + 0x1bf12e1]
00000001405e61bf: mov      r8, qword ptr [rax + 0x58]
00000001405e61c3: mov      rcx, r8
00000001405e61c6: mov      rax, qword ptr [r8 + 8]
00000001405e61ca: cmp      byte ptr [rax + 0x19], 0
00000001405e61ce: jne      0x1405e61e7
00000001405e61d0: cmp      dword ptr [rax + 0x20], edx
00000001405e61d3: jae      0x1405e61db
00000001405e61d5: mov      rax, qword ptr [rax + 0x10]
00000001405e61d9: jmp      0x1405e61e1
00000001405e61db: mov      rcx, rax
00000001405e61de: mov      rax, qword ptr [rax]
00000001405e61e1: cmp      byte ptr [rax + 0x19], 0
00000001405e61e5: je       0x1405e61d0
00000001405e61e7: cmp      byte ptr [rcx + 0x19], 0
00000001405e61eb: jne      0x1405e62ca
00000001405e61f1: cmp      edx, dword ptr [rcx + 0x20]
00000001405e61f4: jb       0x1405e62ca
00000001405e61fa: cmp      rcx, r8
00000001405e61fd: je       0x1405e62ca
00000001405e6203: mov      rdi, qword ptr [rcx + 0x28]
00000001405e6207: test     rdi, rdi
00000001405e620a: je       0x1405e62ca
00000001405e6210: mov      rdi, qword ptr [rdi + 0x140]
00000001405e6217: test     rdi, rdi
00000001405e621a: je       0x1405e631a
00000001405e6220: mov      rbx, qword ptr [rsi + 0x610]
00000001405e6227: test     rbx, rbx
00000001405e622a: je       0x1405e631a
00000001405e6230: mov      rax, r15
00000001405e6233: inc      rax
00000001405e6236: cmp      byte ptr [rbx + rax], 0
00000001405e623a: jne      0x1405e6233
00000001405e623c: test     eax, eax
00000001405e623e: je       0x1405e628d
00000001405e6240: mov      rcx, qword ptr [rdi + 0x20]
00000001405e6244: test     rcx, rcx
00000001405e6247: je       0x1405e6251
00000001405e6249: mov      rax, qword ptr [rcx]
00000001405e624c: call     qword ptr [rax + 0x10]
00000001405e624f: jmp      0x1405e6265
00000001405e6251: mov      rcx, qword ptr [rdi + 0x18]
00000001405e6255: test     rcx, rcx
00000001405e6258: je       0x1405e6262
00000001405e625a: mov      rax, qword ptr [rcx]
00000001405e625d: call     qword ptr [rax + 0x10]
00000001405e6260: jmp      0x1405e6265
00000001405e6262: mov      rax, r9
00000001405e6265: sub      rbx, rax
00000001405e6268: nop      dword ptr [rax + rax]
00000001405e6270: movzx    r8d, byte ptr [rax]
00000001405e6274: movzx    edx, byte ptr [rax + rbx]
00000001405e6278: sub      r8d, edx
00000001405e627b: jne      0x1405e6284
00000001405e627d: inc      rax
00000001405e6280: test     edx, edx
00000001405e6282: jne      0x1405e6270
00000001405e6284: test     r8d, r8d
00000001405e6287: jne      0x1405e631a
00000001405e628d: mov      rdx, qword ptr [rsi + 0x618]
00000001405e6294: mov      rcx, rdi
00000001405e6297: call     0x140ae7c00
00000001405e629c: test     rax, rax
00000001405e629f: je       0x1405e631a
00000001405e62a1: movzx    ecx, byte ptr [rax + 0x120]
00000001405e62a8: lea      rdx, [rsp + 0x70]
00000001405e62ad: shl      rcx, 6
00000001405e62b1: add      rax, 0x7c
00000001405e62b5: add      rcx, rax
00000001405e62b8: call     0x141283ee0
00000001405e62bd: mov      rdx, rax
00000001405e62c0: mov      rcx, rsi
00000001405e62c3: call     0x1410a9400
00000001405e62c8: jmp      0x1405e631a
00000001405e62ca: mov      edx, dword ptr [rsi + 0x620]
00000001405e62d0: mov      dword ptr [rsi + 0x600], r11d
00000001405e62d7: mov      qword ptr [rsi + 0x608], r9
00000001405e62de: mov      qword ptr [rsi + 0x610], r9
00000001405e62e5: mov      qword ptr [rsi + 0x618], r9
00000001405e62ec: mov      dword ptr [rsi + 0x620], r15d
00000001405e62f3: mov      qword ptr [rsi + 0x628], r9
00000001405e62fa: mov      dword ptr [rsi + 0x630], r9d
00000001405e6301: test     edx, edx
00000001405e6303: jns      0x1405e6311
00000001405e6305: mov      dword ptr [rsi + 0x3a8], 1
00000001405e630f: jmp      0x1405e631a
00000001405e6311: mov      rax, qword ptr [rsi]
00000001405e6314: mov      rcx, rsi
00000001405e6317: call     qword ptr [rax + 0x70]
00000001405e631a: mov      rdi, qword ptr [rsi + 0x628]
00000001405e6321: test     rdi, rdi
00000001405e6324: je       0x1405e64b4
00000001405e632a: mov      rax, qword ptr [rip + 0x1bf11d7]
00000001405e6331: mov      ecx, dword ptr [rsi + 0x208]
00000001405e6337: mov      rdx, qword ptr [rax + 0x58]
00000001405e633b: mov      rbx, rdx
00000001405e633e: mov      rax, qword ptr [rdx + 8]
00000001405e6342: cmp      byte ptr [rax + 0x19], 0
00000001405e6346: jne      0x1405e635f
00000001405e6348: cmp      dword ptr [rax + 0x20], ecx
00000001405e634b: jae      0x1405e6353
00000001405e634d: mov      rax, qword ptr [rax + 0x10]
00000001405e6351: jmp      0x1405e6359
00000001405e6353: mov      rbx, rax
00000001405e6356: mov      rax, qword ptr [rax]
00000001405e6359: cmp      byte ptr [rax + 0x19], 0
00000001405e635d: je       0x1405e6348
00000001405e635f: cmp      byte ptr [rbx + 0x19], 0
00000001405e6363: jne      0x1405e64b4
00000001405e6369: cmp      ecx, dword ptr [rbx + 0x20]
00000001405e636c: jb       0x1405e64b4
00000001405e6372: cmp      rbx, rdx
00000001405e6375: je       0x1405e64b4
00000001405e637b: mov      rbx, qword ptr [rbx + 0x28]
00000001405e637f: test     rbx, rbx
00000001405e6382: je       0x1405e64b4
00000001405e6388: cmp      dword ptr [rsi + 0x630], 0
00000001405e638f: je       0x1405e6418
00000001405e6395: cmp      dword ptr [rsi + 0x700], 0x84
00000001405e639f: jne      0x1405e63f0
00000001405e63a1: mov      rcx, rsi
00000001405e63a4: call     0x1405e9d60
00000001405e63a9: mov      r14, rax
00000001405e63ac: test     rax, rax
00000001405e63af: je       0x1405e63c4
00000001405e63b1: lea      rdx, [rip + 0x12a8bb8]
00000001405e63b8: mov      rcx, rax
00000001405e63bb: call     0x141443072
00000001405e63c0: test     eax, eax
00000001405e63c2: je       0x1405e63d7
00000001405e63c4: lea      rdx, [rip + 0x12a8dad]
00000001405e63cb: mov      rcx, r14
00000001405e63ce: call     0x141443072
00000001405e63d3: test     eax, eax
00000001405e63d5: jne      0x1405e63f0
00000001405e63d7: mov      edx, dword ptr [rsi + 0x704]
00000001405e63dd: mov      rcx, qword ptr [rip + 0x1bf1124]
00000001405e63e4: call     0x1400c2d90
00000001405e63e9: test     rax, rax
00000001405e63ec: je       0x1405e63ff
00000001405e63ee: jmp      0x1405e63fc
00000001405e63f0: mov      rax, qword ptr [rbx]
00000001405e63f3: mov      rcx, rbx
00000001405e63f6: call     qword ptr [rax + 0xdc0]
00000001405e63fc: mov      rbx, rax
00000001405e63ff: mov      rcx, rbx
00000001405e6402: call     0x1409ce030
00000001405e6407: test     eax, eax
00000001405e6409: jg       0x1405e64b4
00000001405e640f: test     rbx, rbx
00000001405e6412: je       0x1405e64b4
00000001405e6418: mov      rax, qword ptr [rbx]
00000001405e641b: mov      rdx, rdi
00000001405e641e: mov      rcx, rbx
00000001405e6421: call     qword ptr [rax + 0xc78]
00000001405e6427: mov      rcx, rax
00000001405e642a: test     rax, rax
00000001405e642d: jne      0x1405e645c
00000001405e642f: nop      
00000001405e6430: inc      r15
00000001405e6433: cmp      byte ptr [rdi + r15], 0
00000001405e6438: jne      0x1405e6430
00000001405e643a: test     r15d, r15d
00000001405e643d: je       0x1405e64b4
00000001405e643f: mov      rax, qword ptr [rbx]
00000001405e6442: mov      r8d, 1
00000001405e6448: mov      rdx, rdi
00000001405e644b: mov      rcx, rbx
00000001405e644e: call     qword ptr [rax + 0xc80]
00000001405e6454: mov      rcx, rax
00000001405e6457: test     rax, rax
00000001405e645a: je       0x1405e64b4
00000001405e645c: movzx    edi, byte ptr [rcx + 0x120]
00000001405e6463: lea      rdx, [rsp + 0x70]
00000001405e6468: shl      rdi, 6
00000001405e646c: add      rdi, rcx
00000001405e646f: lea      rcx, [rsi + 0xac]
00000001405e6476: call     0x141283ee0
00000001405e647b: lea      rdx, [rdi + 0x7c]
00000001405e647f: lea      rcx, [rsi + 0xac]
00000001405e6486: call     0x14127e710
00000001405e648b: lea      rdx, [rsp + 0x70]
00000001405e6490: lea      rcx, [rsi + 0xac]
00000001405e6497: call     0x141282e80
00000001405e649c: lea      rdx, [rbp - 0x48]
00000001405e64a0: lea      rcx, [rdi + 0x7c]
00000001405e64a4: call     0x141283ee0
00000001405e64a9: mov      rdx, rax
00000001405e64ac: mov      rcx, rsi
00000001405e64af: call     0x1410a9400
00000001405e64b4: mov      rcx, rsi
00000001405e64b7: call     0x1405e6ef0
00000001405e64bc: mov      ecx, dword ptr [rsi + 0x108]
00000001405e64c2: call     0x140ad8880
00000001405e64c7: mov      r15, qword ptr [rsp + 0x280]
00000001405e64cf: mov      r14, qword ptr [rsp + 0x288]
00000001405e64d7: mov      rdi, qword ptr [rsp + 0x2c0]
00000001405e64df: test     rax, rax
00000001405e64e2: je       0x1405e6541
00000001405e64e4: mov      rdx, qword ptr [rax]
00000001405e64e7: mov      rcx, rax
00000001405e64ea: call     qword ptr [rdx + 0xdc0]
00000001405e64f0: mov      rbx, rax
00000001405e64f3: test     rax, rax
00000001405e64f6: je       0x1405e6541
00000001405e64f8: cmp      dword ptr [rsi + 0x23c], 0
00000001405e64ff: je       0x1405e6511
00000001405e6501: mov      r8, qword ptr [rax]
00000001405e6504: mov      rdx, rsi
00000001405e6507: mov      rcx, rax
00000001405e650a: call     qword ptr [r8 + 0xe00]
00000001405e6511: mov      rdx, qword ptr [rbx]
00000001405e6514: mov      rcx, rbx
00000001405e6517: call     qword ptr [rdx + 0xe08]
00000001405e651d: test     eax, eax
00000001405e651f: je       0x1405e6537
00000001405e6521: mov      rax, qword ptr [rbx]
00000001405e6524: mov      rcx, rbx
00000001405e6527: call     qword ptr [rax + 0xe10]
00000001405e652d: movss    dword ptr [rsi + 0x164], xmm0
00000001405e6535: jmp      0x1405e6541
00000001405e6537: mov      dword ptr [rsi + 0x164], 0x3f800000
00000001405e6541: mov      rdx, r13
00000001405e6544: mov      rcx, rsi
00000001405e6547: call     0x1405e16a0
00000001405e654c: cmp      dword ptr [rsi + 0x640], 1
00000001405e6553: mov      rbx, qword ptr [rsp + 0x2b8]
00000001405e655b: jne      0x1405e65af
00000001405e655d: lea      rcx, [rsi + 0xa0]
00000001405e6564: call     0x1411ac850
00000001405e6569: addss    xmm0, dword ptr [rsi + 0x658]
00000001405e6571: movss    xmm1, dword ptr [rsi + 0x650]
00000001405e6579: mulss    xmm1, dword ptr [rip + 0x11e0ebb]
00000001405e6581: movss    dword ptr [rsi + 0x658], xmm0
00000001405e6589: comiss   xmm0, xmm1
00000001405e658c: jbe      0x1405e65af
00000001405e658e: xor      edx, edx
00000001405e6590: mov      rcx, rsi
00000001405e6593: call     0x1405e0470
00000001405e6598: cmp      eax, 1
00000001405e659b: jne      0x1405e65af
00000001405e659d: mov      rcx, rsi
00000001405e65a0: call     0x1405e47a0
00000001405e65a5: mov      dword ptr [rsi + 0x658], 0
00000001405e65af: mov      rcx, qword ptr [rsi + 0x6d0]
00000001405e65b6: test     rcx, rcx
00000001405e65b9: je       0x1405e669e
00000001405e65bf: cmp      qword ptr [rsi + 0x6d8], 0
00000001405e65c7: je       0x1405e669e
00000001405e65cd: lea      rdx, [rsp + 0x50]
00000001405e65d2: call     0x14128a050
00000001405e65d7: lea      rcx, [rbp]
00000001405e65db: call     0x14127e6d0
00000001405e65e0: movss    xmm3, dword ptr [rsp + 0x58]
00000001405e65e6: lea      rcx, [rsp + 0x70]
00000001405e65eb: movss    xmm2, dword ptr [rsp + 0x54]
00000001405e65f1: movss    xmm1, dword ptr [rsp + 0x50]
00000001405e65f7: call     0x141283eb0
00000001405e65fc: lea      rdx, [rbp + 0x110]
00000001405e6603: lea      rcx, [rbp]
00000001405e6607: call     0x141283aa0
00000001405e660c: mov      rdx, rax
00000001405e660f: lea      r8, [rsp + 0x70]
00000001405e6614: lea      rcx, [rbp + 0x50]
00000001405e6618: call     0x1411af0c0
00000001405e661d: mov      rdx, rax
00000001405e6620: lea      rcx, [rbp + 0xd0]
00000001405e6627: call     0x14127e5e0
00000001405e662c: lea      rdx, [rbp + 0xd0]
00000001405e6633: lea      rcx, [rbp]
00000001405e6637: call     0x14127e710
00000001405e663c: mov      rcx, qword ptr [rsi + 0x6d8]
00000001405e6643: lea      rdx, [rbp]
00000001405e6647: mov      rax, qword ptr [rcx]
00000001405e664a: call     qword ptr [rax + 0x48]
00000001405e664d: mov      rcx, qword ptr [rsi + 0x6d8]
00000001405e6654: mov      rax, qword ptr [rcx]
00000001405e6657: call     qword ptr [rax + 0x68]
00000001405e665a: mov      rcx, qword ptr [rsi + 0x6d8]
00000001405e6661: mov      rax, qword ptr [rcx]
00000001405e6664: call     qword ptr [rax + 0x28]
00000001405e6667: mov      rax, qword ptr [rip + 0x9122eaa]
00000001405e666e: xor      edx, edx
00000001405e6670: mov      rcx, qword ptr [rsi + 0x6d8]
00000001405e6677: movzx    r8d, byte ptr [rax + 0x952]
00000001405e667f: mov      eax, dword ptr [rip + 0x15ae263]
00000001405e6685: mov      r9, qword ptr [rcx]
00000001405e6688: div      r8d
00000001405e668b: mov      edx, eax
00000001405e668d: call     qword ptr [r9 + 0x30]
00000001405e6691: mov      rcx, qword ptr [rsi + 0x6d8]
00000001405e6698: mov      rax, qword ptr [rcx]
00000001405e669b: call     qword ptr [rax + 0x38]
00000001405e669e: mov      rcx, qword ptr [rbp + 0x150]
00000001405e66a5: xor      rcx, rsp
00000001405e66a8: call     0x141441dc0
00000001405e66ad: add      rsp, 0x290
00000001405e66b4: pop      r13
00000001405e66b6: pop      rsi
00000001405e66b7: pop      rbp
00000001405e66b8: ret      
