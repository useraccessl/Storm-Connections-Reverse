00000001405e16a0: mov      rax, rsp
00000001405e16a3: mov      qword ptr [rax + 8], rbx
00000001405e16a7: mov      qword ptr [rax + 0x10], rsi
00000001405e16ab: mov      qword ptr [rax + 0x18], rdi
00000001405e16af: push     rbp
00000001405e16b0: push     r14
00000001405e16b2: push     r15
00000001405e16b4: lea      rbp, [rax - 0x5f]
00000001405e16b8: sub      rsp, 0xc0
00000001405e16bf: movaps   xmmword ptr [rax - 0x28], xmm6
00000001405e16c3: movaps   xmmword ptr [rax - 0x38], xmm7
00000001405e16c7: mov      r14, rdx
00000001405e16ca: mov      rdi, rcx
00000001405e16cd: mov      rax, qword ptr [rip + 0x9127e44]
00000001405e16d4: movzx    r8d, byte ptr [rax + 0x952]
00000001405e16dc: movd     xmm0, r8d
00000001405e16e1: cvtdq2ps xmm0, xmm0
00000001405e16e4: movss    xmm1, dword ptr [rip + 0x1182280]
00000001405e16ec: divss    xmm1, xmm0
00000001405e16f0: movss    xmm2, dword ptr [rip + 0x1234194]
00000001405e16f8: divss    xmm2, xmm1
00000001405e16fc: xor      ecx, ecx
00000001405e16fe: movss    xmm0, dword ptr [rip + 0x11c621a]
00000001405e1706: comiss   xmm2, xmm0
00000001405e1709: jb       0x1405e1721
00000001405e170b: subss    xmm2, xmm0
00000001405e170f: comiss   xmm2, xmm0
00000001405e1712: jae      0x1405e1721
00000001405e1714: movabs   rax, 0x8000000000000000
00000001405e171e: mov      rcx, rax
00000001405e1721: cvttss2si rax, xmm2
00000001405e1726: add      rax, rcx
00000001405e1729: cmp      qword ptr [rdi + 0x100], rax
00000001405e1730: jb       0x1405e193a
00000001405e1736: mov      ecx, dword ptr [rdi + 0x108]
00000001405e173c: call     0x140ad8880
00000001405e1741: mov      rsi, rax
00000001405e1744: test     rax, rax
00000001405e1747: je       0x1405e193a
00000001405e174d: cmp      dword ptr [rdi + 0x1d0], 0
00000001405e1754: je       0x1405e193a
00000001405e175a: xorps    xmm6, xmm6
00000001405e175d: cmp      word ptr [rdi + 0x1ac], -1
00000001405e1765: je       0x1405e1774
00000001405e1767: comiss   xmm6, dword ptr [rdi + 0x1b4]
00000001405e176e: jb       0x1405e193a
00000001405e1774: xor      r15d, r15d
00000001405e1777: mov      ebx, r15d
00000001405e177a: movss    xmm7, dword ptr [rip + 0x11a56ce]
00000001405e1782: movaps   xmm3, xmm6
00000001405e1785: movaps   xmm2, xmm6
00000001405e1788: movaps   xmm1, xmm6
00000001405e178b: lea      rcx, [rbp - 0x29]
00000001405e178f: call     0x1411ab440
00000001405e1794: movaps   xmm3, xmm6
00000001405e1797: movaps   xmm2, xmm6
00000001405e179a: movaps   xmm1, xmm6
00000001405e179d: lea      rcx, [rbp + 7]
00000001405e17a1: call     0x1411ab440
00000001405e17a6: movaps   xmm3, xmm6
00000001405e17a9: movaps   xmm2, xmm6
00000001405e17ac: movaps   xmm1, xmm6
00000001405e17af: lea      rcx, [rbp + 0x13]
00000001405e17b3: call     0x1411ab440
00000001405e17b8: mov      qword ptr [rbp + 0x1f], r15
00000001405e17bc: call     0x140145f60
00000001405e17c1: movsd    xmm0, qword ptr [rax]
00000001405e17c5: movsd    qword ptr [rbp + 0x13], xmm0
00000001405e17ca: mov      eax, dword ptr [rax + 8]
00000001405e17cd: mov      dword ptr [rbp + 0x1b], eax
00000001405e17d0: call     0x1400bfa80
00000001405e17d5: movsd    xmm0, qword ptr [rax]
00000001405e17d9: movsd    qword ptr [rbp + 7], xmm0
00000001405e17de: mov      eax, dword ptr [rax + 8]
00000001405e17e1: mov      dword ptr [rbp + 0xf], eax
00000001405e17e4: movss    xmm0, dword ptr [rsi + 0x70]
00000001405e17e9: subss    xmm0, dword ptr [rdi + 0x70]
00000001405e17ee: movss    dword ptr [rbp - 0x49], xmm0
00000001405e17f3: movss    xmm1, dword ptr [rsi + 0x74]
00000001405e17f8: subss    xmm1, dword ptr [rdi + 0x74]
00000001405e17fd: movss    dword ptr [rbp - 0x45], xmm1
00000001405e1802: movss    xmm0, dword ptr [rsi + 0x78]
00000001405e1807: subss    xmm0, dword ptr [rdi + 0x78]
00000001405e180c: movss    dword ptr [rbp - 0x41], xmm0
00000001405e1811: lea      rcx, [rbp - 0x49]
00000001405e1815: call     0x1411acbb0
00000001405e181a: mov      dword ptr [rbp - 0x41], 0
00000001405e1821: movaps   xmm3, xmm6
00000001405e1824: movaps   xmm2, xmm6
00000001405e1827: movaps   xmm1, xmm6
00000001405e182a: lea      rcx, [rbp - 0x19]
00000001405e182e: call     0x1411ab440
00000001405e1833: lea      rcx, [rbp - 0xd]
00000001405e1837: call     0x1412b2110
00000001405e183c: nop      
00000001405e183d: movd     xmm2, ebx
00000001405e1841: cvtdq2ps xmm2, xmm2
00000001405e1844: mulss    xmm2, xmm7
00000001405e1848: movss    xmm0, dword ptr [rbp - 0x49]
00000001405e184d: mulss    xmm0, xmm2
00000001405e1851: addss    xmm0, dword ptr [rdi + 0x70]
00000001405e1856: movss    dword ptr [rbp - 0x39], xmm0
00000001405e185b: movss    xmm1, dword ptr [rbp - 0x45]
00000001405e1860: mulss    xmm1, xmm2
00000001405e1864: addss    xmm1, dword ptr [rdi + 0x74]
00000001405e1869: movss    dword ptr [rbp - 0x35], xmm1
00000001405e186e: movss    xmm0, dword ptr [rbp - 0x41]
00000001405e1873: mulss    xmm0, xmm2
00000001405e1877: addss    xmm0, dword ptr [rdi + 0x78]
00000001405e187c: movss    dword ptr [rbp - 0x31], xmm0
00000001405e1881: lea      rdx, [rbp - 0x39]
00000001405e1885: lea      rcx, [rbp - 0xd]
00000001405e1889: call     0x1412b3280
00000001405e188e: movss    xmm1, dword ptr [rdi + 0xf8]
00000001405e1896: lea      rcx, [rbp - 0xd]
00000001405e189a: call     0x1412b2610
00000001405e189f: movsd    xmm0, qword ptr [rdi + 0xa0]
00000001405e18a7: movsd    qword ptr [rbp - 0x19], xmm0
00000001405e18ac: mov      eax, dword ptr [rdi + 0xa8]
00000001405e18b2: mov      dword ptr [rbp - 0x11], eax
00000001405e18b5: mov      rax, qword ptr [rsi]
00000001405e18b8: mov      dword ptr [rsp + 0x28], 0x10000
00000001405e18c0: mov      dword ptr [rsp + 0x20], r15d
00000001405e18c5: lea      r9, [rbp - 0x19]
00000001405e18c9: lea      r8, [rbp + 7]
00000001405e18cd: lea      rdx, [rbp - 0x29]
00000001405e18d1: mov      rcx, rsi
00000001405e18d4: call     qword ptr [rax + 0x1658]
00000001405e18da: test     eax, eax
00000001405e18dc: je       0x1405e18e7
00000001405e18de: test     dword ptr [rbp + 0x1f], 0x10000
00000001405e18e5: jne      0x1405e18ff
00000001405e18e7: lea      rcx, [rbp - 0xd]
00000001405e18eb: call     0x1412b2180
00000001405e18f0: inc      ebx
00000001405e18f2: cmp      ebx, 0x3e8
00000001405e18f8: jge      0x1405e193a
00000001405e18fa: jmp      0x1405e1782
00000001405e18ff: lea      rdx, [rip + 0x12ad9a2]
00000001405e1906: lea      rcx, [rip + 0x11b87c3]
00000001405e190d: call     0x14127bf80
00000001405e1912: lea      r8, [r14 + 8]
00000001405e1916: mov      edx, 0x258
00000001405e191b: lea      rcx, [rip + 0x12ad98e]
00000001405e1922: call     0x14127bf80
00000001405e1927: mov      dword ptr [rdi + 0x3a8], 1
00000001405e1931: lea      rcx, [rbp - 0xd]
00000001405e1935: call     0x1412b2180
00000001405e193a: lea      r11, [rsp + 0xc0]
00000001405e1942: mov      rbx, qword ptr [r11 + 0x20]
00000001405e1946: mov      rsi, qword ptr [r11 + 0x28]
00000001405e194a: mov      rdi, qword ptr [r11 + 0x30]
00000001405e194e: movaps   xmm6, xmmword ptr [r11 - 0x10]
00000001405e1953: movaps   xmm7, xmmword ptr [r11 - 0x20]
00000001405e1958: mov      rsp, r11
00000001405e195b: pop      r15
00000001405e195d: pop      r14
00000001405e195f: pop      rbp
00000001405e1960: ret      
