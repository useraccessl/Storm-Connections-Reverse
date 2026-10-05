"""COM vtable order of ID3D11DeviceContext and ID3D11Device (d3d11.h, Windows SDK).

Byte offset of a method = 8 * index. Use these only after proving that the
object behind the call really is that interface.
"""

DEVICE_CONTEXT = [
    'QueryInterface', 'AddRef', 'Release',
    'GetDevice', 'GetPrivateData', 'SetPrivateData', 'SetPrivateDataInterface',
    'VSSetConstantBuffers', 'PSSetShaderResources', 'PSSetShader', 'PSSetSamplers', 'VSSetShader',
    'DrawIndexed', 'Draw', 'Map', 'Unmap', 'PSSetConstantBuffers', 'IASetInputLayout',
    'IASetVertexBuffers', 'IASetIndexBuffer', 'DrawIndexedInstanced', 'DrawInstanced',
    'GSSetConstantBuffers', 'GSSetShader', 'IASetPrimitiveTopology', 'VSSetShaderResources',
    'VSSetSamplers', 'Begin', 'End', 'GetData', 'SetPredication', 'GSSetShaderResources',
    'GSSetSamplers', 'OMSetRenderTargets', 'OMSetRenderTargetsAndUnorderedAccessViews',
    'OMSetBlendState', 'OMSetDepthStencilState', 'SOSetTargets', 'DrawAuto',
    'DrawIndexedInstancedIndirect', 'DrawInstancedIndirect', 'Dispatch', 'DispatchIndirect',
    'RSSetState', 'RSSetViewports', 'RSSetScissorRects', 'CopySubresourceRegion', 'CopyResource',
    'UpdateSubresource', 'CopyStructureCount', 'ClearRenderTargetView',
    'ClearUnorderedAccessViewUint', 'ClearUnorderedAccessViewFloat', 'ClearDepthStencilView',
    'GenerateMips', 'SetResourceMinLOD', 'GetResourceMinLOD', 'ResolveSubresource',
    'ExecuteCommandList', 'HSSetShaderResources', 'HSSetShader', 'HSSetSamplers',
    'HSSetConstantBuffers', 'DSSetShaderResources', 'DSSetShader', 'DSSetSamplers',
    'DSSetConstantBuffers', 'CSSetShaderResources', 'CSSetUnorderedAccessViews', 'CSSetShader',
    'CSSetSamplers', 'CSSetConstantBuffers', 'VSGetConstantBuffers', 'PSGetShaderResources',
    'PSGetShader', 'PSGetSamplers', 'VSGetShader', 'PSGetConstantBuffers', 'IAGetInputLayout',
    'IAGetVertexBuffers', 'IAGetIndexBuffer', 'GSGetConstantBuffers', 'GSGetShader',
    'IAGetPrimitiveTopology', 'VSGetShaderResources', 'VSGetSamplers', 'GetPredication',
    'GSGetShaderResources', 'GSGetSamplers', 'OMGetRenderTargets',
    'OMGetRenderTargetsAndUnorderedAccessViews', 'OMGetBlendState', 'OMGetDepthStencilState',
    'SOGetTargets', 'RSGetState', 'RSGetViewports', 'RSGetScissorRects', 'HSGetShaderResources',
    'HSGetShader', 'HSGetSamplers', 'HSGetConstantBuffers', 'DSGetShaderResources', 'DSGetShader',
    'DSGetSamplers', 'DSGetConstantBuffers', 'CSGetShaderResources', 'CSGetUnorderedAccessViews',
    'CSGetShader', 'CSGetSamplers', 'CSGetConstantBuffers', 'ClearState', 'Flush', 'GetType',
    'GetContextFlags', 'FinishCommandList',
]

DEVICE = [
    'QueryInterface', 'AddRef', 'Release',
    'CreateBuffer', 'CreateTexture1D', 'CreateTexture2D', 'CreateTexture3D',
    'CreateShaderResourceView', 'CreateUnorderedAccessView', 'CreateRenderTargetView',
    'CreateDepthStencilView', 'CreateInputLayout', 'CreateVertexShader', 'CreateGeometryShader',
    'CreateGeometryShaderWithStreamOutput', 'CreatePixelShader', 'CreateHullShader',
    'CreateDomainShader', 'CreateComputeShader', 'CreateClassLinkage', 'CreateBlendState',
    'CreateDepthStencilState', 'CreateRasterizerState', 'CreateSamplerState', 'CreateQuery',
    'CreatePredicate', 'CreateCounter', 'CreateDeferredContext', 'OpenSharedResource',
    'CheckFormatSupport', 'CheckMultisampleQualityLevels', 'CheckCounterInfo', 'CheckCounter',
    'CheckFeatureSupport', 'GetPrivateData', 'SetPrivateData', 'SetPrivateDataInterface',
    'GetFeatureLevel', 'GetCreationFlags', 'GetDeviceRemovedReason', 'GetImmediateContext',
    'SetExceptionMode', 'GetExceptionMode',
]


def context_method(offset: int) -> str | None:
    index, rem = divmod(offset, 8)
    return DEVICE_CONTEXT[index] if rem == 0 and index < len(DEVICE_CONTEXT) else None


def device_method(offset: int) -> str | None:
    index, rem = divmod(offset, 8)
    return DEVICE[index] if rem == 0 and index < len(DEVICE) else None
