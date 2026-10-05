0000000140a6cb10: mov      rax, rsp
0000000140a6cb13: mov      qword ptr [rax + 0x18], rbx
0000000140a6cb17: push     rbp
0000000140a6cb18: push     rsi
0000000140a6cb19: push     rdi
0000000140a6cb1a: lea      rbp, [rax - 0x78]
0000000140a6cb1e: sub      rsp, 0x160
0000000140a6cb25: movaps   xmmword ptr [rax - 0x28], xmm6
0000000140a6cb29: movaps   xmmword ptr [rax - 0x38], xmm7
0000000140a6cb2d: movaps   xmmword ptr [rax - 0x48], xmm8
0000000140a6cb32: movaps   xmmword ptr [rax - 0x58], xmm9
0000000140a6cb37: movaps   xmmword ptr [rax - 0x68], xmm10
0000000140a6cb3c: mov      rax, qword ptr [rip + 0x1679885]
0000000140a6cb43: xor      rax, rsp
0000000140a6cb46: mov      qword ptr [rbp], rax
0000000140a6cb4a: mov      rbx, rdx
0000000140a6cb4d: mov      rdi, rcx
0000000140a6cb50: mov      rdx, qword ptr [rdx + 8]
0000000140a6cb54: add      rdx, 0xac
0000000140a6cb5b: lea      rcx, [rsp + 0x40]
0000000140a6cb60: call     0x14127e3b0
0000000140a6cb65: mov      rsi, qword ptr [rbx + 8]
0000000140a6cb69: mov      edx, 0xc
0000000140a6cb6e: mov      rcx, rbx
0000000140a6cb71: call     0x140a61ec0
0000000140a6cb76: movaps   xmm7, xmm0
0000000140a6cb79: call     0x1410abed0
0000000140a6cb7e: movaps   xmm8, xmm0
0000000140a6cb82: movss    xmm10, dword ptr [rip + 0xcf4c5d]
0000000140a6cb8b: mulss    xmm8, xmm10
0000000140a6cb90: movss    xmm9, dword ptr [rip + 0xcf4c53]
0000000140a6cb99: divss    xmm8, xmm9
0000000140a6cb9e: movaps   xmm0, xmm7
0000000140a6cba1: call     0x1410abed0
0000000140a6cba6: movaps   xmm6, xmm0
0000000140a6cba9: mulss    xmm6, xmm10
0000000140a6cbae: divss    xmm6, xmm9
0000000140a6cbb3: movaps   xmm0, xmm7
0000000140a6cbb6: call     0x1410abed0
0000000140a6cbbb: mulss    xmm0, xmm10
0000000140a6cbc0: divss    xmm0, xmm9
0000000140a6cbc5: movaps   xmm3, xmm8
0000000140a6cbc9: movaps   xmm2, xmm6
0000000140a6cbcc: movaps   xmm1, xmm0
0000000140a6cbcf: lea      rcx, [rbp - 0x80]
0000000140a6cbd3: call     0x14127fea0
0000000140a6cbd8: mov      rcx, rax
0000000140a6cbdb: lea      r8, [rsp + 0x40]
0000000140a6cbe0: lea      rdx, [rbp - 0x40]
0000000140a6cbe4: call     0x14127e960
0000000140a6cbe9: mov      rdx, rax
0000000140a6cbec: lea      rcx, [rsp + 0x40]
0000000140a6cbf1: call     0x14127e710
0000000140a6cbf6: mov      edx, 0x12
0000000140a6cbfb: mov      rcx, rbx
0000000140a6cbfe: call     0x140a61ec0
0000000140a6cc03: mulss    xmm0, xmm10
0000000140a6cc08: divss    xmm0, xmm9
0000000140a6cc0d: movaps   xmm1, xmm0
0000000140a6cc10: lea      rcx, [rbp - 0x40]
0000000140a6cc14: call     0x141281850
0000000140a6cc19: mov      rcx, rax
0000000140a6cc1c: lea      r8, [rsp + 0x40]
0000000140a6cc21: lea      rdx, [rbp - 0x80]
0000000140a6cc25: call     0x14127e960
0000000140a6cc2a: mov      rdx, rax
0000000140a6cc2d: lea      rcx, [rsp + 0x40]
0000000140a6cc32: call     0x14127e710
0000000140a6cc37: mov      edx, 0x10
0000000140a6cc3c: mov      rcx, rbx
0000000140a6cc3f: call     0x140a61ec0
0000000140a6cc44: movaps   xmm6, xmm0
0000000140a6cc47: mov      edx, 0x11
0000000140a6cc4c: mov      rcx, rbx
0000000140a6cc4f: call     0x140a61ec0
0000000140a6cc54: call     0x1410abed0
0000000140a6cc59: addss    xmm6, xmm0
0000000140a6cc5d: lea      rdx, [rsp + 0x30]
0000000140a6cc62: lea      rcx, [rsp + 0x40]
0000000140a6cc67: call     0x141284120
0000000140a6cc6c: movss    xmm3, dword ptr [rax + 8]
0000000140a6cc71: movss    xmm7, dword ptr [rip + 0xcf4527]
0000000140a6cc79: xorps    xmm3, xmm7
0000000140a6cc7c: movss    xmm2, dword ptr [rax + 4]
0000000140a6cc81: xorps    xmm2, xmm7
0000000140a6cc84: movss    xmm1, dword ptr [rax]
0000000140a6cc88: xorps    xmm1, xmm7
0000000140a6cc8b: lea      rcx, [rsp + 0x20]
0000000140a6cc90: call     0x1411ab440
0000000140a6cc95: lea      rcx, [rsp + 0x20]
0000000140a6cc9a: call     0x1411ac880
0000000140a6cc9f: xorps    xmm8, xmm8
0000000140a6cca3: comiss   xmm0, xmm8
0000000140a6cca7: jbe      0x140a6ccfa
0000000140a6cca9: lea      rdx, [rsp + 0x30]
0000000140a6ccae: lea      rcx, [rsp + 0x20]
0000000140a6ccb3: call     0x1411acc30
0000000140a6ccb8: movsd    xmm2, qword ptr [rax]
0000000140a6ccbc: mov      eax, dword ptr [rax + 8]
0000000140a6ccbf: mov      dword ptr [rsp + 0x28], eax
0000000140a6ccc3: movaps   xmm1, xmm2
0000000140a6ccc6: shufps   xmm1, xmm1, 0x55
0000000140a6ccca: mulss    xmm1, xmm6
0000000140a6ccce: movss    xmm0, dword ptr [rsp + 0x28]
0000000140a6ccd4: mulss    xmm0, xmm6
0000000140a6ccd8: movsd    qword ptr [rsp + 0x20], xmm2
0000000140a6ccde: mulss    xmm2, xmm6
0000000140a6cce2: movss    dword ptr [rsi + 0xa0], xmm2
0000000140a6ccea: movss    dword ptr [rsi + 0xa4], xmm1
0000000140a6ccf2: movss    dword ptr [rsi + 0xa8], xmm0
0000000140a6ccfa: mov      edx, 0xa
0000000140a6ccff: mov      rcx, rbx
0000000140a6cd02: call     0x140a61ec0
0000000140a6cd07: movaps   xmm6, xmm0
0000000140a6cd0a: mulss    xmm6, dword ptr [rip + 0xf08a66]
0000000140a6cd12: mov      rax, qword ptr [rip + 0x8c9c7ff]
0000000140a6cd19: movzx    ecx, byte ptr [rax + 0x952]
0000000140a6cd20: imul     ecx, ecx
0000000140a6cd23: movd     xmm1, ecx
0000000140a6cd27: cvtdq2ps xmm1, xmm1
0000000140a6cd2a: divss    xmm6, xmm1
0000000140a6cd2e: mov      rcx, qword ptr gs:[0x58]
0000000140a6cd37: mov      eax, dword ptr [rip + 0x8ce5ed3]
0000000140a6cd3d: mov      edx, 0x3428
0000000140a6cd42: mov      rax, qword ptr [rcx + rax*8]
0000000140a6cd46: mov      ecx, dword ptr [rdx + rax]
0000000140a6cd49: cmp      dword ptr [rip + 0x16faded], ecx
0000000140a6cd4f: jg       0x140a6ce27
0000000140a6cd55: movss    xmm3, dword ptr [rip + 0x16faddb]
0000000140a6cd5d: xorps    xmm3, xmm7
0000000140a6cd60: movss    xmm2, dword ptr [rip + 0x16fadcc]
0000000140a6cd68: xorps    xmm2, xmm7
0000000140a6cd6b: movss    xmm1, dword ptr [rip + 0x16fadbd]
0000000140a6cd73: xorps    xmm1, xmm7
0000000140a6cd76: lea      rcx, [rsp + 0x20]
0000000140a6cd7b: call     0x1411ab440
0000000140a6cd80: movss    xmm1, dword ptr [rsp + 0x20]
0000000140a6cd86: mulss    xmm1, xmm6
0000000140a6cd8a: movss    xmm2, dword ptr [rsp + 0x24]
0000000140a6cd90: mulss    xmm2, xmm6
0000000140a6cd94: movss    xmm0, dword ptr [rsp + 0x28]
0000000140a6cd9a: mulss    xmm0, xmm6
0000000140a6cd9e: movss    dword ptr [rsp + 0x28], xmm0
0000000140a6cda4: unpcklps xmm1, xmm2
0000000140a6cda7: movsd    qword ptr [rdi + 8], xmm1
0000000140a6cdac: mov      eax, dword ptr [rsp + 0x28]
0000000140a6cdb0: mov      dword ptr [rdi + 0x10], eax
0000000140a6cdb3: mov      edx, 0xd
0000000140a6cdb8: mov      rcx, rbx
0000000140a6cdbb: call     0x140a61ec0
0000000140a6cdc0: movaps   xmm1, xmm0
0000000140a6cdc3: mov      rcx, rbx
0000000140a6cdc6: call     0x140a61fc0
0000000140a6cdcb: mov      edx, 0xb
0000000140a6cdd0: mov      rcx, rbx
0000000140a6cdd3: call     0x140a61ec0
0000000140a6cdd8: movss    dword ptr [rdi + 0x14], xmm0
0000000140a6cddd: mov      edx, 0xf
0000000140a6cde2: mov      rcx, rbx
0000000140a6cde5: call     0x140a61ec0
0000000140a6cdea: movss    dword ptr [rdi + 0x18], xmm0
0000000140a6cdef: mov      rcx, qword ptr [rbp]
0000000140a6cdf3: xor      rcx, rsp
0000000140a6cdf6: call     0x141441dc0
0000000140a6cdfb: lea      r11, [rsp + 0x160]
0000000140a6ce03: mov      rbx, qword ptr [r11 + 0x30]
0000000140a6ce07: movaps   xmm6, xmmword ptr [r11 - 0x10]
0000000140a6ce0c: movaps   xmm7, xmmword ptr [r11 - 0x20]
0000000140a6ce11: movaps   xmm8, xmmword ptr [r11 - 0x30]
0000000140a6ce16: movaps   xmm9, xmmword ptr [r11 - 0x40]
0000000140a6ce1b: movaps   xmm10, xmmword ptr [r11 - 0x50]
0000000140a6ce20: mov      rsp, r11
0000000140a6ce23: pop      rdi
0000000140a6ce24: pop      rsi
0000000140a6ce25: pop      rbp
0000000140a6ce26: ret      
0000000140a6ce27: lea      rcx, [rip + 0x16fad0e]
0000000140a6ce2e: call     0x141441c00
0000000140a6ce33: cmp      dword ptr [rip + 0x16fad02], -1
0000000140a6ce3a: jne      0x140a6cd55
0000000140a6ce40: movss    xmm3, dword ptr [rip + 0xcf4798]
0000000140a6ce48: xorps    xmm2, xmm2
0000000140a6ce4b: xorps    xmm1, xmm1
0000000140a6ce4e: lea      rcx, [rip + 0x16facdb]
0000000140a6ce55: call     0x1411ab440
0000000140a6ce5a: lea      rcx, [rip + 0xcbd25f]
0000000140a6ce61: call     0x1414419a8
0000000140a6ce66: nop      
0000000140a6ce67: lea      rcx, [rip + 0x16facce]
0000000140a6ce6e: call     0x141441ba0
0000000140a6ce73: jmp      0x140a6cd55
