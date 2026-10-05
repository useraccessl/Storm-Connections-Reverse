00000001405eae00: mov      qword ptr [rsp + 0x10], rbx
00000001405eae05: push     rbp
00000001405eae06: push     rsi
00000001405eae07: push     rdi
00000001405eae08: push     r12
00000001405eae0a: push     r13
00000001405eae0c: push     r14
00000001405eae0e: push     r15
00000001405eae10: lea      rbp, [rsp - 7]
00000001405eae15: sub      rsp, 0x100
00000001405eae1c: mov      rax, qword ptr [rip + 0x1afb5a5]
00000001405eae23: xor      rax, rsp
00000001405eae26: mov      qword ptr [rbp - 9], rax
00000001405eae2a: mov      dword ptr [rsp + 0x30], r9d
00000001405eae2f: mov      r12d, r8d
00000001405eae32: mov      dword ptr [rsp + 0x40], edx
00000001405eae36: mov      rbx, rcx
00000001405eae39: mov      qword ptr [rbp - 0x71], rcx
00000001405eae3d: mov      r15, qword ptr [rbp + 0x77]
00000001405eae41: mov      qword ptr [rsp + 0x38], r15
00000001405eae46: mov      qword ptr [rbp - 0x39], rcx
00000001405eae4a: mov      rax, qword ptr [rcx]
00000001405eae4d: call     qword ptr [rax + 8]
00000001405eae50: nop      
00000001405eae51: mov      edx, r12d
00000001405eae54: mov      rcx, qword ptr [rip + 0x1bec63d]
00000001405eae5b: call     0x140a63f90
00000001405eae60: mov      rsi, rax
00000001405eae63: mov      qword ptr [rsp + 0x50], rax
00000001405eae68: test     rax, rax
00000001405eae6b: jne      0x1405eae92
00000001405eae6d: lea      rcx, [rip + 0x12a383c]
00000001405eae74: call     0x14127bf80
00000001405eae79: mov      dword ptr [rbx + 0x3a8], 1
00000001405eae83: mov      rax, qword ptr [rbx]
00000001405eae86: mov      rcx, rbx
00000001405eae89: call     qword ptr [rax + 0x10]
00000001405eae8c: nop      
00000001405eae8d: jmp      0x1405eba33
00000001405eae92: mov      rax, qword ptr [rbp + 0x67]
00000001405eae96: movsd    xmm0, qword ptr [rax]
00000001405eae9a: movsd    qword ptr [rsp + 0x78], xmm0
00000001405eaea0: mov      eax, dword ptr [rax + 8]
00000001405eaea3: mov      dword ptr [rbp - 0x79], eax
00000001405eaea6: mov      rax, qword ptr [rbp + 0x6f]
00000001405eaeaa: movsd    xmm0, qword ptr [rax]
00000001405eaeae: movsd    qword ptr [rsp + 0x58], xmm0
00000001405eaeb4: mov      r13d, dword ptr [rax + 8]
00000001405eaeb8: cmp      dword ptr [rbx + 0x250], 0
00000001405eaebf: je       0x1405eaf0e
00000001405eaec1: mov      edx, dword ptr [rbx + 0x254]
00000001405eaec7: cmp      edx, dword ptr [rip + 0x158d05f]
00000001405eaecd: je       0x1405eaf0e
00000001405eaecf: mov      rcx, qword ptr [rip + 0x1bec5ca]
00000001405eaed6: call     0x1400c2dd0
00000001405eaedb: test     rax, rax
00000001405eaede: je       0x1405eaf0e
00000001405eaee0: mov      rcx, qword ptr [rax + 0x140]
00000001405eaee7: test     rcx, rcx
00000001405eaeea: je       0x1405eaf0e
00000001405eaeec: call     0x1412a3bf0
00000001405eaef1: lea      rdx, [rsp + 0x68]
00000001405eaef6: mov      rcx, rax
00000001405eaef9: call     0x141283ee0
00000001405eaefe: movsd    xmm0, qword ptr [rax]
00000001405eaf02: movsd    qword ptr [rsp + 0x78], xmm0
00000001405eaf08: mov      eax, dword ptr [rax + 8]
00000001405eaf0b: mov      dword ptr [rbp - 0x79], eax
00000001405eaf0e: mov      eax, dword ptr [rbx + 0x148]
00000001405eaf14: mov      r14, qword ptr [rsi + rax*8 + 0x360]
00000001405eaf1c: test     r14, r14
00000001405eaf1f: je       0x1405eafce
00000001405eaf25: lea      rax, [r14 + 0x18]
00000001405eaf29: mov      qword ptr [rbp - 0x31], rax
00000001405eaf2d: lea      rax, [r14 + 0x38]
00000001405eaf31: mov      qword ptr [rbp - 0x29], rax
00000001405eaf35: lea      rax, [r14 + 0x58]
00000001405eaf39: mov      qword ptr [rbp - 0x21], rax
00000001405eaf3d: lea      rax, [r14 + 0x78]
00000001405eaf41: mov      qword ptr [rbp - 0x19], rax
00000001405eaf45: lea      rax, [r14 + 0x98]
00000001405eaf4c: mov      qword ptr [rbp - 0x11], rax
00000001405eaf50: lea      rdi, [rbx + 0x118]
00000001405eaf57: lea      r15, [rbp - 0x31]
00000001405eaf5b: sub      r15, rbx
00000001405eaf5e: mov      esi, 5
00000001405eaf63: cmp      qword ptr [rdi], 0
00000001405eaf67: jne      0x1405eafba
00000001405eaf69: mov      rcx, qword ptr [r15 + rdi - 0x118]
00000001405eaf71: mov      rax, 0xffffffffffffffff
00000001405eaf78: nop      dword ptr [rax + rax]
00000001405eaf80: inc      rax
00000001405eaf83: cmp      byte ptr [rcx + rax], 0
00000001405eaf87: jne      0x1405eaf80
00000001405eaf89: test     eax, eax
00000001405eaf8b: je       0x1405eafba
00000001405eaf8d: mov      r8d, 0x1af
00000001405eaf93: lea      rdx, [rip + 0x12a3696]
00000001405eaf9a: mov      ecx, 0x88
00000001405eaf9f: call     0x141272600
00000001405eafa4: mov      qword ptr [rsp + 0x68], rax
00000001405eafa9: test     rax, rax
00000001405eafac: je       0x1405eafb7
00000001405eafae: mov      rcx, rax
00000001405eafb1: call     0x140a60a90
00000001405eafb6: nop      
00000001405eafb7: mov      qword ptr [rdi], rax
00000001405eafba: add      rdi, 8
00000001405eafbe: sub      rsi, 1
00000001405eafc2: jne      0x1405eaf63
00000001405eafc4: mov      r15, qword ptr [rsp + 0x38]
00000001405eafc9: mov      rsi, qword ptr [rsp + 0x50]
00000001405eafce: mov      eax, dword ptr [rsp + 0x40]
00000001405eafd2: mov      dword ptr [rbx + 0x90], eax
00000001405eafd8: mov      eax, dword ptr [rsp + 0x30]
00000001405eafdc: mov      dword ptr [rbx + 0x108], eax
00000001405eafe2: mov      dword ptr [rbx + 0x10c], r12d
00000001405eafe9: lea      rdx, [rsp + 0x78]
00000001405eafee: mov      rcx, rbx
00000001405eaff1: call     0x1410a9400
00000001405eaff6: movsd    xmm0, qword ptr [rsp + 0x58]
00000001405eaffc: movsd    qword ptr [rbx + 0xa0], xmm0
00000001405eb004: mov      dword ptr [rbx + 0xa8], r13d
00000001405eb00b: mov      eax, dword ptr [rbp + 0x7f]
00000001405eb00e: mov      dword ptr [rbx + 0xf0], eax
00000001405eb014: cmp      eax, dword ptr [rip + 0x158cf12]
00000001405eb01a: je       0x1405eb026
00000001405eb01c: mov      dword ptr [rbx + 0x3b0], 1
00000001405eb026: mov      eax, dword ptr [rsi + 0x38]
00000001405eb029: mov      dword ptr [rbx + 0xf4], eax
00000001405eb02f: mov      eax, dword ptr [rsi + 0x3c]
00000001405eb032: mov      dword ptr [rbx + 0xf8], eax
00000001405eb038: xor      r12d, r12d
00000001405eb03b: mov      qword ptr [rbx + 0x100], r12
00000001405eb042: mov      dword ptr [rbx + 0x148], r12d
00000001405eb049: movzx    eax, byte ptr [rbp + 0x87]
00000001405eb050: mov      byte ptr [rbx + 0x15c], al
00000001405eb056: mov      dword ptr [rbx + 0x168], r12d
00000001405eb05d: test     r14, r14
00000001405eb060: je       0x1405eb075
00000001405eb062: mov      rax, qword ptr [r14 + 0xb8]
00000001405eb069: test     rax, rax
00000001405eb06c: je       0x1405eb075
00000001405eb06e: mov      edi, dword ptr [rax + 0x14]
00000001405eb071: test     edi, edi
00000001405eb073: jg       0x1405eb092
00000001405eb075: mov      edi, 1
00000001405eb07a: cmp      dword ptr [rsi + 0x48], edi
00000001405eb07d: cmovg    edi, dword ptr [rsi + 0x48]
00000001405eb081: test     r14, r14
00000001405eb084: je       0x1405eb09b
00000001405eb086: mov      rax, qword ptr [r14 + 0xb8]
00000001405eb08d: test     rax, rax
00000001405eb090: je       0x1405eb09b
00000001405eb092: mov      r8d, dword ptr [rax + 0x18]
00000001405eb096: test     r8d, r8d
00000001405eb099: jg       0x1405eb09f
00000001405eb09b: mov      r8d, dword ptr [rsi + 0x4c]
00000001405eb09f: lea      rcx, [rbx + 0x410]
00000001405eb0a6: mov      edx, edi
00000001405eb0a8: call     0x1409860d0
00000001405eb0ad: lea      rcx, [rbx + 0x448]
00000001405eb0b4: xor      r8d, r8d
00000001405eb0b7: mov      edx, edi
00000001405eb0b9: call     0x1409860d0
00000001405eb0be: mov      dword ptr [rbx + 0x480], r12d
00000001405eb0c5: mov      eax, dword ptr [rsi + 0x2c]
00000001405eb0c8: mov      dword ptr [rbx + 0x404], eax
00000001405eb0ce: mov      eax, dword ptr [rsi + 0x54]
00000001405eb0d1: mov      dword ptr [rbx + 0x408], eax
00000001405eb0d7: mov      rcx, rbx
00000001405eb0da: call     0x1405ea5f0
00000001405eb0df: mov      r13, rax
00000001405eb0e2: mov      qword ptr [rsp + 0x38], rax
00000001405eb0e7: test     rax, rax
00000001405eb0ea: je       0x1405eb113
00000001405eb0ec: xor      edx, edx
00000001405eb0ee: mov      rcx, rax
00000001405eb0f1: call     0x14066cca0
00000001405eb0f6: test     eax, eax
00000001405eb0f8: jne      0x1405eb109
00000001405eb0fa: lea      edx, [rax + 1]
00000001405eb0fd: mov      rcx, r13
00000001405eb100: call     0x14066cca0
00000001405eb105: test     eax, eax
00000001405eb107: je       0x1405eb113
00000001405eb109: mov      dword ptr [rbx + 0x638], 1
00000001405eb113: cmp      dword ptr [rbx + 0x204], -1
00000001405eb11a: je       0x1405eb166
00000001405eb11c: mov      edi, r12d
00000001405eb11f: nop      
00000001405eb120: mov      edx, edi
00000001405eb122: mov      ecx, dword ptr [rbx + 0x108]
00000001405eb128: call     0x140ad88b0
00000001405eb12d: mov      rsi, rax
00000001405eb130: test     rax, rax
00000001405eb133: je       0x1405eb14a
00000001405eb135: lea      rcx, [rax + 0xcc8]
00000001405eb13c: mov      rdx, qword ptr [rcx]
00000001405eb13f: call     qword ptr [rdx + 0x30]
00000001405eb142: cmp      eax, dword ptr [rbx + 0x204]
00000001405eb148: je       0x1405eb153
00000001405eb14a: inc      edi
00000001405eb14c: cmp      edi, 3
00000001405eb14f: jge      0x1405eb166
00000001405eb151: jmp      0x1405eb120
00000001405eb153: mov      qword ptr [rbx + 0x6f8], rsi
00000001405eb15a: mov      eax, dword ptr [rsi + 0xe64]
00000001405eb160: mov      dword ptr [rbx + 0x700], eax
00000001405eb166: lea      rax, [r14 + 0x18]
00000001405eb16a: mov      qword ptr [rbp - 0x31], rax
00000001405eb16e: lea      rax, [r14 + 0x38]
00000001405eb172: mov      qword ptr [rbp - 0x29], rax
00000001405eb176: lea      rax, [r14 + 0x58]
00000001405eb17a: mov      qword ptr [rbp - 0x21], rax
00000001405eb17e: lea      rax, [r14 + 0x78]
00000001405eb182: mov      qword ptr [rbp - 0x19], rax
00000001405eb186: lea      rax, [r14 + 0x98]
00000001405eb18d: mov      qword ptr [rbp - 0x11], rax
00000001405eb191: lea      rdi, [rbp - 0x31]
00000001405eb195: lea      rax, [rbp - 0x31]
00000001405eb199: mov      r14, rbx
00000001405eb19c: sub      r14, rax
00000001405eb19f: mov      esi, 5
00000001405eb1a4: nop      dword ptr [rax]
00000001405eb1a8: nop      dword ptr [rax + rax]
00000001405eb1b0: mov      r8, qword ptr [r14 + rdi + 0x118]
00000001405eb1b8: test     r8, r8
00000001405eb1bb: je       0x1405eb1e2
00000001405eb1bd: mov      rcx, qword ptr [rdi]
00000001405eb1c0: mov      rax, 0xffffffffffffffff
00000001405eb1c7: inc      rax
00000001405eb1ca: cmp      byte ptr [rcx + rax], r12b
00000001405eb1ce: jne      0x1405eb1c7
00000001405eb1d0: test     eax, eax
00000001405eb1d2: je       0x1405eb1e2
00000001405eb1d4: mov      edx, dword ptr [rbx + 0x4b0]
00000001405eb1da: mov      rcx, r8
00000001405eb1dd: call     0x140a614e0
00000001405eb1e2: add      rdi, 8
00000001405eb1e6: sub      rsi, 1
00000001405eb1ea: jne      0x1405eb1b0
00000001405eb1ec: mov      edx, dword ptr [rbx + 0x4b0]
00000001405eb1f2: mov      rcx, qword ptr [rbx + 0x118]
00000001405eb1f9: call     0x140a614e0
00000001405eb1fe: lea      rdi, [rbx + 0x260]
00000001405eb205: mov      esi, 0x20
00000001405eb20a: nop      word ptr [rax + rax]
00000001405eb210: mov      rax, qword ptr [rdi]
00000001405eb213: test     rax, rax
00000001405eb216: je       0x1405eb23b
00000001405eb218: lea      rcx, [rbx + 0x560]
00000001405eb21f: mov      rdx, qword ptr [rcx + 0x20]
00000001405eb223: cmp      rdx, qword ptr [rcx + 0x28]
00000001405eb227: je       0x1405eb233
00000001405eb229: mov      qword ptr [rdx], rax
00000001405eb22c: add      qword ptr [rcx + 0x20], 8
00000001405eb231: jmp      0x1405eb23b
00000001405eb233: mov      r8, rdi
00000001405eb236: call     0x1405dec20
00000001405eb23b: add      rdi, 8
00000001405eb23f: sub      rsi, 1
00000001405eb243: jne      0x1405eb210
00000001405eb245: mov      dword ptr [rbx + 0x484], r12d
00000001405eb24c: mov      eax, dword ptr [rbx + 0x10c]
00000001405eb252: mov      dword ptr [rbx + 0x488], eax
00000001405eb258: mov      eax, dword ptr [rbx + 0x90]
00000001405eb25e: mov      dword ptr [rbx + 0x48c], eax
00000001405eb264: mov      qword ptr [rbx + 0x490], rbx
00000001405eb26b: lea      rdx, [rsp + 0x68]
00000001405eb270: lea      rcx, [rbx + 0xac]
00000001405eb277: call     0x141283ee0
00000001405eb27c: mov      rsi, rax
00000001405eb27f: lea      rdx, [rsp + 0x58]
00000001405eb284: lea      rcx, [rbx + 0xac]
00000001405eb28b: call     0x141284120
00000001405eb290: mov      rdi, rax
00000001405eb293: lea      rdx, [rsp + 0x40]
00000001405eb298: lea      rcx, [rbx + 0xac]
00000001405eb29f: call     0x1412840b0
00000001405eb2a4: mov      rdx, rax
00000001405eb2a7: mov      qword ptr [rsp + 0x20], rsi
00000001405eb2ac: mov      r9, r15
00000001405eb2af: mov      r8, rdi
00000001405eb2b2: lea      rcx, [rbx + 0xac]
00000001405eb2b9: call     0x141282120
00000001405eb2be: mov      rcx, qword ptr [rbx + 0x98]
00000001405eb2c5: call     0x140a61c20
00000001405eb2ca: mov      r12, qword ptr [rsp + 0x50]
00000001405eb2cf: add      r12, 8
00000001405eb2d3: mov      qword ptr [rsp + 0x40], r12
00000001405eb2d8: lea      rdx, [rip + 0x12a3409]
00000001405eb2df: mov      rcx, r12
00000001405eb2e2: call     0x141442fdc
00000001405eb2e7: test     rax, rax
00000001405eb2ea: jne      0x1405eb3c1
00000001405eb2f0: lea      rdx, [rip + 0x12a3401]
00000001405eb2f7: mov      rcx, r12
00000001405eb2fa: call     0x141442fdc
00000001405eb2ff: test     rax, rax
00000001405eb302: jne      0x1405eb3c1
00000001405eb308: lea      rdx, [rip + 0x12a33f9]
00000001405eb30f: mov      rcx, r12
00000001405eb312: call     0x141442fdc
00000001405eb317: test     rax, rax
00000001405eb31a: jne      0x1405eb3c1
00000001405eb320: mov      r8d, 0x242
00000001405eb326: lea      rdx, [rip + 0x12a3303]
00000001405eb32d: lea      ecx, [rax + 0x30]
00000001405eb330: call     0x141272600
00000001405eb335: mov      rdi, rax
00000001405eb338: mov      qword ptr [rsp + 0x68], rax
00000001405eb33d: lea      r14, [rip + 0x11766c4]
00000001405eb344: lea      rsi, [rip + 0x12a3fed]
00000001405eb34b: test     rax, rax
00000001405eb34e: je       0x1405eb3ba
00000001405eb350: mov      r9d, 0xffffffff
00000001405eb356: mov      r8d, 0x20
00000001405eb35c: lea      rdx, [rip + 0x12a33dd]
00000001405eb363: mov      rcx, rax
00000001405eb366: call     0x14109c5c0
00000001405eb36b: nop      
00000001405eb36c: mov      qword ptr [rdi], r14
00000001405eb36f: mov      rcx, rdi
00000001405eb372: call     qword ptr [rip + 0x1176698]
00000001405eb378: mov      r8d, 0x70
00000001405eb37e: lea      rdx, [rip + 0x11767db]
00000001405eb385: lea      ecx, [r8 - 0x58]
00000001405eb389: call     0x141272600
00000001405eb38e: mov      qword ptr [rsp + 0x58], rax
00000001405eb393: test     rax, rax
00000001405eb396: je       0x1405eb3aa
00000001405eb398: mov      qword ptr [rax], rsi
00000001405eb39b: mov      qword ptr [rax + 8], rbx
00000001405eb39f: lea      rcx, [rip - 0xb602]
00000001405eb3a6: mov      qword ptr [rax + 0x10], rcx
00000001405eb3aa: mov      qword ptr [rdi + 0x28], rax
00000001405eb3ae: mov      rax, qword ptr [rdi]
00000001405eb3b1: mov      rcx, rdi
00000001405eb3b4: call     qword ptr [rax + 0x10]
00000001405eb3b7: nop      
00000001405eb3b8: jmp      0x1405eb3bc
00000001405eb3ba: xor      edi, edi
00000001405eb3bc: jmp      0x1405eb460
00000001405eb3c1: mov      r8d, 0x23e
00000001405eb3c7: lea      rdx, [rip + 0x12a3262]
00000001405eb3ce: mov      ecx, 0x30
00000001405eb3d3: call     0x141272600
00000001405eb3d8: mov      rdi, rax
00000001405eb3db: mov      qword ptr [rsp + 0x68], rax
00000001405eb3e0: lea      r14, [rip + 0x1176621]
00000001405eb3e7: lea      rsi, [rip + 0x12a3f4a]
00000001405eb3ee: test     rax, rax
00000001405eb3f1: je       0x1405eb45e
00000001405eb3f3: mov      r9d, dword ptr [rip + 0x158c486]
00000001405eb3fa: mov      r8d, 0x20
00000001405eb400: lea      rdx, [rip + 0x12a3311]
00000001405eb407: mov      rcx, rax
00000001405eb40a: call     0x14109c5c0
00000001405eb40f: nop      
00000001405eb410: mov      qword ptr [rdi], r14
00000001405eb413: mov      rcx, rdi
00000001405eb416: call     qword ptr [rip + 0x11765f4]
00000001405eb41c: mov      r8d, 0x70
00000001405eb422: lea      rdx, [rip + 0x1176737]
00000001405eb429: lea      ecx, [r8 - 0x58]
00000001405eb42d: call     0x141272600
00000001405eb432: mov      qword ptr [rsp + 0x58], rax
00000001405eb437: test     rax, rax
00000001405eb43a: je       0x1405eb44e
00000001405eb43c: mov      qword ptr [rax], rsi
00000001405eb43f: mov      qword ptr [rax + 8], rbx
00000001405eb443: lea      rcx, [rip - 0xb6a6]
00000001405eb44a: mov      qword ptr [rax + 0x10], rcx
00000001405eb44e: mov      qword ptr [rdi + 0x28], rax
00000001405eb452: mov      rax, qword ptr [rdi]
00000001405eb455: mov      rcx, rdi
00000001405eb458: call     qword ptr [rax + 0x10]
00000001405eb45b: nop      
00000001405eb45c: jmp      0x1405eb460
00000001405eb45e: xor      edi, edi
00000001405eb460: mov      qword ptr [rbx + 0x3c0], rdi
00000001405eb467: mov      r8d, 0x245
00000001405eb46d: lea      rdx, [rip + 0x12a31bc]
00000001405eb474: mov      ecx, 0x30
00000001405eb479: call     0x141272600
00000001405eb47e: mov      rdi, rax
00000001405eb481: mov      qword ptr [rsp + 0x68], rax
00000001405eb486: test     rax, rax
00000001405eb489: je       0x1405eb4fd
00000001405eb48b: mov      r9d, 0xffffffff
00000001405eb491: mov      r8d, 0x57
00000001405eb497: lea      rdx, [rip + 0x12a32ba]
00000001405eb49e: mov      rcx, rax
00000001405eb4a1: call     0x14109c5c0
00000001405eb4a6: nop      
00000001405eb4a7: mov      qword ptr [rdi], r14
00000001405eb4aa: mov      rcx, rdi
00000001405eb4ad: call     qword ptr [rip + 0x117655d]
00000001405eb4b3: mov      r8d, 0x70
00000001405eb4b9: lea      rdx, [rip + 0x11766a0]
00000001405eb4c0: lea      ecx, [r8 - 0x58]
00000001405eb4c4: call     0x141272600
00000001405eb4c9: mov      qword ptr [rsp + 0x58], rax
00000001405eb4ce: test     rax, rax
00000001405eb4d1: je       0x1405eb4e9
00000001405eb4d3: mov      qword ptr [rax], rsi
00000001405eb4d6: mov      qword ptr [rax + 8], rbx
00000001405eb4da: lea      rcx, [rip - 0xb735]
00000001405eb4e1: mov      qword ptr [rax + 0x10], rcx
00000001405eb4e5: xor      esi, esi
00000001405eb4e7: jmp      0x1405eb4ed
00000001405eb4e9: xor      esi, esi
00000001405eb4eb: mov      eax, esi
00000001405eb4ed: mov      qword ptr [rdi + 0x28], rax
00000001405eb4f1: mov      rax, qword ptr [rdi]
00000001405eb4f4: mov      rcx, rdi
00000001405eb4f7: call     qword ptr [rax + 0x10]
00000001405eb4fa: nop      
00000001405eb4fb: jmp      0x1405eb501
00000001405eb4fd: xor      esi, esi
00000001405eb4ff: mov      edi, esi
00000001405eb501: mov      qword ptr [rbx + 0x3c8], rdi
00000001405eb508: mov      rax, qword ptr [rbx]
00000001405eb50b: xor      edx, edx
00000001405eb50d: mov      rcx, rbx
00000001405eb510: call     qword ptr [rax + 0x70]
00000001405eb513: cmp      dword ptr [rbx + 0x218], 0
00000001405eb51a: je       0x1405eb69b
00000001405eb520: lea      rdx, [rbx + 0x500]
00000001405eb527: lea      rcx, [rbp - 0x69]
00000001405eb52b: call     0x1405df110
00000001405eb530: nop      
00000001405eb531: mov      r15, qword ptr [rbp - 0x51]
00000001405eb535: mov      rax, qword ptr [rbp - 0x49]
00000001405eb539: cmp      r15, rax
00000001405eb53c: je       0x1405eb678
00000001405eb542: mov      r13d, 0xfffe
00000001405eb548: lea      r12, [rip + 0x1179e91]
00000001405eb54f: lea      rbx, [rip + 0x1179eaa]
00000001405eb556: nop      word ptr [rax + rax]
00000001405eb560: mov      rdi, qword ptr [r15]
00000001405eb563: test     rdi, rdi
00000001405eb566: je       0x1405eb659
00000001405eb56c: lea      rcx, [rbp - 0x31]
00000001405eb570: call     0x141273620
00000001405eb575: mov      qword ptr [rbp - 0x19], rsi
00000001405eb579: mov      dword ptr [rbp - 0x11], esi
00000001405eb57c: mov      qword ptr [rbp - 0x31], rbx
00000001405eb580: lea      rdx, [rbp - 0x31]
00000001405eb584: mov      rcx, rdi
00000001405eb587: call     0x14128f490
00000001405eb58c: mov      r14d, dword ptr [rbp - 0x11]
00000001405eb590: test     r14d, r14d
00000001405eb593: je       0x1405eb61c
00000001405eb599: nop      dword ptr [rax]
00000001405eb5a0: movsxd   rcx, esi
00000001405eb5a3: mov      rax, qword ptr [rbp - 0x19]
00000001405eb5a7: mov      rdi, qword ptr [rax + rcx*8]
00000001405eb5ab: test     rdi, rdi
00000001405eb5ae: je       0x1405eb603
00000001405eb5b0: mov      rcx, qword ptr [rdi + 0x18]
00000001405eb5b4: test     rcx, rcx
00000001405eb5b7: je       0x1405eb603
00000001405eb5b9: mov      rax, qword ptr [rcx]
00000001405eb5bc: call     qword ptr [rax + 0x30]
00000001405eb5bf: lea      rcx, [rip + 0x1ad4272]
00000001405eb5c6: cmp      rax, rcx
00000001405eb5c9: jne      0x1405eb603
00000001405eb5cb: mov      rcx, qword ptr [rdi + 0x20]
00000001405eb5cf: test     rcx, rcx
00000001405eb5d2: je       0x1405eb5dc
00000001405eb5d4: mov      rax, qword ptr [rcx]
00000001405eb5d7: call     qword ptr [rax + 0x10]
00000001405eb5da: jmp      0x1405eb5ef
00000001405eb5dc: mov      rcx, qword ptr [rdi + 0x18]
00000001405eb5e0: test     rcx, rcx
00000001405eb5e3: je       0x1405eb5ed
00000001405eb5e5: mov      rax, qword ptr [rcx]
00000001405eb5e8: call     qword ptr [rax + 0x10]
00000001405eb5eb: jmp      0x1405eb5ef
00000001405eb5ed: xor      eax, eax
00000001405eb5ef: lea      rdx, [rip + 0x121fb2a]
00000001405eb5f6: mov      rcx, rax
00000001405eb5f9: call     0x141442fdc
00000001405eb5fe: test     rax, rax
00000001405eb601: jne      0x1405eb60c
00000001405eb603: inc      esi
00000001405eb605: cmp      esi, r14d
00000001405eb608: jae      0x1405eb61c
00000001405eb60a: jmp      0x1405eb5a0
00000001405eb60c: and      word ptr [rdi + 0x28], r13w
00000001405eb611: mov      rax, qword ptr [rdi + 0x38]
00000001405eb615: mov      dword ptr [rax + 0x38], 0x3f800000
00000001405eb61c: mov      qword ptr [rbp - 0x31], r12
00000001405eb620: cmp      qword ptr [rbp - 0x19], 0
00000001405eb625: je       0x1405eb653
00000001405eb627: lea      rcx, [rbp - 0x31]
00000001405eb62b: call     0x141273770
00000001405eb630: mov      ecx, eax
00000001405eb632: call     0x141273960
00000001405eb637: mov      rcx, qword ptr [rbp - 0x19]
00000001405eb63b: test     rcx, rcx
00000001405eb63e: je       0x1405eb64d
00000001405eb640: call     0x141272e20
00000001405eb645: mov      qword ptr [rbp - 0x19], 0
00000001405eb64d: call     0x141273900
00000001405eb652: nop      
00000001405eb653: mov      rax, qword ptr [rbp - 0x49]
00000001405eb657: xor      esi, esi
00000001405eb659: add      r15, 8
00000001405eb65d: cmp      r15, rax
00000001405eb660: jne      0x1405eb560
00000001405eb666: mov      r15, qword ptr [rbp - 0x51]
00000001405eb66a: mov      rbx, qword ptr [rbp - 0x71]
00000001405eb66e: mov      r12, qword ptr [rsp + 0x40]
00000001405eb673: mov      r13, qword ptr [rsp + 0x38]
00000001405eb678: test     r15, r15
00000001405eb67b: je       0x1405eb69b
00000001405eb67d: lea      rcx, [rbp - 0x69]
00000001405eb681: call     0x141273770
00000001405eb686: mov      ecx, eax
00000001405eb688: call     0x141273960
00000001405eb68d: mov      rcx, r15
00000001405eb690: call     0x1412732b0
00000001405eb695: call     0x141273900
00000001405eb69a: nop      
00000001405eb69b: cmp      dword ptr [rbx + 0x21c], 0
00000001405eb6a2: je       0x1405eb81a
00000001405eb6a8: lea      rdx, [rbx + 0x500]
00000001405eb6af: lea      rcx, [rbp - 0x69]
00000001405eb6b3: call     0x1405df110
00000001405eb6b8: nop      
00000001405eb6b9: mov      r15, qword ptr [rbp - 0x51]
00000001405eb6bd: mov      rax, qword ptr [rbp - 0x49]
00000001405eb6c1: cmp      r15, rax
00000001405eb6c4: je       0x1405eb7f7
00000001405eb6ca: lea      r13, [rip + 0x1179d0f]
00000001405eb6d1: lea      r12, [rip + 0x1179d28]
00000001405eb6d8: nop      dword ptr [rax + rax]
00000001405eb6e0: mov      rdi, qword ptr [r15]
00000001405eb6e3: test     rdi, rdi
00000001405eb6e6: je       0x1405eb7d7
00000001405eb6ec: lea      rcx, [rbp - 0x31]
00000001405eb6f0: call     0x141273620
00000001405eb6f5: mov      qword ptr [rbp - 0x19], rsi
00000001405eb6f9: mov      dword ptr [rbp - 0x11], esi
00000001405eb6fc: mov      qword ptr [rbp - 0x31], r12
00000001405eb700: lea      rdx, [rbp - 0x31]
00000001405eb704: mov      rcx, rdi
00000001405eb707: call     0x14128f490
00000001405eb70c: mov      r14d, dword ptr [rbp - 0x11]
00000001405eb710: test     r14d, r14d
00000001405eb713: je       0x1405eb79c
00000001405eb719: nop      dword ptr [rax]
00000001405eb720: movsxd   rcx, esi
00000001405eb723: mov      rax, qword ptr [rbp - 0x19]
00000001405eb727: mov      rdi, qword ptr [rax + rcx*8]
00000001405eb72b: test     rdi, rdi
00000001405eb72e: je       0x1405eb783
00000001405eb730: mov      rcx, qword ptr [rdi + 0x18]
00000001405eb734: test     rcx, rcx
00000001405eb737: je       0x1405eb783
00000001405eb739: mov      rax, qword ptr [rcx]
00000001405eb73c: call     qword ptr [rax + 0x30]
00000001405eb73f: lea      rcx, [rip + 0x1ad40f2]
00000001405eb746: cmp      rax, rcx
00000001405eb749: jne      0x1405eb783
00000001405eb74b: mov      rcx, qword ptr [rdi + 0x20]
00000001405eb74f: test     rcx, rcx
00000001405eb752: je       0x1405eb75c
00000001405eb754: mov      rax, qword ptr [rcx]
00000001405eb757: call     qword ptr [rax + 0x10]
00000001405eb75a: jmp      0x1405eb76f
00000001405eb75c: mov      rcx, qword ptr [rdi + 0x18]
00000001405eb760: test     rcx, rcx
00000001405eb763: je       0x1405eb76d
00000001405eb765: mov      rax, qword ptr [rcx]
00000001405eb768: call     qword ptr [rax + 0x10]
00000001405eb76b: jmp      0x1405eb76f
00000001405eb76d: xor      eax, eax
00000001405eb76f: lea      rdx, [rip + 0x121f9a2]
00000001405eb776: mov      rcx, rax
00000001405eb779: call     0x141442fdc
00000001405eb77e: test     rax, rax
00000001405eb781: jne      0x1405eb78c
00000001405eb783: inc      esi
00000001405eb785: cmp      esi, r14d
00000001405eb788: jae      0x1405eb79c
00000001405eb78a: jmp      0x1405eb720
00000001405eb78c: or       word ptr [rdi + 0x28], 1
00000001405eb791: mov      rax, qword ptr [rdi + 0x38]
00000001405eb795: mov      dword ptr [rax + 0x38], 0
00000001405eb79c: mov      qword ptr [rbp - 0x31], r13
00000001405eb7a0: cmp      qword ptr [rbp - 0x19], 0
00000001405eb7a5: je       0x1405eb7d3
00000001405eb7a7: lea      rcx, [rbp - 0x31]
00000001405eb7ab: call     0x141273770
00000001405eb7b0: mov      ecx, eax
00000001405eb7b2: call     0x141273960
00000001405eb7b7: mov      rcx, qword ptr [rbp - 0x19]
00000001405eb7bb: test     rcx, rcx
00000001405eb7be: je       0x1405eb7cd
00000001405eb7c0: call     0x141272e20
00000001405eb7c5: mov      qword ptr [rbp - 0x19], 0
00000001405eb7cd: call     0x141273900
00000001405eb7d2: nop      
00000001405eb7d3: mov      rax, qword ptr [rbp - 0x49]
00000001405eb7d7: add      r15, 8
00000001405eb7db: cmp      r15, rax
00000001405eb7de: mov      esi, 0
00000001405eb7e3: jne      0x1405eb6e0
00000001405eb7e9: mov      r15, qword ptr [rbp - 0x51]
00000001405eb7ed: mov      r12, qword ptr [rsp + 0x40]
00000001405eb7f2: mov      r13, qword ptr [rsp + 0x38]
00000001405eb7f7: test     r15, r15
00000001405eb7fa: je       0x1405eb81a
00000001405eb7fc: lea      rcx, [rbp - 0x69]
00000001405eb800: call     0x141273770
00000001405eb805: mov      ecx, eax
00000001405eb807: call     0x141273960
00000001405eb80c: mov      rcx, r15
00000001405eb80f: call     0x1412732b0
00000001405eb814: call     0x141273900
00000001405eb819: nop      
00000001405eb81a: mov      rcx, rbx
00000001405eb81d: call     0x1405e6ef0
00000001405eb822: cmp      dword ptr [rbx + 0x228], 0
00000001405eb829: je       0x1405eb859
00000001405eb82b: mov      ecx, dword ptr [rsp + 0x30]
00000001405eb82f: call     0x140ad8880
00000001405eb834: test     rax, rax
00000001405eb837: je       0x1405eb859
00000001405eb839: cmp      dword ptr [rax + 0xe64], 0x5c
00000001405eb840: jne      0x1405eb859
00000001405eb842: mov      rdx, qword ptr [rax + 0x208]
00000001405eb849: mov      rdx, qword ptr [rdx + 0x20]
00000001405eb84d: mov      rcx, qword ptr [rbx + 0x140]
00000001405eb854: call     0x1412ad870
00000001405eb859: mov      ecx, dword ptr [rsp + 0x30]
00000001405eb85d: call     0x140ad8880
00000001405eb862: test     rax, rax
00000001405eb865: je       0x1405eb96d
00000001405eb86b: mov      eax, dword ptr [rax + 0xe64]
00000001405eb871: add      eax, -0x15
00000001405eb874: cmp      eax, 0xdd
00000001405eb879: ja       0x1405eb96d
00000001405eb87f: cdqe     
00000001405eb881: lea      rdx, [rip - 0x5eb888]
00000001405eb888: movzx    eax, byte ptr [rdx + rax + 0x5eba78]
00000001405eb890: mov      ecx, dword ptr [rdx + rax*4 + 0x5eba5c]
00000001405eb897: add      rcx, rdx
00000001405eb89a: jmp      rcx
00000001405eb89c: lea      rdx, [rip + 0x12a2ecd]
00000001405eb8a3: mov      rcx, r12
00000001405eb8a6: call     0x141299b80
00000001405eb8ab: test     eax, eax
00000001405eb8ad: je       0x1405eb96d
00000001405eb8b3: mov      dword ptr [rbx + 0x5c0], 0x41a00000
00000001405eb8bd: jmp      0x1405eb96d
00000001405eb8c2: lea      rdx, [rip + 0x12a2ec7]
00000001405eb8c9: mov      rcx, r12
00000001405eb8cc: call     0x141299b80
00000001405eb8d1: test     eax, eax
00000001405eb8d3: je       0x1405eb8e4
00000001405eb8d5: mov      dword ptr [rbx + 0x5c0], 0x41a00000
00000001405eb8df: jmp      0x1405eb96d
00000001405eb8e4: lea      rdx, [rip + 0x12a2ec5]
00000001405eb8eb: mov      rcx, r12
00000001405eb8ee: call     0x141299b80
00000001405eb8f3: test     eax, eax
00000001405eb8f5: je       0x1405eb96d
00000001405eb8f7: jmp      0x1405eb963
00000001405eb8f9: lea      rdx, [rip + 0x12a2ec8]
00000001405eb900: mov      rcx, r12
00000001405eb903: call     0x141299b80
00000001405eb908: test     eax, eax
00000001405eb90a: jne      0x1405eb963
00000001405eb90c: lea      rdx, [rip + 0x12a2ecd]
00000001405eb913: mov      rcx, r12
00000001405eb916: call     0x141299b80
00000001405eb91b: test     eax, eax
00000001405eb91d: jne      0x1405eb963
00000001405eb91f: lea      rdx, [rip + 0x12a2ed2]
00000001405eb926: jmp      0x1405eb8eb
00000001405eb928: lea      rdx, [rip + 0x12a2ee1]
00000001405eb92f: jmp      0x1405eb957
00000001405eb931: lea      rdx, [rip + 0x12a2ef8]
00000001405eb938: mov      rcx, r12
00000001405eb93b: call     0x141443072
00000001405eb940: test     eax, eax
00000001405eb942: jne      0x1405eb96d
00000001405eb944: mov      dword ptr [rbx + 0x5c8], 1
00000001405eb94e: jmp      0x1405eb96d
00000001405eb950: lea      rdx, [rip + 0x11bdb41]
00000001405eb957: mov      rcx, r12
00000001405eb95a: call     0x141443072
00000001405eb95f: test     eax, eax
00000001405eb961: jne      0x1405eb96d
00000001405eb963: mov      dword ptr [rbx + 0x5c4], 1
00000001405eb96d: cmp      dword ptr [rbx + 0x230], 0
00000001405eb974: je       0x1405eb994
00000001405eb976: mov      ecx, dword ptr [rbx + 0x108]
00000001405eb97c: call     0x140ad8880
00000001405eb981: test     rax, rax
00000001405eb984: je       0x1405eb994
00000001405eb986: mov      edx, dword ptr [rbx + 0x90]
00000001405eb98c: mov      rcx, rax
00000001405eb98f: call     0x140a05ba0
00000001405eb994: mov      rax, qword ptr [rsp + 0x50]
00000001405eb999: cmp      word ptr [rax + 0x34], 0
00000001405eb99e: jne      0x1405eb9e5
00000001405eb9a0: lea      rdx, [rip + 0x12a2ea9]
00000001405eb9a7: mov      rcx, r12
00000001405eb9aa: call     0x141443072
00000001405eb9af: test     eax, eax
00000001405eb9b1: jne      0x1405eb9e5
00000001405eb9b3: mov      rax, qword ptr [rip + 0x1b89906]
00000001405eb9ba: mov      rdi, qword ptr [rax + 0x228]
00000001405eb9c1: test     rdi, rdi
00000001405eb9c4: je       0x1405eb9e5
00000001405eb9c6: mov      r8d, 5
00000001405eb9cc: lea      rdx, [rip + 0x1175c66]
00000001405eb9d3: mov      rcx, qword ptr [rdi + 0x12ec0]
00000001405eb9da: call     0x1402a05f0
00000001405eb9df: mov      dword ptr [rdi + 0x13004], eax
00000001405eb9e5: test     r13, r13
00000001405eb9e8: je       0x1405eba29
00000001405eb9ea: mov      eax, dword ptr [r13 + 0xea4]
00000001405eb9f1: cmp      eax, 0x88
00000001405eb9f6: jne      0x1405eba17
00000001405eb9f8: mov      dword ptr [rbx + 0x6e4], 1
00000001405eba02: mov      rcx, r13
00000001405eba05: call     0x140994ee0
00000001405eba0a: mov      dword ptr [rbx + 0x6e8], eax
00000001405eba10: mov      eax, dword ptr [r13 + 0xea4]
00000001405eba17: add      eax, -0x4d
00000001405eba1a: cmp      eax, 1
00000001405eba1d: ja       0x1405eba29
00000001405eba1f: mov      dword ptr [rbx + 0x6ec], 1
00000001405eba29: mov      rax, qword ptr [rbx]
00000001405eba2c: mov      rcx, rbx
00000001405eba2f: call     qword ptr [rax + 0x10]
00000001405eba32: nop      
00000001405eba33: mov      rcx, qword ptr [rbp - 9]
00000001405eba37: xor      rcx, rsp
00000001405eba3a: call     0x141441dc0
00000001405eba3f: mov      rbx, qword ptr [rsp + 0x148]
00000001405eba47: add      rsp, 0x100
00000001405eba4e: pop      r15
00000001405eba50: pop      r14
00000001405eba52: pop      r13
00000001405eba54: pop      r12
00000001405eba56: pop      rdi
00000001405eba57: pop      rsi
00000001405eba58: pop      rbp
00000001405eba59: ret      
00000001405eba5a: nop      
00000001405eba5c: sub      byte ptr [rcx - 0x4763ffa2], bh
00000001405eba62: pop      rsi
00000001405eba63: add      dl, al
00000001405eba65: mov      eax, 0xb8f9005e
00000001405eba6a: pop      rsi
00000001405eba6b: add      byte ptr [rcx], dh
00000001405eba6d: mov      ecx, 0xb950005e
00000001405eba72: pop      rsi
00000001405eba73: add      byte ptr [rbp - 0x47], ch
00000001405eba76: pop      rsi
00000001405eba77: add      byte ptr [rax], al
