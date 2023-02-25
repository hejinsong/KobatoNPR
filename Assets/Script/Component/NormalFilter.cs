using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NormalFilter : MonoBehaviour
{
    public bool ExecuteFilter = false;
    // Start is called before the first frame update
    //Reference https://zhuanlan.zhihu.com/p/109101851
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    private void OnValidate()
    {
        if (ExecuteFilter)
        {
            var skinnedMeshRenderer = GetComponent<SkinnedMeshRenderer>();
            if (skinnedMeshRenderer)
            {
                ResetMeshWithAverageNorm(skinnedMeshRenderer.sharedMesh);
            }
            var meshFilter = GetComponent<MeshFilter>();
            if (meshFilter)
            {
                ResetMeshWithAverageNorm(meshFilter.sharedMesh);
            }
        }
    }

    private void ResetMeshWithAverageNorm(Mesh mesh)
    {
        var dicAverageNormal = new Dictionary<Vector3, Vector3>();

        for(var index = 0; index < mesh.vertexCount; ++index)
        {
            if(!dicAverageNormal.ContainsKey(mesh.vertices[index]))
            {
                dicAverageNormal.Add(mesh.vertices[index], mesh.normals[index]);
            }
            else
            {
                dicAverageNormal[mesh.vertices[index]] =
                    (dicAverageNormal[mesh.vertices[index]] + mesh.normals[index]).normalized;
            }
        }
        var normalVector = new Vector3[mesh.vertexCount];
        for(int i = 0; i < mesh.vertexCount; ++i)
        {
            normalVector[i] = dicAverageNormal[mesh.vertices[i]];
        }
        mesh.normals = normalVector;
    }
}
