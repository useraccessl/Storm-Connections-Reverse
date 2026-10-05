0000000141337c60: mov      rax, rsp
0000000141337c63: mov      qword ptr [rax + 0x18], rbx
0000000141337c67: push     rbp
0000000141337c68: push     rsi
0000000141337c69: push     rdi
0000000141337c6a: push     r12
0000000141337c6c: push     r13
0000000141337c6e: push     r14
0000000141337c70: push     r15
0000000141337c72: lea      rbp, [rax - 0x1c8]
0000000141337c79: sub      rsp, 0x290
0000000141337c80: movaps   xmmword ptr [rax - 0x48], xmm6
0000000141337c84: movaps   xmmword ptr [rax - 0x58], xmm7
0000000141337c88: movaps   xmmword ptr [rax - 0x68], xmm8
0000000141337c8d: movaps   xmmword ptr [rax - 0x78], xmm9
0000000141337c92: movaps   xmmword ptr [rax - 0x88], xmm10
0000000141337c9a: mov      rax, qword ptr [rip + 0xdae727]
0000000141337ca1: xor      rax, rsp
0000000141337ca4: mov      qword ptr [rbp + 0x130], rax
0000000141337cab: mov      rdi, r8
0000000141337cae: mov      qword ptr [rsp + 0x58], rdx
0000000141337cb3: mov      rsi, rcx
0000000141337cb6: xor      r14d, r14d
0000000141337cb9: cmp      dword ptr [rip + 0xd96950], r14d
0000000141337cc0: je       0x141337d20
0000000141337cc2: test     r8, r8
0000000141337cc5: je       0x141337d20
0000000141337cc7: xorps    xmm0, xmm0
0000000141337cca: movups   xmmword ptr [rsp + 0x48], xmm0
0000000141337ccf: movq     rax, xmm0
0000000141337cd4: bts      rax, 0x11
0000000141337cd9: bts      rax, 0x12
0000000141337cde: bts      rax, 0x13
0000000141337ce3: bts      rax, 0x14
0000000141337ce8: bts      rax, 0x15
0000000141337ced: bts      rax, 0x28
0000000141337cf2: mov      qword ptr [rsp + 0x48], rax
0000000141337cf7: mov      edx, r14d
0000000141337cfa: lea      rcx, [rsp + 0x48]
0000000141337cff: lea      rax, [rsp + 0x48]
0000000141337d04: sub      r8, rax
0000000141337d07: mov      rax, qword ptr [r8 + rcx]
0000000141337d0b: test     qword ptr [rcx], rax
0000000141337d0e: jne      0x141337d20
0000000141337d10: inc      edx
0000000141337d12: add      rcx, 8
0000000141337d16: cmp      edx, 2
0000000141337d19: jb       0x141337d07
0000000141337d1b: jmp      0x141337ed3
0000000141337d20: call     0x1412e6730
0000000141337d25: mov      r15d, dword ptr [rax + 0x588]
0000000141337d2c: call     0x1412e6730
0000000141337d31: mov      rcx, rax
0000000141337d34: lea      rdx, [rsi + 0x190]
0000000141337d3b: call     0x1412e64b0
0000000141337d40: lea      rax, [rip - 0x11746c7]
0000000141337d47: mov      qword ptr [rsp + 0x20], rax
0000000141337d4c: lea      r9, [rip - 0xb9683]
0000000141337d53: mov      edx, 0x40
0000000141337d58: lea      r8d, [rdx - 0x3c]
0000000141337d5c: lea      rcx, [rbp + 0x30]
0000000141337d60: call     0x141441de0
0000000141337d65: nop      
0000000141337d66: lea      rbx, [rbp + 0x30]
0000000141337d6a: mov      r12d, 4
0000000141337d70: call     0x141284200
0000000141337d75: mov      rdx, rax
0000000141337d78: mov      rcx, rbx
0000000141337d7b: call     0x14127e710
0000000141337d80: add      rbx, 0x40
0000000141337d84: sub      r12, 1
0000000141337d88: jne      0x141337d70
0000000141337d8a: mov      r12d, r14d
0000000141337d8d: test     r15d, r15d
0000000141337d90: je       0x141337df8
0000000141337d92: lea      rbx, [rbp + 0x30]
0000000141337d96: lea      rcx, [rsp + 0x70]
0000000141337d9b: call     0x14127e6d0
0000000141337da0: call     0x1412e6730
0000000141337da5: mov      rcx, rax
0000000141337da8: lea      r8, [rsp + 0x70]
0000000141337dad: mov      edx, r12d
0000000141337db0: call     0x1412e67c0
0000000141337db5: lea      rdx, [rsp + 0x70]
0000000141337dba: mov      rcx, rbx
0000000141337dbd: call     0x14127e710
0000000141337dc2: lea      rdx, [rsi + 0x2e0]
0000000141337dc9: lea      rcx, [rbp - 0x50]
0000000141337dcd: call     0x14127e3b0
0000000141337dd2: mov      r8, rax
0000000141337dd5: lea      rdx, [rbp - 0x10]
0000000141337dd9: mov      rcx, rbx
0000000141337ddc: call     0x141280a10
0000000141337de1: mov      rdx, rax
0000000141337de4: mov      rcx, rbx
0000000141337de7: call     0x14127e710
0000000141337dec: inc      r12d
0000000141337def: add      rbx, 0x40
0000000141337df3: cmp      r12d, r15d
0000000141337df6: jb       0x141337d96
0000000141337df8: lea      rcx, [rsi + 0x1a0]
0000000141337dff: sub      r15d, 1
0000000141337e03: je       0x141337e43
0000000141337e05: sub      r15d, 1
0000000141337e09: lea      r12, [rbp + 0x70]
0000000141337e0d: je       0x141337e39
0000000141337e0f: sub      r15d, 1
0000000141337e13: je       0x141337e29
0000000141337e15: lea      rbx, [rbp + 0xf0]
0000000141337e1c: cmp      r15d, 1
0000000141337e20: lea      r15, [rbp + 0xb0]
0000000141337e27: jmp      0x141337e4f
0000000141337e29: lea      rbx, [rbp + 0xb0]
0000000141337e30: lea      r15, [rbp + 0xb0]
0000000141337e37: jmp      0x141337e4f
0000000141337e39: lea      rbx, [rbp + 0x70]
0000000141337e3d: lea      r15, [rbp + 0x70]
0000000141337e41: jmp      0x141337e4f
0000000141337e43: lea      rbx, [rbp + 0x30]
0000000141337e47: lea      r15, [rbp + 0x30]
0000000141337e4b: lea      r12, [rbp + 0x30]
0000000141337e4f: lea      rdx, [rbp + 0x30]
0000000141337e53: call     0x14127e710
0000000141337e58: mov      rdx, r12
0000000141337e5b: lea      rcx, [rsi + 0x1e0]
0000000141337e62: call     0x14127e710
0000000141337e67: mov      rdx, r15
0000000141337e6a: lea      rcx, [rsi + 0x220]
0000000141337e71: call     0x14127e710
0000000141337e76: mov      rdx, rbx
0000000141337e79: lea      rcx, [rsi + 0x260]
0000000141337e80: call     0x14127e710
0000000141337e85: call     0x1412e6730
0000000141337e8a: mov      rcx, rax
0000000141337e8d: call     0x1412e68a0
0000000141337e92: mov      rcx, rax
0000000141337e95: xor      edx, edx
0000000141337e97: call     0x1412d5fe0
0000000141337e9c: mov      dword ptr [rsi + 0x448], eax
0000000141337ea2: movabs   rax, 0x400200066
0000000141337eac: mov      qword ptr [rsi + 0x440], rax
0000000141337eb3: mov      dword ptr [rsi + 0x44c], r14d
0000000141337eba: lea      r9, [rip - 0x1174841]
0000000141337ec1: mov      edx, 0x40
0000000141337ec6: lea      r8d, [rdx - 0x3c]
0000000141337eca: lea      rcx, [rbp + 0x30]
0000000141337ece: call     0x14144142c
0000000141337ed3: mov      rcx, qword ptr [rip + 0x83d163e]
0000000141337eda: movzx    r12d, word ptr [rcx + 0x4a6]
0000000141337ee2: movzx    r15d, word ptr [rcx + 0x4a8]
0000000141337eea: mov      r13, qword ptr [rcx + 0x578]
0000000141337ef1: xor      edx, edx
0000000141337ef3: mov      rcx, qword ptr [rcx + 0x580]
0000000141337efa: call     0x1412d5fe0
0000000141337eff: mov      ebx, eax
0000000141337f01: mov      edx, dword ptr [rip + 0xd96709]
0000000141337f07: test     edx, edx
0000000141337f09: je       0x141337f1c
0000000141337f0b: test     rdi, rdi
0000000141337f0e: je       0x141337f1c
0000000141337f10: mov      rcx, qword ptr [rdi]
0000000141337f13: shr      rcx, 0x29
0000000141337f17: and      ecx, 1
0000000141337f1a: je       0x141337f42
0000000141337f1c: call     0x141352290
0000000141337f21: mov      ecx, dword ptr [rax + 0x38]
0000000141337f24: mov      dword ptr [rsi + 0x458], ecx
0000000141337f2a: mov      qword ptr [rsi + 0x450], 0x100333
0000000141337f35: mov      dword ptr [rsi + 0x45c], r14d
0000000141337f3c: mov      edx, dword ptr [rip + 0xd966ce]
0000000141337f42: test     edx, edx
0000000141337f44: je       0x141337f57
0000000141337f46: test     rdi, rdi
0000000141337f49: je       0x141337f57
0000000141337f4b: mov      rax, qword ptr [rdi]
0000000141337f4e: shr      rax, 0x2a
0000000141337f52: and      eax, 1
0000000141337f55: je       0x141337f7d
0000000141337f57: call     0x141352290
0000000141337f5c: mov      ecx, dword ptr [rax + 0x40]
0000000141337f5f: mov      dword ptr [rsi + 0x468], ecx
0000000141337f65: mov      qword ptr [rsi + 0x460], 0x100333
0000000141337f70: mov      dword ptr [rsi + 0x46c], r14d
0000000141337f77: mov      edx, dword ptr [rip + 0xd96693]
0000000141337f7d: test     edx, edx
0000000141337f7f: je       0x141337f92
0000000141337f81: test     rdi, rdi
0000000141337f84: je       0x141337f92
0000000141337f86: mov      rax, qword ptr [rdi]
0000000141337f89: shr      rax, 0x2b
0000000141337f8d: and      eax, 1
0000000141337f90: je       0x141337fb8
0000000141337f92: call     0x141352290
0000000141337f97: mov      ecx, dword ptr [rax + 0x48]
0000000141337f9a: mov      dword ptr [rsi + 0x478], ecx
0000000141337fa0: mov      qword ptr [rsi + 0x470], 0x100333
0000000141337fab: mov      dword ptr [rsi + 0x47c], r14d
0000000141337fb2: mov      edx, dword ptr [rip + 0xd96658]
0000000141337fb8: test     edx, edx
0000000141337fba: je       0x141337fcd
0000000141337fbc: test     rdi, rdi
0000000141337fbf: je       0x141337fcd
0000000141337fc1: mov      eax, dword ptr [rdi + 8]
0000000141337fc4: shr      rax, 3
0000000141337fc8: and      eax, 1
0000000141337fcb: je       0x141337feb
0000000141337fcd: mov      dword ptr [rsi + 0x4b8], ebx
0000000141337fd3: mov      qword ptr [rsi + 0x4b0], 0x100333
0000000141337fde: mov      dword ptr [rsi + 0x4bc], r14d
0000000141337fe5: mov      edx, dword ptr [rip + 0xd96625]
0000000141337feb: test     edx, edx
0000000141337fed: je       0x141338000
0000000141337fef: test     rdi, rdi
0000000141337ff2: je       0x141338000
0000000141337ff4: mov      rax, qword ptr [rdi]
0000000141337ff7: shr      rax, 0x2c
0000000141337ffb: and      eax, 1
0000000141337ffe: je       0x14133802b
0000000141338000: mov      edx, 1
0000000141338005: mov      rcx, r13
0000000141338008: call     0x1412d5fe0
000000014133800d: mov      dword ptr [rsi + 0x488], eax
0000000141338013: mov      qword ptr [rsi + 0x480], 0x100333
000000014133801e: mov      dword ptr [rsi + 0x48c], r14d
0000000141338025: mov      edx, dword ptr [rip + 0xd965e5]
000000014133802b: test     edx, edx
000000014133802d: je       0x141338040
000000014133802f: test     rdi, rdi
0000000141338032: je       0x141338040
0000000141338034: mov      rax, qword ptr [rdi]
0000000141338037: shr      rax, 0x2d
000000014133803b: and      eax, 1
000000014133803e: je       0x141338066
0000000141338040: call     0x141352290
0000000141338045: mov      ecx, dword ptr [rax + 0x44]
0000000141338048: mov      dword ptr [rsi + 0x498], ecx
000000014133804e: mov      qword ptr [rsi + 0x490], 0x100333
0000000141338059: mov      dword ptr [rsi + 0x49c], r14d
0000000141338060: mov      edx, dword ptr [rip + 0xd965aa]
0000000141338066: test     edx, edx
0000000141338068: je       0x14133807b
000000014133806a: test     rdi, rdi
000000014133806d: je       0x14133807b
000000014133806f: mov      rax, qword ptr [rdi]
0000000141338072: shr      rax, 0x2e
0000000141338076: and      eax, 1
0000000141338079: je       0x1413380ab
000000014133807b: xor      edx, edx
000000014133807d: mov      rcx, qword ptr [rip + 0x83d1494]
0000000141338084: mov      rcx, qword ptr [rcx + 8]
0000000141338088: call     0x1412d5fe0
000000014133808d: mov      dword ptr [rsi + 0x4a8], eax
0000000141338093: mov      qword ptr [rsi + 0x4a0], 0x111333
000000014133809e: mov      dword ptr [rsi + 0x4ac], r14d
00000001413380a5: mov      edx, dword ptr [rip + 0xd96565]
00000001413380ab: movss    xmm6, dword ptr [rip + 0x42952d]
00000001413380b3: xorps    xmm7, xmm7
00000001413380b6: test     edx, edx
00000001413380b8: je       0x1413380df
00000001413380ba: test     rdi, rdi
00000001413380bd: je       0x1413380df
00000001413380bf: mov      rax, qword ptr [rdi]
00000001413380c2: shr      rax, 0x20
00000001413380c6: and      eax, 1
00000001413380c9: jne      0x1413380df
00000001413380cb: xorps    xmm8, xmm8
00000001413380cf: cvtsi2ss xmm8, r15
00000001413380d4: xorps    xmm9, xmm9
00000001413380d8: cvtsi2ss xmm9, r12
00000001413380dd: jmp      0x14133811c
00000001413380df: xorps    xmm8, xmm8
00000001413380e3: cvtsi2ss xmm8, r15
00000001413380e8: xorps    xmm9, xmm9
00000001413380ec: cvtsi2ss xmm9, r12
00000001413380f1: movaps   xmm2, xmm6
00000001413380f4: divss    xmm2, xmm8
00000001413380f9: movaps   xmm1, xmm6
00000001413380fc: divss    xmm1, xmm9
0000000141338101: lea      rcx, [rsi + 0x500]
0000000141338108: movss    dword ptr [rsp + 0x20], xmm7
000000014133810e: xorps    xmm3, xmm3
0000000141338111: call     0x1412a96c0
0000000141338116: mov      edx, dword ptr [rip + 0xd964f4]
000000014133811c: movss    xmm10, dword ptr [rip + 0x432323]
0000000141338125: test     edx, edx
0000000141338127: je       0x14133813e
0000000141338129: test     rdi, rdi
000000014133812c: je       0x14133813e
000000014133812e: mov      rax, qword ptr [rdi]
0000000141338131: shr      rax, 0x31
0000000141338135: and      eax, 1
0000000141338138: je       0x1413381d2
000000014133813e: lea      rax, [rsp + 0x60]
0000000141338143: mov      qword ptr [rsp + 0x28], rax
0000000141338148: lea      rax, [rsp + 0x34]
000000014133814d: mov      qword ptr [rsp + 0x20], rax
0000000141338152: lea      r9, [rsp + 0x38]
0000000141338157: lea      r8, [rsp + 0x40]
000000014133815c: lea      rdx, [rsp + 0x3c]
0000000141338161: lea      rcx, [rsp + 0x30]
0000000141338166: call     0x14121c520
000000014133816b: xorps    xmm0, xmm0
000000014133816e: cvtsi2ss xmm0, r12
0000000141338173: movss    xmm2, dword ptr [rsp + 0x38]
0000000141338179: movaps   xmm4, xmm2
000000014133817c: mulss    xmm4, xmm10
0000000141338181: addss    xmm4, dword ptr [rsp + 0x3c]
0000000141338187: divss    xmm4, xmm8
000000014133818c: movss    xmm1, dword ptr [rsp + 0x40]
0000000141338192: movaps   xmm3, xmm1
0000000141338195: mulss    xmm3, xmm10
000000014133819a: addss    xmm3, dword ptr [rsp + 0x30]
00000001413381a0: divss    xmm3, xmm0
00000001413381a4: divss    xmm2, xmm8
00000001413381a9: mulss    xmm2, dword ptr [rip + 0x4322c3]
00000001413381b1: divss    xmm1, xmm0
00000001413381b5: mulss    xmm1, xmm10
00000001413381ba: lea      rcx, [rsi + 0x4e0]
00000001413381c1: movss    dword ptr [rsp + 0x20], xmm4
00000001413381c7: call     0x1412a96c0
00000001413381cc: mov      edx, dword ptr [rip + 0xd9643e]
00000001413381d2: mov      rcx, qword ptr [rsp + 0x58]
00000001413381d7: test     rcx, rcx
00000001413381da: je       0x14133829a
00000001413381e0: test     edx, edx
00000001413381e2: je       0x1413381f5
00000001413381e4: test     rdi, rdi
00000001413381e7: je       0x1413381f5
00000001413381e9: mov      rax, qword ptr [rdi]
00000001413381ec: shr      rax, 0x3a
00000001413381f0: and      eax, 1
00000001413381f3: je       0x141338247
00000001413381f5: movss    xmm0, dword ptr [rcx + 0x258]
00000001413381fd: movss    xmm4, dword ptr [rcx + 0x25c]
0000000141338205: subss    xmm4, xmm0
0000000141338209: mulss    xmm4, xmm10
000000014133820e: movaps   xmm2, xmm4
0000000141338211: addss    xmm2, xmm0
0000000141338215: addss    xmm2, xmm2
0000000141338219: xorps    xmm2, xmmword ptr [rip + 0x428f80]
0000000141338220: movaps   xmm1, xmm6
0000000141338223: divss    xmm1, xmm4
0000000141338227: lea      rcx, [rsi + 0x630]
000000014133822e: movss    dword ptr [rsp + 0x20], xmm7
0000000141338234: xorps    xmm3, xmm3
0000000141338237: call     0x1412a96c0
000000014133823c: mov      edx, dword ptr [rip + 0xd963ce]
0000000141338242: mov      rcx, qword ptr [rsp + 0x58]
0000000141338247: test     edx, edx
0000000141338249: je       0x14133825c
000000014133824b: test     rdi, rdi
000000014133824e: je       0x14133825c
0000000141338250: mov      rax, qword ptr [rdi]
0000000141338253: shr      rax, 0x3b
0000000141338257: and      eax, 1
000000014133825a: je       0x14133829a
000000014133825c: movss    xmm1, dword ptr [rcx + 0x230]
0000000141338264: movss    xmm0, dword ptr [rcx + 0x234]
000000014133826c: movaps   xmm3, xmm0
000000014133826f: addss    xmm3, xmm1
0000000141338273: movaps   xmm2, xmm0
0000000141338276: subss    xmm2, xmm1
000000014133827a: addss    xmm1, xmm1
000000014133827e: mulss    xmm1, xmm0
0000000141338282: lea      rcx, [rsi + 0x640]
0000000141338289: movss    dword ptr [rsp + 0x20], xmm6
000000014133828f: call     0x1412a96c0
0000000141338294: mov      edx, dword ptr [rip + 0xd96376]
000000014133829a: test     edx, edx
000000014133829c: je       0x1413382e8
000000014133829e: test     rdi, rdi
00000001413382a1: je       0x1413382e8
00000001413382a3: xorps    xmm0, xmm0
00000001413382a6: movups   xmmword ptr [rsp + 0x48], xmm0
00000001413382ab: movq     rax, xmm0
00000001413382b0: bts      rax, 0x37
00000001413382b5: bts      rax, 0x38
00000001413382ba: bts      rax, 0x39
00000001413382bf: mov      qword ptr [rsp + 0x48], rax
00000001413382c4: lea      rcx, [rsp + 0x48]
00000001413382c9: sub      rcx, rdi
00000001413382cc: nop      dword ptr [rax]
00000001413382d0: mov      rax, qword ptr [rcx + rdi]
00000001413382d4: test     qword ptr [rdi], rax
00000001413382d7: jne      0x1413382e8
00000001413382d9: inc      r14d
00000001413382dc: add      rdi, 8
00000001413382e0: cmp      r14d, 2
00000001413382e4: jb       0x1413382d0
00000001413382e6: jmp      0x141338305
00000001413382e8: movaps   xmm0, xmm6
00000001413382eb: divss    xmm0, xmm9
00000001413382f0: movss    dword ptr [rsi + 0x60c], xmm0
00000001413382f8: divss    xmm6, xmm8
00000001413382fd: movss    dword ptr [rsi + 0x61c], xmm6
0000000141338305: mov      rcx, qword ptr [rbp + 0x130]
000000014133830c: xor      rcx, rsp
000000014133830f: call     0x141441dc0
0000000141338314: lea      r11, [rsp + 0x290]
000000014133831c: mov      rbx, qword ptr [r11 + 0x50]
0000000141338320: movaps   xmm6, xmmword ptr [r11 - 0x10]
0000000141338325: movaps   xmm7, xmmword ptr [r11 - 0x20]
000000014133832a: movaps   xmm8, xmmword ptr [r11 - 0x30]
000000014133832f: movaps   xmm9, xmmword ptr [r11 - 0x40]
0000000141338334: movaps   xmm10, xmmword ptr [r11 - 0x50]
0000000141338339: mov      rsp, r11
000000014133833c: pop      r15
000000014133833e: pop      r14
0000000141338340: pop      r13
0000000141338342: pop      r12
0000000141338344: pop      rdi
0000000141338345: pop      rsi
0000000141338346: pop      rbp
0000000141338347: ret      
