0000000141276690: mov      qword ptr [rsp + 0x20], r9
0000000141276695: mov      qword ptr [rsp + 0x18], r8
000000014127669a: mov      qword ptr [rsp + 8], rcx
000000014127669f: push     rbp
00000001412766a0: push     rbx
00000001412766a1: push     rsi
00000001412766a2: push     rdi
00000001412766a3: push     r12
00000001412766a5: push     r13
00000001412766a7: push     r14
00000001412766a9: push     r15
00000001412766ab: lea      rbp, [rsp - 0xe8]
00000001412766b3: sub      rsp, 0x1e8
00000001412766ba: mov      r14, r9
00000001412766bd: mov      r15, r8
00000001412766c0: mov      rbx, rdx
00000001412766c3: mov      rdi, rcx
00000001412766c6: mov      qword ptr [rbp + 0xd0], rcx
00000001412766cd: mov      rax, qword ptr [rcx]
00000001412766d0: call     qword ptr [rax + 8]
00000001412766d3: nop      
00000001412766d4: mov      esi, 0xffffffff
00000001412766d9: lea      r12, [rip + 0x91b080]
00000001412766e0: mov      qword ptr [rbp + 0x60], r12
00000001412766e4: xorps    xmm3, xmm3
00000001412766e7: xorps    xmm2, xmm2
00000001412766ea: xorps    xmm1, xmm1
00000001412766ed: lea      rcx, [rbp + 0x68]
00000001412766f1: call     0x1411ab440
00000001412766f6: call     0x1400bfa80
00000001412766fb: movsd    xmm0, qword ptr [rax]
00000001412766ff: movsd    qword ptr [rbp + 0x68], xmm0
0000000141276704: mov      eax, dword ptr [rax + 8]
0000000141276707: mov      dword ptr [rbp + 0x70], eax
000000014127670a: xor      r13d, r13d
000000014127670d: mov      qword ptr [rbp + 0x74], r13
0000000141276711: xorps    xmm0, xmm0
0000000141276714: movdqa   xmmword ptr [rbp + 0x80], xmm0
000000014127671c: mov      qword ptr [rbp + 0x90], r13
0000000141276723: mov      qword ptr [rbp + 0x9c], 0xffffffffffffffff
000000014127672e: lea      rax, [rip + 0x91b063]
0000000141276735: mov      qword ptr [rbp + 0x60], rax
0000000141276739: mov      dword ptr [rbp + 0x98], 3
0000000141276743: mov      qword ptr [rbp + 0xa8], r13
000000014127674a: movdqa   xmmword ptr [rbp + 0xb0], xmm0
0000000141276752: mov      qword ptr [rbp + 0xc0], r13
0000000141276759: mov      qword ptr [rbp - 0x30], r12
000000014127675d: xorps    xmm3, xmm3
0000000141276760: xorps    xmm2, xmm2
0000000141276763: xorps    xmm1, xmm1
0000000141276766: lea      rcx, [rbp - 0x28]
000000014127676a: call     0x1411ab440
000000014127676f: call     0x1400bfa80
0000000141276774: movsd    xmm0, qword ptr [rax]
0000000141276778: movsd    qword ptr [rbp - 0x28], xmm0
000000014127677d: mov      eax, dword ptr [rax + 8]
0000000141276780: mov      dword ptr [rbp - 0x20], eax
0000000141276783: mov      qword ptr [rbp - 0x1c], r13
0000000141276787: xorps    xmm0, xmm0
000000014127678a: movdqa   xmmword ptr [rbp - 0x10], xmm0
000000014127678f: mov      qword ptr [rbp], r13
0000000141276793: mov      dword ptr [rbp + 8], r13d
0000000141276797: mov      qword ptr [rbp + 0xc], 0xffffffffffffffff
000000014127679f: lea      r12, [rip + 0x91b02a]
00000001412767a6: mov      qword ptr [rbp - 0x30], r12
00000001412767aa: xorps    xmm3, xmm3
00000001412767ad: xorps    xmm2, xmm2
00000001412767b0: xorps    xmm1, xmm1
00000001412767b3: lea      rcx, [rbp + 0x28]
00000001412767b7: call     0x1411ab440
00000001412767bc: mov      dword ptr [rbp + 8], 2
00000001412767c3: mov      qword ptr [rbp + 0x18], r13
00000001412767c7: call     0x1400bfa80
00000001412767cc: movsd    xmm0, qword ptr [rax]
00000001412767d0: movsd    qword ptr [rbp + 0x28], xmm0
00000001412767d5: mov      eax, dword ptr [rax + 8]
00000001412767d8: mov      dword ptr [rbp + 0x30], eax
00000001412767db: mov      qword ptr [rbp + 0x38], r13
00000001412767df: mov      qword ptr [rbp + 0x40], r13
00000001412767e3: mov      qword ptr [rbp + 0x20], r13
00000001412767e7: mov      dword ptr [rbp + 0x48], r13d
00000001412767eb: lea      rax, [rip + 0x91af6e]
00000001412767f2: mov      qword ptr [rsp + 0x30], rax
00000001412767f7: xorps    xmm3, xmm3
00000001412767fa: xorps    xmm2, xmm2
00000001412767fd: xorps    xmm1, xmm1
0000000141276800: lea      rcx, [rsp + 0x38]
0000000141276805: call     0x1411ab440
000000014127680a: call     0x1400bfa80
000000014127680f: movsd    xmm0, qword ptr [rax]
0000000141276813: movsd    qword ptr [rsp + 0x38], xmm0
0000000141276819: mov      eax, dword ptr [rax + 8]
000000014127681c: mov      dword ptr [rsp + 0x40], eax
0000000141276820: mov      qword ptr [rsp + 0x44], r13
0000000141276825: xorps    xmm0, xmm0
0000000141276828: movdqa   xmmword ptr [rsp + 0x50], xmm0
000000014127682e: mov      qword ptr [rsp + 0x60], r13
0000000141276833: mov      dword ptr [rsp + 0x68], r13d
0000000141276838: mov      qword ptr [rsp + 0x6c], 0xffffffffffffffff
0000000141276841: mov      qword ptr [rsp + 0x30], r12
0000000141276846: xorps    xmm3, xmm3
0000000141276849: xorps    xmm2, xmm2
000000014127684c: xorps    xmm1, xmm1
000000014127684f: lea      rcx, [rbp - 0x78]
0000000141276853: call     0x1411ab440
0000000141276858: mov      dword ptr [rsp + 0x68], 2
0000000141276860: mov      qword ptr [rsp + 0x78], r13
0000000141276865: call     0x1400bfa80
000000014127686a: movsd    xmm0, qword ptr [rax]
000000014127686e: movsd    qword ptr [rbp - 0x78], xmm0
0000000141276873: mov      eax, dword ptr [rax + 8]
0000000141276876: mov      dword ptr [rbp - 0x70], eax
0000000141276879: mov      qword ptr [rbp - 0x68], r13
000000014127687d: mov      qword ptr [rbp - 0x60], r13
0000000141276881: mov      qword ptr [rbp - 0x80], r13
0000000141276885: mov      dword ptr [rbp - 0x58], r13d
0000000141276889: lea      rax, [rip + 0x91af78]
0000000141276890: mov      qword ptr [rsp + 0x30], rax
0000000141276895: xorps    xmm0, xmm0
0000000141276898: movdqa   xmmword ptr [rbp - 0x50], xmm0
000000014127689d: mov      dword ptr [rsp + 0x68], 2
00000001412768a5: mov      qword ptr [rsp + 0x78], r13
00000001412768aa: call     0x1400bfa80
00000001412768af: movsd    xmm0, qword ptr [rax]
00000001412768b3: movsd    qword ptr [rbp - 0x78], xmm0
00000001412768b8: mov      eax, dword ptr [rax + 8]
00000001412768bb: mov      dword ptr [rbp - 0x70], eax
00000001412768be: mov      qword ptr [rbp - 0x68], r13
00000001412768c2: mov      qword ptr [rbp - 0x60], r13
00000001412768c6: mov      qword ptr [rbp - 0x80], r13
00000001412768ca: mov      dword ptr [rbp - 0x58], r13d
00000001412768ce: mov      dword ptr [rsp + 0x68], 4
00000001412768d6: test     rbx, rbx
00000001412768d9: je       0x141276d3f
00000001412768df: mov      rcx, qword ptr [rbx + 0x38]
00000001412768e3: mov      qword ptr [rbp + 0x58], rcx
00000001412768e7: mov      rax, qword ptr [rbx + 0x40]
00000001412768eb: mov      qword ptr [rbp + 0x50], rax
00000001412768ef: mov      rax, qword ptr [rbx + 0x48]
00000001412768f3: mov      qword ptr [rbp - 0x40], rax
00000001412768f7: mov      r12, qword ptr [rbx + 0x50]
00000001412768fb: mov      qword ptr [rbp - 0x38], r12
00000001412768ff: test     rcx, rcx
0000000141276902: je       0x141276d3f
0000000141276908: movzx    eax, byte ptr [rcx + 0x23]
000000014127690c: mov      byte ptr [rdi + 0x78], al
000000014127690f: test     r14, r14
0000000141276912: jne      0x14127694e
0000000141276914: mov      r8d, 0x3fc
000000014127691a: lea      rdx, [rip + 0x91af1f]
0000000141276921: mov      ecx, 0x2d0
0000000141276926: call     0x141272600
000000014127692b: mov      qword ptr [rbp + 0x138], rax
0000000141276932: test     rax, rax
0000000141276935: je       0x141276944
0000000141276937: mov      rcx, rax
000000014127693a: call     0x1412dcbc0
000000014127693f: mov      rsi, rax
0000000141276942: jmp      0x141276947
0000000141276944: mov      rsi, r13
0000000141276947: mov      qword ptr [rsp + 0x20], rsi
000000014127694c: jmp      0x141276956
000000014127694e: mov      rsi, r14
0000000141276951: mov      qword ptr [rsp + 0x20], r14
0000000141276956: xor      eax, eax
0000000141276958: lea      r13d, [rax + 1]
000000014127695c: cmp      ax, word ptr [rbx + 0x14]
0000000141276960: jae      0x141276ce8
0000000141276966: nop      word ptr [rax + rax]
0000000141276970: mov      dword ptr [rbp + 0x138], r13d
0000000141276977: mov      r8d, 0x409
000000014127697d: lea      rdx, [rip + 0x91aebc]
0000000141276984: mov      ecx, 0x250
0000000141276989: call     0x141272600
000000014127698e: mov      qword ptr [rbp + 0xd8], rax
0000000141276995: test     rax, rax
0000000141276998: je       0x1412769a9
000000014127699a: mov      rcx, rax
000000014127699d: call     0x14131b270
00000001412769a2: mov      r14, rax
00000001412769a5: xor      ecx, ecx
00000001412769a7: jmp      0x1412769ae
00000001412769a9: xor      ecx, ecx
00000001412769ab: mov      r14d, ecx
00000001412769ae: mov      qword ptr [r14 + 0x248], r15
00000001412769b5: mov      edi, ecx
00000001412769b7: cmp      cx, word ptr [rbx + 0x1c]
00000001412769bb: jae      0x141276a57
00000001412769c1: mov      r12, qword ptr [rbp + 0x50]
00000001412769c5: xor      r15d, r15d
00000001412769c8: nop      dword ptr [rax + rax]
00000001412769d0: mov      eax, edi
00000001412769d2: lea      rcx, [rax + rax*2]
00000001412769d6: add      rcx, rcx
00000001412769d9: mov      rax, qword ptr [rbx + 0x40]
00000001412769dd: cmp      dword ptr [rax + rcx*8 + 4], r13d
00000001412769e2: jne      0x141276a40
00000001412769e4: mov      dword ptr [rbp + 0x98], 3
00000001412769ee: mov      qword ptr [rbp + 0xa8], r15
00000001412769f5: xorps    xmm0, xmm0
00000001412769f8: movdqa   xmmword ptr [rbp + 0xb0], xmm0
0000000141276a00: mov      qword ptr [rbp + 0xc0], r15
0000000141276a07: movups   xmm0, xmmword ptr [r12 + rcx*8 + 0x18]
0000000141276a0d: movaps   xmmword ptr [rbp + 0xb0], xmm0
0000000141276a14: movsd    xmm1, qword ptr [r12 + rcx*8 + 0x28]
0000000141276a1b: movsd    qword ptr [rbp + 0xc0], xmm1
0000000141276a23: mov      edx, edi
0000000141276a25: mov      rcx, rbx
0000000141276a28: call     0x141320040
0000000141276a2d: mov      qword ptr [rbp + 0x90], rax
0000000141276a34: lea      rdx, [rbp + 0x60]
0000000141276a38: mov      rcx, r14
0000000141276a3b: call     0x14131bb60
0000000141276a40: inc      edi
0000000141276a42: movzx    eax, word ptr [rbx + 0x1c]
0000000141276a46: cmp      edi, eax
0000000141276a48: jb       0x1412769d0
0000000141276a4a: mov      r12, qword ptr [rbp - 0x38]
0000000141276a4e: mov      r15, qword ptr [rbp + 0x140]
0000000141276a55: xor      ecx, ecx
0000000141276a57: mov      edi, ecx
0000000141276a59: cmp      cx, word ptr [rbx + 0x24]
0000000141276a5d: jae      0x141276b5a
0000000141276a63: mov      r12, qword ptr [rbp + 0x130]
0000000141276a6a: nop      word ptr [rax + rax]
0000000141276a70: mov      eax, edi
0000000141276a72: lea      rsi, [rax + rax*8]
0000000141276a76: mov      rax, qword ptr [rbx + 0x48]
0000000141276a7a: cmp      dword ptr [rax + rsi*8 + 4], r13d
0000000141276a7f: jne      0x141276b46
0000000141276a85: mov      r8, r15
0000000141276a88: mov      edx, edi
0000000141276a8a: mov      rcx, rbx
0000000141276a8d: call     0x1413201b0
0000000141276a92: mov      r15, rax
0000000141276a95: test     rax, rax
0000000141276a98: je       0x141276ace
0000000141276a9a: mov      dword ptr [rbp + 8], 2
0000000141276aa1: xor      eax, eax
0000000141276aa3: mov      qword ptr [rbp + 0x18], rax
0000000141276aa7: call     0x1400bfa80
0000000141276aac: movsd    xmm0, qword ptr [rax]
0000000141276ab0: movsd    qword ptr [rbp + 0x28], xmm0
0000000141276ab5: mov      eax, dword ptr [rax + 8]
0000000141276ab8: mov      dword ptr [rbp + 0x30], eax
0000000141276abb: xor      eax, eax
0000000141276abd: mov      qword ptr [rbp + 0x20], rax
0000000141276ac1: mov      qword ptr [rbp + 0x38], r15
0000000141276ac5: mov      dword ptr [rbp + 0x48], 2
0000000141276acc: jmp      0x141276b1f
0000000141276ace: cmp      dword ptr [r12 + 0x58], 1
0000000141276ad4: jne      0x141276b3f
0000000141276ad6: mov      dword ptr [rbp + 8], 2
0000000141276add: xor      r15d, r15d
0000000141276ae0: mov      qword ptr [rbp + 0x18], r15
0000000141276ae4: call     0x1400bfa80
0000000141276ae9: movsd    xmm0, qword ptr [rax]
0000000141276aed: movsd    qword ptr [rbp + 0x28], xmm0
0000000141276af2: mov      eax, dword ptr [rax + 8]
0000000141276af5: mov      dword ptr [rbp + 0x30], eax
0000000141276af8: mov      qword ptr [rbp + 0x38], r15
0000000141276afc: mov      qword ptr [rbp + 0x40], r15
0000000141276b00: mov      qword ptr [rbp + 0x20], r15
0000000141276b04: mov      dword ptr [rbp + 0x48], r15d
0000000141276b08: mov      edx, edi
0000000141276b0a: mov      rcx, rbx
0000000141276b0d: call     0x141320180
0000000141276b12: cmp      dword ptr [rbp + 0x48], r15d
0000000141276b16: jne      0x141276b33
0000000141276b18: mov      dword ptr [rbp + 0x48], 3
0000000141276b1f: mov      qword ptr [rbp + 0x40], rax
0000000141276b23: mov      rax, qword ptr [rbp - 0x40]
0000000141276b27: lea      rax, [rax + rsi*8]
0000000141276b2b: add      rax, 0x18
0000000141276b2f: mov      qword ptr [rbp + 0x18], rax
0000000141276b33: lea      rdx, [rbp - 0x30]
0000000141276b37: mov      rcx, r14
0000000141276b3a: call     0x14131bb50
0000000141276b3f: mov      r15, qword ptr [rbp + 0x140]
0000000141276b46: inc      edi
0000000141276b48: movzx    eax, word ptr [rbx + 0x24]
0000000141276b4c: cmp      edi, eax
0000000141276b4e: jb       0x141276a70
0000000141276b54: mov      r12, qword ptr [rbp - 0x38]
0000000141276b58: xor      ecx, ecx
0000000141276b5a: mov      esi, ecx
0000000141276b5c: cmp      cx, word ptr [rbx + 0x2c]
0000000141276b60: jae      0x141276c7b
0000000141276b66: nop      word ptr [rax + rax]
0000000141276b70: mov      eax, esi
0000000141276b72: lea      rdi, [rax + rax*8]
0000000141276b76: shl      rdi, 4
0000000141276b7a: mov      rax, qword ptr [rbx + 0x50]
0000000141276b7e: cmp      dword ptr [rdi + rax + 4], r13d
0000000141276b83: jne      0x141276c66
0000000141276b89: mov      r8, r15
0000000141276b8c: mov      edx, esi
0000000141276b8e: mov      rcx, rbx
0000000141276b91: call     0x1413200c0
0000000141276b96: mov      r15, rax
0000000141276b99: test     rax, rax
0000000141276b9c: je       0x141276bdc
0000000141276b9e: mov      dword ptr [rsp + 0x68], 2
0000000141276ba6: xor      eax, eax
0000000141276ba8: mov      qword ptr [rsp + 0x78], rax
0000000141276bad: call     0x1400bfa80
0000000141276bb2: movsd    xmm0, qword ptr [rax]
0000000141276bb6: movsd    qword ptr [rbp - 0x78], xmm0
0000000141276bbb: mov      eax, dword ptr [rax + 8]
0000000141276bbe: mov      dword ptr [rbp - 0x70], eax
0000000141276bc1: xor      eax, eax
0000000141276bc3: mov      qword ptr [rbp - 0x80], rax
0000000141276bc7: mov      dword ptr [rsp + 0x68], 4
0000000141276bcf: mov      qword ptr [rbp - 0x68], r15
0000000141276bd3: mov      dword ptr [rbp - 0x58], 2
0000000141276bda: jmp      0x141276c3c
0000000141276bdc: mov      rax, qword ptr [rbp + 0x130]
0000000141276be3: cmp      dword ptr [rax + 0x58], 1
0000000141276be7: jne      0x141276c66
0000000141276be9: mov      dword ptr [rsp + 0x68], 2
0000000141276bf1: xor      r15d, r15d
0000000141276bf4: mov      qword ptr [rsp + 0x78], r15
0000000141276bf9: call     0x1400bfa80
0000000141276bfe: movsd    xmm0, qword ptr [rax]
0000000141276c02: movsd    qword ptr [rbp - 0x78], xmm0
0000000141276c07: mov      eax, dword ptr [rax + 8]
0000000141276c0a: mov      dword ptr [rbp - 0x70], eax
0000000141276c0d: mov      qword ptr [rbp - 0x68], r15
0000000141276c11: mov      qword ptr [rbp - 0x60], r15
0000000141276c15: mov      qword ptr [rbp - 0x80], r15
0000000141276c19: mov      dword ptr [rbp - 0x58], r15d
0000000141276c1d: mov      dword ptr [rsp + 0x68], 4
0000000141276c25: mov      edx, esi
0000000141276c27: mov      rcx, rbx
0000000141276c2a: call     0x141320090
0000000141276c2f: cmp      dword ptr [rbp - 0x58], r15d
0000000141276c33: jne      0x141276c4d
0000000141276c35: mov      dword ptr [rbp - 0x58], 3
0000000141276c3c: mov      qword ptr [rbp - 0x60], rax
0000000141276c40: lea      rax, [r12 + 0x18]
0000000141276c45: add      rax, rdi
0000000141276c48: mov      qword ptr [rsp + 0x78], rax
0000000141276c4d: lea      rax, [r12 + 0x40]
0000000141276c52: add      rax, rdi
0000000141276c55: mov      qword ptr [rbp - 0x48], rax
0000000141276c59: lea      rdx, [rsp + 0x30]
0000000141276c5e: mov      rcx, r14
0000000141276c61: call     0x14131b5b0
0000000141276c66: inc      esi
0000000141276c68: movzx    eax, word ptr [rbx + 0x2c]
0000000141276c6c: cmp      esi, eax
0000000141276c6e: mov      r15, qword ptr [rbp + 0x140]
0000000141276c75: jb       0x141276b70
0000000141276c7b: lea      ecx, [r13 - 1]
0000000141276c7f: imul     rax, rcx, 0xe0
0000000141276c86: mov      rdx, qword ptr [rbp + 0x58]
0000000141276c8a: add      rdx, 0x20
0000000141276c8e: add      rdx, rax
0000000141276c91: mov      rcx, r14
0000000141276c94: call     0x14131c440
0000000141276c99: lea      edx, [r13 - 1]
0000000141276c9d: mov      rcx, rbx
0000000141276ca0: call     0x141320270
0000000141276ca5: mov      rdx, rax
0000000141276ca8: mov      rcx, r14
0000000141276cab: call     0x14131c460
0000000141276cb0: mov      rdx, r14
0000000141276cb3: mov      rsi, qword ptr [rsp + 0x20]
0000000141276cb8: mov      rcx, rsi
0000000141276cbb: call     0x1412dd780
0000000141276cc0: inc      r13d
0000000141276cc3: movzx    eax, word ptr [rbx + 0x14]
0000000141276cc7: cmp      dword ptr [rbp + 0x138], eax
0000000141276ccd: mov      r15, qword ptr [rbp + 0x140]
0000000141276cd4: jb       0x141276970
0000000141276cda: mov      rdi, qword ptr [rbp + 0x130]
0000000141276ce1: mov      r14, qword ptr [rbp + 0x148]
0000000141276ce8: mov      rcx, rsi
0000000141276ceb: call     0x1412dd6f0
0000000141276cf0: test     r14, r14
0000000141276cf3: jne      0x141276d34
0000000141276cf5: mov      qword ptr [rbp + 0x130], rdi
0000000141276cfc: mov      rax, qword ptr [rdi]
0000000141276cff: mov      rcx, rdi
0000000141276d02: call     qword ptr [rax + 8]
0000000141276d05: nop      
0000000141276d06: test     rsi, rsi
0000000141276d09: je       0x141276d2a
0000000141276d0b: mov      rax, qword ptr [rdi]
0000000141276d0e: xor      r8d, r8d
0000000141276d11: mov      rdx, rsi
0000000141276d14: mov      rcx, rdi
0000000141276d17: call     qword ptr [rax + 0xb8]
0000000141276d1d: mov      eax, dword ptr [rdi + 0x6c]
0000000141276d20: test     eax, eax
0000000141276d22: je       0x141276d2a
0000000141276d24: mov      dword ptr [rsi + 0x2c0], eax
0000000141276d2a: mov      rax, qword ptr [rdi]
0000000141276d2d: mov      rcx, rdi
0000000141276d30: call     qword ptr [rax + 0x10]
0000000141276d33: nop      
0000000141276d34: mov      rax, qword ptr [rsi]
0000000141276d37: mov      rcx, rsi
0000000141276d3a: call     qword ptr [rax + 0x60]
0000000141276d3d: mov      esi, eax
0000000141276d3f: lea      rax, [rip + 0x91aa1a]
0000000141276d46: mov      qword ptr [rsp + 0x30], rax
0000000141276d4b: mov      qword ptr [rbp - 0x30], rax
0000000141276d4f: mov      qword ptr [rbp + 0x60], rax
0000000141276d53: mov      rdx, qword ptr [rdi]
0000000141276d56: mov      rcx, rdi
0000000141276d59: call     qword ptr [rdx + 0x10]
0000000141276d5c: nop      
0000000141276d5d: mov      eax, esi
0000000141276d5f: add      rsp, 0x1e8
0000000141276d66: pop      r15
0000000141276d68: pop      r14
0000000141276d6a: pop      r13
0000000141276d6c: pop      r12
0000000141276d6e: pop      rdi
0000000141276d6f: pop      rsi
0000000141276d70: pop      rbx
0000000141276d71: pop      rbp
0000000141276d72: ret      
