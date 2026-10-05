000000014131bbb0: mov      qword ptr [rsp + 0x18], rbx
000000014131bbb5: push     rsi
000000014131bbb6: push     rdi
000000014131bbb7: push     r14
000000014131bbb9: sub      rsp, 0x40
000000014131bbbd: movaps   xmmword ptr [rsp + 0x30], xmm6
000000014131bbc2: xor      r14d, r14d
000000014131bbc5: movss    xmm6, dword ptr [rip + 0x445a13]
000000014131bbcd: mov      edi, r14d
000000014131bbd0: movaps   xmmword ptr [rsp + 0x20], xmm7
000000014131bbd5: mov      rbx, rcx
000000014131bbd8: mov      esi, 1
000000014131bbdd: call     0x1400b07c0
000000014131bbe2: movss    xmm7, dword ptr [rax + 0x5c]
000000014131bbe7: cmp      qword ptr [rbx + 0xa0], rdi
000000014131bbee: je       0x14131bd8f
000000014131bbf4: mov      rcx, qword ptr [rbx + 0x248]
000000014131bbfb: test     rcx, rcx
000000014131bbfe: je       0x14131bd8f
000000014131bc04: mov      rax, qword ptr [rcx]
000000014131bc07: call     qword ptr [rax + 0x20]
000000014131bc0a: movaps   xmm6, xmm0
000000014131bc0d: mulss    xmm6, dword ptr [rbx + 0x90]
000000014131bc15: cmp      dword ptr [rbx + 0x84], r14d
000000014131bc1c: je       0x14131bc28
000000014131bc1e: call     0x1400b07c0
000000014131bc23: movss    dword ptr [rax + 0x5c], xmm6
000000014131bc28: mov      rcx, qword ptr [rbx + 0x248]
000000014131bc2f: mov      rax, qword ptr [rcx]
000000014131bc32: call     qword ptr [rax + 0x10]
000000014131bc35: mov      rcx, qword ptr [rbx + 0x248]
000000014131bc3c: xor      edx, edx
000000014131bc3e: imul     eax, eax, 0x3e8
000000014131bc44: div      dword ptr [rip + 0x878c9e]
000000014131bc4a: mov      edi, eax
000000014131bc4c: mov      eax, dword ptr [rbx + 0x68]
000000014131bc4f: mov      dword ptr [rbx + 0x6c], eax
000000014131bc52: mov      rax, qword ptr [rcx]
000000014131bc55: call     qword ptr [rax + 8]
000000014131bc58: imul     eax, eax, 0x3e8
000000014131bc5e: xor      edx, edx
000000014131bc60: div      dword ptr [rip + 0x878c82]
000000014131bc66: mov      dword ptr [rbx + 0x68], eax
000000014131bc69: cmp      eax, dword ptr [rbx + 0x6c]
000000014131bc6c: jae      0x14131bca4
000000014131bc6e: add      eax, edi
000000014131bc70: cmp      eax, edi
000000014131bc72: jb       0x14131bca4
000000014131bc74: mov      rax, qword ptr [rbx + 0xa0]
000000014131bc7b: mov      ecx, dword ptr [rax]
000000014131bc7d: cmp      dword ptr [rbx + 0x54], ecx
000000014131bc80: jb       0x14131bc9d
000000014131bc82: mov      dword ptr [rbx + 0x6c], r14d
000000014131bc86: mov      dword ptr [rbx + 0x54], r14d
000000014131bc8a: call     0x1400b07c0
000000014131bc8f: cmp      dword ptr [rax + 0x58], r14d
000000014131bc93: je       0x14131bc9d
000000014131bc95: mov      dword ptr [rbx + 0x74], r14d
000000014131bc99: mov      dword ptr [rbx + 0x58], r14d
000000014131bc9d: mov      dword ptr [rbx + 0x8c], r14d
000000014131bca4: mov      r10, qword ptr [rbx + 0xa0]
000000014131bcab: movsxd   r8, dword ptr [rbx + 0x54]
000000014131bcaf: mov      r9d, dword ptr [r10]
000000014131bcb2: cmp      r8d, r9d
000000014131bcb5: jae      0x14131bd8f
000000014131bcbb: mov      r11d, dword ptr [rbx + 0x68]
000000014131bcbf: cmp      edi, r11d
000000014131bcc2: je       0x14131bd8f
000000014131bcc8: test     r8d, r8d
000000014131bccb: js       0x14131bd82
000000014131bcd1: cmp      r8d, r9d
000000014131bcd4: jge      0x14131bced
000000014131bcd6: mov      rax, qword ptr [r10 + 8]
000000014131bcda: mov      edx, dword ptr [rax + r8*4]
000000014131bcde: and      edx, 0xfffffff
000000014131bce4: cmp      r11d, edx
000000014131bce7: jb       0x14131bd8f
000000014131bced: test     r8d, r8d
000000014131bcf0: js       0x14131bd82
000000014131bcf6: cmp      r8d, r9d
000000014131bcf9: jge      0x14131bd13
000000014131bcfb: mov      rax, qword ptr [r10 + 8]
000000014131bcff: cmp      dword ptr [rax + r8*4], r14d
000000014131bd03: jge      0x14131bd13
000000014131bd05: cmp      dword ptr [rbx + 0x74], r14d
000000014131bd09: jne      0x14131bd0e
000000014131bd0b: mov      dword ptr [rbx + 0x70], esi
000000014131bd0e: mov      dword ptr [rbx + 0x5c], esi
000000014131bd11: jmp      0x14131bd8c
000000014131bd13: test     r8d, r8d
000000014131bd16: js       0x14131bd82
000000014131bd18: cmp      r8d, r9d
000000014131bd1b: jge      0x14131bd82
000000014131bd1d: mov      rax, qword ptr [r10 + 8]
000000014131bd21: mov      edx, dword ptr [rax + r8*4]
000000014131bd25: and      edx, 0x40000000
000000014131bd2b: je       0x14131bd82
000000014131bd2d: cmp      dword ptr [rbx + 0xf0], r14d
000000014131bd34: je       0x14131bd82
000000014131bd36: cmp      dword ptr [rbx + 0x74], r14d
000000014131bd3a: jne      0x14131bd40
000000014131bd3c: mov      dword ptr [rbx + 0x70], r14d
000000014131bd40: call     0x1400b07c0
000000014131bd45: mov      dword ptr [rax + 0x64], esi
000000014131bd48: call     0x1400b07c0
000000014131bd4d: lea      rcx, [rbx + 0xa8]
000000014131bd54: mov      rdx, qword ptr [rcx]
000000014131bd57: cmp      dword ptr [rax + 0x114], r14d
000000014131bd5e: je       0x14131bd71
000000014131bd60: call     qword ptr [rdx + 0xd0]
000000014131bd66: call     0x1400b07c0
000000014131bd6b: mov      dword ptr [rax + 0x64], r14d
000000014131bd6f: jmp      0x14131bd8c
000000014131bd71: call     qword ptr [rdx + 0xc8]
000000014131bd77: call     0x1400b07c0
000000014131bd7c: mov      dword ptr [rax + 0x64], r14d
000000014131bd80: jmp      0x14131bd8c
000000014131bd82: cmp      dword ptr [rbx + 0x74], r14d
000000014131bd86: jne      0x14131bd8c
000000014131bd88: mov      dword ptr [rbx + 0x70], r14d
000000014131bd8c: inc      dword ptr [rbx + 0x54]
000000014131bd8f: cmp      dword ptr [rbx + 0x7c], r14d
000000014131bd93: jne      0x14131bf3a
000000014131bd99: xor      edx, edx
000000014131bd9b: mov      qword ptr [rsp + 0x68], rbp
000000014131bda0: lea      rcx, [rbx + 0x150]
000000014131bda7: call     0x141307910
000000014131bdac: inc      dword ptr [rbx + 0x58]
000000014131bdaf: cmp      qword ptr [rbx + 0x98], r14
000000014131bdb6: je       0x14131beb2
000000014131bdbc: call     0x1400b07c0
000000014131bdc1: mov      ecx, dword ptr [rbx + 0x68]
000000014131bdc4: cmp      dword ptr [rax + 0x58], esi
000000014131bdc7: je       0x14131bdeb
000000014131bdc9: cmp      dword ptr [rbx + 0x6c], ecx
000000014131bdcc: jne      0x14131bdf3
000000014131bdce: test     ecx, ecx
000000014131bdd0: jne      0x14131beb2
000000014131bdd6: cmp      dword ptr [rbx + 0x8c], r14d
000000014131bddd: jne      0x14131beb2
000000014131bde3: mov      dword ptr [rbx + 0x8c], esi
000000014131bde9: jmp      0x14131bdf3
000000014131bdeb: cmp      ecx, edi
000000014131bded: je       0x14131beb2
000000014131bdf3: mov      r8d, dword ptr [rbx + 0x198]
000000014131bdfa: test     r8d, r8d
000000014131bdfd: je       0x14131be79
000000014131bdff: cmp      dword ptr [rbx + 0x70], r14d
000000014131be03: je       0x14131be79
000000014131be05: cmp      dword ptr [rbx + 0x78], r14d
000000014131be09: jne      0x14131be79
000000014131be0b: mov      rdx, qword ptr [rbx + 0x98]
000000014131be12: movss    xmm1, dword ptr [rdx + 0x10]
000000014131be17: cmp      byte ptr [rdx], sil
000000014131be1a: jne      0x14131be28
000000014131be1c: cmp      dword ptr [rbx + 0x74], r14d
000000014131be20: jne      0x14131be4f
000000014131be22: mov      dword ptr [rbx + 0x70], r14d
000000014131be26: jmp      0x14131be4f
000000014131be28: mov      rax, qword ptr [rip + 0x83ed6e9]
000000014131be2f: movzx    ecx, byte ptr [rax + 0x952]
000000014131be36: movd     xmm0, ecx
000000014131be3a: cvtdq2ps xmm0, xmm0
000000014131be3d: divss    xmm1, xmm0
000000014131be41: mulss    xmm1, xmm6
000000014131be45: addss    xmm1, dword ptr [rbx + 0x50]
000000014131be4a: movss    dword ptr [rbx + 0x50], xmm1
000000014131be4f: cvttss2si edx, xmm1
000000014131be53: test     edx, edx
000000014131be55: je       0x14131be79
000000014131be57: movss    xmm1, dword ptr [rbx + 0x50]
000000014131be5c: mov      rcx, rbx
000000014131be5f: imul     r8d, dword ptr [rbx + 0x5c]
000000014131be64: movd     xmm0, edx
000000014131be68: cvtdq2ps xmm0, xmm0
000000014131be6b: subss    xmm1, xmm0
000000014131be6f: movss    dword ptr [rbx + 0x50], xmm1
000000014131be74: call     0x14131b5c0
000000014131be79: mov      rax, qword ptr [rbx + 0x98]
000000014131be80: movsx    ecx, word ptr [rax + 0xc]
000000014131be84: cmp      cx, -1
000000014131be88: je       0x14131beb2
000000014131be8a: cmp      ecx, dword ptr [rbx + 0x58]
000000014131be8d: jge      0x14131beb2
000000014131be8f: call     0x1400b07c0
000000014131be94: cmp      dword ptr [rax + 0x58], r14d
000000014131be98: jne      0x14131bea5
000000014131be9a: mov      rax, qword ptr [rbx]
000000014131be9d: mov      rcx, rbx
000000014131bea0: call     qword ptr [rax + 0x58]
000000014131bea3: jmp      0x14131beb2
000000014131bea5: cmp      dword ptr [rbx + 0x74], r14d
000000014131bea9: jne      0x14131beaf
000000014131beab: mov      dword ptr [rbx + 0x70], r14d
000000014131beaf: mov      dword ptr [rbx + 0x74], esi
000000014131beb2: cmp      dword ptr [rbx + 0x240], r14d
000000014131beb9: je       0x14131beeb
000000014131bebb: lea      rdx, [rbx + 0xa8]
000000014131bec2: lea      rcx, [rbx + 0x1f8]
000000014131bec9: call     0x141307910
000000014131bece: cmp      dword ptr [rbx + 0x240], r14d
000000014131bed5: je       0x14131beeb
000000014131bed7: call     0x1400b07c0
000000014131bedc: mov      rcx, rax
000000014131bedf: lea      rdx, [rbx + 0x1f8]
000000014131bee6: call     0x1412765c0
000000014131beeb: cmp      dword ptr [rbx + 0xf0], r14d
000000014131bef2: je       0x14131bf07
000000014131bef4: lea      rcx, [rbx + 0xa8]
000000014131befb: lea      rdx, [rbx + 0x150]
000000014131bf02: call     0x141307910
000000014131bf07: mov      rbp, qword ptr [rsp + 0x68]
000000014131bf0c: cmp      dword ptr [rbx + 0x240], r14d
000000014131bf13: je       0x14131bf22
000000014131bf15: call     0x1400b07c0
000000014131bf1a: mov      rcx, rax
000000014131bf1d: call     0x141278270
000000014131bf22: cmp      dword ptr [rbx + 0x78], r14d
000000014131bf26: je       0x14131bf33
000000014131bf28: cmp      dword ptr [rbx + 0xf0], r14d
000000014131bf2f: cmove    esi, r14d
000000014131bf33: mov      dword ptr [rbx + 0x5c], 1
000000014131bf3a: call     0x1400b07c0
000000014131bf3f: mov      rbx, qword ptr [rsp + 0x70]
000000014131bf44: movaps   xmm6, xmmword ptr [rsp + 0x30]
000000014131bf49: movss    dword ptr [rax + 0x5c], xmm7
000000014131bf4e: mov      eax, esi
000000014131bf50: movaps   xmm7, xmmword ptr [rsp + 0x20]
000000014131bf55: add      rsp, 0x40
000000014131bf59: pop      r14
000000014131bf5b: pop      rdi
000000014131bf5c: pop      rsi
000000014131bf5d: ret      
