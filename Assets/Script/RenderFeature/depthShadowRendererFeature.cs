using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class depthShadowRendererFeature : ScriptableRendererFeature
{
    [Serializable]
    public class DepthSetting
    {
        public LayerMask m_ShadowLayer;
        public Material m_material;
        //now layer is enough
    }
    [SerializeField]
    private DepthSetting m_settings = new DepthSetting();

    DepthShadowRenderPass m_ScriptablePass;
    private int m_ShadowTexID;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new DepthShadowRenderPass(m_settings, RenderPassEvent.BeforeRenderingOpaques);
        m_ShadowTexID = Shader.PropertyToID("_HairDepthTexture");
        //m_depthShadowRT = RTHandles.Alloc(new RenderTargetIdentifier(id));
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_ScriptablePass.Setup(renderingData.cameraData.cameraTargetDescriptor, m_ShadowTexID);
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


