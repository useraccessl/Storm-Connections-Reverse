0000000141367040: mov      qword ptr [rsp + 0x10], rbx
0000000141367045: mov      qword ptr [rsp + 0x18], rsi
000000014136704a: push     rdi
000000014136704b: push     r14
000000014136704d: push     r15
000000014136704f: sub      rsp, 0xb0
0000000141367056: mov      rax, qword ptr [rip + 0xd7f36b]
000000014136705d: xor      rax, rsp
0000000141367060: mov      qword ptr [rsp + 0xa0], rax
0000000141367068: mov      r14, rcx
000000014136706b: xor      edi, edi
000000014136706d: mov      eax, dword ptr [rcx]
000000014136706f: add      eax, -5
0000000141367072: cmp      eax, 0x18
0000000141367075: ja       0x1413676e0
000000014136707b: cdqe     
000000014136707d: lea      rcx, [rip - 0x1367084]
0000000141367084: mov      r8d, dword ptr [rcx + rax*4 + 0x1367728]
000000014136708c: add      r8, rcx
000000014136708f: jmp      r8
0000000141367092: mov      r8d, 0x3e
0000000141367098: lea      rdx, [rip + 0x839e41]
000000014136709f: lea      ecx, [r8 - 0x1e]
00000001413670a3: call     0x141272600
00000001413670a8: mov      rcx, rax
00000001413670ab: mov      qword ptr [rsp + 0x20], rax
00000001413670b0: test     rax, rax
00000001413670b3: je       0x1413676c8
00000001413670b9: mov      rax, qword ptr [r14 + 8]
00000001413670bd: mov      word ptr [rcx + 8], di
00000001413670c1: mov      qword ptr [rcx + 0xc], rdi
00000001413670c5: lea      rdx, [rip + 0x839934]
00000001413670cc: mov      qword ptr [rcx], rdx
00000001413670cf: mov      qword ptr [rcx + 0x18], rax
00000001413670d3: mov      rdi, rcx
00000001413670d6: jmp      0x1413676c8
00000001413670db: mov      r8d, 0x41
00000001413670e1: lea      rdx, [rip + 0x839df8]
00000001413670e8: lea      ecx, [r8 - 0x19]
00000001413670ec: call     0x141272600
00000001413670f1: mov      rcx, rax
00000001413670f4: mov      qword ptr [rsp + 0x20], rax
00000001413670f9: test     rax, rax
00000001413670fc: je       0x1413676c8
0000000141367102: mov      rax, qword ptr [r14 + 8]
0000000141367106: mov      word ptr [rcx + 8], di
000000014136710a: mov      qword ptr [rcx + 0xc], rdi
000000014136710e: lea      rdx, [rip + 0x83993b]
0000000141367115: mov      qword ptr [rcx], rdx
0000000141367118: mov      qword ptr [rcx + 0x18], rax
000000014136711c: mov      qword ptr [rcx + 0x20], rax
0000000141367120: mov      rdi, rcx
0000000141367123: jmp      0x1413676c8
0000000141367128: mov      r8d, 0x44
000000014136712e: lea      rdx, [rip + 0x839dab]
0000000141367135: lea      ecx, [r8 - 0x24]
0000000141367139: call     0x141272600
000000014136713e: mov      rcx, rax
0000000141367141: mov      qword ptr [rsp + 0x20], rax
0000000141367146: test     rax, rax
0000000141367149: je       0x1413676c8
000000014136714f: mov      rax, qword ptr [r14 + 8]
0000000141367153: mov      word ptr [rcx + 8], di
0000000141367157: mov      qword ptr [rcx + 0xc], rdi
000000014136715b: lea      rdx, [rip + 0x83993e]
0000000141367162: mov      qword ptr [rcx], rdx
0000000141367165: mov      qword ptr [rcx + 0x18], rax
0000000141367169: mov      rdi, rcx
000000014136716c: jmp      0x1413676c8
0000000141367171: mov      r8d, 0x47
0000000141367177: lea      rdx, [rip + 0x839d62]
000000014136717e: lea      ecx, [r8 - 0x1f]
0000000141367182: call     0x141272600
0000000141367187: mov      rcx, rax
000000014136718a: mov      qword ptr [rsp + 0x20], rax
000000014136718f: test     rax, rax
0000000141367192: je       0x1413676c8
0000000141367198: mov      rax, qword ptr [r14 + 8]
000000014136719c: mov      word ptr [rcx + 8], di
00000001413671a0: mov      qword ptr [rcx + 0xc], rdi
00000001413671a4: lea      rdx, [rip + 0x838ef5]
00000001413671ab: mov      qword ptr [rcx], rdx
00000001413671ae: mov      qword ptr [rcx + 0x18], rax
00000001413671b2: mov      qword ptr [rcx + 0x20], rax
00000001413671b6: mov      rdi, rcx
00000001413671b9: jmp      0x1413676c8
00000001413671be: mov      r8d, 0x4a
00000001413671c4: lea      rdx, [rip + 0x839d15]
00000001413671cb: lea      ecx, [r8 - 0x22]
00000001413671cf: call     0x141272600
00000001413671d4: mov      qword ptr [rsp + 0x20], rax
00000001413671d9: test     rax, rax
00000001413671dc: je       0x1413671ed
00000001413671de: mov      rdx, qword ptr [r14 + 8]
00000001413671e2: mov      rcx, rax
00000001413671e5: call     0x141393c90
00000001413671ea: mov      rdi, rax
00000001413671ed: jmp      0x1413676c8
00000001413671f2: mov      r8d, 0x4d
00000001413671f8: lea      rdx, [rip + 0x839ce1]
00000001413671ff: lea      ecx, [r8 + 0x1b]
0000000141367203: call     0x141272600
0000000141367208: mov      r15, rax
000000014136720b: mov      qword ptr [rsp + 0x20], rax
0000000141367210: test     rax, rax
0000000141367213: je       0x1413672b3
0000000141367219: mov      rbx, qword ptr [r14 + 8]
000000014136721d: mov      word ptr [rax + 8], di
0000000141367221: mov      qword ptr [rax + 0xc], rdi
0000000141367225: lea      rax, [rip + 0x8398c4]
000000014136722c: mov      qword ptr [r15], rax
000000014136722f: lea      rcx, [r15 + 0x18]
0000000141367233: call     0x14127e6d0
0000000141367238: lea      rcx, [r15 + 0x58]
000000014136723c: call     0x1412aa0a0
0000000141367241: movss    xmm3, dword ptr [rbx]
0000000141367245: movss    xmm4, dword ptr [rip + 0x3fa59b]
000000014136724d: mulss    xmm3, xmm4
0000000141367251: movss    xmm0, dword ptr [rip + 0x3fa593]
0000000141367259: divss    xmm3, xmm0
000000014136725d: movss    xmm2, dword ptr [rbx + 4]
0000000141367262: mulss    xmm2, xmm4
0000000141367266: divss    xmm2, xmm0
000000014136726a: movss    xmm1, dword ptr [rbx + 8]
000000014136726f: mulss    xmm1, xmm4
0000000141367273: divss    xmm1, xmm0
0000000141367277: lea      rcx, [rsp + 0x60]
000000014136727c: call     0x14127fea0
0000000141367281: mov      rdx, rax
0000000141367284: lea      rcx, [r15 + 0x18]
0000000141367288: call     0x14127e710
000000014136728d: lea      rdx, [rsp + 0x38]
0000000141367292: lea      rcx, [r15 + 0x18]
0000000141367296: call     0x1412817c0
000000014136729b: mov      rcx, rax
000000014136729e: lea      rdx, [rsp + 0x28]
00000001413672a3: call     0x1412c5380
00000001413672a8: movups   xmm0, xmmword ptr [rax]
00000001413672ab: movups   xmmword ptr [r15 + 0x58], xmm0
00000001413672b0: mov      rdi, r15
00000001413672b3: jmp      0x1413676c8
00000001413672b8: mov      r8d, 0x50
00000001413672be: lea      rdx, [rip + 0x839c1b]
00000001413672c5: lea      ecx, [r8 - 0x18]
00000001413672c9: call     0x141272600
00000001413672ce: mov      qword ptr [rsp + 0x20], rax
00000001413672d3: test     rax, rax
00000001413672d6: je       0x1413672e7
00000001413672d8: mov      rdx, qword ptr [r14 + 8]
00000001413672dc: mov      rcx, rax
00000001413672df: call     0x141394220
00000001413672e4: mov      rdi, rax
00000001413672e7: jmp      0x1413676c8
00000001413672ec: mov      r8d, 0x53
00000001413672f2: lea      rdx, [rip + 0x839be7]
00000001413672f9: lea      ecx, [r8 - 0x2b]
00000001413672fd: call     0x141272600
0000000141367302: mov      qword ptr [rsp + 0x20], rax
0000000141367307: test     rax, rax
000000014136730a: je       0x14136731b
000000014136730c: mov      rdx, qword ptr [r14 + 8]
0000000141367310: mov      rcx, rax
0000000141367313: call     0x141391d20
0000000141367318: mov      rdi, rax
000000014136731b: jmp      0x1413676c8
0000000141367320: mov      r8d, 0x56
0000000141367326: lea      rdx, [rip + 0x839bb3]
000000014136732d: lea      ecx, [r8 - 0x36]
0000000141367331: call     0x141272600
0000000141367336: mov      rcx, rax
0000000141367339: mov      qword ptr [rsp + 0x20], rax
000000014136733e: test     rax, rax
0000000141367341: je       0x1413676c8
0000000141367347: mov      rax, qword ptr [r14 + 8]
000000014136734b: mov      word ptr [rcx + 8], di
000000014136734f: mov      qword ptr [rcx + 0xc], rdi
0000000141367353: lea      rdx, [rip + 0x8397e6]
000000014136735a: mov      qword ptr [rcx], rdx
000000014136735d: mov      qword ptr [rcx + 0x18], rax
0000000141367361: mov      rdi, rcx
0000000141367364: jmp      0x1413676c8
0000000141367369: mov      r8d, 0x59
000000014136736f: lea      rdx, [rip + 0x839b6a]
0000000141367376: lea      ecx, [r8 - 0x31]
000000014136737a: call     0x141272600
000000014136737f: mov      rcx, rax
0000000141367382: mov      qword ptr [rsp + 0x20], rax
0000000141367387: test     rax, rax
000000014136738a: je       0x1413676c8
0000000141367390: mov      rax, qword ptr [r14 + 8]
0000000141367394: mov      word ptr [rcx + 8], di
0000000141367398: mov      qword ptr [rcx + 0xc], rdi
000000014136739c: lea      rdx, [rip + 0x838d4d]
00000001413673a3: mov      qword ptr [rcx], rdx
00000001413673a6: mov      qword ptr [rcx + 0x18], rax
00000001413673aa: mov      qword ptr [rcx + 0x20], rax
00000001413673ae: mov      rdi, rcx
00000001413673b1: jmp      0x1413676c8
00000001413673b6: mov      r8d, 0x5d
00000001413673bc: lea      rdx, [rip + 0x839b1d]
00000001413673c3: lea      ecx, [r8 - 0x3d]
00000001413673c7: call     0x141272600
00000001413673cc: mov      rbx, rax
00000001413673cf: mov      qword ptr [rsp + 0x20], rax
00000001413673d4: test     rax, rax
00000001413673d7: je       0x1413673f2
00000001413673d9: mov      rdx, qword ptr [r14 + 8]
00000001413673dd: mov      rcx, rax
00000001413673e0: call     0x1413946b0
00000001413673e5: lea      rax, [rip + 0x8397a4]
00000001413673ec: mov      qword ptr [rbx], rax
00000001413673ef: mov      rdi, rbx
00000001413673f2: jmp      0x1413676c8
00000001413673f7: mov      r8d, 0x60
00000001413673fd: lea      rdx, [rip + 0x839adc]
0000000141367404: lea      ecx, [r8 - 0x40]
0000000141367408: call     0x141272600
000000014136740d: mov      qword ptr [rsp + 0x20], rax
0000000141367412: test     rax, rax
0000000141367415: je       0x141367426
0000000141367417: mov      rdx, qword ptr [r14 + 8]
000000014136741b: mov      rcx, rax
000000014136741e: call     0x141394c80
0000000141367423: mov      rdi, rax
0000000141367426: jmp      0x1413676c8
000000014136742b: mov      r8d, 0x63
0000000141367431: lea      rdx, [rip + 0x839aa8]
0000000141367438: lea      ecx, [r8 - 0x43]
000000014136743c: call     0x141272600
0000000141367441: mov      qword ptr [rsp + 0x20], rax
0000000141367446: test     rax, rax
0000000141367449: je       0x14136745a
000000014136744b: mov      rdx, qword ptr [r14 + 8]
000000014136744f: mov      rcx, rax
0000000141367452: call     0x141394e50
0000000141367457: mov      rdi, rax
000000014136745a: jmp      0x1413676c8
000000014136745f: mov      r8d, 0x66
0000000141367465: lea      rdx, [rip + 0x839a74]
000000014136746c: lea      ecx, [r8 - 0x46]
0000000141367470: call     0x141272600
0000000141367475: mov      rcx, rax
0000000141367478: mov      qword ptr [rsp + 0x20], rax
000000014136747d: test     rax, rax
0000000141367480: je       0x1413676c8
0000000141367486: mov      rax, qword ptr [r14 + 8]
000000014136748a: mov      word ptr [rcx + 8], di
000000014136748e: mov      qword ptr [rcx + 0xc], rdi
0000000141367492: lea      rdx, [rip + 0x8397b7]
0000000141367499: mov      qword ptr [rcx], rdx
000000014136749c: mov      qword ptr [rcx + 0x18], rax
00000001413674a0: mov      rdi, rcx
00000001413674a3: jmp      0x1413676c8
00000001413674a8: mov      r8d, 0x69
00000001413674ae: lea      rdx, [rip + 0x839a2b]
00000001413674b5: lea      ecx, [r8 - 0x49]
00000001413674b9: call     0x141272600
00000001413674be: mov      rcx, rax
00000001413674c1: mov      qword ptr [rsp + 0x20], rax
00000001413674c6: test     rax, rax
00000001413674c9: je       0x1413676c8
00000001413674cf: mov      rax, qword ptr [r14 + 8]
00000001413674d3: mov      word ptr [rcx + 8], di
00000001413674d7: mov      qword ptr [rcx + 0xc], rdi
00000001413674db: mov      qword ptr [rcx + 0x18], rax
00000001413674df: lea      rax, [rip + 0x83980a]
00000001413674e6: mov      qword ptr [rcx], rax
00000001413674e9: mov      rdi, rcx
00000001413674ec: jmp      0x1413676c8
00000001413674f1: mov      ecx, 0x20
00000001413674f6: test     edx, edx
00000001413674f8: lea      rdx, [rip + 0x8399e1]
00000001413674ff: je       0x14136753d
0000000141367501: lea      r8d, [rcx + 0x4d]
0000000141367505: call     0x141272600
000000014136750a: mov      rcx, rax
000000014136750d: mov      qword ptr [rsp + 0x20], rax
0000000141367512: test     rax, rax
0000000141367515: je       0x1413676c8
000000014136751b: mov      rax, qword ptr [r14 + 8]
000000014136751f: lea      rdx, [rip + 0x83991a]
0000000141367526: mov      word ptr [rcx + 8], di
000000014136752a: mov      qword ptr [rcx + 0xc], rdi
000000014136752e: mov      qword ptr [rcx], rdx
0000000141367531: mov      qword ptr [rcx + 0x18], rax
0000000141367535: mov      rdi, rcx
0000000141367538: jmp      0x1413676c8
000000014136753d: mov      r8d, 0x6e
0000000141367543: call     0x141272600
0000000141367548: mov      rcx, rax
000000014136754b: mov      qword ptr [rsp + 0x20], rax
0000000141367550: test     rax, rax
0000000141367553: je       0x1413676c8
0000000141367559: mov      rax, qword ptr [r14 + 8]
000000014136755d: mov      word ptr [rcx + 8], di
0000000141367561: mov      qword ptr [rcx + 0xc], rdi
0000000141367565: lea      rdx, [rip + 0x839824]
000000014136756c: mov      qword ptr [rcx], rdx
000000014136756f: mov      qword ptr [rcx + 0x18], rax
0000000141367573: mov      rdi, rcx
0000000141367576: jmp      0x1413676c8
000000014136757b: mov      r8d, 0x71
0000000141367581: lea      rdx, [rip + 0x839958]
0000000141367588: lea      ecx, [r8 - 0x51]
000000014136758c: call     0x141272600
0000000141367591: mov      rcx, rax
0000000141367594: mov      qword ptr [rsp + 0x20], rax
0000000141367599: test     rax, rax
000000014136759c: je       0x1413676c8
00000001413675a2: mov      rax, qword ptr [r14 + 8]
00000001413675a6: mov      word ptr [rcx + 8], di
00000001413675aa: mov      qword ptr [rcx + 0xc], rdi
00000001413675ae: lea      rdx, [rip + 0x83982b]
00000001413675b5: mov      qword ptr [rcx], rdx
00000001413675b8: mov      qword ptr [rcx + 0x18], rax
00000001413675bc: mov      rdi, rcx
00000001413675bf: jmp      0x1413676c8
00000001413675c4: mov      r8d, 0x74
00000001413675ca: lea      rdx, [rip + 0x83990f]
00000001413675d1: lea      ecx, [r8 - 0x54]
00000001413675d5: jmp      0x141367505
00000001413675da: mov      r8d, 0x77
00000001413675e0: lea      rdx, [rip + 0x8398f9]
00000001413675e7: lea      ecx, [r8 - 0x4f]
00000001413675eb: call     0x141272600
00000001413675f0: mov      rcx, rax
00000001413675f3: mov      qword ptr [rsp + 0x20], rax
00000001413675f8: test     rax, rax
00000001413675fb: je       0x1413676c8
0000000141367601: mov      rax, qword ptr [r14 + 8]
0000000141367605: lea      rdx, [rip + 0x839884]
000000014136760c: mov      qword ptr [rcx + 0x20], rax
0000000141367610: jmp      0x141367526
0000000141367615: mov      r8d, 0x7b
000000014136761b: lea      rdx, [rip + 0x8398be]
0000000141367622: lea      ecx, [r8 - 0x5b]
0000000141367626: call     0x141272600
000000014136762b: mov      rcx, rax
000000014136762e: mov      qword ptr [rsp + 0x20], rax
0000000141367633: test     rax, rax
0000000141367636: je       0x1413676c8
000000014136763c: mov      rax, qword ptr [r14 + 8]
0000000141367640: mov      word ptr [rcx + 8], di
0000000141367644: mov      qword ptr [rcx + 0xc], rdi
0000000141367648: mov      qword ptr [rcx + 0x18], rax
000000014136764c: lea      rax, [rip + 0x8396ed]
0000000141367653: mov      qword ptr [rcx], rax
0000000141367656: mov      rdi, rcx
0000000141367659: jmp      0x1413676c8
000000014136765b: mov      r8d, 0x7e
0000000141367661: lea      rdx, [rip + 0x839878]
0000000141367668: lea      ecx, [r8 - 0x5e]
000000014136766c: call     0x141272600
0000000141367671: mov      rbx, rax
0000000141367674: mov      qword ptr [rsp + 0x20], rax
0000000141367679: test     rax, rax
000000014136767c: je       0x141367697
000000014136767e: mov      rdx, qword ptr [r14 + 8]
0000000141367682: mov      rcx, rax
0000000141367685: call     0x1413946b0
000000014136768a: lea      rax, [rip + 0x83955f]
0000000141367691: mov      qword ptr [rbx], rax
0000000141367694: mov      rdi, rbx
0000000141367697: jmp      0x1413676c8
0000000141367699: mov      r8d, 0x82
000000014136769f: lea      rdx, [rip + 0x83983a]
00000001413676a6: lea      ecx, [r8 - 0x62]
00000001413676aa: call     0x141272600
00000001413676af: mov      qword ptr [rsp + 0x20], rax
00000001413676b4: test     rax, rax
00000001413676b7: je       0x1413676c8
00000001413676b9: mov      rdx, qword ptr [r14 + 8]
00000001413676bd: mov      rcx, rax
00000001413676c0: call     0x141394ca0
00000001413676c5: mov      rdi, rax
00000001413676c8: test     rdi, rdi
00000001413676cb: je       0x1413676e0
00000001413676cd: movzx    edx, word ptr [r14 + 0x10]
00000001413676d2: mov      word ptr [rdi + 8], dx
00000001413676d6: mov      r8, qword ptr [rdi]
00000001413676d9: mov      rcx, rdi
00000001413676dc: call     qword ptr [r8 + 0x40]
00000001413676e0: mov      eax, dword ptr [r14]
00000001413676e3: cmp      eax, 0x1b
00000001413676e6: ja       0x1413676fb
00000001413676e8: mov      ecx, 0x8820400
00000001413676ed: bt       ecx, eax
00000001413676f0: jae      0x1413676fb
00000001413676f2: mov      rdx, qword ptr [rdi]
00000001413676f5: mov      rcx, rdi
00000001413676f8: call     qword ptr [rdx + 0x48]
00000001413676fb: mov      rax, rdi
00000001413676fe: mov      rcx, qword ptr [rsp + 0xa0]
0000000141367706: xor      rcx, rsp
0000000141367709: call     0x141441dc0
000000014136770e: lea      r11, [rsp + 0xb0]
0000000141367716: mov      rbx, qword ptr [r11 + 0x28]
000000014136771a: mov      rsi, qword ptr [r11 + 0x30]
000000014136771e: mov      rsp, r11
0000000141367721: pop      r15
0000000141367723: pop      r14
0000000141367725: pop      rdi
0000000141367726: ret      
0000000141367727: nop      
0000000141367728: sub      byte ptr [rcx + 0x36], dh
000000014136772b: add      dword ptr [rcx + 0x71], esi
000000014136772e: add      dword ptr ss:[rsi - 0xdfec98f], edi
0000000141367735: jno      0x14136776d
0000000141367737: add      dword ptr [rax - 0x13fec98e], edi
000000014136773d: jb       0x141367775
000000014136773f: add      dword ptr [rax], esp
0000000141367741: jae      0x141367779
0000000141367743: add      dword ptr [rcx + 0x73], ebp
0000000141367746: add      dword ptr ss:[rdx - 0x24fec990], edx
000000014136774d: jo       0x141367785
000000014136774f: add      edi, esi
0000000141367751: jae      0x141367789
0000000141367753: add      dword ptr [rbx], ebp
0000000141367755: je       0x14136778d
0000000141367757: add      dword ptr [rsi - 0x1ffec98d], esi
000000014136775d: jbe      0x141367795
000000014136775f: add      eax, esp
0000000141367761: jbe      0x141367799
0000000141367763: add      dword ptr [rdi + 0x74], ebx
0000000141367766: add      dword ptr ss:[rax - 0xefec98c], ebp
000000014136776d: je       0x1413677a5
000000014136776f: add      dword ptr [rbx + 0x75], edi
0000000141367772: add      esp, eax
0000000141367775: jne      0x1413677ad
0000000141367777: add      edx, ebx
0000000141367779: jne      0x1413677b1
000000014136777b: add      dword ptr [rip + 0x5b013676], edx
0000000141367781: jbe      0x1413677b9
0000000141367783: add      eax, esp
0000000141367785: jbe      0x1413677bd
