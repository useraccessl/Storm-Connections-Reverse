0000000140a67430: mov      qword ptr [rsp + 0x10], rdx
0000000140a67435: mov      qword ptr [rsp + 8], rcx
0000000140a6743a: push     rbx
0000000140a6743b: push     rbp
0000000140a6743c: push     rsi
0000000140a6743d: push     rdi
0000000140a6743e: push     r12
0000000140a67440: push     r13
0000000140a67442: push     r14
0000000140a67444: push     r15
0000000140a67446: sub      rsp, 0x38
0000000140a6744a: mov      rdi, rdx
0000000140a6744d: mov      ecx, 5
0000000140a67452: call     0x141273960
0000000140a67457: xor      ebx, ebx
0000000140a67459: lea      r11, [rip + 0xe88314]
0000000140a67460: mov      r9, r11
0000000140a67463: inc      r9
0000000140a67466: cmp      byte ptr [r9], bl
0000000140a67469: jne      0x140a67463
0000000140a6746b: sub      r9, r11
0000000140a6746e: mov      rdi, qword ptr [rdi + 0x40]
0000000140a67472: mov      r10, rdi
0000000140a67475: lea      rsi, [rip + 0x17276d4]
0000000140a6747c: test     rdi, rdi
0000000140a6747f: je       0x140a674cb
0000000140a67481: mov      rcx, qword ptr [r10]
0000000140a67484: test     rcx, rcx
0000000140a67487: je       0x140a6748f
0000000140a67489: mov      rax, qword ptr [r10 + 0x10]
0000000140a6748d: jmp      0x140a67495
0000000140a6748f: mov      rax, rbx
0000000140a67492: mov      rcx, rsi
0000000140a67495: cmp      rax, r9
0000000140a67498: jne      0x140a674c2
0000000140a6749a: lea      r8, [rax + rcx]
0000000140a6749e: cmp      rcx, r8
0000000140a674a1: jae      0x140a674ce
0000000140a674a3: mov      rdx, r11
0000000140a674a6: sub      rdx, rcx
0000000140a674a9: nop      dword ptr [rax]
0000000140a674b0: movzx    eax, byte ptr [rdx + rcx]
0000000140a674b4: cmp      byte ptr [rcx], al
0000000140a674b6: jne      0x140a674c2
0000000140a674b8: inc      rcx
0000000140a674bb: cmp      rcx, r8
0000000140a674be: jae      0x140a674ce
0000000140a674c0: jmp      0x140a674b0
0000000140a674c2: mov      r10, qword ptr [r10 + 0x30]
0000000140a674c6: test     r10, r10
0000000140a674c9: jne      0x140a67481
0000000140a674cb: mov      r10, rbx
0000000140a674ce: lea      r11, [rip + 0xe92363]
0000000140a674d5: mov      r9, r11
0000000140a674d8: inc      r9
0000000140a674db: cmp      byte ptr [r9], bl
0000000140a674de: jne      0x140a674d8
0000000140a674e0: sub      r9, r11
0000000140a674e3: test     rdi, rdi
0000000140a674e6: je       0x140a6752b
0000000140a674e8: mov      rcx, qword ptr [rdi]
0000000140a674eb: test     rcx, rcx
0000000140a674ee: je       0x140a674f6
0000000140a674f0: mov      rax, qword ptr [rdi + 0x10]
0000000140a674f4: jmp      0x140a674fc
0000000140a674f6: mov      rax, rbx
0000000140a674f9: mov      rcx, rsi
0000000140a674fc: cmp      rax, r9
0000000140a674ff: jne      0x140a67522
0000000140a67501: lea      r8, [rax + rcx]
0000000140a67505: cmp      rcx, r8
0000000140a67508: jae      0x140a6752e
0000000140a6750a: mov      rdx, r11
0000000140a6750d: sub      rdx, rcx
0000000140a67510: movzx    eax, byte ptr [rdx + rcx]
0000000140a67514: cmp      byte ptr [rcx], al
0000000140a67516: jne      0x140a67522
0000000140a67518: inc      rcx
0000000140a6751b: cmp      rcx, r8
0000000140a6751e: jae      0x140a6752e
0000000140a67520: jmp      0x140a67510
0000000140a67522: mov      rdi, qword ptr [rdi + 0x30]
0000000140a67526: test     rdi, rdi
0000000140a67529: jne      0x140a674e8
0000000140a6752b: mov      rdi, rbx
0000000140a6752e: test     r10, r10
0000000140a67531: je       0x140a67a7e
0000000140a67537: test     rdi, rdi
0000000140a6753a: je       0x140a67a7e
0000000140a67540: mov      rax, qword ptr [r10 + 8]
0000000140a67544: mov      rcx, rsi
0000000140a67547: test     rax, rax
0000000140a6754a: cmovne   rcx, rax
0000000140a6754e: call     qword ptr [rip + 0xcce7ac]
0000000140a67554: mov      dword ptr [rsp + 0x20], eax
0000000140a67558: mov      rax, qword ptr [rdi + 8]
0000000140a6755c: mov      rcx, rsi
0000000140a6755f: test     rax, rax
0000000140a67562: cmovne   rcx, rax
0000000140a67566: call     0x140a6c5b0
0000000140a6756b: mov      edi, eax
0000000140a6756d: mov      r8d, 0x19a
0000000140a67573: lea      rdx, [rip + 0xf0d656]
0000000140a6757a: lea      ecx, [r8 - 0x22]
0000000140a6757e: call     0x141272600
0000000140a67583: mov      rsi, rax
0000000140a67586: mov      qword ptr [rsp + 0x28], rax
0000000140a6758b: test     rax, rax
0000000140a6758e: je       0x140a67a7e
0000000140a67594: mov      qword ptr [rax], rbx
0000000140a67597: mov      qword ptr [rax + 8], rbx
0000000140a6759b: mov      qword ptr [rax + 0x10], rbx
0000000140a6759f: mov      qword ptr [rax + 0xb8], rbx
0000000140a675a6: mov      qword ptr [rax + 0xc0], rbx
0000000140a675ad: mov      qword ptr [rax + 0xc8], rbx
0000000140a675b4: mov      dword ptr [rax + 0xd0], ebx
0000000140a675ba: mov      qword ptr [rax + 0xd8], rbx
0000000140a675c1: mov      qword ptr [rax + 0xe0], rbx
0000000140a675c8: mov      qword ptr [rax + 0xe8], rbx
0000000140a675cf: mov      dword ptr [rax + 0xf0], ebx
0000000140a675d5: mov      qword ptr [rax + 0xf8], rbx
0000000140a675dc: mov      qword ptr [rax + 0x100], rbx
0000000140a675e3: mov      dword ptr [rax + 0x108], ebx
0000000140a675e9: mov      qword ptr [rax + 0x158], rbx
0000000140a675f0: mov      dword ptr [rax + 0x160], ebx
0000000140a675f6: mov      qword ptr [rax + 0x168], rbx
0000000140a675fd: mov      dword ptr [rax + 0x170], ebx
0000000140a67603: lea      rcx, [rax + 0x18]
0000000140a67607: xor      edx, edx
0000000140a67609: mov      r8d, 0xa0
0000000140a6760f: call     0x141442fc4
0000000140a67614: xorps    xmm0, xmm0
0000000140a67617: xor      eax, eax
0000000140a67619: movups   xmmword ptr [rsi + 0x10c], xmm0
0000000140a67620: movups   xmmword ptr [rsi + 0x11c], xmm0
0000000140a67627: movups   xmmword ptr [rsi + 0x12c], xmm0
0000000140a6762e: movups   xmmword ptr [rsi + 0x13c], xmm0
0000000140a67635: mov      qword ptr [rsi + 0x14c], rax
0000000140a6763c: mov      dword ptr [rsi + 0x154], eax
0000000140a67642: mov      dword ptr [rsi], edi
0000000140a67644: mov      ebp, ebx
0000000140a67646: mov      r14d, ebx
0000000140a67649: mov      r15d, ebx
0000000140a6764c: mov      r12d, ebx
0000000140a6764f: mov      r13d, ebx
0000000140a67652: mov      rdi, qword ptr [rsp + 0x88]
0000000140a6765a: mov      rdi, qword ptr [rdi + 0x30]
0000000140a6765e: test     rdi, rdi
0000000140a67661: je       0x140a67a33
0000000140a67667: mov      esi, eax
0000000140a67669: mov      ebx, eax
0000000140a6766b: nop      dword ptr [rax + rax]
0000000140a67670: mov      rax, qword ptr [rdi]
0000000140a67673: lea      rcx, [rip + 0x17274d6]
0000000140a6767a: test     rax, rax
0000000140a6767d: cmovne   rcx, rax
0000000140a67681: call     0x140a664f0
0000000140a67686: cmp      eax, 0x14
0000000140a67689: ja       0x140a676be
0000000140a6768b: cdqe     
0000000140a6768d: lea      rdx, [rip - 0xa67694]
0000000140a67694: mov      ecx, dword ptr [rdx + rax*4 + 0xa67a98]
0000000140a6769b: add      rcx, rdx
0000000140a6769e: jmp      rcx
0000000140a676a0: inc      ebp
0000000140a676a2: jmp      0x140a676be
0000000140a676a4: inc      r14d
0000000140a676a7: jmp      0x140a676be
0000000140a676a9: inc      r15d
0000000140a676ac: jmp      0x140a676be
0000000140a676ae: inc      r12d
0000000140a676b1: jmp      0x140a676be
0000000140a676b3: inc      r13d
0000000140a676b6: jmp      0x140a676be
0000000140a676b8: inc      esi
0000000140a676ba: jmp      0x140a676be
0000000140a676bc: inc      ebx
0000000140a676be: mov      rdi, qword ptr [rdi + 0x58]
0000000140a676c2: test     rdi, rdi
0000000140a676c5: jne      0x140a67670
0000000140a676c7: mov      dword ptr [rsp + 0x98], ebx
0000000140a676ce: mov      dword ptr [rsp + 0x90], esi
0000000140a676d5: lea      rcx, [rdi - 1]
0000000140a676d9: test     ebp, ebp
0000000140a676db: mov      rbx, rdi
0000000140a676de: mov      rsi, qword ptr [rsp + 0x28]
0000000140a676e3: je       0x140a6774a
0000000140a676e5: mov      edi, ebp
0000000140a676e7: mov      eax, 0x10
0000000140a676ec: mul      rdi
0000000140a676ef: cmovo    rax, rcx
0000000140a676f3: mov      r8d, 0x1bb
0000000140a676f9: lea      rdx, [rip + 0xf0d4d0]
0000000140a67700: mov      rcx, rax
0000000140a67703: call     0x141272e00
0000000140a67708: mov      rcx, rax
0000000140a6770b: mov      qword ptr [rsp + 0x28], rax
0000000140a67710: test     rax, rax
0000000140a67713: je       0x140a67739
0000000140a67715: test     ebp, ebp
0000000140a67717: je       0x140a6773c
0000000140a67719: add      rax, 8
0000000140a6771d: nop      dword ptr [rax]
0000000140a67720: mov      qword ptr [rax - 8], rbx
0000000140a67724: mov      dword ptr [rax], ebx
0000000140a67726: mov      dword ptr [rax + 4], 0x3f800000
0000000140a6772d: lea      rax, [rax + 0x10]
0000000140a67731: sub      rdi, 1
0000000140a67735: jne      0x140a67720
0000000140a67737: jmp      0x140a6773c
0000000140a67739: mov      rcx, rbx
0000000140a6773c: mov      qword ptr [rsi + 0xc8], rcx
0000000140a67743: mov      rcx, 0xffffffffffffffff
0000000140a6774a: test     r14d, r14d
0000000140a6774d: je       0x140a677b0
0000000140a6774f: mov      edi, r14d
0000000140a67752: mov      eax, 0x14
0000000140a67757: mul      rdi
0000000140a6775a: cmovo    rax, rcx
0000000140a6775e: mov      r8d, 0x1c0
0000000140a67764: lea      rdx, [rip + 0xf0d465]
0000000140a6776b: mov      rcx, rax
0000000140a6776e: call     0x141272e00
0000000140a67773: mov      rcx, rax
0000000140a67776: mov      qword ptr [rsp + 0x28], rax
0000000140a6777b: test     rax, rax
0000000140a6777e: je       0x140a677a6
0000000140a67780: test     r14d, r14d
0000000140a67783: je       0x140a677a9
0000000140a67785: add      rax, 8
0000000140a67789: nop      dword ptr [rax]
0000000140a67790: mov      qword ptr [rax - 8], rbx
0000000140a67794: mov      qword ptr [rax], rbx
0000000140a67797: mov      dword ptr [rax + 8], ebx
0000000140a6779a: lea      rax, [rax + 0x14]
0000000140a6779e: sub      rdi, 1
0000000140a677a2: jne      0x140a67790
0000000140a677a4: jmp      0x140a677a9
0000000140a677a6: mov      rcx, rbx
0000000140a677a9: mov      qword ptr [rsi + 0xd8], rcx
0000000140a677b0: test     r15d, r15d
0000000140a677b3: je       0x140a67823
0000000140a677b5: mov      edi, r15d
0000000140a677b8: mov      eax, 0x40
0000000140a677bd: mul      rdi
0000000140a677c0: mov      r15, 0xffffffffffffffff
0000000140a677c7: cmovo    rax, r15
0000000140a677cb: mov      r8d, 0x1c5
0000000140a677d1: lea      rdx, [rip + 0xf0d3f8]
0000000140a677d8: mov      rcx, rax
0000000140a677db: call     0x141272e00
0000000140a677e0: mov      rcx, rax
0000000140a677e3: mov      qword ptr [rsp + 0x28], rax
0000000140a677e8: test     rax, rax
0000000140a677eb: je       0x140a67817
0000000140a677ed: test     rdi, rdi
0000000140a677f0: je       0x140a6781a
0000000140a677f2: xorps    xmm0, xmm0
0000000140a677f5: movups   xmmword ptr [rax], xmm0
0000000140a677f8: movups   xmmword ptr [rax + 0x10], xmm0
0000000140a677fc: movups   xmmword ptr [rax + 0x20], xmm0
0000000140a67800: movups   xmmword ptr [rax + 0x30], xmm0
0000000140a67804: lea      rax, [rax + 0x40]
0000000140a67808: sub      rdi, 1
0000000140a6780c: jne      0x140a677f2
0000000140a6780e: mov      qword ptr [rsi + 0xe8], rcx
0000000140a67815: jmp      0x140a6782a
0000000140a67817: mov      rcx, rbx
0000000140a6781a: mov      qword ptr [rsi + 0xe8], rcx
0000000140a67821: jmp      0x140a6782a
0000000140a67823: mov      r15, 0xffffffffffffffff
0000000140a6782a: test     r12d, r12d
0000000140a6782d: je       0x140a67896
0000000140a6782f: mov      edi, r12d
0000000140a67832: mov      eax, 0x20
0000000140a67837: mul      rdi
0000000140a6783a: cmovo    rax, r15
0000000140a6783e: mov      r8d, 0x1ca
0000000140a67844: lea      rdx, [rip + 0xf0d385]
0000000140a6784b: mov      rcx, rax
0000000140a6784e: call     0x141272e00
0000000140a67853: mov      rcx, rax
0000000140a67856: mov      qword ptr [rsp + 0x28], rax
0000000140a6785b: test     rax, rax
0000000140a6785e: je       0x140a6788c
0000000140a67860: test     r12d, r12d
0000000140a67863: je       0x140a6788f
0000000140a67865: add      rax, 8
0000000140a67869: nop      dword ptr [rax]
0000000140a67870: mov      word ptr [rax - 8], bx
0000000140a67874: mov      qword ptr [rax - 4], rbx
0000000140a67878: mov      qword ptr [rax + 4], rbx
0000000140a6787c: mov      qword ptr [rax + 0xc], rbx
0000000140a67880: lea      rax, [rax + 0x20]
0000000140a67884: sub      rdi, 1
0000000140a67888: jne      0x140a67870
0000000140a6788a: jmp      0x140a6788f
0000000140a6788c: mov      rcx, rbx
0000000140a6788f: mov      qword ptr [rsi + 0xb8], rcx
0000000140a67896: test     r13d, r13d
0000000140a67899: je       0x140a67937
0000000140a6789f: mov      ebp, r13d
0000000140a678a2: mov      eax, 0xf8
0000000140a678a7: mul      rbp
0000000140a678aa: cmovo    rax, r15
0000000140a678ae: mov      r8d, 0x1cf
0000000140a678b4: lea      rdx, [rip + 0xf0d315]
0000000140a678bb: mov      rcx, rax
0000000140a678be: call     0x141272e00
0000000140a678c3: mov      r14, rax
0000000140a678c6: mov      qword ptr [rsp + 0x28], rax
0000000140a678cb: test     rax, rax
0000000140a678ce: je       0x140a6792d
0000000140a678d0: test     r13d, r13d
0000000140a678d3: je       0x140a67930
0000000140a678d5: lea      rdi, [rax + 0x48]
0000000140a678d9: nop      dword ptr [rax]
0000000140a678e0: mov      dword ptr [rdi - 0x48], r15d
0000000140a678e4: mov      dword ptr [rdi - 0x24], r15d
0000000140a678e8: mov      qword ptr [rdi], 0
0000000140a678ef: lea      rcx, [rdi + 8]
0000000140a678f3: lea      r9, [rip - 0x6de50a]
0000000140a678fa: mov      edx, 0x54
0000000140a678ff: lea      r8d, [rdx - 0x52]
0000000140a67903: call     0x1400afd00
0000000140a67908: xorps    xmm0, xmm0
0000000140a6790b: movups   xmmword ptr [rdi - 0x44], xmm0
0000000140a6790f: movups   xmmword ptr [rdi - 0x34], xmm0
0000000140a67913: xorps    xmm1, xmm1
0000000140a67916: movups   xmmword ptr [rdi - 0x20], xmm1
0000000140a6791a: movups   xmmword ptr [rdi - 0x10], xmm1
0000000140a6791e: lea      rdi, [rdi + 0xf8]
0000000140a67925: sub      rbp, 1
0000000140a67929: jne      0x140a678e0
0000000140a6792b: jmp      0x140a67930
0000000140a6792d: mov      r14, rbx
0000000140a67930: mov      qword ptr [rsi + 0xf8], r14
0000000140a67937: mov      eax, dword ptr [rsp + 0x90]
0000000140a6793e: test     eax, eax
0000000140a67940: je       0x140a679ba
0000000140a67942: mov      edi, eax
0000000140a67944: mov      eax, 0x68
0000000140a67949: mul      rdi
0000000140a6794c: cmovo    rax, r15
0000000140a67950: mov      r8d, 0x1d4
0000000140a67956: lea      rdx, [rip + 0xf0d273]
0000000140a6795d: mov      rcx, rax
0000000140a67960: call     0x141272e00
0000000140a67965: mov      rcx, rax
0000000140a67968: mov      qword ptr [rsp + 0x90], rax
0000000140a67970: test     rax, rax
0000000140a67973: je       0x140a679b0
0000000140a67975: test     rdi, rdi
0000000140a67978: je       0x140a679b3
0000000140a6797a: add      rax, 0x40
0000000140a6797e: nop      
0000000140a67980: xorps    xmm0, xmm0
0000000140a67983: movups   xmmword ptr [rax - 0x40], xmm0
0000000140a67987: movups   xmmword ptr [rax - 0x30], xmm0
0000000140a6798b: xorps    xmm1, xmm1
0000000140a6798e: movups   xmmword ptr [rax - 0x20], xmm1
0000000140a67992: movups   xmmword ptr [rax - 0x10], xmm1
0000000140a67996: mov      dword ptr [rax], r15d
0000000140a67999: movups   xmmword ptr [rax + 4], xmm0
0000000140a6799d: movups   xmmword ptr [rax + 0x14], xmm0
0000000140a679a1: mov      dword ptr [rax + 0x24], ebx
0000000140a679a4: lea      rax, [rax + 0x68]
0000000140a679a8: sub      rdi, 1
0000000140a679ac: jne      0x140a67980
0000000140a679ae: jmp      0x140a679b3
0000000140a679b0: mov      rcx, rbx
0000000140a679b3: mov      qword ptr [rsi + 0x158], rcx
0000000140a679ba: mov      eax, dword ptr [rsp + 0x98]
0000000140a679c1: test     eax, eax
0000000140a679c3: je       0x140a67a33
0000000140a679c5: mov      edi, eax
0000000140a679c7: mov      eax, 0x2c
0000000140a679cc: mul      rdi
0000000140a679cf: cmovo    rax, r15
0000000140a679d3: mov      r8d, 0x1d9
0000000140a679d9: lea      rdx, [rip + 0xf0d1f0]
0000000140a679e0: mov      rcx, rax
0000000140a679e3: call     0x141272e00
0000000140a679e8: mov      rcx, rax
0000000140a679eb: mov      qword ptr [rsp + 0x90], rax
0000000140a679f3: test     rax, rax
0000000140a679f6: je       0x140a67a29
0000000140a679f8: test     rdi, rdi
0000000140a679fb: je       0x140a67a2c
0000000140a679fd: add      rax, 0x28
0000000140a67a01: mov      dword ptr [rax - 0x28], r15d
0000000140a67a05: mov      dword ptr [rax - 4], 0x3f800000
0000000140a67a0c: mov      dword ptr [rax], 0x3f800000
0000000140a67a12: xorps    xmm0, xmm0
0000000140a67a15: movups   xmmword ptr [rax - 0x24], xmm0
0000000140a67a19: movups   xmmword ptr [rax - 0x14], xmm0
0000000140a67a1d: lea      rax, [rax + 0x2c]
0000000140a67a21: sub      rdi, 1
0000000140a67a25: jne      0x140a67a01
0000000140a67a27: jmp      0x140a67a2c
0000000140a67a29: mov      rcx, rbx
0000000140a67a2c: mov      qword ptr [rsi + 0x168], rcx
0000000140a67a33: mov      rbx, qword ptr [rsp + 0x88]
0000000140a67a3b: mov      rbx, qword ptr [rbx + 0x30]
0000000140a67a3f: test     rbx, rbx
0000000140a67a42: je       0x140a67a58
0000000140a67a44: mov      rdx, rbx
0000000140a67a47: mov      rcx, rsi
0000000140a67a4a: call     0x140a67af0
0000000140a67a4f: mov      rbx, qword ptr [rbx + 0x58]
0000000140a67a53: test     rbx, rbx
0000000140a67a56: jne      0x140a67a44
0000000140a67a58: mov      ecx, dword ptr [rsp + 0x20]
0000000140a67a5c: mov      eax, 1
0000000140a67a61: shl      eax, cl
0000000140a67a63: mov      rdx, qword ptr [rsp + 0x80]
0000000140a67a6b: or       dword ptr [rdx + 0x354], eax
0000000140a67a71: mov      qword ptr [rdx + rcx*8 + 0x358], rsi
0000000140a67a79: mov      ebx, 1
0000000140a67a7e: call     0x141273900
0000000140a67a83: mov      eax, ebx
0000000140a67a85: add      rsp, 0x38
0000000140a67a89: pop      r15
0000000140a67a8b: pop      r14
0000000140a67a8d: pop      r13
0000000140a67a8f: pop      r12
0000000140a67a91: pop      rdi
0000000140a67a92: pop      rsi
0000000140a67a93: pop      rbp
0000000140a67a94: pop      rbx
0000000140a67a95: ret      
0000000140a67a96: nop      
0000000140a67a98: movsb    byte ptr [rdi], byte ptr [rsi]
0000000140a67a99: jbe      0x140a67a41
0000000140a67a9b: add      byte ptr [rax - 0x56ff598a], ah
0000000140a67aa1: jbe      0x140a67a49
0000000140a67aa3: add      byte ptr [rsi - 0x4cff598a], ch
0000000140a67aa9: jbe      0x140a67a51
0000000140a67aab: add      byte ptr [rsi - 0x41ff598a], bh
0000000140a67ab1: jbe      0x140a67a59
0000000140a67ab3: add      byte ptr [rsi - 0x41ff598a], bh
0000000140a67ab9: jbe      0x140a67a61
0000000140a67abb: add      byte ptr [rsi - 0x41ff598a], bh
0000000140a67ac1: jbe      0x140a67a69
0000000140a67ac3: add      byte ptr [rsi - 0x41ff598a], bh
0000000140a67ac9: jbe      0x140a67a71
0000000140a67acb: add      byte ptr [rsi - 0x41ff598a], bh
0000000140a67ad1: jbe      0x140a67a79
0000000140a67ad3: add      byte ptr [rsi - 0x41ff598a], bh
0000000140a67ad9: jbe      0x140a67a81
0000000140a67adb: add      byte ptr [rsi - 0x41ff598a], bh
0000000140a67ae1: jbe      0x140a67a89
0000000140a67ae3: add      byte ptr [rax - 0x43ff598a], bh
0000000140a67ae9: jbe      0x140a67a91
