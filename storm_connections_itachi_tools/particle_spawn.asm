000000014131b5c0: mov      rax, rsp
000000014131b5c3: mov      qword ptr [rax + 0x10], rbx
000000014131b5c7: mov      qword ptr [rax + 0x18], rbp
000000014131b5cb: mov      qword ptr [rax + 0x20], rsi
000000014131b5cf: push     rdi
000000014131b5d0: push     r12
000000014131b5d2: push     r13
000000014131b5d4: push     r14
000000014131b5d6: push     r15
000000014131b5d8: sub      rsp, 0xd0
000000014131b5df: movaps   xmmword ptr [rax - 0x38], xmm6
000000014131b5e3: movaps   xmmword ptr [rax - 0x48], xmm7
000000014131b5e7: movaps   xmmword ptr [rax - 0x58], xmm8
000000014131b5ec: movaps   xmmword ptr [rax - 0x68], xmm10
000000014131b5f1: mov      r12d, r8d
000000014131b5f4: mov      ebx, edx
000000014131b5f6: mov      rdi, rcx
000000014131b5f9: mov      r15d, 1
000000014131b5ff: mov      r13d, dword ptr [rcx + 0x1f0]
000000014131b606: test     r13d, r13d
000000014131b609: je       0x14131ba59
000000014131b60f: lea      rcx, [rsp + 0x40]
000000014131b614: call     0x14131b3b0
000000014131b619: lea      rax, [rip + 0x880310]
000000014131b620: mov      qword ptr [rsp + 0x40], rax
000000014131b625: mov      dword ptr [rsp + 0x78], 3
000000014131b62d: mov      qword ptr [rsp + 0x88], 0
000000014131b639: mov      rcx, qword ptr [rdi + 0x1d8]
000000014131b640: mov      rax, qword ptr [rcx]
000000014131b643: lea      rdx, [rsp + 0x40]
000000014131b648: call     qword ptr [rax + 0x18]
000000014131b64b: mov      r14, qword ptr [rsp + 0x88]
000000014131b653: test     ebx, ebx
000000014131b655: jle      0x14131b960
000000014131b65b: mov      qword ptr [rsp + 0x100], rbx
000000014131b663: movss    xmm10, dword ptr [rip + 0x544edc]
000000014131b66c: movss    xmm7, dword ptr [rip + 0x464e6c]
000000014131b674: movss    xmm8, dword ptr [rip + 0x45c0a7]
000000014131b67d: nop      dword ptr [rax]
000000014131b680: cmp      r13d, 1
000000014131b684: jle      0x14131b6c7
000000014131b686: call     0x1412cd5c0
000000014131b68b: xor      edx, edx
000000014131b68d: div      r13d
000000014131b690: mov      rcx, qword ptr [rdi + 0x1d8]
000000014131b697: test     edx, edx
000000014131b699: jle      0x14131b6af
000000014131b69b: mov      eax, edx
000000014131b69d: nop      dword ptr [rax]
000000014131b6a0: test     rcx, rcx
000000014131b6a3: je       0x14131b6a9
000000014131b6a5: mov      rcx, qword ptr [rcx + 0x30]
000000014131b6a9: sub      rax, 1
000000014131b6ad: jne      0x14131b6a0
000000014131b6af: test     rcx, rcx
000000014131b6b2: je       0x14131b6bf
000000014131b6b4: mov      rax, qword ptr [rcx]
000000014131b6b7: lea      rdx, [rsp + 0x40]
000000014131b6bc: call     qword ptr [rax + 0x18]
000000014131b6bf: mov      r14, qword ptr [rsp + 0x88]
000000014131b6c7: mov      rbx, qword ptr [rdi + 0x98]
000000014131b6ce: movsx    eax, word ptr [rbx + 0x1c]
000000014131b6d2: movd     xmm6, eax
000000014131b6d6: cvtdq2ps xmm6, xmm6
000000014131b6d9: movss    xmm0, dword ptr [rbx + 0x20]
000000014131b6de: call     0x1412cd5f0
000000014131b6e3: mulss    xmm0, xmm6
000000014131b6e7: addss    xmm0, xmm6
000000014131b6eb: test     r14, r14
000000014131b6ee: je       0x14131b94e
000000014131b6f4: cvttss2si ebp, xmm0
000000014131b6f8: test     ebp, ebp
000000014131b6fa: je       0x14131b94e
000000014131b700: movzx    eax, byte ptr [rbx]
000000014131b703: test     al, al
000000014131b705: je       0x14131b72d
000000014131b707: cmp      al, 1
000000014131b709: jne      0x14131b717
000000014131b70b: mov      rax, qword ptr [rdi + 0xa0]
000000014131b712: cmp      dword ptr [rax], 0
000000014131b715: jg       0x14131b72d
000000014131b717: mov      rdx, qword ptr [rsp + 0x70]
000000014131b71c: mov      rcx, r14
000000014131b71f: call     0x1413866f0
000000014131b724: lea      rsi, [rdi + 0xa8]
000000014131b72b: jmp      0x14131b754
000000014131b72d: lea      rsi, [rdi + 0xa8]
000000014131b734: mov      rdx, r14
000000014131b737: mov      rcx, rsi
000000014131b73a: call     0x141385500
000000014131b73f: mov      rbx, rax
000000014131b742: test     rax, rax
000000014131b745: jne      0x14131b760
000000014131b747: mov      rdx, qword ptr [rsp + 0x70]
000000014131b74c: mov      rcx, r14
000000014131b74f: call     0x1413866f0
000000014131b754: mov      rbx, rax
000000014131b757: test     rax, rax
000000014131b75a: je       0x14131b94e
000000014131b760: mov      rdx, rbx
000000014131b763: mov      rcx, rsi
000000014131b766: call     0x141385440
000000014131b76b: test     eax, eax
000000014131b76d: je       0x14131b951
000000014131b773: mov      rax, qword ptr [rdi + 0x98]
000000014131b77a: movsx    ecx, byte ptr [rax + 3]
000000014131b77e: mov      dword ptr [rbx + 0x180], ecx
000000014131b784: mov      rax, qword ptr [rdi + 0x98]
000000014131b78b: movss    xmm3, dword ptr [rax + 0x40]
000000014131b790: movss    xmm2, dword ptr [rax + 0x3c]
000000014131b795: mov      edx, ebp
000000014131b797: mov      rcx, rbx
000000014131b79a: call     0x14130c350
000000014131b79f: mov      rax, qword ptr [rdi + 0x98]
000000014131b7a6: mov      ecx, dword ptr [rax + 8]
000000014131b7a9: mov      dword ptr [rbx + 0x200], ecx
000000014131b7af: mov      eax, dword ptr [rdi + 0x60]
000000014131b7b2: mov      dword ptr [rbx + 0x194], eax
000000014131b7b8: mov      edx, dword ptr [rdi + 0x64]
000000014131b7bb: mov      rcx, rbx
000000014131b7be: call     0x14130ae90
000000014131b7c3: mov      rax, qword ptr [rdi + 0x98]
000000014131b7ca: movss    xmm0, dword ptr [rax + 0x48]
000000014131b7cf: call     0x1412cd5f0
000000014131b7d4: mov      rax, qword ptr [rdi + 0x98]
000000014131b7db: addss    xmm0, dword ptr [rax + 0x44]
000000014131b7e0: movss    dword ptr [rbx + 0x208], xmm0
000000014131b7e8: mov      r15d, 1
000000014131b7ee: mov      rdx, qword ptr [rdi + 0x98]
000000014131b7f5: movsx    rax, byte ptr [rdx + 1]
000000014131b7fa: cmp      eax, 5
000000014131b7fd: ja       0x14131b82d
000000014131b7ff: lea      rsi, [rip - 0x131b806]
000000014131b806: mov      ecx, dword ptr [rsi + rax*4 + 0x131ba90]
000000014131b80d: add      rcx, rsi
000000014131b810: jmp      rcx
000000014131b812: mov      dword ptr [rsp + 0x20], r12d
000000014131b817: movss    xmm3, dword ptr [rip + 0x4875b1]
000000014131b81f: movaps   xmm2, xmm3
000000014131b822: mov      rdx, rbx
000000014131b825: mov      rcx, rdi
000000014131b828: call     0x14131c560
000000014131b82d: xorps    xmm3, xmm3
000000014131b830: xorps    xmm2, xmm2
000000014131b833: xorps    xmm1, xmm1
000000014131b836: lea      rcx, [rsp + 0x30]
000000014131b83b: call     0x1411ab440
000000014131b840: mov      rax, qword ptr [rdi + 0x98]
000000014131b847: movsx    ecx, byte ptr [rax + 4]
000000014131b84b: sub      ecx, r15d
000000014131b84e: je       0x14131b974
000000014131b854: sub      ecx, r15d
000000014131b857: je       0x14131b968
000000014131b85d: cmp      ecx, r15d
000000014131b860: jne      0x14131ba3c
000000014131b866: mov      dword ptr [rbx + 0x17c], r15d
000000014131b86d: movss    xmm0, dword ptr [rip + 0x881417]
000000014131b875: mulss    xmm0, xmm7
000000014131b879: call     0x1412cd5f0
000000014131b87e: movss    xmm2, dword ptr [rip + 0x881406]
000000014131b886: comiss   xmm0, xmm2
000000014131b889: jbe      0x14131b896
000000014131b88b: movaps   xmm1, xmm2
000000014131b88e: mulss    xmm1, xmm7
000000014131b892: subss    xmm0, xmm1
000000014131b896: movaps   xmm1, xmm2
000000014131b899: mulss    xmm1, xmm8
000000014131b89e: comiss   xmm1, xmm0
000000014131b8a1: jbe      0x14131b8ab
000000014131b8a3: mulss    xmm2, xmm7
000000014131b8a7: addss    xmm0, xmm2
000000014131b8ab: movss    dword ptr [rsp + 0x34], xmm0
000000014131b8b1: jmp      0x14131ba3c
000000014131b8b6: movss    xmm2, dword ptr [rdx + 0x14]
000000014131b8bb: comiss   xmm10, xmm2
000000014131b8bf: jbe      0x14131b8c9
000000014131b8c1: movss    xmm2, dword ptr [rip + 0x445d17]
000000014131b8c9: mov      dword ptr [rsp + 0x20], r12d
000000014131b8ce: xorps    xmm3, xmm3
000000014131b8d1: jmp      0x14131b822
000000014131b8d6: movss    xmm2, dword ptr [rdx + 0x14]
000000014131b8db: comiss   xmm10, xmm2
000000014131b8df: jbe      0x14131b8e9
000000014131b8e1: movss    xmm2, dword ptr [rip + 0x445cf7]
000000014131b8e9: mov      dword ptr [rsp + 0x20], r12d
000000014131b8ee: movaps   xmm3, xmm2
000000014131b8f1: jmp      0x14131b822
000000014131b8f6: cmp      r12d, r15d
000000014131b8f9: jle      0x14131b936
000000014131b8fb: mov      dword ptr [rsp + 0x20], 0
000000014131b903: mov      r9d, r12d
000000014131b906: movss    xmm2, dword ptr [rdx + 0x14]
000000014131b90b: mov      rdx, rbx
000000014131b90e: mov      rcx, rdi
000000014131b911: call     0x14131cbf0
000000014131b916: jmp      0x14131b82d
000000014131b91b: cmp      r12d, r15d
000000014131b91e: jle      0x14131b936
000000014131b920: mov      dword ptr [rsp + 0x20], r15d
000000014131b925: jmp      0x14131b903
000000014131b927: cmp      r12d, r15d
000000014131b92a: jle      0x14131b936
000000014131b92c: mov      dword ptr [rsp + 0x20], 2
000000014131b934: jmp      0x14131b903
000000014131b936: movss    xmm2, dword ptr [rdx + 0x14]
000000014131b93b: mov      dword ptr [rsp + 0x20], r12d
000000014131b940: movaps   xmm3, xmm2
000000014131b943: mov      rdx, rbx
000000014131b946: mov      rcx, rdi
000000014131b949: call     0x14131c560
000000014131b94e: xor      r15d, r15d
000000014131b951: sub      qword ptr [rsp + 0x100], 1
000000014131b95a: jne      0x14131b680
000000014131b960: mov      eax, r15d
000000014131b963: jmp      0x14131ba5b
000000014131b968: mov      dword ptr [rbx + 0x17c], r15d
000000014131b96f: jmp      0x14131ba3c
000000014131b974: movss    xmm0, dword ptr [rip + 0x881310]
000000014131b97c: mulss    xmm0, xmm7
000000014131b980: call     0x1412cd5f0
000000014131b985: movss    xmm2, dword ptr [rip + 0x8812ff]
000000014131b98d: comiss   xmm0, xmm2
000000014131b990: jbe      0x14131b99d
000000014131b992: movaps   xmm1, xmm2
000000014131b995: mulss    xmm1, xmm7
000000014131b999: subss    xmm0, xmm1
000000014131b99d: movaps   xmm1, xmm2
000000014131b9a0: mulss    xmm1, xmm8
000000014131b9a5: comiss   xmm1, xmm0
000000014131b9a8: jbe      0x14131b9b5
000000014131b9aa: movaps   xmm1, xmm2
000000014131b9ad: mulss    xmm1, xmm7
000000014131b9b1: addss    xmm0, xmm1
000000014131b9b5: movss    dword ptr [rsp + 0x30], xmm0
000000014131b9bb: mulss    xmm2, xmm7
000000014131b9bf: movaps   xmm0, xmm2
000000014131b9c2: call     0x1412cd5f0
000000014131b9c7: movss    xmm2, dword ptr [rip + 0x8812bd]
000000014131b9cf: comiss   xmm0, xmm2
000000014131b9d2: jbe      0x14131b9df
000000014131b9d4: movaps   xmm1, xmm2
000000014131b9d7: mulss    xmm1, xmm7
000000014131b9db: subss    xmm0, xmm1
000000014131b9df: movaps   xmm1, xmm2
000000014131b9e2: mulss    xmm1, xmm8
000000014131b9e7: comiss   xmm1, xmm0
000000014131b9ea: jbe      0x14131b9f7
000000014131b9ec: movaps   xmm1, xmm2
000000014131b9ef: mulss    xmm1, xmm7
000000014131b9f3: addss    xmm0, xmm1
000000014131b9f7: movss    dword ptr [rsp + 0x34], xmm0
000000014131b9fd: mulss    xmm2, xmm7
000000014131ba01: movaps   xmm0, xmm2
000000014131ba04: call     0x1412cd5f0
000000014131ba09: movss    xmm2, dword ptr [rip + 0x88127b]
000000014131ba11: comiss   xmm0, xmm2
000000014131ba14: jbe      0x14131ba21
000000014131ba16: movaps   xmm1, xmm2
000000014131ba19: mulss    xmm1, xmm7
000000014131ba1d: subss    xmm0, xmm1
000000014131ba21: movaps   xmm1, xmm2
000000014131ba24: mulss    xmm1, xmm8
000000014131ba29: comiss   xmm1, xmm0
000000014131ba2c: jbe      0x14131ba36
000000014131ba2e: mulss    xmm2, xmm7
000000014131ba32: addss    xmm0, xmm2
000000014131ba36: movss    dword ptr [rsp + 0x38], xmm0
000000014131ba3c: lea      rdx, [rsp + 0x30]
000000014131ba41: mov      rcx, rbx
000000014131ba44: call     0x14130c430
000000014131ba49: mov      rdx, rbx
000000014131ba4c: mov      rcx, rdi
000000014131ba4f: call     0x14131d460
000000014131ba54: jmp      0x14131b951
000000014131ba59: xor      eax, eax
000000014131ba5b: lea      r11, [rsp + 0xd0]
000000014131ba63: mov      rbx, qword ptr [r11 + 0x38]
000000014131ba67: mov      rbp, qword ptr [r11 + 0x40]
000000014131ba6b: mov      rsi, qword ptr [r11 + 0x48]
000000014131ba6f: movaps   xmm6, xmmword ptr [r11 - 0x10]
000000014131ba74: movaps   xmm7, xmmword ptr [r11 - 0x20]
000000014131ba79: movaps   xmm8, xmmword ptr [r11 - 0x30]
000000014131ba7e: movaps   xmm10, xmmword ptr [r11 - 0x40]
000000014131ba83: mov      rsp, r11
000000014131ba86: pop      r15
000000014131ba88: pop      r14
000000014131ba8a: pop      r13
000000014131ba8c: pop      r12
000000014131ba8e: pop      rdi
000000014131ba8f: ret      
000000014131ba90: adc      bh, byte ptr [rax - 0x4749fecf]
000000014131ba96: xor      dword ptr [rcx], eax
