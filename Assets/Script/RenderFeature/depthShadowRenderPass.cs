using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System;
using static depthShadowRendererFeature;
using static Unity.Burst.Intrinsics.X86.Avx;

class DepthShadowRenderPass : ScriptableRenderPass
{

    private FilteringSettings m_faceFilter;
    private FilteringSettings m_hairFilter;

    internal int hairColorBufferID = 0;
    internal Material m_material;
    private static readonly ShaderTagId shaderTag = new ShaderTagId("UniversalForward");
    public DepthShadowRenderPass(Setting setting, RenderPassEvent evt)
    {
        RenderQueueRange queue = new RenderQueueRange();
        queue.lowerBound = Mathf.Min(setting.queueMax, setting.queueMin);
        queue.upperBound = Mathf.Max(setting.queueMax, setting.queueMin);

        m_faceFilter = new FilteringSettings(queue, setting.faceLayer);
        m_hairFilter = new FilteringSettings(queue, setting.hairLayer);

        m_material = setting.materia;
        this.renderPassEvent = evt;
        base.profilingSampler = new ProfilingSampler("RenderFeatureShadow");
    }
    // This method is called before executing the render pass.
    // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
    // When empty this render pass will render to the active camera render target.
    // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
    // The render pipeline will ensure target setup and clearing happens in a performant manner.
    public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
    {
        int temp = Shader.PropertyToID("_HairSolidColor");
        RenderTextureDescriptor desc = renderingData.cameraData.cameraTargetDescriptor;
        cmd.GetTemporaryRT(temp, desc);
        hairColorBufferID = temp;
        RenderTargetIdentifier targetIdentifier =
            new RenderTargetIdentifier(temp, 0, CubemapFace.Unknown, -1);
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

            var draw1 = CreateDrawingSettings(shaderTag, ref renderingData, renderingData.cameraData.defaultOpaqueSortFlags);
            draw1.overrideMaterial = m_material;
            draw1.overrideMaterialPassIndex = 0;
            context.DrawRenderers(renderingData.cullResults, ref draw1, ref m_faceFilter);

            var draw2 = CreateDrawingSettings(shaderTag, ref renderingData, renderingData.cameraData.defaultOpaqueSortFlags);
            draw2.overrideMaterial = m_material;
            draw2.overrideMaterialPassIndex = 1;
            context.DrawRenderers(renderingData.cullResults, ref draw2, ref m_hairFilter);
        }
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    // Cleanup any allocated resources that were created during the execution of this render pass.
    public override void OnCameraCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(hairColorBufferID);
    }

    private ProfilingSampler m_profilingSampler = new ProfilingSampler("DepthShadowRenderPass");
}


