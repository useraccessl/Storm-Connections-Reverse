00000001412c7b00: mov      qword ptr [rsp + 8], rbx
00000001412c7b05: mov      qword ptr [rsp + 0x10], rbp
00000001412c7b0a: mov      qword ptr [rsp + 0x18], rsi
00000001412c7b0f: push     rdi
00000001412c7b10: sub      rsp, 0x20
00000001412c7b14: mov      rbx, qword ptr [rcx + 0x308]
00000001412c7b1b: mov      ebp, edx
00000001412c7b1d: mov      eax, dword ptr [rcx + 0x300]
00000001412c7b23: xor      edx, edx
00000001412c7b25: mov      rdi, rcx
00000001412c7b28: div      dword ptr [rbx + 8]
00000001412c7b2b: movzx    r8d, word ptr [rbx + 4]
00000001412c7b30: cmp      eax, r8d
00000001412c7b33: jae      0x1412c7d3b
00000001412c7b39: mov      ecx, dword ptr [rbx]
00000001412c7b3b: mov      rdx, rbx
00000001412c7b3e: mov      esi, eax
00000001412c7b40: mov      eax, ecx
00000001412c7b42: and      al, 6
00000001412c7b44: cmp      al, 4
00000001412c7b46: jne      0x1412c7b76
00000001412c7b48: mov      rdx, qword ptr [rbx + 0x18]
00000001412c7b4c: lea      rax, [rsi + rsi*2]
00000001412c7b50: lea      rcx, [rdi + 0x2b0]
00000001412c7b57: movss    xmm3, dword ptr [rdx + rax*4 + 8]
00000001412c7b5d: movss    xmm2, dword ptr [rdx + rax*4 + 4]
00000001412c7b63: movss    xmm1, dword ptr [rdx + rax*4]
00000001412c7b68: call     0x1411adb80
00000001412c7b6d: mov      rdx, qword ptr [rdi + 0x308]
00000001412c7b74: mov      ecx, dword ptr [rdx]
00000001412c7b76: mov      eax, ecx
00000001412c7b78: and      al, 0x18
00000001412c7b7a: cmp      al, 0x10
00000001412c7b7c: jne      0x1412c7b8c
00000001412c7b7e: mov      rax, qword ptr [rdx + 0x20]
00000001412c7b82: mov      ecx, dword ptr [rax]
00000001412c7b84: mov      dword ptr [rdi + 0x2bc], ecx
00000001412c7b8a: mov      ecx, dword ptr [rdx]
00000001412c7b8c: mov      eax, ecx
00000001412c7b8e: mov      rbx, rdx
00000001412c7b91: and      al, 0x60
00000001412c7b93: cmp      al, 0x40
00000001412c7b95: jne      0x1412c7bbb
00000001412c7b97: mov      rax, qword ptr [rdx + 0x28]
00000001412c7b9b: lea      rcx, [rdi + 0x2c0]
00000001412c7ba2: movss    xmm2, dword ptr [rax + rsi*8 + 4]
00000001412c7ba8: movss    xmm1, dword ptr [rax + rsi*8]
00000001412c7bad: call     0x1412a15c0
00000001412c7bb2: mov      rbx, qword ptr [rdi + 0x308]
00000001412c7bb9: mov      ecx, dword ptr [rbx]
00000001412c7bbb: mov      eax, ecx
00000001412c7bbd: and      eax, 0x180
00000001412c7bc2: cmp      eax, 0x100
00000001412c7bc7: jne      0x1412c7bd8
00000001412c7bc9: mov      rax, qword ptr [rbx + 0x30]
00000001412c7bcd: mov      ecx, dword ptr [rax + rsi*4]
00000001412c7bd0: mov      dword ptr [rdi + 0xa0], ecx
00000001412c7bd6: mov      ecx, dword ptr [rbx]
00000001412c7bd8: mov      eax, ecx
00000001412c7bda: and      eax, 0x600
00000001412c7bdf: cmp      eax, 0x400
00000001412c7be4: jne      0x1412c7c0a
00000001412c7be6: mov      rax, qword ptr [rbx + 0x38]
00000001412c7bea: lea      rcx, [rdi + 0x2c8]
00000001412c7bf1: movss    xmm2, dword ptr [rax + rsi*8 + 4]
00000001412c7bf7: movss    xmm1, dword ptr [rax + rsi*8]
00000001412c7bfc: call     0x1412a15c0
00000001412c7c01: mov      rbx, qword ptr [rdi + 0x308]
00000001412c7c08: mov      ecx, dword ptr [rbx]
00000001412c7c0a: mov      eax, ecx
00000001412c7c0c: and      eax, 0x1800
00000001412c7c11: cmp      eax, 0x1000
00000001412c7c16: jne      0x1412c7c3c
00000001412c7c18: mov      rax, qword ptr [rbx + 0x40]
00000001412c7c1c: lea      rcx, [rdi + 0x2d0]
00000001412c7c23: movss    xmm2, dword ptr [rax + rsi*8 + 4]
00000001412c7c29: movss    xmm1, dword ptr [rax + rsi*8]
00000001412c7c2e: call     0x1412a15c0
00000001412c7c33: mov      rbx, qword ptr [rdi + 0x308]
00000001412c7c3a: mov      ecx, dword ptr [rbx]
00000001412c7c3c: mov      eax, ecx
00000001412c7c3e: and      eax, 0x180000
00000001412c7c43: cmp      eax, 0x100000
00000001412c7c48: jne      0x1412c7c6e
00000001412c7c4a: mov      rax, qword ptr [rbx + 0x60]
00000001412c7c4e: lea      rcx, [rdi + 0x2d8]
00000001412c7c55: movss    xmm2, dword ptr [rax + rsi*8 + 4]
00000001412c7c5b: movss    xmm1, dword ptr [rax + rsi*8]
00000001412c7c60: call     0x1412a15c0
00000001412c7c65: mov      rbx, qword ptr [rdi + 0x308]
00000001412c7c6c: mov      ecx, dword ptr [rbx]
00000001412c7c6e: mov      eax, ecx
00000001412c7c70: and      eax, 0x600000
00000001412c7c75: cmp      eax, 0x400000
00000001412c7c7a: jne      0x1412c7ca0
00000001412c7c7c: mov      rax, qword ptr [rbx + 0x68]
00000001412c7c80: lea      rcx, [rdi + 0x2e0]
00000001412c7c87: movss    xmm2, dword ptr [rax + rsi*8 + 4]
00000001412c7c8d: movss    xmm1, dword ptr [rax + rsi*8]
00000001412c7c92: call     0x1412a15c0
00000001412c7c97: mov      rbx, qword ptr [rdi + 0x308]
00000001412c7c9e: mov      ecx, dword ptr [rbx]
00000001412c7ca0: mov      eax, ecx
00000001412c7ca2: and      eax, 0x6000
00000001412c7ca7: cmp      eax, 0x4000
00000001412c7cac: jne      0x1412c7cbd
00000001412c7cae: mov      rax, qword ptr [rbx + 0x48]
00000001412c7cb2: mov      ecx, dword ptr [rax + rsi*4]
00000001412c7cb5: mov      dword ptr [rdi + 0x2e8], ecx
00000001412c7cbb: mov      ecx, dword ptr [rbx]
00000001412c7cbd: mov      eax, ecx
00000001412c7cbf: and      eax, 0x18000
00000001412c7cc4: cmp      eax, 0x10000
00000001412c7cc9: jne      0x1412c7cda
00000001412c7ccb: mov      rax, qword ptr [rbx + 0x50]
00000001412c7ccf: mov      ecx, dword ptr [rax + rsi*4]
00000001412c7cd2: mov      dword ptr [rdi + 0x2ec], ecx
00000001412c7cd8: mov      ecx, dword ptr [rbx]
00000001412c7cda: mov      eax, ecx
00000001412c7cdc: and      eax, 0x60000
00000001412c7ce1: cmp      eax, 0x40000
00000001412c7ce6: jne      0x1412c7cf7
00000001412c7ce8: mov      rax, qword ptr [rbx + 0x58]
00000001412c7cec: mov      ecx, dword ptr [rax + rsi*4]
00000001412c7cef: mov      dword ptr [rdi + 0x2f0], ecx
00000001412c7cf5: mov      ecx, dword ptr [rbx]
00000001412c7cf7: mov      eax, ecx
00000001412c7cf9: and      eax, 0x1800000
00000001412c7cfe: cmp      eax, 0x1000000
00000001412c7d03: jne      0x1412c7d20
00000001412c7d05: mov      rax, qword ptr [rbx + 0x70]
00000001412c7d09: movss    xmm0, dword ptr [rax + rsi*4]
00000001412c7d0e: divss    xmm0, dword ptr [rip + 0x4d64ca]
00000001412c7d16: movss    dword ptr [rdi + 0x2f8], xmm0
00000001412c7d1e: mov      ecx, dword ptr [rbx]
00000001412c7d20: and      ecx, 0x6000000
00000001412c7d26: cmp      ecx, 0x4000000
00000001412c7d2c: jne      0x1412c7d3b
00000001412c7d2e: mov      rax, qword ptr [rbx + 0x78]
00000001412c7d32: mov      ecx, dword ptr [rax + rsi*4]
00000001412c7d35: mov      dword ptr [rdi + 0x2fc], ecx
00000001412c7d3b: test     ebp, ebp
00000001412c7d3d: je       0x1412c7dbb
00000001412c7d3f: mov      rsi, qword ptr [rdi + 0x38]
00000001412c7d43: mov      eax, 0x88888889
00000001412c7d48: mul      dword ptr [rip + 0x8ccb9a]
00000001412c7d4e: mov      ebp, edx
00000001412c7d50: shr      ebp, 5
00000001412c7d53: test     rsi, rsi
00000001412c7d56: je       0x1412c7d7d
00000001412c7d58: mov      rcx, qword ptr [rsi + 0x28]
00000001412c7d5c: test     rcx, rcx
00000001412c7d5f: je       0x1412c7d6d
00000001412c7d61: call     0x140269a40
00000001412c7d66: mulss    xmm0, dword ptr [rsi + 0x38]
00000001412c7d6b: jmp      0x1412c7d72
00000001412c7d6d: movss    xmm0, dword ptr [rsi + 0x38]
00000001412c7d72: ucomiss  xmm0, dword ptr [rip + 0x499867]
00000001412c7d79: jp       0x1412c7dbb
00000001412c7d7b: jne      0x1412c7dbb
00000001412c7d7d: mov      eax, dword ptr [rdi + 0x300]
00000001412c7d83: movd     xmm0, ebp
00000001412c7d87: cvtdq2ps xmm0, xmm0
00000001412c7d8a: cvttss2si ecx, xmm0
00000001412c7d8e: add      eax, ecx
00000001412c7d90: mov      dword ptr [rdi + 0x300], eax
00000001412c7d96: test     ecx, ecx
00000001412c7d98: jle      0x1412c7dbb
00000001412c7d9a: mov      ecx, dword ptr [rdi + 0x304]
00000001412c7da0: cmp      eax, ecx
00000001412c7da2: jb       0x1412c7dbb
00000001412c7da4: test     byte ptr [rbx], 1
00000001412c7da7: je       0x1412c7db5
00000001412c7da9: xor      edx, edx
00000001412c7dab: div      ecx
00000001412c7dad: mov      dword ptr [rdi + 0x300], edx
00000001412c7db3: jmp      0x1412c7dbb
00000001412c7db5: mov      dword ptr [rdi + 0x300], ecx
00000001412c7dbb: mov      rbx, qword ptr [rsp + 0x30]
00000001412c7dc0: mov      rbp, qword ptr [rsp + 0x38]
00000001412c7dc5: mov      rsi, qword ptr [rsp + 0x40]
00000001412c7dca: add      rsp, 0x20
00000001412c7dce: pop      rdi
00000001412c7dcf: ret      
