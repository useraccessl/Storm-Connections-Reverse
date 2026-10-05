"""Run in RenderDoc 1.46's Python shell after opening an original-game RDC.

Uses the official 1.46 descriptor API, not the removed GetConstantBuffer API.
GPU execution awaits an actual capture; syntax and buffer extraction are checked
separately. Matching is by full original DXBC SHA-256, not by visual guesses.
"""
import hashlib
import json
import struct
from pathlib import Path

ROOT=Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')

def float_fields(raw,variables):
    result={}
    for variable in variables:
        count=variable.type.rows*variable.type.columns*max(1,variable.type.elements)
        offset=variable.byteOffset
        if offset+count*4>len(raw):
            result[variable.name]={'error':'buffer too short','offset':offset,'count':count}
        else:
            result[variable.name]={'offset':offset,'values':list(struct.unpack_from('<'+'f'*count,raw,offset))}
    return result

def export(controller, destination=None, include_all=False, save_textures=True):
    import renderdoc as rd
    known={hashlib.sha256(p.read_bytes()).hexdigest():p.stem for p in (ROOT/'used_shaders').glob('*.dxbc')}
    output=[]
    texture_info={str(t.resourceId):{'width':t.width,'height':t.height,'format':t.format.Name(),'name':str(t.resourceId)} for t in controller.GetTextures()}
    shader_folder=ROOT/'gpu_captures/captured_shaders'
    shader_folder.mkdir(exist_ok=True)
    textures_saved=set()
    def actions(items):
        for a in items:
            if a.flags&rd.ActionFlags.Drawcall: yield a
            yield from actions(a.children)
    for action in actions(controller.GetRootActions()):
        controller.SetFrameEvent(action.eventId,True)
        pipe=controller.GetPipelineState()
        reflections=[(stage,pipe.GetShaderReflection(stage)) for stage in (rd.ShaderStage.Vertex,rd.ShaderStage.Pixel)]
        matched={str(stage):known.get(hashlib.sha256(bytes(ref.rawBytes)).hexdigest())
                 for stage,ref in reflections if ref}
        if not include_all and not any(matched.values()): continue
        if include_all:
            for stage,ref in reflections:
                if not ref: continue
                digest=hashlib.sha256(bytes(ref.rawBytes)).hexdigest()
                matched[str(stage)]=known.get(digest,digest)
                (shader_folder/(matched[str(stage)]+'.dxbc')).write_bytes(bytes(ref.rawBytes))
        record={'event':action.eventId,'indices':action.numIndices,'shaders':matched,'constants':{},'textures':[]}
        for stage,ref in reflections:
            if not ref: continue
            blocks={}
            for index,block in enumerate(ref.constantBlocks):
                if not block.bufferBacked: continue
                desc=pipe.GetConstantBlock(stage,index,0).descriptor
                raw=bytes(controller.GetBufferData(desc.resource,desc.byteOffset,desc.byteSize))
                blocks[block.name]={'buffer':str(desc.resource),'raw_hex':raw.hex(),
                                    'fields':float_fields(raw,block.variables)}
            record['constants'][str(stage)]=blocks
        for used in pipe.GetReadOnlyResources(rd.ShaderStage.Pixel):
            record['textures'].append({'resource':str(used.descriptor.resource),'view':str(used.descriptor.view),
                                       'info':texture_info.get(str(used.descriptor.resource)),
                                       'format':used.descriptor.format.Name(),'binding':used.access.index})
            info=texture_info.get(str(used.descriptor.resource))
            if save_textures and include_all and action.eventId>1800 and info and info['width']<=512 and info['height']<=512:
                rid=used.descriptor.resource
                if str(rid) not in textures_saved:
                    save=rd.TextureSave()
                    save.resourceId=rid
                    save.destType=rd.FileType.PNG
                    controller.SaveTexture(save,str(ROOT/'gpu_captures'/('texture_'+str(rid).split('::')[-1]+'.png')))
                    textures_saved.add(str(rid))
        record['samplers']=[{'binding':s.access.index,'u':str(s.sampler.addressU),'v':str(s.sampler.addressV),
                              'min':str(s.sampler.filter.minify),'mag':str(s.sampler.filter.magnify)}
                             for s in pipe.GetSamplers(rd.ShaderStage.Pixel)]
        state=controller.GetD3D11PipelineState()
        depth=state.outputMerger.depthStencilState
        record['depth']={'enable':depth.depthEnable,'writes':depth.depthWrites,'function':str(depth.depthFunction)}
        record['cull']=str(state.rasterizer.state.cullMode)
        record['blendFactor']=list(pipe.GetBlendFactor())
        record['blend']=[{'enabled':b.enabled,'writeMask':b.writeMask,
                          'rgb':[str(b.colorBlend.source),str(b.colorBlend.destination),str(b.colorBlend.operation)],
                          'alpha':[str(b.alphaBlend.source),str(b.alphaBlend.destination),str(b.alphaBlend.operation)]}
                         for b in pipe.GetColorBlends()]
        record['targets']=[str(d.resource) for d in pipe.GetOutputTargets()]
        output.append(record)
    folder=ROOT/'gpu_captures'
    folder.mkdir(exist_ok=True)
    destination=Path(destination) if destination else folder/'frame_constants.json'
    destination.write_text(json.dumps(output,indent=2)+'\n',encoding='utf-8')
    print('Exported',len(output),'draws matching extracted game shaders to',destination)
    return output

if 'pyrenderdoc' in globals():
    pyrenderdoc.Replay().BlockInvoke(export)
elif 'ctx' in globals():
    ctx.Replay().BlockInvoke(export)
elif __name__=='__main__':
    raise SystemExit('Open the original RDC in RenderDoc, then run this script in its Python shell.')
