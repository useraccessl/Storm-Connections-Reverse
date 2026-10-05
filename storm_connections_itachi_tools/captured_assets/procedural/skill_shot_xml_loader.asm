0000000140a68e20: mov      qword ptr [rsp + 8], rcx
0000000140a68e25: push     rbx
0000000140a68e26: push     rbp
0000000140a68e27: push     rsi
0000000140a68e28: push     rdi
0000000140a68e29: push     r12
0000000140a68e2b: push     r14
0000000140a68e2d: push     r15
0000000140a68e2f: sub      rsp, 0x20
0000000140a68e33: lea      r11, [rip + 0xe909fe]
0000000140a68e3a: mov      rbp, rdx
0000000140a68e3d: mov      r9, r11
0000000140a68e40: mov      r15, rcx
0000000140a68e43: inc      r9
0000000140a68e46: cmp      byte ptr [r9], 0
0000000140a68e4a: jne      0x140a68e43
0000000140a68e4c: mov      r14, qword ptr [rdx + 0x40]
0000000140a68e50: lea      r12, [rip + 0x1725cf9]
0000000140a68e57: sub      r9, r11
0000000140a68e5a: mov      r10, r14
0000000140a68e5d: test     r14, r14
0000000140a68e60: je       0x140a68eab
0000000140a68e62: mov      rcx, qword ptr [r10]
0000000140a68e65: test     rcx, rcx
0000000140a68e68: je       0x140a68e70
0000000140a68e6a: mov      rax, qword ptr [r10 + 0x10]
0000000140a68e6e: jmp      0x140a68e75
0000000140a68e70: xor      eax, eax
0000000140a68e72: mov      rcx, r12
0000000140a68e75: cmp      rax, r9
0000000140a68e78: jne      0x140a68ea2
0000000140a68e7a: lea      r8, [rax + rcx]
0000000140a68e7e: cmp      rcx, r8
0000000140a68e81: jae      0x140a68eae
0000000140a68e83: mov      rdx, r11
0000000140a68e86: sub      rdx, rcx
0000000140a68e89: nop      dword ptr [rax]
0000000140a68e90: movzx    eax, byte ptr [rdx + rcx]
0000000140a68e94: cmp      byte ptr [rcx], al
0000000140a68e96: jne      0x140a68ea2
0000000140a68e98: inc      rcx
0000000140a68e9b: cmp      rcx, r8
0000000140a68e9e: jb       0x140a68e90
0000000140a68ea0: jmp      0x140a68eae
0000000140a68ea2: mov      r10, qword ptr [r10 + 0x30]
0000000140a68ea6: test     r10, r10
0000000140a68ea9: jne      0x140a68e62
0000000140a68eab: xor      r10d, r10d
0000000140a68eae: lea      r11, [rip + 0xf0beef]
0000000140a68eb5: mov      r9, r11
0000000140a68eb8: nop      dword ptr [rax + rax]
0000000140a68ec0: inc      r9
0000000140a68ec3: cmp      byte ptr [r9], 0
0000000140a68ec7: jne      0x140a68ec0
0000000140a68ec9: sub      r9, r11
0000000140a68ecc: mov      rsi, r14
0000000140a68ecf: test     r14, r14
0000000140a68ed2: je       0x140a68f1b
0000000140a68ed4: mov      rcx, qword ptr [rsi]
0000000140a68ed7: test     rcx, rcx
0000000140a68eda: je       0x140a68ee2
0000000140a68edc: mov      rax, qword ptr [rsi + 0x10]
0000000140a68ee0: jmp      0x140a68ee7
0000000140a68ee2: xor      eax, eax
0000000140a68ee4: mov      rcx, r12
0000000140a68ee7: cmp      rax, r9
0000000140a68eea: jne      0x140a68f12
0000000140a68eec: lea      r8, [rax + rcx]
0000000140a68ef0: cmp      rcx, r8
0000000140a68ef3: jae      0x140a68f1d
0000000140a68ef5: mov      rdx, r11
0000000140a68ef8: sub      rdx, rcx
0000000140a68efb: nop      dword ptr [rax + rax]
0000000140a68f00: movzx    eax, byte ptr [rcx + rdx]
0000000140a68f04: cmp      byte ptr [rcx], al
0000000140a68f06: jne      0x140a68f12
0000000140a68f08: inc      rcx
0000000140a68f0b: cmp      rcx, r8
0000000140a68f0e: jb       0x140a68f00
0000000140a68f10: jmp      0x140a68f1d
0000000140a68f12: mov      rsi, qword ptr [rsi + 0x30]
0000000140a68f16: test     rsi, rsi
0000000140a68f19: jne      0x140a68ed4
0000000140a68f1b: xor      esi, esi
0000000140a68f1d: lea      r11, [rip + 0xe8c384]
0000000140a68f24: mov      r9, r11
0000000140a68f27: inc      r9
0000000140a68f2a: cmp      byte ptr [r9], 0
0000000140a68f2e: jne      0x140a68f27
0000000140a68f30: sub      r9, r11
0000000140a68f33: mov      rdi, r14
0000000140a68f36: test     r14, r14
0000000140a68f39: je       0x140a68f82
0000000140a68f3b: nop      dword ptr [rax + rax]
0000000140a68f40: mov      rcx, qword ptr [rdi]
0000000140a68f43: test     rcx, rcx
0000000140a68f46: je       0x140a68f4e
0000000140a68f48: mov      rax, qword ptr [rdi + 0x10]
0000000140a68f4c: jmp      0x140a68f53
0000000140a68f4e: xor      eax, eax
0000000140a68f50: mov      rcx, r12
0000000140a68f53: cmp      rax, r9
0000000140a68f56: jne      0x140a68f79
0000000140a68f58: lea      r8, [rax + rcx]
0000000140a68f5c: cmp      rcx, r8
0000000140a68f5f: jae      0x140a68f84
0000000140a68f61: mov      rdx, r11
0000000140a68f64: sub      rdx, rcx
0000000140a68f67: movzx    eax, byte ptr [rcx + rdx]
0000000140a68f6b: cmp      byte ptr [rcx], al
0000000140a68f6d: jne      0x140a68f79
0000000140a68f6f: inc      rcx
0000000140a68f72: cmp      rcx, r8
0000000140a68f75: jb       0x140a68f67
0000000140a68f77: jmp      0x140a68f84
0000000140a68f79: mov      rdi, qword ptr [rdi + 0x30]
0000000140a68f7d: test     rdi, rdi
0000000140a68f80: jne      0x140a68f40
0000000140a68f82: xor      edi, edi
0000000140a68f84: lea      r11, [rip + 0xf0be1d]
0000000140a68f8b: mov      r9, r11
0000000140a68f8e: nop      
0000000140a68f90: inc      r9
0000000140a68f93: cmp      byte ptr [r9], 0
0000000140a68f97: jne      0x140a68f90
0000000140a68f99: sub      r9, r11
0000000140a68f9c: mov      rbx, r14
0000000140a68f9f: test     r14, r14
0000000140a68fa2: je       0x140a68feb
0000000140a68fa4: mov      rcx, qword ptr [rbx]
0000000140a68fa7: test     rcx, rcx
0000000140a68faa: je       0x140a68fb2
0000000140a68fac: mov      rax, qword ptr [rbx + 0x10]
0000000140a68fb0: jmp      0x140a68fb7
0000000140a68fb2: xor      eax, eax
0000000140a68fb4: mov      rcx, r12
0000000140a68fb7: cmp      rax, r9
0000000140a68fba: jne      0x140a68fe2
0000000140a68fbc: lea      r8, [rax + rcx]
0000000140a68fc0: cmp      rcx, r8
0000000140a68fc3: jae      0x140a68fed
0000000140a68fc5: mov      rdx, r11
0000000140a68fc8: sub      rdx, rcx
0000000140a68fcb: nop      dword ptr [rax + rax]
0000000140a68fd0: movzx    eax, byte ptr [rcx + rdx]
0000000140a68fd4: cmp      byte ptr [rcx], al
0000000140a68fd6: jne      0x140a68fe2
0000000140a68fd8: inc      rcx
0000000140a68fdb: cmp      rcx, r8
0000000140a68fde: jb       0x140a68fd0
0000000140a68fe0: jmp      0x140a68fed
0000000140a68fe2: mov      rbx, qword ptr [rbx + 0x30]
0000000140a68fe6: test     rbx, rbx
0000000140a68fe9: jne      0x140a68fa4
0000000140a68feb: xor      ebx, ebx
0000000140a68fed: lea      r11, [rip + 0xf0bdc8]
0000000140a68ff4: mov      r9, r11
0000000140a68ff7: inc      r9
0000000140a68ffa: cmp      byte ptr [r9], 0
0000000140a68ffe: jne      0x140a68ff7
0000000140a69000: sub      r9, r11
0000000140a69003: test     r14, r14
0000000140a69006: je       0x140a6904b
0000000140a69008: mov      rcx, qword ptr [r14]
0000000140a6900b: test     rcx, rcx
0000000140a6900e: je       0x140a69016
0000000140a69010: mov      rax, qword ptr [r14 + 0x10]
0000000140a69014: jmp      0x140a6901b
0000000140a69016: xor      eax, eax
0000000140a69018: mov      rcx, r12
0000000140a6901b: cmp      rax, r9
0000000140a6901e: jne      0x140a69042
0000000140a69020: lea      r8, [rcx + rax]
0000000140a69024: cmp      rcx, r8
0000000140a69027: jae      0x140a6904e
0000000140a69029: mov      rdx, r11
0000000140a6902c: sub      rdx, rcx
0000000140a6902f: nop      
0000000140a69030: movzx    eax, byte ptr [rcx + rdx]
0000000140a69034: cmp      byte ptr [rcx], al
0000000140a69036: jne      0x140a69042
0000000140a69038: inc      rcx
0000000140a6903b: cmp      rcx, r8
0000000140a6903e: jb       0x140a69030
0000000140a69040: jmp      0x140a6904e
0000000140a69042: mov      r14, qword ptr [r14 + 0x30]
0000000140a69046: test     r14, r14
0000000140a69049: jne      0x140a69008
0000000140a6904b: xor      r14d, r14d
0000000140a6904e: test     r10, r10
0000000140a69051: je       0x140a6907e
0000000140a69053: mov      rax, qword ptr [r10 + 8]
0000000140a69057: mov      rcx, r12
0000000140a6905a: test     rax, rax
0000000140a6905d: cmovne   rcx, rax
0000000140a69061: call     0x140a6c830
0000000140a69066: mov      ecx, dword ptr [r15 + 0xf0]
0000000140a6906d: imul     rdx, rcx, 0xf8
0000000140a69074: mov      rcx, qword ptr [r15 + 0xf8]
0000000140a6907b: mov      dword ptr [rdx + rcx], eax
0000000140a6907e: test     rsi, rsi
0000000140a69081: je       0x140a690c2
0000000140a69083: mov      rax, qword ptr [rsi + 8]
0000000140a69087: mov      rdx, r12
0000000140a6908a: mov      r8, qword ptr [r15 + 0xf8]
0000000140a69091: test     rax, rax
0000000140a69094: cmovne   rdx, rax
0000000140a69098: mov      eax, dword ptr [r15 + 0xf0]
0000000140a6909f: imul     rcx, rax, 0xf8
0000000140a690a6: add      r8, 4
0000000140a690aa: add      r8, rcx
0000000140a690ad: nop      dword ptr [rax]
0000000140a690b0: movzx    eax, byte ptr [rdx]
0000000140a690b3: lea      rdx, [rdx + 1]
0000000140a690b7: mov      byte ptr [r8], al
0000000140a690ba: lea      r8, [r8 + 1]
0000000140a690be: test     al, al
0000000140a690c0: jne      0x140a690b0
0000000140a690c2: test     rdi, rdi
0000000140a690c5: je       0x140a690f3
0000000140a690c7: mov      rax, qword ptr [rdi + 8]
0000000140a690cb: mov      rcx, r12
0000000140a690ce: test     rax, rax
0000000140a690d1: cmovne   rcx, rax
0000000140a690d5: call     0x140a6c790
0000000140a690da: mov      ecx, dword ptr [r15 + 0xf0]
0000000140a690e1: imul     rdx, rcx, 0xf8
0000000140a690e8: mov      rcx, qword ptr [r15 + 0xf8]
0000000140a690ef: mov      dword ptr [rdx + rcx + 0x24], eax
0000000140a690f3: test     rbx, rbx
0000000140a690f6: je       0x140a69144
0000000140a690f8: mov      rax, qword ptr [rbx + 8]
0000000140a690fc: lea      rbx, [rip + 0x1725a4d]
0000000140a69103: mov      r8, qword ptr [r15 + 0xf8]
0000000140a6910a: test     rax, rax
0000000140a6910d: mov      rdx, rbx
0000000140a69110: cmovne   rdx, rax
0000000140a69114: mov      eax, dword ptr [r15 + 0xf0]
0000000140a6911b: imul     rcx, rax, 0xf8
0000000140a69122: add      r8, 0x28
0000000140a69126: add      r8, rcx
0000000140a69129: nop      dword ptr [rax]
0000000140a69130: movzx    eax, byte ptr [rdx]
0000000140a69133: lea      rdx, [rdx + 1]
0000000140a69137: mov      byte ptr [r8], al
0000000140a6913a: lea      r8, [r8 + 1]
0000000140a6913e: test     al, al
0000000140a69140: jne      0x140a69130
0000000140a69142: jmp      0x140a6914b
0000000140a69144: lea      rbx, [rip + 0x1725a05]
0000000140a6914b: mov      eax, dword ptr [r15 + 0xf0]
0000000140a69152: imul     r11, rax, 0xf8
0000000140a69159: add      r11, qword ptr [r15 + 0xf8]
0000000140a69160: cmp      dword ptr [r11], 2
0000000140a69164: jne      0x140a69207
0000000140a6916a: lea      rdi, [rip + 0xf0bc57]
0000000140a69171: mov      r10, rdi
0000000140a69174: inc      r10
0000000140a69177: cmp      byte ptr [r10], 0
0000000140a6917b: jne      0x140a69174
0000000140a6917d: mov      r9, qword ptr [rbp + 0x40]
0000000140a69181: sub      r10, rdi
0000000140a69184: test     r9, r9
0000000140a69187: je       0x140a691ff
0000000140a69189: nop      dword ptr [rax]
0000000140a69190: mov      rcx, qword ptr [r9]
0000000140a69193: test     rcx, rcx
0000000140a69196: je       0x140a6919e
0000000140a69198: mov      rax, qword ptr [r9 + 0x10]
0000000140a6919c: jmp      0x140a691a3
0000000140a6919e: xor      eax, eax
0000000140a691a0: mov      rcx, rbx
0000000140a691a3: cmp      rax, r10
0000000140a691a6: jne      0x140a691f6
0000000140a691a8: lea      r8, [rax + rcx]
0000000140a691ac: cmp      rcx, r8
0000000140a691af: jae      0x140a691c7
0000000140a691b1: mov      rdx, rdi
0000000140a691b4: sub      rdx, rcx
0000000140a691b7: movzx    eax, byte ptr [rcx + rdx]
0000000140a691bb: cmp      byte ptr [rcx], al
0000000140a691bd: jne      0x140a691f6
0000000140a691bf: inc      rcx
0000000140a691c2: cmp      rcx, r8
0000000140a691c5: jb       0x140a691b7
0000000140a691c7: mov      rax, qword ptr [r9 + 8]
0000000140a691cb: mov      rcx, rbx
0000000140a691ce: test     rax, rax
0000000140a691d1: cmovne   rcx, rax
0000000140a691d5: call     qword ptr [rip + 0xcccb25]
0000000140a691db: mov      ecx, dword ptr [r15 + 0xf0]
0000000140a691e2: imul     rdx, rcx, 0xf8
0000000140a691e9: mov      rcx, qword ptr [r15 + 0xf8]
0000000140a691f0: mov      dword ptr [rdx + rcx + 0x4c], eax
0000000140a691f4: jmp      0x140a69207
0000000140a691f6: mov      r9, qword ptr [r9 + 0x30]
0000000140a691fa: test     r9, r9
0000000140a691fd: jne      0x140a69190
0000000140a691ff: mov      dword ptr [r11 + 0x4c], 1
0000000140a69207: mov      eax, dword ptr [r15 + 0xf0]
0000000140a6920e: imul     rdx, rax, 0xf8
0000000140a69215: mov      rax, qword ptr [r15 + 0xf8]
0000000140a6921c: test     r14, r14
0000000140a6921f: je       0x140a69276
0000000140a69221: mov      rbp, qword ptr [rsp + 0x60]
0000000140a69226: mov      dword ptr [rdx + rax + 0x48], 1
0000000140a6922e: mov      rax, qword ptr [r14 + 8]
0000000140a69232: test     rax, rax
0000000140a69235: mov      rdx, qword ptr [rbp + 0xf8]
0000000140a6923c: cmovne   rbx, rax
0000000140a69240: mov      eax, dword ptr [rbp + 0xf0]
0000000140a69246: imul     rcx, rax, 0xf8
0000000140a6924d: add      rdx, 0x50
0000000140a69251: add      rdx, rcx
0000000140a69254: nop      dword ptr [rax]
0000000140a69258: nop      dword ptr [rax + rax]
0000000140a69260: movzx    eax, byte ptr [rbx]
0000000140a69263: lea      rbx, [rbx + 1]
0000000140a69267: mov      byte ptr [rdx], al
0000000140a69269: lea      rdx, [rdx + 1]
0000000140a6926d: test     al, al
0000000140a6926f: jne      0x140a69260
0000000140a69271: jmp      0x140a6935e
0000000140a69276: mov      dword ptr [rdx + rax + 0x48], 0
0000000140a6927e: lea      rdx, [rip + 0xf0b5bf]
0000000140a69285: cmp      byte ptr [rip + 0xf0b5b8], 0
0000000140a6928c: mov      r9, rdx
0000000140a6928f: je       0x140a6929a
0000000140a69291: inc      r9
0000000140a69294: cmp      byte ptr [r9], 0
0000000140a69298: jne      0x140a69291
0000000140a6929a: mov      r10, qword ptr [rbp + 0x30]
0000000140a6929e: sub      r9, rdx
0000000140a692a1: mov      qword ptr [rsp + 0x70], r10
0000000140a692a6: test     r10, r10
0000000140a692a9: je       0x140a69359
0000000140a692af: nop      
0000000140a692b0: mov      rcx, qword ptr [r10]
0000000140a692b3: test     rcx, rcx
0000000140a692b6: je       0x140a692be
0000000140a692b8: mov      rax, qword ptr [r10 + 0x10]
0000000140a692bc: jmp      0x140a692c3
0000000140a692be: xor      eax, eax
0000000140a692c0: mov      rcx, rbx
0000000140a692c3: cmp      rax, r9
0000000140a692c6: jne      0x140a69347
0000000140a692c8: lea      r8, [rax + rcx]
0000000140a692cc: cmp      rcx, r8
0000000140a692cf: jae      0x140a692e4
0000000140a692d1: sub      rdx, rcx
0000000140a692d4: movzx    eax, byte ptr [rcx + rdx]
0000000140a692d8: cmp      byte ptr [rcx], al
0000000140a692da: jne      0x140a69340
0000000140a692dc: inc      rcx
0000000140a692df: cmp      rcx, r8
0000000140a692e2: jb       0x140a692d4
0000000140a692e4: mov      qword ptr [rsp + 0x68], r13
0000000140a692e9: lea      rdx, [rip + 0xe10a90]
0000000140a692f0: mov      r9, rdx
0000000140a692f3: lea      r14, [rip + 0xf0baee]
0000000140a692fa: lea      rsi, [rip + 0xf0bad7]
0000000140a69301: lea      r11, [rip + 0xf0ba5c]
0000000140a69308: nop      dword ptr [rax + rax]
0000000140a69310: inc      r9
0000000140a69313: cmp      byte ptr [r9], 0
0000000140a69317: jne      0x140a69310
0000000140a69319: mov      r13, qword ptr [r10 + 0x40]
0000000140a6931d: sub      r9, rdx
0000000140a69320: mov      r12, r13
0000000140a69323: test     r13, r13
0000000140a69326: je       0x140a693b7
0000000140a6932c: nop      dword ptr [rax]
0000000140a69330: mov      rcx, qword ptr [r12]
0000000140a69334: test     rcx, rcx
0000000140a69337: je       0x140a69378
0000000140a69339: mov      rax, qword ptr [r12 + 0x10]
0000000140a6933e: jmp      0x140a6937d
0000000140a69340: lea      rdx, [rip + 0xf0b4fd]
0000000140a69347: mov      r10, qword ptr [r10 + 0x58]
0000000140a6934b: mov      qword ptr [rsp + 0x70], r10
0000000140a69350: test     r10, r10
0000000140a69353: jne      0x140a692b0
0000000140a69359: mov      rbp, qword ptr [rsp + 0x60]
0000000140a6935e: inc      dword ptr [rbp + 0xf0]
0000000140a69364: mov      eax, 1
0000000140a69369: add      rsp, 0x20
0000000140a6936d: pop      r15
0000000140a6936f: pop      r14
0000000140a69371: pop      r12
0000000140a69373: pop      rdi
0000000140a69374: pop      rsi
0000000140a69375: pop      rbp
0000000140a69376: pop      rbx
0000000140a69377: ret      
0000000140a69378: xor      eax, eax
0000000140a6937a: mov      rcx, rbx
0000000140a6937d: cmp      rax, r9
0000000140a69380: jne      0x140a693a9
0000000140a69382: lea      r8, [rax + rcx]
0000000140a69386: cmp      rcx, r8
0000000140a69389: jae      0x140a693ba
0000000140a6938b: sub      rdx, rcx
0000000140a6938e: nop      
0000000140a69390: movzx    eax, byte ptr [rcx + rdx]
0000000140a69394: cmp      byte ptr [rcx], al
0000000140a69396: jne      0x140a693a2
0000000140a69398: inc      rcx
0000000140a6939b: cmp      rcx, r8
0000000140a6939e: jb       0x140a69390
0000000140a693a0: jmp      0x140a693ba
0000000140a693a2: lea      rdx, [rip + 0xe109d7]
0000000140a693a9: mov      r12, qword ptr [r12 + 0x30]
0000000140a693ae: test     r12, r12
0000000140a693b1: jne      0x140a69330
0000000140a693b7: xor      r12d, r12d
0000000140a693ba: mov      r9, r11
0000000140a693bd: nop      dword ptr [rax]
0000000140a693c0: inc      r9
0000000140a693c3: cmp      byte ptr [r9], 0
0000000140a693c7: jne      0x140a693c0
0000000140a693c9: sub      r9, r11
0000000140a693cc: mov      rbp, r13
0000000140a693cf: test     r13, r13
0000000140a693d2: je       0x140a6941b
0000000140a693d4: mov      rcx, qword ptr [rbp]
0000000140a693d8: test     rcx, rcx
0000000140a693db: je       0x140a693e3
0000000140a693dd: mov      rax, qword ptr [rbp + 0x10]
0000000140a693e1: jmp      0x140a693e8
0000000140a693e3: xor      eax, eax
0000000140a693e5: mov      rcx, rbx
0000000140a693e8: cmp      rax, r9
0000000140a693eb: jne      0x140a69412
0000000140a693ed: lea      r8, [rax + rcx]
0000000140a693f1: cmp      rcx, r8
0000000140a693f4: jae      0x140a6941d
0000000140a693f6: mov      rdx, r11
0000000140a693f9: sub      rdx, rcx
0000000140a693fc: nop      dword ptr [rax]
0000000140a69400: movzx    eax, byte ptr [rcx + rdx]
0000000140a69404: cmp      byte ptr [rcx], al
0000000140a69406: jne      0x140a69412
0000000140a69408: inc      rcx
0000000140a6940b: cmp      rcx, r8
0000000140a6940e: jb       0x140a69400
0000000140a69410: jmp      0x140a6941d
0000000140a69412: mov      rbp, qword ptr [rbp + 0x30]
0000000140a69416: test     rbp, rbp
0000000140a69419: jne      0x140a693d4
0000000140a6941b: xor      ebp, ebp
0000000140a6941d: mov      r9, rsi
0000000140a69420: inc      r9
0000000140a69423: cmp      byte ptr [r9], 0
0000000140a69427: jne      0x140a69420
0000000140a69429: sub      r9, rsi
0000000140a6942c: mov      rdi, r13
0000000140a6942f: test     r13, r13
0000000140a69432: je       0x140a6947b
0000000140a69434: mov      rcx, qword ptr [rdi]
0000000140a69437: test     rcx, rcx
0000000140a6943a: je       0x140a69442
0000000140a6943c: mov      rax, qword ptr [rdi + 0x10]
0000000140a69440: jmp      0x140a69447
0000000140a69442: xor      eax, eax
0000000140a69444: mov      rcx, rbx
0000000140a69447: cmp      rax, r9
0000000140a6944a: jne      0x140a69472
0000000140a6944c: lea      r8, [rax + rcx]
0000000140a69450: cmp      rcx, r8
0000000140a69453: jae      0x140a6947d
0000000140a69455: mov      rdx, rsi
0000000140a69458: sub      rdx, rcx
0000000140a6945b: nop      dword ptr [rax + rax]
0000000140a69460: movzx    eax, byte ptr [rcx + rdx]
0000000140a69464: cmp      byte ptr [rcx], al
0000000140a69466: jne      0x140a69472
0000000140a69468: inc      rcx
0000000140a6946b: cmp      rcx, r8
0000000140a6946e: jb       0x140a69460
0000000140a69470: jmp      0x140a6947d
0000000140a69472: mov      rdi, qword ptr [rdi + 0x30]
0000000140a69476: test     rdi, rdi
0000000140a69479: jne      0x140a69434
0000000140a6947b: xor      edi, edi
0000000140a6947d: mov      r9, r14
0000000140a69480: inc      r9
0000000140a69483: cmp      byte ptr [r9], 0
0000000140a69487: jne      0x140a69480
0000000140a69489: sub      r9, r14
0000000140a6948c: mov      r15, r13
0000000140a6948f: test     r13, r13
0000000140a69492: je       0x140a694db
0000000140a69494: mov      rcx, qword ptr [r15]
0000000140a69497: test     rcx, rcx
0000000140a6949a: je       0x140a694a2
0000000140a6949c: mov      rax, qword ptr [r15 + 0x10]
0000000140a694a0: jmp      0x140a694a7
0000000140a694a2: xor      eax, eax
0000000140a694a4: mov      rcx, rbx
0000000140a694a7: cmp      rax, r9
0000000140a694aa: jne      0x140a694d2
0000000140a694ac: lea      r8, [rcx + rax]
0000000140a694b0: cmp      rcx, r8
0000000140a694b3: jae      0x140a694de
0000000140a694b5: mov      rdx, r14
0000000140a694b8: sub      rdx, rcx
0000000140a694bb: nop      dword ptr [rax + rax]
0000000140a694c0: movzx    eax, byte ptr [rcx + rdx]
0000000140a694c4: cmp      byte ptr [rcx], al
0000000140a694c6: jne      0x140a694d2
0000000140a694c8: inc      rcx
0000000140a694cb: cmp      rcx, r8
0000000140a694ce: jb       0x140a694c0
0000000140a694d0: jmp      0x140a694de
0000000140a694d2: mov      r15, qword ptr [r15 + 0x30]
0000000140a694d6: test     r15, r15
0000000140a694d9: jne      0x140a69494
0000000140a694db: xor      r15d, r15d
0000000140a694de: lea      rdx, [rip + 0xf0b913]
0000000140a694e5: mov      r9, rdx
0000000140a694e8: nop      dword ptr [rax + rax]
0000000140a694f0: inc      r9
0000000140a694f3: cmp      byte ptr [r9], 0
0000000140a694f7: jne      0x140a694f0
0000000140a694f9: sub      r9, rdx
0000000140a694fc: mov      r14, r13
0000000140a694ff: test     r13, r13
0000000140a69502: je       0x140a6954a
0000000140a69504: mov      rcx, qword ptr [r14]
0000000140a69507: test     rcx, rcx
0000000140a6950a: je       0x140a69512
0000000140a6950c: mov      rax, qword ptr [r14 + 0x10]
0000000140a69510: jmp      0x140a69517
0000000140a69512: xor      eax, eax
0000000140a69514: mov      rcx, rbx
0000000140a69517: cmp      rax, r9
0000000140a6951a: jne      0x140a69541
0000000140a6951c: lea      r8, [rax + rcx]
0000000140a69520: cmp      rcx, r8
0000000140a69523: jae      0x140a6954d
0000000140a69525: sub      rdx, rcx
0000000140a69528: movzx    eax, byte ptr [rcx + rdx]
0000000140a6952c: cmp      byte ptr [rcx], al
0000000140a6952e: jne      0x140a6953a
0000000140a69530: inc      rcx
0000000140a69533: cmp      rcx, r8
0000000140a69536: jb       0x140a69528
0000000140a69538: jmp      0x140a6954d
0000000140a6953a: lea      rdx, [rip + 0xf0b8b7]
0000000140a69541: mov      r14, qword ptr [r14 + 0x30]
0000000140a69545: test     r14, r14
0000000140a69548: jne      0x140a69504
0000000140a6954a: xor      r14d, r14d
0000000140a6954d: lea      rdx, [rip + 0xf0b8b4]
0000000140a69554: mov      r9, rdx
0000000140a69557: inc      r9
0000000140a6955a: cmp      byte ptr [r9], 0
0000000140a6955e: jne      0x140a69557
0000000140a69560: sub      r9, rdx
0000000140a69563: mov      rsi, r13
0000000140a69566: test     r13, r13
0000000140a69569: je       0x140a695b6
0000000140a6956b: nop      dword ptr [rax + rax]
0000000140a69570: mov      rcx, qword ptr [rsi]
0000000140a69573: test     rcx, rcx
0000000140a69576: je       0x140a6957e
0000000140a69578: mov      rax, qword ptr [rsi + 0x10]
0000000140a6957c: jmp      0x140a69583
0000000140a6957e: xor      eax, eax
0000000140a69580: mov      rcx, rbx
0000000140a69583: cmp      rax, r9
0000000140a69586: jne      0x140a695ad
0000000140a69588: lea      r8, [rax + rcx]
0000000140a6958c: cmp      rcx, r8
0000000140a6958f: jae      0x140a695b8
0000000140a69591: sub      rdx, rcx
0000000140a69594: movzx    eax, byte ptr [rcx + rdx]
0000000140a69598: cmp      byte ptr [rcx], al
0000000140a6959a: jne      0x140a695a6
0000000140a6959c: inc      rcx
0000000140a6959f: cmp      rcx, r8
0000000140a695a2: jb       0x140a69594
0000000140a695a4: jmp      0x140a695b8
0000000140a695a6: lea      rdx, [rip + 0xf0b85b]
0000000140a695ad: mov      rsi, qword ptr [rsi + 0x30]
0000000140a695b1: test     rsi, rsi
0000000140a695b4: jne      0x140a69570
0000000140a695b6: xor      esi, esi
0000000140a695b8: lea      rdx, [rip + 0xf0b859]
0000000140a695bf: mov      r9, rdx
0000000140a695c2: inc      r9
0000000140a695c5: cmp      byte ptr [r9], 0
0000000140a695c9: jne      0x140a695c2
0000000140a695cb: sub      r9, rdx
0000000140a695ce: test     r13, r13
0000000140a695d1: je       0x140a6961a
0000000140a695d3: mov      rcx, qword ptr [r13]
0000000140a695d7: test     rcx, rcx
0000000140a695da: je       0x140a695e2
0000000140a695dc: mov      rax, qword ptr [r13 + 0x10]
0000000140a695e0: jmp      0x140a695e7
0000000140a695e2: xor      eax, eax
0000000140a695e4: mov      rcx, rbx
0000000140a695e7: cmp      rax, r9
0000000140a695ea: jne      0x140a69611
0000000140a695ec: lea      r8, [rax + rcx]
0000000140a695f0: cmp      rcx, r8
0000000140a695f3: jae      0x140a6961d
0000000140a695f5: sub      rdx, rcx
0000000140a695f8: movzx    eax, byte ptr [rcx + rdx]
0000000140a695fc: cmp      byte ptr [rcx], al
0000000140a695fe: jne      0x140a6960a
0000000140a69600: inc      rcx
0000000140a69603: cmp      rcx, r8
0000000140a69606: jb       0x140a695f8
0000000140a69608: jmp      0x140a6961d
0000000140a6960a: lea      rdx, [rip + 0xf0b807]
0000000140a69611: mov      r13, qword ptr [r13 + 0x30]
0000000140a69615: test     r13, r13
0000000140a69618: jne      0x140a695d3
0000000140a6961a: xor      r13d, r13d
0000000140a6961d: mov      r9, qword ptr [rsp + 0x60]
0000000140a69622: mov      r10d, dword ptr [r9 + 0xf0]
0000000140a69629: mov      r9, qword ptr [r9 + 0xf8]
0000000140a69630: imul     r11, r10, 0xf8
0000000140a69637: mov      r8, r9
0000000140a6963a: mov      ebx, dword ptr [r9 + r11 + 0x48]
0000000140a6963f: test     r12, r12
0000000140a69642: je       0x140a6969a
0000000140a69644: mov      rax, qword ptr [r12 + 8]
0000000140a69649: lea      r8, [r11 + 0x50]
0000000140a6964d: test     rax, rax
0000000140a69650: lea      r12, [rip + 0x17254f9]
0000000140a69657: mov      rdx, r12
0000000140a6965a: cmovne   rdx, rax
0000000140a6965e: imul     rcx, rbx, 0x54
0000000140a69662: add      rcx, r9
0000000140a69665: add      r8, rcx
0000000140a69668: nop      dword ptr [rax + rax]
0000000140a69670: movzx    eax, byte ptr [rdx]
0000000140a69673: lea      rdx, [rdx + 1]
0000000140a69677: mov      byte ptr [r8], al
0000000140a6967a: lea      r8, [r8 + 1]
0000000140a6967e: test     al, al
0000000140a69680: jne      0x140a69670
0000000140a69682: mov      rax, qword ptr [rsp + 0x60]
0000000140a69687: mov      r9, qword ptr [rax + 0xf8]
0000000140a6968e: mov      r10d, dword ptr [rax + 0xf0]
0000000140a69695: mov      r8, r9
0000000140a69698: jmp      0x140a696a1
0000000140a6969a: lea      r12, [rip + 0x17254af]
0000000140a696a1: test     rbp, rbp
0000000140a696a4: je       0x140a696f6
0000000140a696a6: mov      rax, qword ptr [rbp + 8]
0000000140a696aa: mov      r8, r12
0000000140a696ad: test     rax, rax
0000000140a696b0: cmovne   r8, rax
0000000140a696b4: mov      eax, r10d
0000000140a696b7: imul     rdx, rax, 0xf8
0000000140a696be: imul     rcx, rbx, 0x54
0000000140a696c2: add      rcx, rdx
0000000140a696c5: sub      rcx, r8
0000000140a696c8: add      rcx, r9
0000000140a696cb: nop      dword ptr [rax + rax]
0000000140a696d0: movzx    eax, byte ptr [r8]
0000000140a696d4: mov      byte ptr [r8 + rcx + 0x70], al
0000000140a696d9: lea      r8, [r8 + 1]
0000000140a696dd: test     al, al
0000000140a696df: jne      0x140a696d0
0000000140a696e1: mov      rbp, qword ptr [rsp + 0x60]
0000000140a696e6: mov      r10d, dword ptr [rbp + 0xf0]
0000000140a696ed: mov      r8, qword ptr [rbp + 0xf8]
0000000140a696f4: jmp      0x140a696fb
0000000140a696f6: mov      rbp, qword ptr [rsp + 0x60]
0000000140a696fb: test     rdi, rdi
0000000140a696fe: je       0x140a69748
0000000140a69700: mov      rax, qword ptr [rdi + 8]
0000000140a69704: mov      rcx, r12
0000000140a69707: test     rax, rax
0000000140a6970a: mov      rdi, rbx
0000000140a6970d: cmovne   rcx, rax
0000000140a69711: call     0x140a6c8f0
0000000140a69716: mov      ecx, dword ptr [rbp + 0xf0]
0000000140a6971c: imul     rdx, rcx, 0xf8
0000000140a69723: imul     rcx, rbx, 0x54
0000000140a69727: add      rdx, rcx
0000000140a6972a: mov      rcx, qword ptr [rbp + 0xf8]
0000000140a69731: mov      dword ptr [rdx + rcx + 0x90], eax
0000000140a69738: mov      r10d, dword ptr [rbp + 0xf0]
0000000140a6973f: mov      r8, qword ptr [rbp + 0xf8]
0000000140a69746: jmp      0x140a6974b
0000000140a69748: mov      rdi, rbx
0000000140a6974b: test     r15, r15
0000000140a6974e: je       0x140a69794
0000000140a69750: mov      rax, qword ptr [r15 + 8]
0000000140a69754: mov      rcx, r12
0000000140a69757: test     rax, rax
0000000140a6975a: cmovne   rcx, rax
0000000140a6975e: call     qword ptr [rip + 0xccc59c]
0000000140a69764: mov      ecx, dword ptr [rbp + 0xf0]
0000000140a6976a: imul     rdx, rcx, 0xf8
0000000140a69771: imul     rcx, rdi, 0x54
0000000140a69775: add      rdx, rcx
0000000140a69778: mov      rcx, qword ptr [rbp + 0xf8]
0000000140a6977f: mov      dword ptr [rdx + rcx + 0x94], eax
0000000140a69786: mov      r10d, dword ptr [rbp + 0xf0]
0000000140a6978d: mov      r8, qword ptr [rbp + 0xf8]
0000000140a69794: test     r14, r14
0000000140a69797: je       0x140a697dd
0000000140a69799: mov      rax, qword ptr [r14 + 8]
0000000140a6979d: mov      rcx, r12
0000000140a697a0: test     rax, rax
0000000140a697a3: cmovne   rcx, rax
0000000140a697a7: call     qword ptr [rip + 0xccc553]
0000000140a697ad: mov      ecx, dword ptr [rbp + 0xf0]
0000000140a697b3: imul     rdx, rcx, 0xf8
0000000140a697ba: imul     rcx, rdi, 0x54
0000000140a697be: add      rdx, rcx
0000000140a697c1: mov      rcx, qword ptr [rbp + 0xf8]
0000000140a697c8: mov      dword ptr [rdx + rcx + 0x98], eax
0000000140a697cf: mov      r10d, dword ptr [rbp + 0xf0]
0000000140a697d6: mov      r8, qword ptr [rbp + 0xf8]
0000000140a697dd: mov      r11d, r10d
0000000140a697e0: mov      rbx, r8
0000000140a697e3: test     rsi, rsi
0000000140a697e6: je       0x140a6983f
0000000140a697e8: mov      rax, qword ptr [rsi + 8]
0000000140a697ec: mov      rdx, r12
0000000140a697ef: test     rax, rax
0000000140a697f2: lea      rsi, [rip + 0xd0f5f7]
0000000140a697f9: cmovne   rdx, rax
0000000140a697fd: xor      ecx, ecx
0000000140a697ff: nop      
0000000140a69800: movzx    eax, byte ptr [rdx + rcx]
0000000140a69804: inc      rcx
0000000140a69807: cmp      al, byte ptr [rsi + rcx - 1]
0000000140a6980b: jne      0x140a69846
0000000140a6980d: cmp      rcx, 5
0000000140a69811: jne      0x140a69800
0000000140a69813: imul     rdx, rdi, 0x54
0000000140a69817: mov      eax, r10d
0000000140a6981a: imul     rax, rax, 0xf8
0000000140a69821: add      rax, r8
0000000140a69824: mov      dword ptr [rdx + rax + 0x9c], 1
0000000140a6982f: mov      r11d, dword ptr [rbp + 0xf0]
0000000140a69836: mov      rbx, qword ptr [rbp + 0xf8]
0000000140a6983d: jmp      0x140a69846
0000000140a6983f: lea      rsi, [rip + 0xd0f5aa]
0000000140a69846: mov      r8d, r11d
0000000140a69849: mov      r9, rbx
0000000140a6984c: test     r13, r13
0000000140a6984f: je       0x140a6989e
0000000140a69851: mov      rax, qword ptr [r13 + 8]
0000000140a69855: mov      rdx, r12
0000000140a69858: test     rax, rax
0000000140a6985b: cmovne   rdx, rax
0000000140a6985f: xor      ecx, ecx
0000000140a69861: movzx    eax, byte ptr [rdx + rcx]
0000000140a69865: inc      rcx
0000000140a69868: cmp      al, byte ptr [rsi + rcx - 1]
0000000140a6986c: jne      0x140a6989e
0000000140a6986e: cmp      rcx, 5
0000000140a69872: jne      0x140a69861
0000000140a69874: imul     rdx, rdi, 0x54
0000000140a69878: mov      eax, r11d
0000000140a6987b: imul     rax, rax, 0xf8
0000000140a69882: add      rax, rbx
0000000140a69885: mov      dword ptr [rdx + rax + 0xa0], 1
0000000140a69890: mov      r8d, dword ptr [rbp + 0xf0]
0000000140a69897: mov      r9, qword ptr [rbp + 0xf8]
0000000140a6989e: mov      eax, r8d
0000000140a698a1: lea      rdx, [rip + 0xf0af9c]
0000000140a698a8: imul     rcx, rax, 0xf8
0000000140a698af: inc      dword ptr [rcx + r9 + 0x48]
0000000140a698b4: mov      r9, rdx
0000000140a698b7: cmp      byte ptr [rip + 0xf0af86], 0
0000000140a698be: je       0x140a698c9
0000000140a698c0: inc      r9
0000000140a698c3: cmp      byte ptr [r9], 0
0000000140a698c7: jne      0x140a698c0
0000000140a698c9: mov      r10, qword ptr [rsp + 0x70]
0000000140a698ce: sub      r9, rdx
0000000140a698d1: mov      r10, qword ptr [r10 + 0x58]
0000000140a698d5: mov      qword ptr [rsp + 0x70], r10
0000000140a698da: test     r10, r10
0000000140a698dd: je       0x140a6993a
0000000140a698df: nop      
0000000140a698e0: mov      rax, qword ptr [r10]
0000000140a698e3: lea      rbx, [rip + 0x1725266]
0000000140a698ea: test     rax, rax
0000000140a698ed: je       0x140a698f5
0000000140a698ef: mov      rcx, qword ptr [r10 + 0x10]
0000000140a698f3: jmp      0x140a698fa
0000000140a698f5: xor      ecx, ecx
0000000140a698f7: mov      rax, rbx
0000000140a698fa: cmp      rcx, r9
0000000140a698fd: jne      0x140a6992c
0000000140a698ff: lea      r8, [rcx + rax]
0000000140a69903: cmp      rax, r8
0000000140a69906: jae      0x140a692e9
0000000140a6990c: sub      rdx, rax
0000000140a6990f: nop      
0000000140a69910: movzx    ecx, byte ptr [rax + rdx]
0000000140a69914: cmp      byte ptr [rax], cl
0000000140a69916: jne      0x140a69925
0000000140a69918: inc      rax
0000000140a6991b: cmp      rax, r8
0000000140a6991e: jb       0x140a69910
0000000140a69920: jmp      0x140a692e9
0000000140a69925: lea      rdx, [rip + 0xf0af18]
0000000140a6992c: mov      r10, qword ptr [r10 + 0x58]
0000000140a69930: mov      qword ptr [rsp + 0x70], r10
0000000140a69935: test     r10, r10
0000000140a69938: jne      0x140a698e0
0000000140a6993a: mov      r13, qword ptr [rsp + 0x68]
0000000140a6993f: jmp      0x140a6935e
