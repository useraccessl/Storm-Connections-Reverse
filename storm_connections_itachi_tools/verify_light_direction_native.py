"""How the game takes the light direction into object space, run on its own code.

The context fill 0x1413368f0 gives lit shaders g_lightDirection =
0x141283c40(0x141280580(model matrix), direction of the light set's first
directional light). This calls those two routines (native_image.py) on random
model matrices (rotation, uniform or per-axis scale, translation) and checks
the result against two candidate rules:

  full inverse:  inverse(model 3x3) * direction      <- what the port's vertex shader computes
  rigid inverse: transpose(model 3x3) * direction    <- what a first reading of 0x141280580 suggested

  python verify_light_direction_native.py
"""

from __future__ import annotations

import ctypes

import numpy as np

from native_image import NativeImage

if __name__ == '__main__':
    image = NativeImage()
    inverse = image.function(0x141280580, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p)
    direction = image.function(0x141283c40, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p)
    source, inverted, vector, out = (image.block(0x80) for _ in range(4))
    rng = np.random.default_rng(7)
    worst = {'full inverse': 0.0, 'rigid inverse': 0.0}
    cases = 4000
    for case in range(cases):
        q = rng.normal(size=4)
        q /= np.linalg.norm(q)
        w, x, y, z = q
        rotation = np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                             [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                             [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]])
        scale = rng.uniform(0.2, 3.0, 3) if case % 2 else np.full(3, rng.uniform(0.2, 3.0))
        model = np.eye(4, dtype=np.float32)        # the game's packed layout: column k = image of axis k
        model[:3, :3] = (rotation * scale).astype(np.float32)
        model[:3, 3] = rng.uniform(-500, 500, 3)
        light = rng.normal(size=3)
        light = (light / np.linalg.norm(light)).astype(np.float32)
        image.write(source, model.tobytes())
        image.write(vector, light.tobytes())
        inverse(source, inverted)
        direction(inverted, out, vector)
        native = np.frombuffer(image.read(out, 12), dtype=np.float32).astype(np.float64)
        m3 = model[:3, :3].astype(np.float64)
        candidates = {'full inverse': np.linalg.inv(m3) @ light, 'rigid inverse': m3.T @ light}
        for name, value in candidates.items():
            worst[name] = max(worst[name], float(np.abs(native - value).max() / max(1.0, np.abs(value).max())))
    for name, error in worst.items():
        print(f'{name}: largest relative difference over {cases} matrices {error:.3g}')
    assert worst['full inverse'] < 1e-4 < worst['rigid inverse']
    print('PASS: g_lightDirection = inverse(model) * light direction (the length carries 1 / scale)')
