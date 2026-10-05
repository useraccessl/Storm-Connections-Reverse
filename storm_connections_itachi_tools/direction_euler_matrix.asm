00000001411ea620: mov      rax, rsp
00000001411ea623: push     rbx
00000001411ea624: sub      rsp, 0x90
00000001411ea62b: movaps   xmm0, xmmword ptr [rip + 0x5b494e]
00000001411ea632: mov      rbx, rcx
00000001411ea635: movaps   xmmword ptr [rax - 0x18], xmm6
00000001411ea639: movaps   xmm6, xmm2
00000001411ea63c: movaps   xmmword ptr [rax - 0x28], xmm7
00000001411ea640: movaps   xmm7, xmm3
00000001411ea643: movaps   xmmword ptr [rax - 0x38], xmm8
00000001411ea648: movaps   xmm8, xmm1
00000001411ea64c: movaps   xmmword ptr [rax - 0x48], xmm9
00000001411ea651: movaps   xmmword ptr [rax - 0x58], xmm10
00000001411ea656: movaps   xmmword ptr [rax - 0x68], xmm11
00000001411ea65b: movaps   xmmword ptr [rax - 0x78], xmm12
00000001411ea660: xor      eax, eax
00000001411ea662: mov      dword ptr [rcx + 0xc], eax
00000001411ea665: mov      dword ptr [rcx + 0x1c], eax
00000001411ea668: mov      dword ptr [rcx + 0x2c], eax
00000001411ea66b: movups   xmmword ptr [rcx + 0x30], xmm0
00000001411ea66f: movaps   xmm0, xmm2
00000001411ea672: call     0x1414430a2
00000001411ea677: movaps   xmm12, xmm0
00000001411ea67b: movaps   xmm0, xmm7
00000001411ea67e: call     0x1414430a2
00000001411ea683: movaps   xmm11, xmm0
00000001411ea687: movaps   xmm0, xmm8
00000001411ea68b: call     0x1414430a2
00000001411ea690: movaps   xmm9, xmm0
00000001411ea694: movaps   xmm0, xmm6
00000001411ea697: call     0x1414430a8
00000001411ea69c: movaps   xmm10, xmm0
00000001411ea6a0: movaps   xmm0, xmm7
00000001411ea6a3: call     0x1414430a8
00000001411ea6a8: movaps   xmm7, xmm0
00000001411ea6ab: movaps   xmm0, xmm8
00000001411ea6af: call     0x1414430a8
00000001411ea6b4: movaps   xmm6, xmm0
00000001411ea6b7: lea      r11, [rsp + 0x90]
00000001411ea6bf: movaps   xmm8, xmmword ptr [r11 - 0x30]
00000001411ea6c4: movaps   xmm2, xmm7
00000001411ea6c7: mulss    xmm2, xmm10
00000001411ea6cc: movaps   xmm3, xmm0
00000001411ea6cf: mov      rax, rbx
00000001411ea6d2: movaps   xmm0, xmm7
00000001411ea6d5: mulss    xmm3, xmm12
00000001411ea6da: mulss    xmm0, xmm9
00000001411ea6df: movaps   xmm5, xmm9
00000001411ea6e3: xorps    xmm3, xmmword ptr [rip + 0x576ab6]
00000001411ea6ea: mulss    xmm2, xmm6
00000001411ea6ee: mulss    xmm5, xmm11
00000001411ea6f3: movaps   xmm1, xmm5
00000001411ea6f6: mulss    xmm5, xmm10
00000001411ea6fb: subss    xmm1, xmm2
00000001411ea6ff: movaps   xmm2, xmm9
00000001411ea703: mulss    xmm2, xmm10
00000001411ea708: mulss    xmm9, xmm12
00000001411ea70d: movss    dword ptr [rbx], xmm1
00000001411ea711: movaps   xmm1, xmm10
00000001411ea715: movss    dword ptr [rbx + 4], xmm3
00000001411ea71a: mulss    xmm2, xmm7
00000001411ea71e: mulss    xmm1, xmm11
00000001411ea723: mulss    xmm1, xmm6
00000001411ea727: addss    xmm1, xmm0
00000001411ea72b: movaps   xmm0, xmm6
00000001411ea72e: mulss    xmm6, xmm7
00000001411ea732: mulss    xmm7, xmm12
00000001411ea737: movss    dword ptr [rbx + 8], xmm1
00000001411ea73c: subss    xmm6, xmm5
00000001411ea740: mulss    xmm0, xmm11
00000001411ea745: xorps    xmm7, xmmword ptr [rip + 0x576a54]
00000001411ea74c: mulss    xmm12, xmm11
00000001411ea751: movaps   xmm11, xmmword ptr [r11 - 0x60]
00000001411ea756: addss    xmm2, xmm0
00000001411ea75a: movss    dword ptr [rbx + 0x10], xmm2
00000001411ea75f: movss    dword ptr [rbx + 0x14], xmm9
00000001411ea765: movaps   xmm9, xmmword ptr [r11 - 0x40]
00000001411ea76a: movss    dword ptr [rbx + 0x18], xmm6
00000001411ea76f: movaps   xmm6, xmmword ptr [r11 - 0x10]
00000001411ea774: movss    dword ptr [rbx + 0x20], xmm7
00000001411ea779: movaps   xmm7, xmmword ptr [rsp + 0x70]
00000001411ea77e: movss    dword ptr [rbx + 0x24], xmm10
00000001411ea784: movaps   xmm10, xmmword ptr [r11 - 0x50]
00000001411ea789: movss    dword ptr [rbx + 0x28], xmm12
00000001411ea78f: movaps   xmm12, xmmword ptr [r11 - 0x70]
00000001411ea794: mov      rsp, r11
00000001411ea797: pop      rbx
00000001411ea798: ret      
