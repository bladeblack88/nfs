using UnityEngine;

namespace MostWantedMobile.World
{
    /// <summary>Creates a simple test road and roadside barriers at runtime.</summary>
    public sealed class PrototypeTrackBuilder : MonoBehaviour
    {
        [SerializeField, Min(50f)] private float roadLength = 300f;
        [SerializeField, Min(5f)] private float roadWidth = 14f;
        [SerializeField, Min(0.1f)] private float barrierHeight = 1.2f;

        private void Start()
        {
            BuildTrack();
        }

        [ContextMenu("Build Track")]
        public void BuildTrack()
        {
            CreateCube("Road", new Vector3(0f, -0.15f, roadLength * 0.5f),
                new Vector3(roadWidth, 0.3f, roadLength), new Color(0.12f, 0.13f, 0.15f));

            CreateCube("Left barrier", new Vector3(-roadWidth * 0.5f - 0.45f,
                barrierHeight * 0.5f - 0.1f, roadLength * 0.5f),
                new Vector3(0.5f, barrierHeight, roadLength), new Color(0.72f, 0.74f, 0.77f));

            CreateCube("Right barrier", new Vector3(roadWidth * 0.5f + 0.45f,
                barrierHeight * 0.5f - 0.1f, roadLength * 0.5f),
                new Vector3(0.5f, barrierHeight, roadLength), new Color(0.72f, 0.74f, 0.77f));

            for (int z = 5; z < roadLength; z += 10)
            {
                CreateCube("Center line", new Vector3(0f, 0.012f, z),
                    new Vector3(0.16f, 0.025f, 4.5f), new Color(0.95f, 0.85f, 0.35f));
            }
        }

        private static void CreateCube(string objectName, Vector3 position,
            Vector3 scale, Color color)
        {
            GameObject item = GameObject.CreatePrimitive(PrimitiveType.Cube);
            item.name = objectName;
            item.transform.SetParent(null);
            item.transform.position = position;
            item.transform.localScale = scale;

            var renderer = item.GetComponent<Renderer>();
            var material = new Material(Shader.Find("Universal Render Pipeline/Lit")
                ?? Shader.Find("Standard"));
            material.color = color;
            renderer.sharedMaterial = material;
        }
    }
}