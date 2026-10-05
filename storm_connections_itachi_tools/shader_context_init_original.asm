00000001413368f0: mov      rax, rsp
00000001413368f3: push     rbp
00000001413368f4: push     rbx
00000001413368f5: push     rsi
00000001413368f6: push     rdi
00000001413368f7: push     r12
00000001413368f9: push     r13
00000001413368fb: push     r14
00000001413368fd: push     r15
00000001413368ff: lea      rbp, [rax - 0x2b8]
0000000141336906: sub      rsp, 0x378
000000014133690d: movaps   xmmword ptr [rax - 0x58], xmm6
0000000141336911: movaps   xmmword ptr [rax - 0x68], xmm7
0000000141336915: movaps   xmmword ptr [rax - 0x78], xmm8
000000014133691a: movaps   xmmword ptr [rax - 0x88], xmm9
0000000141336922: movaps   xmmword ptr [rax - 0x98], xmm10
000000014133692a: mov      rax, qword ptr [rip + 0xdafa97]
0000000141336931: xor      rax, rsp
0000000141336934: mov      qword ptr [rbp + 0x210], rax
000000014133693b: mov      rdi, r9
000000014133693e: mov      qword ptr [rsp + 0x68], r9
0000000141336943: mov      qword ptr [rsp + 0x78], r8
0000000141336948: mov      r13, rdx
000000014133694b: mov      r14, rcx
000000014133694e: mov      rax, qword ptr [rbp + 0x2e0]
0000000141336955: mov      qword ptr [rsp + 0x50], rax
000000014133695a: mov      rax, qword ptr [rbp + 0x2e8]
0000000141336961: mov      qword ptr [rsp + 0x40], rax
0000000141336966: mov      eax, dword ptr [rbp + 0x310]
000000014133696c: mov      dword ptr [rsp + 0x30], eax
0000000141336970: mov      rax, qword ptr [rbp + 0x318]
0000000141336977: mov      qword ptr [rsp + 0x58], rax
000000014133697c: xor      r15d, r15d
000000014133697f: lea      rcx, [rbp + 0x90]
0000000141336986: call     0x141312be0
000000014133698b: nop      
000000014133698c: mov      rsi, qword ptr [rbp + 0x320]
0000000141336993: cmp      dword ptr [rip + 0xd97c76], r15d
000000014133699a: jne      0x1413369ad
000000014133699c: mov      r12d, 1
00000001413369a2: mov      ebx, r12d
00000001413369a5: mov      eax, r12d
00000001413369a8: jmp      0x141336a86
00000001413369ad: test     rsi, rsi
00000001413369b0: jne      0x1413369c3
00000001413369b2: mov      r12d, 1
00000001413369b8: mov      ebx, r12d
00000001413369bb: mov      eax, r12d
00000001413369be: jmp      0x141336a86
00000001413369c3: xorps    xmm0, xmm0
00000001413369c6: movups   xmmword ptr [rbp - 0x40], xmm0
00000001413369ca: movq     rax, xmm0
00000001413369cf: bts      rax, 2
00000001413369d4: bts      rax, 3
00000001413369d9: bts      rax, 0
00000001413369de: mov      qword ptr [rbp - 0x40], rax
00000001413369e2: xor      edx, edx
00000001413369e4: mov      rcx, rsi
00000001413369e7: lea      r8, [rbp - 0x40]
00000001413369eb: sub      r8, rsi
00000001413369ee: nop      
00000001413369f0: mov      rax, qword ptr [r8 + rcx]
00000001413369f4: mov      r12d, 1
00000001413369fa: test     qword ptr [rcx], rax
00000001413369fd: jne      0x141336a0e
00000001413369ff: inc      edx
0000000141336a01: add      rcx, 8
0000000141336a05: cmp      edx, 2
0000000141336a08: jb       0x1413369f0
0000000141336a0a: xor      ebx, ebx
0000000141336a0c: jmp      0x141336a11
0000000141336a0e: mov      ebx, r12d
0000000141336a11: xorps    xmm0, xmm0
0000000141336a14: movups   xmmword ptr [rbp - 0x40], xmm0
0000000141336a18: movq     rax, xmm0
0000000141336a1d: bts      rax, 4
0000000141336a22: bts      rax, 5
0000000141336a27: bts      rax, 6
0000000141336a2c: bts      rax, 7
0000000141336a31: bts      rax, 8
0000000141336a36: bts      rax, 9
0000000141336a3b: bts      rax, 0xa
0000000141336a40: bts      rax, 0xb
0000000141336a45: bts      rax, 0xc
0000000141336a4a: mov      qword ptr [rbp - 0x40], rax
0000000141336a4e: xor      edx, edx
0000000141336a50: mov      rcx, rsi
0000000141336a53: lea      r8, [rbp - 0x40]
0000000141336a57: sub      r8, rsi
0000000141336a5a: nop      word ptr [rax + rax]
0000000141336a60: mov      rax, qword ptr [r8 + rcx]
0000000141336a64: test     qword ptr [rcx], rax
0000000141336a67: jne      0x141336a78
0000000141336a69: inc      edx
0000000141336a6b: add      rcx, 8
0000000141336a6f: cmp      edx, 2
0000000141336a72: jb       0x141336a60
0000000141336a74: xor      eax, eax
0000000141336a76: jmp      0x141336a7b
0000000141336a78: mov      eax, r12d
0000000141336a7b: mov      r12d, dword ptr [rsi]
0000000141336a7e: shr      r12, 0x17
0000000141336a82: and      r12d, 1
0000000141336a86: mov      dword ptr [rsp + 0x34], eax
0000000141336a8a: movss    xmm9, dword ptr [rip + 0x42ab4d]
0000000141336a93: xorps    xmm10, xmm10
0000000141336a97: test     rdi, rdi
0000000141336a9a: je       0x141336b02
0000000141336a9c: test     ebx, ebx
0000000141336a9e: jne      0x141336aad
0000000141336aa0: test     eax, eax
0000000141336aa2: jne      0x141336aad
0000000141336aa4: test     r12d, r12d
0000000141336aa7: je       0x141336dbd
0000000141336aad: mov      edx, dword ptr [rsp + 0x30]
0000000141336ab1: mov      rcx, r13
0000000141336ab4: call     0x1412b59f0
0000000141336ab9: mov      rdi, rax
0000000141336abc: test     rax, rax
0000000141336abf: je       0x141336af7
0000000141336ac1: mov      r8, qword ptr [rsp + 0x58]
0000000141336ac6: lea      rdx, [rsp + 0x58]
0000000141336acb: mov      rcx, qword ptr [rsp + 0x68]
0000000141336ad0: call     0x141283d60
0000000141336ad5: movss    xmm3, dword ptr [rbp + 0x328]
0000000141336add: lea      r8, [rsp + 0x58]
0000000141336ae2: mov      rdx, r13
0000000141336ae5: lea      rcx, [rbp + 0x90]
0000000141336aec: call     rdi
0000000141336aee: lea      r15, [rbp + 0x90]
0000000141336af5: jmp      0x141336b02
0000000141336af7: mov      rcx, r13
0000000141336afa: call     0x1412b5a00
0000000141336aff: mov      r15, rax
0000000141336b02: movss    xmm6, dword ptr [rip + 0x542b12]
0000000141336b0a: test     ebx, ebx
0000000141336b0c: je       0x141336c1c
0000000141336b12: xor      ebx, ebx
0000000141336b14: movzx    eax, byte ptr [r15 + 0x170]
0000000141336b1c: test     al, al
0000000141336b1e: je       0x141336b7c
0000000141336b20: mov      eax, ebx
0000000141336b22: mov      ecx, ebx
0000000141336b24: shl      rcx, 4
0000000141336b28: mov      edx, ebx
0000000141336b2a: shl      rdx, 5
0000000141336b2e: movups   xmm0, xmmword ptr [rdx + r15 + 0x30]
0000000141336b34: movups   xmmword ptr [rcx + r14], xmm0
0000000141336b39: add      rax, 2
0000000141336b3d: shl      rax, 5
0000000141336b41: add      rcx, 0x40
0000000141336b45: add      rcx, r14
0000000141336b48: movss    xmm0, dword ptr [rdx + r15 + 0x4c]
0000000141336b4f: movss    dword ptr [rsp + 0x20], xmm0
0000000141336b55: movss    xmm3, dword ptr [rdx + r15 + 0x48]
0000000141336b5c: movss    xmm2, dword ptr [rdx + r15 + 0x44]
0000000141336b63: movss    xmm1, dword ptr [rax + r15]
0000000141336b69: call     0x1412a96c0
0000000141336b6e: inc      ebx
0000000141336b70: movzx    eax, byte ptr [r15 + 0x170]
0000000141336b78: cmp      ebx, eax
0000000141336b7a: jb       0x141336b20
0000000141336b7c: movzx    ecx, al
0000000141336b7f: cmp      ecx, 4
0000000141336b82: jae      0x141336bb5
0000000141336b84: mov      ebx, ecx
0000000141336b86: shl      rbx, 4
0000000141336b8a: add      rbx, r14
0000000141336b8d: mov      edi, 4
0000000141336b92: sub      edi, ecx
0000000141336b94: call     0x1412a9cd0
0000000141336b99: movups   xmm0, xmmword ptr [rax]
0000000141336b9c: movups   xmmword ptr [rbx], xmm0
0000000141336b9f: call     0x1412a9c60
0000000141336ba4: movups   xmm0, xmmword ptr [rax]
0000000141336ba7: movups   xmmword ptr [rbx + 0x40], xmm0
0000000141336bab: lea      rbx, [rbx + 0x10]
0000000141336baf: sub      rdi, 1
0000000141336bb3: jne      0x141336b94
0000000141336bb5: lea      rdx, [rbp - 0x30]
0000000141336bb9: mov      rcx, qword ptr [rsp + 0x50]
0000000141336bbe: call     0x141280580
0000000141336bc3: mov      rdx, rax
0000000141336bc6: lea      rcx, [rbp + 0x10]
0000000141336bca: call     0x14127e710
0000000141336bcf: mov      rcx, r14
0000000141336bd2: call     0x1412a8df0
0000000141336bd7: comiss   xmm0, xmm6
0000000141336bda: jbe      0x141336c0c
0000000141336bdc: lea      rdx, [rsp + 0x68]
0000000141336be1: mov      rcx, r14
0000000141336be4: call     0x1412a9ae0
0000000141336be9: mov      r8, rax
0000000141336bec: lea      rdx, [rsp + 0x58]
0000000141336bf1: lea      rcx, [rbp + 0x10]
0000000141336bf5: call     0x141283c40
0000000141336bfa: mov      rdx, rax
0000000141336bfd: movaps   xmm2, xmm10
0000000141336c01: lea      rcx, [rbp - 0x40]
0000000141336c05: call     0x1412a7d80
0000000141336c0a: jmp      0x141336c11
0000000141336c0c: call     0x1412a9cd0
0000000141336c11: movups   xmm0, xmmword ptr [rax]
0000000141336c14: movups   xmmword ptr [r14 + 0x80], xmm0
0000000141336c1c: cmp      dword ptr [rsp + 0x34], 0
0000000141336c21: je       0x141336dbd
0000000141336c27: mov      dword ptr [rsp + 0x30], 0
0000000141336c2f: movzx    eax, byte ptr [r15 + 0x171]
0000000141336c37: test     al, al
0000000141336c39: je       0x141336d4a
0000000141336c3f: movss    xmm7, dword ptr [rip + 0x46a1f9]
0000000141336c47: mov      esi, dword ptr [rsp + 0x30]
0000000141336c4b: nop      dword ptr [rax + rax]
0000000141336c50: mov      ebx, esi
0000000141336c52: lea      rdi, [rbx + rbx*2]
0000000141336c56: add      rdi, rdi
0000000141336c59: mov      ecx, esi
0000000141336c5b: shl      rcx, 4
0000000141336c5f: mov      qword ptr [rsp + 0x68], rcx
0000000141336c64: lea      rax, [rbx + 4]
0000000141336c68: lea      rax, [rax + rax*2]
0000000141336c6c: add      rax, rax
0000000141336c6f: add      rcx, 0x90
0000000141336c76: add      rcx, r14
0000000141336c79: movss    xmm0, dword ptr [r15 + rdi*8 + 0xcc]
0000000141336c83: movss    dword ptr [rsp + 0x20], xmm0
0000000141336c89: movss    xmm3, dword ptr [r15 + rdi*8 + 0xc8]
0000000141336c93: movss    xmm2, dword ptr [r15 + rdi*8 + 0xc4]
0000000141336c9d: movss    xmm1, dword ptr [r15 + rax*8]
0000000141336ca3: call     0x1412a96c0
0000000141336ca8: lea      rax, [rbx + 0xd]
0000000141336cac: add      rax, rax
0000000141336caf: movups   xmm0, xmmword ptr [r15 + rdi*8 + 0xb0]
0000000141336cb8: movups   xmmword ptr [r14 + rax*8], xmm0
0000000141336cbd: movss    xmm1, dword ptr [r15 + rdi*8 + 0xd8]
0000000141336cc7: lea      rax, [rbx + 0x11]
0000000141336ccb: add      rax, rax
0000000141336cce: movss    dword ptr [r14 + rax*8], xmm1
0000000141336cd4: movss    xmm3, dword ptr [r15 + rdi*8 + 0xd0]
0000000141336cde: movss    xmm2, dword ptr [r15 + rdi*8 + 0xd4]
0000000141336ce8: movaps   xmm1, xmm2
0000000141336ceb: mulss    xmm1, xmm6
0000000141336cef: movaps   xmm0, xmm2
0000000141336cf2: subss    xmm0, xmm3
0000000141336cf6: andps    xmm0, xmm7
0000000141336cf9: comiss   xmm1, xmm0
0000000141336cfc: jbe      0x141336d02
0000000141336cfe: addss    xmm2, xmm1
0000000141336d02: mov      rax, qword ptr [rsp + 0x68]
0000000141336d07: movss    dword ptr [r14 + rax + 0x114], xmm3
0000000141336d11: movss    dword ptr [r14 + rax + 0x118], xmm2
0000000141336d1b: subss    xmm2, xmm3
0000000141336d1f: movaps   xmm0, xmm9
0000000141336d23: divss    xmm0, xmm2
0000000141336d27: movss    dword ptr [r14 + rax + 0x11c], xmm0
0000000141336d31: inc      esi
0000000141336d33: movzx    eax, byte ptr [r15 + 0x171]
0000000141336d3b: cmp      esi, eax
0000000141336d3d: jb       0x141336c50
0000000141336d43: mov      rsi, qword ptr [rbp + 0x320]
0000000141336d4a: movzx    ecx, al
0000000141336d4d: cmp      ecx, 4
0000000141336d50: jae      0x141336dbd
0000000141336d52: mov      edi, ecx
0000000141336d54: shl      rdi, 4
0000000141336d58: lea      rbx, [rcx + 0xd]
0000000141336d5c: shl      rbx, 4
0000000141336d60: add      rbx, r14
0000000141336d63: mov      esi, 4
0000000141336d68: sub      esi, ecx
0000000141336d6a: nop      word ptr [rax + rax]
0000000141336d70: call     0x1412a9c60
0000000141336d75: movups   xmm0, xmmword ptr [rax]
0000000141336d78: movups   xmmword ptr [rbx - 0x40], xmm0
0000000141336d7c: call     0x1412a9c60
0000000141336d81: movups   xmm0, xmmword ptr [rax]
0000000141336d84: movups   xmmword ptr [rbx], xmm0
0000000141336d87: lea      rcx, [r14 + 0x110]
0000000141336d8e: add      rcx, rdi
0000000141336d91: movss    dword ptr [rsp + 0x20], xmm6
0000000141336d97: movaps   xmm3, xmm9
0000000141336d9b: movaps   xmm2, xmm10
0000000141336d9f: movaps   xmm1, xmm10
0000000141336da3: call     0x1412a96c0
0000000141336da8: add      rdi, 0x10
0000000141336dac: lea      rbx, [rbx + 0x10]
0000000141336db0: sub      rsi, 1
0000000141336db4: jne      0x141336d70
0000000141336db6: mov      rsi, qword ptr [rbp + 0x320]
0000000141336dbd: cmp      dword ptr [rip + 0xd9784c], 0
0000000141336dc4: je       0x141336dd6
0000000141336dc6: test     rsi, rsi
0000000141336dc9: je       0x141336dd6
0000000141336dcb: mov      eax, dword ptr [rsi]
0000000141336dcd: shr      rax, 0x10
0000000141336dd1: and      eax, 1
0000000141336dd4: je       0x141336e1d
0000000141336dd6: mov      rdi, qword ptr [rsp + 0x78]
0000000141336ddb: lea      rcx, [rdi + 0x124]
0000000141336de2: mov      rbx, qword ptr [rsp + 0x50]
0000000141336de7: mov      r8, rbx
0000000141336dea: lea      rdx, [rbp - 0x30]
0000000141336dee: call     0x141280a10
0000000141336df3: mov      rdx, rax
0000000141336df6: lea      rcx, [rbp + 0x10]
0000000141336dfa: call     0x14127e710
0000000141336dff: lea      rdx, [rbp - 0x30]
0000000141336e03: lea      rcx, [rbp + 0x10]
0000000141336e07: call     0x141280450
0000000141336e0c: mov      rdx, rax
0000000141336e0f: lea      rcx, [r14 + 0x150]
0000000141336e16: call     0x14127e710
0000000141336e1b: jmp      0x141336e27
0000000141336e1d: mov      rbx, qword ptr [rsp + 0x50]
0000000141336e22: mov      rdi, qword ptr [rsp + 0x78]
0000000141336e27: cmp      dword ptr [rip + 0xd977e2], 0
0000000141336e2e: je       0x141336e40
0000000141336e30: test     rsi, rsi
0000000141336e33: je       0x141336e40
0000000141336e35: mov      eax, dword ptr [rsi]
0000000141336e37: shr      rax, 0x16
0000000141336e3b: and      eax, 1
0000000141336e3e: je       0x141336e55
0000000141336e40: mov      rcx, r13
0000000141336e43: call     0x1412b5980
0000000141336e48: movss    xmm0, dword ptr [rax]
0000000141336e4c: movss    dword ptr [r14 + 0x2a0], xmm0
0000000141336e55: test     r12d, r12d
0000000141336e58: je       0x141336e67
0000000141336e5a: movups   xmm0, xmmword ptr [r15 + 0x20]
0000000141336e5f: movups   xmmword ptr [r14 + 0x2b0], xmm0
0000000141336e67: cmp      dword ptr [rip + 0xd977a2], 0
0000000141336e6e: je       0x141336e80
0000000141336e70: test     rsi, rsi
0000000141336e73: je       0x141336e80
0000000141336e75: mov      eax, dword ptr [rsi]
0000000141336e77: shr      rax, 0x18
0000000141336e7b: and      eax, 1
0000000141336e7e: je       0x141336ebf
0000000141336e80: mov      rcx, r13
0000000141336e83: call     0x1412b59c0
0000000141336e88: movss    xmm7, dword ptr [rax + 8]
0000000141336e8d: mov      rcx, r13
0000000141336e90: call     0x1412b59c0
0000000141336e95: movss    xmm6, dword ptr [rax + 4]
0000000141336e9a: mov      rcx, r13
0000000141336e9d: call     0x1412b59c0
0000000141336ea2: lea      rcx, [r14 + 0x2c0]
0000000141336ea9: movss    dword ptr [rsp + 0x20], xmm9
0000000141336eb0: movaps   xmm3, xmm7
0000000141336eb3: movaps   xmm2, xmm6
0000000141336eb6: movss    xmm1, dword ptr [rax]
0000000141336eba: call     0x1412a96c0
0000000141336ebf: cmp      dword ptr [rip + 0xd9774a], 0
0000000141336ec6: je       0x141336ed8
0000000141336ec8: test     rsi, rsi
0000000141336ecb: je       0x141336ed8
0000000141336ecd: mov      eax, dword ptr [rsi]
0000000141336ecf: shr      rax, 0x19
0000000141336ed3: and      eax, 1
0000000141336ed6: je       0x141336f27
0000000141336ed8: mov      rcx, r13
0000000141336edb: call     0x1412b59c0
0000000141336ee0: movss    xmm7, dword ptr [rax + 0x10]
0000000141336ee5: mov      rcx, r13
0000000141336ee8: call     0x1412b59c0
0000000141336eed: movss    xmm6, dword ptr [rax + 0x14]
0000000141336ef2: ucomiss  xmm6, xmm7
0000000141336ef5: jp       0x141336f01
0000000141336ef7: jne      0x141336f01
0000000141336ef9: addss    xmm6, dword ptr [rip + 0x431ae7]
0000000141336f01: mov      rcx, r13
0000000141336f04: call     0x1412b59c0
0000000141336f09: lea      rcx, [r14 + 0x2d0]
0000000141336f10: movss    dword ptr [rsp + 0x20], xmm9
0000000141336f17: movss    xmm3, dword ptr [rax + 0x18]
0000000141336f1c: movaps   xmm2, xmm6
0000000141336f1f: movaps   xmm1, xmm7
0000000141336f22: call     0x1412a96c0
0000000141336f27: lea      rcx, [r14 + 0x2e0]
0000000141336f2e: mov      rdx, rbx
0000000141336f31: call     0x14127e710
0000000141336f36: mov      edx, dword ptr [rip + 0xd976d4]
0000000141336f3c: test     edx, edx
0000000141336f3e: je       0x141336f50
0000000141336f40: test     rsi, rsi
0000000141336f43: je       0x141336f50
0000000141336f45: mov      eax, dword ptr [rsi]
0000000141336f47: shr      rax, 0x1d
0000000141336f4b: and      eax, 1
0000000141336f4e: je       0x141336f71
0000000141336f50: lea      rdx, [rbp - 0x30]
0000000141336f54: mov      rcx, rbx
0000000141336f57: call     0x141280450
0000000141336f5c: mov      rdx, rax
0000000141336f5f: lea      rcx, [r14 + 0x320]
0000000141336f66: call     0x14127e710
0000000141336f6b: mov      edx, dword ptr [rip + 0xd9769f]
0000000141336f71: test     edx, edx
0000000141336f73: je       0x141336f85
0000000141336f75: test     rsi, rsi
0000000141336f78: je       0x141336f85
0000000141336f7a: mov      eax, dword ptr [rsi]
0000000141336f7c: shr      rax, 0x1f
0000000141336f80: and      eax, 1
0000000141336f83: je       0x141336fe1
0000000141336f85: mov      rcx, r13
0000000141336f88: call     0x1412b5a80
0000000141336f8d: movss    xmm8, dword ptr [rax + 0x10]
0000000141336f93: mov      rcx, r13
0000000141336f96: call     0x1412b5a80
0000000141336f9b: movss    xmm7, dword ptr [rax + 8]
0000000141336fa0: mov      rcx, r13
0000000141336fa3: call     0x1412b5a80
0000000141336fa8: movss    xmm6, dword ptr [rax + 4]
0000000141336fad: mov      rcx, r13
0000000141336fb0: call     0x1412b5a80
0000000141336fb5: mulss    xmm8, dword ptr [rip + 0x866dd2]
0000000141336fbe: lea      rcx, [r14 + 0x3a0]
0000000141336fc5: movss    dword ptr [rsp + 0x20], xmm8
0000000141336fcc: movaps   xmm3, xmm7
0000000141336fcf: movaps   xmm2, xmm6
0000000141336fd2: movss    xmm1, dword ptr [rax]
0000000141336fd6: call     0x1412a96c0
0000000141336fdb: mov      edx, dword ptr [rip + 0xd9762f]
0000000141336fe1: test     edx, edx
0000000141336fe3: je       0x141336ff6
0000000141336fe5: test     rsi, rsi
0000000141336fe8: je       0x141336ff6
0000000141336fea: mov      rax, qword ptr [rsi]
0000000141336fed: shr      rax, 0x25
0000000141336ff1: and      eax, 1
0000000141336ff4: je       0x14133702e
0000000141336ff6: lea      rcx, [r14 + 0x3b0]
0000000141336ffd: movss    xmm0, dword ptr [rbp + 0x308]
0000000141337005: movss    dword ptr [rsp + 0x20], xmm0
000000014133700b: movss    xmm3, dword ptr [rbp + 0x300]
0000000141337013: movss    xmm2, dword ptr [rbp + 0x2f8]
000000014133701b: movss    xmm1, dword ptr [rbp + 0x2f0]
0000000141337023: call     0x1412a96c0
0000000141337028: mov      edx, dword ptr [rip + 0xd975e2]
000000014133702e: test     edx, edx
0000000141337030: je       0x141337043
0000000141337032: test     rsi, rsi
0000000141337035: je       0x141337043
0000000141337037: mov      eax, dword ptr [rsi + 8]
000000014133703a: shr      rax, 5
000000014133703e: and      eax, 1
0000000141337041: je       0x141337064
0000000141337043: call     0x1412a9e20
0000000141337048: movups   xmm0, xmmword ptr [rax]
000000014133704b: movups   xmmword ptr [r14 + 0x560], xmm0
0000000141337053: mov      dword ptr [r14 + 0x560], 0x3f800000
000000014133705e: mov      edx, dword ptr [rip + 0xd975ac]
0000000141337064: test     edx, edx
0000000141337066: je       0x141337078
0000000141337068: test     rsi, rsi
000000014133706b: je       0x141337078
000000014133706d: mov      eax, dword ptr [rsi]
000000014133706f: shr      rax, 0x1e
0000000141337073: and      eax, 1
0000000141337076: je       0x1413370a0
0000000141337078: lea      rcx, [rdi + 0x124]
000000014133707f: mov      r8, rbx
0000000141337082: lea      rdx, [rbp - 0x30]
0000000141337086: call     0x141280a10
000000014133708b: mov      rdx, rax
000000014133708e: lea      rcx, [r14 + 0x360]
0000000141337095: call     0x14127e710
000000014133709a: mov      edx, dword ptr [rip + 0xd97570]
00000001413370a0: mov      r10, qword ptr [rsp + 0x40]
00000001413370a5: test     r10, r10
00000001413370a8: je       0x1413371bd
00000001413370ae: test     edx, edx
00000001413370b0: je       0x1413370fb
00000001413370b2: test     rsi, rsi
00000001413370b5: je       0x1413370fb
00000001413370b7: xorps    xmm0, xmm0
00000001413370ba: movups   xmmword ptr [rbp - 0x40], xmm0
00000001413370be: movq     rax, xmm0
00000001413370c3: bts      rax, 0x26
00000001413370c8: bts      rax, 0x27
00000001413370cd: mov      qword ptr [rbp - 0x40], rax
00000001413370d1: xor      r8d, r8d
00000001413370d4: mov      rcx, rsi
00000001413370d7: lea      r9, [rbp - 0x40]
00000001413370db: sub      r9, rsi
00000001413370de: nop      
00000001413370e0: mov      rax, qword ptr [r9 + rcx]
00000001413370e4: test     qword ptr [rcx], rax
00000001413370e7: jne      0x1413370fb
00000001413370e9: inc      r8d
00000001413370ec: add      rcx, 8
00000001413370f0: cmp      r8d, 2
00000001413370f4: jb       0x1413370e0
00000001413370f6: jmp      0x1413371bd
00000001413370fb: mov      r8, r10
00000001413370fe: lea      rdx, [rbp + 0x50]
0000000141337102: mov      rcx, rdi
0000000141337105: call     0x141280a10
000000014133710a: mov      rdx, rax
000000014133710d: lea      rcx, [r14 + 0x3c0]
0000000141337114: call     0x14127e710
0000000141337119: lea      rdx, [rdi + 0x40]
000000014133711d: lea      rcx, [rbp - 0x30]
0000000141337121: call     0x14127e3b0
0000000141337126: lea      rdx, [rbp - 0x80]
000000014133712a: lea      rcx, [rbp - 0x30]
000000014133712e: call     0x141283af0
0000000141337133: movss    xmm0, dword ptr [rbp - 0x74]
0000000141337138: addss    xmm0, dword ptr [rbp - 0x78]
000000014133713d: movss    xmm2, dword ptr [rip + 0x433303]
0000000141337145: mulss    xmm0, xmm2
0000000141337149: movss    dword ptr [rbp - 0x78], xmm0
000000014133714e: movss    xmm0, dword ptr [rbp - 0x68]
0000000141337153: addss    xmm0, dword ptr [rbp - 0x64]
0000000141337158: mulss    xmm0, xmm2
000000014133715c: movss    dword ptr [rbp - 0x68], xmm0
0000000141337161: movss    xmm1, dword ptr [rbp - 0x58]
0000000141337166: addss    xmm1, dword ptr [rbp - 0x54]
000000014133716b: mulss    xmm1, xmm2
000000014133716f: movss    dword ptr [rbp - 0x58], xmm1
0000000141337174: movss    xmm0, dword ptr [rbp - 0x48]
0000000141337179: addss    xmm0, dword ptr [rbp - 0x44]
000000014133717e: mulss    xmm0, xmm2
0000000141337182: movss    dword ptr [rbp - 0x48], xmm0
0000000141337187: lea      rdx, [rbp - 0x80]
000000014133718b: lea      rcx, [rbp - 0x30]
000000014133718f: call     0x1412820a0
0000000141337194: lea      r8, [r14 + 0x3c0]
000000014133719b: lea      rdx, [rbp + 0x50]
000000014133719f: lea      rcx, [rbp - 0x30]
00000001413371a3: call     0x141280a10
00000001413371a8: mov      rdx, rax
00000001413371ab: lea      rcx, [r14 + 0x400]
00000001413371b2: call     0x14127e710
00000001413371b7: mov      edx, dword ptr [rip + 0xd97453]
00000001413371bd: test     edx, edx
00000001413371bf: je       0x1413371d2
00000001413371c1: test     rsi, rsi
00000001413371c4: je       0x1413371d2
00000001413371c6: mov      rax, qword ptr [rsi]
00000001413371c9: shr      rax, 0x2f
00000001413371cd: and      eax, 1
00000001413371d0: je       0x141337217
00000001413371d2: mov      rcx, r13
00000001413371d5: call     0x1412b5a50
00000001413371da: movss    xmm7, dword ptr [rax + 8]
00000001413371df: mov      rcx, r13
00000001413371e2: call     0x1412b5a50
00000001413371e7: movss    xmm6, dword ptr [rax + 4]
00000001413371ec: mov      rcx, r13
00000001413371ef: call     0x1412b5a50
00000001413371f4: lea      rcx, [r14 + 0x4c0]
00000001413371fb: movss    dword ptr [rsp + 0x20], xmm9
0000000141337202: movaps   xmm3, xmm7
0000000141337205: movaps   xmm2, xmm6
0000000141337208: movss    xmm1, dword ptr [rax]
000000014133720c: call     0x1412a96c0
0000000141337211: mov      edx, dword ptr [rip + 0xd973f9]
0000000141337217: test     edx, edx
0000000141337219: je       0x141337229
000000014133721b: test     rsi, rsi
000000014133721e: je       0x141337229
0000000141337220: movzx    eax, word ptr [rsi + 6]
0000000141337224: and      eax, 1
0000000141337227: je       0x141337280
0000000141337229: call     0x1412e6730
000000014133722e: mov      rcx, rax
0000000141337231: lea      rdx, [rsp + 0x40]
0000000141337236: call     0x1412e67a0
000000014133723b: cmp      dword ptr [r13 + 0x250], 0
0000000141337243: je       0x14133724b
0000000141337245: movaps   xmm0, xmm10
0000000141337249: jmp      0x14133724f
000000014133724b: movaps   xmm0, xmm9
000000014133724f: movss    dword ptr [rsp + 0x4c], xmm0
0000000141337255: lea      rcx, [r14 + 0x4d0]
000000014133725c: movss    dword ptr [rsp + 0x20], xmm0
0000000141337262: movss    xmm3, dword ptr [rsp + 0x48]
0000000141337268: movss    xmm2, dword ptr [rsp + 0x44]
000000014133726e: movss    xmm1, dword ptr [rsp + 0x40]
0000000141337274: call     0x1412a96c0
0000000141337279: nop      dword ptr [rax]
0000000141337280: mov      qword ptr [r14 + 0x6e4], 0xffffffffffffffff
000000014133728b: mov      qword ptr [r14 + 0x6ec], 0xffffffffffffffff
0000000141337296: mov      byte ptr [r14 + 0x6f4], 0
000000014133729e: mov      ecx, dword ptr [rip + 0xd9736c]
00000001413372a4: test     ecx, ecx
00000001413372a6: je       0x1413372b9
00000001413372a8: test     rsi, rsi
00000001413372ab: je       0x1413372b9
00000001413372ad: mov      rax, qword ptr [rsi]
00000001413372b0: shr      rax, 0x35
00000001413372b4: and      eax, 1
00000001413372b7: je       0x1413372d3
00000001413372b9: call     0x141284200
00000001413372be: mov      rdx, rax
00000001413372c1: lea      rcx, [r14 + 0x580]
00000001413372c8: call     0x14127e710
00000001413372cd: mov      ecx, dword ptr [rip + 0xd9733d]
00000001413372d3: test     ecx, ecx
00000001413372d5: je       0x1413372e8
00000001413372d7: test     rsi, rsi
00000001413372da: je       0x1413372e8
00000001413372dc: mov      rax, qword ptr [rsi]
00000001413372df: shr      rax, 0x21
00000001413372e3: and      eax, 1
00000001413372e6: je       0x14133730d
00000001413372e8: lea      rcx, [r14 + 0x510]
00000001413372ef: movss    dword ptr [rsp + 0x20], xmm9
00000001413372f6: movaps   xmm3, xmm9
00000001413372fa: movaps   xmm2, xmm10
00000001413372fe: movaps   xmm1, xmm10
0000000141337302: call     0x1412a96c0
0000000141337307: mov      ecx, dword ptr [rip + 0xd97303]
000000014133730d: test     ecx, ecx
000000014133730f: je       0x141337322
0000000141337311: test     rsi, rsi
0000000141337314: je       0x141337322
0000000141337316: mov      rax, qword ptr [rsi]
0000000141337319: shr      rax, 0x22
000000014133731d: and      eax, 1
0000000141337320: je       0x141337347
0000000141337322: lea      rcx, [r14 + 0x520]
0000000141337329: movss    dword ptr [rsp + 0x20], xmm9
0000000141337330: movaps   xmm3, xmm9
0000000141337334: movaps   xmm2, xmm10
0000000141337338: movaps   xmm1, xmm10
000000014133733c: call     0x1412a96c0
0000000141337341: mov      ecx, dword ptr [rip + 0xd972c9]
0000000141337347: test     ecx, ecx
0000000141337349: je       0x14133735c
000000014133734b: test     rsi, rsi
000000014133734e: je       0x14133735c
0000000141337350: mov      rax, qword ptr [rsi]
0000000141337353: shr      rax, 0x23
0000000141337357: and      eax, 1
000000014133735a: je       0x141337372
000000014133735c: call     0x1412a9e20
0000000141337361: movups   xmm0, xmmword ptr [rax]
0000000141337364: movups   xmmword ptr [r14 + 0x530], xmm0
000000014133736c: mov      ecx, dword ptr [rip + 0xd9729e]
0000000141337372: test     ecx, ecx
0000000141337374: je       0x141337387
0000000141337376: test     rsi, rsi
0000000141337379: je       0x141337387
000000014133737b: mov      rax, qword ptr [rsi]
000000014133737e: shr      rax, 0x33
0000000141337382: and      eax, 1
0000000141337385: je       0x14133739d
0000000141337387: call     0x1412a9e20
000000014133738c: movups   xmm0, xmmword ptr [rax]
000000014133738f: movups   xmmword ptr [r14 + 0x540], xmm0
0000000141337397: mov      ecx, dword ptr [rip + 0xd97273]
000000014133739d: test     ecx, ecx
000000014133739f: je       0x1413373b2
00000001413373a1: test     rsi, rsi
00000001413373a4: je       0x1413373b2
00000001413373a6: mov      rax, qword ptr [rsi]
00000001413373a9: shr      rax, 0x24
00000001413373ad: and      eax, 1
00000001413373b0: je       0x1413373c8
00000001413373b2: call     0x1412a9e20
00000001413373b7: movups   xmm0, xmmword ptr [rax]
00000001413373ba: movups   xmmword ptr [r14 + 0x550], xmm0
00000001413373c2: mov      ecx, dword ptr [rip + 0xd97248]
00000001413373c8: test     ecx, ecx
00000001413373ca: je       0x141337418
00000001413373cc: test     rsi, rsi
00000001413373cf: je       0x141337418
00000001413373d1: xorps    xmm0, xmm0
00000001413373d4: movups   xmmword ptr [rbp - 0x40], xmm0
00000001413373d8: movq     rax, xmm0
00000001413373dd: bts      rax, 0x36
00000001413373e2: bts      rax, 0x1a
00000001413373e7: bts      rax, 0x1b
00000001413373ec: mov      qword ptr [rbp - 0x40], rax
00000001413373f0: xor      r8d, r8d
00000001413373f3: mov      rdx, rsi
00000001413373f6: lea      r9, [rbp - 0x40]
00000001413373fa: sub      r9, rsi
00000001413373fd: nop      dword ptr [rax]
0000000141337400: mov      rax, qword ptr [r9 + rdx]
0000000141337404: test     qword ptr [rdx], rax
0000000141337407: jne      0x141337418
0000000141337409: inc      r8d
000000014133740c: add      rdx, 8
0000000141337410: cmp      r8d, 2
0000000141337414: jb       0x141337400
0000000141337416: jmp      0x141337431
0000000141337418: lea      rdx, [rdi + 0x164]
000000014133741f: lea      rcx, [r14 + 0x5c0]
0000000141337426: call     0x14127e710
000000014133742b: mov      ecx, dword ptr [rip + 0xd971df]
0000000141337431: test     ecx, ecx
0000000141337433: je       0x141337446
0000000141337435: test     rsi, rsi
0000000141337438: je       0x141337446
000000014133743a: mov      rax, qword ptr [rsi]
000000014133743d: shr      rax, 0x3c
0000000141337441: and      eax, 1
0000000141337444: je       0x141337480
0000000141337446: mov      rcx, r13
0000000141337449: call     0x1412b59a0
000000014133744e: mov      rbx, rax
0000000141337451: mov      rcx, r13
0000000141337454: call     0x1412b59a0
0000000141337459: lea      rcx, [r14 + 0x650]
0000000141337460: movss    dword ptr [rsp + 0x20], xmm10
0000000141337467: movaps   xmm3, xmm10
000000014133746b: movss    xmm2, dword ptr [rbx + 0xc]
0000000141337470: movss    xmm1, dword ptr [rax + 8]
0000000141337475: call     0x1412a96c0
000000014133747a: mov      ecx, dword ptr [rip + 0xd97190]
0000000141337480: test     ecx, ecx
0000000141337482: je       0x1413374d0
0000000141337484: test     rsi, rsi
0000000141337487: je       0x1413374d0
0000000141337489: xorps    xmm0, xmm0
000000014133748c: movups   xmmword ptr [rbp - 0x40], xmm0
0000000141337490: movq     rax, xmm0
0000000141337495: bts      rax, 0x37
000000014133749a: bts      rax, 0x38
000000014133749f: bts      rax, 0x39
00000001413374a4: mov      qword ptr [rbp - 0x40], rax
00000001413374a8: xor      r8d, r8d
00000001413374ab: mov      rdx, rsi
00000001413374ae: lea      r9, [rbp - 0x40]
00000001413374b2: sub      r9, rsi
00000001413374b5: mov      rax, qword ptr [r9 + rdx]
00000001413374b9: test     qword ptr [rdx], rax
00000001413374bc: jne      0x1413374d0
00000001413374be: inc      r8d
00000001413374c1: add      rdx, 8
00000001413374c5: cmp      r8d, 2
00000001413374c9: jb       0x1413374b5
00000001413374cb: jmp      0x1413375c9
00000001413374d0: mov      rcx, r13
00000001413374d3: call     0x1412b5990
00000001413374d8: movss    xmm0, dword ptr [rax + 0x10]
00000001413374dd: movss    dword ptr [r14 + 0x600], xmm0
00000001413374e6: mov      rcx, r13
00000001413374e9: call     0x1412b5990
00000001413374ee: mov      ecx, dword ptr [rax + 0x14]
00000001413374f1: mov      dword ptr [r14 + 0x604], ecx
00000001413374f8: mov      rcx, r13
00000001413374fb: call     0x1412b5990
0000000141337500: mov      ecx, dword ptr [rax + 0x18]
0000000141337503: mov      dword ptr [r14 + 0x608], ecx
000000014133750a: mov      rcx, r13
000000014133750d: call     0x1412b5990
0000000141337512: movss    xmm0, dword ptr [rax + 0x20]
0000000141337517: movss    dword ptr [r14 + 0x610], xmm0
0000000141337520: mov      rcx, r13
0000000141337523: call     0x1412b5990
0000000141337528: mov      ecx, dword ptr [rax + 0x24]
000000014133752b: mov      dword ptr [r14 + 0x614], ecx
0000000141337532: mov      rcx, r13
0000000141337535: call     0x1412b5990
000000014133753a: mov      ecx, dword ptr [rax + 0x28]
000000014133753d: mov      dword ptr [r14 + 0x618], ecx
0000000141337544: mov      rcx, r13
0000000141337547: call     0x1412b5990
000000014133754c: movss    xmm7, dword ptr [rax + 0x3c]
0000000141337551: movss    xmm9, dword ptr [rip + 0x46b876]
000000014133755a: mulss    xmm7, xmm9
000000014133755f: mov      rcx, r13
0000000141337562: call     0x1412b5990
0000000141337567: movss    xmm8, dword ptr [rax + 0x38]
000000014133756d: mulss    xmm8, xmm9
0000000141337572: ucomiss  xmm8, xmm7
0000000141337576: jp       0x141337586
0000000141337578: jne      0x141337586
000000014133757a: movaps   xmm8, xmm10
000000014133757e: movss    xmm7, dword ptr [rip + 0x4ff342]
0000000141337586: mov      rcx, r13
0000000141337589: call     0x1412b5990
000000014133758e: movss    xmm6, dword ptr [rax + 0x34]
0000000141337593: mulss    xmm6, xmm9
0000000141337598: mov      rcx, r13
000000014133759b: call     0x1412b5990
00000001413375a0: movss    xmm1, dword ptr [rax + 0x30]
00000001413375a5: mulss    xmm1, xmm9
00000001413375aa: lea      rcx, [r14 + 0x620]
00000001413375b1: movss    dword ptr [rsp + 0x20], xmm7
00000001413375b7: movaps   xmm3, xmm8
00000001413375bb: movaps   xmm2, xmm6
00000001413375be: call     0x1412a96c0
00000001413375c3: mov      ecx, dword ptr [rip + 0xd97047]
00000001413375c9: test     ecx, ecx
00000001413375cb: je       0x141337618
00000001413375cd: test     rsi, rsi
00000001413375d0: je       0x141337618
00000001413375d2: xorps    xmm0, xmm0
00000001413375d5: movups   xmmword ptr [rbp - 0x40], xmm0
00000001413375d9: movq     rax, xmm0
00000001413375de: bts      rax, 0x3d
00000001413375e3: bts      rax, 0x3e
00000001413375e8: mov      qword ptr [rbp - 0x40], rax
00000001413375ec: xor      r8d, r8d
00000001413375ef: mov      rdx, rsi
00000001413375f2: lea      r9, [rbp - 0x40]
00000001413375f6: sub      r9, rsi
00000001413375f9: nop      dword ptr [rax]
0000000141337600: mov      rax, qword ptr [r9 + rdx]
0000000141337604: test     qword ptr [rdx], rax
0000000141337607: jne      0x141337618
0000000141337609: inc      r8d
000000014133760c: add      rdx, 8
0000000141337610: cmp      r8d, 2
0000000141337614: jb       0x141337600
0000000141337616: jmp      0x14133767b
0000000141337618: mov      rcx, r13
000000014133761b: call     0x1412b5af0
0000000141337620: movss    xmm8, dword ptr [rax + 0xc]
0000000141337626: mov      rcx, r13
0000000141337629: call     0x1412b5af0
000000014133762e: movss    xmm7, dword ptr [rax + 8]
0000000141337633: mov      rcx, r13
0000000141337636: call     0x1412b5af0
000000014133763b: movss    xmm6, dword ptr [rax + 4]
0000000141337640: mov      rcx, r13
0000000141337643: call     0x1412b5af0
0000000141337648: lea      rcx, [r14 + 0x660]
000000014133764f: movss    dword ptr [rsp + 0x20], xmm8
0000000141337656: movaps   xmm3, xmm7
0000000141337659: movaps   xmm2, xmm6
000000014133765c: movss    xmm1, dword ptr [rax]
0000000141337660: call     0x1412a96c0
0000000141337665: call     0x1412a9e20
000000014133766a: movups   xmm0, xmmword ptr [rax]
000000014133766d: movups   xmmword ptr [r14 + 0x670], xmm0
0000000141337675: mov      ecx, dword ptr [rip + 0xd96f95]
000000014133767b: test     ecx, ecx
000000014133767d: je       0x1413376d8
000000014133767f: test     rsi, rsi
0000000141337682: je       0x1413376d8
0000000141337684: xorps    xmm0, xmm0
0000000141337687: movups   xmmword ptr [rsp + 0x40], xmm0
000000014133768c: movq     rax, xmm0
0000000141337691: bts      rax, 0x3f
0000000141337696: mov      qword ptr [rsp + 0x40], rax
000000014133769b: mov      rax, qword ptr [rsp + 0x48]
00000001413376a0: bts      rax, 0
00000001413376a5: mov      qword ptr [rsp + 0x48], rax
00000001413376aa: xor      r8d, r8d
00000001413376ad: mov      rdx, rsi
00000001413376b0: lea      r9, [rsp + 0x40]
00000001413376b5: sub      r9, rsi
00000001413376b8: nop      dword ptr [rax + rax]
00000001413376c0: mov      rax, qword ptr [r9 + rdx]
00000001413376c4: test     qword ptr [rdx], rax
00000001413376c7: jne      0x1413376d8
00000001413376c9: inc      r8d
00000001413376cc: add      rdx, 8
00000001413376d0: cmp      r8d, 2
00000001413376d4: jb       0x1413376c0
00000001413376d6: jmp      0x14133771e
00000001413376d8: mov      eax, dword ptr [r13 + 0xb4]
00000001413376df: mov      dword ptr [r14 + 0x688], eax
00000001413376e6: mov      qword ptr [r14 + 0x680], 0x100000
00000001413376f1: mov      dword ptr [r14 + 0x68c], 0
00000001413376fc: lea      rdx, [r13 + 0xb8]
0000000141337703: lea      rcx, [rbp - 0x40]
0000000141337707: call     0x1412a7d00
000000014133770c: movups   xmm0, xmmword ptr [rbp - 0x40]
0000000141337710: movups   xmmword ptr [r14 + 0x690], xmm0
0000000141337718: mov      ecx, dword ptr [rip + 0xd96ef2]
000000014133771e: test     ecx, ecx
0000000141337720: je       0x141337768
0000000141337722: test     rsi, rsi
0000000141337725: je       0x141337768
0000000141337727: xorps    xmm0, xmm0
000000014133772a: movups   xmmword ptr [rbp - 0x40], xmm0
000000014133772e: psrldq   xmm0, 8
0000000141337733: movq     rax, xmm0
0000000141337738: bts      rax, 2
000000014133773d: mov      qword ptr [rbp - 0x38], rax
0000000141337741: xor      r8d, r8d
0000000141337744: mov      rdx, rsi
0000000141337747: lea      r9, [rbp - 0x40]
000000014133774b: sub      r9, rsi
000000014133774e: nop      
0000000141337750: mov      rax, qword ptr [r9 + rdx]
0000000141337754: test     qword ptr [rdx], rax
0000000141337757: jne      0x141337768
0000000141337759: inc      r8d
000000014133775c: add      rdx, 8
0000000141337760: cmp      r8d, 2
0000000141337764: jb       0x141337750
0000000141337766: jmp      0x14133778a
0000000141337768: lea      rdx, [r13 + 0xc8]
000000014133776f: lea      rcx, [rbp - 0x40]
0000000141337773: call     0x1412a7d00
0000000141337778: movups   xmm0, xmmword ptr [rbp - 0x40]
000000014133777c: movups   xmmword ptr [r14 + 0x6c0], xmm0
0000000141337784: mov      ecx, dword ptr [rip + 0xd96e86]
000000014133778a: test     ecx, ecx
000000014133778c: je       0x14133779f
000000014133778e: test     rsi, rsi
0000000141337791: je       0x14133779f
0000000141337793: mov      eax, dword ptr [rsi + 8]
0000000141337796: shr      rax, 4
000000014133779a: and      eax, 1
000000014133779d: je       0x1413377c1
000000014133779f: lea      rdx, [r13 + 0xd8]
00000001413377a6: lea      rcx, [rbp - 0x40]
00000001413377aa: call     0x1412a7d00
00000001413377af: movups   xmm0, xmmword ptr [rbp - 0x40]
00000001413377b3: movups   xmmword ptr [r14 + 0x6d0], xmm0
00000001413377bb: mov      ecx, dword ptr [rip + 0xd96e4f]
00000001413377c1: test     ecx, ecx
00000001413377c3: je       0x1413377d6
00000001413377c5: test     rsi, rsi
00000001413377c8: je       0x1413377d6
00000001413377ca: mov      eax, dword ptr [rsi + 8]
00000001413377cd: shr      rax, 7
00000001413377d1: and      eax, 1
00000001413377d4: je       0x1413377e1
00000001413377d6: mov      dword ptr [r14 + 0x6e0], 0
00000001413377e1: lea      r9, [rip - 0xc2558]
00000001413377e8: mov      edx, 0x30
00000001413377ed: lea      r8d, [rdx - 0x2c]
00000001413377f1: lea      rcx, [rbp + 0x140]
00000001413377f8: call     0x14144142c
00000001413377fd: lea      r9, [rip - 0xc25d4]
0000000141337804: mov      edx, 0x20
0000000141337809: lea      r8d, [rdx - 0x1c]
000000014133780d: lea      rcx, [rbp + 0xc0]
0000000141337814: call     0x14144142c
0000000141337819: nop      
000000014133781a: mov      rcx, qword ptr [rbp + 0x210]
0000000141337821: xor      rcx, rsp
0000000141337824: call     0x141441dc0
0000000141337829: lea      r11, [rsp + 0x378]
0000000141337831: movaps   xmm6, xmmword ptr [r11 - 0x18]
0000000141337836: movaps   xmm7, xmmword ptr [r11 - 0x28]
000000014133783b: movaps   xmm8, xmmword ptr [r11 - 0x38]
0000000141337840: movaps   xmm9, xmmword ptr [r11 - 0x48]
0000000141337845: movaps   xmm10, xmmword ptr [r11 - 0x58]
000000014133784a: mov      rsp, r11
000000014133784d: pop      r15
000000014133784f: pop      r14
0000000141337851: pop      r13
0000000141337853: pop      r12
0000000141337855: pop      rdi
0000000141337856: pop      rsi
0000000141337857: pop      rbx
0000000141337858: pop      rbp
0000000141337859: ret      
