000000014130b200: mov      r11, rsp
000000014130b203: mov      qword ptr [r11 + 0x18], rbx
000000014130b207: push     rsi
000000014130b208: push     rdi
000000014130b209: push     r14
000000014130b20b: sub      rsp, 0xd0
000000014130b212: movaps   xmmword ptr [r11 - 0x28], xmm6
000000014130b217: movaps   xmmword ptr [r11 - 0x58], xmm9
000000014130b21c: movaps   xmmword ptr [r11 - 0x68], xmm10
000000014130b221: mov      rax, qword ptr [rip + 0xddb1a0]
000000014130b228: xor      rax, rsp
000000014130b22b: mov      qword ptr [rsp + 0x70], rax
000000014130b230: movss    xmm9, dword ptr [rcx + 0x19c]
000000014130b239: mov      edi, edx
000000014130b23b: mulss    xmm9, dword ptr [rcx + 0x198]
000000014130b244: mov      rbx, rcx
000000014130b247: mov      eax, dword ptr [rcx + 0x74]
000000014130b24a: mov      esi, 1
000000014130b24f: movaps   xmmword ptr [r11 - 0x38], xmm7
000000014130b254: movss    xmm7, dword ptr [rip + 0x456384]
000000014130b25c: movaps   xmmword ptr [r11 - 0x48], xmm8
000000014130b261: movaps   xmm0, xmm9
000000014130b265: movaps   xmm8, xmm9
000000014130b269: movaps   xmm6, xmm7
000000014130b26c: addss    xmm0, dword ptr [rcx + 0x1a0]
000000014130b274: addss    xmm8, dword ptr [rcx + 0x70]
000000014130b27a: movss    dword ptr [rcx + 0x1a0], xmm0
000000014130b282: movss    dword ptr [rcx + 0x70], xmm8
000000014130b288: test     eax, eax
000000014130b28a: je       0x14130b2a0
000000014130b28c: xorps    xmm0, xmm0
000000014130b28f: movaps   xmm1, xmm8
000000014130b293: cvtsi2ss xmm0, rax
000000014130b298: divss    xmm1, xmm0
000000014130b29c: minss    xmm6, xmm1
000000014130b2a0: movss    xmm3, dword ptr [rcx + 0x104]
000000014130b2a8: xorps    xmm10, xmm10
000000014130b2ac: ucomiss  xmm3, xmm10
000000014130b2b0: andps    xmm6, xmmword ptr [rip + 0x495b89]
000000014130b2b7: jp       0x14130b2bb
000000014130b2b9: je       0x14130b330
000000014130b2bb: comiss   xmm3, xmm6
000000014130b2be: movaps   xmm2, xmm7
000000014130b2c1: ja       0x14130b2f9
000000014130b2c3: ucomiss  xmm8, xmm10
000000014130b2c7: jp       0x14130b2cb
000000014130b2c9: je       0x14130b2f9
000000014130b2cb: comiss   xmm6, xmm3
000000014130b2ce: jbe      0x14130b330
000000014130b2d0: movaps   xmm1, xmm6
000000014130b2d3: lea      rdx, [rcx + 0xec]
000000014130b2da: movaps   xmm0, xmm7
000000014130b2dd: subss    xmm1, xmm3
000000014130b2e1: subss    xmm0, xmm3
000000014130b2e5: movaps   xmm2, xmm7
000000014130b2e8: lea      r8, [rcx + 0xf8]
000000014130b2ef: divss    xmm1, xmm0
000000014130b2f3: subss    xmm2, xmm1
000000014130b2f7: jmp      0x14130b31d
000000014130b2f9: ucomiss  xmm8, xmm10
000000014130b2fd: lea      rdx, [rcx + 0xe0]
000000014130b304: lea      r8, [rcx + 0xec]
000000014130b30b: jp       0x14130b30f
000000014130b30d: je       0x14130b31d
000000014130b30f: movaps   xmm0, xmm6
000000014130b312: movaps   xmm2, xmm7
000000014130b315: divss    xmm0, xmm3
000000014130b319: subss    xmm2, xmm0
000000014130b31d: movaps   xmm3, xmm7
000000014130b320: add      rcx, 0x88
000000014130b327: minss    xmm3, xmm2
000000014130b32b: call     0x1412cd690
000000014130b330: movss    xmm1, dword ptr [rbx + 0x150]
000000014130b338: movaps   xmm0, xmm7
000000014130b33b: comiss   xmm1, xmm6
000000014130b33e: jbe      0x14130b35c
000000014130b340: ucomiss  xmm8, xmm10
000000014130b344: lea      rdx, [rbx + 0x120]
000000014130b34b: lea      r8, [rbx + 0x130]
000000014130b352: jp       0x14130b356
000000014130b354: je       0x14130b385
000000014130b356: divss    xmm6, xmm1
000000014130b35a: jmp      0x14130b37e
000000014130b35c: comiss   xmm6, xmm1
000000014130b35f: jb       0x14130b398
000000014130b361: movaps   xmm0, xmm7
000000014130b364: subss    xmm6, xmm1
000000014130b368: subss    xmm0, xmm1
000000014130b36c: lea      rdx, [rbx + 0x130]
000000014130b373: lea      r8, [rbx + 0x140]
000000014130b37a: divss    xmm6, xmm0
000000014130b37e: movaps   xmm0, xmm7
000000014130b381: subss    xmm0, xmm6
000000014130b385: movaps   xmm3, xmm7
000000014130b388: lea      rcx, [rbx + 0x110]
000000014130b38f: minss    xmm3, xmm0
000000014130b393: call     0x1412ccd10
000000014130b398: movss    xmm6, dword ptr [rbx + 0x11c]
000000014130b3a0: xor      r14d, r14d
000000014130b3a3: mov      ecx, dword ptr [rbx + 0x184]
000000014130b3a9: movaps   xmm8, xmmword ptr [rsp + 0xa0]
000000014130b3b2: movss    dword ptr [rbx + 0x6c], xmm6
000000014130b3b7: test     ecx, ecx
000000014130b3b9: je       0x14130b411
000000014130b3bb: sub      ecx, esi
000000014130b3bd: je       0x14130b3f0
000000014130b3bf: cmp      ecx, esi
000000014130b3c1: jne      0x14130b436
000000014130b3c3: movss    xmm1, dword ptr [rbx + 0x68]
000000014130b3c8: movaps   xmm0, xmm9
000000014130b3cc: mulss    xmm0, dword ptr [rbx + 0x64]
000000014130b3d1: subss    xmm1, xmm0
000000014130b3d5: comiss   xmm10, xmm1
000000014130b3d9: movss    dword ptr [rbx + 0x68], xmm1
000000014130b3de: jb       0x14130b436
000000014130b3e0: mov      dword ptr [rbx + 0x68], r14d
000000014130b3e4: mov      dword ptr [rbx + 0x184], 3
000000014130b3ee: jmp      0x14130b436
000000014130b3f0: mov      eax, dword ptr [rbx + 0x78]
000000014130b3f3: xorps    xmm1, xmm1
000000014130b3f6: movss    xmm0, dword ptr [rbx + 0x70]
000000014130b3fb: cvtsi2ss xmm1, rax
000000014130b400: comiss   xmm0, xmm1
000000014130b403: jbe      0x14130b436
000000014130b405: mov      dword ptr [rbx + 0x184], 2
000000014130b40f: jmp      0x14130b436
000000014130b411: movaps   xmm0, xmm9
000000014130b415: mulss    xmm0, dword ptr [rbx + 0x60]
000000014130b41a: addss    xmm0, dword ptr [rbx + 0x68]
000000014130b41f: comiss   xmm0, xmm7
000000014130b422: movss    dword ptr [rbx + 0x68], xmm0
000000014130b427: jb       0x14130b436
000000014130b429: mov      dword ptr [rbx + 0x68], 0x3f800000
000000014130b430: mov      dword ptr [rbx + 0x184], esi
000000014130b436: mov      ecx, dword ptr [rbx + 0x50]
000000014130b439: mulss    xmm6, dword ptr [rbx + 0x68]
000000014130b43e: movaps   xmm7, xmmword ptr [rsp + 0xb0]
000000014130b446: sub      ecx, esi
000000014130b448: je       0x14130b63d
000000014130b44e: sub      ecx, esi
000000014130b450: je       0x14130b58b
000000014130b456: sub      ecx, esi
000000014130b458: je       0x14130b691
000000014130b45e: sub      ecx, esi
000000014130b460: je       0x14130b691
000000014130b466: cmp      ecx, esi
000000014130b468: je       0x14130b472
000000014130b46a: mov      esi, r14d
000000014130b46d: jmp      0x14130b691
000000014130b472: cmp      qword ptr [rbx + 0x40], r14
000000014130b476: je       0x14130b691
000000014130b47c: movss    xmm1, dword ptr [rbx + 0x1a0]
000000014130b484: mov      qword ptr [rsp + 0xf8], rbp
000000014130b48c: cvttss2si ebp, xmm1
000000014130b490: test     ebp, ebp
000000014130b492: jle      0x14130b4b8
000000014130b494: mov      edi, ebp
000000014130b496: nop      word ptr [rax + rax]
000000014130b4a0: mov      rcx, qword ptr [rbx + 0x40]
000000014130b4a4: mov      edx, esi
000000014130b4a6: call     0x1412c7b00
000000014130b4ab: sub      rdi, rsi
000000014130b4ae: jne      0x14130b4a0
000000014130b4b0: movss    xmm1, dword ptr [rbx + 0x1a0]
000000014130b4b8: movd     xmm0, ebp
000000014130b4bc: lea      rcx, [rsp + 0x20]
000000014130b4c1: cvtdq2ps xmm0, xmm0
000000014130b4c4: subss    xmm1, xmm0
000000014130b4c8: movss    dword ptr [rbx + 0x1a0], xmm1
000000014130b4d0: call     0x1412a0c20
000000014130b4d5: movss    xmm0, dword ptr [rbx + 0x1b0]
000000014130b4dd: mulss    xmm0, dword ptr [rbx + 0x88]
000000014130b4e5: mov      rcx, qword ptr [rbx + 0x40]
000000014130b4e9: movss    xmm1, dword ptr [rbx + 0x1b4]
000000014130b4f1: mulss    xmm1, dword ptr [rbx + 0x8c]
000000014130b4f9: mov      rbp, qword ptr [rsp + 0xf8]
000000014130b501: movss    dword ptr [rsp + 0x20], xmm0
000000014130b507: movsd    xmm0, qword ptr [rbx + 0x7c]
000000014130b50c: movss    dword ptr [rsp + 0x24], xmm1
000000014130b512: movsd    qword ptr [rcx + 0x2b0], xmm0
000000014130b51a: mov      eax, dword ptr [rbx + 0x84]
000000014130b520: mov      dword ptr [rcx + 0x2b8], eax
000000014130b526: mov      rax, qword ptr [rbx + 0x40]
000000014130b52a: movsd    xmm0, qword ptr [rsp + 0x20]
000000014130b530: movsd    qword ptr [rax + 0x2c0], xmm0
000000014130b538: movss    xmm1, dword ptr [rbx + 0x98]
000000014130b540: comiss   xmm10, xmm1
000000014130b544: mov      rcx, qword ptr [rbx + 0x40]
000000014130b548: jbe      0x14130b554
000000014130b54a: movss    xmm0, dword ptr [rip + 0x45ef22]
000000014130b552: jmp      0x14130b55c
000000014130b554: movss    xmm0, dword ptr [rip + 0x45eeec]
000000014130b55c: mulss    xmm1, dword ptr [rip + 0x474c9c]
000000014130b564: divss    xmm1, dword ptr [rip + 0x45eeec]
000000014130b56c: addss    xmm1, xmm0
000000014130b570: cvttss2si eax, xmm1
000000014130b574: mov      dword ptr [rcx + 0x2bc], eax
000000014130b57a: mov      rax, qword ptr [rbx + 0x40]
000000014130b57e: movss    dword ptr [rax + 0x2f4], xmm6
000000014130b586: jmp      0x14130b691
000000014130b58b: mov      rcx, qword ptr [rbx + 0x40]
000000014130b58f: test     rcx, rcx
000000014130b592: je       0x14130b691
000000014130b598: mov      rax, qword ptr [rcx]
000000014130b59b: call     qword ptr [rax + 0x28]
000000014130b59e: cmp      edi, esi
000000014130b5a0: jne      0x14130b5d3
000000014130b5a2: lea      rdx, [rbx + 0xa0]
000000014130b5a9: lea      rcx, [rsp + 0x30]
000000014130b5ae: call     0x14127e3b0
000000014130b5b3: lea      rdx, [rbx + 0x1b0]
000000014130b5ba: lea      rcx, [rsp + 0x30]
000000014130b5bf: call     0x141281e90
000000014130b5c4: mov      rcx, qword ptr [rbx + 0x40]
000000014130b5c8: lea      rdx, [rsp + 0x30]
000000014130b5cd: mov      rax, qword ptr [rcx]
000000014130b5d0: call     qword ptr [rax + 0x48]
000000014130b5d3: mov      rax, qword ptr [rip + 0x83fdf3e]
000000014130b5da: movaps   xmm1, xmm6
000000014130b5dd: movzx    ecx, byte ptr [rax + 0x952]
000000014130b5e4: mov      rax, qword ptr [rbx + 0x40]
000000014130b5e8: movd     xmm0, ecx
000000014130b5ec: cvtdq2ps xmm0, xmm0
000000014130b5ef: divss    xmm0, dword ptr [rip + 0x458375]
000000014130b5f7: mulss    xmm0, xmm9
000000014130b5fc: movss    dword ptr [rax + 0x48], xmm0
000000014130b601: mov      rcx, qword ptr [rbx + 0x40]
000000014130b605: call     0x1412a3d30
000000014130b60a: mov      rax, qword ptr [rip + 0x83fdf07]
000000014130b611: xor      edx, edx
000000014130b613: mov      rcx, qword ptr [rbx + 0x40]
000000014130b617: movzx    r8d, byte ptr [rax + 0x952]
000000014130b61f: mov      eax, dword ptr [rip + 0x8892c3]
000000014130b625: mov      r9, qword ptr [rcx]
000000014130b628: div      r8d
000000014130b62b: mov      edx, eax
000000014130b62d: call     qword ptr [r9 + 0x30]
000000014130b631: mov      rcx, qword ptr [rbx + 0x40]
000000014130b635: mov      rax, qword ptr [rcx]
000000014130b638: call     qword ptr [rax + 0x38]
000000014130b63b: jmp      0x14130b691
000000014130b63d: mov      rcx, qword ptr [rbx + 0x40]
000000014130b641: test     rcx, rcx
000000014130b644: je       0x14130b691
000000014130b646: call     0x141291cf0
000000014130b64b: cmp      edi, esi
000000014130b64d: jne      0x14130b67f
000000014130b64f: lea      rdx, [rbx + 0xa0]
000000014130b656: lea      rcx, [rsp + 0x30]
000000014130b65b: call     0x14127e3b0
000000014130b660: lea      rdx, [rbx + 0x1b0]
000000014130b667: lea      rcx, [rsp + 0x30]
000000014130b66c: call     0x141281e90
000000014130b671: mov      rcx, qword ptr [rbx + 0x40]
000000014130b675: lea      rdx, [rsp + 0x30]
000000014130b67a: call     0x14128a3a0
000000014130b67f: mov      rcx, qword ptr [rbx + 0x40]
000000014130b683: movss    dword ptr [rcx + 0x38], xmm6
000000014130b688: mov      rcx, qword ptr [rbx + 0x40]
000000014130b68c: call     0x14128cfb0
000000014130b691: mov      ecx, dword ptr [rbx + 0x74]
000000014130b694: xorps    xmm1, xmm1
000000014130b697: movss    xmm0, dword ptr [rbx + 0x70]
000000014130b69c: cvtsi2ss xmm1, rcx
000000014130b6a1: comiss   xmm0, xmm1
000000014130b6a4: cmova    esi, r14d
000000014130b6a8: mov      eax, esi
000000014130b6aa: mov      rcx, qword ptr [rsp + 0x70]
000000014130b6af: xor      rcx, rsp
000000014130b6b2: call     0x141441dc0
000000014130b6b7: lea      r11, [rsp + 0xd0]
000000014130b6bf: mov      rbx, qword ptr [r11 + 0x30]
000000014130b6c3: movaps   xmm6, xmmword ptr [r11 - 0x10]
000000014130b6c8: movaps   xmm9, xmmword ptr [r11 - 0x40]
000000014130b6cd: movaps   xmm10, xmmword ptr [r11 - 0x50]
000000014130b6d2: mov      rsp, r11
000000014130b6d5: pop      r14
000000014130b6d7: pop      rdi
000000014130b6d8: pop      rsi
000000014130b6d9: ret      
