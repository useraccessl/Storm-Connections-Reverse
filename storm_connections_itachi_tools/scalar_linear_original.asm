00000001413677b0: mov      r9, qword ptr [rcx + 0x18]
00000001413677b4: mov      r10, rdx
00000001413677b7: xor      edx, edx
00000001413677b9: mov      eax, r8d
00000001413677bc: mov      ecx, dword ptr [r9]
00000001413677bf: div      ecx
00000001413677c1: mov      r11d, eax
00000001413677c4: test     edx, edx
00000001413677c6: jne      0x1413677d5
00000001413677c8: movss    xmm0, dword ptr [r9 + rax*4 + 4]
00000001413677cf: movss    dword ptr [r10], xmm0
00000001413677d4: ret      
00000001413677d5: xorps    xmm0, xmm0
00000001413677d8: mov      eax, edx
00000001413677da: cvtsi2ss xmm0, rcx
00000001413677df: xorps    xmm2, xmm2
00000001413677e2: cvtsi2ss xmm2, rax
00000001413677e7: lea      eax, [r11 + 1]
00000001413677eb: divss    xmm2, xmm0
00000001413677ef: movss    xmm0, dword ptr [rip + 0x3f9de9]
00000001413677f7: subss    xmm0, xmm2
00000001413677fb: movaps   xmm1, xmm2
00000001413677fe: mulss    xmm1, dword ptr [r9 + rax*4 + 4]
0000000141367805: mulss    xmm0, dword ptr [r9 + r11*4 + 4]
000000014136780c: addss    xmm1, xmm0
0000000141367810: movss    dword ptr [r10], xmm1
0000000141367815: ret      
0000000141367816: int3     
0000000141367817: int3     
0000000141367818: int3     
0000000141367819: int3     
000000014136781a: int3     
000000014136781b: int3     
000000014136781c: int3     
000000014136781d: int3     
000000014136781e: int3     
000000014136781f: int3     
0000000141367820: mov      r9, qword ptr [rcx + 0x18]
0000000141367824: mov      r10, rdx
0000000141367827: mov      eax, r8d
000000014136782a: xor      edx, edx
000000014136782c: div      dword ptr [r9]
000000014136782f: mov      eax, dword ptr [r9 + rax*4 + 4]
