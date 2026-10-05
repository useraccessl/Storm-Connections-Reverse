0000000140a66080: mov      qword ptr [rsp + 8], rbx
0000000140a66085: mov      qword ptr [rsp + 0x10], rsi
0000000140a6608a: push     rdi
0000000140a6608b: sub      rsp, 0x50
0000000140a6608f: mov      edx, dword ptr [rcx + 8]
0000000140a66092: mov      rdi, rcx
0000000140a66095: mov      rcx, qword ptr [rip + 0x17713fc]
0000000140a6609c: call     0x140a63f90
0000000140a660a1: test     rax, rax
0000000140a660a4: je       0x140a660dd
0000000140a660a6: lea      rsi, [rax + 0x3a8]
0000000140a660ad: test     rsi, rsi
0000000140a660b0: je       0x140a660dd
0000000140a660b2: cmp      byte ptr [rsi], 0
0000000140a660b5: je       0x140a660dd
0000000140a660b7: mov      rdx, qword ptr [rip + 0x17713e2]
0000000140a660be: mov      rcx, rsi
0000000140a660c1: call     0x140a66310
0000000140a660c6: mov      rbx, rax
0000000140a660c9: test     rax, rax
0000000140a660cc: jne      0x140a6614b
0000000140a660ce: mov      rdx, rsi
0000000140a660d1: lea      rcx, [rip + 0xf0e658]
0000000140a660d8: call     0x14127bf80
0000000140a660dd: xor      r9d, r9d
0000000140a660e0: lea      r8, [rip + 0xf0e401]
0000000140a660e7: lea      r10, [rip + 0xf0e512]
0000000140a660ee: lea      r11, [rip + 0xf0e513]
0000000140a660f5: nop      word ptr [rax + rax]
0000000140a66100: mov      rdx, qword ptr [r8]
0000000140a66103: xor      ecx, ecx
0000000140a66105: nop      word ptr [rax + rax]
0000000140a66110: movzx    eax, byte ptr [r10 + rcx]
0000000140a66115: inc      rcx
0000000140a66118: cmp      al, byte ptr [rdx + rcx - 1]
0000000140a6611c: jne      0x140a662ca
0000000140a66122: cmp      rcx, 4
0000000140a66126: jne      0x140a66110
0000000140a66128: mov      rcx, qword ptr [rip + 0x1771371]
0000000140a6612f: lea      rdx, [rip + 0xf0e3aa]
0000000140a66136: movsxd   rax, r9d
0000000140a66139: add      rax, rax
0000000140a6613c: call     qword ptr [rdx + rax*8]
0000000140a6613f: mov      rbx, rax
0000000140a66142: test     rax, rax
0000000140a66145: je       0x140a662da
0000000140a6614b: mov      rax, qword ptr [rbx]
0000000140a6614e: mov      rcx, rbx
0000000140a66151: call     qword ptr [rax + 0x18]
0000000140a66154: mov      r8, qword ptr [rbx]
0000000140a66157: mov      rcx, rbx
0000000140a6615a: cmp      eax, dword ptr [rip + 0x1111dcc]
0000000140a66160: mov      esi, eax
0000000140a66162: je       0x140a662f0
0000000140a66168: call     qword ptr [r8 + 0x40]
0000000140a6616c: lea      rcx, [rbx + 0x1e8]
0000000140a66173: mov      r8d, 3
0000000140a66179: lea      rdx, [rdi + 0x78]
0000000140a6617d: nop      dword ptr [rax]
0000000140a66180: lea      rcx, [rcx + 0x80]
0000000140a66187: movups   xmm0, xmmword ptr [rdx]
0000000140a6618a: lea      rdx, [rdx + 0x80]
0000000140a66191: movups   xmmword ptr [rcx - 0x80], xmm0
0000000140a66195: movups   xmm1, xmmword ptr [rdx - 0x70]
0000000140a66199: movups   xmmword ptr [rcx - 0x70], xmm1
0000000140a6619d: movups   xmm0, xmmword ptr [rdx - 0x60]
0000000140a661a1: movups   xmmword ptr [rcx - 0x60], xmm0
0000000140a661a5: movups   xmm1, xmmword ptr [rdx - 0x50]
0000000140a661a9: movups   xmmword ptr [rcx - 0x50], xmm1
0000000140a661ad: movups   xmm0, xmmword ptr [rdx - 0x40]
0000000140a661b1: movups   xmmword ptr [rcx - 0x40], xmm0
0000000140a661b5: movups   xmm1, xmmword ptr [rdx - 0x30]
0000000140a661b9: movups   xmmword ptr [rcx - 0x30], xmm1
0000000140a661bd: movups   xmm0, xmmword ptr [rdx - 0x20]
0000000140a661c1: movups   xmmword ptr [rcx - 0x20], xmm0
0000000140a661c5: movups   xmm1, xmmword ptr [rdx - 0x10]
0000000140a661c9: movups   xmmword ptr [rcx - 0x10], xmm1
0000000140a661cd: sub      r8, 1
0000000140a661d1: jne      0x140a66180
0000000140a661d3: movups   xmm0, xmmword ptr [rdx]
0000000140a661d6: mov      r10, qword ptr [rbx]
0000000140a661d9: lea      r8, [rdi + 0x10]
0000000140a661dd: movups   xmmword ptr [rcx], xmm0
0000000140a661e0: movups   xmm1, xmmword ptr [rdx + 0x10]
0000000140a661e4: movups   xmmword ptr [rcx + 0x10], xmm1
0000000140a661e8: movups   xmm0, xmmword ptr [rdx + 0x20]
0000000140a661ec: movups   xmmword ptr [rcx + 0x20], xmm0
0000000140a661f0: movups   xmm1, xmmword ptr [rdx + 0x30]
0000000140a661f4: lea      rdx, [rdi + 0x34]
0000000140a661f8: movups   xmmword ptr [rcx + 0x30], xmm1
0000000140a661fc: movzx    eax, byte ptr [rdi + 0x50]
0000000140a66200: lea      rcx, [rdi + 0x40]
0000000140a66204: mov      r9d, dword ptr [rdi + 0xc]
0000000140a66208: mov      byte ptr [rsp + 0x40], al
0000000140a6620c: mov      eax, dword ptr [rdi + 0x4c]
0000000140a6620f: mov      dword ptr [rsp + 0x38], eax
0000000140a66213: mov      qword ptr [rsp + 0x30], rcx
0000000140a66218: mov      rcx, rbx
0000000140a6621b: mov      qword ptr [rsp + 0x28], rdx
0000000140a66220: mov      edx, esi
0000000140a66222: mov      qword ptr [rsp + 0x20], r8
0000000140a66227: mov      r8d, dword ptr [rdi + 8]
0000000140a6622b: call     qword ptr [r10 + 0x50]
0000000140a6622f: mov      eax, dword ptr [rdi + 0x238]
0000000140a66235: mov      dword ptr [rbx + 0x160], eax
0000000140a6623b: mov      eax, dword ptr [rdi + 0x23c]
0000000140a66241: mov      dword ptr [rbx + 0x164], eax
0000000140a66247: mov      rdx, qword ptr [rdi + 0x58]
0000000140a6624b: test     rdx, rdx
0000000140a6624e: je       0x140a66258
0000000140a66250: mov      rcx, rbx
0000000140a66253: call     0x1405eaa90
0000000140a66258: cmp      dword ptr [rdi + 0x60], 0
0000000140a6625c: je       0x140a66268
0000000140a6625e: mov      dword ptr [rbx + 0x1cc], 1
0000000140a66268: cmp      dword ptr [rdi + 0x64], 0
0000000140a6626c: je       0x140a66278
0000000140a6626e: mov      dword ptr [rbx + 0x1d0], 1
0000000140a66278: cmp      dword ptr [rdi + 0x68], 0
0000000140a6627c: je       0x140a66288
0000000140a6627e: mov      dword ptr [rbx + 0x1dc], 1
0000000140a66288: cmp      dword ptr [rdi + 0x240], 0
0000000140a6628f: je       0x140a6629b
0000000140a66291: mov      dword ptr [rbx + 0x1e0], 1
0000000140a6629b: mov      rdx, qword ptr [rdi + 0x70]
0000000140a6629f: test     rdx, rdx
0000000140a662a2: je       0x140a662ac
0000000140a662a4: mov      rcx, rbx
0000000140a662a7: call     0x1405e3a70
0000000140a662ac: mov      eax, dword ptr [rdi + 0x244]
0000000140a662b2: mov      dword ptr [rbx + 0x704], eax
0000000140a662b8: mov      eax, esi
0000000140a662ba: mov      rbx, qword ptr [rsp + 0x60]
0000000140a662bf: mov      rsi, qword ptr [rsp + 0x68]
0000000140a662c4: add      rsp, 0x50
0000000140a662c8: pop      rdi
0000000140a662c9: ret      
0000000140a662ca: inc      r9d
0000000140a662cd: add      r8, 0x10
0000000140a662d1: cmp      r8, r11
0000000140a662d4: jl       0x140a66100
0000000140a662da: mov      eax, dword ptr [rip + 0x1111c4c]
0000000140a662e0: mov      rbx, qword ptr [rsp + 0x60]
0000000140a662e5: mov      rsi, qword ptr [rsp + 0x68]
0000000140a662ea: add      rsp, 0x50
0000000140a662ee: pop      rdi
0000000140a662ef: ret      
0000000140a662f0: mov      edx, 1
0000000140a662f5: call     qword ptr [r8]
0000000140a662f8: mov      rbx, qword ptr [rsp + 0x60]
0000000140a662fd: mov      eax, esi
0000000140a662ff: mov      rsi, qword ptr [rsp + 0x68]
0000000140a66304: add      rsp, 0x50
0000000140a66308: pop      rdi
0000000140a66309: ret      
