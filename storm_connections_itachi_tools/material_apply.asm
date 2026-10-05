00000001412f6ed0: ret      0
00000001412f6ed3: int3     
00000001412f6ed4: int3     
00000001412f6ed5: int3     
00000001412f6ed6: int3     
00000001412f6ed7: int3     
00000001412f6ed8: int3     
00000001412f6ed9: int3     
00000001412f6eda: int3     
00000001412f6edb: int3     
00000001412f6edc: int3     
00000001412f6edd: int3     
00000001412f6ede: int3     
00000001412f6edf: int3     
00000001412f6ee0: sub      rsp, 0x28
00000001412f6ee4: cmp      edx, 0x3f
00000001412f6ee7: ja       0x1412f6f3f
00000001412f6ee9: movsxd   rax, edx
00000001412f6eec: lea      rcx, [rip + 0x8453f1d]
00000001412f6ef3: cmp      qword ptr [rcx + rax*8], 0
00000001412f6ef8: mov      qword ptr [rsp + 0x20], rbx
00000001412f6efd: lea      rbx, [rcx + rax*8]
00000001412f6f01: je       0x1412f6f3a
00000001412f6f03: xor      ecx, ecx
00000001412f6f05: call     0x141273960
00000001412f6f0a: mov      rcx, qword ptr [rbx]
00000001412f6f0d: mov      rax, qword ptr [rcx]
00000001412f6f10: call     qword ptr [rax + 0x18]
00000001412f6f13: mov      rcx, qword ptr [rbx]
00000001412f6f16: test     rcx, rcx
00000001412f6f19: je       0x1412f6f2c
00000001412f6f1b: mov      rax, qword ptr [rcx]
00000001412f6f1e: mov      edx, 1
00000001412f6f23: call     qword ptr [rax]
00000001412f6f25: mov      qword ptr [rbx], 0
00000001412f6f2c: mov      rbx, qword ptr [rsp + 0x20]
00000001412f6f31: add      rsp, 0x28
00000001412f6f35: jmp      0x141273900
00000001412f6f3a: mov      rbx, qword ptr [rsp + 0x20]
