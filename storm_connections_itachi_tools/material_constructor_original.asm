00000001412f5920: mov      qword ptr [rsp + 0x18], rbx
00000001412f5925: mov      qword ptr [rsp + 8], rcx
00000001412f592a: push     rbp
00000001412f592b: push     rsi
00000001412f592c: push     rdi
00000001412f592d: push     r12
00000001412f592f: push     r13
00000001412f5931: push     r14
00000001412f5933: push     r15
00000001412f5935: sub      rsp, 0x20
00000001412f5939: mov      rbp, r8
00000001412f593c: mov      rbx, rdx
00000001412f593f: mov      rdi, rcx
00000001412f5942: call     0x141273620
00000001412f5947: xor      esi, esi
00000001412f5949: mov      qword ptr [rdi + 0x20], rsi
00000001412f594d: mov      qword ptr [rdi + 0x18], rsi
00000001412f5951: lea      rax, [rip + 0x8a2ba8]
00000001412f5958: mov      qword ptr [rdi], rax
00000001412f595b: lea      rcx, [rdi + 0x30]
00000001412f595f: call     0x1412a0c20
00000001412f5964: lea      rcx, [rdi + 0x38]
00000001412f5968: call     0x1412a0c20
00000001412f596d: lea      rcx, [rdi + 0x40]
00000001412f5971: call     0x1412a0c20
00000001412f5976: lea      rcx, [rdi + 0x48]
00000001412f597a: call     0x1412a0c20
00000001412f597f: lea      rcx, [rdi + 0x50]
00000001412f5983: call     0x1412a0c20
00000001412f5988: lea      rcx, [rdi + 0x58]
00000001412f598c: call     0x1412a0c20
00000001412f5991: lea      rcx, [rdi + 0x60]
00000001412f5995: call     0x1412a0c20
00000001412f599a: lea      rcx, [rdi + 0x68]
00000001412f599e: call     0x1412a0c20
00000001412f59a3: mov      rcx, qword ptr [rbx + 8]
00000001412f59a7: mov      qword ptr [rdi + 0x18], rcx
00000001412f59ab: mov      qword ptr [rdi + 0x28], rbp
00000001412f59af: test     rbp, rbp
00000001412f59b2: je       0x1412f59c3
00000001412f59b4: mov      rdx, rdi
00000001412f59b7: mov      rcx, rbp
00000001412f59ba: call     0x141330b10
00000001412f59bf: mov      rcx, qword ptr [rdi + 0x18]
00000001412f59c3: test     rcx, rcx
00000001412f59c6: je       0x1412f59d1
00000001412f59c8: mov      rax, qword ptr [rcx]
00000001412f59cb: call     qword ptr [rax + 8]
00000001412f59ce: mov      rsi, rax
00000001412f59d1: mov      eax, dword ptr [rsi + 0x24]
00000001412f59d4: mov      dword ptr [rdi + 0x80], eax
00000001412f59da: mov      eax, dword ptr [rsi + 0x20]
00000001412f59dd: mov      dword ptr [rdi + 0x7c], eax
00000001412f59e0: lea      rdx, [rsi + 0x28]
00000001412f59e4: lea      rcx, [rsp + 0x68]
00000001412f59e9: call     0x1412a0ba0
00000001412f59ee: movsd    xmm0, qword ptr [rax]
00000001412f59f2: movsd    qword ptr [rdi + 0x30], xmm0
00000001412f59f7: lea      rdx, [rsi + 0x30]
00000001412f59fb: lea      rcx, [rsp + 0x68]
00000001412f5a00: call     0x1412a0ba0
00000001412f5a05: movsd    xmm0, qword ptr [rax]
00000001412f5a09: movsd    qword ptr [rdi + 0x38], xmm0
00000001412f5a0e: lea      rdx, [rsi + 0x38]
00000001412f5a12: lea      rcx, [rsp + 0x68]
00000001412f5a17: call     0x1412a0ba0
00000001412f5a1c: movsd    xmm0, qword ptr [rax]
00000001412f5a20: movsd    qword ptr [rdi + 0x40], xmm0
00000001412f5a25: lea      rdx, [rsi + 0x40]
00000001412f5a29: lea      rcx, [rsp + 0x68]
00000001412f5a2e: call     0x1412a0ba0
00000001412f5a33: movsd    xmm0, qword ptr [rax]
00000001412f5a37: movsd    qword ptr [rdi + 0x48], xmm0
00000001412f5a3c: lea      rdx, [rsi + 0x48]
00000001412f5a40: lea      rcx, [rsp + 0x68]
00000001412f5a45: call     0x1412a0ba0
00000001412f5a4a: movsd    xmm0, qword ptr [rax]
00000001412f5a4e: movsd    qword ptr [rdi + 0x50], xmm0
00000001412f5a53: lea      rdx, [rsi + 0x50]
00000001412f5a57: lea      rcx, [rsp + 0x68]
00000001412f5a5c: call     0x1412a0ba0
00000001412f5a61: movsd    xmm0, qword ptr [rax]
00000001412f5a65: movsd    qword ptr [rdi + 0x58], xmm0
00000001412f5a6a: lea      rdx, [rsi + 0x58]
00000001412f5a6e: lea      rcx, [rsp + 0x68]
00000001412f5a73: call     0x1412a0ba0
00000001412f5a78: movsd    xmm0, qword ptr [rax]
00000001412f5a7c: movsd    qword ptr [rdi + 0x60], xmm0
00000001412f5a81: lea      rdx, [rsi + 0x60]
00000001412f5a85: lea      rcx, [rsp + 0x68]
00000001412f5a8a: call     0x1412a0ba0
00000001412f5a8f: movsd    xmm0, qword ptr [rax]
00000001412f5a93: movsd    qword ptr [rdi + 0x68], xmm0
00000001412f5a98: mov      eax, dword ptr [rsi + 0x68]
00000001412f5a9b: mov      dword ptr [rdi + 0x70], eax
00000001412f5a9e: mov      eax, dword ptr [rsi + 0x6c]
00000001412f5aa1: mov      dword ptr [rdi + 0x74], eax
00000001412f5aa4: mov      eax, dword ptr [rsi + 0x74]
00000001412f5aa7: mov      dword ptr [rdi + 0x78], eax
00000001412f5aaa: mov      eax, dword ptr [rsi + 0x78]
00000001412f5aad: mov      dword ptr [rdi + 0x84], eax
00000001412f5ab3: mov      eax, dword ptr [rsi + 0x7c]
00000001412f5ab6: mov      dword ptr [rdi + 0x88], eax
00000001412f5abc: mov      rax, rdi
00000001412f5abf: mov      rbx, qword ptr [rsp + 0x70]
00000001412f5ac4: add      rsp, 0x20
00000001412f5ac8: pop      r15
00000001412f5aca: pop      r14
00000001412f5acc: pop      r13
00000001412f5ace: pop      r12
00000001412f5ad0: pop      rdi
00000001412f5ad1: pop      rsi
00000001412f5ad2: pop      rbp
00000001412f5ad3: ret      
