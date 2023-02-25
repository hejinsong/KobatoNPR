using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System;
using static depthShadowRendererFeature;
using static Unity.Burst.Intrinsics.X86.Avx;

class DepthShadowRenderPass : ScriptableRenderPass
{
    private static readonly ShaderTagId shaderTag = new ShaderTagId("UniversalForward");//hair use universal lit

    FilteringSettings m_FilteringSettings;
    public DepthShadowRenderPass(DepthSetting setting, RenderPassEvent evt)
    {
        m_FilteringSettings = new FilteringSettings(RenderQueueRange.opaque, setting.m_ShadowLayer);
        this.renderPassEvent = evt;
        base.profilingSampler = new ProfilingSampler("RenderFeatureShadow");
        m_Mat = setting.m_material;
    }
    // This method is called before executing the render pass.
    // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
    // When empty this render pass will render to the active camera render target.
    // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
    // The render pipeline will ensure target setup and clearing happens in a performant manner.
    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        //Need Dirty flag
        cmd.GetTemporaryRT(m_nameID, m_Descriptor);

        RenderTargetIdentifier targetIdentifier =
            new RenderTargetIdentifier(m_nameID, 0, CubemapFace.Unknown, -1);
        RTHandle renderTarget = RTHandles.Alloc(targetIdentifier);
        ConfigureTarget(renderTarget);
        ConfigureClear(ClearFlag.All, Color.black);
    }

    // Here you can implement the rendering logic.
    // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
    // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
    // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        CommandBuffer cmd = CommandBufferPool.Get();
        using (new ProfilingScope(cmd, m_profilingSampler))
        {
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            var drawSetting = CreateDrawingSettings(shaderTag, ref renderingData, renderingData.cameraData.defaultOpaqueSortFlags);
            drawSetting.overrideMaterial = m_Mat;
            drawSetting.overrideMaterialPassIndex = 0;
            context.DrawRenderers(renderingData.cullResults, ref drawSetting, ref m_FilteringSettings);
        }
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public void Setup(RenderTextureDescriptor cameraRTDesc,int nameID)
    {
        m_nameID = nameID;

        m_Descriptor = cameraRTDesc;
    }

    // Cleanup any allocated resources that were created during the execution of this render pass.
    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(m_nameID);
    }

    private ProfilingSampler m_profilingSampler = new ProfilingSampler("DepthShadowRenderPass");
    private int  m_nameID { get; set; }
    internal RenderTextureDescriptor m_Descriptor;
    private Material m_Mat;
}


