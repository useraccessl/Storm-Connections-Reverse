0000000141384fe0: mov      qword ptr [rsp + 0x18], rbx
0000000141384fe5: push     rbp
0000000141384fe6: lea      rbp, [rsp - 0x57]
0000000141384feb: sub      rsp, 0xd0
0000000141384ff2: mov      rax, qword ptr [rip + 0xd613cf]
0000000141384ff9: xor      rax, rsp
0000000141384ffc: mov      qword ptr [rbp + 0x47], rax
0000000141385000: cmp      qword ptr [rcx + 0xe0], 0
0000000141385008: mov      rbx, rcx
000000014138500b: je       0x1413851ce
0000000141385011: mov      eax, dword ptr [rcx + 0x18]
0000000141385014: sub      eax, 3
0000000141385017: cmp      eax, 1
000000014138501a: jbe      0x1413851ce
0000000141385020: lea      rcx, [rbp - 0x39]
0000000141385024: mov      qword ptr [rsp + 0xe8], rdi
000000014138502c: call     0x14127e6d0
0000000141385031: mov      rcx, qword ptr [rbx + 0x40]
0000000141385035: test     rcx, rcx
0000000141385038: je       0x141385090
000000014138503a: mov      rax, qword ptr [rcx]
000000014138503d: call     qword ptr [rax + 0x28]
0000000141385040: mov      rcx, qword ptr [rbx + 0x40]
0000000141385044: lea      rdx, [rbp - 0x49]
0000000141385048: movzx    edi, byte ptr [rcx + 0x120]
000000014138504f: shl      rdi, 6
0000000141385053: add      rdi, rcx
0000000141385056: lea      rcx, [rdi + 0x7c]
000000014138505a: call     0x141283ee0
000000014138505f: movsd    xmm0, qword ptr [rax]
0000000141385063: movsd    qword ptr [rbx + 0xe8], xmm0
000000014138506b: mov      eax, dword ptr [rax + 8]
000000014138506e: mov      dword ptr [rbx + 0xf0], eax
0000000141385074: mov      rax, qword ptr [rbx + 0xe0]
000000014138507b: cmp      byte ptr [rax + 1], 0
000000014138507f: jne      0x1413850d9
0000000141385081: lea      rdx, [rdi + 0x7c]
0000000141385085: lea      rcx, [rbp - 0x39]
0000000141385089: call     0x14127e710
000000014138508e: jmp      0x1413850d9
0000000141385090: cmp      dword ptr [rbx + 0xc4], 3
0000000141385097: jne      0x1413850b4
0000000141385099: lea      rdx, [rbx + 0x50]
000000014138509d: lea      rcx, [rbp + 7]
00000001413850a1: call     0x14127e3b0
00000001413850a6: mov      rdx, rax
00000001413850a9: lea      rcx, [rbp - 0x39]
00000001413850ad: call     0x14127e710
00000001413850b2: jmp      0x1413850d9
00000001413850b4: movsd    xmm0, qword ptr [rbx + 0x90]
00000001413850bc: lea      rcx, [rbp - 0x39]
00000001413850c0: mov      eax, dword ptr [rbx + 0x98]
00000001413850c6: movsd    qword ptr [rbx + 0xe8], xmm0
00000001413850ce: mov      dword ptr [rbx + 0xf0], eax
00000001413850d4: call     0x1412826b0
00000001413850d9: mov      rcx, qword ptr [rbx + 0xc8]
00000001413850e0: call     0x141214650
00000001413850e5: comiss   xmm0, dword ptr [rip + 0x4db45c]
00000001413850ec: mov      rdi, qword ptr [rsp + 0xe8]
00000001413850f4: jbe      0x1413851b3
00000001413850fa: xorps    xmm3, xmm3
00000001413850fd: lea      rcx, [rbp - 0x59]
0000000141385101: xorps    xmm2, xmm2
0000000141385104: xorps    xmm1, xmm1
0000000141385107: call     0x1411ab440
000000014138510c: mov      rcx, qword ptr [rbx + 0xc8]
0000000141385113: mov      rax, qword ptr [rbx + 0xe0]
000000014138511a: movss    xmm3, dword ptr [rcx + 8]
000000014138511f: cmp      byte ptr [rax + 1], 0
0000000141385123: movss    xmm2, dword ptr [rcx + 4]
0000000141385128: movss    xmm1, dword ptr [rcx]
000000014138512c: lea      rcx, [rbp - 0x49]
0000000141385130: jne      0x14138517d
0000000141385132: call     0x1411ab440
0000000141385137: movsd    xmm0, qword ptr [rbp - 0x49]
000000014138513c: lea      rcx, [rbp - 0x59]
0000000141385140: mov      eax, dword ptr [rbp - 0x41]
0000000141385143: movsd    qword ptr [rbp - 0x59], xmm0
0000000141385148: mov      dword ptr [rbp - 0x51], eax
000000014138514b: call     0x1411acbb0
0000000141385150: lea      r8, [rbp - 0x59]
0000000141385154: lea      rdx, [rbp - 0x49]
0000000141385158: lea      rcx, [rbp - 0x39]
000000014138515c: call     0x141283c40
0000000141385161: lea      rcx, [rbx + 0xf4]
0000000141385168: movsd    xmm0, qword ptr [rax]
000000014138516c: movsd    qword ptr [rbp - 0x59], xmm0
0000000141385171: mov      edx, dword ptr [rax + 8]
0000000141385174: movsd    qword ptr [rcx], xmm0
0000000141385178: mov      dword ptr [rcx + 8], edx
000000014138517b: jmp      0x1413851ba
000000014138517d: call     0x1411ab440
0000000141385182: movsd    xmm0, qword ptr [rbp - 0x49]
0000000141385187: lea      rcx, [rbp - 0x59]
000000014138518b: mov      eax, dword ptr [rbp - 0x41]
000000014138518e: movsd    qword ptr [rbp - 0x59], xmm0
0000000141385193: mov      dword ptr [rbp - 0x51], eax
0000000141385196: call     0x1411acbb0
000000014138519b: movsd    xmm0, qword ptr [rbp - 0x59]
00000001413851a0: lea      rcx, [rbx + 0xf4]
00000001413851a7: mov      edx, dword ptr [rbp - 0x51]
00000001413851aa: movsd    qword ptr [rcx], xmm0
00000001413851ae: mov      dword ptr [rcx + 8], edx
00000001413851b1: jmp      0x1413851ba
00000001413851b3: lea      rcx, [rbx + 0xf4]
00000001413851ba: call     0x1411ac850
00000001413851bf: movss    dword ptr [rbx + 0x100], xmm0
00000001413851c7: mov      eax, 1
00000001413851cc: jmp      0x1413851d0
00000001413851ce: xor      eax, eax
00000001413851d0: mov      rcx, qword ptr [rbp + 0x47]
00000001413851d4: xor      rcx, rsp
00000001413851d7: call     0x141441dc0
00000001413851dc: mov      rbx, qword ptr [rsp + 0xf0]
00000001413851e4: add      rsp, 0xd0
00000001413851eb: pop      rbp
00000001413851ec: ret      
00000001413851ed: int3     
00000001413851ee: int3     
00000001413851ef: int3     
00000001413851f0: push     rbx
00000001413851f2: sub      rsp, 0x20
00000001413851f6: mov      rbx, rcx
00000001413851f9: cmp      qword ptr [rcx + 0xe0], 0
0000000141385201: je       0x141385236
0000000141385203: mov      rdx, qword ptr gs:[0x58]
000000014138520c: mov      eax, dword ptr [rip + 0x83cd9fe]
0000000141385212: mov      ecx, 0x3428
0000000141385217: mov      r8, qword ptr [rdx + rax*8]
000000014138521b: mov      eax, dword ptr [rcx + r8]
000000014138521f: cmp      dword ptr [rip + 0xde2623], eax
0000000141385225: jg       0x141385243
0000000141385227: mov      rdx, rbx
000000014138522a: lea      rcx, [rip + 0xde24ef]
0000000141385231: call     0x1412781f0
0000000141385236: mov      rcx, rbx
0000000141385239: add      rsp, 0x20
000000014138523d: pop      rbx
000000014138523e: jmp      0x14131ad20
0000000141385243: lea      rcx, [rip + 0xde25fe]
000000014138524a: call     0x141441c00
000000014138524f: cmp      dword ptr [rip + 0xde25f2], -1
0000000141385256: jne      0x141385227
0000000141385258: lea      rcx, [rip + 0xde24c1]
000000014138525f: call     0x141274bd0
0000000141385264: lea      rcx, [rip + 0x3a4de5]
000000014138526b: call     0x1414419a8
0000000141385270: nop      
0000000141385271: lea      rcx, [rip + 0xde25d0]
0000000141385278: call     0x141441ba0
000000014138527d: jmp      0x141385227
000000014138527f: int3     
0000000141385280: mov      rax, qword ptr [rcx + 0xe0]
0000000141385287: movsx    eax, byte ptr [rax]
000000014138528a: ret      
000000014138528b: int3     
000000014138528c: int3     
000000014138528d: int3     
000000014138528e: int3     
000000014138528f: int3     
0000000141385290: mov      rax, qword ptr [rcx + 0xe0]
0000000141385297: test     rax, rax
000000014138529a: jne      0x14138529d
000000014138529c: ret      
000000014138529d: mov      eax, dword ptr [rax + 4]
00000001413852a0: ret      
00000001413852a1: int3     
00000001413852a2: int3     
00000001413852a3: int3     
00000001413852a4: int3     
00000001413852a5: int3     
00000001413852a6: int3     
00000001413852a7: int3     
00000001413852a8: int3     
00000001413852a9: int3     
00000001413852aa: int3     
00000001413852ab: int3     
00000001413852ac: int3     
00000001413852ad: int3     
00000001413852ae: int3     
00000001413852af: int3     
00000001413852b0: lea      rax, [rcx + 0xe8]
00000001413852b7: ret      
00000001413852b8: int3     
00000001413852b9: int3     
00000001413852ba: int3     
00000001413852bb: int3     
00000001413852bc: int3     
00000001413852bd: int3     
00000001413852be: int3     
00000001413852bf: int3     
00000001413852c0: lea      rax, [rcx + 0xf4]
00000001413852c7: ret      
00000001413852c8: int3     
00000001413852c9: int3     
00000001413852ca: int3     
00000001413852cb: int3     
00000001413852cc: int3     
00000001413852cd: int3     
00000001413852ce: int3     
00000001413852cf: int3     
00000001413852d0: mov      rax, qword ptr [rcx + 0xe0]
00000001413852d7: test     rax, rax
00000001413852da: je       0x1413852ea
00000001413852dc: movss    xmm0, dword ptr [rax + 8]
00000001413852e1: mulss    xmm0, dword ptr [rcx + 0x100]
00000001413852e9: ret      
00000001413852ea: xorps    xmm0, xmm0
00000001413852ed: ret      
00000001413852ee: int3     
00000001413852ef: int3     
00000001413852f0: mov      rax, qword ptr [rcx + 0xc8]
00000001413852f7: mov      eax, dword ptr [rax + 0xc]
00000001413852fa: ret      
00000001413852fb: int3     
00000001413852fc: int3     
00000001413852fd: int3     
00000001413852fe: int3     
00000001413852ff: int3     
