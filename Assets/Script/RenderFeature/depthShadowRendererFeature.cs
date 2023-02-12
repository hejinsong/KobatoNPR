using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class depthShadowRendererFeature : ScriptableRendererFeature
{
    [Serializable]
    public class Setting
    {
        public LayerMask hairLayer;
        public LayerMask faceLayer;

        [Range(1000, 5000)]
        public int queueMin = 2000;
        [Range(1000, 5000)]
        public int queueMax = 2000;

        public Material materia;
    }

    public Setting m_settings = new Setting();

    DepthShadowRenderPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new DepthShadowRenderPass(m_settings, RenderPassEvent.BeforeRenderingOpaques);
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


