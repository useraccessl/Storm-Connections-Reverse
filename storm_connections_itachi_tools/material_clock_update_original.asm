000000014129d760: mov      qword ptr [rsp + 8], rbx
000000014129d765: push     rdi
000000014129d766: sub      rsp, 0x50
000000014129d76a: mov      rdi, rcx
000000014129d76d: movaps   xmmword ptr [rsp + 0x40], xmm6
000000014129d772: mov      rcx, qword ptr [rip + 0x84addb7]
000000014129d779: movaps   xmmword ptr [rsp + 0x30], xmm7
000000014129d77e: mov      rax, qword ptr [rcx]
000000014129d781: call     qword ptr [rax + 8]
000000014129d784: mov      rcx, qword ptr [rip + 0x84adda5]
000000014129d78b: mov      rax, qword ptr [rcx]
000000014129d78e: call     qword ptr [rax + 0x10]
000000014129d791: movzx    eax, word ptr [rdi + 0x4a6]
000000014129d798: mov      ecx, 0x2000
000000014129d79d: movss    xmm3, dword ptr [rdi + 0x5c4]
000000014129d7a5: movss    xmm2, dword ptr [rdi + 0x5c0]
000000014129d7ad: movd     xmm7, eax
000000014129d7b1: movzx    eax, word ptr [rdi + 0x4a8]
000000014129d7b8: cvtdq2ps xmm7, xmm7
000000014129d7bb: movd     xmm6, eax
000000014129d7bf: movaps   xmm1, xmm7
000000014129d7c2: cvtdq2ps xmm6, xmm6
000000014129d7c5: divss    xmm1, xmm6
000000014129d7c9: call     0x141232850
000000014129d7ce: call     0x141232360
000000014129d7d3: movss    xmm0, dword ptr [rdi + 0x5cc]
000000014129d7db: movaps   xmm3, xmm6
000000014129d7de: movss    xmm1, dword ptr [rdi + 0x5c8]
000000014129d7e6: movaps   xmm2, xmm7
000000014129d7e9: movss    dword ptr [rsp + 0x28], xmm0
000000014129d7ef: xorps    xmm0, xmm0
000000014129d7f2: movss    dword ptr [rsp + 0x20], xmm1
000000014129d7f8: xorps    xmm1, xmm1
000000014129d7fb: call     0x14121c800
000000014129d800: movzx    eax, word ptr [rdi + 0x472]
000000014129d807: xorps    xmm2, xmm2
000000014129d80a: mov      rcx, qword ptr [rdi + 0x998]
000000014129d811: xorps    xmm1, xmm1
000000014129d814: movd     xmm0, eax
000000014129d818: movzx    eax, word ptr [rdi + 0x470]
000000014129d81f: cvtdq2ps xmm0, xmm0
000000014129d822: movd     xmm3, eax
000000014129d826: cvtdq2ps xmm3, xmm3
000000014129d829: movss    dword ptr [rsp + 0x20], xmm0
000000014129d82f: call     0x1412b84f0
000000014129d834: mov      rcx, qword ptr [rdi + 0x998]
000000014129d83b: movss    xmm0, dword ptr [rdi + 0x5cc]
000000014129d843: mov      eax, dword ptr [rdi + 0x5c8]
000000014129d849: movss    dword ptr [rcx + 0x25c], xmm0
000000014129d851: mov      dword ptr [rcx + 0x258], eax
000000014129d857: call     0x141284200
000000014129d85c: movss    xmm2, dword ptr [rip + 0x4ddba4]
000000014129d864: mov      rdx, rax
000000014129d867: mov      rcx, qword ptr [rdi + 0x998]
000000014129d86e: call     0x1412b78f0
000000014129d873: lea      rcx, [rdi + 0x968]
000000014129d87a: call     0x141350c00
000000014129d87f: mov      rax, qword ptr gs:[0x58]
000000014129d888: mov      ebx, dword ptr [rip + 0x84b5382]
000000014129d88e: mov      ecx, 0x342c
000000014129d893: mov      rax, qword ptr [rax + rbx*8]
000000014129d897: cmp      byte ptr [rcx + rax], 0
000000014129d89b: jne      0x14129d8a2
000000014129d89d: call     0x141441fb8
000000014129d8a2: mov      rax, qword ptr gs:[0x58]
000000014129d8ab: mov      ecx, 0x3400
000000014129d8b0: mov      rax, qword ptr [rax + rbx*8]
000000014129d8b4: mov      rcx, qword ptr [rcx + rax]
000000014129d8b8: call     0x1412b59b0
000000014129d8bd: test     rax, rax
000000014129d8c0: je       0x14129d8ca
000000014129d8c2: mov      rcx, rax
000000014129d8c5: call     0x1413533b0
000000014129d8ca: lea      rcx, [rdi + 0x888]
000000014129d8d1: call     0x14121c4b0
000000014129d8d6: lea      rcx, [rdi + 0x87c]
000000014129d8dd: call     0x14121c4e0
000000014129d8e2: mov      eax, dword ptr [rdi + 0x87c]
000000014129d8e8: lea      ecx, [rax + rax*2]
000000014129d8eb: mov      eax, dword ptr [rdi + 0x880]
000000014129d8f1: mov      dword ptr [rdi + 0x87c], ecx
000000014129d8f7: lea      ecx, [rax + rax*2]
000000014129d8fa: mov      dword ptr [rdi + 0x880], ecx
000000014129d900: call     0x1412240c0
000000014129d905: mov      rcx, rdi
000000014129d908: mov      qword ptr [rdi + 0x448], rax
000000014129d90f: call     0x1412a5cc0
000000014129d914: mov      rcx, rdi
000000014129d917: call     0x1412a5ca0
000000014129d91c: call     0x14121c8e0
000000014129d921: mov      eax, dword ptr [rdi + 0x954]
000000014129d927: mov      edx, 0x7fffffff
000000014129d92c: mov      ecx, dword ptr [rdi + 0x94c]
000000014129d932: mov      r8d, edx
000000014129d935: sub      r8d, eax
000000014129d938: cmp      r8d, ecx
000000014129d93b: jl       0x14129d941
000000014129d93d: add      eax, ecx
000000014129d93f: jmp      0x14129d948
000000014129d941: mov      eax, ecx
000000014129d943: sub      eax, r8d
000000014129d946: dec      eax
000000014129d948: mov      dword ptr [rdi + 0x954], eax
000000014129d94e: cmp      dword ptr [rdi + 0x95c], 0
000000014129d955: jne      0x14129d973
000000014129d957: mov      eax, dword ptr [rdi + 0x958]
000000014129d95d: sub      edx, eax
000000014129d95f: cmp      edx, ecx
000000014129d961: jl       0x14129d967
000000014129d963: add      eax, ecx
000000014129d965: jmp      0x14129d96d
000000014129d967: mov      eax, ecx
000000014129d969: sub      eax, edx
000000014129d96b: dec      eax
000000014129d96d: mov      dword ptr [rdi + 0x958], eax
000000014129d973: xor      eax, eax
000000014129d975: mov      dword ptr [rdi + 0x948], ecx
000000014129d97b: mov      dword ptr [rdi + 0x94c], eax
000000014129d981: xorps    xmm6, xmm6
000000014129d984: mov      word ptr [rdi + 0x950], ax
000000014129d98b: mov      eax, dword ptr [rdi + 0x448]
000000014129d991: sub      eax, dword ptr [rdi + 0x440]
000000014129d997: cvtsi2ss xmm6, rax
000000014129d99c: call     0x141224120
000000014129d9a1: divss    xmm6, xmm0
000000014129d9a5: movss    dword ptr [rdi + 0x460], xmm6
000000014129d9ad: call     0x14121c4f0
000000014129d9b2: mov      eax, eax
000000014129d9b4: xorps    xmm6, xmm6
000000014129d9b7: cvtsi2ss xmm6, rax
000000014129d9bc: call     0x1412241c0
000000014129d9c1: movss    xmm1, dword ptr [rip + 0x8f6dd7]
000000014129d9c9: divss    xmm6, xmm0
000000014129d9cd: movss    xmm0, dword ptr [rdi + 0x460]
000000014129d9d5: comiss   xmm0, xmm1
000000014129d9d8: movss    dword ptr [rdi + 0x464], xmm6
000000014129d9e0: jbe      0x14129d9ec
000000014129d9e2: mov      dword ptr [rdi + 0x460], 0x411fff97
000000014129d9ec: comiss   xmm6, xmm1
000000014129d9ef: jbe      0x14129d9fb
000000014129d9f1: mov      dword ptr [rdi + 0x464], 0x411fff97
000000014129d9fb: cmp      word ptr [rdi + 0x540], 0
000000014129da03: je       0x14129da8c
000000014129da09: call     0x14121c240
000000014129da0e: movss    xmm6, dword ptr [rip + 0x4c3bca]
000000014129da16: xorps    xmm2, xmm2
000000014129da19: movaps   xmm3, xmm6
000000014129da1c: xorps    xmm1, xmm1
000000014129da1f: xorps    xmm0, xmm0
000000014129da22: call     0x14121c710
000000014129da27: mov      ecx, 1
000000014129da2c: call     0x14121c250
000000014129da31: call     0x14121c450
000000014129da36: call     0x14121c8e0
000000014129da3b: call     0x14121c240
000000014129da40: movaps   xmm3, xmm6
000000014129da43: xorps    xmm2, xmm2
000000014129da46: xorps    xmm1, xmm1
000000014129da49: xorps    xmm0, xmm0
000000014129da4c: call     0x14121c710
000000014129da51: mov      ecx, 1
000000014129da56: call     0x14121c250
000000014129da5b: call     0x14121c450
000000014129da60: call     0x14121c8e0
000000014129da65: mov      rcx, qword ptr [rip + 0x846baac]
000000014129da6c: cmp      dword ptr [rcx + 0x590], 0
000000014129da73: je       0x14129da7a
000000014129da75: call     0x14129b9e0
000000014129da7a: mov      rcx, rdi
000000014129da7d: call     0x14129b510
000000014129da82: call     0x14121c8e0
000000014129da87: call     0x14121c8e0
000000014129da8c: mov      rbx, qword ptr [rsp + 0x60]
000000014129da91: movaps   xmm6, xmmword ptr [rsp + 0x40]
000000014129da96: movaps   xmm7, xmmword ptr [rsp + 0x30]
000000014129da9b: add      rsp, 0x50
000000014129da9f: pop      rdi
000000014129daa0: ret      
