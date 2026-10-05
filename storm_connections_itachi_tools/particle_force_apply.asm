0000000141385ec0: test     rdx, rdx
0000000141385ec3: je       0x14138656a
0000000141385ec9: mov      r11, rsp
0000000141385ecc: push     rbp
0000000141385ecd: push     rdi
0000000141385ece: lea      rbp, [r11 - 0x58]
0000000141385ed2: sub      rsp, 0x148
0000000141385ed9: mov      rax, qword ptr [rip + 0xd604e8]
0000000141385ee0: xor      rax, rsp
0000000141385ee3: mov      qword ptr [rbp - 0x68], rax
0000000141385ee7: mov      qword ptr [r11 - 0x28], r13
0000000141385eeb: mov      rax, rdx
0000000141385eee: mov      r13d, dword ptr [rdx + 0xc]
0000000141385ef2: mov      rdi, rcx
0000000141385ef5: mov      qword ptr [rsp + 0x58], rdx
0000000141385efa: test     r13d, r13d
0000000141385efd: je       0x14138654d
0000000141385f03: mov      qword ptr [r11 - 0x30], r14
0000000141385f07: xor      r14d, r14d
0000000141385f0a: test     r13d, r13d
0000000141385f0d: jle      0x141386545
0000000141385f13: mov      qword ptr [r11 - 0x18], rsi
0000000141385f17: movaps   xmmword ptr [r11 - 0x88], xmm10
0000000141385f1f: movss    xmm10, dword ptr [rip + 0x3db6b8]
0000000141385f28: movaps   xmmword ptr [r11 - 0x98], xmm11
0000000141385f30: xorps    xmm11, xmm11
0000000141385f34: movaps   xmmword ptr [r11 - 0xa8], xmm12
0000000141385f3c: movss    xmm12, dword ptr [rip + 0x4da603]
0000000141385f45: movaps   xmmword ptr [r11 - 0xb8], xmm13
0000000141385f4d: movss    xmm13, dword ptr [rip + 0x41aeea]
0000000141385f56: mov      qword ptr [r11 + 0x18], rbx
0000000141385f5a: mov      qword ptr [r11 - 0x20], r12
0000000141385f5e: mov      qword ptr [r11 - 0x38], r15
0000000141385f62: movaps   xmmword ptr [r11 - 0x48], xmm6
0000000141385f67: movaps   xmmword ptr [r11 - 0x58], xmm7
0000000141385f6c: movaps   xmmword ptr [r11 - 0x68], xmm8
0000000141385f71: movaps   xmmword ptr [r11 - 0x78], xmm9
0000000141385f76: nop      word ptr [rax + rax]
0000000141385f80: mov      edx, r14d
0000000141385f83: mov      rcx, rax
0000000141385f86: call     0x14131b150
0000000141385f8b: mov      rsi, rax
0000000141385f8e: test     rax, rax
0000000141385f91: je       0x1413864ce
0000000141385f97: mov      rbx, qword ptr [rax + 0xe0]
0000000141385f9e: test     rbx, rbx
0000000141385fa1: je       0x1413864ce
0000000141385fa7: movss    xmm0, dword ptr [rbx + 0x10]
0000000141385fac: ucomiss  xmm0, xmm11
0000000141385fb0: jp       0x141385fb8
0000000141385fb2: je       0x1413864ce
0000000141385fb8: mov      rax, qword ptr [rdi]
0000000141385fbb: mov      rcx, rdi
0000000141385fbe: call     qword ptr [rax + 0x70]
0000000141385fc1: mov      r15, rax
0000000141385fc4: test     rax, rax
0000000141385fc7: je       0x1413864ce
0000000141385fcd: mov      rdx, qword ptr [rsi]
0000000141385fd0: mov      rcx, rsi
0000000141385fd3: call     qword ptr [rdx + 0x70]
0000000141385fd6: movss    xmm2, dword ptr [r15]
0000000141385fdb: lea      rcx, [rsp + 0x20]
0000000141385fe0: movss    xmm1, dword ptr [r15 + 4]
0000000141385fe6: mov      r12, rax
0000000141385fe9: movss    xmm0, dword ptr [r15 + 8]
0000000141385fef: subss    xmm2, dword ptr [rax]
0000000141385ff3: subss    xmm1, dword ptr [rax + 4]
0000000141385ff8: subss    xmm0, dword ptr [rax + 8]
0000000141385ffd: movss    dword ptr [rsp + 0x20], xmm2
0000000141386003: movss    dword ptr [rsp + 0x24], xmm1
0000000141386009: movss    dword ptr [rsp + 0x28], xmm0
000000014138600f: call     0x1411ac880
0000000141386014: mov      rcx, rsi
0000000141386017: movaps   xmm9, xmm0
000000014138601b: call     0x1413852d0
0000000141386020: movzx    eax, byte ptr [rbx + 2]
0000000141386024: movaps   xmm8, xmm0
0000000141386028: test     al, al
000000014138602a: je       0x14138603e
000000014138602c: movaps   xmm1, xmm0
000000014138602f: mulss    xmm1, xmm8
0000000141386034: comiss   xmm1, xmm9
0000000141386038: jbe      0x1413864ce
000000014138603e: movss    xmm1, dword ptr [rbx + 0x10]
0000000141386043: movaps   xmm6, xmm10
0000000141386047: movaps   xmm7, xmm1
000000014138604a: mulss    xmm7, dword ptr [rbx + 0x14]
000000014138604f: addss    xmm7, xmm1
0000000141386053: test     al, al
0000000141386055: je       0x1413860db
000000014138605b: andps    xmm0, xmm13
000000014138605f: comiss   xmm0, xmm12
0000000141386063: jbe      0x1413860db
0000000141386065: mov      ecx, dword ptr [rbx + 0xc]
0000000141386068: sub      ecx, 1
000000014138606b: je       0x1413860ab
000000014138606d: cmp      ecx, 1
0000000141386070: jne      0x1413860db
0000000141386072: xorps    xmm1, xmm1
0000000141386075: xorps    xmm0, xmm0
0000000141386078: cvtss2sd xmm1, xmm9
000000014138607d: ucomisd  xmm0, xmm1
0000000141386081: ja       0x141386095
0000000141386083: sqrtpd   xmm0, xmm1
0000000141386087: xorps    xmm6, xmm6
000000014138608a: cvtsd2ss xmm6, xmm0
000000014138608e: divss    xmm6, xmm8
0000000141386093: jmp      0x1413860db
0000000141386095: movaps   xmm0, xmm1
0000000141386098: call     0x141443054
000000014138609d: xorps    xmm6, xmm6
00000001413860a0: cvtsd2ss xmm6, xmm0
00000001413860a4: divss    xmm6, xmm8
00000001413860a9: jmp      0x1413860db
00000001413860ab: xorps    xmm1, xmm1
00000001413860ae: xorps    xmm0, xmm0
00000001413860b1: cvtss2sd xmm1, xmm9
00000001413860b6: ucomisd  xmm0, xmm1
00000001413860ba: ja       0x1413860c2
00000001413860bc: sqrtpd   xmm0, xmm1
00000001413860c0: jmp      0x1413860ca
00000001413860c2: movaps   xmm0, xmm1
00000001413860c5: call     0x141443054
00000001413860ca: cvtsd2ss xmm0, xmm0
00000001413860ce: movaps   xmm6, xmm10
00000001413860d2: divss    xmm0, xmm8
00000001413860d7: subss    xmm6, xmm0
00000001413860db: movsx    rax, byte ptr [rbx]
00000001413860df: cmp      eax, 6
00000001413860e2: ja       0x1413864ce
00000001413860e8: lea      rdx, [rip - 0x13860ef]
00000001413860ef: mov      ecx, dword ptr [rdx + rax*4 + 0x138656c]
00000001413860f6: add      rcx, rdx
00000001413860f9: jmp      rcx
00000001413860fb: movss    xmm1, dword ptr [rsi + 0x100]
0000000141386103: movaps   xmm8, xmm10
0000000141386107: movaps   xmm0, xmm1
000000014138610a: andps    xmm0, xmm13
000000014138610e: comiss   xmm0, xmm12
0000000141386112: jbe      0x141386119
0000000141386114: divss    xmm8, xmm1
0000000141386119: mov      rax, qword ptr [rsi]
000000014138611c: mov      rcx, rsi
000000014138611f: call     qword ptr [rax + 0x78]
0000000141386122: mov      rcx, rax
0000000141386125: call     0x1411ac880
000000014138612a: movaps   xmm9, xmm0
000000014138612e: comiss   xmm9, xmm12
0000000141386132: jbe      0x1413864ce
0000000141386138: mov      rax, qword ptr [rsi]
000000014138613b: mov      rcx, rsi
000000014138613e: call     qword ptr [rax + 0x78]
0000000141386141: xorps    xmm1, xmm1
0000000141386144: xorps    xmm0, xmm0
0000000141386147: cvtss2sd xmm1, xmm9
000000014138614c: mov      rbx, rax
000000014138614f: ucomisd  xmm0, xmm1
0000000141386153: ja       0x14138615b
0000000141386155: sqrtpd   xmm0, xmm1
0000000141386159: jmp      0x141386163
000000014138615b: movaps   xmm0, xmm1
000000014138615e: call     0x141443054
0000000141386163: cvtsd2ss xmm0, xmm0
0000000141386167: lea      rdx, [rsp + 0x30]
000000014138616c: lea      rcx, [rsp + 0x70]
0000000141386171: mulss    xmm6, xmm7
0000000141386175: movaps   xmm3, xmm10
0000000141386179: divss    xmm3, xmm0
000000014138617d: mulss    xmm6, dword ptr [rdi + 0x208]
0000000141386185: movaps   xmm1, xmm3
0000000141386188: movaps   xmm0, xmm3
000000014138618b: mulss    xmm1, dword ptr [rbx]
000000014138618f: mulss    xmm6, xmm8
0000000141386194: movss    dword ptr [rsp + 0x30], xmm1
000000014138619a: mulss    xmm0, dword ptr [rbx + 4]
000000014138619f: mulss    xmm6, dword ptr [rdi + 0x198]
00000001413861a7: movss    dword ptr [rsp + 0x34], xmm0
00000001413861ad: mulss    xmm3, dword ptr [rbx + 8]
00000001413861b2: mulss    xmm6, dword ptr [rdi + 0x19c]
00000001413861ba: movss    dword ptr [rsp + 0x38], xmm3
00000001413861c0: movaps   xmm2, xmm6
00000001413861c3: call     0x1412c4930
00000001413861c8: lea      r8, [rsp + 0x20]
00000001413861cd: lea      rdx, [rsp + 0x60]
00000001413861d2: lea      rcx, [rsp + 0x70]
00000001413861d7: call     0x1412c53f0
00000001413861dc: lea      rcx, [rdi + 0x1dc]
00000001413861e3: movsd    xmm0, qword ptr [rax]
00000001413861e7: movsd    qword ptr [rsp + 0x20], xmm0
00000001413861ed: mov      eax, dword ptr [rax + 8]
00000001413861f0: movss    xmm2, dword ptr [rsp + 0x20]
00000001413861f6: movss    xmm1, dword ptr [rsp + 0x24]
00000001413861fc: mov      dword ptr [rsp + 0x28], eax
0000000141386200: addss    xmm2, dword ptr [r12]
0000000141386206: addss    xmm1, dword ptr [r12 + 4]
000000014138620d: movss    xmm0, dword ptr [rsp + 0x28]
0000000141386213: addss    xmm0, dword ptr [r12 + 8]
000000014138621a: subss    xmm2, dword ptr [r15]
000000014138621f: subss    xmm1, dword ptr [r15 + 4]
0000000141386225: subss    xmm0, dword ptr [r15 + 8]
000000014138622b: movss    dword ptr [rsp + 0x20], xmm2
0000000141386231: movss    dword ptr [rsp + 0x24], xmm1
0000000141386237: movss    dword ptr [rsp + 0x28], xmm0
000000014138623d: jmp      0x1413864c4
0000000141386242: mulss    xmm7, dword ptr [rdi + 0x208]
000000014138624a: mulss    xmm7, dword ptr [rdi + 0x198]
0000000141386252: mulss    xmm7, dword ptr [rdi + 0x19c]
000000014138625a: comiss   xmm11, xmm7
000000014138625e: movaps   xmm0, xmm7
0000000141386261: addss    xmm0, dword ptr [rdi + 0x204]
0000000141386269: movss    dword ptr [rdi + 0x204], xmm0
0000000141386271: jbe      0x1413864ce
0000000141386277: comiss   xmm11, xmm0
000000014138627b: jbe      0x1413864ce
0000000141386281: mov      dword ptr [rdi + 0x204], 0
000000014138628b: jmp      0x1413864ce
0000000141386290: movss    xmm2, dword ptr [r12]
0000000141386296: lea      rcx, [rsp + 0x20]
000000014138629b: movss    xmm1, dword ptr [r12 + 4]
00000001413862a2: movss    xmm0, dword ptr [r12 + 8]
00000001413862a9: subss    xmm2, dword ptr [r15]
00000001413862ae: subss    xmm1, dword ptr [r15 + 4]
00000001413862b4: subss    xmm0, dword ptr [r15 + 8]
00000001413862ba: movss    dword ptr [rsp + 0x20], xmm2
00000001413862c0: movss    dword ptr [rsp + 0x24], xmm1
00000001413862c6: movss    dword ptr [rsp + 0x28], xmm0
00000001413862cc: call     0x1411ac850
00000001413862d1: comiss   xmm0, xmm12
00000001413862d5: jbe      0x1413864ce
00000001413862db: movss    xmm2, dword ptr [rsp + 0x20]
00000001413862e1: movss    xmm1, dword ptr [rsp + 0x24]
00000001413862e7: mulss    xmm6, xmm7
00000001413862eb: mulss    xmm6, dword ptr [rdi + 0x208]
00000001413862f3: mulss    xmm6, dword ptr [rdi + 0x198]
00000001413862fb: mulss    xmm6, dword ptr [rdi + 0x19c]
0000000141386303: divss    xmm6, xmm0
0000000141386307: movss    xmm0, dword ptr [rsp + 0x28]
000000014138630d: mulss    xmm2, xmm6
0000000141386311: mulss    xmm1, xmm6
0000000141386315: mulss    xmm0, xmm6
0000000141386319: movss    dword ptr [rsp + 0x20], xmm2
000000014138631f: movss    dword ptr [rsp + 0x24], xmm1
0000000141386325: movss    dword ptr [rsp + 0x28], xmm0
000000014138632b: jmp      0x1413864bd
0000000141386330: mov      rax, qword ptr [rsi]
0000000141386333: mov      rcx, rsi
0000000141386336: call     qword ptr [rax + 0x78]
0000000141386339: mulss    xmm6, xmm7
000000014138633d: lea      rdx, [rsp + 0x20]
0000000141386342: mov      rcx, rdi
0000000141386345: mulss    xmm6, dword ptr [rdi + 0x208]
000000014138634d: mulss    xmm6, dword ptr [rdi + 0x198]
0000000141386355: mulss    xmm6, dword ptr [rdi + 0x19c]
000000014138635d: movaps   xmm1, xmm6
0000000141386360: movaps   xmm0, xmm6
0000000141386363: mulss    xmm1, dword ptr [rax]
0000000141386367: mulss    xmm0, dword ptr [rax + 4]
000000014138636c: mulss    xmm6, dword ptr [rax + 8]
0000000141386371: movss    dword ptr [rsp + 0x20], xmm1
0000000141386377: movss    dword ptr [rsp + 0x24], xmm0
000000014138637d: movss    dword ptr [rsp + 0x28], xmm6
0000000141386383: call     0x14130ac30
0000000141386388: jmp      0x1413864ce
000000014138638d: movss    xmm3, dword ptr [rbx + 0x28]
0000000141386392: lea      rcx, [rsp + 0x40]
0000000141386397: movss    xmm2, dword ptr [rbx + 0x24]
000000014138639c: movss    xmm1, dword ptr [rbx + 0x20]
00000001413863a1: call     0x1411ab440
00000001413863a6: movss    xmm2, dword ptr [rsp + 0x40]
00000001413863ac: lea      rdx, [rsp + 0x20]
00000001413863b1: movss    xmm1, dword ptr [rsp + 0x44]
00000001413863b7: mov      rcx, rdi
00000001413863ba: movss    xmm0, dword ptr [rsp + 0x48]
00000001413863c0: mulss    xmm6, xmm7
00000001413863c4: mulss    xmm6, dword ptr [rdi + 0x208]
00000001413863cc: mulss    xmm6, dword ptr [rdi + 0x198]
00000001413863d4: mulss    xmm6, dword ptr [rdi + 0x19c]
00000001413863dc: mulss    xmm2, xmm6
00000001413863e0: mulss    xmm1, xmm6
00000001413863e4: mulss    xmm0, xmm6
00000001413863e8: movss    dword ptr [rsp + 0x20], xmm2
00000001413863ee: movss    dword ptr [rsp + 0x24], xmm1
00000001413863f4: movss    dword ptr [rsp + 0x28], xmm0
00000001413863fa: call     0x14130ae60
00000001413863ff: jmp      0x1413864ce
0000000141386404: movss    xmm3, dword ptr [rbx + 0x28]
0000000141386409: lea      rcx, [rsp + 0x4c]
000000014138640e: movss    xmm2, dword ptr [rbx + 0x24]
0000000141386413: movss    xmm1, dword ptr [rbx + 0x20]
0000000141386418: call     0x1411ab440
000000014138641d: movss    xmm2, dword ptr [rsp + 0x4c]
0000000141386423: lea      rcx, [rdi + 0x1f4]
000000014138642a: movss    xmm1, dword ptr [rsp + 0x50]
0000000141386430: movss    xmm0, dword ptr [rsp + 0x54]
0000000141386436: mulss    xmm6, xmm7
000000014138643a: mulss    xmm6, dword ptr [rdi + 0x208]
0000000141386442: mulss    xmm6, dword ptr [rdi + 0x198]
000000014138644a: mulss    xmm6, dword ptr [rdi + 0x19c]
0000000141386452: mulss    xmm2, xmm6
0000000141386456: mulss    xmm1, xmm6
000000014138645a: mulss    xmm0, xmm6
000000014138645e: movss    dword ptr [rsp + 0x20], xmm2
0000000141386464: movss    dword ptr [rsp + 0x24], xmm1
000000014138646a: movss    dword ptr [rsp + 0x28], xmm0
0000000141386470: jmp      0x1413864c4
0000000141386472: mov      rax, qword ptr [rsi]
0000000141386475: mov      rcx, rsi
0000000141386478: call     qword ptr [rax + 0x78]
000000014138647b: mulss    xmm6, xmm7
000000014138647f: mulss    xmm6, dword ptr [rdi + 0x208]
0000000141386487: mulss    xmm6, dword ptr [rdi + 0x198]
000000014138648f: mulss    xmm6, dword ptr [rdi + 0x19c]
0000000141386497: movaps   xmm1, xmm6
000000014138649a: movaps   xmm0, xmm6
000000014138649d: mulss    xmm1, dword ptr [rax]
00000001413864a1: mulss    xmm0, dword ptr [rax + 4]
00000001413864a6: mulss    xmm6, dword ptr [rax + 8]
00000001413864ab: movss    dword ptr [rsp + 0x20], xmm1
00000001413864b1: movss    dword ptr [rsp + 0x24], xmm0
00000001413864b7: movss    dword ptr [rsp + 0x28], xmm6
00000001413864bd: lea      rcx, [rdi + 0x1d0]
00000001413864c4: lea      rdx, [rsp + 0x20]
00000001413864c9: call     0x1411ab760
00000001413864ce: mov      rax, qword ptr [rsp + 0x58]
00000001413864d3: inc      r14d
00000001413864d6: cmp      r14d, r13d
00000001413864d9: jl       0x141385f80
00000001413864df: movaps   xmm13, xmmword ptr [rsp + 0xa0]
00000001413864e8: movaps   xmm12, xmmword ptr [rsp + 0xb0]
00000001413864f1: movaps   xmm11, xmmword ptr [rsp + 0xc0]
00000001413864fa: movaps   xmm10, xmmword ptr [rsp + 0xd0]
0000000141386503: movaps   xmm9, xmmword ptr [rsp + 0xe0]
000000014138650c: movaps   xmm8, xmmword ptr [rsp + 0xf0]
0000000141386515: movaps   xmm7, xmmword ptr [rsp + 0x100]
000000014138651d: movaps   xmm6, xmmword ptr [rsp + 0x110]
0000000141386525: mov      r15, qword ptr [rsp + 0x120]
000000014138652d: mov      r12, qword ptr [rsp + 0x138]
0000000141386535: mov      rsi, qword ptr [rsp + 0x140]
000000014138653d: mov      rbx, qword ptr [rsp + 0x170]
0000000141386545: mov      r14, qword ptr [rsp + 0x128]
000000014138654d: mov      r13, qword ptr [rsp + 0x130]
0000000141386555: mov      rcx, qword ptr [rbp - 0x68]
0000000141386559: xor      rcx, rsp
000000014138655c: call     0x141441dc0
0000000141386561: add      rsp, 0x148
0000000141386568: pop      rdi
0000000141386569: pop      rbp
000000014138656a: ret      
000000014138656b: nop      
000000014138656c: sti      
