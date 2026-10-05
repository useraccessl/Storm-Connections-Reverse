00000001412c84b0: mov      rax, rsp
00000001412c84b3: mov      qword ptr [rax + 0x20], rbx
00000001412c84b7: push     rbp
00000001412c84b8: push     rsi
00000001412c84b9: push     rdi
00000001412c84ba: lea      rbp, [rax - 0x5f]
00000001412c84be: sub      rsp, 0x100
00000001412c84c5: movaps   xmmword ptr [rax - 0x28], xmm6
00000001412c84c9: movaps   xmmword ptr [rax - 0x38], xmm7
00000001412c84cd: movaps   xmmword ptr [rax - 0x48], xmm8
00000001412c84d2: mov      rax, qword ptr [rip + 0xe1deef]
00000001412c84d9: xor      rax, rsp
00000001412c84dc: mov      qword ptr [rbp + 0xf], rax
00000001412c84e0: mov      rsi, rdx
00000001412c84e3: mov      rdi, rcx
00000001412c84e6: mov      rcx, rsi
00000001412c84e9: lea      rdx, [rsp + 0x30]
00000001412c84ee: mov      rbx, r8
00000001412c84f1: call     0x141283ee0
00000001412c84f6: lea      rdx, [rbx + 0x80]
00000001412c84fd: lea      rcx, [rbp - 0x69]
00000001412c8501: call     0x1412c3530
00000001412c8506: lea      rdx, [rsp + 0x20]
00000001412c850b: mov      rcx, rsi
00000001412c850e: call     0x1412840b0
00000001412c8513: mov      rcx, rax
00000001412c8516: call     0x1411ac850
00000001412c851b: lea      rdx, [rsp + 0x20]
00000001412c8520: mov      rcx, rsi
00000001412c8523: movaps   xmm8, xmm0
00000001412c8527: call     0x141284120
00000001412c852c: mov      rcx, rax
00000001412c852f: call     0x1411ac850
00000001412c8534: lea      rdx, [rsp + 0x20]
00000001412c8539: mov      rcx, rsi
00000001412c853c: movaps   xmm7, xmm0
00000001412c853f: call     0x141284190
00000001412c8544: mov      rcx, rax
00000001412c8547: call     0x1411ac850
00000001412c854c: movd     xmm1, dword ptr [rdi + 0x2bc]
00000001412c8554: lea      rcx, [rbp - 0x41]
00000001412c8558: cvtdq2ps xmm1, xmm1
00000001412c855b: movaps   xmm6, xmm0
00000001412c855e: mulss    xmm1, dword ptr [rip + 0x4a1ef2]
00000001412c8566: mulss    xmm1, dword ptr [rip + 0x4a1ed2]
00000001412c856e: call     0x1412c4a70
00000001412c8573: mov      r8, rax
00000001412c8576: lea      rdx, [rbp - 0x19]
00000001412c857a: lea      rcx, [rbp - 0x69]
00000001412c857e: call     0x1412c4740
00000001412c8583: mov      rdx, rax
00000001412c8586: lea      rcx, [rbp - 0x69]
00000001412c858a: call     0x1412c36f0
00000001412c858f: mulss    xmm7, dword ptr [rdi + 0x2c4]
00000001412c8597: lea      rcx, [rbp - 0x79]
00000001412c859b: mulss    xmm8, dword ptr [rdi + 0x2c0]
00000001412c85a4: movaps   xmm3, xmm6
00000001412c85a7: movaps   xmm2, xmm7
00000001412c85aa: movaps   xmm1, xmm8
00000001412c85ae: call     0x1412c4bc0
00000001412c85b3: lea      r8, [rbp - 0x79]
00000001412c85b7: lea      rdx, [rbp - 0x69]
00000001412c85bb: lea      rcx, [rbp - 0x19]
00000001412c85bf: call     0x1411ae650
00000001412c85c4: mov      rdx, rax
00000001412c85c7: lea      rcx, [rbp - 0x41]
00000001412c85cb: call     0x1412c35c0
00000001412c85d0: lea      rdx, [rbp - 0x41]
00000001412c85d4: lea      rcx, [rbp - 0x69]
00000001412c85d8: call     0x1412c36f0
00000001412c85dd: lea      rdx, [rbp - 0x69]
00000001412c85e1: mov      rcx, rsi
00000001412c85e4: call     0x141281f40
00000001412c85e9: movss    xmm0, dword ptr [rsp + 0x30]
00000001412c85ef: lea      rdx, [rsp + 0x20]
00000001412c85f4: addss    xmm0, dword ptr [rdi + 0x2b0]
00000001412c85fc: movss    xmm1, dword ptr [rsp + 0x34]
00000001412c8602: mov      rcx, rsi
00000001412c8605: addss    xmm1, dword ptr [rdi + 0x2b4]
00000001412c860d: movss    dword ptr [rsp + 0x20], xmm0
00000001412c8613: movss    xmm0, dword ptr [rsp + 0x38]
00000001412c8619: addss    xmm0, dword ptr [rdi + 0x2b8]
00000001412c8621: movss    dword ptr [rsp + 0x24], xmm1
00000001412c8627: movss    dword ptr [rsp + 0x28], xmm0
00000001412c862d: call     0x141282e80
00000001412c8632: mov      rcx, qword ptr [rbp + 0xf]
00000001412c8636: xor      rcx, rsp
00000001412c8639: call     0x141441dc0
00000001412c863e: lea      r11, [rsp + 0x100]
00000001412c8646: mov      rbx, qword ptr [r11 + 0x38]
00000001412c864a: movaps   xmm6, xmmword ptr [r11 - 0x10]
00000001412c864f: movaps   xmm7, xmmword ptr [r11 - 0x20]
00000001412c8654: movaps   xmm8, xmmword ptr [r11 - 0x30]
00000001412c8659: mov      rsp, r11
00000001412c865c: pop      rdi
00000001412c865d: pop      rsi
00000001412c865e: pop      rbp
00000001412c865f: ret      
