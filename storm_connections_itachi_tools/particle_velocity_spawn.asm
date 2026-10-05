000000014131d750: mov      r11, rsp
000000014131d753: push     rbp
000000014131d754: push     r14
000000014131d756: push     r15
000000014131d758: lea      rbp, [r11 - 0x38]
000000014131d75c: sub      rsp, 0x120
000000014131d763: movaps   xmmword ptr [r11 - 0x38], xmm6
000000014131d768: mov      rax, qword ptr [rip + 0xdc8c59]
000000014131d76f: xor      rax, rsp
000000014131d772: mov      qword ptr [rbp - 0x40], rax
000000014131d776: mov      qword ptr [r11 + 0x18], rbx
000000014131d77a: mov      r14, rcx
000000014131d77d: mov      rbx, qword ptr [rbp + 0x60]
000000014131d781: lea      rcx, [rsp + 0x20]
000000014131d786: mov      qword ptr [r11 - 0x20], rsi
000000014131d78a: xorps    xmm3, xmm3
000000014131d78d: mov      qword ptr [r11 - 0x28], rdi
000000014131d791: xorps    xmm2, xmm2
000000014131d794: movaps   xmmword ptr [r11 - 0x48], xmm7
000000014131d799: xorps    xmm1, xmm1
000000014131d79c: movaps   xmmword ptr [r11 - 0x58], xmm8
000000014131d7a1: mov      rdi, r9
000000014131d7a4: movaps   xmmword ptr [r11 - 0x68], xmm10
000000014131d7a9: mov      rsi, r8
000000014131d7ac: mov      r15, rdx
000000014131d7af: call     0x1411ab440
000000014131d7b4: mov      rdx, qword ptr [r14 + 0x98]
000000014131d7bb: movss    xmm10, dword ptr [rip + 0x542d84]
000000014131d7c4: movsx    ecx, byte ptr [rdx + 2]
000000014131d7c8: test     ecx, ecx
000000014131d7ca: je       0x14131d982
000000014131d7d0: sub      ecx, 1
000000014131d7d3: je       0x14131d964
000000014131d7d9: sub      ecx, 1
000000014131d7dc: je       0x14131d90f
000000014131d7e2: cmp      ecx, 1
000000014131d7e5: jne      0x14131da01
000000014131d7eb: movss    xmm1, dword ptr [rdx + 0x30]
000000014131d7f0: lea      rcx, [rsp + 0x20]
000000014131d7f5: movss    xmm0, dword ptr [rdx + 0x2c]
000000014131d7fa: movaps   xmm6, xmm1
000000014131d7fd: mulss    xmm6, dword ptr [rdx + 0x38]
000000014131d802: movaps   xmm7, xmm0
000000014131d805: mulss    xmm7, dword ptr [rdx + 0x34]
000000014131d80a: xorps    xmm3, xmm3
000000014131d80d: movss    xmm2, dword ptr [rip + 0x443dcb]
000000014131d815: addss    xmm6, xmm1
000000014131d819: xorps    xmm1, xmm1
000000014131d81c: addss    xmm7, xmm0
000000014131d820: call     0x1411adb80
000000014131d825: lea      rcx, [rbp - 0x80]
000000014131d829: call     0x14127e6d0
000000014131d82e: andps    xmm6, xmmword ptr [rip + 0x48360b]
000000014131d835: movss    xmm8, dword ptr [rip + 0x459ee6]
000000014131d83e: movaps   xmm0, xmm6
000000014131d841: andps    xmm7, xmmword ptr [rip + 0x4835f8]
000000014131d848: movaps   xmm1, xmm6
000000014131d84b: mulss    xmm0, xmm8
000000014131d850: call     0x1412cd630
000000014131d855: movaps   xmm6, xmm0
000000014131d858: movaps   xmm1, xmm7
000000014131d85b: movaps   xmm0, xmm7
000000014131d85e: mulss    xmm0, xmm8
000000014131d863: call     0x1412cd630
000000014131d868: movaps   xmm2, xmm0
000000014131d86b: lea      rcx, [rsp + 0x40]
000000014131d870: movaps   xmm3, xmm6
000000014131d873: xorps    xmm1, xmm1
000000014131d876: call     0x14127fd10
000000014131d87b: mov      rdx, rax
000000014131d87e: lea      rcx, [rbp - 0x80]
000000014131d882: call     0x14127e710
000000014131d887: lea      r8, [rsp + 0x20]
000000014131d88c: lea      rdx, [rsp + 0x30]
000000014131d891: lea      rcx, [rbp - 0x80]
000000014131d895: call     0x141283c40
000000014131d89a: movsd    xmm0, qword ptr [rax]
000000014131d89e: movsd    qword ptr [rsp + 0x20], xmm0
000000014131d8a4: mov      eax, dword ptr [rax + 8]
000000014131d8a7: mov      dword ptr [rsp + 0x28], eax
000000014131d8ab: test     rbx, rbx
000000014131d8ae: je       0x14131da01
000000014131d8b4: lea      rcx, [rsp + 0x40]
000000014131d8b9: call     0x14127e6d0
000000014131d8be: movss    xmm3, dword ptr [rbx + 8]
000000014131d8c3: lea      rcx, [rsp + 0x40]
000000014131d8c8: movss    xmm2, dword ptr [rbx + 4]
000000014131d8cd: movss    xmm1, dword ptr [rbx]
000000014131d8d1: mulss    xmm3, xmm8
000000014131d8d6: mulss    xmm2, xmm8
000000014131d8db: mulss    xmm1, xmm8
000000014131d8e0: call     0x1412cd160
000000014131d8e5: lea      r8, [rsp + 0x20]
000000014131d8ea: lea      rdx, [rsp + 0x30]
000000014131d8ef: lea      rcx, [rsp + 0x40]
000000014131d8f4: call     0x141283c40
000000014131d8f9: movsd    xmm0, qword ptr [rax]
000000014131d8fd: movsd    qword ptr [rsp + 0x20], xmm0
000000014131d903: mov      eax, dword ptr [rax + 8]
000000014131d906: mov      dword ptr [rsp + 0x28], eax
000000014131d90a: jmp      0x14131da01
000000014131d90f: movss    xmm7, dword ptr [rip + 0x459e0d]
000000014131d917: movss    xmm1, dword ptr [rip + 0x443cc1]
000000014131d91f: movaps   xmm0, xmm7
000000014131d922: call     0x1412cd630
000000014131d927: movss    xmm1, dword ptr [rip + 0x443cb1]
000000014131d92f: movaps   xmm8, xmm0
000000014131d933: movaps   xmm0, xmm7
000000014131d936: call     0x1412cd630
000000014131d93b: movss    xmm1, dword ptr [rip + 0x443c9d]
000000014131d943: movaps   xmm6, xmm0
000000014131d946: movaps   xmm0, xmm7
000000014131d949: call     0x1412cd630
000000014131d94e: movaps   xmm3, xmm8
000000014131d952: lea      rcx, [rsp + 0x20]
000000014131d957: movaps   xmm2, xmm6
000000014131d95a: movaps   xmm1, xmm0
000000014131d95d: call     0x1411adb80
000000014131d962: jmp      0x14131d9b0
000000014131d964: movss    xmm2, dword ptr [rdi]
000000014131d968: movss    xmm1, dword ptr [rdi + 4]
000000014131d96d: movss    xmm0, dword ptr [rdi + 8]
000000014131d972: subss    xmm2, dword ptr [rsi]
000000014131d976: subss    xmm1, dword ptr [rsi + 4]
000000014131d97b: subss    xmm0, dword ptr [rsi + 8]
000000014131d980: jmp      0x14131d99e
000000014131d982: movss    xmm2, dword ptr [rsi]
000000014131d986: movss    xmm1, dword ptr [rsi + 4]
000000014131d98b: movss    xmm0, dword ptr [rsi + 8]
000000014131d990: subss    xmm2, dword ptr [rdi]
000000014131d994: subss    xmm1, dword ptr [rdi + 4]
000000014131d999: subss    xmm0, dword ptr [rdi + 8]
000000014131d99e: movss    dword ptr [rsp + 0x28], xmm0
000000014131d9a4: movss    dword ptr [rsp + 0x24], xmm1
000000014131d9aa: movss    dword ptr [rsp + 0x20], xmm2
000000014131d9b0: test     rbx, rbx
000000014131d9b3: je       0x14131da01
000000014131d9b5: lea      rcx, [rsp + 0x20]
000000014131d9ba: call     0x1411ac850
000000014131d9bf: comiss   xmm0, xmm10
000000014131d9c3: jbe      0x14131d9cf
000000014131d9c5: lea      rcx, [rsp + 0x20]
000000014131d9ca: call     0x1411acbb0
000000014131d9cf: movss    xmm2, dword ptr [rsp + 0x20]
000000014131d9d5: movss    xmm1, dword ptr [rsp + 0x24]
000000014131d9db: movss    xmm0, dword ptr [rsp + 0x28]
000000014131d9e1: addss    xmm2, dword ptr [rbx]
000000014131d9e5: addss    xmm1, dword ptr [rbx + 4]
000000014131d9ea: addss    xmm0, dword ptr [rbx + 8]
000000014131d9ef: movss    dword ptr [rsp + 0x20], xmm2
000000014131d9f5: movss    dword ptr [rsp + 0x24], xmm1
000000014131d9fb: movss    dword ptr [rsp + 0x28], xmm0
000000014131da01: lea      rcx, [rsp + 0x20]
000000014131da06: call     0x1411ac850
000000014131da0b: movaps   xmm8, xmmword ptr [rsp + 0xe0]
000000014131da14: movaps   xmm7, xmmword ptr [rsp + 0xf0]
000000014131da1c: mov      rdi, qword ptr [rsp + 0x110]
000000014131da24: mov      rsi, qword ptr [rsp + 0x118]
000000014131da2c: mov      rbx, qword ptr [rsp + 0x150]
000000014131da34: comiss   xmm0, xmm10
000000014131da38: movaps   xmm10, xmmword ptr [rsp + 0xd0]
000000014131da41: jbe      0x14131da4d
000000014131da43: lea      rcx, [rsp + 0x20]
000000014131da48: call     0x1411acbb0
000000014131da4d: mov      rax, qword ptr [r14 + 0x98]
000000014131da54: movss    xmm0, dword ptr [rax + 0x28]
000000014131da59: movss    xmm6, dword ptr [rax + 0x24]
000000014131da5e: call     0x1412cd5f0
000000014131da63: movss    xmm2, dword ptr [rsp + 0x20]
000000014131da69: movss    xmm1, dword ptr [rsp + 0x24]
000000014131da6f: mulss    xmm0, xmm6
000000014131da73: addss    xmm6, xmm0
000000014131da77: movss    xmm0, dword ptr [rsp + 0x28]
000000014131da7d: mulss    xmm6, dword ptr [r15 + 0x108]
000000014131da86: mulss    xmm0, xmm6
000000014131da8a: mulss    xmm2, xmm6
000000014131da8e: movss    dword ptr [rsp + 0x28], xmm0
000000014131da94: mov      eax, dword ptr [rsp + 0x28]
000000014131da98: mulss    xmm1, xmm6
000000014131da9c: movaps   xmm0, xmm2
000000014131da9f: unpcklps xmm0, xmm1
000000014131daa2: movsd    qword ptr [r15 + 0x1d0], xmm0
000000014131daab: mov      dword ptr [r15 + 0x1d8], eax
000000014131dab2: mov      rcx, qword ptr [rbp - 0x40]
000000014131dab6: xor      rcx, rsp
000000014131dab9: call     0x141441dc0
000000014131dabe: movaps   xmm6, xmmword ptr [rsp + 0x100]
000000014131dac6: add      rsp, 0x120
000000014131dacd: pop      r15
000000014131dacf: pop      r14
000000014131dad1: pop      rbp
000000014131dad2: ret      
