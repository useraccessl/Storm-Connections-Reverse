0000000141326490: mov      qword ptr [rsp + 0x10], rbx
0000000141326495: mov      qword ptr [rsp + 0x18], rsi
000000014132649a: mov      qword ptr [rsp + 0x20], rdi
000000014132649f: push     rbp
00000001413264a0: push     r12
00000001413264a2: push     r13
00000001413264a4: push     r14
00000001413264a6: push     r15
00000001413264a8: lea      rbp, [rsp - 0x760]
00000001413264b0: sub      rsp, 0x860
00000001413264b7: mov      rax, qword ptr [rip + 0xdbff0a]
00000001413264be: xor      rax, rsp
00000001413264c1: mov      qword ptr [rbp + 0x750], rax
00000001413264c8: mov      r15, rcx
00000001413264cb: mov      r8d, 0x6c
00000001413264d1: lea      rdx, [rip + 0x875e78]
00000001413264d8: mov      ecx, 0x2000
00000001413264dd: call     0x141272e00
00000001413264e2: mov      rbx, rax
00000001413264e5: mov      qword ptr [rsp + 0x38], rax
00000001413264ea: mov      edx, 0x80
00000001413264ef: mov      rcx, rax
00000001413264f2: call     0x141216fb0
00000001413264f7: call     0x141301580
00000001413264fc: lea      rcx, [rbp + 0x4f0]
0000000141326503: call     0x1412b48e0
0000000141326508: nop      
0000000141326509: mov      byte ptr [rbp + 0x748], 2
0000000141326510: mov      r12d, dword ptr [rip + 0x842c6f9]
0000000141326517: mov      edx, 0x342c
000000014132651c: mov      rcx, qword ptr gs:[0x58]
0000000141326525: mov      rax, qword ptr [rcx + r12*8]
0000000141326529: cmp      byte ptr [rdx + rax], 0
000000014132652d: jne      0x141326534
000000014132652f: call     0x141441fb8
0000000141326534: mov      rax, qword ptr gs:[0x58]
000000014132653d: mov      edx, 0x3400
0000000141326542: mov      rcx, qword ptr [rax + r12*8]
0000000141326546: lea      rax, [rbp + 0x4f0]
000000014132654d: mov      qword ptr [rdx + rcx], rax
0000000141326551: cmp      dword ptr [r15 + 0x220], 0
0000000141326559: jne      0x141326b93
000000014132655f: lea      rdi, [rip + 0x86afd2]
0000000141326566: lea      r14, [rip + 0x86afab]
000000014132656d: xor      esi, esi
000000014132656f: movzx    ebx, byte ptr [rsp + 0x30]
0000000141326574: nop      dword ptr [rax]
0000000141326578: nop      dword ptr [rax + rax]
0000000141326580: mov      edx, 1
0000000141326585: lea      rcx, [rsp + 0x60]
000000014132658a: call     0x1412b71d0
000000014132658f: nop      
0000000141326590: lea      rax, [rbp + 0x250]
0000000141326597: mov      qword ptr [rsp + 0x40], rax
000000014132659c: mov      qword ptr [rbp + 0x250], rdi
00000001413265a3: lea      rax, [rbp + 0x270]
00000001413265aa: mov      qword ptr [rsp + 0x48], rax
00000001413265af: lea      rcx, [rbp + 0x270]
00000001413265b6: call     0x141273620
00000001413265bb: mov      qword ptr [rbp + 0x270], r14
00000001413265c2: mov      qword ptr [rbp + 0x288], rsi
00000001413265c9: mov      qword ptr [rbp + 0x290], rsi
00000001413265d0: lea      rcx, [rbp + 0x270]
00000001413265d7: call     0x141273770
00000001413265dc: mov      ecx, eax
00000001413265de: call     0x141273960
00000001413265e3: mov      dword ptr [rsp + 0x20], 0x63
00000001413265eb: lea      r9, [rip + 0x43ac9e]
00000001413265f2: mov      r8, qword ptr [rbp + 0x278]
00000001413265f9: mov      edx, 0x28
00000001413265fe: lea      ecx, [rdx - 0x20]
0000000141326601: call     0x1412734b0
0000000141326606: mov      rdi, rax
0000000141326609: call     0x141273900
000000014132660e: mov      qword ptr [rdi], rdi
0000000141326611: mov      qword ptr [rdi + 8], rdi
0000000141326615: mov      qword ptr [rdi + 0x10], rdi
0000000141326619: mov      word ptr [rdi + 0x18], 0x101
000000014132661f: mov      qword ptr [rbp + 0x288], rdi
0000000141326626: lea      rcx, [rbp + 0x2b0]
000000014132662d: call     0x141312be0
0000000141326632: nop      
0000000141326633: lea      rcx, [rbp + 0x430]
000000014132663a: call     0x141306610
000000014132663f: nop      
0000000141326640: lea      rcx, [rbp + 0x440]
0000000141326647: call     0x1412b9440
000000014132664c: lea      rax, [rip + 0x668215]
0000000141326653: mov      qword ptr [rbp + 0x460], rax
000000014132665a: mov      qword ptr [rbp + 0x468], 0
0000000141326665: lea      rax, [rip + 0x478874]
000000014132666c: mov      qword ptr [rbp + 0x470], rax
0000000141326673: movaps   xmm0, xmmword ptr [rip + 0x43ab16]
000000014132667a: movaps   xmmword ptr [rbp + 0x480], xmm0
0000000141326681: movaps   xmm1, xmm0
0000000141326684: movaps   xmmword ptr [rbp + 0x490], xmm0
000000014132668b: movaps   xmm0, xmmword ptr [rip + 0x4788ee]
0000000141326692: movaps   xmmword ptr [rbp + 0x4a0], xmm0
0000000141326699: movaps   xmm1, xmm0
000000014132669c: movaps   xmmword ptr [rbp + 0x4c0], xmm0
00000001413266a3: mov      dword ptr [rbp + 0x4d0], 0x3f800000
00000001413266ad: lea      rcx, [r15 + 0x268]
00000001413266b4: call     0x1412a7920
00000001413266b9: cmp      qword ptr [r15 + 0x260], 0
00000001413266c1: jne      0x14132670f
00000001413266c3: movzx    r14d, byte ptr [r15 + 0x224]
00000001413266cb: mov      rdi, qword ptr [r15 + 0x2b8]
00000001413266d2: lea      rcx, [rdi + 0x40]
00000001413266d6: call     0x1412a7920
00000001413266db: not      r14b
00000001413266de: movzx    eax, byte ptr [rdi + 0x70]
00000001413266e2: and      r14b, al
00000001413266e5: mov      byte ptr [rdi + 0x70], r14b
00000001413266e9: lea      rcx, [rdi + 0x40]
00000001413266ed: call     0x1412a7990
00000001413266f2: lea      rcx, [r15 + 0x268]
00000001413266f9: call     0x1412a7990
00000001413266fe: lea      rcx, [r15 + 0x298]
0000000141326705: call     0x14120c4f0
000000014132670a: jmp      0x141326b57
000000014132670f: lea      rax, [r15 + 0x240]
0000000141326716: test     rax, rax
0000000141326719: je       0x141326728
000000014132671b: mov      rcx, qword ptr [rax]
000000014132671e: test     rcx, rcx
0000000141326721: je       0x141326728
0000000141326723: mov      rax, qword ptr [rcx]
0000000141326726: jmp      0x14132672b
0000000141326728: mov      rax, rsi
000000014132672b: mov      rcx, qword ptr [rax + 0x10]
000000014132672f: dec      rcx
0000000141326732: and      rcx, qword ptr [r15 + 0x258]
0000000141326739: mov      rax, qword ptr [rax + 8]
000000014132673d: mov      rsi, qword ptr [rax + rcx*8]
0000000141326741: mov      rax, qword ptr [rsi]
0000000141326744: mov      qword ptr [rsp + 0x50], rax
0000000141326749: mov      eax, dword ptr [rsi + 8]
000000014132674c: mov      dword ptr [rsp + 0x58], eax
0000000141326750: mov      eax, dword ptr [rsi + 0xc]
0000000141326753: mov      dword ptr [rsp + 0x5c], eax
0000000141326757: lea      rdx, [rsi + 0x10]
000000014132675b: lea      rcx, [rsp + 0x60]
0000000141326760: call     0x141275600
0000000141326765: movups   xmm0, xmmword ptr [rsi + 0x2c0]
000000014132676c: movaps   xmmword ptr [rbp + 0x210], xmm0
0000000141326773: movups   xmm1, xmmword ptr [rsi + 0x2d0]
000000014132677a: movaps   xmmword ptr [rbp + 0x220], xmm1
0000000141326781: movups   xmm0, xmmword ptr [rsi + 0x2e0]
0000000141326788: movaps   xmmword ptr [rbp + 0x230], xmm0
000000014132678f: movups   xmm1, xmmword ptr [rsi + 0x2f0]
0000000141326796: movaps   xmmword ptr [rbp + 0x240], xmm1
000000014132679d: mov      rax, qword ptr [rsi + 0x310]
00000001413267a4: mov      qword ptr [rbp + 0x260], rax
00000001413267ab: mov      rax, qword ptr [rsi + 0x318]
00000001413267b2: mov      qword ptr [rbp + 0x268], rax
00000001413267b9: lea      r14, [rsi + 0x320]
00000001413267c0: lea      rax, [rbp + 0x270]
00000001413267c7: cmp      rax, r14
00000001413267ca: je       0x141326813
00000001413267cc: mov      rdi, qword ptr [rbp + 0x288]
00000001413267d3: mov      r8, qword ptr [rdi + 8]
00000001413267d7: lea      rdx, [rbp + 0x270]
00000001413267de: lea      rcx, [rbp + 0x288]
00000001413267e5: call     0x1412742b0
00000001413267ea: mov      qword ptr [rdi + 8], rdi
00000001413267ee: mov      qword ptr [rdi], rdi
00000001413267f1: mov      qword ptr [rdi + 0x10], rdi
00000001413267f5: mov      qword ptr [rbp + 0x290], 0
0000000141326800: movzx    r8d, bl
0000000141326804: mov      rdx, r14
0000000141326807: lea      rcx, [rbp + 0x270]
000000014132680e: call     0x141273a10
0000000141326813: movups   xmm0, xmmword ptr [rsi + 0x350]
000000014132681a: movaps   xmmword ptr [rbp + 0x2a0], xmm0
0000000141326821: lea      rax, [rsi + 0x360]
0000000141326828: lea      rcx, [rbp + 0x2b0]
000000014132682f: mov      edx, 3
0000000141326834: nop      dword ptr [rax]
0000000141326838: nop      dword ptr [rax + rax]
0000000141326840: movups   xmm0, xmmword ptr [rax]
0000000141326843: movups   xmmword ptr [rcx], xmm0
0000000141326846: movups   xmm1, xmmword ptr [rax + 0x10]
000000014132684a: movups   xmmword ptr [rcx + 0x10], xmm1
000000014132684e: movups   xmm0, xmmword ptr [rax + 0x20]
0000000141326852: movups   xmmword ptr [rcx + 0x20], xmm0
0000000141326856: movups   xmm1, xmmword ptr [rax + 0x30]
000000014132685a: movups   xmmword ptr [rcx + 0x30], xmm1
000000014132685e: movups   xmm0, xmmword ptr [rax + 0x40]
0000000141326862: movups   xmmword ptr [rcx + 0x40], xmm0
0000000141326866: movups   xmm1, xmmword ptr [rax + 0x50]
000000014132686a: movups   xmmword ptr [rcx + 0x50], xmm1
000000014132686e: movups   xmm0, xmmword ptr [rax + 0x60]
0000000141326872: movups   xmmword ptr [rcx + 0x60], xmm0
0000000141326876: lea      rcx, [rcx + 0x80]
000000014132687d: movups   xmm1, xmmword ptr [rax + 0x70]
0000000141326881: movups   xmmword ptr [rcx - 0x10], xmm1
0000000141326885: lea      rax, [rax + 0x80]
000000014132688c: sub      rdx, 1
0000000141326890: jne      0x141326840
0000000141326892: movss    xmm0, dword ptr [rsi + 0x4e0]
000000014132689a: movss    dword ptr [rbp + 0x430], xmm0
00000001413268a2: movups   xmm1, xmmword ptr [rsi + 0x4f0]
00000001413268a9: movaps   xmmword ptr [rbp + 0x440], xmm1
00000001413268b0: movups   xmm0, xmmword ptr [rsi + 0x500]
00000001413268b7: movaps   xmmword ptr [rbp + 0x450], xmm0
00000001413268be: movss    xmm1, dword ptr [rsi + 0x518]
00000001413268c6: movss    dword ptr [rbp + 0x468], xmm1
00000001413268ce: movss    xmm0, dword ptr [rsi + 0x51c]
00000001413268d6: movss    dword ptr [rbp + 0x46c], xmm0
00000001413268de: movups   xmm1, xmmword ptr [rsi + 0x530]
00000001413268e5: movaps   xmmword ptr [rbp + 0x480], xmm1
00000001413268ec: movups   xmm0, xmmword ptr [rsi + 0x540]
00000001413268f3: movaps   xmmword ptr [rbp + 0x490], xmm0
00000001413268fa: movsd    xmm1, qword ptr [rsi + 0x550]
0000000141326902: movsd    qword ptr [rbp + 0x4a0], xmm1
000000014132690a: movss    xmm0, dword ptr [rsi + 0x558]
0000000141326912: movss    dword ptr [rbp + 0x4a8], xmm0
000000014132691a: movss    xmm1, dword ptr [rsi + 0x55c]
0000000141326922: movss    dword ptr [rbp + 0x4ac], xmm1
000000014132692a: movups   xmm0, xmmword ptr [rsi + 0x560]
0000000141326931: movaps   xmmword ptr [rbp + 0x4b0], xmm0
0000000141326938: movups   xmm1, xmmword ptr [rsi + 0x570]
000000014132693f: movaps   xmmword ptr [rbp + 0x4c0], xmm1
0000000141326946: movups   xmm0, xmmword ptr [rsi + 0x580]
000000014132694d: movaps   xmmword ptr [rbp + 0x4d0], xmm0
0000000141326954: mov      eax, dword ptr [rsi + 0x590]
000000014132695a: mov      dword ptr [rbp + 0x4e0], eax
0000000141326960: mov      eax, dword ptr [rsi + 0x594]
0000000141326966: mov      dword ptr [rbp + 0x4e4], eax
000000014132696c: lea      rcx, [r15 + 0x268]
0000000141326973: call     0x1412a7990
0000000141326978: mov      ecx, dword ptr [rsp + 0x5c]
000000014132697c: call     0x141273960
0000000141326981: lea      rdx, [rbp + 0x250]
0000000141326988: lea      rcx, [rbp + 0x4f0]
000000014132698f: call     0x1412b6950
0000000141326994: mov      rax, qword ptr gs:[0x58]
000000014132699d: mov      rcx, qword ptr [rax + r12*8]
00000001413269a1: mov      eax, 0x342c
00000001413269a6: cmp      byte ptr [rax + rcx], 0
00000001413269aa: jne      0x1413269b1
00000001413269ac: call     0x141441fb8
00000001413269b1: mov      rax, qword ptr gs:[0x58]
00000001413269ba: mov      edx, 0x3408
00000001413269bf: mov      rcx, qword ptr [rax + r12*8]
00000001413269c3: lea      rax, [rsp + 0x60]
00000001413269c8: mov      qword ptr [rdx + rcx], rax
00000001413269cc: lea      rcx, [rbp + 0x210]
00000001413269d3: call     0x141218270
00000001413269d8: mov      ecx, dword ptr [rsp + 0x58]
00000001413269dc: test     ecx, ecx
00000001413269de: je       0x141326a45
00000001413269e0: sub      ecx, 1
00000001413269e3: je       0x141326a36
00000001413269e5: cmp      ecx, 1
00000001413269e8: jne      0x141326aea
00000001413269ee: mov      rdi, qword ptr [rsp + 0x50]
00000001413269f3: call     0x14127afe0
00000001413269f8: xor      r8d, r8d
00000001413269fb: mov      rdx, rdi
00000001413269fe: mov      rcx, rax
0000000141326a01: call     0x141279fb0
0000000141326a06: mov      rcx, qword ptr [rsp + 0x50]
0000000141326a0b: call     0x141300370
0000000141326a10: mov      rcx, qword ptr [rsp + 0x50]
0000000141326a15: test     rcx, rcx
0000000141326a18: je       0x141326aea
0000000141326a1e: mov      rax, qword ptr [rcx]
0000000141326a21: mov      edx, 1
0000000141326a26: call     qword ptr [rax]
0000000141326a28: mov      qword ptr [rsp + 0x50], 0
0000000141326a31: jmp      0x141326aea
0000000141326a36: mov      rcx, qword ptr [rsp + 0x50]
0000000141326a3b: call     0x141325a50
0000000141326a40: jmp      0x141326aea
0000000141326a45: mov      edx, dword ptr [rbp + 0x4e4]
0000000141326a4b: mov      rcx, qword ptr [rsp + 0x50]
0000000141326a50: call     0x141325090
0000000141326a55: mov      rsi, qword ptr [rsp + 0x50]
0000000141326a5a: mov      rdi, qword ptr [r15 + 0x2b8]
0000000141326a61: lea      r14, [rdi + 0xc8]
0000000141326a68: mov      rcx, r14
0000000141326a6b: call     0x1412a7920
0000000141326a70: lea      r12, [rdi + 0x78]
0000000141326a74: mov      rcx, qword ptr [rdi + 0x90]
0000000141326a7b: mov      rax, qword ptr [rcx + 8]
0000000141326a7f: mov      rdx, rcx
0000000141326a82: cmp      byte ptr [rax + 0x19], 0
0000000141326a86: jne      0x141326aa0
0000000141326a88: cmp      qword ptr [rax + 0x20], rsi
0000000141326a8c: jae      0x141326a94
0000000141326a8e: mov      rax, qword ptr [rax + 0x10]
0000000141326a92: jmp      0x141326a9a
0000000141326a94: mov      rdx, rax
0000000141326a97: mov      rax, qword ptr [rax]
0000000141326a9a: cmp      byte ptr [rax + 0x19], 0
0000000141326a9e: je       0x141326a88
0000000141326aa0: cmp      byte ptr [rdx + 0x19], 0
0000000141326aa4: jne      0x141326aac
0000000141326aa6: cmp      rsi, qword ptr [rdx + 0x20]
0000000141326aaa: jae      0x141326aaf
0000000141326aac: mov      rdx, rcx
0000000141326aaf: lea      rcx, [rdi + 0x90]
0000000141326ab6: call     0x141328610
0000000141326abb: mov      rdi, rax
0000000141326abe: mov      rcx, r12
0000000141326ac1: call     0x141273770
0000000141326ac6: mov      ecx, eax
0000000141326ac8: call     0x141273960
0000000141326acd: mov      rcx, rdi
0000000141326ad0: call     0x1412732b0
0000000141326ad5: call     0x141273900
0000000141326ada: nop      
0000000141326adb: mov      rcx, r14
0000000141326ade: call     0x1412a7990
0000000141326ae3: mov      r12d, dword ptr [rip + 0x842c126]
0000000141326aea: call     0x141273900
0000000141326aef: lea      rcx, [r15 + 0x268]
0000000141326af6: call     0x1412a7920
0000000141326afb: mov      rdi, qword ptr [r15 + 0x250]
0000000141326b02: dec      rdi
0000000141326b05: and      rdi, qword ptr [r15 + 0x258]
0000000141326b0c: mov      rax, qword ptr [r15 + 0x248]
0000000141326b13: mov      rdi, qword ptr [rax + rdi*8]
0000000141326b17: lea      rcx, [rdi + 0x300]
0000000141326b1e: call     0x141275160
0000000141326b23: lea      rcx, [rdi + 0x10]
0000000141326b27: call     0x1412b7490
0000000141326b2c: sub      qword ptr [r15 + 0x260], 1
0000000141326b34: jne      0x141326b43
0000000141326b36: mov      qword ptr [r15 + 0x258], 0
0000000141326b41: jmp      0x141326b4a
0000000141326b43: inc      qword ptr [r15 + 0x258]
0000000141326b4a: lea      rcx, [r15 + 0x268]
0000000141326b51: call     0x1412a7990
0000000141326b56: nop      
0000000141326b57: lea      rcx, [rbp + 0x250]
0000000141326b5e: call     0x141275160
0000000141326b63: lea      rcx, [rsp + 0x60]
0000000141326b68: call     0x1412b7490
0000000141326b6d: cmp      dword ptr [r15 + 0x220], 0
0000000141326b75: mov      esi, 0
0000000141326b7a: lea      rdi, [rip + 0x86a9b7]
0000000141326b81: lea      r14, [rip + 0x86a990]
0000000141326b88: je       0x141326580
0000000141326b8e: mov      rbx, qword ptr [rsp + 0x38]
0000000141326b93: test     rbx, rbx
0000000141326b96: je       0x141326ba0
0000000141326b98: mov      rcx, rbx
0000000141326b9b: call     0x141272e20
0000000141326ba0: call     0x141301590
0000000141326ba5: nop      
0000000141326ba6: lea      rcx, [rbp + 0x4f0]
0000000141326bad: call     0x1412b4da0
0000000141326bb2: mov      rcx, qword ptr [rbp + 0x750]
0000000141326bb9: xor      rcx, rsp
0000000141326bbc: call     0x141441dc0
0000000141326bc1: lea      r11, [rsp + 0x860]
0000000141326bc9: mov      rbx, qword ptr [r11 + 0x38]
0000000141326bcd: mov      rsi, qword ptr [r11 + 0x40]
0000000141326bd1: mov      rdi, qword ptr [r11 + 0x48]
0000000141326bd5: mov      rsp, r11
0000000141326bd8: pop      r15
0000000141326bda: pop      r14
0000000141326bdc: pop      r13
0000000141326bde: pop      r12
0000000141326be0: pop      rbp
0000000141326be1: ret      
