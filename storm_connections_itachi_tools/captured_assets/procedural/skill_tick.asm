00000001405e00c0: mov      qword ptr [rsp + 0x18], rbx
00000001405e00c5: mov      qword ptr [rsp + 0x20], rdi
00000001405e00ca: push     rbp
00000001405e00cb: lea      rbp, [rsp - 0x80]
00000001405e00d0: sub      rsp, 0x180
00000001405e00d7: mov      rax, qword ptr [rip + 0x1b062ea]
00000001405e00de: xor      rax, rsp
00000001405e00e1: mov      qword ptr [rbp + 0x70], rax
00000001405e00e5: mov      rbx, rcx
00000001405e00e8: mov      edi, edx
00000001405e00ea: mov      rcx, qword ptr [rcx + 0x140]
00000001405e00f1: test     rcx, rcx
00000001405e00f4: je       0x1405e02e8
00000001405e00fa: mov      rax, qword ptr [rcx]
00000001405e00fd: call     qword ptr [rax + 0x28]
00000001405e0100: lea      rcx, [rsp + 0x70]
00000001405e0105: call     0x14127e6d0
00000001405e010a: movss    xmm3, dword ptr [rbx + 0x78]
00000001405e010f: lea      rcx, [rsp + 0x30]
00000001405e0114: movss    xmm2, dword ptr [rbx + 0x74]
00000001405e0119: movss    xmm1, dword ptr [rbx + 0x70]
00000001405e011e: call     0x141283eb0
00000001405e0123: lea      rdx, [rbp - 0x10]
00000001405e0127: lea      rcx, [rsp + 0x70]
00000001405e012c: call     0x141283aa0
00000001405e0131: mov      rdx, rax
00000001405e0134: lea      r8, [rsp + 0x30]
00000001405e0139: lea      rcx, [rbp + 0x30]
00000001405e013d: call     0x1411af0c0
00000001405e0142: mov      rdx, rax
00000001405e0145: lea      rcx, [rbp - 0x50]
00000001405e0149: call     0x14127e5e0
00000001405e014e: lea      rdx, [rbp - 0x50]
00000001405e0152: lea      rcx, [rsp + 0x70]
00000001405e0157: call     0x14127e710
00000001405e015c: lea      rdx, [rbx + 0xac]
00000001405e0163: lea      rcx, [rbp + 0x30]
00000001405e0167: call     0x14127e3b0
00000001405e016c: mov      r8, rax
00000001405e016f: lea      rdx, [rbp - 0x10]
00000001405e0173: lea      rcx, [rsp + 0x70]
00000001405e0178: call     0x141280a10
00000001405e017d: mov      rdx, rax
00000001405e0180: lea      rcx, [rsp + 0x70]
00000001405e0185: call     0x14127e710
00000001405e018a: movss    xmm1, dword ptr [rbx + 0xec]
00000001405e0192: lea      rcx, [rbp + 0x30]
00000001405e0196: mulss    xmm1, dword ptr [rip + 0x118164a]
00000001405e019e: divss    xmm1, dword ptr [rip + 0x1181646]
00000001405e01a6: call     0x1412818a0
00000001405e01ab: mov      r8, rax
00000001405e01ae: lea      rdx, [rbp - 0x10]
00000001405e01b2: lea      rcx, [rsp + 0x70]
00000001405e01b7: call     0x141280a10
00000001405e01bc: mov      rdx, rax
00000001405e01bf: lea      rcx, [rsp + 0x70]
00000001405e01c4: call     0x14127e710
00000001405e01c9: movss    xmm1, dword ptr [rbx + 0x160]
00000001405e01d1: lea      rcx, [rsp + 0x40]
00000001405e01d6: movaps   xmm3, xmm1
00000001405e01d9: movaps   xmm2, xmm1
00000001405e01dc: call     0x141281b10
00000001405e01e1: lea      rdx, [rbp + 0x30]
00000001405e01e5: lea      rcx, [rsp + 0x70]
00000001405e01ea: call     0x141283aa0
00000001405e01ef: mov      rdx, rax
00000001405e01f2: lea      r8, [rsp + 0x40]
00000001405e01f7: lea      rcx, [rbp - 0x10]
00000001405e01fb: call     0x1411aee30
00000001405e0200: mov      rdx, rax
00000001405e0203: lea      rcx, [rbp - 0x50]
00000001405e0207: call     0x14127e5e0
00000001405e020c: lea      rdx, [rbp - 0x50]
00000001405e0210: lea      rcx, [rsp + 0x70]
00000001405e0215: call     0x14127e710
00000001405e021a: mov      rcx, qword ptr [rbx + 0x140]
00000001405e0221: lea      rdx, [rsp + 0x70]
00000001405e0226: mov      rax, qword ptr [rcx]
00000001405e0229: call     qword ptr [rax + 0x48]
00000001405e022c: mov      rcx, qword ptr [rbx + 0x140]
00000001405e0233: mov      edx, edi
00000001405e0235: mov      rax, qword ptr [rcx]
00000001405e0238: call     qword ptr [rax + 0x30]
00000001405e023b: movss    xmm1, dword ptr [rbx + 0x160]
00000001405e0243: lea      rcx, [rsp + 0x50]
00000001405e0248: movaps   xmm3, xmm1
00000001405e024b: movaps   xmm2, xmm1
00000001405e024e: call     0x1411ab440
00000001405e0253: mov      rcx, qword ptr [rbx + 0x140]
00000001405e025a: lea      rdx, [rsp + 0x50]
00000001405e025f: call     0x1412baf40
00000001405e0264: mov      rcx, qword ptr [rbx + 0x140]
00000001405e026b: mov      rax, qword ptr [rcx]
00000001405e026e: call     qword ptr [rax + 0x38]
00000001405e0271: mov      rcx, rbx
00000001405e0274: call     0x1405e6750
00000001405e0279: mov      rcx, qword ptr [rbx + 0x688]
00000001405e0280: test     rcx, rcx
00000001405e0283: je       0x1405e02e8
00000001405e0285: mov      rax, qword ptr [rbx + 0x140]
00000001405e028c: mov      edx, dword ptr [rax + 0x3c]
00000001405e028f: call     0x140ad2f20
00000001405e0294: call     0x1400bfa80
00000001405e0299: lea      rdx, [rsp + 0x60]
00000001405e029e: lea      rcx, [rsp + 0x70]
00000001405e02a3: movsd    xmm0, qword ptr [rax]
00000001405e02a7: movsd    qword ptr [rsp + 0x20], xmm0
00000001405e02ad: mov      eax, dword ptr [rax + 8]
00000001405e02b0: mov      dword ptr [rsp + 0x28], eax
00000001405e02b4: call     0x141283ee0
00000001405e02b9: lea      rdx, [rsp + 0x60]
00000001405e02be: lea      rcx, [rsp + 0x20]
00000001405e02c3: call     0x140af0fc0
00000001405e02c8: test     eax, eax
00000001405e02ca: je       0x1405e02e8
00000001405e02cc: mov      rax, qword ptr [rbx + 0x140]
00000001405e02d3: lea      rdx, [rsp + 0x20]
00000001405e02d8: mov      rcx, qword ptr [rbx + 0x688]
00000001405e02df: mov      r8d, dword ptr [rax + 0x3c]
00000001405e02e3: call     0x140ad2f30
00000001405e02e8: mov      rcx, qword ptr [rbp + 0x70]
00000001405e02ec: xor      rcx, rsp
00000001405e02ef: call     0x141441dc0
00000001405e02f4: lea      r11, [rsp + 0x180]
00000001405e02fc: mov      rbx, qword ptr [r11 + 0x20]
00000001405e0300: mov      rdi, qword ptr [r11 + 0x28]
00000001405e0304: mov      rsp, r11
00000001405e0307: pop      rbp
00000001405e0308: ret      
