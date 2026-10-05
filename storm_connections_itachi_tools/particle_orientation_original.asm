0000000141386590: mov      qword ptr [rsp + 8], rbx
0000000141386595: mov      qword ptr [rsp + 0x10], rsi
000000014138659a: push     rdi
000000014138659b: sub      rsp, 0x90
00000001413865a2: movaps   xmmword ptr [rsp + 0x80], xmm6
00000001413865aa: mov      esi, r8d
00000001413865ad: mov      rdi, rcx
00000001413865b0: mov      rbx, qword ptr [rdx + 0x30]
00000001413865b4: xor      eax, eax
00000001413865b6: mov      edx, dword ptr [rcx + 0x190]
00000001413865bc: test     edx, edx
00000001413865be: jle      0x1413865d3
00000001413865c0: mov      rbx, qword ptr [rbx + 0x30]
00000001413865c4: test     rbx, rbx
00000001413865c7: je       0x1413866d3
00000001413865cd: inc      eax
00000001413865cf: cmp      eax, edx
00000001413865d1: jl       0x1413865c0
00000001413865d3: test     rbx, rbx
00000001413865d6: je       0x1413866d3
00000001413865dc: lea      rax, [rip + 0x80b17d]
00000001413865e3: mov      qword ptr [rsp + 0x30], rax
00000001413865e8: xorps    xmm6, xmm6
00000001413865eb: xorps    xmm3, xmm3
00000001413865ee: xorps    xmm2, xmm2
00000001413865f1: xorps    xmm1, xmm1
00000001413865f4: lea      rcx, [rsp + 0x38]
00000001413865f9: call     0x1411ab440
00000001413865fe: call     0x1400bfa80
0000000141386603: movsd    xmm0, qword ptr [rax]
0000000141386607: movsd    qword ptr [rsp + 0x38], xmm0
000000014138660d: mov      eax, dword ptr [rax + 8]
0000000141386610: mov      dword ptr [rsp + 0x40], eax
0000000141386614: mov      qword ptr [rsp + 0x44], 0
000000014138661d: xorps    xmm0, xmm0
0000000141386620: movdqa   xmmword ptr [rsp + 0x50], xmm0
0000000141386626: mov      qword ptr [rsp + 0x60], 0
000000014138662f: mov      qword ptr [rsp + 0x6c], 0xffffffffffffffff
0000000141386638: lea      rax, [rip + 0x815119]
000000014138663f: mov      qword ptr [rsp + 0x30], rax
0000000141386644: mov      dword ptr [rsp + 0x68], 1
000000014138664c: mov      qword ptr [rsp + 0x78], 0
0000000141386655: mov      rax, qword ptr [rbx]
0000000141386658: lea      rdx, [rsp + 0x30]
000000014138665d: mov      rcx, rbx
0000000141386660: call     qword ptr [rax + 0x18]
0000000141386663: mov      rdx, qword ptr [rsp + 0x78]
0000000141386668: test     rdx, rdx
000000014138666b: je       0x1413866d3
000000014138666d: movss    xmm0, dword ptr [rdi + 0x70]
0000000141386672: test     esi, esi
0000000141386674: jne      0x1413866bf
0000000141386676: ucomiss  xmm0, xmm6
0000000141386679: jp       0x1413866d3
000000014138667b: jne      0x1413866d3
000000014138667d: movss    xmm2, dword ptr [rdx + 0x80]
0000000141386685: movaps   xmm0, xmm2
0000000141386688: mulss    xmm0, dword ptr [rdx + 0x68]
000000014138668d: movss    dword ptr [rsp + 0x20], xmm0
0000000141386693: movaps   xmm1, xmm2
0000000141386696: mulss    xmm1, dword ptr [rdx + 0x6c]
000000014138669b: movss    dword ptr [rsp + 0x24], xmm1
00000001413866a1: mulss    xmm2, dword ptr [rdx + 0x70]
00000001413866a6: movss    dword ptr [rsp + 0x28], xmm2
00000001413866ac: lea      rcx, [rdi + 0x1e8]
00000001413866b3: lea      rdx, [rsp + 0x20]
00000001413866b8: call     0x1411ab760
00000001413866bd: jmp      0x1413866d3
00000001413866bf: ucomiss  xmm0, xmm6
00000001413866c2: jp       0x1413866c6
00000001413866c4: je       0x1413866d3
00000001413866c6: add      rdx, 0x68
00000001413866ca: mov      rcx, rdi
00000001413866cd: call     0x14130ac30
00000001413866d2: nop      
00000001413866d3: lea      r11, [rsp + 0x90]
00000001413866db: mov      rbx, qword ptr [r11 + 0x10]
00000001413866df: mov      rsi, qword ptr [r11 + 0x18]
00000001413866e3: movaps   xmm6, xmmword ptr [r11 - 0x10]
00000001413866e8: mov      rsp, r11
00000001413866eb: pop      rdi
00000001413866ec: ret      
