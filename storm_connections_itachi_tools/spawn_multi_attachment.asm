000000014131cbf0: mov      rax, rsp
000000014131cbf3: mov      qword ptr [rax + 0x20], rbx
000000014131cbf7: push     rbp
000000014131cbf8: push     rsi
000000014131cbf9: push     rdi
000000014131cbfa: push     r12
000000014131cbfc: push     r13
000000014131cbfe: push     r14
000000014131cc00: push     r15
000000014131cc02: lea      rbp, [rax - 0x128]
000000014131cc09: sub      rsp, 0x1f0
000000014131cc10: movaps   xmmword ptr [rax - 0x48], xmm6
000000014131cc14: movaps   xmmword ptr [rax - 0x58], xmm7
000000014131cc18: movaps   xmmword ptr [rax - 0x68], xmm8
000000014131cc1d: movaps   xmmword ptr [rax - 0x78], xmm9
000000014131cc22: movaps   xmmword ptr [rax - 0x88], xmm10
000000014131cc2a: movaps   xmmword ptr [rax - 0x98], xmm11
000000014131cc32: movaps   xmmword ptr [rax - 0xa8], xmm12
000000014131cc3a: mov      rax, qword ptr [rip + 0xdc9787]
000000014131cc41: xor      rax, rsp
000000014131cc44: mov      qword ptr [rbp + 0x70], rax
000000014131cc48: mov      esi, r9d
000000014131cc4b: movaps   xmm12, xmm2
000000014131cc4f: mov      r13, rdx
000000014131cc52: mov      r14, rcx
000000014131cc55: lea      rcx, [rbp - 0x60]
000000014131cc59: call     0x14131b3b0
000000014131cc5e: lea      rax, [rip + 0x87eaf3]
000000014131cc65: mov      qword ptr [rbp - 0x60], rax
000000014131cc69: mov      dword ptr [rbp - 0x28], 1
000000014131cc70: xor      r12d, r12d
000000014131cc73: mov      qword ptr [rbp - 0x18], r12
000000014131cc77: mov      edi, r12d
000000014131cc7a: xorps    xmm3, xmm3
000000014131cc7d: xorps    xmm2, xmm2
000000014131cc80: xorps    xmm1, xmm1
000000014131cc83: lea      rcx, [rsp + 0x70]
000000014131cc88: call     0x1411ab440
000000014131cc8d: xorps    xmm3, xmm3
000000014131cc90: xorps    xmm2, xmm2
000000014131cc93: xorps    xmm1, xmm1
000000014131cc96: lea      rcx, [rsp + 0x40]
000000014131cc9b: call     0x1411ab440
000000014131cca0: xorps    xmm3, xmm3
000000014131cca3: xorps    xmm2, xmm2
000000014131cca6: xorps    xmm1, xmm1
000000014131cca9: lea      rcx, [rbp - 0x70]
000000014131ccad: call     0x1411ab440
000000014131ccb2: xorps    xmm3, xmm3
000000014131ccb5: xorps    xmm2, xmm2
000000014131ccb8: xorps    xmm1, xmm1
000000014131ccbb: lea      rcx, [rsp + 0x50]
000000014131ccc0: call     0x1411ab440
000000014131ccc5: movss    xmm10, dword ptr [rip + 0x444912]
000000014131ccce: movaps   xmm11, xmm10
000000014131ccd2: mov      rbx, qword ptr [r14 + 0x180]
000000014131ccd9: mov      r15d, dword ptr [r14 + 0x1a0]
000000014131cce0: call     0x1412cd5c0
000000014131cce5: xor      edx, edx
000000014131cce7: cmp      esi, r15d
000000014131ccea: je       0x14131ccef
000000014131ccec: sub      esi, r15d
000000014131ccef: div      esi
000000014131ccf1: mov      r15d, edx
000000014131ccf4: test     edx, edx
000000014131ccf6: jne      0x14131cd0d
000000014131ccf8: mov      rbx, qword ptr [r14 + 0x180]
000000014131ccff: mov      rax, qword ptr [rbx + 0x30]
000000014131cd03: test     rax, rax
000000014131cd06: je       0x14131cd50
000000014131cd08: mov      rdi, rax
000000014131cd0b: jmp      0x14131cd50
000000014131cd0d: mov      esi, r12d
000000014131cd10: mov      rax, qword ptr [rbx]
000000014131cd13: mov      rcx, rbx
000000014131cd16: call     qword ptr [rax + 0x68]
000000014131cd19: test     eax, eax
000000014131cd1b: jne      0x14131cd24
000000014131cd1d: cmp      esi, r15d
000000014131cd20: je       0x14131cd32
000000014131cd22: inc      esi
000000014131cd24: mov      rdi, qword ptr [rbx + 0x30]
000000014131cd28: test     rdi, rdi
000000014131cd2b: je       0x14131cd3e
000000014131cd2d: mov      rbx, rdi
000000014131cd30: jmp      0x14131cd10
000000014131cd32: mov      r15d, esi
000000014131cd35: mov      rdi, qword ptr [rbx + 0x30]
000000014131cd39: test     rdi, rdi
000000014131cd3c: jne      0x14131cd50
000000014131cd3e: mov      rdi, qword ptr [r14 + 0x190]
000000014131cd45: mov      rax, qword ptr [rdi + 0x28]
000000014131cd49: test     rax, rax
000000014131cd4c: cmovne   rbx, rax
000000014131cd50: mov      dword ptr [rbp - 0x28], 1
000000014131cd57: mov      qword ptr [rbp - 0x18], r12
000000014131cd5b: mov      rax, qword ptr [rbx]
000000014131cd5e: lea      rdx, [rbp - 0x60]
000000014131cd62: mov      rcx, rbx
000000014131cd65: call     qword ptr [rax + 0x18]
000000014131cd68: mov      rsi, qword ptr [rbp - 0x18]
000000014131cd6c: mov      rcx, qword ptr [rsi]
000000014131cd6f: test     rcx, rcx
000000014131cd72: je       0x14131cdcc
000000014131cd74: mov      rax, qword ptr [rcx]
000000014131cd77: call     qword ptr [rax + 0x28]
000000014131cd7a: mov      rcx, qword ptr [rsi]
000000014131cd7d: movzx    ebx, byte ptr [rcx + 0x120]
000000014131cd84: shl      rbx, 6
000000014131cd88: add      rbx, rcx
000000014131cd8b: xorps    xmm3, xmm3
000000014131cd8e: xorps    xmm2, xmm2
000000014131cd91: movaps   xmm1, xmm10
000000014131cd95: lea      rcx, [rbp - 0x80]
000000014131cd99: call     0x1411ab440
000000014131cd9e: lea      r8, [rbp - 0x80]
000000014131cda2: lea      rdx, [rsp + 0x60]
000000014131cda7: lea      rcx, [rbx + 0x7c]
000000014131cdab: call     0x141283c40
000000014131cdb0: movsd    xmm0, qword ptr [rax]
000000014131cdb4: movsd    qword ptr [rbp - 0x80], xmm0
000000014131cdb9: mov      eax, dword ptr [rax + 8]
000000014131cdbc: mov      dword ptr [rbp - 0x78], eax
000000014131cdbf: lea      rcx, [rbp - 0x80]
000000014131cdc3: call     0x1411ac850
000000014131cdc8: movaps   xmm11, xmm0
000000014131cdcc: mov      dword ptr [rbp - 0x28], 1
000000014131cdd3: mov      qword ptr [rbp - 0x18], r12
000000014131cdd7: mov      rax, qword ptr [rdi]
000000014131cdda: lea      rdx, [rbp - 0x60]
000000014131cdde: mov      rcx, rdi
000000014131cde1: call     qword ptr [rax + 0x18]
000000014131cde4: mov      rbx, qword ptr [rbp - 0x18]
000000014131cde8: xorps    xmm3, xmm3
000000014131cdeb: xorps    xmm2, xmm2
000000014131cdee: xorps    xmm1, xmm1
000000014131cdf1: lea      rcx, [rsp + 0x30]
000000014131cdf6: call     0x1411ab440
000000014131cdfb: mov      rcx, rsi
000000014131cdfe: call     0x141387bc0
000000014131ce03: movsd    xmm6, qword ptr [rax]
000000014131ce07: mov      eax, dword ptr [rax + 8]
000000014131ce0a: mov      dword ptr [rsp + 0x68], eax
000000014131ce0e: mov      rcx, rbx
000000014131ce11: call     0x141387bc0
000000014131ce16: movsd    xmm0, qword ptr [rax]
000000014131ce1a: mov      eax, dword ptr [rax + 8]
000000014131ce1d: mov      dword ptr [rbp - 0x78], eax
000000014131ce20: movaps   xmm3, xmm0
000000014131ce23: subss    xmm3, xmm6
000000014131ce27: movaps   xmm2, xmm0
000000014131ce2a: shufps   xmm2, xmm2, 0x55
000000014131ce2e: movaps   xmm0, xmm6
000000014131ce31: shufps   xmm0, xmm0, 0x55
000000014131ce35: movsd    qword ptr [rsp + 0x60], xmm6
000000014131ce3b: subss    xmm2, xmm0
000000014131ce3f: movss    xmm1, dword ptr [rbp - 0x78]
000000014131ce44: subss    xmm1, dword ptr [rsp + 0x68]
000000014131ce4a: movss    dword ptr [rsp + 0x30], xmm3
000000014131ce50: movss    dword ptr [rsp + 0x34], xmm2
000000014131ce56: movss    dword ptr [rsp + 0x38], xmm1
000000014131ce5c: lea      rcx, [rsp + 0x30]
000000014131ce61: call     0x1411ac850
000000014131ce66: movss    xmm1, dword ptr [rip + 0x5436da]
000000014131ce6e: movss    xmm9, dword ptr [rip + 0x45a8ad]
000000014131ce77: comiss   xmm1, xmm0
000000014131ce7a: jb       0x14131ce90
000000014131ce7c: xorps    xmm3, xmm3
000000014131ce7f: movaps   xmm2, xmm9
000000014131ce83: xorps    xmm1, xmm1
000000014131ce86: lea      rcx, [rsp + 0x30]
000000014131ce8b: call     0x1411adb80
000000014131ce90: lea      rdx, [rsp + 0x60]
000000014131ce95: lea      rcx, [rsp + 0x30]
000000014131ce9a: call     0x1411acc30
000000014131ce9f: movsd    xmm1, qword ptr [rax]
000000014131cea3: mov      eax, dword ptr [rax + 8]
000000014131cea6: mov      dword ptr [rsp + 0x68], eax
000000014131ceaa: movss    dword ptr [rsp + 0x70], xmm1
000000014131ceb0: movaps   xmm0, xmm1
000000014131ceb3: shufps   xmm0, xmm0, 0x55
000000014131ceb7: movsd    qword ptr [rsp + 0x60], xmm1
000000014131cebd: movss    dword ptr [rsp + 0x74], xmm0
000000014131cec3: movss    xmm0, dword ptr [rsp + 0x68]
000000014131cec9: movss    dword ptr [rsp + 0x78], xmm0
000000014131cecf: lea      rcx, [rsp + 0x30]
000000014131ced4: call     0x1411ac850
000000014131ced9: movaps   xmm6, xmm0
000000014131cedc: movaps   xmm0, xmm10
000000014131cee0: call     0x1412cd5f0
000000014131cee5: mulss    xmm6, xmm0
000000014131cee9: movss    xmm3, dword ptr [rsp + 0x70]
000000014131ceef: mulss    xmm3, xmm6
000000014131cef3: movss    xmm2, dword ptr [rsp + 0x74]
000000014131cef9: mulss    xmm2, xmm6
000000014131cefd: movss    xmm1, dword ptr [rsp + 0x78]
000000014131cf03: mulss    xmm1, xmm6
000000014131cf07: movss    dword ptr [rsp + 0x30], xmm3
000000014131cf0d: movss    dword ptr [rsp + 0x34], xmm2
000000014131cf13: movss    dword ptr [rsp + 0x38], xmm1
000000014131cf19: mov      rcx, rsi
000000014131cf1c: call     0x141387bc0
000000014131cf21: movsd    xmm0, qword ptr [rax]
000000014131cf25: mov      eax, dword ptr [rax + 8]
000000014131cf28: mov      dword ptr [rsp + 0x68], eax
000000014131cf2c: movaps   xmm2, xmm0
000000014131cf2f: addss    xmm2, dword ptr [rsp + 0x30]
000000014131cf35: movaps   xmm1, xmm0
000000014131cf38: shufps   xmm1, xmm1, 0x55
000000014131cf3c: movsd    qword ptr [rsp + 0x60], xmm0
000000014131cf42: addss    xmm1, dword ptr [rsp + 0x34]
000000014131cf48: movss    xmm0, dword ptr [rsp + 0x68]
000000014131cf4e: addss    xmm0, dword ptr [rsp + 0x38]
000000014131cf54: movss    dword ptr [rsp + 0x40], xmm2
000000014131cf5a: movss    dword ptr [rsp + 0x44], xmm1
000000014131cf60: movss    dword ptr [rsp + 0x48], xmm0
000000014131cf66: movss    xmm1, dword ptr [rip + 0x87fd1e]
000000014131cf6e: movaps   xmm0, xmm1
000000014131cf71: xorps    xmm0, xmmword ptr [rip + 0x444228]
000000014131cf78: call     0x1412cd630
000000014131cf7d: movaps   xmm7, xmm0
000000014131cf80: movss    xmm1, dword ptr [rip + 0x87fd04]
000000014131cf88: movaps   xmm0, xmm1
000000014131cf8b: xorps    xmm0, xmmword ptr [rip + 0x44420e]
000000014131cf92: call     0x1412cd630
000000014131cf97: movaps   xmm6, xmm0
000000014131cf9a: mov      rax, qword ptr [r14 + 0x98]
000000014131cfa1: movss    xmm0, dword ptr [rax + 0x18]
000000014131cfa6: call     0x1412cd5f0
000000014131cfab: movaps   xmm8, xmm10
000000014131cfaf: subss    xmm8, xmm0
000000014131cfb4: mulss    xmm8, xmm12
000000014131cfb9: xorps    xmm3, xmm3
000000014131cfbc: xorps    xmm2, xmm2
000000014131cfbf: movaps   xmm1, xmm10
000000014131cfc3: lea      rcx, [rsp + 0x30]
000000014131cfc8: call     0x1411adb80
000000014131cfcd: lea      rcx, [rbp - 0x10]
000000014131cfd1: call     0x14127e6d0
000000014131cfd6: movaps   xmm1, xmm7
000000014131cfd9: lea      rcx, [rbp + 0x30]
000000014131cfdd: call     0x1412818f0
000000014131cfe2: mov      rdx, rax
000000014131cfe5: lea      rcx, [rbp - 0x10]
000000014131cfe9: call     0x14127e710
000000014131cfee: lea      r8, [rsp + 0x30]
000000014131cff3: lea      rdx, [rsp + 0x60]
000000014131cff8: lea      rcx, [rbp - 0x10]
000000014131cffc: call     0x141283c40
000000014131d001: movsd    xmm0, qword ptr [rax]
000000014131d005: movsd    qword ptr [rsp + 0x30], xmm0
000000014131d00b: mov      eax, dword ptr [rax + 8]
000000014131d00e: mov      dword ptr [rsp + 0x38], eax
000000014131d012: movaps   xmm1, xmm6
000000014131d015: lea      rcx, [rbp + 0x30]
000000014131d019: call     0x141281850
000000014131d01e: mov      rdx, rax
000000014131d021: lea      rcx, [rbp - 0x10]
000000014131d025: call     0x14127e710
000000014131d02a: lea      r8, [rsp + 0x30]
000000014131d02f: lea      rdx, [rsp + 0x60]
000000014131d034: lea      rcx, [rbp - 0x10]
000000014131d038: call     0x141283c40
000000014131d03d: movsd    xmm1, qword ptr [rax]
000000014131d041: movsd    qword ptr [rsp + 0x30], xmm1
000000014131d047: mov      eax, dword ptr [rax + 8]
000000014131d04a: mov      dword ptr [rsp + 0x38], eax
000000014131d04e: mulss    xmm12, xmm11
000000014131d053: mulss    xmm8, xmm11
000000014131d058: movaps   xmm1, xmm12
000000014131d05c: movaps   xmm0, xmm8
000000014131d060: call     0x1412cd630
000000014131d065: movss    xmm3, dword ptr [rsp + 0x30]
000000014131d06b: mulss    xmm3, xmm0
000000014131d06f: movss    xmm2, dword ptr [rsp + 0x34]
000000014131d075: mulss    xmm2, xmm0
000000014131d079: movss    xmm1, dword ptr [rsp + 0x38]
000000014131d07f: mulss    xmm1, xmm0
000000014131d083: movss    dword ptr [rbp - 0x70], xmm3
000000014131d088: movss    dword ptr [rbp - 0x6c], xmm2
000000014131d08d: movss    dword ptr [rbp - 0x68], xmm1
000000014131d092: addss    xmm3, dword ptr [rsp + 0x40]
000000014131d098: addss    xmm2, dword ptr [rsp + 0x44]
000000014131d09e: addss    xmm1, dword ptr [rsp + 0x48]
000000014131d0a4: movss    dword ptr [rsp + 0x40], xmm3
000000014131d0aa: movss    dword ptr [rsp + 0x44], xmm2
000000014131d0b0: movss    dword ptr [rsp + 0x48], xmm1
000000014131d0b6: lea      rdx, [rsp + 0x40]
000000014131d0bb: mov      rcx, r13
000000014131d0be: call     0x14130c410
000000014131d0c3: mov      dword ptr [r13 + 0x190], r15d
000000014131d0ca: movss    dword ptr [r13 + 0x108], xmm11
000000014131d0d3: mov      ecx, dword ptr [rbp + 0x150]
000000014131d0d9: test     ecx, ecx
000000014131d0db: je       0x14131d151
000000014131d0dd: sub      ecx, 1
000000014131d0e0: je       0x14131d138
000000014131d0e2: cmp      ecx, 1
000000014131d0e5: jne      0x14131d25c
000000014131d0eb: movss    xmm0, dword ptr [rsp + 0x70]
000000014131d0f1: mulss    xmm0, xmm9
000000014131d0f6: movss    dword ptr [rsp + 0x50], xmm0
000000014131d0fc: movss    xmm1, dword ptr [rsp + 0x74]
000000014131d102: mulss    xmm1, xmm9
000000014131d107: movss    dword ptr [rsp + 0x54], xmm1
000000014131d10d: movss    xmm0, dword ptr [rsp + 0x78]
000000014131d113: mulss    xmm0, xmm9
000000014131d118: movss    dword ptr [rsp + 0x58], xmm0
000000014131d11e: mov      rcx, rbx
000000014131d121: call     0x141387bc0
000000014131d126: mov      r9, rax
000000014131d129: lea      rax, [rsp + 0x50]
000000014131d12e: mov      qword ptr [rsp + 0x20], rax
000000014131d133: jmp      0x14131d24b
000000014131d138: movsd    xmm0, qword ptr [rsp + 0x70]
000000014131d13e: movsd    qword ptr [rsp + 0x50], xmm0
000000014131d144: mov      eax, dword ptr [rsp + 0x78]
000000014131d148: mov      dword ptr [rsp + 0x58], eax
000000014131d14c: mov      rcx, rsi
000000014131d14f: jmp      0x14131d121
000000014131d151: call     0x1412cd5c0
000000014131d156: test     al, 1
000000014131d158: je       0x14131d1cd
000000014131d15a: mov      rcx, rsi
000000014131d15d: call     0x141387bc0
000000014131d162: movsd    xmm3, qword ptr [rax]
000000014131d166: mov      eax, dword ptr [rax + 8]
000000014131d169: mov      dword ptr [rsp + 0x68], eax
000000014131d16d: movss    xmm0, dword ptr [rsp + 0x40]
000000014131d173: subss    xmm0, xmm3
000000014131d177: movss    dword ptr [rsp + 0x50], xmm0
000000014131d17d: movss    xmm2, dword ptr [rsp + 0x44]
000000014131d183: movaps   xmm1, xmm3
000000014131d186: shufps   xmm1, xmm1, 0x55
000000014131d18a: subss    xmm2, xmm1
000000014131d18e: movss    dword ptr [rsp + 0x54], xmm2
000000014131d194: movss    xmm0, dword ptr [rsp + 0x48]
000000014131d19a: subss    xmm0, dword ptr [rsp + 0x68]
000000014131d1a0: movss    dword ptr [rsp + 0x58], xmm0
000000014131d1a6: lea      rcx, [rsp + 0x50]
000000014131d1ab: call     0x1411ac850
000000014131d1b0: comiss   xmm0, dword ptr [rip + 0x87e7a9]
000000014131d1b7: jbe      0x14131d1c8
000000014131d1b9: lea      rcx, [rsp + 0x50]
000000014131d1be: call     0x1411acbb0
000000014131d1c3: lea      r12, [rsp + 0x50]
000000014131d1c8: mov      rcx, rsi
000000014131d1cb: jmp      0x14131d23e
000000014131d1cd: mov      rcx, rbx
000000014131d1d0: call     0x141387bc0
000000014131d1d5: movsd    xmm3, qword ptr [rax]
000000014131d1d9: mov      eax, dword ptr [rax + 8]
000000014131d1dc: mov      dword ptr [rsp + 0x68], eax
000000014131d1e0: movss    xmm0, dword ptr [rsp + 0x40]
000000014131d1e6: subss    xmm0, xmm3
000000014131d1ea: movss    dword ptr [rsp + 0x50], xmm0
000000014131d1f0: movss    xmm2, dword ptr [rsp + 0x44]
000000014131d1f6: movaps   xmm1, xmm3
000000014131d1f9: shufps   xmm1, xmm1, 0x55
000000014131d1fd: subss    xmm2, xmm1
000000014131d201: movss    dword ptr [rsp + 0x54], xmm2
000000014131d207: movss    xmm0, dword ptr [rsp + 0x48]
000000014131d20d: subss    xmm0, dword ptr [rsp + 0x68]
000000014131d213: movss    dword ptr [rsp + 0x58], xmm0
000000014131d219: lea      rcx, [rsp + 0x50]
000000014131d21e: call     0x1411ac850
000000014131d223: comiss   xmm0, dword ptr [rip + 0x87e736]
000000014131d22a: jbe      0x14131d23b
000000014131d22c: lea      rcx, [rsp + 0x50]
000000014131d231: call     0x1411acbb0
000000014131d236: jmp      0x14131d11e
000000014131d23b: mov      rcx, rbx
000000014131d23e: call     0x141387bc0
000000014131d243: mov      r9, rax
000000014131d246: mov      qword ptr [rsp + 0x20], r12
000000014131d24b: lea      r8, [rsp + 0x40]
000000014131d250: mov      rdx, r13
000000014131d253: mov      rcx, r14
000000014131d256: call     0x14131d750
000000014131d25b: nop      
000000014131d25c: mov      rcx, qword ptr [rbp + 0x70]
000000014131d260: xor      rcx, rsp
000000014131d263: call     0x141441dc0
000000014131d268: lea      r11, [rsp + 0x1f0]
000000014131d270: mov      rbx, qword ptr [r11 + 0x58]
000000014131d274: movaps   xmm6, xmmword ptr [r11 - 0x10]
000000014131d279: movaps   xmm7, xmmword ptr [r11 - 0x20]
000000014131d27e: movaps   xmm8, xmmword ptr [r11 - 0x30]
000000014131d283: movaps   xmm9, xmmword ptr [r11 - 0x40]
000000014131d288: movaps   xmm10, xmmword ptr [r11 - 0x50]
000000014131d28d: movaps   xmm11, xmmword ptr [r11 - 0x60]
000000014131d292: movaps   xmm12, xmmword ptr [r11 - 0x70]
000000014131d297: mov      rsp, r11
000000014131d29a: pop      r15
000000014131d29c: pop      r14
000000014131d29e: pop      r13
000000014131d2a0: pop      r12
000000014131d2a2: pop      rdi
000000014131d2a3: pop      rsi
000000014131d2a4: pop      rbp
000000014131d2a5: ret      
