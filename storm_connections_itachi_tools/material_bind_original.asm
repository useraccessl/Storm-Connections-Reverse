00000001412f5ff0: mov      rax, rsp
00000001412f5ff3: mov      qword ptr [rax + 0x18], rbx
00000001412f5ff7: push     rbp
00000001412f5ff8: push     rsi
00000001412f5ff9: push     rdi
00000001412f5ffa: push     r12
00000001412f5ffc: push     r13
00000001412f5ffe: push     r14
00000001412f6000: push     r15
00000001412f6002: lea      rbp, [rax - 0x5f]
00000001412f6006: sub      rsp, 0xe0
00000001412f600d: movaps   xmmword ptr [rax - 0x48], xmm6
00000001412f6011: movaps   xmmword ptr [rax - 0x58], xmm7
00000001412f6015: mov      rax, qword ptr [rip + 0xdf03ac]
00000001412f601c: xor      rax, rsp
00000001412f601f: mov      qword ptr [rbp - 9], rax
00000001412f6023: mov      rdi, rcx
00000001412f6026: xor      ebx, ebx
00000001412f6028: mov      rcx, qword ptr [rcx + 0x18]
00000001412f602c: mov      r14, rdx
00000001412f602f: test     rcx, rcx
00000001412f6032: je       0x1412f603f
00000001412f6034: mov      rax, qword ptr [rcx]
00000001412f6037: call     qword ptr [rax + 8]
00000001412f603a: mov      rsi, rax
00000001412f603d: jmp      0x1412f6042
00000001412f603f: mov      rsi, rbx
00000001412f6042: lea      rdx, [r14 + 0x510]
00000001412f6049: lea      rcx, [rbp - 0x59]
00000001412f604d: call     0x1412a7d00
00000001412f6052: lea      rdx, [r14 + 0x520]
00000001412f6059: lea      rcx, [rbp - 0x49]
00000001412f605d: call     0x1412a7d00
00000001412f6062: lea      rdx, [r14 + 0x530]
00000001412f6069: lea      rcx, [rbp - 0x79]
00000001412f606d: call     0x1412a7d00
00000001412f6072: lea      rdx, [r14 + 0x540]
00000001412f6079: lea      rcx, [rbp - 0x39]
00000001412f607d: call     0x1412a7d00
00000001412f6082: lea      rdx, [r14 + 0x550]
00000001412f6089: lea      rcx, [rbp - 0x29]
00000001412f608d: call     0x1412a7d00
00000001412f6092: lea      rdx, [r14 + 0x3b0]
00000001412f6099: lea      rcx, [rbp - 0x69]
00000001412f609d: call     0x1412a7d00
00000001412f60a2: lea      rdx, [r14 + 0x4f0]
00000001412f60a9: lea      rcx, [rsp + 0x30]
00000001412f60ae: call     0x1412a7d00
00000001412f60b3: lea      rdx, [r14 + 0x560]
00000001412f60ba: lea      rcx, [rbp - 0x19]
00000001412f60be: call     0x1412a7d00
00000001412f60c3: movss    xmm0, dword ptr [rdi + 0x54]
00000001412f60c8: lea      rcx, [rbp - 0x59]
00000001412f60cc: movss    xmm3, dword ptr [rdi + 0x50]
00000001412f60d1: movss    xmm2, dword ptr [rdi + 0x34]
00000001412f60d6: movss    xmm1, dword ptr [rdi + 0x30]
00000001412f60db: movss    dword ptr [rsp + 0x20], xmm0
00000001412f60e1: call     0x1412a96c0
00000001412f60e6: movss    xmm0, dword ptr [rdi + 0x5c]
00000001412f60eb: lea      rcx, [rbp - 0x49]
00000001412f60ef: movss    xmm3, dword ptr [rdi + 0x58]
00000001412f60f4: movss    xmm2, dword ptr [rdi + 0x3c]
00000001412f60f9: movss    xmm1, dword ptr [rdi + 0x38]
00000001412f60fe: movss    dword ptr [rsp + 0x20], xmm0
00000001412f6104: call     0x1412a96c0
00000001412f6109: movss    xmm0, dword ptr [rdi + 0x64]
00000001412f610e: lea      rcx, [rbp - 0x79]
00000001412f6112: movss    xmm3, dword ptr [rdi + 0x60]
00000001412f6117: movss    xmm2, dword ptr [rdi + 0x44]
00000001412f611c: movss    xmm1, dword ptr [rdi + 0x40]
00000001412f6121: movss    dword ptr [rsp + 0x20], xmm0
00000001412f6127: call     0x1412a96c0
00000001412f612c: movss    xmm0, dword ptr [rdi + 0x6c]
00000001412f6131: lea      rcx, [rbp - 0x39]
00000001412f6135: movss    xmm3, dword ptr [rdi + 0x68]
00000001412f613a: movss    xmm2, dword ptr [rdi + 0x4c]
00000001412f613f: movss    xmm1, dword ptr [rdi + 0x48]
00000001412f6144: movss    dword ptr [rsp + 0x20], xmm0
00000001412f614a: call     0x1412a96c0
00000001412f614f: movss    xmm2, dword ptr [rdi + 0x74]
00000001412f6154: lea      rcx, [rbp - 0x29]
00000001412f6158: movss    xmm1, dword ptr [rdi + 0x70]
00000001412f615d: xorps    xmm7, xmm7
00000001412f6160: xorps    xmm3, xmm3
00000001412f6163: movss    dword ptr [rsp + 0x20], xmm7
00000001412f6169: call     0x1412a96c0
00000001412f616e: mov      rcx, qword ptr [rdi + 0x18]
00000001412f6172: movss    xmm0, dword ptr [rdi + 0x80]
00000001412f617a: movss    xmm1, dword ptr [rdi + 0x7c]
00000001412f617f: movss    dword ptr [rbp - 0x69], xmm0
00000001412f6184: movss    dword ptr [rbp - 0x5d], xmm1
00000001412f6189: test     rcx, rcx
00000001412f618c: je       0x1412f61a9
00000001412f618e: mov      rax, qword ptr [rcx]
00000001412f6191: call     qword ptr [rax + 8]
00000001412f6194: test     rax, rax
00000001412f6197: je       0x1412f61a9
00000001412f6199: test     byte ptr [rax + 0x1c], 0x20
00000001412f619d: je       0x1412f61a9
00000001412f619f: movss    xmm0, dword ptr [rdi + 0x78]
00000001412f61a4: movss    dword ptr [rbp - 0x79], xmm0
00000001412f61a9: movss    xmm0, dword ptr [rdi + 0x84]
00000001412f61b1: divss    xmm0, dword ptr [rip + 0x4a8027]
00000001412f61b9: mov      rcx, qword ptr [rip + 0x8413358]
00000001412f61c0: movss    dword ptr [rbp - 0x19], xmm0
00000001412f61c5: call     0x1412a4eb0
00000001412f61ca: xorps    xmm0, xmm0
00000001412f61cd: movd     xmm6, eax
00000001412f61d1: mov      eax, dword ptr [rip + 0x89e711]
00000001412f61d7: cvtdq2ps xmm6, xmm6
00000001412f61da: cvtsi2ss xmm0, rax
00000001412f61df: mulss    xmm6, dword ptr [rip + 0x46d781]
00000001412f61e7: divss    xmm6, xmm0
00000001412f61eb: movss    xmm0, dword ptr [rdi + 0x60]
00000001412f61f0: call     0x141299bc0
00000001412f61f5: test     eax, eax
00000001412f61f7: je       0x1412f61fe
00000001412f61f9: xorps    xmm1, xmm1
00000001412f61fc: jmp      0x1412f6215
00000001412f61fe: movaps   xmm1, xmm6
00000001412f6201: mulss    xmm1, dword ptr [rdi + 0x60]
00000001412f6206: cvttss2si eax, xmm1
00000001412f620a: movd     xmm0, eax
00000001412f620e: cvtdq2ps xmm0, xmm0
00000001412f6211: subss    xmm1, xmm0
00000001412f6215: movss    xmm0, dword ptr [rdi + 0x64]
00000001412f621a: movss    dword ptr [rsp + 0x30], xmm1
00000001412f6220: call     0x141299bc0
00000001412f6225: test     eax, eax
00000001412f6227: je       0x1412f622e
00000001412f6229: xorps    xmm1, xmm1
00000001412f622c: jmp      0x1412f6245
00000001412f622e: movaps   xmm1, xmm6
00000001412f6231: mulss    xmm1, dword ptr [rdi + 0x64]
00000001412f6236: cvttss2si eax, xmm1
00000001412f623a: movd     xmm0, eax
00000001412f623e: cvtdq2ps xmm0, xmm0
00000001412f6241: subss    xmm1, xmm0
00000001412f6245: movss    xmm0, dword ptr [rdi + 0x68]
00000001412f624a: movss    dword ptr [rsp + 0x34], xmm1
00000001412f6250: call     0x141299bc0
00000001412f6255: test     eax, eax
00000001412f6257: je       0x1412f625e
00000001412f6259: xorps    xmm1, xmm1
00000001412f625c: jmp      0x1412f6275
00000001412f625e: movaps   xmm1, xmm6
00000001412f6261: mulss    xmm1, dword ptr [rdi + 0x68]
00000001412f6266: cvttss2si eax, xmm1
00000001412f626a: movd     xmm0, eax
00000001412f626e: cvtdq2ps xmm0, xmm0
00000001412f6271: subss    xmm1, xmm0
00000001412f6275: movss    xmm0, dword ptr [rdi + 0x6c]
00000001412f627a: movss    dword ptr [rsp + 0x38], xmm1
00000001412f6280: call     0x141299bc0
00000001412f6285: test     eax, eax
00000001412f6287: jne      0x1412f62a0
00000001412f6289: mulss    xmm6, dword ptr [rdi + 0x6c]
00000001412f628e: cvttss2si eax, xmm6
00000001412f6292: movd     xmm0, eax
00000001412f6296: cvtdq2ps xmm0, xmm0
00000001412f6299: subss    xmm6, xmm0
00000001412f629d: movaps   xmm7, xmm6
00000001412f62a0: movups   xmm0, xmmword ptr [rbp - 0x59]
00000001412f62a4: movups   xmm1, xmmword ptr [rbp - 0x49]
00000001412f62a8: movups   xmmword ptr [r14 + 0x510], xmm0
00000001412f62b0: movups   xmm0, xmmword ptr [rbp - 0x79]
00000001412f62b4: movups   xmmword ptr [r14 + 0x520], xmm1
00000001412f62bc: movups   xmm1, xmmword ptr [rbp - 0x39]
00000001412f62c0: movups   xmmword ptr [r14 + 0x530], xmm0
00000001412f62c8: movups   xmm0, xmmword ptr [rbp - 0x29]
00000001412f62cc: movups   xmmword ptr [r14 + 0x540], xmm1
00000001412f62d4: movups   xmm1, xmmword ptr [rbp - 0x69]
00000001412f62d8: movups   xmmword ptr [r14 + 0x550], xmm0
00000001412f62e0: movups   xmm0, xmmword ptr [rsp + 0x30]
00000001412f62e5: movups   xmmword ptr [r14 + 0x3b0], xmm1
00000001412f62ed: shufps   xmm0, xmm0, 0x93
00000001412f62f1: movss    xmm0, xmm7
00000001412f62f5: shufps   xmm0, xmm0, 0x39
00000001412f62f9: movups   xmmword ptr [r14 + 0x4f0], xmm0
00000001412f6301: movups   xmmword ptr [rsp + 0x30], xmm0
00000001412f6306: movups   xmm0, xmmword ptr [rbp - 0x19]
00000001412f630a: movups   xmmword ptr [r14 + 0x560], xmm0
00000001412f6312: mov      eax, dword ptr [rdi + 0x88]
00000001412f6318: mov      dword ptr [r14 + 0x6e0], eax
00000001412f631f: movzx    edi, byte ptr [rsi + 0x18]
00000001412f6323: test     edi, edi
00000001412f6325: je       0x1412f634d
00000001412f6327: nop      word ptr [rax + rax]
00000001412f6330: mov      rax, qword ptr [rsi + 0x10]
00000001412f6334: movzx    ecx, bx
00000001412f6337: shl      rcx, 5
00000001412f633b: mov      edx, dword ptr [rcx + rax + 4]
00000001412f633f: mov      rcx, r14
00000001412f6342: call     0x141337b50
00000001412f6347: inc      ebx
00000001412f6349: cmp      ebx, edi
00000001412f634b: jb       0x1412f6330
00000001412f634d: mov      rcx, qword ptr [rbp - 9]
00000001412f6351: xor      rcx, rsp
00000001412f6354: call     0x141441dc0
00000001412f6359: lea      r11, [rsp + 0xe0]
00000001412f6361: mov      rbx, qword ptr [r11 + 0x50]
00000001412f6365: movaps   xmm6, xmmword ptr [r11 - 0x10]
00000001412f636a: movaps   xmm7, xmmword ptr [r11 - 0x20]
00000001412f636f: mov      rsp, r11
00000001412f6372: pop      r15
00000001412f6374: pop      r14
00000001412f6376: pop      r13
00000001412f6378: pop      r12
00000001412f637a: pop      rdi
00000001412f637b: pop      rsi
00000001412f637c: pop      rbp
00000001412f637d: ret      
