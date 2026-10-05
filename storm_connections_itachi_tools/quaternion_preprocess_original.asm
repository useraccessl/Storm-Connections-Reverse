0000000141394b30: mov      r11, rsp
0000000141394b33: mov      qword ptr [r11 + 0x20], rbp
0000000141394b37: push     rsi
0000000141394b38: sub      rsp, 0x70
0000000141394b3c: mov      rax, qword ptr [rip + 0xd51885]
0000000141394b43: xor      rax, rsp
0000000141394b46: mov      qword ptr [rsp + 0x40], rax
0000000141394b4b: xor      esi, esi
0000000141394b4d: mov      rbp, rcx
0000000141394b50: cmp      si, word ptr [rcx + 8]
0000000141394b54: jae      0x141394c5e
0000000141394b5a: mov      qword ptr [r11 + 0x10], rbx
0000000141394b5e: mov      qword ptr [r11 + 0x18], rdi
0000000141394b62: movaps   xmmword ptr [rsp + 0x60], xmm6
0000000141394b67: movss    xmm6, dword ptr [rip + 0x810691]
0000000141394b6f: movaps   xmmword ptr [rsp + 0x50], xmm7
0000000141394b74: movss    xmm7, dword ptr [rip + 0x68dbfc]
0000000141394b7c: nop      dword ptr [rax]
0000000141394b80: mov      rbx, qword ptr [rbp + 0x18]
0000000141394b84: lea      rcx, [rsp + 0x30]
0000000141394b89: movzx    edi, si
0000000141394b8c: call     0x1412aa0a0
0000000141394b91: movsx    eax, word ptr [rbx + rdi*8 + 0xa]
0000000141394b96: lea      rcx, [rsp + 0x30]
0000000141394b9b: movd     xmm0, eax
0000000141394b9f: movsx    eax, word ptr [rbx + rdi*8 + 8]
0000000141394ba4: cvtdq2ps xmm0, xmm0
0000000141394ba7: movd     xmm3, eax
0000000141394bab: movsx    eax, word ptr [rbx + rdi*8 + 6]
0000000141394bb0: cvtdq2ps xmm3, xmm3
0000000141394bb3: movd     xmm2, eax
0000000141394bb7: movsx    eax, word ptr [rbx + rdi*8 + 4]
0000000141394bbc: cvtdq2ps xmm2, xmm2
0000000141394bbf: movd     xmm1, eax
0000000141394bc3: cvtdq2ps xmm1, xmm1
0000000141394bc6: mulss    xmm0, xmm6
0000000141394bca: mulss    xmm1, xmm6
0000000141394bce: mulss    xmm3, xmm6
0000000141394bd2: mulss    xmm2, xmm6
0000000141394bd6: movss    dword ptr [rsp + 0x20], xmm0
0000000141394bdc: call     0x1412ab7f0
0000000141394be1: lea      rcx, [rsp + 0x30]
0000000141394be6: call     0x1412ab300
0000000141394beb: movss    xmm0, dword ptr [rsp + 0x30]
0000000141394bf1: inc      si
0000000141394bf4: movss    xmm1, dword ptr [rsp + 0x34]
0000000141394bfa: movss    xmm3, dword ptr [rsp + 0x3c]
0000000141394c00: movss    xmm2, dword ptr [rsp + 0x38]
0000000141394c06: mulss    xmm0, xmm7
0000000141394c0a: mulss    xmm1, xmm7
0000000141394c0e: cvttss2si eax, xmm0
0000000141394c12: mulss    xmm2, xmm7
0000000141394c16: mov      word ptr [rbx + rdi*8 + 4], ax
0000000141394c1b: cvttss2si eax, xmm1
0000000141394c1f: mulss    xmm3, xmm7
0000000141394c23: mov      word ptr [rbx + rdi*8 + 6], ax
0000000141394c28: cvttss2si eax, xmm2
0000000141394c2c: mov      word ptr [rbx + rdi*8 + 8], ax
0000000141394c31: cvttss2si eax, xmm3
0000000141394c35: mov      word ptr [rbx + rdi*8 + 0xa], ax
0000000141394c3a: cmp      si, word ptr [rbp + 8]
0000000141394c3e: jb       0x141394b80
0000000141394c44: movaps   xmm7, xmmword ptr [rsp + 0x50]
0000000141394c49: movaps   xmm6, xmmword ptr [rsp + 0x60]
0000000141394c4e: mov      rdi, qword ptr [rsp + 0x90]
0000000141394c56: mov      rbx, qword ptr [rsp + 0x88]
0000000141394c5e: mov      rcx, qword ptr [rsp + 0x40]
0000000141394c63: xor      rcx, rsp
0000000141394c66: call     0x141441dc0
0000000141394c6b: mov      rbp, qword ptr [rsp + 0x98]
0000000141394c73: add      rsp, 0x70
0000000141394c77: pop      rsi
0000000141394c78: ret      
