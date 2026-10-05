00000001412c7dd0: push     rbx
00000001412c7dd2: sub      rsp, 0x30
00000001412c7dd6: test     byte ptr [rcx + 0x28], 1
00000001412c7dda: mov      rbx, rcx
00000001412c7ddd: jne      0x1412c7f33
00000001412c7de3: mov      r9d, dword ptr [rcx + 0x70]
00000001412c7de7: xor      r8d, r8d
00000001412c7dea: movaps   xmmword ptr [rsp + 0x20], xmm6
00000001412c7def: test     r9d, r9d
00000001412c7df2: je       0x1412c7efc
00000001412c7df8: nop      dword ptr [rax + rax]
00000001412c7e00: mov      rax, qword ptr [rbx + 0x68]
00000001412c7e04: movsxd   rcx, r8d
00000001412c7e07: mov      rdx, qword ptr [rax + rcx*8]
00000001412c7e0b: mov      rax, qword ptr [rbx + 0x308]
00000001412c7e12: cmp      qword ptr [rax + 0x38], 0
00000001412c7e17: je       0x1412c7e2d
00000001412c7e19: movsd    xmm0, qword ptr [rbx + 0x2c8]
00000001412c7e21: movsd    qword ptr [rdx + 0x30], xmm0
00000001412c7e26: mov      rax, qword ptr [rbx + 0x308]
00000001412c7e2d: cmp      qword ptr [rax + 0x60], 0
00000001412c7e32: je       0x1412c7e48
00000001412c7e34: movsd    xmm0, qword ptr [rbx + 0x2d8]
00000001412c7e3c: movsd    qword ptr [rdx + 0x38], xmm0
00000001412c7e41: mov      rax, qword ptr [rbx + 0x308]
00000001412c7e48: cmp      qword ptr [rax + 0x40], 0
00000001412c7e4d: je       0x1412c7e63
00000001412c7e4f: movsd    xmm0, qword ptr [rbx + 0x2d0]
00000001412c7e57: movsd    qword ptr [rdx + 0x50], xmm0
00000001412c7e5c: mov      rax, qword ptr [rbx + 0x308]
00000001412c7e63: cmp      qword ptr [rax + 0x68], 0
00000001412c7e68: je       0x1412c7e7e
00000001412c7e6a: movsd    xmm0, qword ptr [rbx + 0x2e0]
00000001412c7e72: movsd    qword ptr [rdx + 0x58], xmm0
00000001412c7e77: mov      rax, qword ptr [rbx + 0x308]
00000001412c7e7e: cmp      qword ptr [rax + 0x58], 0
00000001412c7e83: je       0x1412c7e95
00000001412c7e85: mov      eax, dword ptr [rbx + 0x2f0]
00000001412c7e8b: mov      dword ptr [rdx + 0x7c], eax
00000001412c7e8e: mov      rax, qword ptr [rbx + 0x308]
00000001412c7e95: cmp      qword ptr [rax + 0x48], 0
00000001412c7e9a: je       0x1412c7eac
00000001412c7e9c: mov      eax, dword ptr [rbx + 0x2e8]
00000001412c7ea2: mov      dword ptr [rdx + 0x70], eax
00000001412c7ea5: mov      rax, qword ptr [rbx + 0x308]
00000001412c7eac: cmp      qword ptr [rax + 0x50], 0
00000001412c7eb1: je       0x1412c7ec3
00000001412c7eb3: mov      eax, dword ptr [rbx + 0x2ec]
00000001412c7eb9: mov      dword ptr [rdx + 0x74], eax
00000001412c7ebc: mov      rax, qword ptr [rbx + 0x308]
00000001412c7ec3: cmp      qword ptr [rax + 0x70], 0
00000001412c7ec8: je       0x1412c7edd
00000001412c7eca: mov      eax, dword ptr [rbx + 0x2f8]
00000001412c7ed0: mov      dword ptr [rdx + 0x80], eax
00000001412c7ed6: mov      rax, qword ptr [rbx + 0x308]
00000001412c7edd: cmp      qword ptr [rax + 0x78], 0
00000001412c7ee2: je       0x1412c7ef0
00000001412c7ee4: mov      eax, dword ptr [rbx + 0x2fc]
00000001412c7eea: mov      dword ptr [rdx + 0x84], eax
00000001412c7ef0: inc      r8d
00000001412c7ef3: cmp      r8d, r9d
00000001412c7ef6: jb       0x1412c7e00
00000001412c7efc: movss    xmm6, dword ptr [rbx + 0xa0]
00000001412c7f04: movaps   xmm0, xmm6
00000001412c7f07: mulss    xmm0, dword ptr [rbx + 0x2f4]
00000001412c7f0f: movss    dword ptr [rbx + 0xa0], xmm0
00000001412c7f17: call     0x141216e70
00000001412c7f1c: xor      edx, edx
00000001412c7f1e: mov      rcx, rbx
00000001412c7f21: call     0x1412d1d10
00000001412c7f26: movss    dword ptr [rbx + 0xa0], xmm6
00000001412c7f2e: movaps   xmm6, xmmword ptr [rsp + 0x20]
00000001412c7f33: add      rsp, 0x30
00000001412c7f37: pop      rbx
00000001412c7f38: ret      
