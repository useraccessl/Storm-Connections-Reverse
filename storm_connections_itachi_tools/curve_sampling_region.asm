000000014138e000: pop      rsi
000000014138e001: ret      
000000014138e002: int3     
000000014138e003: int3     
000000014138e004: int3     
000000014138e005: int3     
000000014138e006: int3     
000000014138e007: int3     
000000014138e008: int3     
000000014138e009: int3     
000000014138e00a: int3     
000000014138e00b: int3     
000000014138e00c: int3     
000000014138e00d: int3     
000000014138e00e: int3     
000000014138e00f: int3     
000000014138e010: movaps   xmm0, xmmword ptr [rdx]
000000014138e013: movups   xmmword ptr [rcx + 0x50], xmm0
000000014138e017: ret      
000000014138e018: int3     
000000014138e019: int3     
000000014138e01a: int3     
000000014138e01b: int3     
000000014138e01c: int3     
000000014138e01d: int3     
000000014138e01e: int3     
000000014138e01f: int3     
000000014138e020: sub      rsp, 0x18
000000014138e024: movss    xmm0, dword ptr [rip + 0x69235c]
000000014138e02c: xorps    xmm4, xmm4
000000014138e02f: movzx    eax, dl
000000014138e032: xorps    xmm1, xmm1
000000014138e035: xorps    xmm2, xmm2
000000014138e038: xorps    xmm3, xmm3
000000014138e03b: cvtsi2ss xmm4, eax
000000014138e03f: movzx    eax, r8b
000000014138e043: cvtsi2ss xmm1, eax
000000014138e047: movzx    eax, r9b
000000014138e04b: mulss    xmm4, xmm0
000000014138e04f: cvtsi2ss xmm2, eax
000000014138e053: movzx    eax, byte ptr [rsp + 0x40]
000000014138e058: shufps   xmm4, xmm4, 0xe1
000000014138e05c: mulss    xmm1, xmm0
000000014138e060: cvtsi2ss xmm3, eax
000000014138e064: movss    xmm4, xmm1
000000014138e068: mulss    xmm2, xmm0
000000014138e06c: shufps   xmm4, xmm4, 0xc6
000000014138e070: mulss    xmm3, xmm0
000000014138e074: movss    xmm4, xmm2
000000014138e078: shufps   xmm4, xmm4, 0x27
000000014138e07c: movss    xmm4, xmm3
000000014138e080: shufps   xmm4, xmm4, 0x39
000000014138e084: movups   xmmword ptr [rcx + 0x50], xmm4
000000014138e088: add      rsp, 0x18
000000014138e08c: ret      
000000014138e08d: int3     
000000014138e08e: int3     
000000014138e08f: int3     
000000014138e090: sub      rsp, 0x18
000000014138e094: movss    xmm0, dword ptr [rip + 0x6922ec]
000000014138e09c: xorps    xmm4, xmm4
000000014138e09f: mov      eax, edx
000000014138e0a1: xorps    xmm1, xmm1
000000014138e0a4: shr      eax, 0x18
000000014138e0a7: xorps    xmm2, xmm2
000000014138e0aa: xorps    xmm3, xmm3
000000014138e0ad: cvtsi2ss xmm4, rax
000000014138e0b2: mov      eax, edx
000000014138e0b4: shr      eax, 0x10
000000014138e0b7: movzx    eax, al
000000014138e0ba: mulss    xmm4, xmm0
000000014138e0be: cvtsi2ss xmm1, rax
000000014138e0c3: mov      eax, edx
000000014138e0c5: shr      eax, 8
000000014138e0c8: movzx    eax, al
000000014138e0cb: shufps   xmm4, xmm4, 0xe1
000000014138e0cf: cvtsi2ss xmm2, rax
000000014138e0d4: movzx    eax, dl
000000014138e0d7: cvtsi2ss xmm3, rax
000000014138e0dc: mulss    xmm1, xmm0
000000014138e0e0: mulss    xmm2, xmm0
000000014138e0e4: movss    xmm4, xmm1
000000014138e0e8: mulss    xmm3, xmm0
000000014138e0ec: shufps   xmm4, xmm4, 0xc6
000000014138e0f0: movss    xmm4, xmm2
000000014138e0f4: shufps   xmm4, xmm4, 0x27
000000014138e0f8: movss    xmm4, xmm3
000000014138e0fc: shufps   xmm4, xmm4, 0x39
000000014138e100: movups   xmmword ptr [rcx + 0x50], xmm4
000000014138e104: add      rsp, 0x18
000000014138e108: ret      
000000014138e109: int3     
000000014138e10a: int3     
000000014138e10b: int3     
000000014138e10c: int3     
000000014138e10d: int3     
000000014138e10e: int3     
000000014138e10f: int3     
000000014138e110: sub      rsp, 0x18
000000014138e114: movss    xmm0, dword ptr [rsp + 0x40]
000000014138e11a: movaps   xmm4, xmm1
000000014138e11d: shufps   xmm4, xmm4, 0xe1
000000014138e121: movss    xmm4, xmm2
000000014138e125: shufps   xmm4, xmm4, 0xc6
000000014138e129: movss    xmm4, xmm3
000000014138e12d: shufps   xmm4, xmm4, 0x27
000000014138e131: movss    xmm4, xmm0
000000014138e135: shufps   xmm4, xmm4, 0x39
000000014138e139: movups   xmmword ptr [rcx + 0x50], xmm4
000000014138e13d: add      rsp, 0x18
000000014138e141: ret      
000000014138e142: int3     
000000014138e143: int3     
000000014138e144: int3     
000000014138e145: int3     
000000014138e146: int3     
000000014138e147: int3     
000000014138e148: int3     
000000014138e149: int3     
000000014138e14a: int3     
000000014138e14b: int3     
000000014138e14c: int3     
000000014138e14d: int3     
000000014138e14e: int3     
000000014138e14f: int3     
000000014138e150: movzx    eax, dl
000000014138e153: movd     xmm0, eax
000000014138e157: cvtdq2ps xmm0, xmm0
000000014138e15a: mulss    xmm0, dword ptr [rip + 0x692226]
000000014138e162: movss    dword ptr [rcx + 0x58], xmm0
000000014138e167: ret      
000000014138e168: int3     
000000014138e169: int3     
000000014138e16a: int3     
000000014138e16b: int3     
000000014138e16c: int3     
000000014138e16d: int3     
000000014138e16e: int3     
000000014138e16f: int3     
000000014138e170: movss    dword ptr [rcx + 0x58], xmm1
000000014138e175: ret      
000000014138e176: int3     
000000014138e177: int3     
000000014138e178: int3     
000000014138e179: int3     
000000014138e17a: int3     
000000014138e17b: int3     
000000014138e17c: int3     
000000014138e17d: int3     
000000014138e17e: int3     
000000014138e17f: int3     
000000014138e180: movzx    eax, dl
000000014138e183: movd     xmm0, eax
000000014138e187: cvtdq2ps xmm0, xmm0
000000014138e18a: mulss    xmm0, dword ptr [rip + 0x6921f6]
000000014138e192: movss    dword ptr [rcx + 0x54], xmm0
000000014138e197: ret      
000000014138e198: int3     
000000014138e199: int3     
000000014138e19a: int3     
000000014138e19b: int3     
000000014138e19c: int3     
000000014138e19d: int3     
000000014138e19e: int3     
000000014138e19f: int3     
000000014138e1a0: movss    dword ptr [rcx + 0x54], xmm1
000000014138e1a5: ret      
000000014138e1a6: int3     
000000014138e1a7: int3     
000000014138e1a8: int3     
000000014138e1a9: int3     
000000014138e1aa: int3     
000000014138e1ab: int3     
000000014138e1ac: int3     
000000014138e1ad: int3     
000000014138e1ae: int3     
000000014138e1af: int3     
000000014138e1b0: movzx    eax, dl
000000014138e1b3: movd     xmm0, eax
000000014138e1b7: cvtdq2ps xmm0, xmm0
000000014138e1ba: mulss    xmm0, dword ptr [rip + 0x6921c6]
000000014138e1c2: movss    dword ptr [rcx + 0x50], xmm0
000000014138e1c7: ret      
000000014138e1c8: int3     
000000014138e1c9: int3     
000000014138e1ca: int3     
000000014138e1cb: int3     
000000014138e1cc: int3     
000000014138e1cd: int3     
000000014138e1ce: int3     
000000014138e1cf: int3     
000000014138e1d0: movss    dword ptr [rcx + 0x50], xmm1
000000014138e1d5: ret      
000000014138e1d6: int3     
000000014138e1d7: int3     
000000014138e1d8: int3     
000000014138e1d9: int3     
000000014138e1da: int3     
000000014138e1db: int3     
000000014138e1dc: int3     
000000014138e1dd: int3     
000000014138e1de: int3     
000000014138e1df: int3     
000000014138e1e0: mov      qword ptr [rsp + 8], rbx
000000014138e1e5: push     rdi
000000014138e1e6: sub      rsp, 0x30
000000014138e1ea: mov      rdi, rcx
000000014138e1ed: movaps   xmmword ptr [rsp + 0x20], xmm6
000000014138e1f2: mov      rcx, qword ptr [rcx + 0x18]
000000014138e1f6: movaps   xmm6, xmm2
000000014138e1f9: movsxd   rbx, edx
000000014138e1fc: mov      rax, qword ptr [rcx]
000000014138e1ff: call     qword ptr [rax + 8]
000000014138e202: movzx    r8d, word ptr [rax + 0x28]
000000014138e207: cmp      r8d, ebx
000000014138e20a: jle      0x14138e221
000000014138e20c: test     ebx, ebx
000000014138e20e: js       0x14138e221
000000014138e210: mov      rax, qword ptr [rdi + 0x28]
000000014138e214: mov      rdx, rbx
000000014138e217: shl      rdx, 6
000000014138e21b: movss    dword ptr [rdx + rax + 0x2c], xmm6
000000014138e221: mov      rbx, qword ptr [rsp + 0x40]
000000014138e226: movaps   xmm6, xmmword ptr [rsp + 0x20]
000000014138e22b: add      rsp, 0x30
000000014138e22f: pop      rdi
000000014138e230: ret      
000000014138e231: int3     
000000014138e232: int3     
000000014138e233: int3     
000000014138e234: int3     
000000014138e235: int3     
000000014138e236: int3     
000000014138e237: int3     
000000014138e238: int3     
000000014138e239: int3     
000000014138e23a: int3     
000000014138e23b: int3     
000000014138e23c: int3     
000000014138e23d: int3     
000000014138e23e: int3     
000000014138e23f: int3     
000000014138e240: mov      qword ptr [rsp + 8], rbx
000000014138e245: mov      qword ptr [rsp + 0x10], rsi
000000014138e24a: push     rdi
000000014138e24b: sub      rsp, 0x20
000000014138e24f: mov      rdi, rcx
000000014138e252: movsxd   rbx, edx
000000014138e255: mov      rcx, qword ptr [rcx + 0x18]
000000014138e259: mov      esi, r8d
000000014138e25c: mov      rax, qword ptr [rcx]
000000014138e25f: call     qword ptr [rax + 8]
000000014138e262: movzx    r9d, word ptr [rax + 0x28]
000000014138e267: cmp      r9d, ebx
000000014138e26a: jle      0x14138e28c
000000014138e26c: test     ebx, ebx
000000014138e26e: js       0x14138e28c
000000014138e270: mov      rax, qword ptr [rdi + 0x28]
000000014138e274: mov      rdx, rbx
000000014138e277: shl      rdx, 6
000000014138e27b: cmp      dword ptr [rdx + rax + 0x30], esi
000000014138e27f: je       0x14138e28c
000000014138e281: mov      dword ptr [rdx + rax + 0x30], esi
000000014138e285: mov      dword ptr [rdi + 0x78], 1
000000014138e28c: mov      rbx, qword ptr [rsp + 0x30]
000000014138e291: mov      rsi, qword ptr [rsp + 0x38]
000000014138e296: add      rsp, 0x20
000000014138e29a: pop      rdi
000000014138e29b: ret      
000000014138e29c: int3     
000000014138e29d: int3     
000000014138e29e: int3     
000000014138e29f: int3     
000000014138e2a0: mov      qword ptr [rsp + 8], rbx
000000014138e2a5: mov      qword ptr [rsp + 0x10], rsi
000000014138e2aa: push     rdi
000000014138e2ab: sub      rsp, 0x20
000000014138e2af: mov      rdi, rcx
000000014138e2b2: movsxd   rbx, edx
000000014138e2b5: mov      rcx, qword ptr [rcx + 0x18]
000000014138e2b9: mov      rsi, r8
000000014138e2bc: mov      rax, qword ptr [rcx]
000000014138e2bf: call     qword ptr [rax + 8]
000000014138e2c2: movzx    r9d, word ptr [rax + 0x28]
000000014138e2c7: cmp      r9d, ebx
000000014138e2ca: jle      0x14138e2e3
000000014138e2cc: test     ebx, ebx
000000014138e2ce: js       0x14138e2e3
000000014138e2d0: mov      rax, qword ptr [rdi + 0x28]
000000014138e2d4: mov      rdx, rbx
000000014138e2d7: movaps   xmm0, xmmword ptr [rsi]
000000014138e2da: shl      rdx, 6
000000014138e2de: movups   xmmword ptr [rdx + rax + 0x20], xmm0
000000014138e2e3: mov      rbx, qword ptr [rsp + 0x30]
000000014138e2e8: mov      rsi, qword ptr [rsp + 0x38]
000000014138e2ed: add      rsp, 0x20
000000014138e2f1: pop      rdi
000000014138e2f2: ret      
000000014138e2f3: int3     
000000014138e2f4: int3     
000000014138e2f5: int3     
000000014138e2f6: int3     
000000014138e2f7: int3     
000000014138e2f8: int3     
000000014138e2f9: int3     
000000014138e2fa: int3     
000000014138e2fb: int3     
000000014138e2fc: int3     
000000014138e2fd: int3     
000000014138e2fe: int3     
000000014138e2ff: int3     
000000014138e300: mov      qword ptr [rsp + 8], rbx
000000014138e305: push     rdi
000000014138e306: sub      rsp, 0x40
000000014138e30a: mov      rdi, rcx
000000014138e30d: movaps   xmmword ptr [rsp + 0x30], xmm6
000000014138e312: mov      rcx, qword ptr [rcx + 0x18]
000000014138e316: movaps   xmm6, xmm3
000000014138e319: movaps   xmmword ptr [rsp + 0x20], xmm7
000000014138e31e: movaps   xmm7, xmm2
000000014138e321: movsxd   rbx, edx
000000014138e324: mov      rax, qword ptr [rcx]
000000014138e327: call     qword ptr [rax + 8]
000000014138e32a: movzx    r8d, word ptr [rax + 0x28]
000000014138e32f: cmp      r8d, ebx
000000014138e332: jle      0x14138e36c
000000014138e334: test     ebx, ebx
000000014138e336: js       0x14138e36c
000000014138e338: mov      rcx, rbx
000000014138e33b: shl      rcx, 6
000000014138e33f: add      rcx, qword ptr [rdi + 0x28]
000000014138e343: movss    xmm0, dword ptr [rcx]
000000014138e347: ucomiss  xmm0, xmm7
000000014138e34a: jp       0x14138e35a
000000014138e34c: jne      0x14138e35a
000000014138e34e: movss    xmm0, dword ptr [rcx + 4]
000000014138e353: ucomiss  xmm0, xmm6
000000014138e356: jp       0x14138e35a
000000014138e358: je       0x14138e36c
000000014138e35a: movaps   xmm2, xmm6
000000014138e35d: movaps   xmm1, xmm7
000000014138e360: call     0x1412a15c0
000000014138e365: mov      dword ptr [rdi + 0x78], 1
000000014138e36c: mov      rbx, qword ptr [rsp + 0x50]
000000014138e371: movaps   xmm6, xmmword ptr [rsp + 0x30]
000000014138e376: movaps   xmm7, xmmword ptr [rsp + 0x20]
000000014138e37b: add      rsp, 0x40
000000014138e37f: pop      rdi
000000014138e380: ret      
000000014138e381: int3     
000000014138e382: int3     
000000014138e383: int3     
000000014138e384: int3     
000000014138e385: int3     
000000014138e386: int3     
000000014138e387: int3     
000000014138e388: int3     
000000014138e389: int3     
000000014138e38a: int3     
000000014138e38b: int3     
000000014138e38c: int3     
000000014138e38d: int3     
000000014138e38e: int3     
000000014138e38f: int3     
000000014138e390: mov      qword ptr [rsp + 8], rbx
000000014138e395: mov      qword ptr [rsp + 0x10], rsi
000000014138e39a: push     rdi
000000014138e39b: sub      rsp, 0x20
000000014138e39f: mov      rdi, rcx
000000014138e3a2: movsxd   rbx, edx
000000014138e3a5: mov      rcx, qword ptr [rcx + 0x18]
000000014138e3a9: movzx    esi, r8w
000000014138e3ad: mov      rax, qword ptr [rcx]
000000014138e3b0: call     qword ptr [rax + 8]
000000014138e3b3: movzx    r9d, word ptr [rax + 0x28]
000000014138e3b8: cmp      r9d, ebx
000000014138e3bb: jle      0x14138e3d1
000000014138e3bd: test     ebx, ebx
000000014138e3bf: js       0x14138e3d1
000000014138e3c1: mov      rax, qword ptr [rdi + 0x28]
000000014138e3c5: mov      rdx, rbx
000000014138e3c8: shl      rdx, 6
000000014138e3cc: mov      word ptr [rdx + rax + 0x34], si
000000014138e3d1: mov      rbx, qword ptr [rsp + 0x30]
000000014138e3d6: mov      rsi, qword ptr [rsp + 0x38]
000000014138e3db: add      rsp, 0x20
000000014138e3df: pop      rdi
000000014138e3e0: ret      
000000014138e3e1: int3     
000000014138e3e2: int3     
000000014138e3e3: int3     
000000014138e3e4: int3     
000000014138e3e5: int3     
000000014138e3e6: int3     
000000014138e3e7: int3     
000000014138e3e8: int3     
000000014138e3e9: int3     
000000014138e3ea: int3     
000000014138e3eb: int3     
000000014138e3ec: int3     
000000014138e3ed: int3     
000000014138e3ee: int3     
000000014138e3ef: int3     
000000014138e3f0: mov      qword ptr [rsp + 8], rbx
000000014138e3f5: mov      qword ptr [rsp + 0x10], rsi
000000014138e3fa: push     rdi
000000014138e3fb: sub      rsp, 0x20
000000014138e3ff: xorps    xmm0, xmm0
000000014138e402: movsxd   rbx, edx
000000014138e405: comiss   xmm0, xmm2
000000014138e408: mov      rdi, rcx
000000014138e40b: jbe      0x14138e417
000000014138e40d: movss    xmm0, dword ptr [rip + 0x3dc05f]
000000014138e415: jmp      0x14138e41f
000000014138e417: movss    xmm0, dword ptr [rip + 0x3dc029]
000000014138e41f: mulss    xmm2, dword ptr [rip + 0x3f1dd9]
000000014138e427: mov      rcx, qword ptr [rcx + 0x18]
000000014138e42b: divss    xmm2, dword ptr [rip + 0x3dc025]
000000014138e433: mov      rax, qword ptr [rcx]
000000014138e436: addss    xmm2, xmm0
000000014138e43a: cvttss2si esi, xmm2
000000014138e43e: call     qword ptr [rax + 8]
000000014138e441: movzx    ecx, word ptr [rax + 0x28]
000000014138e445: cmp      ecx, ebx
000000014138e447: jle      0x14138e469
000000014138e449: test     ebx, ebx
000000014138e44b: js       0x14138e469
000000014138e44d: mov      rcx, qword ptr [rdi + 0x28]
000000014138e451: mov      rax, rbx
000000014138e454: shl      rax, 6
000000014138e458: cmp      dword ptr [rax + rcx + 0x30], esi
000000014138e45c: je       0x14138e469
000000014138e45e: mov      dword ptr [rax + rcx + 0x30], esi
000000014138e462: mov      dword ptr [rdi + 0x78], 1
000000014138e469: mov      rbx, qword ptr [rsp + 0x30]
000000014138e46e: mov      rsi, qword ptr [rsp + 0x38]
000000014138e473: add      rsp, 0x20
000000014138e477: pop      rdi
000000014138e478: ret      
000000014138e479: int3     
000000014138e47a: int3     
000000014138e47b: int3     
000000014138e47c: int3     
000000014138e47d: int3     
000000014138e47e: int3     
000000014138e47f: int3     
000000014138e480: mov      qword ptr [rsp + 8], rbx
000000014138e485: push     rdi
000000014138e486: sub      rsp, 0x40
000000014138e48a: mov      rdi, rcx
000000014138e48d: movaps   xmmword ptr [rsp + 0x30], xmm6
000000014138e492: mov      rcx, qword ptr [rcx + 0x18]
000000014138e496: movaps   xmm6, xmm3
000000014138e499: movaps   xmmword ptr [rsp + 0x20], xmm7
000000014138e49e: movaps   xmm7, xmm2
000000014138e4a1: movsxd   rbx, edx
000000014138e4a4: mov      rax, qword ptr [rcx]
000000014138e4a7: call     qword ptr [rax + 8]
000000014138e4aa: movzx    r8d, word ptr [rax + 0x28]
000000014138e4af: cmp      r8d, ebx
000000014138e4b2: jle      0x14138e4ec
000000014138e4b4: test     ebx, ebx
000000014138e4b6: js       0x14138e4ec
000000014138e4b8: mov      rax, rbx
000000014138e4bb: shl      rax, 6
000000014138e4bf: add      rax, qword ptr [rdi + 0x28]
000000014138e4c3: movss    xmm0, dword ptr [rax + 8]
000000014138e4c8: ucomiss  xmm0, xmm7
000000014138e4cb: jp       0x14138e4db
000000014138e4cd: jne      0x14138e4db
000000014138e4cf: movss    xmm0, dword ptr [rax + 0xc]
000000014138e4d4: ucomiss  xmm0, xmm6
000000014138e4d7: jp       0x14138e4db
000000014138e4d9: je       0x14138e4ec
000000014138e4db: movss    dword ptr [rax + 8], xmm7
000000014138e4e0: movss    dword ptr [rax + 0xc], xmm6
000000014138e4e5: mov      dword ptr [rdi + 0x78], 1
000000014138e4ec: mov      rbx, qword ptr [rsp + 0x50]
000000014138e4f1: movaps   xmm6, xmmword ptr [rsp + 0x30]
000000014138e4f6: movaps   xmm7, xmmword ptr [rsp + 0x20]
000000014138e4fb: add      rsp, 0x40
000000014138e4ff: pop      rdi
000000014138e500: ret      
000000014138e501: int3     
000000014138e502: int3     
000000014138e503: int3     
000000014138e504: int3     
000000014138e505: int3     
000000014138e506: int3     
000000014138e507: int3     
000000014138e508: int3     
000000014138e509: int3     
000000014138e50a: int3     
000000014138e50b: int3     
000000014138e50c: int3     
000000014138e50d: int3     
000000014138e50e: int3     
000000014138e50f: int3     
000000014138e510: mov      qword ptr [rsp + 8], rbx
000000014138e515: mov      qword ptr [rsp + 0x10], rsi
000000014138e51a: push     rdi
000000014138e51b: sub      rsp, 0x20
000000014138e51f: mov      rsi, rcx
000000014138e522: movsxd   rbx, edx
000000014138e525: mov      rcx, qword ptr [rcx + 0x18]
000000014138e529: mov      rdi, r8
000000014138e52c: mov      rax, qword ptr [rcx]
000000014138e52f: call     qword ptr [rax + 8]
000000014138e532: movzx    r9d, word ptr [rax + 0x28]
000000014138e537: cmp      r9d, ebx
000000014138e53a: jle      0x14138e557
000000014138e53c: test     ebx, ebx
000000014138e53e: js       0x14138e557
000000014138e540: mov      rax, qword ptr [rsi + 0x28]
000000014138e544: mov      rdx, rbx
000000014138e547: shl      rdx, 6
000000014138e54b: cmp      qword ptr [rdx + rax + 0x38], rdi
000000014138e550: je       0x14138e557
000000014138e552: mov      qword ptr [rdx + rax + 0x38], rdi
000000014138e557: mov      rbx, qword ptr [rsp + 0x30]
000000014138e55c: mov      rsi, qword ptr [rsp + 0x38]
000000014138e561: add      rsp, 0x20
000000014138e565: pop      rdi
000000014138e566: ret      
000000014138e567: int3     
000000014138e568: int3     
000000014138e569: int3     
000000014138e56a: int3     
000000014138e56b: int3     
000000014138e56c: int3     
000000014138e56d: int3     
000000014138e56e: int3     
000000014138e56f: int3     
000000014138e570: mov      qword ptr [rsp + 8], rbx
000000014138e575: push     rdi
000000014138e576: sub      rsp, 0x40
000000014138e57a: mov      rdi, rcx
000000014138e57d: movaps   xmmword ptr [rsp + 0x30], xmm6
000000014138e582: mov      rcx, qword ptr [rcx + 0x18]
000000014138e586: movaps   xmm6, xmm3
000000014138e589: movaps   xmmword ptr [rsp + 0x20], xmm7
000000014138e58e: movaps   xmm7, xmm2
000000014138e591: movsxd   rbx, edx
000000014138e594: mov      rax, qword ptr [rcx]
000000014138e597: call     qword ptr [rax + 8]
000000014138e59a: movzx    r8d, word ptr [rax + 0x28]
000000014138e59f: cmp      r8d, ebx
000000014138e5a2: jle      0x14138e5c5
000000014138e5a4: test     ebx, ebx
000000014138e5a6: js       0x14138e5c5
000000014138e5a8: mov      rcx, qword ptr [rdi + 0x28]
000000014138e5ac: mov      rdx, rbx
000000014138e5af: shl      rdx, 6
000000014138e5b3: add      rcx, 0x10
000000014138e5b7: add      rcx, rdx
000000014138e5ba: movaps   xmm2, xmm6
000000014138e5bd: movaps   xmm1, xmm7
000000014138e5c0: call     0x1412a15c0
000000014138e5c5: mov      rbx, qword ptr [rsp + 0x50]
000000014138e5ca: movaps   xmm6, xmmword ptr [rsp + 0x30]
000000014138e5cf: movaps   xmm7, xmmword ptr [rsp + 0x20]
000000014138e5d4: add      rsp, 0x40
000000014138e5d8: pop      rdi
000000014138e5d9: ret      
000000014138e5da: int3     
000000014138e5db: int3     
000000014138e5dc: int3     
000000014138e5dd: int3     
000000014138e5de: int3     
000000014138e5df: int3     
000000014138e5e0: movss    dword ptr [rcx + 0x30], xmm1
000000014138e5e5: movss    dword ptr [rcx + 0x34], xmm2
000000014138e5ea: ret      
000000014138e5eb: int3     
000000014138e5ec: int3     
000000014138e5ed: int3     
000000014138e5ee: int3     
000000014138e5ef: int3     
000000014138e5f0: movss    dword ptr [rcx + 0x30], xmm1
000000014138e5f5: ret      
000000014138e5f6: int3     
000000014138e5f7: int3     
000000014138e5f8: int3     
000000014138e5f9: int3     
000000014138e5fa: int3     
000000014138e5fb: int3     
000000014138e5fc: int3     
000000014138e5fd: int3     
000000014138e5fe: int3     
000000014138e5ff: int3     
000000014138e600: movss    dword ptr [rcx + 0x34], xmm1
000000014138e605: ret      
000000014138e606: int3     
000000014138e607: int3     
000000014138e608: int3     
000000014138e609: int3     
000000014138e60a: int3     
000000014138e60b: int3     
000000014138e60c: int3     
000000014138e60d: int3     
000000014138e60e: int3     
000000014138e60f: int3     
000000014138e610: movss    dword ptr [rcx + 0x38], xmm1
000000014138e615: ret      
000000014138e616: int3     
000000014138e617: int3     
000000014138e618: int3     
000000014138e619: int3     
000000014138e61a: int3     
000000014138e61b: int3     
000000014138e61c: int3     
000000014138e61d: int3     
000000014138e61e: int3     
000000014138e61f: int3     
000000014138e620: xorps    xmm0, xmm0
000000014138e623: comiss   xmm0, xmm1
000000014138e626: jbe      0x14138e632
000000014138e628: movss    xmm0, dword ptr [rip + 0x3dbe44]
000000014138e630: jmp      0x14138e63a
000000014138e632: movss    xmm0, dword ptr [rip + 0x3dbe0e]
000000014138e63a: mulss    xmm1, dword ptr [rip + 0x3f1bbe]
000000014138e642: divss    xmm1, dword ptr [rip + 0x3dbe0e]
000000014138e64a: addss    xmm1, xmm0
000000014138e64e: cvttss2si eax, xmm1
000000014138e652: mov      dword ptr [rcx + 0x60], eax
000000014138e655: ret      
000000014138e656: int3     
000000014138e657: int3     
000000014138e658: int3     
000000014138e659: int3     
000000014138e65a: int3     
000000014138e65b: int3     
000000014138e65c: int3     
000000014138e65d: int3     
000000014138e65e: int3     
000000014138e65f: int3     
000000014138e660: push     rbx
000000014138e662: sub      rsp, 0x20
000000014138e666: mov      rbx, rcx
000000014138e669: add      rcx, 0x3c
000000014138e66d: ucomiss  xmm1, dword ptr [rcx]
000000014138e670: jp       0x14138e67c
000000014138e672: jne      0x14138e67c
000000014138e674: ucomiss  xmm2, dword ptr [rbx + 0x40]
000000014138e678: jp       0x14138e67c
000000014138e67a: je       0x14138e688
000000014138e67c: call     0x1412a15c0
000000014138e681: mov      dword ptr [rbx + 0x78], 1
000000014138e688: add      rsp, 0x20
000000014138e68c: pop      rbx
000000014138e68d: ret      
000000014138e68e: int3     
000000014138e68f: int3     
000000014138e690: ucomiss  xmm1, dword ptr [rcx + 0x3c]
000000014138e694: jp       0x14138e698
000000014138e696: je       0x14138e6a4
000000014138e698: movss    dword ptr [rcx + 0x3c], xmm1
000000014138e69d: mov      dword ptr [rcx + 0x78], 1
000000014138e6a4: ret      
000000014138e6a5: int3     
000000014138e6a6: int3     
000000014138e6a7: int3     
000000014138e6a8: int3     
000000014138e6a9: int3     
000000014138e6aa: int3     
000000014138e6ab: int3     
000000014138e6ac: int3     
000000014138e6ad: int3     
000000014138e6ae: int3     
000000014138e6af: int3     
000000014138e6b0: ucomiss  xmm1, dword ptr [rcx + 0x40]
000000014138e6b4: jp       0x14138e6b8
000000014138e6b6: je       0x14138e6c4
000000014138e6b8: movss    dword ptr [rcx + 0x40], xmm1
000000014138e6bd: mov      dword ptr [rcx + 0x78], 1
000000014138e6c4: ret      
000000014138e6c5: int3     
000000014138e6c6: int3     
000000014138e6c7: int3     
000000014138e6c8: int3     
000000014138e6c9: int3     
000000014138e6ca: int3     
000000014138e6cb: int3     
000000014138e6cc: int3     
000000014138e6cd: int3     
000000014138e6ce: int3     
000000014138e6cf: int3     
000000014138e6d0: mov      qword ptr [rsp + 8], rbx
000000014138e6d5: mov      qword ptr [rsp + 0x10], rsi
000000014138e6da: push     rdi
000000014138e6db: sub      rsp, 0x20
000000014138e6df: mov      rsi, rcx
000000014138e6e2: movsxd   rbx, edx
000000014138e6e5: mov      rcx, qword ptr [rcx + 0x18]
000000014138e6e9: mov      rdi, r8
000000014138e6ec: mov      rax, qword ptr [rcx]
000000014138e6ef: call     qword ptr [rax + 8]
000000014138e6f2: movzx    r9d, word ptr [rax + 0x28]
000000014138e6f7: cmp      r9d, ebx
000000014138e6fa: jle      0x14138e717
000000014138e6fc: test     ebx, ebx
000000014138e6fe: js       0x14138e717
000000014138e700: mov      rax, qword ptr [rsi + 0x28]
000000014138e704: mov      rdx, rbx
000000014138e707: shl      rdx, 6
000000014138e70b: cmp      qword ptr [rdx + rax + 0x38], rdi
000000014138e710: je       0x14138e717
000000014138e712: mov      qword ptr [rdx + rax + 0x38], rdi
000000014138e717: mov      rbx, qword ptr [rsp + 0x30]
000000014138e71c: mov      rsi, qword ptr [rsp + 0x38]
000000014138e721: add      rsp, 0x20
000000014138e725: pop      rdi
000000014138e726: ret      
000000014138e727: int3     
000000014138e728: int3     
000000014138e729: int3     
000000014138e72a: int3     
000000014138e72b: int3     
000000014138e72c: int3     
000000014138e72d: int3     
000000014138e72e: int3     
000000014138e72f: int3     
000000014138e730: mov      rax, rsp
000000014138e733: mov      qword ptr [rax + 0x10], rbx
000000014138e737: mov      qword ptr [rax + 0x18], rbp
000000014138e73b: mov      qword ptr [rax + 0x20], rsi
000000014138e73f: push     rdi
000000014138e740: push     r12
000000014138e742: push     r13
000000014138e744: push     r14
000000014138e746: push     r15
000000014138e748: sub      rsp, 0x150
000000014138e74f: movaps   xmmword ptr [rax - 0x38], xmm6
000000014138e753: movaps   xmmword ptr [rax - 0x48], xmm7
000000014138e757: movaps   xmmword ptr [rax - 0x58], xmm8
000000014138e75c: mov      rax, qword ptr [rip + 0xd57c65]
000000014138e763: xor      rax, rsp
000000014138e766: mov      qword ptr [rsp + 0x110], rax
000000014138e76e: mov      esi, edx
000000014138e770: mov      dword ptr [rsp + 0x2c], edx
000000014138e774: mov      rdi, rcx
000000014138e777: call     0x14138f050
000000014138e77c: call     0x141217670
000000014138e781: mov      rax, qword ptr gs:[0x58]
000000014138e78a: mov      ebx, dword ptr [rip + 0x83c4480]
000000014138e790: mov      r14d, 0x342c
000000014138e796: mov      r8, qword ptr [rax + rbx*8]
000000014138e79a: cmp      byte ptr [r14 + r8], 0
000000014138e79f: jne      0x14138e7a6
000000014138e7a1: call     0x141441fb8
000000014138e7a6: mov      rax, qword ptr gs:[0x58]
000000014138e7af: lea      rdx, [rsp + 0x20]
000000014138e7b4: mov      r15d, 0x3400
000000014138e7ba: mov      rcx, qword ptr [rax + rbx*8]
000000014138e7be: mov      rcx, qword ptr [rcx + r15]
000000014138e7c2: call     0x1412b5310
000000014138e7c7: movss    xmm7, dword ptr [rip + 0x3d29d1]
000000014138e7cf: xor      ebp, ebp
000000014138e7d1: movss    xmm8, dword ptr [rip + 0x3d2e06]
000000014138e7da: movss    xmm6, dword ptr [rip + 0x691ba6]
000000014138e7e2: mov      rax, qword ptr gs:[0x58]
000000014138e7eb: mov      rcx, qword ptr [rax + rbx*8]
000000014138e7ef: cmp      byte ptr [r14 + rcx], 0
000000014138e7f4: jne      0x14138e7fb
000000014138e7f6: call     0x141441fb8
000000014138e7fb: mov      rax, qword ptr gs:[0x58]
000000014138e804: lea      rdx, [rsp + 0x40]
000000014138e809: mov      rcx, qword ptr [rax + rbx*8]
000000014138e80d: mov      rcx, qword ptr [r15 + rcx]
000000014138e811: call     0x1412b56a0
000000014138e816: mov      rcx, qword ptr [rax]
000000014138e819: cmp      qword ptr [rsp + 0x20], rcx
000000014138e81e: je       0x14138ed39
000000014138e824: test     esi, esi
000000014138e826: je       0x14138e82d
000000014138e828: call     0x141216e70
000000014138e82d: mov      rcx, qword ptr [rip + 0x837ace4]
000000014138e834: movzx    eax, word ptr [rcx + 0x4a8]
000000014138e83b: movd     xmm1, eax
000000014138e83f: movzx    eax, word ptr [rcx + 0x472]
000000014138e846: cvtdq2ps xmm1, xmm1
000000014138e849: movd     xmm0, eax
000000014138e84d: movzx    eax, word ptr [rcx + 0x4a6]
000000014138e854: cvtdq2ps xmm0, xmm0
000000014138e857: divss    xmm1, xmm0
000000014138e85b: movd     xmm0, eax
000000014138e85f: movzx    eax, word ptr [rcx + 0x470]
000000014138e866: cvtdq2ps xmm0, xmm0
000000014138e869: movd     xmm2, eax
000000014138e86d: cvtdq2ps xmm2, xmm2
000000014138e870: divss    xmm0, xmm2
000000014138e874: movaps   xmm2, xmm8
000000014138e878: call     0x1412181b0
000000014138e87d: movss    xmm2, dword ptr [rdi + 0x38]
000000014138e882: movss    xmm1, dword ptr [rdi + 0x34]
000000014138e887: movss    xmm0, dword ptr [rdi + 0x30]
000000014138e88c: call     0x1412183e0
000000014138e891: mov      ecx, dword ptr [rdi + 0x60]
000000014138e894: call     0x141218060
000000014138e899: movss    xmm1, dword ptr [rdi + 0x48]
000000014138e89e: xorps    xmm2, xmm2
000000014138e8a1: movss    xmm0, dword ptr [rdi + 0x44]
000000014138e8a6: xorps    xmm1, xmm7
000000014138e8a9: xorps    xmm0, xmm7
000000014138e8ac: call     0x1412183e0
000000014138e8b1: mov      rcx, qword ptr [rdi + 0x18]
000000014138e8b5: mov      dword ptr [rsp + 0x28], ebp
000000014138e8b9: mov      rax, qword ptr [rcx]
000000014138e8bc: call     qword ptr [rax + 8]
000000014138e8bf: cmp      bp, word ptr [rax + 0x28]
000000014138e8c3: jae      0x14138ecd1
000000014138e8c9: xor      ebx, ebx
000000014138e8cb: mov      esi, ebx
000000014138e8cd: mov      r14d, ebx
000000014138e8d0: mov      rcx, qword ptr [rdi + 0x18]
000000014138e8d4: mov      rax, qword ptr [rcx]
000000014138e8d7: call     qword ptr [rax + 8]
000000014138e8da: mov      rbp, qword ptr [rdi + 0x28]
000000014138e8de: mov      r12, qword ptr [rax + 0x10]
000000014138e8e2: test     dword ptr [r14 + r12 + 0x18], 0x500
000000014138e8eb: jne      0x14138ec91
000000014138e8f1: mov      rax, qword ptr [rax + 0x20]
000000014138e8f5: movzx    ecx, byte ptr [r14 + r12 + 7]
000000014138e8fb: mov      rcx, qword ptr [rax + rcx*8]
000000014138e8ff: mov      rax, qword ptr [rcx]
000000014138e902: call     qword ptr [rax + 8]
000000014138e905: mov      r13, qword ptr [rsi + rbp + 0x38]
000000014138e90a: test     r13, r13
000000014138e90d: jne      0x14138e91b
000000014138e90f: mov      r13, rax
000000014138e912: test     rax, rax
000000014138e915: je       0x14138ec91
000000014138e91b: mov      ecx, dword ptr [r14 + r12]
000000014138e91f: lea      r15, [rsp + 0x50]
000000014138e924: mov      eax, ecx
000000014138e926: xorps    xmm3, xmm3
000000014138e929: shr      eax, 0x18
000000014138e92c: xorps    xmm2, xmm2
000000014138e92f: xorps    xmm0, xmm0
000000014138e932: xorps    xmm1, xmm1
000000014138e935: cvtsi2ss xmm3, rax
000000014138e93a: mov      eax, ecx
000000014138e93c: shr      eax, 0x10
000000014138e93f: movzx    eax, al
000000014138e942: cvtsi2ss xmm2, rax
000000014138e947: mov      eax, ecx
000000014138e949: shr      eax, 8
000000014138e94c: movzx    eax, al
000000014138e94f: mulss    xmm3, xmm6
000000014138e953: cvtsi2ss xmm0, rax
000000014138e958: movzx    eax, cl
000000014138e95b: mov      rcx, qword ptr [rsp + 0x20]
000000014138e960: mulss    xmm3, dword ptr [rdi + 0x5c]
000000014138e965: mov      rcx, qword ptr [rcx + 0x20]
000000014138e969: cvtsi2ss xmm1, rax
000000014138e96e: mulss    xmm3, dword ptr [rsi + rbp + 0x2c]
000000014138e974: mulss    xmm1, xmm6
000000014138e978: mulss    xmm2, xmm6
000000014138e97c: mulss    xmm1, dword ptr [rdi + 0x58]
000000014138e981: mulss    xmm2, dword ptr [rdi + 0x50]
000000014138e986: mulss    xmm1, dword ptr [rsi + rbp + 0x28]
000000014138e98c: mulss    xmm2, dword ptr [rsi + rbp + 0x20]
000000014138e992: mulss    xmm0, xmm6
000000014138e996: movss    dword ptr [rsp + 0x38], xmm1
000000014138e99c: movss    dword ptr [rsp + 0x3c], xmm3
000000014138e9a2: mulss    xmm0, dword ptr [rdi + 0x54]
000000014138e9a7: movss    dword ptr [rsp + 0x30], xmm2
000000014138e9ad: mulss    xmm0, dword ptr [rsi + rbp + 0x24]
000000014138e9b3: movss    dword ptr [rsp + 0x34], xmm0
000000014138e9b9: call     0x1412b5ab0
000000014138e9be: test     rax, rax
000000014138e9c1: je       0x14138ea2e
000000014138e9c3: mov      rax, qword ptr gs:[0x58]
000000014138e9cc: mov      ebx, dword ptr [rip + 0x83c423e]
000000014138e9d2: mov      rcx, qword ptr [rax + rbx*8]
000000014138e9d6: mov      eax, 0x342c
000000014138e9db: cmp      byte ptr [rax + rcx], 0
000000014138e9df: jne      0x14138e9e6
000000014138e9e1: call     0x141441fb8
000000014138e9e6: mov      rax, qword ptr gs:[0x58]
000000014138e9ef: mov      rcx, qword ptr [rax + rbx*8]
000000014138e9f3: mov      eax, 0x3400
000000014138e9f8: mov      rcx, qword ptr [rax + rcx]
000000014138e9fc: call     0x1412b59b0
000000014138ea01: mov      rcx, rax
000000014138ea04: mov      edx, 4
000000014138ea09: call     0x1412dc940
000000014138ea0e: mov      rcx, qword ptr [rsp + 0x20]
000000014138ea13: mov      rbx, rax
000000014138ea16: lea      r15, [rax + 0x70]
000000014138ea1a: mov      rcx, qword ptr [rcx + 0x20]
000000014138ea1e: call     0x1412b5ab0
000000014138ea23: mov      rcx, rax
000000014138ea26: mov      rdx, rbx
000000014138ea29: call     0x1412fe4c0
000000014138ea2e: movsx    r8, word ptr [rsi + rbp + 0x34]
000000014138ea34: xor      r9d, r9d
000000014138ea37: movzx    ecx, word ptr [r14 + r12 + 0x10]
000000014138ea3d: movaps   xmm0, xmmword ptr [rsp + 0x30]
000000014138ea42: lea      rdx, [rcx + rcx*2]
000000014138ea46: mov      rcx, qword ptr [rdi + 0x70]
000000014138ea4a: mov      eax, dword ptr [rcx + rdx*4]
000000014138ea4d: mov      dword ptr [r15], eax
000000014138ea50: mov      eax, dword ptr [rcx + rdx*4 + 4]
000000014138ea54: mov      dword ptr [r15 + 4], eax
000000014138ea58: mov      dword ptr [r15 + 8], 0x3f800000
000000014138ea60: mov      dword ptr [rcx + rdx*4 + 8], r9d
000000014138ea65: movups   xmmword ptr [r15 + 0x10], xmm0
000000014138ea6a: mov      dword ptr [r15 + 0xc], r9d
000000014138ea6e: mov      qword ptr [r15 + 0x28], r9
000000014138ea72: movzx    eax, word ptr [r14 + r12 + 0x12]
000000014138ea78: mov      rcx, qword ptr [rdi + 0x70]
000000014138ea7c: lea      rdx, [rax + rax*2]
000000014138ea80: mov      eax, dword ptr [rcx + rdx*4]
000000014138ea83: mov      dword ptr [r15 + 0x30], eax
000000014138ea87: mov      eax, dword ptr [rcx + rdx*4 + 4]
000000014138ea8b: mov      dword ptr [r15 + 0x34], eax
000000014138ea8f: mov      dword ptr [r15 + 0x38], 0x3f800000
000000014138ea97: mov      dword ptr [rcx + rdx*4 + 8], r9d
000000014138ea9c: movups   xmmword ptr [r15 + 0x40], xmm0
000000014138eaa1: mov      dword ptr [r15 + 0x3c], r9d
000000014138eaa5: mov      qword ptr [r15 + 0x58], r9
000000014138eaa9: movzx    eax, word ptr [r14 + r12 + 0x14]
000000014138eaaf: mov      rcx, qword ptr [rdi + 0x70]
000000014138eab3: lea      rdx, [rax + rax*2]
000000014138eab7: mov      eax, dword ptr [rcx + rdx*4]
000000014138eaba: mov      dword ptr [r15 + 0x60], eax
000000014138eabe: mov      eax, dword ptr [rcx + rdx*4 + 4]
000000014138eac2: mov      dword ptr [r15 + 0x64], eax
000000014138eac6: mov      dword ptr [r15 + 0x68], 0x3f800000
000000014138eace: mov      dword ptr [rcx + rdx*4 + 8], r9d
000000014138ead3: movups   xmmword ptr [r15 + 0x70], xmm0
000000014138ead8: mov      dword ptr [r15 + 0x6c], r9d
000000014138eadc: mov      qword ptr [r15 + 0x88], r9
000000014138eae3: movzx    eax, word ptr [r14 + r12 + 0x16]
000000014138eae9: mov      rcx, qword ptr [rdi + 0x70]
000000014138eaed: lea      rdx, [rax + rax*2]
000000014138eaf1: mov      eax, dword ptr [rcx + rdx*4]
000000014138eaf4: mov      dword ptr [r15 + 0x90], eax
000000014138eafb: mov      eax, dword ptr [rcx + rdx*4 + 4]
000000014138eaff: mov      dword ptr [r15 + 0x94], eax
000000014138eb06: mov      dword ptr [r15 + 0x98], 0x3f800000
000000014138eb11: mov      dword ptr [rcx + rdx*4 + 8], r9d
000000014138eb16: movups   xmmword ptr [r15 + 0xa0], xmm0
000000014138eb1e: mov      dword ptr [r15 + 0x9c], r9d
000000014138eb25: mov      qword ptr [r15 + 0xb8], r9
000000014138eb2c: mov      rax, qword ptr [r14 + r12 + 0x20]
000000014138eb31: movzx    ecx, word ptr [rax + r8*4]
000000014138eb36: movd     xmm0, ecx
000000014138eb3a: cvtdq2ps xmm0, xmm0
000000014138eb3d: addss    xmm0, dword ptr [rsi + rbp + 0x10]
000000014138eb43: movss    dword ptr [r15 + 0x20], xmm0
000000014138eb49: mov      rax, qword ptr [r14 + r12 + 0x20]
000000014138eb4e: movzx    ecx, word ptr [rax + r8*4 + 2]
000000014138eb54: movd     xmm0, ecx
000000014138eb58: cvtdq2ps xmm0, xmm0
000000014138eb5b: addss    xmm0, dword ptr [rsi + rbp + 0x14]
000000014138eb61: movss    dword ptr [r15 + 0x24], xmm0
000000014138eb67: mov      rax, qword ptr [r14 + r12 + 0x20]
000000014138eb6c: movzx    ecx, word ptr [rax + r8*4]
000000014138eb71: movzx    eax, word ptr [r14 + r12 + 8]
000000014138eb77: add      ecx, eax
000000014138eb79: movd     xmm0, ecx
000000014138eb7d: cvtdq2ps xmm0, xmm0
000000014138eb80: addss    xmm0, dword ptr [rsi + rbp + 0x10]
000000014138eb86: movss    dword ptr [r15 + 0x50], xmm0
000000014138eb8c: mov      rax, qword ptr [r14 + r12 + 0x20]
000000014138eb91: movzx    ecx, word ptr [rax + r8*4 + 2]
000000014138eb97: movd     xmm0, ecx
000000014138eb9b: cvtdq2ps xmm0, xmm0
000000014138eb9e: addss    xmm0, dword ptr [rsi + rbp + 0x14]
000000014138eba4: movss    dword ptr [r15 + 0x54], xmm0
000000014138ebaa: mov      rax, qword ptr [r14 + r12 + 0x20]
000000014138ebaf: movzx    ecx, word ptr [rax + r8*4]
000000014138ebb4: movd     xmm0, ecx
000000014138ebb8: cvtdq2ps xmm0, xmm0
000000014138ebbb: addss    xmm0, dword ptr [rsi + rbp + 0x10]
000000014138ebc1: movss    dword ptr [r15 + 0x80], xmm0
000000014138ebca: mov      rax, qword ptr [r14 + r12 + 0x20]
000000014138ebcf: movzx    ecx, word ptr [rax + r8*4 + 2]
000000014138ebd5: movzx    eax, word ptr [r14 + r12 + 0xa]
000000014138ebdb: add      ecx, eax
000000014138ebdd: movd     xmm0, ecx
000000014138ebe1: cvtdq2ps xmm0, xmm0
000000014138ebe4: addss    xmm0, dword ptr [rsi + rbp + 0x14]
000000014138ebea: movss    dword ptr [r15 + 0x84], xmm0
000000014138ebf3: mov      rax, qword ptr [r14 + r12 + 0x20]
000000014138ebf8: movzx    ecx, word ptr [rax + r8*4]
000000014138ebfd: movzx    eax, word ptr [r14 + r12 + 8]
000000014138ec03: add      ecx, eax
000000014138ec05: movd     xmm0, ecx
000000014138ec09: cvtdq2ps xmm0, xmm0
000000014138ec0c: addss    xmm0, dword ptr [rsi + rbp + 0x10]
000000014138ec12: movss    dword ptr [r15 + 0xb0], xmm0
000000014138ec1b: mov      rax, qword ptr [r14 + r12 + 0x20]
000000014138ec20: movzx    ecx, word ptr [rax + r8*4 + 2]
000000014138ec26: movzx    eax, word ptr [r14 + r12 + 0xa]
000000014138ec2c: add      ecx, eax
000000014138ec2e: movd     xmm0, ecx
000000014138ec32: cvtdq2ps xmm0, xmm0
000000014138ec35: addss    xmm0, dword ptr [rsi + rbp + 0x14]
000000014138ec3b: movss    dword ptr [r15 + 0xb4], xmm0
000000014138ec44: mov      ecx, dword ptr [r14 + r12 + 0x18]
000000014138ec49: mov      eax, dword ptr [rdi + 0x68]
000000014138ec4c: mov      r9d, dword ptr [rdi + 0x64]
000000014138ec50: shr      ecx, 0xb
000000014138ec53: and      ecx, 3
000000014138ec56: inc      ecx
000000014138ec58: test     eax, eax
000000014138ec5a: jne      0x14138ec63
000000014138ec5c: mov      eax, ecx
000000014138ec5e: shl      eax, 0x11
000000014138ec61: or       eax, ecx
000000014138ec63: mov      r8d, dword ptr [r13 + 0x18]
000000014138ec67: or       r9d, eax
000000014138ec6a: test     rbx, rbx
000000014138ec6d: je       0x14138ec82
000000014138ec6f: lea      rcx, [rbx + 0x20]
000000014138ec73: mov      dword ptr [rbx + 0x68], r8d
000000014138ec77: mov      dword ptr [rbx + 0x64], r9d
000000014138ec7b: call     0x141216df0
000000014138ec80: jmp      0x14138ec8f
000000014138ec82: mov      edx, 4
000000014138ec87: mov      rcx, r15
000000014138ec8a: call     0x1412543a0
000000014138ec8f: xor      ebx, ebx
000000014138ec91: mov      rcx, qword ptr [rdi + 0x18]
000000014138ec95: add      r14, 0x30
000000014138ec99: mov      ebp, dword ptr [rsp + 0x28]
000000014138ec9d: add      rsi, 0x40
000000014138eca1: inc      ebp
000000014138eca3: mov      dword ptr [rsp + 0x28], ebp
000000014138eca7: mov      rax, qword ptr [rcx]
000000014138ecaa: call     qword ptr [rax + 8]
000000014138ecad: movzx    eax, word ptr [rax + 0x28]
000000014138ecb1: cmp      ebp, eax
000000014138ecb3: jl       0x14138e8d0
000000014138ecb9: mov      ebx, dword ptr [rip + 0x83c3f51]
000000014138ecbf: xor      ebp, ebp
000000014138ecc1: mov      esi, dword ptr [rsp + 0x2c]
000000014138ecc5: mov      r14d, 0x342c
000000014138eccb: mov      r15d, 0x3400
000000014138ecd1: mov      rax, qword ptr [rsp + 0x20]
000000014138ecd6: mov      rdx, qword ptr [rax + 0x10]
000000014138ecda: cmp      byte ptr [rdx + 0x19], 0
000000014138ecde: je       0x14138ed12
000000014138ece0: mov      rcx, qword ptr [rax + 8]
000000014138ece4: cmp      byte ptr [rcx + 0x19], 0
000000014138ece8: jne      0x14138ed08
000000014138ecea: nop      word ptr [rax + rax]
000000014138ecf0: cmp      rax, qword ptr [rcx + 0x10]
000000014138ecf4: jne      0x14138ed08
000000014138ecf6: mov      qword ptr [rsp + 0x20], rcx
000000014138ecfb: mov      rax, rcx
000000014138ecfe: mov      rcx, qword ptr [rcx + 8]
000000014138ed02: cmp      byte ptr [rcx + 0x19], 0
000000014138ed06: je       0x14138ecf0
000000014138ed08: mov      qword ptr [rsp + 0x20], rcx
000000014138ed0d: jmp      0x14138e7e2
000000014138ed12: mov      rcx, qword ptr [rdx]
000000014138ed15: cmp      byte ptr [rcx + 0x19], 0
000000014138ed19: jne      0x14138ed2f
000000014138ed1b: nop      dword ptr [rax + rax]
000000014138ed20: mov      rax, qword ptr [rcx]
000000014138ed23: mov      rdx, rcx
000000014138ed26: mov      rcx, rax
000000014138ed29: cmp      byte ptr [rax + 0x19], 0
000000014138ed2d: je       0x14138ed20
000000014138ed2f: mov      qword ptr [rsp + 0x20], rdx
000000014138ed34: jmp      0x14138e7e2
000000014138ed39: call     0x1412175d0
000000014138ed3e: mov      rcx, qword ptr [rsp + 0x110]
000000014138ed46: xor      rcx, rsp
000000014138ed49: call     0x141441dc0
000000014138ed4e: lea      r11, [rsp + 0x150]
000000014138ed56: mov      rbx, qword ptr [r11 + 0x38]
000000014138ed5a: mov      rbp, qword ptr [r11 + 0x40]
000000014138ed5e: mov      rsi, qword ptr [r11 + 0x48]
000000014138ed62: movaps   xmm6, xmmword ptr [r11 - 0x10]
000000014138ed67: movaps   xmm7, xmmword ptr [r11 - 0x20]
000000014138ed6c: movaps   xmm8, xmmword ptr [r11 - 0x30]
000000014138ed71: mov      rsp, r11
000000014138ed74: pop      r15
000000014138ed76: pop      r14
000000014138ed78: pop      r13
000000014138ed7a: pop      r12
000000014138ed7c: pop      rdi
000000014138ed7d: ret      
000000014138ed7e: int3     
000000014138ed7f: int3     
000000014138ed80: mov      qword ptr [rsp + 8], rbx
000000014138ed85: mov      qword ptr [rsp + 0x10], rbp
000000014138ed8a: mov      qword ptr [rsp + 0x18], rsi
000000014138ed8f: mov      qword ptr [rsp + 0x20], rdi
000000014138ed94: push     r14
000000014138ed96: sub      rsp, 0x30
000000014138ed9a: mov      rbp, rcx
000000014138ed9d: mov      r14, r9
000000014138eda0: mov      rcx, qword ptr [rcx + 0x18]
000000014138eda4: mov      rbx, r8
000000014138eda7: mov      esi, edx
000000014138eda9: mov      rax, qword ptr [rcx]
000000014138edac: call     qword ptr [rax + 8]
000000014138edaf: movzx    ecx, byte ptr [r14 + 6]
000000014138edb4: mov      rdi, qword ptr [rsp + 0x60]
000000014138edb9: cmp      cl, 0xff
000000014138edbc: je       0x14138ede6
000000014138edbe: mov      edx, dword ptr [r14 + 0x18]
000000014138edc2: lea      r9, [rcx + rcx*2]
000000014138edc6: mov      r8d, ecx
000000014138edc9: shl      r9, 4
000000014138edcd: add      r9, qword ptr [rax + 0x10]
000000014138edd1: mov      rcx, rbp
000000014138edd4: shl      r8, 6
000000014138edd8: add      r8, qword ptr [rbp + 0x28]
000000014138eddc: mov      qword ptr [rsp + 0x20], rdi
000000014138ede1: call     0x14138ed80
000000014138ede6: test     sil, 2
000000014138edea: je       0x14138edfd
000000014138edec: movss    xmm1, dword ptr [rbx + 4]
000000014138edf1: xorps    xmm2, xmm2
000000014138edf4: movss    xmm0, dword ptr [rbx]
000000014138edf8: call     0x1412183e0
000000014138edfd: movss    xmm1, dword ptr [rdi + 4]
000000014138ee02: xorps    xmm2, xmm2
000000014138ee05: movss    xmm0, dword ptr [rdi]
000000014138ee09: call     0x1412183e0
000000014138ee0e: test     sil, 8
000000014138ee12: je       0x14138ee1c
000000014138ee14: mov      ecx, dword ptr [rbx + 0x30]
000000014138ee17: call     0x141218060
000000014138ee1c: test     sil, 0x20
000000014138ee20: je       0x14138ee39
000000014138ee22: movss    xmm2, dword ptr [rip + 0x3d27b6]
000000014138ee2a: movss    xmm1, dword ptr [rbx + 0xc]
000000014138ee2f: movss    xmm0, dword ptr [rbx + 8]
000000014138ee34: call     0x1412181b0
000000014138ee39: movss    xmm1, dword ptr [rdi + 4]
000000014138ee3e: xorps    xmm2, xmm2
000000014138ee41: movss    xmm0, dword ptr [rdi]
000000014138ee45: xorps    xmm1, xmmword ptr [rip + 0x3d2354]
000000014138ee4c: xorps    xmm0, xmmword ptr [rip + 0x3d234d]
000000014138ee53: call     0x1412183e0
000000014138ee58: test     sil, 0x10
000000014138ee5c: je       0x14138ee66
000000014138ee5e: mov      ecx, dword ptr [rbx + 0x30]
000000014138ee61: call     0x141218060
000000014138ee66: test     sil, 4
000000014138ee6a: je       0x14138eee4
000000014138ee6c: mov      eax, dword ptr [r14]
000000014138ee6f: xorps    xmm2, xmm2
000000014138ee72: shr      eax, 0x18
000000014138ee75: cvtsi2ss xmm2, rax
000000014138ee7a: mulss    xmm2, dword ptr [rip + 0x691506]
000000014138ee82: movaps   xmm0, xmm2
000000014138ee85: movaps   xmm1, xmm2
000000014138ee88: mulss    xmm0, dword ptr [rdi + 0x1c]
000000014138ee8d: mulss    xmm1, dword ptr [rdi + 0x4c]
000000014138ee92: movss    dword ptr [rdi + 0x1c], xmm0
000000014138ee97: mulss    xmm0, dword ptr [rbx + 0x2c]
000000014138ee9c: movss    dword ptr [rdi + 0x4c], xmm1
000000014138eea1: movss    dword ptr [rdi + 0x1c], xmm0
000000014138eea6: movaps   xmm0, xmm2
000000014138eea9: mulss    xmm1, dword ptr [rbx + 0x2c]
000000014138eeae: mulss    xmm0, dword ptr [rdi + 0x7c]
000000014138eeb3: mulss    xmm2, dword ptr [rdi + 0xac]
000000014138eebb: movss    dword ptr [rdi + 0x7c], xmm0
000000014138eec0: movss    dword ptr [rdi + 0x4c], xmm1
000000014138eec5: mulss    xmm0, dword ptr [rbx + 0x2c]
000000014138eeca: movss    dword ptr [rdi + 0xac], xmm2
000000014138eed2: movss    dword ptr [rdi + 0x7c], xmm0
000000014138eed7: mulss    xmm2, dword ptr [rbx + 0x2c]
000000014138eedc: movss    dword ptr [rdi + 0xac], xmm2
000000014138eee4: mov      rbx, qword ptr [rsp + 0x40]
000000014138eee9: mov      rbp, qword ptr [rsp + 0x48]
000000014138eeee: mov      rsi, qword ptr [rsp + 0x50]
000000014138eef3: mov      rdi, qword ptr [rsp + 0x58]
000000014138eef8: add      rsp, 0x30
000000014138eefc: pop      r14
000000014138eefe: ret      
000000014138eeff: int3     
000000014138ef00: mov      qword ptr [rsp + 8], rbx
000000014138ef05: mov      qword ptr [rsp + 0x10], rbp
000000014138ef0a: mov      qword ptr [rsp + 0x18], rsi
000000014138ef0f: push     rdi
000000014138ef10: push     r14
000000014138ef12: push     r15
000000014138ef14: sub      rsp, 0x30
000000014138ef18: mov      rbp, rcx
000000014138ef1b: mov      r14, r9
000000014138ef1e: mov      rcx, qword ptr [rcx + 0x18]
000000014138ef22: mov      rsi, r8
000000014138ef25: mov      ebx, edx
000000014138ef27: mov      rax, qword ptr [rcx]
000000014138ef2a: call     qword ptr [rax + 8]
000000014138ef2d: movzx    ecx, byte ptr [r14 + 6]
000000014138ef32: mov      r15, rax
000000014138ef35: mov      rdi, qword ptr [rsp + 0x70]
000000014138ef3a: cmp      cl, 0xff
000000014138ef3d: je       0x14138ef67
000000014138ef3f: mov      edx, dword ptr [r14 + 0x18]
000000014138ef43: lea      r9, [rcx + rcx*2]
000000014138ef47: mov      r8d, ecx
000000014138ef4a: shl      r9, 4
000000014138ef4e: add      r9, qword ptr [rax + 0x10]
000000014138ef52: mov      rcx, rbp
000000014138ef55: shl      r8, 6
000000014138ef59: add      r8, qword ptr [rbp + 0x28]
000000014138ef5d: mov      qword ptr [rsp + 0x20], rdi
000000014138ef62: call     0x14138ef00
000000014138ef67: test     bl, 2
000000014138ef6a: je       0x14138ef7d
000000014138ef6c: movss    xmm1, dword ptr [rsi + 4]
000000014138ef71: xorps    xmm2, xmm2
000000014138ef74: movss    xmm0, dword ptr [rsi]
000000014138ef78: call     0x1412183e0
000000014138ef7d: movss    xmm1, dword ptr [rdi + 4]
000000014138ef82: xorps    xmm2, xmm2
000000014138ef85: movss    xmm0, dword ptr [rdi]
000000014138ef89: call     0x1412183e0
000000014138ef8e: test     bl, 8
000000014138ef91: je       0x14138ef9b
000000014138ef93: mov      ecx, dword ptr [rsi + 0x30]
000000014138ef96: call     0x141218060
000000014138ef9b: test     bl, 0x20
000000014138ef9e: je       0x14138efb7
000000014138efa0: movss    xmm2, dword ptr [rip + 0x3d2638]
000000014138efa8: movss    xmm1, dword ptr [rsi + 0xc]
000000014138efad: movss    xmm0, dword ptr [rsi + 8]
000000014138efb2: call     0x1412181b0
000000014138efb7: movss    xmm1, dword ptr [rdi + 4]
000000014138efbc: xorps    xmm2, xmm2
000000014138efbf: movss    xmm0, dword ptr [rdi]
000000014138efc3: xorps    xmm1, xmmword ptr [rip + 0x3d21d6]
000000014138efca: xorps    xmm0, xmmword ptr [rip + 0x3d21cf]
000000014138efd1: call     0x1412183e0
000000014138efd6: test     bl, 0x10
000000014138efd9: je       0x14138f02e
000000014138efdb: movzx    edi, word ptr [r14 + 0x10]
000000014138efe0: xorps    xmm2, xmm2
000000014138efe3: mov      rbx, qword ptr [r15 + 0x18]
000000014138efe7: movsx    eax, word ptr [rbx + rdi*4 + 2]
000000014138efec: movd     xmm1, eax
000000014138eff0: movsx    eax, word ptr [rbx + rdi*4]
000000014138eff4: cvtdq2ps xmm1, xmm1
000000014138eff7: movd     xmm0, eax
000000014138effb: cvtdq2ps xmm0, xmm0
000000014138effe: call     0x1412183e0
000000014138f003: mov      ecx, dword ptr [rsi + 0x30]
000000014138f006: call     0x141218060
000000014138f00b: movsx    eax, word ptr [rbx + rdi*4 + 2]
000000014138f010: xorps    xmm2, xmm2
000000014138f013: neg      eax
000000014138f015: movd     xmm1, eax
000000014138f019: movsx    eax, word ptr [rbx + rdi*4]
000000014138f01d: neg      eax
000000014138f01f: cvtdq2ps xmm1, xmm1
000000014138f022: movd     xmm0, eax
000000014138f026: cvtdq2ps xmm0, xmm0
000000014138f029: call     0x1412183e0
000000014138f02e: mov      rbx, qword ptr [rsp + 0x50]
000000014138f033: mov      rbp, qword ptr [rsp + 0x58]
000000014138f038: mov      rsi, qword ptr [rsp + 0x60]
000000014138f03d: add      rsp, 0x30
000000014138f041: pop      r15
000000014138f043: pop      r14
000000014138f045: pop      rdi
000000014138f046: ret      
000000014138f047: int3     
000000014138f048: int3     
000000014138f049: int3     
000000014138f04a: int3     
000000014138f04b: int3     
000000014138f04c: int3     
000000014138f04d: int3     
000000014138f04e: int3     
000000014138f04f: int3     
000000014138f050: mov      r11, rsp
000000014138f053: push     rbx
000000014138f054: sub      rsp, 0xe0
000000014138f05b: mov      rax, qword ptr [rip + 0xd57366]
000000014138f062: xor      rax, rsp
000000014138f065: mov      qword ptr [rsp + 0x70], rax
000000014138f06a: cmp      dword ptr [rcx + 0x78], 0
000000014138f06e: mov      rbx, rcx
000000014138f071: je       0x14138f434
000000014138f077: mov      qword ptr [r11 + 0x20], rdi
000000014138f07b: mov      qword ptr [r11 - 0x18], r13
000000014138f07f: call     0x141217670
000000014138f084: call     0x141216e70
000000014138f089: mov      rcx, qword ptr [rbx + 0x18]
000000014138f08d: xor      edi, edi
000000014138f08f: mov      r13d, edi
000000014138f092: mov      rax, qword ptr [rcx]
000000014138f095: call     qword ptr [rax + 8]
000000014138f098: cmp      di, word ptr [rax + 0x28]
000000014138f09c: jae      0x14138f41c
000000014138f0a2: mov      qword ptr [rsp + 0xf8], rbp
000000014138f0aa: mov      qword ptr [rsp + 0x100], rsi
000000014138f0b2: mov      qword ptr [rsp + 0xd8], r12
000000014138f0ba: mov      qword ptr [rsp + 0xc8], r14
000000014138f0c2: mov      r14d, edi
000000014138f0c5: mov      qword ptr [rsp + 0xc0], r15
000000014138f0cd: mov      r15d, edi
000000014138f0d0: movaps   xmmword ptr [rsp + 0xb0], xmm6
000000014138f0d8: movss    xmm6, dword ptr [rip + 0x3d2500]
000000014138f0e0: movaps   xmmword ptr [rsp + 0xa0], xmm7
000000014138f0e8: movaps   xmmword ptr [rsp + 0x90], xmm8
000000014138f0f1: movaps   xmmword ptr [rsp + 0x80], xmm9
000000014138f0fa: movss    xmm9, dword ptr [rip + 0x3d209d]
000000014138f103: mov      rcx, qword ptr [rbx + 0x18]
000000014138f107: mov      rax, qword ptr [rcx]
000000014138f10a: call     qword ptr [rax + 8]
000000014138f10d: mov      r12, qword ptr [rbx + 0x28]
000000014138f111: mov      rbp, rax
000000014138f114: mov      rsi, qword ptr [rax + 0x10]
000000014138f118: mov      rdx, qword ptr [rax + 0x18]
000000014138f11c: lea      rdi, [rsi + 0x10]
000000014138f120: add      rdi, r14
000000014138f123: movzx    r8d, word ptr [rdi]
000000014138f127: movsx    ecx, word ptr [rdx + r8*4]
000000014138f12c: movd     xmm0, ecx
000000014138f130: cvtdq2ps xmm0, xmm0
000000014138f133: movss    dword ptr [rsp + 0x40], xmm0
000000014138f139: movsx    ecx, word ptr [rdx + r8*4 + 2]
000000014138f13f: mov      dword ptr [rsp + 0x48], 0x3f800000
000000014138f147: movd     xmm1, ecx
000000014138f14b: cvtdq2ps xmm1, xmm1
000000014138f14e: movss    dword ptr [rsp + 0x44], xmm1
000000014138f154: mov      rcx, qword ptr [rax + 0x18]
000000014138f158: movzx    edx, word ptr [r14 + rsi + 0x12]
000000014138f15e: movsx    eax, word ptr [rcx + rdx*4]
000000014138f162: movd     xmm0, eax
000000014138f166: cvtdq2ps xmm0, xmm0
000000014138f169: movss    dword ptr [rsp + 0x4c], xmm0
000000014138f16f: movsx    eax, word ptr [rcx + rdx*4 + 2]
000000014138f174: mov      dword ptr [rsp + 0x54], 0x3f800000
000000014138f17c: movd     xmm1, eax
000000014138f180: cvtdq2ps xmm1, xmm1
000000014138f183: movss    dword ptr [rsp + 0x50], xmm1
000000014138f189: movzx    edx, word ptr [r14 + rsi + 0x14]
000000014138f18f: mov      rcx, qword ptr [rbp + 0x18]
000000014138f193: movsx    eax, word ptr [rcx + rdx*4]
000000014138f197: movd     xmm0, eax
000000014138f19b: cvtdq2ps xmm0, xmm0
000000014138f19e: movss    dword ptr [rsp + 0x58], xmm0
000000014138f1a4: movsx    eax, word ptr [rcx + rdx*4 + 2]
000000014138f1a9: mov      dword ptr [rsp + 0x60], 0x3f800000
000000014138f1b1: movd     xmm1, eax
000000014138f1b5: cvtdq2ps xmm1, xmm1
000000014138f1b8: movss    dword ptr [rsp + 0x5c], xmm1
000000014138f1be: movzx    edx, word ptr [r14 + rsi + 0x16]
000000014138f1c4: mov      rcx, qword ptr [rbp + 0x18]
000000014138f1c8: movsx    eax, word ptr [rcx + rdx*4]
000000014138f1cc: movd     xmm0, eax
000000014138f1d0: cvtdq2ps xmm0, xmm0
000000014138f1d3: movss    dword ptr [rsp + 0x64], xmm0
000000014138f1d9: movsx    eax, word ptr [rcx + rdx*4 + 2]
000000014138f1de: mov      dword ptr [rsp + 0x6c], 0x3f800000
000000014138f1e6: movd     xmm1, eax
000000014138f1ea: cvtdq2ps xmm1, xmm1
000000014138f1ed: movss    dword ptr [rsp + 0x68], xmm1
000000014138f1f3: call     0x141217670
000000014138f1f8: movzx    eax, byte ptr [r14 + rsi + 6]
000000014138f1fe: cmp      al, 0xff
000000014138f200: je       0x14138f230
000000014138f202: mov      edx, dword ptr [r14 + rsi + 0x18]
000000014138f207: lea      r9, [rax + rax*2]
000000014138f20b: mov      r8d, eax
000000014138f20e: shl      r9, 4
000000014138f212: add      r9, qword ptr [rbp + 0x10]
000000014138f216: lea      rax, [rsp + 0x40]
000000014138f21b: shl      r8, 6
000000014138f21f: mov      rcx, rbx
000000014138f222: add      r8, qword ptr [rbx + 0x28]
000000014138f226: mov      qword ptr [rsp + 0x20], rax
000000014138f22b: call     0x14138ef00
000000014138f230: movss    xmm1, dword ptr [rbx + 0x48]
000000014138f235: xorps    xmm2, xmm2
000000014138f238: movss    xmm0, dword ptr [rbx + 0x44]
000000014138f23d: call     0x1412183e0
000000014138f242: movss    xmm1, dword ptr [rbx + 0x40]
000000014138f247: movaps   xmm2, xmm6
000000014138f24a: movss    xmm0, dword ptr [rbx + 0x3c]
000000014138f24f: call     0x1412181b0
000000014138f254: movss    xmm1, dword ptr [rbx + 0x48]
000000014138f259: xorps    xmm2, xmm2
000000014138f25c: movss    xmm0, dword ptr [rbx + 0x44]
000000014138f261: xorps    xmm1, xmm9
000000014138f265: xorps    xmm0, xmm9
000000014138f269: call     0x1412183e0
000000014138f26e: mov      eax, dword ptr [r14 + rsi + 0x18]
000000014138f273: xor      ebp, ebp
000000014138f275: movaps   xmm8, xmm6
000000014138f279: movaps   xmm7, xmm6
000000014138f27c: test     al, 0x40
000000014138f27e: je       0x14138f28b
000000014138f280: divss    xmm8, dword ptr [rbx + 0x3c]
000000014138f286: mov      ebp, 1
000000014138f28b: test     al, al
000000014138f28d: jns      0x14138f29c
000000014138f28f: movaps   xmm7, xmm6
000000014138f292: mov      ebp, 1
000000014138f297: divss    xmm7, dword ptr [rbx + 0x40]
000000014138f29c: movss    xmm1, dword ptr [r15 + r12 + 4]
000000014138f2a3: xorps    xmm2, xmm2
000000014138f2a6: movss    xmm0, dword ptr [r15 + r12]
000000014138f2ac: call     0x1412183e0
000000014138f2b1: movsx    eax, word ptr [r14 + rsi + 0xe]
000000014138f2b7: xorps    xmm2, xmm2
000000014138f2ba: movd     xmm1, eax
000000014138f2be: movsx    eax, word ptr [r14 + rsi + 0xc]
000000014138f2c4: cvtdq2ps xmm1, xmm1
000000014138f2c7: movd     xmm0, eax
000000014138f2cb: addss    xmm1, dword ptr [rsp + 0x44]
000000014138f2d1: cvtdq2ps xmm0, xmm0
000000014138f2d4: addss    xmm0, dword ptr [rsp + 0x40]
000000014138f2da: call     0x1412183e0
000000014138f2df: test     ebp, ebp
000000014138f2e1: je       0x14138f2f2
000000014138f2e3: movaps   xmm2, xmm6
000000014138f2e6: movaps   xmm1, xmm7
000000014138f2e9: movaps   xmm0, xmm8
000000014138f2ed: call     0x1412181b0
000000014138f2f2: movss    xmm1, dword ptr [r15 + r12 + 0xc]
000000014138f2f9: movaps   xmm2, xmm6
000000014138f2fc: movss    xmm0, dword ptr [r15 + r12 + 8]
000000014138f303: call     0x1412181b0
000000014138f308: mov      ecx, dword ptr [r15 + r12 + 0x30]
000000014138f30d: call     0x141218060
000000014138f312: movsx    eax, word ptr [r14 + rsi + 0xe]
000000014138f318: movss    xmm1, dword ptr [rsp + 0x44]
000000014138f31e: xorps    xmm1, xmm9
000000014138f322: movd     xmm0, eax
000000014138f326: movsx    eax, word ptr [r14 + rsi + 0xc]
000000014138f32c: cvtdq2ps xmm0, xmm0
000000014138f32f: movd     xmm2, eax
000000014138f333: subss    xmm1, xmm0
000000014138f337: movss    xmm0, dword ptr [rsp + 0x40]
000000014138f33d: cvtdq2ps xmm2, xmm2
000000014138f340: xorps    xmm0, xmm9
000000014138f344: subss    xmm0, xmm2
000000014138f348: xorps    xmm2, xmm2
000000014138f34b: call     0x1412183e0
000000014138f350: lea      rsi, [rsp + 0x40]
000000014138f355: mov      ebp, 4
000000014138f35a: nop      word ptr [rax + rax]
000000014138f360: mov      rdx, rsi
000000014138f363: lea      rcx, [rsp + 0x30]
000000014138f368: call     0x141214d80
000000014138f36d: movzx    eax, word ptr [rdi]
000000014138f370: lea      rdi, [rdi + 2]
000000014138f374: movss    xmm0, dword ptr [rsp + 0x30]
000000014138f37a: add      rsi, 0xc
000000014138f37e: lea      rcx, [rax + rax*2]
000000014138f382: mov      rax, qword ptr [rbx + 0x70]
000000014138f386: movss    dword ptr [rax + rcx*4], xmm0
000000014138f38b: movzx    eax, word ptr [rdi - 2]
000000014138f38f: movss    xmm0, dword ptr [rsp + 0x34]
000000014138f395: lea      rcx, [rax + rax*2]
000000014138f399: mov      rax, qword ptr [rbx + 0x70]
000000014138f39d: movss    dword ptr [rax + rcx*4 + 4], xmm0
000000014138f3a3: sub      rbp, 1
000000014138f3a7: jne      0x14138f360
000000014138f3a9: call     0x1412175d0
000000014138f3ae: mov      rcx, qword ptr [rbx + 0x18]
000000014138f3b2: inc      r13d
000000014138f3b5: add      r14, 0x30
000000014138f3b9: add      r15, 0x40
000000014138f3bd: mov      rax, qword ptr [rcx]
000000014138f3c0: call     qword ptr [rax + 8]
000000014138f3c3: movzx    eax, word ptr [rax + 0x28]
000000014138f3c7: cmp      r13d, eax
000000014138f3ca: jl       0x14138f103
000000014138f3d0: movaps   xmm9, xmmword ptr [rsp + 0x80]
000000014138f3d9: xor      edi, edi
000000014138f3db: movaps   xmm8, xmmword ptr [rsp + 0x90]
000000014138f3e4: movaps   xmm7, xmmword ptr [rsp + 0xa0]
000000014138f3ec: movaps   xmm6, xmmword ptr [rsp + 0xb0]
000000014138f3f4: mov      r15, qword ptr [rsp + 0xc0]
000000014138f3fc: mov      r14, qword ptr [rsp + 0xc8]
000000014138f404: mov      r12, qword ptr [rsp + 0xd8]
000000014138f40c: mov      rsi, qword ptr [rsp + 0x100]
000000014138f414: mov      rbp, qword ptr [rsp + 0xf8]
000000014138f41c: call     0x1412175d0
000000014138f421: mov      r13, qword ptr [rsp + 0xd0]
000000014138f429: mov      dword ptr [rbx + 0x78], edi
000000014138f42c: mov      rdi, qword ptr [rsp + 0x108]
000000014138f434: mov      rcx, qword ptr [rsp + 0x70]
000000014138f439: xor      rcx, rsp
000000014138f43c: call     0x141441dc0
000000014138f441: add      rsp, 0xe0
000000014138f448: pop      rbx
000000014138f449: ret      
000000014138f44a: int3     
000000014138f44b: int3     
000000014138f44c: int3     
000000014138f44d: int3     
000000014138f44e: int3     
000000014138f44f: int3     
000000014138f450: mov      rax, rsp
000000014138f453: mov      qword ptr [rax + 0x18], rbx
000000014138f457: mov      qword ptr [rax + 0x20], rbp
000000014138f45b: push     rsi
000000014138f45c: push     rdi
000000014138f45d: push     r14
000000014138f45f: sub      rsp, 0xc0
000000014138f466: movaps   xmmword ptr [rax - 0x28], xmm6
000000014138f46a: movaps   xmmword ptr [rax - 0x38], xmm7
000000014138f46e: movaps   xmmword ptr [rax - 0x48], xmm8
000000014138f473: movaps   xmmword ptr [rax - 0x58], xmm9
000000014138f478: mov      rax, qword ptr [rip + 0xd56f49]
000000014138f47f: xor      rax, rsp
000000014138f482: mov      qword ptr [rsp + 0x70], rax
000000014138f487: mov      rdi, rcx
000000014138f48a: movsxd   rbx, edx
000000014138f48d: mov      rcx, qword ptr [rcx + 0x18]
000000014138f491: mov      rax, qword ptr [rcx]
000000014138f494: call     qword ptr [rax + 8]
000000014138f497: movss    xmm6, dword ptr [rip + 0x3d2141]
000000014138f49f: lea      rsi, [rbx + rbx*2]
000000014138f4a3: mov      rbp, rax
000000014138f4a6: shl      rsi, 4
000000014138f4aa: mov      r14, rbx
000000014138f4ad: add      rsi, qword ptr [rax + 0x10]
000000014138f4b1: mov      rcx, qword ptr [rax + 0x18]
000000014138f4b5: lea      rbx, [rsi + 0x10]
000000014138f4b9: movzx    edx, word ptr [rbx]
000000014138f4bc: shl      r14, 6
000000014138f4c0: add      r14, qword ptr [rdi + 0x28]
000000014138f4c4: movsx    eax, word ptr [rcx + rdx*4]
000000014138f4c8: movd     xmm0, eax
000000014138f4cc: cvtdq2ps xmm0, xmm0
000000014138f4cf: movss    dword ptr [rsp + 0x40], xmm0
000000014138f4d5: movsx    eax, word ptr [rcx + rdx*4 + 2]
000000014138f4da: mov      dword ptr [rsp + 0x48], 0x3f800000
000000014138f4e2: movd     xmm1, eax
000000014138f4e6: cvtdq2ps xmm1, xmm1
000000014138f4e9: movss    dword ptr [rsp + 0x44], xmm1
000000014138f4ef: movzx    edx, word ptr [rsi + 0x12]
000000014138f4f3: mov      rcx, qword ptr [rbp + 0x18]
000000014138f4f7: movsx    eax, word ptr [rcx + rdx*4]
000000014138f4fb: movd     xmm0, eax
000000014138f4ff: cvtdq2ps xmm0, xmm0
000000014138f502: movss    dword ptr [rsp + 0x4c], xmm0
000000014138f508: movsx    eax, word ptr [rcx + rdx*4 + 2]
000000014138f50d: mov      dword ptr [rsp + 0x54], 0x3f800000
000000014138f515: movd     xmm1, eax
000000014138f519: cvtdq2ps xmm1, xmm1
000000014138f51c: movss    dword ptr [rsp + 0x50], xmm1
000000014138f522: movzx    edx, word ptr [rsi + 0x14]
000000014138f526: mov      rcx, qword ptr [rbp + 0x18]
000000014138f52a: movsx    eax, word ptr [rcx + rdx*4]
000000014138f52e: movd     xmm0, eax
000000014138f532: cvtdq2ps xmm0, xmm0
000000014138f535: movss    dword ptr [rsp + 0x58], xmm0
000000014138f53b: movsx    eax, word ptr [rcx + rdx*4 + 2]
000000014138f540: mov      dword ptr [rsp + 0x60], 0x3f800000
000000014138f548: movd     xmm1, eax
000000014138f54c: cvtdq2ps xmm1, xmm1
000000014138f54f: movss    dword ptr [rsp + 0x5c], xmm1
000000014138f555: movzx    edx, word ptr [rsi + 0x16]
000000014138f559: mov      rcx, qword ptr [rbp + 0x18]
000000014138f55d: movsx    eax, word ptr [rcx + rdx*4]
000000014138f561: movd     xmm0, eax
000000014138f565: cvtdq2ps xmm0, xmm0
000000014138f568: movss    dword ptr [rsp + 0x64], xmm0
000000014138f56e: movsx    eax, word ptr [rcx + rdx*4 + 2]
000000014138f573: mov      dword ptr [rsp + 0x6c], 0x3f800000
000000014138f57b: movd     xmm1, eax
000000014138f57f: cvtdq2ps xmm1, xmm1
000000014138f582: movss    dword ptr [rsp + 0x68], xmm1
000000014138f588: call     0x141217670
000000014138f58d: movzx    eax, byte ptr [rsi + 6]
000000014138f591: cmp      al, 0xff
000000014138f593: je       0x14138f5c1
000000014138f595: mov      edx, dword ptr [rsi + 0x18]
000000014138f598: lea      r9, [rax + rax*2]
000000014138f59c: mov      r8d, eax
000000014138f59f: shl      r9, 4
000000014138f5a3: add      r9, qword ptr [rbp + 0x10]
000000014138f5a7: lea      rax, [rsp + 0x40]
000000014138f5ac: shl      r8, 6
000000014138f5b0: mov      rcx, rdi
000000014138f5b3: add      r8, qword ptr [rdi + 0x28]
000000014138f5b7: mov      qword ptr [rsp + 0x20], rax
000000014138f5bc: call     0x14138ef00
000000014138f5c1: movss    xmm1, dword ptr [rdi + 0x48]
000000014138f5c6: xorps    xmm2, xmm2
000000014138f5c9: movss    xmm0, dword ptr [rdi + 0x44]
000000014138f5ce: call     0x1412183e0
000000014138f5d3: movss    xmm1, dword ptr [rdi + 0x40]
000000014138f5d8: movaps   xmm2, xmm6
000000014138f5db: movss    xmm0, dword ptr [rdi + 0x3c]
000000014138f5e0: call     0x1412181b0
000000014138f5e5: movss    xmm1, dword ptr [rdi + 0x48]
000000014138f5ea: xorps    xmm2, xmm2
000000014138f5ed: movss    xmm0, dword ptr [rdi + 0x44]
000000014138f5f2: movss    xmm9, dword ptr [rip + 0x3d1ba5]
000000014138f5fb: xorps    xmm1, xmm9
000000014138f5ff: xorps    xmm0, xmm9
000000014138f603: call     0x1412183e0
000000014138f608: mov      ecx, dword ptr [rsi + 0x18]
000000014138f60b: movaps   xmm8, xmm6
000000014138f60f: mov      eax, ecx
000000014138f611: movaps   xmm7, xmm6
000000014138f614: and      eax, 0x40
000000014138f617: je       0x14138f61f
000000014138f619: divss    xmm8, dword ptr [rdi + 0x3c]
000000014138f61f: xor      ebp, ebp
000000014138f621: test     eax, eax
000000014138f623: setne    bpl
000000014138f627: test     cl, cl
000000014138f629: jns      0x14138f638
000000014138f62b: movaps   xmm7, xmm6
000000014138f62e: mov      ebp, 1
000000014138f633: divss    xmm7, dword ptr [rdi + 0x40]
000000014138f638: movss    xmm1, dword ptr [r14 + 4]
000000014138f63e: xorps    xmm2, xmm2
000000014138f641: movss    xmm0, dword ptr [r14]
000000014138f646: call     0x1412183e0
000000014138f64b: movsx    eax, word ptr [rsi + 0xe]
000000014138f64f: xorps    xmm2, xmm2
000000014138f652: movd     xmm1, eax
000000014138f656: movsx    eax, word ptr [rsi + 0xc]
000000014138f65a: cvtdq2ps xmm1, xmm1
000000014138f65d: movd     xmm0, eax
000000014138f661: addss    xmm1, dword ptr [rsp + 0x44]
000000014138f667: cvtdq2ps xmm0, xmm0
000000014138f66a: addss    xmm0, dword ptr [rsp + 0x40]
000000014138f670: call     0x1412183e0
000000014138f675: test     ebp, ebp
000000014138f677: je       0x14138f688
000000014138f679: movaps   xmm2, xmm6
000000014138f67c: movaps   xmm1, xmm7
000000014138f67f: movaps   xmm0, xmm8
000000014138f683: call     0x1412181b0
000000014138f688: movss    xmm1, dword ptr [r14 + 0xc]
000000014138f68e: movaps   xmm2, xmm6
000000014138f691: movss    xmm0, dword ptr [r14 + 8]
000000014138f697: call     0x1412181b0
000000014138f69c: mov      ecx, dword ptr [r14 + 0x30]
000000014138f6a0: call     0x141218060
000000014138f6a5: movsx    eax, word ptr [rsi + 0xe]
000000014138f6a9: xorps    xmm2, xmm2
000000014138f6ac: movss    xmm1, dword ptr [rsp + 0x44]
000000014138f6b2: xorps    xmm1, xmm9
000000014138f6b6: movd     xmm0, eax
000000014138f6ba: movsx    eax, word ptr [rsi + 0xc]
000000014138f6be: cvtdq2ps xmm0, xmm0
000000014138f6c1: movd     xmm3, eax
000000014138f6c5: subss    xmm1, xmm0
000000014138f6c9: movss    xmm0, dword ptr [rsp + 0x40]
000000014138f6cf: cvtdq2ps xmm3, xmm3
000000014138f6d2: xorps    xmm0, xmm9
000000014138f6d6: subss    xmm0, xmm3
000000014138f6da: call     0x1412183e0
000000014138f6df: lea      rsi, [rsp + 0x40]
000000014138f6e4: mov      ebp, 4
000000014138f6e9: nop      dword ptr [rax]
000000014138f6f0: mov      rdx, rsi
000000014138f6f3: lea      rcx, [rsp + 0x30]
000000014138f6f8: call     0x141214d80
000000014138f6fd: movzx    eax, word ptr [rbx]
000000014138f700: lea      rbx, [rbx + 2]
000000014138f704: movss    xmm0, dword ptr [rsp + 0x30]
000000014138f70a: add      rsi, 0xc
000000014138f70e: lea      rcx, [rax + rax*2]
000000014138f712: mov      rax, qword ptr [rdi + 0x70]
000000014138f716: movss    dword ptr [rax + rcx*4], xmm0
000000014138f71b: movzx    eax, word ptr [rbx - 2]
000000014138f71f: movss    xmm0, dword ptr [rsp + 0x34]
000000014138f725: lea      rcx, [rax + rax*2]
000000014138f729: mov      rax, qword ptr [rdi + 0x70]
000000014138f72d: movss    dword ptr [rax + rcx*4 + 4], xmm0
000000014138f733: sub      rbp, 1
000000014138f737: jne      0x14138f6f0
000000014138f739: call     0x1412175d0
000000014138f73e: mov      rcx, qword ptr [rsp + 0x70]
000000014138f743: xor      rcx, rsp
000000014138f746: call     0x141441dc0
000000014138f74b: lea      r11, [rsp + 0xc0]
000000014138f753: mov      rbx, qword ptr [r11 + 0x30]
000000014138f757: mov      rbp, qword ptr [r11 + 0x38]
000000014138f75b: movaps   xmm6, xmmword ptr [r11 - 0x10]
000000014138f760: movaps   xmm7, xmmword ptr [r11 - 0x20]
000000014138f765: movaps   xmm8, xmmword ptr [r11 - 0x30]
000000014138f76a: movaps   xmm9, xmmword ptr [r11 - 0x40]
000000014138f76f: mov      rsp, r11
000000014138f772: pop      r14
000000014138f774: pop      rdi
000000014138f775: pop      rsi
000000014138f776: ret      
000000014138f777: int3     
000000014138f778: int3     
000000014138f779: int3     
000000014138f77a: int3     
000000014138f77b: int3     
000000014138f77c: int3     
000000014138f77d: int3     
000000014138f77e: int3     
000000014138f77f: int3     
000000014138f780: mov      qword ptr [rsp + 0x10], rbx
000000014138f785: mov      qword ptr [rsp + 8], rcx
000000014138f78a: push     rdi
000000014138f78b: sub      rsp, 0x20
000000014138f78f: mov      rbx, rdx
000000014138f792: mov      rdi, rcx
000000014138f795: call     0x141273620
000000014138f79a: xor      ecx, ecx
000000014138f79c: mov      qword ptr [rdi + 0x20], rcx
000000014138f7a0: lea      rax, [rip + 0x815461]
000000014138f7a7: mov      qword ptr [rdi], rax
000000014138f7aa: mov      qword ptr [rdi + 0x18], rcx
000000014138f7ae: mov      qword ptr [rdi + 0x30], rcx
000000014138f7b2: mov      qword ptr [rdi + 0x28], rcx
000000014138f7b6: mov      qword ptr [rdi + 0x40], rcx
000000014138f7ba: mov      word ptr [rdi + 0x38], cx
000000014138f7be: mov      rdx, rbx
000000014138f7c1: mov      rcx, rdi
000000014138f7c4: call     0x14138ff10
000000014138f7c9: nop      
000000014138f7ca: mov      rax, rdi
000000014138f7cd: mov      rbx, qword ptr [rsp + 0x38]
000000014138f7d2: add      rsp, 0x20
000000014138f7d6: pop      rdi
000000014138f7d7: ret      
000000014138f7d8: int3     
000000014138f7d9: int3     
000000014138f7da: int3     
000000014138f7db: int3     
000000014138f7dc: int3     
000000014138f7dd: int3     
000000014138f7de: int3     
000000014138f7df: int3     
000000014138f7e0: push     rbx
000000014138f7e2: sub      rsp, 0x20
000000014138f7e6: mov      rbx, rcx
000000014138f7e9: call     0x141273620
000000014138f7ee: xor      ecx, ecx
000000014138f7f0: lea      rax, [rip + 0x815411]
000000014138f7f7: mov      qword ptr [rbx], rax
000000014138f7fa: mov      rax, rbx
000000014138f7fd: mov      qword ptr [rbx + 0x20], rcx
000000014138f801: mov      qword ptr [rbx + 0x18], rcx
000000014138f805: mov      qword ptr [rbx + 0x30], rcx
000000014138f809: mov      qword ptr [rbx + 0x28], rcx
000000014138f80d: mov      qword ptr [rbx + 0x40], rcx
000000014138f811: mov      word ptr [rbx + 0x38], cx
000000014138f815: add      rsp, 0x20
000000014138f819: pop      rbx
000000014138f81a: ret      
000000014138f81b: int3     
000000014138f81c: int3     
000000014138f81d: int3     
000000014138f81e: int3     
000000014138f81f: int3     
000000014138f820: push     rbx
000000014138f822: sub      rsp, 0x20
000000014138f826: test     byte ptr [rcx + 0x38], 2
000000014138f82a: lea      rax, [rip + 0x8153d7]
000000014138f831: mov      qword ptr [rcx], rax
000000014138f834: mov      rbx, rcx
000000014138f837: je       0x14138f864
000000014138f839: mov      rcx, qword ptr [rcx + 0x28]
000000014138f83d: test     rcx, rcx
000000014138f840: je       0x14138f854
000000014138f842: mov      rax, qword ptr [rcx]
000000014138f845: mov      edx, 1
000000014138f84a: call     qword ptr [rax]
000000014138f84c: mov      qword ptr [rbx + 0x28], 0
000000014138f854: lea      rax, [rip + 0x3d1b2d]
000000014138f85b: mov      qword ptr [rbx], rax
000000014138f85e: add      rsp, 0x20
000000014138f862: pop      rbx
000000014138f863: ret      
000000014138f864: lea      rax, [rip + 0x3d1b1d]
000000014138f86b: mov      qword ptr [rcx], rax
000000014138f86e: add      rsp, 0x20
000000014138f872: pop      rbx
000000014138f873: ret      
000000014138f874: int3     
000000014138f875: int3     
000000014138f876: int3     
000000014138f877: int3     
000000014138f878: int3     
000000014138f879: int3     
000000014138f87a: int3     
000000014138f87b: int3     
000000014138f87c: int3     
000000014138f87d: int3     
000000014138f87e: int3     
000000014138f87f: int3     
000000014138f880: mov      qword ptr [rsp + 8], rbx
000000014138f885: push     rdi
000000014138f886: sub      rsp, 0x20
000000014138f88a: test     byte ptr [rcx + 0x38], 2
000000014138f88e: lea      rax, [rip + 0x815373]
000000014138f895: mov      qword ptr [rcx], rax
000000014138f898: mov      edi, edx
000000014138f89a: mov      rbx, rcx
000000014138f89d: je       0x14138f8ba
000000014138f89f: mov      rcx, qword ptr [rcx + 0x28]
000000014138f8a3: test     rcx, rcx
000000014138f8a6: je       0x14138f8ba
000000014138f8a8: mov      rax, qword ptr [rcx]
000000014138f8ab: mov      edx, 1
000000014138f8b0: call     qword ptr [rax]
000000014138f8b2: mov      qword ptr [rbx + 0x28], 0
000000014138f8ba: lea      rax, [rip + 0x3d1ac7]
000000014138f8c1: mov      qword ptr [rbx], rax
000000014138f8c4: test     dil, 1
000000014138f8c8: je       0x14138f8d7
000000014138f8ca: mov      edx, 0x48
000000014138f8cf: mov      rcx, rbx
000000014138f8d2: call     0x141272800
000000014138f8d7: mov      rax, rbx
000000014138f8da: mov      rbx, qword ptr [rsp + 0x30]
000000014138f8df: add      rsp, 0x20
000000014138f8e3: pop      rdi
000000014138f8e4: ret      
000000014138f8e5: int3     
000000014138f8e6: int3     
000000014138f8e7: int3     
000000014138f8e8: int3     
000000014138f8e9: int3     
000000014138f8ea: int3     
000000014138f8eb: int3     
000000014138f8ec: int3     
000000014138f8ed: int3     
000000014138f8ee: int3     
000000014138f8ef: int3     
000000014138f8f0: push     r15
000000014138f8f2: sub      rsp, 0x80
000000014138f8f9: cmp      qword ptr [rcx + 0x28], 0
000000014138f8fe: mov      r15, rcx
000000014138f901: jne      0x14138f90f
000000014138f903: xor      eax, eax
000000014138f905: add      rsp, 0x80
000000014138f90c: pop      r15
000000014138f90e: ret      
000000014138f90f: mov      rcx, qword ptr [rcx + 0x18]
000000014138f913: mov      qword ptr [rsp + 0x98], rbp
000000014138f91b: mov      qword ptr [rsp + 0xa0], rsi
000000014138f923: mov      qword ptr [rsp + 0x70], r12
000000014138f928: xor      r12d, r12d
000000014138f92b: mov      qword ptr [rsp + 0x68], r13
000000014138f930: mov      qword ptr [rsp + 0x60], r14
000000014138f935: test     rcx, rcx
000000014138f938: je       0x14138f945
000000014138f93a: mov      rax, qword ptr [rcx]
000000014138f93d: call     qword ptr [rax + 8]
000000014138f940: mov      r13, rax
000000014138f943: jmp      0x14138f948
000000014138f945: mov      r13, r12
000000014138f948: mov      eax, 0x88888889
000000014138f94d: mov      esi, 1
000000014138f952: mul      dword ptr [rip + 0x804f90]
000000014138f958: mov      eax, dword ptr [r15 + 0x30]
000000014138f95c: movzx    r14d, r12w
000000014138f960: mov      ecx, edx
000000014138f962: xor      edx, edx
000000014138f964: shr      ecx, 4
000000014138f967: div      ecx
000000014138f969: mov      ebp, eax
000000014138f96b: cmp      r12w, word ptr [r13 + 0x40]
000000014138f970: jae      0x14138fb6c
000000014138f976: mov      qword ptr [rsp + 0x78], rdi
000000014138f97b: movaps   xmmword ptr [rsp + 0x50], xmm6
000000014138f980: movss    xmm6, dword ptr [rip + 0x8152f8]
000000014138f988: movaps   xmmword ptr [rsp + 0x40], xmm7
000000014138f98d: movss    xmm7, dword ptr [rip + 0x6917e3]
000000014138f995: movaps   xmmword ptr [rsp + 0x30], xmm8
000000014138f99b: movss    xmm8, dword ptr [rip + 0x3d1e44]
000000014138f9a4: movaps   xmmword ptr [rsp + 0x20], xmm9
000000014138f9aa: movss    xmm9, dword ptr [rip + 0x3d1e39]
000000014138f9b3: mov      qword ptr [rsp + 0x90], rbx
000000014138f9bb: nop      dword ptr [rax + rax]
000000014138f9c0: movzx    eax, r14w
000000014138f9c4: imul     rdi, rax, 0x78
000000014138f9c8: add      rdi, qword ptr [r13 + 0x38]
000000014138f9cc: mov      rcx, qword ptr [rdi + 0x10]
000000014138f9d0: test     rcx, rcx
000000014138f9d3: je       0x14138fa00
000000014138f9d5: mov      ebx, dword ptr [rdi + 8]
000000014138f9d8: mov      eax, ebp
000000014138f9da: movzx    edx, word ptr [rdi]
000000014138f9dd: cmp      ebx, ebp
000000014138f9df: cmovbe   eax, ebx
000000014138f9e2: movss    xmm3, dword ptr [rcx + rax*8 + 4]
000000014138f9e8: movss    xmm2, dword ptr [rcx + rax*8]
000000014138f9ed: mov      rcx, qword ptr [r15 + 0x28]
000000014138f9f1: call     0x14138e300
000000014138f9f6: cmp      ebx, ebp
000000014138f9f8: mov      eax, r12d
000000014138f9fb: cmovbe   eax, esi
000000014138f9fe: mov      esi, eax
000000014138fa00: mov      rcx, qword ptr [rdi + 0x20]
000000014138fa04: test     rcx, rcx
000000014138fa07: je       0x14138fa34
000000014138fa09: mov      ebx, dword ptr [rdi + 0x18]
000000014138fa0c: mov      eax, ebp
000000014138fa0e: movzx    edx, word ptr [rdi]
000000014138fa11: cmp      ebx, ebp
000000014138fa13: cmovbe   eax, ebx
000000014138fa16: movss    xmm3, dword ptr [rcx + rax*8 + 4]
000000014138fa1c: movss    xmm2, dword ptr [rcx + rax*8]
000000014138fa21: mov      rcx, qword ptr [r15 + 0x28]
000000014138fa25: call     0x14138e480
000000014138fa2a: cmp      ebx, ebp
000000014138fa2c: mov      eax, r12d
000000014138fa2f: cmovbe   eax, esi
000000014138fa32: mov      esi, eax
000000014138fa34: mov      rdx, qword ptr [rdi + 0x30]
000000014138fa38: test     rdx, rdx
000000014138fa3b: je       0x14138fa9c
000000014138fa3d: cmp      dword ptr [rdi + 0x28], ebp
000000014138fa40: mov      eax, r12d
000000014138fa43: mov      r8, qword ptr [r15 + 0x28]
000000014138fa47: cmovbe   eax, esi
000000014138fa4a: mov      esi, eax
000000014138fa4c: mov      eax, ebp
000000014138fa4e: cmovbe   eax, dword ptr [rdi + 0x28]
000000014138fa52: movsx    ecx, word ptr [rdx + rax*2]
000000014138fa56: movzx    eax, word ptr [r13 + 0x48]
000000014138fa5b: movzx    edx, word ptr [rdi]
000000014138fa5e: test     al, 4
000000014138fa60: je       0x14138fa6f
000000014138fa62: movd     xmm2, ecx
000000014138fa66: cvtdq2ps xmm2, xmm2
000000014138fa69: mulss    xmm2, xmm6
000000014138fa6d: jmp      0x14138fa94
000000014138fa6f: test     al, 2
000000014138fa71: je       0x14138fa83
000000014138fa73: movzx    eax, cx
000000014138fa76: movd     xmm2, eax
000000014138fa7a: cvtdq2ps xmm2, xmm2
000000014138fa7d: mulss    xmm2, xmm7
000000014138fa81: jmp      0x14138fa94
000000014138fa83: movd     xmm2, ecx
000000014138fa87: cvtdq2ps xmm2, xmm2
000000014138fa8a: mulss    xmm2, xmm8
000000014138fa8f: divss    xmm2, xmm9
000000014138fa94: mov      rcx, r8
000000014138fa97: call     0x14138e3f0
000000014138fa9c: mov      rcx, qword ptr [rdi + 0x40]
000000014138faa0: test     rcx, rcx
000000014138faa3: je       0x14138faca
000000014138faa5: mov      ebx, dword ptr [rdi + 0x38]
000000014138faa8: mov      eax, ebp
000000014138faaa: movzx    edx, word ptr [rdi]
000000014138faad: cmp      ebx, ebp
000000014138faaf: cmovbe   eax, ebx
000000014138fab2: movss    xmm2, dword ptr [rcx + rax*4]
000000014138fab7: mov      rcx, qword ptr [r15 + 0x28]
000000014138fabb: call     0x14138e1e0
000000014138fac0: cmp      ebx, ebp
000000014138fac2: mov      eax, r12d
000000014138fac5: cmovbe   eax, esi
000000014138fac8: mov      esi, eax
000000014138faca: mov      r10, qword ptr [rdi + 0x60]
000000014138face: test     r10, r10
000000014138fad1: je       0x14138fb06
000000014138fad3: mov      r9d, dword ptr [rdi + 0x58]
000000014138fad7: mov      edx, ebp
000000014138fad9: mov      rax, qword ptr [r15 + 0x28]
000000014138fadd: cmp      r9d, ebp
000000014138fae0: movzx    r8d, word ptr [rdi]
000000014138fae4: cmovbe   edx, r9d
000000014138fae8: shl      r8, 6
000000014138faec: cmp      r9d, ebp
000000014138faef: mov      rcx, qword ptr [rax + 0x28]
000000014138faf3: movzx    eax, word ptr [r10 + rdx*2]
000000014138faf8: mov      word ptr [r8 + rcx + 0x34], ax
000000014138fafe: mov      eax, r12d
000000014138fb01: cmovbe   eax, esi
000000014138fb04: mov      esi, eax
000000014138fb06: mov      rcx, qword ptr [rdi + 0x70]
000000014138fb0a: test     rcx, rcx
000000014138fb0d: je       0x14138fb3a
000000014138fb0f: mov      ebx, dword ptr [rdi + 0x68]
000000014138fb12: mov      eax, ebp
000000014138fb14: movzx    edx, word ptr [rdi]
000000014138fb17: cmp      ebx, ebp
000000014138fb19: cmovbe   eax, ebx
000000014138fb1c: movss    xmm3, dword ptr [rcx + rax*8 + 4]
000000014138fb22: movss    xmm2, dword ptr [rcx + rax*8]
000000014138fb27: mov      rcx, qword ptr [r15 + 0x28]
000000014138fb2b: call     0x14138e570
000000014138fb30: cmp      ebx, ebp
000000014138fb32: mov      ecx, r12d
000000014138fb35: cmovbe   ecx, esi
000000014138fb38: mov      esi, ecx
000000014138fb3a: inc      r14w
000000014138fb3e: cmp      r14w, word ptr [r13 + 0x40]
000000014138fb43: jb       0x14138f9c0
000000014138fb49: movaps   xmm9, xmmword ptr [rsp + 0x20]
000000014138fb4f: movaps   xmm8, xmmword ptr [rsp + 0x30]
000000014138fb55: movaps   xmm7, xmmword ptr [rsp + 0x40]
000000014138fb5a: movaps   xmm6, xmmword ptr [rsp + 0x50]
000000014138fb5f: mov      rdi, qword ptr [rsp + 0x78]
000000014138fb64: mov      rbx, qword ptr [rsp + 0x90]
000000014138fb6c: mov      r14, qword ptr [rsp + 0x60]
000000014138fb71: mov      eax, esi
000000014138fb73: mov      rsi, qword ptr [rsp + 0xa0]
000000014138fb7b: mov      r13, qword ptr [rsp + 0x68]
000000014138fb80: mov      r12, qword ptr [rsp + 0x70]
000000014138fb85: mov      rbp, qword ptr [rsp + 0x98]
000000014138fb8d: add      rsp, 0x80
000000014138fb94: pop      r15
000000014138fb96: ret      
000000014138fb97: int3     
000000014138fb98: int3     
000000014138fb99: int3     
000000014138fb9a: int3     
000000014138fb9b: int3     
000000014138fb9c: int3     
000000014138fb9d: int3     
000000014138fb9e: int3     
000000014138fb9f: int3     
000000014138fba0: mov      qword ptr [rsp + 8], rbx
000000014138fba5: push     rdi
000000014138fba6: sub      rsp, 0x20
000000014138fbaa: movzx    eax, word ptr [rcx + 0x38]
000000014138fbae: mov      rdi, rdx
000000014138fbb1: mov      rbx, rcx
000000014138fbb4: test     al, 2
000000014138fbb6: je       0x14138fbee
000000014138fbb8: mov      rcx, qword ptr [rcx + 0x28]
000000014138fbbc: test     rcx, rcx
000000014138fbbf: je       0x14138fbcf
000000014138fbc1: mov      rax, qword ptr [rcx]
000000014138fbc4: mov      edx, 1
000000014138fbc9: call     qword ptr [rax]
000000014138fbcb: movzx    eax, word ptr [rbx + 0x38]
000000014138fbcf: mov      ecx, 0xfffd
000000014138fbd4: mov      qword ptr [rbx + 0x40], rdi
000000014138fbd8: and      ax, cx
000000014138fbdb: mov      qword ptr [rbx + 0x28], rdi
000000014138fbdf: mov      word ptr [rbx + 0x38], ax
000000014138fbe3: mov      rbx, qword ptr [rsp + 0x30]
000000014138fbe8: add      rsp, 0x20
000000014138fbec: pop      rdi
000000014138fbed: ret      
000000014138fbee: mov      rbx, qword ptr [rsp + 0x30]
000000014138fbf3: mov      qword ptr [rcx + 0x40], rdi
000000014138fbf7: mov      qword ptr [rcx + 0x28], rdi
000000014138fbfb: add      rsp, 0x20
000000014138fbff: pop      rdi
000000014138fc00: ret      
000000014138fc01: int3     
000000014138fc02: int3     
000000014138fc03: int3     
000000014138fc04: int3     
000000014138fc05: int3     
000000014138fc06: int3     
000000014138fc07: int3     
000000014138fc08: int3     
000000014138fc09: int3     
000000014138fc0a: int3     
000000014138fc0b: int3     
000000014138fc0c: int3     
000000014138fc0d: int3     
000000014138fc0e: int3     
000000014138fc0f: int3     
000000014138fc10: mov      rcx, qword ptr [rcx + 0x28]
000000014138fc14: test     rcx, rcx
000000014138fc17: je       0x14138fc23
000000014138fc19: mov      edx, 1
000000014138fc1e: jmp      0x14138d480
000000014138fc23: ret      
000000014138fc24: int3     
000000014138fc25: int3     
000000014138fc26: int3     
000000014138fc27: int3     
000000014138fc28: int3     
000000014138fc29: int3     
000000014138fc2a: int3     
000000014138fc2b: int3     
000000014138fc2c: int3     
000000014138fc2d: int3     
000000014138fc2e: int3     
000000014138fc2f: int3     
000000014138fc30: mov      r8d, dword ptr [rcx + 0x34]
000000014138fc34: test     r8d, r8d
000000014138fc37: jle      0x14138fc5c
000000014138fc39: mov      eax, dword ptr [rcx + 0x30]
000000014138fc3c: add      eax, edx
000000014138fc3e: mov      dword ptr [rcx + 0x30], eax
000000014138fc41: test     edx, edx
000000014138fc43: jns      0x14138fc6a
000000014138fc45: test     eax, eax
000000014138fc47: jns      0x14138fc5c
000000014138fc49: test     byte ptr [rcx + 0x38], 1
000000014138fc4d: je       0x14138fc62
000000014138fc4f: neg      eax
000000014138fc51: cdq      
000000014138fc52: idiv     r8d
000000014138fc55: sub      r8d, edx
000000014138fc58: mov      dword ptr [rcx + 0x30], r8d
000000014138fc5c: mov      eax, 0xffffffff
000000014138fc61: ret      
000000014138fc62: mov      dword ptr [rcx + 0x30], 0
000000014138fc69: ret      
000000014138fc6a: cmp      r8d, eax
000000014138fc6d: jge      0x14138fc5c
000000014138fc6f: test     byte ptr [rcx + 0x38], 1
000000014138fc73: je       0x14138fc82
000000014138fc75: cdq      
000000014138fc76: idiv     r8d
000000014138fc79: mov      eax, 0xffffffff
000000014138fc7e: mov      dword ptr [rcx + 0x30], edx
000000014138fc81: ret      
000000014138fc82: sub      eax, r8d
000000014138fc85: mov      dword ptr [rcx + 0x30], r8d
000000014138fc89: ret      
000000014138fc8a: int3     
000000014138fc8b: int3     
000000014138fc8c: int3     
000000014138fc8d: int3     
000000014138fc8e: int3     
000000014138fc8f: int3     
000000014138fc90: movsx    eax, cx
000000014138fc93: movd     xmm0, eax
000000014138fc97: cvtdq2ps xmm0, xmm0
000000014138fc9a: mulss    xmm0, dword ptr [rip + 0x814fde]
000000014138fca2: ret      
000000014138fca3: int3     
000000014138fca4: int3     
000000014138fca5: int3     
000000014138fca6: int3     
000000014138fca7: int3     
000000014138fca8: int3     
000000014138fca9: int3     
000000014138fcaa: int3     
000000014138fcab: int3     
000000014138fcac: int3     
000000014138fcad: int3     
000000014138fcae: int3     
000000014138fcaf: int3     
000000014138fcb0: mov      rcx, qword ptr [rcx + 0x28]
000000014138fcb4: test     rcx, rcx
000000014138fcb7: jne      0x14138d4c0
000000014138fcbd: xor      eax, eax
000000014138fcbf: ret      
000000014138fcc0: push     rbx
000000014138fcc2: sub      rsp, 0x20
000000014138fcc6: mov      rcx, qword ptr [rcx + 0x28]
000000014138fcca: mov      rbx, rdx
000000014138fccd: test     rcx, rcx
000000014138fcd0: je       0x14138fce0
000000014138fcd2: call     0x14138d550
000000014138fcd7: mov      rax, rbx
000000014138fcda: add      rsp, 0x20
000000014138fcde: pop      rbx
000000014138fcdf: ret      
000000014138fce0: call     0x1412a1aa0
000000014138fce5: mov      rdx, rax
000000014138fce8: mov      rcx, rbx
000000014138fceb: call     0x1412a0bc0
000000014138fcf0: mov      rax, rbx
000000014138fcf3: add      rsp, 0x20
000000014138fcf7: pop      rbx
000000014138fcf8: ret      
000000014138fcf9: int3     
000000014138fcfa: int3     
000000014138fcfb: int3     
000000014138fcfc: int3     
000000014138fcfd: int3     
000000014138fcfe: int3     
000000014138fcff: int3     
000000014138fd00: mov      rax, qword ptr [rip + 0x8379811]
000000014138fd07: xor      edx, edx
000000014138fd09: movzx    r8d, byte ptr [rax + 0x952]
000000014138fd11: mov      eax, dword ptr [rip + 0x804bd1]
000000014138fd17: div      r8d
000000014138fd1a: xor      edx, edx
000000014138fd1c: mov      r8d, eax
000000014138fd1f: mov      eax, dword ptr [rcx + 0x34]
000000014138fd22: div      r8d
000000014138fd25: ret      
000000014138fd26: int3     
000000014138fd27: int3     
000000014138fd28: int3     
000000014138fd29: int3     
000000014138fd2a: int3     
000000014138fd2b: int3     
000000014138fd2c: int3     
000000014138fd2d: int3     
000000014138fd2e: int3     
000000014138fd2f: int3     
000000014138fd30: mov      rax, qword ptr [rip + 0x83797e1]
000000014138fd37: xor      edx, edx
000000014138fd39: movzx    r8d, byte ptr [rax + 0x952]
000000014138fd41: mov      eax, dword ptr [rip + 0x804ba1]
000000014138fd47: div      r8d
000000014138fd4a: xor      edx, edx
000000014138fd4c: mov      r8d, eax
000000014138fd4f: mov      eax, dword ptr [rcx + 0x30]
000000014138fd52: div      r8d
000000014138fd55: ret      
000000014138fd56: int3     
000000014138fd57: int3     
000000014138fd58: int3     
000000014138fd59: int3     
000000014138fd5a: int3     
000000014138fd5b: int3     
000000014138fd5c: int3     
000000014138fd5d: int3     
000000014138fd5e: int3     
000000014138fd5f: int3     
000000014138fd60: mov      rcx, qword ptr [rcx + 0x28]
000000014138fd64: test     rcx, rcx
000000014138fd67: jne      0x14138d4b0
000000014138fd6d: movss    xmm0, dword ptr [rip + 0x3d186b]
000000014138fd75: ret      
000000014138fd76: int3     
000000014138fd77: int3     
000000014138fd78: int3     
000000014138fd79: int3     
000000014138fd7a: int3     
000000014138fd7b: int3     
000000014138fd7c: int3     
000000014138fd7d: int3     
000000014138fd7e: int3     
000000014138fd7f: int3     
000000014138fd80: mov      rcx, qword ptr [rcx + 0x28]
000000014138fd84: test     rcx, rcx
000000014138fd87: jne      0x14138d810
000000014138fd8d: xorps    xmm0, xmm0
000000014138fd90: ret      
000000014138fd91: int3     
000000014138fd92: int3     
000000014138fd93: int3     
000000014138fd94: int3     
000000014138fd95: int3     
000000014138fd96: int3     
000000014138fd97: int3     
000000014138fd98: int3     
000000014138fd99: int3     
000000014138fd9a: int3     
000000014138fd9b: int3     
000000014138fd9c: int3     
000000014138fd9d: int3     
000000014138fd9e: int3     
000000014138fd9f: int3     
000000014138fda0: push     rbx
000000014138fda2: sub      rsp, 0x20
000000014138fda6: mov      rbx, rdx
000000014138fda9: mov      rcx, qword ptr [rcx + 0x28]
000000014138fdad: test     rcx, rcx
000000014138fdb0: je       0x14138fdce
000000014138fdb2: call     0x14138dc20
000000014138fdb7: movsd    xmm0, qword ptr [rax]
000000014138fdbb: mov      eax, dword ptr [rax + 8]
000000014138fdbe: movsd    qword ptr [rbx], xmm0
000000014138fdc2: mov      dword ptr [rbx + 8], eax
000000014138fdc5: mov      rax, rbx
000000014138fdc8: add      rsp, 0x20
000000014138fdcc: pop      rbx
000000014138fdcd: ret      
000000014138fdce: mov      rcx, qword ptr gs:[0x58]
000000014138fdd7: mov      eax, dword ptr [rip + 0x83c2e33]
000000014138fddd: mov      edx, 0x3428
000000014138fde2: mov      rcx, qword ptr [rcx + rax*8]
000000014138fde6: mov      eax, dword ptr [rdx + rcx]
000000014138fde9: cmp      dword ptr [rip + 0xdd84dd], eax
000000014138fdef: jg       0x14138fe0f
000000014138fdf1: movsd    xmm0, qword ptr [rip + 0xdd84c7]
000000014138fdf9: mov      eax, dword ptr [rip + 0xdd84c9]
000000014138fdff: movsd    qword ptr [rbx], xmm0
000000014138fe03: mov      dword ptr [rbx + 8], eax
000000014138fe06: mov      rax, rbx
000000014138fe09: add      rsp, 0x20
000000014138fe0d: pop      rbx
000000014138fe0e: ret      
000000014138fe0f: lea      rcx, [rip + 0xdd84b6]
000000014138fe16: call     0x141441c00
000000014138fe1b: cmp      dword ptr [rip + 0xdd84aa], -1
000000014138fe22: jne      0x14138fdf1
000000014138fe24: xorps    xmm3, xmm3
000000014138fe27: xorps    xmm2, xmm2
000000014138fe2a: xorps    xmm1, xmm1
000000014138fe2d: lea      rcx, [rip + 0xdd848c]
000000014138fe34: call     0x1411ab440
000000014138fe39: lea      rcx, [rip + 0x39a290]
000000014138fe40: call     0x1414419a8
000000014138fe45: nop      
000000014138fe46: lea      rcx, [rip + 0xdd847f]
000000014138fe4d: call     0x141441ba0
000000014138fe52: jmp      0x14138fdf1
000000014138fe54: int3     
000000014138fe55: int3     
000000014138fe56: int3     
000000014138fe57: int3     
000000014138fe58: int3     
000000014138fe59: int3     
000000014138fe5a: int3     
000000014138fe5b: int3     
000000014138fe5c: int3     
000000014138fe5d: int3     
000000014138fe5e: int3     
000000014138fe5f: int3     
000000014138fe60: mov      rcx, qword ptr [rcx + 0x28]
000000014138fe64: test     rcx, rcx
000000014138fe67: jne      0x14138dc60
000000014138fe6d: xorps    xmm0, xmm0
000000014138fe70: ret      
000000014138fe71: int3     
000000014138fe72: int3     
000000014138fe73: int3     
000000014138fe74: int3     
000000014138fe75: int3     
000000014138fe76: int3     
000000014138fe77: int3     
000000014138fe78: int3     
000000014138fe79: int3     
000000014138fe7a: int3     
000000014138fe7b: int3     
000000014138fe7c: int3     
000000014138fe7d: int3     
000000014138fe7e: int3     
000000014138fe7f: int3     
000000014138fe80: push     rbx
000000014138fe82: sub      rsp, 0x20
000000014138fe86: mov      rcx, qword ptr [rcx + 0x28]
000000014138fe8a: mov      rbx, rdx
000000014138fe8d: test     rcx, rcx
000000014138fe90: je       0x14138fe99
000000014138fe92: call     0x14138dc80
000000014138fe97: jmp      0x14138fe9e
000000014138fe99: call     0x1412a1aa0
000000014138fe9e: mov      rdx, rax
000000014138fea1: mov      rcx, rbx
000000014138fea4: call     0x1412a0bc0
000000014138fea9: mov      rax, rbx
000000014138feac: add      rsp, 0x20
000000014138feb0: pop      rbx
000000014138feb1: ret      
000000014138feb2: int3     
000000014138feb3: int3     
000000014138feb4: int3     
000000014138feb5: int3     
000000014138feb6: int3     
000000014138feb7: int3     
000000014138feb8: int3     
000000014138feb9: int3     
000000014138feba: int3     
000000014138febb: int3     
000000014138febc: int3     
000000014138febd: int3     
000000014138febe: int3     
000000014138febf: int3     
000000014138fec0: mov      rcx, qword ptr [rcx + 0x28]
000000014138fec4: test     rcx, rcx
000000014138fec7: jne      0x14138ddd0
000000014138fecd: ret      
000000014138fece: int3     
000000014138fecf: int3     
000000014138fed0: mov      qword ptr [rsp + 8], rbx
000000014138fed5: push     rdi
000000014138fed6: sub      rsp, 0x20
000000014138feda: mov      rdi, rcx
000000014138fedd: mov      rbx, rdx
000000014138fee0: mov      rcx, rdx
000000014138fee3: call     0x1412a2400
000000014138fee8: lea      rcx, [rip + 0xd2fa99]
000000014138feef: cmp      rax, rcx
000000014138fef2: jne      0x14138feff
000000014138fef4: mov      rdx, rbx
000000014138fef7: mov      rcx, rdi
000000014138fefa: call     0x14138ff10
000000014138feff: mov      rbx, qword ptr [rsp + 0x30]
000000014138ff04: add      rsp, 0x20
000000014138ff08: pop      rdi
000000014138ff09: ret      
000000014138ff0a: int3     
000000014138ff0b: int3     
000000014138ff0c: int3     
000000014138ff0d: int3     
000000014138ff0e: int3     
000000014138ff0f: int3     
000000014138ff10: mov      qword ptr [rsp + 0x10], rbx
000000014138ff15: mov      qword ptr [rsp + 0x18], rbp
000000014138ff1a: push     rsi
000000014138ff1b: sub      rsp, 0x20
000000014138ff1f: mov      rsi, rdx
000000014138ff22: mov      rbx, rcx
000000014138ff25: mov      rax, qword ptr [rdx + 8]
000000014138ff29: cmp      qword ptr [rcx + 0x18], rax
000000014138ff2d: jne      0x14138ff46
000000014138ff2f: mov      dword ptr [rcx + 0x30], 0
000000014138ff36: mov      rbx, qword ptr [rsp + 0x38]
000000014138ff3b: mov      rbp, qword ptr [rsp + 0x40]
000000014138ff40: add      rsp, 0x20
000000014138ff44: pop      rsi
000000014138ff45: ret      
000000014138ff46: movzx    eax, word ptr [rcx + 0x38]
000000014138ff4a: test     al, 2
000000014138ff4c: je       0x14138ff79
000000014138ff4e: mov      rcx, qword ptr [rcx + 0x28]
000000014138ff52: test     rcx, rcx
000000014138ff55: je       0x14138ff6d
000000014138ff57: mov      rax, qword ptr [rcx]
000000014138ff5a: mov      edx, 1
000000014138ff5f: call     qword ptr [rax]
000000014138ff61: movzx    eax, word ptr [rbx + 0x38]
000000014138ff65: mov      qword ptr [rbx + 0x28], 0
000000014138ff6d: mov      ecx, 0xfffd
000000014138ff72: and      ax, cx
000000014138ff75: mov      word ptr [rbx + 0x38], ax
000000014138ff79: mov      rax, qword ptr [rsi + 8]
000000014138ff7d: mov      qword ptr [rbx + 0x18], rax
000000014138ff81: mov      rax, qword ptr [rbx + 0x40]
000000014138ff85: test     rax, rax
000000014138ff88: je       0x14138ff90
000000014138ff8a: mov      qword ptr [rbx + 0x28], rax
000000014138ff8e: jmp      0x14138ffdd
000000014138ff90: mov      rcx, rsi
000000014138ff93: call     0x141341280
000000014138ff98: mov      rbp, rax
000000014138ff9b: test     rax, rax
000000014138ff9e: je       0x14138ffdd
000000014138ffa0: mov      r8d, 0x71
000000014138ffa6: lea      rdx, [rip + 0x814c83]
000000014138ffad: lea      ecx, [r8 + 0xf]
000000014138ffb1: call     0x141272600
000000014138ffb6: mov      qword ptr [rsp + 0x30], rax
000000014138ffbb: test     rax, rax
000000014138ffbe: je       0x14138ffc9
000000014138ffc0: mov      rcx, rax
000000014138ffc3: call     0x14138d110
000000014138ffc8: nop      
000000014138ffc9: mov      qword ptr [rbx + 0x28], rax
000000014138ffcd: mov      rdx, rbp
000000014138ffd0: mov      rcx, rax
000000014138ffd3: call     0x14138de80
000000014138ffd8: or       word ptr [rbx + 0x38], 2
000000014138ffdd: mov      dword ptr [rbx + 0x30], 0
000000014138ffe4: mov      eax, dword ptr [rsi + 0x4c]
000000014138ffe7: mov      dword ptr [rbx + 0x34], eax
000000014138ffea: mov      rbx, qword ptr [rsp + 0x38]
000000014138ffef: mov      rbp, qword ptr [rsp + 0x40]
000000014138fff4: add      rsp, 0x20
000000014138fff8: pop      rsi
000000014138fff9: ret      
000000014138fffa: int3     
000000014138fffb: int3     
000000014138fffc: int3     
000000014138fffd: int3     
000000014138fffe: int3     
000000014138ffff: int3     
0000000141390000: mov      rax, qword ptr [rip + 0x8379511]
0000000141390007: mov      r9d, edx
000000014139000a: xor      edx, edx
000000014139000c: movzx    r8d, byte ptr [rax + 0x952]
0000000141390014: mov      eax, dword ptr [rip + 0x8048ce]
000000014139001a: div      r8d
000000014139001d: imul     eax, r9d
0000000141390021: mov      dword ptr [rcx + 0x30], eax
0000000141390024: ret      
0000000141390025: int3     
0000000141390026: int3     
0000000141390027: int3     
0000000141390028: int3     
0000000141390029: int3     
000000014139002a: int3     
000000014139002b: int3     
000000014139002c: int3     
000000014139002d: int3     
000000014139002e: int3     
000000014139002f: int3     
0000000141390030: mov      rcx, qword ptr [rcx + 0x28]
0000000141390034: test     rcx, rcx
0000000141390037: jne      0x14138ddc0
000000014139003d: ret      
000000014139003e: int3     
000000014139003f: int3     
0000000141390040: mov      rcx, qword ptr [rcx + 0x28]
0000000141390044: test     rcx, rcx
0000000141390047: jne      0x14138e1e0
000000014139004d: ret      
000000014139004e: int3     
000000014139004f: int3     
0000000141390050: mov      rcx, qword ptr [rcx + 0x28]
0000000141390054: test     rcx, rcx
0000000141390057: jne      0x14138e5e0
000000014139005d: ret      
000000014139005e: int3     
000000014139005f: int3     
0000000141390060: mov      rcx, qword ptr [rcx + 0x28]
0000000141390064: test     rcx, rcx
0000000141390067: jne      0x14138e620
000000014139006d: ret      
000000014139006e: int3     
000000014139006f: int3     
0000000141390070: mov      rcx, qword ptr [rcx + 0x28]
0000000141390074: test     rcx, rcx
0000000141390077: jne      0x14138e660
000000014139007d: ret      
000000014139007e: int3     
000000014139007f: int3     
0000000141390080: push     rbx
0000000141390082: sub      rsp, 0x20
0000000141390086: mov      rbx, rcx
0000000141390089: mov      r8d, 0x1f
000000014139008f: lea      rdx, [rip + 0x814bfa]
0000000141390096: lea      ecx, [r8 + 1]
000000014139009a: call     0x141272600
000000014139009f: mov      qword ptr [rsp + 0x38], rax
00000001413900a4: test     rax, rax
00000001413900a7: je       0x1413900bb
00000001413900a9: mov      rdx, rbx
00000001413900ac: mov      rcx, rax
00000001413900af: call     0x14139c840
00000001413900b4: nop      
00000001413900b5: add      rsp, 0x20
00000001413900b9: pop      rbx
00000001413900ba: ret      
00000001413900bb: xor      eax, eax
00000001413900bd: add      rsp, 0x20
00000001413900c1: pop      rbx
00000001413900c2: ret      
00000001413900c3: int3     
00000001413900c4: int3     
00000001413900c5: int3     
00000001413900c6: int3     
00000001413900c7: int3     
00000001413900c8: int3     
00000001413900c9: int3     
00000001413900ca: int3     
00000001413900cb: int3     
00000001413900cc: int3     
00000001413900cd: int3     
00000001413900ce: int3     
00000001413900cf: int3     
00000001413900d0: mov      qword ptr [rsp + 8], rbx
00000001413900d5: mov      qword ptr [rsp + 0x10], rsi
00000001413900da: push     rdi
00000001413900db: sub      rsp, 0x20
00000001413900df: mov      rdi, rdx
00000001413900e2: mov      rsi, rcx
00000001413900e5: mov      r8d, 0x29
00000001413900eb: lea      rdx, [rip + 0x814b9e]
00000001413900f2: lea      ecx, [r8 + 0x77]
00000001413900f6: call     0x141272600
00000001413900fb: mov      rbx, rax
00000001413900fe: mov      qword ptr [rsp + 0x40], rax
0000000141390103: test     rax, rax
0000000141390106: je       0x141390131
0000000141390108: mov      rcx, qword ptr [rsi + 8]
000000014139010c: mov      rdx, qword ptr [rcx]
000000014139010f: call     qword ptr [rdx + 8]
0000000141390112: mov      rdx, rax
0000000141390115: mov      r8, rdi
0000000141390118: mov      rcx, rbx
000000014139011b: call     0x1412a1be0
0000000141390120: nop      
0000000141390121: mov      rbx, qword ptr [rsp + 0x30]
0000000141390126: mov      rsi, qword ptr [rsp + 0x38]
000000014139012b: add      rsp, 0x20
000000014139012f: pop      rdi
0000000141390130: ret      
0000000141390131: xor      eax, eax
0000000141390133: mov      rbx, qword ptr [rsp + 0x30]
0000000141390138: mov      rsi, qword ptr [rsp + 0x38]
000000014139013d: add      rsp, 0x20
0000000141390141: pop      rdi
0000000141390142: ret      
0000000141390143: int3     
0000000141390144: int3     
0000000141390145: int3     
0000000141390146: int3     
0000000141390147: int3     
0000000141390148: int3     
0000000141390149: int3     
000000014139014a: int3     
000000014139014b: int3     
000000014139014c: int3     
000000014139014d: int3     
000000014139014e: int3     
000000014139014f: int3     
0000000141390150: mov      qword ptr [rsp + 0x10], rbx
0000000141390155: mov      qword ptr [rsp + 8], rcx
000000014139015a: push     rdi
000000014139015b: sub      rsp, 0x20
000000014139015f: mov      rbx, rdx
0000000141390162: mov      rdi, rcx
0000000141390165: lea      rax, [rip + 0x814b8c]
000000014139016c: mov      qword ptr [rcx], rax
000000014139016f: xor      r8d, r8d
0000000141390172: lea      rdx, [rcx + 0x18]
0000000141390176: mov      rcx, rbx
0000000141390179: call     0x141391760
000000014139017e: mov      r8d, 1
0000000141390184: lea      rdx, [rdi + 0x30]
0000000141390188: mov      rcx, rbx
000000014139018b: call     0x141391760
0000000141390190: mov      r8d, 2
0000000141390196: lea      rdx, [rdi + 0x48]
000000014139019a: mov      rcx, rbx
000000014139019d: call     0x141391760
00000001413901a2: nop      
00000001413901a3: mov      rax, rdi
00000001413901a6: mov      rbx, qword ptr [rsp + 0x38]
00000001413901ab: add      rsp, 0x20
00000001413901af: pop      rdi
00000001413901b0: ret      
00000001413901b1: int3     
00000001413901b2: int3     
00000001413901b3: int3     
00000001413901b4: int3     
00000001413901b5: int3     
00000001413901b6: int3     
00000001413901b7: int3     
00000001413901b8: int3     
00000001413901b9: int3     
00000001413901ba: int3     
00000001413901bb: int3     
00000001413901bc: int3     
00000001413901bd: int3     
00000001413901be: int3     
00000001413901bf: int3     
00000001413901c0: push     rbx
00000001413901c2: sub      rsp, 0x20
00000001413901c6: lea      rax, [rip + 0x8079ab]
00000001413901cd: mov      rbx, rcx
00000001413901d0: mov      qword ptr [rcx], rax
00000001413901d3: test     dl, 1
00000001413901d6: je       0x1413901e2
00000001413901d8: mov      edx, 0x60
00000001413901dd: call     0x141272800
00000001413901e2: mov      rax, rbx
00000001413901e5: add      rsp, 0x20
00000001413901e9: pop      rbx
00000001413901ea: ret      
00000001413901eb: int3     
00000001413901ec: int3     
00000001413901ed: int3     
00000001413901ee: int3     
00000001413901ef: int3     
00000001413901f0: push     rbx
00000001413901f2: sub      rsp, 0x20
00000001413901f6: mov      rbx, rcx
00000001413901f9: mov      r8d, 0x26
00000001413901ff: lea      rdx, [rip + 0x814b0a]
0000000141390206: lea      ecx, [r8 - 6]
000000014139020a: call     0x141272600
000000014139020f: mov      qword ptr [rsp + 0x38], rax
0000000141390214: test     rax, rax
0000000141390217: je       0x14139022b
0000000141390219: mov      rdx, rbx
000000014139021c: mov      rcx, rax
000000014139021f: call     0x14139cb20
0000000141390224: nop      
0000000141390225: add      rsp, 0x20
0000000141390229: pop      rbx
000000014139022a: ret      
000000014139022b: xor      eax, eax
000000014139022d: add      rsp, 0x20
0000000141390231: pop      rbx
0000000141390232: ret      
0000000141390233: int3     
0000000141390234: int3     
0000000141390235: int3     
0000000141390236: int3     
0000000141390237: int3     
0000000141390238: int3     
0000000141390239: int3     
000000014139023a: int3     
000000014139023b: int3     
000000014139023c: int3     
000000014139023d: int3     
000000014139023e: int3     
000000014139023f: int3     
0000000141390240: mov      qword ptr [rsp + 0x10], rbx
0000000141390245: mov      qword ptr [rsp + 8], rcx
000000014139024a: push     rdi
000000014139024b: sub      rsp, 0x20
000000014139024f: mov      rbx, rdx
0000000141390252: mov      rdi, rcx
0000000141390255: lea      rax, [rip + 0x814b1c]
000000014139025c: mov      qword ptr [rcx], rax
000000014139025f: xor      r8d, r8d
0000000141390262: lea      rdx, [rcx + 0x18]
0000000141390266: mov      rcx, rbx
0000000141390269: call     0x141391760
000000014139026e: mov      r8d, 1
0000000141390274: lea      rdx, [rdi + 0x30]
0000000141390278: mov      rcx, rbx
000000014139027b: call     0x141391760
0000000141390280: mov      r8d, 2
0000000141390286: lea      rdx, [rdi + 0x48]
000000014139028a: mov      rcx, rbx
000000014139028d: call     0x141391760
0000000141390292: mov      r8d, 3
0000000141390298: lea      rdx, [rdi + 0x60]
000000014139029c: mov      rcx, rbx
000000014139029f: call     0x141391760
00000001413902a4: mov      r8d, 4
00000001413902aa: lea      rdx, [rdi + 0x78]
00000001413902ae: mov      rcx, rbx
00000001413902b1: call     0x141391760
00000001413902b6: nop      
00000001413902b7: mov      rax, rdi
00000001413902ba: mov      rbx, qword ptr [rsp + 0x38]
00000001413902bf: add      rsp, 0x20
00000001413902c3: pop      rdi
00000001413902c4: ret      
00000001413902c5: int3     
00000001413902c6: int3     
00000001413902c7: int3     
00000001413902c8: int3     
00000001413902c9: int3     
00000001413902ca: int3     
00000001413902cb: int3     
00000001413902cc: int3     
00000001413902cd: int3     
00000001413902ce: int3     
00000001413902cf: int3     
00000001413902d0: push     rbx
00000001413902d2: sub      rsp, 0x20
00000001413902d6: lea      rax, [rip + 0x80789b]
00000001413902dd: mov      rbx, rcx
00000001413902e0: mov      qword ptr [rcx], rax
00000001413902e3: test     dl, 1
00000001413902e6: je       0x1413902f2
00000001413902e8: mov      edx, 0x90
00000001413902ed: call     0x141272800
00000001413902f2: mov      rax, rbx
00000001413902f5: add      rsp, 0x20
00000001413902f9: pop      rbx
00000001413902fa: ret      
00000001413902fb: int3     
00000001413902fc: int3     
00000001413902fd: int3     
00000001413902fe: int3     
00000001413902ff: int3     
0000000141390300: push     rbx
0000000141390302: sub      rsp, 0x20
0000000141390306: mov      rbx, rcx
0000000141390309: mov      r8d, 0x25
000000014139030f: lea      rdx, [rip + 0x814a7a]
0000000141390316: lea      ecx, [r8 + 0xb]
000000014139031a: call     0x141272600
000000014139031f: mov      qword ptr [rsp + 0x38], rax
0000000141390324: test     rax, rax
0000000141390327: je       0x14139033b
0000000141390329: mov      rdx, rbx
000000014139032c: mov      rcx, rax
000000014139032f: call     0x14139cdc0
0000000141390334: nop      
0000000141390335: add      rsp, 0x20
0000000141390339: pop      rbx
000000014139033a: ret      
000000014139033b: xor      eax, eax
000000014139033d: add      rsp, 0x20
0000000141390341: pop      rbx
0000000141390342: ret      
0000000141390343: int3     
0000000141390344: int3     
0000000141390345: int3     
0000000141390346: int3     
0000000141390347: int3     
0000000141390348: int3     
0000000141390349: int3     
000000014139034a: int3     
000000014139034b: int3     
000000014139034c: int3     
000000014139034d: int3     
000000014139034e: int3     
000000014139034f: int3     
0000000141390350: mov      qword ptr [rsp + 0x10], rbx
0000000141390355: mov      qword ptr [rsp + 8], rcx
000000014139035a: push     rdi
000000014139035b: sub      rsp, 0x20
000000014139035f: mov      rbx, rdx
0000000141390362: mov      rdi, rcx
0000000141390365: lea      rax, [rip + 0x814a8c]
000000014139036c: mov      qword ptr [rcx], rax
000000014139036f: xor      r8d, r8d
0000000141390372: lea      rdx, [rcx + 0x18]
0000000141390376: mov      rcx, rbx
0000000141390379: call     0x141391760
000000014139037e: mov      r8d, 1
0000000141390384: lea      rdx, [rdi + 0x30]
0000000141390388: mov      rcx, rbx
000000014139038b: call     0x141391760
0000000141390390: nop      
0000000141390391: mov      rax, rdi
0000000141390394: mov      rbx, qword ptr [rsp + 0x38]
0000000141390399: add      rsp, 0x20
000000014139039d: pop      rdi
000000014139039e: ret      
000000014139039f: int3     
00000001413903a0: push     rbx
00000001413903a2: sub      rsp, 0x20
00000001413903a6: lea      rax, [rip + 0x8077cb]
00000001413903ad: mov      rbx, rcx
00000001413903b0: mov      qword ptr [rcx], rax
00000001413903b3: test     dl, 1
00000001413903b6: je       0x1413903c2
00000001413903b8: mov      edx, 0x48
00000001413903bd: call     0x141272800
00000001413903c2: mov      rax, rbx
00000001413903c5: add      rsp, 0x20
00000001413903c9: pop      rbx
00000001413903ca: ret      
00000001413903cb: int3     
00000001413903cc: int3     
00000001413903cd: int3     
00000001413903ce: int3     
00000001413903cf: int3     
00000001413903d0: push     rbx
00000001413903d2: sub      rsp, 0x20
00000001413903d6: mov      rbx, rcx
00000001413903d9: mov      r8d, 0x26
00000001413903df: lea      rdx, [rip + 0x814a2a]
00000001413903e6: lea      ecx, [r8 - 0xe]
00000001413903ea: call     0x141272600
00000001413903ef: mov      qword ptr [rsp + 0x38], rax
00000001413903f4: test     rax, rax
00000001413903f7: je       0x14139040b
00000001413903f9: mov      rdx, rbx
00000001413903fc: mov      rcx, rax
00000001413903ff: call     0x14139d0f0
0000000141390404: nop      
0000000141390405: add      rsp, 0x20
0000000141390409: pop      rbx
000000014139040a: ret      
000000014139040b: xor      eax, eax
000000014139040d: add      rsp, 0x20
0000000141390411: pop      rbx
0000000141390412: ret      
0000000141390413: int3     
0000000141390414: int3     
0000000141390415: int3     
0000000141390416: int3     
0000000141390417: int3     
0000000141390418: int3     
0000000141390419: int3     
000000014139041a: int3     
000000014139041b: int3     
000000014139041c: int3     
000000014139041d: int3     
000000014139041e: int3     
000000014139041f: int3     
0000000141390420: sub      rsp, 8
0000000141390424: mov      r10, rdx
0000000141390427: xor      eax, eax
0000000141390429: sub      rdx, rcx
000000014139042c: mov      r9, rcx
000000014139042f: add      rdx, 7
0000000141390433: shr      rdx, 3
0000000141390437: cmp      rcx, r10
000000014139043a: cmova    rdx, rax
000000014139043e: test     rdx, rdx
0000000141390441: je       0x141390482
0000000141390443: cmp      rdx, 2
0000000141390447: jb       0x141390482
0000000141390449: mov      rax, qword ptr [r8]
000000014139044c: add      rcx, -8
0000000141390450: lea      rcx, [rcx + rdx*8]
0000000141390454: cmp      r9, r8
0000000141390457: ja       0x14139045e
0000000141390459: cmp      rcx, r8
000000014139045c: jae      0x141390482
000000014139045e: mov      qword ptr [rsp], rdi
0000000141390462: and      rdx, 0xfffffffffffffffe
0000000141390466: mov      rdi, r9
0000000141390469: lea      rdx, [rdx*8]
0000000141390471: mov      rcx, rdx
0000000141390474: shr      rcx, 3
0000000141390478: rep stosq qword ptr [rdi], rax
000000014139047b: add      r9, rdx
000000014139047e: mov      rdi, qword ptr [rsp]
0000000141390482: cmp      r9, r10
0000000141390485: je       0x14139049f
0000000141390487: nop      word ptr [rax + rax]
0000000141390490: mov      rax, qword ptr [r8]
0000000141390493: mov      qword ptr [r9], rax
0000000141390496: add      r9, 8
000000014139049a: cmp      r9, r10
000000014139049d: jne      0x141390490
000000014139049f: add      rsp, 8
00000001413904a3: ret      
00000001413904a4: int3     
00000001413904a5: int3     
00000001413904a6: int3     
00000001413904a7: int3     
00000001413904a8: int3     
00000001413904a9: int3     
00000001413904aa: int3     
00000001413904ab: int3     
00000001413904ac: int3     
00000001413904ad: int3     
00000001413904ae: int3     
00000001413904af: int3     
00000001413904b0: cmp      rcx, rdx
00000001413904b3: je       0x1413904cf
00000001413904b5: nop      word ptr [rax + rax]
00000001413904c0: mov      rax, qword ptr [r8]
00000001413904c3: mov      qword ptr [rcx], rax
00000001413904c6: add      rcx, 8
00000001413904ca: cmp      rcx, rdx
00000001413904cd: jne      0x1413904c0
00000001413904cf: ret      
00000001413904d0: mov      r11, rsp
00000001413904d3: mov      qword ptr [r11 + 0x10], rbx
00000001413904d7: mov      qword ptr [r11 + 8], rcx
00000001413904db: push     rbp
00000001413904dc: push     rsi
00000001413904dd: push     rdi
00000001413904de: push     r12
00000001413904e0: push     r13
00000001413904e2: push     r14
00000001413904e4: push     r15
00000001413904e6: sub      rsp, 0x50
00000001413904ea: mov      r15d, r8d
00000001413904ed: mov      rbp, rdx
00000001413904f0: mov      r14, rcx
00000001413904f3: lea      rax, [rip + 0x8149de]
00000001413904fa: mov      qword ptr [rcx], rax
00000001413904fd: lea      rsi, [rcx + 0x300]
0000000141390504: mov      qword ptr [r11 + 0x20], rsi
0000000141390508: lea      rcx, [r11 - 0x50]
000000014139050c: call     0x141273620
0000000141390511: lea      rax, [rip + 0x814960]
0000000141390518: mov      qword ptr [rsp + 0x38], rax
000000014139051d: xor      r12d, r12d
0000000141390520: mov      dword ptr [rsi], r12d
0000000141390523: lea      rdi, [rsi + 8]
0000000141390527: mov      qword ptr [rsp + 0x30], rdi
000000014139052c: lea      rcx, [rsp + 0x38]
0000000141390531: call     0x141273770
0000000141390536: mov      edx, eax
0000000141390538: mov      rcx, rdi
000000014139053b: call     0x1412735d0
0000000141390540: lea      rax, [rip + 0x814951]
0000000141390547: mov      qword ptr [rdi], rax
000000014139054a: mov      qword ptr [rdi + 0x18], r12
000000014139054e: mov      qword ptr [rdi + 0x20], r12
0000000141390552: mov      rcx, rdi
0000000141390555: call     0x141273770
000000014139055a: mov      ecx, eax
000000014139055c: call     0x141273960
0000000141390561: mov      dword ptr [rsp + 0x20], 0x63
0000000141390569: lea      r9, [rip + 0x3d0d20]
0000000141390570: mov      r8, qword ptr [rdi + 8]
0000000141390574: lea      edx, [r12 + 0x70]
0000000141390579: lea      ecx, [rdx - 0x68]
000000014139057c: call     0x1412734b0
0000000141390581: mov      rbx, rax
0000000141390584: call     0x141273900
0000000141390589: mov      qword ptr [rbx], rbx
000000014139058c: mov      qword ptr [rbx + 8], rbx
0000000141390590: mov      qword ptr [rdi + 0x18], rbx
0000000141390594: lea      rcx, [rsp + 0x38]
0000000141390599: call     0x141273770
000000014139059e: mov      edx, eax
00000001413905a0: lea      rcx, [rsi + 0x30]
00000001413905a4: call     0x1412735d0
00000001413905a9: lea      rax, [rip + 0x814908]
00000001413905b0: mov      qword ptr [rsi + 0x30], rax
00000001413905b4: mov      qword ptr [rsi + 0x48], r12
00000001413905b8: mov      qword ptr [rsi + 0x50], r12
00000001413905bc: mov      qword ptr [rsi + 0x58], r12
00000001413905c0: mov      qword ptr [rsi + 0x60], 7
00000001413905c8: mov      qword ptr [rsi + 0x68], 8
00000001413905d0: mov      dword ptr [rsi], 0x3f800000
00000001413905d6: mov      r8, qword ptr [rsi + 0x20]
00000001413905da: lea      edx, [r12 + 0x10]
00000001413905df: lea      rcx, [rsi + 0x30]
00000001413905e3: call     0x1413910a0
00000001413905e8: nop      
00000001413905e9: lea      rax, [rip + 0x3d0d98]
00000001413905f0: mov      qword ptr [rsp + 0x38], rax
00000001413905f5: xor      r8d, r8d
00000001413905f8: lea      rdx, [r14 + 0xd0]
00000001413905ff: mov      rcx, rbp
0000000141390602: call     0x141391760
0000000141390607: mov      ebx, 1
000000014139060c: mov      r8d, ebx
000000014139060f: lea      rdx, [r14 + 0xe8]
0000000141390616: mov      rcx, rbp
0000000141390619: call     0x141391760
000000014139061e: lea      r8d, [r12 + 2]
0000000141390623: lea      rdx, [r14 + 0x100]
000000014139062a: mov      rcx, rbp
000000014139062d: call     0x141391760
0000000141390632: lea      r8d, [r12 + 3]
0000000141390637: lea      rdx, [r14 + 0x118]
000000014139063e: mov      rcx, rbp
0000000141390641: call     0x141391760
0000000141390646: lea      rdx, [r14 + 0x130]
000000014139064d: lea      r8d, [r12 + 4]
0000000141390652: mov      rcx, rbp
0000000141390655: call     0x141391760
000000014139065a: lea      rdx, [r14 + 0x148]
0000000141390661: lea      r8d, [r12 + 5]
0000000141390666: mov      rcx, rbp
0000000141390669: call     0x141391760
000000014139066e: lea      rdx, [r14 + 0x160]
0000000141390675: lea      r8d, [r12 + 6]
000000014139067a: mov      rcx, rbp
000000014139067d: call     0x141391760
0000000141390682: lea      rdx, [r14 + 0x178]
0000000141390689: lea      r8d, [r12 + 7]
000000014139068e: mov      rcx, rbp
0000000141390691: call     0x141391760
0000000141390696: lea      rdx, [r14 + 0x190]
000000014139069d: lea      r8d, [r12 + 8]
00000001413906a2: mov      rcx, rbp
00000001413906a5: call     0x141391760
00000001413906aa: lea      rdx, [r14 + 0x1a8]
00000001413906b1: lea      r8d, [r12 + 9]
00000001413906b6: mov      rcx, rbp
00000001413906b9: call     0x141391760
00000001413906be: lea      rdx, [r14 + 0x1c0]
00000001413906c5: lea      r8d, [r12 + 0xa]
00000001413906ca: mov      rcx, rbp
00000001413906cd: call     0x141391760
00000001413906d2: lea      rdx, [r14 + 0x1d8]
00000001413906d9: lea      r8d, [r12 + 0xb]
00000001413906de: mov      rcx, rbp
00000001413906e1: call     0x141391760
00000001413906e6: lea      r8d, [r12 + 0xc]
00000001413906eb: lea      rdx, [r14 + 0x1f0]
00000001413906f2: mov      rcx, rbp
00000001413906f5: call     0x141391760
00000001413906fa: lea      r8d, [r12 + 0xd]
00000001413906ff: lea      rdx, [r14 + 0x208]
0000000141390706: mov      rcx, rbp
0000000141390709: call     0x141391760
000000014139070e: lea      r8d, [r12 + 0xe]
0000000141390713: lea      rdx, [r14 + 0x220]
000000014139071a: mov      rcx, rbp
000000014139071d: call     0x141391760
0000000141390722: lea      r8d, [r12 + 0xf]
0000000141390727: lea      rdx, [r14 + 0x238]
000000014139072e: mov      rcx, rbp
0000000141390731: call     0x141391760
0000000141390736: lea      r8d, [r12 + 0x10]
000000014139073b: lea      rdx, [r14 + 0x250]
0000000141390742: mov      rcx, rbp
0000000141390745: call     0x141391760
000000014139074a: lea      r8d, [r12 + 0x11]
000000014139074f: lea      rdx, [r14 + 0x268]
0000000141390756: mov      rcx, rbp
0000000141390759: call     0x141391760
000000014139075e: lea      rdx, [r14 + 0x280]
0000000141390765: lea      r8d, [r12 + 0x12]
000000014139076a: mov      rcx, rbp
000000014139076d: call     0x141391760
0000000141390772: lea      rdx, [r14 + 0x298]
0000000141390779: lea      r8d, [r12 + 0x13]
000000014139077e: mov      rcx, rbp
0000000141390781: call     0x141391760
0000000141390786: lea      rdx, [r14 + 0x2b0]
000000014139078d: lea      r8d, [r12 + 0x14]
0000000141390792: mov      rcx, rbp
0000000141390795: call     0x141391760
000000014139079a: lea      rdx, [r14 + 0x2c8]
00000001413907a1: lea      r8d, [r12 + 0x15]
00000001413907a6: mov      rcx, rbp
00000001413907a9: call     0x141391760
00000001413907ae: lea      r8d, [r12 + 0x16]
00000001413907b3: lea      rdx, [r14 + 0x2e0]
00000001413907ba: mov      rcx, rbp
00000001413907bd: call     0x141391760
00000001413907c2: mov      rax, qword ptr [rip + 0x8378d4f]
00000001413907c9: cmp      byte ptr [rax + 0x952], 0x3c
00000001413907d0: jne      0x1413907d7
00000001413907d2: test     r15d, r15d
00000001413907d5: je       0x1413907d9
00000001413907d7: xor      ebx, ebx
00000001413907d9: mov      edx, ebx
00000001413907db: lea      rcx, [r14 + 0xd0]
00000001413907e2: call     0x141367040
00000001413907e7: mov      qword ptr [r14 + 0x18], rax
00000001413907eb: mov      edx, ebx
00000001413907ed: lea      rcx, [r14 + 0xe8]
00000001413907f4: call     0x141367040
00000001413907f9: mov      qword ptr [r14 + 0x20], rax
00000001413907fd: mov      edx, ebx
00000001413907ff: lea      rcx, [r14 + 0x100]
0000000141390806: call     0x141367040
000000014139080b: mov      qword ptr [r14 + 0x28], rax
000000014139080f: mov      edx, ebx
0000000141390811: lea      rcx, [r14 + 0x118]
0000000141390818: call     0x141367040
000000014139081d: mov      qword ptr [r14 + 0x30], rax
0000000141390821: mov      edx, ebx
0000000141390823: lea      rcx, [r14 + 0x130]
000000014139082a: call     0x141367040
000000014139082f: mov      qword ptr [r14 + 0x38], rax
0000000141390833: mov      edx, ebx
0000000141390835: lea      rcx, [r14 + 0x148]
000000014139083c: call     0x141367040
0000000141390841: mov      qword ptr [r14 + 0x40], rax
0000000141390845: mov      edx, ebx
0000000141390847: lea      rcx, [r14 + 0x160]
000000014139084e: call     0x141367040
0000000141390853: mov      qword ptr [r14 + 0x48], rax
0000000141390857: mov      edx, ebx
0000000141390859: lea      rcx, [r14 + 0x178]
0000000141390860: call     0x141367040
0000000141390865: mov      qword ptr [r14 + 0x50], rax
0000000141390869: mov      edx, ebx
000000014139086b: lea      rcx, [r14 + 0x190]
0000000141390872: call     0x141367040
0000000141390877: mov      qword ptr [r14 + 0x58], rax
000000014139087b: mov      edx, ebx
000000014139087d: lea      rcx, [r14 + 0x1a8]
0000000141390884: call     0x141367040
0000000141390889: mov      qword ptr [r14 + 0x60], rax
000000014139088d: mov      edx, ebx
000000014139088f: lea      rcx, [r14 + 0x1c0]
0000000141390896: call     0x141367040
000000014139089b: mov      qword ptr [r14 + 0x68], rax
000000014139089f: mov      edx, ebx
00000001413908a1: lea      rcx, [r14 + 0x1d8]
00000001413908a8: call     0x141367040
00000001413908ad: mov      qword ptr [r14 + 0x70], rax
00000001413908b1: mov      edx, ebx
00000001413908b3: lea      rcx, [r14 + 0x280]
00000001413908ba: call     0x141367040
00000001413908bf: mov      qword ptr [r14 + 0xa8], rax
00000001413908c6: mov      edx, ebx
00000001413908c8: lea      rcx, [r14 + 0x298]
00000001413908cf: call     0x141367040
00000001413908d4: mov      qword ptr [r14 + 0xb0], rax
00000001413908db: mov      edx, ebx
00000001413908dd: lea      rcx, [r14 + 0x2b0]
00000001413908e4: call     0x141367040
00000001413908e9: mov      qword ptr [r14 + 0xb8], rax
00000001413908f0: mov      edx, ebx
00000001413908f2: lea      rcx, [r14 + 0x2c8]
00000001413908f9: call     0x141367040
00000001413908fe: mov      qword ptr [r14 + 0xc0], rax
0000000141390905: lea      rcx, [r14 + 0x1f0]
000000014139090c: call     0x141367790
0000000141390911: mov      qword ptr [r14 + 0x78], rax
0000000141390915: lea      rcx, [r14 + 0x208]
000000014139091c: call     0x141367790
0000000141390921: mov      qword ptr [r14 + 0x80], rax
0000000141390928: lea      rcx, [r14 + 0x220]
000000014139092f: call     0x141367790
0000000141390934: mov      qword ptr [r14 + 0x88], rax
000000014139093b: lea      rcx, [r14 + 0x238]
0000000141390942: call     0x141367790
0000000141390947: mov      qword ptr [r14 + 0x90], rax
000000014139094e: lea      rcx, [r14 + 0x250]
0000000141390955: call     0x141367790
000000014139095a: mov      qword ptr [r14 + 0x98], rax
0000000141390961: lea      rcx, [r14 + 0x268]
0000000141390968: call     0x141367790
000000014139096d: mov      qword ptr [r14 + 0xa0], rax
0000000141390974: lea      rcx, [r14 + 0x2e0]
000000014139097b: call     0x141367790
0000000141390980: mov      qword ptr [r14 + 0xc8], rax
0000000141390987: mov      rax, r14
000000014139098a: mov      rbx, qword ptr [rsp + 0x98]
0000000141390992: add      rsp, 0x50
0000000141390996: pop      r15
0000000141390998: pop      r14
000000014139099a: pop      r13
000000014139099c: pop      r12
000000014139099e: pop      rdi
000000014139099f: pop      rsi
00000001413909a0: pop      rbp
00000001413909a1: ret      
00000001413909a2: int3     
00000001413909a3: int3     
00000001413909a4: int3     
00000001413909a5: int3     
00000001413909a6: int3     
00000001413909a7: int3     
00000001413909a8: int3     
00000001413909a9: int3     
00000001413909aa: int3     
00000001413909ab: int3     
00000001413909ac: int3     
00000001413909ad: int3     
00000001413909ae: int3     
00000001413909af: int3     
00000001413909b0: lea      rax, [rip + 0x3d09d1]
00000001413909b7: mov      qword ptr [rcx], rax
00000001413909ba: ret      
00000001413909bb: int3     
00000001413909bc: int3     
00000001413909bd: int3     
00000001413909be: int3     
00000001413909bf: int3     
00000001413909c0: mov      qword ptr [rsp + 8], rbx
00000001413909c5: mov      qword ptr [rsp + 0x10], rsi
00000001413909ca: push     rdi
00000001413909cb: sub      rsp, 0x20
00000001413909cf: mov      rsi, rcx
00000001413909d2: mov      rbx, qword ptr [rcx + 0x48]
00000001413909d6: add      rcx, 0x30
00000001413909da: call     0x141273770
00000001413909df: mov      ecx, eax
00000001413909e1: call     0x141273960
00000001413909e6: mov      rcx, rbx
00000001413909e9: call     0x1412732b0
00000001413909ee: call     0x141273900
00000001413909f3: xor      eax, eax
00000001413909f5: mov      qword ptr [rsi + 0x48], rax
00000001413909f9: mov      qword ptr [rsi + 0x50], rax
00000001413909fd: mov      qword ptr [rsi + 0x58], rax
0000000141390a01: lea      rax, [rip + 0x3d0980]
0000000141390a08: mov      qword ptr [rsi + 0x30], rax
0000000141390a0c: lea      rcx, [rsi + 8]
0000000141390a10: mov      rbx, qword ptr [rsp + 0x30]
0000000141390a15: mov      rsi, qword ptr [rsp + 0x38]
0000000141390a1a: add      rsp, 0x20
0000000141390a1e: pop      rdi
0000000141390a1f: jmp      0x141390a80
0000000141390a24: int3     
0000000141390a25: int3     
0000000141390a26: int3     
0000000141390a27: int3     
0000000141390a28: int3     
0000000141390a29: int3     
0000000141390a2a: int3     
0000000141390a2b: int3     
0000000141390a2c: int3     
0000000141390a2d: int3     
0000000141390a2e: int3     
0000000141390a2f: int3     
0000000141390a30: mov      qword ptr [rsp + 8], rbx
0000000141390a35: push     rdi
0000000141390a36: sub      rsp, 0x20
0000000141390a3a: mov      rdi, rcx
0000000141390a3d: mov      rbx, qword ptr [rcx + 0x18]
0000000141390a41: call     0x141273770
0000000141390a46: mov      ecx, eax
0000000141390a48: call     0x141273960
0000000141390a4d: mov      rcx, rbx
0000000141390a50: call     0x1412732b0
0000000141390a55: call     0x141273900
0000000141390a5a: xor      eax, eax
0000000141390a5c: mov      qword ptr [rdi + 0x18], rax
0000000141390a60: mov      qword ptr [rdi + 0x20], rax
0000000141390a64: mov      qword ptr [rdi + 0x28], rax
0000000141390a68: lea      rax, [rip + 0x3d0919]
0000000141390a6f: mov      qword ptr [rdi], rax
0000000141390a72: mov      rbx, qword ptr [rsp + 0x30]
0000000141390a77: add      rsp, 0x20
0000000141390a7b: pop      rdi
0000000141390a7c: ret      
0000000141390a7d: int3     
0000000141390a7e: int3     
0000000141390a7f: int3     
0000000141390a80: mov      qword ptr [rsp + 8], rbx
0000000141390a85: mov      qword ptr [rsp + 0x10], rsi
0000000141390a8a: push     rdi
0000000141390a8b: sub      rsp, 0x20
0000000141390a8f: mov      rsi, rcx
0000000141390a92: mov      rdx, qword ptr [rcx + 0x18]
0000000141390a96: mov      rax, qword ptr [rdx + 8]
0000000141390a9a: mov      qword ptr [rax], 0
0000000141390aa1: mov      rdi, qword ptr [rdx]
0000000141390aa4: test     rdi, rdi
0000000141390aa7: je       0x141390ad8
0000000141390aa9: nop      dword ptr [rax]
0000000141390ab0: mov      rbx, qword ptr [rdi]
0000000141390ab3: mov      rcx, rsi
0000000141390ab6: call     0x141273770
0000000141390abb: mov      ecx, eax
0000000141390abd: call     0x141273960
0000000141390ac2: mov      rcx, rdi
0000000141390ac5: call     0x1412732b0
0000000141390aca: call     0x141273900
0000000141390acf: nop      
0000000141390ad0: mov      rdi, rbx
0000000141390ad3: test     rbx, rbx
0000000141390ad6: jne      0x141390ab0
0000000141390ad8: mov      rbx, qword ptr [rsi + 0x18]
0000000141390adc: mov      rcx, rsi
0000000141390adf: call     0x141273770
0000000141390ae4: mov      ecx, eax
0000000141390ae6: call     0x141273960
0000000141390aeb: mov      rcx, rbx
0000000141390aee: call     0x1412732b0
0000000141390af3: call     0x141273900
0000000141390af8: nop      
0000000141390af9: lea      rax, [rip + 0x3d0888]
0000000141390b00: mov      qword ptr [rsi], rax
0000000141390b03: mov      rbx, qword ptr [rsp + 0x30]
0000000141390b08: mov      rsi, qword ptr [rsp + 0x38]
0000000141390b0d: add      rsp, 0x20
0000000141390b11: pop      rdi
0000000141390b12: ret      
0000000141390b13: int3     
0000000141390b14: int3     
0000000141390b15: int3     
0000000141390b16: int3     
0000000141390b17: int3     
0000000141390b18: int3     
0000000141390b19: int3     
0000000141390b1a: int3     
0000000141390b1b: int3     
0000000141390b1c: int3     
0000000141390b1d: int3     
0000000141390b1e: int3     
0000000141390b1f: int3     
0000000141390b20: lea      rax, [rip + 0x3d0861]
0000000141390b27: mov      qword ptr [rcx], rax
0000000141390b2a: ret      
0000000141390b2b: int3     
0000000141390b2c: int3     
0000000141390b2d: int3     
0000000141390b2e: int3     
0000000141390b2f: int3     
0000000141390b30: jmp      0x1413909c0
0000000141390b35: int3     
0000000141390b36: int3     
0000000141390b37: int3     
0000000141390b38: int3     
0000000141390b39: int3     
0000000141390b3a: int3     
0000000141390b3b: int3     
0000000141390b3c: int3     
0000000141390b3d: int3     
0000000141390b3e: int3     
0000000141390b3f: int3     
0000000141390b40: mov      qword ptr [rsp + 8], rbx
0000000141390b45: push     rdi
0000000141390b46: sub      rsp, 0x20
0000000141390b4a: lea      rax, [rip + 0x814387]
0000000141390b51: mov      rdi, rcx
0000000141390b54: mov      qword ptr [rcx], rax
0000000141390b57: xor      ebx, ebx
0000000141390b59: mov      rcx, qword ptr [rcx + 0x18]
0000000141390b5d: test     rcx, rcx
0000000141390b60: je       0x141390b6e
0000000141390b62: mov      rax, qword ptr [rcx]
0000000141390b65: lea      edx, [rbx + 1]
0000000141390b68: call     qword ptr [rax]
0000000141390b6a: mov      qword ptr [rdi + 0x18], rbx
0000000141390b6e: mov      rcx, qword ptr [rdi + 0x20]
0000000141390b72: test     rcx, rcx
0000000141390b75: je       0x141390b85
0000000141390b77: mov      rax, qword ptr [rcx]
0000000141390b7a: mov      edx, 1
0000000141390b7f: call     qword ptr [rax]
0000000141390b81: mov      qword ptr [rdi + 0x20], rbx
0000000141390b85: mov      rcx, qword ptr [rdi + 0x28]
0000000141390b89: test     rcx, rcx
0000000141390b8c: je       0x141390b9c
0000000141390b8e: mov      rax, qword ptr [rcx]
0000000141390b91: mov      edx, 1
0000000141390b96: call     qword ptr [rax]
0000000141390b98: mov      qword ptr [rdi + 0x28], rbx
0000000141390b9c: mov      rcx, qword ptr [rdi + 0x30]
0000000141390ba0: test     rcx, rcx
0000000141390ba3: je       0x141390bb3
0000000141390ba5: mov      rax, qword ptr [rcx]
0000000141390ba8: mov      edx, 1
0000000141390bad: call     qword ptr [rax]
0000000141390baf: mov      qword ptr [rdi + 0x30], rbx
0000000141390bb3: mov      rcx, qword ptr [rdi + 0x38]
0000000141390bb7: test     rcx, rcx
0000000141390bba: je       0x141390bca
0000000141390bbc: mov      rax, qword ptr [rcx]
0000000141390bbf: mov      edx, 1
0000000141390bc4: call     qword ptr [rax]
0000000141390bc6: mov      qword ptr [rdi + 0x38], rbx
0000000141390bca: mov      rcx, qword ptr [rdi + 0x40]
0000000141390bce: test     rcx, rcx
0000000141390bd1: je       0x141390be1
0000000141390bd3: mov      rax, qword ptr [rcx]
0000000141390bd6: mov      edx, 1
0000000141390bdb: call     qword ptr [rax]
0000000141390bdd: mov      qword ptr [rdi + 0x40], rbx
0000000141390be1: mov      rcx, qword ptr [rdi + 0x48]
0000000141390be5: test     rcx, rcx
0000000141390be8: je       0x141390bf8
0000000141390bea: mov      rax, qword ptr [rcx]
0000000141390bed: mov      edx, 1
0000000141390bf2: call     qword ptr [rax]
0000000141390bf4: mov      qword ptr [rdi + 0x48], rbx
0000000141390bf8: mov      rcx, qword ptr [rdi + 0x50]
0000000141390bfc: test     rcx, rcx
0000000141390bff: je       0x141390c0f
0000000141390c01: mov      rax, qword ptr [rcx]
0000000141390c04: mov      edx, 1
0000000141390c09: call     qword ptr [rax]
0000000141390c0b: mov      qword ptr [rdi + 0x50], rbx
0000000141390c0f: mov      rcx, qword ptr [rdi + 0x58]
0000000141390c13: test     rcx, rcx
0000000141390c16: je       0x141390c26
0000000141390c18: mov      rax, qword ptr [rcx]
0000000141390c1b: mov      edx, 1
0000000141390c20: call     qword ptr [rax]
0000000141390c22: mov      qword ptr [rdi + 0x58], rbx
0000000141390c26: mov      rcx, qword ptr [rdi + 0x60]
0000000141390c2a: test     rcx, rcx
0000000141390c2d: je       0x141390c3d
0000000141390c2f: mov      rax, qword ptr [rcx]
0000000141390c32: mov      edx, 1
0000000141390c37: call     qword ptr [rax]
0000000141390c39: mov      qword ptr [rdi + 0x60], rbx
0000000141390c3d: mov      rcx, qword ptr [rdi + 0x68]
0000000141390c41: test     rcx, rcx
0000000141390c44: je       0x141390c54
0000000141390c46: mov      rax, qword ptr [rcx]
0000000141390c49: mov      edx, 1
0000000141390c4e: call     qword ptr [rax]
0000000141390c50: mov      qword ptr [rdi + 0x68], rbx
0000000141390c54: mov      rcx, qword ptr [rdi + 0x70]
0000000141390c58: test     rcx, rcx
0000000141390c5b: je       0x141390c6b
0000000141390c5d: mov      rax, qword ptr [rcx]
0000000141390c60: mov      edx, 1
0000000141390c65: call     qword ptr [rax]
0000000141390c67: mov      qword ptr [rdi + 0x70], rbx
0000000141390c6b: mov      rcx, qword ptr [rdi + 0x78]
0000000141390c6f: test     rcx, rcx
0000000141390c72: je       0x141390c82
0000000141390c74: mov      rax, qword ptr [rcx]
0000000141390c77: mov      edx, 1
0000000141390c7c: call     qword ptr [rax]
0000000141390c7e: mov      qword ptr [rdi + 0x78], rbx
0000000141390c82: mov      rcx, qword ptr [rdi + 0x80]
0000000141390c89: test     rcx, rcx
0000000141390c8c: je       0x141390c9f
0000000141390c8e: mov      rax, qword ptr [rcx]
0000000141390c91: mov      edx, 1
0000000141390c96: call     qword ptr [rax]
0000000141390c98: mov      qword ptr [rdi + 0x80], rbx
0000000141390c9f: mov      rcx, qword ptr [rdi + 0x88]
0000000141390ca6: test     rcx, rcx
0000000141390ca9: je       0x141390cbc
0000000141390cab: mov      rax, qword ptr [rcx]
0000000141390cae: mov      edx, 1
0000000141390cb3: call     qword ptr [rax]
0000000141390cb5: mov      qword ptr [rdi + 0x88], rbx
0000000141390cbc: mov      rcx, qword ptr [rdi + 0x90]
0000000141390cc3: test     rcx, rcx
0000000141390cc6: je       0x141390cd9
0000000141390cc8: mov      rax, qword ptr [rcx]
0000000141390ccb: mov      edx, 1
0000000141390cd0: call     qword ptr [rax]
0000000141390cd2: mov      qword ptr [rdi + 0x90], rbx
0000000141390cd9: mov      rcx, qword ptr [rdi + 0x98]
0000000141390ce0: test     rcx, rcx
0000000141390ce3: je       0x141390cf6
0000000141390ce5: mov      rax, qword ptr [rcx]
0000000141390ce8: mov      edx, 1
0000000141390ced: call     qword ptr [rax]
0000000141390cef: mov      qword ptr [rdi + 0x98], rbx
0000000141390cf6: mov      rcx, qword ptr [rdi + 0xa0]
0000000141390cfd: test     rcx, rcx
0000000141390d00: je       0x141390d13
0000000141390d02: mov      rax, qword ptr [rcx]
0000000141390d05: mov      edx, 1
0000000141390d0a: call     qword ptr [rax]
0000000141390d0c: mov      qword ptr [rdi + 0xa0], rbx
0000000141390d13: mov      rcx, qword ptr [rdi + 0xa8]
0000000141390d1a: test     rcx, rcx
0000000141390d1d: je       0x141390d30
0000000141390d1f: mov      rax, qword ptr [rcx]
0000000141390d22: mov      edx, 1
0000000141390d27: call     qword ptr [rax]
0000000141390d29: mov      qword ptr [rdi + 0xa8], rbx
0000000141390d30: mov      rcx, qword ptr [rdi + 0xb0]
0000000141390d37: test     rcx, rcx
0000000141390d3a: je       0x141390d4d
0000000141390d3c: mov      rax, qword ptr [rcx]
0000000141390d3f: mov      edx, 1
0000000141390d44: call     qword ptr [rax]
0000000141390d46: mov      qword ptr [rdi + 0xb0], rbx
0000000141390d4d: mov      rcx, qword ptr [rdi + 0xb8]
0000000141390d54: test     rcx, rcx
0000000141390d57: je       0x141390d6a
0000000141390d59: mov      rax, qword ptr [rcx]
0000000141390d5c: mov      edx, 1
0000000141390d61: call     qword ptr [rax]
0000000141390d63: mov      qword ptr [rdi + 0xb8], rbx
0000000141390d6a: mov      rcx, qword ptr [rdi + 0xc0]
0000000141390d71: test     rcx, rcx
0000000141390d74: je       0x141390d87
0000000141390d76: mov      rax, qword ptr [rcx]
0000000141390d79: mov      edx, 1
0000000141390d7e: call     qword ptr [rax]
0000000141390d80: mov      qword ptr [rdi + 0xc0], rbx
0000000141390d87: mov      rcx, qword ptr [rdi + 0xc8]
0000000141390d8e: test     rcx, rcx
0000000141390d91: je       0x141390da4
0000000141390d93: mov      rax, qword ptr [rcx]
0000000141390d96: mov      edx, 1
0000000141390d9b: call     qword ptr [rax]
0000000141390d9d: mov      qword ptr [rdi + 0xc8], rbx
0000000141390da4: mov      rcx, rdi
0000000141390da7: call     0x141390fa0
0000000141390dac: mov      rdx, qword ptr [rip + 0x83bfacd]
0000000141390db3: lea      rcx, [rdi + 0x300]
0000000141390dba: sub      rdx, rax
0000000141390dbd: cmp      qword ptr [rip + 0x83bfabc], rax
0000000141390dc4: cmovb    rdx, rbx
0000000141390dc8: mov      qword ptr [rip + 0x83bfab1], rdx
0000000141390dcf: call     0x141391400
0000000141390dd4: lea      rcx, [rdi + 0x300]
0000000141390ddb: call     0x1413909c0
0000000141390de0: mov      rbx, qword ptr [rsp + 0x30]
0000000141390de5: lea      rax, [rip + 0x806d8c]
0000000141390dec: mov      qword ptr [rdi], rax
0000000141390def: add      rsp, 0x20
0000000141390df3: pop      rdi
0000000141390df4: ret      
0000000141390df5: int3     
0000000141390df6: int3     
0000000141390df7: int3     
0000000141390df8: int3     
0000000141390df9: int3     
0000000141390dfa: int3     
0000000141390dfb: int3     
0000000141390dfc: int3     
0000000141390dfd: int3     
0000000141390dfe: int3     
0000000141390dff: int3     
0000000141390e00: push     rbx
0000000141390e02: sub      rsp, 0x20
0000000141390e06: lea      rax, [rip + 0x3d057b]
0000000141390e0d: mov      rbx, rcx
0000000141390e10: mov      qword ptr [rcx], rax
0000000141390e13: test     dl, 1
0000000141390e16: je       0x141390e22
0000000141390e18: mov      edx, 0x18
0000000141390e1d: call     0x141272800
0000000141390e22: mov      rax, rbx
0000000141390e25: add      rsp, 0x20
0000000141390e29: pop      rbx
0000000141390e2a: ret      
0000000141390e2b: int3     
0000000141390e2c: int3     
0000000141390e2d: int3     
0000000141390e2e: int3     
0000000141390e2f: int3     
0000000141390e30: push     rbx
0000000141390e32: sub      rsp, 0x20
0000000141390e36: lea      rax, [rip + 0x3d054b]
0000000141390e3d: mov      rbx, rcx
0000000141390e40: mov      qword ptr [rcx], rax
0000000141390e43: test     dl, 1
0000000141390e46: je       0x141390e52
0000000141390e48: mov      edx, 0x18
0000000141390e4d: call     0x141272800
0000000141390e52: mov      rax, rbx
0000000141390e55: add      rsp, 0x20
0000000141390e59: pop      rbx
0000000141390e5a: ret      
0000000141390e5b: int3     
0000000141390e5c: int3     
0000000141390e5d: int3     
0000000141390e5e: int3     
0000000141390e5f: int3     
0000000141390e60: push     rbx
0000000141390e62: sub      rsp, 0x20
0000000141390e66: lea      rax, [rip + 0x3d051b]
0000000141390e6d: mov      rbx, rcx
0000000141390e70: mov      qword ptr [rcx], rax
0000000141390e73: test     dl, 1
0000000141390e76: je       0x141390e82
0000000141390e78: mov      edx, 0x18
0000000141390e7d: call     0x141272800
0000000141390e82: mov      rax, rbx
0000000141390e85: add      rsp, 0x20
0000000141390e89: pop      rbx
0000000141390e8a: ret      
0000000141390e8b: int3     
0000000141390e8c: int3     
0000000141390e8d: int3     
0000000141390e8e: int3     
0000000141390e8f: int3     
0000000141390e90: mov      qword ptr [rsp + 8], rbx
0000000141390e95: push     rdi
0000000141390e96: sub      rsp, 0x20
0000000141390e9a: mov      ebx, edx
0000000141390e9c: mov      rdi, rcx
0000000141390e9f: call     0x141390b40
0000000141390ea4: test     bl, 1
0000000141390ea7: je       0x141390eb6
0000000141390ea9: mov      edx, 0x370
0000000141390eae: mov      rcx, rdi
0000000141390eb1: call     0x141272800
0000000141390eb6: mov      rbx, qword ptr [rsp + 0x30]
0000000141390ebb: mov      rax, rdi
0000000141390ebe: add      rsp, 0x20
0000000141390ec2: pop      rdi
0000000141390ec3: ret      
0000000141390ec4: int3     
0000000141390ec5: int3     
0000000141390ec6: int3     
0000000141390ec7: int3     
0000000141390ec8: int3     
0000000141390ec9: int3     
0000000141390eca: int3     
0000000141390ecb: int3     
0000000141390ecc: int3     
0000000141390ecd: int3     
0000000141390ece: int3     
0000000141390ecf: int3     
0000000141390ed0: push     rbx
0000000141390ed2: sub      rsp, 0x20
0000000141390ed6: mov      rbx, rcx
0000000141390ed9: mov      r8d, 0x10e
0000000141390edf: lea      rdx, [rip + 0x81409a]
0000000141390ee6: lea      ecx, [r8 - 0x46]
0000000141390eea: call     0x141272600
0000000141390eef: mov      qword ptr [rsp + 0x38], rax
0000000141390ef4: test     rax, rax
0000000141390ef7: je       0x141390f0b
0000000141390ef9: mov      rdx, rbx
0000000141390efc: mov      rcx, rax
0000000141390eff: call     0x14139d2f0
0000000141390f04: nop      
0000000141390f05: add      rsp, 0x20
0000000141390f09: pop      rbx
0000000141390f0a: ret      
0000000141390f0b: xor      eax, eax
0000000141390f0d: add      rsp, 0x20
0000000141390f11: pop      rbx
0000000141390f12: ret      
0000000141390f13: int3     
0000000141390f14: int3     
0000000141390f15: int3     
0000000141390f16: int3     
0000000141390f17: int3     
0000000141390f18: int3     
0000000141390f19: int3     
0000000141390f1a: int3     
0000000141390f1b: int3     
0000000141390f1c: int3     
0000000141390f1d: int3     
0000000141390f1e: int3     
0000000141390f1f: int3     
0000000141390f20: mov      qword ptr [rsp + 8], rbx
0000000141390f25: mov      qword ptr [rsp + 0x10], rsi
0000000141390f2a: push     rdi
0000000141390f2b: sub      rsp, 0x20
0000000141390f2f: mov      rdi, rdx
0000000141390f32: mov      rsi, rcx
0000000141390f35: mov      r8d, 0x114
0000000141390f3b: lea      rdx, [rip + 0x81403e]
0000000141390f42: mov      ecx, 0x90
0000000141390f47: call     0x141272600
0000000141390f4c: mov      rbx, rax
0000000141390f4f: mov      qword ptr [rsp + 0x40], rax
0000000141390f54: test     rax, rax
0000000141390f57: je       0x141390f82
0000000141390f59: mov      rcx, qword ptr [rsi + 8]
0000000141390f5d: mov      rdx, qword ptr [rcx]
0000000141390f60: call     qword ptr [rdx + 8]
0000000141390f63: mov      rdx, rax
0000000141390f66: mov      r8, rdi
0000000141390f69: mov      rcx, rbx
0000000141390f6c: call     0x1412f5920
0000000141390f71: nop      
0000000141390f72: mov      rbx, qword ptr [rsp + 0x30]
0000000141390f77: mov      rsi, qword ptr [rsp + 0x38]
0000000141390f7c: add      rsp, 0x20
0000000141390f80: pop      rdi
0000000141390f81: ret      
0000000141390f82: xor      eax, eax
0000000141390f84: mov      rbx, qword ptr [rsp + 0x30]
0000000141390f89: mov      rsi, qword ptr [rsp + 0x38]
0000000141390f8e: add      rsp, 0x20
0000000141390f92: pop      rdi
0000000141390f93: ret      
0000000141390f94: int3     
0000000141390f95: int3     
0000000141390f96: int3     
0000000141390f97: int3     
0000000141390f98: int3     
0000000141390f99: int3     
0000000141390f9a: int3     
0000000141390f9b: int3     
0000000141390f9c: int3     
0000000141390f9d: int3     
0000000141390f9e: int3     
0000000141390f9f: int3     
0000000141390fa0: movss    xmm1, dword ptr [rcx + 0x300]
0000000141390fa8: comiss   xmm1, dword ptr [rip + 0x3d0631]
0000000141390faf: mov      rdx, qword ptr [rcx + 0x368]
0000000141390fb6: jbe      0x141391016
0000000141390fb8: xorps    xmm0, xmm0
0000000141390fbb: test     rdx, rdx
0000000141390fbe: js       0x141390fc7
0000000141390fc0: cvtsi2ss xmm0, rdx
0000000141390fc5: jmp      0x141390fdc
0000000141390fc7: mov      rax, rdx
0000000141390fca: and      edx, 1
0000000141390fcd: shr      rax, 1
0000000141390fd0: or       rax, rdx
0000000141390fd3: cvtsi2ss xmm0, rax
0000000141390fd8: addss    xmm0, xmm0
0000000141390fdc: mulss    xmm0, xmm1
0000000141390fe0: xor      ecx, ecx
0000000141390fe2: movss    xmm1, dword ptr [rip + 0x416936]
0000000141390fea: mulss    xmm0, dword ptr [rip + 0x484a6e]
0000000141390ff2: comiss   xmm0, xmm1
0000000141390ff5: jb       0x14139100d
0000000141390ff7: subss    xmm0, xmm1
0000000141390ffb: comiss   xmm0, xmm1
0000000141390ffe: jae      0x14139100d
0000000141391000: movabs   rax, 0x8000000000000000
000000014139100a: mov      rcx, rax
000000014139100d: cvttss2si rax, xmm0
0000000141391012: add      rax, rcx
0000000141391015: ret      
0000000141391016: imul     rax, rdx, 0x58
000000014139101a: ret      
000000014139101b: int3     
000000014139101c: int3     
000000014139101d: int3     
000000014139101e: int3     
000000014139101f: int3     
0000000141391020: push     rbx
0000000141391022: sub      rsp, 0x20
0000000141391026: mov      rbx, rcx
0000000141391029: call     0x141390fa0
000000014139102e: mov      rdx, qword ptr [rbx + 0x368]
0000000141391035: lea      rcx, [rip + 0x813eb4]
000000014139103c: mov      r8, rax
000000014139103f: add      rsp, 0x20
0000000141391043: pop      rbx
0000000141391044: jmp      0x14127bf80
0000000141391049: int3     
000000014139104a: int3     
000000014139104b: int3     
000000014139104c: int3     
000000014139104d: int3     
000000014139104e: int3     
000000014139104f: int3     
0000000141391050: mov      rcx, qword ptr [rip + 0x83bf829]
0000000141391057: xorps    xmm0, xmm0
000000014139105a: test     rcx, rcx
000000014139105d: js       0x141391066
000000014139105f: cvtsi2ss xmm0, rcx
0000000141391064: jmp      0x14139107b
0000000141391066: mov      rax, rcx
0000000141391069: and      ecx, 1
000000014139106c: shr      rax, 1
000000014139106f: or       rax, rcx
0000000141391072: cvtsi2ss xmm0, rax
0000000141391077: addss    xmm0, xmm0
000000014139107b: mulss    xmm0, dword ptr [rip + 0x803719]
0000000141391083: lea      rcx, [rip + 0x813eb6]
000000014139108a: cvtps2pd xmm1, xmm0
000000014139108d: movq     rdx, xmm1
0000000141391092: jmp      0x14127bf80
0000000141391097: int3     
0000000141391098: int3     
0000000141391099: int3     
000000014139109a: int3     
000000014139109b: int3     
000000014139109c: int3     
000000014139109d: int3     
000000014139109e: int3     
000000014139109f: int3     
00000001413910a0: mov      qword ptr [rsp + 0x10], rbx
00000001413910a5: mov      qword ptr [rsp + 0x18], r8
00000001413910aa: push     rbp
00000001413910ab: push     rsi
00000001413910ac: push     r14
00000001413910ae: sub      rsp, 0x30
00000001413910b2: mov      r14, rdx
00000001413910b5: mov      rbp, rcx
00000001413910b8: mov      rdx, qword ptr [rcx + 0x20]
00000001413910bc: mov      rbx, r8
00000001413910bf: mov      rcx, qword ptr [rcx + 0x18]
00000001413910c3: mov      rsi, rdx
00000001413910c6: sub      rsi, rcx
00000001413910c9: sar      rsi, 3
00000001413910cd: cmp      rsi, r14
00000001413910d0: jae      0x141391173
00000001413910d6: mov      rcx, rbp
00000001413910d9: mov      qword ptr [rsp + 0x50], rdi
00000001413910de: call     0x141273770
00000001413910e3: mov      ecx, eax
00000001413910e5: call     0x141273960
00000001413910ea: mov      r8, qword ptr [rbp + 8]
00000001413910ee: lea      r14, [r14*8]
00000001413910f6: mov      rdx, r14
00000001413910f9: mov      dword ptr [rsp + 0x20], 0x63
0000000141391101: lea      r9, [rip + 0x3d0188]
0000000141391108: mov      ecx, 8
000000014139110d: call     0x1412734b0
0000000141391112: mov      rdi, rax
0000000141391115: call     0x141273900
000000014139111a: test     rsi, rsi
000000014139111d: je       0x14139113f
000000014139111f: mov      rsi, qword ptr [rbp + 0x18]
0000000141391123: mov      rcx, rbp
0000000141391126: call     0x141273770
000000014139112b: mov      ecx, eax
000000014139112d: call     0x141273960
0000000141391132: mov      rcx, rsi
0000000141391135: call     0x1412732b0
000000014139113a: call     0x141273900
000000014139113f: lea      rax, [r14 + rdi]
0000000141391143: mov      qword ptr [rbp + 0x18], rdi
0000000141391147: mov      qword ptr [rbp + 0x20], rax
000000014139114b: mov      qword ptr [rbp + 0x28], rax
000000014139114f: cmp      rdi, rax
0000000141391152: je       0x141391160
0000000141391154: mov      qword ptr [rdi], rbx
0000000141391157: add      rdi, 8
000000014139115b: cmp      rdi, rax
000000014139115e: jne      0x141391154
0000000141391160: mov      rdi, qword ptr [rsp + 0x50]
0000000141391165: mov      rbx, qword ptr [rsp + 0x58]
000000014139116a: add      rsp, 0x30
000000014139116e: pop      r14
0000000141391170: pop      rsi
0000000141391171: pop      rbp
0000000141391172: ret      
0000000141391173: lea      r8, [rsp + 0x60]
0000000141391178: call     0x141390420
000000014139117d: mov      rbx, qword ptr [rsp + 0x58]
0000000141391182: add      rsp, 0x30
0000000141391186: pop      r14
0000000141391188: pop      rsi
0000000141391189: pop      rbp
000000014139118a: ret      
000000014139118b: int3     
000000014139118c: int3     
000000014139118d: int3     
000000014139118e: int3     
000000014139118f: int3     
0000000141391190: mov      qword ptr [rsp + 8], rcx
0000000141391195: push     rbx
0000000141391196: push     rbp
0000000141391197: push     rsi
0000000141391198: push     rdi
0000000141391199: push     r12
000000014139119b: push     r13
000000014139119d: push     r14
000000014139119f: push     r15
00000001413911a1: sub      rsp, 0x38
00000001413911a5: mov      r14, r8
00000001413911a8: mov      r12, rdx
00000001413911ab: mov      rdx, rcx
00000001413911ae: cmp      r12, r8
00000001413911b1: je       0x1413913d5
00000001413911b7: mov      r13, qword ptr [rcx + 0x20]
00000001413911bb: mov      r8, qword ptr [rcx + 0x48]
00000001413911bf: mov      qword ptr [rsp + 0x28], r8
00000001413911c4: lea      rbp, [rcx + 8]
00000001413911c8: mov      r15, qword ptr [r12 + 8]
00000001413911cd: mov      qword ptr [rsp + 0x98], r15
00000001413911d5: movzx    ecx, byte ptr [r12 + 0x10]
00000001413911db: movabs   rax, 0xcbf29ce484222325
00000001413911e5: xor      rcx, rax
00000001413911e8: movabs   r9, 0x100000001b3
00000001413911f2: imul     rcx, r9
00000001413911f6: movzx    eax, byte ptr [r12 + 0x11]
00000001413911fc: xor      rcx, rax
00000001413911ff: imul     rcx, r9
0000000141391203: movzx    eax, byte ptr [r12 + 0x12]
0000000141391209: xor      rcx, rax
000000014139120c: imul     rcx, r9
0000000141391210: movzx    eax, byte ptr [r12 + 0x13]
0000000141391216: xor      rcx, rax
0000000141391219: imul     rcx, r9
000000014139121d: mov      rsi, qword ptr [rdx + 0x60]
0000000141391221: and      rsi, rcx
0000000141391224: shl      rsi, 4
0000000141391228: add      rsi, r8
000000014139122b: mov      qword ptr [rsp + 0x88], rsi
0000000141391233: mov      rax, qword ptr [rsi]
0000000141391236: mov      qword ptr [rsp + 0x90], rax
000000014139123e: mov      rdi, qword ptr [rsi + 8]
0000000141391242: mov      qword ptr [rsp + 0x20], rdi
0000000141391247: mov      rbx, qword ptr [r12]
000000014139124b: mov      rcx, rbp
000000014139124e: call     0x141273770
0000000141391253: mov      ecx, eax
0000000141391255: call     0x141273960
000000014139125a: mov      rcx, r12
000000014139125d: call     0x1412732b0
0000000141391262: call     0x141273900
0000000141391267: nop      
0000000141391268: dec      qword ptr [rbp + 0x20]
000000014139126c: cmp      r12, rdi
000000014139126f: je       0x1413912af
0000000141391271: mov      rsi, rbx
0000000141391274: cmp      rbx, r14
0000000141391277: je       0x1413912c1
0000000141391279: mov      rdi, rbx
000000014139127c: mov      rbx, qword ptr [rbx]
000000014139127f: mov      rcx, rbp
0000000141391282: call     0x141273770
0000000141391287: mov      ecx, eax
0000000141391289: call     0x141273960
000000014139128e: mov      rcx, rdi
0000000141391291: call     0x1412732b0
0000000141391296: call     0x141273900
000000014139129b: nop      
000000014139129c: dec      qword ptr [rbp + 0x20]
00000001413912a0: cmp      rdi, qword ptr [rsp + 0x20]
00000001413912a5: jne      0x141391271
00000001413912a7: mov      rsi, qword ptr [rsp + 0x88]
00000001413912af: cmp      qword ptr [rsp + 0x90], r12
00000001413912b7: jne      0x1413912df
00000001413912b9: mov      qword ptr [rsi], r13
00000001413912bc: mov      rax, r13
00000001413912bf: jmp      0x1413912e2
00000001413912c1: cmp      qword ptr [rsp + 0x90], r12
00000001413912c9: jne      0x1413913ce
00000001413912cf: mov      rax, qword ptr [rsp + 0x88]
00000001413912d7: mov      qword ptr [rax], rbx
00000001413912da: jmp      0x1413913ce
00000001413912df: mov      rax, r15
00000001413912e2: mov      qword ptr [rsi + 8], rax
00000001413912e6: cmp      rbx, r14
00000001413912e9: je       0x1413913ce
00000001413912ef: nop      
00000001413912f0: mov      rsi, rbx
00000001413912f3: movzx    ecx, byte ptr [rbx + 0x10]
00000001413912f7: movabs   rax, 0xcbf29ce484222325
0000000141391301: xor      rcx, rax
0000000141391304: movabs   rdx, 0x100000001b3
000000014139130e: imul     rcx, rdx
0000000141391312: movzx    eax, byte ptr [rbx + 0x11]
0000000141391316: xor      rcx, rax
0000000141391319: imul     rcx, rdx
000000014139131d: movzx    eax, byte ptr [rbx + 0x12]
0000000141391321: xor      rcx, rax
0000000141391324: imul     rcx, rdx
0000000141391328: movzx    eax, byte ptr [rbx + 0x13]
000000014139132c: xor      rcx, rax
000000014139132f: imul     rcx, rdx
0000000141391333: mov      rax, qword ptr [rsp + 0x80]
000000014139133b: mov      r12, qword ptr [rax + 0x60]
000000014139133f: and      r12, rcx
0000000141391342: shl      r12, 4
0000000141391346: add      r12, qword ptr [rsp + 0x28]
000000014139134b: mov      r15, qword ptr [r12 + 8]
0000000141391350: mov      rdi, rbx
0000000141391353: mov      rbx, qword ptr [rbx]
0000000141391356: mov      rcx, rbp
0000000141391359: call     0x141273770
000000014139135e: mov      ecx, eax
0000000141391360: call     0x141273960
0000000141391365: mov      rcx, rdi
0000000141391368: call     0x1412732b0
000000014139136d: call     0x141273900
0000000141391372: nop      
0000000141391373: dec      qword ptr [rbp + 0x20]
0000000141391377: cmp      rdi, r15
000000014139137a: je       0x1413913b4
000000014139137c: nop      dword ptr [rax]
0000000141391380: mov      rsi, rbx
0000000141391383: cmp      rbx, r14
0000000141391386: je       0x1413913e9
0000000141391388: mov      rdi, rbx
000000014139138b: mov      rbx, qword ptr [rbx]
000000014139138e: mov      rcx, rbp
0000000141391391: call     0x141273770
0000000141391396: mov      ecx, eax
0000000141391398: call     0x141273960
000000014139139d: mov      rcx, rdi
00000001413913a0: call     0x1412732b0
00000001413913a5: call     0x141273900
00000001413913aa: nop      
00000001413913ab: dec      qword ptr [rbp + 0x20]
00000001413913af: cmp      rdi, r15
00000001413913b2: jne      0x141391380
00000001413913b4: mov      qword ptr [r12], r13
00000001413913b8: mov      qword ptr [r12 + 8], r13
00000001413913bd: cmp      rbx, r14
00000001413913c0: jne      0x1413912f0
00000001413913c6: mov      r15, qword ptr [rsp + 0x98]
00000001413913ce: mov      qword ptr [r15], rbx
00000001413913d1: mov      qword ptr [rbx + 8], r15
00000001413913d5: mov      rax, r14
00000001413913d8: add      rsp, 0x38
00000001413913dc: pop      r15
00000001413913de: pop      r14
00000001413913e0: pop      r13
00000001413913e2: pop      r12
00000001413913e4: pop      rdi
00000001413913e5: pop      rsi
00000001413913e6: pop      rbp
00000001413913e7: pop      rbx
00000001413913e8: ret      
00000001413913e9: mov      qword ptr [r12], rbx
00000001413913ed: mov      rax, qword ptr [rsp + 0x98]
00000001413913f5: mov      qword ptr [rax], rbx
00000001413913f8: mov      qword ptr [rbx + 8], rax
00000001413913fc: jmp      0x1413913d5
00000001413913fe: int3     
00000001413913ff: int3     
0000000141391400: mov      qword ptr [rsp + 0x10], rbx
0000000141391405: mov      qword ptr [rsp + 0x18], rbp
000000014139140a: mov      qword ptr [rsp + 0x20], rsi
000000014139140f: push     rdi
0000000141391410: sub      rsp, 0x20
0000000141391414: mov      rdi, rcx
0000000141391417: mov      rcx, qword ptr [rcx + 0x28]
000000014139141b: test     rcx, rcx
000000014139141e: je       0x1413914bc
0000000141391424: mov      rax, qword ptr [rdi + 0x68]
0000000141391428: shr      rax, 3
000000014139142c: cmp      rax, rcx
000000014139142f: jbe      0x141391445
0000000141391431: mov      rdx, qword ptr [rdi + 0x20]
0000000141391435: mov      r8, rdx
0000000141391438: mov      rdx, qword ptr [rdx]
000000014139143b: mov      rcx, rdi
000000014139143e: call     0x141391190
0000000141391443: jmp      0x1413914bc
0000000141391445: mov      rcx, qword ptr [rdi + 0x20]
0000000141391449: mov      rax, qword ptr [rcx + 8]
000000014139144d: mov      qword ptr [rax], 0
0000000141391454: mov      rsi, qword ptr [rcx]
0000000141391457: test     rsi, rsi
000000014139145a: je       0x141391489
000000014139145c: nop      dword ptr [rax]
0000000141391460: mov      rbx, qword ptr [rsi]
0000000141391463: lea      rcx, [rdi + 8]
0000000141391467: call     0x141273770
000000014139146c: mov      ecx, eax
000000014139146e: call     0x141273960
0000000141391473: mov      rcx, rsi
0000000141391476: call     0x1412732b0
000000014139147b: call     0x141273900
0000000141391480: nop      
0000000141391481: mov      rsi, rbx
0000000141391484: test     rbx, rbx
0000000141391487: jne      0x141391460
0000000141391489: mov      rax, qword ptr [rdi + 0x20]
000000014139148d: mov      qword ptr [rax], rax
0000000141391490: mov      rax, qword ptr [rdi + 0x20]
0000000141391494: mov      qword ptr [rax + 8], rax
0000000141391498: mov      qword ptr [rdi + 0x28], 0
00000001413914a0: mov      rax, qword ptr [rdi + 0x20]
00000001413914a4: mov      qword ptr [rsp + 0x30], rax
00000001413914a9: lea      r8, [rsp + 0x30]
00000001413914ae: mov      rdx, qword ptr [rdi + 0x50]
00000001413914b2: mov      rcx, qword ptr [rdi + 0x48]
00000001413914b6: call     0x141390420
00000001413914bb: nop      
00000001413914bc: mov      rbx, qword ptr [rsp + 0x38]
00000001413914c1: mov      rbp, qword ptr [rsp + 0x40]
00000001413914c6: mov      rsi, qword ptr [rsp + 0x48]
00000001413914cb: add      rsp, 0x20
00000001413914cf: pop      rdi
00000001413914d0: ret      
00000001413914d1: int3     
00000001413914d2: int3     
00000001413914d3: int3     
00000001413914d4: int3     
00000001413914d5: int3     
00000001413914d6: int3     
00000001413914d7: int3     
00000001413914d8: int3     
00000001413914d9: int3     
00000001413914da: int3     
00000001413914db: int3     
00000001413914dc: int3     
00000001413914dd: int3     
00000001413914de: int3     
00000001413914df: int3     
00000001413914e0: mov      qword ptr [rsp + 8], rbx
00000001413914e5: mov      qword ptr [rsp + 0x10], rsi
00000001413914ea: push     rdi
00000001413914eb: sub      rsp, 0x20
00000001413914ef: mov      rdi, rdx
00000001413914f2: mov      rsi, rcx
00000001413914f5: mov      r8d, 0x1a
00000001413914fb: lea      rdx, [rip + 0x813ade]
0000000141391502: mov      ecx, 0x2b0
0000000141391507: call     0x141272600
000000014139150c: mov      rbx, rax
000000014139150f: mov      qword ptr [rsp + 0x40], rax
0000000141391514: test     rax, rax
0000000141391517: je       0x141391542
0000000141391519: mov      rcx, qword ptr [rsi + 8]
000000014139151d: mov      rdx, qword ptr [rcx]
0000000141391520: call     qword ptr [rdx + 8]
0000000141391523: mov      rdx, rax
0000000141391526: mov      r8, rdi
0000000141391529: mov      rcx, rbx
000000014139152c: call     0x1412d1210
0000000141391531: nop      
0000000141391532: mov      rbx, qword ptr [rsp + 0x30]
0000000141391537: mov      rsi, qword ptr [rsp + 0x38]
000000014139153c: add      rsp, 0x20
0000000141391540: pop      rdi
0000000141391541: ret      
0000000141391542: xor      eax, eax
0000000141391544: mov      rbx, qword ptr [rsp + 0x30]
0000000141391549: mov      rsi, qword ptr [rsp + 0x38]
000000014139154e: add      rsp, 0x20
0000000141391552: pop      rdi
0000000141391553: ret      
0000000141391554: int3     
0000000141391555: int3     
0000000141391556: int3     
0000000141391557: int3     
0000000141391558: int3     
0000000141391559: int3     
000000014139155a: int3     
000000014139155b: int3     
000000014139155c: int3     
000000014139155d: int3     
000000014139155e: int3     
000000014139155f: int3     
0000000141391560: mov      qword ptr [rsp + 0x10], rbx
0000000141391565: mov      qword ptr [rsp + 0x18], rsi
000000014139156a: mov      qword ptr [rsp + 8], rcx
000000014139156f: push     rdi
0000000141391570: sub      rsp, 0x20
0000000141391574: mov      rsi, rdx
0000000141391577: mov      rdi, rcx
000000014139157a: lea      rax, [rip + 0x813abf]
0000000141391581: mov      qword ptr [rcx], rax
0000000141391584: movzx    eax, word ptr [rdx + 0x400]
000000014139158b: mov      dword ptr [rcx + 0x20], eax
000000014139158e: mov      r8d, eax
0000000141391591: mov      eax, 0x18
0000000141391596: mul      r8
0000000141391599: mov      rcx, 0xffffffffffffffff
00000001413915a0: cmovo    rax, rcx
00000001413915a4: lea      r8d, [rcx + 0x22]
00000001413915a8: lea      rdx, [rip + 0x813ab1]
00000001413915af: mov      rcx, rax
00000001413915b2: call     0x141272e00
00000001413915b7: mov      qword ptr [rdi + 0x18], rax
00000001413915bb: xor      ebx, ebx
00000001413915bd: cmp      dword ptr [rdi + 0x20], ebx
00000001413915c0: jbe      0x1413915f6
00000001413915c2: nop      dword ptr [rax]
00000001413915c6: nop      word ptr [rax + rax]
00000001413915d0: movzx    eax, bx
00000001413915d3: lea      rcx, [rax + rax*2]
00000001413915d7: mov      rax, qword ptr [rdi + 0x18]
00000001413915db: lea      rdx, [rax + rcx*8]
00000001413915df: movzx    r8d, bx
00000001413915e3: mov      rcx, rsi
00000001413915e6: call     0x141391760
00000001413915eb: inc      bx
00000001413915ee: movzx    eax, bx
00000001413915f1: cmp      eax, dword ptr [rdi + 0x20]
00000001413915f4: jb       0x1413915d0
00000001413915f6: mov      rax, rdi
00000001413915f9: mov      rbx, qword ptr [rsp + 0x38]
00000001413915fe: mov      rsi, qword ptr [rsp + 0x40]
0000000141391603: add      rsp, 0x20
0000000141391607: pop      rdi
0000000141391608: ret      
0000000141391609: int3     
000000014139160a: int3     
000000014139160b: int3     
000000014139160c: int3     
000000014139160d: int3     
000000014139160e: int3     
000000014139160f: int3     
0000000141391610: push     rbx
0000000141391612: sub      rsp, 0x20
0000000141391616: lea      rax, [rip + 0x813a23]
000000014139161d: mov      rbx, rcx
0000000141391620: mov      qword ptr [rcx], rax
0000000141391623: mov      rcx, qword ptr [rcx + 0x18]
0000000141391627: test     rcx, rcx
000000014139162a: je       0x141391639
000000014139162c: call     0x141272e20
0000000141391631: mov      qword ptr [rbx + 0x18], 0
0000000141391639: lea      rax, [rip + 0x806538]
0000000141391640: mov      qword ptr [rbx], rax
0000000141391643: add      rsp, 0x20
0000000141391647: pop      rbx
0000000141391648: ret      
0000000141391649: int3     
000000014139164a: int3     
000000014139164b: int3     
000000014139164c: int3     
000000014139164d: int3     
000000014139164e: int3     
000000014139164f: int3     
0000000141391650: mov      qword ptr [rsp + 8], rbx
0000000141391655: push     rdi
0000000141391656: sub      rsp, 0x20
000000014139165a: lea      rax, [rip + 0x8139df]
0000000141391661: mov      rbx, rcx
0000000141391664: mov      qword ptr [rcx], rax
0000000141391667: mov      edi, edx
0000000141391669: mov      rcx, qword ptr [rcx + 0x18]
000000014139166d: test     rcx, rcx
0000000141391670: je       0x14139167f
0000000141391672: call     0x141272e20
0000000141391677: mov      qword ptr [rbx + 0x18], 0
000000014139167f: lea      rax, [rip + 0x8064f2]
0000000141391686: mov      qword ptr [rbx], rax
0000000141391689: test     dil, 1
000000014139168d: je       0x14139169c
000000014139168f: mov      edx, 0x28
0000000141391694: mov      rcx, rbx
0000000141391697: call     0x141272800
000000014139169c: mov      rax, rbx
000000014139169f: mov      rbx, qword ptr [rsp + 0x30]
00000001413916a4: add      rsp, 0x20
00000001413916a8: pop      rdi
00000001413916a9: ret      
00000001413916aa: int3     
00000001413916ab: int3     
00000001413916ac: int3     
00000001413916ad: int3     
00000001413916ae: int3     
00000001413916af: int3     
00000001413916b0: push     rbx
00000001413916b2: sub      rsp, 0x20
00000001413916b6: mov      rbx, rcx
00000001413916b9: mov      r8d, 0x37
00000001413916bf: lea      rdx, [rip + 0x81399a]
00000001413916c6: lea      ecx, [r8 - 0x1f]
00000001413916ca: call     0x141272600
00000001413916cf: mov      qword ptr [rsp + 0x38], rax
00000001413916d4: test     rax, rax
00000001413916d7: je       0x1413916eb
00000001413916d9: mov      rdx, rbx
00000001413916dc: mov      rcx, rax
00000001413916df: call     0x14139d820
00000001413916e4: nop      
00000001413916e5: add      rsp, 0x20
00000001413916e9: pop      rbx
00000001413916ea: ret      
00000001413916eb: xor      eax, eax
00000001413916ed: add      rsp, 0x20
00000001413916f1: pop      rbx
00000001413916f2: ret      
00000001413916f3: int3     
00000001413916f4: int3     
00000001413916f5: int3     
00000001413916f6: int3     
00000001413916f7: int3     
00000001413916f8: int3     
00000001413916f9: int3     
00000001413916fa: int3     
00000001413916fb: int3     
00000001413916fc: int3     
00000001413916fd: int3     
00000001413916fe: int3     
00000001413916ff: int3     
0000000141391700: push     rbx
0000000141391702: sub      rsp, 0x20
0000000141391706: mov      rcx, qword ptr [rcx + 8]
000000014139170a: mov      rbx, rdx
000000014139170d: mov      rax, qword ptr [rcx]
0000000141391710: call     qword ptr [rax + 8]
0000000141391713: mov      rdx, rbx
0000000141391716: mov      rcx, rax
0000000141391719: mov      r8, qword ptr [rax]
000000014139171c: add      rsp, 0x20
0000000141391720: pop      rbx
0000000141391721: jmp      qword ptr [r8]
0000000141391724: int3     
0000000141391725: int3     
0000000141391726: int3     
0000000141391727: int3     
0000000141391728: int3     
0000000141391729: int3     
000000014139172a: int3     
000000014139172b: int3     
000000014139172c: int3     
000000014139172d: int3     
000000014139172e: int3     
000000014139172f: int3     
0000000141391730: cmp      edx, dword ptr [rcx + 0x20]
0000000141391733: jae      0x141391744
0000000141391735: mov      eax, edx
0000000141391737: lea      rdx, [rax + rax*2]
000000014139173b: mov      rax, qword ptr [rcx + 0x18]
000000014139173f: lea      rax, [rax + rdx*8]
0000000141391743: ret      
0000000141391744: xor      eax, eax
0000000141391746: ret      
0000000141391747: int3     
0000000141391748: int3     
0000000141391749: int3     
000000014139174a: int3     
000000014139174b: int3     
000000014139174c: int3     
000000014139174d: int3     
000000014139174e: int3     
000000014139174f: int3     
0000000141391750: mov      eax, dword ptr [rcx + 0x20]
0000000141391753: ret      
0000000141391754: int3     
0000000141391755: int3     
0000000141391756: int3     
0000000141391757: int3     
0000000141391758: int3     
0000000141391759: int3     
000000014139175a: int3     
000000014139175b: int3     
000000014139175c: int3     
000000014139175d: int3     
000000014139175e: int3     
000000014139175f: int3     
0000000141391760: mov      qword ptr [rsp + 8], rbx
0000000141391765: movzx    r10d, word ptr [rcx + 0x400]
000000014139176d: xor      ebx, ebx
000000014139176f: movzx    r11d, r8w
0000000141391773: movzx    eax, bx
0000000141391776: cmp      bx, r10w
000000014139177a: jae      0x1413917a3
000000014139177c: nop      dword ptr [rax]
0000000141391780: movzx    r9d, ax
0000000141391784: mov      r8d, r9d
0000000141391787: shl      r8, 5
000000014139178b: cmp      word ptr [r8 + rcx + 4], r11w
0000000141391791: jne      0x14139179a
0000000141391793: cmp      byte ptr [r8 + rcx + 0x18], bl
0000000141391798: je       0x1413917af
000000014139179a: inc      ax
000000014139179d: cmp      ax, r10w
00000001413917a1: jb       0x141391780
00000001413917a3: mov      qword ptr [rdx + 8], rbx
00000001413917a7: mov      dword ptr [rdx], ebx
00000001413917a9: mov      rbx, qword ptr [rsp + 8]
00000001413917ae: ret      
00000001413917af: mov      rbx, qword ptr [rsp + 8]
00000001413917b4: shl      r9, 5
00000001413917b8: mov      rax, qword ptr [r9 + rcx + 0x10]
00000001413917bd: mov      byte ptr [r9 + rcx + 0x18], 1
00000001413917c3: mov      qword ptr [rdx + 8], rax
00000001413917c7: mov      eax, dword ptr [r9 + rcx]
00000001413917cb: mov      dword ptr [rdx], eax
00000001413917cd: movzx    eax, word ptr [r9 + rcx + 8]
00000001413917d3: mov      word ptr [rdx + 0x10], ax
00000001413917d7: ret      
00000001413917d8: int3     
00000001413917d9: int3     
00000001413917da: int3     
00000001413917db: int3     
00000001413917dc: int3     
00000001413917dd: int3     
00000001413917de: int3     
00000001413917df: int3     
00000001413917e0: mov      qword ptr [rsp + 8], rbx
00000001413917e5: mov      qword ptr [rsp + 0x10], rdi
00000001413917ea: mov      r8d, dword ptr [rcx]
00000001413917ed: mov      edi, 0
00000001413917f2: mov      rdx, qword ptr [rcx + 0x10]
00000001413917f6: test     r8b, 6
00000001413917fa: mov      rax, rdx
00000001413917fd: cmove    rax, rdi
0000000141391801: mov      qword ptr [rcx + 0x18], rax
0000000141391805: mov      eax, r8d
0000000141391808: shr      eax, 1
000000014139180a: and      al, 3
000000014139180c: cmp      al, 2
000000014139180e: jne      0x14139181e
0000000141391810: movzx    eax, word ptr [rcx + 4]
0000000141391814: lea      r9, [rax + rax*2]
0000000141391818: shl      r9, 2
000000014139181c: jmp      0x14139182a
000000014139181e: test     al, al
0000000141391820: mov      r9d, 0xc
0000000141391826: cmove    r9, rdi
000000014139182a: add      rdx, r9
000000014139182d: mov      r10d, r8d
0000000141391830: test     r8b, 0x18
0000000141391834: mov      rax, rdx
0000000141391837: mov      r9d, 4
000000014139183d: cmove    rax, rdi
0000000141391841: shr      r10d, 3
0000000141391845: and      r10b, 3
0000000141391849: mov      qword ptr [rcx + 0x20], rax
000000014139184d: cmp      r10b, 2
0000000141391851: jne      0x14139185d
0000000141391853: movzx    eax, word ptr [rcx + 4]
0000000141391857: shl      rax, 2
000000014139185b: jmp      0x141391867
000000014139185d: test     r10b, r10b
0000000141391860: mov      rax, r9
0000000141391863: cmove    rax, rdi
0000000141391867: add      rdx, rax
000000014139186a: mov      r11d, r8d
000000014139186d: test     r8b, 0x60
0000000141391871: mov      rax, rdx
0000000141391874: mov      r10d, 8
000000014139187a: cmove    rax, rdi
000000014139187e: shr      r11d, 5
0000000141391882: and      r11b, 3
0000000141391886: mov      qword ptr [rcx + 0x28], rax
000000014139188a: cmp      r11b, 2
000000014139188e: jne      0x14139189a
0000000141391890: movzx    eax, word ptr [rcx + 4]
0000000141391894: shl      rax, 3
0000000141391898: jmp      0x1413918a4
000000014139189a: test     r11b, r11b
000000014139189d: mov      rax, r10
00000001413918a0: cmove    rax, rdi
00000001413918a4: add      rdx, rax
00000001413918a7: mov      r11d, r8d
00000001413918aa: test     r8d, 0x180
00000001413918b1: mov      rax, rdx
00000001413918b4: cmove    rax, rdi
00000001413918b8: shr      r11d, 7
00000001413918bc: and      r11b, 3
00000001413918c0: mov      qword ptr [rcx + 0x30], rax
00000001413918c4: cmp      r11b, 2
00000001413918c8: jne      0x1413918d4
00000001413918ca: movzx    eax, word ptr [rcx + 4]
00000001413918ce: shl      rax, 2
00000001413918d2: jmp      0x1413918de
00000001413918d4: test     r11b, r11b
00000001413918d7: mov      rax, r9
00000001413918da: cmove    rax, rdi
00000001413918de: add      rdx, rax
00000001413918e1: mov      r11d, r8d
00000001413918e4: test     r8d, 0x600
00000001413918eb: mov      rax, rdx
00000001413918ee: cmove    rax, rdi
00000001413918f2: shr      r11d, 9
00000001413918f6: and      r11b, 3
00000001413918fa: mov      qword ptr [rcx + 0x38], rax
00000001413918fe: cmp      r11b, 2
0000000141391902: jne      0x14139190e
0000000141391904: movzx    eax, word ptr [rcx + 4]
0000000141391908: shl      rax, 3
000000014139190c: jmp      0x141391918
000000014139190e: test     r11b, r11b
0000000141391911: mov      rax, r10
0000000141391914: cmove    rax, rdi
0000000141391918: add      rdx, rax
000000014139191b: mov      r11d, r8d
000000014139191e: test     r8d, 0x1800
0000000141391925: mov      rax, rdx
0000000141391928: cmove    rax, rdi
000000014139192c: shr      r11d, 0xb
0000000141391930: and      r11b, 3
0000000141391934: mov      qword ptr [rcx + 0x40], rax
0000000141391938: cmp      r11b, 2
000000014139193c: jne      0x141391948
000000014139193e: movzx    eax, word ptr [rcx + 4]
0000000141391942: shl      rax, 3
0000000141391946: jmp      0x141391952
0000000141391948: test     r11b, r11b
000000014139194b: mov      rax, r10
000000014139194e: cmove    rax, rdi
0000000141391952: add      rdx, rax
0000000141391955: mov      ebx, r8d
0000000141391958: test     r8d, 0x6000
000000014139195f: mov      rax, rdx
0000000141391962: cmove    rax, rdi
0000000141391966: shr      ebx, 0xd
0000000141391969: movzx    r11d, bl
000000014139196d: mov      qword ptr [rcx + 0x48], rax
0000000141391971: and      r11b, 3
0000000141391975: cmp      r11b, 2
0000000141391979: jne      0x141391985
000000014139197b: movzx    eax, word ptr [rcx + 4]
000000014139197f: shl      rax, 2
0000000141391983: jmp      0x14139198f
0000000141391985: test     r11b, r11b
0000000141391988: mov      rax, r9
000000014139198b: cmove    rax, rdi
000000014139198f: add      rdx, rax
0000000141391992: mov      r11d, r8d
0000000141391995: test     bl, 3
0000000141391998: mov      rax, rdx
000000014139199b: cmove    rax, rdi
000000014139199f: shr      r11d, 0xf
00000001413919a3: and      r11b, 3
00000001413919a7: mov      qword ptr [rcx + 0x50], rax
00000001413919ab: cmp      r11b, 2
00000001413919af: jne      0x1413919bb
00000001413919b1: movzx    eax, word ptr [rcx + 4]
00000001413919b5: shl      rax, 2
00000001413919b9: jmp      0x1413919c5
00000001413919bb: test     r11b, r11b
00000001413919be: mov      rax, r9
00000001413919c1: cmove    rax, rdi
00000001413919c5: add      rdx, rax
00000001413919c8: mov      r11d, r8d
00000001413919cb: test     r8d, 0x6000
00000001413919d2: mov      rax, rdx
00000001413919d5: cmove    rax, rdi
00000001413919d9: shr      r11d, 0x11
00000001413919dd: and      r11b, 3
00000001413919e1: mov      qword ptr [rcx + 0x58], rax
00000001413919e5: cmp      r11b, 2
00000001413919e9: jne      0x1413919f5
00000001413919eb: movzx    eax, word ptr [rcx + 4]
00000001413919ef: shl      rax, 2
00000001413919f3: jmp      0x1413919ff
00000001413919f5: test     r11b, r11b
00000001413919f8: mov      rax, r9
00000001413919fb: cmove    rax, rdi
00000001413919ff: add      rdx, rax
0000000141391a02: mov      r11d, r8d
0000000141391a05: test     r8d, 0x180000
0000000141391a0c: mov      rax, rdx
0000000141391a0f: cmove    rax, rdi
0000000141391a13: shr      r11d, 0x13
0000000141391a17: and      r11b, 3
0000000141391a1b: mov      qword ptr [rcx + 0x60], rax
0000000141391a1f: cmp      r11b, 2
0000000141391a23: jne      0x141391a2f
0000000141391a25: movzx    eax, word ptr [rcx + 4]
0000000141391a29: shl      rax, 3
0000000141391a2d: jmp      0x141391a39
0000000141391a2f: test     r11b, r11b
0000000141391a32: mov      rax, r10
0000000141391a35: cmove    rax, rdi
0000000141391a39: add      rdx, rax
0000000141391a3c: test     r8d, 0x600000
0000000141391a43: mov      rax, rdx
0000000141391a46: cmove    rax, rdi
0000000141391a4a: mov      qword ptr [rcx + 0x68], rax
0000000141391a4e: mov      eax, r8d
0000000141391a51: shr      eax, 0x15
0000000141391a54: and      al, 3
0000000141391a56: cmp      al, 2
0000000141391a58: jne      0x141391a65
0000000141391a5a: movzx    r10d, word ptr [rcx + 4]
0000000141391a5f: shl      r10, 3
0000000141391a63: jmp      0x141391a6b
0000000141391a65: test     al, al
0000000141391a67: cmove    r10, rdi
0000000141391a6b: test     r8d, 0x1800000
0000000141391a72: lea      r11, [r10 + rdx]
0000000141391a76: mov      rax, r11
0000000141391a79: cmove    rax, rdi
0000000141391a7d: mov      qword ptr [rcx + 0x70], rax
0000000141391a81: mov      eax, r8d
0000000141391a84: shr      eax, 0x17
0000000141391a87: and      al, 3
0000000141391a89: cmp      al, 2
0000000141391a8b: jne      0x141391a98
0000000141391a8d: movzx    r9d, word ptr [rcx + 4]
0000000141391a92: shl      r9, 2
0000000141391a96: jmp      0x141391a9e
0000000141391a98: test     al, al
0000000141391a9a: cmove    r9, rdi
0000000141391a9e: test     r8d, 0x6000000
0000000141391aa5: lea      rax, [r11 + r9]
0000000141391aa9: cmove    rax, rdi
0000000141391aad: mov      qword ptr [rcx + 0x78], rax
0000000141391ab1: mov      rbx, qword ptr [rsp + 8]
0000000141391ab6: mov      rdi, qword ptr [rsp + 0x10]
0000000141391abb: ret      
0000000141391abc: int3     
0000000141391abd: int3     
0000000141391abe: int3     
0000000141391abf: int3     
0000000141391ac0: xor      eax, eax
0000000141391ac2: mov      qword ptr [rcx + 0x18], rax
0000000141391ac6: mov      qword ptr [rcx + 0x20], rax
0000000141391aca: mov      qword ptr [rcx + 0x28], rax
0000000141391ace: mov      qword ptr [rcx + 0x30], rax
0000000141391ad2: mov      qword ptr [rcx + 0x38], rax
0000000141391ad6: mov      qword ptr [rcx + 0x40], rax
0000000141391ada: mov      qword ptr [rcx + 0x48], rax
0000000141391ade: mov      qword ptr [rcx + 0x50], rax
0000000141391ae2: mov      qword ptr [rcx + 0x58], rax
0000000141391ae6: mov      qword ptr [rcx + 0x60], rax
0000000141391aea: mov      qword ptr [rcx + 0x68], rax
0000000141391aee: mov      qword ptr [rcx + 0x70], rax
0000000141391af2: mov      qword ptr [rcx + 0x78], rax
0000000141391af6: ret      
0000000141391af7: int3     
0000000141391af8: int3     
0000000141391af9: int3     
0000000141391afa: int3     
0000000141391afb: int3     
0000000141391afc: int3     
0000000141391afd: int3     
0000000141391afe: int3     
0000000141391aff: int3     
0000000141391b00: xor      eax, eax
0000000141391b02: mov      qword ptr [rcx], rax
0000000141391b05: mov      qword ptr [rcx + 8], rax
0000000141391b09: mov      qword ptr [rcx + 0x10], rax
0000000141391b0d: mov      rax, rcx
0000000141391b10: ret      
0000000141391b11: int3     
0000000141391b12: int3     
0000000141391b13: int3     
0000000141391b14: int3     
0000000141391b15: int3     
0000000141391b16: int3     
0000000141391b17: int3     
0000000141391b18: int3     
0000000141391b19: int3     
0000000141391b1a: int3     
0000000141391b1b: int3     
0000000141391b1c: int3     
0000000141391b1d: int3     
0000000141391b1e: int3     
0000000141391b1f: int3     
0000000141391b20: xor      eax, eax
0000000141391b22: mov      qword ptr [rcx], rax
0000000141391b25: mov      qword ptr [rcx + 8], rax
0000000141391b29: mov      qword ptr [rcx + 0x10], rax
0000000141391b2d: ret      
0000000141391b2e: int3     
0000000141391b2f: int3     
0000000141391b30: cmp      dword ptr [rcx + 0x10], edx
0000000141391b33: lea      rax, [rcx + 0x10]
0000000141391b37: ja       0x141391b4f
0000000141391b39: nop      dword ptr [rax]
0000000141391b40: mov      rcx, rax
0000000141391b43: add      rax, 0x10
0000000141391b47: cmp      dword ptr [rax], edx
0000000141391b49: jbe      0x141391b40
0000000141391b4b: mov      rax, rcx
0000000141391b4e: ret      
0000000141391b4f: cmp      dword ptr [rcx], edx
0000000141391b51: jbe      0x141391b5b
0000000141391b53: sub      rcx, 0x10
0000000141391b57: cmp      dword ptr [rcx], edx
0000000141391b59: ja       0x141391b53
0000000141391b5b: mov      rax, rcx
0000000141391b5e: ret      
0000000141391b5f: int3     
0000000141391b60: mov      r9, qword ptr [rcx + 0x20]
0000000141391b64: cmp      dword ptr [r9 + 0x10], r8d
0000000141391b68: lea      rax, [r9 + 0x10]
0000000141391b6c: ja       0x141391b7e
0000000141391b6e: nop      
0000000141391b70: mov      r9, rax
0000000141391b73: add      rax, 0x10
0000000141391b77: cmp      dword ptr [rax], r8d
0000000141391b7a: jbe      0x141391b70
0000000141391b7c: jmp      0x141391b8c
0000000141391b7e: cmp      dword ptr [r9], r8d
0000000141391b81: jbe      0x141391b8c
0000000141391b83: sub      r9, 0x10
0000000141391b87: cmp      dword ptr [r9], r8d
0000000141391b8a: ja       0x141391b83
0000000141391b8c: movss    xmm3, dword ptr [rip + 0x3cfa4c]
0000000141391b94: xorps    xmm4, xmm4
0000000141391b97: mov      qword ptr [rcx + 0x20], r9
0000000141391b9b: xorps    xmm0, xmm0
0000000141391b9e: sub      r8d, dword ptr [r9]
0000000141391ba1: mov      eax, r8d
0000000141391ba4: cvtsi2ss xmm4, rax
0000000141391ba9: mov      eax, dword ptr [r9 + 0x10]
0000000141391bad: sub      eax, dword ptr [r9]
0000000141391bb0: cvtsi2ss xmm0, rax
0000000141391bb5: divss    xmm4, xmm0
0000000141391bb9: subss    xmm3, xmm4
0000000141391bbd: movaps   xmm0, xmm4
0000000141391bc0: mulss    xmm0, dword ptr [r9 + 0x14]
0000000141391bc6: movaps   xmm1, xmm3
0000000141391bc9: movaps   xmm2, xmm3
0000000141391bcc: mulss    xmm1, dword ptr [r9 + 4]
0000000141391bd2: addss    xmm1, xmm0
0000000141391bd6: movaps   xmm0, xmm4
0000000141391bd9: movss    dword ptr [rdx], xmm1
0000000141391bdd: mulss    xmm2, dword ptr [r9 + 8]
0000000141391be3: mulss    xmm0, dword ptr [r9 + 0x18]
0000000141391be9: addss    xmm2, xmm0
0000000141391bed: movss    dword ptr [rdx + 4], xmm2
0000000141391bf2: mulss    xmm3, dword ptr [r9 + 0xc]
0000000141391bf8: mulss    xmm4, dword ptr [r9 + 0x1c]
0000000141391bfe: addss    xmm3, xmm4
0000000141391c02: movss    dword ptr [rdx + 8], xmm3
0000000141391c07: ret      
0000000141391c08: int3     
0000000141391c09: int3     
0000000141391c0a: int3     
0000000141391c0b: int3     
0000000141391c0c: int3     
0000000141391c0d: int3     
0000000141391c0e: int3     
0000000141391c0f: int3     
0000000141391c10: mov      qword ptr [rsp + 8], rbx
0000000141391c15: push     rdi
0000000141391c16: sub      rsp, 0x60
0000000141391c1a: mov      r9, qword ptr [rcx + 0x20]
0000000141391c1e: mov      rdi, rdx
0000000141391c21: lea      rax, [r9 + 0x10]
0000000141391c25: movaps   xmmword ptr [rsp + 0x50], xmm6
0000000141391c2a: mov      rbx, rcx
0000000141391c2d: cmp      dword ptr [rax], r8d
0000000141391c30: ja       0x141391c40
0000000141391c32: mov      r9, rax
0000000141391c35: add      rax, 0x10
0000000141391c39: cmp      dword ptr [rax], r8d
0000000141391c3c: jbe      0x141391c32
0000000141391c3e: jmp      0x141391c4e
0000000141391c40: cmp      dword ptr [r9], r8d
0000000141391c43: jbe      0x141391c4e
0000000141391c45: sub      r9, 0x10
0000000141391c49: cmp      dword ptr [r9], r8d
0000000141391c4c: ja       0x141391c45
0000000141391c4e: mov      qword ptr [rcx + 0x20], r9
0000000141391c52: xorps    xmm6, xmm6
0000000141391c55: sub      r8d, dword ptr [r9]
0000000141391c58: lea      rcx, [rsp + 0x30]
0000000141391c5d: movss    xmm3, dword ptr [r9 + 0xc]
0000000141391c63: xorps    xmm0, xmm0
0000000141391c66: movss    xmm2, dword ptr [r9 + 8]
0000000141391c6c: movss    xmm1, dword ptr [r9 + 4]
0000000141391c72: mov      eax, r8d
0000000141391c75: cvtsi2ss xmm6, rax
0000000141391c7a: mov      eax, dword ptr [r9 + 0x10]
0000000141391c7e: sub      eax, dword ptr [r9]
0000000141391c81: cvtsi2ss xmm0, rax
0000000141391c86: divss    xmm6, xmm0
0000000141391c8a: call     0x1411ab440
0000000141391c8f: mov      rax, qword ptr [rbx + 0x20]
0000000141391c93: lea      rcx, [rsp + 0x20]
0000000141391c98: movss    xmm3, dword ptr [rax + 0x1c]
0000000141391c9d: movss    xmm2, dword ptr [rax + 0x18]
0000000141391ca2: movss    xmm1, dword ptr [rax + 0x14]
0000000141391ca7: call     0x1411ab440
0000000141391cac: movaps   xmm3, xmm6
0000000141391caf: lea      r8, [rsp + 0x20]
0000000141391cb4: lea      rdx, [rsp + 0x30]
0000000141391cb9: lea      rcx, [rsp + 0x40]
0000000141391cbe: call     0x1411ac910
0000000141391cc3: mov      rbx, qword ptr [rsp + 0x70]
0000000141391cc8: movaps   xmm6, xmmword ptr [rsp + 0x50]
0000000141391ccd: movsd    xmm0, qword ptr [rax]
0000000141391cd1: mov      ecx, dword ptr [rax + 8]
0000000141391cd4: movsd    qword ptr [rdi], xmm0
0000000141391cd8: mov      dword ptr [rdi + 8], ecx
0000000141391cdb: add      rsp, 0x60
0000000141391cdf: pop      rdi
0000000141391ce0: ret      
0000000141391ce1: int3     
0000000141391ce2: int3     
0000000141391ce3: int3     
0000000141391ce4: int3     
0000000141391ce5: int3     
0000000141391ce6: int3     
0000000141391ce7: int3     
0000000141391ce8: int3     
0000000141391ce9: int3     
0000000141391cea: int3     
0000000141391ceb: int3     
0000000141391cec: int3     
0000000141391ced: int3     
0000000141391cee: int3     
0000000141391cef: int3     
0000000141391cf0: cmp      dword ptr [rcx + 0x14], edx
0000000141391cf3: lea      rax, [rcx + 0x14]
0000000141391cf7: ja       0x141391d0f
0000000141391cf9: nop      dword ptr [rax]
0000000141391d00: mov      rcx, rax
0000000141391d03: add      rax, 0x14
0000000141391d07: cmp      dword ptr [rax], edx
0000000141391d09: jbe      0x141391d00
0000000141391d0b: mov      rax, rcx
0000000141391d0e: ret      
0000000141391d0f: cmp      dword ptr [rcx], edx
0000000141391d11: jbe      0x141391d1b
0000000141391d13: sub      rcx, 0x14
0000000141391d17: cmp      dword ptr [rcx], edx
0000000141391d19: ja       0x141391d13
0000000141391d1b: mov      rax, rcx
0000000141391d1e: ret      
0000000141391d1f: int3     
0000000141391d20: xor      eax, eax
0000000141391d22: mov      qword ptr [rcx + 0x18], rdx
0000000141391d26: mov      word ptr [rcx + 8], ax
0000000141391d2a: mov      qword ptr [rcx + 0xc], rax
0000000141391d2e: lea      rax, [rip + 0x80e40b]
0000000141391d35: mov      qword ptr [rcx], rax
0000000141391d38: mov      rax, rcx
0000000141391d3b: mov      qword ptr [rcx + 0x20], rdx
0000000141391d3f: ret      
0000000141391d40: lea      rax, [rip + 0x80e2a9]
0000000141391d47: mov      qword ptr [rcx], rax
0000000141391d4a: ret      
0000000141391d4b: int3     
0000000141391d4c: int3     
0000000141391d4d: int3     
0000000141391d4e: int3     
0000000141391d4f: int3     
0000000141391d50: push     rbx
0000000141391d52: push     rsi
0000000141391d53: push     rdi
0000000141391d54: sub      rsp, 0x40
0000000141391d58: mov      rax, qword ptr [rip + 0xd54669]
0000000141391d5f: xor      rax, rsp
0000000141391d62: mov      qword ptr [rsp + 0x30], rax
0000000141391d67: mov      rbx, rcx
0000000141391d6a: mov      edi, r8d
0000000141391d6d: lea      rcx, [rsp + 0x20]
0000000141391d72: mov      rsi, rdx
0000000141391d75: call     0x1412aa0a0
0000000141391d7a: mov      rax, qword ptr [rbx]
0000000141391d7d: lea      rdx, [rsp + 0x20]
0000000141391d82: mov      r8d, edi
0000000141391d85: mov      rcx, rbx
0000000141391d88: call     qword ptr [rax + 0x30]
0000000141391d8b: lea      rdx, [rsp + 0x20]
0000000141391d90: mov      rcx, rsi
0000000141391d93: call     0x14127e760
0000000141391d98: mov      rcx, qword ptr [rsp + 0x30]
0000000141391d9d: xor      rcx, rsp
0000000141391da0: call     0x141441dc0
0000000141391da5: add      rsp, 0x40
0000000141391da9: pop      rdi
0000000141391daa: pop      rsi
0000000141391dab: pop      rbx
0000000141391dac: ret      
0000000141391dad: int3     
0000000141391dae: int3     
0000000141391daf: int3     
0000000141391db0: mov      qword ptr [rsp + 0x20], rbx
0000000141391db5: push     rdi
0000000141391db6: sub      rsp, 0x80
0000000141391dbd: movaps   xmmword ptr [rsp + 0x70], xmm6
0000000141391dc2: mov      rax, qword ptr [rip + 0xd545ff]
0000000141391dc9: xor      rax, rsp
0000000141391dcc: mov      qword ptr [rsp + 0x60], rax
0000000141391dd1: mov      rbx, qword ptr [rcx + 0x20]
0000000141391dd5: mov      rdi, rdx
0000000141391dd8: cmp      dword ptr [rbx + 0x14], r8d
0000000141391ddc: lea      rax, [rbx + 0x14]
0000000141391de0: ja       0x141391df0
0000000141391de2: mov      rbx, rax
0000000141391de5: add      rax, 0x14
0000000141391de9: cmp      dword ptr [rax], r8d
0000000141391dec: jbe      0x141391de2
0000000141391dee: jmp      0x141391dfe
0000000141391df0: cmp      dword ptr [rbx], r8d
0000000141391df3: jbe      0x141391dfe
0000000141391df5: sub      rbx, 0x14
0000000141391df9: cmp      dword ptr [rbx], r8d
0000000141391dfc: ja       0x141391df5
0000000141391dfe: movss    xmm1, dword ptr [rbx + 4]
0000000141391e03: xorps    xmm0, xmm0
0000000141391e06: mov      qword ptr [rcx + 0x20], rbx
0000000141391e0a: xorps    xmm6, xmm6
0000000141391e0d: sub      r8d, dword ptr [rbx]
0000000141391e10: lea      rcx, [rsp + 0x40]
0000000141391e15: mov      eax, r8d
0000000141391e18: cvtsi2ss xmm6, rax
0000000141391e1d: mov      eax, dword ptr [rbx + 0x14]
0000000141391e20: sub      eax, dword ptr [rbx]
0000000141391e22: movss    dword ptr [rsp + 0x20], xmm1
0000000141391e28: cvtsi2ss xmm0, rax
0000000141391e2d: divss    xmm6, xmm0
0000000141391e31: movss    xmm0, dword ptr [rbx + 8]
0000000141391e36: movss    dword ptr [rsp + 0x24], xmm0
0000000141391e3c: movss    xmm1, dword ptr [rbx + 0xc]
0000000141391e41: movss    dword ptr [rsp + 0x28], xmm1
0000000141391e47: movss    xmm0, dword ptr [rbx + 0x10]
0000000141391e4c: movss    dword ptr [rsp + 0x2c], xmm0
0000000141391e52: call     0x1412aa0a0
0000000141391e57: lea      rdx, [rsp + 0x20]
0000000141391e5c: lea      rcx, [rsp + 0x40]
0000000141391e61: call     0x1412ab8b0
0000000141391e66: movss    xmm0, dword ptr [rbx + 0x18]
0000000141391e6b: lea      rcx, [rsp + 0x30]
0000000141391e70: movss    dword ptr [rsp + 0x20], xmm0
0000000141391e76: movss    xmm1, dword ptr [rbx + 0x1c]
0000000141391e7b: movss    dword ptr [rsp + 0x24], xmm1
0000000141391e81: movss    xmm0, dword ptr [rbx + 0x20]
0000000141391e86: movss    dword ptr [rsp + 0x28], xmm0
0000000141391e8c: movss    xmm1, dword ptr [rbx + 0x24]
0000000141391e91: movss    dword ptr [rsp + 0x2c], xmm1
0000000141391e97: call     0x1412aa0a0
0000000141391e9c: lea      rdx, [rsp + 0x20]
0000000141391ea1: lea      rcx, [rsp + 0x30]
0000000141391ea6: call     0x1412ab8b0
0000000141391eab: movaps   xmm3, xmm6
0000000141391eae: lea      r8, [rsp + 0x30]
0000000141391eb3: lea      rdx, [rsp + 0x50]
0000000141391eb8: lea      rcx, [rsp + 0x40]
0000000141391ebd: call     0x1412ab9c0
0000000141391ec2: movups   xmm0, xmmword ptr [rax]
0000000141391ec5: movups   xmmword ptr [rdi], xmm0
0000000141391ec8: mov      rcx, qword ptr [rsp + 0x60]
0000000141391ecd: xor      rcx, rsp
0000000141391ed0: call     0x141441dc0
0000000141391ed5: mov      rbx, qword ptr [rsp + 0xa8]
0000000141391edd: movaps   xmm6, xmmword ptr [rsp + 0x70]
0000000141391ee2: add      rsp, 0x80
0000000141391ee9: pop      rdi
0000000141391eea: ret      
0000000141391eeb: int3     
0000000141391eec: int3     
0000000141391eed: int3     
0000000141391eee: int3     
0000000141391eef: int3     
0000000141391ef0: mov      qword ptr [rsp + 0x10], rbx
0000000141391ef5: mov      qword ptr [rsp + 0x18], rbp
0000000141391efa: mov      qword ptr [rsp + 0x20], rsi
0000000141391eff: push     rdi
0000000141391f00: sub      rsp, 0x50
0000000141391f04: mov      rax, qword ptr [rip + 0xd544bd]
0000000141391f0b: xor      rax, rsp
0000000141391f0e: mov      qword ptr [rsp + 0x40], rax
0000000141391f13: xor      esi, esi
0000000141391f15: mov      rbp, rcx
0000000141391f18: cmp      si, word ptr [rcx + 8]
0000000141391f1c: jae      0x141391f74
0000000141391f1e: nop      
0000000141391f20: mov      rbx, qword ptr [rbp + 0x18]
0000000141391f24: lea      rcx, [rsp + 0x30]
0000000141391f29: movzx    eax, si
0000000141391f2c: lea      rdi, [rax + rax*4]
0000000141391f30: call     0x1412aa0a0
0000000141391f35: movss    xmm0, dword ptr [rbx + rdi*4 + 0x10]
0000000141391f3b: lea      rcx, [rsp + 0x30]
0000000141391f40: movss    xmm3, dword ptr [rbx + rdi*4 + 0xc]
0000000141391f46: movss    xmm2, dword ptr [rbx + rdi*4 + 8]
0000000141391f4c: movss    xmm1, dword ptr [rbx + rdi*4 + 4]
0000000141391f52: movss    dword ptr [rsp + 0x20], xmm0
0000000141391f58: call     0x1412ab7f0
0000000141391f5d: lea      rcx, [rsp + 0x30]
0000000141391f62: call     0x1412aad00
0000000141391f67: test     al, al
0000000141391f69: je       0x141391f9b
0000000141391f6b: inc      si
0000000141391f6e: cmp      si, word ptr [rbp + 8]
0000000141391f72: jb       0x141391f20
0000000141391f74: mov      eax, 1
0000000141391f79: mov      rcx, qword ptr [rsp + 0x40]
0000000141391f7e: xor      rcx, rsp
0000000141391f81: call     0x141441dc0
0000000141391f86: mov      rbx, qword ptr [rsp + 0x68]
0000000141391f8b: mov      rbp, qword ptr [rsp + 0x70]
0000000141391f90: mov      rsi, qword ptr [rsp + 0x78]
0000000141391f95: add      rsp, 0x50
0000000141391f99: pop      rdi
0000000141391f9a: ret      
0000000141391f9b: xor      eax, eax
0000000141391f9d: jmp      0x141391f79
0000000141391f9f: int3     
0000000141391fa0: mov      qword ptr [rsp + 0x20], rbp
0000000141391fa5: push     rsi
0000000141391fa6: sub      rsp, 0x50
0000000141391faa: mov      rax, qword ptr [rip + 0xd54417]
0000000141391fb1: xor      rax, rsp
0000000141391fb4: mov      qword ptr [rsp + 0x40], rax
0000000141391fb9: xor      esi, esi
0000000141391fbb: mov      rbp, rcx
0000000141391fbe: cmp      si, word ptr [rcx + 8]
0000000141391fc2: jae      0x14139206a
0000000141391fc8: mov      qword ptr [rsp + 0x68], rbx
0000000141391fcd: mov      qword ptr [rsp + 0x70], rdi
0000000141391fd2: nop      dword ptr [rax]
0000000141391fd6: nop      word ptr [rax + rax]
0000000141391fe0: mov      rbx, qword ptr [rbp + 0x18]
0000000141391fe4: lea      rcx, [rsp + 0x30]
0000000141391fe9: movzx    eax, si
0000000141391fec: lea      rdi, [rax + rax*4]
0000000141391ff0: call     0x1412aa0a0
0000000141391ff5: movss    xmm0, dword ptr [rbx + rdi*4 + 0x10]
0000000141391ffb: lea      rcx, [rsp + 0x30]
