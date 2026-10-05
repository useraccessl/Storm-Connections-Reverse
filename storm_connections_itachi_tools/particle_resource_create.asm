00000001413866f0: mov      qword ptr [rsp + 0x10], rbx
00000001413866f5: mov      qword ptr [rsp + 0x18], rbp
00000001413866fa: push     rsi
00000001413866fb: push     rdi
00000001413866fc: push     r12
00000001413866fe: push     r14
0000000141386700: push     r15
0000000141386702: sub      rsp, 0x20
0000000141386706: mov      r12, rdx
0000000141386709: mov      rsi, rcx
000000014138670c: xor      ebp, ebp
000000014138670e: mov      r14d, ebp
0000000141386711: cmp      dword ptr [rcx + 0x14], 6
0000000141386715: jne      0x141386860
000000014138671b: mov      r14, qword ptr [rcx]
000000014138671e: test     r14, r14
0000000141386721: je       0x141386860
0000000141386727: mov      rdx, r14
000000014138672a: lea      rcx, [rip + 0x8382bff]
0000000141386731: call     0x141293820
0000000141386736: mov      r15, rax
0000000141386739: test     rax, rax
000000014138673c: je       0x141386860
0000000141386742: mov      rcx, rax
0000000141386745: call     0x1412fc350
000000014138674a: mov      rdi, rax
000000014138674d: test     rax, rax
0000000141386750: je       0x141386860
0000000141386756: mov      rdx, qword ptr [r14]
0000000141386759: mov      rcx, r14
000000014138675c: call     qword ptr [rdx + 0x30]
000000014138675f: mov      rdx, qword ptr [r14]
0000000141386762: lea      rcx, [rip + 0xd39147]
0000000141386769: cmp      rax, rcx
000000014138676c: mov      rcx, r14
000000014138676f: jne      0x1413867a3
0000000141386771: call     qword ptr [rdx + 0x18]
0000000141386774: mov      rbx, rax
0000000141386777: mov      rdx, qword ptr [r14]
000000014138677a: mov      rcx, r14
000000014138677d: call     qword ptr [rdx + 0x30]
0000000141386780: mov      rdx, rax
0000000141386783: mov      r8, rbx
0000000141386786: mov      rcx, rdi
0000000141386789: call     0x141287ca0
000000014138678e: test     rax, rax
0000000141386791: je       0x141386858
0000000141386797: mov      dword ptr [rsi + 0x14], 5
000000014138679e: jmp      0x141386855
00000001413867a3: call     qword ptr [rdx + 0x30]
00000001413867a6: mov      rdx, qword ptr [r14]
00000001413867a9: lea      rcx, [rip + 0xd390e8]
00000001413867b0: cmp      rax, rcx
00000001413867b3: mov      rcx, r14
00000001413867b6: jne      0x1413867e3
00000001413867b8: call     qword ptr [rdx + 0x18]
00000001413867bb: mov      rbx, rax
00000001413867be: mov      rdx, qword ptr [r14]
00000001413867c1: mov      rcx, r14
00000001413867c4: call     qword ptr [rdx + 0x30]
00000001413867c7: mov      rdx, rax
00000001413867ca: mov      r8, rbx
00000001413867cd: mov      rcx, rdi
00000001413867d0: call     0x141287ca0
00000001413867d5: test     rax, rax
00000001413867d8: je       0x141386858
00000001413867da: mov      dword ptr [rsi + 0x14], 2
00000001413867e1: jmp      0x141386855
00000001413867e3: call     qword ptr [rdx + 0x30]
00000001413867e6: mov      rdx, qword ptr [r14]
00000001413867e9: lea      rcx, [rip + 0xd39270]
00000001413867f0: cmp      rax, rcx
00000001413867f3: mov      rcx, r14
00000001413867f6: jne      0x141386823
00000001413867f8: call     qword ptr [rdx + 0x18]
00000001413867fb: mov      rbx, rax
00000001413867fe: mov      rdx, qword ptr [r14]
0000000141386801: mov      rcx, r14
0000000141386804: call     qword ptr [rdx + 0x30]
0000000141386807: mov      rdx, rax
000000014138680a: mov      r8, rbx
000000014138680d: mov      rcx, rdi
0000000141386810: call     0x141287ca0
0000000141386815: test     rax, rax
0000000141386818: je       0x141386858
000000014138681a: mov      dword ptr [rsi + 0x14], 1
0000000141386821: jmp      0x141386855
0000000141386823: call     qword ptr [rdx + 0x30]
0000000141386826: lea      rcx, [rip + 0xd390b3]
000000014138682d: cmp      rax, rcx
0000000141386830: jne      0x141386858
0000000141386832: mov      rax, qword ptr [r14]
0000000141386835: mov      rcx, r14
0000000141386838: call     qword ptr [rax + 0x18]
000000014138683b: mov      rbx, rax
000000014138683e: mov      rdx, qword ptr [r14]
0000000141386841: mov      rcx, r14
0000000141386844: call     qword ptr [rdx + 0x30]
0000000141386847: mov      rdx, rax
000000014138684a: mov      r8, rbx
000000014138684d: mov      rcx, rdi
0000000141386850: call     0x141287ca0
0000000141386855: mov      qword ptr [rsi], rax
0000000141386858: mov      dword ptr [r15 + 0x6c], 1
0000000141386860: cmp      qword ptr [rsi], rbp
0000000141386863: je       0x141386b4d
0000000141386869: cmp      dword ptr [rsi + 0x14], 6
000000014138686d: je       0x141386b4d
0000000141386873: mov      r8d, 0x9c
0000000141386879: lea      rdx, [rip + 0x81dbf0]
0000000141386880: mov      ecx, 0x230
0000000141386885: call     0x141272600
000000014138688a: mov      r15, rax
000000014138688d: mov      qword ptr [rsp + 0x50], rax
0000000141386892: test     rax, rax
0000000141386895: je       0x1413869a9
000000014138689b: mov      rcx, rax
000000014138689e: call     0x14130aa70
00000001413868a3: nop      
00000001413868a4: lea      rax, [rip + 0x81dafd]
00000001413868ab: mov      qword ptr [r15], rax
00000001413868ae: lea      rdi, [r15 + 0x1d0]
00000001413868b5: xorps    xmm3, xmm3
00000001413868b8: xorps    xmm2, xmm2
00000001413868bb: xorps    xmm1, xmm1
00000001413868be: mov      rcx, rdi
00000001413868c1: call     0x1411ab440
00000001413868c6: lea      rcx, [rdi + 0xc]
00000001413868ca: xorps    xmm3, xmm3
00000001413868cd: xorps    xmm2, xmm2
00000001413868d0: xorps    xmm1, xmm1
00000001413868d3: call     0x1411ab440
00000001413868d8: lea      rcx, [rdi + 0x18]
00000001413868dc: xorps    xmm3, xmm3
00000001413868df: xorps    xmm2, xmm2
00000001413868e2: xorps    xmm1, xmm1
00000001413868e5: call     0x1411ab440
00000001413868ea: lea      rcx, [rdi + 0x24]
00000001413868ee: xorps    xmm3, xmm3
00000001413868f1: xorps    xmm2, xmm2
00000001413868f4: xorps    xmm1, xmm1
00000001413868f7: call     0x1411ab440
00000001413868fc: xorps    xmm3, xmm3
00000001413868ff: xorps    xmm2, xmm2
0000000141386902: xorps    xmm1, xmm1
0000000141386905: lea      rcx, [r15 + 0x20c]
000000014138690c: call     0x1411ab440
0000000141386911: mov      dword ptr [r15 + 0x21c], 0xffffffff
000000014138691c: mov      dword ptr [r15 + 0x220], ebp
0000000141386923: call     0x1400bfa80
0000000141386928: movsd    xmm0, qword ptr [rax]
000000014138692c: movsd    qword ptr [rdi], xmm0
0000000141386930: mov      eax, dword ptr [rax + 8]
0000000141386933: mov      dword ptr [rdi + 8], eax
0000000141386936: call     0x1400bfa80
000000014138693b: movsd    xmm0, qword ptr [rax]
000000014138693f: movsd    qword ptr [rdi + 0xc], xmm0
0000000141386944: mov      eax, dword ptr [rax + 8]
0000000141386947: mov      dword ptr [rdi + 0x14], eax
000000014138694a: call     0x1400bfa80
000000014138694f: movsd    xmm0, qword ptr [rax]
0000000141386953: movsd    qword ptr [rdi + 0x18], xmm0
0000000141386958: mov      eax, dword ptr [rax + 8]
000000014138695b: mov      dword ptr [rdi + 0x20], eax
000000014138695e: call     0x140298a20
0000000141386963: movsd    xmm0, qword ptr [rax]
0000000141386967: movsd    qword ptr [rdi + 0x24], xmm0
000000014138696c: mov      eax, dword ptr [rax + 8]
000000014138696f: mov      dword ptr [rdi + 0x2c], eax
0000000141386972: mov      dword ptr [rdi + 0x34], 0x3f800000
0000000141386979: mov      dword ptr [rdi + 0x38], 0x3f800000
0000000141386980: call     0x1400bfa80
0000000141386985: movsd    xmm0, qword ptr [rax]
0000000141386989: movsd    qword ptr [r15 + 0x20c], xmm0
0000000141386992: mov      eax, dword ptr [rax + 8]
0000000141386995: mov      dword ptr [r15 + 0x214], eax
000000014138699c: mov      dword ptr [r15 + 0x218], 1
00000001413869a7: jmp      0x1413869ac
00000001413869a9: mov      r15, rbp
00000001413869ac: mov      qword ptr [r15 + 0x1a8], r12
00000001413869b3: mov      ecx, dword ptr [rsi + 0x14]
00000001413869b6: sub      ecx, 1
00000001413869b9: je       0x141386ab3
00000001413869bf: sub      ecx, 1
00000001413869c2: je       0x141386a39
00000001413869c4: sub      ecx, 1
00000001413869c7: je       0x1413869f9
00000001413869c9: sub      ecx, 1
00000001413869cc: je       0x1413869f1
00000001413869ce: cmp      ecx, 1
00000001413869d1: jne      0x141386b28
00000001413869d7: mov      rdx, qword ptr [rsi]
00000001413869da: mov      rcx, r15
00000001413869dd: call     0x14130bbf0
00000001413869e2: cmp      dword ptr [rsi + 0x14], 5
00000001413869e6: jne      0x141386b28
00000001413869ec: jmp      0x141386b1c
00000001413869f1: mov      r9d, 1
00000001413869f7: jmp      0x1413869fc
00000001413869f9: xor      r9d, r9d
00000001413869fc: mov      r8d, dword ptr [rsi + 0x10]
0000000141386a00: mov      rdx, qword ptr [rsi]
0000000141386a03: mov      rcx, r15
0000000141386a06: call     0x14130bd20
0000000141386a0b: mov      edx, dword ptr [rsi + 0x14]
0000000141386a0e: lea      eax, [rdx - 3]
0000000141386a11: cmp      eax, 1
0000000141386a14: ja       0x141386b28
0000000141386a1a: mov      rcx, qword ptr [rsi]
0000000141386a1d: test     rcx, rcx
0000000141386a20: je       0x141386b28
0000000141386a26: lea      eax, [rdx - 3]
0000000141386a29: cmp      eax, 1
0000000141386a2c: cmova    rcx, rbp
0000000141386a30: mov      r14, qword ptr [rcx + 8]
0000000141386a34: jmp      0x141386b28
0000000141386a39: mov      rdx, qword ptr [rsi]
0000000141386a3c: mov      rcx, r15
0000000141386a3f: call     0x14130bb20
0000000141386a44: test     eax, eax
0000000141386a46: je       0x141386aab
0000000141386a48: mov      r8d, 0xb8
0000000141386a4e: lea      rdx, [rip + 0x81da1b]
0000000141386a55: lea      ecx, [r8 - 0x68]
0000000141386a59: call     0x141272600
0000000141386a5e: mov      qword ptr [rsp + 0x50], rax
0000000141386a63: test     rax, rax
0000000141386a66: je       0x141386a82
0000000141386a68: cmp      dword ptr [rsi + 0x14], 2
0000000141386a6c: jne      0x141386a71
0000000141386a6e: mov      rbp, qword ptr [rsi]
0000000141386a71: mov      r8, rbp
0000000141386a74: mov      rdx, r15
0000000141386a77: mov      rcx, rax
0000000141386a7a: call     0x14139b7f0
0000000141386a7f: mov      rbp, rax
0000000141386a82: call     0x1400b07c0
0000000141386a87: mov      r9, qword ptr [rax]
0000000141386a8a: xor      r8d, r8d
0000000141386a8d: mov      rdx, rbp
0000000141386a90: mov      rcx, rax
0000000141386a93: call     qword ptr [r9 + 0xb8]
0000000141386a9a: mov      rax, qword ptr [rbp]
0000000141386a9e: mov      rcx, rbp
0000000141386aa1: call     qword ptr [rax + 0x60]
0000000141386aa4: mov      dword ptr [r15 + 0x21c], eax
0000000141386aab: cmp      dword ptr [rsi + 0x14], 2
0000000141386aaf: jne      0x141386b28
0000000141386ab1: jmp      0x141386b1c
0000000141386ab3: mov      rdx, qword ptr [rsi]
0000000141386ab6: mov      rcx, r15
0000000141386ab9: call     0x14130bca0
0000000141386abe: test     eax, eax
0000000141386ac0: je       0x141386b1c
0000000141386ac2: mov      r8d, 0xa9
0000000141386ac8: lea      rdx, [rip + 0x81d9a1]
0000000141386acf: lea      ecx, [r8 - 0x59]
0000000141386ad3: call     0x141272600
0000000141386ad8: mov      qword ptr [rsp + 0x50], rax
0000000141386add: test     rax, rax
0000000141386ae0: je       0x141386af3
0000000141386ae2: mov      r8, qword ptr [rsi]
0000000141386ae5: mov      rdx, r15
0000000141386ae8: mov      rcx, rax
0000000141386aeb: call     0x14139b840
0000000141386af0: mov      rbp, rax
0000000141386af3: call     0x1400b07c0
0000000141386af8: mov      r9, qword ptr [rax]
0000000141386afb: xor      r8d, r8d
0000000141386afe: mov      rdx, rbp
0000000141386b01: mov      rcx, rax
0000000141386b04: call     qword ptr [r9 + 0xb8]
0000000141386b0b: mov      rax, qword ptr [rbp]
0000000141386b0f: mov      rcx, rbp
0000000141386b12: call     qword ptr [rax + 0x60]
0000000141386b15: mov      dword ptr [r15 + 0x21c], eax
0000000141386b1c: mov      rax, qword ptr [rsi]
0000000141386b1f: test     rax, rax
0000000141386b22: je       0x141386b28
0000000141386b24: mov      r14, qword ptr [rax + 8]
0000000141386b28: test     r14, r14
0000000141386b2b: je       0x141386b48
0000000141386b2d: mov      rdx, r14
0000000141386b30: lea      rcx, [rip + 0x83827f9]
0000000141386b37: call     0x141293820
0000000141386b3c: test     rax, rax
0000000141386b3f: je       0x141386b48
0000000141386b41: mov      dword ptr [rax + 0x6c], 1
0000000141386b48: mov      rax, r15
0000000141386b4b: jmp      0x141386b50
0000000141386b4d: mov      rax, rbp
0000000141386b50: mov      rbx, qword ptr [rsp + 0x58]
0000000141386b55: mov      rbp, qword ptr [rsp + 0x60]
0000000141386b5a: add      rsp, 0x20
0000000141386b5e: pop      r15
0000000141386b60: pop      r14
0000000141386b62: pop      r12
0000000141386b64: pop      rdi
0000000141386b65: pop      rsi
0000000141386b66: ret      
