00000001412f6380: mov      r8d, dword ptr [rdx]
00000001412f6383: add      rdx, 4
00000001412f6387: test     r8b, 1
00000001412f638b: je       0x1412f6396
00000001412f638d: mov      eax, dword ptr [rdx]
00000001412f638f: add      rdx, 4
00000001412f6393: mov      dword ptr [rcx + 0x30], eax
00000001412f6396: test     r8b, 2
00000001412f639a: je       0x1412f63a5
00000001412f639c: mov      eax, dword ptr [rdx]
00000001412f639e: add      rdx, 4
00000001412f63a2: mov      dword ptr [rcx + 0x34], eax
00000001412f63a5: test     r8b, 4
00000001412f63a9: je       0x1412f63b4
00000001412f63ab: mov      eax, dword ptr [rdx]
00000001412f63ad: add      rdx, 4
00000001412f63b1: mov      dword ptr [rcx + 0x38], eax
00000001412f63b4: test     r8b, 8
00000001412f63b8: je       0x1412f63c3
00000001412f63ba: mov      eax, dword ptr [rdx]
00000001412f63bc: add      rdx, 4
00000001412f63c0: mov      dword ptr [rcx + 0x3c], eax
00000001412f63c3: test     r8b, 0x10
00000001412f63c7: je       0x1412f63d2
00000001412f63c9: mov      eax, dword ptr [rdx]
00000001412f63cb: add      rdx, 4
00000001412f63cf: mov      dword ptr [rcx + 0x40], eax
00000001412f63d2: test     r8b, 0x20
00000001412f63d6: je       0x1412f63e1
00000001412f63d8: mov      eax, dword ptr [rdx]
00000001412f63da: add      rdx, 4
00000001412f63de: mov      dword ptr [rcx + 0x44], eax
00000001412f63e1: test     r8b, 0x40
00000001412f63e5: je       0x1412f63f0
00000001412f63e7: mov      eax, dword ptr [rdx]
00000001412f63e9: add      rdx, 4
00000001412f63ed: mov      dword ptr [rcx + 0x48], eax
00000001412f63f0: test     r8b, r8b
00000001412f63f3: jns      0x1412f63fe
00000001412f63f5: mov      eax, dword ptr [rdx]
00000001412f63f7: add      rdx, 4
00000001412f63fb: mov      dword ptr [rcx + 0x4c], eax
00000001412f63fe: bt       r8d, 8
00000001412f6403: jae      0x1412f640e
00000001412f6405: mov      eax, dword ptr [rdx]
00000001412f6407: add      rdx, 4
00000001412f640b: mov      dword ptr [rcx + 0x50], eax
00000001412f640e: bt       r8d, 9
00000001412f6413: jae      0x1412f641e
00000001412f6415: mov      eax, dword ptr [rdx]
00000001412f6417: add      rdx, 4
00000001412f641b: mov      dword ptr [rcx + 0x54], eax
00000001412f641e: bt       r8d, 0xa
00000001412f6423: jae      0x1412f642e
00000001412f6425: mov      eax, dword ptr [rdx]
00000001412f6427: add      rdx, 4
00000001412f642b: mov      dword ptr [rcx + 0x58], eax
00000001412f642e: bt       r8d, 0xb
00000001412f6433: jae      0x1412f643e
00000001412f6435: mov      eax, dword ptr [rdx]
00000001412f6437: add      rdx, 4
00000001412f643b: mov      dword ptr [rcx + 0x5c], eax
00000001412f643e: bt       r8d, 0xc
00000001412f6443: jae      0x1412f644e
00000001412f6445: mov      eax, dword ptr [rdx]
00000001412f6447: add      rdx, 4
00000001412f644b: mov      dword ptr [rcx + 0x70], eax
00000001412f644e: bt       r8d, 0xd
00000001412f6453: jae      0x1412f645e
00000001412f6455: mov      eax, dword ptr [rdx]
00000001412f6457: add      rdx, 4
00000001412f645b: mov      dword ptr [rcx + 0x74], eax
00000001412f645e: bt       r8d, 0xe
00000001412f6463: jae      0x1412f646e
00000001412f6465: mov      eax, dword ptr [rdx]
00000001412f6467: add      rdx, 4
00000001412f646b: mov      dword ptr [rcx + 0x78], eax
00000001412f646e: bt       r8d, 0xf
00000001412f6473: jae      0x1412f647e
00000001412f6475: mov      eax, dword ptr [rdx]
00000001412f6477: add      rdx, 4
00000001412f647b: mov      dword ptr [rcx + 0x7c], eax
00000001412f647e: bt       r8d, 0x10
00000001412f6483: jae      0x1412f6491
00000001412f6485: mov      eax, dword ptr [rdx]
00000001412f6487: add      rdx, 4
00000001412f648b: mov      dword ptr [rcx + 0x80], eax
00000001412f6491: bt       r8d, 0x11
00000001412f6496: jae      0x1412f64a4
00000001412f6498: mov      eax, dword ptr [rdx]
00000001412f649a: add      rdx, 4
00000001412f649e: mov      dword ptr [rcx + 0x84], eax
00000001412f64a4: bt       r8d, 0x12
00000001412f64a9: jae      0x1412f64b4
00000001412f64ab: mov      eax, dword ptr [rdx]
00000001412f64ad: add      rdx, 4
00000001412f64b1: mov      dword ptr [rcx + 0x68], eax
00000001412f64b4: bt       r8d, 0x13
00000001412f64b9: jae      0x1412f64c4
00000001412f64bb: mov      eax, dword ptr [rdx]
00000001412f64bd: add      rdx, 4
00000001412f64c1: mov      dword ptr [rcx + 0x6c], eax
00000001412f64c4: bt       r8d, 0x14
00000001412f64c9: jae      0x1412f64d4
00000001412f64cb: mov      eax, dword ptr [rdx]
00000001412f64cd: add      rdx, 4
00000001412f64d1: mov      dword ptr [rcx + 0x60], eax
00000001412f64d4: bt       r8d, 0x15
00000001412f64d9: jae      0x1412f64e4
00000001412f64db: mov      eax, dword ptr [rdx]
00000001412f64dd: add      rdx, 4
00000001412f64e1: mov      dword ptr [rcx + 0x64], eax
00000001412f64e4: bt       r8d, 0x16
00000001412f64e9: jae      0x1412f64f3
00000001412f64eb: mov      eax, dword ptr [rdx]
00000001412f64ed: mov      dword ptr [rcx + 0x88], eax
00000001412f64f3: ret      
