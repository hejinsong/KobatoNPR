using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class depthShadowRendererFeature : ScriptableRendererFeature
{
    DepthShadowRenderPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new DepthShadowRenderPass(RenderPassEvent.BeforeRenderingOpaques);
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


