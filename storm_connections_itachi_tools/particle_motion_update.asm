0000000141386b70: mov      r11, rsp
0000000141386b73: push     rbp
0000000141386b74: push     rbx
0000000141386b75: push     rdi
0000000141386b76: lea      rbp, [r11 - 0x68]
0000000141386b7a: sub      rsp, 0x150
0000000141386b81: mov      rax, qword ptr [rip + 0xd5f840]
0000000141386b88: xor      rax, rsp
0000000141386b8b: mov      qword ptr [rbp - 0x10], rax
0000000141386b8f: mov      rax, qword ptr [rip + 0x8382982]
0000000141386b96: mov      rdi, rcx
0000000141386b99: movd     xmm1, dword ptr [rcx + 0x194]
0000000141386ba1: mov      qword ptr [r11 + 0x18], rsi
0000000141386ba5: mov      rsi, rdx
0000000141386ba8: cvtdq2ps xmm1, xmm1
0000000141386bab: movzx    edx, byte ptr [rax + 0x952]
0000000141386bb2: mov      qword ptr [r11 + 0x20], r14
0000000141386bb6: movd     xmm0, edx
0000000141386bba: cvtdq2ps xmm0, xmm0
0000000141386bbd: movaps   xmmword ptr [r11 - 0x68], xmm10
0000000141386bc2: divss    xmm1, xmm0
0000000141386bc6: movss    dword ptr [rcx + 0x198], xmm1
0000000141386bce: call     0x1400b07c0
0000000141386bd3: movsd    xmm0, qword ptr [rdi + 0x7c]
0000000141386bd8: movsd    qword ptr [rsp + 0x30], xmm0
0000000141386bde: mov      ecx, dword ptr [rax + 0x5c]
0000000141386be1: mov      eax, dword ptr [rdi + 0x84]
0000000141386be7: mov      dword ptr [rsp + 0x38], eax
0000000141386beb: mov      eax, dword ptr [rdi + 0x200]
0000000141386bf1: mov      dword ptr [rdi + 0x19c], ecx
0000000141386bf7: test     eax, eax
0000000141386bf9: je       0x141386c53
0000000141386bfb: test     al, 1
0000000141386bfd: je       0x141386c19
0000000141386bff: call     0x1400b07c0
0000000141386c04: mov      rcx, rdi
0000000141386c07: mov      rdx, qword ptr [rax + 0x90]
0000000141386c0e: call     0x141385ec0
0000000141386c13: mov      eax, dword ptr [rdi + 0x200]
0000000141386c19: bt       eax, 8
0000000141386c1d: jae      0x141386c39
0000000141386c1f: call     0x1400b07c0
0000000141386c24: mov      rcx, rdi
0000000141386c27: mov      rdx, qword ptr [rax + 0x88]
0000000141386c2e: call     0x141385ec0
0000000141386c33: mov      eax, dword ptr [rdi + 0x200]
0000000141386c39: bt       eax, 0x10
0000000141386c3d: jae      0x141386c53
0000000141386c3f: call     0x1400b07c0
0000000141386c44: mov      rcx, rdi
0000000141386c47: mov      rdx, qword ptr [rax + 0x80]
0000000141386c4e: call     0x141385ec0
0000000141386c53: movss    xmm2, dword ptr [rdi + 0x19c]
0000000141386c5b: lea      rdx, [rsp + 0x20]
0000000141386c60: mulss    xmm2, dword ptr [rdi + 0x204]
0000000141386c68: lea      rcx, [rdi + 0x7c]
0000000141386c6c: mulss    xmm2, dword ptr [rdi + 0x198]
0000000141386c74: movaps   xmm1, xmm2
0000000141386c77: movaps   xmm0, xmm2
0000000141386c7a: mulss    xmm1, dword ptr [rdi + 0x1d0]
0000000141386c82: mulss    xmm0, dword ptr [rdi + 0x1d4]
0000000141386c8a: mulss    xmm2, dword ptr [rdi + 0x1d8]
0000000141386c92: movss    dword ptr [rsp + 0x20], xmm1
0000000141386c98: movss    dword ptr [rsp + 0x24], xmm0
0000000141386c9e: movss    dword ptr [rsp + 0x28], xmm2
0000000141386ca4: call     0x1411ab760
0000000141386ca9: movss    xmm2, dword ptr [rdi + 0x204]
0000000141386cb1: lea      rdx, [rsp + 0x20]
0000000141386cb6: movaps   xmm1, xmm2
0000000141386cb9: lea      rcx, [rdi + 0x7c]
0000000141386cbd: mulss    xmm1, dword ptr [rdi + 0x1dc]
0000000141386cc5: movaps   xmm0, xmm2
0000000141386cc8: mulss    xmm0, dword ptr [rdi + 0x1e0]
0000000141386cd0: mulss    xmm2, dword ptr [rdi + 0x1e4]
0000000141386cd8: movss    dword ptr [rsp + 0x20], xmm1
0000000141386cde: movss    dword ptr [rsp + 0x24], xmm0
0000000141386ce4: movss    dword ptr [rsp + 0x28], xmm2
0000000141386cea: call     0x1411ab760
0000000141386cef: movss    xmm2, dword ptr [rdi + 0x19c]
0000000141386cf7: lea      rdx, [rsp + 0x20]
0000000141386cfc: mulss    xmm2, dword ptr [rdi + 0x204]
0000000141386d04: lea      rcx, [rdi + 0x7c]
0000000141386d08: mulss    xmm2, dword ptr [rdi + 0x198]
0000000141386d10: movaps   xmm1, xmm2
0000000141386d13: movaps   xmm0, xmm2
0000000141386d16: mulss    xmm1, dword ptr [rdi + 0x1e8]
0000000141386d1e: mulss    xmm0, dword ptr [rdi + 0x1ec]
0000000141386d26: mulss    xmm2, dword ptr [rdi + 0x1f0]
0000000141386d2e: movss    dword ptr [rsp + 0x20], xmm1
0000000141386d34: movss    dword ptr [rsp + 0x24], xmm0
0000000141386d3a: movss    dword ptr [rsp + 0x28], xmm2
0000000141386d40: call     0x1411ab760
0000000141386d45: cmp      dword ptr [rdi + 0x17c], 0
0000000141386d4c: movss    xmm10, dword ptr [rip + 0x4d97f3]
0000000141386d55: je       0x141386dec
0000000141386d5b: movss    xmm2, dword ptr [rdi + 0x7c]
0000000141386d60: lea      rcx, [rsp + 0x20]
0000000141386d65: movss    xmm1, dword ptr [rdi + 0x80]
0000000141386d6d: movss    xmm0, dword ptr [rdi + 0x84]
0000000141386d75: subss    xmm2, dword ptr [rsp + 0x30]
0000000141386d7b: subss    xmm1, dword ptr [rsp + 0x34]
0000000141386d81: subss    xmm0, dword ptr [rsp + 0x38]
0000000141386d87: movss    dword ptr [rsp + 0x20], xmm2
0000000141386d8d: movss    dword ptr [rsp + 0x24], xmm1
0000000141386d93: movss    dword ptr [rsp + 0x28], xmm0
0000000141386d99: call     0x1411ac850
0000000141386d9e: comiss   xmm0, xmm10
0000000141386da2: jbe      0x141386dec
0000000141386da4: movss    xmm1, dword ptr [rip + 0x3da834]
0000000141386dac: movss    xmm3, dword ptr [rsp + 0x20]
0000000141386db2: movss    xmm2, dword ptr [rsp + 0x24]
0000000141386db8: divss    xmm1, xmm0
0000000141386dbc: movss    xmm0, dword ptr [rsp + 0x28]
0000000141386dc2: mulss    xmm0, xmm1
0000000141386dc6: mulss    xmm3, xmm1
0000000141386dca: mulss    xmm2, xmm1
0000000141386dce: movaps   xmm1, xmm3
0000000141386dd1: movss    dword ptr [rsp + 0x58], xmm0
0000000141386dd7: mov      eax, dword ptr [rsp + 0x58]
0000000141386ddb: unpcklps xmm1, xmm2
0000000141386dde: movsd    qword ptr [rdi + 0x20c], xmm1
0000000141386de6: mov      dword ptr [rdi + 0x214], eax
0000000141386dec: mov      ecx, dword ptr [rdi + 0x180]
0000000141386df2: mov      r14d, 1
0000000141386df8: sub      ecx, r14d
0000000141386dfb: je       0x141386e07
0000000141386dfd: cmp      ecx, r14d
0000000141386e00: jne      0x141386e15
0000000141386e02: xor      r8d, r8d
0000000141386e05: jmp      0x141386e0a
0000000141386e07: mov      r8d, r14d
0000000141386e0a: mov      rdx, rsi
0000000141386e0d: mov      rcx, rdi
0000000141386e10: call     0x141386590
0000000141386e15: mov      ecx, dword ptr [rdi + 0x50]
0000000141386e18: sub      ecx, 3
0000000141386e1b: je       0x141387114
0000000141386e21: cmp      ecx, r14d
0000000141386e24: je       0x141387114
0000000141386e2a: movaps   xmmword ptr [rsp + 0x140], xmm6
0000000141386e32: lea      rcx, [rsp + 0x70]
0000000141386e37: movaps   xmmword ptr [rsp + 0x110], xmm9
0000000141386e40: call     0x14127e6d0
0000000141386e45: cmp      dword ptr [rdi + 0x17c], 0
0000000141386e4c: xorps    xmm9, xmm9
0000000141386e50: je       0x141386f67
0000000141386e56: call     0x1400bfa80
0000000141386e5b: movss    xmm2, dword ptr [rip + 0x3e1b85]
0000000141386e63: lea      rcx, [rdi + 0x20c]
0000000141386e6a: mov      rdx, rax
0000000141386e6d: call     0x1411ac3b0
0000000141386e72: test     al, al
0000000141386e74: jne      0x141386f67
0000000141386e7a: movss    xmm6, dword ptr [rip + 0x3da31e]
0000000141386e82: lea      rcx, [rsp + 0x40]
0000000141386e87: movss    xmm3, dword ptr [rdi + 0x214]
0000000141386e8f: movss    xmm2, dword ptr [rdi + 0x210]
0000000141386e97: xorps    xmm3, xmm6
0000000141386e9a: movss    xmm1, dword ptr [rdi + 0x20c]
0000000141386ea2: xorps    xmm2, xmm6
0000000141386ea5: xorps    xmm1, xmm6
0000000141386ea8: call     0x1411ab440
0000000141386ead: movss    xmm2, dword ptr [rsp + 0x40]
0000000141386eb3: ucomiss  xmm2, xmm9
0000000141386eb7: movss    xmm0, dword ptr [rsp + 0x44]
0000000141386ebd: movss    xmm1, dword ptr [rsp + 0x48]
0000000141386ec3: movss    dword ptr [rsp + 0x60], xmm2
0000000141386ec9: movss    dword ptr [rsp + 0x64], xmm0
0000000141386ecf: movss    dword ptr [rsp + 0x68], xmm1
0000000141386ed5: jp       0x141386eec
0000000141386ed7: jne      0x141386eec
0000000141386ed9: ucomiss  xmm0, xmm9
0000000141386edd: jp       0x141386eec
0000000141386edf: jne      0x141386eec
0000000141386ee1: movaps   xmm3, xmm2
0000000141386ee4: xorps    xmm1, xmm6
0000000141386ee7: xorps    xmm2, xmm2
0000000141386eea: jmp      0x141386ef5
0000000141386eec: xorps    xmm2, xmm6
0000000141386eef: xorps    xmm3, xmm3
0000000141386ef2: movaps   xmm1, xmm0
0000000141386ef5: lea      rcx, [rsp + 0x40]
0000000141386efa: call     0x1411ab440
0000000141386eff: movsd    xmm0, qword ptr [rsp + 0x40]
0000000141386f05: lea      rcx, [rsp + 0x30]
0000000141386f0a: mov      eax, dword ptr [rsp + 0x48]
0000000141386f0e: movsd    qword ptr [rsp + 0x30], xmm0
0000000141386f14: mov      dword ptr [rsp + 0x38], eax
0000000141386f18: call     0x1411acbb0
0000000141386f1d: lea      r8, [rsp + 0x60]
0000000141386f22: lea      rdx, [rsp + 0x40]
0000000141386f27: lea      rcx, [rsp + 0x30]
0000000141386f2c: call     0x1411ac0f0
0000000141386f31: lea      r9, [rsp + 0x50]
0000000141386f36: lea      r8, [rsp + 0x60]
0000000141386f3b: lea      rdx, [rsp + 0x30]
0000000141386f40: movsd    xmm0, qword ptr [rax]
0000000141386f44: lea      rcx, [rbp - 0x50]
0000000141386f48: movsd    qword ptr [rsp + 0x50], xmm0
0000000141386f4e: mov      eax, dword ptr [rax + 8]
0000000141386f51: mov      dword ptr [rsp + 0x58], eax
0000000141386f55: call     0x1412c48c0
0000000141386f5a: mov      rdx, rax
0000000141386f5d: lea      rcx, [rsp + 0x70]
0000000141386f62: call     0x141281f40
0000000141386f67: lea      rdx, [rdi + 0x7c]
0000000141386f6b: lea      rcx, [rsp + 0x70]
0000000141386f70: call     0x141282e80
0000000141386f75: cmp      dword ptr [rdi + 0x178], 0
0000000141386f7c: je       0x141387025
0000000141386f82: movss    xmm0, dword ptr [rdi + 0x9c]
0000000141386f8a: movaps   xmmword ptr [rsp + 0x130], xmm7
0000000141386f92: movaps   xmmword ptr [rsp + 0x120], xmm8
0000000141386f9b: movss    xmm8, dword ptr [rdi + 0x94]
0000000141386fa4: call     0x1412ccd80
0000000141386fa9: movaps   xmm7, xmm0
0000000141386fac: movss    xmm0, dword ptr [rdi + 0x98]
0000000141386fb4: call     0x1412ccd80
0000000141386fb9: movaps   xmm6, xmm0
0000000141386fbc: movaps   xmm0, xmm8
0000000141386fc0: call     0x1412ccd80
0000000141386fc5: movaps   xmm3, xmm7
0000000141386fc8: lea      rcx, [rdi + 0x94]
0000000141386fcf: movaps   xmm2, xmm6
0000000141386fd2: movaps   xmm1, xmm0
0000000141386fd5: call     0x1411adb80
0000000141386fda: movss    xmm3, dword ptr [rdi + 0x94]
0000000141386fe2: lea      rcx, [rbp - 0x50]
0000000141386fe6: movss    xmm2, dword ptr [rdi + 0x98]
0000000141386fee: movss    xmm1, dword ptr [rdi + 0x9c]
0000000141386ff6: call     0x1412c4330
0000000141386ffb: mov      rdx, rax
0000000141386ffe: lea      rcx, [rdi + 0x154]
0000000141387005: call     0x1412c36f0
000000014138700a: movaps   xmm8, xmmword ptr [rsp + 0x120]
0000000141387013: movaps   xmm7, xmmword ptr [rsp + 0x130]
000000014138701b: mov      dword ptr [rdi + 0x178], 0
0000000141387025: movss    xmm0, dword ptr [rdi + 0x94]
000000014138702d: ucomiss  xmm0, xmm9
0000000141387031: movaps   xmm6, xmmword ptr [rsp + 0x140]
0000000141387039: jp       0x14138705d
000000014138703b: jne      0x14138705d
000000014138703d: movss    xmm0, dword ptr [rdi + 0x98]
0000000141387045: ucomiss  xmm0, xmm9
0000000141387049: jp       0x14138705d
000000014138704b: jne      0x14138705d
000000014138704d: movss    xmm0, dword ptr [rdi + 0x9c]
0000000141387055: ucomiss  xmm0, xmm9
0000000141387059: jp       0x14138705d
000000014138705b: je       0x14138707f
000000014138705d: lea      r8, [rdi + 0x154]
0000000141387064: lea      rdx, [rbp - 0x50]
0000000141387068: lea      rcx, [rsp + 0x70]
000000014138706d: call     0x141280ad0
0000000141387072: mov      rdx, rax
0000000141387075: lea      rcx, [rsp + 0x70]
000000014138707a: call     0x14127e710
000000014138707f: movss    xmm1, dword ptr [rdi + 0x1f4]
0000000141387087: mulss    xmm1, dword ptr [rdi + 0x88]
000000014138708f: movss    xmm0, dword ptr [rdi + 0x108]
0000000141387097: movaps   xmm9, xmmword ptr [rsp + 0x110]
00000001413870a0: mulss    xmm1, xmm0
00000001413870a4: comiss   xmm10, xmm1
00000001413870a8: jae      0x1413870f9
00000001413870aa: movss    xmm2, dword ptr [rdi + 0x1f8]
00000001413870b2: mulss    xmm2, dword ptr [rdi + 0x8c]
00000001413870ba: mulss    xmm2, xmm0
00000001413870be: comiss   xmm10, xmm2
00000001413870c2: jae      0x1413870f9
00000001413870c4: movss    xmm3, dword ptr [rdi + 0x1fc]
00000001413870cc: mulss    xmm3, dword ptr [rdi + 0x90]
00000001413870d4: mulss    xmm3, xmm0
00000001413870d8: comiss   xmm10, xmm3
00000001413870dc: jae      0x1413870f9
00000001413870de: lea      rcx, [rsp + 0x50]
00000001413870e3: call     0x1411ab440
00000001413870e8: lea      rdx, [rsp + 0x50]
00000001413870ed: lea      rcx, [rsp + 0x70]
00000001413870f2: call     0x141281e90
00000001413870f7: jmp      0x1413870fc
00000001413870f9: xor      r14d, r14d
00000001413870fc: lea      rcx, [rdi + 0xa0]
0000000141387103: mov      dword ptr [rdi + 0x218], r14d
000000014138710a: lea      rdx, [rsp + 0x70]
000000014138710f: call     0x14127e710
0000000141387114: mov      edx, dword ptr [rdi + 0x218]
000000014138711a: mov      rcx, rdi
000000014138711d: call     0x14130b200
0000000141387122: mov      ebx, eax
0000000141387124: call     0x1400bfa80
0000000141387129: movsd    xmm0, qword ptr [rax]
000000014138712d: movsd    qword ptr [rdi + 0x1dc], xmm0
0000000141387135: mov      ecx, dword ptr [rax + 8]
0000000141387138: mov      dword ptr [rdi + 0x1e4], ecx
000000014138713e: mov      dword ptr [rdi + 0x198], 0x3f800000
0000000141387148: call     0x1400b07c0
000000014138714d: mov      ecx, dword ptr [rax + 0xd4]
0000000141387153: mov      dword ptr [rdi + 0x220], ecx
0000000141387159: call     0x1400b07c0
000000014138715e: movaps   xmm10, xmmword ptr [rsp + 0x100]
0000000141387167: mov      r14, qword ptr [rsp + 0x188]
000000014138716f: mov      rsi, qword ptr [rsp + 0x180]
0000000141387177: mov      ecx, dword ptr [rax + 0xd4]
000000014138717d: cmp      dword ptr [rax + 0xdc], ecx
0000000141387183: mov      eax, ebx
0000000141387185: jne      0x14138718d
