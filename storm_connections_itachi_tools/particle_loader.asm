0000000141320290: mov      qword ptr [rsp + 0x20], rbx
0000000141320295: push     rbp
0000000141320296: push     rsi
0000000141320297: push     rdi
0000000141320298: push     r12
000000014132029a: push     r13
000000014132029c: push     r14
000000014132029e: push     r15
00000001413202a0: lea      rbp, [rsp - 0x160]
00000001413202a8: sub      rsp, 0x260
00000001413202af: mov      rax, qword ptr [rip + 0xdc6112]
00000001413202b6: xor      rax, rsp
00000001413202b9: mov      qword ptr [rbp + 0x150], rax
00000001413202c0: mov      word ptr [rsp + 0x20], r9w
00000001413202c6: mov      r12, r8
00000001413202c9: mov      qword ptr [rsp + 0x30], r8
00000001413202ce: mov      r13, rdx
00000001413202d1: mov      qword ptr [rsp + 0x38], rdx
00000001413202d6: mov      rsi, rcx
00000001413202d9: mov      r8d, 0x28
00000001413202df: lea      rdx, [rcx + 0x10]
00000001413202e3: mov      rcx, r12
00000001413202e6: call     0x14132d6f0
00000001413202eb: cmp      eax, 0x28
00000001413202ee: jb       0x14132161c
00000001413202f4: mov      edx, 1
00000001413202f9: lea      rcx, [rsi + 0x10]
00000001413202fd: call     0x14131fdf0
0000000141320302: movzx    eax, word ptr [rsi + 0x14]
0000000141320306: mov      rcx, 0xffffffffffffffff
000000014132030d: xor      edi, edi
000000014132030f: test     ax, ax
0000000141320312: je       0x141320642
0000000141320318: mov      r14d, eax
000000014132031b: mov      eax, 0xe0
0000000141320320: mul      r14
0000000141320323: cmovo    rax, rcx
0000000141320327: lea      r8d, [rcx + 0x57]
000000014132032b: lea      rdx, [rip + 0x87b93e]
0000000141320332: mov      rcx, rax
0000000141320335: call     0x141272e00
000000014132033a: mov      r15, rax
000000014132033d: mov      qword ptr [rsp + 0x28], rax
0000000141320342: test     rax, rax
0000000141320345: je       0x14132036e
0000000141320347: lea      rbx, [rax + 0x10]
000000014132034b: nop      dword ptr [rax + rax]
0000000141320350: mov      qword ptr [rbx - 8], rdi
0000000141320354: mov      dword ptr [rbx], edi
0000000141320356: lea      rcx, [rbx + 0x10]
000000014132035a: call     0x14131e9f0
000000014132035f: lea      rbx, [rbx + 0xe0]
0000000141320366: sub      r14, 1
000000014132036a: jne      0x141320350
000000014132036c: jmp      0x141320371
000000014132036e: mov      r15, rdi
0000000141320371: mov      qword ptr [rsi + 0x38], r15
0000000141320375: mov      qword ptr [rbp + 0x88], rdi
000000014132037c: lea      rcx, [rbp + 0x90]
0000000141320383: call     0x14131e9f0
0000000141320388: mov      r14d, edi
000000014132038b: movzx    eax, word ptr [rsi + 0x14]
000000014132038f: cmp      di, ax
0000000141320392: jae      0x14132055e
0000000141320398: mov      rbx, rdi
000000014132039b: movzx    r15d, word ptr [rsp + 0x20]
00000001413203a1: nop      dword ptr [rax]
00000001413203a5: nop      word ptr [rax + rax]
00000001413203b0: mov      r8d, 0xd0
00000001413203b6: lea      rdx, [rbp + 0x80]
00000001413203bd: mov      rcx, r12
00000001413203c0: call     0x14132d6f0
00000001413203c5: cmp      eax, 0xd0
00000001413203ca: jb       0x14132161c
00000001413203d0: mov      ecx, dword ptr [rbp + 0x80]
00000001413203d6: call     0x1412e4220
00000001413203db: mov      dword ptr [rbp + 0x80], eax
00000001413203e1: mov      ecx, dword ptr [rbp + 0x84]
00000001413203e7: call     0x1412e4220
00000001413203ec: mov      dword ptr [rbp + 0x84], eax
00000001413203f2: mov      ecx, dword ptr [rbp + 0x88]
00000001413203f8: call     0x1412e4220
00000001413203fd: mov      dword ptr [rbp + 0x88], eax
0000000141320403: lea      rcx, [rbp + 0x90]
000000014132040a: call     0x14131fc90
000000014132040f: mov      eax, dword ptr [rbp + 0x80]
0000000141320415: mov      dword ptr [rbp - 0x60], eax
0000000141320418: mov      eax, dword ptr [rbp + 0x84]
000000014132041e: mov      dword ptr [rbp - 0x5c], eax
0000000141320421: mov      eax, dword ptr [rbp + 0x88]
0000000141320427: mov      qword ptr [rbp - 0x58], rax
000000014132042b: mov      eax, dword ptr [rbp + 0x8c]
0000000141320431: mov      dword ptr [rbp - 0x50], eax
0000000141320434: lea      rcx, [rbp - 0x40]
0000000141320438: lea      rax, [rbp + 0x90]
000000014132043f: movups   xmm0, xmmword ptr [rax]
0000000141320442: movups   xmmword ptr [rcx], xmm0
0000000141320445: movups   xmm1, xmmword ptr [rax + 0x10]
0000000141320449: movups   xmmword ptr [rcx + 0x10], xmm1
000000014132044d: movups   xmm0, xmmword ptr [rax + 0x20]
0000000141320451: movups   xmmword ptr [rcx + 0x20], xmm0
0000000141320455: movups   xmm1, xmmword ptr [rax + 0x30]
0000000141320459: movups   xmmword ptr [rcx + 0x30], xmm1
000000014132045d: movups   xmm0, xmmword ptr [rax + 0x40]
0000000141320461: movups   xmmword ptr [rcx + 0x40], xmm0
0000000141320465: movups   xmm1, xmmword ptr [rax + 0x50]
0000000141320469: movups   xmmword ptr [rcx + 0x50], xmm1
000000014132046d: movups   xmm0, xmmword ptr [rax + 0x60]
0000000141320471: movups   xmmword ptr [rcx + 0x60], xmm0
0000000141320475: movups   xmm1, xmmword ptr [rax + 0x70]
0000000141320479: movups   xmmword ptr [rcx + 0x70], xmm1
000000014132047d: movups   xmm0, xmmword ptr [rax + 0x80]
0000000141320484: movups   xmmword ptr [rcx + 0x80], xmm0
000000014132048b: movups   xmm1, xmmword ptr [rax + 0x90]
0000000141320492: movups   xmmword ptr [rcx + 0x90], xmm1
0000000141320499: movups   xmm0, xmmword ptr [rax + 0xa0]
00000001413204a0: movups   xmmword ptr [rcx + 0xa0], xmm0
00000001413204a7: movups   xmm1, xmmword ptr [rax + 0xb0]
00000001413204ae: movups   xmmword ptr [rcx + 0xb0], xmm1
00000001413204b5: mov      rcx, qword ptr [rsi + 0x38]
00000001413204b9: add      rcx, rbx
00000001413204bc: lea      rax, [rbp - 0x60]
00000001413204c0: movups   xmm0, xmmword ptr [rax]
00000001413204c3: movups   xmmword ptr [rcx], xmm0
00000001413204c6: movups   xmm1, xmmword ptr [rax + 0x10]
00000001413204ca: movups   xmmword ptr [rcx + 0x10], xmm1
00000001413204ce: movups   xmm0, xmmword ptr [rax + 0x20]
00000001413204d2: movups   xmmword ptr [rcx + 0x20], xmm0
00000001413204d6: movups   xmm1, xmmword ptr [rax + 0x30]
00000001413204da: movups   xmmword ptr [rcx + 0x30], xmm1
00000001413204de: movups   xmm0, xmmword ptr [rax + 0x40]
00000001413204e2: movups   xmmword ptr [rcx + 0x40], xmm0
00000001413204e6: movups   xmm1, xmmword ptr [rax + 0x50]
00000001413204ea: movups   xmmword ptr [rcx + 0x50], xmm1
00000001413204ee: movups   xmm0, xmmword ptr [rax + 0x60]
00000001413204f2: movups   xmmword ptr [rcx + 0x60], xmm0
00000001413204f6: sub      rcx, -0x80
00000001413204fa: movups   xmm1, xmmword ptr [rax + 0x70]
00000001413204fe: movups   xmmword ptr [rcx - 0x10], xmm1
0000000141320502: lea      rax, [rax + 0x80]
0000000141320509: movups   xmm0, xmmword ptr [rax]
000000014132050c: movups   xmmword ptr [rcx], xmm0
000000014132050f: movups   xmm1, xmmword ptr [rax + 0x10]
0000000141320513: movups   xmmword ptr [rcx + 0x10], xmm1
0000000141320517: movups   xmm0, xmmword ptr [rax + 0x20]
000000014132051b: movups   xmmword ptr [rcx + 0x20], xmm0
000000014132051f: movups   xmm1, xmmword ptr [rax + 0x30]
0000000141320523: movups   xmmword ptr [rcx + 0x30], xmm1
0000000141320527: movups   xmm0, xmmword ptr [rax + 0x40]
000000014132052b: movups   xmmword ptr [rcx + 0x40], xmm0
000000014132052f: movups   xmm1, xmmword ptr [rax + 0x50]
0000000141320533: movups   xmmword ptr [rcx + 0x50], xmm1
0000000141320537: cmp      r15w, 0x7b
000000014132053c: jae      0x141320547
000000014132053e: mov      rax, qword ptr [rsi + 0x38]
0000000141320542: mov      byte ptr [rbx + rax + 0x2e], dil
0000000141320547: inc      r14d
000000014132054a: add      rbx, 0xe0
0000000141320551: movzx    eax, word ptr [rsi + 0x14]
0000000141320555: cmp      r14d, eax
0000000141320558: jl       0x1413203b0
000000014132055e: mov      r14d, edi
0000000141320561: cmp      di, ax
0000000141320564: jae      0x14132063b
000000014132056a: mov      rbx, rdi
000000014132056d: nop      dword ptr [rax]
0000000141320570: mov      rax, qword ptr [rsi + 0x38]
0000000141320574: mov      edx, dword ptr [rbx + rax]
0000000141320577: mov      rcx, r13
000000014132057a: call     0x1412864d0
000000014132057f: mov      rcx, qword ptr [rsi + 0x38]
0000000141320583: mov      qword ptr [rbx + rcx + 8], rax
0000000141320588: mov      rax, qword ptr [rsi + 0x38]
000000014132058c: test     byte ptr [rbx + rax + 0x26], 2
0000000141320591: jne      0x141320624
0000000141320597: mov      dword ptr [rbx + rax + 0xa0], 0x3f800000
00000001413205a2: mov      rax, qword ptr [rsi + 0x38]
00000001413205a6: mov      dword ptr [rbx + rax + 0xa4], 0x3f800000
00000001413205b1: mov      rax, qword ptr [rsi + 0x38]
00000001413205b5: mov      dword ptr [rbx + rax + 0xa8], 0x3f800000
00000001413205c0: mov      rax, qword ptr [rsi + 0x38]
00000001413205c4: mov      dword ptr [rbx + rax + 0xb0], 0x3f800000
00000001413205cf: mov      rax, qword ptr [rsi + 0x38]
00000001413205d3: mov      dword ptr [rbx + rax + 0xb4], 0x3f800000
00000001413205de: mov      rax, qword ptr [rsi + 0x38]
00000001413205e2: mov      dword ptr [rbx + rax + 0xb8], 0x3f800000
00000001413205ed: mov      rax, qword ptr [rsi + 0x38]
00000001413205f1: mov      dword ptr [rbx + rax + 0xc0], 0x3f800000
00000001413205fc: mov      rax, qword ptr [rsi + 0x38]
0000000141320600: mov      dword ptr [rbx + rax + 0xc4], 0x3f800000
000000014132060b: mov      rax, qword ptr [rsi + 0x38]
000000014132060f: mov      dword ptr [rbx + rax + 0xc8], 0x3f800000
000000014132061a: mov      rax, qword ptr [rsi + 0x38]
000000014132061e: or       word ptr [rbx + rax + 0x26], 2
0000000141320624: inc      r14d
0000000141320627: add      rbx, 0xe0
000000014132062e: movzx    eax, word ptr [rsi + 0x14]
0000000141320632: cmp      r14d, eax
0000000141320635: jl       0x141320570
000000014132063b: mov      rcx, 0xffffffffffffffff
0000000141320642: movzx    eax, word ptr [rsi + 0x1c]
0000000141320646: test     ax, ax
0000000141320649: je       0x14132091f
000000014132064f: mov      ebx, eax
0000000141320651: mov      eax, 0x30
0000000141320656: mul      rbx
0000000141320659: cmovo    rax, rcx
000000014132065d: mov      r8d, 0x86
0000000141320663: lea      rdx, [rip + 0x87b606]
000000014132066a: mov      rcx, rax
000000014132066d: call     0x141272e00
0000000141320672: mov      qword ptr [rsp + 0x28], rax
0000000141320677: test     rax, rax
000000014132067a: je       0x141320692
000000014132067c: lea      rcx, [rax + 0x10]
0000000141320680: mov      qword ptr [rcx - 8], rdi
0000000141320684: mov      dword ptr [rcx], edi
0000000141320686: lea      rcx, [rcx + 0x30]
000000014132068a: sub      rbx, 1
000000014132068e: jne      0x141320680
0000000141320690: jmp      0x141320695
0000000141320692: mov      rax, rdi
0000000141320695: mov      qword ptr [rsi + 0x40], rax
0000000141320699: mov      qword ptr [rbp - 0x80], rdi
000000014132069d: mov      r14d, edi
00000001413206a0: movzx    eax, word ptr [rsi + 0x1c]
00000001413206a4: cmp      di, ax
00000001413206a7: jae      0x141320783
00000001413206ad: mov      rbx, rdi
00000001413206b0: mov      r8d, 0x20
00000001413206b6: lea      rdx, [rsp + 0x78]
00000001413206bb: mov      rcx, r12
00000001413206be: call     0x14132d6f0
00000001413206c3: cmp      eax, 0x20
00000001413206c6: jb       0x14132161c
00000001413206cc: mov      ecx, dword ptr [rsp + 0x78]
00000001413206d0: call     0x1412e4220
00000001413206d5: mov      dword ptr [rsp + 0x78], eax
00000001413206d9: mov      ecx, dword ptr [rsp + 0x7c]
00000001413206dd: call     0x1412e4220
00000001413206e2: mov      dword ptr [rsp + 0x7c], eax
00000001413206e6: mov      ecx, dword ptr [rbp - 0x80]
00000001413206e9: call     0x1412e4220
00000001413206ee: mov      dword ptr [rbp - 0x80], eax
00000001413206f1: mov      ecx, dword ptr [rbp - 0x78]
00000001413206f4: call     0x1412e4220
00000001413206f9: mov      dword ptr [rbp - 0x78], eax
00000001413206fc: mov      ecx, dword ptr [rbp - 0x70]
00000001413206ff: call     0x1412e4220
0000000141320704: mov      dword ptr [rbp - 0x70], eax
0000000141320707: mov      ecx, dword ptr [rbp - 0x6c]
000000014132070a: call     0x1412e4220
000000014132070f: mov      edx, eax
0000000141320711: mov      dword ptr [rbp - 0x6c], eax
0000000141320714: mov      ecx, dword ptr [rsp + 0x78]
0000000141320718: mov      dword ptr [rsp + 0x40], ecx
000000014132071c: mov      ecx, dword ptr [rsp + 0x7c]
0000000141320720: mov      dword ptr [rsp + 0x44], ecx
0000000141320724: mov      ecx, dword ptr [rbp - 0x80]
0000000141320727: mov      qword ptr [rsp + 0x48], rcx
000000014132072c: mov      ecx, dword ptr [rbp - 0x7c]
000000014132072f: mov      dword ptr [rsp + 0x50], ecx
0000000141320733: mov      ecx, dword ptr [rbp - 0x78]
0000000141320736: mov      qword ptr [rsp + 0x58], rcx
000000014132073b: mov      ecx, dword ptr [rbp - 0x74]
000000014132073e: mov      qword ptr [rsp + 0x60], rcx
0000000141320743: mov      eax, dword ptr [rbp - 0x70]
0000000141320746: mov      dword ptr [rsp + 0x68], eax
000000014132074a: mov      dword ptr [rsp + 0x6c], edx
000000014132074e: mov      rax, qword ptr [rsi + 0x40]
0000000141320752: movups   xmm0, xmmword ptr [rsp + 0x40]
0000000141320757: movups   xmmword ptr [rbx + rax], xmm0
000000014132075b: movups   xmm1, xmmword ptr [rsp + 0x50]
0000000141320760: movups   xmmword ptr [rbx + rax + 0x10], xmm1
0000000141320765: movups   xmm0, xmmword ptr [rsp + 0x60]
000000014132076a: movups   xmmword ptr [rbx + rax + 0x20], xmm0
000000014132076f: inc      r14d
0000000141320772: add      rbx, 0x30
0000000141320776: movzx    eax, word ptr [rsi + 0x1c]
000000014132077a: cmp      r14d, eax
000000014132077d: jl       0x1413206b0
0000000141320783: mov      ebx, edi
0000000141320785: mov      dword ptr [rsp + 0x28], ebx
0000000141320789: cmp      di, ax
000000014132078c: jae      0x14132091f
0000000141320792: mov      r12, rdi
0000000141320795: nop      word ptr [rax + rax]
00000001413207a0: mov      rax, qword ptr [rsi + 0x40]
00000001413207a4: mov      edx, dword ptr [r12 + rax]
00000001413207a8: mov      rcx, r13
00000001413207ab: call     0x1412864d0
00000001413207b0: mov      r14, rax
00000001413207b3: test     rax, rax
00000001413207b6: je       0x1413208ff
00000001413207bc: mov      r15d, edi
00000001413207bf: lea      rcx, [rip + 0x83e8b6a]
00000001413207c6: call     0x141293e90
00000001413207cb: test     eax, eax
00000001413207cd: jle      0x14132083b
00000001413207cf: nop      
00000001413207d0: mov      edx, r15d
00000001413207d3: lea      rcx, [rip + 0x83e8b56]
00000001413207da: call     0x141293ce0
00000001413207df: test     rax, rax
00000001413207e2: je       0x141320823
00000001413207e4: mov      rdx, rax
00000001413207e7: lea      rcx, [rip + 0x83e8b42]
00000001413207ee: call     0x141294c00
00000001413207f3: mov      r13, rax
00000001413207f6: test     rax, rax
00000001413207f9: je       0x141320823
00000001413207fb: mov      rdx, qword ptr [r14]
00000001413207fe: mov      rcx, r14
0000000141320801: call     qword ptr [rdx + 0x18]
0000000141320804: mov      rbx, rax
0000000141320807: mov      rdx, qword ptr [r14]
000000014132080a: mov      rcx, r14
000000014132080d: call     qword ptr [rdx + 0x30]
0000000141320810: mov      rdx, rax
0000000141320813: mov      r8, rbx
0000000141320816: mov      rcx, r13
0000000141320819: call     0x141287ca0
000000014132081e: test     rax, rax
0000000141320821: jne      0x141320865
0000000141320823: inc      r15d
0000000141320826: lea      rcx, [rip + 0x83e8b03]
000000014132082d: call     0x141293e90
0000000141320832: cmp      r15d, eax
0000000141320835: jl       0x1413207d0
0000000141320837: mov      ebx, dword ptr [rsp + 0x28]
000000014132083b: mov      rcx, qword ptr [rsi + 0x40]
000000014132083f: add      rcx, r12
0000000141320842: mov      qword ptr [rcx + 0x18], rdi
0000000141320846: mov      qword ptr [rcx + 0x20], rdi
000000014132084a: mov      qword ptr [rcx + 0x28], rdi
000000014132084e: mov      rax, qword ptr [rsi + 0x40]
0000000141320852: mov      qword ptr [r12 + rax + 0x18], r14
0000000141320857: mov      dword ptr [r12 + rax + 0x2c], 6
0000000141320860: jmp      0x1413208ff
0000000141320865: mov      rcx, qword ptr [rsi + 0x40]
0000000141320869: mov      edx, dword ptr [rcx + r12 + 0x2c]
000000014132086e: sub      edx, 1
0000000141320871: je       0x1413209e8
0000000141320877: sub      edx, 1
000000014132087a: je       0x1413209a5
0000000141320880: sub      edx, 1
0000000141320883: je       0x1413208cf
0000000141320885: sub      edx, 1
0000000141320888: je       0x1413208cf
000000014132088a: cmp      edx, 1
000000014132088d: jne      0x1413208fb
000000014132088f: mov      rax, qword ptr [r14]
0000000141320892: mov      rcx, r14
0000000141320895: call     qword ptr [rax + 0x18]
0000000141320898: mov      rbx, rax
000000014132089b: mov      rdx, qword ptr [r14]
000000014132089e: mov      rcx, r14
00000001413208a1: call     qword ptr [rdx + 0x30]
00000001413208a4: mov      rdx, rax
00000001413208a7: mov      r8, rbx
00000001413208aa: mov      rcx, r13
00000001413208ad: call     0x141287ca0
00000001413208b2: mov      rcx, qword ptr [rsi + 0x40]
00000001413208b6: mov      ebx, dword ptr [rsp + 0x28]
00000001413208ba: test     rax, rax
00000001413208bd: je       0x1413208ff
00000001413208bf: mov      qword ptr [r12 + rcx + 0x18], rax
00000001413208c4: mov      dword ptr [r12 + rcx + 0x2c], 5
00000001413208cd: jmp      0x1413208ff
00000001413208cf: mov      rax, qword ptr [r14]
00000001413208d2: mov      rcx, r14
00000001413208d5: call     qword ptr [rax + 0x18]
00000001413208d8: mov      rbx, rax
00000001413208db: mov      rdx, qword ptr [r14]
00000001413208de: mov      rcx, r14
00000001413208e1: call     qword ptr [rdx + 0x30]
00000001413208e4: mov      rdx, rax
00000001413208e7: mov      r8, rbx
00000001413208ea: mov      rcx, r13
00000001413208ed: call     0x141287ca0
00000001413208f2: mov      rcx, qword ptr [rsi + 0x40]
00000001413208f6: mov      qword ptr [r12 + rcx + 0x18], rax
00000001413208fb: mov      ebx, dword ptr [rsp + 0x28]
00000001413208ff: inc      ebx
0000000141320901: mov      dword ptr [rsp + 0x28], ebx
0000000141320905: add      r12, 0x30
0000000141320909: movzx    eax, word ptr [rsi + 0x1c]
000000014132090d: cmp      ebx, eax
000000014132090f: mov      r13, qword ptr [rsp + 0x38]
0000000141320914: jl       0x1413207a0
000000014132091a: mov      r12, qword ptr [rsp + 0x30]
000000014132091f: movzx    eax, word ptr [rsi + 0x24]
0000000141320923: test     ax, ax
0000000141320926: je       0x141320d28
000000014132092c: mov      ebx, eax
000000014132092e: mov      eax, 0x48
0000000141320933: mul      rbx
0000000141320936: mov      rcx, 0xffffffffffffffff
000000014132093d: cmovo    rax, rcx
0000000141320941: mov      r8d, 0xd0
0000000141320947: lea      rdx, [rip + 0x87b322]
000000014132094e: mov      rcx, rax
0000000141320951: call     0x141272e00
0000000141320956: mov      qword ptr [rsp + 0x30], rax
000000014132095b: test     rax, rax
000000014132095e: je       0x141320a2f
0000000141320964: lea      rcx, [rax + 0x20]
0000000141320968: nop      dword ptr [rax + rax]
0000000141320970: mov      qword ptr [rcx - 0x18], rdi
0000000141320974: mov      dword ptr [rcx - 0x10], edi
0000000141320977: mov      dword ptr [rcx - 8], edi
000000014132097a: mov      dword ptr [rcx - 4], 0xbf800000
0000000141320981: mov      dword ptr [rcx], edi
0000000141320983: mov      dword ptr [rcx + 4], 1
000000014132098a: mov      qword ptr [rcx + 8], 1
0000000141320992: mov      qword ptr [rcx + 0x10], rdi
0000000141320996: lea      rcx, [rcx + 0x48]
000000014132099a: sub      rbx, 1
000000014132099e: jne      0x141320970
00000001413209a0: jmp      0x141320a32
00000001413209a5: mov      rax, qword ptr [r14]
00000001413209a8: mov      rcx, r14
00000001413209ab: call     qword ptr [rax + 0x18]
00000001413209ae: mov      rbx, rax
00000001413209b1: mov      rdx, qword ptr [r14]
00000001413209b4: mov      rcx, r14
00000001413209b7: call     qword ptr [rdx + 0x30]
00000001413209ba: mov      rdx, rax
00000001413209bd: mov      r8, rbx
00000001413209c0: mov      rcx, r13
00000001413209c3: call     0x141287ca0
00000001413209c8: mov      rcx, qword ptr [rsi + 0x40]
00000001413209cc: test     rax, rax
00000001413209cf: je       0x1413208fb
00000001413209d5: mov      qword ptr [r12 + rcx + 0x18], rax
00000001413209da: mov      dword ptr [r12 + rcx + 0x2c], 2
00000001413209e3: jmp      0x1413208fb
00000001413209e8: mov      rax, qword ptr [r14]
00000001413209eb: mov      rcx, r14
00000001413209ee: call     qword ptr [rax + 0x18]
00000001413209f1: mov      rbx, rax
00000001413209f4: mov      rdx, qword ptr [r14]
00000001413209f7: mov      rcx, r14
00000001413209fa: call     qword ptr [rdx + 0x30]
00000001413209fd: mov      rdx, rax
0000000141320a00: mov      r8, rbx
0000000141320a03: mov      rcx, r13
0000000141320a06: call     0x141287ca0
0000000141320a0b: mov      rcx, qword ptr [rsi + 0x40]
0000000141320a0f: mov      ebx, dword ptr [rsp + 0x28]
0000000141320a13: test     rax, rax
0000000141320a16: je       0x1413208ff
0000000141320a1c: mov      qword ptr [r12 + rcx + 0x18], rax
0000000141320a21: mov      dword ptr [r12 + rcx + 0x2c], 1
0000000141320a2a: jmp      0x1413208ff
0000000141320a2f: mov      rax, rdi
0000000141320a32: mov      qword ptr [rsi + 0x48], rax
0000000141320a36: movzx    eax, word ptr [rsi + 0x24]
0000000141320a3a: movzx    r15d, word ptr [rsp + 0x20]
0000000141320a40: mov      r14d, edi
0000000141320a43: cmp      r15w, 0x77
0000000141320a48: ja       0x141320b90
0000000141320a4e: cmp      di, ax
0000000141320a51: jae      0x141320cd3
0000000141320a57: mov      rbx, rdi
0000000141320a5a: nop      word ptr [rax + rax]
0000000141320a60: mov      qword ptr [rsp + 0x48], rdi
0000000141320a65: mov      dword ptr [rsp + 0x50], edi
0000000141320a69: mov      dword ptr [rsp + 0x54], 0xbf800000
0000000141320a71: mov      dword ptr [rsp + 0x58], edi
0000000141320a75: mov      dword ptr [rsp + 0x5c], 1
0000000141320a7d: mov      qword ptr [rsp + 0x60], 1
0000000141320a86: mov      qword ptr [rsp + 0x68], rdi
0000000141320a8b: mov      r8d, 0x30
0000000141320a91: lea      rdx, [rsp + 0x40]
0000000141320a96: mov      rcx, r12
0000000141320a99: call     0x14132d6f0
0000000141320a9e: cmp      eax, 0x30
0000000141320aa1: jb       0x14132161c
0000000141320aa7: mov      ecx, dword ptr [rsp + 0x40]
0000000141320aab: call     0x1412e4220
0000000141320ab0: mov      dword ptr [rsp + 0x40], eax
0000000141320ab4: mov      ecx, dword ptr [rsp + 0x44]
0000000141320ab8: call     0x1412e4220
0000000141320abd: mov      dword ptr [rsp + 0x44], eax
0000000141320ac1: mov      ecx, dword ptr [rsp + 0x48]
0000000141320ac5: call     0x1412e4220
0000000141320aca: mov      dword ptr [rsp + 0x48], eax
0000000141320ace: lea      rcx, [rsp + 0x50]
0000000141320ad3: call     0x1412e5110
0000000141320ad8: mov      ecx, dword ptr [rsp + 0x5c]
0000000141320adc: call     0x1412e4220
0000000141320ae1: mov      dword ptr [rsp + 0x5c], eax
0000000141320ae5: mov      ecx, dword ptr [rsp + 0x60]
0000000141320ae9: call     0x1412e4220
0000000141320aee: mov      dword ptr [rsp + 0x60], eax
0000000141320af2: mov      eax, dword ptr [rsp + 0x40]
0000000141320af6: mov      dword ptr [rbp - 0x60], eax
0000000141320af9: mov      eax, dword ptr [rsp + 0x44]
0000000141320afd: mov      dword ptr [rbp - 0x5c], eax
0000000141320b00: mov      eax, dword ptr [rsp + 0x48]
0000000141320b04: mov      qword ptr [rbp - 0x58], rax
0000000141320b08: mov      eax, dword ptr [rsp + 0x4c]
0000000141320b0c: mov      dword ptr [rbp - 0x50], eax
0000000141320b0f: movups   xmm0, xmmword ptr [rsp + 0x50]
0000000141320b14: movups   xmmword ptr [rbp - 0x48], xmm0
0000000141320b18: movups   xmm1, xmmword ptr [rsp + 0x60]
0000000141320b1d: movups   xmmword ptr [rbp - 0x38], xmm1
0000000141320b21: mov      eax, dword ptr [rsp + 0x70]
0000000141320b25: mov      dword ptr [rbp - 0x28], eax
0000000141320b28: mov      eax, dword ptr [rsp + 0x74]
0000000141320b2c: mov      qword ptr [rbp - 0x20], rax
0000000141320b30: mov      rax, qword ptr [rsi + 0x48]
0000000141320b34: movaps   xmm0, xmmword ptr [rbp - 0x60]
0000000141320b38: movups   xmmword ptr [rbx + rax], xmm0
0000000141320b3c: movaps   xmm1, xmmword ptr [rbp - 0x50]
0000000141320b40: movups   xmmword ptr [rbx + rax + 0x10], xmm1
0000000141320b45: movaps   xmm0, xmmword ptr [rbp - 0x40]
0000000141320b49: movups   xmmword ptr [rbx + rax + 0x20], xmm0
0000000141320b4e: movaps   xmm1, xmmword ptr [rbp - 0x30]
0000000141320b52: movups   xmmword ptr [rbx + rax + 0x30], xmm1
0000000141320b57: movsd    xmm0, qword ptr [rbp - 0x20]
0000000141320b5c: movsd    qword ptr [rbx + rax + 0x40], xmm0
0000000141320b62: mov      rax, qword ptr [rsi + 0x48]
0000000141320b66: mov      dword ptr [rbx + rax + 0x38], 0xffffffff
0000000141320b6e: mov      rax, qword ptr [rsi + 0x48]
0000000141320b72: mov      qword ptr [rbx + rax + 0x40], rdi
0000000141320b77: inc      r14d
0000000141320b7a: add      rbx, 0x48
0000000141320b7e: movzx    eax, word ptr [rsi + 0x24]
0000000141320b82: cmp      r14d, eax
0000000141320b85: jl       0x141320a60
0000000141320b8b: jmp      0x141320cd3
0000000141320b90: mov      qword ptr [rsp + 0x48], rdi
0000000141320b95: mov      dword ptr [rsp + 0x50], edi
0000000141320b99: mov      dword ptr [rsp + 0x54], 0xbf800000
0000000141320ba1: mov      dword ptr [rsp + 0x58], edi
0000000141320ba5: mov      dword ptr [rsp + 0x5c], 1
0000000141320bad: mov      qword ptr [rsp + 0x60], 1
0000000141320bb6: mov      qword ptr [rsp + 0x68], rdi
0000000141320bbb: cmp      di, ax
0000000141320bbe: jae      0x141320cd3
0000000141320bc4: mov      rbx, rdi
0000000141320bc7: nop      word ptr [rax + rax]
0000000141320bd0: mov      r8d, 0x38
0000000141320bd6: lea      rdx, [rsp + 0x40]
0000000141320bdb: mov      rcx, r12
0000000141320bde: call     0x14132d6f0
0000000141320be3: cmp      eax, 0x38
0000000141320be6: jb       0x14132161c
0000000141320bec: mov      ecx, dword ptr [rsp + 0x40]
0000000141320bf0: call     0x1412e4220
0000000141320bf5: mov      dword ptr [rsp + 0x40], eax
0000000141320bf9: mov      ecx, dword ptr [rsp + 0x44]
0000000141320bfd: call     0x1412e4220
0000000141320c02: mov      dword ptr [rsp + 0x44], eax
0000000141320c06: mov      ecx, dword ptr [rsp + 0x48]
0000000141320c0a: call     0x1412e4220
0000000141320c0f: mov      dword ptr [rsp + 0x48], eax
0000000141320c13: lea      rcx, [rsp + 0x50]
0000000141320c18: call     0x1412e5110
0000000141320c1d: mov      ecx, dword ptr [rsp + 0x5c]
0000000141320c21: call     0x1412e4220
0000000141320c26: mov      dword ptr [rsp + 0x5c], eax
0000000141320c2a: mov      ecx, dword ptr [rsp + 0x60]
0000000141320c2e: call     0x1412e4220
0000000141320c33: mov      dword ptr [rsp + 0x60], eax
0000000141320c37: mov      ecx, dword ptr [rsp + 0x70]
0000000141320c3b: call     0x1412e4220
0000000141320c40: mov      dword ptr [rsp + 0x70], eax
0000000141320c44: mov      ecx, dword ptr [rsp + 0x74]
0000000141320c48: call     0x1412e4220
0000000141320c4d: mov      edx, eax
0000000141320c4f: mov      dword ptr [rsp + 0x74], edx
0000000141320c53: mov      ecx, dword ptr [rsp + 0x40]
0000000141320c57: mov      dword ptr [rbp - 0x60], ecx
0000000141320c5a: mov      ecx, dword ptr [rsp + 0x44]
0000000141320c5e: mov      dword ptr [rbp - 0x5c], ecx
0000000141320c61: mov      ecx, dword ptr [rsp + 0x48]
0000000141320c65: mov      qword ptr [rbp - 0x58], rcx
0000000141320c69: mov      ecx, dword ptr [rsp + 0x4c]
0000000141320c6d: mov      dword ptr [rbp - 0x50], ecx
0000000141320c70: movups   xmm0, xmmword ptr [rsp + 0x50]
0000000141320c75: movups   xmmword ptr [rbp - 0x48], xmm0
0000000141320c79: movups   xmm1, xmmword ptr [rsp + 0x60]
0000000141320c7e: movups   xmmword ptr [rbp - 0x38], xmm1
0000000141320c82: mov      eax, dword ptr [rsp + 0x70]
0000000141320c86: mov      dword ptr [rbp - 0x28], eax
0000000141320c89: mov      qword ptr [rbp - 0x20], rdx
0000000141320c8d: mov      rax, qword ptr [rsi + 0x48]
0000000141320c91: movaps   xmm0, xmmword ptr [rbp - 0x60]
0000000141320c95: movups   xmmword ptr [rbx + rax], xmm0
0000000141320c99: movaps   xmm1, xmmword ptr [rbp - 0x50]
0000000141320c9d: movups   xmmword ptr [rbx + rax + 0x10], xmm1
0000000141320ca2: movaps   xmm0, xmmword ptr [rbp - 0x40]
0000000141320ca6: movups   xmmword ptr [rbx + rax + 0x20], xmm0
0000000141320cab: movaps   xmm1, xmmword ptr [rbp - 0x30]
0000000141320caf: movups   xmmword ptr [rbx + rax + 0x30], xmm1
0000000141320cb4: movsd    xmm0, qword ptr [rbp - 0x20]
0000000141320cb9: movsd    qword ptr [rbx + rax + 0x40], xmm0
0000000141320cbf: inc      r14d
0000000141320cc2: add      rbx, 0x48
0000000141320cc6: movzx    eax, word ptr [rsi + 0x24]
0000000141320cca: cmp      r14d, eax
0000000141320ccd: jl       0x141320bd0
0000000141320cd3: mov      r14d, edi
0000000141320cd6: cmp      di, ax
0000000141320cd9: jae      0x141320d2e
0000000141320cdb: mov      rbx, rdi
0000000141320cde: nop      
0000000141320ce0: mov      rax, qword ptr [rsi + 0x48]
0000000141320ce4: mov      edx, dword ptr [rbx + rax]
0000000141320ce7: mov      rcx, r13
0000000141320cea: call     0x1412864d0
0000000141320cef: mov      rcx, qword ptr [rsi + 0x48]
0000000141320cf3: mov      qword ptr [rbx + rcx + 8], rax
0000000141320cf8: mov      rax, qword ptr [rsi + 0x48]
0000000141320cfc: mov      edx, dword ptr [rbx + rax + 0x38]
0000000141320d00: cmp      edx, -1
0000000141320d03: je       0x141320d16
0000000141320d05: mov      rcx, r13
0000000141320d08: call     0x1412864d0
0000000141320d0d: mov      rcx, qword ptr [rsi + 0x48]
0000000141320d11: mov      qword ptr [rbx + rcx + 0x40], rax
0000000141320d16: inc      r14d
0000000141320d19: add      rbx, 0x48
0000000141320d1d: movzx    eax, word ptr [rsi + 0x24]
0000000141320d21: cmp      r14d, eax
0000000141320d24: jl       0x141320ce0
0000000141320d26: jmp      0x141320d2e
0000000141320d28: movzx    r15d, word ptr [rsp + 0x20]
0000000141320d2e: movzx    eax, word ptr [rsi + 0x2c]
0000000141320d32: test     ax, ax
0000000141320d35: je       0x141321209
0000000141320d3b: mov      r14d, eax
0000000141320d3e: mov      eax, 0x90
0000000141320d43: mul      r14
0000000141320d46: mov      rcx, 0xffffffffffffffff
0000000141320d4d: cmovo    rax, rcx
0000000141320d51: mov      r8d, 0x107
0000000141320d57: lea      rdx, [rip + 0x87af12]
0000000141320d5e: mov      rcx, rax
0000000141320d61: call     0x141272e00
0000000141320d66: mov      r15, rax
0000000141320d69: mov      qword ptr [rsp + 0x30], rax
0000000141320d6e: test     rax, rax
0000000141320d71: je       0x141320dca
0000000141320d73: lea      rbx, [rax + 0x60]
0000000141320d77: nop      word ptr [rax + rax]
0000000141320d80: mov      qword ptr [rbx - 0x58], rdi
0000000141320d84: mov      dword ptr [rbx - 0x50], edi
0000000141320d87: mov      dword ptr [rbx - 0x48], edi
0000000141320d8a: mov      dword ptr [rbx - 0x44], 0xbf800000
0000000141320d91: mov      dword ptr [rbx - 0x40], edi
0000000141320d94: mov      dword ptr [rbx - 0x3c], 1
0000000141320d9b: mov      qword ptr [rbx - 0x38], 1
0000000141320da3: mov      qword ptr [rbx - 0x30], rdi
0000000141320da7: mov      qword ptr [rbx - 0x10], rdi
0000000141320dab: mov      qword ptr [rbx], rdi
0000000141320dae: mov      qword ptr [rbx + 8], rdi
0000000141320db2: lea      rcx, [rbx - 0x20]
0000000141320db6: call     0x141387d10
0000000141320dbb: lea      rbx, [rbx + 0x90]
0000000141320dc2: sub      r14, 1
0000000141320dc6: jne      0x141320d80
0000000141320dc8: jmp      0x141320dcd
0000000141320dca: mov      r15, rdi
0000000141320dcd: mov      qword ptr [rsi + 0x50], r15
0000000141320dd1: movzx    r15d, word ptr [rsp + 0x20]
0000000141320dd7: cmp      r15w, 0x77
0000000141320ddc: ja       0x141320fce
0000000141320de2: mov      r14d, edi
0000000141320de5: movzx    ecx, word ptr [rsi + 0x2c]
0000000141320de9: cmp      di, cx
0000000141320dec: jae      0x1413211ae
0000000141320df2: mov      rbx, rdi
0000000141320df5: mov      qword ptr [rbp - 0x58], rdi
0000000141320df9: mov      dword ptr [rbp - 0x50], 0
0000000141320e00: mov      dword ptr [rbp - 0x4c], 0xbf800000
0000000141320e07: mov      dword ptr [rbp - 0x48], 0
0000000141320e0e: mov      dword ptr [rbp - 0x44], 1
0000000141320e15: mov      qword ptr [rbp - 0x40], 1
0000000141320e1d: mov      qword ptr [rbp - 0x38], rdi
0000000141320e21: mov      qword ptr [rbp - 0x20], 0
0000000141320e29: xorps    xmm0, xmm0
0000000141320e2c: movaps   xmmword ptr [rbp - 0x10], xmm0
0000000141320e30: lea      rcx, [rbp - 0x30]
0000000141320e34: call     0x141387d10
0000000141320e39: mov      r8d, 0x60
0000000141320e3f: lea      rdx, [rbp - 0x60]
0000000141320e43: mov      rcx, r12
0000000141320e46: call     0x14132d6f0
0000000141320e4b: cmp      eax, 0x60
0000000141320e4e: jb       0x14132161c
0000000141320e54: mov      ecx, dword ptr [rbp - 0x60]
0000000141320e57: call     0x1412e4220
0000000141320e5c: mov      dword ptr [rbp - 0x60], eax
0000000141320e5f: mov      ecx, dword ptr [rbp - 0x5c]
0000000141320e62: call     0x1412e4220
0000000141320e67: mov      dword ptr [rbp - 0x5c], eax
0000000141320e6a: mov      ecx, dword ptr [rbp - 0x58]
0000000141320e6d: call     0x1412e4220
0000000141320e72: mov      dword ptr [rbp - 0x58], eax
0000000141320e75: lea      rcx, [rbp - 0x50]
0000000141320e79: call     0x1412e5110
0000000141320e7e: mov      ecx, dword ptr [rbp - 0x44]
0000000141320e81: call     0x1412e4220
0000000141320e86: mov      dword ptr [rbp - 0x44], eax
0000000141320e89: mov      ecx, dword ptr [rbp - 0x40]
0000000141320e8c: call     0x1412e4220
0000000141320e91: mov      dword ptr [rbp - 0x40], eax
0000000141320e94: mov      ecx, dword ptr [rbp - 0x2c]
0000000141320e97: call     0x1412e4220
0000000141320e9c: mov      dword ptr [rbp - 0x2c], eax
0000000141320e9f: mov      ecx, dword ptr [rbp - 0x28]
0000000141320ea2: call     0x1412e4220
0000000141320ea7: mov      dword ptr [rbp - 0x28], eax
0000000141320eaa: mov      ecx, dword ptr [rbp - 0x24]
0000000141320ead: call     0x1412e4220
0000000141320eb2: mov      dword ptr [rbp - 0x24], eax
0000000141320eb5: mov      ecx, dword ptr [rbp - 0x20]
0000000141320eb8: call     0x1412e4220
0000000141320ebd: mov      dword ptr [rbp - 0x20], eax
0000000141320ec0: mov      ecx, dword ptr [rbp - 0x1c]
0000000141320ec3: call     0x1412e4220
0000000141320ec8: mov      dword ptr [rbp - 0x1c], eax
0000000141320ecb: lea      rcx, [rbp - 0x10]
0000000141320ecf: call     0x1412e48d0
0000000141320ed4: mov      ecx, dword ptr [rbp]
0000000141320ed7: call     0x1412e4220
0000000141320edc: mov      dword ptr [rbp], eax
0000000141320edf: mov      ecx, dword ptr [rbp + 4]
0000000141320ee2: call     0x1412e4220
0000000141320ee7: mov      edx, eax
0000000141320ee9: mov      ecx, dword ptr [rbp - 0x60]
0000000141320eec: mov      dword ptr [rbp + 0x80], ecx
0000000141320ef2: mov      ecx, dword ptr [rbp - 0x5c]
0000000141320ef5: mov      dword ptr [rbp + 0x84], ecx
0000000141320efb: mov      ecx, dword ptr [rbp - 0x58]
0000000141320efe: mov      qword ptr [rbp + 0x88], rcx
0000000141320f05: mov      ecx, dword ptr [rbp - 0x54]
0000000141320f08: mov      dword ptr [rbp + 0x90], ecx
0000000141320f0e: movaps   xmm0, xmmword ptr [rbp - 0x50]
0000000141320f12: movups   xmmword ptr [rbp + 0x98], xmm0
0000000141320f19: movaps   xmm1, xmmword ptr [rbp - 0x40]
0000000141320f1d: movups   xmmword ptr [rbp + 0xa8], xmm1
0000000141320f24: movaps   xmm2, xmmword ptr [rbp - 0x30]
0000000141320f28: movaps   xmm3, xmmword ptr [rbp - 0x20]
0000000141320f2c: movaps   xmm4, xmmword ptr [rbp - 0x10]
0000000141320f30: mov      eax, dword ptr [rbp]
0000000141320f33: mov      dword ptr [rbp + 0xf0], eax
0000000141320f39: mov      qword ptr [rbp + 0xf8], rdx
0000000141320f40: mov      rax, qword ptr [rsi + 0x50]
0000000141320f44: movaps   xmm0, xmmword ptr [rbp + 0x80]
0000000141320f4b: movaps   xmmword ptr [rax + rbx], xmm0
0000000141320f4f: movaps   xmm1, xmmword ptr [rbp + 0x90]
0000000141320f56: movaps   xmmword ptr [rax + rbx + 0x10], xmm1
0000000141320f5b: movaps   xmm0, xmmword ptr [rbp + 0xa0]
0000000141320f62: movaps   xmmword ptr [rax + rbx + 0x20], xmm0
0000000141320f67: movaps   xmm1, xmmword ptr [rbp + 0xb0]
0000000141320f6e: movaps   xmmword ptr [rax + rbx + 0x30], xmm1
0000000141320f73: movaps   xmmword ptr [rax + rbx + 0x40], xmm2
0000000141320f78: movaps   xmmword ptr [rax + rbx + 0x50], xmm3
0000000141320f7d: movaps   xmmword ptr [rax + rbx + 0x60], xmm4
0000000141320f82: movaps   xmm0, xmmword ptr [rbp + 0xf0]
0000000141320f89: movaps   xmmword ptr [rax + rbx + 0x70], xmm0
0000000141320f8e: movaps   xmm1, xmmword ptr [rbp + 0x100]
0000000141320f95: movaps   xmmword ptr [rax + rbx + 0x80], xmm1
0000000141320f9d: mov      rax, qword ptr [rsi + 0x50]
0000000141320fa1: mov      dword ptr [rax + rbx + 0x70], 0xffffffff
0000000141320fa9: mov      rax, qword ptr [rsi + 0x50]
0000000141320fad: mov      qword ptr [rax + rbx + 0x78], rdi
0000000141320fb2: inc      r14d
0000000141320fb5: add      rbx, 0x90
0000000141320fbc: movzx    ecx, word ptr [rsi + 0x2c]
0000000141320fc0: cmp      r14d, ecx
0000000141320fc3: jl       0x141320df5
0000000141320fc9: jmp      0x1413211ae
0000000141320fce: mov      qword ptr [rbp - 0x58], rdi
0000000141320fd2: mov      dword ptr [rbp - 0x50], 0
0000000141320fd9: mov      dword ptr [rbp - 0x4c], 0xbf800000
0000000141320fe0: mov      dword ptr [rbp - 0x48], 0
0000000141320fe7: mov      dword ptr [rbp - 0x44], 1
0000000141320fee: mov      qword ptr [rbp - 0x40], 1
0000000141320ff6: mov      qword ptr [rbp - 0x38], rdi
0000000141320ffa: mov      qword ptr [rbp - 0x20], 0
0000000141321002: xorps    xmm0, xmm0
0000000141321005: movaps   xmmword ptr [rbp - 0x10], xmm0
0000000141321009: lea      rcx, [rbp - 0x30]
000000014132100d: call     0x141387d10
0000000141321012: mov      r14d, edi
0000000141321015: movzx    ecx, word ptr [rsi + 0x2c]
0000000141321019: cmp      di, cx
000000014132101c: jae      0x1413211ae
0000000141321022: mov      rbx, rdi
0000000141321025: nop      word ptr [rax + rax]
0000000141321030: mov      r8d, 0x70
0000000141321036: lea      rdx, [rbp - 0x60]
000000014132103a: mov      rcx, r12
000000014132103d: call     0x14132d6f0
0000000141321042: cmp      eax, 0x70
0000000141321045: jb       0x14132161c
000000014132104b: mov      ecx, dword ptr [rbp - 0x60]
000000014132104e: call     0x1412e4220
0000000141321053: mov      dword ptr [rbp - 0x60], eax
0000000141321056: mov      ecx, dword ptr [rbp - 0x5c]
0000000141321059: call     0x1412e4220
000000014132105e: mov      dword ptr [rbp - 0x5c], eax
0000000141321061: mov      ecx, dword ptr [rbp - 0x58]
0000000141321064: call     0x1412e4220
0000000141321069: mov      dword ptr [rbp - 0x58], eax
000000014132106c: lea      rcx, [rbp - 0x50]
0000000141321070: call     0x1412e5110
0000000141321075: mov      ecx, dword ptr [rbp - 0x44]
0000000141321078: call     0x1412e4220
000000014132107d: mov      dword ptr [rbp - 0x44], eax
0000000141321080: mov      ecx, dword ptr [rbp - 0x40]
0000000141321083: call     0x1412e4220
0000000141321088: mov      dword ptr [rbp - 0x40], eax
000000014132108b: mov      ecx, dword ptr [rbp - 0x2c]
000000014132108e: call     0x1412e4220
0000000141321093: mov      dword ptr [rbp - 0x2c], eax
0000000141321096: mov      ecx, dword ptr [rbp - 0x28]
0000000141321099: call     0x1412e4220
000000014132109e: mov      dword ptr [rbp - 0x28], eax
00000001413210a1: mov      ecx, dword ptr [rbp - 0x24]
00000001413210a4: call     0x1412e4220
00000001413210a9: mov      dword ptr [rbp - 0x24], eax
00000001413210ac: mov      ecx, dword ptr [rbp - 0x20]
00000001413210af: call     0x1412e4220
00000001413210b4: mov      dword ptr [rbp - 0x20], eax
00000001413210b7: mov      ecx, dword ptr [rbp - 0x1c]
00000001413210ba: call     0x1412e4220
00000001413210bf: mov      dword ptr [rbp - 0x1c], eax
00000001413210c2: lea      rcx, [rbp - 0x10]
00000001413210c6: call     0x1412e48d0
00000001413210cb: mov      ecx, dword ptr [rbp]
00000001413210ce: call     0x1412e4220
00000001413210d3: mov      dword ptr [rbp], eax
00000001413210d6: mov      ecx, dword ptr [rbp + 4]
00000001413210d9: call     0x1412e4220
00000001413210de: mov      edx, eax
00000001413210e0: mov      dword ptr [rbp + 4], edx
00000001413210e3: mov      ecx, dword ptr [rbp - 0x60]
00000001413210e6: mov      dword ptr [rbp + 0x80], ecx
00000001413210ec: mov      ecx, dword ptr [rbp - 0x5c]
00000001413210ef: mov      dword ptr [rbp + 0x84], ecx
00000001413210f5: mov      ecx, dword ptr [rbp - 0x58]
00000001413210f8: mov      qword ptr [rbp + 0x88], rcx
00000001413210ff: mov      ecx, dword ptr [rbp - 0x54]
0000000141321102: mov      dword ptr [rbp + 0x90], ecx
0000000141321108: movaps   xmm0, xmmword ptr [rbp - 0x50]
000000014132110c: movups   xmmword ptr [rbp + 0x98], xmm0
0000000141321113: movaps   xmm1, xmmword ptr [rbp - 0x40]
0000000141321117: movups   xmmword ptr [rbp + 0xa8], xmm1
000000014132111e: movaps   xmm2, xmmword ptr [rbp - 0x30]
0000000141321122: movaps   xmm3, xmmword ptr [rbp - 0x20]
0000000141321126: movaps   xmm4, xmmword ptr [rbp - 0x10]
000000014132112a: mov      eax, dword ptr [rbp]
000000014132112d: mov      dword ptr [rbp + 0xf0], eax
0000000141321133: mov      qword ptr [rbp + 0xf8], rdx
000000014132113a: mov      rax, qword ptr [rsi + 0x50]
000000014132113e: movaps   xmm0, xmmword ptr [rbp + 0x80]
0000000141321145: movaps   xmmword ptr [rax + rbx], xmm0
0000000141321149: movaps   xmm1, xmmword ptr [rbp + 0x90]
0000000141321150: movaps   xmmword ptr [rax + rbx + 0x10], xmm1
0000000141321155: movaps   xmm0, xmmword ptr [rbp + 0xa0]
000000014132115c: movaps   xmmword ptr [rax + rbx + 0x20], xmm0
0000000141321161: movaps   xmm1, xmmword ptr [rbp + 0xb0]
0000000141321168: movaps   xmmword ptr [rax + rbx + 0x30], xmm1
000000014132116d: movaps   xmmword ptr [rax + rbx + 0x40], xmm2
0000000141321172: movaps   xmmword ptr [rax + rbx + 0x50], xmm3
0000000141321177: movaps   xmmword ptr [rax + rbx + 0x60], xmm4
000000014132117c: movaps   xmm0, xmmword ptr [rbp + 0xf0]
0000000141321183: movaps   xmmword ptr [rax + rbx + 0x70], xmm0
0000000141321188: movaps   xmm1, xmmword ptr [rbp + 0x100]
000000014132118f: movaps   xmmword ptr [rax + rbx + 0x80], xmm1
0000000141321197: inc      r14d
000000014132119a: add      rbx, 0x90
00000001413211a1: movzx    ecx, word ptr [rsi + 0x2c]
00000001413211a5: cmp      r14d, ecx
00000001413211a8: jl       0x141321030
00000001413211ae: mov      r14d, edi
00000001413211b1: cmp      di, cx
00000001413211b4: jae      0x141321209
00000001413211b6: mov      rbx, rdi
00000001413211b9: nop      dword ptr [rax]
00000001413211c0: mov      rax, qword ptr [rsi + 0x50]
00000001413211c4: mov      edx, dword ptr [rax + rbx]
00000001413211c7: mov      rcx, r13
00000001413211ca: call     0x1412864d0
00000001413211cf: mov      rcx, qword ptr [rsi + 0x50]
00000001413211d3: mov      qword ptr [rcx + rbx + 8], rax
00000001413211d8: mov      rax, qword ptr [rsi + 0x50]
00000001413211dc: mov      edx, dword ptr [rax + rbx + 0x70]
00000001413211e0: cmp      edx, -1
00000001413211e3: je       0x1413211f6
00000001413211e5: mov      rcx, r13
00000001413211e8: call     0x1412864d0
00000001413211ed: mov      rcx, qword ptr [rsi + 0x50]
00000001413211f1: mov      qword ptr [rcx + rbx + 0x78], rax
00000001413211f6: inc      r14d
00000001413211f9: add      rbx, 0x90
0000000141321200: movzx    eax, word ptr [rsi + 0x2c]
0000000141321204: cmp      r14d, eax
0000000141321207: jl       0x1413211c0
0000000141321209: cmp      word ptr [rsi + 0x34], 0
000000014132120e: je       0x141321337
0000000141321214: movzx    ecx, word ptr [rsi + 0x36]
0000000141321218: mov      eax, 4
000000014132121d: mul      rcx
0000000141321220: mov      r13, 0xffffffffffffffff
0000000141321227: cmovo    rax, r13
000000014132122b: mov      r8d, 0x13f
0000000141321231: lea      rdx, [rip + 0x87aa38]
0000000141321238: mov      rcx, rax
000000014132123b: call     0x141272e00
0000000141321240: mov      qword ptr [rsi + 0x60], rax
0000000141321244: movzx    r8d, word ptr [rsi + 0x36]
0000000141321249: mov      rdx, rax
000000014132124c: mov      rcx, r12
000000014132124f: call     0x14132d6f0
0000000141321254: movzx    ecx, word ptr [rsi + 0x36]
0000000141321258: cmp      eax, ecx
000000014132125a: jb       0x14132161c
0000000141321260: mov      edx, ecx
0000000141321262: mov      rcx, qword ptr [rsi + 0x60]
0000000141321266: call     0x1412e4600
000000014132126b: mov      r14d, edi
000000014132126e: movzx    ebx, word ptr [rsi + 0x34]
0000000141321272: mov      eax, 0x10
0000000141321277: mul      rbx
000000014132127a: cmovo    rax, r13
000000014132127e: mov      r8d, 0x148
0000000141321284: lea      rdx, [rip + 0x87a9e5]
000000014132128b: mov      rcx, rax
000000014132128e: call     0x141272e00
0000000141321293: mov      rdx, rax
0000000141321296: mov      qword ptr [rsp + 0x30], rax
000000014132129b: test     rax, rax
000000014132129e: je       0x1413212c2
00000001413212a0: mov      rcx, rax
00000001413212a3: test     rbx, rbx
00000001413212a6: je       0x1413212c5
00000001413212a8: nop      dword ptr [rax + rax]
00000001413212b0: mov      dword ptr [rcx], edi
00000001413212b2: mov      qword ptr [rcx + 8], rdi
00000001413212b6: lea      rcx, [rcx + 0x10]
00000001413212ba: sub      rbx, 1
00000001413212be: jne      0x1413212b0
00000001413212c0: jmp      0x1413212c5
00000001413212c2: mov      rdx, rdi
00000001413212c5: mov      qword ptr [rsi + 0x58], rdx
00000001413212c9: mov      r9d, edi
00000001413212cc: cmp      di, word ptr [rsi + 0x34]
00000001413212d0: jae      0x141321337
00000001413212d2: mov      r8, rdi
00000001413212d5: nop      word ptr [rax + rax]
00000001413212e0: mov      ecx, r14d
00000001413212e3: mov      rax, qword ptr [rsi + 0x60]
00000001413212e7: mov      ecx, dword ptr [rax + rcx*4]
00000001413212ea: mov      dword ptr [rdx + r8], ecx
00000001413212ee: lea      ecx, [r14 + 1]
00000001413212f2: mov      rax, qword ptr [rsi + 0x60]
00000001413212f6: lea      rdx, [rax + rcx*4]
00000001413212fa: mov      rax, qword ptr [rsi + 0x58]
00000001413212fe: mov      qword ptr [r8 + rax + 8], rdx
0000000141321303: mov      eax, 8
0000000141321308: mov      rdx, qword ptr [rsi + 0x58]
000000014132130c: mov      ecx, dword ptr [rdx + r8]
0000000141321310: test     ecx, ecx
0000000141321312: je       0x14132131e
0000000141321314: lea      eax, [rcx*4 + 0xb]
000000014132131b: and      eax, 0xfffffff8
000000014132131e: cdqe     
0000000141321320: shr      rax, 2
0000000141321324: add      r14d, eax
0000000141321327: inc      r9d
000000014132132a: add      r8, 0x10
000000014132132e: movzx    eax, word ptr [rsi + 0x34]
0000000141321332: cmp      r9d, eax
0000000141321335: jl       0x1413212e0
0000000141321337: mov      r11d, edi
000000014132133a: mov      r10d, edi
000000014132133d: cmp      di, word ptr [rsi + 0x14]
0000000141321341: jae      0x14132161c
0000000141321347: mov      r8, rdi
000000014132134a: nop      word ptr [rax + rax]
0000000141321350: cmp      r15w, 0x7b
0000000141321355: jae      0x141321361
0000000141321357: mov      rax, qword ptr [rsi + 0x38]
000000014132135b: mov      byte ptr [rax + r8 + 0x2e], 0
0000000141321361: mov      rax, qword ptr [rsi + 0x38]
0000000141321365: cmp      byte ptr [rax + r8 + 0x2e], 0
000000014132136b: jbe      0x14132139b
000000014132136d: mov      ecx, edi
000000014132136f: movzx    edx, word ptr [rsi + 0x1c]
0000000141321373: test     edx, edx
0000000141321375: je       0x14132139b
0000000141321377: mov      r9d, dword ptr [rax + r8 + 4]
000000014132137c: mov      rax, qword ptr [rsi + 0x40]
0000000141321380: add      rax, 4
0000000141321384: cmp      dword ptr [rax], r9d
0000000141321387: je       0x141321395
0000000141321389: inc      ecx
000000014132138b: add      rax, 0x30
000000014132138f: cmp      ecx, edx
0000000141321391: jl       0x141321384
0000000141321393: jmp      0x14132139b
0000000141321395: mov      r11d, 1
000000014132139b: inc      r10d
000000014132139e: add      r8, 0xe0
00000001413213a5: movzx    eax, word ptr [rsi + 0x14]
00000001413213a9: cmp      r10d, eax
00000001413213ac: jl       0x141321350
00000001413213ae: test     r11d, r11d
00000001413213b1: je       0x14132161c
00000001413213b7: mov      r8d, 8
00000001413213bd: lea      rdx, [rsp + 0x28]
00000001413213c2: mov      rcx, r12
00000001413213c5: call     0x14132d6f0
00000001413213ca: cmp      eax, 8
00000001413213cd: jb       0x14132161c
00000001413213d3: mov      rcx, qword ptr [rsp + 0x28]
00000001413213d8: call     0x1412e5a00
00000001413213dd: mov      qword ptr [rsp + 0x28], rax
00000001413213e2: mov      r8d, 0x16f
00000001413213e8: lea      rdx, [rip + 0x87a881]
00000001413213ef: mov      rcx, rax
00000001413213f2: call     0x141272e00
00000001413213f7: mov      rbx, rax
00000001413213fa: mov      r8d, dword ptr [rsp + 0x28]
00000001413213ff: mov      rdx, rax
0000000141321402: mov      rcx, r12
0000000141321405: call     0x14132d6f0
000000014132140a: mov      ecx, eax
000000014132140c: cmp      rcx, qword ptr [rsp + 0x28]
0000000141321411: jae      0x141321420
0000000141321413: mov      rcx, rbx
0000000141321416: call     0x141272e20
000000014132141b: jmp      0x14132161c
0000000141321420: lea      rcx, [rsi + 0x68]
0000000141321424: mov      r8d, 1
000000014132142a: mov      rdx, rbx
000000014132142d: call     0x1412632a0
0000000141321432: mov      rcx, rbx
0000000141321435: call     0x141272e20
000000014132143a: mov      rcx, qword ptr [rsi + 0x90]
0000000141321441: sub      rcx, qword ptr [rsi + 0x88]
0000000141321448: movabs   r12, 0x4924924924924925
0000000141321452: mov      rax, r12
0000000141321455: imul     rcx
0000000141321458: mov      r10, rdx
000000014132145b: sar      r10, 4
000000014132145f: mov      rax, r10
0000000141321462: shr      rax, 0x3f
0000000141321466: add      r10, rax
0000000141321469: lea      r13, [rsi + 0xa0]
0000000141321470: mov      r15, qword ptr [r13 + 0x20]
0000000141321474: mov      r9, qword ptr [r13 + 0x18]
0000000141321478: mov      rcx, r15
000000014132147b: sub      rcx, r9
000000014132147e: movabs   r11, 0x2aaaaaaaaaaaaaab
0000000141321488: mov      rax, r11
000000014132148b: imul     rcx
000000014132148e: mov      rcx, rdx
0000000141321491: sar      rcx, 3
0000000141321495: mov      rax, rcx
0000000141321498: shr      rax, 0x3f
000000014132149c: add      rcx, rax
000000014132149f: cmp      r10, rcx
00000001413214a2: jae      0x1413214e4
00000001413214a4: lea      r14, [r10 + r10*2]
00000001413214a8: shl      r14, 4
00000001413214ac: add      r14, r9
00000001413214af: mov      rbx, r14
00000001413214b2: cmp      r14, r15
00000001413214b5: je       0x1413214de
00000001413214b7: lea      r12, [rip + 0x43feca]
00000001413214be: nop      
00000001413214c0: mov      rcx, rbx
00000001413214c3: call     0x141321a30
00000001413214c8: mov      qword ptr [rbx], r12
00000001413214cb: add      rbx, 0x30
00000001413214cf: cmp      rbx, r15
00000001413214d2: jne      0x1413214c0
00000001413214d4: movabs   r12, 0x4924924924924925
00000001413214de: mov      qword ptr [r13 + 0x20], r14
00000001413214e2: jmp      0x141321533
00000001413214e4: jbe      0x141321533
00000001413214e6: mov      r8, qword ptr [r13 + 0x28]
00000001413214ea: sub      r8, r9
00000001413214ed: mov      rax, r11
00000001413214f0: imul     r8
00000001413214f3: sar      rdx, 3
00000001413214f7: mov      rax, rdx
00000001413214fa: shr      rax, 0x3f
00000001413214fe: add      rdx, rax
0000000141321501: cmp      r10, rdx
0000000141321504: jbe      0x141321518
0000000141321506: lea      r8, [rsp + 0x20]
000000014132150b: mov      rdx, r10
000000014132150e: mov      rcx, r13
0000000141321511: call     0x14131dce0
0000000141321516: jmp      0x141321533
0000000141321518: sub      r10, rcx
000000014132151b: movzx    r9d, byte ptr [rsp + 0x20]
0000000141321521: mov      r8, r10
0000000141321524: mov      rdx, r15
0000000141321527: mov      rcx, r13
000000014132152a: call     0x141321ca0
000000014132152f: mov      qword ptr [r13 + 0x20], rax
0000000141321533: mov      r14, qword ptr [rsi + 0x90]
000000014132153a: mov      rbx, qword ptr [rsi + 0x88]
0000000141321541: mov      rcx, r14
0000000141321544: sub      rcx, rbx
0000000141321547: mov      rax, r12
000000014132154a: imul     rcx
000000014132154d: sar      rdx, 4
0000000141321551: mov      rax, rdx
0000000141321554: shr      rax, 0x3f
0000000141321558: add      rdx, rax
000000014132155b: je       0x1413215b1
000000014132155d: mov      r8, rdi
0000000141321560: imul     rdx, r8, 0x38
0000000141321564: add      rdx, qword ptr [rsi + 0x88]
000000014132156b: lea      rcx, [r8 + r8*2]
000000014132156f: shl      rcx, 4
0000000141321573: add      rcx, qword ptr [rsi + 0xb8]
000000014132157a: call     0x14131f3f0
000000014132157f: inc      edi
0000000141321581: mov      r14, qword ptr [rsi + 0x90]
0000000141321588: mov      rbx, qword ptr [rsi + 0x88]
000000014132158f: movsxd   r8, edi
0000000141321592: mov      rcx, r14
0000000141321595: sub      rcx, rbx
0000000141321598: mov      rax, r12
000000014132159b: imul     rcx
000000014132159e: sar      rdx, 4
00000001413215a2: mov      rax, rdx
00000001413215a5: shr      rax, 0x3f
00000001413215a9: add      rdx, rax
00000001413215ac: cmp      r8, rdx
00000001413215af: jb       0x141321560
00000001413215b1: cmp      dword ptr [rip + 0x842ac78], 0
00000001413215b8: jne      0x14132161c
00000001413215ba: cmp      rbx, r14
00000001413215bd: je       0x1413215db
00000001413215bf: nop      
00000001413215c0: mov      rax, qword ptr [rbx]
00000001413215c3: xor      edx, edx
00000001413215c5: mov      rcx, rbx
00000001413215c8: call     qword ptr [rax + 8]
00000001413215cb: add      rbx, 0x38
00000001413215cf: cmp      rbx, r14
00000001413215d2: jne      0x1413215c0
00000001413215d4: mov      rbx, qword ptr [rsi + 0x88]
00000001413215db: mov      qword ptr [rsi + 0x90], rbx
00000001413215e2: lea      rcx, [rsi + 0x70]
00000001413215e6: mov      rdx, qword ptr [rcx + 0x20]
00000001413215ea: cmp      rdx, qword ptr [rcx + 0x28]
00000001413215ee: je       0x14132161c
00000001413215f0: mov      rax, qword ptr [rcx + 0x18]
00000001413215f4: cmp      rax, rdx
00000001413215f7: jne      0x141321600
00000001413215f9: call     0x141321ad0
00000001413215fe: jmp      0x14132161c
0000000141321600: sub      rdx, rax
0000000141321603: mov      rax, r12
0000000141321606: imul     rdx
0000000141321609: sar      rdx, 4
000000014132160d: mov      rax, rdx
0000000141321610: shr      rax, 0x3f
0000000141321614: add      rdx, rax
0000000141321617: call     0x1413217f0
000000014132161c: mov      rcx, qword ptr [rbp + 0x150]
0000000141321623: xor      rcx, rsp
0000000141321626: call     0x141441dc0
000000014132162b: mov      rbx, qword ptr [rsp + 0x2b8]
0000000141321633: add      rsp, 0x260
000000014132163a: pop      r15
000000014132163c: pop      r14
000000014132163e: pop      r13
0000000141321640: pop      r12
0000000141321642: pop      rdi
0000000141321643: pop      rsi
0000000141321644: pop      rbp
0000000141321645: ret      
0000000141321646: int3     
0000000141321647: int3     
0000000141321648: int3     
0000000141321649: int3     
000000014132164a: int3     
000000014132164b: int3     
000000014132164c: int3     
000000014132164d: int3     
000000014132164e: int3     
000000014132164f: int3     
0000000141321650: mov      qword ptr [rsp + 0x18], rbx
0000000141321655: push     r14
0000000141321657: sub      rsp, 0x20
000000014132165b: lea      rcx, [rip + 0x83e7cce]
0000000141321662: mov      r14, rdx
0000000141321665: xor      ebx, ebx
0000000141321667: call     0x141293e90
000000014132166c: test     eax, eax
000000014132166e: jle      0x141321701
0000000141321674: mov      qword ptr [rsp + 0x30], rsi
0000000141321679: mov      qword ptr [rsp + 0x38], rdi
000000014132167e: nop      
0000000141321680: mov      edx, ebx
0000000141321682: lea      rcx, [rip + 0x83e7ca7]
0000000141321689: call     0x141293ce0
000000014132168e: test     rax, rax
0000000141321691: je       0x1413216d2
0000000141321693: mov      rdx, rax
0000000141321696: lea      rcx, [rip + 0x83e7c93]
000000014132169d: call     0x141294c00
00000001413216a2: mov      rsi, rax
00000001413216a5: test     rax, rax
00000001413216a8: je       0x1413216d2
00000001413216aa: mov      rax, qword ptr [r14]
00000001413216ad: mov      rcx, r14
00000001413216b0: call     qword ptr [rax + 0x18]
00000001413216b3: mov      rdx, qword ptr [r14]
00000001413216b6: mov      rcx, r14
00000001413216b9: mov      rdi, rax
00000001413216bc: call     qword ptr [rdx + 0x30]
00000001413216bf: mov      r8, rdi
00000001413216c2: mov      rcx, rsi
00000001413216c5: mov      rdx, rax
00000001413216c8: call     0x141287ca0
00000001413216cd: test     rax, rax
00000001413216d0: jne      0x1413216fc
00000001413216d2: lea      rcx, [rip + 0x83e7c57]
00000001413216d9: inc      ebx
00000001413216db: call     0x141293e90
00000001413216e0: cmp      ebx, eax
00000001413216e2: jl       0x141321680
00000001413216e4: xor      eax, eax
00000001413216e6: mov      rsi, qword ptr [rsp + 0x30]
00000001413216eb: mov      rdi, qword ptr [rsp + 0x38]
00000001413216f0: mov      rbx, qword ptr [rsp + 0x40]
00000001413216f5: add      rsp, 0x20
00000001413216f9: pop      r14
00000001413216fb: ret      
00000001413216fc: mov      rax, rsi
00000001413216ff: jmp      0x1413216e6
0000000141321701: mov      rbx, qword ptr [rsp + 0x40]
0000000141321706: xor      eax, eax
0000000141321708: add      rsp, 0x20
000000014132170c: pop      r14
000000014132170e: ret      
000000014132170f: int3     
0000000141321710: cmp      rdx, r8
0000000141321713: je       0x141321764
0000000141321715: mov      qword ptr [rsp + 8], rbx
000000014132171a: mov      qword ptr [rsp + 0x10], rsi
000000014132171f: push     rdi
0000000141321720: sub      rsp, 0x20
0000000141321724: mov      rdi, r8
0000000141321727: mov      rbx, rdx
000000014132172a: lea      rsi, [rip + 0x87a497]
0000000141321731: lea      rcx, [rbx + 0xa8]
0000000141321738: mov      qword ptr [rcx], rsi
000000014132173b: call     0x141414110
0000000141321740: nop      
0000000141321741: mov      rcx, rbx
0000000141321744: call     0x14140ac80
0000000141321749: add      rbx, 0x100
0000000141321750: cmp      rbx, rdi
0000000141321753: jne      0x141321731
0000000141321755: mov      rbx, qword ptr [rsp + 0x30]
000000014132175a: mov      rsi, qword ptr [rsp + 0x38]
000000014132175f: add      rsp, 0x20
0000000141321763: pop      rdi
0000000141321764: ret      
0000000141321765: int3     
0000000141321766: int3     
0000000141321767: int3     
0000000141321768: int3     
0000000141321769: int3     
000000014132176a: int3     
000000014132176b: int3     
000000014132176c: int3     
000000014132176d: int3     
000000014132176e: int3     
000000014132176f: int3     
0000000141321770: cmp      rdx, r8
0000000141321773: je       0x1413217b4
0000000141321775: mov      qword ptr [rsp + 0x10], rbx
000000014132177a: push     rdi
000000014132177b: sub      rsp, 0x20
000000014132177f: mov      qword ptr [rsp + 0x30], rsi
0000000141321784: mov      rdi, r8
0000000141321787: lea      rsi, [rip + 0x43fbfa]
