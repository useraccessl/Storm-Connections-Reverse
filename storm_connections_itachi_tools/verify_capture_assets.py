import hashlib, json, struct
from pathlib import Path
from PIL import Image
import numpy as np
ROOT=Path(__file__).resolve().parent
pairs=[('83525','4efb_amt00'),('83527','4efb_amt01'),('83535','4efb_maplus01')]
result=[]
for resource,name in pairs:
    gpu=Image.open(ROOT/'gpu_captures'/('texture_'+resource+'.png')).convert('RGBA')
    asset=Image.open(ROOT/'captured_assets/preview'/(name+'.png')).convert('RGBA')
    same=gpu.size==asset.size and gpu.tobytes()==asset.tobytes()
    difference=np.abs(np.array(gpu).astype(np.int16)-np.array(asset).astype(np.int16))
    error=difference.reshape(-1,4).max(axis=0).tolist()
    nut=(ROOT/'captured_assets/textures/4efb_amt1'/(name+'.nut')).read_bytes()
    offset=0x10+struct.unpack_from('>H',nut,28)[0]
    compressed=(ROOT/'gpu_captures'/('texture_'+resource+'.bc')).read_bytes()
    exact_blocks=compressed==nut[offset:offset+len(compressed)]
    result.append({'gpu_resource':resource,'asset':name,'size':list(gpu.size),'identical_compressed_blocks':exact_blocks,'compressed_sha256':hashlib.sha256(compressed).hexdigest(),'identical_pixels':same,'max_rgba_error':error,'gpu_sha256':hashlib.sha256(gpu.tobytes()).hexdigest(),'asset_sha256':hashlib.sha256(asset.tobytes()).hexdigest()})
    print(resource,name,gpu.size,'exact compressed blocks:',exact_blocks,'max decoder RGBA difference:',error)
(ROOT/'gpu_captures/asset_matches.json').write_text(json.dumps(result,indent=2))
assert all(r['identical_compressed_blocks'] for r in result), 'GPU texture does not match original asset'
