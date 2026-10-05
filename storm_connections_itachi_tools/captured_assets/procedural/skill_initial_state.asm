0000000140a60a90: mov      qword ptr [rsp + 0x18], rbx
0000000140a60a95: mov      qword ptr [rsp + 8], rcx
0000000140a60a9a: push     rbp
0000000140a60a9b: push     rsi
0000000140a60a9c: push     rdi
0000000140a60a9d: sub      rsp, 0x30
0000000140a60aa1: mov      rsi, rcx
0000000140a60aa4: call     0x141273620
0000000140a60aa9: nop      
0000000140a60aaa: lea      rax, [rip + 0xf13577]
0000000140a60ab1: mov      qword ptr [rsi], rax
0000000140a60ab4: lea      rax, [rsi + 0x28]
0000000140a60ab8: mov      qword ptr [rsp + 0x58], rax
0000000140a60abd: lea      rcx, [rip + 0xf13534]
0000000140a60ac4: mov      qword ptr [rax], rcx
0000000140a60ac7: lea      rdi, [rax + 8]
0000000140a60acb: mov      qword ptr [rsp + 0x58], rdi
0000000140a60ad0: mov      rcx, rdi
0000000140a60ad3: call     0x141273620
0000000140a60ad8: lea      rax, [rip + 0xe22e19]
0000000140a60adf: mov      qword ptr [rdi], rax
0000000140a60ae2: xor      ebp, ebp
0000000140a60ae4: mov      qword ptr [rdi + 0x18], rbp
0000000140a60ae8: mov      qword ptr [rdi + 0x20], rbp
0000000140a60aec: mov      rcx, rdi
0000000140a60aef: call     0x141273770
0000000140a60af4: mov      ecx, eax
0000000140a60af6: call     0x141273960
0000000140a60afb: mov      dword ptr [rsp + 0x20], 0x63
0000000140a60b03: lea      r9, [rip + 0xd00786]
0000000140a60b0a: mov      r8, qword ptr [rdi + 8]
0000000140a60b0e: lea      edx, [rbp + 0x18]
0000000140a60b11: lea      ecx, [rbp + 8]
0000000140a60b14: call     0x1412734b0
0000000140a60b19: mov      rbx, rax
0000000140a60b1c: call     0x141273900
0000000140a60b21: mov      qword ptr [rbx], rbx
0000000140a60b24: mov      qword ptr [rbx + 8], rbx
0000000140a60b28: mov      qword ptr [rdi + 0x18], rbx
0000000140a60b2c: lea      rcx, [rsi + 0x58]
0000000140a60b30: call     0x141273620
0000000140a60b35: lea      rax, [rip + 0xf134cc]
0000000140a60b3c: mov      qword ptr [rsi + 0x58], rax
0000000140a60b40: mov      qword ptr [rsi + 0x70], rbp
0000000140a60b44: mov      qword ptr [rsi + 0x78], rbp
0000000140a60b48: mov      qword ptr [rsi + 0x80], rbp
0000000140a60b4f: mov      qword ptr [rsi + 0x18], rbp
0000000140a60b53: mov      dword ptr [rsi + 0x20], ebp
0000000140a60b56: mov      rax, qword ptr [rsi + 0x80]
0000000140a60b5d: sub      rax, qword ptr [rsi + 0x70]
0000000140a60b61: sar      rax, 3
0000000140a60b65: cmp      rax, 0x1e
0000000140a60b69: jae      0x140a60b78
0000000140a60b6b: lea      edx, [rbp + 0x1e]
0000000140a60b6e: lea      rcx, [rsi + 0x58]
0000000140a60b72: call     0x140a61810
0000000140a60b77: nop      
0000000140a60b78: mov      rax, rsi
0000000140a60b7b: mov      rbx, qword ptr [rsp + 0x60]
0000000140a60b80: add      rsp, 0x30
0000000140a60b84: pop      rdi
0000000140a60b85: pop      rsi
0000000140a60b86: pop      rbp
0000000140a60b87: ret      
