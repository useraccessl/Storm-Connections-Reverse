0000000140a6e0d0: mov      rax, rsp
0000000140a6e0d3: mov      qword ptr [rax + 0x18], rbx
0000000140a6e0d7: push     rbp
0000000140a6e0d8: push     rsi
0000000140a6e0d9: push     rdi
0000000140a6e0da: push     r12
0000000140a6e0dc: push     r13
0000000140a6e0de: push     r14
0000000140a6e0e0: push     r15
0000000140a6e0e2: sub      rsp, 0x1a0
0000000140a6e0e9: movaps   xmmword ptr [rax - 0x48], xmm6
0000000140a6e0ed: movaps   xmmword ptr [rax - 0x58], xmm7
0000000140a6e0f1: mov      rax, qword ptr [rip + 0x16782d0]
0000000140a6e0f8: xor      rax, rsp
0000000140a6e0fb: mov      qword ptr [rsp + 0x170], rax
0000000140a6e103: mov      r14, rdx
0000000140a6e106: mov      r12, rcx
0000000140a6e109: mov      r15, qword ptr [rdx + 8]
0000000140a6e10d: lea      rdi, [r15 + 0xa0]
0000000140a6e114: xor      ebx, ebx
0000000140a6e116: mov      r13d, ebx
0000000140a6e119: mov      rcx, rdx
0000000140a6e11c: call     0x140a61e70
0000000140a6e121: test     rax, rax
0000000140a6e124: je       0x140a6e12d
0000000140a6e126: mov      r13d, dword ptr [rax + 0x100]
0000000140a6e12d: mov      rax, qword ptr [r14 + 8]
0000000140a6e131: movss    xmm2, dword ptr [rax + 0x164]
0000000140a6e139: movaps   xmm1, xmm2
0000000140a6e13c: mulss    xmm1, dword ptr [rdi + 4]
0000000140a6e141: addss    xmm1, dword ptr [r15 + 0x74]
0000000140a6e147: movaps   xmm0, xmm2
0000000140a6e14a: mulss    xmm0, dword ptr [rdi + 8]
0000000140a6e14f: addss    xmm0, dword ptr [r15 + 0x78]
0000000140a6e155: mulss    xmm2, dword ptr [rdi]
0000000140a6e159: addss    xmm2, dword ptr [r15 + 0x70]
0000000140a6e15f: movss    dword ptr [r15 + 0x70], xmm2
0000000140a6e165: movss    dword ptr [r15 + 0x74], xmm1
0000000140a6e16b: movss    dword ptr [r15 + 0x78], xmm0
0000000140a6e171: movss    xmm7, dword ptr [rdi + 8]
0000000140a6e176: xorps    xmm6, xmm6
0000000140a6e179: mov      rcx, rdi
0000000140a6e17c: comiss   xmm7, xmm6
0000000140a6e17f: jbe      0x140a6e1d5
0000000140a6e181: call     0x1411ac880
0000000140a6e186: comiss   xmm0, xmm6
0000000140a6e189: jbe      0x140a6e21e
0000000140a6e18f: lea      rdx, [rsp + 0x30]
0000000140a6e194: mov      rcx, rdi
0000000140a6e197: call     0x1411acc30
0000000140a6e19c: mov      ecx, dword ptr [rax + 8]
0000000140a6e19f: movsd    xmm0, qword ptr [rax]
0000000140a6e1a3: movsd    qword ptr [rdi], xmm0
0000000140a6e1a7: mov      dword ptr [rdi + 8], ecx
0000000140a6e1aa: movss    xmm1, dword ptr [r12 + 0x20]
0000000140a6e1b1: movaps   xmm2, xmm1
0000000140a6e1b4: mulss    xmm2, dword ptr [rdi + 4]
0000000140a6e1b9: movaps   xmm0, xmm1
0000000140a6e1bc: mulss    xmm0, dword ptr [rdi + 8]
0000000140a6e1c1: mulss    xmm1, dword ptr [rdi]
0000000140a6e1c5: movss    dword ptr [rdi], xmm1
0000000140a6e1c9: movss    dword ptr [rdi + 4], xmm2
0000000140a6e1ce: movss    dword ptr [rdi + 8], xmm0
0000000140a6e1d3: jmp      0x140a6e21e
0000000140a6e1d5: mov      dword ptr [rdi + 8], ebx
0000000140a6e1d8: call     0x1411ac880
0000000140a6e1dd: comiss   xmm0, xmm6
0000000140a6e1e0: jbe      0x140a6e219
0000000140a6e1e2: lea      rdx, [rsp + 0x30]
0000000140a6e1e7: mov      rcx, rdi
0000000140a6e1ea: call     0x1411acc30
0000000140a6e1ef: mov      ecx, dword ptr [rax + 8]
0000000140a6e1f2: movsd    xmm0, qword ptr [rax]
0000000140a6e1f6: movsd    qword ptr [rdi], xmm0
0000000140a6e1fa: mov      dword ptr [rdi + 8], ecx
0000000140a6e1fd: movss    xmm0, dword ptr [r12 + 0x20]
0000000140a6e204: movaps   xmm1, xmm0
0000000140a6e207: mulss    xmm1, dword ptr [rdi + 4]
0000000140a6e20c: mulss    xmm0, dword ptr [rdi]
0000000140a6e210: movss    dword ptr [rdi], xmm0
0000000140a6e214: movss    dword ptr [rdi + 4], xmm1
0000000140a6e219: movss    dword ptr [rdi + 8], xmm7
0000000140a6e21e: lea      rax, [rip - 0x850de5]
0000000140a6e225: mov      qword ptr [rsp + 0x20], rax
0000000140a6e22a: lea      r9, [rip - 0x850fc1]
0000000140a6e231: mov      edx, 0x20
0000000140a6e236: lea      r8d, [rdx - 0x18]
0000000140a6e23a: lea      rcx, [rsp + 0x68]
0000000140a6e23f: call     0x141441de0
0000000140a6e244: nop      
0000000140a6e245: mov      dword ptr [rsp + 0x60], ebx
0000000140a6e249: lea      rbx, [rsp + 0x78]
0000000140a6e24e: lea      rsi, [rsp + 0x6c]
0000000140a6e253: mov      ebp, 8
0000000140a6e258: nop      dword ptr [rax + rax]
0000000140a6e260: mov      dword ptr [rbx - 0x10], 0xbf800000
0000000140a6e267: movaps   xmm3, xmm6
0000000140a6e26a: movaps   xmm2, xmm6
0000000140a6e26d: movaps   xmm1, xmm6
0000000140a6e270: mov      rcx, rsi
0000000140a6e273: call     0x1411adb80
0000000140a6e278: xor      eax, eax
0000000140a6e27a: mov      qword ptr [rbx], rax
0000000140a6e27d: mov      dword ptr [rbx + 8], eax
0000000140a6e280: mov      eax, dword ptr [rip + 0x1109ca6]
0000000140a6e286: mov      dword ptr [rbx + 0xc], eax
0000000140a6e289: add      rsi, 0x20
0000000140a6e28d: lea      rbx, [rbx + 0x20]
0000000140a6e291: sub      rbp, 1
0000000140a6e295: jne      0x140a6e260
0000000140a6e297: lea      rdx, [rsp + 0x60]
0000000140a6e29c: mov      rcx, r14
0000000140a6e29f: call     0x140a620a0
0000000140a6e2a4: test     eax, eax
0000000140a6e2a6: je       0x140a6e2f6
0000000140a6e2a8: xor      edx, edx
0000000140a6e2aa: mov      r9d, dword ptr [rsp + 0x60]
0000000140a6e2af: test     r9d, r9d
0000000140a6e2b2: jle      0x140a6e338
0000000140a6e2b8: cmp      dl, 8
0000000140a6e2bb: jae      0x140a6e2e3
0000000140a6e2bd: movzx    eax, dl
0000000140a6e2c0: shl      rax, 5
0000000140a6e2c4: lea      r8, [rsp + 0x68]
0000000140a6e2c9: add      r8, rax
0000000140a6e2cc: je       0x140a6e2e3
0000000140a6e2ce: mov      rax, qword ptr [r8 + 0x10]
0000000140a6e2d2: mov      ecx, dword ptr [rax + 0x38]
0000000140a6e2d5: and      ecx, 0x20000002
0000000140a6e2db: cmp      ecx, 0x20000002
0000000140a6e2e1: je       0x140a6e2ec
0000000140a6e2e3: inc      edx
0000000140a6e2e5: cmp      edx, r9d
0000000140a6e2e8: jge      0x140a6e338
0000000140a6e2ea: jmp      0x140a6e2b8
0000000140a6e2ec: mov      eax, dword ptr [r8 + 0xc]
0000000140a6e2f0: mov      dword ptr [r15 + 0x78], eax
0000000140a6e2f4: jmp      0x140a6e338
0000000140a6e2f6: mov      rcx, qword ptr [rip + 0x18c79db]
0000000140a6e2fd: call     0x14109e1d0
0000000140a6e302: cmp      eax, 0x89
0000000140a6e307: je       0x140a6e338
0000000140a6e309: mov      rax, qword ptr [rip + 0x8c9b208]
0000000140a6e310: movzx    ecx, byte ptr [rax + 0x952]
0000000140a6e317: movd     xmm0, ecx
0000000140a6e31b: cvtdq2ps xmm0, xmm0
0000000140a6e31e: movss    xmm2, dword ptr [rip + 0xf074ce]
0000000140a6e326: divss    xmm2, xmm0
0000000140a6e32a: movss    xmm1, dword ptr [rdi + 8]
0000000140a6e32f: subss    xmm1, xmm2
0000000140a6e333: movss    dword ptr [rdi + 8], xmm1
0000000140a6e338: test     r13d, r13d
0000000140a6e33b: je       0x140a6e398
0000000140a6e33d: lea      rdx, [rsp + 0x30]
0000000140a6e342: lea      rcx, [r15 + 0xac]
0000000140a6e349: call     0x141283ee0
0000000140a6e34e: mov      rsi, rax
0000000140a6e351: call     0x140136c20
0000000140a6e356: mov      rdi, rax
0000000140a6e359: lea      rdx, [rsp + 0x3c]
0000000140a6e35e: lea      rcx, [r15 + 0xac]
0000000140a6e365: call     0x141284120
0000000140a6e36a: mov      rbx, rax
0000000140a6e36d: lea      rdx, [rsp + 0x48]
0000000140a6e372: lea      rcx, [r15 + 0xac]
0000000140a6e379: call     0x1412840b0
0000000140a6e37e: mov      rdx, rax
0000000140a6e381: mov      qword ptr [rsp + 0x20], rsi
0000000140a6e386: mov      r9, rdi
0000000140a6e389: mov      r8, rbx
0000000140a6e38c: lea      rcx, [r15 + 0xac]
0000000140a6e393: call     0x141282120
0000000140a6e398: mov      rax, qword ptr [r14 + 8]
0000000140a6e39c: cmp      dword ptr [rax + 0x3b0], 0
0000000140a6e3a3: je       0x140a6e3cd
0000000140a6e3a5: movss    xmm2, dword ptr [r12 + 0x14]
0000000140a6e3ac: movss    xmm1, dword ptr [r12 + 0x18]
0000000140a6e3b3: mov      rcx, r14
0000000140a6e3b6: call     0x140a61fa0
0000000140a6e3bb: test     eax, eax
0000000140a6e3bd: jne      0x140a6e3cd
0000000140a6e3bf: mov      rax, qword ptr [r14 + 8]
0000000140a6e3c3: mov      dword ptr [rax + 0x3b0], 0
0000000140a6e3cd: mov      rcx, r14
0000000140a6e3d0: call     0x140a61c20
0000000140a6e3d5: nop      
0000000140a6e3d6: lea      r9, [rip - 0x850f9d]
0000000140a6e3dd: mov      edx, 0x20
0000000140a6e3e2: lea      r8d, [rdx - 0x18]
0000000140a6e3e6: lea      rcx, [rsp + 0x68]
0000000140a6e3eb: call     0x14144142c
0000000140a6e3f0: nop      
0000000140a6e3f1: mov      rcx, qword ptr [rsp + 0x170]
0000000140a6e3f9: xor      rcx, rsp
0000000140a6e3fc: call     0x141441dc0
0000000140a6e401: lea      r11, [rsp + 0x1a0]
0000000140a6e409: mov      rbx, qword ptr [r11 + 0x50]
0000000140a6e40d: movaps   xmm6, xmmword ptr [r11 - 0x10]
0000000140a6e412: movaps   xmm7, xmmword ptr [r11 - 0x20]
0000000140a6e417: mov      rsp, r11
0000000140a6e41a: pop      r15
0000000140a6e41c: pop      r14
0000000140a6e41e: pop      r13
0000000140a6e420: pop      r12
0000000140a6e422: pop      rdi
0000000140a6e423: pop      rsi
0000000140a6e424: pop      rbp
0000000140a6e425: ret      
