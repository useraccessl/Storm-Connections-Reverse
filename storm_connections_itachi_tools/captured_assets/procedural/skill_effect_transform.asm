00000001405e8690: push     rbp
00000001405e8692: push     rbx
00000001405e8693: push     rdi
00000001405e8694: push     r12
00000001405e8696: lea      rbp, [rsp - 0x18]
00000001405e869b: sub      rsp, 0x118
00000001405e86a2: mov      rax, qword ptr [rip + 0x1afdd1f]
00000001405e86a9: xor      rax, rsp
00000001405e86ac: mov      qword ptr [rbp - 0x20], rax
00000001405e86b0: xor      eax, eax
00000001405e86b2: mov      rbx, rdx
00000001405e86b5: cmp      dword ptr [rcx + 0x108], eax
00000001405e86bb: mov      rdi, rcx
00000001405e86be: mov      edx, dword ptr [rcx + 0x10c]
00000001405e86c4: mov      r12d, r8d
00000001405e86c7: mov      rcx, qword ptr [rip + 0x1beedca]
00000001405e86ce: sete     al
00000001405e86d1: mov      dword ptr [rsp + 0x38], eax
00000001405e86d5: call     0x140a63f90
00000001405e86da: mov      qword ptr [rsp + 0x48], rax
00000001405e86df: mov      rcx, rax
00000001405e86e2: test     rax, rax
00000001405e86e5: jne      0x1405e8702
00000001405e86e7: lea      rcx, [rip + 0x12a67a2]
00000001405e86ee: call     0x14127bf80
00000001405e86f3: mov      dword ptr [rdi + 0x3a8], 1
00000001405e86fd: jmp      0x1405e9354
00000001405e8702: mov      eax, dword ptr [rdi + 0x148]
00000001405e8708: mov      qword ptr [rsp + 0x150], rsi
00000001405e8710: mov      qword ptr [rsp + 0x108], r14
00000001405e8718: mov      r14d, 1
00000001405e871e: mov      qword ptr [rsp + 0x100], r15
00000001405e8726: mov      r15, qword ptr [rcx + rax*8 + 0x360]
00000001405e872e: test     r15, r15
00000001405e8731: je       0x1405e92db
00000001405e8737: mov      eax, dword ptr [r15 + 0xf0]
00000001405e873e: mov      ecx, r14d
00000001405e8741: mov      qword ptr [rsp + 0x110], r13
00000001405e8749: mov      r13d, r14d
00000001405e874c: xor      r14d, r14d
00000001405e874f: mov      dword ptr [rsp + 0x30], ecx
00000001405e8753: test     eax, eax
00000001405e8755: je       0x1405e8fbe
00000001405e875b: movaps   xmmword ptr [rsp + 0xf0], xmm6
00000001405e8763: lea      rdx, [rip - 0x5e876a]
00000001405e876a: xorps    xmm6, xmm6
00000001405e876d: nop      dword ptr [rax]
00000001405e8770: cmp      dword ptr [rdi + 0x3a8], 0
00000001405e8777: jne      0x1405e8fb2
00000001405e877d: mov      eax, r14d
00000001405e8780: imul     rsi, rax, 0xf8
00000001405e8787: add      rsi, qword ptr [r15 + 0xf8]
00000001405e878e: movsxd   rax, dword ptr [rsi]
00000001405e8791: cmp      eax, 0xf
00000001405e8794: ja       0x1405e8fa9
00000001405e879a: mov      ecx, dword ptr [rdx + rax*4 + 0x5e9370]
00000001405e87a1: add      rcx, rdx
00000001405e87a4: jmp      rcx
00000001405e87a6: test     r12d, r12d
00000001405e87a9: je       0x1405e8fa9
00000001405e87af: cmp      dword ptr [rdi + 0x3ac], 0
00000001405e87b6: je       0x1405e87f3
00000001405e87b8: mov      rax, qword ptr [rdi]
00000001405e87bb: mov      r8, rbx
00000001405e87be: mov      rdx, rsi
00000001405e87c1: mov      rcx, rdi
00000001405e87c4: call     qword ptr [rax + 0x90]
00000001405e87ca: mov      dword ptr [rdi + 0x3ac], 0
00000001405e87d4: mov      ecx, dword ptr [rsp + 0x30]
00000001405e87d8: lea      rdx, [rip - 0x5e87df]
00000001405e87df: mov      eax, dword ptr [r15 + 0xf0]
00000001405e87e6: inc      r14d
00000001405e87e9: cmp      r14d, eax
00000001405e87ec: jb       0x1405e8770
00000001405e87ee: jmp      0x1405e8fb6
00000001405e87f3: lea      rcx, [rsi + 4]
00000001405e87f7: call     qword ptr [rip + 0x114d503]
00000001405e87fd: movss    xmm1, dword ptr [rip + 0x117b167]
00000001405e8805: xorps    xmm2, xmm2
00000001405e8808: mov      ecx, eax
00000001405e880a: mov      rax, qword ptr [rip + 0x9120d07]
00000001405e8811: cvtsi2ss xmm2, rcx
00000001405e8816: movzx    ecx, byte ptr [rax + 0x952]
00000001405e881d: movd     xmm0, ecx
00000001405e8821: cvtdq2ps xmm0, xmm0
00000001405e8824: divss    xmm1, xmm0
00000001405e8828: divss    xmm2, xmm1
00000001405e882c: cvttss2si rcx, xmm2
00000001405e8831: mov      ecx, ecx
00000001405e8833: cmp      qword ptr [rdi + 0x100], rcx
00000001405e883a: jne      0x1405e8850
00000001405e883c: mov      rax, qword ptr [rdi]
00000001405e883f: mov      r8, rbx
00000001405e8842: mov      rdx, rsi
00000001405e8845: mov      rcx, rdi
00000001405e8848: call     qword ptr [rax + 0x90]
00000001405e884e: jmp      0x1405e87d4
00000001405e8850: cmp      dword ptr [rdi + 0x480], 0
00000001405e8857: je       0x1405e8860
00000001405e8859: cmp      dword ptr [r15 + 0x14], 0
00000001405e885e: jne      0x1405e883c
00000001405e8860: cmp      dword ptr [rdi + 0x6e4], 0
00000001405e8867: je       0x1405e87d4
00000001405e886d: mov      r8, rsi
00000001405e8870: mov      rdx, rbx
00000001405e8873: mov      rcx, rdi
00000001405e8876: call     0x1405e12d0
00000001405e887b: jmp      0x1405e87d4
00000001405e8880: test     r12d, r12d
00000001405e8883: je       0x1405e8fa9
00000001405e8889: lea      rcx, [rsi + 4]
00000001405e888d: call     qword ptr [rip + 0x114d46d]
00000001405e8893: movss    xmm1, dword ptr [rip + 0x117b0d1]
00000001405e889b: xorps    xmm2, xmm2
00000001405e889e: mov      ecx, eax
00000001405e88a0: mov      rax, qword ptr [rip + 0x9120c71]
00000001405e88a7: cvtsi2ss xmm2, rcx
00000001405e88ac: movzx    ecx, byte ptr [rax + 0x952]
00000001405e88b3: movd     xmm0, ecx
00000001405e88b7: cvtdq2ps xmm0, xmm0
00000001405e88ba: divss    xmm1, xmm0
00000001405e88be: divss    xmm2, xmm1
00000001405e88c2: cvttss2si rax, xmm2
00000001405e88c7: test     eax, eax
00000001405e88c9: je       0x1405e8fa2
00000001405e88cf: mov      ecx, eax
00000001405e88d1: xor      edx, edx
00000001405e88d3: mov      rax, qword ptr [rdi + 0x100]
00000001405e88da: div      rcx
00000001405e88dd: test     rdx, rdx
00000001405e88e0: jne      0x1405e87d4
00000001405e88e6: jmp      0x1405e883c
00000001405e88eb: test     r12d, r12d
00000001405e88ee: je       0x1405e8abd
00000001405e88f4: mov      rcx, qword ptr [rdi + 0x140]
00000001405e88fb: test     rcx, rcx
00000001405e88fe: je       0x1405e8fa9
00000001405e8904: call     0x1412a3c00
00000001405e8909: test     eax, eax
00000001405e890b: je       0x1405e87d4
00000001405e8911: inc      dword ptr [rdi + 0x168]
00000001405e8917: mov      eax, dword ptr [rdi + 0x168]
00000001405e891d: cmp      eax, dword ptr [rsi + 0x4c]
00000001405e8920: jae      0x1405e883c
00000001405e8926: mov      rax, qword ptr [rdi + 0x140]
00000001405e892d: mov      dword ptr [rax + 0x3c], 0
00000001405e8934: jmp      0x1405e87d4
00000001405e8939: test     rbx, rbx
00000001405e893c: je       0x1405e8fa9
00000001405e8942: cmp      dword ptr [rbx], 1
00000001405e8945: jne      0x1405e8fa9
00000001405e894b: mov      eax, dword ptr [rbx + 0x1c]
00000001405e894e: mov      edx, 0
00000001405e8953: sub      eax, 5
00000001405e8956: mov      ecx, 3
00000001405e895b: test     eax, 0xfffffffb
00000001405e8960: mov      eax, 0x60
00000001405e8965: sete     dl
00000001405e8968: cmp      eax, 4
00000001405e896b: jbe      0x1405e8977
00000001405e896d: dec      rcx
00000001405e8970: sub      eax, 0x20
00000001405e8973: jns      0x1405e8968
00000001405e8975: jmp      0x1405e8982
00000001405e8977: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e897b: shr      eax, 4
00000001405e897e: and      al, 1
00000001405e8980: jne      0x1405e89f9
00000001405e8982: mov      ecx, 3
00000001405e8987: mov      eax, 0x60
00000001405e898c: nop      dword ptr [rax]
00000001405e8990: cmp      eax, 5
00000001405e8993: jbe      0x1405e899f
00000001405e8995: dec      rcx
00000001405e8998: sub      eax, 0x20
00000001405e899b: jns      0x1405e8990
00000001405e899d: jmp      0x1405e89aa
00000001405e899f: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e89a3: shr      eax, 5
00000001405e89a6: and      al, 1
00000001405e89a8: jne      0x1405e89f9
00000001405e89aa: mov      ecx, 3
00000001405e89af: mov      eax, 0x60
00000001405e89b4: cmp      eax, 6
00000001405e89b7: jbe      0x1405e89c3
00000001405e89b9: dec      rcx
00000001405e89bc: sub      eax, 0x20
00000001405e89bf: jns      0x1405e89b4
00000001405e89c1: jmp      0x1405e89ce
00000001405e89c3: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e89c7: shr      eax, 6
00000001405e89ca: and      al, 1
00000001405e89cc: jne      0x1405e89f9
00000001405e89ce: mov      ecx, 3
00000001405e89d3: mov      eax, 0x60
00000001405e89d8: cmp      eax, 7
00000001405e89db: jbe      0x1405e89ea
00000001405e89dd: dec      rcx
00000001405e89e0: sub      eax, 0x20
00000001405e89e3: jns      0x1405e89d8
00000001405e89e5: jmp      0x1405e87d4
00000001405e89ea: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e89ee: shr      eax, 7
00000001405e89f1: and      al, 1
00000001405e89f3: je       0x1405e87d4
00000001405e89f9: test     edx, edx
00000001405e89fb: je       0x1405e87d4
00000001405e8a01: mov      rax, qword ptr [rdi]
00000001405e8a04: mov      r8, rbx
00000001405e8a07: mov      rdx, rsi
00000001405e8a0a: mov      rcx, rdi
00000001405e8a0d: call     qword ptr [rax + 0x90]
00000001405e8a13: xor      ecx, ecx
00000001405e8a15: mov      dword ptr [rsp + 0x30], ecx
00000001405e8a19: jmp      0x1405e87d8
00000001405e8a1e: test     rbx, rbx
00000001405e8a21: je       0x1405e8abd
00000001405e8a27: cmp      dword ptr [rbx], 1
00000001405e8a2a: jne      0x1405e8abd
00000001405e8a30: mov      ecx, 3
00000001405e8a35: mov      eax, 0x60
00000001405e8a3a: nop      word ptr [rax + rax]
00000001405e8a40: cmp      eax, 4
00000001405e8a43: jbe      0x1405e8a4f
00000001405e8a45: dec      rcx
00000001405e8a48: sub      eax, 0x20
00000001405e8a4b: jns      0x1405e8a40
00000001405e8a4d: jmp      0x1405e8a5a
00000001405e8a4f: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e8a53: shr      eax, 4
00000001405e8a56: and      al, 1
00000001405e8a58: jne      0x1405e8ad1
00000001405e8a5a: mov      ecx, 3
00000001405e8a5f: mov      eax, 0x60
00000001405e8a64: cmp      eax, 5
00000001405e8a67: jbe      0x1405e8a73
00000001405e8a69: dec      rcx
00000001405e8a6c: sub      eax, 0x20
00000001405e8a6f: jns      0x1405e8a64
00000001405e8a71: jmp      0x1405e8a7e
00000001405e8a73: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e8a77: shr      eax, 5
00000001405e8a7a: and      al, 1
00000001405e8a7c: jne      0x1405e8ad1
00000001405e8a7e: mov      ecx, 3
00000001405e8a83: mov      eax, 0x60
00000001405e8a88: cmp      eax, 6
00000001405e8a8b: jbe      0x1405e8a97
00000001405e8a8d: dec      rcx
00000001405e8a90: sub      eax, 0x20
00000001405e8a93: jns      0x1405e8a88
00000001405e8a95: jmp      0x1405e8aa2
00000001405e8a97: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e8a9b: shr      eax, 6
00000001405e8a9e: and      al, 1
00000001405e8aa0: jne      0x1405e8ad1
00000001405e8aa2: mov      ecx, 3
00000001405e8aa7: mov      eax, 0x60
00000001405e8aac: nop      dword ptr [rax]
00000001405e8ab0: cmp      eax, 7
00000001405e8ab3: jbe      0x1405e8ac6
00000001405e8ab5: dec      rcx
00000001405e8ab8: sub      eax, 0x20
00000001405e8abb: jns      0x1405e8ab0
00000001405e8abd: mov      ecx, dword ptr [rsp + 0x30]
00000001405e8ac1: jmp      0x1405e87df
00000001405e8ac6: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e8aca: shr      eax, 7
00000001405e8acd: and      al, 1
00000001405e8acf: je       0x1405e8abd
00000001405e8ad1: cmp      dword ptr [rbx + 0x1c], 4
00000001405e8ad5: jne      0x1405e8abd
00000001405e8ad7: mov      rax, qword ptr [rdi]
00000001405e8ada: mov      r8, rbx
00000001405e8add: mov      rdx, rsi
00000001405e8ae0: mov      rcx, rdi
00000001405e8ae3: call     qword ptr [rax + 0x90]
00000001405e8ae9: xor      ecx, ecx
00000001405e8aeb: mov      dword ptr [rsp + 0x30], ecx
00000001405e8aef: jmp      0x1405e87d8
00000001405e8af4: test     rbx, rbx
00000001405e8af7: je       0x1405e8fa9
00000001405e8afd: mov      edx, dword ptr [rbx]
00000001405e8aff: mov      ecx, dword ptr [rbx + 0x20]
00000001405e8b02: cmp      edx, 3
00000001405e8b05: jne      0x1405e87d4
00000001405e8b0b: test     cl, 2
00000001405e8b0e: je       0x1405e8b1e
00000001405e8b10: mov      eax, ecx
00000001405e8b12: and      eax, 0xf0f0f0
00000001405e8b17: cmp      eax, 0xe0e000
00000001405e8b1c: je       0x1405e8b42
00000001405e8b1e: cmp      edx, 3
00000001405e8b21: jne      0x1405e87d4
00000001405e8b27: test     cl, 2
00000001405e8b2a: je       0x1405e87d4
00000001405e8b30: and      ecx, 0xf0f0f0
00000001405e8b36: cmp      ecx, 0xe0a000
00000001405e8b3c: jne      0x1405e87d4
00000001405e8b42: mov      edx, dword ptr [rbx + 0x18]
00000001405e8b45: mov      rcx, rdi
00000001405e8b48: call     0x1405e15c0
00000001405e8b4d: test     eax, eax
00000001405e8b4f: je       0x1405e8b63
00000001405e8b51: mov      rax, qword ptr [rdi]
00000001405e8b54: mov      r8, rbx
00000001405e8b57: mov      rdx, rsi
00000001405e8b5a: mov      rcx, rdi
00000001405e8b5d: call     qword ptr [rax + 0x90]
00000001405e8b63: xor      r13d, r13d
00000001405e8b66: jmp      0x1405e87d4
00000001405e8b6b: test     rbx, rbx
00000001405e8b6e: je       0x1405e8fa9
00000001405e8b74: mov      edx, dword ptr [rbx]
00000001405e8b76: mov      ecx, dword ptr [rbx + 0x20]
00000001405e8b79: cmp      edx, 3
00000001405e8b7c: jne      0x1405e87d4
00000001405e8b82: test     cl, 2
00000001405e8b85: je       0x1405e8b95
00000001405e8b87: mov      eax, ecx
00000001405e8b89: and      eax, 0xf0f0f0
00000001405e8b8e: cmp      eax, 0x3060
00000001405e8b93: je       0x1405e8b42
00000001405e8b95: cmp      edx, 3
00000001405e8b98: jne      0x1405e87d4
00000001405e8b9e: test     cl, 2
00000001405e8ba1: je       0x1405e8bb1
00000001405e8ba3: mov      eax, ecx
00000001405e8ba5: and      eax, 0xf0f0f0
00000001405e8baa: cmp      eax, 0x90b0c0
00000001405e8baf: je       0x1405e8b42
00000001405e8bb1: cmp      edx, 3
00000001405e8bb4: jne      0x1405e87d4
00000001405e8bba: test     cl, 2
00000001405e8bbd: je       0x1405e87d4
00000001405e8bc3: and      ecx, 0xf0f0f0
00000001405e8bc9: cmp      ecx, 0x60c0
00000001405e8bcf: jmp      0x1405e8b3c
00000001405e8bd4: test     rbx, rbx
00000001405e8bd7: je       0x1405e8fa9
00000001405e8bdd: cmp      dword ptr [rbx], 3
00000001405e8be0: mov      eax, dword ptr [rbx + 0x20]
00000001405e8be3: jne      0x1405e8fa9
00000001405e8be9: test     al, 2
00000001405e8beb: je       0x1405e8fa9
00000001405e8bf1: and      eax, 0xf0f0f0
00000001405e8bf6: cmp      eax, 0x606060
00000001405e8bfb: jne      0x1405e8fa9
00000001405e8c01: jmp      0x1405e8b42
00000001405e8c06: test     rbx, rbx
00000001405e8c09: je       0x1405e8abd
00000001405e8c0f: cmp      dword ptr [rbx], 3
00000001405e8c12: mov      eax, dword ptr [rbx + 0x20]
00000001405e8c15: jne      0x1405e8abd
00000001405e8c1b: test     al, 2
00000001405e8c1d: je       0x1405e8abd
00000001405e8c23: and      eax, 0xf0f0f0
00000001405e8c28: cmp      eax, 0x5000
00000001405e8c2d: jne      0x1405e8abd
00000001405e8c33: jmp      0x1405e8b42
00000001405e8c38: test     rbx, rbx
00000001405e8c3b: je       0x1405e8abd
00000001405e8c41: cmp      dword ptr [rbx], 3
00000001405e8c44: mov      eax, dword ptr [rbx + 0x20]
00000001405e8c47: jne      0x1405e8abd
00000001405e8c4d: test     al, 2
00000001405e8c4f: je       0x1405e8abd
00000001405e8c55: and      eax, 0xf0f0f0
00000001405e8c5a: cmp      eax, 0x404040
00000001405e8c5f: jne      0x1405e8abd
00000001405e8c65: jmp      0x1405e8b42
00000001405e8c6a: test     rbx, rbx
00000001405e8c6d: je       0x1405e8fa9
00000001405e8c73: mov      r8d, dword ptr [rbx]
00000001405e8c76: mov      edx, dword ptr [rbx + 0x20]
00000001405e8c79: cmp      r8d, 3
00000001405e8c7d: jne      0x1405e87d4
00000001405e8c83: mov      eax, edx
00000001405e8c85: and      eax, 0xf0f0f0
00000001405e8c8a: cmp      eax, 0xf0f0f0
00000001405e8c8f: sete     cl
00000001405e8c92: test     dl, 2
00000001405e8c95: setne    al
00000001405e8c98: test     al, cl
00000001405e8c9a: jne      0x1405e8b42
00000001405e8ca0: cmp      r8d, r8d
00000001405e8ca3: jne      0x1405e87d4
00000001405e8ca9: test     dl, 2
00000001405e8cac: je       0x1405e87d4
00000001405e8cb2: and      edx, 0xf0f0f0
00000001405e8cb8: cmp      edx, 0xc0c0c0
00000001405e8cbe: jmp      0x1405e8b3c
00000001405e8cc3: test     rbx, rbx
00000001405e8cc6: je       0x1405e8abd
00000001405e8ccc: mov      rax, qword ptr [rip + 0x1be078d]
00000001405e8cd3: test     rax, rax
00000001405e8cd6: je       0x1405e8dca
00000001405e8cdc: mov      ecx, dword ptr [rax + 8]
00000001405e8cdf: cmp      ecx, 0x407d23cf
00000001405e8ce5: jne      0x1405e8d2c
00000001405e8ce7: movss    xmm0, dword ptr [rbx + 0x28]
00000001405e8cec: ucomiss  xmm0, xmm6
00000001405e8cef: jp       0x1405e8dca
00000001405e8cf5: jne      0x1405e8dca
00000001405e8cfb: movss    xmm0, dword ptr [rbx + 0x2c]
00000001405e8d00: ucomiss  xmm0, xmm6
00000001405e8d03: jp       0x1405e8dca
00000001405e8d09: jne      0x1405e8dca
00000001405e8d0f: movss    xmm0, dword ptr [rbx + 0x30]
00000001405e8d14: ucomiss  xmm0, xmm6
00000001405e8d17: jp       0x1405e8dca
00000001405e8d1d: jne      0x1405e8dca
00000001405e8d23: mov      ecx, dword ptr [rsp + 0x30]
00000001405e8d27: jmp      0x1405e87df
00000001405e8d2c: cmp      ecx, 0x11470c3b
00000001405e8d32: jne      0x1405e8dca
00000001405e8d38: movss    xmm1, dword ptr [rbx + 0x28]
00000001405e8d3d: ucomiss  xmm1, dword ptr [rip + 0x12a660c]
00000001405e8d44: jp       0x1405e8d6c
00000001405e8d46: jne      0x1405e8d6c
00000001405e8d48: movss    xmm0, dword ptr [rbx + 0x2c]
00000001405e8d4d: ucomiss  xmm0, dword ptr [rip + 0x12a6620]
00000001405e8d54: jp       0x1405e8d6c
00000001405e8d56: jne      0x1405e8d6c
00000001405e8d58: movss    xmm0, dword ptr [rbx + 0x30]
00000001405e8d5d: ucomiss  xmm0, dword ptr [rip + 0x12a65fc]
00000001405e8d64: jp       0x1405e8d6c
00000001405e8d66: je       0x1405e8abd
00000001405e8d6c: ucomiss  xmm1, dword ptr [rip + 0x12a65e9]
00000001405e8d73: jp       0x1405e8d9b
00000001405e8d75: jne      0x1405e8d9b
00000001405e8d77: movss    xmm0, dword ptr [rbx + 0x2c]
00000001405e8d7c: ucomiss  xmm0, dword ptr [rip + 0x12a65d5]
00000001405e8d83: jp       0x1405e8d9b
00000001405e8d85: jne      0x1405e8d9b
00000001405e8d87: movss    xmm0, dword ptr [rbx + 0x30]
00000001405e8d8c: ucomiss  xmm0, dword ptr [rip + 0x12a65d1]
00000001405e8d93: jp       0x1405e8d9b
00000001405e8d95: je       0x1405e8abd
00000001405e8d9b: ucomiss  xmm1, dword ptr [rip + 0x12a65ce]
00000001405e8da2: jp       0x1405e8dca
00000001405e8da4: jne      0x1405e8dca
00000001405e8da6: movss    xmm0, dword ptr [rbx + 0x2c]
00000001405e8dab: ucomiss  xmm0, dword ptr [rip + 0x12a65b6]
00000001405e8db2: jp       0x1405e8dca
00000001405e8db4: jne      0x1405e8dca
00000001405e8db6: movss    xmm0, dword ptr [rbx + 0x30]
00000001405e8dbb: ucomiss  xmm0, dword ptr [rip + 0x12a6592]
00000001405e8dc2: jp       0x1405e8dca
00000001405e8dc4: je       0x1405e8abd
00000001405e8dca: cmp      dword ptr [rbx], 3
00000001405e8dcd: mov      eax, dword ptr [rbx + 0x20]
00000001405e8dd0: jne      0x1405e8fa9
00000001405e8dd6: test     al, 2
00000001405e8dd8: je       0x1405e8abd
00000001405e8dde: test     eax, 0x40010000
00000001405e8de3: je       0x1405e8fa9
00000001405e8de9: jmp      0x1405e8b42
00000001405e8dee: test     rbx, rbx
00000001405e8df1: je       0x1405e8abd
00000001405e8df7: cmp      dword ptr [rbx], 3
00000001405e8dfa: mov      eax, dword ptr [rbx + 0x20]
00000001405e8dfd: jne      0x1405e8abd
00000001405e8e03: test     al, 2
00000001405e8e05: je       0x1405e8abd
00000001405e8e0b: test     eax, 0x40010000
00000001405e8e10: je       0x1405e8abd
00000001405e8e16: mov      edx, dword ptr [rbx + 0x18]
00000001405e8e19: mov      rcx, rdi
00000001405e8e1c: call     0x1405e15c0
00000001405e8e21: test     eax, eax
00000001405e8e23: je       0x1405e8b63
00000001405e8e29: mov      rcx, qword ptr [rsp + 0x48]
00000001405e8e2e: lea      rdx, [rip + 0x12a6093]
00000001405e8e35: add      rcx, 8
00000001405e8e39: call     0x141299b80
00000001405e8e3e: test     eax, eax
00000001405e8e40: je       0x1405e8b51
00000001405e8e46: test     dword ptr [rbx + 0x20], 0x20000
00000001405e8e4d: jne      0x1405e8b51
00000001405e8e53: cmp      dword ptr [rbx + 0x18], 0
00000001405e8e57: jne      0x1405e87d4
00000001405e8e5d: jmp      0x1405e8b51
00000001405e8e62: test     rbx, rbx
00000001405e8e65: je       0x1405e8e8a
00000001405e8e67: cmp      dword ptr [rbx], 3
00000001405e8e6a: mov      eax, dword ptr [rbx + 0x20]
00000001405e8e6d: jne      0x1405e8abd
00000001405e8e73: test     al, 2
00000001405e8e75: je       0x1405e8abd
00000001405e8e7b: bt       eax, 0x1d
00000001405e8e7f: jae      0x1405e8abd
00000001405e8e85: jmp      0x1405e8b42
00000001405e8e8a: mov      rcx, qword ptr [rip + 0x1d4ce47]
00000001405e8e91: call     0x14109e1d0
00000001405e8e96: cmp      eax, 0x89
00000001405e8e9b: jne      0x1405e87d4
00000001405e8ea1: movss    xmm4, dword ptr [rdi + 0x78]
00000001405e8ea6: lea      rax, [rsp + 0x40]
00000001405e8eab: movss    xmm3, dword ptr [rdi + 0xf4]
00000001405e8eb3: lea      r9, [rbp - 0x30]
00000001405e8eb7: movss    xmm1, dword ptr [rdi + 0x70]
00000001405e8ebc: lea      r8, [rsp + 0x50]
00000001405e8ec1: movss    xmm2, dword ptr [rdi + 0x74]
00000001405e8ec6: lea      rdx, [rsp + 0x60]
00000001405e8ecb: mov      rcx, qword ptr [rip + 0x912104e]
00000001405e8ed2: movaps   xmm0, xmm4
00000001405e8ed5: mov      qword ptr [rsp + 0x28], rax
00000001405e8eda: subss    xmm0, xmm3
00000001405e8ede: addss    xmm4, xmm3
00000001405e8ee2: movss    dword ptr [rsp + 0x50], xmm1
00000001405e8ee8: lea      rax, [rsp + 0x70]
00000001405e8eed: movss    dword ptr [rsp + 0x54], xmm2
00000001405e8ef3: movss    dword ptr [rsp + 0x60], xmm1
00000001405e8ef9: movss    dword ptr [rsp + 0x64], xmm2
00000001405e8eff: movss    dword ptr [rsp + 0x58], xmm0
00000001405e8f05: movss    dword ptr [rsp + 0x68], xmm4
00000001405e8f0b: mov      qword ptr [rsp + 0x40], 0
00000001405e8f14: mov      qword ptr [rsp + 0x20], rax
00000001405e8f19: call     0x1412c1f20
00000001405e8f1e: test     eax, eax
00000001405e8f20: je       0x1405e87d4
00000001405e8f26: xorps    xmm0, xmm0
00000001405e8f29: lea      rcx, [rbp - 0x58]
00000001405e8f2d: xor      eax, eax
00000001405e8f2f: movaps   xmm3, xmm6
00000001405e8f32: movaps   xmm2, xmm6
00000001405e8f35: mov      qword ptr [rbp - 0x60], rax
00000001405e8f39: movaps   xmm1, xmm6
00000001405e8f3c: movups   xmmword ptr [rbp - 0x7c], xmm0
00000001405e8f40: call     0x1411ab440
00000001405e8f45: mov      rax, qword ptr [rsp + 0x40]
00000001405e8f4a: lea      rcx, [rbp - 0x58]
00000001405e8f4e: movss    xmm3, dword ptr [rsp + 0x78]
00000001405e8f54: movss    xmm2, dword ptr [rsp + 0x74]
00000001405e8f5a: movss    xmm1, dword ptr [rsp + 0x70]
00000001405e8f60: mov      qword ptr [rbp - 0x60], rax
00000001405e8f64: mov      dword ptr [rbp - 0x80], 3
00000001405e8f6b: call     0x1411adb80
00000001405e8f70: cmp      dword ptr [rdi + 0x4cc], 0
00000001405e8f77: jne      0x1405e8b63
00000001405e8f7d: mov      rax, qword ptr [rdi]
00000001405e8f80: lea      r8, [rbp - 0x80]
00000001405e8f84: mov      rdx, rsi
00000001405e8f87: mov      rcx, rdi
00000001405e8f8a: call     qword ptr [rax + 0x90]
00000001405e8f90: xor      r13d, r13d
00000001405e8f93: mov      dword ptr [rdi + 0x4cc], 1
00000001405e8f9d: jmp      0x1405e87d4
00000001405e8fa2: lea      rdx, [rip - 0x5e8fa9]
00000001405e8fa9: mov      ecx, dword ptr [rsp + 0x30]
00000001405e8fad: jmp      0x1405e87df
00000001405e8fb2: mov      ecx, dword ptr [rsp + 0x30]
00000001405e8fb6: movaps   xmm6, xmmword ptr [rsp + 0xf0]
00000001405e8fbe: xor      r14d, r14d
00000001405e8fc1: test     eax, eax
00000001405e8fc3: je       0x1405e918b
00000001405e8fc9: mov      r12d, dword ptr [rsp + 0x38]
00000001405e8fce: nop      
00000001405e8fd0: cmp      dword ptr [rdi + 0x3a8], 0
00000001405e8fd7: jne      0x1405e918b
00000001405e8fdd: mov      eax, r14d
00000001405e8fe0: imul     rsi, rax, 0xf8
00000001405e8fe7: add      rsi, qword ptr [r15 + 0xf8]
00000001405e8fee: mov      eax, dword ptr [rsi]
00000001405e8ff0: cmp      eax, 3
00000001405e8ff3: je       0x1405e90ac
00000001405e8ff9: cmp      eax, 6
00000001405e8ffc: je       0x1405e906f
00000001405e8ffe: cmp      eax, 0x10
00000001405e9001: jne      0x1405e9177
00000001405e9007: test     rbx, rbx
00000001405e900a: je       0x1405e9177
00000001405e9010: cmp      dword ptr [rbx], 2
00000001405e9013: jne      0x1405e9177
00000001405e9019: mov      ecx, r12d
00000001405e901c: call     0x140ad8880
00000001405e9021: test     rax, rax
00000001405e9024: je       0x1405e904c
00000001405e9026: cmp      dword ptr [rax + 0xe64], 0x57
00000001405e902d: jne      0x1405e904c
00000001405e902f: movss    xmm1, dword ptr [rdi + 0x1ec]
00000001405e9037: mov      rcx, rax
00000001405e903a: mulss    xmm1, dword ptr [rdi + 0x1b4]
00000001405e9042: call     0x14064df10
00000001405e9047: jmp      0x1405e9177
00000001405e904c: mov      edx, dword ptr [rdi + 0x10c]
00000001405e9052: mov      rcx, qword ptr [rip + 0x1bee43f]
00000001405e9059: call     0x140a63f90
00000001405e905e: mov      ecx, dword ptr [rax + 0x50]
00000001405e9061: cmp      dword ptr [rbx + 0x14], ecx
00000001405e9064: jb       0x1405e9177
00000001405e906a: jmp      0x1405e9165
00000001405e906f: test     r13d, r13d
00000001405e9072: je       0x1405e9177
00000001405e9078: test     rbx, rbx
00000001405e907b: je       0x1405e9177
00000001405e9081: cmp      dword ptr [rbx], 3
00000001405e9084: jne      0x1405e9177
00000001405e908a: test     byte ptr [rbx + 0x20], 2
00000001405e908e: je       0x1405e9177
00000001405e9094: mov      edx, dword ptr [rbx + 0x18]
00000001405e9097: mov      rcx, rdi
00000001405e909a: call     0x1405e15c0
00000001405e909f: test     eax, eax
00000001405e90a1: je       0x1405e9177
00000001405e90a7: jmp      0x1405e9165
00000001405e90ac: test     ecx, ecx
00000001405e90ae: je       0x1405e9177
00000001405e90b4: test     rbx, rbx
00000001405e90b7: je       0x1405e9177
00000001405e90bd: cmp      dword ptr [rbx], 1
00000001405e90c0: jne      0x1405e9177
00000001405e90c6: mov      ecx, 3
00000001405e90cb: mov      eax, 0x60
00000001405e90d0: cmp      eax, 4
00000001405e90d3: jbe      0x1405e90df
00000001405e90d5: dec      rcx
00000001405e90d8: sub      eax, 0x20
00000001405e90db: jns      0x1405e90d0
00000001405e90dd: jmp      0x1405e90ea
00000001405e90df: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e90e3: shr      eax, 4
00000001405e90e6: and      al, 1
00000001405e90e8: jne      0x1405e915a
00000001405e90ea: mov      ecx, 3
00000001405e90ef: mov      eax, 0x60
00000001405e90f4: cmp      eax, 5
00000001405e90f7: jbe      0x1405e9103
00000001405e90f9: dec      rcx
00000001405e90fc: sub      eax, 0x20
00000001405e90ff: jns      0x1405e90f4
00000001405e9101: jmp      0x1405e910e
00000001405e9103: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e9107: shr      eax, 5
00000001405e910a: and      al, 1
00000001405e910c: jne      0x1405e915a
00000001405e910e: mov      ecx, 3
00000001405e9113: mov      eax, 0x60
00000001405e9118: cmp      eax, 6
00000001405e911b: jbe      0x1405e9127
00000001405e911d: dec      rcx
00000001405e9120: sub      eax, 0x20
00000001405e9123: jns      0x1405e9118
00000001405e9125: jmp      0x1405e9132
00000001405e9127: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e912b: shr      eax, 6
00000001405e912e: and      al, 1
00000001405e9130: jne      0x1405e915a
00000001405e9132: mov      ecx, 3
00000001405e9137: mov      eax, 0x60
00000001405e913c: nop      dword ptr [rax]
00000001405e9140: cmp      eax, 7
00000001405e9143: jbe      0x1405e914f
00000001405e9145: dec      rcx
00000001405e9148: sub      eax, 0x20
00000001405e914b: jns      0x1405e9140
00000001405e914d: jmp      0x1405e9177
00000001405e914f: mov      eax, dword ptr [rbx + rcx*4 + 4]
00000001405e9153: shr      eax, 7
00000001405e9156: and      al, 1
00000001405e9158: je       0x1405e9177
00000001405e915a: mov      eax, dword ptr [rbx + 0x1c]
00000001405e915d: sub      eax, 3
00000001405e9160: cmp      eax, 1
00000001405e9163: jbe      0x1405e9177
00000001405e9165: mov      rax, qword ptr [rdi]
00000001405e9168: mov      r8, rbx
00000001405e916b: mov      rdx, rsi
00000001405e916e: mov      rcx, rdi
00000001405e9171: call     qword ptr [rax + 0x90]
00000001405e9177: mov      ecx, dword ptr [rsp + 0x30]
00000001405e917b: inc      r14d
00000001405e917e: cmp      r14d, dword ptr [r15 + 0xf0]
00000001405e9185: jb       0x1405e8fd0
00000001405e918b: cmp      dword ptr [rdi + 0x3a8], 0
00000001405e9192: mov      r13, qword ptr [rsp + 0x110]
00000001405e919a: jne      0x1405e92d5
00000001405e91a0: lea      rcx, [rdi + 0x410]
00000001405e91a7: call     0x140986060
00000001405e91ac: test     eax, eax
00000001405e91ae: jne      0x1405e91ef
00000001405e91b0: xor      esi, esi
00000001405e91b2: cmp      dword ptr [r15 + 0xf0], esi
00000001405e91b9: jbe      0x1405e91ef
00000001405e91bb: nop      dword ptr [rax + rax]
00000001405e91c0: mov      eax, esi
00000001405e91c2: imul     rdx, rax, 0xf8
00000001405e91c9: add      rdx, qword ptr [r15 + 0xf8]
00000001405e91d0: cmp      dword ptr [rdx], 0x11
00000001405e91d3: jne      0x1405e91e4
00000001405e91d5: mov      rax, qword ptr [rdi]
00000001405e91d8: mov      r8, rbx
00000001405e91db: mov      rcx, rdi
00000001405e91de: call     qword ptr [rax + 0x90]
00000001405e91e4: inc      esi
00000001405e91e6: cmp      esi, dword ptr [r15 + 0xf0]
00000001405e91ed: jb       0x1405e91c0
00000001405e91ef: cmp      dword ptr [rdi + 0x3a8], 0
00000001405e91f6: jne      0x1405e92d5
00000001405e91fc: mov      eax, dword ptr [rdi + 0x148]
00000001405e9202: mov      rsi, qword ptr [rsp + 0x48]
00000001405e9207: mov      rsi, qword ptr [rsi + rax*8 + 0x360]
00000001405e920f: test     rsi, rsi
00000001405e9212: je       0x1405e92d5
00000001405e9218: cmp      dword ptr [rsi + 0x108], 0
00000001405e921f: je       0x1405e9278
00000001405e9221: lea      rcx, [rdi + 0x448]
00000001405e9228: call     0x140986060
00000001405e922d: test     eax, eax
00000001405e922f: jne      0x1405e92d5
00000001405e9235: xor      r14d, r14d
00000001405e9238: cmp      dword ptr [rsi + 0xf0], r14d
00000001405e923f: jbe      0x1405e92d5
00000001405e9245: mov      eax, r14d
00000001405e9248: imul     rdx, rax, 0xf8
00000001405e924f: add      rdx, qword ptr [rsi + 0xf8]
00000001405e9256: cmp      dword ptr [rdx], 0x12
00000001405e9259: jne      0x1405e926a
00000001405e925b: mov      rax, qword ptr [rdi]
00000001405e925e: mov      r8, rbx
00000001405e9261: mov      rcx, rdi
00000001405e9264: call     qword ptr [rax + 0x90]
00000001405e926a: inc      r14d
00000001405e926d: cmp      r14d, dword ptr [rsi + 0xf0]
00000001405e9274: jb       0x1405e9245
00000001405e9276: jmp      0x1405e92d5
00000001405e9278: lea      rcx, [rdi + 0x410]
00000001405e927f: call     0x140986060
00000001405e9284: test     eax, eax
00000001405e9286: je       0x1405e9298
00000001405e9288: lea      rcx, [rdi + 0x448]
00000001405e928f: call     0x140986060
00000001405e9294: test     eax, eax
00000001405e9296: jne      0x1405e92d5
00000001405e9298: xor      r14d, r14d
00000001405e929b: cmp      dword ptr [rsi + 0xf0], r14d
00000001405e92a2: jbe      0x1405e92d5
00000001405e92a4: mov      eax, r14d
00000001405e92a7: imul     rdx, rax, 0xf8
00000001405e92ae: add      rdx, qword ptr [rsi + 0xf8]
00000001405e92b5: cmp      dword ptr [rdx], 0x12
00000001405e92b8: jne      0x1405e92c9
00000001405e92ba: mov      rax, qword ptr [rdi]
00000001405e92bd: mov      r8, rbx
00000001405e92c0: mov      rcx, rdi
00000001405e92c3: call     qword ptr [rax + 0x90]
00000001405e92c9: inc      r14d
00000001405e92cc: cmp      r14d, dword ptr [rsi + 0xf0]
00000001405e92d3: jb       0x1405e92a4
00000001405e92d5: mov      r14d, 1
00000001405e92db: mov      r15, qword ptr [rsp + 0x100]
00000001405e92e3: test     rbx, rbx
00000001405e92e6: je       0x1405e9344
00000001405e92e8: xor      esi, esi
00000001405e92ea: nop      word ptr [rax + rax]
00000001405e92f0: mov      ecx, dword ptr [rdi + 0x108]
00000001405e92f6: mov      edx, esi
00000001405e92f8: call     0x140ad88b0
00000001405e92fd: test     rax, rax
00000001405e9300: je       0x1405e931e
00000001405e9302: cmp      dword ptr [rax + 0xe64], 0x115
00000001405e930c: jne      0x1405e931e
00000001405e930e: mov      rdx, qword ptr [rax]
00000001405e9311: mov      rcx, rax
00000001405e9314: call     qword ptr [rdx + 0x1278]
00000001405e931a: test     eax, eax
00000001405e931c: jne      0x1405e9327
00000001405e931e: inc      esi
00000001405e9320: cmp      esi, 3
00000001405e9323: jl       0x1405e92f0
00000001405e9325: jmp      0x1405e9344
00000001405e9327: cmp      dword ptr [rbx], 3
00000001405e932a: mov      eax, dword ptr [rbx + 0x20]
00000001405e932d: jne      0x1405e933a
00000001405e932f: test     al, 2
00000001405e9331: je       0x1405e933a
00000001405e9333: test     eax, 0x40010000
00000001405e9338: jne      0x1405e933d
00000001405e933a: xor      r14d, r14d
00000001405e933d: mov      dword ptr [rdi + 0x6f4], r14d
00000001405e9344: mov      rsi, qword ptr [rsp + 0x150]
00000001405e934c: mov      r14, qword ptr [rsp + 0x108]
00000001405e9354: mov      rcx, qword ptr [rbp - 0x20]
00000001405e9358: xor      rcx, rsp
00000001405e935b: call     0x141441dc0
00000001405e9360: add      rsp, 0x118
00000001405e9367: pop      r12
00000001405e9369: pop      rdi
00000001405e936a: pop      rbx
00000001405e936b: pop      rbp
00000001405e936c: ret      
00000001405e936d: nop      dword ptr [rax]
00000001405e9370: cmpsb    byte ptr [rsi], byte ptr [rdi]
00000001405e9371: xchg     dword ptr [rsi], ebx
00000001405e9374: or       byte ptr [rax - 0x7714ffa2], 0x5e
00000001405e937b: add      byte ptr [rcx + 0x39005e8f], ch
00000001405e9381: mov      dword ptr [rsi], ebx
