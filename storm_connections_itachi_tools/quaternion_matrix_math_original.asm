00000001411edd20: mov      qword ptr [rsp + 8], rbx
00000001411edd25: push     rdi
00000001411edd26: sub      rsp, 0x20
00000001411edd2a: mov      rbx, rdx
00000001411edd2d: mov      rdi, rcx
00000001411edd30: mov      rcx, rbx
00000001411edd33: xor      edx, edx
00000001411edd35: call     0x1411b6dd0
00000001411edd3a: xor      edx, edx
00000001411edd3c: mov      rcx, rbx
00000001411edd3f: mov      r8d, dword ptr [rax]
00000001411edd42: mov      dword ptr [rdi], r8d
00000001411edd45: call     0x1411b6dd0
00000001411edd4a: xor      edx, edx
00000001411edd4c: mov      rcx, rbx
00000001411edd4f: mov      r8d, dword ptr [rax + 4]
00000001411edd53: mov      dword ptr [rdi + 4], r8d
00000001411edd57: call     0x1411b6dd0
00000001411edd5c: mov      edx, 1
00000001411edd61: mov      ecx, dword ptr [rax + 8]
00000001411edd64: mov      dword ptr [rdi + 8], ecx
00000001411edd67: mov      rcx, rbx
00000001411edd6a: call     0x1411b6dd0
00000001411edd6f: mov      edx, 1
00000001411edd74: mov      ecx, dword ptr [rax]
00000001411edd76: mov      dword ptr [rdi + 0x10], ecx
00000001411edd79: mov      rcx, rbx
00000001411edd7c: call     0x1411b6dd0
00000001411edd81: mov      edx, 1
00000001411edd86: mov      ecx, dword ptr [rax + 4]
00000001411edd89: mov      dword ptr [rdi + 0x14], ecx
00000001411edd8c: mov      rcx, rbx
00000001411edd8f: call     0x1411b6dd0
00000001411edd94: mov      edx, 2
00000001411edd99: mov      ecx, dword ptr [rax + 8]
00000001411edd9c: mov      dword ptr [rdi + 0x18], ecx
00000001411edd9f: mov      rcx, rbx
00000001411edda2: call     0x1411b6dd0
00000001411edda7: mov      edx, 2
00000001411eddac: mov      ecx, dword ptr [rax]
00000001411eddae: mov      dword ptr [rdi + 0x20], ecx
00000001411eddb1: mov      rcx, rbx
00000001411eddb4: call     0x1411b6dd0
00000001411eddb9: mov      edx, 2
00000001411eddbe: mov      ecx, dword ptr [rax + 4]
00000001411eddc1: mov      dword ptr [rdi + 0x24], ecx
00000001411eddc4: mov      rcx, rbx
00000001411eddc7: call     0x1411b6dd0
00000001411eddcc: mov      rbx, qword ptr [rsp + 0x30]
00000001411eddd1: mov      ecx, dword ptr [rax + 8]
00000001411eddd4: mov      dword ptr [rdi + 0x28], ecx
00000001411eddd7: add      rsp, 0x20
00000001411edddb: pop      rdi
00000001411edddc: ret      
