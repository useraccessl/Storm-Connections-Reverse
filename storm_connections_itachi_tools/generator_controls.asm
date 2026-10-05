000000014131bf40: mov      ebx, dword ptr [rsp + 0x70]
000000014131bf44: movaps   xmm6, xmmword ptr [rsp + 0x30]
000000014131bf49: movss    dword ptr [rax + 0x5c], xmm7
000000014131bf4e: mov      eax, esi
000000014131bf50: movaps   xmm7, xmmword ptr [rsp + 0x20]
000000014131bf55: add      rsp, 0x40
000000014131bf59: pop      r14
000000014131bf5b: pop      rdi
000000014131bf5c: pop      rsi
000000014131bf5d: ret      
000000014131bf5e: int3     
000000014131bf5f: int3     
000000014131bf60: mov      qword ptr [rsp + 8], rbx
000000014131bf65: push     rdi
000000014131bf66: sub      rsp, 0x20
000000014131bf6a: mov      rbx, qword ptr [rcx + 0x180]
000000014131bf71: mov      rdi, rcx
000000014131bf74: test     rbx, rbx
000000014131bf77: je       0x14131bf91
000000014131bf79: nop      dword ptr [rax]
000000014131bf80: mov      rcx, rbx
000000014131bf83: call     0x141387ca0
000000014131bf88: mov      rbx, qword ptr [rbx + 0x30]
000000014131bf8c: test     rbx, rbx
000000014131bf8f: jne      0x14131bf80
000000014131bf91: mov      rbx, qword ptr [rdi + 0x228]
000000014131bf98: test     rbx, rbx
000000014131bf9b: je       0x14131bfb1
000000014131bf9d: nop      dword ptr [rax]
000000014131bfa0: mov      rcx, rbx
000000014131bfa3: call     0x141387ca0
000000014131bfa8: mov      rbx, qword ptr [rbx + 0x30]
000000014131bfac: test     rbx, rbx
000000014131bfaf: jne      0x14131bfa0
000000014131bfb1: xor      ebx, ebx
000000014131bfb3: cmp      dword ptr [rdi + 0x74], ebx
000000014131bfb6: jne      0x14131bfbb
000000014131bfb8: mov      dword ptr [rdi + 0x70], ebx
000000014131bfbb: mov      rax, qword ptr [rdi + 0x98]
000000014131bfc2: test     rax, rax
000000014131bfc5: je       0x14131bff2
000000014131bfc7: test     byte ptr [rax + 6], 4
000000014131bfcb: je       0x14131bff2
000000014131bfcd: call     0x1400b07c0
000000014131bfd2: lea      rcx, [rdi + 0xa8]
000000014131bfd9: mov      rdx, qword ptr [rcx]
000000014131bfdc: cmp      dword ptr [rax + 0x114], ebx
000000014131bfe2: je       0x14131bfec
000000014131bfe4: call     qword ptr [rdx + 0xd0]
000000014131bfea: jmp      0x14131bff2
000000014131bfec: call     qword ptr [rdx + 0xc8]
000000014131bff2: mov      qword ptr [rdi + 0x248], rbx
000000014131bff9: mov      rbx, qword ptr [rsp + 0x30]
000000014131bffe: mov      dword ptr [rdi + 0x78], 1
000000014131c005: add      rsp, 0x20
000000014131c009: pop      rdi
000000014131c00a: ret      
000000014131c00b: int3     
000000014131c00c: int3     
000000014131c00d: int3     
000000014131c00e: int3     
000000014131c00f: int3     
000000014131c010: push     rbx
000000014131c012: sub      rsp, 0x20
000000014131c016: cmp      dword ptr [rcx + 0x74], 0
000000014131c01a: mov      rbx, rcx
000000014131c01d: jne      0x14131c026
000000014131c01f: mov      dword ptr [rcx + 0x70], 0
000000014131c026: mov      rax, qword ptr [rcx + 0x98]
000000014131c02d: test     rax, rax
000000014131c030: je       0x14131c068
000000014131c032: test     byte ptr [rax + 6], 4
000000014131c036: je       0x14131c068
000000014131c038: call     0x1400b07c0
000000014131c03d: lea      rcx, [rbx + 0xa8]
000000014131c044: mov      rdx, qword ptr [rcx]
000000014131c047: cmp      dword ptr [rax + 0x114], 0
000000014131c04e: je       0x14131c05c
000000014131c050: add      rsp, 0x20
000000014131c054: pop      rbx
000000014131c055: jmp      qword ptr [rdx + 0xd0]
000000014131c05c: add      rsp, 0x20
000000014131c060: pop      rbx
000000014131c061: jmp      qword ptr [rdx + 0xc8]
000000014131c068: add      rsp, 0x20
000000014131c06c: pop      rbx
000000014131c06d: ret      
000000014131c06e: int3     
000000014131c06f: int3     
000000014131c070: mov      qword ptr [rsp + 8], rbx
000000014131c075: push     rdi
000000014131c076: sub      rsp, 0x20
000000014131c07a: mov      rax, qword ptr [rcx]
000000014131c07d: mov      rdi, rcx
000000014131c080: call     qword ptr [rax + 0x58]
000000014131c083: mov      rax, qword ptr [rdi + 0xa8]
000000014131c08a: lea      rcx, [rdi + 0xa8]
000000014131c091: call     qword ptr [rax + 0xc8]
000000014131c097: mov      rax, qword ptr [rdi + 0xa8]
000000014131c09e: lea      rcx, [rdi + 0xa8]
000000014131c0a5: call     qword ptr [rax + 0x48]
000000014131c0a8: mov      rbx, qword ptr [rsp + 0x30]
000000014131c0ad: xor      eax, eax
000000014131c0af: mov      qword ptr [rdi + 0x248], rax
000000014131c0b6: mov      qword ptr [rdi + 0xa0], rax
000000014131c0bd: add      rsp, 0x20
000000014131c0c1: pop      rdi
000000014131c0c2: ret      
000000014131c0c3: int3     
000000014131c0c4: int3     
000000014131c0c5: int3     
000000014131c0c6: int3     
000000014131c0c7: int3     
000000014131c0c8: int3     
000000014131c0c9: int3     
000000014131c0ca: int3     
000000014131c0cb: int3     
000000014131c0cc: int3     
000000014131c0cd: int3     
000000014131c0ce: int3     
000000014131c0cf: int3     
000000014131c0d0: sub      rsp, 0x28
000000014131c0d4: cmp      dword ptr [rcx + 0x80], 0
000000014131c0db: jne      0x14131c0ea
000000014131c0dd: add      rcx, 0xa8
000000014131c0e4: mov      rax, qword ptr [rcx]
000000014131c0e7: call     qword ptr [rax + 0x40]
000000014131c0ea: mov      eax, 1
000000014131c0ef: add      rsp, 0x28
000000014131c0f3: ret      
000000014131c0f4: int3     
000000014131c0f5: int3     
000000014131c0f6: int3     
000000014131c0f7: int3     
000000014131c0f8: int3     
000000014131c0f9: int3     
000000014131c0fa: int3     
000000014131c0fb: int3     
000000014131c0fc: int3     
000000014131c0fd: int3     
000000014131c0fe: int3     
000000014131c0ff: int3     
000000014131c100: mov      qword ptr [rsp + 8], rbx
000000014131c105: mov      qword ptr [rsp + 0x10], rsi
000000014131c10a: mov      qword ptr [rsp + 0x18], rdi
000000014131c10f: push     r14
000000014131c111: sub      rsp, 0x20
000000014131c115: mov      rsi, rcx
000000014131c118: mov      rbx, qword ptr [rcx + 0x228]
000000014131c11f: test     rbx, rbx
000000014131c122: je       0x14131c1ab
000000014131c128: mov      eax, dword ptr [rip + 0x8436ae2]
000000014131c12e: lea      rdi, [rax*8]
000000014131c136: mov      r14d, 0x3428
000000014131c13c: nop      dword ptr [rax]
000000014131c140: mov      rax, qword ptr gs:[0x58]
000000014131c149: mov      rcx, qword ptr [rax + rdi]
000000014131c14d: mov      eax, dword ptr [r14 + rcx]
000000014131c151: cmp      dword ptr [rip + 0xe4b6f1], eax
000000014131c157: jle      0x14131c193
000000014131c159: lea      rcx, [rip + 0xe4b6e8]
000000014131c160: call     0x141441c00
000000014131c165: cmp      dword ptr [rip + 0xe4b6dc], -1
000000014131c16c: jne      0x14131c193
000000014131c16e: lea      rcx, [rip + 0xe4b5ab]
000000014131c175: call     0x141274bd0
000000014131c17a: lea      rcx, [rip + 0x40decf]
000000014131c181: call     0x1414419a8
000000014131c186: nop      
000000014131c187: lea      rcx, [rip + 0xe4b6ba]
000000014131c18e: call     0x141441ba0
000000014131c193: mov      rdx, rbx
000000014131c196: lea      rcx, [rip + 0xe4b583]
000000014131c19d: call     0x141278d70
000000014131c1a2: mov      rbx, qword ptr [rbx + 0x30]
000000014131c1a6: test     rbx, rbx
000000014131c1a9: jne      0x14131c140
000000014131c1ab: mov      rax, qword ptr [rsi + 0x150]
000000014131c1b2: lea      rcx, [rsi + 0x150]
000000014131c1b9: call     qword ptr [rax + 0xc8]
000000014131c1bf: mov      rax, qword ptr [rsi + 0x150]
000000014131c1c6: lea      rcx, [rsi + 0x150]
000000014131c1cd: call     qword ptr [rax + 0x48]
000000014131c1d0: mov      rax, qword ptr [rsi + 0x1a8]
000000014131c1d7: lea      rcx, [rsi + 0x1a8]
000000014131c1de: call     qword ptr [rax + 0xc8]
000000014131c1e4: mov      rax, qword ptr [rsi + 0x1a8]
000000014131c1eb: lea      rcx, [rsi + 0x1a8]
000000014131c1f2: call     qword ptr [rax + 0x48]
000000014131c1f5: mov      rax, qword ptr [rsi + 0x1f8]
000000014131c1fc: lea      rcx, [rsi + 0x1f8]
000000014131c203: call     qword ptr [rax + 0xc8]
000000014131c209: mov      rax, qword ptr [rsi + 0x1f8]
000000014131c210: lea      rcx, [rsi + 0x1f8]
000000014131c217: call     qword ptr [rax + 0x48]
000000014131c21a: mov      rax, qword ptr [rsi + 0xa8]
000000014131c221: lea      rcx, [rsi + 0xa8]
000000014131c228: call     qword ptr [rax + 0xc8]
000000014131c22e: mov      rax, qword ptr [rsi + 0xa8]
000000014131c235: lea      rcx, [rsi + 0xa8]
000000014131c23c: call     qword ptr [rax + 0x48]
000000014131c23f: mov      qword ptr [rsi + 0xa0], 0
000000014131c24a: mov      rbx, qword ptr [rsp + 0x30]
000000014131c24f: mov      rsi, qword ptr [rsp + 0x38]
000000014131c254: mov      rdi, qword ptr [rsp + 0x40]
000000014131c259: add      rsp, 0x20
000000014131c25d: pop      r14
000000014131c25f: ret      
000000014131c260: mov      eax, dword ptr [rcx + 0xf0]
000000014131c266: ret      
000000014131c267: int3     
000000014131c268: int3     
000000014131c269: int3     
000000014131c26a: int3     
000000014131c26b: int3     
000000014131c26c: int3     
000000014131c26d: int3     
000000014131c26e: int3     
000000014131c26f: int3     
000000014131c270: add      rcx, 0x1f8
000000014131c277: jmp      0x141308b30
000000014131c27c: int3     
000000014131c27d: int3     
000000014131c27e: int3     
000000014131c27f: int3     
000000014131c280: add      rcx, 0xa8
000000014131c287: mov      rax, qword ptr [rcx]
000000014131c28a: jmp      qword ptr [rax + 0xa8]
000000014131c291: int3     
000000014131c292: int3     
000000014131c293: int3     
000000014131c294: int3     
000000014131c295: int3     
000000014131c296: int3     
000000014131c297: int3     
000000014131c298: int3     
000000014131c299: int3     
000000014131c29a: int3     
000000014131c29b: int3     
000000014131c29c: int3     
000000014131c29d: int3     
000000014131c29e: int3     
000000014131c29f: int3     
000000014131c2a0: add      rcx, 0x150
000000014131c2a7: jmp      0x141308b30
000000014131c2ac: int3     
000000014131c2ad: int3     
000000014131c2ae: int3     
000000014131c2af: int3     
000000014131c2b0: movss    xmm0, dword ptr [rcx + 0x90]
000000014131c2b8: ret      
000000014131c2b9: int3     
000000014131c2ba: int3     
000000014131c2bb: int3     
000000014131c2bc: int3     
000000014131c2bd: int3     
000000014131c2be: int3     
000000014131c2bf: int3     
000000014131c2c0: add      rcx, 0x1f8
000000014131c2c7: jmp      0x141309e30
000000014131c2cc: int3     
000000014131c2cd: int3     
000000014131c2ce: int3     
000000014131c2cf: int3     
000000014131c2d0: add      rcx, 0x150
000000014131c2d7: jmp      0x141309e30
000000014131c2dc: int3     
000000014131c2dd: int3     
000000014131c2de: int3     
000000014131c2df: int3     
000000014131c2e0: add      rcx, 0x1a8
000000014131c2e7: jmp      0x141309e30
000000014131c2ec: int3     
000000014131c2ed: int3     
000000014131c2ee: int3     
000000014131c2ef: int3     
000000014131c2f0: mov      rdx, qword ptr [rcx + 0xa0]
000000014131c2f7: xor      eax, eax
000000014131c2f9: test     rdx, rdx
000000014131c2fc: je       0x14131c30d
000000014131c2fe: mov      ecx, dword ptr [rcx + 0x54]
000000014131c301: mov      r8d, 1
000000014131c307: cmp      dword ptr [rdx], ecx
000000014131c309: cmove    eax, r8d
000000014131c30d: ret      
000000014131c30e: int3     
000000014131c30f: int3     
000000014131c310: push     rbx
000000014131c312: sub      rsp, 0x20
000000014131c316: mov      rbx, rcx
000000014131c319: call     0x1400b07c0
000000014131c31e: cmp      dword ptr [rax + 0x114], 0
000000014131c325: je       0x14131c36d
000000014131c327: lea      rcx, [rbx + 0x150]
000000014131c32e: mov      rax, qword ptr [rcx]
000000014131c331: call     qword ptr [rax + 0xd0]
000000014131c337: lea      rcx, [rbx + 0x1a8]
000000014131c33e: mov      rax, qword ptr [rcx]
000000014131c341: call     qword ptr [rax + 0xd0]
000000014131c347: lea      rcx, [rbx + 0x1f8]
000000014131c34e: mov      rax, qword ptr [rcx]
000000014131c351: call     qword ptr [rax + 0xd0]
000000014131c357: lea      rcx, [rbx + 0xa8]
000000014131c35e: mov      rax, qword ptr [rcx]
000000014131c361: add      rsp, 0x20
000000014131c365: pop      rbx
000000014131c366: jmp      qword ptr [rax + 0xd0]
000000014131c36d: add      rsp, 0x20
000000014131c371: pop      rbx
000000014131c372: ret      
000000014131c373: int3     
000000014131c374: int3     
000000014131c375: int3     
000000014131c376: int3     
000000014131c377: int3     
000000014131c378: int3     
000000014131c379: int3     
000000014131c37a: int3     
000000014131c37b: int3     
000000014131c37c: int3     
000000014131c37d: int3     
000000014131c37e: int3     
000000014131c37f: int3     
000000014131c380: push     rbx
000000014131c382: sub      rsp, 0x20
000000014131c386: lea      rbx, [rcx + 0x1f8]
000000014131c38d: mov      rcx, rbx
000000014131c390: call     0x141308b30
000000014131c395: test     rax, rax
000000014131c398: je       0x14131c3b0
000000014131c39a: mov      rdx, rax
000000014131c39d: mov      rcx, rbx
000000014131c3a0: call     0x1413092d0
000000014131c3a5: mov      eax, 1
000000014131c3aa: add      rsp, 0x20
000000014131c3ae: pop      rbx
000000014131c3af: ret      
000000014131c3b0: add      rsp, 0x20
000000014131c3b4: pop      rbx
000000014131c3b5: ret      
000000014131c3b6: int3     
000000014131c3b7: int3     
000000014131c3b8: int3     
000000014131c3b9: int3     
000000014131c3ba: int3     
000000014131c3bb: int3     
000000014131c3bc: int3     
000000014131c3bd: int3     
000000014131c3be: int3     
000000014131c3bf: int3     
000000014131c3c0: push     rbx
000000014131c3c2: sub      rsp, 0x20
000000014131c3c6: lea      rbx, [rcx + 0x150]
000000014131c3cd: mov      rcx, rbx
000000014131c3d0: call     0x141308b30
000000014131c3d5: test     rax, rax
000000014131c3d8: je       0x14131c3f0
000000014131c3da: mov      rdx, rax
000000014131c3dd: mov      rcx, rbx
000000014131c3e0: call     0x1413092d0
000000014131c3e5: mov      eax, 1
000000014131c3ea: add      rsp, 0x20
000000014131c3ee: pop      rbx
000000014131c3ef: ret      
000000014131c3f0: add      rsp, 0x20
000000014131c3f4: pop      rbx
000000014131c3f5: ret      
000000014131c3f6: int3     
000000014131c3f7: int3     
000000014131c3f8: int3     
000000014131c3f9: int3     
000000014131c3fa: int3     
000000014131c3fb: int3     
000000014131c3fc: int3     
000000014131c3fd: int3     
000000014131c3fe: int3     
000000014131c3ff: int3     
000000014131c400: push     rbx
000000014131c402: sub      rsp, 0x20
000000014131c406: lea      rbx, [rcx + 0x1a8]
000000014131c40d: mov      rcx, rbx
000000014131c410: call     0x141308b30
000000014131c415: test     rax, rax
000000014131c418: je       0x14131c430
000000014131c41a: mov      rdx, rax
000000014131c41d: mov      rcx, rbx
000000014131c420: call     0x1413092d0
000000014131c425: mov      eax, 1
000000014131c42a: add      rsp, 0x20
000000014131c42e: pop      rbx
000000014131c42f: ret      
000000014131c430: add      rsp, 0x20
000000014131c434: pop      rbx
000000014131c435: ret      
000000014131c436: int3     
000000014131c437: int3     
000000014131c438: int3     
000000014131c439: int3     
000000014131c43a: int3     
000000014131c43b: int3     
000000014131c43c: int3     
000000014131c43d: int3     
000000014131c43e: int3     
000000014131c43f: int3     
