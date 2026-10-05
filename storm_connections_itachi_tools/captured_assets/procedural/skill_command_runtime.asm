0000000140a69d70: mov      qword ptr [rsp + 8], rbx
0000000140a69d75: mov      qword ptr [rsp + 0x10], rbp
0000000140a69d7a: mov      qword ptr [rsp + 0x18], rsi
0000000140a69d7f: mov      qword ptr [rsp + 0x20], rdi
0000000140a69d84: push     r13
0000000140a69d86: push     r14
0000000140a69d88: push     r15
0000000140a69d8a: sub      rsp, 0x20
0000000140a69d8e: lea      r11, [rip + 0xf0af8b]
0000000140a69d95: mov      r13, rcx
0000000140a69d98: mov      r9, r11
0000000140a69d9b: nop      dword ptr [rax + rax]
0000000140a69da0: inc      r9
0000000140a69da3: cmp      byte ptr [r9], 0
0000000140a69da7: jne      0x140a69da0
0000000140a69da9: mov      rbp, qword ptr [rdx + 0x40]
0000000140a69dad: lea      r15, [rip + 0x1724d9c]
0000000140a69db4: sub      r9, r11
0000000140a69db7: xor      edi, edi
0000000140a69db9: mov      r10, rbp
0000000140a69dbc: test     rbp, rbp
0000000140a69dbf: je       0x140a69e0b
0000000140a69dc1: mov      rax, qword ptr [r10]
0000000140a69dc4: test     rax, rax
0000000140a69dc7: je       0x140a69dcf
0000000140a69dc9: mov      rcx, qword ptr [r10 + 0x10]
0000000140a69dcd: jmp      0x140a69dd5
0000000140a69dcf: mov      rcx, rdi
0000000140a69dd2: mov      rax, r15
0000000140a69dd5: cmp      rcx, r9
0000000140a69dd8: jne      0x140a69e02
0000000140a69dda: lea      r8, [rcx + rax]
0000000140a69dde: cmp      rax, r8
0000000140a69de1: jae      0x140a69e0e
0000000140a69de3: mov      rdx, r11
0000000140a69de6: sub      rdx, rax
0000000140a69de9: nop      dword ptr [rax]
0000000140a69df0: movzx    ecx, byte ptr [rdx + rax]
0000000140a69df4: cmp      byte ptr [rax], cl
0000000140a69df6: jne      0x140a69e02
0000000140a69df8: inc      rax
0000000140a69dfb: cmp      rax, r8
0000000140a69dfe: jb       0x140a69df0
0000000140a69e00: jmp      0x140a69e0e
0000000140a69e02: mov      r10, qword ptr [r10 + 0x30]
0000000140a69e06: test     r10, r10
0000000140a69e09: jne      0x140a69dc1
0000000140a69e0b: mov      r10, rdi
0000000140a69e0e: lea      r11, [rip + 0xf0af13]
0000000140a69e15: mov      r9, r11
0000000140a69e18: inc      r9
0000000140a69e1b: cmp      byte ptr [r9], dil
0000000140a69e1e: jne      0x140a69e18
0000000140a69e20: sub      r9, r11
0000000140a69e23: mov      r14, rbp
0000000140a69e26: test     rbp, rbp
0000000140a69e29: je       0x140a69e73
0000000140a69e2b: nop      dword ptr [rax + rax]
0000000140a69e30: mov      rcx, qword ptr [r14]
0000000140a69e33: test     rcx, rcx
0000000140a69e36: je       0x140a69e3e
0000000140a69e38: mov      rax, qword ptr [r14 + 0x10]
0000000140a69e3c: jmp      0x140a69e44
0000000140a69e3e: mov      rax, rdi
0000000140a69e41: mov      rcx, r15
0000000140a69e44: cmp      rax, r9
0000000140a69e47: jne      0x140a69e6a
0000000140a69e49: lea      r8, [rax + rcx]
0000000140a69e4d: cmp      rcx, r8
0000000140a69e50: jae      0x140a69e76
0000000140a69e52: mov      rdx, r11
0000000140a69e55: sub      rdx, rcx
0000000140a69e58: movzx    eax, byte ptr [rdx + rcx]
0000000140a69e5c: cmp      byte ptr [rcx], al
0000000140a69e5e: jne      0x140a69e6a
0000000140a69e60: inc      rcx
0000000140a69e63: cmp      rcx, r8
0000000140a69e66: jb       0x140a69e58
0000000140a69e68: jmp      0x140a69e76
0000000140a69e6a: mov      r14, qword ptr [r14 + 0x30]
0000000140a69e6e: test     r14, r14
0000000140a69e71: jne      0x140a69e30
0000000140a69e73: mov      r14, rdi
0000000140a69e76: lea      r11, [rip + 0xf0aeb3]
0000000140a69e7d: mov      r9, r11
0000000140a69e80: inc      r9
0000000140a69e83: cmp      byte ptr [r9], dil
0000000140a69e86: jne      0x140a69e80
0000000140a69e88: sub      r9, r11
0000000140a69e8b: mov      rsi, rbp
0000000140a69e8e: test     rbp, rbp
0000000140a69e91: je       0x140a69edb
0000000140a69e93: mov      rcx, qword ptr [rsi]
0000000140a69e96: test     rcx, rcx
0000000140a69e99: je       0x140a69ea1
0000000140a69e9b: mov      rax, qword ptr [rsi + 0x10]
0000000140a69e9f: jmp      0x140a69ea7
0000000140a69ea1: mov      rax, rdi
0000000140a69ea4: mov      rcx, r15
0000000140a69ea7: cmp      rax, r9
0000000140a69eaa: jne      0x140a69ed2
0000000140a69eac: lea      r8, [rax + rcx]
0000000140a69eb0: cmp      rcx, r8
0000000140a69eb3: jae      0x140a69ede
0000000140a69eb5: mov      rdx, r11
0000000140a69eb8: sub      rdx, rcx
0000000140a69ebb: nop      dword ptr [rax + rax]
0000000140a69ec0: movzx    eax, byte ptr [rdx + rcx]
0000000140a69ec4: cmp      byte ptr [rcx], al
0000000140a69ec6: jne      0x140a69ed2
0000000140a69ec8: inc      rcx
0000000140a69ecb: cmp      rcx, r8
0000000140a69ece: jb       0x140a69ec0
0000000140a69ed0: jmp      0x140a69ede
0000000140a69ed2: mov      rsi, qword ptr [rsi + 0x30]
0000000140a69ed6: test     rsi, rsi
0000000140a69ed9: jne      0x140a69e93
0000000140a69edb: mov      rsi, rdi
0000000140a69ede: lea      r11, [rip + 0xf0ae53]
0000000140a69ee5: mov      r9, r11
0000000140a69ee8: inc      r9
0000000140a69eeb: cmp      byte ptr [r9], dil
0000000140a69eee: jne      0x140a69ee8
0000000140a69ef0: sub      r9, r11
0000000140a69ef3: mov      rbx, rbp
0000000140a69ef6: test     rbp, rbp
0000000140a69ef9: je       0x140a69f43
0000000140a69efb: nop      dword ptr [rax + rax]
0000000140a69f00: mov      rcx, qword ptr [rbx]
0000000140a69f03: test     rcx, rcx
0000000140a69f06: je       0x140a69f0e
0000000140a69f08: mov      rax, qword ptr [rbx + 0x10]
0000000140a69f0c: jmp      0x140a69f14
0000000140a69f0e: mov      rax, rdi
0000000140a69f11: mov      rcx, r15
0000000140a69f14: cmp      rax, r9
0000000140a69f17: jne      0x140a69f3a
0000000140a69f19: lea      r8, [rax + rcx]
0000000140a69f1d: cmp      rcx, r8
0000000140a69f20: jae      0x140a69f46
0000000140a69f22: mov      rdx, r11
0000000140a69f25: sub      rdx, rcx
0000000140a69f28: movzx    eax, byte ptr [rdx + rcx]
0000000140a69f2c: cmp      byte ptr [rcx], al
0000000140a69f2e: jne      0x140a69f3a
0000000140a69f30: inc      rcx
0000000140a69f33: cmp      rcx, r8
0000000140a69f36: jb       0x140a69f28
0000000140a69f38: jmp      0x140a69f46
0000000140a69f3a: mov      rbx, qword ptr [rbx + 0x30]
0000000140a69f3e: test     rbx, rbx
0000000140a69f41: jne      0x140a69f00
0000000140a69f43: mov      rbx, rdi
0000000140a69f46: lea      r11, [rip + 0xf0adfb]
0000000140a69f4d: mov      r9, r11
0000000140a69f50: inc      r9
0000000140a69f53: cmp      byte ptr [r9], dil
0000000140a69f56: jne      0x140a69f50
0000000140a69f58: sub      r9, r11
0000000140a69f5b: test     rbp, rbp
0000000140a69f5e: je       0x140a69fab
0000000140a69f60: mov      rcx, qword ptr [rbp]
0000000140a69f64: test     rcx, rcx
0000000140a69f67: je       0x140a69f6f
0000000140a69f69: mov      rax, qword ptr [rbp + 0x10]
0000000140a69f6d: jmp      0x140a69f75
0000000140a69f6f: mov      rax, rdi
0000000140a69f72: mov      rcx, r15
0000000140a69f75: cmp      rax, r9
0000000140a69f78: jne      0x140a69fa2
0000000140a69f7a: lea      r8, [rax + rcx]
0000000140a69f7e: cmp      rcx, r8
0000000140a69f81: jae      0x140a69fae
0000000140a69f83: mov      rdx, r11
0000000140a69f86: sub      rdx, rcx
0000000140a69f89: nop      dword ptr [rax]
0000000140a69f90: movzx    eax, byte ptr [rdx + rcx]
0000000140a69f94: cmp      byte ptr [rcx], al
0000000140a69f96: jne      0x140a69fa2
0000000140a69f98: inc      rcx
0000000140a69f9b: cmp      rcx, r8
0000000140a69f9e: jb       0x140a69f90
0000000140a69fa0: jmp      0x140a69fae
0000000140a69fa2: mov      rbp, qword ptr [rbp + 0x30]
0000000140a69fa6: test     rbp, rbp
0000000140a69fa9: jne      0x140a69f60
0000000140a69fab: mov      rbp, rdi
0000000140a69fae: test     r10, r10
0000000140a69fb1: je       0x140a69fe9
0000000140a69fb3: mov      rcx, qword ptr [rip + 0x175e9d6]
0000000140a69fba: mov      eax, edi
0000000140a69fbc: test     rcx, rcx
0000000140a69fbf: je       0x140a69fd4
0000000140a69fc1: mov      rax, qword ptr [r10 + 8]
0000000140a69fc5: mov      rdx, r15
0000000140a69fc8: test     rax, rax
0000000140a69fcb: cmovne   rdx, rax
0000000140a69fcf: call     0x140924cc0
0000000140a69fd4: mov      ecx, dword ptr [r13 + 0xd0]
0000000140a69fdb: lea      rdx, [rcx + rcx*4]
0000000140a69fdf: mov      rcx, qword ptr [r13 + 0xd8]
0000000140a69fe6: mov      dword ptr [rcx + rdx*4], eax
0000000140a69fe9: test     r14, r14
0000000140a69fec: je       0x140a6a018
0000000140a69fee: mov      rax, qword ptr [r14 + 8]
0000000140a69ff2: mov      rcx, r15
0000000140a69ff5: test     rax, rax
0000000140a69ff8: cmovne   rcx, rax
0000000140a69ffc: call     qword ptr [rip + 0xccbcfe]
0000000140a6a002: mov      ecx, dword ptr [r13 + 0xd0]
0000000140a6a009: lea      rdx, [rcx + rcx*4]
0000000140a6a00d: mov      rcx, qword ptr [r13 + 0xd8]
0000000140a6a014: mov      dword ptr [rcx + rdx*4 + 4], eax
0000000140a6a018: test     rsi, rsi
0000000140a6a01b: je       0x140a6a047
0000000140a6a01d: mov      rax, qword ptr [rsi + 8]
0000000140a6a021: mov      rcx, r15
0000000140a6a024: test     rax, rax
0000000140a6a027: cmovne   rcx, rax
0000000140a6a02b: call     qword ptr [rip + 0xccbccf]
0000000140a6a031: mov      ecx, dword ptr [r13 + 0xd0]
0000000140a6a038: lea      rdx, [rcx + rcx*4]
0000000140a6a03c: mov      rcx, qword ptr [r13 + 0xd8]
0000000140a6a043: mov      dword ptr [rcx + rdx*4 + 8], eax
0000000140a6a047: test     rbx, rbx
0000000140a6a04a: je       0x140a6a076
0000000140a6a04c: mov      rax, qword ptr [rbx + 8]
0000000140a6a050: mov      rcx, r15
0000000140a6a053: test     rax, rax
0000000140a6a056: cmovne   rcx, rax
0000000140a6a05a: call     qword ptr [rip + 0xccbca0]
0000000140a6a060: mov      ecx, dword ptr [r13 + 0xd0]
0000000140a6a067: lea      rdx, [rcx + rcx*4]
0000000140a6a06b: mov      rcx, qword ptr [r13 + 0xd8]
0000000140a6a072: mov      dword ptr [rcx + rdx*4 + 0xc], eax
0000000140a6a076: test     rbp, rbp
0000000140a6a079: je       0x140a6a0be
0000000140a6a07b: mov      rax, qword ptr [rbp + 8]
0000000140a6a07f: lea      rdx, [rip + 0xd0ed6a]
0000000140a6a086: test     rax, rax
0000000140a6a089: cmovne   r15, rax
0000000140a6a08d: nop      dword ptr [rax]
0000000140a6a090: movzx    ecx, byte ptr [r15 + rdi]
0000000140a6a095: inc      rdi
0000000140a6a098: cmp      cl, byte ptr [rdx + rdi - 1]
0000000140a6a09c: jne      0x140a6a0be
0000000140a6a09e: cmp      rdi, 5
0000000140a6a0a2: jne      0x140a6a090
0000000140a6a0a4: mov      ecx, dword ptr [r13 + 0xd0]
0000000140a6a0ab: lea      rdx, [rcx + rcx*4]
0000000140a6a0af: mov      rcx, qword ptr [r13 + 0xd8]
0000000140a6a0b6: mov      dword ptr [rcx + rdx*4 + 0x10], 1
0000000140a6a0be: inc      dword ptr [r13 + 0xd0]
0000000140a6a0c5: mov      eax, 1
0000000140a6a0ca: mov      rbx, qword ptr [rsp + 0x40]
0000000140a6a0cf: mov      rbp, qword ptr [rsp + 0x48]
0000000140a6a0d4: mov      rsi, qword ptr [rsp + 0x50]
0000000140a6a0d9: mov      rdi, qword ptr [rsp + 0x58]
0000000140a6a0de: add      rsp, 0x20
0000000140a6a0e2: pop      r15
0000000140a6a0e4: pop      r14
0000000140a6a0e6: pop      r13
0000000140a6a0e8: ret      
