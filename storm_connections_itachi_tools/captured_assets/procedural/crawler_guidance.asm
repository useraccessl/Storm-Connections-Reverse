0000000140a62320: mov      rax, rsp
0000000140a62323: mov      qword ptr [rax + 0x10], rbx
0000000140a62327: push     rbp
0000000140a62328: push     rsi
0000000140a62329: push     rdi
0000000140a6232a: push     r12
0000000140a6232c: push     r13
0000000140a6232e: push     r14
0000000140a62330: push     r15
0000000140a62332: lea      rbp, [rax - 0x57]
0000000140a62336: sub      rsp, 0x100
0000000140a6233d: movaps   xmmword ptr [rax - 0x48], xmm6
0000000140a62341: movaps   xmmword ptr [rax - 0x58], xmm7
0000000140a62345: movaps   xmmword ptr [rax - 0x68], xmm8
0000000140a6234a: movaps   xmmword ptr [rax - 0x78], xmm9
0000000140a6234f: movaps   xmmword ptr [rax - 0x88], xmm10
0000000140a62357: mov      rax, qword ptr [rip + 0x168406a]
0000000140a6235e: xor      rax, rsp
0000000140a62361: mov      qword ptr [rbp - 0x41], rax
0000000140a62365: movaps   xmm10, xmm3
0000000140a62369: mov      qword ptr [rsp + 0x40], rcx
0000000140a6236e: movaps   xmm9, xmm2
0000000140a62372: movaps   xmm6, xmm1
0000000140a62375: mov      rbx, rcx
0000000140a62378: call     0x1400bfa80
0000000140a6237d: mov      r12, qword ptr [rbx + 8]
0000000140a62381: xor      r15d, r15d
0000000140a62384: mov      r8d, dword ptr [rip + 0x1115ba1]
0000000140a6238b: mov      ebx, dword ptr [r12 + 0xf0]
0000000140a62393: lea      rdi, [r12 + 0xa0]
0000000140a6239b: cmp      ebx, r8d
0000000140a6239e: je       0x140a628a8
0000000140a623a4: mov      rax, qword ptr [rip + 0x17751c5]
0000000140a623ab: mov      rdx, qword ptr [rax + 0x58]
0000000140a623af: mov      rcx, rdx
0000000140a623b2: mov      rax, qword ptr [rdx + 8]
0000000140a623b6: cmp      byte ptr [rax + 0x19], r15b
0000000140a623ba: jne      0x140a623d7
0000000140a623bc: nop      dword ptr [rax]
0000000140a623c0: cmp      dword ptr [rax + 0x20], ebx
0000000140a623c3: jae      0x140a623cb
0000000140a623c5: mov      rax, qword ptr [rax + 0x10]
0000000140a623c9: jmp      0x140a623d1
0000000140a623cb: mov      rcx, rax
0000000140a623ce: mov      rax, qword ptr [rax]
0000000140a623d1: cmp      byte ptr [rax + 0x19], r15b
0000000140a623d5: je       0x140a623c0
0000000140a623d7: cmp      byte ptr [rcx + 0x19], r15b
0000000140a623db: jne      0x140a628a8
0000000140a623e1: cmp      ebx, dword ptr [rcx + 0x20]
0000000140a623e4: jb       0x140a628a8
0000000140a623ea: cmp      rcx, rdx
0000000140a623ed: je       0x140a628a8
0000000140a623f3: mov      r13, qword ptr [rcx + 0x28]
0000000140a623f7: test     r13, r13
0000000140a623fa: je       0x140a628a8
0000000140a62400: mov      rax, qword ptr [rip + 0x1775101]
0000000140a62407: mov      esi, dword ptr [r13 + 0x90]
0000000140a6240e: mov      rdx, qword ptr [rax + 0x58]
0000000140a62412: mov      rcx, rdx
0000000140a62415: mov      rax, qword ptr [rdx + 8]
0000000140a62419: cmp      byte ptr [rax + 0x19], r15b
0000000140a6241d: jne      0x140a62437
0000000140a6241f: nop      
0000000140a62420: cmp      dword ptr [rax + 0x20], esi
0000000140a62423: jae      0x140a6242b
0000000140a62425: mov      rax, qword ptr [rax + 0x10]
0000000140a62429: jmp      0x140a62431
0000000140a6242b: mov      rcx, rax
0000000140a6242e: mov      rax, qword ptr [rax]
0000000140a62431: cmp      byte ptr [rax + 0x19], r15b
0000000140a62435: je       0x140a62420
0000000140a62437: cmp      byte ptr [rcx + 0x19], r15b
0000000140a6243b: jne      0x140a62469
0000000140a6243d: cmp      esi, dword ptr [rcx + 0x20]
0000000140a62440: jb       0x140a62469
0000000140a62442: cmp      rcx, rdx
0000000140a62445: je       0x140a62469
0000000140a62447: mov      r14, qword ptr [rcx + 0x28]
0000000140a6244b: test     r14, r14
0000000140a6244e: je       0x140a6246c
0000000140a62450: mov      rcx, r14
0000000140a62453: call     0x1409ce030
0000000140a62458: test     eax, eax
0000000140a6245a: jg       0x140a628a8
0000000140a62460: mov      r8d, dword ptr [rip + 0x1115ac5]
0000000140a62467: jmp      0x140a6246c
0000000140a62469: mov      r14, r15
0000000140a6246c: mov      eax, dword ptr [r13 + 0x78]
0000000140a62470: xorps    xmm8, xmm8
0000000140a62474: movsd    xmm0, qword ptr [r13 + 0x70]
0000000140a6247a: mov      r13, qword ptr [rsp + 0x40]
0000000140a6247f: mov      dword ptr [rsp + 0x38], eax
0000000140a62483: movsd    qword ptr [rsp + 0x30], xmm0
0000000140a62489: mov      rax, qword ptr [r13 + 8]
0000000140a6248d: test     rax, rax
0000000140a62490: je       0x140a6254a
0000000140a62496: cmp      dword ptr [rax + 0x6c0], r15d
0000000140a6249d: je       0x140a6254a
0000000140a624a3: cmp      esi, r8d
0000000140a624a6: je       0x140a6254a
0000000140a624ac: test     r14, r14
0000000140a624af: je       0x140a6254a
0000000140a624b5: lea      rcx, [rsp + 0x60]
0000000140a624ba: call     0x14127e6d0
0000000140a624bf: lea      rdx, [r14 + 0x108]
0000000140a624c6: lea      rcx, [rsp + 0x60]
0000000140a624cb: call     0x14127e710
0000000140a624d0: mov      rax, qword ptr [r13 + 8]
0000000140a624d4: lea      rdx, [rsp + 0x40]
0000000140a624d9: xorps    xmm2, xmm2
0000000140a624dc: lea      rcx, [rsp + 0x50]
0000000140a624e1: movsd    xmm0, qword ptr [rax + 0x6c4]
0000000140a624e9: movsd    qword ptr [rsp + 0x40], xmm0
0000000140a624ef: mov      eax, dword ptr [rax + 0x6cc]
0000000140a624f5: mov      dword ptr [rsp + 0x48], eax
0000000140a624f9: call     0x1412a7d80
0000000140a624fe: lea      r8, [rsp + 0x50]
0000000140a62503: lea      rdx, [rsp + 0x40]
0000000140a62508: lea      rcx, [rsp + 0x60]
0000000140a6250d: call     0x141283bb0
0000000140a62512: lea      rcx, [rsp + 0x30]
0000000140a62517: movups   xmm1, xmmword ptr [rax]
0000000140a6251a: movaps   xmm2, xmm1
0000000140a6251d: movaps   xmm0, xmm1
0000000140a62520: shufps   xmm2, xmm1, 0xaa
0000000140a62524: addss    xmm2, dword ptr [rsp + 0x38]
0000000140a6252a: shufps   xmm0, xmm1, 0x55
0000000140a6252e: addss    xmm0, dword ptr [rsp + 0x34]
0000000140a62534: movups   xmmword ptr [rsp + 0x50], xmm1
0000000140a62539: addss    xmm1, dword ptr [rsp + 0x30]
0000000140a6253f: movaps   xmm3, xmm2
0000000140a62542: movaps   xmm2, xmm0
0000000140a62545: call     0x1411adb80
0000000140a6254a: call     0x1400bfa80
0000000140a6254f: mov      rax, qword ptr [rip + 0x1774f4a]
0000000140a62556: movss    xmm2, dword ptr [rsp + 0x30]
0000000140a6255c: movss    xmm1, dword ptr [rsp + 0x34]
0000000140a62562: movss    xmm0, dword ptr [rsp + 0x38]
0000000140a62568: subss    xmm2, dword ptr [r12 + 0x70]
0000000140a6256f: subss    xmm1, dword ptr [r12 + 0x74]
0000000140a62576: subss    xmm0, dword ptr [r12 + 0x78]
0000000140a6257d: movss    dword ptr [rsp + 0x20], xmm2
0000000140a62583: movss    dword ptr [rsp + 0x24], xmm1
0000000140a62589: movss    dword ptr [rsp + 0x28], xmm0
0000000140a6258f: mov      rdx, qword ptr [rax + 0x58]
0000000140a62593: mov      rcx, rdx
0000000140a62596: mov      rax, qword ptr [rdx + 8]
0000000140a6259a: cmp      byte ptr [rax + 0x19], r15b
0000000140a6259e: jne      0x140a625b7
0000000140a625a0: cmp      dword ptr [rax + 0x20], ebx
0000000140a625a3: jae      0x140a625ab
0000000140a625a5: mov      rax, qword ptr [rax + 0x10]
0000000140a625a9: jmp      0x140a625b1
0000000140a625ab: mov      rcx, rax
0000000140a625ae: mov      rax, qword ptr [rax]
0000000140a625b1: cmp      byte ptr [rax + 0x19], r15b
0000000140a625b5: je       0x140a625a0
0000000140a625b7: cmp      byte ptr [rcx + 0x19], r15b
0000000140a625bb: jne      0x140a62705
0000000140a625c1: cmp      ebx, dword ptr [rcx + 0x20]
0000000140a625c4: jb       0x140a62705
0000000140a625ca: cmp      rcx, rdx
0000000140a625cd: je       0x140a62705
0000000140a625d3: mov      rbx, qword ptr [rcx + 0x28]
0000000140a625d7: test     rbx, rbx
0000000140a625da: je       0x140a62705
0000000140a625e0: mov      rax, qword ptr [rbx + 0x140]
0000000140a625e7: mov      rcx, qword ptr [rax + 0x20]
0000000140a625eb: test     rcx, rcx
0000000140a625ee: je       0x140a625f8
0000000140a625f0: mov      rax, qword ptr [rcx]
0000000140a625f3: call     qword ptr [rax + 0x10]
0000000140a625f6: jmp      0x140a6260c
0000000140a625f8: mov      rcx, qword ptr [rax + 0x18]
0000000140a625fc: test     rcx, rcx
0000000140a625ff: je       0x140a62609
0000000140a62601: mov      rax, qword ptr [rcx]
0000000140a62604: call     qword ptr [rax + 0x10]
0000000140a62607: jmp      0x140a6260c
0000000140a62609: mov      rax, r15
0000000140a6260c: mov      rdx, rax
0000000140a6260f: lea      rcx, [rip + 0xe50212]
0000000140a62616: call     0x141443072
0000000140a6261b: test     eax, eax
0000000140a6261d: je       0x140a62662
0000000140a6261f: mov      rax, qword ptr [rbx + 0x140]
0000000140a62626: mov      rcx, qword ptr [rax + 0x20]
0000000140a6262a: test     rcx, rcx
0000000140a6262d: je       0x140a62637
0000000140a6262f: mov      rax, qword ptr [rcx]
0000000140a62632: call     qword ptr [rax + 0x10]
0000000140a62635: jmp      0x140a6264b
0000000140a62637: mov      rcx, qword ptr [rax + 0x18]
0000000140a6263b: test     rcx, rcx
0000000140a6263e: je       0x140a62648
0000000140a62640: mov      rax, qword ptr [rcx]
0000000140a62643: call     qword ptr [rax + 0x10]
0000000140a62646: jmp      0x140a6264b
0000000140a62648: mov      rax, r15
0000000140a6264b: mov      rdx, rax
0000000140a6264e: lea      rcx, [rip + 0xe501e3]
0000000140a62655: call     0x141443072
0000000140a6265a: test     eax, eax
0000000140a6265c: jne      0x140a62705
0000000140a62662: call     0x1400bfa80
0000000140a62667: movss    xmm2, dword ptr [rsp + 0x38]
0000000140a6266d: xor      edx, edx
0000000140a6266f: addss    xmm2, dword ptr [rip + 0xd048a5]
0000000140a62677: movss    xmm1, dword ptr [rsp + 0x30]
0000000140a6267d: subss    xmm1, dword ptr [r12 + 0x70]
0000000140a62684: movss    xmm0, dword ptr [rsp + 0x34]
0000000140a6268a: subss    xmm0, dword ptr [r12 + 0x74]
0000000140a62691: mov      rax, qword ptr [rip + 0x8ca6e80]
0000000140a62698: movss    xmm7, dword ptr [rbp + 0x7f]
0000000140a6269d: mulss    xmm7, dword ptr [rip + 0xd2bb67]
0000000140a626a5: movss    dword ptr [rsp + 0x20], xmm1
0000000140a626ab: movaps   xmm1, xmm10
0000000140a626af: movss    dword ptr [rsp + 0x24], xmm0
0000000140a626b5: addss    xmm1, xmm10
0000000140a626ba: movss    dword ptr [rsp + 0x38], xmm2
0000000140a626c0: movaps   xmm0, xmm9
0000000140a626c4: subss    xmm2, dword ptr [r12 + 0x78]
0000000140a626cb: addss    xmm0, xmm9
0000000140a626d0: movaps   xmm10, xmm1
0000000140a626d4: movss    dword ptr [rsp + 0x28], xmm2
0000000140a626da: movzx    ecx, byte ptr [rax + 0x952]
0000000140a626e1: movaps   xmm9, xmm0
0000000140a626e5: mov      eax, dword ptr [rip + 0x11321fd]
0000000140a626eb: lea      rax, [rax + rax*2]
0000000140a626ef: div      rcx
0000000140a626f2: mov      rcx, qword ptr [r13 + 8]
0000000140a626f6: cmp      qword ptr [rcx + 0x100], rax
0000000140a626fd: jae      0x140a628a8
0000000140a62703: jmp      0x140a6270a
0000000140a62705: movss    xmm7, dword ptr [rbp + 0x7f]
0000000140a6270a: lea      rcx, [rsp + 0x20]
0000000140a6270f: call     0x1411ac880
0000000140a62714: comiss   xmm0, xmm8
0000000140a62718: jbe      0x140a628a8
0000000140a6271e: lea      rdx, [rsp + 0x40]
0000000140a62723: lea      rcx, [rsp + 0x20]
0000000140a62728: call     0x1411acc30
0000000140a6272d: mov      rcx, rdi
0000000140a62730: movsd    xmm1, qword ptr [rax]
0000000140a62734: mov      eax, dword ptr [rax + 8]
0000000140a62737: movaps   xmm0, xmm1
0000000140a6273a: shufps   xmm0, xmm0, 0x55
0000000140a6273e: movss    dword ptr [rsp + 0x24], xmm0
0000000140a62744: mov      dword ptr [rsp + 0x48], eax
0000000140a62748: movss    xmm0, dword ptr [rsp + 0x48]
0000000140a6274e: movss    dword ptr [rsp + 0x28], xmm0
0000000140a62754: movss    dword ptr [rsp + 0x20], xmm1
0000000140a6275a: movsd    qword ptr [rsp + 0x40], xmm1
0000000140a62760: call     0x1411ac880
0000000140a62765: comiss   xmm0, xmm8
0000000140a62769: jbe      0x140a628a8
0000000140a6276f: call     0x1400bfa80
0000000140a62774: lea      rdx, [rsp + 0x50]
0000000140a62779: mov      rcx, rdi
0000000140a6277c: call     0x1411acc30
0000000140a62781: lea      rdx, [rsp + 0x20]
0000000140a62786: lea      rcx, [rsp + 0x40]
0000000140a6278b: movsd    xmm0, qword ptr [rax]
0000000140a6278f: movsd    qword ptr [rsp + 0x40], xmm0
0000000140a62795: mov      eax, dword ptr [rax + 8]
0000000140a62798: mov      dword ptr [rsp + 0x48], eax
0000000140a6279c: call     0x1411ac380
0000000140a627a1: cvtss2sd xmm0, xmm0
0000000140a627a5: call     0x141443096
0000000140a627aa: movss    xmm3, dword ptr [rip + 0xd07c96]
0000000140a627b2: xorps    xmm1, xmm1
0000000140a627b5: comisd   xmm1, xmm0
0000000140a627b9: movaps   xmm2, xmm0
0000000140a627bc: jbe      0x140a627c8
0000000140a627be: movss    xmm0, dword ptr [rip + 0xd07cae]
0000000140a627c6: jmp      0x140a627cb
0000000140a627c8: movaps   xmm0, xmm3
0000000140a627cb: mulsd    xmm2, qword ptr [rip + 0xd07c8d]
0000000140a627d3: xorps    xmm1, xmm1
0000000140a627d6: cvtps2pd xmm0, xmm0
0000000140a627d9: divsd    xmm2, qword ptr [rip + 0xd07c6f]
0000000140a627e1: mulss    xmm6, xmm3
0000000140a627e5: addsd    xmm2, xmm0
0000000140a627e9: cvttsd2si eax, xmm2
0000000140a627ed: cvtsi2ss xmm1, eax
0000000140a627f1: mulss    xmm1, dword ptr [rip + 0xd5677b]
0000000140a627f9: mulss    xmm1, dword ptr [rip + 0xd07c3f]
0000000140a62801: comiss   xmm6, xmm1
0000000140a62804: jb       0x140a628a8
0000000140a6280a: mov      rcx, rdi
0000000140a6280d: call     0x1411ac850
0000000140a62812: movss    xmm3, dword ptr [rsp + 0x28]
0000000140a62818: movaps   xmm6, xmm0
0000000140a6281b: movss    xmm2, dword ptr [rsp + 0x24]
0000000140a62821: mov      rcx, rdi
0000000140a62824: movss    xmm1, dword ptr [rsp + 0x20]
0000000140a6282a: mulss    xmm3, xmm6
0000000140a6282e: mulss    xmm2, xmm6
0000000140a62832: mulss    xmm1, xmm6
0000000140a62836: mulss    xmm3, xmm7
0000000140a6283a: mulss    xmm2, xmm10
0000000140a6283f: addss    xmm3, dword ptr [rdi + 8]
0000000140a62844: mulss    xmm1, xmm9
0000000140a62849: addss    xmm2, dword ptr [rdi + 4]
0000000140a6284e: addss    xmm1, dword ptr [rdi]
0000000140a62852: call     0x1411adb80
0000000140a62857: mov      rcx, rdi
0000000140a6285a: call     0x1411ac880
0000000140a6285f: comiss   xmm0, xmm8
0000000140a62863: jbe      0x140a628a2
0000000140a62865: lea      rdx, [rsp + 0x50]
0000000140a6286a: mov      rcx, rdi
0000000140a6286d: call     0x1411acc30
0000000140a62872: movaps   xmm1, xmm6
0000000140a62875: movsd    xmm0, qword ptr [rax]
0000000140a62879: mov      ecx, dword ptr [rax + 8]
0000000140a6287c: movsd    qword ptr [rdi], xmm0
0000000140a62880: movaps   xmm0, xmm6
0000000140a62883: mov      dword ptr [rdi + 8], ecx
0000000140a62886: mulss    xmm6, dword ptr [rdi]
0000000140a6288a: mulss    xmm1, dword ptr [rdi + 4]
0000000140a6288f: mulss    xmm0, dword ptr [rdi + 8]
0000000140a62894: movss    dword ptr [rdi], xmm6
0000000140a62898: movss    dword ptr [rdi + 4], xmm1
0000000140a6289d: movss    dword ptr [rdi + 8], xmm0
0000000140a628a2: mov      r15d, 1
0000000140a628a8: mov      eax, r15d
0000000140a628ab: mov      rcx, qword ptr [rbp - 0x41]
0000000140a628af: xor      rcx, rsp
0000000140a628b2: call     0x141441dc0
0000000140a628b7: lea      r11, [rsp + 0x100]
0000000140a628bf: mov      rbx, qword ptr [r11 + 0x48]
0000000140a628c3: movaps   xmm6, xmmword ptr [r11 - 0x10]
0000000140a628c8: movaps   xmm7, xmmword ptr [r11 - 0x20]
0000000140a628cd: movaps   xmm8, xmmword ptr [r11 - 0x30]
0000000140a628d2: movaps   xmm9, xmmword ptr [r11 - 0x40]
0000000140a628d7: movaps   xmm10, xmmword ptr [r11 - 0x50]
0000000140a628dc: mov      rsp, r11
0000000140a628df: pop      r15
0000000140a628e1: pop      r14
0000000140a628e3: pop      r13
0000000140a628e5: pop      r12
0000000140a628e7: pop      rdi
0000000140a628e8: pop      rsi
0000000140a628e9: pop      rbp
0000000140a628ea: ret      
