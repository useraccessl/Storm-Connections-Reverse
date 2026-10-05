000000014130ae90: mov      dword ptr [rcx + 0x1a4], edx
000000014130ae96: test     edx, edx
000000014130ae98: js       0x14130aee5
000000014130ae9a: mov      r8d, dword ptr [rcx + 0x50]
000000014130ae9e: sub      r8d, 1
000000014130aea2: je       0x14130aed8
000000014130aea4: sub      r8d, 1
000000014130aea8: je       0x14130aeca
000000014130aeaa: sub      r8d, 1
000000014130aeae: je       0x14130aee5
000000014130aeb0: sub      r8d, 1
000000014130aeb4: je       0x14130aee5
000000014130aeb6: cmp      r8d, 1
000000014130aeba: jne      0x14130aee5
000000014130aebc: mov      rcx, qword ptr [rcx + 0x40]
000000014130aec0: test     rcx, rcx
000000014130aec3: je       0x14130aee5
000000014130aec5: jmp      0x1412d1760
000000014130aeca: mov      rcx, qword ptr [rcx + 0x40]
000000014130aece: test     rcx, rcx
000000014130aed1: je       0x14130aee5
000000014130aed3: jmp      0x1412adad0
000000014130aed8: mov      rcx, qword ptr [rcx + 0x40]
000000014130aedc: test     rcx, rcx
000000014130aedf: jne      0x14128d280
000000014130aee5: ret      
000000014130aee6: int3     
000000014130aee7: int3     
000000014130aee8: int3     
000000014130aee9: int3     
000000014130aeea: int3     
000000014130aeeb: int3     
000000014130aeec: int3     
000000014130aeed: int3     
000000014130aeee: int3     
000000014130aeef: int3     
000000014130aef0: mov      qword ptr [rsp + 8], rbx
000000014130aef5: push     rdi
000000014130aef6: sub      rsp, 0x20
000000014130aefa: mov      rbx, rcx
000000014130aefd: call     0x1412c55a0
000000014130af02: mov      rdx, rax
000000014130af05: lea      rcx, [rbx + 0xf4]
000000014130af0c: call     0x1412c36f0
000000014130af11: call     0x141284200
000000014130af16: mov      rdx, rax
000000014130af19: lea      rcx, [rbx + 0x40]
