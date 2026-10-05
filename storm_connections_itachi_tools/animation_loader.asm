000000014134a350: mov      qword ptr [rsp + 0x20], rbx
000000014134a355: push     rbp
000000014134a356: push     rsi
000000014134a357: push     rdi
000000014134a358: push     r12
000000014134a35a: push     r13
000000014134a35c: push     r14
000000014134a35e: push     r15
000000014134a360: lea      rbp, [rsp - 0x490]
000000014134a368: sub      rsp, 0x590
000000014134a36f: movaps   xmmword ptr [rsp + 0x580], xmm6
000000014134a377: mov      rax, qword ptr [rip + 0xd9c04a]
000000014134a37e: xor      rax, rsp
000000014134a381: mov      qword ptr [rbp + 0x470], rax
000000014134a388: movzx    r14d, r9w
000000014134a38c: mov      word ptr [rsp + 0x38], r9w
000000014134a392: mov      rsi, r8
000000014134a395: mov      qword ptr [rsp + 0x40], r8
000000014134a39a: mov      r15, rdx
000000014134a39d: mov      r13, rcx
000000014134a3a0: mov      qword ptr [rsp + 0x50], rcx
000000014134a3a5: mov      rcx, r8
000000014134a3a8: cmp      r9w, 0x65
000000014134a3ad: ja       0x14134a473
000000014134a3b3: mov      r8d, 0x10
000000014134a3b9: lea      rdx, [rbp - 0x68]
000000014134a3bd: call     0x14132d6f0
000000014134a3c2: cmp      eax, 0x10
000000014134a3c5: jb       0x14134b9cf
000000014134a3cb: mov      ecx, dword ptr [rbp - 0x68]
000000014134a3ce: call     0x1412e4220
000000014134a3d3: mov      r10d, eax
000000014134a3d6: movzx    ecx, word ptr [rbp - 0x60]
000000014134a3da: movzx    r9d, cx
000000014134a3de: shr      r9w, 8
000000014134a3e3: shl      cx, 8
000000014134a3e7: xor      r9w, cx
000000014134a3eb: movzx    ecx, word ptr [rbp - 0x5e]
000000014134a3ef: movzx    r8d, cx
000000014134a3f3: shr      r8w, 8
000000014134a3f8: shl      cx, 8
000000014134a3fc: xor      r8w, cx
000000014134a400: movzx    eax, word ptr [rbp - 0x5c]
000000014134a404: movzx    edx, ax
000000014134a407: shr      dx, 8
000000014134a40b: shl      ax, 8
000000014134a40f: xor      dx, ax
000000014134a412: movzx    eax, word ptr [rbp - 0x5a]
000000014134a416: movzx    ecx, ax
000000014134a419: shr      cx, 8
000000014134a41d: shl      ax, 8
000000014134a421: xor      cx, ax
000000014134a424: mov      dword ptr [rbp - 0x80], r10d
000000014134a428: mov      word ptr [rbp - 0x74], r9w
000000014134a42d: mov      word ptr [rbp - 0x72], r8w
000000014134a432: mov      word ptr [rbp - 0x70], dx
000000014134a436: mov      eax, 0x88888889
000000014134a43b: mul      dword ptr [rip + 0x84a4a7]
000000014134a441: shr      edx, 4
000000014134a444: mov      dword ptr [rbp - 0x7c], edx
000000014134a447: movzx    eax, word ptr [rbp - 0x64]
000000014134a44b: movzx    r8d, ax
000000014134a44f: shr      r8w, 8
000000014134a454: shl      ax, 8
000000014134a458: xor      r8w, ax
000000014134a45c: movzx    eax, word ptr [rbp - 0x62]
000000014134a460: movzx    edx, ax
000000014134a463: shr      dx, 8
000000014134a467: shl      ax, 8
000000014134a46b: xor      dx, ax
000000014134a46e: jmp      0x14134a520
000000014134a473: mov      r8d, 0x14
000000014134a479: lea      rdx, [rbp - 0x80]
000000014134a47d: call     0x14132d6f0
000000014134a482: cmp      eax, 0x14
000000014134a485: jb       0x14134b9cf
000000014134a48b: mov      ecx, dword ptr [rbp - 0x80]
000000014134a48e: call     0x1412e4220
000000014134a493: mov      dword ptr [rbp - 0x80], eax
000000014134a496: mov      ecx, dword ptr [rbp - 0x7c]
000000014134a499: call     0x1412e4220
000000014134a49e: mov      dword ptr [rbp - 0x7c], eax
000000014134a4a1: movzx    eax, word ptr [rbp - 0x78]
000000014134a4a5: movzx    r8d, ax
000000014134a4a9: shr      r8w, 8
000000014134a4ae: shl      ax, 8
000000014134a4b2: xor      r8w, ax
000000014134a4b6: movzx    eax, word ptr [rbp - 0x76]
000000014134a4ba: movzx    edx, ax
000000014134a4bd: shr      dx, 8
000000014134a4c1: shl      ax, 8
000000014134a4c5: xor      dx, ax
000000014134a4c8: movzx    eax, word ptr [rbp - 0x74]
000000014134a4cc: movzx    ecx, ax
000000014134a4cf: shr      cx, 8
000000014134a4d3: shl      ax, 8
000000014134a4d7: xor      cx, ax
000000014134a4da: mov      word ptr [rbp - 0x74], cx
000000014134a4de: movzx    eax, word ptr [rbp - 0x72]
000000014134a4e2: movzx    ecx, ax
000000014134a4e5: shr      cx, 8
000000014134a4e9: shl      ax, 8
000000014134a4ed: xor      cx, ax
000000014134a4f0: mov      word ptr [rbp - 0x72], cx
000000014134a4f4: movzx    eax, word ptr [rbp - 0x70]
000000014134a4f8: movzx    ecx, ax
000000014134a4fb: shr      cx, 8
000000014134a4ff: shl      ax, 8
000000014134a503: xor      cx, ax
000000014134a506: mov      word ptr [rbp - 0x70], cx
000000014134a50a: movzx    eax, word ptr [rbp - 0x6e]
000000014134a50e: movzx    ecx, ax
000000014134a511: shr      cx, 8
000000014134a515: shl      ax, 8
000000014134a519: xor      cx, ax
000000014134a51c: mov      r10d, dword ptr [rbp - 0x80]
000000014134a520: mov      word ptr [rbp - 0x78], r8w
000000014134a525: mov      word ptr [rbp - 0x6e], cx
000000014134a529: mov      word ptr [rbp - 0x76], dx
000000014134a52d: mov      word ptr [r13 + 0xd8], r8w
000000014134a535: mov      dword ptr [r13 + 0x88], r10d
000000014134a53c: and      dx, 1
000000014134a540: mov      word ptr [r13 + 0xda], dx
000000014134a548: xor      edx, edx
000000014134a54a: mov      rcx, r15
000000014134a54d: call     0x1412864d0
000000014134a552: mov      qword ptr [r13 + 0xe0], rax
000000014134a559: movzx    edi, word ptr [rbp - 0x78]
000000014134a55d: lea      rcx, [r13 + 0xb8]
000000014134a564: call     0x141273770
000000014134a569: mov      ecx, eax
000000014134a56b: call     0x141273960
000000014134a570: mov      rcx, qword ptr [r13 + 0xd0]
000000014134a577: xor      r12d, r12d
000000014134a57a: test     rcx, rcx
000000014134a57d: je       0x14134a58b
000000014134a57f: call     0x141272e20
000000014134a584: mov      qword ptr [r13 + 0xd0], r12
000000014134a58b: call     0x141273900
000000014134a590: mov      eax, 8
000000014134a595: lea      r12, [rax - 9]
000000014134a599: test     edi, edi
000000014134a59b: je       0x14134a5c6
000000014134a59d: mul      rdi
000000014134a5a0: cmovo    rax, r12
000000014134a5a4: lea      r9d, [r12 + 0x28]
000000014134a5a9: lea      r8, [rip + 0x433170]
000000014134a5b0: mov      rdx, qword ptr [r13 + 0xc0]
000000014134a5b7: mov      rcx, rax
000000014134a5ba: call     0x141272d70
000000014134a5bf: mov      qword ptr [r13 + 0xd0], rax
000000014134a5c6: xor      ebx, ebx
000000014134a5c8: mov      edx, ebx
000000014134a5ca: cmp      bx, word ptr [rbp - 0x78]
000000014134a5ce: jae      0x14134a5e7
000000014134a5d0: mov      ecx, edx
000000014134a5d2: mov      rax, qword ptr [r13 + 0xd0]
000000014134a5d9: mov      qword ptr [rax + rcx*8], rbx
000000014134a5dd: inc      edx
000000014134a5df: movzx    eax, word ptr [rbp - 0x78]
000000014134a5e3: cmp      edx, eax
000000014134a5e5: jb       0x14134a5d0
000000014134a5e7: movzx    eax, word ptr [rbp - 0x74]
000000014134a5eb: mov      edi, eax
000000014134a5ed: test     eax, eax
000000014134a5ef: je       0x14134a667
000000014134a5f1: mov      rcx, qword ptr [r13 + 0x98]
000000014134a5f8: mov      qword ptr [rsp + 0x30], rcx
000000014134a5fd: mov      eax, 0x58
000000014134a602: mul      rdi
000000014134a605: cmovo    rax, r12
000000014134a609: add      rax, 8
000000014134a60d: cmovb    rax, r12
000000014134a611: mov      r9d, 0x91
000000014134a617: lea      r8, [rip + 0x433102]
000000014134a61e: mov      rdx, rcx
000000014134a621: mov      rcx, rax
000000014134a624: call     0x141272d70
000000014134a629: mov      qword ptr [rsp + 0x48], rax
000000014134a62e: test     rax, rax
000000014134a631: je       0x14134a65e
000000014134a633: mov      qword ptr [rax], rdi
000000014134a636: lea      rbx, [rax + 8]
000000014134a63a: lea      rax, [rip - 0xd41]
000000014134a641: mov      qword ptr [rsp + 0x20], rax
000000014134a646: lea      r9, [rip - 0x104d]
000000014134a64d: mov      r8d, edi
000000014134a650: mov      edx, 0x58
000000014134a655: mov      rcx, rbx
000000014134a658: call     0x141441de0
000000014134a65d: nop      
000000014134a65e: movzx    eax, word ptr [rbp - 0x74]
000000014134a662: mov      rsi, qword ptr [rsp + 0x40]
000000014134a667: mov      qword ptr [r13 + 0xa8], rbx
000000014134a66e: mov      dword ptr [r13 + 0xb0], edi
000000014134a675: xor      edi, edi
000000014134a677: mov      r13d, edi
000000014134a67a: mov      dword ptr [rsp + 0x48], edi
000000014134a67e: cmp      di, ax
000000014134a681: jae      0x14134a89c
000000014134a687: nop      word ptr [rax + rax]
000000014134a690: mov      r8d, 8
000000014134a696: lea      rdx, [rsp + 0x30]
000000014134a69b: mov      rcx, rsi
000000014134a69e: call     0x14132d6f0
000000014134a6a3: cmp      eax, 8
000000014134a6a6: jb       0x14134b9cf
000000014134a6ac: mov      ecx, dword ptr [rsp + 0x30]
000000014134a6b0: call     0x1412e4220
000000014134a6b5: mov      r8d, eax
000000014134a6b8: mov      dword ptr [rsp + 0x30], eax
000000014134a6bc: movzx    ecx, word ptr [rsp + 0x34]
000000014134a6c1: movzx    edx, cx
000000014134a6c4: shr      dx, 8
000000014134a6c8: shl      cx, 8
000000014134a6cc: xor      dx, cx
000000014134a6cf: mov      word ptr [rsp + 0x34], dx
000000014134a6d4: movzx    ecx, word ptr [rsp + 0x36]
000000014134a6d9: movzx    edx, cx
000000014134a6dc: shr      dx, 8
000000014134a6e0: shl      cx, 8
000000014134a6e4: xor      dx, cx
000000014134a6e7: mov      word ptr [rsp + 0x36], dx
000000014134a6ec: movsxd   rax, r13d
000000014134a6ef: imul     rsi, rax, 0x58
000000014134a6f3: mov      rdi, qword ptr [rsp + 0x50]
000000014134a6f8: mov      rbx, qword ptr [rdi + 0xa8]
000000014134a6ff: mov      edx, r8d
000000014134a702: mov      rcx, r15
000000014134a705: cmp      r14w, 0x67
000000014134a70a: jbe      0x14134a713
000000014134a70c: call     0x1412864a0
000000014134a711: jmp      0x14134a718
000000014134a713: call     0x1412864d0
000000014134a718: mov      qword ptr [rbx + rsi], rax
000000014134a71c: movzx    ebx, word ptr [rsp + 0x34]
000000014134a721: mov      rdi, qword ptr [rdi + 0xa8]
000000014134a728: mov      r14d, 8
000000014134a72e: test     ebx, ebx
000000014134a730: jne      0x14134a738
000000014134a732: xor      ecx, ecx
000000014134a734: mov      eax, ecx
000000014134a736: jmp      0x14134a75e
000000014134a738: mov      rax, r14
000000014134a73b: mul      rbx
000000014134a73e: cmovo    rax, r12
000000014134a742: mov      r9d, 0x91
000000014134a748: lea      r8, [rip + 0x432fd1]
000000014134a74f: mov      rdx, qword ptr [rsi + rdi + 0x38]
000000014134a754: mov      rcx, rax
000000014134a757: call     0x141272d70
000000014134a75c: xor      ecx, ecx
000000014134a75e: mov      qword ptr [rsi + rdi + 0x48], rax
000000014134a763: mov      dword ptr [rsi + rdi + 0x50], ebx
000000014134a767: movzx    edi, word ptr [rsp + 0x36]
000000014134a76c: mov      rax, qword ptr [rsp + 0x50]
000000014134a771: mov      rbx, qword ptr [rax + 0xa8]
000000014134a778: test     edi, edi
000000014134a77a: jne      0x14134a781
000000014134a77c: mov      rax, rcx
000000014134a77f: jmp      0x14134a7a5
000000014134a781: mov      rax, r14
000000014134a784: mul      rdi
000000014134a787: cmovo    rax, r12
000000014134a78b: mov      r9d, 0x91
000000014134a791: lea      r8, [rip + 0x432f88]
000000014134a798: mov      rdx, qword ptr [rsi + rbx + 0x10]
000000014134a79d: mov      rcx, rax
000000014134a7a0: call     0x141272d70
000000014134a7a5: mov      qword ptr [rsi + rbx + 0x20], rax
000000014134a7aa: mov      dword ptr [rsi + rbx + 0x28], edi
000000014134a7ae: xor      edi, edi
000000014134a7b0: mov      r14d, edi
000000014134a7b3: cmp      di, word ptr [rsp + 0x34]
000000014134a7b8: jae      0x14134a810
000000014134a7ba: mov      r12, qword ptr [rsp + 0x40]
000000014134a7bf: mov      r13, qword ptr [rsp + 0x50]
000000014134a7c4: mov      rcx, r12
000000014134a7c7: call     0x14132d8f0
000000014134a7cc: mov      edx, eax
000000014134a7ce: mov      ecx, 1
000000014134a7d3: call     0x1412e4250
000000014134a7d8: mov      rcx, qword ptr [r13 + 0xa8]
000000014134a7df: movsxd   rdi, r14d
000000014134a7e2: mov      rbx, qword ptr [rsi + rcx + 0x48]
000000014134a7e7: mov      edx, eax
000000014134a7e9: mov      rcx, r15
000000014134a7ec: call     0x1412864a0
000000014134a7f1: mov      qword ptr [rbx + rdi*8], rax
000000014134a7f5: inc      r14d
000000014134a7f8: movzx    eax, word ptr [rsp + 0x34]
000000014134a7fd: cmp      r14d, eax
000000014134a800: jb       0x14134a7c4
000000014134a802: mov      r12, 0xffffffffffffffff
000000014134a809: mov      r13d, dword ptr [rsp + 0x48]
000000014134a80e: xor      edi, edi
000000014134a810: mov      r14d, edi
000000014134a813: cmp      di, word ptr [rsp + 0x36]
000000014134a818: jae      0x14134a87c
000000014134a81a: mov      r12, qword ptr [rsp + 0x40]
000000014134a81f: mov      r13, qword ptr [rsp + 0x50]
000000014134a824: nop      dword ptr [rax]
000000014134a828: nop      dword ptr [rax + rax]
000000014134a830: mov      rax, qword ptr [r13 + 0xa8]
000000014134a837: movsxd   rdi, r14d
000000014134a83a: mov      rbx, qword ptr [rsi + rax + 0x20]
000000014134a83f: mov      rcx, r12
000000014134a842: call     0x14132d8f0
000000014134a847: mov      edx, eax
000000014134a849: mov      ecx, 1
000000014134a84e: call     0x1412e4250
000000014134a853: mov      edx, eax
000000014134a855: mov      rcx, r15
000000014134a858: call     0x1412864a0
000000014134a85d: mov      qword ptr [rbx + rdi*8], rax
000000014134a861: inc      r14d
000000014134a864: movzx    eax, word ptr [rsp + 0x36]
000000014134a869: cmp      r14d, eax
000000014134a86c: jb       0x14134a830
000000014134a86e: mov      r12, 0xffffffffffffffff
000000014134a875: mov      r13d, dword ptr [rsp + 0x48]
000000014134a87a: xor      edi, edi
000000014134a87c: inc      r13d
000000014134a87f: mov      dword ptr [rsp + 0x48], r13d
000000014134a884: movzx    eax, word ptr [rbp - 0x74]
000000014134a888: cmp      r13d, eax
000000014134a88b: movzx    r14d, word ptr [rsp + 0x38]
000000014134a891: mov      rsi, qword ptr [rsp + 0x40]
000000014134a896: jb       0x14134a690
000000014134a89c: movzx    edx, word ptr [rbp - 0x72]
000000014134a8a0: mov      r14, qword ptr [rsp + 0x50]
000000014134a8a5: lea      rcx, [r14 + 0x10]
000000014134a8a9: call     0x1412e1910
000000014134a8ae: mov      esi, edi
000000014134a8b0: mov      r13, qword ptr [rsp + 0x40]
000000014134a8b5: cmp      di, word ptr [rbp - 0x72]
000000014134a8b9: jae      0x14134a8f5
000000014134a8bb: nop      dword ptr [rax + rax]
000000014134a8c0: movsxd   rdi, esi
000000014134a8c3: mov      rbx, qword ptr [r14 + 0x28]
000000014134a8c7: mov      rcx, r13
000000014134a8ca: call     0x14132d8f0
000000014134a8cf: mov      edx, eax
000000014134a8d1: mov      ecx, 1
000000014134a8d6: call     0x1412e4250
000000014134a8db: mov      edx, eax
000000014134a8dd: mov      rcx, r15
000000014134a8e0: call     0x1412864d0
000000014134a8e5: mov      qword ptr [rbx + rdi*8], rax
000000014134a8e9: inc      esi
000000014134a8eb: movzx    eax, word ptr [rbp - 0x72]
000000014134a8ef: cmp      esi, eax
000000014134a8f1: jb       0x14134a8c0
000000014134a8f3: xor      edi, edi
000000014134a8f5: movzx    edx, word ptr [rbp - 0x70]
000000014134a8f9: lea      rcx, [r14 + 0x38]
000000014134a8fd: call     0x1412e1910
000000014134a902: mov      esi, edi
000000014134a904: cmp      di, word ptr [rbp - 0x70]
000000014134a908: jae      0x14134a945
000000014134a90a: nop      word ptr [rax + rax]
000000014134a910: movsxd   rdi, esi
000000014134a913: mov      rbx, qword ptr [r14 + 0x50]
000000014134a917: mov      rcx, r13
000000014134a91a: call     0x14132d8f0
000000014134a91f: mov      edx, eax
000000014134a921: mov      ecx, 1
000000014134a926: call     0x1412e4250
000000014134a92b: mov      edx, eax
000000014134a92d: mov      rcx, r15
000000014134a930: call     0x1412864d0
000000014134a935: mov      qword ptr [rbx + rdi*8], rax
000000014134a939: inc      esi
000000014134a93b: movzx    eax, word ptr [rbp - 0x70]
000000014134a93f: cmp      esi, eax
000000014134a941: jb       0x14134a910
000000014134a943: xor      edi, edi
000000014134a945: movzx    eax, word ptr [rbp - 0x6e]
000000014134a949: mov      ebx, eax
000000014134a94b: test     eax, eax
000000014134a94d: jne      0x14134a954
000000014134a94f: mov      rdx, rdi
000000014134a952: jmp      0x14134a980
000000014134a954: mov      eax, 8
000000014134a959: mul      rbx
000000014134a95c: cmovo    rax, r12
000000014134a960: mov      r9d, 0x91
000000014134a966: lea      r8, [rip + 0x432db3]
000000014134a96d: mov      rdx, qword ptr [r14 + 0x68]
000000014134a971: mov      rcx, rax
000000014134a974: call     0x141272d70
000000014134a979: mov      rdx, rax
000000014134a97c: movzx    eax, word ptr [rbp - 0x6e]
000000014134a980: mov      qword ptr [r14 + 0x78], rdx
000000014134a984: mov      dword ptr [r14 + 0x80], ebx
000000014134a98b: movzx    r8d, ax
000000014134a98f: shl      r8d, 3
000000014134a993: mov      rcx, r13
000000014134a996: call     0x14132d6f0
000000014134a99b: mov      ecx, eax
000000014134a99d: movzx    r8d, word ptr [rbp - 0x6e]
000000014134a9a2: lea      rax, [r8*8]
000000014134a9aa: cmp      rcx, rax
000000014134a9ad: jb       0x14134b9cf
000000014134a9b3: mov      rdx, qword ptr [r14 + 0x78]
000000014134a9b7: lea      r8, [rdx + r8*8]
000000014134a9bb: cmp      rdx, r8
000000014134a9be: jae      0x14134aa1f
000000014134a9c0: movzx    eax, word ptr [rdx]
000000014134a9c3: movzx    ecx, ax
000000014134a9c6: shr      cx, 8
000000014134a9ca: shl      ax, 8
000000014134a9ce: xor      cx, ax
000000014134a9d1: mov      word ptr [rdx], cx
000000014134a9d4: movzx    eax, word ptr [rdx + 2]
000000014134a9d8: movzx    ecx, ax
000000014134a9db: shr      cx, 8
000000014134a9df: shl      ax, 8
000000014134a9e3: xor      cx, ax
000000014134a9e6: mov      word ptr [rdx + 2], cx
000000014134a9ea: movzx    eax, word ptr [rdx + 4]
000000014134a9ee: movzx    ecx, ax
000000014134a9f1: shr      cx, 8
000000014134a9f5: shl      ax, 8
000000014134a9f9: xor      cx, ax
000000014134a9fc: mov      word ptr [rdx + 4], cx
000000014134aa00: movzx    eax, word ptr [rdx + 6]
000000014134aa04: movzx    ecx, ax
000000014134aa07: shr      cx, 8
000000014134aa0b: shl      ax, 8
000000014134aa0f: xor      cx, ax
000000014134aa12: mov      word ptr [rdx + 6], cx
000000014134aa16: add      rdx, 8
000000014134aa1a: cmp      rdx, r8
000000014134aa1d: jb       0x14134a9c0
000000014134aa1f: lea      rcx, [rbp - 0x18]
000000014134aa23: call     0x141273620
000000014134aa28: lea      rsi, [rip + 0x416c29]
000000014134aa2f: mov      qword ptr [rbp - 0x18], rsi
000000014134aa33: mov      qword ptr [rbp + 0x18], 0xf
000000014134aa3b: mov      qword ptr [rbp + 0x10], 0xa
000000014134aa43: movsd    xmm0, qword ptr [rip + 0x529fdd]
000000014134aa4b: movsd    qword ptr [rbp], xmm0
000000014134aa50: movzx    eax, word ptr [rip + 0x529fd9]
000000014134aa57: mov      word ptr [rbp + 8], ax
000000014134aa5b: mov      byte ptr [rbp + 0xa], 0
000000014134aa5f: mov      rbx, qword ptr [r15 + 0x1d0]
000000014134aa66: lea      rcx, [rbp - 0x50]
000000014134aa6a: call     0x141273620
000000014134aa6f: mov      qword ptr [rbp - 0x50], rsi
000000014134aa73: mov      qword ptr [rbp - 0x38], rdi
000000014134aa77: mov      qword ptr [rbp - 0x28], rdi
000000014134aa7b: mov      qword ptr [rbp - 0x20], 0xf
000000014134aa83: mov      byte ptr [rbp - 0x38], 0
000000014134aa87: mov      r8, r12
000000014134aa8a: nop      word ptr [rax + rax]
000000014134aa90: inc      r8
000000014134aa93: cmp      byte ptr [rbx + r8], 0
000000014134aa98: jne      0x14134aa90
000000014134aa9a: mov      rdx, rbx
000000014134aa9d: lea      rcx, [rbp - 0x50]
000000014134aaa1: call     0x1400b2580
000000014134aaa6: nop      
000000014134aaa7: lea      rbx, [rbp - 0x38]
000000014134aaab: cmp      qword ptr [rbp - 0x20], 0x10
000000014134aab0: cmovae   rbx, qword ptr [rbp - 0x38]
000000014134aab5: mov      rdi, qword ptr [rbp - 0x28]
000000014134aab9: test     rdi, rdi
000000014134aabc: je       0x14134aaf8
000000014134aabe: xor      edx, edx
000000014134aac0: mov      r8d, 0x100
000000014134aac6: lea      rcx, [rbp + 0x60]
000000014134aaca: call     0x141442fc4
000000014134aacf: mov      byte ptr [rbp + 0x9a], 1
000000014134aad6: lea      rdx, [rdi + rbx]
000000014134aada: mov      rcx, rbx
000000014134aadd: cmp      rbx, rdx
000000014134aae0: jae      0x14134aaf8
000000014134aae2: movzx    eax, byte ptr [rcx]
000000014134aae5: cmp      byte ptr [rbp + rax + 0x60], 0
000000014134aaea: jne      0x14134ad32
000000014134aaf0: inc      rcx
000000014134aaf3: cmp      rcx, rdx
000000014134aaf6: jb       0x14134aae2
000000014134aaf8: mov      rcx, r12
000000014134aafb: lea      eax, [rcx + 1]
000000014134aafe: mov      rbx, qword ptr [rbp + 0x10]
000000014134ab02: movsxd   rdi, eax
000000014134ab05: lea      rcx, [rbp - 0x50]
000000014134ab09: call     0x141273770
000000014134ab0e: mov      edx, eax
000000014134ab10: lea      rcx, [rbp - 0x68]
000000014134ab14: call     0x1412735d0
000000014134ab19: mov      qword ptr [rbp - 0x68], rsi
000000014134ab1d: lea      rcx, [rbp - 0x68]
000000014134ab21: call     0x141273770
000000014134ab26: mov      edx, eax
000000014134ab28: lea      rcx, [rbp + 0x20]
000000014134ab2c: call     0x1412735d0
000000014134ab31: mov      qword ptr [rbp + 0x20], rsi
000000014134ab35: xor      eax, eax
000000014134ab37: mov      qword ptr [rbp + 0x38], rax
000000014134ab3b: mov      qword ptr [rbp + 0x48], rax
000000014134ab3f: mov      qword ptr [rbp + 0x50], 0xf
000000014134ab47: mov      byte ptr [rbp + 0x38], al
000000014134ab4a: mov      rax, qword ptr [rbp - 0x28]
000000014134ab4e: cmp      rax, rdi
000000014134ab51: jb       0x14134ba08
000000014134ab57: sub      rax, rdi
000000014134ab5a: cmp      rax, rbx
000000014134ab5d: cmovb    rbx, rax
000000014134ab61: lea      rdx, [rbp - 0x38]
000000014134ab65: cmp      qword ptr [rbp - 0x20], 0x10
000000014134ab6a: cmovae   rdx, qword ptr [rbp - 0x38]
000000014134ab6f: add      rdx, rdi
000000014134ab72: mov      r8, rbx
000000014134ab75: lea      rcx, [rbp + 0x20]
000000014134ab79: call     0x1400b2580
000000014134ab7e: nop      
000000014134ab7f: lea      rsi, [rip + 0x416802]
000000014134ab86: mov      qword ptr [rbp - 0x68], rsi
000000014134ab8a: lea      rdx, [rbp + 0x38]
000000014134ab8e: cmp      qword ptr [rbp + 0x50], 0x10
000000014134ab93: cmovae   rdx, qword ptr [rbp + 0x38]
000000014134ab98: nop      dword ptr [rax + rax]
000000014134aba0: inc      r12
000000014134aba3: cmp      byte ptr [rdx + r12], 0
000000014134aba8: jne      0x14134aba0
000000014134abaa: mov      r8, r12
000000014134abad: lea      rcx, [rbp - 0x50]
000000014134abb1: call     0x1400b2580
000000014134abb6: nop      
000000014134abb7: cmp      qword ptr [rbp + 0x50], 0x10
000000014134abbc: jb       0x14134abe0
000000014134abbe: mov      rbx, qword ptr [rbp + 0x38]
000000014134abc2: lea      rcx, [rbp + 0x20]
000000014134abc6: call     0x141273770
000000014134abcb: mov      ecx, eax
000000014134abcd: call     0x141273960
000000014134abd2: mov      rcx, rbx
000000014134abd5: call     0x1412732b0
000000014134abda: call     0x141273900
000000014134abdf: nop      
000000014134abe0: xor      r12d, r12d
000000014134abe3: mov      edi, r12d
000000014134abe6: mov      dword ptr [rsp + 0x48], r12d
000000014134abeb: lea      rcx, [rbp - 0x38]
000000014134abef: cmp      qword ptr [rbp - 0x20], 0x10
000000014134abf4: cmovae   rcx, qword ptr [rbp - 0x38]
000000014134abf9: add      rcx, qword ptr [rbp - 0x28]
000000014134abfd: lea      r9, [rbp]
000000014134ac01: cmp      qword ptr [rbp + 0x18], 0x10
000000014134ac06: cmovae   r9, qword ptr [rbp]
000000014134ac0b: lea      r8, [rbp]
000000014134ac0f: cmovae   r8, qword ptr [rbp]
000000014134ac14: mov      r10, qword ptr [rbp + 0x10]
000000014134ac18: lea      rax, [r8 + r10]
000000014134ac1c: mov      rdx, rax
000000014134ac1f: sub      rdx, r9
000000014134ac22: movabs   r11, 0x8000000000000000
000000014134ac2c: cmp      rdx, r11
000000014134ac2f: je       0x14134ba01
000000014134ac35: cmp      rax, r9
000000014134ac38: je       0x14134ac56
000000014134ac3a: sub      rcx, r8
000000014134ac3d: sub      rcx, r10
000000014134ac40: lea      r8, [rax - 1]
000000014134ac44: movzx    edx, byte ptr [rcx + rax - 1]
000000014134ac49: cmp      byte ptr [r8], dl
000000014134ac4c: jne      0x14134aca4
000000014134ac4e: mov      rax, r8
000000014134ac51: cmp      r8, r9
000000014134ac54: jne      0x14134ac40
000000014134ac56: mov      rcx, r14
000000014134ac59: call     0x1412a23e0
000000014134ac5e: mov      rbx, rax
000000014134ac61: lea      rdx, [rip + 0x854a18]
000000014134ac68: mov      rcx, rax
000000014134ac6b: call     0x141299c70
000000014134ac70: test     eax, eax
000000014134ac72: jne      0x14134aca4
000000014134ac74: lea      rdx, [rip + 0x854a15]
000000014134ac7b: mov      rcx, rbx
000000014134ac7e: call     0x141299c70
000000014134ac83: test     eax, eax
000000014134ac85: jne      0x14134aca4
000000014134ac87: lea      rdx, [rip + 0x854a12]
000000014134ac8e: mov      rcx, rbx
000000014134ac91: call     0x141299c70
000000014134ac96: test     eax, eax
000000014134ac98: mov      eax, 1
000000014134ac9d: cmove    edi, eax
000000014134aca0: mov      dword ptr [rsp + 0x48], edi
000000014134aca4: mov      word ptr [rsp + 0x38], r12w
000000014134acaa: cmp      r12w, word ptr [rbp - 0x78]
000000014134acaf: jae      0x14134b96a
000000014134acb5: lea      r15, [rip - 0x134acbc]
000000014134acbc: nop      dword ptr [rax]
000000014134acc0: mov      r8d, 8
000000014134acc6: lea      rdx, [rsp + 0x30]
000000014134accb: mov      rcx, r13
000000014134acce: call     0x14132d6f0
000000014134acd3: cmp      eax, 8
000000014134acd6: jb       0x14134b963
000000014134acdc: mov      ecx, dword ptr [rsp + 0x30]
000000014134ace0: call     0x1412e4220
000000014134ace5: mov      dword ptr [rsp + 0x30], eax
000000014134ace9: movzx    eax, word ptr [rsp + 0x36]
000000014134acee: movzx    edx, ax
000000014134acf1: shr      dx, 8
000000014134acf5: shl      ax, 8
000000014134acf9: xor      dx, ax
000000014134acfc: mov      word ptr [rsp + 0x36], dx
000000014134ad01: movzx    eax, word ptr [rsp + 0x34]
000000014134ad06: movzx    ecx, ax
000000014134ad09: shr      cx, 8
000000014134ad0d: shl      ax, 8
000000014134ad11: xor      cx, ax
000000014134ad14: movzx    eax, cx
000000014134ad17: mov      word ptr [rsp + 0x34], ax
000000014134ad1c: dec      eax
000000014134ad1e: cmp      eax, 8
000000014134ad21: ja       0x14134ad6b
000000014134ad23: cdqe     
000000014134ad25: mov      ecx, dword ptr [r15 + rax*4 + 0x134ba10]
000000014134ad2d: add      rcx, r15
000000014134ad30: jmp      rcx
000000014134ad32: sub      rcx, rbx
000000014134ad35: jmp      0x14134aafb
000000014134ad3a: mov      esi, 0x110
000000014134ad3f: jmp      0x14134ad6e
000000014134ad41: mov      esi, 0x60
000000014134ad46: jmp      0x14134ad6e
000000014134ad48: mov      esi, 0x18
000000014134ad4d: jmp      0x14134ad6e
000000014134ad4f: mov      esi, 0x370
000000014134ad54: jmp      0x14134ad6e
000000014134ad56: mov      esi, 0x90
000000014134ad5b: jmp      0x14134ad6e
000000014134ad5d: mov      esi, 0x48
000000014134ad62: jmp      0x14134ad6e
000000014134ad64: mov      esi, 0x28
000000014134ad69: jmp      0x14134ad6e
000000014134ad6b: mov      esi, r12d
000000014134ad6e: mov      ebx, r12d
000000014134ad71: movzx    edi, r12w
000000014134ad75: cmp      r12w, dx
000000014134ad79: jae      0x14134af1c
000000014134ad7f: nop      
000000014134ad80: mov      r8d, 8
000000014134ad86: lea      rdx, [rsp + 0x40]
000000014134ad8b: mov      rcx, r13
000000014134ad8e: call     0x14132d6f0
000000014134ad93: cmp      eax, 8
000000014134ad96: jb       0x14134b963
000000014134ad9c: movzx    eax, word ptr [rsp + 0x40]
000000014134ada1: movzx    r9d, ax
000000014134ada5: shr      r9w, 8
000000014134adaa: shl      ax, 8
000000014134adae: xor      r9w, ax
000000014134adb2: mov      word ptr [rsp + 0x40], r9w
000000014134adb8: movzx    eax, word ptr [rsp + 0x42]
000000014134adbd: movzx    ecx, ax
000000014134adc0: shr      cx, 8
000000014134adc4: shl      ax, 8
000000014134adc8: xor      cx, ax
000000014134adcb: movzx    r10d, cx
000000014134adcf: mov      word ptr [rsp + 0x42], r10w
000000014134add5: movzx    eax, word ptr [rsp + 0x44]
000000014134adda: movzx    r8d, ax
000000014134adde: shr      r8w, 8
000000014134ade3: shl      ax, 8
000000014134ade7: xor      r8w, ax
000000014134adeb: mov      word ptr [rsp + 0x44], r8w
000000014134adf1: movzx    eax, word ptr [rsp + 0x46]
000000014134adf6: movzx    ecx, ax
000000014134adf9: shr      cx, 8
000000014134adfd: shl      ax, 8
000000014134ae01: xor      cx, ax
000000014134ae04: mov      word ptr [rsp + 0x46], cx
000000014134ae09: mov      edx, r12d
000000014134ae0c: lea      eax, [r10 - 1]
000000014134ae10: cmp      eax, 0x1c
000000014134ae13: ja       0x14134aedc
000000014134ae19: cdqe     
000000014134ae1b: mov      ecx, dword ptr [r15 + rax*4 + 0x134ba34]
000000014134ae23: add      rcx, r15
000000014134ae26: jmp      rcx
000000014134ae28: movzx    eax, r8w
000000014134ae2c: lea      edx, [rax + rax*2]
000000014134ae2f: jmp      0x14134aedc
000000014134ae34: movzx    edx, r8w
000000014134ae38: jmp      0x14134aed9
000000014134ae3d: movzx    edx, r8w
000000014134ae41: shl      edx, 4
000000014134ae44: jmp      0x14134aedc
000000014134ae49: movzx    eax, r8w
000000014134ae4d: lea      edx, [rax + rax*4]
000000014134ae50: shl      edx, 3
000000014134ae53: jmp      0x14134aedc
000000014134ae58: movzx    eax, r8w
000000014134ae5c: lea      ecx, [rax + rax*4]
000000014134ae5f: lea      edx, [rcx*4 + 0x40]
000000014134ae66: jmp      0x14134aedc
000000014134ae68: movzx    eax, r8w
000000014134ae6c: lea      edx, [rax + rax*4]
000000014134ae6f: jmp      0x14134aed9
000000014134ae71: movzx    edx, r8w
000000014134ae75: shl      edx, 3
000000014134ae78: jmp      0x14134aedc
000000014134ae7a: movzx    edx, r8w
000000014134ae7e: shl      edx, 3
000000014134ae81: add      ebx, 4
000000014134ae84: jmp      0x14134aedc
000000014134ae86: movzx    eax, r8w
000000014134ae8a: lea      edx, [rax + rax*2]
000000014134ae8d: add      edx, edx
000000014134ae8f: add      ebx, 4
000000014134ae92: jmp      0x14134aedc
000000014134ae94: movzx    edx, r8w
000000014134ae98: add      edx, edx
000000014134ae9a: add      ebx, 4
000000014134ae9d: jmp      0x14134aedc
000000014134ae9f: movzx    eax, r8w
000000014134aea3: lea      edx, [rax + rax*2]
000000014134aea6: add      ebx, 4
000000014134aea9: jmp      0x14134aedc
000000014134aeab: movzx    eax, r8w
000000014134aeaf: lea      edx, [rax + rax*2]
000000014134aeb2: shl      edx, 2
000000014134aeb5: add      ebx, 4
000000014134aeb8: jmp      0x14134aedc
000000014134aeba: movzx    edx, r8w
000000014134aebe: shl      edx, 2
000000014134aec1: add      ebx, 4
000000014134aec4: jmp      0x14134aedc
000000014134aec6: movzx    edx, r8w
000000014134aeca: shl      edx, 4
000000014134aecd: add      ebx, 4
000000014134aed0: jmp      0x14134aedc
000000014134aed2: movzx    eax, r8w
000000014134aed6: lea      edx, [rax + rax*2]
000000014134aed9: shl      edx, 2
000000014134aedc: add      edx, 3
000000014134aedf: and      edx, 0xfffffffc
000000014134aee2: movzx    ecx, di
000000014134aee5: shl      rcx, 5
000000014134aee9: mov      byte ptr [rbp + rcx + 0x78], 0
000000014134aeee: mov      word ptr [rbp + rcx + 0x68], r8w
000000014134aef4: mov      qword ptr [rbp + rcx + 0x70], r12
000000014134aef9: mov      word ptr [rbp + rcx + 0x66], dx
000000014134aefe: mov      dword ptr [rbp + rcx + 0x60], r10d
000000014134af03: mov      word ptr [rbp + rcx + 0x64], r9w
000000014134af09: add      ebx, edx
000000014134af0b: inc      di
000000014134af0e: movzx    edx, word ptr [rsp + 0x36]
000000014134af13: cmp      di, dx
000000014134af16: jb       0x14134ad80
000000014134af1c: mov      word ptr [rbp + 0x460], dx
000000014134af23: lea      ecx, [rbx + rsi]
000000014134af26: mov      r8d, 0x2b8
000000014134af2c: lea      rdx, [rip + 0x8546fd]
000000014134af33: call     0x1412734a0
000000014134af38: mov      r12, rax
000000014134af3b: add      rsi, rax
000000014134af3e: xor      ebx, ebx
000000014134af40: movzx    r15d, bx
000000014134af44: cmp      bx, word ptr [rsp + 0x36]
000000014134af49: jae      0x14134b6dd
000000014134af4f: nop      
000000014134af50: movzx    r14d, r15w
000000014134af54: shl      r14, 5
000000014134af58: mov      qword ptr [rbp + r14 + 0x70], rsi
000000014134af5d: mov      eax, dword ptr [rbp + r14 + 0x60]
000000014134af62: add      eax, -0xf
000000014134af65: cmp      eax, 0xe
000000014134af68: ja       0x14134af88
000000014134af6a: cdqe     
000000014134af6c: lea      rdx, [rip - 0x134af73]
000000014134af73: mov      ecx, dword ptr [rdx + rax*4 + 0x134baa8]
000000014134af7a: add      rcx, rdx
000000014134af7d: jmp      rcx
000000014134af7f: mov      eax, dword ptr [rbp - 0x7c]
000000014134af82: mov      dword ptr [rsi], eax
000000014134af84: add      rsi, 4
000000014134af88: movzx    r8d, word ptr [rbp + r14 + 0x66]
000000014134af8e: mov      rdx, rsi
000000014134af91: mov      rcx, r13
000000014134af94: call     0x14132d6f0
000000014134af99: movzx    ecx, word ptr [rbp + r14 + 0x66]
000000014134af9f: cmp      eax, ecx
000000014134afa1: jb       0x14134b958
000000014134afa7: movzx    edi, word ptr [rbp + r14 + 0x68]
000000014134afad: mov      eax, dword ptr [rbp + r14 + 0x60]
000000014134afb2: dec      eax
000000014134afb4: cmp      eax, 0x1c
000000014134afb7: ja       0x14134b6bf
000000014134afbd: cdqe     
000000014134afbf: lea      rdx, [rip - 0x134afc6]
000000014134afc6: mov      ecx, dword ptr [rdx + rax*4 + 0x134bae4]
000000014134afcd: add      rcx, rdx
000000014134afd0: jmp      rcx
000000014134afd2: mov      rdx, rsi
000000014134afd5: lea      r8, [rsi + rdi*4]
000000014134afd9: cmp      rsi, r8
000000014134afdc: jae      0x14134b6bf
000000014134afe2: movzx    eax, word ptr [rdx]
000000014134afe5: movzx    ecx, ax
000000014134afe8: shr      cx, 8
000000014134afec: shl      ax, 8
000000014134aff0: xor      cx, ax
000000014134aff3: mov      word ptr [rdx], cx
000000014134aff6: add      rdx, 4
000000014134affa: cmp      rdx, r8
000000014134affd: jb       0x14134afe2
000000014134afff: jmp      0x14134b6bf
000000014134b004: shl      rdi, 4
000000014134b008: add      rdi, rsi
000000014134b00b: cmp      rsi, rdi
000000014134b00e: jae      0x14134b6bf
000000014134b014: lea      rbx, [rsi + 8]
000000014134b018: mov      ecx, dword ptr [rbx - 8]
000000014134b01b: call     0x1412e4220
000000014134b020: mov      dword ptr [rbx - 8], eax
000000014134b023: mov      ecx, dword ptr [rbx - 4]
000000014134b026: call     0x1412e4220
000000014134b02b: mov      dword ptr [rbx - 4], eax
000000014134b02e: mov      ecx, dword ptr [rbx]
000000014134b030: call     0x1412e4220
000000014134b035: mov      dword ptr [rbx], eax
000000014134b037: mov      ecx, dword ptr [rbx + 4]
000000014134b03a: call     0x1412e4220
000000014134b03f: mov      dword ptr [rbx + 4], eax
000000014134b042: lea      rbx, [rbx + 0x10]
000000014134b046: lea      rax, [rbx - 8]
000000014134b04a: cmp      rax, rdi
000000014134b04d: jb       0x14134b018
000000014134b04f: jmp      0x14134b6bd
000000014134b054: lea      rax, [rdi + rdi*2]
000000014134b058: lea      rdi, [rsi + rax*4]
000000014134b05c: cmp      rsi, rdi
000000014134b05f: jae      0x14134b6bf
000000014134b065: lea      rbx, [rsi + 8]
000000014134b069: nop      dword ptr [rax]
000000014134b070: mov      ecx, dword ptr [rbx - 8]
000000014134b073: call     0x1412e4220
000000014134b078: mov      dword ptr [rbx - 8], eax
000000014134b07b: mov      ecx, dword ptr [rbx - 4]
000000014134b07e: call     0x1412e4220
000000014134b083: mov      dword ptr [rbx - 4], eax
000000014134b086: mov      ecx, dword ptr [rbx]
000000014134b088: call     0x1412e4220
000000014134b08d: mov      dword ptr [rbx], eax
000000014134b08f: lea      rbx, [rbx + 0xc]
000000014134b093: lea      rax, [rbx - 8]
000000014134b097: cmp      rax, rdi
000000014134b09a: jb       0x14134b070
000000014134b09c: jmp      0x14134b6bd
000000014134b0a1: shl      rdi, 4
000000014134b0a5: add      rdi, rsi
000000014134b0a8: cmp      rsi, rdi
000000014134b0ab: jae      0x14134b6bf
000000014134b0b1: lea      rbx, [rsi + 8]
000000014134b0b5: mov      ecx, dword ptr [rbx - 8]
000000014134b0b8: call     0x1412e4220
000000014134b0bd: mov      dword ptr [rbx - 8], eax
000000014134b0c0: mov      ecx, dword ptr [rbx - 4]
000000014134b0c3: call     0x1412e4220
000000014134b0c8: mov      dword ptr [rbx - 4], eax
000000014134b0cb: mov      ecx, dword ptr [rbx]
000000014134b0cd: call     0x1412e4220
000000014134b0d2: mov      dword ptr [rbx], eax
000000014134b0d4: mov      ecx, dword ptr [rbx + 4]
000000014134b0d7: call     0x1412e4220
000000014134b0dc: mov      dword ptr [rbx + 4], eax
000000014134b0df: lea      rbx, [rbx + 0x10]
000000014134b0e3: lea      rax, [rbx - 8]
000000014134b0e7: cmp      rax, rdi
000000014134b0ea: jb       0x14134b0b5
000000014134b0ec: jmp      0x14134b6bd
000000014134b0f1: lea      rax, [rdi + rdi*4]
000000014134b0f5: lea      rdi, [rsi + rax*8]
000000014134b0f9: cmp      rsi, rdi
000000014134b0fc: jae      0x14134b6bf
000000014134b102: lea      rbx, [rsi + 8]
000000014134b106: mov      ecx, dword ptr [rbx - 8]
000000014134b109: call     0x1412e4220
000000014134b10e: mov      dword ptr [rbx - 8], eax
000000014134b111: mov      ecx, dword ptr [rbx - 4]
000000014134b114: call     0x1412e4220
000000014134b119: mov      dword ptr [rbx - 4], eax
000000014134b11c: mov      ecx, dword ptr [rbx]
000000014134b11e: call     0x1412e4220
000000014134b123: mov      dword ptr [rbx], eax
000000014134b125: mov      ecx, dword ptr [rbx + 4]
000000014134b128: call     0x1412e4220
000000014134b12d: mov      dword ptr [rbx + 4], eax
000000014134b130: mov      ecx, dword ptr [rbx + 8]
000000014134b133: call     0x1412e4220
000000014134b138: mov      dword ptr [rbx + 8], eax
000000014134b13b: mov      ecx, dword ptr [rbx + 0xc]
000000014134b13e: call     0x1412e4220
000000014134b143: mov      dword ptr [rbx + 0xc], eax
000000014134b146: mov      ecx, dword ptr [rbx + 0x10]
000000014134b149: call     0x1412e4220
000000014134b14e: mov      dword ptr [rbx + 0x10], eax
000000014134b151: mov      ecx, dword ptr [rbx + 0x14]
000000014134b154: call     0x1412e4220
000000014134b159: mov      dword ptr [rbx + 0x14], eax
000000014134b15c: mov      ecx, dword ptr [rbx + 0x18]
000000014134b15f: call     0x1412e4220
000000014134b164: mov      dword ptr [rbx + 0x18], eax
000000014134b167: mov      ecx, dword ptr [rbx + 0x1c]
000000014134b16a: call     0x1412e4220
000000014134b16f: mov      dword ptr [rbx + 0x1c], eax
000000014134b172: lea      rbx, [rbx + 0x28]
000000014134b176: lea      rax, [rbx - 8]
000000014134b17a: cmp      rax, rdi
000000014134b17d: jb       0x14134b106
000000014134b17f: jmp      0x14134b6bd
000000014134b184: lea      rax, [rdi + rdi*2]
000000014134b188: lea      rdi, [rsi + rax*4]
000000014134b18c: cmp      rsi, rdi
000000014134b18f: jae      0x14134b6bf
000000014134b195: lea      rbx, [rsi + 8]
000000014134b199: nop      dword ptr [rax]
000000014134b1a0: mov      ecx, dword ptr [rbx - 8]
000000014134b1a3: call     0x1412e4220
000000014134b1a8: mov      dword ptr [rbx - 8], eax
000000014134b1ab: mov      ecx, dword ptr [rbx - 4]
000000014134b1ae: call     0x1412e4220
000000014134b1b3: mov      dword ptr [rbx - 4], eax
000000014134b1b6: mov      ecx, dword ptr [rbx]
000000014134b1b8: call     0x1412e4220
000000014134b1bd: mov      dword ptr [rbx], eax
000000014134b1bf: lea      rbx, [rbx + 0xc]
000000014134b1c3: lea      rax, [rbx - 8]
000000014134b1c7: cmp      rax, rdi
000000014134b1ca: jb       0x14134b1a0
000000014134b1cc: jmp      0x14134b6bd
000000014134b1d1: mov      rcx, rsi
000000014134b1d4: call     0x1412e4a90
000000014134b1d9: lea      rbx, [rsi + 0x40]
000000014134b1dd: lea      rdi, [rdi + rdi*4]
000000014134b1e1: lea      rdi, [rdi + 0x10]
000000014134b1e5: lea      rdi, [rsi + rdi*4]
000000014134b1e9: cmp      rbx, rdi
000000014134b1ec: jae      0x14134b6bd
000000014134b1f2: mov      ecx, dword ptr [rbx]
000000014134b1f4: call     0x1412e4220
000000014134b1f9: mov      dword ptr [rbx], eax
000000014134b1fb: mov      ecx, dword ptr [rbx + 4]
000000014134b1fe: call     0x1412e4220
000000014134b203: mov      dword ptr [rbx + 4], eax
000000014134b206: mov      ecx, dword ptr [rbx + 8]
000000014134b209: call     0x1412e4220
000000014134b20e: mov      dword ptr [rbx + 8], eax
000000014134b211: mov      ecx, dword ptr [rbx + 0xc]
000000014134b214: call     0x1412e4220
000000014134b219: mov      dword ptr [rbx + 0xc], eax
000000014134b21c: mov      ecx, dword ptr [rbx + 0x10]
000000014134b21f: call     0x1412e4220
000000014134b224: mov      dword ptr [rbx + 0x10], eax
000000014134b227: add      rbx, 0x14
000000014134b22b: cmp      rbx, rdi
000000014134b22e: jb       0x14134b1f2
000000014134b230: jmp      0x14134b6bd
000000014134b235: lea      rax, [rdi + rdi*4]
000000014134b239: lea      rdi, [rsi + rax*4]
000000014134b23d: cmp      rsi, rdi
000000014134b240: jae      0x14134b6bf
000000014134b246: lea      rbx, [rsi + 8]
000000014134b24a: nop      word ptr [rax + rax]
000000014134b250: mov      ecx, dword ptr [rbx - 8]
000000014134b253: call     0x1412e4220
000000014134b258: mov      dword ptr [rbx - 8], eax
000000014134b25b: mov      ecx, dword ptr [rbx - 4]
000000014134b25e: call     0x1412e4220
000000014134b263: mov      dword ptr [rbx - 4], eax
000000014134b266: mov      ecx, dword ptr [rbx]
000000014134b268: call     0x1412e4220
000000014134b26d: mov      dword ptr [rbx], eax
000000014134b26f: mov      ecx, dword ptr [rbx + 4]
000000014134b272: call     0x1412e4220
000000014134b277: mov      dword ptr [rbx + 4], eax
000000014134b27a: mov      ecx, dword ptr [rbx + 8]
000000014134b27d: call     0x1412e4220
000000014134b282: mov      dword ptr [rbx + 8], eax
000000014134b285: lea      rbx, [rbx + 0x14]
000000014134b289: lea      rax, [rbx - 8]
000000014134b28d: cmp      rax, rdi
000000014134b290: jb       0x14134b250
000000014134b292: jmp      0x14134b6bd
000000014134b297: mov      rbx, rsi
000000014134b29a: lea      rdi, [rsi + rdi*4]
000000014134b29e: cmp      rsi, rdi
000000014134b2a1: jae      0x14134b6bd
000000014134b2a7: mov      ecx, dword ptr [rbx]
000000014134b2a9: call     0x1412e4220
000000014134b2ae: mov      dword ptr [rbx], eax
000000014134b2b0: add      rbx, 4
000000014134b2b4: cmp      rbx, rdi
000000014134b2b7: jb       0x14134b2a7
000000014134b2b9: jmp      0x14134b6bd
000000014134b2be: mov      rbx, rsi
000000014134b2c1: lea      rdi, [rsi + rdi*8]
000000014134b2c5: cmp      rsi, rdi
000000014134b2c8: jae      0x14134b6bd
000000014134b2ce: nop      
000000014134b2d0: mov      ecx, dword ptr [rbx + 4]
000000014134b2d3: call     0x1412e4220
000000014134b2d8: mov      dword ptr [rbx + 4], eax
000000014134b2db: mov      ecx, dword ptr [rbx]
000000014134b2dd: call     0x1412e4220
000000014134b2e2: mov      dword ptr [rbx], eax
000000014134b2e4: add      rbx, 8
000000014134b2e8: cmp      rbx, rdi
000000014134b2eb: jb       0x14134b2d0
000000014134b2ed: jmp      0x14134b6bd
000000014134b2f2: mov      rbx, rsi
000000014134b2f5: lea      rdi, [rsi + rdi*8]
000000014134b2f9: cmp      rsi, rdi
000000014134b2fc: jae      0x14134b6bd
000000014134b302: mov      ecx, dword ptr [rbx]
000000014134b304: call     0x1412e4220
000000014134b309: mov      dword ptr [rbx], eax
000000014134b30b: mov      ecx, dword ptr [rbx + 4]
000000014134b30e: call     0x1412e4220
000000014134b313: mov      dword ptr [rbx + 4], eax
000000014134b316: add      rbx, 8
000000014134b31a: cmp      rbx, rdi
000000014134b31d: jb       0x14134b302
000000014134b31f: jmp      0x14134b6bd
000000014134b324: lea      rax, [rdi + rdi*2]
000000014134b328: lea      rdi, [rsi + rax*4]
000000014134b32c: cmp      rsi, rdi
000000014134b32f: jae      0x14134b6bf
000000014134b335: lea      rbx, [rsi + 8]
000000014134b339: nop      dword ptr [rax]
000000014134b340: mov      ecx, dword ptr [rbx - 8]
000000014134b343: call     0x1412e4220
000000014134b348: mov      dword ptr [rbx - 8], eax
000000014134b34b: mov      ecx, dword ptr [rbx - 4]
000000014134b34e: call     0x1412e4220
000000014134b353: mov      dword ptr [rbx - 4], eax
000000014134b356: mov      ecx, dword ptr [rbx]
000000014134b358: call     0x1412e4220
000000014134b35d: mov      dword ptr [rbx], eax
000000014134b35f: lea      rbx, [rbx + 0xc]
000000014134b363: lea      rax, [rbx - 8]
000000014134b367: cmp      rax, rdi
000000014134b36a: jb       0x14134b340
000000014134b36c: jmp      0x14134b6bd
000000014134b371: lea      r8, [rsi + rdi*8]
000000014134b375: cmp      rsi, r8
000000014134b378: jae      0x14134b6bf
000000014134b37e: lea      rdx, [rsi + 4]
000000014134b382: nop      dword ptr [rax]
000000014134b386: nop      word ptr [rax + rax]
000000014134b390: movzx    eax, word ptr [rdx - 4]
000000014134b394: movzx    ecx, ax
000000014134b397: shr      cx, 8
000000014134b39b: shl      ax, 8
000000014134b39f: xor      cx, ax
000000014134b3a2: mov      word ptr [rdx - 4], cx
000000014134b3a6: movzx    eax, word ptr [rdx - 2]
000000014134b3aa: movzx    ecx, ax
000000014134b3ad: shr      cx, 8
000000014134b3b1: shl      ax, 8
000000014134b3b5: xor      cx, ax
000000014134b3b8: mov      word ptr [rdx - 2], cx
000000014134b3bc: movzx    eax, word ptr [rdx]
000000014134b3bf: movzx    ecx, ax
000000014134b3c2: shr      cx, 8
000000014134b3c6: shl      ax, 8
000000014134b3ca: xor      cx, ax
000000014134b3cd: mov      word ptr [rdx], cx
000000014134b3d0: movzx    eax, word ptr [rdx + 2]
000000014134b3d4: movzx    ecx, ax
000000014134b3d7: shr      cx, 8
000000014134b3db: shl      ax, 8
000000014134b3df: xor      cx, ax
000000014134b3e2: mov      word ptr [rdx + 2], cx
000000014134b3e6: lea      rdx, [rdx + 8]
000000014134b3ea: lea      rax, [rdx - 4]
000000014134b3ee: cmp      rax, r8
000000014134b3f1: jb       0x14134b390
000000014134b3f3: jmp      0x14134b6bf
000000014134b3f8: lea      rax, [rdi + rdi*2]
000000014134b3fc: lea      r8, [rsi + rax*2]
000000014134b400: cmp      rsi, r8
000000014134b403: jae      0x14134b6bf
000000014134b409: lea      rdx, [rsi + 4]
000000014134b40d: nop      dword ptr [rax]
000000014134b410: movzx    eax, word ptr [rdx - 4]
000000014134b414: movzx    ecx, ax
000000014134b417: shr      cx, 8
000000014134b41b: shl      ax, 8
000000014134b41f: xor      cx, ax
000000014134b422: mov      word ptr [rdx - 4], cx
000000014134b426: movzx    eax, word ptr [rdx - 2]
000000014134b42a: movzx    ecx, ax
000000014134b42d: shr      cx, 8
000000014134b431: shl      ax, 8
000000014134b435: xor      cx, ax
000000014134b438: mov      word ptr [rdx - 2], cx
000000014134b43c: movzx    eax, word ptr [rdx]
000000014134b43f: movzx    ecx, ax
000000014134b442: shr      cx, 8
000000014134b446: shl      ax, 8
000000014134b44a: xor      cx, ax
000000014134b44d: mov      word ptr [rdx], cx
000000014134b450: lea      rdx, [rdx + 6]
000000014134b454: lea      rax, [rdx - 4]
000000014134b458: cmp      rax, r8
000000014134b45b: jb       0x14134b410
000000014134b45d: jmp      0x14134b6bf
000000014134b462: mov      rdx, rsi
000000014134b465: lea      r8, [rsi + rdi*2]
000000014134b469: mov      rax, rbx
000000014134b46c: lea      rdi, [rdi*2 + 1]
000000014134b474: shr      rdi, 1
000000014134b477: cmp      rsi, r8
000000014134b47a: cmova    rdi, rbx
000000014134b47e: test     rdi, rdi
000000014134b481: je       0x14134b53e
000000014134b487: cmp      rdi, 8
000000014134b48b: jb       0x14134b53e
000000014134b491: and      rdi, 0xfffffffffffffff8
000000014134b495: mov      ecx, 8
000000014134b49a: movd     xmm4, ecx
000000014134b49e: movd     xmm5, ecx
000000014134b4a2: movdqa   xmm6, xmmword ptr [rip + 0x6d64a6]
000000014134b4aa: nop      word ptr [rax + rax]
000000014134b4b0: movq     xmm3, qword ptr [rdx]
000000014134b4b4: xorps    xmm0, xmm0
000000014134b4b7: movdqa   xmm1, xmm3
000000014134b4bb: punpcklwd xmm1, xmm0
000000014134b4bf: pslld    xmm1, xmm4
000000014134b4c3: pshuflw  xmm0, xmm1, 0xd8
000000014134b4c8: pshufhw  xmm1, xmm0, 0xd8
000000014134b4cd: pshufd   xmm2, xmm1, 0xd8
000000014134b4d2: movq     xmm0, xmm5
000000014134b4d6: psrlw    xmm3, xmm0
000000014134b4da: pxor     xmm3, xmm2
000000014134b4de: movq     xmm0, xmm6
000000014134b4e2: pand     xmm3, xmm0
000000014134b4e6: pxor     xmm3, xmm2
000000014134b4ea: movq     qword ptr [rdx], xmm3
000000014134b4ee: movq     xmm3, qword ptr [rdx + 8]
000000014134b4f3: xorps    xmm0, xmm0
000000014134b4f6: movdqa   xmm1, xmm3
000000014134b4fa: punpcklwd xmm1, xmm0
000000014134b4fe: pslld    xmm1, xmm4
000000014134b502: pshuflw  xmm0, xmm1, 0xd8
000000014134b507: pshufhw  xmm1, xmm0, 0xd8
000000014134b50c: pshufd   xmm2, xmm1, 0xd8
000000014134b511: movq     xmm0, xmm5
000000014134b515: psrlw    xmm3, xmm0
000000014134b519: pxor     xmm3, xmm2
000000014134b51d: movq     xmm0, xmm6
000000014134b521: pand     xmm3, xmm0
000000014134b525: pxor     xmm3, xmm2
000000014134b529: movq     qword ptr [rdx + 8], xmm3
000000014134b52e: add      rdx, 0x10
000000014134b532: add      rax, rcx
000000014134b535: cmp      rax, rdi
000000014134b538: jb       0x14134b4b0
000000014134b53e: cmp      rdx, r8
000000014134b541: jae      0x14134b6bf
000000014134b547: nop      word ptr [rax + rax]
000000014134b550: movzx    eax, word ptr [rdx]
000000014134b553: movzx    ecx, ax
000000014134b556: shr      cx, 8
000000014134b55a: shl      ax, 8
000000014134b55e: xor      cx, ax
000000014134b561: mov      word ptr [rdx], cx
000000014134b564: add      rdx, 2
000000014134b568: cmp      rdx, r8
000000014134b56b: jb       0x14134b550
000000014134b56d: jmp      0x14134b6bf
000000014134b572: lea      rax, [rdi + rdi*2]
000000014134b576: lea      rdi, [rsi + rax*4]
000000014134b57a: cmp      rsi, rdi
000000014134b57d: jae      0x14134b6bf
000000014134b583: lea      rbx, [rsi + 8]
000000014134b587: mov      ecx, dword ptr [rbx - 8]
000000014134b58a: call     0x1412e4220
000000014134b58f: mov      dword ptr [rbx - 8], eax
000000014134b592: mov      ecx, dword ptr [rbx - 4]
000000014134b595: call     0x1412e4220
000000014134b59a: mov      dword ptr [rbx - 4], eax
000000014134b59d: mov      ecx, dword ptr [rbx]
000000014134b59f: call     0x1412e4220
000000014134b5a4: mov      dword ptr [rbx], eax
000000014134b5a6: lea      rbx, [rbx + 0xc]
000000014134b5aa: lea      rax, [rbx - 8]
000000014134b5ae: cmp      rax, rdi
000000014134b5b1: jb       0x14134b587
000000014134b5b3: jmp      0x14134b6bd
000000014134b5b8: mov      rbx, rsi
000000014134b5bb: lea      rdi, [rsi + rdi*4]
000000014134b5bf: cmp      rsi, rdi
000000014134b5c2: jae      0x14134b6bd
000000014134b5c8: mov      ecx, dword ptr [rbx]
000000014134b5ca: call     0x1412e4220
000000014134b5cf: mov      dword ptr [rbx], eax
000000014134b5d1: add      rbx, 4
000000014134b5d5: cmp      rbx, rdi
000000014134b5d8: jb       0x14134b5c8
000000014134b5da: jmp      0x14134b6bd
000000014134b5df: shl      rdi, 4
000000014134b5e3: add      rdi, rsi
000000014134b5e6: cmp      rsi, rdi
000000014134b5e9: jae      0x14134b6bf
000000014134b5ef: lea      rbx, [rsi + 8]
000000014134b5f3: mov      ecx, dword ptr [rbx - 8]
000000014134b5f6: call     0x1412e4220
000000014134b5fb: mov      dword ptr [rbx - 8], eax
000000014134b5fe: mov      ecx, dword ptr [rbx - 4]
000000014134b601: call     0x1412e4220
000000014134b606: mov      dword ptr [rbx - 4], eax
000000014134b609: mov      ecx, dword ptr [rbx]
000000014134b60b: call     0x1412e4220
000000014134b610: mov      dword ptr [rbx], eax
000000014134b612: mov      ecx, dword ptr [rbx + 4]
000000014134b615: call     0x1412e4220
000000014134b61a: mov      dword ptr [rbx + 4], eax
000000014134b61d: lea      rbx, [rbx + 0x10]
000000014134b621: lea      rax, [rbx - 8]
000000014134b625: cmp      rax, rdi
000000014134b628: jb       0x14134b5f3
000000014134b62a: jmp      0x14134b6bd
000000014134b62f: mov      rbx, rsi
000000014134b632: lea      rdi, [rsi + rdi*4]
000000014134b636: cmp      rsi, rdi
000000014134b639: jae      0x14134b6bd
000000014134b63f: nop      
000000014134b640: mov      ecx, dword ptr [rbx]
000000014134b642: call     0x1412e4220
000000014134b647: mov      dword ptr [rbx], eax
000000014134b649: add      rbx, 4
000000014134b64d: cmp      rbx, rdi
000000014134b650: jb       0x14134b640
000000014134b652: jmp      0x14134b6bd
000000014134b654: lea      rax, [rdi + rdi*2]
000000014134b658: lea      rdi, [rsi + rax*4]
000000014134b65c: cmp      rsi, rdi
000000014134b65f: jae      0x14134b6bf
000000014134b661: lea      rbx, [rsi + 6]
000000014134b665: mov      ecx, dword ptr [rbx - 6]
000000014134b668: call     0x1412e4220
000000014134b66d: mov      dword ptr [rbx - 6], eax
000000014134b670: movzx    eax, word ptr [rbx - 2]
000000014134b674: movzx    ecx, ax
000000014134b677: shr      cx, 8
000000014134b67b: shl      ax, 8
000000014134b67f: xor      cx, ax
000000014134b682: mov      word ptr [rbx - 2], cx
000000014134b686: movzx    eax, word ptr [rbx]
000000014134b689: movzx    ecx, ax
000000014134b68c: shr      cx, 8
000000014134b690: shl      ax, 8
000000014134b694: xor      cx, ax
000000014134b697: mov      word ptr [rbx], cx
000000014134b69a: movzx    eax, word ptr [rbx + 2]
000000014134b69e: movzx    ecx, ax
000000014134b6a1: shr      cx, 8
000000014134b6a5: shl      ax, 8
000000014134b6a9: xor      cx, ax
000000014134b6ac: mov      word ptr [rbx + 2], cx
000000014134b6b0: lea      rbx, [rbx + 0xc]
000000014134b6b4: lea      rax, [rbx - 6]
000000014134b6b8: cmp      rax, rdi
000000014134b6bb: jb       0x14134b665
000000014134b6bd: xor      ebx, ebx
000000014134b6bf: movzx    eax, word ptr [rbp + r14 + 0x66]
000000014134b6c5: add      rsi, rax
000000014134b6c8: inc      r15w
000000014134b6cc: cmp      r15w, word ptr [rsp + 0x36]
000000014134b6d2: jb       0x14134af50
000000014134b6d8: mov      r14, qword ptr [rsp + 0x50]
000000014134b6dd: movzx    eax, word ptr [rsp + 0x34]
000000014134b6e2: dec      eax
000000014134b6e4: lea      r15, [rip - 0x134b6eb]
000000014134b6eb: cmp      eax, 8
000000014134b6ee: ja       0x14134b915
000000014134b6f4: cdqe     
000000014134b6f6: mov      ecx, dword ptr [r15 + rax*4 + 0x134bb58]
000000014134b6fe: add      rcx, r15
000000014134b701: jmp      rcx
000000014134b703: mov      qword ptr [rsp + 0x70], r12
000000014134b708: lea      rax, [rip + 0x84c489]
000000014134b70f: mov      qword ptr [r12], rax
000000014134b713: mov      qword ptr [r12 + 0x78], rbx
000000014134b718: mov      qword ptr [r12 + 0x80], rbx
000000014134b720: mov      qword ptr [r12 + 0x88], rbx
000000014134b728: mov      qword ptr [r12 + 0x90], rbx
000000014134b730: lea      rsi, [r12 + 0x98]
000000014134b738: mov      qword ptr [rsp + 0x78], rsi
000000014134b73d: lea      rcx, [rsp + 0x58]
000000014134b742: call     0x141273620
000000014134b747: lea      rax, [rip + 0x853e62]
000000014134b74e: mov      qword ptr [rsp + 0x58], rax
000000014134b753: mov      dword ptr [rsi], ebx
000000014134b755: lea      rdi, [rsi + 8]
000000014134b759: mov      qword ptr [rbp - 0x68], rdi
000000014134b75d: lea      rcx, [rsp + 0x58]
000000014134b762: call     0x141273770
000000014134b767: mov      edx, eax
000000014134b769: mov      rcx, rdi
000000014134b76c: call     0x1412735d0
000000014134b771: lea      rax, [rip + 0x853e58]
000000014134b778: mov      qword ptr [rdi], rax
000000014134b77b: mov      qword ptr [rdi + 0x18], rbx
000000014134b77f: mov      qword ptr [rdi + 0x20], rbx
000000014134b783: mov      rcx, rdi
000000014134b786: call     0x141273770
000000014134b78b: mov      ecx, eax
000000014134b78d: call     0x141273960
000000014134b792: mov      dword ptr [rsp + 0x20], 0x63
000000014134b79a: lea      r9, [rip + 0x415aef]
000000014134b7a1: mov      r8, qword ptr [rdi + 8]
000000014134b7a5: mov      edx, 0x58
000000014134b7aa: lea      ecx, [rdx - 0x50]
000000014134b7ad: call     0x1412734b0
000000014134b7b2: mov      rbx, rax
000000014134b7b5: call     0x141273900
000000014134b7ba: mov      qword ptr [rbx], rbx
000000014134b7bd: mov      qword ptr [rbx + 8], rbx
000000014134b7c1: mov      qword ptr [rdi + 0x18], rbx
000000014134b7c5: lea      rcx, [rsp + 0x58]
000000014134b7ca: call     0x141273770
000000014134b7cf: mov      edx, eax
000000014134b7d1: lea      rcx, [rsi + 0x30]
000000014134b7d5: call     0x1412735d0
000000014134b7da: lea      rax, [rip + 0x853e0f]
000000014134b7e1: mov      qword ptr [rsi + 0x30], rax
000000014134b7e5: xor      eax, eax
000000014134b7e7: mov      qword ptr [rsi + 0x48], rax
000000014134b7eb: mov      qword ptr [rsi + 0x50], rax
000000014134b7ef: mov      qword ptr [rsi + 0x58], rax
000000014134b7f3: mov      qword ptr [rsi + 0x60], 7
000000014134b7fb: mov      eax, 8
000000014134b800: mov      qword ptr [rsi + 0x68], rax
000000014134b804: mov      dword ptr [rsi], 0x3f800000
000000014134b80a: mov      r8, qword ptr [rsi + 0x20]
000000014134b80e: lea      edx, [rax + 8]
000000014134b811: lea      rcx, [rsi + 0x30]
000000014134b815: call     0x1412e9900
000000014134b81a: nop      
000000014134b81b: xor      ebx, ebx
000000014134b81d: mov      dword ptr [r12 + 0x108], ebx
000000014134b825: xor      r8d, r8d
000000014134b828: lea      rdx, [r12 + 0x18]
000000014134b82d: lea      rcx, [rbp + 0x60]
000000014134b831: call     0x141391760
000000014134b836: lea      r8d, [rbx + 1]
000000014134b83a: lea      rdx, [r12 + 0x30]
000000014134b83f: lea      rcx, [rbp + 0x60]
000000014134b843: call     0x141391760
000000014134b848: lea      r8d, [rbx + 2]
000000014134b84c: lea      rdx, [r12 + 0x48]
000000014134b851: lea      rcx, [rbp + 0x60]
000000014134b855: call     0x141391760
000000014134b85a: lea      r8d, [rbx + 3]
000000014134b85e: lea      rdx, [r12 + 0x60]
000000014134b863: lea      rcx, [rbp + 0x60]
000000014134b867: call     0x141391760
000000014134b86c: mov      rcx, r12
000000014134b86f: call     0x1412e9830
000000014134b874: jmp      0x14134b915
000000014134b879: lea      rax, [rip + 0x853d10]
000000014134b880: mov      qword ptr [r12], rax
000000014134b884: xor      r8d, r8d
000000014134b887: lea      rdx, [r12 + 0x18]
000000014134b88c: lea      rcx, [rbp + 0x60]
000000014134b890: call     0x141391760
000000014134b895: mov      r8d, 1
000000014134b89b: lea      rdx, [r12 + 0x30]
000000014134b8a0: lea      rcx, [rbp + 0x60]
000000014134b8a4: call     0x141391760
000000014134b8a9: mov      r8d, 2
000000014134b8af: lea      rdx, [r12 + 0x48]
000000014134b8b4: lea      rcx, [rbp + 0x60]
000000014134b8b8: call     0x141391760
000000014134b8bd: jmp      0x14134b915
000000014134b8bf: lea      rax, [rip + 0x853d4a]
000000014134b8c6: mov      qword ptr [r12], rax
000000014134b8ca: jmp      0x14134b915
000000014134b8cc: mov      r8d, dword ptr [rsp + 0x48]
000000014134b8d1: lea      rdx, [rbp + 0x60]
000000014134b8d5: mov      rcx, r12
000000014134b8d8: call     0x1413904d0
000000014134b8dd: jmp      0x14134b915
000000014134b8df: lea      rdx, [rbp + 0x60]
000000014134b8e3: mov      rcx, r12
000000014134b8e6: call     0x141390150
000000014134b8eb: jmp      0x14134b915
000000014134b8ed: lea      rdx, [rbp + 0x60]
000000014134b8f1: mov      rcx, r12
000000014134b8f4: call     0x141390240
000000014134b8f9: jmp      0x14134b915
000000014134b8fb: lea      rdx, [rbp + 0x60]
000000014134b8ff: mov      rcx, r12
000000014134b902: call     0x141390350
000000014134b907: jmp      0x14134b915
000000014134b909: lea      rdx, [rbp + 0x60]
000000014134b90d: mov      rcx, r12
000000014134b910: call     0x141391560
000000014134b915: mov      qword ptr [r12 + 8], rbx
000000014134b91a: movzx    eax, word ptr [rsp + 0x30]
000000014134b91f: mov      word ptr [r12 + 0x10], ax
000000014134b925: mov      eax, dword ptr [rsp + 0x30]
000000014134b929: shr      eax, 0x10
000000014134b92c: mov      word ptr [r12 + 0x12], ax
000000014134b932: movzx    ebx, word ptr [rsp + 0x38]
000000014134b937: mov      rax, qword ptr [r14 + 0xd0]
000000014134b93e: mov      qword ptr [rax + rbx*8], r12
000000014134b942: inc      bx
000000014134b945: mov      word ptr [rsp + 0x38], bx
000000014134b94a: xor      r12d, r12d
000000014134b94d: cmp      bx, word ptr [rbp - 0x78]
000000014134b951: jae      0x14134b963
000000014134b953: jmp      0x14134acc0
000000014134b958: mov      rcx, r12
000000014134b95b: call     0x141273220
000000014134b960: xor      r12d, r12d
000000014134b963: lea      rsi, [rip + 0x415a1e]
000000014134b96a: cmp      qword ptr [rbp - 0x20], 0x10
000000014134b96f: jb       0x14134b992
000000014134b971: mov      rbx, qword ptr [rbp - 0x38]
000000014134b975: lea      rcx, [rbp - 0x50]
000000014134b979: call     0x141273770
000000014134b97e: mov      ecx, eax
000000014134b980: call     0x141273960
000000014134b985: mov      rcx, rbx
000000014134b988: call     0x1412732b0
000000014134b98d: call     0x141273900
000000014134b992: mov      qword ptr [rbp - 0x28], r12
000000014134b996: mov      qword ptr [rbp - 0x20], 0xf
000000014134b99e: mov      byte ptr [rbp - 0x38], 0
000000014134b9a2: mov      qword ptr [rbp - 0x50], rsi
000000014134b9a6: cmp      qword ptr [rbp + 0x18], 0x10
000000014134b9ab: jb       0x14134b9cf
000000014134b9ad: mov      rbx, qword ptr [rbp]
000000014134b9b1: lea      rcx, [rbp - 0x18]
000000014134b9b5: call     0x141273770
000000014134b9ba: mov      ecx, eax
000000014134b9bc: call     0x141273960
000000014134b9c1: mov      rcx, rbx
000000014134b9c4: call     0x1412732b0
000000014134b9c9: call     0x141273900
000000014134b9ce: nop      
000000014134b9cf: mov      rcx, qword ptr [rbp + 0x470]
000000014134b9d6: xor      rcx, rsp
000000014134b9d9: call     0x141441dc0
000000014134b9de: mov      rbx, qword ptr [rsp + 0x5e8]
000000014134b9e6: movaps   xmm6, xmmword ptr [rsp + 0x580]
000000014134b9ee: add      rsp, 0x590
000000014134b9f5: pop      r15
000000014134b9f7: pop      r14
000000014134b9f9: pop      r13
000000014134b9fb: pop      r12
000000014134b9fd: pop      rdi
000000014134b9fe: pop      rsi
000000014134b9ff: pop      rbp
000000014134ba00: ret      
000000014134ba01: call     qword ptr [rip + 0x3ea681]
000000014134ba07: nop      
000000014134ba08: call     0x1400bfa60
000000014134ba0d: int3     
000000014134ba0e: nop      
000000014134ba10: cmp      ch, byte ptr [rbp - 0x52befecc]
000000014134ba16: xor      al, 1
000000014134ba18: lodsq    rax, qword ptr [rsi]
000000014134ba1a: xor      al, 1
000000014134ba1c: lodsq    rax, qword ptr [rsi]
000000014134ba1e: xor      al, 1
000000014134ba20: lodsd    eax, dword ptr [rsi]
000000014134ba22: xor      al, 1
000000014134ba24: push     rsi
000000014134ba25: lodsd    eax, dword ptr [rsi]
000000014134ba26: xor      al, 1
000000014134ba28: imul     ebp, dword ptr [rbp - 0x52a2fecc], 0x34
000000014134ba2f: add      dword ptr [rbp + rbp*4 + 0x34], esp
000000014134ba33: add      dword ptr [rax], ebp
000000014134ba35: scasb    al, byte ptr [rdi]
000000014134ba36: xor      al, 1
000000014134ba38: fsubr    qword ptr [rsi - 0x51cbfecc]
000000014134ba3e: xor      al, 1
000000014134ba40: cmp      eax, 0xd20134ae
000000014134ba45: scasb    al, byte ptr [rdi]
000000014134ba46: xor      al, 1
000000014134ba48: cmp      eax, 0x490134ae
000000014134ba4d: scasb    al, byte ptr [rdi]
000000014134ba4e: xor      al, 1
