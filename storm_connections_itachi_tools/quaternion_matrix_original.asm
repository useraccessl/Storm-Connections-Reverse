000000014127e760: mov      qword ptr [rsp + 0x18], rbx
000000014127e765: push     rdi
000000014127e766: sub      rsp, 0x90
000000014127e76d: mov      rax, qword ptr [rip + 0xe67c54]
000000014127e774: xor      rax, rsp
000000014127e777: mov      qword ptr [rsp + 0x88], rax
000000014127e77f: mov      rdi, rcx
000000014127e782: mov      rbx, rdx
000000014127e785: lea      rcx, [rsp + 0x60]
000000014127e78a: call     0x1412c3660
000000014127e78f: mov      rdx, rbx
000000014127e792: lea      rcx, [rsp + 0x60]
000000014127e797: call     0x1412c3710
000000014127e79c: lea      rcx, [rsp + 0x20]
000000014127e7a1: call     0x1411f0720
000000014127e7a6: movups   xmm0, xmmword ptr [rdi]
000000014127e7a9: lea      rdx, [rsp + 0x60]
000000014127e7ae: lea      rcx, [rsp + 0x20]
000000014127e7b3: movups   xmmword ptr [rax], xmm0
000000014127e7b6: movups   xmm1, xmmword ptr [rdi + 0x10]
000000014127e7ba: movups   xmmword ptr [rax + 0x10], xmm1
000000014127e7be: movups   xmm0, xmmword ptr [rdi + 0x20]
000000014127e7c2: movups   xmmword ptr [rax + 0x20], xmm0
000000014127e7c6: movups   xmm1, xmmword ptr [rdi + 0x30]
000000014127e7ca: movups   xmmword ptr [rax + 0x30], xmm1
000000014127e7ce: call     0x1411edd20
000000014127e7d3: lea      rcx, [rsp + 0x20]
000000014127e7d8: call     0x1411f0730
000000014127e7dd: movups   xmm0, xmmword ptr [rax]
000000014127e7e0: movups   xmmword ptr [rdi], xmm0
000000014127e7e3: movups   xmm1, xmmword ptr [rax + 0x10]
000000014127e7e7: movups   xmmword ptr [rdi + 0x10], xmm1
000000014127e7eb: movups   xmm0, xmmword ptr [rax + 0x20]
000000014127e7ef: movups   xmmword ptr [rdi + 0x20], xmm0
000000014127e7f3: movups   xmm1, xmmword ptr [rax + 0x30]
000000014127e7f7: mov      rax, rdi
000000014127e7fa: movups   xmmword ptr [rdi + 0x30], xmm1
000000014127e7fe: mov      rcx, qword ptr [rsp + 0x88]
000000014127e806: xor      rcx, rsp
000000014127e809: call     0x141441dc0
000000014127e80e: mov      rbx, qword ptr [rsp + 0xb0]
000000014127e816: add      rsp, 0x90
000000014127e81d: pop      rdi
000000014127e81e: ret      
