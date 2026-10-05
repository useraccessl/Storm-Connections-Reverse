00000001405e6ef0: mov      qword ptr [rsp + 8], rbx
00000001405e6ef5: mov      qword ptr [rsp + 0x10], rsi
00000001405e6efa: mov      qword ptr [rsp + 0x18], rdi
00000001405e6eff: push     rbp
00000001405e6f00: push     r12
00000001405e6f02: push     r13
00000001405e6f04: push     r14
00000001405e6f06: push     r15
00000001405e6f08: lea      rbp, [rsp - 0x37]
00000001405e6f0d: sub      rsp, 0xa0
00000001405e6f14: mov      r15, rcx
00000001405e6f17: cmp      dword ptr [rcx + 0x220], 0
00000001405e6f1e: je       0x1405e70dd
00000001405e6f24: mov      rbx, qword ptr [rcx + 0x140]
00000001405e6f2b: test     rbx, rbx
00000001405e6f2e: je       0x1405e7065
00000001405e6f34: lea      rcx, [rbp - 0x29]
00000001405e6f38: call     0x141273620
00000001405e6f3d: xor      r12d, r12d
00000001405e6f40: mov      qword ptr [rbp - 0x11], r12
00000001405e6f44: mov      dword ptr [rbp - 9], r12d
00000001405e6f48: lea      rax, [rip + 0x117e4b1]
00000001405e6f4f: mov      qword ptr [rbp - 0x29], rax
00000001405e6f53: lea      r8, [rbp - 0x29]
00000001405e6f57: lea      rdx, [rip + 0x1ad8b02]
00000001405e6f5e: mov      rcx, rbx
00000001405e6f61: call     0x1412a3840
00000001405e6f66: movsxd   r14, dword ptr [rbp - 9]
00000001405e6f6a: test     r14, r14
00000001405e6f6d: jle      0x1405e702b
00000001405e6f73: mov      ebx, r12d
00000001405e6f76: lea      r13, [rip + 0x12a818b]
00000001405e6f7d: lea      r12, [rip + 0x12a8194]
00000001405e6f84: mov      rax, qword ptr [rbp - 0x11]
00000001405e6f88: mov      rdi, qword ptr [rax + rbx*8]
00000001405e6f8c: test     rdi, rdi
00000001405e6f8f: je       0x1405e701c
00000001405e6f95: mov      rcx, r13
00000001405e6f98: call     0x14127c020
00000001405e6f9d: mov      dword ptr [rbp - 0x49], eax
00000001405e6fa0: mov      byte ptr [rbp - 0x45], 1
00000001405e6fa4: mov      qword ptr [rbp - 0x41], r13
00000001405e6fa8: lea      r8, [rbp - 0x49]
00000001405e6fac: lea      rdx, [rip + 0x1ad88b5]
00000001405e6fb3: mov      rcx, rdi
00000001405e6fb6: call     0x14128f480
00000001405e6fbb: mov      rsi, rax
00000001405e6fbe: mov      rcx, r12
00000001405e6fc1: call     0x14127c020
00000001405e6fc6: mov      dword ptr [rbp - 0x39], eax
00000001405e6fc9: mov      byte ptr [rbp - 0x35], 1
00000001405e6fcd: mov      qword ptr [rbp - 0x31], r12
00000001405e6fd1: lea      r8, [rbp - 0x39]
00000001405e6fd5: lea      rdx, [rip + 0x1ad888c]
00000001405e6fdc: mov      rcx, rdi
00000001405e6fdf: call     0x14128f480
00000001405e6fe4: test     rsi, rsi
00000001405e6fe7: je       0x1405e6ffa
00000001405e6fe9: test     rax, rax
00000001405e6fec: je       0x1405e6ffa
00000001405e6fee: mov      edx, dword ptr [rax + 0x70]
00000001405e6ff1: mov      dword ptr [rsi + 0x70], edx
00000001405e6ff4: mov      eax, dword ptr [rax + 0x74]
00000001405e6ff7: mov      dword ptr [rsi + 0x74], eax
00000001405e6ffa: lea      rdx, [rip + 0x12a8127]
00000001405e7001: mov      rcx, rdi
00000001405e7004: call     0x1410971e0
00000001405e7009: test     eax, eax
00000001405e700b: jne      0x1405e701c
00000001405e700d: lea      rdx, [rip + 0x12a8124]
00000001405e7014: mov      rcx, rdi
00000001405e7017: call     0x1410971e0
00000001405e701c: inc      rbx
00000001405e701f: cmp      rbx, r14
00000001405e7022: jl       0x1405e6f84
00000001405e7028: xor      r12d, r12d
00000001405e702b: lea      rax, [rip + 0x117e3ae]
00000001405e7032: mov      qword ptr [rbp - 0x29], rax
00000001405e7036: cmp      qword ptr [rbp - 0x11], 0
00000001405e703b: je       0x1405e7065
00000001405e703d: lea      rcx, [rbp - 0x29]
00000001405e7041: call     0x141273770
00000001405e7046: mov      ecx, eax
00000001405e7048: call     0x141273960
00000001405e704d: mov      rcx, qword ptr [rbp - 0x11]
00000001405e7051: test     rcx, rcx
00000001405e7054: je       0x1405e705f
00000001405e7056: call     0x141272e20
00000001405e705b: mov      qword ptr [rbp - 0x11], r12
00000001405e705f: call     0x141273900
00000001405e7064: nop      
00000001405e7065: lea      rdx, [r15 + 0x500]
00000001405e706c: lea      rcx, [rbp - 1]
00000001405e7070: call     0x1405df110
00000001405e7075: nop      
00000001405e7076: mov      rbx, qword ptr [rbp + 0x17]
00000001405e707a: mov      rax, qword ptr [rbp + 0x1f]
00000001405e707e: cmp      rbx, rax
00000001405e7081: je       0x1405e70ba
00000001405e7083: mov      rdi, qword ptr [rbx]
00000001405e7086: test     rdi, rdi
00000001405e7089: je       0x1405e70ad
00000001405e708b: lea      rdx, [rip + 0x12a80be]
00000001405e7092: mov      rcx, rdi
00000001405e7095: call     0x1410971e0
00000001405e709a: lea      rdx, [rip + 0x12a80bf]
00000001405e70a1: mov      rcx, rdi
00000001405e70a4: call     0x1410971e0
00000001405e70a9: mov      rax, qword ptr [rbp + 0x1f]
00000001405e70ad: add      rbx, 8
00000001405e70b1: cmp      rbx, rax
00000001405e70b4: jne      0x1405e7083
00000001405e70b6: mov      rbx, qword ptr [rbp + 0x17]
00000001405e70ba: test     rbx, rbx
00000001405e70bd: je       0x1405e70dd
00000001405e70bf: lea      rcx, [rbp - 1]
00000001405e70c3: call     0x141273770
00000001405e70c8: mov      ecx, eax
00000001405e70ca: call     0x141273960
00000001405e70cf: mov      rcx, rbx
00000001405e70d2: call     0x1412732b0
00000001405e70d7: call     0x141273900
00000001405e70dc: nop      
00000001405e70dd: lea      r11, [rsp + 0xa0]
00000001405e70e5: mov      rbx, qword ptr [r11 + 0x30]
00000001405e70e9: mov      rsi, qword ptr [r11 + 0x38]
00000001405e70ed: mov      rdi, qword ptr [r11 + 0x40]
00000001405e70f1: mov      rsp, r11
00000001405e70f4: pop      r15
00000001405e70f6: pop      r14
00000001405e70f8: pop      r13
00000001405e70fa: pop      r12
00000001405e70fc: pop      rbp
00000001405e70fd: ret      
